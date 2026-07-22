/**
 * Generates the RPC → REST parity table from the AST of `rpc-router.service.ts`.
 *
 * The Guard and Permissions columns are transcription from source, and a
 * program transcribes without drift — which is the whole point. The gate this
 * replaces was "reviewed by someone who did not write it", and there is one
 * developer (ADR-0009). Phase 1.5 is about to rewrite 94 of these rows, so a
 * hand-maintained table would be stale the moment it lands.
 *
 * What it does NOT decide: the Verb and Route columns, and Phase 1.5's triage
 * buckets. Those need judgement the generator cannot supply — get them from a
 * fresh agent read.
 *
 *   pnpm parity:generate
 *
 * Writes:
 *   docs/generated/rpc-parity.json  — machine-readable, consumed by CI
 *   docs/generated/rpc-parity.md    — the human view
 */
import * as ts from 'typescript';
import * as fs from 'fs';
import * as path from 'path';

const BACKEND_ROOT = path.resolve(__dirname, '..');
const REPO_ROOT = path.resolve(BACKEND_ROOT, '../..');
const ROUTER = path.join(BACKEND_ROOT, 'src/realtime/rpc-router.service.ts');
const POLICY = path.join(
  BACKEND_ROOT,
  'src/church-permission-policy/church-permission-policy.service.ts',
);
const OUT_DIR = path.join(REPO_ROOT, 'docs/generated');

const PERMISSION_HELPERS = [
  'requireAnyOperationPermission',
  'requireOperationPermission',
] as const;

/**
 * Every gating helper, strongest first.
 *
 * Order matters and is not cosmetic. A case may call several — `requireUserId`
 * to get the caller, then `requireSuperAdminOrClient` to gate them — and those
 * calls are **sequential and ANDed**, not alternatives. The effective gate is
 * therefore the strongest helper present, not the first one reached. Reading it
 * as "first wins" under-reports `admin.churchRequest.approve` and `.reject` as
 * merely authenticated, which is precisely the kind of drift this generator
 * exists to prevent.
 */
const HELPERS_BY_STRENGTH = [
  ...PERMISSION_HELPERS,
  'requireSuperAdminOrClient',
  'requireAuthAny',
  'requireUserId',
] as const;

export interface ParityRow {
  /** The RPC action name, e.g. `finance.get`. */
  action: string;
  /** The strongest guard helper the case calls, or `none`. */
  guard: string;
  /** Every guard helper the case calls, in source order. They are ANDed. */
  guards: string[];
  /** The exact allow-list passed to the permission helper. Empty when unguarded. */
  permissions: string[];
  /** True when the case is authenticated but carries no permission check. */
  unguarded: boolean;
  line: number;
}

function parse(file: string): ts.SourceFile {
  return ts.createSourceFile(
    file,
    fs.readFileSync(file, 'utf8'),
    ts.ScriptTarget.Latest,
    true,
  );
}

/** String literals in an expression — the allow-list, whether array or scalar. */
function stringLiterals(node: ts.Node): string[] {
  const out: string[] = [];
  const visit = (n: ts.Node) => {
    if (ts.isStringLiteral(n)) out.push(n.text);
    ts.forEachChild(n, visit);
  };
  visit(node);
  return out;
}

/** The `handle` switch — the router's single dispatch point. */
function findDispatchSwitch(sf: ts.SourceFile): ts.CaseBlock {
  let found: ts.CaseBlock | undefined;
  const visit = (n: ts.Node) => {
    if (
      !found &&
      ts.isMethodDeclaration(n) &&
      n.name.getText() === 'handle'
    ) {
      const inner = (m: ts.Node) => {
        if (!found && ts.isSwitchStatement(m)) found = m.caseBlock;
        ts.forEachChild(m, inner);
      };
      ts.forEachChild(n, inner);
    }
    ts.forEachChild(n, visit);
  };
  visit(sf);
  if (!found) throw new Error('Could not find the dispatch switch in handle()');
  return found;
}

/** Inspect one case body for the guard helpers it calls and the allow-list it passes. */
function inspectCaseBody(clause: ts.CaseClause): {
  guard: string;
  guards: string[];
  permissions: string[];
} {
  const seen: string[] = [];
  let permissions: string[] = [];

  const visit = (n: ts.Node) => {
    if (ts.isCallExpression(n) && ts.isPropertyAccessExpression(n.expression)) {
      const name = n.expression.name.getText();
      if ((HELPERS_BY_STRENGTH as readonly string[]).includes(name)) {
        if (!seen.includes(name)) seen.push(name);
        if (
          (PERMISSION_HELPERS as readonly string[]).includes(name) &&
          permissions.length === 0
        ) {
          // arg 0 is `client`; the allow-list is everything after it.
          permissions = n.arguments.slice(1).flatMap((a) => stringLiterals(a));
        }
      }
    }
    ts.forEachChild(n, visit);
  };
  clause.statements.forEach(visit);

  const guard =
    HELPERS_BY_STRENGTH.find((h) => seen.includes(h)) ?? 'none';

  return { guard, guards: seen, permissions };
}

