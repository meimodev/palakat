# `palakat_backend` → GCP Cloud Run: Migration Plan (HTTP-only + FCM)

**Date:** 2026-07-21
**Decision taken:** the WebSocket is **removed** and handed off to **FCM**. Optimisation target is **price**.
**Companion:** [`palakat-backend-gcp-cloud-run-migration-analysis.md`](./palakat-backend-gcp-cloud-run-migration-analysis.md) — the *whether*. This document is the *how*.
**Supersedes for deployment:** [`palakat-backend-aws-ec2-cicd-deployment-guide.md`](./palakat-backend-aws-ec2-cicd-deployment-guide.md) once Phase 9 completes.

---

## 0. What the decision changes

The analysis priced Cloud Run **with** the socket at Rp 875.790/bulan — 2,3× the current EC2 box — because an
instance holding any open WebSocket is billed as active, which defeats scale-to-zero. Removing the socket removes
that floor. The target architecture is genuinely cheaper than what you run today:

| Architecture | Monthly | vs. EC2 today |
|---|---:|---:|
| EC2 today (socket, always on) | Rp 378.029 | — |
| Cloud Run **with** socket (the rejected option) | Rp 875.790 | +Rp 497.761 |
| **Cloud Run HTTP-only + FCM, 180h active** | **Rp 226.810** | **−Rp 151.219** |
| **Cloud Run HTTP-only + FCM, 90h active** | **Rp 162.800** | **−Rp 215.229** |
| Single church (~200 users), HTTP-only | **Rp 0** | −Rp 378.029 |

Plus two line items that disappear entirely: **Redis** (never needed without the Socket.IO adapter — saves the
Rp 666.000/bulan Memorystore option outright) and **Pusher Beams** (§4 folds it into FCM, which is free).

### 0.1 The sequencing consequence — this is the biggest change to the plan

The previous draft migrated first and removed the socket later. **For a price target, that order is backwards.**

Migrating first means paying the Rp 875.790/bulan socket-pinned rate for every month the client rewrite takes —
and the client rewrite is the long pole, plausibly 2–3 months including app-store rollout. That is
**~Rp 1,5 juta wasted** to arrive at the same place.

**So: do the socket removal on EC2, where it costs nothing extra, and migrate only once the backend is
HTTP-only.** EC2 charges Rp 378.029/bulan whether it is serving sockets or not. It is the free staging ground for
the entire refactor.

```
Phases 0–6  ── on EC2, no infra cost change ──────────►  backend + client go HTTP-only
Phases 7–9  ── migrate the finished thing ───────────►  Cloud Run, scale-to-zero
Phase 10    ── tune ─────────────────────────────────►  price floor
```

### 0.2 One question still open

| # | Question | Why it matters |
|---|---|---|
| Q1 | **Which region is the Supabase project in?** | Cloud Run must match it. Cross-cloud adds 5–15 ms per Prisma query *and* per-GiB egress. Singapore Supabase → `asia-southeast1`. Do not pick a region for client latency; the DB round-trip dominates. |

Q2 (keep the socket?) and Q3 (staging?) are answered: **no socket**, and staging is now nearly free —
`min-instances=0` on request-based billing costs approximately nothing when idle, so run one.

---

## 1. What the code review changed about the estimate

Six findings from reading the source. Together they make this refactor **materially cheaper than the analysis
§10.8 assumed** — with one new risk that is more serious than anything in the original document.

### 1.1 ✅ Every push already funnels through one service

`src/realtime/realtime-emitter.service.ts` is the **single seam**. All 14 `emitToRoom` call sites route through
`RealtimeEmitterService.emitToRoom(room, event, payload)` (:53). The three higher-level helpers —
`emitActivityEvent` (:107), `emitFinanceEvent` (:138), `emitApprovalLifecycleEvent` (:179) — all funnel into it.

**Swapping the socket for FCM is a one-file reimplementation of that service.** No caller changes.

### 1.2 ✅ The payload shape is already an FCM data message

Every helper builds `{ data: { ... } }`. That is literally the FCM data-message envelope. The only adaptation
needed: **FCM data values must all be strings**, so nested objects/arrays get `JSON.stringify`d.

### 1.3 ✅ Room names are already valid FCM topics

`pusher-beams.service.ts` formats interests as `church.{id}` (:191), `membership.{id}` (:167),
`account.{id}` (:181), `church.{id}_bipra.{BIPRA}` (:155), `church.{id}_column.{id}` (:202),
`membership.{id}.birthday` (:171). FCM topics permit `[a-zA-Z0-9-_.~%]+` — dots and underscores included.
**Every existing name maps 1:1 to an FCM topic with no renaming.**

### 1.4 ✅ FCM is already shipping in the Flutter app

`apps/palakat/pubspec.yaml:52` — `firebase_messaging: ^15.1.5  # Required for Pusher Beams FCM integration`.
Pusher Beams delivers over FCM on Android, so **the token plumbing, `google-services.json`, APNs certificate and
notification permission flow are already working in production.** The client-side push half of this migration is
mostly already built. The analysis assumed it was greenfield.

### 1.5 ✅ The client RPC surface is confined to a repository layer

`packages/palakat_shared/lib/core/services/socket_service.dart` is the single transport, and **`http_service.dart`
already sits beside it**. The ~150 RPC call sites live in **22 files** under
`packages/palakat_shared/lib/core/repositories/`. The Flutter app mirrors the backend's structure: one brain, two
transports. The UI layer does not touch the socket.

The client rewrite is still the dominant cost, but it is a bounded, mechanical, file-by-file job in one directory
— not an app-wide refactor.

### 1.6 🔴 NEW RISK — FCM topics are client-subscribable; socket rooms were not

**This is the most important finding in this document, and it is a security regression if handled naively.**

Socket rooms are **server-controlled**: the server authenticates the connection, then decides which rooms that
client joins. FCM topics are **client-controlled**: any app instance can call `subscribeToTopic('church.123')`
and Firebase will deliver. **Firebase performs no authorization check on topic subscription.**

Today's payloads carry real content — `entityTitle`, `actorName`, `financeType`, `affectedMembershipIds`,
`resultingStatus`. Publishing those to `church.{id}` topics means **anyone who can guess a church ID receives that
church's finance and approval activity.**

