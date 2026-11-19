#!/usr/bin/env bash
# Renders every board (or the stems given) with tool/dc/support.js in headless Chrome
# and reports any with a JS error, an unreplaced {{ or no "rendered" marker. See SHOTS.md.
# usage: board_check.sh [Stem ...]     env: JOBS (default 6)
source "$(dirname "$0")/shot_common.sh"

if [[ "${1:-}" == --one ]]; then # internal: one board → "<Stem>\t<status>\t<detail>"
  STEM="$3"; dom="$(chrome --window-size=1440,1000 --virtual-time-budget=2500 --dump-dom "file://$2/$STEM.dc.html" || true)"
  html="$(grep -o '<html[^>]*' <<<"$dom" | head -1 || true)"
  err="$(grep -o 'data-dc-error="[^"]*"' <<<"$html" | sed 's/&quot;/"/g; s/&lt;/</g; s/&gt;/>/g; s/&amp;/\&/g' || true)"
  miss="$(grep -o 'data-dc-missing="[^"]*"' <<<"$html" || true)"
  # {{ anywhere outside <script> (the logic class may legitimately contain it)
  braces="$(perl -0pe 's/<script\b.*?<\/script>//gs' <<<"$dom" | grep -c '{{' || true)"
  if [[ -z "$dom" ]]; then st=FAIL; d="no DOM (Chrome failed)"
  elif [[ -n "$err" ]]; then st=FAIL; d="$err"
  elif [[ "$braces" != 0 ]]; then st=FAIL; d="unreplaced {{ on $braces line(s)"
  elif ! grep -q 'data-dc="ok"' <<<"$html"; then st=FAIL; d="no data-dc=ok marker"
  else st=ok; d="$miss"; fi
  printf '%s\t%s\t%s\n' "$STEM" "$st" "$d"
  exit 0
fi

dir="$(board_dir)"
trap 'rm -rf "$dir"' EXIT
if [[ $# -gt 0 ]]; then printf '%s\n' "$@"; else (cd "$BOARDS" && ls *.dc.html | sed 's/\.dc\.html$//'); fi |
  xargs -P "${JOBS:-6}" -I{} bash "$0" --one "$dir" {} > "$dir/result.tsv" || true

sort "$dir/result.tsv" | awk -F'\t' '
  $2 != "ok" { print "FAIL  " $1 ": " $3; bad++ }
  $2 == "ok" && $3 != "" { warn = warn "  note  " $1 ": unbound names " $3 "\n" }
  END { printf "%s", warn; printf "%d boards, %d ok, %d failed\n", NR, NR - bad, bad; exit bad > 0 }'