export function generateRows(routerFile = ROUTER): ParityRow[] {
  const sf = parse(routerFile);
  const caseBlock = findDispatchSwitch(sf);
  const rows: ParityRow[] = [];

  // A clause with no statements falls through to the next one, and shares its
  // guard. Collect those and flush when a body finally appears.
  let pending: ts.CaseClause[] = [];

  for (const clause of caseBlock.clauses) {
    if (!ts.isCaseClause(clause)) continue; // default:
    pending.push(clause);
    if (clause.statements.length === 0) continue;

    const { guard, guards, permissions } = inspectCaseBody(clause);
    for (const c of pending) {
      const action = ts.isStringLiteral(c.expression)
        ? c.expression.text
        : c.expression.getText();
      rows.push({
        action,
        guard,
        guards,
        permissions,
        unguarded: !(PERMISSION_HELPERS as readonly string[]).includes(guard),
        line: sf.getLineAndCharacterOfPosition(c.getStart()).line + 1,
      });
    }
    pending = [];
  }

  return rows;
}

/** `ALL_PERMISSIONS` as declared by the policy service — the defined universe. */
export function definedPermissions(policyFile = POLICY): string[] {
  const sf = parse(policyFile);
  let out: string[] = [];
  const visit = (n: ts.Node) => {
    if (
      ts.isVariableDeclaration(n) &&
      n.name.getText() === 'ALL_PERMISSIONS' &&
      n.initializer
    ) {
      out = stringLiterals(n.initializer);
    }
    ts.forEachChild(n, visit);
  };
  visit(sf);
  if (out.length === 0) throw new Error('Could not read ALL_PERMISSIONS');
  return out;
}

export function analyse(rows: ParityRow[], defined: string[]) {
  const referenced = new Set(rows.flatMap((r) => r.permissions));
  return {
    total: rows.length,
    unguarded: rows.filter((r) => r.unguarded).length,
    /** Passed in an allow-list and never defined — the clause is dead. */
    phantom: [...referenced].filter((p) => !defined.includes(p)).sort(),
    /** Defined and never checked — either dead, or something is under-guarded. */
    unchecked: defined.filter((p) => !referenced.has(p)).sort(),
  };
}

function toMarkdown(rows: ParityRow[], summary: ReturnType<typeof analyse>) {
  const lines: string[] = [
    '<!-- GENERATED by scripts/generate-parity-table.ts — do not edit by hand. -->',
    '',
    '# RPC → REST parity table (generated)',
    '',
    `**${summary.total} actions**, of which **${summary.unguarded} are authenticated but unauthorized**.`,
    '',
    'The Guard and Permissions columns are transcribed from the AST and are',
    'authoritative. **Verb and Route are not generated** — they need judgement,',
    'and a fresh agent read supplies it (ADR-0009).',
    '',
    '| Action | Guard | Permissions (any-of) | Verb | Route |',
    '|---|---|---|---|---|',
  ];
  for (const r of rows) {
    const perms = r.permissions.length
      ? r.permissions.map((p) => `\`${p}\``).join('<br>')
      : r.unguarded
        ? '🔴 **none**'
        : '';
    lines.push(`| \`${r.action}\` | \`${r.guard}\` | ${perms} | | |`);
  }
  lines.push('');
  lines.push('## Permission findings');
  lines.push('');
  lines.push(
    `**Phantom** — referenced in an allow-list, never defined in \`ALL_PERMISSIONS\`. The clause is dead:`,
  );
  lines.push('');
  for (const p of summary.phantom) lines.push(`- \`${p}\``);
  if (!summary.phantom.length) lines.push('- _none_');
  lines.push('');
  lines.push(
    `**Unchecked** — defined and never checked. Either dead, or the matching actions are under-guarded:`,
  );
  lines.push('');
  for (const p of summary.unchecked) lines.push(`- \`${p}\``);
  if (!summary.unchecked.length) lines.push('- _none_');
  lines.push('');
  return lines.join('\n');
}

if (require.main === module) {
  const rows = generateRows();
  const defined = definedPermissions();
  const summary = analyse(rows, defined);

  fs.mkdirSync(OUT_DIR, { recursive: true });
  fs.writeFileSync(
    path.join(OUT_DIR, 'rpc-parity.json'),
    JSON.stringify({ summary, rows }, null, 2) + '\n',
  );
  fs.writeFileSync(
    path.join(OUT_DIR, 'rpc-parity.md'),
    toMarkdown(rows, summary),
  );

  console.log(
    `${summary.total} actions · ${summary.unguarded} unguarded · ` +
      `${summary.phantom.length} phantom · ${summary.unchecked.length} unchecked`,
  );
}
