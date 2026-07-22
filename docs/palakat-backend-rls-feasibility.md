# Can church permissions and approval rules be expressed as RLS?

Answer to [#24](../../issues/24). Everything below was **executed** against a
local Supabase stack (Postgres 17.6) with the real Prisma schema loaded, not
reasoned about on paper. Runnable artefacts live in [`docs/spike/rls/`](./spike/rls/):

| File | What it is |
|---|---|
| `00_helpers.sql` | identity / scope / permission functions |
| `01_fixture.sql` | two churches, six actors, so cross-church leaks are testable |
| `02_policies.sql` | the policies for all three cases |
| `03_tests.sql` | 20 behavioural tests, each isolated |
| `04_case2_fix.sql` | the `security definer` remedy for case 2 |

## Verdict

| Case | Expressible as RLS? |
|---|---|
| 1. Finance approval with override | **Yes** — but only with column grants (see F3) |
| 2. Membership invitation respond/approve | **No** — needs a `security definer` function |
| 3. Church-scoped admin article management | **Premise is false** — articles are not church-scoped |

The permission model itself ported cleanly, and that was the surprise. It is
already declarative: `ChurchPermissionPolicy.policy` is a JSON blob per church
mapping a permission key to `{mode:'positionsAny', positionIds:[…]}`, and the
check in `getEffectivePermissions()` is a set intersection against the
requester's `MembershipPosition` ids. That is one SQL predicate:

```sql
create or replace function app.has_permission(perm text) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select app.is_elevated() or exists (
    select 1
    from "ChurchPermissionPolicy" p
    join "MembershipPosition" mp
      on mp."membershipId" = app.current_membership_id()
    where p."churchId" = app.current_church_id()
      and p.policy -> 'grants' -> perm -> 'positionIds' @> to_jsonb(mp.id)
  )
$$;
```

The 499 lines of `church-permission-policy.service.ts` are mostly policy
*authoring, defaulting and normalisation* — not checking. The check is nine lines
of SQL. **The risk in this migration is not the permission model.**

## Test results

19 of 20 behaved as designed. The one failure is case 2, and it is structural.

```
 1.1  treasurer approves own pending row            ALLOW   ALLOWED(1)
 1.2  treasurer approves someone else's row         DENY    BLOCKED
 1.3  treasurer re-decides an already-APPROVED row  DENY    BLOCKED
 1.4  church admin overrides another member's row   ALLOW   ALLOWED(1)
 1.5  same admin, but member-app session (aud)      DENY    BLOCKED
 1.6  church-2 admin overrides a church-1 row       DENY    BLOCKED
 1.7  plain member overrides anything               DENY    BLOCKED
 1.8  override an already-decided row               ALLOW   ALLOWED(1)
 1.9  self-approve reverting to UNCONFIRMED         DENY    ERROR(42501)
 1.10 reparent own approver onto another revenue    DENY    ERROR(42501)
 1.11 church-2 admin reads church-1 revenue         DENY    BLOCKED
 2.1  invitee rejects own pending invitation        ALLOW   ALLOWED(1)
 2.2  unrelated member responds to it               DENY    BLOCKED
 2.3  invitee reads own invitation                  ALLOW   ALLOWED(1)
 2.4  invitee ACCEPTS -> must create Membership     ALLOW   ERROR(42501)  <-- F1
 2.5  invitee self-joins an arbitrary church        DENY    ERROR(42501)
 3.1  anonymous reads a published article           ALLOW   ALLOWED(1)
 3.2  plain member lists draft articles             DENY    BLOCKED
 3.3  church admin edits an article                 DENY    BLOCKED
 3.4  platform super-admin edits an article         ALLOW   ALLOWED(1)
```

Case 1 reproduces every rule in `finance.service.ts:373-412` (same church, own
row, `UNCONFIRMED` only) and `:557-600` (override skips both the self-only and
the single-shot checks), plus the `aud='admin'` session requirement from
`rpc-router.service.ts:2174`. Test 1.5 is worth noting: the *same account* with
the *same permission* is correctly denied purely because the token's audience is
`member` rather than `admin`.

---

## F1 — Invitation-accept cannot be a policy (case 2)

Accepting an invitation creates the invitee's `Membership` row. Every other
policy derives church scope *from* `Membership`. At the moment of the write the
actor has no scope, so `app.current_church_id()` is null and any scope-based
`INSERT` policy denies. Chicken-and-egg: the operation establishes the scope
that RLS needs in order to authorise the operation.

This is not fixable by writing a cleverer policy. A policy permissive enough to
let the invitee insert is permissive enough to let them self-join any church —
test 2.5 exists to make that concrete. It moves to a `security definer`
function that revalidates the invitation and does both writes atomically
(`04_case2_fix.sql`), after which:

```
 2.4b invitee accepts via security definer RPC     ALLOW   ALLOWED(1)
 2.6  invitee accepts SOMEONE ELSE'S invitation    DENY    ERROR(42501)
 2.7  direct INSERT into Membership still blocked  DENY    ERROR(42501)
```

Expect this shape wherever a write **establishes** scope rather than operating
within it: invitation accept, church creation, first-admin bootstrap.

## F2 — RLS is row-level, not column-level

The app narrows writes twice: RLS's equivalent of *which rows* via service
checks, and *which columns* via DTO whitelists. Only the first has an RLS
counterpart. Under PostgREST the client controls the whole patch body.

Demonstrated with identical policies, varying only the grant:

```
A: grant update (status, "updatedAt")  -> permission denied
B: grant update                        -> 1 row(s) moved
```

In case B the treasurer moved their own approver row onto a *different revenue*,
silently appointing themselves approver of an entry they were never assigned to.
The policies did not stop it — every predicate still held. Only the column grant
did.

**Consequence:** every writable table needs a column-grant audit, and that
audit has no counterpart in the current codebase to port from. It is new work.

## F3 — One pair of parentheses is worth 964×

`(select app.current_church_id())` is evaluated once as an InitPlan;
`app.current_church_id()` is evaluated per row. Same logic, same results, on
200,011 revenue rows:

| Policy | Plan | Execution |
|---|---|---|
| `app.current_church_id()` | Seq Scan, fn per row | **10,707 ms** |
| `(select app.current_church_id())` | Seq Scan, InitPlan | **11.1 ms** |
| `(select …)` + index on `("churchId","createdAt")` | Index Scan | **1.13 ms** |

Both variants are *correct*. The slow one is the shape you get by writing the
policy the obvious way. This is the single strongest argument that RLS
authorship here is expert work rather than mechanical translation — a reviewer
reading for correctness will pass it.

## F4 — `Revenue` has no index on `churchId`

It has one on `isOverridden` (F5, a dead column) but none on the column every
RLS policy filters by. Under RLS `churchId` becomes an unavoidable predicate on
every query against the table, so this stops being a tuning detail. Same check
is owed for `Expense`, `Activity` and every other church-scoped table.

## F5 — The override audit trail does not exist

`Revenue`, `Expense` and `Activity` each carry `isOverridden`, `overrideStatus`,
`overrideMembershipId`, `overrideNote`, `overriddenAt`, plus an index on
`isOverridden`. **None of these five columns is ever written** — no assignment
exists anywhere outside generated Prisma code. `adminOverrideApprover()` accepts
an `overrideNote` parameter and drops it.

What actually happens on override is that the approver's `status` is mutated in
place. Afterwards an overridden approval is **indistinguishable from the
approver having decided it themselves**. The realtime event says
`isOverride: true`, but nothing durable does.

#24 named `isOverridden` and `ApprovalOverrideStatus` as defining part of the
hardest case. They carry no data. Two consequences: RLS has less to express than
the ticket assumed, *and* if that audit trail is wanted, the migration is the
moment to add it — as generated columns or a trigger, since RLS cannot write
audit fields.

## F6 — Case 3's premise is false

#24 asks about "church-scoped admin article management". `Article` has **no
`churchId` column**, and `article.service.ts:269 findAllAdmin()` calls
`assertAdmin(user)` — a global role check with no church filter in the `where`.
Articles are a single global CMS.

So case 3 is not a hard case, it is the *easiest* one: publish-status for
readers, platform-role for writers, four lines of policy. It was picked as a
hard case because the ticket assumed a scoping that the schema does not have.

## F7 — Lazy policy self-healing has no RLS equivalent

`ensurePolicyExists()` creates a church's policy row on first read, and
`normalizeStoredPolicy()` backfills keys added since the row was written. A
policy predicate cannot INSERT, so neither survives the port.

Measured on the spike database: **8 of 10 churches have no
`ChurchPermissionPolicy` row.** With the helper above, a member holding *Ketua
Jemaat* — the highest position — in one of those churches resolves to **zero
permissions**:

```
church 3 has a policy row: false
Ketua Jemaat of church 3, override permission: false
```

Today that is invisible because the row is conjured on first read. Under RLS it
is a silent, total lockout that looks like a permissions bug. The port needs
policy rows backfilled by migration and a `NOT NULL` guarantee going forward,
plus a decision about what a *missing* key inside an existing policy means.

## F8 — `Account.id` is an int; `auth.users.id` is a uuid

There is no external-identity column on `Account` — no `authUserId`, no
`firebaseUid`. The prototype had to add one:

```sql
alter table "Account" add column "authUserId" uuid;
create unique index account_auth_user_id_key on "Account" ("authUserId");
```

Every policy in the system routes through this mapping, so it is on the critical
path for the port, and it needs a backfill strategy for existing accounts.

---

## What this means for #26

The three cases were chosen as the hardest, and two of the three turned out not
to be what the ticket thought they were. The load-bearing conclusions:

1. **The permission model is not the risk.** It is already data, and it ports to
   nine lines of SQL.
2. **The risk is everything the application layer was doing implicitly** —
   column whitelists (F2), lazy self-healing (F7), identity mapping (F8),
   index assumptions (F4). None of it is visible in the permission code, so none
   of it appears in an effort estimate derived from reading that code.
3. **Combined with the parity table** (`palakat-backend-rpc-rest-parity-table.md`):
   94 of 166 actions are authenticated-but-unauthorized. RLS has no
   "authenticated therefore allowed" tier that is safe to write. Those 94 get
   policies authored from nothing, which is authorization design performed
   during a migration.

Point 3, not the three hard cases, is the real input to #26.
