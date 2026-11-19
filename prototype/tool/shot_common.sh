# Shared by board_shot.sh, app_shot.sh, compare.sh. Source it; see SHOTS.md.
# Parses: <Stem> [tweak=value ...] [--out F] [--width W --height H] [--click TEXT]... [--route /Stem/x] [--ms N]
set -euo pipefail

PROTO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO="$(cd "$PROTO/.." && pwd)"
CANVAS="$REPO/docs/design/handoff/canvas"
BOARDS="$CANVAS/boards"
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"

STEM="" OUT="" DEFW="" DEFH="" WIDTH="" HEIGHT="" ROUTE="" MS=""
TWEAKS=() CLICKS=()

parse_args() {
  [[ $# -ge 1 && "$1" != -* ]] || { echo "usage: $(basename "$0") <Stem> [tweak=value ...] [--out file.png] [--width W --height H] [--click TEXT]... [--route /Stem/child] [--ms N]" >&2; exit 2; }
  STEM="$1"; shift
  [[ -f "$BOARDS/$STEM.dc.html" ]] || { echo "no board $BOARDS/$STEM.dc.html" >&2; exit 2; }
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --out) OUT="$2"; shift 2 ;;
      --width) WIDTH="$2"; shift 2 ;;
      --height) HEIGHT="$2"; shift 2 ;;
      --click) CLICKS+=("$2"); shift 2 ;;
      --route) ROUTE="$2"; shift 2 ;;
      --ms) MS="$2"; shift 2 ;;
      *=*) TWEAKS+=("$1"); shift ;;
      *) echo "unknown argument: $1" >&2; exit 2 ;;
    esac
  done
  local wh
  wh="$(python3 -c 'import json,sys; b=json.load(open(sys.argv[1]))["boards"][sys.argv[2]+".dc.html"]; print(b["w"], b["h"])' "$CANVAS/canvas.json" "$STEM")"
  DEFW="${wh% *}" DEFH="${wh#* }"
  WIDTH="${WIDTH:-$DEFW}"; HEIGHT="${HEIGHT:-$DEFH}"
}

# <Stem>[__tweak-value][__route-x][__klik-text] (filesystem-safe), shared by both sides so pairs line up.
shot_name() {
  local n="$STEM" t c
  for t in ${TWEAKS[@]+"${TWEAKS[@]}"}; do n+="__${t%%=*}-${t#*=}"; done
  [[ -n "$ROUTE" && "$ROUTE" != "/$STEM" ]] && n+="__route${ROUTE#/"$STEM"}"
  for c in ${CLICKS[@]+"${CLICKS[@]}"}; do n+="__klik-$c"; done
  [[ "$WIDTH" != "$DEFW" || "$HEIGHT" != "$DEFH" ]] && n+="__${WIDTH}x${HEIGHT}"
  printf '%s' "$n" | LC_ALL=C sed -E 's/[^A-Za-z0-9._-]+/_/g' | cut -c1-180
}

# Headless Chrome with its own throwaway profile (safe to run many at once).
chrome() {
  local prof rc=0; prof="$(mktemp -d "${TMPDIR:-/tmp}/dc-chrome.XXXXXX")"
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=1 \
    --force-prefers-reduced-motion --allow-file-access-from-files --no-first-run --no-default-browser-check \
    --disable-extensions --mute-audio --user-data-dir="$prof" "$@" 2>/dev/null || rc=$?
  rm -rf "$prof"
  return $rc
}

# A temp dir holding links to every board, support.js and the bundled fonts; prints its path.
board_dir() {
  local d; d="$(mktemp -d "${TMPDIR:-/tmp}/dc-boards.XXXXXX")"
  ln -s "$BOARDS"/*.dc.html "$d/"
  ln -s "$PROTO/tool/dc/support.js" "$d/support.js"
  ln -s "$PROTO/assets/fonts" "$d/fonts"
  printf '%s' "$d"
}

# file:// URL of a board in dir $1 with tweaks, klik steps and size as the query.
board_url() {
  python3 - "$1" "$STEM" "$WIDTH" "$HEIGHT" ${TWEAKS[@]+"${TWEAKS[@]}"} -- ${CLICKS[@]+"${CLICKS[@]}"} <<'EOF'
import sys, urllib.parse as u
d, stem, w, h, *rest = sys.argv[1:]
i = rest.index('--'); tw, kl = rest[:i], rest[i+1:]
q = [tuple(t.split('=', 1)) for t in tw] + [('_w', w), ('_h', h)]
if kl: q.append(('klik', '|'.join(kl)))
print('file://' + u.quote(f'{d}/{stem}.dc.html') + '?' + u.urlencode(q, quote_via=u.quote))
EOF
}