**Mitigation (mandatory, and it is also the cheapest option):** FCM messages become **bare change signals** —
entity type, entity id, event name, nothing else. The client receives the ping and **refetches over authenticated
REST**, where the permission guards from Phase 1 apply.

```ts
// FCM payload: no content, just "something you care about changed"
{ topic: `church.${churchId}`, data: { event: 'finance.updated', entityId: String(id) } }
```

This costs one extra REST call per event, keeps every authorization decision on the server, and stays well inside
FCM's 4 KB data limit. Payload-bearing pushes are the anti-pattern here.

> Note: **Pusher Beams interests have the same self-subscribe property**, so this exposure partially pre-exists
> for the existing notification payloads. Phase 4 should fix both at once rather than porting the flaw across.

If a future event genuinely must carry content, the alternative is **device-token targeting** — the server keeps a
token registry and sends to specific devices via `sendEachForMulticast`. That restores server-side control at the
cost of a token table, rotation handling, and per-device fan-out. **Do not build it unless a concrete requirement
appears.**

---

## 2. Phase map

```
ON EC2 — no infrastructure cost change
Phase 0   Correctness fixes            job-claim race, font, pool bound        ~1–2 days
Phase 1   Permission parity            REST guards to match RPC  🔴 SECURITY   ~4–6 days
Phase 2   REST completeness            fill controller gaps vs. 166 actions    ~2–3 days
Phase 3   FCM push                     reimplement the emitter; retire Beams   ~2–3 days
Phase 4   Event-driven jobs            kill the 10s poller  🔴 PRICE-CRITICAL  ~2 days
Phase 5   Flutter client               22 repos socket→HTTP, topics, polling   ~2–4 weeks
Phase 6   Drain + delete the socket    force-update gate, then delete code     ~2–4 weeks wall
─────────────────────────────────────────────────────────────────────────────────────────
THEN MIGRATE — now cheap, because there is no socket to pin an instance
Phase 7   Containerize + scaffolding   Dockerfile, registry, secrets, WIF      ~2 days
Phase 8   Deploy HTTP-only             scale-to-zero config + CI/CD            ~1,5 days
Phase 9   Cutover                      DNS, soak, decommission EC2             ~0,5 day
Phase 10  Cost tuning                  right-size, split the report worker     ~1–2 days
```

Backend engineering: **~3 weeks**. Client: **2–4 weeks**, overlapping. Wall-clock is dominated by Phase 6 —
waiting for app-store rollout and old installs to drain.

**Phases 0, 1 and 4 are the ones that can hurt you.** The rest is mechanical.

---

## 3. Phase 0 — correctness fixes (do first, regardless)

Scale-to-zero and multi-instance both become real in this plan, so the single-process assumptions that EC2 hides
must go first.

### 0.1 🔴 Atomic job claim in `ReportQueueService`

`src/report/report-queue.service.ts:29` guards with `private isProcessing = false` (per-process); `:283`/`:296`
claim a job as `findFirst` → separate `update`. Two instances claim the same job, render it twice, and every
downstream side-effect fires twice.

```ts
const [job] = await this.prisma.$queryRaw<ReportJob[]>`
  UPDATE "ReportJob" SET status = 'PROCESSING', "updatedAt" = NOW()
  WHERE id = (
    SELECT id FROM "ReportJob"
    WHERE status = 'PENDING'
    ORDER BY "createdAt" ASC
    LIMIT 1
    FOR UPDATE SKIP LOCKED
  )
  RETURNING *;
`;
if (!job) return;
```

Keep `isProcessing` as a *local* limiter — still correct for bounding one process to one job. It is simply no
longer the correctness mechanism.

Add a **stale-job reaper**: a job stuck in `PROCESSING` past N minutes never recovers today. On Cloud Run,
instances die on every revision rollout and on every scale-to-zero, so this goes from rare to routine.

**Verification:** integration test running two `processQueue()` calls concurrently against one PENDING row,
asserting exactly one render.

### 0.2 🔴 Ship the PDF font

`src/report/report-renderer.ts:7–14` probes six paths; the first five are host absolute paths present on Ubuntu
EC2 and on **no** slim container base. `resolveUnicodeFontPath()` returns `undefined` and PDF rendering falls back
to a non-Unicode core font **with no error and no log line**. Most Indonesian text is Latin-1, so it passes a
smoke test and mangles glyphs later.

Verified path arithmetic: compiled output is `dist/src/report/report-renderer.js`, so `__dirname/../../assets` =
`dist/assets`. `nest-cli.json` declares `"assets": ["assets/**/*"]` against `sourceRoot: "src"`, copying
`src/assets/**` → `dist/assets/**`. `src/utils/gmim-letterhead.ts:104-105` already documents and depends on this
exact layout. **Committing the TTF to `src/assets/fonts/NotoSans-Regular.ttf` works with no build change.**

Recommended: `apt-get install -y --no-install-recommends fonts-dejavu-core` in the Dockerfile (Phase 7) — no
binary in git, and candidate #1 then resolves exactly as on EC2. Either way:

```ts
// report-renderer.ts — fail loud at boot, not silently at render time
const UNICODE_FONT_PATH = resolveUnicodeFontPath();
if (!UNICODE_FONT_PATH) {
  throw new Error('No Unicode font found — PDF export would silently mangle non-Latin-1 glyphs');
}
```

### 0.3 🟠 Bound the Prisma pool

`src/prisma.service.ts:19-21` builds `new Pool({ connectionString })` with no `max` — `pg`'s default of **10 per
process**. With scale-to-zero the instance count is spiky by design.

```ts
const pool = new Pool({
  connectionString,
  max: Number(process.env.DATABASE_POOL_MAX ?? 3),
  idleTimeoutMillis: 30_000,
  connectionTimeoutMillis: 10_000,
});
```

Route the service through **Supabase's transaction pooler (port 6543, `?pgbouncer=true`)**. That disables prepared
statements — **run the full e2e suite against the pooler URL before cutover, not after**. Migrations keep the
**direct** connection on 5432; PgBouncer transaction mode cannot run DDL reliably.

