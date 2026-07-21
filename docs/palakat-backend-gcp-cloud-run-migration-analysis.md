# Porting `palakat_backend` to GCP Cloud Run — Drawbacks, Cost, and Performance Analysis

**Date:** 2026-07-21
**Scope:** `apps/palakat_backend` (NestJS 10, Prisma 7 + Postgres, Socket.IO, in-process cron)
**Question asked:** should we move off AWS to GCP Cloud Run, and how does that compare to AWS Lambda on cost and performance?
**Currency:** all costs shown as **USD · IDR** at an assumed **Rp 18,500 / USD**. Read §3.7 before treating the
rupiah figures as a budget — Google and AWS bill in USD, so these are conversions, not prices.

---

## 0. Read this first — the premise needs correcting

Two corrections before any comparison is meaningful.

### 0.1 You are not on Lambda. You are on EC2.

The only AWS deployment design in this repo is
[`docs/palakat-backend-aws-ec2-cicd-deployment-guide.md`](./palakat-backend-aws-ec2-cicd-deployment-guide.md):
a **single EC2 instance** running `systemd` + Nginx, with **Supabase Postgres** as the database and GitHub
Actions for CI/CD. There is no `serverless.yml`, no SAM template, no CDK app, no Lambda handler, no
`@vendia/serverless-express` adapter anywhere in the tree. `grep -riE 'aws|lambda|serverless'` across
`apps/palakat_backend/src` returns zero real hits — only substring collisions like `rawStartDate` and `sawSection`.

So "Cloud Run instead of Lambda" is comparing your **hypothetical future** against **someone else's
hypothetical future**. The real comparison is **Cloud Run vs. the EC2 box you actually run**. This document
answers both, but the EC2 column is the one that decides anything.

### 0.2 This application cannot run on AWS Lambda without a rewrite

Not "would be awkward on" — **cannot**, as written. Three hard blockers:

| Blocker | Evidence in repo | Why Lambda can't |
|---|---|---|
| Persistent Socket.IO server | `src/realtime/realtime.gateway.ts` — `@WebSocketGateway({ path: '/ws' })`, `handleConnection`, `handleDisconnect` | Lambda has no long-lived connections. API Gateway WebSocket API speaks **raw** WebSocket with route-key dispatch; it does **not** speak the Socket.IO/Engine.IO protocol (handshake, polling upgrade, ack ids, rooms). The Flutter client and the entire `rpc-router.service.ts` dispatch layer would need rewriting on both ends. |
| In-process job queue | `src/report/report-queue.service.ts:268` — `@Cron(CronExpression.EVERY_10_SECONDS)` polling `reportJob` | Lambda has no resident process to poll on a 10-second tick. Needs EventBridge Scheduler + SQS, or Step Functions. |
| Long CPU-bound report rendering | `pdfkit` + `exceljs` in `report.service.ts` (~1,900 lines) and `report-renderer.ts` | Lambda caps at 15 minutes and 10 GB. Large multi-church PDF/XLSX exports are exactly the workload that finds that ceiling. |

Plus: `report-renderer.ts:13` loads TTF fonts from `__dirname/../../assets/fonts` off the filesystem, and
`rpc-router.service.ts` streams file uploads. Both are doable on Lambda, neither is free.

**Conclusion:** Lambda is priced below as a thought experiment for completeness, because you asked. It is not a
live option. Treat the Lambda column as "what a rewrite would cost you to *run*, on top of what it costs you to
*build*."

---

## 1. What the application actually is

Facts established by reading the code, because they drive every conclusion below:

- **Stateful by design.** Clients hold a Socket.IO connection at `/ws`, authenticate via
  `handshake.auth.token`, and issue RPC calls over that socket (`@SubscribeMessage('rpc')` →
  `RpcRouterService.dispatch`). `rpc-router.service.ts` is the single largest file in the backend. This is not
  a REST API with a bit of realtime bolted on — the socket **is** a primary API surface.
- **Two in-process cron jobs.**
  - `report-queue.service.ts:268` — `@Cron(EVERY_10_SECONDS)` job queue poller.
  - `notification/birthday-notification.service.ts:15` — `@Cron('0 7 * * *')` daily push notifications to
    every congregant with a matching birthday.
- **Single-instance assumptions baked in.** `ReportQueueService` guards concurrency with a **per-process
  boolean**, `private isProcessing = false`. The job claim is a non-atomic read-then-write:
  ```ts
  const job = await this.prisma.reportJob.findFirst({ where: { status: PENDING }, orderBy: { createdAt: 'asc' } });
  // ... then, separately:
  await this.prisma.reportJob.update({ where: { id: job.id }, data: { status: PROCESSING } });
  ```
- **Redis is optional today.** `redis-io.adapter.ts` logs *"Redis is not configured; using in-memory socket.io
  adapter"* and continues. The EC2 guide explicitly says Redis is not required for single-instance.
- **Prisma 7 with `@prisma/adapter-pg`** — a real `pg.Pool` per process (`src/prisma.service.ts`). Notably
  the driver-adapter path means **no Rust query-engine binary**, which is genuinely good news for container
  size and cold start.
- **Database is already off AWS.** Supabase, per the deployment guide.

That last point matters more than it looks: **you are already multi-cloud.** The "move off AWS" decision only
moves the compute, and the compute is the cheap part.

---

## 2. The single most important finding

From Google's own documentation on [WebSockets on Cloud Run](https://docs.cloud.google.com/run/docs/triggering/websockets):

> **"A Cloud Run instance that has any open WebSocket connection is considered active, so CPU is allocated and
> the service is billed as instance-based billing."**

Read that again with your architecture in mind. Every Flutter client that opens the app holds a socket. As long
as **one** user has the app open, **your Cloud Run instance is billed at the active rate.** Scale-to-zero — the
entire economic premise of serverless — **does not apply to this application.**

Which means: for `palakat_backend`, Cloud Run is not "serverless pay-per-use." It is **a managed always-on
container that you rent by the vCPU-second**, and you should price it that way. Everything in §3 follows from this.

---

## 3. Cost comparison

All rates verified 2026-07-21 against primary sources (linked in §8). Region: `us-central1` for Cloud Run,
`us-east-1` for AWS. Jakarta (`asia-southeast2` / `ap-southeast-3`) runs roughly 15–25% higher on both sides;
the *ratios* hold. IDR at Rp 18,500 / USD.

### 3.1 Verified rates

Billed rates are per-second and denominated in USD. Converting a per-vCPU-second rate to rupiah produces a
meaningless fraction, so the practical column — what one unit costs if you run it for a full month — is given
in both.

