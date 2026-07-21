# `palakat_backend` → GCP Cloud Run: Migration Plan

**Date:** 2026-07-21
**Companion:** [`palakat-backend-gcp-cloud-run-migration-analysis.md`](./palakat-backend-gcp-cloud-run-migration-analysis.md) — the *whether*. This document is the *how*.
**Supersedes for deployment:** [`palakat-backend-aws-ec2-cicd-deployment-guide.md`](./palakat-backend-aws-ec2-cicd-deployment-guide.md) once Stage 6 completes.

---

## 0. Decision gate — read before Stage 0

The analysis concluded: **Cloud Run costs ~2,3× the current EC2 box (Rp 875.790 vs Rp 378.029/bulan) and is not
cheaper at any realistic scale while WebSockets stay.** Migration is justified by three things only:

1. Sunday-morning burst capacity (`t3.small` burst credits are the wrong instrument for a hard weekly peak).
2. Zonal redundancy (today: one instance, one AZ).
3. Deleting server ops — SSH keys, systemd, Nginx, TLS renewal, OS patching.

If none of those is the actual pain, **stop here**. The cheaper answer is `t3.medium` (Rp 658.933/bulan, a console
dropdown) or a second EC2 instance behind an ALB.

Three questions must have answers before Stage 1. They change the plan materially:

| # | Question | Why it changes the plan |
|---|---|---|
| Q1 | **Which region is the Supabase project in?** | Cloud Run region must match it, or every Prisma query pays +5–15 ms and per-GiB egress. Singapore Supabase → `asia-southeast1`. Jakarta-hosted Supabase → `asia-southeast2`. Do not pick a region for client latency; the DB round-trip dominates. |
| Q2 | **Do we keep the WebSocket?** | Keeping it → instance-based billing, `min-instances=1`, 3600 s timeout, session affinity, no scale-to-zero, Rp ~876 ribu/bulan floor. Dropping it (analysis §10) → scale-to-zero, Rp 0–384 ribu/bulan, but a Flutter rewrite of 166 RPC actions plus a permission-parity audit. **Stages 1–6 are identical either way** — decide before Stage 7. |
| Q3 | **Staging environment: yes or no?** | Two Cloud Run services double the always-on cost unless staging runs `min-instances=0`. Recommended: staging at `min-instances=0`, request-based billing, accept that its cron jobs do not fire. |

**Recommended answers if nobody has a strong opinion:** Q1 = match Supabase. Q2 = keep the socket for now, revisit
after the container is in production. Q3 = yes, `min-instances=0`.

---

## 1. Shape of the plan

```
Stage 0  Pre-migration fixes        platform-independent, do regardless          ~1–2 days
Stage 1  Containerize                Dockerfile + local parity                   ~1 day
Stage 2  GCP scaffolding             project, registry, secrets, WIF             ~0,5 day
Stage 3  Service configuration       flags, probes, timeouts                     ~0,5 day
Stage 4  Migrations out of the box   Cloud Run Job                               ~0,5 day
Stage 5  CI/CD replacement           new GitHub Actions workflow                 ~1 day
Stage 6  Cutover + rollback          DNS, soak, decommission                     ~0,5 day
─────────────────────────────────────────────────────────────────────────────────────────
Stage 7  Earn multi-instance         only if burst is the reason                 ~2–3 days
Stage 8  Delete the socket           its own project, not part of this one       weeks
```

Stages 1–6 are the **lift-and-shift**: `max-instances=1`, zero application code changes beyond Stage 0.
Total realistic: **4–6 engineer-days**, matching the analysis §3.6 estimate.

---

## 2. Stage 0 — fixes that must land first (platform-independent)

These are not Cloud Run work. They are correctness fixes that the current single-process EC2 deployment masks.
Ship them to EC2 first and let them soak; then migrate a known-good build.

### 0.1 🔴 Atomic job claim in `ReportQueueService` — blocking for Stage 7, not Stage 1

`src/report/report-queue.service.ts:29` guards with `private isProcessing = false` (per-process), and
`:283`/`:296` claim a job as `findFirst` → separate `update`. Two instances both claim the same job.

Replace the claim with a single atomic statement:

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

Keep `isProcessing` as a *local* concurrency limiter — it is still correct for bounding one process to one job at
a time. It is simply no longer the correctness mechanism.

Also add a stale-job reaper: a job stuck in `PROCESSING` past N minutes (instance killed mid-render) never
recovers today. On Cloud Run, instances are killed on every revision rollout, so this goes from rare to routine.

**Verification:** integration test that starts two `processQueue()` calls concurrently against one PENDING row and
asserts exactly one render happens.

### 0.2 🔴 Ship the PDF font — silent-degradation trap

`src/report/report-renderer.ts:7–14` probes six paths; the first five are host absolute paths that exist on Ubuntu
EC2 and on **no** slim container base. The sixth, `__dirname/../../assets/fonts/NotoSans-Regular.ttf`, resolves at
runtime to `dist/assets/fonts/NotoSans-Regular.ttf`.