Scale-to-zero makes the pooler more important than it was: cold instances open fresh connections in bursts.

### 0.4 🟡 Repo hygiene that will bite the Docker build

- `apps/palakat_backend/package-lock.json` and `apps/palakat_backend/pnpm-lock.yaml` are stale; the root
  `pnpm-lock.yaml` is authoritative. Delete both or the build picks the wrong one.
- `apps/palakat_backend/vercel.json` is a static-site config (SPA rewrites, COOP/COEP) sitting in the backend
  package, used by nothing. Delete.
- `RealtimeEmitterService.emitToSocketId` (:64) has **zero callers**. Dead code — delete it in Phase 3.

---

## 4. Phase 1 — permission parity 🔴 the security critical path

**This is the phase that can ship a vulnerability. It cannot be rushed and it cannot be parallelised with the
client work.**

The RPC path enforces fine-grained permissions:

```ts
// rpc-router.service.ts:2070
case 'finance.list': {
  const { user } = await this.requireAnyOperationPermission(client, [
    'ops.finance.revenue.create', 'ops.finance.expense.create', 'ops.approval.finance',
  ]);
  …
}
```

The REST path does not:

```ts
// finance.controller.ts
@Get()
async findAll(@Query() query: FinanceListQueryDto, @Req() req: any) {
  return this.financeService.findAll(query, req.user);   // @UseGuards(AuthGuard('jwt')) only
}
```

**Any authenticated user reaches `financeService.findAll` over REST today.** Pointing the Flutter client at the
existing 27 controllers as-is ships a privilege-escalation bug across finance and probably other modules.

Work:

1. Extract `requireAnyOperationPermission` / `requireUserId` from `RpcRouterService` into a reusable Nest **guard**
   with a `@RequirePermissions('ops.finance.…')` decorator.
2. Extract `withPagination` / `normalizePaginatedList` into an interceptor — but **check for overlap first**:
   `PaginationInterceptor` is already registered globally in `main.ts:33`. Do not add a second one.
3. **Audit all 166 RPC actions against their controller counterpart, one by one.** Do not skip this because the
   controllers "already exist" — they exist, they are not equivalent.
4. Only then repoint the client.

**Deliverable: a checked-off table of 166 actions**, each mapped to a REST route with its permission set, reviewed
by someone who did not write it. This table is the contract Phase 5 builds against.

**Gate:** an automated test asserting that every permission-bearing route rejects an under-privileged token. A
manual audit without a regression test decays on the first refactor.

---

## 5. Phase 2 — REST completeness

With the parity table from Phase 1, fill the gaps. `RpcRouterService` makes **zero** direct Prisma calls and 143
service delegations, so every action already has a service method behind it. The work is controller surface, not
business logic — the service layer is untouched.

Watch for:

- **File upload** — `file.upload.chunk` streams over the socket via `createWriteStream`. The REST equivalent is
  multipart or resumable upload. This is the one action that is not a mechanical port. Prefer uploading directly
  to Firebase Storage from the client with a server-issued signed URL — it removes the bytes from Cloud Run
  entirely, which is both simpler and cheaper (no request-seconds spent shuttling file data).
- **`document.generate`** — long-running; must return a job id immediately, not block a request.
- **Pagination envelope** — RPC responses go through `normalizePaginatedList`. The REST envelope must match
  byte-for-byte or every client model breaks subtly.

---

## 6. Phase 3 — FCM replaces the socket emitter

### 6.1 Reimplement the one seam

`RealtimeEmitterService.emitToRoom` becomes an FCM topic publish. Callers do not change.

```ts
// realtime-emitter.service.ts — same signature, different transport
async emitToRoom(room: string, event: string, payload: unknown) {
  if (!room?.trim()) return;
  // ponytail: bare change-signal only. Topics are client-subscribable (§1.6),
  // so content never travels in the push — the client refetches over REST.
  const entityId = extractEntityId(payload);
  await this.firebase.messaging().send({
    topic: room,                                  // church.12 / membership.5 — already FCM-legal
    data: { event, ...(entityId ? { entityId } : {}) },
    android: { priority: 'high' },
    apns: { payload: { aps: { 'content-available': 1 } } },
  });
}
```

`FirebaseAdminService` (`src/firebase/firebase-admin.service.ts:36`) already calls `initializeApp` with `cert(...)`
and exposes `auth()` (:52) and `storage()` (:66). **Add a `messaging()` accessor** in the same shape, including
the existing `isConfigured()` no-op fallback so tests and local dev keep working.

### 6.2 Retire Pusher Beams in the same change

Beams is a **paid vendor doing what FCM does free**, over FCM anyway on Android. `publishToInterests` has ~7 call
sites and the interest formatters (§1.3) map straight to topics.

- Replace `PusherBeamsService.publishToInterests(interests, payload)` with an FCM topic send.
- Keep the formatter methods — they become the topic-name vocabulary. Move them out of `pusher-beams.service.ts`
  into a `TopicsService` so nothing references a retired vendor by name.
- Delete `@pusher/push-notifications-server`, `pusher_beams`, and the `pusher_beams_web_stub` package (which
  exists solely to stub Beams on web — an entire workspace package that disappears).
- Drop `PUSHER_BEAMS_INSTANCE_ID` / `PUSHER_BEAMS_SECRET_KEY`.

**Do this after** the FCM emitter is proven in production, not simultaneously. One transport change at a time.

### 6.3 The one category FCM cannot serve

**FCM data messages are best-effort** — Android Doze and iOS background throttling may delay or batch them. Fine
for notifications and admin banners. **Not** fine for `reportJob.*` progress ticks, which want sub-second liveness
while a user watches a modal.

Replacement: **poll `GET /report-jobs/:id` every 2 seconds while the progress modal is open.** Report generation is
rare, user-initiated, and short. Thirty seconds of polling, occasionally, is nothing — and it deletes the only
category that genuinely wanted a live channel.