| | Cloud Run (instance-based) | Cloud Run (request-based) | AWS Lambda |
|---|---|---|---|
| CPU | $0.000018 / vCPU-s | $0.000024 / vCPU-s active, $0.0000025 idle | bundled into GB-s |
| Memory | $0.000002 / GiB-s | $0.0000025 / GiB-s | $0.0000166667 / GB-s (x86)<br>$0.0000133334 / GB-s (Arm) |
| Requests | none | $0.40 / M · **Rp 7.400 / juta** | $0.20 / M · **Rp 3.700 / juta** |
| Free tier / mo | 240.000 vCPU-s + 450.000 GiB-s | 180.000 vCPU-s + 360.000 GiB-s + 2 juta req | 1 juta req + 400.000 GB-s |

**What one unit costs running 24/7 for a month** — the number worth memorising:

| Unit | Cloud Run instance-based | Cloud Run request-based (active) |
|---|---|---|
| 1 vCPU | $47.30 · **Rp 875.124** | $63.07 · **Rp 1.166.832** |
| 1 GiB RAM | $5.26 · **Rp 97.236** | $6.57 · **Rp 121.545** |

So a rupiah rule of thumb: **each always-on vCPU on Cloud Run is roughly Rp 875 ribu/bulan, each GiB of RAM
roughly Rp 100 ribu/bulan.** Size the container and you can price it in your head.

API Gateway WebSocket (needed for any Lambda realtime path): **$1.00 / M messages · Rp 18.500 / juta**
(metered in 32 KB increments) + **$0.25 / M connection-minutes · Rp 4.625 / juta**.

### 3.2 Always-on single instance — the honest apples-to-apples

Because §2 means your instance is always active:

| Configuration | Monthly (USD) | Monthly (IDR) |
|---|---:|---:|
| **EC2 `t4g.small`** (2 vCPU burst / 2 GiB) + 20 GB gp3 + IPv4 | **$17.51** | **Rp 324.009** |
| **EC2 `t3.small`** (2 vCPU burst / 2 GiB) + 20 GB gp3 + IPv4 | **$20.43** | **Rp 378.029** |
| Cloud Run 0.5 vCPU / 512 MiB, instance-based | $21.06 | Rp 389.610 |
| Cloud Run 0.5 vCPU / 512 MiB, request-based | $30.00 | Rp 555.019 |
| **Cloud Run 1 vCPU / 1 GiB, instance-based** | **$47.34** | **Rp 875.790** |
| Cloud Run 1 vCPU / 1 GiB, request-based (3 juta req) | $64.82 | Rp 1.199.207 |
| Cloud Run 1 vCPU / 2 GiB, instance-based | $52.60 | Rp 973.026 |
| Cloud Run 2 vCPU / 2 GiB, instance-based | $99.90 | Rp 1.848.150 |

EC2 line items: `t3.small` $15.18 · Rp 280.904 compute + $1.60 · Rp 29.600 for 20 GB gp3 + $3.65 · Rp 67.525
for the public IPv4 address (AWS began charging $0.005/hr for all public IPv4 in Feb 2024 — easy to forget).

**The honest number: a like-for-like Cloud Run instance (1 vCPU / 1 GiB) costs ~2.3× your current EC2 box —
Rp 875.790 vs Rp 378.029 per month.** The gap is **Rp 497.761/bulan**, or **Rp 5.973.132 per year** — call it
**~Rp 6 juta annually** for the same application doing the same work.

You *can* get to parity at 0.5 vCPU / 512 MiB ($21.06). You should not want to. That is half a core and 512 MB
for a Node process that renders PDFs with `pdfkit` and spreadsheets with `exceljs` — and on Cloud Run the
writable filesystem is **tmpfs backed by the memory limit**, so every byte of a generated report counts against
that 512 MB. One large multi-church export OOM-kills the instance, which on Cloud Run means every WebSocket
client attached to it drops simultaneously.

### 3.3 Scale-out — where the gap widens

The premium is multiplicative, not fixed:

| Instances (1 vCPU / 1 GiB) | Cloud Run | Equivalent EC2 `t3.small` |
|---|---:|---:|
| 1 | $47.34 · Rp 875.790 | $20.43 · Rp 378.029 |
| 2 | $99.90 · Rp 1.848.150 | $40.87 · Rp 756.058 |
| 3 | $152.46 · Rp 2.820.510 | $61.30 · Rp 1.134.087 |
| 5 | $257.58 · Rp 4.765.230 | $102.17 · Rp 1.890.145 |
| 10 | $520.38 · **Rp 9.627.030** | $204.34 · Rp 3.780.290 |

At ten instances you are paying **nearly Rp 10 juta/bulan** for compute alone — Rp 5,8 juta/bulan more than the
EC2 equivalent, before Redis or egress.

And multi-instance Cloud Run **forces Redis** (§4.4), which is a new line item:
Memorystore Basic M1 is ~$0.049/GiB-hr ≈ **$36/mo · Rp 666.000** for 1 GiB with no free tier. Upstash
serverless Redis is the pragmatic alternative — free at 256 MB / 500 ribu commands/mo, then $0.20 · Rp 3.700
per 100 ribu commands. Socket.IO's Redis adapter is *chatty* (every cross-instance emit is a pub/sub round
trip), so model the command count honestly before assuming the free tier holds.

### 3.4 The scale-to-zero case that does not apply to you

For completeness — if this were a plain REST API with no sockets, and traffic ran 8 hours a day:

| | Monthly (USD) | Monthly (IDR) |
|---|---:|---:|
| Cloud Run 1 vCPU / 1 GiB, request-based, 33% active | $18.39 | Rp 340.289 |
| Cloud Run 0.5 vCPU / 512 MiB, request-based, 33% active | $6.79 | **Rp 125.560** |

That **Rp 125 ribu/bulan** is the number Cloud Run marketing is selling you — one third of the EC2 bill, not
2,3×. **Your open WebSockets are what stand between you and it.**

Moving the realtime layer to a managed service flips these economics. **§10 works that option through in
full** — including the finding that 166 of the 166 socket RPC actions are not realtime at all, and a correction
to the Pusher Channels suggestion originally made here (it costs more than the problem; use FCM, which is free
and already in your dependency tree).

### 3.5 Lambda, priced for completeness

Assumes API Gateway WebSocket, 2 hrs/day connected per user, 150 ms and 1 GB per RPC invocation:

