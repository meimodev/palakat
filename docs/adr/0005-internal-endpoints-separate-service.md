---
status: accepted
date: 2026-07-22
relates-to: "#26, #27"
---

# Scheduler and Tasks endpoints run as a separate, IAM-protected service

The Cloud Run service is `--allow-unauthenticated`, because the API is public. Cloud
Scheduler and Cloud Tasks then call `/internal/*` endpoints that deliberately skip user
authentication — the cron sweep, the report task handler. The migration plan's original
answer was to hand-verify the Google-signed OIDC token's `aud` **and** `email` inside the
application.

That places the least-protected routes in the codebase behind a check we wrote, on a
service reachable from the internet, where a too-permissive verification fails silently.

**Decision:** deploy the **same image** a second time as `palakat-internal` with
`--no-allow-unauthenticated`, granting `roles/run.invoker` only to the `palakat-invoker`
service account. Google rejects an unauthenticated or wrongly-authenticated request before
the process starts handling it. Scheduler and Tasks target that service's URL; the public
service does not route `/internal/*` at all.

## Why this is less work, not more

It replaces token-verification code with one extra `gcloud run deploy` line in CI. There
is no second build, no second image, no divergent configuration — same revision, different
invoker policy. The bug class disappears rather than being defended against.

## Considered and rejected

- **One public service, verify in app code.** The plan as originally written. Fewer moving
  parts in the deployment, but the correctness of the most sensitive routes becomes ours
  to maintain, and a mistake produces no visible failure.
- **IAM plus in-app verification.** Defence in depth, but the redundant check drifts out of
  sync with the IAM policy, and the disagreement surfaces at the worst time.

## Consequences

- The internal worker scales independently of user traffic, which is where
  [#27](https://github.com/meimodev/palakat/issues/27)'s report worker and the
  split-worker option in the plan's cost-tuning section were already heading. This decision
  makes that split cheap rather than a later refactor.
- Two services means two revisions to keep in step. They deploy from the same image tag in
  the same pipeline step — if they ever diverge, that is the bug.
- `/internal/*` must be genuinely unreachable on the public service, not merely unrouted by
  convention. That is worth an explicit test.