Verified path arithmetic: compiled output lands at `dist/src/report/report-renderer.js`, so `../../assets` =
`dist/assets`. `nest-cli.json` declares `"assets": ["assets/**/*"]` against `sourceRoot: "src"`, which copies
`src/assets/**` → `dist/assets/**`. `src/utils/gmim-letterhead.ts:104-105` already documents and relies on this
exact layout. **So committing the TTF to `src/assets/fonts/NotoSans-Regular.ttf` works with no build change.**

Two ways to fix; pick one:

- **Dockerfile (recommended, no binary in git):** `apt-get install -y --no-install-recommends fonts-dejavu-core`
  in the runtime stage. Candidate #1 then resolves exactly as it does on EC2.
- **Commit the font:** drop `NotoSans-Regular.ttf` into `src/assets/fonts/`. Works, adds ~450 KB to the repo.

Either way, **add a startup assertion** so this can never degrade silently again:

```ts
// report-renderer.ts — fail loud at boot, not silently at render time
const UNICODE_FONT_PATH = resolveUnicodeFontPath();
if (!UNICODE_FONT_PATH) {
  throw new Error('No Unicode font found — PDF export would silently mangle non-Latin-1 glyphs');
}
```

Without the assertion, a base-image change six months from now reintroduces the bug and no test catches it,
because most Indonesian text is Latin-1 and renders fine.

### 0.3 🟠 Bound the Prisma connection pool

`src/prisma.service.ts:19-21` constructs `new Pool({ connectionString })` with no `max`, taking `pg`'s default of
**10 connections per process**. Cloud Run's default `max-instances` is 100.

```ts
const pool = new Pool({
  connectionString,
  max: Number(process.env.DATABASE_POOL_MAX ?? 3),
  idleTimeoutMillis: 30_000,
  connectionTimeoutMillis: 10_000,
});
```

Make it env-driven so the Cloud Run Job (migrations) and the service can differ without a code change.

Separately: route the service through **Supabase's transaction pooler on port 6543** with `?pgbouncer=true`.
That disables prepared statements. **Verify before cutover, not after** — run the full e2e suite against the
pooler URL. Migrations must keep using the **direct** connection (port 5432); PgBouncer transaction mode cannot
run DDL reliably.

### 0.4 🟡 Repo hygiene that will otherwise bite the Docker build

- `apps/palakat_backend/package-lock.json` and `apps/palakat_backend/pnpm-lock.yaml` are stale artifacts — the
  root `pnpm-lock.yaml` is authoritative (the existing workflow installs from the repo root). Delete both, or the
  Docker build will pick the wrong one depending on copy order.
- `pnpm-workspace.yaml` lists `packages/node/*`, which is **empty**. Harmless, but the build context must still
  include it or `pnpm install --frozen-lockfile` complains about a lockfile/workspace mismatch.
- `apps/palakat_backend/vercel.json` is a static-site config (SPA rewrites, COOP/COEP headers) sitting in the
  backend package. It is not used by anything here. Delete or move.

### Stage 0 exit criteria

- [ ] Concurrent-claim test passes; stale-job reaper in place.
- [ ] Font assertion throws on a container with no fonts installed (prove it by building a `node:24-slim` image
      without the apt line and watching it fail at boot).
- [ ] `DATABASE_POOL_MAX` honoured; e2e suite green against the Supabase transaction pooler.
- [ ] Deployed to EC2 and soaked for at least one Sunday service.

---

## 3. Stage 1 — containerize

### 3.1 Build facts that constrain the Dockerfile

| Fact | Source | Consequence |
|---|---|---|
| pnpm workspace rooted at repo root | `pnpm-workspace.yaml` | **Build context must be the repo root**, not `apps/palakat_backend`. |
| `packageManager: pnpm@10.17.0` | `apps/palakat_backend/package.json:115` | Use corepack; do not `npm i -g pnpm`. |
| CI uses Node 24 | `.github/workflows/palakat-backend-deploy.yml` | Base image `node:24-slim` — match production to CI. |
| Prisma 7 `prisma-client` generator → `src/generated/prisma`, **not tracked in git** | `prisma/schema.prisma:1-5`, `git ls-files` returns 0 | `prisma generate` **must** run inside the build, before `nest build`. Output is TypeScript, compiled by `tsc` into `dist/src/generated/prisma`. |
| `datasource db` has **no** `url` | `prisma/schema.prisma:7-9` | The URL comes from `prisma.config.ts`. Needed for `migrate`, not for runtime — `PrismaService` builds its own connection string from env. |
| `build` = `prisma generate && nest build`; `start:prod` = `node dist/src/main.js` | `package.json` scripts | Container `CMD` is `node dist/src/main.js`. Do **not** use `pnpm start:prod` (it adds a pnpm process for nothing). |
| `postinstall: prisma generate` | `package.json` | Install with `--ignore-scripts` in the deps layer so Docker caching actually works, then generate explicitly. |
| No Rust query engine (driver adapter) | `@prisma/adapter-pg` in `prisma.service.ts` | No engine binary to copy or match to libc. This is why `node:24-slim` is fine and Alpine is unnecessary risk. |
| `app.listen(process.env.PORT \|\| 3000, '0.0.0.0')` | `src/main.ts` | Already Cloud Run compatible. Do **not** set `PORT` yourself; Cloud Run injects it. |