| Realtime category | Sites | Replacement |
|---|---|---|
| `notification.created/updated/deleted` | `notification.service.ts` :116, :441, :485 | FCM topic ping → client refetch |
| `activity.*` / `finance.*` / `approval.*` banners | `rpc-router.service.ts` :3153, :3956 + emitter helpers | FCM topic ping → refetch, or refetch-on-focus |
| `reportJob.*` progress | `report-queue.service.ts` :138, :305, :362, :375, :408 | 2-second polling while the modal is open |

---

## 7. Phase 4 — event-driven jobs 🔴 the price-critical phase

**Get this wrong and the entire price argument collapses.**

`report-queue.service.ts:268` runs `@Cron(CronExpression.EVERY_10_SECONDS)`. Two independent problems:

1. On request-based billing, CPU is throttled outside request handling — **a `@Cron` timer is not a request**, so
   it fires only opportunistically. Reports never finish. No error, no alert.
2. Naively replacing it with Cloud Scheduler hitting an endpoint every minute means **the instance never scales to
   zero**. You would pay the always-on rate and get cold-start latency as a bonus — the worst of both models.

**A polling queue and scale-to-zero are fundamentally incompatible.** The queue must become event-driven.

### 7.1 Report queue → Cloud Tasks

On report-job creation, enqueue a Cloud Task targeting an authenticated worker endpoint. No polling, no idle
wake-ups, and lower latency than a 10-second tick.

```
POST /report-jobs  ──►  create row  ──►  Cloud Tasks enqueue
                                              │
                                              ▼
                                    POST /internal/tasks/report/:id   (OIDC-authenticated)
```

- **Cloud Tasks free tier: 1 juta operations/month.** This will cost nothing.
- Configure the queue with `--max-attempts` and `--max-concurrent-dispatches` matched to `max-instances`.
- Retries are then Cloud Tasks' problem, not a cron loop's.
- Keep the atomic claim from Phase 0.1 — a retried task must not double-render.
- Keep a **once-daily** Scheduler sweep for orphans (rows whose task was lost). Once a day, not once a minute.

### 7.2 Birthday job → Cloud Scheduler

`birthday-notification.service.ts:15` — `@Cron('0 7 * * *')` becomes Cloud Scheduler → `POST
/internal/cron/birthday` with OIDC auth. Once a day, one wake-up, negligible.

This job is **already idempotent** and needs no logic change: `schema.prisma:677` has `dedupeKey String? @unique`,
and the service inserts first, catches Prisma `P2002`, and `continue`s before sending the push. It is the pattern
Phase 0.1 was missing. Keep it — Cloud Scheduler can double-deliver.

### 7.3 Secure the internal endpoints

`/internal/*` must reject anything without a valid Google-signed OIDC token from the invoking service account.
Verify the token's `aud` and `email`. These routes bypass user authentication by design, so a mistake here is a
full authorization bypass. Exclude them from the global `api/v1` prefix deliberately, as `main.ts:17-21` already
does for `/health`.

---

## 8. Phase 5 — Flutter client

The bounded, mechanical, long part. Structure is favourable (§1.5).

1. **Transport swap.** 22 repository files under `packages/palakat_shared/lib/core/repositories/`, ~150 call
   sites, from `socket_service.dart` to the existing `http_service.dart`. Work against the Phase 1 parity table,
   one repository at a time.
2. **Topic subscription** replaces room joins. On login/session restore, `subscribeToTopic` for the user's
   `account.{id}`, `membership.{id}`, `church.{id}`, and column/bipra topics. **`unsubscribeFromTopic` on logout
   and on church switch** — a missed unsubscribe leaks another church's notifications to a device forever, and
   there is no server-side revocation for topics.
3. **Handle bare change signals.** `realtime_events_service.dart` stops carrying payload content and instead
   invalidates the relevant cache/provider so the UI refetches over REST. Simpler than today's payload merging.
4. **Report progress polling** — 2 s interval, only while the modal is open, with a hard stop on close and a
   backstop timeout.
5. **`firebase_messaging` is already wired** (`apps/palakat/pubspec.yaml:52`) — no new dependency, no new
   platform configuration.

**Price note:** every RPC that was one socket message becomes one **billable Cloud Run request**. At 24 juta
requests/month that is Rp 162.800/bulan, and it is the largest single line item in the target architecture —
larger than CPU. Design the client to be less chatty than the socket was: cache aggressively, coalesce list
refreshes, and do not refetch on every FCM ping if several arrive together. **Request count is the main price
lever after migration.**

---

## 9. Phase 6 — drain the socket, then delete it

**Installed apps do not update on your schedule.** Old versions hold sockets and will keep doing so for weeks.
Cutting the socket server before they drain breaks working installs.

1. **Ship both transports.** Backend keeps the gateway; new client releases use HTTP + FCM. Zero risk, since the
   socket is already running.
2. **Force the upgrade.** The repo already has a version-gated update mechanism driven by tag severity
   (`-breaking` / `-recommended`, per the `push-deploy` workflow). Ship this release as **`-breaking`** so old
   clients are gated into updating.
3. **Measure the drain.** Log Socket.IO connections by client version. Wait until the tail is negligible —
   expect **2–4 weeks**.
4. **Then delete:** `realtime.gateway.ts`, `rpc-router.service.ts` (the single largest file in the backend),
   `redis-io.adapter.ts`, `socket_service.dart`, and the `@nestjs/websockets` / `@nestjs/platform-socket.io` /
   `@socket.io/redis-adapter` / `socket_io_client` dependencies.
5. Remove the `RedisIoAdapter` wiring from `main.ts:43-45`.

> **Do not migrate to Cloud Run before step 4 completes.** Running the socket on Cloud Run for even one month
> costs the full Rp 875.790 always-on rate. On EC2 the drain period is free.

**Deleting `rpc-router.service.ts` is the single biggest maintenance win in this plan** — one transport, one
permission model, one place where authorization lives.

---

## 10. Phase 7 — containerize + GCP scaffolding

### 10.1 Build facts that constrain the Dockerfile

