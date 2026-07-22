---
status: accepted
date: 2026-07-22
relates-to: "#33, ADR-0008"
---

# The parity table is generated from source and asserted in CI, not reviewed by a second person

Phase 2's security gate required the RPC→REST parity table to be *"reviewed by someone who did
not write it."* There is one developer. The gate is replaced by a generator plus a CI check,
with an independent agent read for the columns a program cannot judge.

## Why the gate could not be satisfied

The plan and the table both state it:

> §7 gate: *"Parity table reviewed by someone who did not write it."*
> Table header: *"**Status: draft — needs independent review.**"*

Solo. So the gate is either never satisfied, or satisfied by the author re-reading their own
454-row table — which is not what it says and not what it is for. R1 is the only risk in the
plan rated *privilege escalation*, so deleting the gate was not acceptable either.

## Why generation is a better gate than review

The table says this about itself:

> *"The **Guard** and **Permissions** columns are transcribed from source and are the ones
> that matter; **Verb** and **Route** are mechanical proposals and are the least trustworthy
> part of this document."*

The security-critical columns are **transcription**, and transcription is the one thing a
program does without drift. §6 already asked for the deliverable to be *"machine-checkable if
possible"* and then never returned to it.

So:

1. **Generate** the Guard and Permissions columns by extracting every
   `requireAnyOperationPermission` / `requireOperationPermission` allow-list per `case` block.
2. **Assert in CI** that each registered route's `@RequirePermissions` set equals its RPC
   case's allow-list. A mismatch fails the build.

This converts R1 from *"high if rushed"* to *"cannot merge"*, and unlike a review pass it keeps
working — it catches the Phase 5 regression where a permission set drifts while three clients
are being re-pointed.

It also kills the copy that goes stale. [ADR-0008](./0008-authorization-hardening-precedes-transport.md)
rewrites 94 of those rows; a hand-maintained table is wrong the moment that lands, while a
generated one updates for free.

## What generation cannot do

A program checks that a permission set *matches*. It cannot check that the set is *correct*,
and it cannot judge the table's self-declared weakest columns (Verb, Route) or ADR-0008's
triage buckets. Those get a read from a fresh agent with no memory of authoring the table —
a real independent read for the parts that need judgement, and the closest available thing to
the reviewer the gate asked for.

## Consequences

- The hand-written `docs/palakat-backend-rpc-rest-parity-table.md` retires in favour of
  generated output. Its **Findings** section is prose reasoning, not transcription — keep it,
  or migrate it into ADR-0008.
- The generator becomes a build dependency of Phase 2 and must exist before controllers are
  written, not alongside them.
- The CI check is the artefact that outlives the migration. When `rpc-router.service.ts` is
  deleted in Phase 5 the RPC side of the diff disappears, and the check degrades to asserting
  every registered route carries an explicit permission or a recorded exemption. Keep that
  half.
