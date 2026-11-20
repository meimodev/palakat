#!/usr/bin/env bash
# Screenshot a design board with tool/dc/support.js in headless Chrome. See SHOTS.md.
# usage: board_shot.sh <Stem> [tweak=value ...] [--out file.png] [--width W --height H] [--click TEXT | --type TEXT | --wait MS]... [--ms N]
source "$(dirname "$0")/shot_common.sh"
parse_args "$@"
OUT="${OUT:-$PROTO/build/shots/board/$(shot_name).png}"
mkdir -p "$(dirname "$OUT")"
if [[ -z "$MS" ]]; then
  MS=2500
  for c in ${CLICKS[@]+"${CLICKS[@]}"}; do [[ "$c" =~ ^tunggu:([0-9]+)$ ]] && MS=$((MS + BASH_REMATCH[1])) || MS=$((MS + 1000)); done
fi

dir="$(board_dir)"
trap 'rm -rf "$dir"' EXIT
dom="$dir/dom.html"
rm -f "$OUT"
chrome --window-size="$WIDTH,$HEIGHT" --virtual-time-budget="$MS" --screenshot="$OUT" --dump-dom "$(board_url "$dir")" > "$dom" || true

[[ -s "$OUT" ]] || { echo "board_shot: Chrome wrote no screenshot for $STEM" >&2; exit 1; }
state="$(grep -o '<html[^>]*' "$dom" | grep -o 'data-dc="[^"]*"' || true)"
err="$(grep -o '<html[^>]*' "$dom" | grep -o 'data-dc-error="[^"]*"' | sed 's/&quot;/"/g; s/&lt;/</g; s/&gt;/>/g; s/&amp;/\&/g' || true)"
echo "$OUT"
if [[ -n "$err" || "$state" != 'data-dc="ok"' ]]; then
  echo "board_shot: $STEM did not render cleanly: ${err:-${state:-no data-dc marker (raise --ms?)}}" >&2
  exit 1
fi