| Users | Conn-minutes | Messages | Invoke | Duration | **Total (USD)** | **Total (IDR)** |
|---|---|---|---|---|---:|---:|
| 200 | 0,7 juta → $0.18 | 0,7 juta → $0.72 | $0.00 | $0.00 | **$0.90** | **Rp 16.650** |
| 4.000 | 14,4 juta → $3.60 | 24 juta → $24.00 | $4.60 | $53.33 | **$85.53** | **Rp 1.582.369** |
| 40.000 | 144 juta → $36.00 | 240 juta → $240.00 | $47.80 | $593.33 | **$917.13** | **Rp 16.966.989** |

Note the shape: at small scale Lambda is nearly free; at real scale it is **the most expensive option by far**,
and the cost is dominated by **per-message** charges — which is precisely the wrong pricing axis for a
chatty RPC-over-socket protocol. Every `reportJob.updated` progress tick, every room broadcast, is a billable
message. At 40 ribu users you would be paying **~Rp 17 juta/bulan to run what a Rp 378 ribu EC2 box runs
today** — a **45× increase** — after paying for a full rewrite of the realtime layer.

**Lambda is the worst option for this workload on both cost and effort. Please drop it from consideration.**

### 3.6 Costs nobody puts in the comparison table

| Item | Impact |
|---|---|
| **Cross-cloud egress to Supabase** | Supabase runs on AWS. Cloud Run → Supabase means every Prisma query leaves GCP over the internet: **~$0.085–0.12/GiB · Rp 1.572–2.220 per GiB**, plus ~5–15 ms added per round trip vs. same-region. Chatty ORM patterns (N+1s in `report.service.ts` loops) multiply this. Today, EC2 in the same region as Supabase pays neither. |
| **Artifact Registry** | ~$0.10/GB-month · **Rp 1.850/GB-bulan**. A NestJS + pnpm image is 300–600 MB; keeping 20 revisions is real storage. |
| **Cloud Build** | 120 free build-minutes/day, then $0.003/min · Rp 56/menit. Probably free for you. |
| **Egress to mobile clients** | GCP premium tier ~$0.12/GiB · **Rp 2.220/GiB** to APAC. AWS gives 100 GB/mo free then $0.09/GiB · **Rp 1.665/GiB**. GCP is more expensive here *and* has a smaller free allowance — for a mobile app shipping reports and images this is a genuine recurring difference. |
| **Migration labour** | See §4. Realistically 3–6 engineer-days minimum, more if you scale past one instance. At any plausible Indonesian senior-dev day rate this dwarfs the first year of infrastructure difference in either direction. |
| **A second cloud to operate** | Two IAM models, two billing consoles, two audit trails, two on-call runbooks, two sets of credentials to rotate. For a team this size that is a permanent, recurring tax. |

### 3.7 The rupiah figures carry FX risk that the dollar figures do not

Every number in this document is **billed in USD**. Google Cloud and AWS invoice in dollars; the rupiah column
is a conversion at an assumed Rp 18.500/USD, not a price anyone has quoted you.

That matters more than it sounds for this project. If the app is funded in rupiah — church budgets,
congregational contributions, a local sponsor — then **your revenue is IDR and your infrastructure cost is
USD**. Every 1% the rupiah weakens raises your real hosting bill by 1%, with no action on your part and no
warning. Over the past several years IDR/USD has moved by well more than 10% within single years.

Applied to the decision:

| Scenario at Rp 18.500 | +10% IDR weakening (Rp 20.350) |
|---|---|
| EC2 `t3.small` — Rp 378.029/bulan | Rp 415.832/bulan (+Rp 37.803) |
| Cloud Run 1 vCPU/1 GiB — Rp 875.790/bulan | Rp 963.369/bulan (+Rp 87.579) |

**FX exposure scales with the size of the bill.** Choosing the 2,3× more expensive platform also means taking
2,3× the currency risk on the same workload. This is not an argument against Cloud Run by itself — it is an
argument for not carrying more USD-denominated cost than the technical case actually justifies.

Two practical notes: budget in IDR with **headroom of at least 10–15%** rather than converting at today's
spot rate, and set a **billing budget alert in USD** (both clouds support this) so a currency move or a traffic
spike surfaces before the invoice does.

---

## 4. Drawbacks and blockers, specific to this codebase

These are the things that will actually bite. Ordered by severity.

### 4.1 🔴 The report queue will double-process jobs on any multi-instance deployment

`ReportQueueService.processQueue` guards with `private isProcessing = false` — **a per-process variable**. Two
Cloud Run instances have two separate booleans. Then the claim is non-atomic: `findFirst({status: PENDING})`
followed by a separate `update`. Two instances polling the same 10-second tick will both read the same PENDING
job, both mark it PROCESSING, and both render it. The user gets duplicate reports, you pay twice for the CPU,
and any downstream side-effect (Pusher notification, file write) fires twice.

**This is a latent data-correctness bug that only manifests when you scale out.** Today EC2 hides it by
running exactly one process. Cloud Run's autoscaler removes that protection silently and without warning.

Fix: atomic claim.
```sql
UPDATE "ReportJob" SET status = 'PROCESSING'
WHERE id = (SELECT id FROM "ReportJob" WHERE status = 'PENDING'
            ORDER BY "createdAt" LIMIT 1 FOR UPDATE SKIP LOCKED)
RETURNING *;
```
Or move the queue out of the request-serving process entirely (Cloud Tasks → a Cloud Run Job).

### 4.2 🟢 Cron jobs fire N times on N instances — but the birthday job already defends itself

`@Cron('0 7 * * *')` in `birthday-notification.service.ts` runs on **every** instance, so with three instances
the job body executes three times at 07:00. **This one is safe**, and deliberately so:

- `schema.prisma:677` — `dedupeKey String? @unique` on `Notification`.
- The service builds `member-birthday:{churchId}:{recipientId}:{membershipId}:{dateKey}`, calls
  `notification.create` **first**, catches Prisma `P2002` (unique violation) and `continue`s, and only sends
  the Pusher push **after** the insert succeeds.

That is a correct database-backed idempotency guard. Duplicate pushes are prevented. Credit where due — this
is the pattern §4.1 is missing.

One residual, mildly amplified by Cloud Run: the `create` and the `publishToInterests` are not atomic. If the
process dies in that window the dedupe row blocks any retry and the push is lost silently (at-most-once
delivery). On EC2 the process rarely dies mid-job; on Cloud Run instances are terminated on scale-down and on
every revision rollout, so the window gets hit more often. Low severity, worth knowing.

**Note the asymmetry: `@Cron` duplication is a real hazard in general — the birthday job survives it only
because someone thought about idempotency there. Nobody thought about it in the report queue (§4.1).**

### 4.3 🔴 On request-based billing, your cron jobs silently stop

Cloud Run's request-based model throttles CPU to near-zero outside of request handling. A `@Cron` timer is not
a request. Your 10-second queue poller and your 07:00 notification job **will not fire reliably** — they will
fire only opportunistically when a request happens to be in flight. No error, no alert, just reports that never
finish.

