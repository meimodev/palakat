# Palakat prototype: build plan

18 November 2026. The plan for building every board of the Palakat design as one clickable Flutter prototype with mock data. It is written so an autonomous build run (a goal) can execute it end to end and check itself.

## Goal

Copy this block as the goal for the build run.

> Build the Palakat clickable prototype described in `docs/build/README.md`, following `docs/build/CONVENTIONS.md`. Every one of the 199 boards in `docs/design/handoff/canvas/canvas.json` must exist as its own route in the Flutter app at `prototype/`, look like its board source (`docs/design/handoff/canvas/boards/<Stem>.dc.html`) and its spec (`docs/build/screens/*.md`), behave as the board's logic class does, run the board's animations, and link to every board its source links to. Mock data only, no backend. Work milestone by milestone (M0 to M9 below). The goal is met when every check in "Definition of done for the whole prototype" passes: `fvm flutter analyze` is clean, `fvm flutter test` passes (registry, routes at every frame size and tweak, link coverage, component and formatter tests), `fvm flutter build web --release` succeeds, and the review pass in M9 finds no board that differs from its source.

## What is in `docs/build/`

| File | What it is | Use it when |
| --- | --- | --- |
| `CONVENTIONS.md` | Fixed architecture: stack, layout, routes, form factors, theme, prototype panel, behaviour, motion, accessibility | Always. It wins over everything else in this folder |
| `screens/01-…md` to `screens/23-…md` | One spec section per board: layout, views, tweaks, handlers, motion, links, mock data, acceptance checks | Building a screen |
| `components.md` | The 31 design-system components, shared primitives, app chrome, icons, as Flutter widgets | M1, M2 |
| `motion.md` | Every animation on the boards and its Flutter implementation | M1, and any screen with motion |
| `navigation.md` | Shells, side-nav variants, the route table for all 199 boards, the link graph, the launcher | M2, and wiring every screen |
| `mock-data.md` | Data model and seed values, including where boards disagree | M0, M1, every screen |
| `rules-checklist.md` | Every product and design rule as a check | Every review |
| `board-manifest.json` | Generated per board: frame, tweaks, links, inbound links, keyframes, timers | Generating the registry; tests |
| `icon-inventory.json` | Generated: the distinct inline SVG icons on the boards | M1 |

The design itself is in `docs/design/handoff/` (the handoff package, the canvas board sources, the design-system component previews and the tokens).

## Scope

In scope: all 199 boards, every state the canvas can switch to (tweaks), every interaction drawn on a board, every link between boards, both form factors as drawn, the named motions, light theme as drawn and a working dark theme.

| Canvas page | Boards |
| --- | --- |
| Ponsel (finance round 1, phone) | 9 |
| Web (finance round 1, laptop and tablet) | 12 |
| Peta dan keputusan (maps and decisions) | 4 |
| Keuangan · P2 dan P3 | 19 |
| Pelengkap | 61 |
| A4 · Laporan resmi, sementara, TERBATAS | 7 |
| Putaran 2 · Kerangka platform | 26 |
| Putaran 3 · Sekretariat (includes A4 Warta Jemaat) | 21 |
| Putaran 4 · Data jemaat | 18 |
| Putaran 5 · Kolaborasi | 22 |
| **All** | **199** |

Out of scope: a backend, real sign-in, real SMS or WhatsApp codes, real AI calls, real camera capture, real file upload or download, real PDF or Excel files, push notifications, persistence across reloads. Where a board shows these, the prototype fakes them exactly as the board does (timers, sample results), and nothing leaves the device.

## Approach, in one paragraph

One Flutter app, one route per board (`/<Stem>`), so the prototype maps one to one onto the canvas and every link and test is mechanical. Each board is its own screen widget with its own state, as each artboard is on the canvas; shared seed data keeps names and figures consistent. A launcher lists every board; a floating Keadaan panel switches each board's states and holds everything the handoff says is prototype-only, so the screens themselves stay exactly as the app would show them. Phone boards render in a device frame on wide windows; laptop boards are fluid pages; A4 boards are fixed pages. All 199 routes exist from the first milestone as stubs, so later work only replaces stub files and never touches shared wiring, which lets screen groups be built in parallel.

## Milestones

