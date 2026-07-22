# Daily database backup

**Status:** workflow written and merged; **not yet running — it needs the four settings below.**
Tracked on [#42](https://github.com/meimodev/palakat/issues/42).

`palakat_admin` has been serving production since 2026-03-20 (decision 21), and Supabase Free has
no automated backups worth the name (§13 R2). Until this runs, **there is no copy of the production
database anywhere.**

---

## Why GitHub Actions and not Cloud Scheduler

The plan puts this on Cloud Scheduler eventually. It is on GitHub Actions today because **Cloud
Scheduler, Cloud Run jobs and the GCP project itself do not exist until Phase 6**, and the whole
point of decision 21 is that this starts *now* rather than at the end of a fourteen-week migration.
Waiting for the migration to protect against the migration is backwards.

Nothing downstream depends on where it runs. Move it in Phase 3b if that is tidier then.

---

## What you have to create

Four settings. Two GitHub **variables**, one **secret**, one bucket.

### 1. The bucket, with retention as a lifecycle rule

```bash
PROJECT=your-project-id
BUCKET=palakat-db-backups

gcloud storage buckets create "gs://${BUCKET}" \
  --project="${PROJECT}" \
  --location=asia-southeast1 \
  --uniform-bucket-level-access \
  --public-access-prevention

cat > /tmp/lifecycle.json <<'JSON'
{"rule": [{"action": {"type": "Delete"}, "condition": {"age": 30}}]}
JSON

gcloud storage buckets update "gs://${BUCKET}" --lifecycle-file=/tmp/lifecycle.json
```

> ⚠️ **Lifecycle deletes by age. It cannot tell a good backup from the last one standing.**
> If the job fails silently for thirty days, every backup ages out and the bucket is empty at the
> moment you need it. The defence is that the job fails *loudly* — a failed scheduled workflow
> emails the repo owner. **If you mute those notifications you have deleted this backup system
> without noticing.**

### 2. A service account that can only write here

```bash
gcloud iam service-accounts create palakat-db-backup \
  --project="${PROJECT}" --display-name="Daily DB backup writer"

SA="palakat-db-backup@${PROJECT}.iam.gserviceaccount.com"

# objectCreator, not objectAdmin: this account may add backups and may not
# delete or overwrite them. If the workflow is ever compromised, the worst it
# can do is fill the bucket.
gcloud storage buckets add-iam-policy-binding "gs://${BUCKET}" \
  --member="serviceAccount:${SA}" --role=roles/storage.objectCreator
```

### 3. Workload Identity Federation, so no key ever exists

Matches how the repo already authenticates to AWS — OIDC, keyless.

```bash
gcloud iam workload-identity-pools create github \
  --project="${PROJECT}" --location=global --display-name="GitHub Actions"

gcloud iam workload-identity-pools providers create-oidc github \
  --project="${PROJECT}" --location=global --workload-identity-pool=github \
  --display-name="GitHub" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
  --attribute-condition="assertion.repository == 'meimodev/palakat'"

PROJECT_NUMBER=$(gcloud projects describe "${PROJECT}" --format='value(projectNumber)')

gcloud iam service-accounts add-iam-policy-binding "${SA}" \
  --project="${PROJECT}" --role=roles/iam.workloadIdentityUser \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github/attribute.repository/meimodev/palakat"
```

> `--attribute-condition` is not optional. Without it **any** GitHub repository in the world can
> mint a token for this service account. §6 of the plan says the same thing about the Phase 6
> provider; it is the same trap twice.

### 4. Set them on the repo

| Kind | Name | Value |
|---|---|---|
| Variable | `GCS_BACKUP_BUCKET` | `palakat-db-backups` |
| Variable | `GCP_WIF_PROVIDER` | `projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github/providers/github` |
| Variable | `GCP_BACKUP_SERVICE_ACCOUNT` | `palakat-db-backup@PROJECT.iam.gserviceaccount.com` |
| Secret | `DATABASE_URL_SESSION` | see below — **this is the part that goes wrong** |

---

## 🔴 The connection string is the part that goes wrong

Supabase gives you three URLs and only one of them works here.

| | Port | Works for `pg_dump` from Actions? |
|---|---|---|
| Direct (`db.<ref>.supabase.co`) | 5432 | **No** — IPv6-only on Free, and GitHub's hosted runners have no IPv6. It will hang, then time out. |
| Transaction pooler | 6543 | **No** — transaction mode cannot hold the session state `pg_dump` needs. |
| **Session pooler** (`aws-0-<region>.pooler.supabase.com`) | **5432** | **Yes.** Use this one. |

Note the trap: the session pooler and the direct connection are **both on 5432**. The port does not
tell you which one you have — the hostname does.

This is also why `DATABASE_URL_SESSION` is a distinct secret from the plan's `DATABASE_URL_DIRECT`
(§12.2), which genuinely does need the direct connection because DDL cannot go through a pooler.
Two different secrets, two different requirements, easy to swap by accident.

### Postgres major version

`pg_dump` refuses to run against a server **newer** than itself, and the runner's bundled client
tracks Ubuntu rather than Supabase. The workflow pins the client to `postgres:17-alpine`. If
Supabase moves past 17, set the repo variable `SUPABASE_PG_MAJOR` and nothing else changes.

---

## Proving a backup is restorable

**The daily job does not do this, and cannot.** It verifies the archive is readable and contains the
tables we expect, which is worth doing and is a weaker claim than "this restores into a working
database" — `pg_restore --list` is happy with archives that `pg_restore` chokes on.

```bash
./scripts/restore-rehearsal.sh gs://palakat-db-backups/daily/2026/07/22T180000Z.pgc
```

It starts a scratch Postgres container, restores into it, filters out the Supabase-specific noise
(missing `auth`/`storage` schemas, absent roles, unavailable extensions — none of which say anything
about your data), and then **counts rows**, because a restore that produces an empty schema exits 0.

Needs `docker`, plus `gcloud` for a `gs://` path. It creates and destroys one container and touches
nothing else.

**#42 is not done until this has passed once.** An untested backup is a hypothesis.

---

## Restoring for real

Same archive, pointed at a real target:

```bash
gcloud storage cp gs://palakat-db-backups/daily/<stamp>.pgc ./restore.pgc

pg_restore --no-owner --no-privileges \
  --dbname="$DATABASE_URL_DIRECT" ./restore.pgc
```

Use the **direct** connection here, not the session pooler — this is DDL.

Expect the same Supabase noise the rehearsal filters, and read it rather than piping it away: in a
real restore, an error about a *table* is a problem, an error about a role is not.
