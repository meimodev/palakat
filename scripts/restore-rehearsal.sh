#!/usr/bin/env bash
#
# Prove a backup is restorable. Run this once before calling #42 done, and
# again whenever the schema changes shape.
#
# An untested backup is a hypothesis. The daily job checks that the dump is
# readable and contains the tables we expect, which is worth doing but is not
# the same claim as "this restores into a working database" — pg_restore can
# fail on extensions, roles, or ordering that pg_restore --list is happy with.
#
#   ./scripts/restore-rehearsal.sh gs://palakat-db-backups/daily/2026/07/22T180000Z.pgc
#   ./scripts/restore-rehearsal.sh ./dump.pgc
#
# Needs docker and, for a gs:// path, gcloud. Touches nothing but a scratch
# container it creates and destroys.

set -euo pipefail

SOURCE="${1:-}"
PG_MAJOR="${PG_MAJOR:-17}"
CONTAINER="palakat-restore-rehearsal-$$"
WORKDIR="$(mktemp -d)"

if [ -z "$SOURCE" ]; then
  echo "usage: $0 <gs://bucket/path.pgc | ./local.pgc>" >&2
  exit 64
fi

cleanup() {
  docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
  rm -rf "$WORKDIR"
}
trap cleanup EXIT

case "$SOURCE" in
  gs://*)
    echo "==> fetching $SOURCE"
    gcloud storage cp "$SOURCE" "$WORKDIR/dump.pgc"
    ;;
  *)
    cp "$SOURCE" "$WORKDIR/dump.pgc"
    ;;
esac

echo "==> starting a scratch postgres:${PG_MAJOR}"
docker run -d --name "$CONTAINER" \
  -e POSTGRES_PASSWORD=rehearsal \
  -e POSTGRES_DB=rehearsal \
  "postgres:${PG_MAJOR}-alpine" >/dev/null

for _ in $(seq 1 60); do
  if docker exec "$CONTAINER" pg_isready -U postgres -q; then break; fi
  sleep 1
done
docker exec "$CONTAINER" pg_isready -U postgres -q

docker cp "$WORKDIR/dump.pgc" "$CONTAINER:/tmp/dump.pgc"

echo "==> restoring"
# --no-owner/--no-privileges because the dump is taken that way: Supabase's
# roles do not exist in a scratch container and are not what we are testing.
# Not using --exit-on-error: we want to see *every* problem in one run, then
# judge them below, rather than fixing them one container at a time.
set +e
docker exec "$CONTAINER" pg_restore \
  --username=postgres --dbname=rehearsal \
  --no-owner --no-privileges \
  /tmp/dump.pgc 2> "$WORKDIR/restore.err"
set -e

# Errors about missing extensions and absent Supabase roles are expected in a
# bare container and say nothing about the data. Anything else is a real
# finding and the whole point of running this.
grep -vE 'must be owner of extension|role "[^"]+" does not exist|extension "[^"]+" (already exists|is not available)|schema "(auth|storage|graphql|extensions|realtime|vault|supabase_[a-z_]+)" (already exists|does not exist)' \
  "$WORKDIR/restore.err" | grep -E '^pg_restore: error' > "$WORKDIR/real.err" || true

if [ -s "$WORKDIR/real.err" ]; then
  echo "!! restore reported errors that are not the expected Supabase noise:"
  cat "$WORKDIR/real.err"
  echo "!! REHEARSAL FAILED — this backup is not proven restorable."
  exit 1
fi

echo "==> counting rows in the tables that matter"
# A restore that produces empty tables exits 0. Row counts are the only thing
# that distinguishes "restored" from "created the schema".
#
# Real COUNT(*), not pg_stat_user_tables.n_live_tup: that column is a
# stats-collector estimate and reads 0 on a freshly restored table until
# something ANALYZEs it, which would fail every rehearsal for the wrong reason.
: > "$WORKDIR/counts.txt"
for table in Account Membership Church Activity; do
  count=$(docker exec "$CONTAINER" psql -U postgres -d rehearsal -tA \
    -c "SELECT count(*) FROM public.\"${table}\";" 2>/dev/null || echo "MISSING")
  echo "${table} ${count}" | tee -a "$WORKDIR/counts.txt"

  if [ "$count" = "MISSING" ]; then
    echo "!! ${table} does not exist after restore"
    echo "!! REHEARSAL FAILED"
    exit 1
  fi
  if [ "$count" -eq 0 ]; then
    echo "!! ${table} restored with zero rows — the dump is not usable"
    echo "!! REHEARSAL FAILED"
    exit 1
  fi
done

echo
echo "==> REHEARSAL PASSED — $SOURCE restores into a working database."
echo "    Record the date on #42; an untested backup is a hypothesis."