| Fact | Source | Consequence |
|---|---|---|
| pnpm workspace rooted at repo root | `pnpm-workspace.yaml` | **Build context is the repo root**, not `apps/palakat_backend`. |
| `packageManager: pnpm@10.17.0` | `package.json:115` | Use corepack; do not `npm i -g pnpm`. |
| CI uses Node 24 | existing workflow | Base `node:24-slim` — match production to CI. |
| Prisma 7 `prisma-client` generator → `src/generated/prisma`, **untracked in git** | `schema.prisma:1-5`; `git ls-files` returns 0 | `prisma generate` **must** run in the build, before `nest build`. Output is TypeScript, compiled by `tsc` into `dist/`. |
| `datasource db` has **no** `url` | `schema.prisma:7-9` | URL comes from `prisma.config.ts`. Needed for `migrate`, not runtime — `PrismaService` builds its own from env. |
| `build` = `prisma generate && nest build`; `start:prod` = `node dist/src/main.js` | `package.json` | `CMD` is `node dist/src/main.js`. Do not wrap in pnpm. |
| `postinstall: prisma generate` | `package.json` | Install with `--ignore-scripts` so layer caching works, then generate explicitly. |
| No Rust query engine (driver adapter) | `prisma.service.ts` | Nothing to match to libc — `node:24-slim` is fine, Alpine is unnecessary risk. **Also the main reason cold starts are tolerable**, which now matters because scale-to-zero is the point. |
| `app.listen(process.env.PORT \|\| 3000, '0.0.0.0')` | `main.ts` | Already Cloud Run compatible. Do not set `PORT` yourself. |

### 10.2 `apps/palakat_backend/Dockerfile`

```dockerfile
# syntax=docker/dockerfile:1
# Build context is the REPO ROOT:  docker build -f apps/palakat_backend/Dockerfile .

FROM node:24-slim AS base
ENV PNPM_HOME=/pnpm PATH=/pnpm:$PATH
RUN corepack enable
WORKDIR /repo

FROM base AS deps
COPY pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/palakat_backend/package.json apps/palakat_backend/
RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --frozen-lockfile --ignore-scripts

FROM deps AS build
COPY apps/palakat_backend apps/palakat_backend
RUN pnpm --dir apps/palakat_backend run build   # prisma generate && nest build

FROM base AS runtime
ENV NODE_ENV=production
# ponytail: fonts-dejavu-core satisfies UNICODE_FONT_CANDIDATES[0] — the same font
# the Ubuntu EC2 box resolves. Alternative is committing the TTF to src/assets/fonts/.
RUN apt-get update \
 && apt-get install -y --no-install-recommends fonts-dejavu-core ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY --from=build /repo/node_modules                          /repo/node_modules
COPY --from=build /repo/apps/palakat_backend/node_modules     /repo/apps/palakat_backend/node_modules
COPY --from=build /repo/apps/palakat_backend/dist             /repo/apps/palakat_backend/dist
COPY --from=build /repo/apps/palakat_backend/prisma           /repo/apps/palakat_backend/prisma
COPY --from=build /repo/apps/palakat_backend/prisma.config.ts /repo/apps/palakat_backend/
COPY --from=build /repo/apps/palakat_backend/package.json     /repo/apps/palakat_backend/

WORKDIR /repo/apps/palakat_backend
USER node
CMD ["node", "dist/src/main.js"]
```

**Image size now matters more than it did.** With scale-to-zero, every cold start pulls and starts this image.
Deleting the socket stack (`@nestjs/websockets`, `platform-socket.io`, `redis-adapter`, `@pusher/…`) in Phase 6
shrinks it for free. If cold start exceeds ~3 s after that, prune dev dependencies with `pnpm deploy --filter` —
**measure first** (Phase 10), do not pre-optimise.

`.dockerignore` at repo root:

```
**/node_modules
**/dist
**/.env
**/.env.*
!**/.env.example
build/
.dart_tool/
.git
.claude
ios/ android/ macos/ windows/ linux/ web/
apps/palakat_backend/src/generated
```

The last line matters: a stale local `src/generated/prisma` must never shadow the one built in the image.

### 10.3 GCP scaffolding

```bash
gcloud config set project PROJECT_ID
gcloud services enable run.googleapis.com artifactregistry.googleapis.com \
  secretmanager.googleapis.com cloudscheduler.googleapis.com \
  cloudtasks.googleapis.com iamcredentials.googleapis.com

gcloud artifacts repositories create palakat \
  --repository-format=docker --location=REGION
```

Set an Artifact Registry **cleanup policy** immediately (keep 10 recent, delete untagged after 7 days). Without
it storage grows forever at Rp 1.850/GB-bulan and nobody notices.

Three identities, kept separate:

| Identity | Roles |
|---|---|
| `palakat-backend` (runtime) | `roles/secretmanager.secretAccessor` |
| `palakat-invoker` (Scheduler + Tasks) | `roles/run.invoker` on the service |
| `palakat-deployer` (GitHub Actions) | `roles/run.admin`, `roles/artifactregistry.writer`, `roles/iam.serviceAccountUser` |

### 10.4 Configuration — the trap this project has

`src/app.module.ts:38-45` sets
`ignoreEnvFile: !DOTENV_CONFIG_PATH && (NODE_ENV === 'production' || INVOCATION_ID !== undefined)`.

**Set `NODE_ENV=production` and do NOT set `DOTENV_CONFIG_PATH`.** Then `@nestjs/config` reads only `process.env`
and the sectioned `[local]/[staging]/[production]` `.env` format that `prisma.config.ts` parses is bypassed
entirely. That format exists for the EC2 file at `/etc/palakat/palakat_backend.env` and has no Cloud Run
equivalent. `PALAKAT_ENV` becomes irrelevant once `DATABASE_URL` is a real environment variable. **It looks like
something that needs porting; it does not.**

Secrets, one per Secret Manager entry: `JWT_SECRET`, `DATABASE_URL`, `DATABASE_URL_DIRECT`, `HEALTH_PAGE_SECRET`,
`APP_CLIENT_PASSWORD`, `FIREBASE_PRIVATE_KEY`, `SONG_DB_FILE_ID`. Pusher's two are **deleted** in Phase 3.

> ⚠️ **`FIREBASE_PRIVATE_KEY` is the one that will break.** In the EC2 `.env` it is a single line with literal
> `\n` escapes. Secret Manager will happily store a real multi-line PEM instead — a *different* string, producing
> an opaque failure at `cert(...)` in `firebase-admin.service.ts:36`. **Store it byte-identical to the `.env`
> line, escapes included.** This now matters more than before, because FCM delivery depends on it: a bad key
> means *all* push silently stops, not just Firebase auth.

