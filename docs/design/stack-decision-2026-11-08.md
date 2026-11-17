# Stack decision — Flutter, Supabase and Vercel

Date: 8 November 2026
Decided by: the user, acting as product owner ("Supabase and Vercel are enough"; "Use Flutter"; Supabase on the free plan while possible)
Status: DECIDED for hosting and client. Where each piece of server-side code runs is proposed below and not yet decided. Amended 17 November 2026: Firebase Cloud Messaging added for push notifications (DL20 in [the platform module plan](platform-module-plan-2026-11-17.md)).

## Decision

- **Client:** Flutter (`supabase_flutter`; Supabase lists Flutter as a generally available client library).
- **Database, authentication, evidence storage:** Supabase (managed PostgreSQL).
- **Hosting and a second object store:** Vercel (static hosting for a Flutter web build, functions, Vercel Blob).
- **Push notifications (added 17 November 2026, DL20):** Firebase Cloud Messaging, for push only. Messages are sent from a server-side function, so the FCM credentials never reach the app. In-app notifications stay on Supabase Realtime. FCM's limits and pricing have not yet been checked in vendor documentation.
- **Not used:** AWS. An S3 bucket with Object Lock was offered and declined.
- **Plan:** build on the Supabase Free plan. Go-live with real church data needs a paid plan (see below). That is a condition for production use, not a coding blocker.

This satisfies S section 3 (one application, one transactional relational database) and round 5A (managed cloud, no church self-hosting).

## Checked in vendor documentation (8 November 2026, updated 16 November 2026)

