# ADR-0006: No-go on removing NestJS

**Date:** 2026-07-22
**Status:** Proposed — answers [#26](https://github.com/meimodev/palakat/issues/26); merging this ratifies it
**Supersedes:** nothing. Closes the fork opened by [#14](https://github.com/meimodev/palakat/issues/14).

## Verdict

**No-go.** Do not port `palakat_backend` to Supabase. Proceed with the Cloud Run
plan, which per [ADR-0002](./0002-effort-ceiling-and-meaning-of-no.md) is what
"no" commits to — socket deleted, REST surface built, Cloud Run. Not "stay as we are".

## The decisive finding

**[#17](https://github.com/meimodev/palakat/issues/17) + [#27](https://github.com/meimodev/palakat/issues/27): a "go" does not remove GCP.**

Report generation cannot run on Edge Functions. `pdfkit` hits Deno's filesystem
sandbox on its font-loading path, `exceljs` has no supported Deno path, and the
2-second CPU cap is not liftable — `EdgeRuntime.waitUntil()` postpones worker
retirement without raising the budget. Supabase has no long-running compute tier
to fall back on. #27 therefore places the surviving Node worker on **Cloud Run
Jobs triggered by Cloud Tasks**.

So the end state of "go" is Supabase **plus** GCP **plus** Firebase — three
platforms where there are currently two. The ticket asks whether to remove NestJS
entirely, and the answer is that it cannot be removed entirely: the framework
goes, the Node runtime stays, and the GCP account stays with it.

That matters because consolidation was the driver. Every other argument for the
port — less ops surface, one vendor, one dashboard, one bill — is downstream of
an assumption that the port ends with one platform. It does not. **No cost
estimate can justify a benefit that does not arrive**, which is why this finding
is decisive on its own and why the verdict does not depend on
[#25](https://github.com/meimodev/palakat/issues/25) (see below).

## Supporting findings

Each of these would be survivable alone. Together they remove any margin.

**The bar is 1×, not 3×** ([#16](https://github.com/meimodev/palakat/issues/16)).
The ceiling stayed at 12–15 weeks, but the marginal cost of "no" was corrected
from 4–5 weeks to **8–12 weeks** once the Flutter client work — three apps,
~180 call sites — was counted. Supabase must now land at roughly the same cost
as staying on Nest, not merely within triple it.

**The client rewrite is common to both branches.** The RPC router is deleted on
either verdict ([#23](https://github.com/meimodev/palakat/issues/23)), and
Supabase Realtime has no request/response primitive
([#18](https://github.com/meimodev/palakat/issues/18)), so the ~180 call sites
are rewritten either way. The fork is therefore *only* about what the server
becomes — and "go" is a strict superset of "no-go" work.

**Firebase does not leave either** ([#28](https://github.com/meimodev/palakat/issues/28)).
Path B keeps Firebase as the phone verifier because Twilio's Indonesia SMS rate
($0.4414/segment + ~$0.05 ≈ $0.49) is *higher* than Firebase's ($0.35, first
10/day free). Consequences: `auth.uid()` does not work, the Custom Access Token
Hook never fires, and `syncClaims()` is not deleted — it becomes permanent.

**"Database Rp 0" has a ceiling** ([#21](https://github.com/meimodev/palakat/issues/21)).
Free allows 5 GB egress/month. With the backend on GCP, every query bills as
Supabase egress. At a realistic ~1 KB response the Free tier holds to roughly
5 juta requests/month (≈800–1.600 users), after which Pro at Rp 462.500/bulan
alone exceeds the entire current EC2 bill of Rp 378.029.

**RLS is not less work than the guards it replaces**
([#24](https://github.com/meimodev/palakat/issues/24)). Details below.

## The strongest case for "go", and why it does not carry

The honest argument for the port is **PostgREST**: it generates the REST surface
for free, so the 4–5 weeks of Phase 2 REST work in the no-go branch largely
disappears. That is a real saving and it deserves a real answer.

The answer is that the work does not disappear, it moves — into RLS policy
authoring, which [#24](https://github.com/meimodev/palakat/issues/24) measured
directly rather than estimating:

- **94 of 166 actions are authenticated-but-unauthorized.** RLS has no safe
  "authenticated therefore allowed" tier, so those get policies authored from
  nothing. That is authorization *design*, performed during a migration.
- **Column narrowing has no counterpart to port.** RLS is row-level only. The
  app gets column narrowing free from DTO whitelists; under PostgREST the client
  controls the patch body. Demonstrated: with a full-column grant a treasurer
  moved their own approver row onto a revenue they were never assigned to, with
  every policy predicate still satisfied.
- **Correct-but-catastrophic policy shapes exist.** `(select fn())` runs as an
  InitPlan; `fn()` runs per row. Same logic, both correct, **11.1 ms vs
  10,707 ms** on 200k rows. A reviewer reading for correctness passes the slow one.
- **Invariants held in application code silently vanish.** `ensurePolicyExists()`
  conjures a church's permission row on first read; a policy cannot INSERT. Today
  8 of 10 churches have no policy row, and after the port a *Ketua Jemaat* in one
  of them resolves to zero permissions.

PostgREST removes the typing of endpoints. It does not remove the deciding of
what those endpoints may do, and #24 found that part to be larger here than the
typing was.

## Why this does not wait for #25

[#26](https://github.com/meimodev/palakat/issues/26) asks for the verdict to be
weighed against the *measured* slice cost from #25, which is still open. It is
being answered without it, deliberately.

#25 would sharpen the cost side of the ledger. The decisive finding is on the
**benefit** side: the port does not consolidate platforms. A slice measurement
cannot move that, so #25 can only change a number that is already losing against
a benefit that is already absent. Building it to confirm a conclusion it cannot
overturn is the sunk-cost version of diligence.

**Recommend closing #25 as not-needed**, with this ADR as the reason — not as
"done".

## What is still worth doing

The fork closing does not make the research worthless. Carry forward:

1. **FCM direct, drop Pusher Beams** ([#22](https://github.com/meimodev/palakat/issues/22)).
   Verdict-independent. `firebase-admin` is already initialized; FCM is free at
   any scale where Pusher tiers at $29–$399/mo. Removes two packages and a
   dependency override — the workspace currently stubs `pusher_beams_web` with a
   no-op because the real SDK broke the WASM build. Web push is dead today.
2. **Fix the 94 unguarded actions on Nest.** This is the most valuable thing
   #24 produced and it is a live security finding, not a migration artifact. It
   is *cheaper* on Nest than it would have been under RLS, and it is a
   prerequisite for any future port.
3. **The dead findings from #24.** `ops.approval.finance` is referenced but never
   defined; `ops.approvalRule.manage` is defined but never checked; four client
   calls have no server handler; the five override audit columns are never
   written; `Revenue` is indexed on the dead `isOverridden` and not on `churchId`.
4. **`FOR UPDATE SKIP LOCKED` job claiming and the stale-job reaper**
   ([#20](https://github.com/meimodev/palakat/issues/20)) — merged in
   [#35](https://github.com/meimodev/palakat/pull/35). Correct on either branch.
5. **The parity table** — it is the Phase 1 input to the Cloud Run plan's REST
   surface, and was always shared work.

Explicitly **not** worth adopting piecemeal: Supabase Auth (Path B means no gain),
Supabase Storage (no first-party Dart TUS client — #18), Supabase Realtime for
push-only (FCM already covers it, and it would add a platform for one feature).

## What would flip this

- **Reports stop needing a long-running process** — simplified, moved
  client-side, or bounded under 2s CPU. This is the decisive finding, so
  removing it reopens the question properly.
- **The 94 unguarded actions get guarded on Nest first.** RLS translation then
  becomes mechanical rather than design work, which is item 2 above — doing it
  is genuinely a step toward a future port, not away from one.
- **A second developer joins.** The 8–12 weeks of shared client work is the
  bulk of both branches and is parallelisable; the ceiling is a solo-FTE
  calendar limit.
- **A real congregation onboards and egress economics change.** Would need
  re-running against Pro-tier pricing on both sides, not Free.

## Consequences

- The Cloud Run plan's §0.0 status block is unblocked: it stops being "the no-go
  branch of an open fork" and becomes the approved plan.
- #14, #24, #25, #26 close. The `spike/supabase-15` branch stays as evidence.
- The Supabase spike project can be torn down. Keep `docs/spike/rls/` — it is
  the reproducible record of why, and the input if this is ever reopened.
