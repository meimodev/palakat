# Prototype conventions

These rules are fixed. Every spec in `docs/build/` and every line of the prototype follows them. Where a spec seems to disagree, this file wins; where this file and the board source disagree on what the screen shows, the board wins.

## What is being built

A clickable prototype of every board on the Palakat design canvas (199 boards), in Flutter, with mock data only. No backend, no network calls, no persistence beyond the running session. It must look, move and navigate exactly as the boards do.

## Sources, in order of authority

| What | Where | Wins on |
| --- | --- | --- |
| Board source (one HTML file per artboard) | `docs/design/handoff/canvas/boards/<Stem>.dc.html` | Layout, copy, states, interactions, motion, links |
| Board index (frame size, title, canvas page) | `docs/design/handoff/canvas/canvas.json` | Form factor, title |
| Tokens | `docs/design/handoff/tokens/palakat_tokens.dart`, `palakat-tokens.json` | Colour, type, radius, spacing, motion values |
| Component guidelines and previews | `docs/design/handoff/design-system/components/<Name>/` | Component look and rules |
| Handoff text | `docs/design/handoff/01-foundations.md` … `05-master-file-update.md` | Rules, glossary, decisions |
| Mechanical manifest | `docs/build/board-manifest.json` | Tweaks, links, keyframes, inbound links per board |

The canvas copy of the tokens (`project/ds/palakat/tokens.json` on the canvas) holds old values for `putus` and `garisTegas`. Ignore it. The handoff tokens are current: `putus` #808D87, `garisTegas` #7F8C86 (decision C02, C03).

### How to read a board file

A board is HTML inside `<x-dc>…</x-dc>` plus a logic class in `<script type="text/x-dc">`:

- `{{name}}` is a value returned by `renderVals()` in the logic class. Read the class to know what it is.
- `<sc-if value="{{flag}}">` shows its content only when `flag` is true. `<sc-for list="{{items}}" as="x">` repeats.
- `onClick="{{handler}}"` binds a handler from `renderVals()`. `state = {…}` is the board's initial state; `setState` changes it.
- `data-props='{…}'` on the script tag declares the board's tweaks (states switched on the canvas). `$preview` is the frame size.
- `<a href="Other.dc.html">` is a link to another board.
- Inline `style="…"` values are exact. Copy them.
- Many web boards share a helper `tukarJk(...)`: when `jabatanKosong` is on, it swaps "Meiske L." for "Yanti Sumual, Operator" in strings dated 16/11/2026. Reproduce that effect where the board enables it (`if (jk && true)`), not where it is disabled (`if (jk && false)`).

## Stack

