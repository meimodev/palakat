# Demo app conventions

These rules are fixed. Every spec in `docs/build/` and every line of the demo app in `prototype/` follows them. The build plan is `README.md`; where it decides something, it wins over this file. Where a spec seems to disagree, this file wins; where this file and the board source disagree on what the screen shows, the board wins.

## What is being built

The Palakat demo app (README.md, "Goal"): one Flutter app for Android phones, Android tablets and the web that runs every module on dummy data held in memory, behind repository interfaces shaped after the domain model, on shared Riverpod state. A persona picker is the only way in; the seed story moves with the real date; state resets on every launch (D6). There is no backend and no network call. The screens look, move and read as the boards draw them, but what one persona does on one screen shows on every other screen and for every other persona (D4).

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

## Stack

- Flutter 3.47.8 through fvm (`prototype/.fvmrc`), Dart 3. Project at `prototype/`, package name `palakat_prototype`.
- Targets: web (local dev, `fvm flutter run -d chrome`, `fvm flutter build web`) and a debug Android build (D15).
- Dependencies: exactly `flutter`, `flutter_riverpod` (state, D12; plain providers, no code generation), `go_router` and `flutter_svg` (the icons are inline SVG in one registry, `lib/widgets/ikon_data.dart`. The owner had the line icons redrawn for the demo app: simple, one thin 1.5 stroke on a 24 grid, round caps and corners, each matching what it stands for; the logo, the progress rings and the animated seal frames keep the boards' drawings), plus `flutter_test`. No `intl`, no `google_fonts`, no `dotted_border`: dashed and dotted lines come from one shared painter. Nothing that persists state (D6).
- Fonts bundled as assets under `prototype/assets/fonts/`, static TTFs only (no variable fonts: Flutter does not map `fontWeight` onto a `wght` axis): Plus Jakarta Sans 400, 500, 600, 700 (`PlusJakartaSans-Regular/Medium/SemiBold/Bold.ttf` from github.com/tokotype/PlusJakartaSans, `fonts/ttf`) and IBM Plex Mono 400, 500, 600 (`IBMPlexMono-Regular/Medium/SemiBold.ttf` from github.com/IBM/plex, `packages/plex-mono/fonts/complete/ttf`). Each file is declared with its weight in `pubspec.yaml` under the families `PlusJakartaSans` and `IBMPlexMono` (the names `PalakatText.sans` and `.mono` use). Both are SIL OFL; keep the licences next to them as `OFL-PlusJakartaSans.txt` and `OFL-IBMPlexMono.txt`.
- `fvm flutter analyze` clean; `dart format` applied (never to `lib/theme/palakat_tokens.dart`, which is copied from the handoff).

## Project layout

README §3.1 is the full layout. In short, under `prototype/`:

```
lib/
  main.dart                 runApp(ProviderScope(child: PalakatApp()))
  app/                      app.dart, tata.dart (layout choice), layar.dart (one Layar per screen),
                            router.dart (phone tree and web tree), belum_dipindah.dart (migration marker)
  core/                     format.dart, clock.dart, tanggal.dart
  domain/ data/             entities, repositories, in-memory store and seed (from M1)
  providers/                Riverpod providers: clock, layout, session, repositories, read models
  shell/                    product chrome: LayarPonsel, KepalaPonsel, PonselTabBar, HalamanWeb,
                            NavSamping, HalamanA4, Tautan, Toast
  screens/<pageId>/         the screen files, in the board's canvas-page folder; screens/pemilih/ the picker
  widgets/ motion/ theme/   design-system components, named motions, tokens and colours
  mock/                     the prototype's board data, until each milestone moves it into the seed (gone in M10)
test/flows/                 harness.dart and one flow test file per flow (README §8)
assets/fonts/
```

## Screens and routes

README §3.6 is the routing design and §7 the board → screen table; `lib/app/layar.dart` is its code.

- One `Layar` value per app screen, not per board. A twin pair (phone and web) and a static/Alur pair share one `Layar`; the comment above each value names the boards it replaces, and the comment block `Papan yang dibuang:` at the end names the dropped boards.
- Each `Layar` has a path (`/keuangan/catat`, `/draf/:id`), says which layouts have a screen for it (`ponsel`, `web`; the tablet uses the web tree) and its module.
- `router.dart` builds the phone tree for `Tata.ponsel` and the web tree for `Tata.web` and `Tata.tablet`, with the same paths. Every page is a sub-route of the role home `/`. Without a session every location shows the picker `/pilih`.
- A phone board with child routes keeps its `ShellRoute` + `<Stem>Kendali` (navigation.md 2.1) under its new path, with the same child path names. A bottom sheet or side panel is not a route.
- Every control that opens another screen is `Tautan(ke: Layar.x, param: {...}, anak: '…', cara: Cara.dorong | ganti | naik)` or a widget that wraps it (`Tombol(ke:)`, `KepalaPonsel(kembaliKe:)`, `NavSamping` items). No string paths in screen code: in-board navigation uses `context.dorongKe`, `gantiKe` and `naikKe` with a `Layar`. A `Tautan` to a `Layar` the current layout lacks fails an assert in debug, so a screen drawn for both layouts leaves such a link out (`adaLayar`). Use `dorong` for a drill-in that the board pairs with a back control or a breadcrumb, `ganti` for a tab or side-nav change, `naik` for back arrows and breadcrumbs. System and browser Back must work everywhere.
- The layout (`Tata`) is chosen once at launch in `lib/app/tata.dart`, the only file that reads `kIsWeb` or the platform.

## Form factors

| Board frame | Form | How it renders |
| --- | --- | --- |
| 390 × 844 | Phone | Full screen on an Android phone (`Tata.ponsel`). There is no device frame |
| 1440 × 1000–1300, `expand: fill` | Laptop page | Fluid, fills the window, scrolls as a page. Side nav plus content; below 860 px the side nav collapses behind a "Menu" button (the boards' `.pn` CSS shows exactly how) |
| 834 × 1112, `expand: fill` | Tablet | Fluid like a laptop page; drawn for 834 wide. Shown on an Android tablet (`Tata.tablet`) for the finance home, list and form; every other tablet screen is the laptop page |
| 794 × 1123 or 1123 × 794 | A4 page | Fixed-size white page centred on `kertas`, scaled down to fit narrower windows, scrolls |

## Theme

- Copy `palakat_tokens.dart` into `lib/theme/`. Build one `ThemeExtension<PalakatWarna>` with a light and a dark instance from `PalakatColors` and `PalakatColorsGelap`. Widgets read `context.warna.<token>`. No hex literal outside `lib/theme/`; the three illustration colours listed below live there too.
- Text styles from `PalakatText`; `sans` = Plus Jakarta Sans, `mono` = IBM Plex Mono. Every money figure and code (No. Bukti, No. MA, IDs) is mono.
- The screens are drawn light. Light and dark follow the system (`ThemeMode.system`); dark must stay legible, but dark is not checked against boards.

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

## Prototype chrome (removed)

The prototype's launcher, Keadaan panel, tweaks, device frame, journeys, reset machinery and component gallery are gone (README §6, D5). The screens show only what the app shows: no "Dilihat sebagai" chips, no "Contoh:" buttons, no accepted code 123456, no "Di prototipe ini" hints. Where a board fakes another person's step, the other persona does it after a sign-out and sign-in through the picker.

## Behaviour

- Shared state (D4): domain data lives only in the in-memory repositories (README §3.4, §4). Screens read it through providers; a widget or a surviving `Kendali` holds only UI state (form text, filters, an open sheet, a toast, the current step). Never change a provider while widgets are building: commands run in callbacks.
- Screens behave as the boards do: reproduce every handler of the board's logic class (typed input and its formatting, conditions of `TombolBersyarat`, refusals, sheets, toasts, step changes). Fixed sample outcomes and fake timers for AI, upload and similar work are fine (D4); a timer that fakes outside work keeps the board's milliseconds and carries `// tiruan: <what it fakes>` (README §3.7).
- Only real conditions are shown (D9): a board state that real data can reach is kept and read from state; a state only a fault could cause is dropped.
- Computed totals win (D11): screens show what the seed transactions add up to. Board figures are a guide, not a target, and there are no balancing rows.
- Dates come from the clock and the seed anchors (D8, README §5.3), never from literals.
- Rupiah formatter: `rp(-15000)` → `−Rp15.000` (U+2212, dot thousands, no decimals). Dates `dd/mm/yyyy` in tables and inputs, `6 Oktober` plus the year in sentences, time `11.05`. Not known is `—`.
- Copy is verbatim from the board, Bahasa Indonesia, including `·`, `—`, `−`, `··4821`, curly quotes.

## Motion

Named motions from the tokens, curve `Cubic(0.2, 0.8, 0.2, 1)`: `sentuh` 160 ms, `pindahLayar` 280 ms, `kait` 450 ms, `tinta` 700 ms, `segelTahan` 1600 ms, `segel` 900 ms. The boards' CSS keyframes (`muncul`, `masuk`, `naik`, `pudar`, `cap`, `sapu`, `isi`, `titik`, `gelap`, `lingkar`, `putar`, `kait`, `dariKanan`, `dariKiri`, `balik`, `tali`, `denyut`, `turun`, `kilat`) each map to one Flutter implementation in `lib/motion/`, specified in `docs/build/motion.md`. When reduce motion is on (the system setting, `MediaQuery.disableAnimations`), every animation completes instantly and pulsing stops.

## Accessibility

- Every pressable target at least 44 × 44. Labels of checkboxes and radios are part of their target.
- `aria-label` on a board becomes a `Semantics` label. `role="status"`/`role="alert"` become live-region semantics.
- Keyboard focus on web: solid 2 px `laut` outline, 2 px offset.
- A disabled action always shows its reason in full-contrast text next to it.

## Definition of done for one screen

1. Its flow tests pass (README §8.3), on every layout the flow names.
2. Every element, string and kept state in its spec is present, and each state comes from real state (no `belumDipindah`).
3. Every handler works; every link goes where the spec says; Back returns.
4. Its motions run as specified and stop under reduce motion.
5. Colours come from tokens only.
6. It renders without overflow at its frame size and, for laptop pages, at 860 and 1280 wide.

## Settled conflicts between specs

The spec verifiers flagged places where the shared documents disagree. These rulings apply everywhere:

- **Board parity by default.** Where a screen spec "recommends" behaviour the board does not have (resetting state on a tweak change, wiring a checkbox the board leaves unwired, cancelling a timer the board keeps), build the board's behaviour. Only the deviations listed in this file are applied; log any other recommendation in `docs/build/review-log.md` for the product owner.
- **Deviations that are applied:** 12 px text becomes 13 px; `TombolBersyarat` stays pressable and re-checks its condition on press (component guideline in `02-components.md`), even where the board sets `disabled`; prototype-only copy is dropped; count-ups jump to the final figure under reduce motion.
- **Back is instant.** `motion.md` is the motion authority: a pop never plays the reverse transition, and entrances do not replay on Back. Where `navigation.md` says otherwise, `motion.md` wins.
- **Push or go.** For a board's own links, its screen spec wins over `navigation.md` §3.4. A button with an in-board effect is not a link, even if `navigation.md` lists it.
- **Inbound and out-links** come from `navigation.md`'s computed lists (they include links built in JavaScript that the manifest misses), mapped to `Layar` values through README §7.2.
- **Scroll on view change** inside a board: jump to top (a prototype choice shared by all specs).
