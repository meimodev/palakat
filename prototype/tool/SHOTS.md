# Visual-parity shots

Compare a Flutter screen with its design board, pixel for pixel at the board's frame size.

```sh
cd prototype
tool/compare.sh Main                          # board left, app right
tool/compare.sh Main gagalSimpan=true bulan=sepi
tool/compare.sh Kesiapan masukSebagai="Bendahara Komisi Diakonia"
tool/compare.sh Main --click Catat --click Belanja   # click by visible text, in order, on both sides
tool/compare.sh Main --route /Main/catat      # the app opens this route; the board shows the board
tool/board_shot.sh WebBeranda [tweak=value ...] [--out f.png] [--width W --height H] [--click T]... [--ms N]
tool/app_shot.sh   WebBeranda [tweak=value ...] [--route /Stem/x] [--out f.png] [--width W --height H] [--click T]... [--ms N]
tool/board_check.sh [Stem ...]                # render every board (or the given ones); report errors
```

`compare.sh` prints three paths and exits non-zero if either side reported a problem (the PNGs are still written):

```
build/shots/board/<name>.png   the board in headless Chrome
build/shots/app/<name>.png     the Flutter screen
build/shots/pair/<name>.png    side by side, labelled
```

`<name>` is `<Stem>`, then `__<tweak>-<value>` per tweak, `__route_<child>`, `__klik-<text>` per click and `__WxH` when the size is not the board's, with unsafe characters turned into `_`. Example: `Main__gagalSimpan-true.png`. `build/` is git-ignored.

Read the pair PNG with your image viewer (the Read tool shows PNGs). Look at the two halves; the frame size is identical, so positions line up.

## Arguments

- `tweak=value`: a board tweak from its `data-props` (the same names as `lib/boards.dart`). Booleans are `true`/`false`; enum values must be one of the options (quote values with spaces). An unknown tweak or value is an error on both sides, with the valid names listed.
- `--click TEXT` (repeatable): after the screen is up, click the first element whose text contains TEXT. Board: the first clickable element in document order (`button`, `a`, `label`, inputs, anything with an `onClick`) whose text, `aria-label` or `placeholder` contains it, else the deepest element containing it. App: `find.textContaining(TEXT)`, hit-testable first. A miss is reported and the shot shows the state before it. Clicking a link on the board navigates to that board (tweaks are not carried over).
- `--route /Stem/child`: app only; tweaks and frame size still come from `Stem`.
- `--width W --height H`: another frame size (both sides; the board also gets it as `$preview`).
- `--ms N`: wait before capture. Board: Chrome virtual-time budget (default 2500 + 1000 per click). App: fake time pumped before the clicks (default 2500; 1000 more after each click).

## How it works

**Board** (`board_shot.sh`): a temp dir holds links to every board, `tool/dc/support.js` and `assets/fonts/`; headless Chrome opens `file://…/<Stem>.dc.html?tweak=value&_w=W&_h=H&klik=a|b` at W×H, device scale 1, with `--force-prefers-reduced-motion` (the boards' own CSS then cuts animations to 0.01 ms, so end states are captured) and `--virtual-time-budget`, which runs the boards' own `setTimeout`/`setInterval` (count-ups, "menyimpan…") to completion instantly. The same run dumps the DOM; `support.js` marks `<html data-dc="ok">` once rendered, every click is done and fonts are ready, or `data-dc="error" data-dc-error="…"`, which the script prints. Errors also show as a red bar at the top of the shot.

**Fonts**: `support.js` drops the Google Fonts `<link>` and declares `@font-face` for 'Plus Jakarta Sans' (400–700) and 'IBM Plex Mono' (400–600) from `fonts/` next to it, i.e. the same TTFs Flutter bundles. Works offline and matches the app's glyphs.

**App** (`app_shot.sh` → `test/shot_test.dart`, skipped unless `--dart-define=SHOT=<Stem>`, so plain `fvm flutter test` stays fast): loads the real TTFs with `FontLoader`, sets the view to the frame size at devicePixelRatio 1, builds the app as in `main.dart` but without `BingkaiPerangkat` (no device frame, no Keadaan panel handle over the screen), with reduced motion on, goes to `/<Stem>` (or `--route`), pumps in 100 ms steps (never `pumpAndSettle`), and writes the root `RepaintBoundary` to PNG. An exception or overflow while building fails the test after the PNG is written; `app_shot.sh` prints the key lines. Each run compiles the test (≈5–10 s). Several runs at once in one checkout worked in testing.

**Pair**: composed by headless Chrome from a two-image HTML page (no ImageMagick on this machine).

## support.js, the board runtime

A stand-in for the canvas runtime the boards load as `./support.js` (not in the handoff). It implements what the 199 boards use:

- `<x-dc>` markup; `<helmet>` styles moved to `<head>`.
- `{{a.b}}` in text (always as text, never HTML) and attributes (stringified; `null`/`undefined` → empty, or the attribute is dropped when it is only the binding). `{{true}}`/`{{false}}`/numbers as literals.
- `disabled`, `checked`, `readonly`, `selected`, `hidden`, `open`, `required` as presence attributes; `aria-*` keep `"true"`/`"false"`. `value` on `input`/`textarea`/`select` and `checked` are also set as properties.
- `<sc-if value>` (JS truthiness) and `<sc-for list as>` (arrays; objects iterate their values; `$index` is available), nested, with outer names visible inside.
- `on*="{{fn}}"` → event listeners (`onClick`, `onChange`, `onPointerDown/Up/Leave`, any other `onX` → `x`). `onChange` on text inputs and textareas fires on every keystroke (React semantics); on checkboxes, radios and selects on `change`. Handlers get the native event (`e.target.value`, `e.target.checked`).
- `class Component extends DCLogic`: `this.props` (data-props defaults, query overrides, `$preview`), `state` (class field), `setState(obj | fn)` merges into the same state object synchronously and re-renders once per microtask, `forceUpdate`, `componentDidMount`, `componentWillUnmount` (on page hide), `renderVals()`. Direct `this.state.x = …` mutations show on the next render.
- Re-rendering rebuilds the DOM and restores focus and caret by element position, so typing keeps working.

## Known limits

- Re-rendering replaces the whole DOM: scroll positions inside scrolled panes, `<details>` open state and running CSS animations restart on every `setState`. The boards' initial render is unaffected.
- `--click` cannot type text, drag or hover; there is no typing step. For a typed state, change the board's state in a scratch copy, or open the board in a browser (copy the dir `board_shot.sh` builds) and type.
- Clicks are `element.click()`: no pointerdown/up, so press-and-hold controls (`onPointerDown`, two boards: TutupBuku, WebTutupBuku) cannot be driven.
- `sc-if` uses JS truthiness: an empty array is true. Matches every board as written; the original runtime's rule is unknown.
- Text is rendered by Chrome's and Flutter's own shapers: expect sub-pixel differences in glyph positioning and line breaking near the wrap width, not different fonts.
- The board side is what the canvas showed at mount; the app side honours `kurangiGerak` (reduced motion), so looping animations are compared at rest.
- The yellow double underline on app text means the widget has no `Material`/`DefaultTextStyle` ancestor; it is in the app (the `BelumDibangun` stubs show it), not the harness.
- `board_check.sh` checks rendering (JS errors, unreplaced `{{`, the ready marker) at default tweaks, not pixels. Last run: 199 of 199 boards ok; a one-off sweep of every non-default tweak option (323 renders) was also all ok.
- macOS paths: Chrome at `/Applications/Google Chrome.app` (override with `CHROME=`), `fvm`, `python3`, `perl`.