Each milestone ends with its checks passing. Build in this order; within M3 to M8 the screen files are independent and can be built in parallel (see "Working in parallel").

### M0 · Scaffold

1. `fvm flutter create --platforms web,ios,android --org id.palakat --project-name palakat_prototype prototype`. Add `go_router` and `flutter_svg`. Fonts (CONVENTIONS, Stack): static TTFs `PlusJakartaSans-Regular/Medium/SemiBold/Bold.ttf` from github.com/tokotype/PlusJakartaSans (`fonts/ttf`) and `IBMPlexMono-Regular/Medium/SemiBold.ttf` from github.com/IBM/plex (`packages/plex-mono/fonts/complete/ttf`), copied to `prototype/assets/fonts/` and each declared with its weight (400, 500, 600, 700) under the families `PlusJakartaSans` and `IBMPlexMono` in `pubspec.yaml`. Copy each repo's SIL OFL licence next to them: `OFL.txt` from tokotype/PlusJakartaSans saved as `OFL-PlusJakartaSans.txt`, `packages/plex-mono/LICENSE.txt` from IBM/plex saved as `OFL-IBMPlexMono.txt`. No variable fonts: Flutter does not map `fontWeight` onto a variable font's `wght` axis, so every weight would render the same.
2. Copy `docs/design/handoff/tokens/palakat_tokens.dart` into `lib/theme/`. Build `PalakatWarna` (light and dark), the text theme and context extensions (`components.md`, Theme layer).
3. Write `prototype/tool/gen_boards.py`. It reads `docs/design/handoff/canvas/canvas.json`, `docs/build/board-manifest.json` and the `json computed-links` (3.3) and `json child-routes` (2.2) blocks of `docs/build/navigation.md`. Manifest keys and link values are file names: strip `.dc.html`. Per board, `outLinks = links ∪ jsLinks ∪ computed − self`, where AIBulan's `jsLinks` count as empty (dead, navigation.md 3.2); `inbound` = the reverse of `outLinks` over all boards (not the manifest's `inbound`). That gives 1282 links and the Out and In counts of navigation.md 2.2. It generates `lib/boards.dart` (stem, title, pageId, form, frame size, tweaks with options and defaults, `outLinks`, `inbound`) and `lib/router.dart`: one `GoRoute` per board, and for each of the 17 boards in `json child-routes` a `ShellRoute` with builder `<Stem>Kendali(child: child)` around `/<Stem>` and its child routes, each child built and animated as navigation.md 2.1 states. Run it; commit both generated files. Re-run whenever the `json child-routes` block changes (a spec that adds a child route adds it to the block first).
4. Generate a stub screen file for every board at `lib/screens/<pageId>/<snake_stem>.dart`: a `<Stem>Screen` showing the canvas title and "Belum dibangun". Also stub `<Stem>Kendali` (a `StatefulWidget` that returns `child`) and the `anak` and `param` parameters of `<Stem>Screen` for the 17 boards with child routes (navigation.md 2.1). The router imports every stub. `gen_boards.py` derives `<snake_stem>` with exactly `snake = re.sub(r'(?<=[a-z0-9])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])', '_', stem).lower()`, which keeps acronyms whole (`AIFoto` → `ai_foto.dart`, `WebAI` → `web_ai.dart`, `BantuanAI` → `bantuan_ai.dart`, `A4F02a` → `a4_f02a.dart`, `WebBeranda` → `web_beranda.dart`) and matches every screen path the specs name. Do not split on each capital (that gives `a_i_foto.dart`).
5. Build the form-factor wrappers (device frame, laptop page, tablet, A4 page, sheet), the launcher at `/` (by canvas page and by role journey, `navigation.md`), the `PrototypeState` and the Keadaan panel showing each board's tweaks from the registry.
6. Mock data skeleton and formatters (`mock-data.md`): `rp()`, dates, time, `—`.

Checks: `flutter analyze` clean; `test/registry_test.dart` (199 boards, titles, forms and tweaks match `canvas.json` and the manifest); `test/routes_test.dart` (every route builds without exceptions at its frame size); `test/format_test.dart` (`rp(-15000) == '−Rp15.000'`, `rp(1250000) == 'Rp1.250.000'`, dates and time); the app runs in Chrome and every launcher entry opens its stub.