### 3.2 `apps/palakat_backend/Dockerfile`

```dockerfile
# syntax=docker/dockerfile:1
# Build context is the REPO ROOT:  docker build -f apps/palakat_backend/Dockerfile .

FROM node:24-slim AS base
ENV PNPM_HOME=/pnpm PATH=/pnpm:$PATH
RUN corepack enable
WORKDIR /repo

# ---------- deps ----------
FROM base AS deps
COPY pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/palakat_backend/package.json apps/palakat_backend/
RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --frozen-lockfile --ignore-scripts

# ---------- build ----------
FROM deps AS build
COPY apps/palakat_backend apps/palakat_backend
# runs `prisma generate && nest build`; generated TS is compiled into dist/
RUN pnpm --dir apps/palakat_backend run build

# ---------- runtime ----------
FROM base AS runtime
ENV NODE_ENV=production
# ponytail: fonts-dejavu-core satisfies UNICODE_FONT_CANDIDATES[0] — same font the
# Ubuntu EC2 box resolves. Alternative is committing the TTF to src/assets/fonts/.
RUN apt-get update \
 && apt-get install -y --no-install-recommends fonts-dejavu-core ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY --from=build /repo/node_modules                        /repo/node_modules
COPY --from=build /repo/apps/palakat_backend/node_modules   /repo/apps/palakat_backend/node_modules
COPY --from=build /repo/apps/palakat_backend/dist           /repo/apps/palakat_backend/dist
# prisma schema + config are needed by the migrations Job (Stage 4), same image
COPY --from=build /repo/apps/palakat_backend/prisma         /repo/apps/palakat_backend/prisma
COPY --from=build /repo/apps/palakat_backend/prisma.config.ts /repo/apps/palakat_backend/
COPY --from=build /repo/apps/palakat_backend/package.json   /repo/apps/palakat_backend/

WORKDIR /repo/apps/palakat_backend
USER node
CMD ["node", "dist/src/main.js"]
```

**Skipped deliberately:** a separate prod-only dependency install. Copying the full `node_modules` yields a
~400–600 MB image instead of ~250 MB. That costs roughly **Rp 700/bulan** in Artifact Registry across 20
revisions and a few seconds of cold start you are paying `min-instances=1` to avoid anyway. Add `pnpm deploy
--filter` or `--prod` pruning when image size measurably hurts, not before.

`.dockerignore` at the repo root:

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

That last line matters: a stale local `src/generated/prisma` must never shadow the one built in the image.

### 3.3 Local parity check before touching GCP

```bash
docker build -f apps/palakat_backend/Dockerfile -t palakat-backend:local .
docker run --rm -p 8080:8080 \
  -e PORT=8080 \
  -e NODE_ENV=production \
  -e DATABASE_URL="postgresql://…supabase…:6543/postgres?pgbouncer=true" \
  -e JWT_SECRET=… -e HEALTH_PAGE_SECRET=… \
  palakat-backend:local

curl -fsS -H "x-health-secret: $HEALTH_PAGE_SECRET" http://localhost:8080/health
```

Then exercise, in this order: **a PDF export** (proves the font), **a socket connect + one RPC** (proves the
gateway), **a report job end-to-end** (proves the cron fires and the queue drains).

### Stage 1 exit criteria

- [ ] Image builds from a clean checkout with no network access to the EC2 box.
- [ ] `/health` returns 200 with the secret header, 401/403 without.
- [ ] PDF export contains correct glyphs — inspect the file, do not trust a 200.
- [ ] Socket connects, one RPC round-trips, one report job completes.

---

## 4. Stage 2 — GCP scaffolding

Substitute your own values for `PROJECT_ID`, `REGION` (answer to Q1), `GH_ORG/REPO`.

### 4.1 Project, APIs, registry

```bash
gcloud config set project PROJECT_ID
gcloud services enable \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  secretmanager.googleapis.com \
  cloudscheduler.googleapis.com \
  iamcredentials.googleapis.com

gcloud artifacts repositories create palakat \
  --repository-format=docker --location=REGION \
  --description="palakat backend images"
```

Set a **cleanup policy** on the repository immediately (keep 10 most recent, delete untagged after 7 days).
Without it, Artifact Registry storage grows forever at Rp 1.850/GB-bulan and nobody notices.

### 4.2 Service account — least privilege