Workload Identity Federation (the existing workflow already declares `permissions: id-token: write`):

```bash
gcloud iam workload-identity-pools providers create-oidc github-provider \
  --location=global --workload-identity-pool=github \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
  --attribute-condition="assertion.repository=='GH_ORG/REPO'"
```

**`--attribute-condition` is not optional.** Without it any GitHub repository on the internet can mint tokens for
your project.

---

## 11. Phase 8 — deploy HTTP-only, priced for scale-to-zero

### 11.1 Service configuration — the point of the whole exercise

```bash
gcloud run deploy palakat-backend \
  --image=REGION-docker.pkg.dev/PROJECT_ID/palakat/backend:TAG \
  --region=REGION \
  --service-account=palakat-backend@PROJECT_ID.iam.gserviceaccount.com \
  --min-instances=0 \
  --max-instances=5 \
  --cpu=1 --memory=1Gi \
  --concurrency=80 \
  --timeout=300 \
  --allow-unauthenticated \
  --set-env-vars=NODE_ENV=production,FORCE_SEEDING=false,DATABASE_POOL_MAX=3,… \
  --set-secrets=JWT_SECRET=JWT_SECRET:latest,DATABASE_URL=DATABASE_URL:latest,…
```

Compare against the rejected socket configuration — this is where the money is:

| Setting | With socket (rejected) | HTTP-only (this plan) | Why |
|---|---|---|---|
| `min-instances` | 1 | **0** | Nothing pins an instance. This is the entire saving. |
| CPU allocation | `--no-cpu-throttling` (always) | **request-based (default)** | Cron is gone (Phase 4), so nothing needs CPU between requests. |
| `timeout` | 3600 s | **300 s** | No connections to hold. Long work is a Task, not a request. |
| `session-affinity` | required | **off** | No sticky handshake. Affinity was best-effort anyway. |
| `max-instances` | 1 (forced) | **5** | Safe now: atomic job claim (0.1), no in-memory socket adapter, no Redis. |
| Redis | mandatory at >1 instance | **none** | Rp 666.000/bulan line item deleted. |

`--max-instances=5` is a **cost ceiling**, not a capacity target. A runaway default is how a Rp 200 ribu service
becomes a Rp 10 juta one. Raise it deliberately, with a budget alert already in place.

**Startup probe:** use the **default TCP probe**. `/health` sits behind `HealthSecretGuard`
(`health-secret.guard.ts:29` requires an `x-health-secret` header), and header-bearing HTTP probes cannot be
expressed in `gcloud run deploy` flags — they need `gcloud run services replace service.yaml`. TCP is sufficient
because the app binds its port only after `PrismaService.$connect()` resolves.

### 11.2 Migrations — a Cloud Run Job, never the container start

```bash
gcloud run jobs create palakat-migrate \
  --image=…:TAG --region=REGION \
  --service-account=palakat-backend@PROJECT_ID.iam.gserviceaccount.com \
  --set-secrets=DATABASE_URL=DATABASE_URL_DIRECT:latest \
  --command=npx --args=prisma,migrate,deploy \
  --max-retries=0 --task-timeout=600
```

1. **`DATABASE_URL_DIRECT`, not the pooler** — DDL needs port 5432. A separate secret holding a different URL.
2. **`npx prisma migrate deploy`, not `pnpm run db:deploy`** — the npm script also runs `prisma generate`, which
   is pointless in a runtime container.
3. `prisma.config.ts` resolves `datasource.url` from `process.env` first, so no `.env` file need exist in the
   image.
4. **Never run the seed in production.** `FORCE_SEEDING=false`, and `db:push` (`--force-reset`) must not exist in
   any pipeline that can reach production.

### 11.3 Scheduler and Tasks

```bash
gcloud scheduler jobs create http birthday-notifications \
  --schedule="0 7 * * *" --time-zone="Asia/Makassar" \
  --uri="https://api.example.com/internal/cron/birthday" \
  --oidc-service-account-email=palakat-invoker@PROJECT_ID.iam.gserviceaccount.com

gcloud tasks queues create report-jobs \
  --max-attempts=3 --max-concurrent-dispatches=5
```

Match `--time-zone` to the congregation's actual timezone — `0 7 * * *` in UTC is 15:00 WITA, which is not a
birthday-notification hour.

### 11.4 CI/CD

The existing `.github/workflows/palakat-backend-deploy.yml` (~150 lines: temporary SG ingress, scp a tarball, ssh,
build on the box, `db:deploy`, `systemctl restart`, health poll, revoke ingress) is **deleted**. Keep the
`deploy-backend*` tag trigger so muscle memory survives.

```yaml
      - name: Build & push
        run: |
          IMAGE="${{ vars.GCP_REGION }}-docker.pkg.dev/${{ vars.GCP_PROJECT }}/palakat/backend:${{ github.sha }}"
          docker build -f apps/palakat_backend/Dockerfile -t "$IMAGE" .
          docker push "$IMAGE"
          echo "IMAGE=$IMAGE" >> "$GITHUB_ENV"
      - name: Migrate
        run: |
          gcloud run jobs update palakat-migrate --image="$IMAGE" --region=$REGION
          gcloud run jobs execute palakat-migrate --region=$REGION --wait
      - name: Deploy (no traffic)
        run: gcloud run deploy palakat-backend --image="$IMAGE" --region=$REGION --no-traffic --tag=candidate
      - name: Smoke the candidate
        run: |
          URL=$(gcloud run services describe palakat-backend --region=$REGION \
                 --format='value(status.traffic.filter("tag=candidate").url)')
          curl -fsS -H "x-health-secret: ${{ secrets.HEALTH_PAGE_SECRET }}" "$URL/health"
      - name: Promote
        run: gcloud run services update-traffic palakat-backend --region=$REGION --to-latest
```

Order matters: **migrate → deploy `--no-traffic` → smoke the tagged revision → promote.** The `--tag=candidate`
URL lets you hit the new revision before any user does — something `systemctl restart` never allowed.

