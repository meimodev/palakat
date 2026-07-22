/**
 * CI gate for the permission model. Fails the build on two kinds of drift:
 *
 * 1. **The committed parity table no longer matches the router.** Someone
 *    changed an allow-list and did not regenerate. The table is the spec for
 *    Phase 2 and Phase 5, so a stale one is worse than none.
 * 2. **A route's `@RequirePermissions` disagrees with its RPC case.** This is
 *    the check ADR-0009 asks for, and it is the one that catches a privilege
 *    escalation introduced by a typo during transcription.
 *
 *   pnpm parity:check
 *
 * Until Phase 2 registers controllers there is nothing to compare in (2), so it
 * passes while reporting 0/166 coverage. That is intended — the gate is built
 * before the surface it guards, because afterwards is too late.
 */
import * as ts from 'typescript';
import * as fs from 'fs';
import * as path from 'path';
import { generateRows, definedPermissions, analyse } from './generate-parity-table';

const BACKEND_ROOT = path.resolve(__dirname, '..');
const REPO_ROOT = path.resolve(BACKEND_ROOT, '../..');
const COMMITTED = path.join(REPO_ROOT, 'docs/generated/rpc-parity.json');
const SRC = path.join(BACKEND_ROOT, 'src');

interface RouteBinding {
  action: string;
  permissions: string[];
  file: string;
  method: string;
}

/** Decorator calls on a node, as `{ name, args }` with string-literal args only. */
function decorators(node: ts.Node): { name: string; args: string[] }[] {
  const found: { name: string; args: string[] }[] = [];
  const mods = ts.canHaveDecorators(node) ? ts.getDecorators(node) : undefined;
  for (const d of mods ?? []) {
    if (!ts.isCallExpression(d.expression)) continue;
    const name = d.expression.expression.getText();
    const args = d.expression.arguments
      .filter(ts.isStringLiteral)
      .map((a) => a.text);
    found.push({ name, args });
  }
  return found;
}

function walk(dir: string, out: string[] = []): string[] {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      if (entry.name === 'generated' || entry.name === 'node_modules') continue;
      walk(full, out);
    } else if (entry.name.endsWith('.controller.ts')) {
      out.push(full);
    }
  }
  return out;
}

function collectRouteBindings(): RouteBinding[] {
  const bindings: RouteBinding[] = [];
  for (const file of walk(SRC)) {
    const sf = ts.createSourceFile(
      file,
      fs.readFileSync(file, 'utf8'),
      ts.ScriptTarget.Latest,
      true,
    );
    const visit = (n: ts.Node) => {
      if (ts.isMethodDeclaration(n)) {
        const decs = decorators(n);
        const action = decs.find((d) => d.name === 'RpcAction')?.args[0];
        if (action) {
          const permissions =
            decs.find((d) => d.name === 'RequirePermissions')?.args ?? [];
          bindings.push({
            action,
            permissions,
            file: path.relative(REPO_ROOT, file),
            method: n.name.getText(),
          });
        }
      }
      ts.forEachChild(n, visit);
    };
    visit(sf);
  }
  return bindings;
}

const sameSet = (a: string[], b: string[]) =>
  a.length === b.length && [...a].sort().join('|') === [...b].sort().join('|');

function main(): number {
  const failures: string[] = [];

  const rows = generateRows();
  const summary = analyse(rows, definedPermissions());

  // (1) the committed table must match what the router says today
  if (!fs.existsSync(COMMITTED)) {
    failures.push(
      `Missing ${path.relative(REPO_ROOT, COMMITTED)} — run \`pnpm parity:generate\`.`,
    );
  } else {
    const committed = JSON.parse(fs.readFileSync(COMMITTED, 'utf8'));
    const fresh = JSON.stringify({ summary, rows });
    if (JSON.stringify({ summary: committed.summary, rows: committed.rows }) !== fresh) {
      failures.push(
        'The committed parity table is stale — the router changed. Run `pnpm parity:generate` and commit the result.',
      );
    }
  }

  // (2) every route that claims an action must carry that action's allow-list
  const byAction = new Map(rows.map((r) => [r.action, r]));
  const bindings = collectRouteBindings();

  for (const b of bindings) {
    const row = byAction.get(b.action);
    if (!row) {
      failures.push(
        `${b.file}#${b.method}: @RpcAction('${b.action}') does not match any RPC action.`,
      );
      continue;
    }
    if (!sameSet(b.permissions, row.permissions)) {
      failures.push(
        `${b.file}#${b.method}: @RequirePermissions([${b.permissions.join(', ')}]) ` +
          `!= RPC allow-list for '${b.action}' ([${row.permissions.join(', ')}]).`,
      );
    }
  }

  const claimed = new Set(bindings.map((b) => b.action));
  const duplicates = bindings
    .map((b) => b.action)
    .filter((a, i, all) => all.indexOf(a) !== i);
  for (const d of new Set(duplicates)) {
    failures.push(`Action '${d}' is claimed by more than one route.`);
  }

  console.log(
    `parity: ${rows.length} actions · ${summary.unguarded} without a permission check · ` +
      `${claimed.size}/${rows.length} claimed by a REST route`,
  );
  if (summary.phantom.length) {
    console.log(`  phantom permissions (dead clauses): ${summary.phantom.join(', ')}`);
  }
  if (summary.unchecked.length) {
    console.log(`  defined but never checked: ${summary.unchecked.join(', ')}`);
  }

  if (failures.length) {
    console.error('\nPermission parity FAILED:');
    for (const f of failures) console.error(`  - ${f}`);
    return 1;
  }
  console.log('permission parity OK');
  return 0;
}

if (require.main === module) {
  process.exit(main());
}