```bash
gcloud iam service-accounts create palakat-backend --display-name="palakat backend runtime"
# runtime SA: read secrets only. It does NOT need run.admin.
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:palakat-backend@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

The deployer (GitHub Actions) is a **separate** identity with `roles/run.admin`,
`roles/artifactregistry.writer`, and `roles/iam.serviceAccountUser` on the runtime SA. Do not merge the two.

### 4.3 Secrets — and the config trap this project has

`src/app.module.ts:38-45` sets `ignoreEnvFile: !DOTENV_CONFIG_PATH && (NODE_ENV === 'production' || INVOCATION_ID !== undefined)`.

**On Cloud Run: set `NODE_ENV=production` and do NOT set `DOTENV_CONFIG_PATH`.** Then `ignoreEnvFile` is `true`,
`@nestjs/config` reads only from `process.env`, and the sectioned `[local]/[staging]/[production]` `.env` format
that `prisma.config.ts` parses is bypassed entirely. That format exists for the EC2 file at
`/etc/palakat/palakat_backend.env` and has no equivalent on Cloud Run. `PALAKAT_ENV` is likewise irrelevant once
`DATABASE_URL` is a real environment variable.

Load secrets one per Secret Manager entry:

```bash
for K in JWT_SECRET DATABASE_URL HEALTH_PAGE_SECRET APP_CLIENT_PASSWORD \
         PUSHER_BEAMS_SECRET_KEY FIREBASE_PRIVATE_KEY SONG_DB_FILE_ID; do
  gcloud secrets create "$K" --replication-policy=automatic
done
```

> ⚠️ **`FIREBASE_PRIVATE_KEY` is the one that will break.** In the EC2 `.env` it is stored as a single line with
> literal `\n` escape sequences, and the app un-escapes them. Secret Manager will happily store a real multi-line
> PEM instead — which produces a *different* string and an opaque `Invalid PEM formatted message` at Firebase
> init. **Store the value byte-identical to the `.env` line, escapes included**, and verify by asserting on the
> parsed key at startup, not by watching the container come up.

Non-secret env vars go inline: `NODE_ENV=production`, `PUBLIC_BASE_URL`, `FORCE_SEEDING=false`,
`DATABASE_POOL_MAX=3`, `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, `FIREBASE_STORAGE_BUCKET`,
`PUSHER_BEAMS_INSTANCE_ID`.

Leave `REDIS_URL`, `REDIS_HOST`, `REDIS_PORT` **unset** for Stage 1–6. `redis-io.adapter.ts:25-33` logs
*"Redis is not configured; using in-memory socket.io adapter"* and continues. That is correct at
`max-instances=1`.

> **Note for Stage 7:** `redis-io.adapter.ts:61` *throws* if Redis is configured but unreachable, and
> `main.ts` awaits `connectToRedis()` **before** `app.listen()`. So a bad `REDIS_URL` produces a container that
> never binds a port — Cloud Run reports "failed to start and listen", not "Redis down". Failing loudly is the
> right behaviour; just know how it will present. Upstash requires `rediss://` (TLS), not `redis://`.

### 4.4 Workload Identity Federation — no JSON keys

The existing workflow already declares `permissions: id-token: write`, so the plumbing is half done.

```bash
gcloud iam workload-identity-pools create github --location=global
gcloud iam workload-identity-pools providers create-oidc github-provider \
  --location=global --workload-identity-pool=github \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
  --attribute-condition="assertion.repository=='GH_ORG/REPO'"
```

The `--attribute-condition` is not optional. Without it, **any** GitHub repository on the internet can mint tokens
for your project.

---

## 5. Stage 3 — service configuration

### 5.1 The flags, and why each one

```bash
gcloud run deploy palakat-backend \
  --image=REGION-docker.pkg.dev/PROJECT_ID/palakat/backend:TAG \
  --region=REGION \
  --service-account=palakat-backend@PROJECT_ID.iam.gserviceaccount.com \
  --min-instances=1 \
  --max-instances=1 \
  --no-cpu-throttling \
  --cpu=1 --memory=1Gi \
  --concurrency=80 \
  --timeout=3600 \
  --session-affinity \
  --allow-unauthenticated \
  --set-env-vars=NODE_ENV=production,FORCE_SEEDING=false,DATABASE_POOL_MAX=3,… \
  --set-secrets=JWT_SECRET=JWT_SECRET:latest,DATABASE_URL=DATABASE_URL:latest,…
```