### M1 · Design system, icons, motion

1. Shared primitives: `GarisBorder`/`GarisPainter` (solid, dashed `putus`, dotted `laut`), the rupiah and date input formatters, `PalakatIkon` and the logo (`components.md`).
2. The 31 components in `lib/widgets/`, each with every variant (`components.md`).
3. The motion library in `lib/motion/` (`motion.md`), honouring reduce motion.
4. A gallery route `/_komponen` (launcher entry "Komponen") showing every component and variant, in both themes side by side, mirroring the design-system previews in `docs/design/handoff/design-system/components/*/preview.html`.

Checks: a widget test per component covering each variant (status → line style and colours; TombolBersyarat shows the first unmet reason only after input starts and re-checks on press; hold button cancels if released early); motion tests that each named motion has the token duration and completes instantly under reduce motion; visual comparison of `/_komponen` with the previews.

### M2 · Shells and navigation

1. Phone shells: bottom tab bar, header with back, save status; web side nav in every variant with the below-860 px drawer; tablet nav (`navigation.md`, `components.md`).
2. The `Tautan` helper: every control that navigates to another board is built with `Tautan(ke: '<TargetStem>')` (push or go per `navigation.md`), so link coverage can be checked from source.
3. Global `jabatanKosong`: the phone one-line banner and web banner, driven by the panel switch, on every board that has the tweak.

Checks: `test/links_test.dart`: expected = `outLinks` from `boards.dart` (navigation.md 3.1). A target is present when the screen file contains `ke: '<T>'`, `kembaliKe: '<T>'` or `keBagi: '<T>'` as a literal, or `item: nav<Name>` whose list contains T, or `PonselTabBar(` (TutupBuku, Lainnya, and Main on lainnya.dart). This test is expected to fail until M8 and must pass at the end. Side-nav and tab bar widget tests at 1440, 860 and 390 wide.

### M3 · Finance core (screens 01–04)

`screens/01-main.md`, `02-awal.md`, `03-webrekonsiliasi.md`, `04-lainnya.md`: Harian (Main), Tutup buku, Pengaturan awal and saldo awal, Koreksi, Web Beranda and Transaksi, Rekonsiliasi, Laporan, Hitung kas, Bagi, Lainnya, Mata Anggaran, Bendahara, Pengaturan, Persembahan. These carry the main motions (Bukukan, Cocokkan, Tutup buku); build them first.

### M4 · Finance extended (screens 05–13)

`screens/05-kewajiban.md` to `13-tabberanda.md`: Uang Muka and Titipan, restricted access, second checker, AI help, report pack, voucher list, import, export, documents, drafts, incidents, report format approval, setup lists, refunds, notifications, sign-in, search, approvals, statement entry, Alih peruntukan, settings changes, month picker, recovery, cases, handover, connection and session states, camera, document viewer, A4 report pages, decisions sheet, dates, report drill-down, AI suggestions, upload, Excel samples, loading states, account and sign-out, tablet boards, the platform map, the refund flow.

### M5 · Platform frame (screens 14–16)

`14-berandajabatan.md` to `16-alurmasuk.md`: combined Beranda, modules, post assignment, vacant post, delegation, notifications, people search, the round-2 flows, sign-in and account linking, Akun saya, member account recovery.

### M6 · Secretariat (screens 17–19)

`17-keadaanumum.md` to `19-alursurat.md`: general states, church documents, letters, announcements, Warta Jemaat editor and archive, name exception, the round-3 flows, the A4 Warta page, membership request, paper-book import.

### M7 · Member data (screens 20–21)

`20-konfirmasikeluarga.md`, `21-aluranggota.md`: family confirmation, verification queue, member and family data, life events, display name, consent withdrawal, duplicates, my offerings, the round-4 flows, unit finance and unit blockers.

### M8 · Collaboration (screens 22–23)

`22-permintaandana.md`, `23-alurunit.md`: fund requests, committees, worship and attendance, cross-unit reports, named offerings, readiness statements, the round-5 flows, approver table, unit Kas/Bank, forming a committee.

### M9 · Whole-prototype verification

