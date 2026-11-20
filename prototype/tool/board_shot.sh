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
url="$(board_url "$dir")"
win="$WIDTH"
if (( WIDTH < 500 )); then
  # Headless Chrome will not make a window narrower than 500: lay the board out
  # in an iframe of exactly WIDTH x HEIGHT in a 500-wide window (the shot is
  # 500 wide, the board in its left WIDTH px) and mirror the board's ready
  # marker onto this page for --dump-dom.
  win=500
  cat > "$dir/bingkai.html" <<EOF
<!doctype html><meta charset="utf-8">
<style>html,body{margin:0;background:#fff}iframe{display:block;border:0;width:${WIDTH}px;height:${HEIGHT}px}</style>
<iframe src="${url//&/&amp;}"></iframe>
<script>
var f = document.querySelector('iframe'), h = document.documentElement;
setInterval(function () {
  try {
    var b = f.contentDocument.documentElement;
    ['data-dc', 'data-dc-error'].forEach(function (a) {
      if (b.hasAttribute(a)) h.setAttribute(a, b.getAttribute(a));
    });
  } catch (e) {
    h.setAttribute('data-dc', 'error');
    h.setAttribute('data-dc-error', 'bingkai: ' + e.message);
  }
}, 50);
</script>
EOF
  url="file://$dir/bingkai.html"
fi
chrome --window-size="$win,$HEIGHT" --virtual-time-budget="$MS" --screenshot="$OUT" --dump-dom "$url" > "$dom" || true

[[ -s "$OUT" ]] || { echo "board_shot: Chrome wrote no screenshot for $STEM" >&2; exit 1; }
state="$(grep -o '<html[^>]*' "$dom" | grep -o 'data-dc="[^"]*"' || true)"
err="$(grep -o '<html[^>]*' "$dom" | grep -o 'data-dc-error="[^"]*"' | sed 's/&quot;/"/g; s/&lt;/</g; s/&gt;/>/g; s/&amp;/\&/g' || true)"
echo "$OUT"
if [[ -n "$err" || "$state" != 'data-dc="ok"' ]]; then
  echo "board_shot: $STEM did not render cleanly: ${err:-${state:-no data-dc marker (raise --ms?)}}" >&2
  exit 1
fi