| Flag | Reason | What breaks without it |
|---|---|---|
| `--min-instances=1` | Cron jobs need a resident process. | `@Cron(EVERY_10_SECONDS)` queue poller and the 07:00 birthday job stop firing. Reports never finish, silently. |
| `--max-instances=1` | The `isProcessing` latch and the in-memory Socket.IO adapter are single-process assumptions until Stage 7. | Duplicate report processing; socket rooms split across instances. |
| `--no-cpu-throttling` | Instance-based billing, CPU always allocated. | Same as `min-instances`: cron dies. This is analysis §4.3, and it is the crux — *the config that makes Cloud Run cheap is the config that breaks this app.* |
| `--timeout=3600` | Cloud Run treats a WebSocket as an HTTP request. Default is **300 s**. | Every client force-disconnects every 5 minutes instead of every 60. |
| `--session-affinity` | Socket.IO's polling handshake needs the same process. Best-effort only. | Intermittent handshake failures, hard to reproduce. Belt-and-braces even at one instance. |
| `--concurrency=80` | Each WebSocket occupies a concurrency slot for its whole life. | At the default this is fine; at concurrency 1 you would pin one instance per connected user. |
| `--memory=1Gi` | Cloud Run's writable FS is **tmpfs charged against the memory limit**. `report-renderer.ts` and the chunked upload path both write temp files. | An OOM kill drops **every** connected WebSocket at once. Do not run 512 MiB with `exceljs` + `pdfkit` in the process. |

`--max-instances=1` is the single most important line. It is what makes "zero application code changes" true.

### 5.2 Probes

Use the **default TCP startup probe**. `/health` sits behind `HealthSecretGuard`
(`src/health/health-secret.guard.ts:29` requires an `x-health-secret` header), and an HTTP probe with custom
headers cannot be expressed in `gcloud run deploy` flags — it needs `gcloud run services replace service.yaml`.

```
ponytail: TCP startup probe. The app binds its port only after
PrismaService.$connect() and RedisIoAdapter.connectToRedis() both resolve,
so "port is open" already implies "DB reachable". Switch to an HTTP probe
via service.yaml if a future failure mode lets the port open while the app
is unhealthy.
```

Raise `--startup-probe-timeout` if NestJS bootstrap plus Prisma connect exceeds the default window — measure it
from the local container in Stage 1, do not guess.

### 5.3 What still has to be built outside Cloud Run

- **Domain + TLS:** `gcloud beta run domain-mappings create` (managed certificate, ~15–60 min to provision), or
  put a Global External HTTPS Load Balancer in front. Domain mapping is the lazy option and is enough here.
- **Nginx is gone.** Anything it did — body size limits, WebSocket upgrade headers, redirects — must be
  re-checked. Cloud Run handles the upgrade natively; `maxHttpBufferSize: 1024 * 1024` is set in
  `redis-io.adapter.ts:73`, so upload chunk size is already app-level, not proxy-level. Confirm no other Nginx
  directive was load-bearing before deleting the box.
- **CORS** is set in `main.ts` (`origin: true, credentials: true`) and in the gateway. Unchanged by the move.

---

## 6. Stage 4 — migrations out of the container start

`prisma migrate deploy` must **never** run in the container `CMD`. At `max-instances=1` it would appear to work;
at Stage 7 every scaled instance races the same migration.

Today the EC2 workflow runs `pnpm run db:deploy` over SSH mid-deploy. Replacement: a **Cloud Run Job** on the same
image.

```bash
gcloud run jobs create palakat-migrate \
  --image=REGION-docker.pkg.dev/PROJECT_ID/palakat/backend:TAG \
  --region=REGION \
  --service-account=palakat-backend@PROJECT_ID.iam.gserviceaccount.com \
  --set-secrets=DATABASE_URL=DATABASE_URL_DIRECT:latest \
  --command=npx --args=prisma,migrate,deploy \
  --max-retries=0 --task-timeout=600
```

Three things to get right:

1. **`DATABASE_URL_DIRECT`, not the pooler.** Migrations need the direct connection on port 5432. PgBouncer
   transaction mode cannot run DDL reliably. This is a *second* secret, holding a *different* URL.
2. **`npx prisma migrate deploy`, not `pnpm run db:deploy`.** The npm script is `prisma migrate deploy && prisma
   generate` — regenerating the client in a runtime container is pointless and slow.
3. `prisma.config.ts` resolves `datasource.url` via `readEnvValue('DATABASE_URL')`, which reads `process.env`
   first. With the env var set, the `.env`-file fallback never fires. No `.env` needs to exist in the image.

**Never run the seed in production.** `FORCE_SEEDING=false`, and `prisma db push --force-reset` (`db:push`) must
not exist in any pipeline that can touch production.

Both `@Cron` jobs keep working at `min-instances=1` + `--no-cpu-throttling`. Cloud Scheduler is **not** needed for
Stages 1–6 — it becomes mandatory the moment scale-to-zero is viable (Stage 8).

---

## 7. Stage 5 — CI/CD replacement

The existing `.github/workflows/palakat-backend-deploy.yml` (~150 lines: temporary SG ingress authorization, scp a
tarball, ssh, `pnpm install`, build on the box, `db:deploy`, `systemctl restart`, health poll, revoke ingress) is
**deleted entirely**. Keep the trigger — tags matching `deploy-backend*` — so muscle memory survives.

