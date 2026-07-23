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
  /**
   * The case authorizes by hand rather than through a helper — an inline
   * `role !== 'SUPER_ADMIN'` test, or its own `ForbiddenException`. Phase 1.5's
   * triage found 11 of these hiding inside the "94 unguarded" figure, including
   * every `admin.*` action, so a row flagged here is guarded and the helper
   * column simply cannot say so.
   */
  inlineGuard: boolean;
  line: number;
  /** REST verb from the route map, or `null` when the action is not an HTTP route. */
  verb: string | null;
  /** REST route from the route map, or `null` when the action is not an HTTP route. */
  route: string | null;
  /** The route map's judgement note, when it carries one. */
  note?: string;
}

/** A route with no RPC counterpart (decision 36 / §7) — carries its own allow-list. */
export interface ExtraRoute {
  action: string;
  verb: string;
  route: string;
  permissions: string[];
  note: string;
}

interface RouteMapEntry {
  verb: string | null;
  route: string | null;
  note?: string;
}
interface RouteMap {
  routes: Record<string, RouteMapEntry>;
  extra: ExtraRoute[];
}

/**
 * The Verb/Route judgement (ADR-0009). Hand-maintained beside this script, merged
 * onto the AST rows here. `parity:check` regenerates the same object it compares
 * against, so the merge must be deterministic — it reads only the committed file.
 */
function loadRouteMap(): RouteMap {
  const file = path.join(__dirname, 'route-map.json');
  return JSON.parse(fs.readFileSync(file, 'utf8'));
}

/**
 * Fill each row's Verb/Route from the map, failing loudly on any drift between the
 * router and the map. A new RPC action with no map entry, or a map entry for an
 * action the router dropped, both stop the build — which is how the judgement stays
 * in lock-step with the surface it describes.
 */
function mergeRouteMap(rows: ParityRow[], map: RouteMap): void {
  const mapped = new Set(Object.keys(map.routes));
  const actions = new Set(rows.map((r) => r.action));
  const missing = [...actions].filter((a) => !mapped.has(a));
  const orphan = [...mapped].filter((a) => !actions.has(a));
  if (missing.length || orphan.length) {
    const parts = [
      missing.length && `no route-map entry for: ${missing.join(', ')}`,
      orphan.length && `route-map entry for unknown action: ${orphan.join(', ')}`,
    ].filter(Boolean);
    throw new Error(
      `route-map.json is out of sync with the router — ${parts.join(' · ')}. ` +
        `Edit scripts/route-map.json.`,
    );
  }
  for (const r of rows) {
    const e = map.routes[r.action];
    r.verb = e.verb;
    r.route = e.route;
    if (e.note) r.note = e.note;
  }
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

/**
 * Authorization written inline instead of through a helper. The generator reads
 * helpers, so without this a hand-rolled check reads as no check at all — which
 * over-reports the hardening work and, worse, invites a "fix" that adds a
 * redundant guard to code that was already correct.
 */
const INLINE_GUARD =
  /SUPER_ADMIN|ForbiddenException|Insufficient (permission|role)|\brole\s*[!=]==/;

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
    const bodyText = clause.statements
      .map((s) => s.getText())
      .join('\n')
      .split('\n')
      .filter((l) => !/requireUserId\(client\)/.test(l))
      .join('\n');
    const inlineGuard = INLINE_GUARD.test(bodyText);
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
        inlineGuard,
        line: sf.getLineAndCharacterOfPosition(c.getStart()).line + 1,
        verb: null,
        route: null,
      });
    }
    pending = [];
  }

  mergeRouteMap(rows, loadRouteMap());
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
    /** No helper permission AND no inline check — the actual hardening backlog. */
    trulyUnguarded: rows.filter((r) => r.unguarded && !r.inlineGuard).length,
    /** Authorized by hand; the helper column cannot show it. */
    inlineGuarded: rows.filter((r) => r.inlineGuard).length,
    /** Passed in an allow-list and never defined — the clause is dead. */
    phantom: [...referenced].filter((p) => !defined.includes(p)).sort(),
    /** Defined and never checked — either dead, or something is under-guarded. */
    unchecked: defined.filter((p) => !referenced.has(p)).sort(),
  };
}

function fmtPerms(permissions: string[], unguarded: boolean): string {
  return permissions.length
    ? permissions.map((p) => `\`${p}\``).join('<br>')
    : unguarded
      ? '🔴 **none**'
      : '';
}

function toMarkdown(
  rows: ParityRow[],
  summary: ReturnType<typeof analyse>,
  extra: ExtraRoute[],
) {
  const lines: string[] = [
    '<!-- GENERATED by scripts/generate-parity-table.ts — do not edit by hand. -->',
    '',
    '# RPC → REST parity table (generated)',
    '',
    `**${summary.total} actions**, of which **${summary.unguarded} are authenticated but unauthorized**.`,
    '',
    'The Guard and Permissions columns are transcribed from the AST and are',
    'authoritative. **Verb and Route come from `scripts/route-map.json`** — the',
    'judgement a program cannot make (ADR-0009), merged in here. A `—` verb means',
    'the action does not become an HTTP route; the Notes column says why.',
    '',
    '| Action | Guard | Permissions (any-of) | Verb | Route | Notes |',
    '|---|---|---|---|---|---|',
  ];
  for (const r of rows) {
    const verb = r.verb ? `\`${r.verb}\`` : '—';
    const route = r.route ? `\`${r.route}\`` : '—';
    lines.push(
      `| \`${r.action}\` | \`${r.guard}\` | ${fmtPerms(r.permissions, r.unguarded)} | ${verb} | ${route} | ${r.note ?? ''} |`,
    );
  }
  lines.push('');
  lines.push('## Routes with no RPC counterpart');
  lines.push('');
  lines.push(
    'Four client calls hit the router\'s `default: throw Unknown action` today (decision 36 / §7).',
    'They have no AST row to transcribe, so their permissions are a route-map judgement, not a',
    'generated allow-list — the CI parity check treats them as documented exemptions.',
  );
  lines.push('');
  lines.push('| Action | Verb | Route | Permissions | Notes |');
  lines.push('|---|---|---|---|---|');
  for (const e of extra) {
    const perms = e.permissions.length
      ? e.permissions.map((p) => `\`${p}\``).join('<br>')
      : '🔑 auth-only';
    lines.push(
      `| \`${e.action}\` | \`${e.verb}\` | \`${e.route}\` | ${perms} | ${e.note} |`,
    );
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
  const extraRoutes = loadRouteMap().extra;

  fs.mkdirSync(OUT_DIR, { recursive: true });
  fs.writeFileSync(
    path.join(OUT_DIR, 'rpc-parity.json'),
    JSON.stringify({ summary, rows, extraRoutes }, null, 2) + '\n',
  );
  fs.writeFileSync(
    path.join(OUT_DIR, 'rpc-parity.md'),
    toMarkdown(rows, summary, extraRoutes),
  );

  console.log(
    `${summary.total} actions · ${summary.unguarded} unguarded · ` +
      `${summary.phantom.length} phantom · ${summary.unchecked.length} unchecked`,
  );
}