Mitigation: **instance-based billing** (CPU always allocated) + `min-instances ≥ 1`. Which is exactly the
configuration that costs $47/mo and is not serverless. This is the crux of the whole analysis: *the
configuration that makes Cloud Run cheap is the configuration that breaks this app.*

### 4.4 🟠 Socket.IO's polling upgrade needs sticky sessions; Cloud Run affinity is best-effort

Google's docs are explicit: *"Session affinity on Cloud Run provides best effort affinity, new WebSockets
requests could still potentially connect to different instances, due to built-in load balancing."*

Socket.IO's default transport sequence is HTTP long-polling → upgrade to WebSocket, and the polling handshake
**requires** every request in the handshake to reach the same process. Best-effort affinity means intermittent,
hard-to-reproduce connection failures. Your gateway sets `allowEIO3: true`, which implies you're supporting
older clients that may not skip polling.

Mitigations: force `transports: ['websocket']` on the Flutter client (skips polling entirely — recommended,
and cheap), **and** enable session affinity, **and** ship the Redis adapter. All three.

### 4.5 🟠 Hard 60-minute cap on every WebSocket connection

Cloud Run treats a WebSocket as an HTTP request, so it is bound by the request timeout: **default 5 minutes,
maximum 60 minutes**. Your current Nginx setup has no such ceiling. Every client is force-disconnected at least
hourly, forever.

Socket.IO reconnects automatically, and `handleConnection` re-runs `auth.attach` from the handshake token, so
the happy path should survive. But: any per-connection server-side state in `RpcRouterService` is discarded on
`onDisconnect`, room memberships must be rebuilt, and in-flight RPCs at the moment of cutoff are lost. **You must
raise the timeout from the 5-minute default to 3600s explicitly** — otherwise you get a disconnect storm every
five minutes.

### 4.6 🟠 Prisma connection pool × autoscaling = Supabase connection exhaustion

`PrismaService` constructs `new Pool({ connectionString })` with **no `max`**, so it takes `pg`'s default of
10 connections **per instance**. Cloud Run's default max-instances is high. Scale to 20 instances and you are
asking Supabase for 200 connections; Supabase's smaller tiers cap well below that.

Fixes: set `max` explicitly (2–5), route through Supabase's transaction pooler on port 6543, and set
`max-instances` to something you have actually reasoned about. Note the transaction pooler requires
`?pgbouncer=true` and disables prepared statements — verify your Prisma queries tolerate that before cutover,
not after.

### 4.7 🟡 The tmpfs trap

Cloud Run's writable filesystem is **in-memory** and counts against the memory limit. `report-renderer.ts`
and the file-upload paths in `rpc-router.service.ts` (`createWriteStream`) need auditing: any temp file is RAM.
Size the instance for peak-report-size + Node heap, not for steady state. This is the most common way teams
get surprise OOM kills on Cloud Run.

### 4.8 🟠 PDF fonts will silently degrade on a slim container base image

This is the sharpest container-specific trap in the codebase. `report-renderer.ts:7-14` resolves a Unicode font
by probing a candidate list, in order:

```ts
const UNICODE_FONT_CANDIDATES = [
  '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
  '/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf',
  '/usr/share/fonts/noto/NotoSans-Regular.ttf',
  '/System/Library/Fonts/Supplemental/Arial Unicode MS.ttf',
  '/System/Library/Fonts/Helvetica.ttc',
  path.join(__dirname, '../../assets/fonts/NotoSans-Regular.ttf'),
];
// ...
if (fs.existsSync(candidate)) return candidate;   // else → undefined
```

The first five are **absolute host paths**. On Ubuntu EC2, `fonts-dejavu-core` is usually present, so candidate
#1 resolves and everything works. On `node:20-slim`, `alpine`, or distroless — the natural Cloud Run base
images — **none of them exist.**

And the in-repo fallback does not save you: `find apps/palakat_backend -name '*.ttf'` returns **nothing**.
There is no font in the repository. `resolveUnicodeFontPath()` returns `undefined` and PDF rendering falls back
to a non-Unicode core font, **with no error and no log line**. Most Indonesian text is Latin-1 and will look
fine, which is exactly what makes this dangerous — it will pass a smoke test and mangle glyphs in production
later.

Fix: `apt-get install -y fonts-dejavu-core` in the Dockerfile, **or** commit the TTF to
`src/assets/fonts/` — the latter works because `nest-cli.json` already declares `"assets": ["assets/**/*"]`, so
`nest build` will copy it. (Contrary to what you might expect, asset copying is **already configured
correctly** here; the gap is that the font file itself was never added.) Either way, add a startup assertion so
a missing font fails loudly instead of degrading silently.

### 4.9 🟡 There is no Dockerfile, and the monorepo makes it non-trivial

`apps/palakat_backend` has a `docker-compose.yaml` (local Postgres only) and no application Dockerfile. You
need a multi-stage build handling pnpm workspace hoisting (the release needs `pnpm-workspace.yaml` and
`pnpm-lock.yaml` from the repo root) and `prisma generate`. Prisma 7 with `@prisma/adapter-pg` means no Rust
query-engine binary to wrangle, which makes this meaningfully easier than it would have been on Prisma 5/6.

Also: `prisma migrate deploy` must **not** run at container start, or every scaled instance races to migrate.
It belongs in a Cloud Build step or a one-shot Cloud Run Job.

### 4.10 🟡 Ecosystem friction

- **Health checks**: `/health` requires `HEALTH_PAGE_SECRET` via header. Cloud Run startup/liveness probes can
  send headers, but this must be configured deliberately or your service never reports healthy.
- **`INVOCATION_ID`**: `app.module.ts` keys `ignoreEnvFile` off this systemd-specific variable. Harmless on
  Cloud Run (`NODE_ENV=production` covers it) but it is a small sign of how much systemd-shaped assumption is
  in the config.
- **Firebase Admin + Pusher Beams**: both fine on GCP, and Firebase Admin is arguably *better* on GCP
  (workload identity instead of a `FIREBASE_PRIVATE_KEY` env var). Small genuine win.
- **CI/CD**: the existing GitHub Actions workflow (scp a tarball + ssh + `systemctl restart`) is thrown away
  entirely. Cloud Run's replacement is simpler, but it is still a rewrite plus Workload Identity Federation
  setup between GitHub and GCP.

---

## 5. Performance comparison