```yaml
name: Deploy Palakat Backend (Cloud Run)
on:
  push:
    tags: ['deploy-backend*']
  workflow_dispatch:

permissions:
  contents: read
  id-token: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: ${{ vars.GCP_WIF_PROVIDER }}
          service_account: ${{ vars.GCP_DEPLOYER_SA }}
      - uses: google-github-actions/setup-gcloud@v2
      - run: gcloud auth configure-docker ${{ vars.GCP_REGION }}-docker.pkg.dev --quiet

      - name: Build & push
        run: |
          IMAGE="${{ vars.GCP_REGION }}-docker.pkg.dev/${{ vars.GCP_PROJECT }}/palakat/backend:${{ github.sha }}"
          docker build -f apps/palakat_backend/Dockerfile -t "$IMAGE" .
          docker push "$IMAGE"
          echo "IMAGE=$IMAGE" >> "$GITHUB_ENV"

      - name: Migrate
        run: |
          gcloud run jobs update palakat-migrate --image="$IMAGE" --region=${{ vars.GCP_REGION }}
          gcloud run jobs execute palakat-migrate --region=${{ vars.GCP_REGION }} --wait

      - name: Deploy (no traffic yet)
        run: |
          gcloud run deploy palakat-backend --image="$IMAGE" \
            --region=${{ vars.GCP_REGION }} --no-traffic --tag=candidate

      - name: Smoke test the candidate revision
        run: |
          URL=$(gcloud run services describe palakat-backend --region=${{ vars.GCP_REGION }} \
                 --format='value(status.traffic.filter("tag=candidate").url)')
          curl -fsS -H "x-health-secret: ${{ secrets.HEALTH_PAGE_SECRET }}" "$URL/health"

      - name: Promote
        run: gcloud run services update-traffic palakat-backend \
               --region=${{ vars.GCP_REGION }} --to-latest
```

Order matters: **migrate → deploy with `--no-traffic` → smoke the tagged revision → promote.** The
`--tag=candidate` URL lets you hit the new revision before any user does — something the EC2 pipeline could never
do, since `systemctl restart` was the test.

Deleted along with the old workflow: `EC2_SSH_PRIVATE_KEY`, `EC2_SSH_PASSPHRASE`, `EC2_HOST`, `EC2_USER`,
`EC2_PORT`, `EC2_SECURITY_GROUP_ID`, `AWS_ROLE_TO_ASSUME`. **Revoke the SSH key at the same time you delete the
secret** — a deleted GitHub secret is not a revoked key.

Migrations run **before** the new code takes traffic, so every migration must be **backward compatible with the
currently-running revision**. Expand/contract, never rename-in-place. This constraint exists on EC2 too; the
zero-downtime rollout makes violating it much more visible.

---

## 8. Stage 6 — cutover and rollback

1. Deploy to Cloud Run against the **production** Supabase database, no DNS change. Both stacks now run; EC2 still
   serves all clients.
2. Verify against the `run.app` URL: health, login, a socket RPC, a PDF export, one report job start-to-finish.
3. Watch one full cron cycle — confirm the 10-second poller ticks and the 07:00 birthday job fires **exactly
   once**. Cloud Logging: filter `resource.type="cloud_run_revision"`.
4. Map the domain. **Lower the DNS TTL to 60 s at least 24 hours beforehand** — this is the step teams skip and
   then cannot roll back quickly.
5. Cut over. Sockets on EC2 do not migrate; clients reconnect. Do this **outside** a service, i.e. not Sunday
   morning.
6. Soak **one full week including a Sunday**, EC2 still running and warm.
7. Only then: stop the EC2 instance (do not terminate). Wait another week. Then terminate and release the Elastic
   IP — an unattached EIP still bills.

**Rollback ladder, fastest first:**

| Failure | Action | Time |
|---|---|---|
| Bad revision | `gcloud run services update-traffic palakat-backend --to-revisions=PREVIOUS=100` | seconds |
| Cloud Run broadly wrong | DNS back to EC2 (which is why it stays running for a week) | ~60 s at TTL 60 |
| Bad migration | Forward-fix only. **There is no rollback for `migrate deploy`.** | — |

That last row is why migrations must be expand/contract. Take a Supabase snapshot immediately before the first
production migration run.

---

## 9. Stage 7 — earn multi-instance (only if burst is the reason)

Do not raise `max-instances` until **all** of these are true:

1. ✅ Atomic job claim shipped and tested (Stage 0.1). **The one that matters.**
2. ⬜ Redis provisioned and the Socket.IO adapter made **mandatory** — start with Upstash (free at 256 MB /
   500 ribu commands, `rediss://` URL). Memorystore Basic M1 is ~$36/mo · Rp 666.000 with no free tier; only
   justify it on measured command volume. Socket.IO's adapter is chatty: every cross-instance emit is a pub/sub
   round trip.
3. ⬜ Flutter client forced to `transports: ['websocket']`, skipping the polling handshake entirely. Cheapest
   mitigation for best-effort affinity. Note `allowEIO3: true` in `redis-io.adapter.ts:72` — confirm no client
   still needs the polling path before removing it.
