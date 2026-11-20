#!/usr/bin/env bash
# Board (left) and Flutter screen (right) side by side. See SHOTS.md.
# usage: compare.sh <Stem> [tweak=value ...] [--route /Stem/child] [--width W --height H] [--click TEXT | --type TEXT | --wait MS]... [--ms N]
source "$(dirname "$0")/shot_common.sh"
parse_args "$@"
[[ -z "$OUT" ]] || { echo "compare.sh: --out is not supported; outputs go to build/shots/{board,app,pair}" >&2; exit 2; }
name="$(shot_name)"
TOOL="$PROTO/tool"

# --route only applies to the app; the board side always shows the board.
common=("$STEM" ${TWEAKS[@]+"${TWEAKS[@]}"} --width "$WIDTH" --height "$HEIGHT")
bargs=("${common[@]}" --out "$PROTO/build/shots/board/$name.png")
aargs=("${common[@]}" --out "$PROTO/build/shots/app/$name.png")
for c in ${CLICKS[@]+"${CLICKS[@]}"}; do bargs+=(--click "$c"); aargs+=(--click "$c"); done
[[ -n "$ROUTE" ]] && aargs+=(--route "$ROUTE")
[[ -n "$MS" ]] && { aargs+=(--ms "$MS"); bargs+=(--ms "$MS"); }

# Both sides at once; each reports its own problems on stderr.
brc=0 arc=0
"$TOOL/board_shot.sh" "${bargs[@]}" > /dev/null & bpid=$!
"$TOOL/app_shot.sh" "${aargs[@]}" > /dev/null || arc=$?
wait $bpid || brc=$?
board="$PROTO/build/shots/board/$name.png" app="$PROTO/build/shots/app/$name.png"
[[ -s "$board" && -s "$app" ]] || { echo "compare.sh: a side is missing, no pair" >&2; exit 1; }

pair="$PROTO/build/shots/pair/$name.png"
mkdir -p "$(dirname "$pair")"
dir="$(mktemp -d "${TMPDIR:-/tmp}/dc-pair.XXXXXX")"
trap 'rm -rf "$dir"' EXIT
gap=16 label=28
cat > "$dir/pair.html" <<EOF
<!doctype html><meta charset="utf-8">
<style>body{margin:0;background:#9aa39f;display:flex;gap:${gap}px;font:600 14px/${label}px system-ui,sans-serif;color:#13201C}
div{display:flex;flex-direction:column;width:${WIDTH}px}span{padding-left:8px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}img{display:block;width:${WIDTH}px;height:${HEIGHT}px}</style>
<div><span>board · $name</span><img src="file://$board"></div><div><span>app</span><img src="file://$app"></div>
EOF
chrome --window-size="$((WIDTH * 2 + gap)),$((HEIGHT + label))" --virtual-time-budget=1000 --screenshot="$pair" "file://$dir/pair.html" || true
[[ -s "$pair" ]] || { echo "compare.sh: Chrome wrote no pair image" >&2; exit 1; }
printf '%s\n%s\n%s\n' "$board" "$app" "$pair"
exit $((brc || arc))