1. All tests green, including `links_test.dart` (expected = `outLinks`, navigation.md 3.1) with no exceptions list. AIBulan's dead `jsLinks` are already left out of `outLinks`, so it passes with `ke: 'TutupBuku'` alone.
2. `test/routes_test.dart` extended: every board at its frame size with each tweak option in turn (one tweak changed from default at a time), plus laptop boards at 1280, 860 and 390 wide; no overflow, no exceptions.
3. Rules pass: run every automated check in `rules-checklist.md` (greps over `lib/`, widget tests) and walk the manual ones.
4. Review pass, board by board in canvas order: open the prototype (`fvm flutter run -d web-server --web-port 8080`, then `http://localhost:8080/#/<Stem>`) next to the board (the canvas at https://claude.ai/artifact/J8KD2YST4nhJUNkSFrNZuF in Play mode, or the board source and spec), switch every tweak, run every handler, follow every link and Back. Log each difference in `docs/build/review-log.md` and fix it. Done when the log has no open rows.
5. Reduce motion on: no animation runs, pulses stop. Gelap theme: every board legible (not compared to boards).
6. `fvm flutter build web --release` succeeds; the built site works when served statically.

## Working in parallel

After M2, each screens file is a unit of work that touches only its own screen files (`lib/screens/<pageId>/…` for its boards) and, at most, adds child routes by re-running the generator. Shared files (`lib/widgets/`, `lib/motion/`, `lib/shell/`, `lib/mock/`, `lib/theme/`) are owned by M0 to M2. A screen unit that needs a change there records it and makes it in a separate, small change after checking no other unit is editing the same file. Seed data a screen needs and that is missing goes into `lib/mock/` as an addition, never a rename.

Suggested split for parallel workers: one worker per milestone M3 to M8, or one per screens file when more are available. Each worker reads `CONVENTIONS.md`, its screens file, and the parts of `components.md`, `motion.md`, `navigation.md` and `mock-data.md` its boards cite.

## Definition of done for the whole prototype

- [ ] 199 routes, one per board, each built from its spec (no stub left: `grep -r "Belum dibangun" prototype/lib/screens` returns nothing).
- [ ] Every board's tweaks are in the Keadaan panel with the canvas's names, options and defaults, and each option changes the screen as specified.
- [ ] Every link on every board works (`links_test.dart` green) and Back returns.
- [ ] Every handler in every board's logic class has its Flutter equivalent (spec "Interactions" lists, checked in the review pass).
- [ ] Every animation in `motion.md` is implemented, used where the specs say, and off under reduce motion.
- [ ] No hex colour outside `lib/theme/` except the three illustration colours in CONVENTIONS.
- [ ] `fvm flutter analyze` clean, `fvm flutter test` green, `fvm flutter build web --release` succeeds.
- [ ] `docs/build/review-log.md` has no open rows.

## Decisions taken for the prototype

| Decision | Why |
| --- | --- |
| Flutter, not a web-only prototype | The decided stack is Flutter (`docs/design/stack-decision-2026-11-08.md`), the handoff ships Flutter tokens and a Flutter mapping, and one build covers phone and web. |
| One route per board, named after the board file | Makes the prototype verifiable against the canvas mechanically: registry, routes and links are tested against `canvas.json` and the manifest. |
| Each board keeps its own state | That is how the canvas behaves; a shared live ledger would invent behaviour the boards do not show. |
| `jabatanKosong` is one global switch | 69 boards carry the same scenario; switching it once and seeing it everywhere is how the Operator would experience it. |
| Prototype-only devices live in the Keadaan panel | The handoff says not to build them into the app, but the two-sided flows cannot be demonstrated without them. |
| Phone boards in a device frame on wide windows | The phone layouts are fixed at 390 × 844; stretching them to a laptop window would not be the design. |
| `flutter_svg` added | The icons are drawn one by one as inline SVG on the boards; rendering their own path data keeps them exact. |
| Canvas token copy ignored | It holds the old `putus` and `garisTegas` values; decision C02/C03 confirmed the handoff values. |
| 12 px text becomes 13 px | The foundations forbid text below 13; the twelve places are listed in the specs. |

## Not final in the design, carried as is

From the handoff README: the consent text is a default not reviewed by counsel; the Mata Anggaran rows are invented samples; the F01 lines for transfers and adjustments, treasury net position and accountability flags are not drawn; no icon library is chosen. The prototype shows what the boards show and nothing more.