| Fact | Source | Effect |
|---|---|---|
| **Free plan:** no automatic database backups, and backups are not downloadable. Supabase advises exporting data regularly and keeping off-site copies | Supabase, Database Backups and Production Checklist | Round 5D (RPO 1 hour, 7-day PITR, 35 daily, 12 monthly) and round 5E (restore tests) cannot be met on Free |
| **Free plan:** a project with little activity over 7 days is paused. It can be resumed for 90 days after the pause | Supabase, Project Pausing | Fine during active building; unacceptable for a live ledger |
| **Free plan limits:** database 500 MB (read-only above it), 1 GB disk, 50 MB per file, 10 GB bandwidth | Supabase, Database Size, File Limits, Bandwidth | A church ledger is small, but evidence photos and bandwidth need watching |
| Point-in-time recovery is a paid add-on (7, 14 or 28 days; about USD 100 a month for 7 days at the time of reading). Worst-case RPO 2 minutes | Supabase, Database Backups | Meets RPO 1 hour and 7-day PITR once on a paid plan |
| Enabling PITR stops the daily backups; without it, daily backups last 7 (Pro), 14 (Team) or 30 (Enterprise) days | Same | The 35 daily and 12 monthly snapshots need our own scheduled encrypted dumps |
| Database backups do not include Storage files | Same | Evidence files need their own second copy (round 5C) |
| Read replicas replicate asynchronously | Supabase, Read Replicas | No synchronous standby: EC04 uses "log archiving only" |
| Edge Functions: 2 s CPU per request, 150 s wall clock on Free (400 s paid), 256 MB memory | Supabase, Edge Function Limits | Fine for an AI proxy; too tight for heavy report rendering |
| Vercel Blob: private access exists; a blob is not overwritten unless `allow-overwrite` is set, but `del` removes it permanently. No object lock is documented | Vercel, Blob docs | Write-once is enforced by our code and tokens, not by the provider |
| **Pro plan:** from USD 25 a month, with USD 10 a month of compute credits (enough for one Micro instance, about USD 10). Small compute is about USD 15 | Supabase, Pricing and Manage Compute usage | Plan and compute for one project cost about USD 25 to 30 a month |
| **PITR 7 days:** USD 0.137 an hour, about USD 100 a month, billed by the hour and not covered by the spend cap. The backups page says PITR is available on all compute sizes; the 8 November reading said at least Small. Supabase's own example (Pro, Small, 7-day PITR) totals USD 130 a month | Supabase, Database Backups and Manage Point-in-Time Recovery usage | Go-live costs about USD 125 a month on Micro, or USD 130 on Small, before usage above the plan quotas |
| **Supabase Storage:** S3 versioning is not supported, and the object-lock headers are not implemented. Deleted objects are removed permanently. Overwriting (`upsert`) needs `SELECT` and `UPDATE` policies on `storage.objects`; the service key bypasses all policies | Supabase, S3 Compatibility and Storage Access Control | No provider-enforced immutability here either. Write-once is enforced by an `INSERT`-only policy and by keeping the service key off clients. The second copy (round 5C) is still needed |
| **Vercel Functions** (Node.js, Python, Bun): read-only filesystem with 500 MB of `/tmp`; memory 2 GB (Hobby) or 4 GB (Pro); duration 300 s (Hobby) or 800 s (Pro, 1800 s in beta). No `pg_dump` binary is documented in these runtimes. The Container runtime (beta, all plans) runs any OCI image under the same limits. Cron Jobs run once a day on Hobby (±59 min), once a minute on Pro | Vercel, Functions Limits, Runtimes, Container Runtime, Cron Jobs Usage & Pricing | A standard Vercel function cannot run a dump. A dump on Vercel needs the beta Container runtime with `pg_dump` in the image, and must finish in 300 s on Hobby |
| **Supabase dump tooling:** Supabase documents a scheduled GitHub Actions workflow that runs `supabase db dump` for roles, schema and data. `supabase db dump` runs `pg_dump` in a container, so it needs Docker. GitHub runners are IPv4 only and must use the Session pooler unless the project buys the IPv4 add-on. The guide warns that `data.sql` is plain text with `auth.users` password hashes, and suggests a private bucket over committing it | Supabase, Automated backups using GitHub Actions; CLI reference, `supabase db dump` | A documented route for the 35 daily and 12 monthly dumps, outside Vercel. Our job must encrypt the dump and keep it out of the repository |
| **Statement timeout:** defaults are `anon` 3 s, `authenticated` 8 s, `service_role` none (falls back to `authenticator`'s 8 s), `postgres` none (global cap 2 min). Client-library (Data API) and Dashboard queries can be raised to at most 60 s. Raise it per function with `set statement_timeout` in the function definition, or per role with `alter role … set statement_timeout` and `NOTIFY pgrst, 'reload config'`. Longer work needs the session-mode pooler or a direct connection | Supabase, Timeouts | Each EC04 close step called over RPC must finish within 60 s, and within 8 s unless the function sets its own timeout |

Not checked: whether a dump of our database completes within a Vercel Container function's limits. The documentation cannot answer this; it needs a test.

## What Flutter changes

With Flutter and Supabase there is no application server between the client and the database. Everything the specifications call server-authoritative (finalization, numbering, reconciliation, close, capability checks) must run in the database or in a function the client calls. Proposed split:

| Where | What | Why |
|---|---|---|
| **Postgres functions** called as RPC (`SECURITY DEFINER`) | Posting kernel, voucher allocation, case and item consumption, period close commit, attestation, evidence decisions | One transaction gives atomicity, row locks (EC01), composite keys and deferred constraint triggers (EC06). The EC drafts already use these mechanisms |
| **Row-level security and grants** | Tenant and capability checks as defense in depth; clients get no direct write access to financial tables | The Data API exposes tables, so a missing policy is a data leak. This needs its own review in slice 1 |
| **Supabase Edge Functions** | AI proxy (OpenRouter key and ZDR setting stay server-side), cost reservation call, push sends through Firebase Cloud Messaging (DL20) | Secrets stay off the device. Within the 2 s CPU limit |
| **Vercel functions** | Report rendering (PDF and Excel), export packaging, the close archive write, scheduled dumps | Heavier CPU and time than Edge Functions. A standard function cannot run `pg_dump`; see Open points |
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
- Finding (16 November): scheduled dumps cannot run in a standard Vercel function as proposed. The options are the beta Vercel Container runtime or a GitHub Actions schedule, which Supabase documents but which adds GitHub to the stack.
- Finding (16 November): each close step called over RPC is capped at 60 s by Supabase. EC04 must set a per-function timeout and fit within it, or run the step over a direct connection.
- Whether Supabase Auth is used as is, and the exact RLS design. Decide in slice 1.
- Whether the accepted limit on write-once storage is enough, or the church later wants provider-enforced immutability. That is a swap of one storage target. Finding (16 November): Supabase Storage has no object lock or versioning either, so that target would be outside Supabase and Vercel.