Migrations run *before* the new code takes traffic, so **every migration must be backward compatible with the
running revision**. Expand/contract, never rename-in-place.

Delete `EC2_SSH_PRIVATE_KEY`, `EC2_SSH_PASSPHRASE`, `EC2_HOST`, `EC2_USER`, `EC2_PORT`,
`EC2_SECURITY_GROUP_ID`, `AWS_ROLE_TO_ASSUME`. **Revoke the SSH key when you delete the secret** — a deleted
GitHub secret is not a revoked key.

---

## 12. Phase 9 — cutover

1. Deploy to Cloud Run against the **production** Supabase database, no DNS change. Both stacks run; EC2 serves
   all clients.
2. Verify on the `run.app` URL: health, login, a REST call per module, a PDF export, one report job end-to-end
   **including its Cloud Task**, and one FCM delivery to a real device.
3. **Verify cold start.** With `min-instances=0` the first request after idle pays 2–5 s. Measure it. If it is
   unacceptable for the Sunday peak, see Phase 10.3 — do not reflexively set `min-instances=1` and give back the
   entire saving.
4. Watch the 07:00 Scheduler job fire **exactly once**, and confirm the daily orphan sweep runs.
5. **Lower DNS TTL to 60 s at least 24 hours beforehand.** This is the step teams skip and then cannot roll back.
6. Cut over. Do it **outside** a service.
7. Soak **one full week including a Sunday** with EC2 still running and warm.
8. Stop the EC2 instance (do not terminate). Wait another week. Then terminate and **release the Elastic IP** — an
   unattached EIP still bills.

**Rollback ladder:**

| Failure | Action | Time |
|---|---|---|
| Bad revision | `gcloud run services update-traffic --to-revisions=PREVIOUS=100` | seconds |
| Cloud Run broadly wrong | DNS back to EC2 (why it stays warm for a week) | ~60 s at TTL 60 |
| Bad migration | **Forward-fix only.** There is no rollback for `migrate deploy`. | — |

Snapshot Supabase immediately before the first production migration run.

---

## 13. Phase 10 — cost tuning

Only after real traffic data exists. **Measure, then tune.**

### 13.1 Where the money actually goes

At 4.000 users, 24 juta requests/month, 1 vCPU / 1 GiB:

| Line item | 180h active | 90h active |
|---|---:|---:|
| CPU (net of 180.000 vCPU-s free) | $3.46 · Rp 64.010 | **$0 — free tier covers it** |
| Memory (net of 360.000 GiB-s free) | $0 | $0 |
| Requests (24 juta, net of 2 juta free) | $8.80 · Rp 162.800 | $8.80 · Rp 162.800 |
| **Total** | **$12.26 · Rp 226.810** | **$8.80 · Rp 162.800** |

**Requests dominate — not CPU.** That inverts the usual intuition and sets the priority: reducing request count
beats any container tuning. Cache aggressively on the client, coalesce list refreshes, and do not refetch on every
FCM ping.

The free tier does real work here, unlike in the socket architecture where it covered 9,1% of an always-on vCPU.
Break-even (compute entirely free): **50 h/bulan at 1 vCPU, 100 h/bulan at 0,5 vCPU**.

### 13.2 Right-size, and consider splitting the report worker

The service must currently be sized for its **peak** workload — a large `pdfkit`/`exceljs` export — even though
that happens rarely. Cloud Run's writable filesystem is **tmpfs charged against the memory limit**, so every byte
of a generated report counts against RAM.

**Optimisation:** move report rendering to a **separate Cloud Run Job** sized 2 vCPU / 2 GiB, triggered by the
Cloud Task from Phase 4. The API service then drops to **0,5 vCPU / 512 MiB**, where 100 h/month of compute is
free.

| | Single service | Split (API + report Job) |
|---|---:|---:|
| API compute, 90h | $0 (free tier) at 1 vCPU | $0 (free tier) at 0,5 vCPU, with 2× the headroom |
| API compute, 180h | $3.46 · Rp 64.010 | **$0 — 180h at 0,5 vCPU is still near the allowance** |
| Report rendering | shared, forces 1 GiB+ sizing | billed per run — minutes/month |
| tmpfs OOM risk | real | **gone** — isolated in a job sized for it |

Saves on the order of **Rp 60 ribu/bulan** and removes risk R7 outright. **Do it only if the bill or an OOM
justifies it** — it adds a component, and Phase 4's Cloud Task already provides the trigger, so it is cheap to
add later.

### 13.3 Cold start vs. `min-instances`

`min-instances=1` costs **~Rp 875 ribu/bulan** and eliminates cold starts. That is the entire saving, spent.
Cheaper options first:

- **Pre-warm on a schedule.** Cloud Scheduler pings `/health` every 5 minutes from 07:30–12:00 Sunday. Instances
  stay warm through the peak; the rest of the week scales to zero. Costs a few active-hours, not Rp 875 ribu.
- **Trim the image** (Phase 6 already deletes the socket stack; `pnpm deploy --prod` prunes further).
- **Startup CPU boost** — `--cpu-boost` accelerates bootstrap for a fraction of always-on cost.

Prisma 7's driver adapter means no Rust engine binary to load, so NestJS bootstrap is the whole cold start. Measure
it before spending anything.

### 13.4 Guardrails, configured on day one

- **Billing budget alert in USD** at 100% / 150% / 200%. Bills are USD; funding is likely IDR. Budget in IDR with
  **10–15% FX headroom** (analysis §3.7). Carrying a smaller USD bill also means carrying less currency risk.
- **`max-instances` explicit**, never default.
- **Artifact Registry cleanup policy.**
- **Log-based alerts** on `Container called exit` and on Cloud Tasks dead-letter depth — with no cron loop, a
  silently failing task queue is how reports stop without anyone noticing.
- **Uptime check** on `/health` with the secret header (Cloud Monitoring uptime checks *do* support custom
  headers, unlike startup probes). Doubles as a keep-warm ping.

---

## 14. Risk register