- Flutter 3.47 (the machine's `fvm` default), Dart 3. Project at `prototype/`, package name `palakat_prototype`.
- Targets: web (Chrome, the primary review target), iOS and Android.
- Dependencies: `go_router` and `flutter_svg` (the icons are inline SVG drawn one by one on the boards; render the board's own path data rather than redrawing it), plus `flutter_test`. No state-management package, no `intl`, no `google_fonts`, no `dotted_border`: dashed and dotted lines come from one shared painter.
- Fonts bundled as assets under `prototype/assets/fonts/`, static TTFs only (no variable fonts: Flutter does not map `fontWeight` onto a `wght` axis): Plus Jakarta Sans 400, 500, 600, 700 (`PlusJakartaSans-Regular/Medium/SemiBold/Bold.ttf` from github.com/tokotype/PlusJakartaSans, `fonts/ttf`) and IBM Plex Mono 400, 500, 600 (`IBMPlexMono-Regular/Medium/SemiBold.ttf` from github.com/IBM/plex, `packages/plex-mono/fonts/complete/ttf`). Each file is declared with its weight in `pubspec.yaml` under the families `PlusJakartaSans` and `IBMPlexMono` (the names `PalakatText.sans` and `.mono` use). Both are SIL OFL; keep the licences next to them as `OFL-PlusJakartaSans.txt` and `OFL-IBMPlexMono.txt`.
- `flutter analyze` clean; `dart format` applied.

## Project layout

```
prototype/
  lib/
    main.dart                 app, router, theme
    router.dart               one GoRoute per board, generated from the board list
    boards.dart               the board registry: stem, title, canvas page, form, tweaks
    theme/                    palakat_tokens.dart (copied), PalakatWarna ThemeExtension, TextTheme
    widgets/                  the 31 design-system components and shared primitives
    shell/                    phone tab bar, web side nav, device frame, A4 page, prototype panel
    motion/                   the named animations (tinta, cap, segel, kait, …)
    mock/                     seed data and formatters
    screens/<pageId>/<snake_stem>.dart   one file per board
  test/
  assets/fonts/
```

`<pageId>` is the board's canvas page id: `ponsel`, `web`, `sistem`, `lanjut`, `lengkap`, `a4`, `a4s`, `a4t`, `p2`, `p3`, `p4`, `p5`.

## One route per board

- Path `/<Stem>`, where Stem is the file name without `.dc.html`: `Main.dc.html` → `/Main`, `WebBeranda.dc.html` → `/WebBeranda`.
- Widget `class <Stem>Screen` in `lib/screens/<pageId>/<snake_case_stem>.dart` (`WebBeranda` → `web_beranda.dart`).
- A full-screen view inside a board (for example the Catat form inside `Main`) is a child route `/<Stem>/<sub>`, `<sub>` a short lowercase Indonesian name taken from the board (`/Main/catat`, `/Main/periksa`). A bottom sheet or side panel is not a route.
- Every `<a href="X.dc.html">` becomes navigation to `/X`. Use `push` for a drill-in that the board pairs with a back control or a breadcrumb, `go` for a tab or side-nav change. System and browser Back must work everywhere.
- A link built in JavaScript (side-nav arrays, list rows) counts the same as an `<a>`.
- Build every control that navigates to another board with the shared `Tautan(ke: '<TargetStem>', …)` helper (it decides push or go and wraps the child as a 44 px target). The link test reads the screen files and checks every manifest link of the board appears as `Tautan(ke: '…')`.
- `lib/boards.dart` and `lib/router.dart` are generated from `canvas.json` and `board-manifest.json` by `prototype/tool/gen_boards.py`. Do not hand-edit them; re-run the generator.

## Form factors

| Board frame | Form | How it renders |
| --- | --- | --- |
| 390 × 844 | Phone | Full screen on a phone. On a window wider than 600 px, centred in a 390 × 844 device frame (corner radius 36) on a neutral backdrop, content scrolls inside the frame |
| 1440 × 1000–1300, `expand: fill` | Laptop page | Fluid, fills the window, scrolls as a page. Side nav plus content; below 860 px the side nav collapses behind a "Menu" button (the boards' `.pn` CSS shows exactly how) |
| 834 × 1112, `expand: fill` | Tablet | Fluid like a laptop page; drawn for 834 wide |
| 794 × 1123 or 1123 × 794 | A4 page | Fixed-size white page centred on `kertas`, scaled down to fit narrower windows, scrolls |
| 1280–1760 wide, no `expand` | Sheet (maps, decisions) | Fixed-size, scrolls both ways, links clickable |

## Theme

- Copy `palakat_tokens.dart` into `lib/theme/`. Build one `ThemeExtension<PalakatWarna>` with a light and a dark instance from `PalakatColors` and `PalakatColorsGelap`. Widgets read `context.warna.<token>`. No hex literal outside `lib/theme/`; the three illustration colours listed below live there too.
- Text styles from `PalakatText`; `sans` = Plus Jakarta Sans, `mono` = IBM Plex Mono. Every money figure and code (No. Bukti, No. MA, IDs) is mono.
- The screens are drawn light. The prototype panel switches Terang/Gelap; dark must stay legible, but dark is not checked against boards.

### Board hex → token

| Hex in board | Token |
| --- | --- |
| #F3F5F1 | `kertas` |
| #FFFFFF | `permukaan` as a background; `diLaut` as text or icon on `laut`; `diBata` on `bata`; `permukaan` as text on `tinta` |
| #13201C | `tinta` |
| #43514C | `tinta2` |
| #5E6A66 | `tinta3` |
| #808D87 | `putus` (lines only) |
| #DDE2DB | `garis` |
| #7F8C86 | `garisTegas` |
| #0E5A63 | `laut` |
| #0A4249 | `lautTua` |
| #E1EEED | `lautLembut` |
| #A63C1C | `bata` |
| #F8E8E0 | `bataLembut` |
| #EAF0EC | `diTinta` |
| #D5DDD8 | `diTinta2` |

Three colours are illustration only: #86B5B8 (third peruntukan segment: Awal, Bagi, WebBagi, AlihPeruntukan, WebAlihPeruntukan), #FBFAF6 (receipt paper: Kamera, LihatDokumen, WebLihatDokumen, WebUnggah), #C9DAD9 (answer-card rule: Cari, WebCari), kept as `PalakatIlustrasi` constants in lib/theme/.

### Off-token sizes

Boards use some radii and sizes outside the tokens (radius 10 on side-nav items, 18 on AI panels, 8 and 4 on small marks; font 17, 19, 20, 24, 32, 34, 36 px in places). Copy the board value. Twelve places use 12 px text, which breaks the "no text below 13" rule: use 13 and list the place in the spec's notes.

## Prototype chrome (not part of the app)

The app screens show only what the app would show. Everything that exists only to demonstrate the design lives in the **Keadaan panel**, a floating control available on every board (outside the device frame on wide windows, a small handle at the screen edge on phones):

- The board's tweaks, with the exact names, options and defaults from its `data-props`.
- Global switches: `jabatanKosong` (one switch for all boards that have it: the Operator Yanti Sumual runs the vacant Bendahara Jemaat post), Terang/Gelap, reduce motion, phone frame on/off.
- The prototype devices the handoff says not to build (`03-screens-and-flows.md`, "Prototype devices"): "Dilihat sebagai" chips, buttons starting with "Contoh:", the accepted code 123456, and "Di prototipe ini: …" hints. Show them here, labelled, never inside the screen.
- Links: "Semua layar" (the launcher), the board's inbound links, and its canvas title.

The launcher at `/` lists every board twice: by canvas page in canvas order, and by role journey (the "Journeys by role" list in `03-screens-and-flows.md`). Boards nothing links to (maps, A4 pages, tablet, loading states) are reached from here.

Tweak values live in memory for the session: a `PrototypeState` (`ChangeNotifier`) holds the global switches and a map `stem → {tweak: value}`, defaulting to each board's `data-props` default.

## Behaviour

- Each board keeps its own interaction state, as on the canvas. Reproduce every handler of the board's logic class: typed input and its formatting, conditions of `TombolBersyarat`, refusals, sheets, toasts, step changes.
- A `setTimeout` that fakes progress (upload, AI, saving, generating) becomes a `Timer` (dart:async) with the same milliseconds, cancelled in dispose.
- Mock data is shared Dart constants in `lib/mock/`. A screen shows exactly the figures its board shows. Where two boards show different figures for the same thing, each screen keeps its own board's figure; `docs/build/mock-data.md` lists these.
- Rupiah formatter: `rp(-15000)` → `−Rp15.000` (U+2212, dot thousands, no decimals). Dates `06/10/2026` in tables and inputs, `6 Oktober 2026` in sentences, time `11.05`. Not known is `—`.
- Copy is verbatim from the board, Bahasa Indonesia, including `·`, `—`, `−`, `··4821`, curly quotes.

## Motion

Named motions from the tokens, curve `Cubic(0.2, 0.8, 0.2, 1)`: `sentuh` 160 ms, `pindahLayar` 280 ms, `kait` 450 ms, `tinta` 700 ms, `segelTahan` 1600 ms, `segel` 900 ms. The boards' CSS keyframes (`muncul`, `masuk`, `naik`, `pudar`, `cap`, `sapu`, `isi`, `titik`, `gelap`, `lingkar`, `putar`, `kait`, `dariKanan`, `dariKiri`, `balik`, `tali`, `denyut`, `turun`, `kilat`) each map to one Flutter implementation in `lib/motion/`, specified in `docs/build/motion.md`. When reduce motion is on (system setting or panel), every animation completes instantly and pulsing stops.

## Accessibility

- Every pressable target at least 44 × 44. Labels of checkboxes and radios are part of their target.
- `aria-label` on a board becomes a `Semantics` label. `role="status"`/`role="alert"` become live-region semantics.
- Keyboard focus on web: solid 2 px `laut` outline, 2 px offset.
- A disabled action always shows its reason in full-contrast text next to it.

## Definition of done for one board

1. Route `/<Stem>` opens it; it renders without overflow at its frame size and, for laptop pages, at 860 and 1280 wide.
2. Every element, string and state in its spec is present; every tweak is in the Keadaan panel and changes the screen as specified.
3. Every handler works; every link goes where the spec says; Back returns.
4. Its motions run as specified and stop under reduce motion.
5. Colours come from tokens only.
6. Its acceptance checks in `docs/build/screens/` pass.

## Settled conflicts between specs

The spec verifiers flagged places where the shared documents disagree. These rulings apply everywhere:

- **Board parity by default.** Where a screen spec "recommends" behaviour the board does not have (resetting state on a tweak change, wiring a checkbox the board leaves unwired, cancelling a timer the board keeps), build the board's behaviour. Only the deviations listed in this file are applied; log any other recommendation in `docs/build/review-log.md` for the product owner.
- **Deviations that are applied:** 12 px text becomes 13 px; `TombolBersyarat` stays pressable and re-checks its condition on press (component guideline in `02-components.md`), even where the board sets `disabled`; prototype-only copy goes to the Keadaan panel; count-ups jump to the final figure under reduce motion.
- **Back is instant.** `motion.md` is the motion authority: a pop never plays the reverse transition, and entrances do not replay on Back. Where `navigation.md` says otherwise, `motion.md` wins.
- **Push or go.** For a board's own links, its screen spec wins over `navigation.md` §3.4. A button with an in-board effect is not a link, even if `navigation.md` lists it.
- **Inbound and out-links** come from `navigation.md`'s computed lists (they include links built in JavaScript that the manifest misses); `gen_boards.py` takes them from there.
- **Scroll on view change** inside a board: jump to top (a prototype choice shared by all specs).
