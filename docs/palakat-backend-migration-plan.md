# `palakat_backend` Migration Plan — Shared Work, and the Fork

**Status:** handoff document. Written 2026-07-21 for a session that has not seen the prior conversation.
**Audience:** the next agent session, or the solo dev, picking this up cold.
**Prerequisite reading:** none. This document is self-contained; everything it depends on is linked and summarised inline.

---

## 0. Orientation — read this before doing anything

### 0.1 There are two migrations on the table, not one

| | Destination | Status |
|---|---|---|
| **Supabase port** | Remove NestJS entirely; run on Supabase (Postgres + RLS + Auth + Edge Functions + Realtime) | Live wayfinder map, [#14](https://github.com/meimodev/palakat/issues/14). **6 research tickets closed, 8 open. Go/no-go NOT made.** |
| **Cloud Run port** | Keep NestJS; move the container off EC2 to GCP Cloud Run | Fully researched and merged: [`palakat-backend-gcp-cloud-run-migration-analysis.md`](./palakat-backend-gcp-cloud-run-migration-analysis.md) |

These are **not** alternatives at the same level. Map [#14](https://github.com/meimodev/palakat/issues/14) explicitly places the second one out of its own scope:

> **Alternative hosts for Nest** (Fly, Railway, Cloud Run). A legitimate answer to the ops-burden driver, but it is not this destination — it belongs to a **no-go follow-up**, not this route.

So: **Supabase is the GO branch. Cloud Run is the NO-GO branch.** Choosing Cloud Run is materially the same act as answering [#26](https://github.com/meimodev/palakat/issues/26) "no".

### 0.2 The decision has not been made, and that is deliberate

[#26 Go or no-go on removing NestJS](https://github.com/meimodev/palakat/issues/26) is **open**. Gating it:

| Ticket | Type | Why it gates |
|---|---|---|
| [#15](https://github.com/meimodev/palakat/issues/15) Provision the Supabase spike project | task | Nothing can be prototyped against real shapes until this exists |
| [#16](https://github.com/meimodev/palakat/issues/16) Set the effort ceiling | grilling | The threshold that makes it a "no" |
| [#28](https://github.com/meimodev/palakat/issues/28) Native Supabase phone auth vs Firebase third-party | grilling | RLS can't be written until settled — the two paths give RLS different subjects |
| [#24](https://github.com/meimodev/palakat/issues/24) Can permissions be expressed as RLS? | prototype | **Highest-risk piece of the whole port** |
| [#25](https://github.com/meimodev/palakat/issues/25) One vertical slice end-to-end | prototype | Produces the measured per-module cost |
| [#23](https://github.com/meimodev/palakat/issues/23) Does the RPC router survive? | grilling | Biggest scope lever |
| [#27](https://github.com/meimodev/palakat/issues/27) Where does the surviving Node worker run? | grilling | Reports can't run on Supabase, so *something* Node-shaped survives |

### 0.3 ⚠️ Honest warning about the request that produced this document

This plan was requested with the words *"I'm ready to do big migration."* [#16](https://github.com/meimodev/palakat/issues/16) exists precisely to guard against that sentence:

> The verdict ticket needs a threshold set **before** the numbers arrive, otherwise whatever the spikes cost gets rationalised as acceptable.

**Readiness is not a finding.** The map may still legitimately end in "no" — it says so in its own Destination. Phase 0 below is therefore not ceremony to be skipped; it is the part that protects a solo dev from committing to a multi-month port on enthusiasm. If the next session finds itself skipping Phase 0 because the decision "feels made", that is the failure mode this paragraph is here to name.

### 0.4 What this document adds

The prior work produced two independent analyses that **converged without knowing about each other**:

- The Supabase research ([#18](https://github.com/meimodev/palakat/issues/18)) concluded the RPC router should be **deleted, not ported**.
- The Cloud Run analysis (§10 of the merged doc) independently concluded the WebSocket should be **deleted**, having counted that 166 of 166 RPC actions are plain CRUD.
- The Supabase research ([#22](https://github.com/meimodev/palakat/issues/22)) recommended **FCM direct over Pusher Beams**.
- The Cloud Run analysis (§10.5) independently reached **the same** recommendation, and corrected its own earlier Pusher suggestion to get there.

**Two routes, same answers.** That is what makes a shared-work phase possible: the overlap is not a compromise, it is the critical path for both branches.

---

## 1. Baseline — measured, do not re-derive

From map [#14](https://github.com/meimodev/palakat/issues/14) plus measurements taken 2026-07-21.

| | |
|---|---|
| Backend | 26k LOC TS (excl. generated), 30 modules, **27 controllers, 132 REST routes** |
| Second API surface | `src/realtime/rpc-router.service.ts` — **4,009 lines, 166 socket RPC actions**, incl. 25 MB chunked upload over WS |
| Data | 40 Prisma models, ~700-line schema, **85 `$transaction`/raw-SQL sites across 29 files** |
| Authorisation | own JWT (`aud` = user/admin/super-admin), bcrypt, Firebase phone verify, `RolesGuard`, **`church-permission-policy.service.ts` 499 lines**, plus per-service checks |
| Scheduled | birthday notifications `0 7 * * *`; report queue poll every 10 s |
| Heavy compute | `report.service.ts` **2,221 lines**, pdfkit + exceljs |
| Health | `health.service.ts` 436 lines, secret-guarded controller |
| External | Firebase Storage (files) + Firebase Auth (phone), Pusher Beams (push), Redis (socket.io adapter), Supabase (Postgres — **already**) |
| Flutter data layer | **~21 retrofit repositories** (43 files incl. `.g.dart`) in `packages/palakat_shared/lib/core/repositories/`, `socket_service.dart` **786 lines**, `http_service.dart` 393 lines |
| Tests | 22 `*.spec.ts` + fast-check property suite in `test/property/` |

**The single most important context fact:** the project is **pre-launch**. No live users, no real financial data. No data migration, no zero-downtime cutover, no dual-run, no bcrypt hash import. This is what makes a full port defensible at all — and it has an expiry date. If launch happens before [#26](https://github.com/meimodev/palakat/issues/26) is decided, the destination is redrawn and this becomes a different, much harder effort.

---

## 2. Phase 0 — Gates (blocking, both branches)

**Nothing in Phase 1+ starts until Phase 0 closes.** These are wayfinder tickets; work them one per session, per the map's own rules.

### 0.A [#15](https://github.com/meimodev/palakat/issues/15) Provision the Supabase spike project — `task`, do first

Unblocks everything else. Record: project ref, connection method, whether **Supabase branching** is available on the current plan, and whether `prisma migrate deploy` + `prisma/seed.ts` + `prisma/seed_congregation.ts` run clean.

> ⚠️ Postgres is *already* on Supabase per the EC2 deployment guide. Confirm whether the spike gets a **throwaway branch** or a separate project — do not point spikes at anything that will become production.

### 0.B [#16](https://github.com/meimodev/palakat/issues/16) Set the effort ceiling — `grilling`, do second

Must be pinned **before** [#25](https://github.com/meimodev/palakat/issues/25) produces numbers. Output: a threshold in a unit real for a solo dev (weeks full-time / calendar months / "before launch"), **and** a definition of what "no" means — stay on Nest as-is, or a reduced scope (Supabase Auth + Storage only) that is still a win.

### 0.C [#28](https://github.com/meimodev/palakat/issues/28) Phone auth fork — `grilling`, blocks [#24](https://github.com/meimodev/palakat/issues/24)

Path A (native Supabase phone) costs ≈$0.49/verification vs Firebase $0.35 — ~40% worse — but gives one auth system, real `auth.users`, working `auth.uid()`, and the Custom Access Token Hook. Path B (Firebase via Third-Party Auth) keeps the cheaper SMS but **`auth.uid()` does not work** and role claims live in Firebase custom claims forever.

Research recommended prototyping **Path B first**, as it has the unknown RLS ergonomics. Re-verify SMS pricing before committing — the fork turns on a $0.14 delta.

### 0.D [#24](https://github.com/meimodev/palakat/issues/24) RLS prototype — `prototype`, **highest risk on the map**

Three hardest real cases against the real schema: finance approval with override; membership invitation respond/approve; church-scoped admin article management. Answer what holds, what it costs in policy complexity and query performance, and what needs a `security definer` function or Edge Function instead.

**This is the ticket most likely to produce a "no".** 499 lines of imperative permission logic plus per-service checks across 26 services must become declarative RLS across ~40 tables with no application layer to fall back on.

### 0.E [#25](https://github.com/meimodev/palakat/issues/25) Vertical slice — `prototype`

Cash accounts recommended: real `$transaction` usage, church-scoped uniqueness (`@@unique([churchId, name])`), a Flutter repository consuming it. Build Supabase-only. Report **hours spent**, what was harder than expected, what got lost (typed DTOs? `class-validator`? the jest specs?), and the **multiplier for the remaining ~29 modules**.

### 0.F [#23](https://github.com/meimodev/palakat/issues/23) RPC router verdict + [#27](https://github.com/meimodev/palakat/issues/27) worker host — `grilling`

Both are heavily pre-informed by §3 below. [#23](https://github.com/meimodev/palakat/issues/23) should be close to a formality given two independent analyses already say "delete". [#27](https://github.com/meimodev/palakat/issues/27) is the honest one: if a Node worker survives regardless, **one quarter of the motivation for the whole port evaporates** — the ops-burden driver. Do not let that go unstated.

### 0.G [#26](https://github.com/meimodev/palakat/issues/26) The verdict — `grilling`, last

Weigh measured slice cost against the ceiling. State the decisive finding plainly. If go: phase ordering + abort triggers. If no-go: the reduced scope still worth doing.

**Phase 0 exit criteria:** #15, #16, #28, #24, #25, #23, #27 closed, and #26 answered with reasoning recorded.

---

## 3. Phase 1 — Shared work (do regardless of the verdict)

**This is the "nothing gets wasted" phase.** Every item is required on both branches. It can begin **in parallel with Phase 0** — it does not depend on the verdict, and doing it first makes both branches cheaper and the [#25](https://github.com/meimodev/palakat/issues/25) slice measurement more honest.

### 1.1 🔴 Fix the report-queue job-claim race — *do this first, it is a live bug*

**File:** `src/report/report-queue.service.ts:268`

`processQueue()` guards concurrency with `private isProcessing = false` — a **per-process boolean** — then claims work non-atomically:

```ts
const job = await this.prisma.reportJob.findFirst({
  where: { status: PENDING }, orderBy: { createdAt: 'asc' },
});
// ...separately:
await this.prisma.reportJob.update({
  where: { id: job.id }, data: { status: PROCESSING },
});
```

Two processes read the same PENDING row and both render it. Duplicate reports, double CPU, duplicated side effects (Pusher notification, file write).

Today exactly one process runs, which hides it. **Any** second instance — a second EC2 box, a Cloud Run autoscale event, or a Supabase worker — removes that protection **silently, with no error and no log**.

**Fix** (identical on both branches; [#20](https://github.com/meimodev/palakat/issues/20) reached the same conclusion independently):

```sql
UPDATE "ReportJob" SET status = 'PROCESSING'
WHERE id = (
  SELECT id FROM "ReportJob" WHERE status = 'PENDING'
  ORDER BY "createdAt" LIMIT 1
  FOR UPDATE SKIP LOCKED
)
RETURNING *;
```

**Acceptance:** a test that runs two concurrent claimers against a single PENDING job and asserts exactly one wins. Delete `isProcessing` — do not keep it "as well", it will mask the regression.

### 1.2 Move both cron jobs behind an external scheduler

`@Cron` in-process is incompatible with **both** target architectures — with Cloud Run request-based billing (CPU throttled outside requests, jobs silently stop) and with Supabase (no Nest process at all).

| Job | Location | Target |
|---|---|---|
| Report queue poll (10 s) | `report-queue.service.ts:268` | Supabase: pg_cron + pg_net (sub-minute supported since pg_cron 1.5). Cloud Run: Cloud Scheduler → authenticated HTTP endpoint |
| Birthday notifications (`0 7 * * *`) | `notification/birthday-notification.service.ts:15` | same |

> ⚠️ **Timezone gotcha, from [#20](https://github.com/meimodev/palakat/issues/20):** pg_cron runs in **UTC** and hosted Supabase does not expose `cron.timezone`. The `0 7 * * *` birthday job must be **pre-shifted to UTC** or rewritten with `AT TIME ZONE`. This silently sends birthday notifications at the wrong hour otherwise — WIB is UTC+7, so `0 7 * * *` would fire at 14:00 local.

**Do not** move notification-sending into a DB trigger/webhook — [#22](https://github.com/meimodev/palakat/issues/22) found `pg_net` has **no automatic retry**. Invoke from application code.

**Leave alone:** the birthday job's idempotency is already correct — `dedupeKey String? @unique` on `Notification` (`schema.prisma:677`), `create` first, catch `P2002` → `continue`, push only after the insert succeeds. Preserve this pattern exactly; it is the model §1.1 is missing.

### 1.3 Pusher Beams → FCM direct

Both routes agree, for different reasons that reinforce each other:

- [#22](https://github.com/meimodev/palakat/issues/22): Pusher's web SDK **already broke the Flutter WASM build** and was stubbed out (commit `0285286`, `packages/pusher_beams_web_stub/`). **Web push is dead today.** FCM Topics map 1:1 onto Device Interests; `firebase-admin` + `firebase_messaging` are already dependencies; FCM is free at any scale.
- Cloud Run §10.5: Pusher Channels at $49/mo · Rp 906.500 would cost **more than the Cloud Run bill it eliminates**; its free tier caps at 100 concurrent connections.

`firebase-admin` is already wired (`src/firebase/firebase-admin.service.ts` uses `auth()` and `storage()`) — it simply never calls `messaging()`. This is a config change, not a new vendor.

> ⚠️ **FCM data messages are best-effort** — OS-throttled by Android Doze and iOS background limits. Fine for notifications and admin banners. **Not** fine for report-progress ticks; see §1.5.

**Cleanup:** `packages/pusher_beams_web_stub/` and `packages/palakat_shared/lib/core/services/pusher_beams_service.dart` become deletable.

### 1.4 Permission-parity audit — the highest-value shared artifact

**This is the item that pays for itself twice, and it is the one most likely to be skipped.**

The two existing API surfaces are **not** at permission parity. Concretely:

```ts
// rpc-router.service.ts:2070 — enforces operation permissions
case 'finance.list': {
  const { user } = await this.requireAnyOperationPermission(client, [
    'ops.finance.revenue.create',
    'ops.finance.expense.create',
    'ops.approval.finance',
  ]);
  ...
}

// finance.controller.ts — JWT only, no operation check
@UseGuards(AuthGuard('jwt'))
@Get()
async findAll(@Query() query: FinanceListQueryDto, @Req() req: any) {
  return this.financeService.findAll(query, req.user);
}
```

**The REST surface is less protected than the RPC surface.** Any authenticated user reaches `financeService.findAll`.

Why this matters on **both** branches:

- **Cloud Run branch:** repointing the Flutter client at existing controllers ships a **privilege-escalation bug** across finance and probably other modules.
- **Supabase branch:** [#24](https://github.com/meimodev/palakat/issues/24) cannot write RLS policies for authorisation rules nobody has enumerated. **The audit output *is* the RLS specification.**

**Deliverable:** a table of all 166 RPC actions × required permissions × the matching REST route × whether that route enforces the same rule. Machine-checkable if possible.

**Do this before [#24](https://github.com/meimodev/palakat/issues/24), not after.** It converts the RLS prototype from "reason about 499 lines of imperative logic" into "encode a known list", which is a materially different — and much more estimable — task.

### 1.5 Retire the socket transport for request/response

Both branches delete it. The evidence, from two independent counts:

- **166 RPC actions; effectively none are realtime.** `account.list`, `church.create`, `finance.get`, `cashAccount.update` — CRUD. Request up, response back, exchange over.
- **True realtime surface is 10 `emitToRoom` call sites** in three categories:

| Category | Sites | Replacement |
|---|---|---|
| `notification.*` | `notification.service.ts` ×3 | FCM data message (§1.3) / Postgres Changes |
| `activity.*`, `finance.*`, `approval.*` banners | `rpc-router.service.ts` ×2 | FCM data message, or refetch-on-focus |
| `reportJob.*` progress | `report-queue.service.ts` ×5 | **Short-lived polling** — `GET /report-jobs/:id` every 2 s while the modal is open |

Report generation is rare, user-initiated and short; polling for ~30 s occasionally costs nothing and removes the only category that genuinely wanted a live channel.

**The refactor is cheaper than its line count suggests:**

```
$ grep -c 'this.prisma\.'             rpc-router.service.ts  →    0
$ grep -cE 'this\.[a-zA-Z]+Service\.'  rpc-router.service.ts  →  143
```

Zero direct database calls, 143 service delegations. `RpcRouterService` is a **pure transport adapter** over the same service layer the 27 controllers already use. Two transports, one brain — so this is a **transport swap, not a business-logic rewrite**. The blocker is §1.4, not the plumbing.

**Consequences when it lands:** Redis becomes unnecessary (its only job is the socket.io adapter), `socket_service.dart` (786 lines) becomes deletable, and the sticky-session and 60-minute-timeout problems disappear on the Cloud Run branch.

### 1.6 Phase 1 exit criteria

- [ ] Concurrent-claimer test passes; `isProcessing` deleted
- [ ] Both cron jobs fire from an external scheduler; birthday job verified firing at 07:00 **WIB**
- [ ] FCM sending live; Pusher Beams packages deleted
- [ ] Permission-parity table complete for all 166 actions, gaps closed
- [ ] Client on HTTP for request/response; socket carries push only (or is gone)

---

## 4. Phase 2 — The fork

Enter only after [#26](https://github.com/meimodev/palakat/issues/26).

### 4.A GO — Supabase port ([#14](https://github.com/meimodev/palakat/issues/14))

Ordering below is a **proposal for [#26](https://github.com/meimodev/palakat/issues/26) to ratify**, not a decision this document is entitled to make.

| Step | Work | Notes |
|---|---|---|
| A1 | Schema + migration tooling | Open question on the map: does Prisma stay the source of truth, or do Supabase migrations take over? Affects 40 models + 3 seed scripts. **Decide before A2.** |
| A2 | Auth cutover | Per [#28](https://github.com/meimodev/palakat/issues/28). `aud`/`role` are Supabase-reserved → `app_metadata.app_scope` / `account_role` / `account_id` (bridges UUID `sub` to integer `Account.id`). |
| A3 | RLS rollout | Driven by the §1.4 table. Expect `security definer` helpers where RLS can't express a rule. |
| A4 | Strangle the REST surface | 132 routes → PostgREST + Edge Functions, module by module, using the [#25](https://github.com/meimodev/palakat/issues/25) multiplier. |
| A5 | Retained Node worker | Report generation only (~2k lines: `report` module + renderer). Per [#17](https://github.com/meimodev/palakat/issues/17) this **cannot** be Deno: pdfkit breaks on the filesystem sandbox, exceljs has no Deno support, and 2 s CPU / 256 MB caps rule it out regardless. Host per [#27](https://github.com/meimodev/palakat/issues/27). |
| A6 | Flutter data layer | ~21 retrofit repositories → `supabase-dart` or thin Edge Function clients. Delete `socket_service.dart`. |
| A7 | Storage | Firebase Storage → Supabase Storage. **Gap:** no first-party TUS client in `supabase_flutter`; either a third-party Dart lib or non-resumable signed-URL uploads. Only matters if chunked upload survives §1.5. |
| A8 | Delete NestJS | The destination. |

**Still unspecified on the map** — surface these rather than inventing answers: test strategy once logic moves to plpgsql/Edge Functions (the 22 specs + property suite test *NestJS services*); local dev + CI once there's no Nest build; observability replacing `health.service.ts`; admin web app auth for the two Flutter web apps.

**Abort triggers** (propose to [#26](https://github.com/meimodev/palakat/issues/26)): [#25](https://github.com/meimodev/palakat/issues/25)'s multiplier exceeds the [#16](https://github.com/meimodev/palakat/issues/16) ceiling; [#24](https://github.com/meimodev/palakat/issues/24) finds a core rule inexpressible without an application layer; launch date arrives mid-port (pre-launch assumption expires — see §1).

### 4.B NO-GO — Cloud Run port

Fully specified in [`palakat-backend-gcp-cloud-run-migration-analysis.md`](./palakat-backend-gcp-cloud-run-migration-analysis.md). Condensed:

| Step | Work |
|---|---|
| B1 | Multi-stage Dockerfile (pnpm workspace hoisting; `prisma generate`). Prisma 7 + `@prisma/adapter-pg` means **no Rust engine binary** — easier than Prisma 5/6. |
| B2 | **Fonts.** `report-renderer.ts:7-14` probes absolute host paths (`/usr/share/fonts/...`) and **no `.ttf` is committed**. On a slim base image all candidates miss and PDF rendering degrades **silently**. `apt-get install fonts-dejavu-core` or commit the TTF (`nest-cli.json` already declares `"assets"`). Add a startup assertion. |
| B3 | Deploy `min-instances=1`, `max-instances=1`, instance-based billing, timeout 3600 s. **Zero code changes** at max=1. |
| B4 | Migrations from a Cloud Build step or one-shot Job — **never** at container start. |
| B5 | Multi-instance only after Phase 1: bound the Prisma pool (`max: 3`, currently unbounded at `pg`'s default 10/instance), Supabase transaction pooler (port 6543, needs `?pgbouncer=true`, disables prepared statements — verify first), audit tmpfs (Cloud Run's writable FS is **RAM**). |

**Costs** (Rp 18.500/USD, net of free tier): EC2 today Rp 377.955/bulan · Cloud Run with sockets Rp 875.790 · **Cloud Run HTTP-only + FCM ≈ Rp 383.912** · a single-church HTTP-only deployment **Rp 0** (free tier covers ≤50 active-hours/month, but only **9,1%** of an always-on vCPU — which is why §1.5 is load-bearing here).

**Note the honest framing:** Cloud Run does **not** beat EC2 on cost. It buys managed infra, zero-downtime deploys, zonal redundancy and burst capacity. Do not sell it internally as a saving.

---

## 5. Risk register

| Risk | Severity | Mitigation |
|---|---|---|
| §1.1 job race ships to a second instance | 🔴 | Fix in Phase 1, before any scale-out on any platform |
| §1.4 parity gap → privilege escalation | 🔴 | Audit before repointing any client or writing any RLS |
| [#24](https://github.com/meimodev/palakat/issues/24) finds RLS can't express core rules | 🔴 | Abort trigger; §1.4 de-risks it substantially |
| Launch before [#26](https://github.com/meimodev/palakat/issues/26) decides | 🔴 | Pre-launch is the load-bearing assumption; if it expires, redraw the destination |
| Enthusiasm overrides the [#16](https://github.com/meimodev/palakat/issues/16) ceiling | 🟠 | Set the ceiling **before** [#25](https://github.com/meimodev/palakat/issues/25) reports. See §0.3 |
| pg_cron UTC → birthday pushes at 14:00 WIB | 🟠 | Pre-shift the expression; assert in a test |
| B2 fonts degrade silently | 🟠 | Startup assertion, not a smoke test |
| Ops-burden driver not actually satisfied ([#27](https://github.com/meimodev/palakat/issues/27)) | 🟠 | State it plainly in [#26](https://github.com/meimodev/palakat/issues/26) rather than discovering it after |
| No TUS client in `supabase_flutter` | 🟡 | Only bites if chunked upload survives §1.5 |
| Test strategy undefined post-port | 🟡 | Map's "Not yet specified"; graduate after [#25](https://github.com/meimodev/palakat/issues/25) |

---

## 6. Working agreements for the next session

1. **Respect the wayfinder process.** Map [#14](https://github.com/meimodev/palakat/issues/14) is the canonical artifact. Claim a ticket by assigning it to yourself **before** starting. **One ticket per session** (research tickets excepted).
2. **Phase 0 is planning; Phase 1 is code.** The map says *"Planning only. Prototypes are throwaway spikes on scratch branches. Nothing on this map ships to `main`."* Phase 1 in this document is **not** on that map — it is shippable maintenance that happens to benefit both branches. Do not ship Phase 0 spikes.
3. **Standing preference: the laziest thing that works.** From the map: *"Deleting a subsystem beats porting it. If a spike shows a capability can simply be dropped, that is a valid and preferred answer."* §1.5 is that principle applied.
4. **Skills to consult:** `/grilling`, `/domain-modeling`, `supabase`, `supabase-postgres-best-practices`, `/research`, `/prototype`.
5. **Do not re-derive §1's baseline.** It is measured. Re-measure only if you suspect drift.
6. **Record decisions on the tickets**, not in chat — resolution comment, close, append a one-line gist to the map's Decisions-so-far.

---

## 7. Recommended immediate next actions

| Order | Action | Why |
|---|---|---|
| 1 | **§1.1 job-claim race** | Live correctness bug. Independent of every decision here. Small. |
| 2 | [#15](https://github.com/meimodev/palakat/issues/15) spike project | Unblocks all prototypes |
| 3 | [#16](https://github.com/meimodev/palakat/issues/16) effort ceiling | Must precede [#25](https://github.com/meimodev/palakat/issues/25)'s numbers |
| 4 | **§1.4 permission-parity audit** | Feeds [#24](https://github.com/meimodev/palakat/issues/24); the single highest-leverage artifact in this plan |
| 5 | [#28](https://github.com/meimodev/palakat/issues/28) phone auth fork | Blocks [#24](https://github.com/meimodev/palakat/issues/24) |
| 6 | [#24](https://github.com/meimodev/palakat/issues/24) RLS prototype | Highest-risk; most likely source of a "no" |
| 7 | [#25](https://github.com/meimodev/palakat/issues/25) vertical slice | Produces the multiplier |
| 8 | [#23](https://github.com/meimodev/palakat/issues/23), [#27](https://github.com/meimodev/palakat/issues/27) → [#26](https://github.com/meimodev/palakat/issues/26) | The verdict |

Items 1 and 4 are **shared work** and can proceed in parallel with the Phase 0 tickets. Everything else is sequential.

---

## 8. Sources

**In-repo:**
- [`docs/palakat-backend-gcp-cloud-run-migration-analysis.md`](./palakat-backend-gcp-cloud-run-migration-analysis.md) — Cloud Run branch, in full (cost, performance, §10 socket removal, §3.8 free tier)
- [`docs/palakat-backend-aws-ec2-cicd-deployment-guide.md`](./palakat-backend-aws-ec2-cicd-deployment-guide.md) — the current EC2 + Supabase + GitHub Actions deployment
- `docs/research/*.md` on branches `research/*` — the six closed research tickets. **Not on `main`;** read via `git show origin/research/<name>:docs/research/<name>.md`

**Issues:** map [#14](https://github.com/meimodev/palakat/issues/14) · closed research [#17](https://github.com/meimodev/palakat/issues/17) [#18](https://github.com/meimodev/palakat/issues/18) [#19](https://github.com/meimodev/palakat/issues/19) [#20](https://github.com/meimodev/palakat/issues/20) [#21](https://github.com/meimodev/palakat/issues/21) [#22](https://github.com/meimodev/palakat/issues/22) · open [#15](https://github.com/meimodev/palakat/issues/15) [#16](https://github.com/meimodev/palakat/issues/16) [#23](https://github.com/meimodev/palakat/issues/23) [#24](https://github.com/meimodev/palakat/issues/24) [#25](https://github.com/meimodev/palakat/issues/25) [#26](https://github.com/meimodev/palakat/issues/26) [#27](https://github.com/meimodev/palakat/issues/27) [#28](https://github.com/meimodev/palakat/issues/28)

**Code referenced:** `src/report/report-queue.service.ts:268` · `src/notification/birthday-notification.service.ts:15` · `src/realtime/rpc-router.service.ts:2070` · `src/finance/finance.controller.ts` · `src/report/report-renderer.ts:7-14` · `src/prisma.service.ts` · `src/firebase/firebase-admin.service.ts` · `prisma/schema.prisma:677` · `packages/palakat_shared/lib/core/services/socket_service.dart`

---

## 9. One-paragraph summary

`palakat_backend` is a 26k-line NestJS monolith on a single EC2 box with Postgres already on Supabase. Two migrations are live: a **Supabase port that deletes NestJS** (map [#14](https://github.com/meimodev/palakat/issues/14), 6 research tickets closed, **go/no-go still open**) and a **Cloud Run port that keeps it** (fully analysed, and by the map's own definition the *no-go* branch). Before either, a block of **shared work pays off on both paths**: an atomic job claim replacing a per-process boolean that will silently double-process reports on any second instance; both cron jobs moved behind an external scheduler with the UTC/WIB shift handled; Pusher Beams replaced by FCM (both analyses independently agree); a permission-parity audit across all 166 RPC actions, which doubles as the RLS specification [#24](https://github.com/meimodev/palakat/issues/24) needs; and retirement of the socket transport, which two independent analyses agree should be **deleted rather than ported**, since 166 of 166 RPC actions are CRUD and the router holds zero business logic. Do that work first, close the Phase 0 gates without letting readiness substitute for evidence, and the verdict in [#26](https://github.com/meimodev/palakat/issues/26) gets made on measurements rather than enthusiasm.