| # | Risk | Likelihood | Impact | Mitigation | Phase |
|---|---|---|---|---|---|
| R1 | **FCM topics are client-subscribable → cross-church data leak** | **High if payloads carry content** | **Confidentiality breach** | Bare change-signals only; client refetches over authenticated REST | 3 |
| R2 | REST lacks the RPC permission checks → privilege escalation | **High if Phase 1 is rushed** | Finance data exposed to any authenticated user | Audit all 166 actions; automated under-privileged-token tests | 1 |
| R3 | Polling cron survives into Cloud Run → scale-to-zero never happens | Medium | Price target missed entirely; pays always-on | Cloud Tasks (event-driven), not Scheduler polling | 4 |
| R4 | Socket cut before old installs drain | Medium | Working installs break | Dual transport + `-breaking` update gate + measure the drain | 6 |
| R5 | Duplicate report processing at >1 instance | Certain without the fix | Data correctness + double CPU | `FOR UPDATE SKIP LOCKED` + atomic claim | 0 |
| R6 | `FIREBASE_PRIVATE_KEY` newline mangling in Secret Manager | High | **All push silently stops** | Store byte-identical to `.env`; assert on the parsed key at boot | 7 |
| R7 | tmpfs OOM during a large export | Medium | Instance killed mid-render | 1 GiB minimum; split the report worker (13.2) | 8, 10 |
| R8 | Topic unsubscribe missed on logout / church switch | Medium | Device keeps receiving another church's pings, permanently | Explicit unsubscribe; no server-side revocation exists | 5 |
| R9 | PDF glyphs silently degrade on the slim base image | High if unaddressed | Corrupt reports found by users | `fonts-dejavu-core` + **startup assertion** | 0 |
| R10 | Prepared statements break on PgBouncer | Medium | Runtime query failures | Full e2e against the pooler **before** cutover | 0 |
| R11 | Request count higher than modelled | Medium | Requests are the dominant cost | Client-side caching; monitor request count as the primary price metric | 5, 10 |
| R12 | Cold start hurts the Sunday peak | Medium | Poor UX at the worst moment | Scheduled pre-warm before `min-instances=1` | 10 |
| R13 | Cross-cloud DB latency if regions mismatch | Certain if mismatched | +5–15 ms/query, compounds in report loops | Q1: match the Supabase region | 7 |
| R14 | Non-backward-compatible migration during rollout | Medium | Old revision errors mid-deploy | Expand/contract; snapshot before first prod migration | 8 |
| R15 | Runaway `max-instances` | Low | Rp 10 juta surprise | Explicit ceiling + budget alerts | 8, 10 |

---

## 15. Checklist

```
ON EC2 — no cost change
Phase 0   [ ] atomic job claim + stale-job reaper + concurrency test
          [ ] font in image + startup assertion
          [ ] DATABASE_POOL_MAX; e2e green against the transaction pooler
          [ ] stale lockfiles, vercel.json, dead emitToSocketId removed

Phase 1   [ ] @RequirePermissions guard extracted from RpcRouterService
          [ ] all 166 actions audited into a reviewed parity table
          [ ] under-privileged-token tests pass on every route   🔴 SECURITY GATE

Phase 2   [ ] controller gaps filled; pagination envelope byte-identical
          [ ] file upload re-designed (signed URL direct to Storage)

Phase 3   [ ] FirebaseAdminService.messaging() added
          [ ] emitToRoom reimplemented — BARE SIGNALS ONLY, no payload content
          [ ] Pusher Beams retired; deps + secrets + web stub package deleted
          [ ] report progress → 2s polling

Phase 4   [ ] report queue → Cloud Tasks (NOT a Scheduler poll)   🔴 PRICE GATE
          [ ] birthday → Cloud Scheduler, correct timezone
          [ ] /internal/* verifies OIDC aud + email
          [ ] daily orphan sweep

Phase 5   [ ] 22 repositories on http_service
          [ ] topic subscribe AND unsubscribe on logout / church switch
          [ ] FCM ping → cache invalidate → refetch
          [ ] request count measured, not assumed

Phase 6   [ ] dual transport shipped; drain measured by client version
          [ ] -breaking update gate released
          [ ] gateway, rpc-router, redis adapter, socket deps deleted

THEN MIGRATE
Phase 7   [ ] Dockerfile (context = repo root); .dockerignore excludes src/generated
          [ ] APIs, registry + cleanup policy, three separate service accounts
          [ ] FIREBASE_PRIVATE_KEY verified byte-identical
          [ ] WIF with --attribute-condition

Phase 8   [ ] min=0, max=5, request-based, timeout 300, no affinity, no Redis
          [ ] migrations = Cloud Run Job on the DIRECT url
          [ ] CI/CD: migrate → --no-traffic → smoke → promote
          [ ] EC2/AWS secrets deleted AND SSH key revoked

Phase 9   [ ] DNS TTL 60s, 24h ahead
          [ ] cold start measured; Scheduler + Tasks verified end-to-end
          [ ] one-week soak with EC2 warm → stop → terminate → release EIP

Phase 10  [ ] USD budget alert; IDR budget +15% headroom
          [ ] max-instances explicit; dead-letter alerting
          [ ] split report worker IF the bill or an OOM justifies it
```

---

## 16. Bottom line

| Question | Answer |
|---|---|
| Is Cloud Run cheaper now? | **Yes** — Rp 163–227 ribu/bulan vs Rp 378 ribu on EC2, plus Redis and Pusher Beams deleted. The socket was the entire reason it was not. |
| What is the hardest part? | **Phase 1**, the permission-parity audit. It is security work, not plumbing. |
| What is the longest part? | **Phase 5–6**, the Flutter rewrite and the drain. Bounded to 22 repository files, but gated on app-store rollout. |
| What single mistake costs the most? | Replacing the 10-second poller with a **Scheduler poll instead of Cloud Tasks** — the instance never idles and the whole price case evaporates. |
| What single mistake is most dangerous? | Putting **content in FCM payloads**. Topics are client-subscribable; socket rooms were not. |
| Why migrate last? | Running the socket on Cloud Run costs Rp 875.790/bulan. The drain period is free on EC2. |
| Biggest non-cost win | Deleting `rpc-router.service.ts`: one transport, one permission model, one place authorization lives. |
