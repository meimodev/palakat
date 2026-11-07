# Stack decision — Flutter, Supabase and Vercel

Date: 8 November 2026
Decided by: the user, acting as product owner ("Supabase and Vercel are enough"; "Use Flutter"; Supabase on the free plan while possible)
Status: DECIDED for hosting and client. Where each piece of server-side code runs is proposed below and not yet decided.

## Decision

- **Client:** Flutter (`supabase_flutter`; Supabase lists Flutter as a generally available client library).
- **Database, authentication, evidence storage:** Supabase (managed PostgreSQL).
- **Hosting and a second object store:** Vercel (static hosting for a Flutter web build, functions, Vercel Blob).
- **Not used:** AWS. An S3 bucket with Object Lock was offered and declined.
- **Plan:** build on the Supabase Free plan. Go-live with real church data needs a paid plan (see below). That is a condition for production use, not a coding blocker.

This satisfies S section 3 (one application, one transactional relational database) and round 5A (managed cloud, no church self-hosting).

## Checked in vendor documentation (8 November 2026)

| Fact | Source | Effect |
|---|---|---|
| **Free plan:** no automatic database backups, and backups are not downloadable. Supabase advises exporting data regularly and keeping off-site copies | Supabase, Database Backups and Production Checklist | Round 5D (RPO 1 hour, 7-day PITR, 35 daily, 12 monthly) and round 5E (restore tests) cannot be met on Free |
| **Free plan:** a project with little activity over 7 days is paused. It can be resumed for 90 days after the pause | Supabase, Project Pausing | Fine during active building; unacceptable for a live ledger |
| **Free plan limits:** database 500 MB (read-only above it), 1 GB disk, 50 MB per file, 10 GB bandwidth | Supabase, Database Size, File Limits, Bandwidth | A church ledger is small, but evidence photos and bandwidth need watching |
| Point-in-time recovery is a paid add-on (7, 14 or 28 days; about USD 100 a month for 7 days at the time of reading) and needs at least Small compute. Worst-case RPO 2 minutes | Supabase, Database Backups | Meets RPO 1 hour and 7-day PITR once on a paid plan |
| Enabling PITR stops the daily backups; without it, daily backups last 7 (Pro), 14 (Team) or 30 (Enterprise) days | Same | The 35 daily and 12 monthly snapshots need our own scheduled encrypted dumps |
| Database backups do not include Storage files | Same | Evidence files need their own second copy (round 5C) |
| Read replicas replicate asynchronously | Supabase, Read Replicas | No synchronous standby: EC04 uses "log archiving only" |
| Edge Functions: 2 s CPU per request, 150 s wall clock on Free (400 s paid), 256 MB memory | Supabase, Edge Function Limits | Fine for an AI proxy; too tight for heavy report rendering |
| Vercel Blob: private access exists; a blob is not overwritten unless `allow-overwrite` is set, but `del` removes it permanently. No object lock is documented | Vercel, Blob docs | Write-once is enforced by our code and tokens, not by the provider |

Not checked: current Pro plan price, Supabase Storage immutability features, whether a Vercel function can run a database dump, the database statement timeout that limits a close function.

## What Flutter changes

With Flutter and Supabase there is no application server between the client and the database. Everything the specifications call server-authoritative (finalization, numbering, reconciliation, close, capability checks) must run in the database or in a function the client calls. Proposed split:

| Where | What | Why |
|---|---|---|
| **Postgres functions** called as RPC (`SECURITY DEFINER`) | Posting kernel, voucher allocation, case and item consumption, period close commit, attestation, evidence decisions | One transaction gives atomicity, row locks (EC01), composite keys and deferred constraint triggers (EC06). The EC drafts already use these mechanisms |
| **Row-level security and grants** | Tenant and capability checks as defense in depth; clients get no direct write access to financial tables | The Data API exposes tables, so a missing policy is a data leak. This needs its own review in slice 1 |
| **Supabase Edge Functions** | AI proxy (OpenRouter key and ZDR setting stay server-side), cost reservation call | Secrets stay off the device. Within the 2 s CPU limit |
| **Vercel functions** | Report rendering (PDF and Excel), export packaging, the close archive write, scheduled dumps | Heavier CPU and time than Edge Functions. Unverified: whether they can run a database dump |
| **Flutter app** | Capture, review, display; never holds a service key; no offline finalization | Round 5A |

Consequence for EC04: a Postgres function cannot hold a lock across a call to Vercel Blob. The close therefore runs as **prepare** (compute the snapshot and archive content, return a state hash), **archive** (write it to Blob), **commit-if-unchanged** (re-check that the period's population still matches the hash, then commit). If anything changed, the close aborts and is retried. S forbids a persistent "checking" state, so a version check replaces the lock.

## What the Free plan means for the roadmap

- **Build and test on Free** with fictional data only. Keep the project active so it is not paused. Take manual exports with the Supabase CLI.
- **Do not put real church ledgers on Free.** It has no backups, so the approved recovery policy cannot be met. This is added to the open conditions for production use.
- **At go-live** move to a paid plan with the PITR add-on, then run the first restore drill (round 5E) before the first real close.
- If the church wants to run a pilot on Free with real data anyway, that is a change to the approved recovery policy and needs the product owner's explicit decision. It is not assumed here.

## Open points

- Whether report rendering happens in a Vercel function or in the Flutter client from the frozen snapshot. Decide in slice 6.
- The scheduled dump job: where it runs, how it is encrypted, where the key lives.
- Whether Supabase Auth is used as is, and the exact RLS design. Decide in slice 1.
- Whether the accepted limit on write-once storage is enough, or the church later wants provider-enforced immutability. That is a swap of one storage target.