| Dimension | EC2 (current) | Cloud Run | Lambda + API GW WS |
|---|---|---|---|
| **Cold start** | None. Process is always resident. | 2–5 s for NestJS bootstrap + Prisma init + Redis connect. Avoidable with `min-instances ≥ 1` — which you need anyway. Startup CPU boost helps. | 1–3 s. Prisma 7's driver adapter (no Rust engine binary) helps a lot here vs. older Prisma. |
| **Steady-state latency** | Best. Warm process, warm pool, warm Prisma client. | Equal to EC2 once warm — same container, same code. | Worse. Per-invocation overhead on every RPC message. |
| **DB round-trip** | Same-region as Supabase (if configured per the guide) → ~1–2 ms. | Cross-cloud → **+5–15 ms per query**. Compounds badly in loops. | Same as Cloud Run, plus pooling overhead. |
| **WebSocket stability** | Excellent. Only bounded by Nginx config. | Capped at 60 min, best-effort affinity, drops on every scale-down and every revision deploy. | Managed by API Gateway; most stable of the three, but Socket.IO protocol doesn't run on it. |
| **Burst handling (Sunday 09:00)** | ⚠️ **Weakest point.** `t3.small` is burstable — sustained load drains CPU credits and the box throttles to 20% baseline. This is a real risk for a church app with a hard weekly peak. | ✅ **Strongest point.** Autoscales in seconds. | ✅ Scales, at a price. |
| **Report generation (CPU-bound)** | Burst credits drain under load. | Full dedicated vCPU per instance, no credit system. Better. | 15-min ceiling; large exports at risk. |
| **Deploy** | `systemctl restart` = brief downtime, all sockets drop. | Zero-downtime revision rollout, traffic splitting, instant rollback. Sockets on the old revision still drop. | Per-function, near-instant. |
| **Zonal redundancy** | ❌ Single instance, single AZ. **One AZ outage = full outage.** | ✅ Built in by default. | ✅ Built in. |

### The two performance arguments that genuinely favour Cloud Run

1. **Burst.** A church app has the sharpest imaginable weekly traffic curve: near-zero all week, hard spike on
   Sunday morning. `t3.small` burst credits are exactly the wrong instrument for that shape — you can drain
   credits mid-service and throttle to 20% CPU at your single most important moment. Cloud Run scales
   horizontally through it without thinking. **This is the strongest technical case for the migration and it
   has nothing to do with cost.**
2. **Redundancy.** Your current architecture is one EC2 instance in one availability zone. Cloud Run is
   zonally redundant by default. Going from "one box" to "managed multi-zone" is a real availability upgrade
   you cannot buy on EC2 for $27/mo.

### The performance argument that favours staying

Steady-state p50/p99 will be **the same or slightly worse** on Cloud Run, because it is the same container
running the same code — plus 5–15 ms of cross-cloud latency on every single database query. Nothing about
Cloud Run makes warm requests faster.

---

## 6. Honest pushback

You asked for it, so here it is, unhedged.

**1. The stated motivation is missing.** "Port to Cloud Run instead of AWS" is a statement about
infrastructure, not about a problem. Nothing in this analysis can tell you whether to migrate, because the
answer depends entirely on *why* — and the "why" is not in the request. If it is cost: **Cloud Run is 2,3×
more expensive** for your workload (**Rp 875.790 vs Rp 378.029/bulan, ~Rp 6 juta/tahun extra**), so the answer
is no. If it is ops burden: yes, and read §7. If it is Sunday-morning burst capacity or single-AZ risk: yes,
and those are good reasons. If it is "serverless is modern": that is not a reason, and your open WebSockets
mean you would not even be serverless.

**2. Scale-to-zero — the entire reason to pick Cloud Run — does not apply to you.** One user with the app open
pins an instance active. You will pay for a 24/7 container with serverless pricing on top of it, which is the
worst of both models. You would be adopting a serverless platform and then configuring every serverless
property out of it (`min-instances=1`, instance-based billing, 3600s timeout, session affinity).

**3. Your architecture has a single-instance assumption that Cloud Run will break silently.** §4.1 is a real
correctness bug — duplicate report processing — masked today only by the fact that exactly one process runs.
Cloud Run's autoscaler removes that mask *without any signal*: no error, no log, just a user receiving two
reports and you paying twice for the CPU. The birthday cron (§4.2) shows the team already knows how to write
an idempotency guard; the report queue simply never got one. **If you take nothing else from this document:
fix the job-claim race before you scale to two of anything, on any platform.**

**4. Migrating compute while leaving the database on Supabase/AWS makes the split worse, not better.** Today
your app and DB are one region apart at most. After migration every Prisma query is a cross-cloud internet hop
with per-GiB egress attached. You would be *adding* a network boundary in the hottest path in the system in
order to remove one you never complained about.

**5. Lambda should not be on the list at all.** It cannot run this app, and if you rewrote the app to fit it,
per-message pricing on a chatty RPC socket protocol produces **Rp 17 juta/bulan at 40 ribu users** vs. Rp 378
ribu today — a 45× increase. It is the most expensive option on both axes — build and run.

**6. The cheapest correct answer is probably not a migration.** If the pain is Sunday burst, `t3.medium` costs
**$35.62 · Rp 658.933/bulan** all-in and buys headroom today with zero migration risk — still cheaper than
Cloud Run at 1 vCPU/1 GiB (Rp 875.790), and it is a console dropdown, not a project. If the pain is single-AZ
risk, an ALB plus a second EC2 instance costs less than the Cloud Run equivalent — though it hits the same
§4.1 bug, which tells you that bug is the real blocker, not the platform. **The multi-instance work is the
same work regardless of cloud.** Do it first, then choose a platform from a position where all the options
actually work.

**7. Your costs are in USD but your funding probably is not.** See §3.7 — picking the 2,3× more expensive
platform also means carrying 2,3× the currency exposure on the same workload, permanently.

**8. Two clouds is a permanent tax on a small team.** You would run compute on GCP, data on Supabase/AWS, push
on Pusher, and mobile builds on Codemagic. Every incident starts with "which console?" That cost never shows up
in a pricing table and never goes away.

**9. The whole decision is worth less than you think.** The spread between the cheapest and most expensive
*viable* option here is roughly **Rp 500 ribu/bulan** — about **Rp 6 juta/tahun**. Real money for a church
app, but also less than a week of engineering time. Do not spend a month optimising a Rp 6 juta/tahun
decision. Pick on the technical merits (burst, redundancy, ops load), budget the difference with FX headroom,
and move on. **The one thing genuinely worth engineering time here is the §4.1 job-claim race** — that is a
correctness bug, and correctness bugs do not get cheaper by waiting.

---

## 7. If you migrate anyway — the lazy path that works

Migrating is defensible. §5's burst and redundancy arguments are real. But do it in the order that avoids every
blocker in §4:

