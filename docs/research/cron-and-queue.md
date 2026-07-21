# What replaces the scheduled work once the long-lived Nest process is gone?

**Ticket:** [#20](https://github.com/meimodev/palakat/issues/20) · **Parent:** [#14](https://github.com/meimodev/palakat/issues/14)
**Scope:** scheduling and queueing only. PDF/report *generation* itself is covered separately by #17 — this doc assumes "something invocable exists" for the actual work.

## Verdict

Both cron jobs and the report queue have a direct, well-documented Supabase replacement: **pg_cron (Supabase Cron) + pg_net for scheduling/invocation, `SELECT … FOR UPDATE SKIP LOCKED` (or a pgmq-backed queue) for single-consumer concurrency, and `cron.job_run_details` + Log Explorer for observability.** The 10-second poll is not abusive on Supabase — sub-minute (down to 1-second) schedules are natively supported since pg_cron 1.5+ — but the current in-process `isProcessing` boolean has **no equivalent** in a stateless architecture and must be replaced with a database-level lock. The birthday job's `0 7 * * *` schedule silently breaks for the timezone question — pg_cron runs in UTC by default and Supabase does not expose `cron.timezone` for reconfiguration on hosted projects — so this is a **real gap**, not a nitpick, and needs an explicit fix (see §6). Nothing here blocks a "yes" on removing Nest, but the migration is not zero-effort: it requires new SQL objects (advisory-lock-guarded queue-draining function, a rewritten birthday query using `AT TIME ZONE`) that don't exist today.

## Summary table

| Current Nest behaviour | Supabase replacement | Gap / risk |
|---|---|---|
| `@Cron('0 7 * * *')` daily birthday push, server-local (assumed UTC in prod) time | `cron.schedule('birthday-notify', '0 7 * * *', $$ select net.http_post(...) $$)` — Supabase Cron / pg_cron | **Timezone**: pg_cron's scheduler runs on `cron.timezone`, which defaults to UTC/GMT and is a postmaster-level GUC not exposed for editing on hosted Supabase projects ([Supabase Cron docs](https://supabase.com/docs/guides/cron), [pg_cron GitHub](https://github.com/citusdata/pg_cron)). `0 7 * * *` UTC ≠ 07:00 WIB (UTC+7) or WITA (UTC+8). Must either hardcode the UTC-shifted cron expression (`0 0 * * *` for WIB, `0 23 * * *` for WITA — no DST in Indonesia so this is stable) or, if churches span multiple Indonesian zones, run the job hourly/at midnight-UTC and filter recipients with `AT TIME ZONE` per-church inside the query. |
| `@Cron(CronExpression.EVERY_10_SECONDS)` polling `ReportJob` table | `cron.schedule('report-drain', '10 seconds', $$ select net.http_post(url:='.../functions/v1/drain-report-queue', ...) $$)` | Supported natively — pg_cron accepts `'[1-59] seconds'` syntax since Postgres 15.1.1.61+ on Supabase ([Cron quickstart](https://supabase.com/docs/guides/cron)). A 10s poll is well within the documented 8-concurrent-job / 10-minute-per-job limits ([Cron overview](https://supabase.com/docs/guides/cron)). Not abusive; this is the documented pattern. |
| In-process `isProcessing` boolean guarding "only one job runs at a time" | Postgres-level lock: `SELECT id FROM "ReportJob" WHERE status='PENDING' ORDER BY "createdAt" ASC FOR UPDATE SKIP LOCKED LIMIT 1` inside a single transaction, or `pg_try_advisory_lock()` wrapping the whole drain function | **No automatic replacement** — a boolean in RAM only works with one long-lived process. With cron firing an Edge Function every 10s, overlapping invocations are the default risk if the Edge Function runtime or job takes >10s. Must add `FOR UPDATE SKIP LOCKED` and/or `pg_try_advisory_lock(hashtext('report-queue'))` explicitly — see §4. |
| `ReportJob` table polling (custom `PENDING`/`PROCESSING`/`COMPLETED`/`FAILED` state machine, hand-rolled) | Either **keep the table + SKIP LOCKED** (minimal change, keeps existing progress/status columns) or **migrate to Supabase Queues (pgmq)** | pgmq is at-least-once / exactly-once-within-visibility-window via `read()`+`delete()`, not a perfect drop-in: no built-in dead-letter queue or max-retry — `read_ct` must be checked by app logic ([pgmq docs](https://supabase.com/docs/guides/queues/pgmq)). Consumers must still be *triggered* by something — pgmq has no push/webhook consumer, so a cron poll is still required either way (see §3). Given the existing `ReportJob` table already carries progress %, requester, format, etc., keeping the table and adding `FOR UPDATE SKIP LOCKED` is lower-risk than a pgmq migration. |
| Progress percentage writes (`progress: 10` → `100`) read by clients via realtime/poll | Unchanged — an Edge Function can `UPDATE "ReportJob" SET progress = ...` exactly as the Nest service does today; Supabase Realtime can still broadcast the row change | Works as-is. Not blocked by the scheduling change. |
| NestJS `Logger` writing to stdout/app logs | `cron.job_run_details` table (per-run status/duration) + Edge Function invocation logs in Supabase Log Explorer | Different shape, not worse — see §7. Requires switching alerting/monitoring habits from "grep app logs" to "query `cron.job_run_details` / Log Explorer", which is a process change for the team, not a capability gap. |

## Findings by question

### 1. Supabase Cron (pg_cron) scheduling granularity

- Supabase Cron supports schedules "from every second to once a year" ([Cron overview](https://supabase.com/docs/guides/cron)).
- Sub-minute jobs use the syntax `'[1-59] seconds'`, e.g. `'30 seconds'`, and require Postgres **15.1.1.61 or later** (all current Supabase projects meet this) ([Cron quickstart](https://supabase.com/docs/guides/cron)).
- Platform limits: **no more than 8 Cron Jobs run concurrently**, and **each job should run no more than 10 minutes** ([Cron overview](https://supabase.com/docs/guides/cron)). Separately, the underlying pg_cron scheduler itself defaults to `cron.max_running_jobs = 32` ([pg_cron debugging guide](https://supabase.com/docs/guides/troubleshooting/pgcron-debugging-guide-n1KTaz)) — this is a different, lower-level ceiling than the 8-job Supabase Cron UI limit.
- **A 10-second poll is the documented pattern, not an abuse of the platform.** Supabase's own docs use `'30 seconds'` polling as the canonical example for driving an Edge Function worker loop.

### 2. How a scheduled job invokes work

Two invocation shapes, both via pg_cron, no separate "native Edge Function scheduler" exists:
- **Direct SQL**: `cron.schedule('name', 'schedule', $$ sql-or-function $$)` — zero network latency, runs inside Postgres ([Cron overview](https://supabase.com/docs/guides/cron)).
- **HTTP call via `pg_net`** to invoke an Edge Function: `net.http_post(url:=..., headers:=..., body:=..., timeout_milliseconds:=...)` ([Cron quickstart](https://supabase.com/docs/guides/cron); confirmed identical pattern in [Scheduling Edge Functions](https://supabase.com/docs/guides/functions/schedule-functions)).
- Supabase's own "Scheduling Edge Functions" doc confirms: **Edge Function scheduling is pg_cron + pg_net composed together, not a distinct product feature.** Auth secrets (URL, publishable key) should go in Supabase Vault (`vault.create_secret`) rather than hardcoded into the cron job body ([Scheduling Edge Functions](https://supabase.com/docs/guides/functions/schedule-functions)).
- **Failure/retry semantics differ by shape:**
  - Direct SQL runs inside the pg_cron transaction; failure is a Postgres error, logged synchronously to `cron.job_run_details`.
  - `pg_net` calls are **asynchronous and fire-and-forget from the caller's perspective** — the request row is inserted and the cron job "succeeds" immediately, while the actual HTTP call completes later. Responses/errors land in `net._http_response`, retained for only **6 hours by default**, and pg_net enforces a default 2000ms timeout per call plus a platform cap of ~200 requests/second ([pg_net docs](https://supabase.com/docs/guides/database/extensions/pg_net)). There is **no automatic retry** on pg_net failures — the caller (the cron job body or the Edge Function) must implement retry logic itself. `net._http_response` rows are also stored in an **unlogged table**, so they don't survive a crash/unclean shutdown — durability is weak, treat it as a debugging aid, not a source of truth.

### 3. Supabase Queues (pgmq) fit for the report queue

- pgmq (`pgmq.send`, `pgmq.read`, `pgmq.pop`, `pgmq.archive`, `pgmq.delete`, `pgmq.set_vt`) is a real Postgres-native queue, not just a wrapper around the existing table pattern ([pgmq API](https://supabase.com/docs/guides/queues/pgmq)).
- **Visibility timeout (VT)**: `read()` makes a message invisible to other readers for VT seconds; if not deleted/archived before VT expires, it becomes visible again for redelivery ([pgmq docs](https://supabase.com/docs/guides/queues/pgmq)).
- **Delivery semantics are mixed, not uniformly "exactly once"**: Supabase's marketing copy claims "Exactly Once Message Delivery" ([Queues overview](https://supabase.com/docs/guides/queues)), but the actual API-level guarantee is **at-least-once with `read()`+explicit `delete()`** (exactly-once *within* a visibility window, i.e. a second consumer can't see it until VT expires — but if a worker crashes mid-processing after `read()` and before `delete()`, the message reappears and gets reprocessed). `pop()` (atomic read+delete) is weaker still — **at-most-once**, since a crash after pop but before finishing work loses the message ([pgmq docs](https://supabase.com/docs/guides/queues/pgmq)).
- **No built-in dead-letter queue or max-retry config.** `read_ct` tracks how many times a message has been read; the application is responsible for checking `read_ct` and deciding to archive/delete a poison message ([pgmq docs](https://supabase.com/docs/guides/queues/pgmq); corroborated by search results referencing pgmq/GitHub — no DLQ primitive exists in pgmq itself).
- **Consumer triggering is pull-based, not push.** There is no webhook/push consumer for pgmq — something still has to call `pgmq.read()`/`pop()`, meaning **a cron job (or an externally-triggered Edge Function) is still required either way** ([Queues quickstart](https://supabase.com/docs/guides/queues/quickstart)). The documented reference architecture is literally: pg_cron fires every N seconds → invokes an Edge Function via pg_net → Edge Function calls `pgmq.read()`/pops a batch → processes → deletes/archives (search result summary of the Supabase-recommended pattern, cross-referenced with the Cron and Queues docs above).
- **Verdict for this project**: pgmq buys visibility-timeout-based redelivery and an archive table, but the existing `ReportJob` table already carries richer domain state (`progress`, `format`, `churchId`, `requestedById`, `reportId`) that pgmq's opaque JSON payload doesn't replace for free — you'd still keep `ReportJob` as the source of truth and either (a) use it directly with `FOR UPDATE SKIP LOCKED` (simplest, no new extension), or (b) use pgmq purely as the trigger/dedup mechanism while `ReportJob` remains the state table. Given pre-launch status and low job volume, (a) is the lower-risk path; pgmq is worth revisiting only if job volume or need for cross-service decoupling grows.

### 4. Concurrency: replacing the in-process `isProcessing` boolean

There is no in-memory equivalent once there's no single long-lived process — every Edge Function invocation is a fresh, isolated instance. The concrete recommended mechanism, in order of preference for this codebase:

1. **`SELECT ... FOR UPDATE SKIP LOCKED` inside a transaction** — claim the next `PENDING` row atomically:
   ```sql
   WITH next_job AS (
     SELECT id FROM "ReportJob"
     WHERE status = 'PENDING'
     ORDER BY "createdAt" ASC
     FOR UPDATE SKIP LOCKED
     LIMIT 1
   )
   UPDATE "ReportJob" SET status = 'PROCESSING', progress = 10
   WHERE id IN (SELECT id FROM next_job)
   RETURNING id;
   ```
   This guarantees that if two overlapping cron-triggered invocations run concurrently, only one gets each row — the second sees zero rows (`SKIP LOCKED` skips rows another transaction already has locked) rather than blocking or double-processing ([Postgres explicit locking docs](https://www.postgresql.org/docs/current/explicit-locking.html)). This is the direct structural replacement for `isProcessing`, and requires no new extension.
2. **`pg_try_advisory_lock(hashtext('report-queue-drain'))`** as an additional outer guard if you want to serialize the *whole* drain function (not just per-row), e.g. to prevent two Edge Function invocations from both spinning up expensive PDF rendering simultaneously even if there are multiple pending rows. Advisory locks are session/transaction scoped and auto-released on disconnect, so a crashed Edge Function invocation can't leave a stale lock held forever ([Postgres explicit locking docs](https://www.postgresql.org/docs/current/explicit-locking.html)).
3. **pgmq's visibility timeout** is a third option but only if you migrate the queue itself (see §3) — it serializes at the message level for free but doesn't serialize "only one report renders at a time" unless VT ≥ worst-case render time.

Recommendation for this repo: **use `FOR UPDATE SKIP LOCKED` on the existing `ReportJob` table**, optionally wrapped in `pg_try_advisory_lock` if report generation is CPU/memory-heavy enough that true single-flight (not just single-row-claim) matters.

### 5. Progress reporting

Unaffected by the scheduling change. Nothing about `progress` percentage writes depends on a long-lived process — an Edge Function can `UPDATE "ReportJob" SET progress = N WHERE id = ...` exactly like the current `processNextJob()` does, and Supabase Realtime (already used elsewhere via `RealtimeEmitterService`/Pusher in the current code) can broadcast row changes the same way. No gap here — this question is answered by ruling it out as a risk, not by finding a new mechanism.

### 6. Timezone handling for the birthday job

This is the clearest concrete gap found:

- pg_cron's scheduler evaluates cron expressions against the `cron.timezone` GUC, which **defaults to GMT/UTC** and is a **postmaster-context setting** (requires a full Postgres restart to change, and is not a per-session/per-job setting) ([pg_cron GitHub](https://github.com/citusdata/pg_cron); corroborated by search results on `cron.timezone`).
- On hosted Supabase, this GUC is **not exposed for customer configuration** — an open, unanswered Supabase community discussion asks exactly this question with no official resolution as of the time of writing ([Supabase Discussion #36383](https://github.com/orgs/supabase/discussions/36383)). Treat "can I set `cron.timezone` on my Supabase project" as **unresolved/no** until Supabase documents otherwise — this is a secondary-source/community signal, not a confirmed platform capability, and should be re-verified before final implementation.
- **Practical consequence**: `0 7 * * *` scheduled naively on Supabase Cron fires at **07:00 UTC**, which is **14:00 WIB** (UTC+7) / **15:00 WITA** (UTC+8) — not 07:00 local time as the current Nest deployment (presumably running with a UTC or local-configured server clock) intends.
- **Fix, not a blocker**: Indonesia has no DST, so the offset is constant. Schedule the cron expression pre-shifted to UTC for the target local time (`0 0 * * *` UTC = 07:00 WIB, `0 23 * * *` UTC = 07:00 WITA), or — if churches span more than one Indonesian timezone — run the job once per hour and have the query itself filter "is it currently 07:00 in this row's timezone" using `AT TIME ZONE` against a per-church timezone column. The current `birthday-notification.service.ts` iterates `prisma.church.findMany()` with no timezone field at all, so **a per-church timezone column doesn't exist yet** — if churches are genuinely split across WIB/WITA, this is new schema work, not just a cron-expression change.

### 7. Observability without a Nest logger

- Every pg_cron job run (success or failure) is recorded in **`cron.job_run_details`** (status, start/end time, return message) — this is the direct replacement for "check the app logs for cron errors" ([Supabase pg_cron debugging guide](https://supabase.com/docs/guides/troubleshooting/pgcron-debugging-guide-n1KTaz)).
- The Supabase **Dashboard → Cron** view surfaces job history/logs directly; deeper investigation goes through **Log Explorer** against Postgres logs ([pg_cron debugging guide](https://supabase.com/docs/guides/troubleshooting/pgcron-debugging-guide-n1KTaz)).
- Documented common failure modes to watch for, per the debugging guide: the pg_cron background worker process itself crashing (check `pg_stat_activity`), jobs exceeding execution time, connection/concurrency exhaustion (`cron.max_running_jobs`), and running an outdated pg_cron version lacking auto-revival fixes.
- For the `pg_net`-invoked Edge Function leg specifically, failures surface in **`net._http_response`** (status codes, `error_msg`, `timed_out`) but only for **6 hours** by default ([pg_net docs](https://supabase.com/docs/guides/database/extensions/pg_net)) — any alerting built on this needs to poll faster than that retention window, or the Edge Function itself needs to write its own failure state (e.g. the existing `lastFailedAt`/`lastErrorMessage` fields already on `ReportQueueService`'s health snapshot should move into a durable table row rather than in-memory fields, for the same reason `isProcessing` needs to move — see §4).

## Sources (primary, all fetched directly)

- Supabase Cron overview — https://supabase.com/docs/guides/cron
- Supabase Cron quickstart (syntax, seconds schedules, `pg_net` example) — https://supabase.com/docs/guides/cron (quickstart section)
- Supabase Queues overview — https://supabase.com/docs/guides/queues
- Supabase Queues quickstart (pull-based consumer model) — https://supabase.com/docs/guides/queues/quickstart
- pgmq SQL API reference — https://supabase.com/docs/guides/queues/pgmq
- pg_net extension docs — https://supabase.com/docs/guides/database/extensions/pg_net
- Scheduling Edge Functions (pg_cron + pg_net composition, Vault pattern) — https://supabase.com/docs/guides/functions/schedule-functions
- pg_cron debugging guide (observability, common failure modes) — https://supabase.com/docs/guides/troubleshooting/pgcron-debugging-guide-n1KTaz
- Postgres explicit locking docs (advisory locks, `FOR UPDATE SKIP LOCKED`) — https://www.postgresql.org/docs/current/explicit-locking.html
- pg_cron upstream project (timezone GUC behavior) — https://github.com/citusdata/pg_cron

### Secondary / lower-trust sources (used only where primary docs were silent, flagged explicitly above)

- Supabase community discussion on `cron.timezone` configurability (unanswered as of fetch time) — https://github.com/orgs/supabase/discussions/36383
- Search-engine-summarized community threads on pgmq dead-letter/retry behavior, used only to corroborate the primary pgmq docs' silence on DLQ support, not as a standalone claim.

## Code reviewed (this repo)

- `apps/palakat_backend/src/notification/birthday-notification.service.ts` — `@Cron('0 7 * * *')`, iterates all churches with no per-church timezone field.
- `apps/palakat_backend/src/report/report-queue.service.ts` — `@Cron(CronExpression.EVERY_10_SECONDS)`, in-process `isProcessing` boolean, `ReportJob` state machine (`PENDING`→`PROCESSING`→`COMPLETED`/`FAILED`), progress percentage writes, in-memory `lastAttemptedAt`/`lastCompletedAt`/`lastFailedAt`/`lastErrorMessage` health fields.
- `apps/palakat_backend/src/app.module.ts` — `ScheduleModule.forRoot()`.
- `apps/palakat_backend/prisma/schema.prisma` — `ReportJobStatus` enum (`PENDING`, `PROCESSING`, `COMPLETED`, `FAILED`).
