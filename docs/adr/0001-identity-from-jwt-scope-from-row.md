---
status: accepted
date: 2026-07-21
relates-to: "#24, #26, #28"
---

# Identity comes from the token, scope comes from the row

If the Supabase port goes ahead ([#26](https://github.com/meimodev/palakat/issues/26)),
authorisation moves from `PermissionsGuard` into RLS policies with no application
layer to fall back on. Firebase stays as the identity provider via Third-Party Auth
([#28](https://github.com/meimodev/palakat/issues/28)), which means `auth.uid()` does
not work and policies must read identity out of the JWT.

**Decision:** policies trust the token for **identity only** — the `accountId` claim
already written by `AuthService.syncClaims` — and resolve **church scope and effective
permissions live** against the `Membership` row through a `security definer` helper.
The `churchId` and `membershipId` claims are not authoritative for access decisions.

## Why not trust the claims

They are a snapshot. `syncClaims` bakes `{ accountId, membershipId, churchId }` into
Firebase custom claims at sync time, and Firebase ID tokens refresh roughly hourly. A
church switch, a revoked membership or a role change would leave a token asserting
access it no longer has, for up to an hour, with nothing above the database to catch it.

Today's `PermissionsGuard` re-reads Postgres on every request. Trusting the claims
would be a **weakening** of the current authorisation model adopted silently during a
transport migration — the exact class of change this project has already decided not to
make (permission behaviour is ported verbatim, never redesigned in flight).

## Considered and rejected

- **Claims authoritative.** Fastest policies, no joins. Rejected: accepts an up-to-hour
  revocation window and forces a client token refresh on every scope-changing mutation.
- **Claims for reads, row for writes.** Bounds staleness to stale reads. Rejected: two
  policy shapes across ~40 tables, and "which reads are sensitive" becomes a judgement
  call over finance data.

## Consequence to measure

Every policy carries a join. Whether that is affordable is the open question
[#24](https://github.com/meimodev/palakat/issues/24) exists to answer — it is the
prototype's primary measurement, not an assumption this decision is entitled to make.
If the join proves unaffordable, this ADR is what gets revisited, not the auth fork.
