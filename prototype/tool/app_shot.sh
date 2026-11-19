#!/usr/bin/env bash
# Screenshot the Flutter screen for a board via test/shot_test.dart. See SHOTS.md.
# usage: app_shot.sh <Stem> [tweak=value ...] [--route /Stem/child] [--out file.png] [--width W --height H] [--click TEXT]... [--ms N]
source "$(dirname "$0")/shot_common.sh"
parse_args "$@"
OUT="${OUT:-$PROTO/build/shots/app/$(shot_name).png}"
mkdir -p "$(dirname "$OUT")"
OUT="$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT")"

enc() { python3 -c 'import sys,urllib.parse as u; print(u.quote(sys.argv[1], safe=""))' "$1"; }
tw="" kl=""
for t in ${TWEAKS[@]+"${TWEAKS[@]}"}; do tw+="${tw:+&}${t%%=*}=$(enc "${t#*=}")"; done
for c in ${CLICKS[@]+"${CLICKS[@]}"}; do kl+="${kl:+|}$(enc "$c")"; done

rm -f "$OUT"
log="$(mktemp "${TMPDIR:-/tmp}/app-shot.XXXXXX")"
trap 'rm -f "$log"' EXIT
rc=0
(cd "$PROTO" && fvm flutter test test/shot_test.dart --no-pub \
  --dart-define=SHOT="$STEM" --dart-define=TWEAKS="$tw" --dart-define=ROUTE="$ROUTE" \
  --dart-define=KLIK="$kl" --dart-define=OUT="$OUT" --dart-define=W="$WIDTH" --dart-define=H="$HEIGHT" \
  ${MS:+--dart-define=MS="$MS"}) > "$log" 2>&1 || rc=$?

if [[ ! -s "$OUT" ]]; then cat "$log" >&2; echo "app_shot: no screenshot for $STEM" >&2; exit 1; fi
echo "$OUT"
if [[ $rc -ne 0 ]]; then
  grep -E 'KLIK:|^(The following|A Render|Expected|  Actual)|overflowed' "$log" | head -20 >&2
  echo "app_shot: the test reported the problem above (exception, overflow or KLIK miss); the PNG was still written" >&2
  exit 1
fi
