---
status: accepted
date: 2026-07-22
relates-to: "ADR-0006, #24, #33"
---

# The 94 unguarded actions are fixed on the RPC path, before the REST surface is built

The parity table found **94 of 166 RPC actions authenticated but unauthorized** — any signed-in
user of any church can invoke them. They are fixed **on the existing socket path, before
Phase 2 begins**, not ported verbatim into REST and fixed later.

## The contradiction this resolves

The migration plan says both of these, and they cannot both hold:

> §6: *"Port that logic verbatim into a Nest guard. **Do not redesign the permission model
> during a transport migration** — behavioural parity is the goal."*

> [ADR-0006](./0006-no-go-on-removing-nestjs.md), *What is still worth doing* #2: *"**Fix the
> 94 unguarded actions on Nest.** This is the most valuable thing #24 produced and it is a
> live security finding, not a migration artifact."*

Verbatim parity means registering 94 auth-only routes on a public REST surface. Fixing them
inside Phase 2 means performing authorization *design* in the phase R1 already rates as the
one that ships privilege escalation.

## The decisive argument

Phase 2's exit gate is *"under-privileged-token test green on every permission-bearing
route."* Under verbatim parity **94 of 166 routes are not permission-bearing**, so the gate
has nothing to assert against 57% of the surface. It goes green while covering the minority —
a gate that passes because there is nothing to check is worse than no gate, because it is
recorded as having been satisfied.

§6's rule is right. The way to honour it is to finish the redesign *before* the transport
migration, not after it.

## Why the RPC path and not REST

One surface instead of two. A live reference implementation to diff behaviour against.
Existing tests. No new routes, so no interaction with route registration, guards, envelopes
or validation at the same time. ADR-0006 already says this is cheaper on Nest than it would
have been under RLS.

Doing it per-module *during* Phase 2 was the worst option considered: it interleaves design
decisions with transport changes, so a 403 surfacing in Phase 5 is ambiguous between a wrong
permission and a wrong route shape — R18's failure mode applied to authorization instead of
validation.

## Scope, honestly

The 94 is not 94 design decisions. Triage first — probably a day — into three buckets:

| Bucket | Example | Work |
|---|---|---|
| Correct as-is | `location.list` — reference data | none, record why |
| Needs a permission | church-scoped writes | the real work |
| Needs church-scoping in the service, not a permission | own-records reads | service-layer |

Only the second and third buckets cost anything. The triage output is what populates the
parity table's Permissions column, which is what makes Phase 2 pure transcription.

Two related findings from the same table are folded in here rather than tracked separately:
`ops.approval.finance` is passed in allow-lists and **never defined**, so those clauses are
dead; `ops.approvalRule.manage` is defined and **never checked**, so either it is dead or the
approval-rule actions are under-guarded. The triage decides which.

## Consequences

- RPC behaviour changes while three clients still speak RPC. A call that worked yesterday
  returns 403 today. Under [ADR-0007](./0007-release-freeze-and-the-14-week-bar.md)'s release
  freeze that costs dev-build friction and nothing else — which is precisely the window in
  which this is cheap, and it closes when the freeze does.
- Phase 2 becomes transcription, and its security gate becomes meaningful across all 166
  routes rather than 72.
- This is also the prerequisite ADR-0006 names for any future Supabase port: RLS translation
  becomes mechanical rather than design work. Doing it is a step toward that option, not away
  from it.
