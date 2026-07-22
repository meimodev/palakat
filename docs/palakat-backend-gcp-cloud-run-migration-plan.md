# `palakat_backend` → GCP Cloud Run: Migration Plan (HTTP-only + FCM)

**Date:** 2026-07-21 · **Revised:** 2026-07-22 (approved — see §0.0; scope grilled — see §0.05; **execution status — see §0.01**)
**Companion:** [`palakat-backend-gcp-cloud-run-migration-analysis.md`](./palakat-backend-gcp-cloud-run-migration-analysis.md) — the *whether*, now historical. This document is the *how*, and it is the single live plan for the backend migration.
**Supersedes for deployment:** the current EC2 + GitHub Actions deployment, once Phase 8 completes.

---

## 0.0 ✅ Status: approved. The fork is closed and this is the surviving branch.

**[#26](https://github.com/meimodev/palakat/issues/26) is answered: no-go on removing NestJS.** See
[ADR-0006](./adr/0006-no-go-on-removing-nestjs.md), 2026-07-22. This document is no longer gated.

There were two migrations on the table — a Supabase port that removed NestJS, and this one, which keeps
it — and Cloud Run was the **no-go** branch. It is now simply the plan. The handoff document that held both
branches open (`palakat-backend-migration-plan.md`) was deleted on consolidation; its verdict lives in
ADR-0006, its effort framing in [ADR-0002](./adr/0002-effort-ceiling-and-meaning-of-no.md), and its measured
baseline in §0.3 below.

The decisive finding was that a "go" would not have removed GCP: report generation cannot run on Edge
Functions ([#17](https://github.com/meimodev/palakat/issues/17)) and the surviving Node worker lands on
Cloud Run Jobs ([#27](https://github.com/meimodev/palakat/issues/27)), so the port would have ended with
three platforms rather than one. Consolidation was the driver, and it never arrived.

> **What this does *not* license.** Approval settles the destination, not the sequencing. Every decision
> in §0 and every risk in §13 stands unchanged, and the "pre-launch" caveat below is unchanged —
> `palakat_admin` is live, so the daily `pg_dump` starts now.

Effort framing retained from the grilling session of 2026-07-21 — see
[ADR-0002](./adr/0002-effort-ceiling-and-meaning-of-no.md). **It is now historical**: it judged the
Supabase port, and that fork is closed. The live bar is §0.05's.

| | |
|---|---|
| **Effort ceiling for the alternative** | ~12–15 weeks solo FTE for the Supabase port. Beyond it, #26 is a no. **Expired with the fork.** |
| **What "no" commits to** | This plan in full — socket deleted, REST surface built, Cloud Run. Not "stay as we are". |
| **Marginal cost of "no"** | **8–12 weeks** beyond genuinely shared work (decision 23 — the earlier 3–5 omitted the client work). Re-derived to **~10–14 weeks** by §0.05. |

---

## 0.01 ⏱️ Where the work actually is — read this first

**Last updated: 2026-07-22.** Execution is tracked on a wayfinder map,
**[#41](https://github.com/meimodev/palakat/issues/41)**, with one ticket per phase. This section is
the summary; the map is the live index and the tickets hold the detail. **Update this section
whenever a phase moves** — a session that reads only this document must be able to pick up work
without opening the tracker first.

| Phase | State | Where |
|---|---|---|
| **0** Correctness fixes | ✅ merged | [#35](https://github.com/meimodev/palakat/pull/35) |
| **3a** Birthday timezone | ✅ merged | [#54](https://github.com/meimodev/palakat/pull/54) · `d26576c` |
| **1** Permission layer + generated parity table | ✅ merged | [#55](https://github.com/meimodev/palakat/pull/55) · `f76313d` |
| **1.5** Authorization hardening | 🔄 **in progress** — triage done, first tranche in review | [#45](https://github.com/meimodev/palakat/issues/45), [#56](https://github.com/meimodev/palakat/pull/56) |
| **2** REST surface | ⛔ blocked on 1.5 | [#46](https://github.com/meimodev/palakat/issues/46) |
| **4** FCM push | 🟢 takeable now — independent of Phase 2 | [#47](https://github.com/meimodev/palakat/issues/47) |
| **5**–**9**, **3b** | ⛔ blocked, in plan order | [#48](https://github.com/meimodev/palakat/issues/48)–[#53](https://github.com/meimodev/palakat/issues/53) |
| Daily `pg_dump` (decision 21 — *not* a phase, and overdue) | 🟢 **unstarted, needs GCS credentials** | [#42](https://github.com/meimodev/palakat/issues/42) |

### What Phase 1 built, that Phase 2 depends on

- `PermissionsGuard` (`src/auth/permissions.guard.ts`) — a verbatim port of the RPC path's
  `requireAnyOperationPermission`, **including** attaching `churchId` to the request and the fallback
  to resolving it from the membership. §6's code sketch omits that fallback; the shipped guard has it,
  and the guard is the reference, not the sketch.
- `@RequirePermissions(...)` and `@RpcAction('<action>')` (`src/auth/`). Every Phase 2 route carries both.
- **`pnpm parity:generate`** → `docs/generated/rpc-parity.{json,md}`. Generated, never hand-edited.
- **`pnpm parity:check`** — CI gate (`.github/workflows/palakat-backend-ci.yml`, the repo's first
  PR-triggered CI). Fails if the committed table is stale, or if a route's `@RequirePermissions`
  disagrees with its RPC allow-list. It also prints **`n/166` actions claimed by a REST route**,
  which is Phase 2's completeness measure.

> ⚠️ **The parity table sees helpers, not authorization.** It reads `requireOperationPermission` and
> friends. It cannot see a guard inside a service (`ChurchPermissionPolicyService.assertCanManagePolicy`)
> and, until Phase 1.5 taught it to, could not see an inline `if (auth?.role !== 'SUPER_ADMIN')`.
> **A guard it cannot see reads exactly like a guard that is not there.** Rows now carry
> `inlineGuard`, and the summary separates `trulyUnguarded` from `unguarded` — use the former.
>
> ⚠️ **It also walks only one of the two doors.** The generator reads the RPC `handle()` switch. The
> 27 REST controllers reach the same services independently and are invisible to it. Phase 1.5d found
> `approver.update` guarded in the switch the table reads and **unguarded** in the controller it does
> not — `PATCH /approver/:id` let any signed-in account set any approver's status. Phase 2 deletes all
> 27 controllers, which closes this door by construction; until it lands, a green table is a statement
> about the RPC surface alone.

### What Phase 1.5 has established so far

**The "94 unguarded actions" figure is a router-level measurement and should not be planned against.**
It mixes three populations — see [`…-phase-1.5-authorization-triage.md`](./palakat-backend-phase-1.5-authorization-triage.md):

| | Count | |
|---|---:|---|
| Inline-guarded | 11 | Authorizes by hand rather than via a helper. Guarded. **Not work.** |
| Scoped-arg | 27 | Passes `user` or a caller-derived id. **All read (#59): all 27 enforce. Not work.** |
| **Bare** | **56** | No helper, no inline check, nothing caller-derived reaches the service. **No layer can be enforcing anything.** |

Done: `sub.join` room authorization (§3.1); `ops.approvalRule.manage` now enforced on all five
`approvalRule.*` actions — that finding is closed, and the generator proves it with `unchecked: []`;
and [#59](https://github.com/meimodev/palakat/issues/59), which read all 27 scoped-arg actions and
found every one of them genuinely enforcing. **Nothing moved out of the 27, so the backlog is still
exactly the 56 bare actions.**

#59 did find one hole, on a door the parity table does not walk — `approver.service.update` took an
**optional** requester id and ran its self-only check only `if (typeof … === 'number')`, and
`PATCH /approver/:id` passed nothing. Fixed by resolving the requester inside the service so no caller
can reach the write without an identity. **Generalise the shape, not the instance: an optional
identity parameter whose absence silences the check is fail-open by omission.** A sweep found exactly
one other, `churchRequest.findAll`, tracked separately.

[#57](https://github.com/meimodev/palakat/issues/57) then gated **22 of the 26 bare church-scoped
writes**, taking the router from 123 to 103 actions without a permission check. One new permission
key, `ops.church.manage` (the church's own structure — profile, columns, positions, location,
documents, files), with the same default positions as `ops.approvalRule.manage`; the rest reuse
`ops.activity.create`, `ops.report.generate` and `ops.members.invite`. `location.create`/`.delete`
went to super-admin as national reference data.

> ⚠️ **The parity table names actions, not audiences — and that decides the answer.** The four writes
> #57 could *not* gate (`membership.create`, `membership.update`, `account.update`,
> `document.update`) are the ones the **member app** calls: joining a church, editing your own
> membership, profile, certificate. A leadership permission on those locks members out of their own
> records, and on `membership.create` it is circular. They need self-scoping instead —
> [#63](https://github.com/meimodev/palakat/issues/63). Two rows can look identical in the table and
> have opposite correct answers. **Phase 2 writes REST routes from this table; the audience is not in
> it.** Callers live in `packages/palakat_shared/lib/core/repositories`, not `apps/*/lib` — a sweep of
> the app trees reports almost everything uncalled and is wrong.

Remaining, split off [#45](https://github.com/meimodev/palakat/issues/45) and blocking it:
[#58](https://github.com/meimodev/palakat/issues/58) bare reads → service scoping ·
[#63](https://github.com/meimodev/palakat/issues/63) the four member-app writes → self-scoping ·
[#60](https://github.com/meimodev/palakat/issues/60) the `ops.approval.finance` widening decision ·
[#61](https://github.com/meimodev/palakat/issues/61) the `GET /church-request` read leak.

---

## 0.05 Scope grilling, 2026-07-22 — the freeze, the bar, and eight scope answers

A grilling session after approval walked the plan's open branches. Eleven decisions, recorded as
decisions 26–36 in §0 and as three ADRs. Four of them change the shape of the work, so they are
summarised here rather than left to be discovered in the decision table.

**1. `palakat` does not launch until this plan completes** — [ADR-0007](./adr/0007-release-freeze-and-the-14-week-bar.md).
Every aggressive choice here rests on being unreleased. Launching mid-plan reinstates §10.2's hard
gate, which depends on update-gate tooling that does not exist.

**2. The bar on this plan is 14 weeks**, with a named descope ladder — same ADR. ADR-0002's ceiling
judged the *other* branch and expired when the fork closed; with the freeze in place, **this plan's
duration is the launch delay**, and that had no bar at all.

> Descope ladder, in order: **`palakat_super_admin`** (33 call sites, never deployed, nothing depends
> on it), then **the 31 uncalled routes** (decision 27 put them in; they are the cheapest thing to
> take back out).

**3. The 94 unguarded actions are fixed on the RPC path *before* Phase 2** —
[ADR-0008](./adr/0008-authorization-hardening-precedes-transport.md). §6 said port verbatim; ADR-0006
said fix them. Both could not hold. Decisive: under verbatim parity **94 of 166 routes are not
permission-bearing**, so Phase 2's exit gate has nothing to assert against 57% of the surface and
goes green while covering the minority.

**4. The parity table is generated and CI-asserted, not human-reviewed** —
[ADR-0009](./adr/0009-parity-table-is-generated-not-reviewed.md). The gate said *"reviewed by someone
who did not write it"*; there is one developer. The security-critical columns are transcription, and
a program transcribes without drift.

Two answers deliberately run against a recommendation, recorded so they are not re-argued as
oversights:

- **Decision 27** ports all 166 actions including the 31 nothing calls, against the parity table's own
  *"delete candidates, not port candidates."* Uniform process was preferred over per-action judgement
  on the phase that can ship a privilege escalation. They are second on the descope ladder.
- **Decision 35** lets the EC2 guide's deletion stand rather than keeping it until Phase 8. §13's
  rollback ladder carries the retrieval command instead.

> ⚠️ **"Pre-launch" is not uniform, and this plan leans on it heavily.** `palakat` (mobile) has never been
> released — zero `v*` tags. `palakat_super_admin` has never been deployed — no workflow runs. But
> **`palakat_admin` is live on Vercel**, with successful production deploys on 2026-03-18 and 2026-03-20.
> Per decision 21 the data behind it is pilot/internal and disposable, which is what keeps the aggressive choices
> here defensible — but it is a live deployment, so the **daily `pg_dump` starts now**, not at some future
> onboarding event. If that pilot becomes a real congregation, decisions 12, 16 and ADR-0002 all need revisiting
> together.

### The freeze is lifted

Nothing here is gated any more. Phases 2, 5, 7, 8 and 9 — frozen until now because they carry a transport
or permission opinion — are open.

Work already banked while the fork was open, all of which was chosen for being verdict-independent and
none of which is wasted:

| Done | Where |
|---|---|
| Phase 1 parity table — all 166 RPC actions mapped to verb + route + guard. **Superseded by the generated table** (§0.01); kept as the human-derived baseline the generator was validated against | [`…-rpc-rest-parity-table.md`](./palakat-backend-rpc-rest-parity-table.md) ([#33](https://github.com/meimodev/palakat/pull/33)) |
| Stale-job reaper, atomic `SKIP LOCKED` claim, bundled PDF font, dead-code deletions | [#35](https://github.com/meimodev/palakat/pull/35) |
| RLS feasibility evidence — kept as the record of *why*, and the input if this is reopened | [`…-rls-feasibility.md`](./palakat-backend-rls-feasibility.md) ([#34](https://github.com/meimodev/palakat/pull/34)) |

> ⚠️ **The 94 has since been re-derived to 56** by Phase 1.5's triage — see §0.01 and §6.5. The
> paragraphs below are kept as written because they record why Phase 1.5 exists; **do not size the
> work from them.**

**Carried in from the closed fork as new Phase 2 scope:** the parity table found **94 of 166 actions
authenticated but unauthorized**, plus a phantom permission (`ops.approval.finance`, referenced and never
defined), an unchecked one (`ops.approvalRule.manage`), and four client calls with no server handler. That
is a live security finding, not a migration artifact — it does not go away by staying on Nest, and the REST
surface must not be built on top of it unexamined.

**Phase 6 was never no-go-only work.** Report generation cannot run on Deno
([#17](https://github.com/meimodev/palakat/issues/17)), so a Node worker survives on Cloud Run
([#27](https://github.com/meimodev/palakat/issues/27)) under either verdict — the observation that
**a "go" would not have removed GCP** is precisely what decided
[#26](https://github.com/meimodev/palakat/issues/26). See [ADR-0006](./adr/0006-no-go-on-removing-nestjs.md).

---

## 0. Decisions taken

These are settled **conditional on #26 answering "no"**. The plan below implements them; it does not
re-argue them.

| # | Decision | Consequence |
|---|---|---|
| 1 | **WebSocket removed, handed to FCM** | Scale-to-zero becomes real. This is what makes Cloud Run cheaper than EC2. |
| 2 | **Full REST parity** — not an RPC-over-HTTP shim | Phase 2 is **3–5 weeks**: register 24 dead modules, build the permission layer from nothing, close a 131→166 route gap. The largest single cost in this plan. |
| 3 | **Database stays on Supabase**, Free tier, Southeast Asia | DB costs **Rp 0**. Total run cost is compute only. Free-tier ceilings become risks — §11. |
| 4 | **Region `asia-southeast1`** (Singapore) | Matches Supabase's Southeast Asia region. DB round-trip stays intra-metro. |
| 5 | **FCM topics + bare change signals** | No token registry. Content never leaves the authenticated path. |
| 6 | **`min-instances=0`, cold starts accepted** | Cheapest possible. 2–5 s on the first request after idle. Reversible. |
| 7 | ~~**Hard `-breaking` update gate immediately**~~ | **Superseded by decision 15.** The app has never been released and no update-gate mechanism exists. |
| 8 | **Birthday cron pinned to `Asia/Makassar`**, date-matching fixed | Behaviour change: notifications move from ~15:00 to 07:00 local. |
| 9 | **`Asia/Makassar` is app-wide, not per-church** | GMIM is a single Minahasa synod; no church sits in another Indonesian zone. `Church` gains no timezone column. Glossary term: **Church-local day** (`CONTEXT.md`). The superseded handoff plan said WIB; this resolves that disagreement in favour of WITA. |
| 10 | **Under a "go", identity comes from the token and scope from the row** | Not a Cloud Run decision, but it constrains Phase 1: the guard's behaviour is the thing RLS would have to reproduce. [ADR-0001](./adr/0001-identity-from-jwt-scope-from-row.md). |
| 11 | **There is no single cost number — two scales and a crossover** | Free tier covers launch scale and nothing like the modelled load. §0.1 and §14.1 are priced twice. **At target scale this migration is not a saving.** |
| 12 | **Free serves production until the first real congregation, then Pro** | Trigger is an onboarding event, not a usage threshold. Requires a *daily* `pg_dump` to GCS, not only the pre-migration one. |
| 13 | **Push splits by category — content-free, not notification-free** | `notification.*` keeps an OS-rendered generic title/body; change signals stay data-only. Reverses §9.1's uniform data-only send. [ADR-0003](./adr/0003-push-splits-by-category.md). |
| 14 | **Change signals invalidate; they never trigger a refetch** | Refetch happens when a screen is next viewed. This is the fan-out control that keeps decision 11's crossover where it is. |
| 15 | **The hard `-breaking` gate is deleted** | `version: 1.0.0+1`, **zero `v*` tags — never released**, and no update-gate mechanism exists in the backend or the client. Decision 7 assumed tooling that does not exist to drain a client base that does not exist. Revisit only if launch precedes Phase 5. |
| 16 | **Phase 8's cutover ceremony is kept in full, as a rehearsal** | Deliberately *not* symmetrical with 15: the gate needed unbuilt tooling, the soak needs only patience. A soak that finds nothing costs nothing, and the runbook gets learned while mistakes are free. |
| 17 | **All 132 route decorators are deleted; every route is written from the parity table** | Coverage is uneven and the gaps sit where authority is highest (`admin`: 26 RPC actions vs 8 decorators) and the trust boundary widest (`file`: 11 vs 6). `finance-entry` has no controller at all. Uniform process beats per-module judgement on the phase that can ship a privilege escalation. |
| 18 | **REST is deliberately stricter than RPC on input validation** | The global `ValidationPipe` is HTTP-only and the gateway has no `@UsePipes`, so **production validates ~4 of 166 actions**. Parity means permissions and success semantics — **not** porting the absence of validation. The parity table gains a request-shape column; the 54 DTOs become candidates to verify, not the source of truth. |
| 19 | **Uploads: constrain at signing, verify at finalize** | Firebase Storage rules do **not** apply to GCS signed URLs, so enforcement is built explicitly on both sides. [ADR-0004](./adr/0004-upload-trust-boundary.md). |
| 20 | **24 juta requests/bulan is a stress case, not a forecast** | It was derived from "2 hrs/day connected per user" — a socket-era assumption — and contradicts the same analysis's 200-user figure by 1,7× per user. A bottom-up estimate from real screen flows replaces it; measurement replaces both. |
| 21 | **`palakat_admin` is already deployed** — pilot use, disposable data | "Pre-launch" holds for `palakat` (never released) and `palakat_super_admin` (never deployed), **not** for the admin web app: successful production deploys on 2026-03-18 and 2026-03-20. Consequence: the **daily `pg_dump` starts now**, not at first congregation. |
| 22 | **Phase 5 covers three clients, ~180 call sites** | Neither admin app imports `palakat_shared/core/repositories/` — **zero imports each**. `palakat_super_admin` is migrated, not deleted: church-request approval and song management have no other home. |
| 23 | **The no-go branch costs 8–12 weeks, not 4–5** | [ADR-0002](./adr/0002-effort-ceiling-and-meaning-of-no.md) named the Flutter work fork-specific and then omitted it from the total. Ceiling stays 12–15 weeks as a **calendar** limit — so it is now a **~1× bar, not 3×**, and a "no" is materially more likely. |
| 24 | **`/internal/*` runs as a second, IAM-protected Cloud Run service** | Same image, `--no-allow-unauthenticated`. Replaces hand-verifying `aud`+`email` on a public service. [ADR-0005](./adr/0005-internal-endpoints-separate-service.md). |
| 25 | **`BIPRA` and `Column` enter the glossary** | Both appear in FCM topic names (`church.{id}_bipra.{BIPRA}`, `church.{id}_column.{id}`) and neither is decodable from the repo. `Column` collides with "table column" in documents full of DDL. |
| 26 | **The full plan stands, Phases 0→9** | The fork closing did not reopen the scope. ADR-0002 defined "no" as this plan in full, and that commitment survives the fork it was written for. |
| 27 | **All 166 actions are ported, including the 31 nothing calls** | Uniform process over per-action judgement, extending decision 17. Runs against the parity table's own "delete candidates, not port candidates" — accepted knowingly, and they sit second on §0.05's descope ladder. |
| 28 | **`palakat` does not launch until this plan completes** | [ADR-0007](./adr/0007-release-freeze-and-the-14-week-bar.md). Decision 15 holds, R7 stays retired, R7b stays dormant. Launch is downstream of Phase 9. |
| 29 | **14-week bar on this plan, with a named descope ladder** | [ADR-0007](./adr/0007-release-freeze-and-the-14-week-bar.md). ADR-0002's ceiling judged the other branch and expired with the fork; the freeze makes this plan's duration the launch delay. |
| 30 | **Rate limiting on the public auth surface, in Phase 2** | Five unauthenticated password endpoints go on a public URL. `ThrottlerModule` global, `@Throttle` tightened on `/auth/*`. Credential stuffing is also a billing event under `min-instances=0`. |
| 31 | **The 94 unguarded actions are fixed on RPC before Phase 2** | [ADR-0008](./adr/0008-authorization-hardening-precedes-transport.md). New Phase 1.5. Without it Phase 2's security gate covers 72 of 166 routes and reports green. |
| 32 | **The parity table is generated from the AST and asserted in CI** | [ADR-0009](./adr/0009-parity-table-is-generated-not-reviewed.md). Replaces a review gate a solo dev cannot satisfy. A fresh agent reads the judgement columns the generator cannot check. |
| 33 | **Phase 3 splits — 3a on EC2, 3b at migration** | Every mechanism in Phase 3 is GCP, and the plan placed it on EC2. Only the birthday timezone fix pays off on EC2, and it needs no GCP at all. |
| 34 | **The bottom-up request estimate is dropped** | Decision 20 asked for one; decisions 12 and 14 made it gate nothing, and it would model a client layer Phase 5 rewrites. Instrument from day one instead — R20's own mitigation. |
| 35 | **The EC2 deployment guide stays deleted** | Against the recommendation to keep it until Phase 8. §13's rollback ladder carries the `git show` retrieval command so the runbook is findable without knowing it existed. |
| 36 | **`approver.delete` and the three `churchLetterhead.*` routes are built** | Four client calls hit `default: throw Unknown action` today. `ChurchLetterheadService` exists and is unreachable; per-church letterheads are a wanted feature. An approver who cannot be removed is an authorization problem. |

### 0.1 What it costs

The socket is why Cloud Run was 2,3× EC2 — an instance holding any open WebSocket bills as active, defeating
scale-to-zero. Removing it removes that floor.

**But "database Rp 0" is not a property of this plan — it is a property of being small.** Per decision 11, there
are two prices, and which one applies is set by request volume, not by architecture.

#### At launch scale — one church, ~200 users

| Architecture | Compute | Database | **Total** |
|---|---:|---:|---:|
| EC2 today (socket, always on) | Rp 378.029 | Rp 0 | **Rp 378.029** |
| **Cloud Run HTTP-only + FCM** | Rp 0 | Rp 0 (Free) | **Rp 0** |

Here the migration is unambiguously better: free tier covers compute *and* database, and two line items are
deleted outright — **Redis** (never needed without the Socket.IO adapter; the Memorystore option was
Rp 666.000/bulan) and **Pusher Beams** (folded into FCM, which is free).

#### At the stress case — 4.000 users, 24 juta requests/bulan

> ⚠️ **This is an upper bound, not a forecast** (decision 20). The 24 juta figure comes from the analysis's
> "2 hrs/day connected per user" — a **socket-era** assumption for an architecture that no longer has a
> persistent connection, and one that contradicts the same document's 200-user figure by 1,7× per user. A
> bottom-up estimate from real screen flows replaces it; measurement replaces both.

| Architecture | Compute | Database | **Total** |
|---|---:|---:|---:|
| EC2 today (socket, always on) | Rp 378.029 | Rp 0 | **Rp 378.029** |
| Cloud Run **with** socket (rejected) | Rp 875.790 | — | **Rp 875.790+** |
| Cloud Run HTTP-only + FCM, 180h active | Rp 226.810 | Rp 462.500 (Pro) | **Rp 689.310** |
| Cloud Run HTTP-only + FCM, 90h active | Rp 162.800 | Rp 462.500 (Pro) | **Rp 625.300** |

**At target scale this migration is not a saving.** It costs roughly Rp 250–310 ribu/bulan more than EC2, and
buys managed infrastructure, zero-downtime deploys, zonal redundancy, burst capacity, and — via Pro — real
automated backups and PITR for a church's financial records. That is a defensible purchase. It is not a discount,
and it must not be sold internally as one.

#### The crossover

Supabase Free allows **5 GB egress/bulan** (and 500 MB database, 50.000 MAU; paused after 1 week idle). Cloud Run
is GCP and Supabase SEA is not, so **every query counts as egress** — R3 says so, and the earlier version of this
table then ignored it.

```
5 GB ÷ 24 juta requests  =  208 bytes per response, everything included
```

That is not achievable with real read shapes. At a realistic ~1 KB average the Free ceiling is **≈5 juta
requests/bulan**, or **≈800–1.600 users** at this plan's own 6.000 requests/user/month.

> **Decision 12:** the trigger to move to Pro is **the first real congregation onboarding**, not a usage
> threshold. It arrives earlier than the ceilings and cannot be missed. Until then Free serves production,
> defended by a **daily** `pg_dump` to GCS (§12.2 covers only the pre-migration dump — that is not sufficient on
> its own) and Free usage alerts.

Decision 14 is what keeps the crossover where it is. See §9.4.

> **Reconciling with the older figure of Rp 383.912/bulan**, quoted by the now-deleted handoff plan and by
> [the analysis](./palakat-backend-gcp-cloud-run-migration-analysis.md), alongside the plain statement that
> Cloud Run *does not* beat EC2 on cost. Both figures are right. Those price Cloud Run **with the socket still
> attached**; this plan prices it **with the socket deleted**. The whole saving is decision 1. If the socket
> survives for any reason, revert to that number and the cost case for migrating disappears with it.

### 0.2 Sequencing — the socket work happens on EC2

Running the socket on Cloud Run costs the always-on rate for every month the refactor takes. EC2 charges
Rp 378.029 whether it serves sockets or not, so it is the free staging ground. **Migrate last.**

```
Phases 0–5  ── on EC2, no infra cost change ──►  backend + client go HTTP-only
Phases 6–8  ── migrate the finished thing ────►  Cloud Run, scale-to-zero
Phase 9     ── tune ──────────────────────────►  price floor
```

**"On EC2" does not mean "shared with the Supabase branch."** The deleted handoff plan's "nothing gets wasted"
framing was wrong in two places, and the correction is what sets the ceiling in [ADR-0002](./adr/0002-effort-ceiling-and-meaning-of-no.md):

| Phase | Shared with a "go"? | |
|---|---|---|
| 0 correctness fixes | ✅ yes | Defects either way. |
| 1 parity table | ✅ yes | The RLS spec under a go; the review artefact under a no-go. |
| 1 `PermissionsGuard` | ❌ no | Under a go this logic becomes RLS policies, not a Nest guard. |
| 2 REST surface | ❌ **no** — 3–4 weeks | Becomes PostgREST + Edge Functions under a go. The single largest piece of throwaway work available. |
| 3 event-driven jobs | ✅ yes | External scheduler + task queue is required on both. |
| 4 FCM | ✅ yes | Pusher Beams retires either way. |
| 5 client repositories | ❌ no | Different URLs, payload shapes and auth headers per branch. Move them **once**, after #26 — two `-breaking` gates is two support events. |
| 6 scaffolding | ✅ yes | Per [#27](https://github.com/meimodev/palakat/issues/27), the report worker lands on Cloud Run under either verdict. |

### 0.3 Baseline — measured, do not re-derive

Measured 2026-07-21 against map [#14](https://github.com/meimodev/palakat/issues/14), and carried here from the
deleted handoff plan. The effort figures in §0.0 and the phase estimates below rest on these numbers. **Re-measure
only if you suspect drift** — do not spend a session recounting them.

| | |
|---|---|
| Backend | 26k LOC TS (excl. generated), 30 modules, **27 controllers, 132 route decorators** |
| Second API surface | `src/realtime/rpc-router.service.ts` — **4,009 lines, 166 socket RPC actions**, incl. 25 MB chunked upload over WS |
| Data | 40 Prisma models, ~700-line schema, **85 `$transaction`/raw-SQL sites across 29 files** |
| Authorisation | own JWT (`aud` = user/admin/super-admin), bcrypt, Firebase phone verify, `RolesGuard`, **`church-permission-policy.service.ts` 499 lines**, plus per-service checks |
| Scheduled | birthday notifications `0 7 * * *`; report queue poll every 10 s |
| Heavy compute | `report.service.ts` **2,221 lines**, pdfkit + exceljs |
| Health | `health.service.ts` 436 lines, secret-guarded controller |
| External | Firebase Storage (files) + Firebase Auth (phone), Pusher Beams (push), Redis (socket.io adapter), Supabase (Postgres — **already**) |
| Flutter data layer | **~21 retrofit repositories** (43 files incl. `.g.dart`) in `packages/palakat_shared/lib/core/repositories/`, `socket_service.dart` **786 lines**, `http_service.dart` 393 lines |
| Tests | 22 `*.spec.ts` + fast-check property suite in `test/property/` |

> ⚠️ Phase 0 has since landed ([#35](https://github.com/meimodev/palakat/pull/35)): stale-job reaper, atomic
> `SKIP LOCKED` claim, bundled PDF font, dead-code deletions. Line counts in the table predate it. The
> structural figures — 166 actions, 132 decorators, 40 models, ~21 repositories — are unchanged and are the
> ones the phases are sized against.

---

## 1. Two corrections to the existing analysis

Both were load-bearing, and both are wrong. Established by reading the source.

### 1.1 ❌ "27 REST controllers already exist, so this is a transport swap"

Analysis §10.3's central claim. **False.**

- **27** controller files exist, carrying **132 route decorators**. (Re-measured 2026-07-21; the earlier
  "26 / 131" was off by one on both counts. Matches the handoff plan's baseline.)
- **Only 2 are registered**: `HealthController` and `VerifyController`. Every other module — `FinanceModule`,
  `MembershipModule`, `ReportModule` and 22 more — declares `providers:` and **no `controllers:` array at all**.
- **Zero** controllers carry any permission decorator. The count across all 27 files is 0.

So what exists is code that has never been wired, never been guarded, and never served a request. Phase 2 is not
alignment work — it is building the REST surface, with 131 routes of untested code as a starting draft.

### 1.2 ✅ There is no live privilege-escalation bug

Analysis §10.4 and the previous draft of this plan both claimed the REST surface was reachable and
under-protected. **It is not reachable.** Unregistered controllers serve nothing. `GET /api/v1/finance` returns
404 today, not data.

The risk is real but **prospective**: it appears the moment Phase 2 registers those modules. It is created by this
migration, not inherited by it. That reframes it from "hotfix now" to "do not get Phase 2 wrong."

### 1.3 ❌ "The job-claim race is a live bug"

Claimed by §5's 🔴 and by the handoff plan's "do this first, it is a live bug". **It is latent, not live.**

EC2 runs **one** process — `ExecStart=/usr/bin/env pnpm run start:prod` under systemd, no PM2, no cluster mode.
The per-process `isProcessing` guard (`report-queue.service.ts:29`) therefore holds today. The race arms at
>1 instance, which is a Cloud Run condition.

**What *is* live in that file is the other half, and neither document says so: there is no stale-job reaper
anywhere.** `getHealthSnapshot` (:50) only *counts* rows in `PROCESSING`; nothing ever resets one.
`Restart=always` plus a deploy restart mid-render strands the job permanently — the user's modal spins with no
error and no recovery path. That is the defect worth shipping during the freeze.

Tempered by the baseline's most important fact: the project is **pre-launch**. "Live" means broken for you, not
for users.

### 1.4 ⚠️ The PDF font may or may not be broken today — one command settles it

`report-renderer.ts:7-14` probes six paths. No `.ttf` is committed (`src/assets/` holds only `gmim-logo.png`),
so candidate [5] never resolves. Whether [0] or [1] hits depends on the Ubuntu image the EC2 box was built from;
`fonts-dejavu-core` is not present on every minimal server image. The failure is **silent** either way.

```bash
ls /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf
```

Regardless of the answer, the fix in §5.2 is to **commit the font** so it resolves host-independently — that is
what makes it branch-agnostic work rather than Dockerfile work.

---

## 2. What the code review found in our favour

Six findings that shrink the FCM half of the work.

### 2.1 Every push funnels through one service

`src/realtime/realtime-emitter.service.ts` is the **single seam**. All 14 `emitToRoom` call sites route through
`RealtimeEmitterService.emitToRoom(room, event, payload)` (:53). The three helpers — `emitActivityEvent` (:107),
`emitFinanceEvent` (:138), `emitApprovalLifecycleEvent` (:179) — all funnel into it. **The transport swap is a
one-file reimplementation.** No caller changes.

### 2.2 Payloads are already FCM-shaped

Every helper builds `{ data: { ... } }` — literally the FCM data-message envelope. Only adaptation: **FCM data
values must all be strings.**

### 2.3 Room names are already valid FCM topics

`pusher-beams.service.ts` formats interests as `church.{id}` (:191), `membership.{id}` (:167), `account.{id}`
(:181), `church.{id}_bipra.{BIPRA}` (:155), `church.{id}_column.{id}` (:202), `membership.{id}.birthday` (:171).
FCM topics permit `[a-zA-Z0-9-_.~%]+`. **Every name maps 1:1 with no renaming.**

### 2.4 FCM already ships in the Flutter app

`apps/palakat/pubspec.yaml:52` — `firebase_messaging: ^15.1.5  # Required for Pusher Beams FCM integration`.
Beams delivers over FCM on Android, so token plumbing, `google-services.json`, the APNs certificate and the
notification permission flow **already work in production**.

### 2.5 Generated reports already go to Firebase Storage

`report.service.ts:2133` uploads via `firebaseAdmin.bucket()`. Reports are **not** served off local disk, so the
tmpfs exposure is narrower than feared and report downloads never consume Cloud Run egress.

### 2.6 `emitToSocketId` has zero callers

`realtime-emitter.service.ts:64`. Dead code — delete it.

---

## 3. 🔴 The security constraint: FCM topics are client-subscribable

**The most important design constraint in this migration.**

FCM topics are **client-controlled**: any app instance can call `subscribeToTopic('church.123')` and
**Firebase performs no authorization check.**

> ### 3.1 ❌ Correction — socket rooms were *not* server-controlled either
>
> **Earlier drafts of this section opened by contrasting "server-controlled" socket rooms with
> client-controlled FCM topics. That contrast was false**, and it mattered: it framed this whole
> constraint as something FCM *introduces*.
>
> `sub.join` took the room name straight from the payload and joined it:
>
> ```ts
> case 'sub.join': {
>   this.requireUserId(client);
>   const room = payload.room as string;
>   if (!room || room.trim().length === 0) throw new BadRequestException('room is required');
>   client.join(room);          // ← no membership check of any kind
> ```
>
> Any authenticated user could join `church.{any id}` and receive exactly the payloads listed below —
> `entityTitle`, `actorName`, `financeType`, `affectedMembershipIds`, `resultingStatus`. The client
> named the room and the server obeyed.
>
> Three consequences, none of which change this plan's direction:
>
> 1. **The mandate below is still right**, and now has a second, independent justification.
> 2. **The exposure was live, not prospective** — and `palakat_admin` is deployed (decision 21).
> 3. **Phase 4 closes this exposure rather than opening it.** Read the rest of §3 that way.
>
> Fixed in Phase 1.5 ([#56](https://github.com/meimodev/palakat/pull/56)): `sub.join` now checks the
> requested room against the caller's own account, membership, church and column, as an **allow-list**
> over the grammar `pusher-beams.service.ts` defines (`src/realtime/room-authorization.ts`). A
> deny-list on a name the caller composes is not defensible.
>
> The same lesson applies to the FCM design: `subscribeToTopic` is client-side and has **no** server to
> refuse it, so the content rule below is the only control. That is why it is a mandate and not a
> preference.

Today's payloads carry `entityTitle`, `actorName`, `financeType`, `affectedMembershipIds`, `resultingStatus`.
Published to `church.{id}` topics, **anyone guessing a church ID would receive that church's finance and approval
activity.**

**Therefore, mandatory:** no push carries entity content. But the rule is **content-free, not
notification-free** — an earlier draft of this plan conflated the two and would have deleted the notification
feature as a side effect of a security fix. Per decision 13 and
[ADR-0003](./adr/0003-push-splits-by-category.md), push splits by what the message is *for*:

| | **Change signal** | **Notification** |
|---|---|---|
| Events | `activity.*`, `finance.*`, `approval.*` | `notification.*` |
| Payload | `data` only — event name + entity id | generic OS-rendered title/body + routing `data` |
| Rendered by OS? | no | **yes — works with the app killed** |
| Client does | marks the provider stale (§9.4) | user taps → app fetches real content over REST |

```ts
// change signal — no content at all
{ topic: `church.${churchId}`, data: { event: 'finance.updated', entityId: String(id) } }

// notification — rendered by the OS, but the text is deliberately vague
{ topic: `membership.${id}`,
  notification: { title: 'Palakat', body: 'Ada pemberitahuan baru' },
  data: { event: 'notification.created', entityId: String(id) } }
```

**Why the generic title is not a leak.** A self-subscribed stranger already learns *"something happened in
church N"* from the subscription itself — this design accepts that. A generic title reveals exactly that and no
more. What must never travel is what the current helpers build: `entityTitle`, `actorName`, `financeType`,
`affectedMembershipIds`, `resultingStatus`.

> ⚠️ **Notification copy is a security surface.** Whoever edits that string is editing what leaks to an
> unauthorised subscriber. It belongs under review, not in a translation file edited casually.

Glossary: `CONTEXT.md` defines **Change signal** and **Notification** as distinct terms precisely because
conflating them is what hid this.

> **Pusher Beams interests have the same self-subscribe property**, so this exposure partially exists today for
> notification payloads. Phase 4 fixes both at once rather than porting the flaw forward.

---

## 4. Phase map

```
ON EC2 — no infrastructure cost change
Phase 0   Correctness fixes           reaper, atomic claim, font, pool bound  ✅ done (#35)
Phase 3a  Birthday timezone           @Cron timeZone + handler in WITA        ✅ done (#54)
Phase 1   Permission layer            guard + GENERATED parity table          ✅ done (#55)
Phase 1.5 Authorization hardening     triage done; 56 bare actions to fix     🔄 in progress 🔴 SECURITY
Phase 2   REST surface                delete 27 controllers, write 166 + 4    ~3–4 weeks  🔴 SECURITY
Phase 4   FCM push                    reimplement the emitter; retire Beams   ~2–3 days   🟢 takeable now
Phase 5   Flutter clients (×3)        ~180 call sites → REST, topics          ~3–6 weeks
─────────────────────────────────────────────────────────────────────────────────────────
THEN MIGRATE — nothing pins an instance any more
Phase 6   Containerize + scaffolding  Dockerfile, registry, secrets, WIF      ~2 days
Phase 3b  Event-driven jobs           Cloud Tasks, Scheduler, /internal svc   ~2 days     🔴 PRICE
Phase 7   Deploy HTTP-only            scale-to-zero config + CI/CD            ~1,5 days
Phase 8   Cutover                     DNS, soak, decommission EC2             ~0,5 day
Phase 9   Cost tuning                 measure, then right-size                ~1–2 days
```

Backend **6–9 weeks**, dominated by Phase 2 (delete-all-and-rewrite) with Phase 1.5 ahead of it. Clients
**3–6 weeks** across *three* apps, overlapping from Phase 1's parity table onward. Migration itself is **under a
week** — it is the smallest part of this project.

**Total: ~10–14 weeks, and the bar is 14** (decision 29, [ADR-0007](./adr/0007-release-freeze-and-the-14-week-bar.md)).
That re-derives decision 23's 8–12 by adding Phase 1.5, the parity-table generator, throttling and four new
routes. ADR-0002's 12–15 week ceiling judged the *Supabase* branch and expired with the fork; do not read the two
numbers as a comparison.

**Two phases moved, and why.** Phase 3 was listed under `ON EC2` while every mechanism in it — Cloud Tasks,
Cloud Scheduler, an IAM-protected second service — is GCP, which Phase 6 builds three phases later. It splits
(decision 33): **3a** is the birthday timezone fix, a live defect needing no GCP, done now; **3b** is everything
else, after Phase 6. Nothing is lost by waiting — the 10-second poller is only a problem on request-based
billing, so it costs nothing on EC2.

**Phases 1.5, 2 and 3b are the ones that can hurt you.** 1.5 and 2 ship a vulnerability if rushed; 3b deletes the
price case if done with a poller.

---

## 5. Phase 0 — correctness fixes

Scale-to-zero and multi-instance both become real, so single-process assumptions must go first.

**All of §5 ships during the freeze** — these are defects on either branch. See §0.0.

### 0.1 🔴 Stale-job reaper (live) + atomic job claim (latent)

Two separate defects, ranked correctly per §1.3.

**The reaper is the live one.** Nothing resets a row stuck in `PROCESSING` — `getHealthSnapshot` (:50) counts
them and moves on. Any restart mid-render strands the job forever. Sweep rows whose `updatedAt` is older than a
render's worth of time back to `PENDING` (or `FAILED` past a retry count), and run it on boot as well as on a
schedule, because boot is exactly when the stranding happened.

**The atomic claim is the latent one**, armed by `max-instances=5`. `report-queue.service.ts:29` guards with
`private isProcessing = false` (per-process); `:283`/`:296` claim a job as `findFirst` → separate `update`. Two
instances claim the same job and render it twice. Worth fixing now anyway: the raw SQL below survives into a
plpgsql function under a "go", so it is not throwaway work.

```ts
const [job] = await this.prisma.$queryRaw<ReportJob[]>`
  UPDATE "ReportJob" SET status = 'PROCESSING', "updatedAt" = NOW()
  WHERE id = (
    SELECT id FROM "ReportJob"
    WHERE status = 'PENDING'
    ORDER BY "createdAt" ASC
    LIMIT 1
    FOR UPDATE SKIP LOCKED
  )
  RETURNING *;
`;
if (!job) return;
```

Keep `isProcessing` as a *local* limiter.

**Verification:** integration test running two `processQueue()` calls concurrently against one PENDING row,
asserting exactly one render. Plus a test that a `PROCESSING` row older than the threshold is reclaimed.

### 0.2 🔴 Ship the PDF font

`report-renderer.ts:7–14` probes six paths; the first five are host absolute paths present on Ubuntu EC2 and on
**no** slim container base. `resolveUnicodeFontPath()` then returns `undefined` and PDF rendering silently falls
back to a non-Unicode core font — **no error, no log line**. Most Indonesian text is Latin-1, so it passes a smoke
test and mangles glyphs later.

Verified path arithmetic: compiled output is `dist/src/report/report-renderer.js`, so `__dirname/../../assets` =
`dist/assets`. `nest-cli.json` declares `"assets": ["assets/**/*"]` against `sourceRoot: "src"`, copying
`src/assets/**` → `dist/assets/**`. `src/utils/gmim-letterhead.ts:104-105` already documents and depends on this
layout.

**Fix by committing the font**, not in the Dockerfile. `src/assets/fonts/NotoSans-Regular.ttf` makes candidate
[5] resolve on every host — EC2, container, laptop, and a Supabase-branch worker alike — which is what makes this
freeze-eligible work rather than Cloud Run work. The `fonts-dejavu-core` apt line in §11.2 becomes belt-and-braces,
not the mechanism. And regardless:

```ts
const UNICODE_FONT_PATH = resolveUnicodeFontPath();
if (!UNICODE_FONT_PATH) {
  throw new Error('No Unicode font found — PDF export would silently mangle non-Latin-1 glyphs');
}
```

### 0.3 🟠 Bound the Prisma pool

`prisma.service.ts:19-21` builds `new Pool({ connectionString })` with no `max` — `pg`'s default of **10 per
process**. Scale-to-zero makes instance count spiky by design, and **Supabase Free has a low direct-connection
ceiling** (§11, R4).

```ts
const pool = new Pool({
  connectionString,
  max: Number(process.env.DATABASE_POOL_MAX ?? 3),
  idleTimeoutMillis: 30_000,
  connectionTimeoutMillis: 10_000,
});
```

Route the service through **Supabase's transaction pooler (port 6543, `?pgbouncer=true`)**. That disables prepared
statements — **run the full e2e suite against the pooler URL before cutover**. Migrations keep the **direct**
connection on 5432; PgBouncer transaction mode cannot run DDL reliably.

### 0.4 🟡 Repo hygiene

- `apps/palakat_backend/package-lock.json` and `apps/palakat_backend/pnpm-lock.yaml` are stale; the root
  `pnpm-lock.yaml` is authoritative. Delete both or the Docker build picks the wrong one.
- `apps/palakat_backend/vercel.json` is a static-site config used by nothing. Delete.
- `RealtimeEmitterService.emitToSocketId` (:64) — zero callers. Delete.

---

## 6. Phase 1 — the permission layer ✅ done ([#55](https://github.com/meimodev/palakat/pull/55))

> **This section is now historical.** The shipped code is the reference, not the sketch below:
> `src/auth/permissions.guard.ts`, `permissions.decorator.ts`, `rpc-action.decorator.ts`,
> `scripts/generate-parity-table.ts`, `scripts/check-permission-parity.ts`. See §0.01 for what
> Phase 2 consumes.
>
> ⚠️ **The `PermissionsGuard` sketch below is subtly wrong and was not shipped as written.** It does
> `req.churchId = res?.data?.churchId` and stops. But `getEffectivePermissions` returns
> `churchId: null` for an elevated role with no membership row, so the RPC helper falls back to
> `resolveRequesterChurchIdForUser`. Dropping that fallback 500s exactly the accounts with the most
> authority. The shipped guard keeps it, via
> `src/church-permission-policy/resolve-requester-church-id.ts`, which the RPC router now shares so
> the two authorization doors cannot drift.

**Built from nothing.** No controller carried a permission decorator.

The RPC path is the specification. `requireAnyOperationPermission` (`rpc-router.service.ts:380`) resolves the
caller's effective permissions and matches against an allow-list:

```ts
const user = this.requireUserId(client);                       // reads client.data.user only
const res  = await this.churchPermissionPolicyService.getEffectivePermissions(user);
const allowedPermission = permissions.find((p) => res?.data?.permissions.includes(p));
if (!allowedPermission) throw new ForbiddenException('Insufficient permission');
```

Port that logic verbatim into a Nest guard. **Do not redesign the permission model during a transport
migration** — behavioural parity is the goal; any improvement is a separate change with its own review.

```ts
@Injectable()
export class PermissionsGuard implements CanActivate {
  constructor(
    private reflector: Reflector,
    private policy: ChurchPermissionPolicyService,
  ) {}

  async canActivate(ctx: ExecutionContext): Promise<boolean> {
    const required = this.reflector.get<string[]>(PERMISSIONS_KEY, ctx.getHandler());
    if (!required?.length) return true;
    const req = ctx.switchToHttp().getRequest();
    const res: any = await this.policy.getEffectivePermissions(req.user);
    const perms = res?.data?.permissions ?? [];
    if (!required.some((p) => perms.includes(p))) {
      throw new ForbiddenException('Insufficient permission');
    }
    req.churchId = res?.data?.churchId;      // RPC handlers rely on this
    return true;
  }
}
```

Also needed:

- **`churchId` resolution.** RPC returns it alongside the permission; handlers use it. The guard must attach it to
  the request, including the `resolveRequesterChurchIdForUser` fallback path.
- **Pagination.** `PaginationInterceptor` is **already registered globally** in `main.ts:33`. Check it against
  `withPagination` / `normalizePaginatedList` before adding anything — the envelope must match byte-for-byte or
  every Flutter model breaks subtly.

**Deliverable: the parity table.** All 166 RPC actions, each mapped to **four** columns:

| Column | Source | Note |
|---|---|---|
| Target route + HTTP verb | the `case` blocks | |
| Exact permission set | `requireAnyOperationPermission` call sites | The security column. |
| **Request shape** | **what the Flutter repositories actually send** | Per decision 18 — *not* the existing DTO files. |
| Response envelope | the RPC return shape | Must match byte-for-byte or Flutter models break subtly. |

Per decision 17 this table is not a cross-check against existing controllers — **it is the only source**. Every
route in Phase 2 is written from it, and the 132 existing decorators are deleted.

The request-shape column exists because of a trap decision 18 records: `main.ts:34` registers a global
`ValidationPipe` that applies to **HTTP only** — the gateway declares no `@UsePipes`, and `rpc-router.service.ts`
calls `validateDto` at just **4 of 166** actions. So registering a route silently puts it behind strict
validation the socket never applied. Without this column those mismatches surface as 400s during Phase 5, one
repository at a time, while the transport is also changing. With it, they are a design-time decision.

The 54 DTO files (49 using `class-validator`) are **candidate implementations to verify against the table**, not
evidence of anything — they were written for the path that has never served a request.

Produce the table before writing controllers. It is the review artefact for Phase 2 and the spec for Phase 5.

**Generate it, do not write it** (decision 32, [ADR-0009](./adr/0009-parity-table-is-generated-not-reviewed.md)).
The Guard and Permissions columns are transcription from source, and a program transcribes without drift. Two
pieces:

1. A generator that walks `rpc-router.service.ts` and emits, per `case`, the guard helper used and the exact
   allow-list passed to `requireAnyOperationPermission` / `requireOperationPermission`.
2. A CI check asserting every registered route's `@RequirePermissions` set equals its RPC case's allow-list.
   Mismatch fails the build.

This exists because the gate it replaces — *"reviewed by someone who did not write it"* — cannot be satisfied by
a solo dev, and because Phase 1.5 rewrites 94 of those rows. A hand-maintained table is stale the moment that
lands; a generated one is not. The Verb/Route columns and Phase 1.5's triage buckets still need judgement — get
that from a fresh agent read, which is the closest available thing to the reviewer the gate asked for.

The generator is a **build dependency of Phase 2**. It must exist before controllers are written, not alongside
them.

---

## 6.5 Phase 1.5 — fix the 94 unguarded actions, on the RPC path 🔴

**1–2 weeks. New — decision 31, [ADR-0008](./adr/0008-authorization-hardening-precedes-transport.md).**

The parity table found **94 of 166 actions authenticated but unauthorized**: any signed-in user of any church can
invoke them. §6 above says port the permission model verbatim; ADR-0006 says fix the 94. Both cannot hold, and
the tie-breaker is Phase 2's own exit gate — *"under-privileged-token test green on every permission-bearing
route."* Under verbatim parity **94 of 166 routes are not permission-bearing**, so the gate asserts nothing
against 57% of the surface and reports green having covered the minority.

So the redesign finishes *before* the transport migration rather than during or after it. On the RPC path there
is one surface, a live reference implementation, existing tests, and no interaction with route registration,
guards, envelopes or validation changing at the same time.

**✅ The triage is done** — [`…-phase-1.5-authorization-triage.md`](./palakat-backend-phase-1.5-authorization-triage.md),
[#45](https://github.com/meimodev/palakat/issues/45). It changed the size of this phase, so read its
result before planning against the paragraph above.

**94 was a router-level count and mixes three populations:**

| Population | Count | Work |
|---|---:|---|
| **Inline-guarded** — hand-written role check instead of a helper | 11 | **none** — guarded; the generator simply could not see it |
| **Scoped-arg** — passes `user` or a caller-derived id | 27 | verify the service enforces ([#59](https://github.com/meimodev/palakat/issues/59)) |
| **Bare** — nothing caller-derived reaches the service | **56** | the real work ([#57](https://github.com/meimodev/palakat/issues/57), [#58](https://github.com/meimodev/palakat/issues/58)) |

Within the 56, the original three buckets still apply: correct as authenticated-only (`location.list`
— reference data; record why), needs a permission (church-scoped writes → #57), needs church-scoping
in the service rather than a permission (own-records reads → #58). `approver.list` is the model for
the third — it forces `query.churchId` to the requester's own church and **rejects** a mismatch
rather than silently ignoring it.

**The two dead-permission findings, resolved:**

- `ops.approvalRule.manage` was defined in `ALL_PERMISSIONS` and never checked. The triage decided
  which horn: **the approval-rule actions were under-guarded**, not the permission dead. All five
  `approvalRule.*` now require it ([#56](https://github.com/meimodev/palakat/pull/56)), and the
  generator reports `unchecked: []`.
- `ops.approval.finance` is passed at `rpc-router.service.ts:2075` and `:2096` and is **never
  defined** — only `ops.approval.finance.override` exists, so those clauses are dead. **Still open,
  deliberately** ([#60](https://github.com/meimodev/palakat/issues/60)): the comment above the call
  says *"Allow finance creators OR finance approvers to read detail"*, so correcting it **widens**
  finance read access. It is the only widening in this phase, and every other change here tightens.
  Tightening is safe to do unilaterally under the freeze; this is not.

**Also fixed here, and not previously in this plan's scope:** `sub.join` accepted any room name —
see §3.1. That was a live cross-church data leak, and it falsified §3's original framing.

> ⚠️ **This changes RPC behaviour while three clients still speak RPC.** A call that worked yesterday returns 403
> today. Under decision 28's release freeze that costs dev-build friction and nothing else — which is exactly
> why it is cheap now and stops being cheap at launch.

---

## 7. Phase 2 — the REST surface 🔴 the security critical path

**3–4 weeks. The largest phase in the plan, and the one that can ship a vulnerability.**

**Start by deleting all 27 controller files.** Per decision 17, the 132 existing decorators are not a draft to
adopt — coverage is uneven and the gaps sit exactly where it matters: `admin` has 26 RPC actions against 8
decorators, `file` 11 against 6, and `finance-entry` — the module `CONTEXT.md` treats as canonical — has no
controller at all, while `FinanceController` exposes 2 of Finance's 7 actions. A plausible-looking route that
survives review because it looked familiar is the failure mode this phase cannot afford.

Then, per module in dependency order:

1. **Write the controller from the parity table.** Not from the deleted file, not from the RPC `case` block —
   from the reviewed table.
2. **Register it.** Add `controllers: [XController]` to the module — currently absent in 25 of 27.
3. **Apply guards.** `@UseGuards(AuthGuard('jwt'), PermissionsGuard)` plus `@RequirePermissions(...)` per route,
   transcribed from the table.
4. **Bind the request shape.** Use the table's request-shape column, and keep the global `ValidationPipe` strict
   (decision 18). Where an existing DTO matches the column, reuse it; where it does not, the table wins.
5. **Verify the response envelope** against the RPC path — pagination shape, error mapping (`mapErrorToRpc` has an
   HTTP equivalent in `PrismaExceptionFilter`), and status codes.
6. **Test.** Every permission-bearing route gets a test asserting an under-privileged token receives 403.
   After Phase 1.5 that is every route bar the deliberately public ones — which is the point of doing 1.5 first.

**All 166 actions are ported, including the 31 no client calls** (decision 27). The parity table recommends the
opposite — *"delete candidates, not port candidates — a guarded route for an action nothing invokes is attack
surface with no user-visible function"* — and that recommendation was heard and declined: uniform process beats
per-action judgement on the phase that can ship a privilege escalation. The 31 are second on §0.05's descope
ladder if the 14-week bar comes under pressure.

**Four routes have no RPC counterpart to port** (decision 36). Four client calls hit the router's
`default: throw Unknown action` today, so they fail at runtime on the socket:

| Client call | Client site | Server today |
|---|---|---|
| `approver.delete` | `approver_repository.dart:127` | list/get/create/update/override exist — no delete |
| `churchLetterhead.getMe` | `church_letterhead_repository.dart:28` | no `churchLetterhead.*` case at all |
| `churchLetterhead.updateMe` | `church_letterhead_repository.dart:47` | ″ |
| `churchLetterhead.setLogo` | `church_letterhead_repository.dart:116` | ″ |

`ChurchLetterheadService` exists in the backend and is **never referenced by the router**, so per-church
letterhead customisation is written and unreachable. Build all four. `approver.delete` is not a nicety: a church
that can add an approver but never remove one keeps approval rights with a member who has left the role.

### 7.1 Rate limiting — new in this phase

Decision 30. This plan's security story is entirely **authorization**; authentication abuse is unaddressed
anywhere in it. That was survivable behind a Socket.IO handshake. Phase 2 puts **five unauthenticated password
endpoints on a public URL** with predictable paths:

| Route | |
|---|---|
| `POST /auth/sign-in` | identifier + password → user token. No client calls it. |
| `POST /auth/admin-sign-in` | identifier + password → admin token. No client calls it. |
| `POST /auth/super-admin-sign-in` | phone + password → super-admin token. **Is** called. |
| `POST /auth/refresh` | refresh token → new tokens. No client calls it. |
| `POST /auth/signing-client` | static `APP_CLIENT_USERNAME` / `APP_CLIENT_PASSWORD` → client token |

`ThrottlerModule` registered globally with a loose default, `@Throttle` tightened over the `/auth/*` cluster.
Nothing custom, no Redis — per-instance counters are weak at `max-instances=5` and strictly better than nothing,
and Cloud Armor can harden it later without rework.

Note the second-order effect: with `min-instances=0` and request billing, a credential-stuffing run is also a
**billing event** — it scales instances and Supabase egress. R17 prices a runaway `max-instances` as an accident;
this is the deliberate version.

Two actions are **not** mechanical ports:

- **`file.upload.chunk`** streams over the socket via `createWriteStream`. Do not rebuild chunked upload over
  HTTP — the bytes would become billable request-seconds and tmpfs memory. Issue a **signed URL** and have the
  client upload directly. `firebaseAdmin.bucket()` is already wired (`report.service.ts:2133`).

  **But that deletes the enforcement point, and rules do not replace it.** Today the server checks
  `session.receivedBytes` against `MAX_FILE_BYTES` (25 MB) / `MAX_ARTICLE_COVER_BYTES` (5 MB) as bytes arrive
  (`rpc-router.service.ts:931`), requires `image/*` for covers (:842), and infers the extension itself.
  A signed URL from `getSignedUrl()` is a **GCS** URL — **Firebase Storage security rules do not apply to it**.

  Per decision 19 and [ADR-0004](./adr/0004-upload-trust-boundary.md), enforcement is rebuilt on both sides:

  | Stage | Server does |
  |---|---|
  | **Sign** | binds `x-goog-content-length-range` + expected content type into the URL; chooses the storage path itself — the client never picks where its object lands |
  | **Upload** | nothing — GCS rejects oversized or mistyped uploads on its own |
  | **Finalize** | reads the object's **real** metadata from GCS, re-checks it, and only then writes the `FileManager` row |

  Writing `FileManager` only after reading real metadata makes it impossible for the row and the object to
  disagree — `sizeInKB` records what landed, not what was declared. Unfinalized objects are swept by the daily
  orphan job from Phase 3, which stops being a nicety: an unfinalized object is now the *normal* representation
  of a failed upload.
- **`document.generate`** is long-running. It must return a job id immediately, never block a request.

**Gate — do not proceed to Phase 5 without all of:**

- [ ] Parity table **generated** from source, and the CI permission-diff check green (decision 32). The old
      "reviewed by someone who did not write it" is unsatisfiable solo — see [ADR-0009](./adr/0009-parity-table-is-generated-not-reviewed.md).
- [ ] Fresh-agent read of the Verb/Route columns and Phase 1.5's triage buckets — the judgement the generator
      cannot make.
- [ ] Under-privileged-token test green on every permission-bearing route. **Phase 1.5 closed, so this now
      covers the surface rather than 72 of 166 routes.**
- [ ] `/auth/*` throttled (§7.1).
- [ ] No route registered that lacks either an explicit permission or a documented reason to be public.
- [ ] The old RPC path still runs unchanged — it is the reference implementation until Phase 5 completes.

---

## 8. Phase 3 — event-driven jobs 🔴 the price-critical path

**Get this wrong and the entire price case evaporates.**

> **This phase splits (decision 33).** Earlier drafts listed it under `ON EC2`, but every mechanism below is
> GCP — Cloud Tasks, Cloud Scheduler, an IAM-protected second Cloud Run service — and Phase 6 builds that
> scaffolding three phases later. It could not run where it was placed.
>
> | | | When |
> |---|---|---|
> | **3a** | Birthday timezone: `@Cron('0 7 * * *', { timeZone: 'Asia/Makassar' })` **and** handler date-matching in WITA | **Now, on EC2.** ~1 hour |
> | **3b** | §8.1 Cloud Tasks, §8.2 Scheduler, §8.3 `/internal` service | After Phase 6 |
>
> 3a is a live defect — the job fires at the wrong local hour today, on the box currently serving. It needs no
> GCP at all. 3b has no value before the container exists: the 10-second poller is only a problem on
> request-based billing, so it costs nothing on EC2 and stays until migration.
>
> ⚠️ §8.2's note that the daily birthday job keeps a Free Supabase project from pausing (R3b) is moot on EC2.
> **Verify the Scheduler job actually fires** after migration before relying on it for that.

`report-queue.service.ts:268` runs `@Cron(CronExpression.EVERY_10_SECONDS)`. Two problems:

1. On request-based billing, CPU is throttled outside request handling — **a `@Cron` timer is not a request**, so
   it fires only opportunistically. Reports never finish. No error, no alert.
2. Replacing it with a Cloud Scheduler poll means **the instance never scales to zero.** You would pay the
   always-on rate *and* take cold-start latency. Worst of both.

**A polling queue and scale-to-zero are incompatible.** The queue becomes event-driven.

### 8.1 Report queue → Cloud Tasks

```
POST /report-jobs  ──►  create row  ──►  Cloud Tasks enqueue
                                              │
                                              ▼
                              POST /internal/tasks/report/:id   (OIDC-authenticated)
```

- Cloud Tasks' free allowance comfortably covers this volume; expect **Rp 0**.
- Set `--max-attempts` and `--max-concurrent-dispatches` to match `max-instances`.
- Retries become Cloud Tasks' problem. The Phase 0.1 atomic claim ensures a retried task cannot double-render.
- Keep a **once-daily** Scheduler sweep for orphaned rows whose task was lost. Daily, not minutely.

### 8.2 Birthday job → Cloud Scheduler, correctly zoned

`birthday-notification.service.ts:15` is `@Cron('0 7 * * *')` with **no `timeZone` option**, and the handler
derives `dateKey` from `new Date()`. Both use process-local time — **always UTC on Cloud Run**. So 07:00 means
15:00 WITA, and the birthday calendar day rolls over at 08:00 local.

Fix both halves, per decision 8:

```bash
gcloud scheduler jobs create http birthday-notifications \
  --schedule="0 7 * * *" --time-zone="Asia/Makassar" \
  --uri="https://api.example.com/internal/cron/birthday" \
  --oidc-service-account-email=palakat-invoker@PROJECT_ID.iam.gserviceaccount.com
```

The handler must derive month/day/`dateKey` in `Asia/Makassar` too — scheduling alone does not fix date-matching.

Per decision 9, that zone is **app-wide**, not per-church. `sendDailyBirthdayNotifications` derives one
`dateKey` and loops every church with it (`birthday-notification.service.ts:16-21`), which is correct behaviour
under a single-synod deployment and should stay that way. `Church` gains **no** timezone column. The concept is
named **Church-local day** in `CONTEXT.md`; use that term rather than "today" or "server date".

**This changes observable behaviour**: notifications move from mid-afternoon to 07:00 local. Announce it.

The job is **already idempotent** and needs no logic change — `schema.prisma:677` has `dedupeKey String? @unique`,
and the service inserts first, catches Prisma `P2002`, and continues before sending. Keep that: Cloud Scheduler
can double-deliver.

> **Free-tier bonus:** Supabase pauses inactive Free projects. This daily job touches the database every day, so
> it keeps the project active on its own. Do not remove it without checking §11 R6.

### 8.3 Secure `/internal/*` — a second service, not a code check

These routes bypass user authentication by design, so a mistake is a full authorization bypass. The earlier draft
verified the Google-signed OIDC token's `aud` and `email` in application code, on a service that is
`--allow-unauthenticated` because the API is public — putting the least-protected routes in the codebase behind a
check we wrote, reachable from the internet, where being too permissive fails **silently**.

Per decision 24 and [ADR-0005](./adr/0005-internal-endpoints-separate-service.md), deploy the **same image** a
second time:

```bash
gcloud run deploy palakat-internal \
  --image=asia-southeast1-docker.pkg.dev/PROJECT_ID/palakat/backend:TAG \
  --region=asia-southeast1 \
  --service-account=palakat-backend@PROJECT_ID.iam.gserviceaccount.com \
  --no-allow-unauthenticated \
  --min-instances=0 --max-instances=3

gcloud run services add-iam-policy-binding palakat-internal \
  --region=asia-southeast1 \
  --member=serviceAccount:palakat-invoker@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/run.invoker
```

Google rejects an unauthenticated or wrongly-authenticated request **before the process handles it**. Scheduler
and Tasks target this service's URL. Still exclude `/internal/*` from the global `api/v1` prefix as
`main.ts:17-21` already does for `/health`.

Two things this buys beyond the security property: the internal worker **scales independently of user traffic**
— which is where §14.2's split-worker option was already heading — and it is *less* code than token verification,
not more.

> **Test that `/internal/*` is genuinely unreachable on the public service**, not merely unrouted by convention.
> Same image means the handlers exist there too.

---

## 9. Phase 4 — FCM replaces the socket emitter

### 9.1 Reimplement the one seam

Callers do not change. Per §3, the payload carries no content.

```ts
// realtime-emitter.service.ts — same signature, different transport
async emitToRoom(room: string, event: string, payload: unknown) {
  if (!room?.trim()) return;
  // ponytail: content never travels in the push — topics are client-subscribable (§3).
  // But notifications still need the OS to draw something, so they carry a
  // deliberately generic title/body. Content-free, not notification-free.
  const entityId = extractEntityId(payload);
  const isUserFacing = event.startsWith('notification.');

  await this.firebase.messaging().send({
    topic: room,                                   // church.12 / membership.5 — already FCM-legal
    data: { event, ...(entityId ? { entityId } : {}) },
    ...(isUserFacing
      ? {
          // rendered by the OS with the app killed. Text is a security surface — §3.
          notification: { title: 'Palakat', body: 'Ada pemberitahuan baru' },
          android: { priority: 'high' },
        }
      : {
          android: { priority: 'high' },
          apns: { payload: { aps: { 'content-available': 1 } } },
        }),
  });
}
```

**Do not add an `onBackgroundMessage` handler.** There is none in the Flutter app today and the split above means
none is needed — the OS draws the notification. A background isolate that refetches and builds a local
notification would make the user-visible feature depend on `content-available` delivery, which iOS throttles and
drops precisely when the app is killed.

`FirebaseAdminService` (`firebase-admin.service.ts:36`) already calls `initializeApp` with `cert(...)` and exposes
`auth()` (:52) and `storage()` (:66). **Add `messaging()`** in the same shape, including the existing
`isConfigured()` no-op fallback so tests and local dev keep working.

### 9.2 Retire Pusher Beams

Beams is a **paid vendor doing what FCM does free**, over FCM anyway on Android. `publishToInterests` has ~7 call
sites and the formatters (§2.3) map straight to topics.

- Replace `publishToInterests(interests, payload)` with an FCM topic send.
- Keep the formatter methods as the topic-name vocabulary, moved into a `TopicsService` so nothing references a
  retired vendor by name.
- Delete `@pusher/push-notifications-server`, `pusher_beams`, and the `pusher_beams_web_stub` workspace package
  (which exists solely to stub Beams on web).
- Drop `PUSHER_BEAMS_INSTANCE_ID` / `PUSHER_BEAMS_SECRET_KEY`.

**Do this after** the FCM emitter is proven in production. One transport change at a time.

### 9.3 The category FCM cannot serve

FCM data messages are **best-effort** — Android Doze and iOS background throttling delay or batch them. Fine for
notifications and banners. **Not** fine for `reportJob.*` progress ticks, which want sub-second liveness while a
user watches a modal.

**Poll `GET /report-jobs/:id` every 2 seconds while the modal is open.** Report generation is rare,
user-initiated, and short. That deletes the only category that genuinely wanted a live channel.

| Category | Sites | Replacement |
|---|---|---|
| `notification.created/updated/deleted` | `notification.service.ts` :116, :441, :485 | **Notification** — OS-rendered generic title/body, tap → fetch content |
| `activity.*` / `finance.*` / `approval.*` | `rpc-router.service.ts` :3153, :3956 + emitter helpers | **Change signal** — invalidate only, refetch on next view (§9.4) |
| `reportJob.*` progress | `report-queue.service.ts` :138, :305, :362, :375, :408 | 2-second polling while modal open |

### 9.4 🔴 Change signals invalidate — they never trigger a refetch

**Decision 14, and it is a cost control, not a UX preference.**

A single finance entry in a 200-member church publishes to `church.{id}`. If each device refetches on arrival,
that is 200 requests and 200 payloads for one write. At a 20 KB list response, ~4 MB per event; 50 events/day is
**~6 GB/bulan from one church** — past the entire Free egress allowance in §0.1, and billed twice on Cloud Run
(per-request *and* per-GB) once on Pro.

So the client marks the relevant provider **stale** and does nothing else. The read happens when a screen that
needs it is next viewed. A user with the app closed, or on another screen, issues **zero** requests.

Fan-out collapses from *every subscribed device* to *the handful currently looking*, which is the difference
between the two columns of §0.1 arriving early or late.

§10.1 step 3 is written against this rule. Eager refetch is the amplifier — do not reintroduce it as an
optimisation.

---

## 10. Phase 5 — Flutter client, then the hard gate

### 10.1 The client work

**There are three clients, not one** (decision 22). An earlier draft scoped only the shared package:

| App | Own repo files | Socket call sites | Deployed? |
|---|---:|---:|---|
| `palakat_shared` (consumed by `palakat`) | 22 repositories | 138 | — |
| `palakat` (mobile) | 8 | 2 | never (`v*` tags: zero) |
| **`palakat_admin`** (web, Vercel) | 2 | **9** | **yes — 2026-03-20** |
| **`palakat_super_admin`** (web, Vercel) | 5 | **33** | never — no workflow runs |

**Neither admin app imports `palakat_shared/core/repositories/` — zero imports each.** They have their own data
layers and hold `SocketService` directly, so migrating the 22 shared repositories does not touch them. That is
~42 call sites and two apps the estimate previously priced at zero.

Two corrections to the earlier framing:

- "`http_service.dart` already sits beside it" implies a trodden path. **One file references it repo-wide**, and
  **zero of the 22 repositories use it.** It is a file, not a precedent.
- `palakat_super_admin` is the heaviest client migration in the repo and has never served anyone. It is migrated
  rather than deleted (decision 22) because church-request approval and song-database management have no other
  home — but it is the natural candidate to sequence **last**, since nothing depends on it yet.

The UI layer never touches the socket. That much is favourable and still true.

1. **Re-point the data layers** onto REST routes, working from the Phase 1 parity table — 22 shared repositories
   first, then `palakat_admin`'s 2, then `palakat_super_admin`'s 5. One repository at a time.
2. **Topic subscription** replaces room joins. On login/session restore, `subscribeToTopic` for `account.{id}`,
   `membership.{id}`, `church.{id}`, and the column/bipra topics.
   **`unsubscribeFromTopic` on logout and on church switch** — a missed unsubscribe leaks another church's pings
   to that device permanently, and **there is no server-side revocation for topics**.
3. **Handle change signals — invalidate only.** `realtime_events_service.dart` stops merging payload content and
   marks the relevant provider **stale**. It does **not** refetch (§9.4). The read happens when a screen that
   needs the data is next viewed. Simpler than today, and it is the fan-out control the cost model depends on.
   Notifications are a separate path: the OS renders them, and the app fetches content only when one is tapped.
4. **Report progress polling** — 2 s, only while the modal is open, hard stop on close plus a backstop timeout.
5. **No new dependency** — `firebase_messaging` is already there (§2.4).

**Price note:** every RPC that was one socket message becomes one **billable request** — and now bills *twice*,
once as a Cloud Run request and once as Supabase egress (§0.1). At 24 juta requests/month that is Rp 162.800 of
compute plus the Pro tier the egress forces. Requests are the **largest line item in the target architecture**,
larger than CPU. Cache aggressively, coalesce list refreshes, and never refetch on a change signal.

### 10.2 ~~The hard gate~~ — deleted, there is nothing to drain

**Decision 15 removes this step entirely.** The earlier draft specified a `-breaking` release, a midweek ship
window, a pre-written support answer, and watching Socket.IO connections by client version until they reached
zero. All of it assumed installed clients. Checking:

| | |
|---|---|
| `apps/palakat/pubspec.yaml` | `version: 1.0.0+1` |
| `git tag --list 'v*'` | **empty — never released** |
| Update-gate mechanism | **none.** No version floor in the backend, no force-update check in Flutter; `package_info` appears only on the settings screen |
| Codemagic trigger | `branch_patterns` (`main`, `develop`) — not tags |

So there are no old clients to strand, and no mechanism with which to strand them. The HTTP+FCM client is simply
**the first release**. R7 disappears with it.

Keep the socket running server-side through the transition anyway — it costs nothing on EC2 and it is the
rollback while you are re-pointing 21 repositories.

> **Trigger to reinstate:** if launch happens before Phase 5 completes, this section comes back *and* the update
> gate has to be built first. It is unbuilt work on no phase estimate — treat it as a real dependency, not a flag.

### 10.3 Then delete the socket

Once connections reach zero — which, per decision 15, means *once you stop connecting from your own dev builds*,
not once a user population drains:

- `realtime.gateway.ts`, `rpc-router.service.ts` (the largest file in the backend), `redis-io.adapter.ts`
- `socket_service.dart`
- deps: `@nestjs/websockets`, `@nestjs/platform-socket.io`, `@socket.io/redis-adapter`, `socket_io_client`
- the `RedisIoAdapter` wiring in `main.ts:43-45`

**Do not migrate to Cloud Run before this completes.** One month of socket on Cloud Run costs the full
Rp 875.790.

**Deleting `rpc-router.service.ts` is the biggest maintenance win here** — one transport, one permission model,
one place authorization lives.

---

## 11. Phase 6 — containerize + scaffolding

> **This phase is shared with the Supabase branch.** [#17](https://github.com/meimodev/palakat/issues/17)
> established that report generation cannot run on Deno — pdfkit breaks on the filesystem sandbox, exceljs has no
> Deno support, and the 2 s CPU / 256 MB Edge caps rule it out regardless. So ~2k lines of Node survive a "go",
> and [#27](https://github.com/meimodev/palakat/issues/27) puts them on a Cloud Run Job. The Dockerfile,
> Artifact Registry, secrets, WIF and Cloud Tasks pipeline below get built either way. Two consequences, both to
> be stated rather than buried: this work is not gated on #26, and **a "go" does not remove GCP from the stack**.

### 11.1 Build facts that constrain the Dockerfile

| Fact | Source | Consequence |
|---|---|---|
| pnpm workspace at repo root | `pnpm-workspace.yaml` | **Build context is the repo root.** |
| `packageManager: pnpm@10.17.0` | `package.json:115` | Use corepack. |
| CI uses Node 24 | existing workflow | Base `node:24-slim`. |
| Prisma 7 `prisma-client` generator → `src/generated/prisma`, **untracked** | `schema.prisma:1-5`; `git ls-files` returns 0 | `prisma generate` **must** run in the build before `nest build`. Output is TypeScript, compiled by `tsc`. |
| `datasource db` has **no** `url` | `schema.prisma:7-9` | URL comes from `prisma.config.ts`; needed for `migrate`, not runtime. |
| `build` = `prisma generate && nest build`; `start:prod` = `node dist/src/main.js` | `package.json` | `CMD` is `node dist/src/main.js`. |
| `postinstall: prisma generate` | `package.json` | Install `--ignore-scripts` so caching works, then generate explicitly. |
| No Rust query engine (driver adapter) | `prisma.service.ts` | `node:24-slim` is fine. **Also why cold starts are tolerable** — which now matters, since you accepted them. |
| `app.listen(process.env.PORT \|\| 3000, '0.0.0.0')` | `main.ts` | Already Cloud Run compatible. Do not set `PORT`. |

### 11.2 `apps/palakat_backend/Dockerfile`

```dockerfile
# syntax=docker/dockerfile:1
# Build context is the REPO ROOT:  docker build -f apps/palakat_backend/Dockerfile .

FROM node:24-slim AS base
ENV PNPM_HOME=/pnpm PATH=/pnpm:$PATH
RUN corepack enable
WORKDIR /repo

FROM base AS deps
COPY pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/palakat_backend/package.json apps/palakat_backend/
RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --frozen-lockfile --ignore-scripts

FROM deps AS build
COPY apps/palakat_backend apps/palakat_backend
RUN pnpm --dir apps/palakat_backend run build   # prisma generate && nest build

FROM base AS runtime
ENV NODE_ENV=production
# ponytail: fonts-dejavu-core satisfies UNICODE_FONT_CANDIDATES[0] — the same font
# the Ubuntu EC2 box resolves. Alternative is committing the TTF to src/assets/fonts/.
RUN apt-get update \
 && apt-get install -y --no-install-recommends fonts-dejavu-core ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY --from=build /repo/node_modules                          /repo/node_modules
COPY --from=build /repo/apps/palakat_backend/node_modules     /repo/apps/palakat_backend/node_modules
COPY --from=build /repo/apps/palakat_backend/dist             /repo/apps/palakat_backend/dist
COPY --from=build /repo/apps/palakat_backend/prisma           /repo/apps/palakat_backend/prisma
COPY --from=build /repo/apps/palakat_backend/prisma.config.ts /repo/apps/palakat_backend/
COPY --from=build /repo/apps/palakat_backend/package.json     /repo/apps/palakat_backend/

WORKDIR /repo/apps/palakat_backend
USER node
CMD ["node", "dist/src/main.js"]
```

**Image size matters more now.** You accepted cold starts, so every scale-from-zero pulls and starts this image.
Phase 5's deletions (socket stack, Pusher) shrink it for free. If cold start exceeds ~3 s afterwards, prune dev
dependencies with `pnpm deploy --prod` — **measure first** (Phase 9).

`.dockerignore` at repo root:

```
**/node_modules
**/dist
**/.env
**/.env.*
!**/.env.example
build/
.dart_tool/
.git
.claude
ios/ android/ macos/ windows/ linux/ web/
apps/palakat_backend/src/generated
```

The last line matters: a stale local `src/generated/prisma` must never shadow the one built in the image.

### 11.3 GCP scaffolding — `asia-southeast1`

```bash
gcloud config set project PROJECT_ID
gcloud services enable run.googleapis.com artifactregistry.googleapis.com \
  secretmanager.googleapis.com cloudscheduler.googleapis.com \
  cloudtasks.googleapis.com iamcredentials.googleapis.com

gcloud artifacts repositories create palakat \
  --repository-format=docker --location=asia-southeast1
```

Set an Artifact Registry **cleanup policy** immediately (keep 10 recent, delete untagged after 7 days), or storage
grows forever at Rp 1.850/GB-bulan unnoticed.

Three identities, kept separate:

| Identity | Roles |
|---|---|
| `palakat-backend` (runtime) | `roles/secretmanager.secretAccessor` |
| `palakat-invoker` (Scheduler + Tasks) | `roles/run.invoker` on the service |
| `palakat-deployer` (GitHub Actions) | `roles/run.admin`, `roles/artifactregistry.writer`, `roles/iam.serviceAccountUser` |

### 11.4 Configuration — the trap this project has

`app.module.ts:38-45` sets
`ignoreEnvFile: !DOTENV_CONFIG_PATH && (NODE_ENV === 'production' || INVOCATION_ID !== undefined)`.

**Set `NODE_ENV=production` and do NOT set `DOTENV_CONFIG_PATH`.** Then `@nestjs/config` reads only `process.env`,
and the sectioned `[local]/[staging]/[production]` `.env` format that `prisma.config.ts` parses is bypassed
entirely. That format exists for the EC2 file at `/etc/palakat/palakat_backend.env` and has no Cloud Run
equivalent. `PALAKAT_ENV` becomes irrelevant once `DATABASE_URL` is a real environment variable. **It looks like
something that needs porting; it does not.**

Secrets, one per entry: `JWT_SECRET`, `DATABASE_URL`, `DATABASE_URL_DIRECT`, `HEALTH_PAGE_SECRET`,
`APP_CLIENT_PASSWORD`, `FIREBASE_PRIVATE_KEY`, `SONG_DB_FILE_ID`. Pusher's two are deleted in Phase 4.

> ⚠️ **`FIREBASE_PRIVATE_KEY` is the one that will break.** In the EC2 `.env` it is a single line with literal
> `\n` escapes. Secret Manager will happily store a real multi-line PEM instead — a *different* string, producing
> an opaque failure at `cert(...)` (`firebase-admin.service.ts:36`). **Store it byte-identical to the `.env` line,
> escapes included.** This matters more now: FCM delivery depends on it, so a bad key means **all push silently
> stops**, not just Firebase auth.

WIF — the existing workflow already declares `permissions: id-token: write`:

```bash
gcloud iam workload-identity-pools providers create-oidc github-provider \
  --location=global --workload-identity-pool=github \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
  --attribute-condition="assertion.repository=='GH_ORG/REPO'"
```

**`--attribute-condition` is not optional.** Without it any GitHub repository on the internet can mint tokens for
your project.

---

## 12. Phase 7 — deploy HTTP-only, priced for scale-to-zero

### 12.1 Service configuration

```bash
gcloud run deploy palakat-backend \
  --image=asia-southeast1-docker.pkg.dev/PROJECT_ID/palakat/backend:TAG \
  --region=asia-southeast1 \
  --service-account=palakat-backend@PROJECT_ID.iam.gserviceaccount.com \
  --min-instances=0 \
  --max-instances=5 \
  --cpu=1 --memory=1Gi \
  --concurrency=80 \
  --timeout=300 \
  --allow-unauthenticated \
  --set-env-vars=NODE_ENV=production,FORCE_SEEDING=false,DATABASE_POOL_MAX=3,… \
  --set-secrets=JWT_SECRET=JWT_SECRET:latest,DATABASE_URL=DATABASE_URL:latest,…
```

Against the rejected socket configuration — this is where the money is:

| Setting | With socket (rejected) | HTTP-only (this plan) | Why |
|---|---|---|---|
| `min-instances` | 1 | **0** | Nothing pins an instance. The entire saving. |
| CPU allocation | `--no-cpu-throttling` | **request-based (default)** | Cron is gone (Phase 3); nothing needs CPU between requests. |
| `timeout` | 3600 s | **300 s** | No connections to hold. Long work is a Task. |
| `session-affinity` | required | **off** | No sticky handshake. |
| `max-instances` | 1 (forced) | **5** | Safe now: atomic claim, no in-memory socket adapter. |
| Redis | mandatory at >1 instance | **none** | Rp 666.000/bulan line item deleted. |

`--max-instances=5` is a **cost ceiling**, not a capacity target. Raise it deliberately, with a budget alert
already in place.

**Startup probe:** default **TCP**. `/health` sits behind `HealthSecretGuard` (`health-secret.guard.ts:29`
requires `x-health-secret`), and header-bearing HTTP probes cannot be expressed in `gcloud run deploy` flags —
they need `gcloud run services replace service.yaml`. TCP suffices because the app binds its port only after
`PrismaService.$connect()` resolves.

**No pre-warm Scheduler job**, per decision 6. If Sunday latency proves annoying, adding one is a single
`gcloud scheduler` command with no code change — the escape hatch stays open.

### 12.2 Migrations — a Cloud Run Job, never container start

```bash
gcloud run jobs create palakat-migrate \
  --image=…:TAG --region=asia-southeast1 \
  --service-account=palakat-backend@PROJECT_ID.iam.gserviceaccount.com \
  --set-secrets=DATABASE_URL=DATABASE_URL_DIRECT:latest \
  --command=npx --args=prisma,migrate,deploy \
  --max-retries=0 --task-timeout=600
```

1. **`DATABASE_URL_DIRECT`, not the pooler** — DDL needs port 5432.
2. **`npx prisma migrate deploy`, not `pnpm run db:deploy`** — the script also runs `prisma generate`, pointless
   in a runtime container.
3. `prisma.config.ts` resolves `datasource.url` from `process.env` first, so no `.env` need exist in the image.
4. **Never run the seed in production.** `FORCE_SEEDING=false`; `db:push` (`--force-reset`) must not exist in any
   pipeline that can reach production.
5. **Supabase Free has no automated backups** (§13 R2). `pg_dump` to a GCS bucket **before every migration run**,
   as a pipeline step, not a habit.

### 12.3 CI/CD

The existing workflow (~150 lines: temporary SG ingress, scp a tarball, ssh, build on the box, `db:deploy`,
`systemctl restart`, health poll, revoke ingress) is **deleted**. Keep the `deploy-backend*` tag trigger.

```yaml
      - name: Build & push
        run: |
          IMAGE="asia-southeast1-docker.pkg.dev/${{ vars.GCP_PROJECT }}/palakat/backend:${{ github.sha }}"
          docker build -f apps/palakat_backend/Dockerfile -t "$IMAGE" .
          docker push "$IMAGE"
          echo "IMAGE=$IMAGE" >> "$GITHUB_ENV"
      - name: Backup before migrating        # Supabase Free has no automated backups
        run: |
          pg_dump "${{ secrets.DATABASE_URL_DIRECT }}" | gzip \
            | gcloud storage cp - gs://palakat-db-backups/$(date +%Y%m%d%H%M%S).sql.gz
      - name: Migrate
        run: |
          gcloud run jobs update palakat-migrate --image="$IMAGE" --region=asia-southeast1
          gcloud run jobs execute palakat-migrate --region=asia-southeast1 --wait
      - name: Deploy (no traffic)
        run: gcloud run deploy palakat-backend --image="$IMAGE" --region=asia-southeast1 --no-traffic --tag=candidate
      - name: Smoke the candidate
        run: |
          URL=$(gcloud run services describe palakat-backend --region=asia-southeast1 \
                 --format='value(status.traffic.filter("tag=candidate").url)')
          curl -fsS -H "x-health-secret: ${{ secrets.HEALTH_PAGE_SECRET }}" "$URL/health"
      - name: Promote
        run: gcloud run services update-traffic palakat-backend --region=asia-southeast1 --to-latest
      - name: Deploy the internal service        # same image, IAM-protected — ADR-0005
        run: gcloud run deploy palakat-internal --image="$IMAGE" --region=asia-southeast1 --no-allow-unauthenticated
```

**Both services deploy from the same `$IMAGE` in the same run.** If they ever diverge, that is the bug — never
promote one without the other.

Order matters: **backup → migrate → deploy `--no-traffic` → smoke the tagged revision → promote.** The
`--tag=candidate` URL lets you hit the new revision before any user does — something `systemctl restart` never
allowed.

Migrations run *before* the new code takes traffic, so **every migration must be backward compatible with the
running revision**. Expand/contract, never rename-in-place.

Delete `EC2_SSH_PRIVATE_KEY`, `EC2_SSH_PASSPHRASE`, `EC2_HOST`, `EC2_USER`, `EC2_PORT`,
`EC2_SECURITY_GROUP_ID`, `AWS_ROLE_TO_ASSUME`. **Revoke the SSH key when you delete the secret** — a deleted
GitHub secret is not a revoked key.

---

## 13. Phase 8 — cutover

> **Why this is kept in full while §10.2's gate was deleted.** Both were written for a user base that does not
> exist, but they fail differently. The gate depended on tooling nobody has built; the ceremony below depends
> only on patience. Per decision 16 it runs as a **rehearsal** — a soak that finds nothing costs nothing, and the
> runbook gets learned while a mistake costs an afternoon rather than a congregation. Steps 5–8 protect nobody
> today and are executed anyway, deliberately.

1. Deploy to Cloud Run against the **production** Supabase database, no DNS change. Both stacks run.
2. Verify on the `run.app` URL: health, login, a REST call per module, a PDF export, one report job end-to-end
   **including its Cloud Task**, and one FCM delivery to a real device.
3. **Measure cold start.** You accepted it — but measure it so the decision stays informed. If it is worse than
   ~5 s, trim the image before considering `min-instances`.
4. Watch the 07:00 **Asia/Makassar** Scheduler job fire exactly once, and confirm the daily orphan sweep runs.
5. **Lower DNS TTL to 60 s at least 24 hours beforehand.** The step teams skip and then cannot roll back.
6. Cut over — **outside** a service, and midweek.
7. Soak **one full week including a Sunday**, EC2 still running and warm.
8. Stop the EC2 instance (do not terminate). Wait another week. Then terminate and **release the Elastic IP** — an
   unattached EIP still bills.

**Rollback ladder:**

| Failure | Action | Time |
|---|---|---|
| Bad revision | `gcloud run services update-traffic --to-revisions=PREVIOUS=100` | seconds |
| Cloud Run broadly wrong | DNS back to EC2 (why it stays warm a week) | ~60 s at TTL 60 |
| ↳ *need the EC2 runbook?* | It was deleted on consolidation (decision 35). `git show 1ee2a96^:docs/palakat-backend-aws-ec2-cicd-deployment-guide.md` | seconds |
| Bad migration | Restore the `pg_dump` from §12.2. **There is no `migrate deploy` rollback.** | minutes |

---

## 14. Phase 9 — cost tuning

Measure first.

### 14.1 Where the money goes

At 4.000 users, 1 vCPU / 1 GiB, and the **24 juta stress case** — an upper bound carried from a socket-era
assumption, not a forecast (decision 20, R20):

| Line item | 180h active | 90h active |
|---|---:|---:|
| CPU (net of 180.000 vCPU-s free) | $3.46 · Rp 64.010 | **$0 — free tier covers it** |
| Memory (net of 360.000 GiB-s free) | $0 | $0 |
| Requests (24 juta, net of 2 juta free) | $8.80 · Rp 162.800 | $8.80 · Rp 162.800 |
| **Database (Supabase Pro — see below)** | **Rp 462.500** | **Rp 462.500** |
| **Total** | **Rp 689.310** | **Rp 625.300** |

**The database is the largest line item at this scale, and it is forced by request volume, not by data volume.**
24 juta cross-cloud queries cannot fit in Free's 5 GB egress — that would need 208-byte responses. Pro's 250 GB
covers it comfortably, but Pro's $25 alone exceeds the entire EC2 bill this plan set out to beat (§0.1).

**After the database, requests dominate — not CPU.** That still inverts the usual intuition: reducing request
count beats any container tuning, and it now compounds, because every request avoided is both a Cloud Run charge
and a gigabyte of egress not spent. Cache aggressively on the client, coalesce list refreshes, and never refetch
on a change signal (§9.4).

Break-even for free compute: **50 h/bulan at 1 vCPU, 100 h/bulan at 0,5 vCPU.**

### 14.2 Right-size, and consider splitting the report worker

The service is sized for its **peak** — a large `pdfkit`/`exceljs` export — though that is rare. Cloud Run's
writable filesystem is tmpfs charged against the memory limit. Mitigating factor: **generated reports upload to
Firebase Storage** (`report.service.ts:2133`), so files do not accumulate locally.

**Optimisation:** move rendering into a separate Cloud Run **Job** at 2 vCPU / 2 GiB, triggered by the Phase 3
Cloud Task. The API service then drops to **0,5 vCPU / 512 MiB**, where 100 h/month is free.

| | Single service | Split |
|---|---:|---:|
| API compute, 90h | $0 at 1 vCPU | $0 at 0,5 vCPU, double the headroom |
| API compute, 180h | Rp 64.010 | **~Rp 0** |
| Report rendering | forces 1 GiB+ sizing always | billed per run — minutes/month |
| tmpfs OOM risk | real | **isolated** |

Saves ~Rp 60 ribu/bulan and removes R7. **Only if the bill or an OOM justifies it** — the Cloud Task trigger
already exists, so it is cheap to add later.

### 14.3 Guardrails, day one

- **Billing budget alert in USD** at 100 / 150 / 200%. Bills are USD, funding is IDR — budget with **10–15% FX
  headroom**. A smaller USD bill also means less currency exposure.
- **`max-instances` explicit**, never default.
- **Artifact Registry cleanup policy.**
- **Log-based alerts** on `Container called exit` and Cloud Tasks dead-letter depth — with no cron loop, a
  silently failing queue is how reports stop without anyone noticing.
- **Uptime check** on `/health` with the secret header (Cloud Monitoring uptime checks *do* support custom
  headers, unlike startup probes).
- **Supabase Free usage alerts** — §15 R2/R3.

---

## 15. Risk register

| # | Risk | Likelihood | Impact | Mitigation | Phase |
|---|---|---|---|---|---|
| R1 | **Phase 2 registers routes with wrong or missing permissions** | **High if rushed** | **Privilege escalation** — created by this migration, not inherited | Parity table reviewed independently; under-privileged-token test on every route | 2 |
| R2 | **Supabase Free has no automated backups** | Certain | **Unrecoverable data loss on a bad migration** | `pg_dump` to GCS before every migration, as a pipeline step | 7 |
| R3 | **Supabase Free egress ceiling is ~5× below the modelled load** | **Certain at scale, not a risk** | **The Rp 0 database line is false above ~5 juta requests/bulan** — Pro at Rp 462.500 exceeds the whole EC2 bill | Priced explicitly at both scales (§0.1, §14.1); move to Pro on first real congregation (decision 12); §9.4 keeps the crossover far away | 0, 5, 9 |
| R3b | Free's other ceilings — 500 MB database, 50.000 MAU, paused after 1 week idle | Medium | Project throttled or suspended | Usage alerts; the daily birthday job prevents the idle pause (§8.2); **daily** `pg_dump` to GCS while on Free | 0, 9 |
| R4 | **Supabase Free connection ceiling vs. spiky scale-from-zero** | Medium | Connection refusals under load | `DATABASE_POOL_MAX=3`, transaction pooler, `max-instances=5` | 0, 7 |
| R5 | FCM topics client-subscribable → cross-church leak | **High if payloads carry content** | **Confidentiality breach** | Bare change-signals only; refetch over authenticated REST | 4 |
| R6 | Polling cron survives into Cloud Run | Medium | **Price case deleted** — instance never idles | Cloud Tasks, not a Scheduler poll | 3 |
| ~~R7~~ | ~~Hard gate strands users who cannot update~~ | **Retired** | — | Decision 15: never released, zero installs, no gate mechanism exists. Returns only if launch precedes Phase 5 | 5 |
| R7b | **Update gate is unbuilt work assumed to be done** | Medium | Phase 5 blocks on tooling nobody has estimated | Only bites if launch precedes Phase 5 — treat as a dependency, not a flag | 5 |
| R8 | Duplicate report processing at >1 instance | Certain without the fix | Correctness + double CPU | `FOR UPDATE SKIP LOCKED` | 0 |
| R9 | `FIREBASE_PRIVATE_KEY` newline mangling | High | **All push silently stops** | Store byte-identical to `.env`; assert on the parsed key at boot | 6 |
| R10 | PDF glyphs silently degrade | High if unaddressed | Corrupt reports found by users | `fonts-dejavu-core` + startup assertion | 0 |
| R11 | Prepared statements break on PgBouncer | Medium | Runtime query failures | Full e2e against the pooler **before** cutover | 0 |
| R12 | Request count above model | Medium | Requests are the dominant cost | Client caching; monitor request count as the primary price metric | 5, 9 |
| R13 | Cold start hurts the Sunday peak | **Medium — accepted** | 2–5 s first request | Measure; trim image; pre-warm is one command if needed | 8, 9 |
| R14 | Topic unsubscribe missed on logout / church switch | Medium | Device receives another church's pings permanently | Explicit unsubscribe; no server-side revocation exists | 5 |
| R15 | tmpfs OOM during a large export | Low–Medium | Instance killed mid-render | 1 GiB minimum; reports already stream to Storage; split worker if needed | 7, 9 |
| R16 | Non-backward-compatible migration during rollout | Medium | Old revision errors mid-deploy | Expand/contract; backup precedes every run | 7 |
| R17 | Runaway `max-instances` | Low | Rp 10 juta surprise | Explicit ceiling + budget alerts | 7, 9 |
| R18 | **Validation drift** — REST rejects payloads the socket accepted | **High without the table's request-shape column** | 400s discovered per-repository during Phase 5, while transport is also changing | Decision 18: request shape sourced from the client and carried in the parity table; `ValidationPipe` stays strict deliberately | 1, 2, 5 |
| R19 | **Unfinalized uploads** accumulate in the bucket | Medium | Storage cost; `FileManager` and storage disagree | [ADR-0004](./adr/0004-upload-trust-boundary.md): row written only after reading real GCS metadata; daily orphan sweep becomes load-bearing | 2, 3 |
| R20 | **Request model is a socket-era guess** | **Certain — it is already known wrong** | The Free→Pro crossover (§0.1) is priced against a number derived from hours-connected | ~~Bottom-up estimate from screen flows~~ **dropped, decision 34** — it gates nothing (decision 12's trigger is an event, `max-instances` is a cost ceiling) and would model a client layer Phase 5 rewrites. 24 juta relabelled a stress case; **instrument day one** and let measurement replace both numbers | 9 |
| R21 | **Two admin clients missing from the Phase 5 estimate** | **Certain — already found** | ~42 call sites and two apps priced at zero; `palakat_admin` is live, so it breaks visibly | Decision 22: three clients, ~180 call sites, Phase 5 re-sized to 3–6 weeks | 5 |
| R22 | **Ceiling and no-go cost were misaligned** | **Certain — already found** | #26 would have been judged against a 3× bar that is really ~1× | Decision 23: no-go is 8–12 weeks; ADR-0002 amended in place rather than silently corrected | — |
| R23 | `/internal/*` reachable on the public service | Low after decision 24 | Full authorization bypass | Second IAM-protected service ([ADR-0005](./adr/0005-internal-endpoints-separate-service.md)) **plus** an explicit test that the public service does not serve the prefix | 3b, 7 |
| R24 | **Phase 2's security gate passes while covering 57% of the surface** | **Certain under verbatim parity** | 94 auth-only routes registered; the under-privileged-token test has nothing to assert on them and reports green | Decision 31 / [ADR-0008](./adr/0008-authorization-hardening-precedes-transport.md): Phase 1.5 fixes the 94 on RPC **before** Phase 2, so the gate covers the surface | 1.5, 2 |
| R25 | **Credential stuffing against the public auth routes** | Medium once Phase 2 registers them | Account compromise, **and a billing event** — it scales instances and Supabase egress under `min-instances=0` | Decision 30: `ThrottlerModule` global, `@Throttle` on `/auth/*` (§7.1). Cloud Armor later if it is not enough | 2 |
| R26 | **Phase 1.5 is an unmeasured block on the critical path** | Medium | 1–2 weeks is a triage-informed guess; the ~1½–2½ weeks it adds is what moved 8–12 to ~10–14 | Triage the 94 into three buckets first (~1 day) — only two buckets cost anything. If the triage says otherwise, the 14-week bar and its descope ladder are the control | 1.5 |
| R27 | **Launch imposed before the plan completes** | Low under decision 28, **not zero** | Decisions 12, 15, 16 all reverse at once; §10.2's gate returns and its tooling is unbuilt | [ADR-0007](./adr/0007-release-freeze-and-the-14-week-bar.md) makes the freeze explicit rather than assumed. If it is overridden, the update gate is built **first**, and the ADR is void | 5 |

---

## 16. Checklist

```
DONE — shipped in #35
          [x] stale-job reaper (the live defect) + reclaim test
          [x] atomic job claim FOR UPDATE SKIP LOCKED + concurrency test
          [x] NotoSans-Regular.ttf committed to src/assets/fonts/ + startup assertion
          [x] stale lockfiles, vercel.json, dead emitToSocketId removed

RELEASE FREEZE IN FORCE until Phase 9 closes — decision 28, ADR-0007
BAR: 14 weeks. Descope ladder: palakat_super_admin, then the 31 uncalled routes

ON EC2 — no cost change
Phase 0   [ ] DATABASE_POOL_MAX; e2e green against the transaction pooler
          [ ] Supabase Free limits checked; usage alerts set
          [ ] daily pg_dump → GCS starting NOW — palakat_admin is already live

Phase 3a  [ ] birthday @Cron gains { timeZone: 'Asia/Makassar' }        ~1 hour
          [ ] handler date-matching moved to Asia/Makassar too
          [ ] announce it — notifications move from ~15:00 to 07:00 local

Phase 1   [ ] PARITY TABLE GENERATOR: walks rpc-router.service.ts, emits guard
              + exact allow-list per case                    (ADR-0009)
          [ ] CI CHECK: @RequirePermissions per route == RPC allow-list
          [ ] PermissionsGuard + @RequirePermissions, ported verbatim from RPC
          [ ] churchId resolution attached to the request
          [ ] PaginationInterceptor overlap checked before adding anything
          [ ] request-shape column sourced from the CLIENT, not the untested DTOs

Phase 1.5 [x] triage the 94 auth-only actions → 11 inline / 27 scoped / 56 bare
Phase 1.5 [x] sub.join room authorization (§3.1 — was a live leak)
Phase 1.5 [x] ops.approvalRule.manage enforced; `unchecked: []`
Phase 1.5 [x] #59 — read all 27 scoped-arg actions; all 27 enforce, none moved
Phase 1.5 [x] approver.update self-check made fail-CLOSED (was skipped when the
              requester was absent; PATCH /approver/:id passed none)
Phase 1.5 [x] #57 — 22 of 26 bare writes gated; new ops.church.manage;
              123 → 103 actions without a permission check
Phase 1.5 [ ] the bare reads: #58                                    🔴 SECURITY GATE
Phase 1.5 [ ] #63 — the 4 member-app writes need self-scoping, not a permission
Phase 1.5 [ ] #61 — GET /church-request returns every request, all churches
Phase 1.5 [ ] #60 — decide the ops.approval.finance widening
              (correct as-is / needs permission / needs church-scoping)
          [ ] fix buckets 2 and 3 ON THE RPC PATH, before any controller exists
          [ ] ops.approval.finance — referenced, never defined: remove or define
          [ ] ops.approvalRule.manage — defined, never checked: dead, or the
              approval-rule actions are under-guarded. Decide which
          [ ] regenerate the table; CI check green

Phase 2   [ ] all 27 existing controller files DELETED first     🔴 SECURITY GATE
          [ ] every route written from the GENERATED table; 25 modules registered
          [ ] all 166 actions ported, incl. the 31 nothing calls (decision 27)
          [ ] 4 NEW routes: approver.delete + churchLetterhead getMe/updateMe/
              setLogo — client calls that throw Unknown action today
          [ ] ThrottlerModule global; @Throttle tightened on /auth/*
          [ ] every route guarded per the table
          [ ] ValidationPipe left strict — REST is deliberately stricter than RPC
          [ ] response envelope byte-identical to RPC
          [ ] under-privileged-token test green on every route
          [ ] fresh-agent read of Verb/Route + the 1.5 triage buckets
          [ ] upload → signed URL with length+type bound at signing
          [ ] upload → finalize endpoint verifies REAL GCS metadata before
              writing FileManager; orphan sweep covers unfinalized objects

Phase 4   [ ] FirebaseAdminService.messaging() added
          [ ] emitToRoom → FCM, NO ENTITY CONTENT in any push
          [ ] notification.* keeps an OS-rendered GENERIC title/body — verify on a
              KILLED app, both platforms. No onBackgroundMessage handler added.
          [ ] change signals (activity/finance/approval) data-only
          [ ] Pusher Beams retired AFTER FCM proven; deps + secrets + web stub deleted
          [ ] report progress → 2s polling

Phase 5   [ ] THREE clients: 22 shared repos + palakat_admin (2) +
              palakat_super_admin (5). ~180 call sites, not 138
          [ ] topic subscribe AND unsubscribe on logout / church switch
          [ ] change signal → invalidate ONLY; refetch on next view, never on arrival
          [ ] NO -breaking gate — never released, nothing to drain (decision 15)
          [ ] socket code deleted once your own dev builds stop connecting

THEN MIGRATE
Phase 6   [ ] Dockerfile (context = repo root); .dockerignore excludes src/generated
          [ ] asia-southeast1 everywhere; registry + cleanup policy
          [ ] three separate service accounts
          [ ] FIREBASE_PRIVATE_KEY verified byte-identical
          [ ] WIF with --attribute-condition

Phase 3b  [ ] report queue → Cloud Tasks (NOT a Scheduler poll)     🔴 PRICE GATE
          [ ] birthday → Scheduler --time-zone=Asia/Makassar, replacing 3a's @Cron
          [ ] VERIFY it fires — R3b's anti-idle-pause depends on it
          [ ] /internal/* on a SEPARATE service, --no-allow-unauthenticated
          [ ] test: /internal/* NOT reachable on the public service
          [ ] daily orphan sweep

Phase 7   [ ] min=0, max=5, request-based, timeout 300, no affinity, no Redis
          [ ] palakat-internal deployed from the SAME image, IAM-bound
          [ ] pg_dump → GCS step precedes every migration
          [ ] migrations = Cloud Run Job on the DIRECT url
          [ ] CI/CD: backup → migrate → --no-traffic → smoke → promote
          [ ] EC2/AWS secrets deleted AND SSH key revoked

Phase 8   [ ] DNS TTL 60s, 24h ahead; cut over midweek
          [ ] cold start measured; Scheduler + Tasks verified end-to-end
          [ ] one-week soak with EC2 warm → stop → terminate → release EIP

Phase 9   [ ] USD budget alert; IDR budget +15% headroom
          [ ] request count monitored as the primary price metric
          [ ] Supabase egress monitored as the SECOND price metric — 5 GB Free ceiling
          [ ] Pro provisioned when the first real congregation onboards
          [ ] split report worker IF the bill or an OOM justifies it
          [ ] NO bottom-up request estimate — measure instead (decision 34)

THEN, AND ONLY THEN
          [ ] lift the release freeze; palakat 1.0.0 ships          (ADR-0007)
```

---

## 17. Bottom line

| Question | Answer |
|---|---|
| Is this approved? | **Yes.** [#26](https://github.com/meimodev/palakat/issues/26) answered no-go on removing NestJS; [ADR-0006](./adr/0006-no-go-on-removing-nestjs.md) ratified it 2026-07-22. Scope grilled and confirmed the same day — §0.05. |
| How long, and what if it runs over? | **~10–14 weeks, bar at 14** ([ADR-0007](./adr/0007-release-freeze-and-the-14-week-bar.md)). Over the bar, shed `palakat_super_admin` first, then the 31 uncalled routes. ADR-0002's 12–15 weeks judged the *Supabase* branch and expired with the fork — not a comparison. |
| What makes all of this cheap to get wrong? | **The app has never been released** — `1.0.0+1`, zero tags, no update gate anywhere. No users to strand, no data to lose, no rollback to rehearse under pressure. That is the enabling condition for every aggressive choice here, and it expires at launch — which is why launch is frozen behind Phase 9 (decision 28). |
| What does the freeze cost? | The plan's duration **is** the launch delay. That is the trade accepted in ADR-0007, and the 14-week bar is the control on it. |
| Cheaper than today? | **Only while small.** At launch scale Rp 0 vs Rp 378 ribu. At 4.000 users, Rp 625–689 ribu vs Rp 378 ribu — Supabase Free cannot carry 24 juta cross-cloud queries, and Pro alone costs more than the EC2 box. Redis and Pusher Beams are still deleted either way. |
| Biggest cost in the project? | **Phase 2**, 3–4 weeks, now preceded by **Phase 1.5**, 1–2 weeks. The REST surface is 131 unwired, unguarded, untested routes — not the "already exists" the analysis claimed. |
| Most dangerous mistake? | Registering routes in Phase 2 without correct permissions. The vulnerability is **created by** this work, not inherited. Its quiet twin: **letting the gate pass while it covers 57% of the surface** — which is what Phase 1.5 exists to prevent ([ADR-0008](./adr/0008-authorization-hardening-precedes-transport.md)). |
| Most expensive mistake? | Replacing the 10-second poller with a **Scheduler poll instead of Cloud Tasks** — the instance never idles and the price case evaporates. |
| Most easily missed? | Putting **content in FCM payloads**. Topics are client-subscribable; socket rooms were not. Its twin: over-correcting to data-only everywhere, which **deletes tray notifications** for backgrounded apps — content-free, not notification-free ([ADR-0003](./adr/0003-push-splits-by-category.md)). |
| Why migrate last? | The socket on Cloud Run costs Rp 875.790/bulan. The refactor is free on EC2. |
| What is the real floor? | **Requests, not CPU** — and they now bill twice, as Cloud Run requests *and* Supabase egress. Client caching plus invalidate-only change signals (§9.4) is the main price lever after migration, and the thing keeping the Free→Pro crossover distant. |
| Biggest non-cost win | Deleting `rpc-router.service.ts`: one transport, one permission model, one place authorization lives. |
| What survives the migration itself? | The **CI permission-diff check** ([ADR-0009](./adr/0009-parity-table-is-generated-not-reviewed.md)). When the RPC router is deleted the diff loses its left-hand side and degrades to asserting every registered route carries an explicit permission or a recorded exemption. Keep that half — it is the only artefact here that keeps paying after Phase 9. |