### Phase 1 — Lift and shift, `max-instances=1`

- Write the multi-stage Dockerfile (§4.9), and **install `fonts-dejavu-core` or commit the TTF** (§4.8) — this
  is the one thing that will break silently rather than loudly.
- Deploy with **`min-instances=1`, `max-instances=1`, instance-based billing, timeout 3600s.**
- **Zero code changes required.** One instance means: the `isProcessing` latch is still correct, cron fires
  exactly once, the in-memory Socket.IO adapter is still valid, no Redis needed.
- Run migrations from a separate Cloud Build step, never at container start.
- **Cost: ~$21–47/mo · Rp 390 ribu – 876 ribu/bulan** depending on sizing. Against Rp 378 ribu on EC2 today,
  the premium runs from roughly **nothing to Rp 500 ribu/bulan**. You are paying it to delete SSH keys,
  systemd, Nginx, TLS renewal, and OS patching from your life. **For a one-person ops team that is a
  defensible trade — just make the trade knowingly.**
- What you get immediately: zero-downtime deploys, instant rollback, zonal redundancy, managed TLS, built-in
  logging. What you do *not* get yet: burst scaling. Which was one of your two good reasons. Hence phase 2.

### Phase 2 — Earn the right to scale out

Only after all of these are done and tested:

1. Atomic job claim in `ReportQueueService` (`FOR UPDATE SKIP LOCKED`) — §4.1. **This is the one that matters.**
2. Ship Redis (Upstash first; Memorystore only if command volume justifies $36/mo · Rp 666.000) and make the
   Socket.IO adapter mandatory, not optional — §4.4.
3. Force `transports: ['websocket']` in the Flutter client; enable session affinity — §4.4.
4. Bound the Prisma pool (`max: 3`), move to the Supabase transaction pooler, verify prepared-statement
   compatibility — §4.6.
5. Audit tmpfs usage in report rendering and file upload — §4.7.

The birthday cron (§4.2) needs no work — it is already idempotent. Sweep any *future* `@Cron` for the same
guarantee.

Then raise `max-instances`. **Costs scale linearly and steeply — $47 · Rp 876 ribu per always-on instance — so
set the ceiling deliberately, not at the default.** A runaway `max-instances` on Cloud Run is how a
Rp 876 ribu/bulan service quietly becomes a Rp 10 juta/bulan one.

### Phase 3 — Optional, and the actual prize

Move the realtime layer off your own process so sockets stop pinning instances active, and Cloud Run can finally
scale to zero.

**This phase is worked through in detail in §10**, which was added after the first draft in response to the
follow-up question *"can the realtime transactions be moved to serverless functions?"* Two corrections to what
this section originally said:

- **Not via Cloud Functions.** Cloud Functions 2nd gen *is* Cloud Run and inherits the same
  billed-while-connected rule (§10.1). No serverless platform holds connections cheaply.
- **Not via Pusher Channels.** At Rp 906.500/bulan it costs more than the Cloud Run bill it would eliminate
  (§10.5). **Use FCM** — free, unlimited, and `firebase-admin` is already wired.

The genuinely good news from §10: only **10 push call sites** are truly realtime; the other 166 RPC actions are
CRUD, and `rpc-router.service.ts` is a pure adapter over the same service layer the 27 REST controllers already
use. The blocker is permission parity between the two transports (§10.4), not the transport swap itself.

---

## 8. Sources

Rates verified 2026-07-21.