4. ⬜ `DATABASE_POOL_MAX` × `max-instances` verified under the Supabase tier's connection ceiling, through the
   transaction pooler.
5. ⬜ tmpfs audit: peak report size + Node heap must fit the memory limit, with the instance serving other
   requests at the same time.
6. ⬜ Any *new* `@Cron` reviewed for idempotency. The birthday job is already safe — `schema.prisma:677`
   `dedupeKey String? @unique`, insert-then-push, catch `P2002`, continue. It is the model to copy.

Then raise the ceiling **deliberately**:

```bash
gcloud run services update palakat-backend --max-instances=3 --region=REGION
```

At Rp ~876 ribu per always-on instance, a default `max-instances=100` is how a Rp 876 ribu/bulan service becomes a
Rp 10 juta/bulan one during a traffic anomaly. Set a **billing budget alert in USD** (§10) before raising it, not
after.

---

## 10. Cost, budget, and guardrails

Expected Stage 6 steady state, per the analysis:

| Line item | Monthly |
|---|---:|
| Cloud Run 1 vCPU / 1 GiB, instance-based, always-on (net of free tier) | $47.34 · Rp 875.790 |
| Artifact Registry (~5 GB with cleanup policy) | ~$0.50 · Rp 9.250 |
| Egress to mobile clients (APAC, ~$0.12/GiB) | volume-dependent |
| Cross-cloud egress to Supabase | volume-dependent; **zero if Q1 region matches** |
| **vs. EC2 today** | $20.43 · Rp 378.029 |
| **Delta** | **+Rp ~500 ribu/bulan ≈ Rp 6 juta/tahun** |

Guardrails to configure on day one:

- **Billing budget alert in USD** at 100%, 150%, 200% of expected. Bills are USD; funding is likely IDR (analysis
  §3.7). Budget in IDR with **10–15% FX headroom**.
- **`max-instances` explicit**, never default.
- **Artifact Registry cleanup policy.**
- **Log-based alert** on `Container called exit` and on `The request was aborted because there was no available
  instance`.
- **Uptime check** against `/health` with the secret header — Cloud Monitoring uptime checks support custom
  headers even though startup probes are awkward to configure with them.

---

## 11. Risk register

| # | Risk | Likelihood | Impact | Mitigation | Stage |
|---|---|---|---|---|---|
| R1 | PDF glyphs silently degrade on the slim base image | **High** if unaddressed | Corrupt reports, discovered by users | `fonts-dejavu-core` + **startup assertion** | 0.2 |
| R2 | `FIREBASE_PRIVATE_KEY` newline mangling in Secret Manager | **High** | Push notifications dead | Store byte-identical to `.env`; assert on parsed key at boot | 2 |
| R3 | Duplicate report processing after scale-out | Certain at >1 instance | Data correctness + double CPU spend | `FOR UPDATE SKIP LOCKED` | 0.1 |
| R4 | Cron silently stops | High if `--no-cpu-throttling` is omitted | Reports never finish, no error | Instance-based billing + `min-instances=1`; alert on queue depth | 3 |
| R5 | Supabase connection exhaustion | Medium at >3 instances | 500s under load | `DATABASE_POOL_MAX=3` + transaction pooler + bounded `max-instances` | 0.3, 7 |
| R6 | Prepared statements break on PgBouncer | Medium | Runtime query failures | Full e2e against the pooler **before** cutover | 0.3 |
| R7 | tmpfs OOM during a large export | Medium | Instance killed → **all** sockets drop at once | 1 GiB minimum; audit temp-file paths | 3 |
| R8 | Cross-cloud DB latency (+5–15 ms/query) | Certain if regions mismatch | Compounds in `report.service.ts` loops | Q1: match the Supabase region | 0 |
| R9 | WebSocket 60-min cap, best-effort affinity | Certain | Hourly reconnects; per-connection state lost | `--timeout=3600`, `--session-affinity`, force `transports: ['websocket']` | 3, 7 |
| R10 | Two clouds to operate, permanently | Certain | Recurring ops tax on a small team | Accept it knowingly, or do not migrate | 0 |
| R11 | Runaway `max-instances` | Low | Rp 10 juta/bulan surprise | Explicit ceiling + budget alerts | 7, 10 |
| R12 | Non-backward-compatible migration during rollout | Medium | Old revision errors mid-deploy | Expand/contract; snapshot before first prod migration | 5, 6 |

---

## 12. Stage 8 — deleting the WebSocket (scoped, not planned here)

The analysis §10 finding stands: **166 of 166 RPC actions are CRUD**, `rpc-router.service.ts` makes **zero** direct
Prisma calls and 143 service delegations, 27 REST controllers already cover the same domains, and only **10
`emitToRoom` call sites** are genuinely realtime. Replace them with FCM (free, `firebase-admin` already wired,
`messaging()` simply never called) plus 2-second polling while the report-progress modal is open.

Two things gate it, and neither is transport plumbing:

- 🔴 **Permission parity.** The RPC path calls `requireAnyOperationPermission(...)`; the REST controllers have
  `@UseGuards(AuthGuard('jwt'))` and nothing more. Repointing the client at the controllers as-is ships a
  **privilege-escalation bug** across finance and probably other modules. All 166 actions need auditing against
  their controller counterpart. That is security work; it cannot be rushed.
- ⚠️ **Cron and scale-to-zero are mutually exclusive.** The moment scale-to-zero becomes real, both `@Cron` jobs
  stop. **Cloud Scheduler → an authenticated HTTP endpoint must ship in the same change**, not after.

The payoff: scale-to-zero becomes real (Rp 0/bulan for a single-church deployment, ~Rp 384 ribu at 4.000 users),
the Redis line item disappears, and analysis §4.4/§4.5 vanish outright. It saves **nothing against EC2** — it makes
*Cloud Run* affordable. The dominant cost is the Flutter client rewrite.

**Treat it as its own project with its own plan.** It is a real prize; it is not urgent; and it is far easier to
scope once the container is already running in production.

---

## 13. Summary checklist

```
Stage 0 — before anything          [ ] atomic job claim + stale-job reaper
                                   [ ] font in image + startup assertion
                                   [ ] pool bounded, pooler e2e green
                                   [ ] stale lockfiles / vercel.json removed
                                   [ ] soaked on EC2 through one Sunday

Stage 1 — containerize             [ ] Dockerfile (context = repo root)
                                   [ ] .dockerignore excludes src/generated
                                   [ ] local run: health, socket, PDF, report job

Stage 2 — GCP scaffolding          [ ] APIs, Artifact Registry + cleanup policy
                                   [ ] runtime SA (secretAccessor only)
                                   [ ] secrets loaded; FIREBASE_PRIVATE_KEY verified
                                   [ ] WIF with --attribute-condition

Stage 3 — service config           [ ] min=1 max=1 --no-cpu-throttling
                                   [ ] --timeout=3600 --session-affinity
                                   [ ] 1 vCPU / 1 GiB; TCP startup probe
                                   [ ] domain mapping + managed TLS

Stage 4 — migrations               [ ] Cloud Run Job, DIRECT url, npx prisma migrate deploy
                                   [ ] seed disabled in every prod path

Stage 5 — CI/CD                    [ ] new workflow: migrate → --no-traffic → smoke → promote
                                   [ ] EC2/AWS secrets deleted AND SSH key revoked

Stage 6 — cutover                  [ ] DNS TTL 60s, 24h ahead
                                   [ ] cron observed firing exactly once
                                   [ ] one-week soak with EC2 warm
                                   [ ] EC2 stopped → terminated → EIP released

Always                             [ ] USD billing budget alert, IDR budget +15%
                                   [ ] max-instances explicit
```

---

## 14. Corrections and additions to the analysis document

Recorded because they came from reading the code while writing this plan:

1. **§4.8 is right about the font but understates the fix path.** `src/assets/` already exists (`gmim-logo.png`),
   `nest-cli.json` asset copying is configured, and `src/utils/gmim-letterhead.ts:100-105` documents the exact
   `dist/assets` layout that `report-renderer.ts:13` depends on. Committing the TTF works with no build change —
   verified, not assumed.
2. **§4.9 misses the Prisma 7 generator detail.** `provider = "prisma-client"` outputs **TypeScript** into
   `src/generated/prisma`, which is *not tracked in git*. `prisma generate` must run before `tsc`, and the
   generated client is compiled into `dist/`. This is why the `build` script's ordering is load-bearing and why
   `--ignore-scripts` at install time is safe.
3. **§4.10's `INVOCATION_ID` note is only half the config story.** The bigger issue is the **sectioned `.env`
   format** parsed by `prisma.config.ts` (`[local]`/`[staging]`/`[production]` via `PALAKAT_ENV`). It has no
   Cloud Run equivalent and is bypassed entirely by `NODE_ENV=production` + no `DOTENV_CONFIG_PATH`. Worth stating
   explicitly, because it looks like something that needs porting and does not.
4. **New finding — Redis failure mode.** `redis-io.adapter.ts:61` throws on connect failure and `main.ts` awaits
   it *before* `app.listen()`. A misconfigured `REDIS_URL` in Stage 7 presents as "container failed to start and
   listen on PORT", not as a Redis error. Correct behaviour, confusing symptom.
5. **New finding — `FIREBASE_PRIVATE_KEY` escaping** across the `.env` → Secret Manager boundary (R2). Not
   mentioned in the analysis; high likelihood; opaque failure.
6. **New finding — health probe vs. `HealthSecretGuard`.** §4.10 says probes "can send headers"; in practice
   `gcloud run deploy` flags cannot express them — it requires `gcloud run services replace service.yaml`. The
   default TCP startup probe sidesteps this and is sufficient, because the app binds its port only after Prisma
   and the socket adapter are both up.
