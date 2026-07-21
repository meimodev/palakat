---
status: accepted
date: 2026-07-21
relates-to: "#16, #25, #26"
---

# The effort ceiling for the Supabase port, and what "no" commits us to

[#16](https://github.com/meimodev/palakat/issues/16) asks for a threshold above which
removing NestJS is a "no", and for a definition of what "no" actually means. Both halves
are recorded here because the second one determines whether the first is meaningful.

**Ceiling: ~12–15 weeks** of solo full-time-equivalent effort for the full port. If
[#25](https://github.com/meimodev/palakat/issues/25)'s measured multiplier projects
beyond that, [#26](https://github.com/meimodev/palakat/issues/26) is a no.

**"No" means the full Cloud Run plan** — delete `rpc-router.service.ts`, build the
guarded REST surface, move off EC2 — as specified in
[`palakat-backend-gcp-cloud-run-migration-plan.md`](../palakat-backend-gcp-cloud-run-migration-plan.md).
It is **not** "stay as we are".

## Why the ceiling is anchored to the no-go branch

The no-go branch costs **3–5 weeks of marginal work**, so the ceiling is roughly 3× the
alternative rather than 3× nothing. Setting it against a do-nothing baseline would have
decided #26 in advance: no rewrite of 40 models, a 499-line permission service and 85
transaction sites justifies 12 weeks against a free alternative.

Correcting the handoff plan on this point: the REST surface (3–4 weeks) and the ~21
Flutter repositories are **fork-specific, not shared work**. Under a go they become
PostgREST and Edge Functions; building them on NestJS first would be work thrown away.
Genuinely shared work is the permission-parity table, the report-queue fixes, FCM, the
external schedulers, and — per
[#27](https://github.com/meimodev/palakat/issues/27) — the Cloud Run scaffolding for the
surviving Node report worker.

## Consequences accepted

- A go does **not** remove GCP from the stack. Report generation cannot run on Deno
  ([#17](https://github.com/meimodev/palakat/issues/17)), so a Node worker survives on
  Cloud Run either way and the ops-burden argument for the port shrinks accordingly.
- The reduced-scope fallback #16 floats (Supabase Auth + Storage only) is **dropped**:
  Supabase phone verification is dearer than Firebase's and migrating Storage buys
  nothing.
- The ceiling assumes the project stays **pre-launch**. If launch lands before #26 is
  answered, the enabling condition expires and this ADR is void.