- [Cloud Run pricing](https://cloud.google.com/run/pricing) — CPU/memory/request rates, instance-based vs. request-based, free tiers, idle min-instance rate
- [WebSockets on Cloud Run](https://docs.cloud.google.com/run/docs/triggering/websockets) — the billing quote in §2, session affinity, multi-instance coordination, HTTP/2 incompatibility
- [Cloud Run request timeout](https://docs.cloud.google.com/run/docs/configuring/request-timeout) — 5 min default, 60 min maximum
- [Cloud Run instance autoscaling](https://docs.cloud.google.com/run/docs/about-instance-autoscaling) — scale-to-zero, 15-min idle retention, <10% utilization shutdown
- [AWS Lambda pricing](https://aws.amazon.com/lambda/pricing/) — GB-second model, 1M req + 400k GB-s free tier
- [Amazon API Gateway pricing](https://aws.amazon.com/api-gateway/pricing/) — WebSocket $1.00/M messages (32 KB increments), $0.25/M connection-minutes
- [EC2 On-Demand pricing](https://aws.amazon.com/ec2/pricing/on-demand/) — T-family rates and Unlimited-mode credit charges
- [Memorystore for Redis pricing](https://cloud.google.com/memorystore/docs/redis/pricing) — Basic M1 tier
- [Upstash Redis pricing](https://upstash.com/pricing) — serverless free tier and per-command rates
- [Cloud Run functions version comparison](https://docs.cloud.google.com/functions/docs/concepts/version-comparison)
  — the §10.1 quote that 2nd-gen functions deploy as Cloud Run services; 60-min HTTP / 9-min event timeouts
- [Firebase pricing](https://firebase.google.com/pricing) — FCM free and unlimited; Firestore read pricing
  ($0.06 per 100k reads, 50k/day free) used in §10.5
- [Pusher Channels pricing](https://pusher.com/channels/pricing/) — Sandbox 100 concurrent connections, paid
  tiers from $49/mo, fan-out counted per delivered message (§10.5)
- Lambda per-GB-second figures ($0.0000166667 x86 / $0.0000133334 Arm) cross-checked against
  [CloudZero's 2026 Lambda pricing guide](https://www.cloudzero.com/blog/lambda-pricing/) because AWS renders
  its own rate tables in JavaScript and they are not machine-readable.
- Repo evidence: `docs/palakat-backend-aws-ec2-cicd-deployment-guide.md`, `src/realtime/*`,
  `src/report/report-queue.service.ts`, `src/notification/birthday-notification.service.ts`,
  `src/prisma.service.ts`, `src/app.module.ts`, `package.json`.

---

## 9. Bottom line

| Question | Answer |
|---|---|
| Are we on Lambda today? | No. Single EC2 + Supabase. |
| Can this app run on Lambda? | No — not without rewriting the realtime layer, the job queue, and the cron jobs. |
| Is Cloud Run cheaper than what we run now? | **No. ~2,3× more** — **Rp 875.790 vs Rp 378.029/bulan**, ~**Rp 6 juta/tahun** extra — because open WebSockets defeat scale-to-zero. |
| Is Cloud Run cheaper than Lambda? | Yes, dramatically, at any scale that matters. |
| Is Cloud Run faster? | Same steady-state, **worse** DB latency (cross-cloud), **much better** burst handling. |
| Is there a good reason to migrate? | Yes: Sunday-morning burst capacity, zonal redundancy, and deleting server ops. **None of them is cost.** |
| What should we do first, regardless? | **Fix the report-queue job-claim race (§4.1).** It blocks multi-instance on *any* platform, including a second EC2 box. The birthday cron is already idempotent and needs nothing. |
| Recommended path if migrating | Phase 1: lift-and-shift at `max-instances=1`, zero code changes, **Rp 390–876 ribu/bulan**. Earn multi-instance later. |
| Cheapest fix if the real pain is Sunday burst | `t3.medium` — **Rp 658.933/bulan**, a console dropdown, no migration. |
| Budgeting caveat | Bills are in USD. Budget IDR with **10–15% headroom** and set a USD billing alert (§3.7). |
| Can we delete the WebSocket and go serverless? | Mostly yes — see §10. **Not** by moving it to Cloud Functions (those *are* Cloud Run). By deleting it: 166 of your 166 RPC actions are CRUD, not realtime. |

---

## 10. Follow-up: can we drop the WebSocket and move realtime to serverless functions?

Asked after the first draft. Short answer: **the "serverless functions" half of the idea does not work, but the
"drop the WebSocket" half does — and it is far more achievable than §7 Phase 3 implied.** Two separate claims,
so take them separately.

### 10.1 ❌ Moving realtime to serverless functions solves nothing — Cloud Functions *is* Cloud Run

From [Google's own version-comparison doc](https://docs.cloud.google.com/functions/docs/concepts/version-comparison):

> **"By deploying functions directly onto Cloud Run, your functions are automatically built as containers and
> deployed as a Cloud Run service."**

Cloud Functions 2nd gen is a packaging convenience on top of Cloud Run. Same runtime, same billing model, same
60-minute HTTP ceiling, and — decisively — **the same §2 rule: an instance holding an open WebSocket is billed
as active.** Moving the gateway into a "function" relocates the invoice, not the cost.

Generalise it, because this is the part worth internalising: **no serverless compute platform lets you hold a
connection cheaply.** Serverless bills for resident time; a held connection *is* resident time. Cloud Run,
Cloud Functions, Lambda + API Gateway (§3.5, and there the connection-minutes are itemised on the bill) — all
three charge you for it, just on different line items.

The only way to stop paying to hold connections is **to stop holding them yourself** and delegate to a service
whose entire business model is holding connections. Which leads to the half that does work.

### 10.2 ✅ 166 of your 166 RPC actions are not realtime

This is the finding that changes the answer. `rpc-router.service.ts` dispatches **166 actions**. Sampling the
list:

```
account.list      church.create     finance.get        cashAccount.update
activity.delete   column.list       document.generate  approvalRule.create
membership.get    articles.like     expense.update     file.upload.chunk
```

These are **CRUD request/response**. Nothing about them requires a persistent connection — it is REST wearing
a socket costume. A request goes up, a response comes back, the exchange is over.

The genuinely realtime surface — server pushing to a client that did not ask — is **10 `emitToRoom` call sites**
in three categories:

| Category | Sites | Events |
|---|---|---|
| Notifications | `notification.service.ts` ×3 | `notification.created/updated/deleted` |
| Entity lifecycle | `rpc-router.service.ts` ×2 | `activity.*`, `finance.*`, `approval.*` — in-app banners for admins |
| Report job progress | `report-queue.service.ts` ×5 | `reportJob.created/updated/…` progress ticks |

**Ten push points are holding an entire always-on billing model hostage.** That is the whole problem, stated
precisely.

### 10.3 ✅ The refactor is much cheaper than it looks — you already have two transports over one brain

The decisive structural fact:

```
$ grep -c 'this.prisma\.'            rpc-router.service.ts   →   0
$ grep -cE 'this\.[a-zA-Z]+Service\.' rpc-router.service.ts   →   143
```

**Zero direct database calls. 143 service delegations.** `RpcRouterService` is a *pure transport adapter* — it
authenticates, checks permissions, normalises pagination, and hands off to the service layer. Compare a case
body against the equivalent controller:

```ts
// rpc-router.service.ts:2070
case 'finance.list': {
  const { user } = await this.requireAnyOperationPermission(client, [...]);
  const query = this.withPagination(payload) as any;
  const res: any = await this.financeService.findAll(query, user);
  return this.normalizePaginatedList(query, res);
}

// finance.controller.ts — same service, same method
@Get()
async findAll(@Query() query: FinanceListQueryDto, @Req() req: any) {
  return this.financeService.findAll(query, req.user);
}
```

Your architecture is already:

```
Socket RPC  ──┐
              ├──►  Service layer (all business logic)  ──►  Prisma
REST HTTP   ──┘
```

**27 REST controllers already exist**, covering the same domains. Dropping the socket is therefore a *transport
swap*, not a rewrite of business logic. The backend keeps every service untouched.

### 10.4 🔴 The landmine: your two transports are not at permission parity

Look at that comparison again. The RPC path calls `requireAnyOperationPermission(client, ['ops.finance.revenue.create',
'ops.finance.expense.create', 'ops.approval.finance'])`. The REST path has `@UseGuards(AuthGuard('jwt'))` and
**nothing else** — any authenticated user reaches `financeService.findAll`.

**The REST surface is less protected than the RPC surface.** If you point the Flutter client at the existing
controllers as-is, you ship a privilege-escalation bug across the finance module and probably others.

This is the actual work in this migration, and it is not transport plumbing:

1. Extract `requireAnyOperationPermission` / `requireUserId` into a reusable Nest **guard** (`@RequirePermissions('ops.finance.…')`).
2. Extract `withPagination` / `normalizePaginatedList` into an **interceptor** — you already have
   `PaginationInterceptor` registered globally in `main.ts`, so check for overlap before adding a second one.
3. Bring every controller to parity with its RPC counterpart, action by action, **auditing all 166** rather than
   assuming the controller is equivalent.
4. Only then repoint the client.

Do not skip step 3 because the controllers "already exist." They exist; they are not equivalent.

### 10.5 Which push transport — and *not* the one this document recommended earlier

§3.4 and §7 Phase 3 suggested Pusher Channels on the grounds that you already pay Pusher for Beams. **Running
the numbers, that advice was wrong.** Correcting it:

| Option | Cost at 4.000 users | Verdict |
|---|---:|---|
| **FCM** (Firebase Cloud Messaging) | **Rp 0** | ✅ Free, unlimited, no per-message fee. `firebase-admin` is **already wired** (`firebase-admin.service.ts` uses `auth()` and `storage()`); you just never called `messaging()`. No new vendor. |
| Firestore listeners | ~Rp 23.310 | Workable. 50 ribu reads/day free, then $0.06 · Rp 1.110 per 100 ribu reads. Adds a data model you don't have. |
| Pusher Channels (Sandbox) | Rp 0 | ❌ **100 concurrent connections.** Unusable past ~100 simultaneous users. |
| Pusher Channels (paid) | **Rp 906.500** | ❌ **Worse than the problem.** Paying Rp 906 ribu/bulan to avoid Rp 876 ribu/bulan of Cloud Run is a net loss — and fan-out counts against your quota (1 message to 50 subscribers = 51 messages). |
| Ably | ~Rp 460 ribu est. | Consumption-based, no daily cap, better SLA. Cheaper than Pusher, still a new vendor for something FCM does free. |

**Take FCM.** It costs nothing, it is already in your dependency tree, and it is the same channel your Pusher
Beams notifications are ultimately delivered over anyway.

One honest caveat: **FCM data messages are best-effort.** The OS may delay or batch them — Android Doze, iOS
background throttling. That is fine for notifications and admin banners. It is *not* fine for the report-progress
ticks, which want sub-second liveness while the user watches a modal.

Solve that one differently and trivially: **poll `GET /report-jobs/:id` every 2 seconds while the progress modal
is open.** Report generation is rare, user-initiated, and short. A handful of polls for 30 seconds occasionally
is nothing — and it deletes the only category that genuinely wanted a live channel.

So the mapping is:

| Realtime category | Replacement |
|---|---|
| `notification.*` | FCM data message |
| `activity.*` / `finance.*` / `approval.*` banners | FCM data message, or refetch-on-focus |
| `reportJob.*` progress | Short-lived polling while the modal is open |

### 10.6 What it costs — including the part that gets *more* expensive

Once sockets are gone, Cloud Run's bill is driven by **active instance-hours**, not by user count. At 1 vCPU /
1 GiB and 24 juta requests/month:

| Active instance-hours / month | Cost |
|---|---:|
| 730h (always on — today, because of sockets) | $73.22 · Rp 1.354.607 |
| 360h (12h/day) | $37.92 · Rp 701.594 |
| **180h (6h/day) — realistic for a church app** | **$20.75 · Rp 383.912** |
| 90h (3h/day) | $12.26 · Rp 226.736 |
| 45h | $8.80 · Rp 162.800 |

For scale: 24 juta requests × 150 ms is only **12,5 instance-hours of actual work** at concurrency 80. The bill
is set by how *spread out* the traffic is, not by how much of it there is. For an app with evening and Sunday
peaks, 90–180 active-hours/month is the honest range.

**Comparison at 4.000 users:**

| Architecture | Monthly |
|---|---:|
| EC2 today (sockets, always on) | $20.43 · Rp 377.955 |
| Cloud Run **with** sockets (always on) | $47.34 · Rp 875.790 |
| **Cloud Run HTTP-only + FCM (~180h)** | **$20.75 · Rp 383.912** |
| Cloud Run HTTP-only + Pusher Channels paid | $69.75 · Rp 1.290.412 |

- **vs. Cloud Run with sockets: saves Rp 491.878/bulan ≈ Rp 5,9 juta/tahun.** This is the real prize.
- **vs. EC2 today: saves nothing.** Rp 383.912 vs Rp 377.955 — a rounding error. Be clear-eyed: this refactor
  does **not** beat the box you already run on price. It makes *Cloud Run* affordable.
- **It also deletes the Redis line item** (Rp 666.000/bulan Memorystore, or the Upstash tier) — no Socket.IO
  adapter means no cross-instance pub/sub. That saving is larger than the compute saving.

**And one cost that goes up, which no one mentions.** Today, one WebSocket connection is *one* Cloud Run
request no matter how many RPCs travel over it. Switching to HTTP turns 24 juta RPC calls into **24 juta
billable requests** — $8.80 · **Rp 162.800/bulan** in per-request charges that simply did not exist before, and
which forms a hard floor no amount of CPU tuning removes. It is comfortably outweighed here, but it is a real
line item and it scales with request count.

### 10.7 The architectural payoff is bigger than the money

Deleting the socket does not just cut ~Rp 6 juta/tahun off the Cloud Run bill. It **removes three of the
blockers in §4 outright**:

| Blocker | Status after |
|---|---|
| §4.4 Socket.IO sticky sessions vs. best-effort affinity | ✅ **Gone.** No sockets, no affinity requirement. |
| §4.5 Hard 60-minute WebSocket timeout | ✅ **Gone.** HTTP requests finish in milliseconds. |
| §3.3 Redis mandatory for multi-instance | ✅ **Gone.** No adapter, no pub/sub, no Memorystore. |
| §4.1 Report-queue job-claim race | ❌ **Still there.** Independent of transport — still the first thing to fix. |
| §4.3 Cron silently stops on request-based billing | ⚠️ **Still there**, and now it *bites*, because scale-to-zero is finally viable. Move both `@Cron` jobs to **Cloud Scheduler → HTTP endpoint** as part of this work. |

That last row is the trap. Scale-to-zero and in-process `@Cron` are mutually exclusive. The moment this refactor
makes scale-to-zero real, your cron jobs stop running. **Cloud Scheduler hitting an authenticated HTTP endpoint
is the replacement**, and it must ship in the same change, not after.

Multi-instance Cloud Run also becomes genuinely *safe* rather than merely affordable — which was the original
goal behind the whole migration question.

### 10.8 Honest verdict

**Do it — but for the architecture, not the money.** It saves nothing against your current EC2 box. What it
buys is a system where scale-to-zero, multi-instance, and autoscaling all actually work, instead of one where
you adopt a serverless platform and then configure every serverless property back out of it (§6, item 2).

Sequenced against §7:

- The **client rewrite is the dominant cost** and it is Flutter-side, not backend. 166 actions to repoint.
- The **backend cost is the permission-parity audit** (§10.4), not the transport plumbing. That audit is
  security work and cannot be rushed.
- **Fix §4.1 first regardless.** It is independent of all of this.
- Realistic sizing: this is materially more than the 3–6 engineer-days quoted in §3.6 for a plain lift-and-shift.
  Treat it as its own project.

If you want the cheap win first: **§7 Phase 1 (lift-and-shift at `max-instances=1`) requires zero code changes
and costs Rp 390–876 ribu/bulan.** Ship that, run it, then decide whether ~Rp 6 juta/tahun and a cleaner
architecture justify the client rewrite. It is a real prize, but it is not urgent, and it is much easier to
scope once the container is already running in production.
