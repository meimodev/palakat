---
status: accepted
date: 2026-07-22
relates-to: "ADR-0002, ADR-0006"
---

# The release freeze, the 14-week bar, and what gets dropped if it breaks

`palakat` (mobile) does not launch until the Cloud Run migration completes. That plan is
bounded at **14 weeks**, and if it runs past, scope is shed in a fixed order rather than
the calendar being extended.

## Why a freeze

Every aggressive choice in
[`palakat-backend-gcp-cloud-run-migration-plan.md`](../palakat-backend-gcp-cloud-run-migration-plan.md)
rests on the app being unreleased: no update gate is built (decision 15), the socket is
deleted once *your own dev builds* stop connecting (§10.3), Supabase Free serves production
(decision 12), and Phase 8's cutover runs as a rehearsal where a mistake costs an afternoon
(decision 16).

Launching mid-plan detonates all four at once. It also reinstates §10.2's hard gate, which
depends on an update-gate mechanism that **does not exist** — no version floor in the
backend, no force-update check in Flutter, Codemagic triggering on `branch_patterns` rather
than tags. R7b prices that at zero because it was written as a flag; it is unbuilt work with
no estimate.

The alternatives were a known launch date inside the window (there isn't one) or a tripwire
that converts the risk to a decision if a date appears. The freeze was chosen because a
tripwire still leaves the plan's enabling condition owned by someone else's calendar.

## Why the bar moved, and why it needs to exist at all

[ADR-0002](./0002-effort-ceiling-and-meaning-of-no.md) set a 12–15 week ceiling to judge the
**Supabase port**. [ADR-0006](./0006-no-go-on-removing-nestjs.md) closed that fork, so the
ceiling now binds nothing — it expired at the same moment this plan started gating the
release date.

That is the problem. **With the freeze in place, the plan's duration is the launch delay.**
The two places the number moves are Phase 2 (3–4 weeks on a phase already re-scoped once)
and Phase 5 (a 3–6 week range — a 2× spread on the second-largest item), and both move up.
A grilling session on 2026-07-22 added roughly 1½–2½ weeks of scope on top:

| Change | Effect |
|---|---|
| Fix the 94 unguarded actions on RPC before Phase 2 ([ADR-0008](./0008-authorization-hardening-precedes-transport.md)) | new pre-Phase-2 block, ~1–2 weeks |
| Generate the parity table + CI permission diff ([ADR-0009](./0009-parity-table-is-generated-not-reviewed.md)) | ~2–4 days, partly repaid by not hand-maintaining 454 rows |
| Throttling on the public auth routes | ~½ day |
| Build `approver.delete` and the three `churchLetterhead.*` routes | small |

**8–12 weeks becomes ~10–14.** The bar is set at the top of that, deliberately: this is
[#16](https://github.com/meimodev/palakat/issues/16)'s argument one level up — *a threshold
decided before the numbers arrive, otherwise whatever it costs gets rationalised as
acceptable*. ADR-0002 recorded its own correction in place rather than repairing it quietly,
for the same reason.

## The descope ladder

Named now, while shedding either item is free. In order:

1. **`palakat_super_admin`** — 33 call sites, never deployed, no workflow runs, nothing
   depends on it. Decision 22 already sequences it last for exactly this reason. The largest
   single descope available.
2. **The 31 uncalled RPC actions** — carried into Phase 2 by a deliberate choice for uniform
   process (decision 17), against the parity table's own recommendation to treat them as
   delete candidates. Dropping them late costs nothing already spent.

## Consequences

- Launch is downstream of Phases 0–9. There is no partial-launch option; time-boxing by
  phase was rejected because it ships a socket client that then needs the force-update
  tooling decision 15 deleted.
- The longer the plan runs, the more it justifies itself by the freeze it caused. The bar is
  the control on that, and it is a calendar limit, not a budget to spend.
- If a launch date is imposed externally, this ADR is void and §10.2's gate returns —
  *and the update-gate mechanism has to be built first*.
