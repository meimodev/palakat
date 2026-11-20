# Prototype code architecture: migration map

All paths are relative to `prototype/`. I read the files and made no changes. Points marked **(inferred)** are my reading, not something a file states.

## 0. Size and shape
- `lib/` has 331 Dart files. Most of the code sits in four places:
  - `lib/screens/`: 244 files, about 87.2k lines, in 12 folders (`ponsel web sistem lanjut lengkap a4 a4s a4t p2 p3 p4 p5`). The folders follow the canvas pages listed in `halamanKanvas` in `lib/boards.dart`.
  - `lib/widgets/`: about 6.6k lines.
  - `lib/shell/`: about 4.0k lines.
  - `lib/mock/`: about 4.7k lines.
- There are 199 boards: 101 `ponsel`, 83 `laptop`, 3 `tablet` (TabBeranda, TabTransaksi, TabCatat), 8 `a4` and 4 `lembar` (PetaLayar, Cakupan, Keputusan, PetaPlatform).
- `pubspec.yaml` depends only on `go_router ^18.1.4` and `flutter_svg ^2.4.0`. It has no state-management package, so Riverpod would be new. Fonts are PlusJakartaSans and IBMPlexMono. The package name is `palakat_prototype`, and the Android `applicationId` is `id.palakat.palakat_prototype` (`android/app/build.gradle*` line 19).
- No file in `lib/` checks `kIsWeb` or `Platform`. Every form factor runs on every platform. A phone board is wrapped in the device frame only when the window is wider than 600 (`lib/shell/bingkai_perangkat.dart:81-86`).

## 1. How screens hold state today

There are three layers, and none of them is shared across screens.

**a) Board-local state, two patterns**
- **Kendali plus ChangeNotifier.** 17 boards have child routes (`papanBerAnak`, end of `lib/boards.dart`): Main, TutupBuku, Awal, Koreksi, HitungKas, Lainnya, MataAnggaran, Bendahara, Persembahan, Kewajiban, Terbatas, Laporan, Dokumen, Kejadian, Kamera, Keluar, AlurDokumen. Each board has a `<Stem>Kendali` StatefulWidget that the router mounts as a `ShellRoute` builder. Taking `lib/screens/ponsel/main.dart` as the example:
  - `_MainKeadaan extends ChangeNotifier` (lines ~160-330) holds the form fields, `saldo = {...saldoNovember}`, the `pend/bel/drafN/drafRp` counters, and `baru`, the newly added row. It also holds three cancellable `Timer`s: 1100 ms retry, 1300 ms upload, 2600 ms toast.
  - It exposes `ulang()` to reset itself, plus actions: `mulai`, `cobaLagi`, `lampirkan`, `simpanDraf`, `bukukan`.
  - `_MainLingkup extends InheritedNotifier` hands it to `MainScreen(anak: …)`. MainScreen is a single widget that switches its view on `anak` ('transaksi', 'catat', 'mata-anggaran', 'periksa', 'detail').
  - `_MainKendaliState` also draws overlays (`PonselTabBar`, `Toast`, the `_LembarCatat` sheet) inside `LayarPonsel`.
  - About 18 screen files define a `ChangeNotifier`.
- **Plain StatefulWidget.** 190 screen files are StatefulWidgets with `setState` fields. Example: `WebTransaksiScreen` (`lib/screens/web/web_transaksi.dart:209-230`) keeps `_f`, `_pilih` and `_buku`, and builds its rows from a file-local `_data(bool buku)`.
- **Board-local seed data.** Many screens carry their own const data in addition to `lib/mock`. Examples: `_dataRamai` and `_akun` in `ponsel/main.dart`; `_data()` in `web/web_transaksi.dart`; `web_excel_data.dart` (1253 lines); `web_paket_laporan_data.dart` (803 lines); `terbatas_data.dart`.
- Twins disagree on the same record. Main lists "Fotokopi warta jemaat" dated 14/11/2026, while WebTransaksi lists it as 16/11/2026, and the two use different BKU numbers. WebBeranda reads the static `totalSaldoNovember`, whereas Main's saldo changes after Bukukan. Booking something on one board never shows on another.

**b) Global tweaks: `PrototypeState`** (`lib/shell/prototipe_state.dart`)
- It is a ChangeNotifier provided by `PrototipeLingkup` (an InheritedNotifier) from `lib/main.dart`.
- Fields:
  - `jabatanKosong`: the global vacancy switch.
  - `gelap`/`tema`: theme.
  - `kurangiGerak`: applied at the root through `MediaQuery.disableAnimations` (`main.dart` ~53-57).
  - `bingkaiPonsel`, `urutPerjalanan`.
  - `_tweak[stem][nama]`: defaults come from `Papan.tweaks` in `boards.dart`, so this layer depends on the generated registry.
- Screens read it through `context.tweak<T>(stem, nama)` (78 call sites in 75 files) or `context.prototipe.jabatanKosong` and `PrototypeState.maybeOf(...)` (about 20 sites). 76 screen files mention `jabatanKosong`.
- Tweak inventory from `boards.dart`:
  - `keadaan` on 93 boards. 34 of these are `['Alur']` with a single value. The rest mix four kinds of option:
    - data states, e.g. 'Draf/Diterbitkan/Ralat sebagai revisi';
    - persona views, e.g. 'Dilihat Operator', 'Dilihat Penatua Kolom 7';
    - staged faults, e.g. 'Gagal memuat', 'Tidak ada sambungan', 'Sesi berakhir…';
    - steps.
  - `jabatanKosong` on 69 boards.
  - The rest: `bulan` (ramai/sepi), `masukSebagai`, `gagalSimpan`, `gagalUnggah`, `gagalDiCekTerakhir`, `adaHambatan`, `keadaanAI`, `biayaAI`, `contohTerisi`, and others.
- **Shell widgets also read the switch.** `LayarPonsel` (`shell/layar_ponsel.dart`) and `HalamanWeb` (`shell/halaman_web.dart`) show `PitaJabatanKosong` when `jabatanKosong:` is true **and** `PrototypeState.jabatanKosong` is on. Screens pass `jabatanKosong: true` as a constant (`ponsel/main.dart:445`, `web/web_beranda.dart` ~289, `web/web_transaksi.dart`).
- **`AlatPrototipe`** (`shell/perangkat_prototipe.dart`) publishes per-board prototype devices into the Keadaan panel. It is used in 19 screen files and in `widgets/alur_kit.dart`. Examples: "Di prototipe ini kode yang benar adalah 123456", "Contoh: diverifikasi" (`p2/alur_masuk_isi.dart:547-560`), and "Dilihat sebagai" chips.

**c) Reset: `ulangPapan`** (`lib/shell/kendali.dart`)
- `ulangPapan` is a global `Map<String, VoidCallback>`. Each mounted Kendali registers `_ulang` in it (`ponsel/main.dart` ~415-428).
- `_ulang` calls the notifier's `ulang()`, then bumps `_generasi`.
- `GenerasiPapan` (an InheritedWidget) and `DenganGenerasi` (a `KeyedSubtree` keyed on the generation) remount widget-local state.
- `Tautan.buka` with `Cara.dorong` to a board already in the stack pops down to that board's root and calls `ulangPapan[ke]` (`shell/tautan.dart:114-133`). 17 screen files use `ulangPapan`/`DenganGenerasi`/`GenerasiPapan`.

## 2. How navigation works today

**One route per board**
- `lib/router.dart` is generated (header "GENERATED by tool/gen_boards.py"). It has been unchanged since commit b66ce03e.
- `buatRouter()` builds:
  - `GoRoute('/')` → `Peluncur` (the launcher);
  - `_komponen` → `KomponenGaleri`;
  - every board as `/<Stem>`;
  - for the 17 `papanBerAnak` boards, a `ShellRoute(builder: <Stem>Kendali)` wrapping `GoRoute('<Stem>')` and its child routes, e.g. `/Main/{transaksi,catat,mata-anggaran,periksa,detail}`, `/Kewajiban/kasus/:id`, `/Terbatas/transaksi/:no`, `/Laporan/rinci/:f`.
- Child routes pass `anak` and `param: s.pathParameters` into the same Screen class.
- `errorBuilder` → `TidakDitemukanScreen`.
- Every page goes through `halaman(...)` (`lib/motion/halaman.dart`), which returns a `CustomTransitionPage` driven by a `Kerangka` keyframe with instant reverse, or a `NoTransitionPage`.
- `main.dart` sets `GoRouter.optionURLReflectsImperativeAPIs = true` so that a push shows its URL (navigation.md 5.4).

**`Tautan` is the only link widget** (`shell/tautan.dart`)
- Signature: `Tautan(ke: '<Stem>' | '<Stem>/<child>', cara: Cara.dorong|ganti|naik, diSini:)`.
- The three `Cara` values:
  - `dorong` = `push('/ke')`;
  - `ganti` = `go`;
  - `naik` = `kembaliKe`. This pops when the page directly below is `/ke` or one of its children, and calls `go` otherwise. Built on `tumpukanHalaman()`, which flattens `ShellRouteMatch`.
- A self link calls `diSini` and does nothing else.
- Other widgets embed `Tautan`:
  - `Tombol(ke:, cara:)` in `widgets/tombol.dart:56-139`;
  - `ButirPerhatian`, `KartuKasus` and `PemilihMataAnggaran`, all in `widgets/`;
  - `KepalaPonsel(kembaliKe: '<Stem>')`, the back arrow, in `shell/kepala_ponsel.dart:15-70`;
  - `NavSamping(item: nav…)` side-nav items, which use `Cara.ganti`;
  - `PonselTabBar`.
- Counts: `ke: '…'` literals appear about 745 times in `lib/screens`. There are 16 direct `kembaliKe(` calls, and 15 files call `go`/`push` directly. Board-internal helpers do their own stack walking, e.g. `_keMain`/`_keAnak`/`_atasMain` in `ponsel/main.dart` ~330-375.
- Rules are in navigation.md 3.1:
  - link targets are string literals in the screen file;
  - no board links to another board's child route;
  - `test/links_test.dart` checks coverage against `Papan.keluar`.
- **Side-nav lists** are in `shell/nav_item.dart`: `navKeuangan`, `navTerbatas`, `navMasuk`, `navVerifikasi`, `navPemulihan` and `navPlatform`, with stems as targets. `navPlatform` sends "Ibadah dan kegiatan" and "Panitia" to the **phone** boards `Ibadah` and `Panitia` (decision 26). The web build has no web screen for those two.
- **Flow boards.** These are the 34 boards with "Alur" in the title, e.g. `p2/alur_masuk.dart`. They are thin form-factor wrappers around a shared stateful body (`AlurMasukIsi`) that changes step in place (`nomor → kode → kenal → tunggu`). Each wrapper passes in its own form factor's link widgets as constructor arguments (`ke: 'Pemulihan'` against `'WebPemulihan'`, `'WartaArsip'` against `'WebWartaArsip'`).

## 3. Reuse, refactor, delete

**Reusable as is**
- `lib/theme/` (`palakat_tema.dart`, `palakat_tokens.dart`, `palakat_warna.dart`): light and dark, `context.warna`, `PalakatText`, `PalakatMotion`.
- `lib/motion/`: `gerak`, `hitung`, `kerangka`, `ulang`, `urutan` and `halaman.dart`. `halaman()` only needs a `GoRouterState`. `hitung.dart` imports `mock/format.dart`.
- `lib/widgets/`: all 41 files are presentational. Four import `shell/tautan.dart` (`tombol`, `butir_perhatian`, `kartu_kasus`, `pemilih_mata_anggaran`). Five import `mock/format.dart`, and `lencana_status.dart` imports `mock/model.dart`. These keep working as long as `Tautan` and the formatters move along with them.
- `lib/mock/format.dart`: `rp`, `titik`, `hanyaAngka`, `tgl`, `tglPanjang`, `jam` and so on. However, `hari = 20261116` and `hariTeks = '16/11/2026'` are fixed "today" values and must become the real clock.
- These shell files are product chrome, not demo machinery, and should be kept: `layar_ponsel`, `kepala_ponsel`, `ponsel_tab_bar`, `halaman_web`, `nav_samping`, `nav_item`, `panel_samping`, `halaman_a4`, `halaman_lembar`, `tablet` (a typedef of HalamanWeb), `toast`. **(inferred)** They are reusable once their `PrototypeState` reads are replaced by a provider.

**Must be refactored**
- **Screen state.** Each `_<Stem>Keadaan` ChangeNotifier and each board's `setState` fields that hold *domain* data should become Riverpod providers backed by repositories:
  - Domain data (saldo, transactions, drafts, posting) moves out.
  - UI-local state (filters, open sheet, form text) can stay in widgets.
  - Board-local const data (`_dataRamai`, `_data()`, `*_data.dart`) has to be merged into one seed.
- **`lib/mock/model.dart`** (700 lines; `Gereja`, `Orang`, `Penugasan`, `KasBank`, `MataAnggaran`, `Transaksi`, `Bulan`, `Kasus`, `Rekonsiliasi`, …). It stores dates as strings, e.g. `'16/11/2026'`, with this rationale in the header: "DateTime has no const constructor". It holds "only what the boards show". It needs to be reshaped after the real domain model with `DateTime` values relative to today.
- **`lib/mock/laporan.dart`.** Its header says report tables are "strings exactly as this file's source lists them; the screens print them, never recompute them". Shared state requires that these be computed.
- **Tweak reads.** Each `context.tweak` and `jabatanKosong` read should become derived state:
  - the persona or session (which post the signed-in user acts as);
  - real data conditions (month state, document status);
  - for staged faults (`gagal*`, 'Gagal memuat', 'Tidak ada sambungan'), the branch is deleted.
- **`tukarJk` vacancy rewriting** (`mock/jabatan_kosong.dart:67-104`). `papanTukarJk` lists 18 boards. `tukarJk` rewrites "Meiske L." to "Yanti Sumual, Operator" in display strings, but only when every date in the string is 16/11/2026. It is used in 9 screen files: `ponsel/main_periksa.dart:404`, `ponsel/mata_anggaran.dart:162`, `web/web_rekonsiliasi.dart:103`, `web/web_mata_anggaran.dart:127`, `lengkap/draf.dart:87`, `lengkap/dokumen.dart:244`, `lengkap/web_draf.dart:91`, `lengkap/web_dokumen.dart:94`, and `tukarJkDalam`. In the real app, the actor's name must be the recorded actor of each record ("dijalankan oleh"), not a string swap. The constants `plk`/`plk2`/`navPenggunaJk`/`jkPita*` should come from the session.
- **Routes.** Replace the 199 stem routes with real paths per platform: phone app routes on Android and web app routes on web. Child-route ShellRoutes such as `/Main/*` can stay as nested routes. The ~745 `ke: '<Stem>'` literals and the `nav…` lists need mapping to the new route names. Options: a stem→path table, or keep `Tautan` with a `ke` that resolves through a map. **(inferred)** A map keeps the diff small.
- **`AlurMasukIsi`-style flows.** The prototype-only devices ("123456", "Contoh: diverifikasi") must be replaced by real cross-persona actions. For example, the Penatua verifies in AntreanVerifikasi and the status then shows for the member.

**Must be deleted**
- Launcher and journeys: `shell/peluncur.dart`, `shell/perjalanan.dart`. `perjalanan.dart`'s eight role headings (`perjalanan.dart:30-234`) are a useful source for the persona picker list.
- Keadaan panel and device frame: `shell/panel_keadaan.dart`, `shell/bingkai_perangkat.dart`. The frame imports `boards.dart` and is wired in `main.dart` as `BingkaiPerangkat`; the `InheritedGoRouter` wrapper exists only for the panel.
- Prototype state and devices: `shell/prototipe_state.dart`, `shell/perangkat_prototipe.dart` (and all `AlatPrototipe` wrappers in 19 screens plus `widgets/alur_kit.dart`).
- Reset machinery: `shell/kendali.dart`, which holds `ulangPapan`, `GenerasiPapan` and `DenganGenerasi`.
- `shell/komponen_galeri.dart`, 1156 lines, at route `/_komponen`.
- `shell/belum_dibangun.dart`: no screen uses it any more; only the generator refers to it.
- `shell/tidak_ditemukan.dart` (optional, keep or replace).
- `lib/boards.dart` (generated; `Papan`, `Tweak`, `semuaPapan`, `papanBerAnak`).
- The generated `lib/router.dart`.
- The `lib/screens/sistem/` boards PetaLayar, Cakupan, Keputusan and PetaPlatform. These are design maps, not app screens.
- All of `tool/`: `gen_boards.py` (it writes `lib/boards.dart` at line 126, `lib/router.dart` at line 182, and stubs at line 220), `SHOTS.md`, `app_shot.sh`, `board_check.sh`, `board_shot.sh`, `compare.sh`, `shot_common.sh`, `dc/support.js`.
- Tests: see risk (a) for the list.

## 4. Phone/web twin patterns

- There are 101 phone boards and 83 laptop boards. 70 phone boards have a `Web<Stem>` twin.
- 31 boards are phone-only, among them Main, Lainnya, Bendahara, Kamera, Ibadah, Panitia, PermintaanDana, AntreanVerifikasi and most Alur* boards.
- 13 boards are web-only: WebBeranda, WebTransaksi, WebCatat, WebRekonsiliasi, WebPengaturan, WebPaketLaporan, WebExcel, WebExcelTerbatas, WebKasus, WebSerahTerima, WebUnggah, WebVerifikasi, WebAI.
- The finance core is split differently on each side. Phone Main (with its child routes) corresponds to WebBeranda, WebTransaksi and WebCatat on the web, plus the tablet TabBeranda, TabTransaksi and TabCatat (`lib/screens/web/tab_*.dart`, which share `tab_beranda_kit.dart`).

**Pattern A: shared body plus thin wrappers.** About 25 pairs.
- A `*_isi.dart` or `*_bagian.dart` file holds the stateful body, and each wrapper supplies the shell (`LayarPonsel`+`KepalaPonsel` against `HalamanWeb`+`NavSamping`) and the form-specific `ke` targets.
- Pairs that share a body this way:
  - `p2/alur_masuk_isi` (570 lines; wrappers of 48 and 83 lines), `p2/beranda_jabatan_isi`;
  - `p3/dokumen_gereja_isi`, `p3/{buka_nama,pengumuman,permohonan_surat,warta_arsip}_bagian`;
  - `p5/{alur_unit,kas_unit,kesiapan,selesaikan_unit}_isi`;
  - `lengkap/{ai_mata_anggaran,awal_isian,memuat,pengembalian}_isi`, `lengkap/{ai_foto,cari,format_laporan,kejadian}_bagian`;
  - `lanjut/bantuan_ai_bagian`, `lanjut/terbatas_data`;
  - `ponsel/bagi_logika` (shared by `bagi` and `web_bagi`);
  - `lengkap/rekon_isi.dart`, which is itself the RekonIsi board and is imported by `web_rekon_isi.dart` (96 lines).
- In these pairs, nearly all of the logic is shared.

**Pattern B: independent twins.** This covers the round-1 finance core:
- `ponsel/main.dart` (1243 + 537 + 612 lines) against `web/web_transaksi.dart` (870), `web/web_beranda.dart` (600) and `web/tab_catat.dart` (842);
- `ponsel/hitung_kas` (817) against `web/web_hitung_kas` (624);
- `ponsel/tutup_buku` (1852) against `web/web_tutup_buku` (1028);
- `ponsel/awal` (1280) against `web/web_awal` (829);
- `ponsel/mata_anggaran` against `web/web_mata_anggaran`.

These twins import only `mock/`, `widgets/`, `shell/` and `theme/`. They share no screen code and each carries its own data and logic. **(inferred)** These are where providers will remove the most duplication, and where twin drift (§1a) has to be fixed first.

## 5. Concrete risks for a step-by-step migration

**a) Tests that break first**
- Most of `test/` depends on demo machinery. 11 of 18 files import `boards.dart`, `router.dart`, `main.dart` or `prototipe_state.dart`:
  - `routes_test`, `links_test`, `registry_test`, `deep_link_test`, `chrome_test`, `shot_test`, `galeri_test`, `tanggal_test`;
  - `rules_test` (643 lines; W1-W7 sweeps over boards, which also imports `panel_keadaan`);
  - `mock_test` (which imports `boards.dart`);
  - `shell_test` (which imports `kendali.dart` and `prototipe_state.dart`).
- Removing `boards.dart` or `PrototypeState` breaks all of them at compile time, and a single compile error fails the whole `flutter test` run. They should be deleted in the same step.
- These test files depend only on widgets, motion, format and theme, and can be kept: `components_a/b/c_test`, `primitives_test`, `motion_test`, `ikon_test`, `format_test`. `components_a_test` imports `shell/tautan.dart` and `mock/model.dart`, so it will need updating.
- The repo has no per-board test files. The board-level checks are the sweeps in `routes_test`, `rules_test` and `shot_test`.

**b) Generated files**
- `lib/router.dart` and `lib/boards.dart` are rewritten whenever `tool/gen_boards.py` runs, from `docs/design/handoff/canvas/canvas.json`, `docs/build/board-manifest.json` and the navigation.md json blocks. It asserts 199 boards.
- Any hand edit to the router is lost if someone reruns the generator. Delete the generator before the first hand edit to `router.dart`.
- `links_test` relies on string-literal `ke:` targets, so moving targets into a map makes the test meaningless.

**c) The vacancy logic is string-based**
- `tukarJk` and `tukarJkPapan` depend on the literal "Meiske L." and on the fixed date 16/11/2026 (`mock/jabatan_kosong.dart:79-93`).
- Once dates are relative to today, the date guard never matches, and the swap silently stops working.
- The vacancy has to become data: a vacant post, a run-by assignment, and an actor recorded on each action.
- `jabatanKosong: true` is a constant on many `LayarPonsel`/`HalamanWeb` calls. It must become "the session acts on a vacant post".

**d) Timers inside widgets and notifiers**
- 23 `Timer(`/`Future.delayed` calls sit in 16 screen files, with hotspots in `ponsel/tutup_buku.dart` (4), `web/web_tutup_buku.dart` (3) and `ponsel/main.dart` (3). There are 31 literal durations of 1000 ms or more. Timers also appear in `widgets/tombol.dart`, `motion/{ulang,hitung,gerak}.dart`.
- If an action's outcome moves into a provider while its timer stays in a disposed widget, the result can be lost or applied twice. For example, `lampirkan` sets `dok = 'terlampir'` after 1300 ms.
- In tests, pending timers fail with the "Timer still pending" error unless they are pumped.

**e) Fixed "today" values everywhere**
- `hari`/`hariTeks` live in `mock/format.dart`.
- 174 literal "16/11/2026" or "November 2026" strings appear across 99 screen files, e.g. `web_beranda.dart` 'November 2026 · Belum ditutup' and `main.dart` `tgl: '16/11/2026'`, `_noBukti = 'BKU-2026-0147'`.
- 202 `rp(…)`/`saldoNovember` references read static totals.
- All of these need deriving from the clock and from state, screen by screen.

**f) Tweaks that encode mutually exclusive situations**
- Example: `bulan` ramai/sepi on Main and WebBeranda.
- Example: `keadaan` 'Bendahara aktif' against 'Belum ada Bendahara aktif'.
- Example: the four `Dilihat …` persona views.
- One story cannot hold both sides at the same time. **(inferred)** The seed needs different months, units or personas to express each side, and staged-fault options ('Gagal memuat', `gagalSimpan`, 'Tidak ada sambungan') lose their branches.

**g) Cross-persona steps now done by demo buttons**
- `AlatPrototipe` devices complete the other party's side of a flow. Examples: "Contoh: diverifikasi" in `alur_masuk_isi.dart:553`, and "Contoh: Rp250.000 dibukukan".
- With the panel removed, these flows stall unless the other persona's screen performs the action on shared state.

**h) Platform split**
- Nothing selects screens by platform today. Web's `navPlatform` opens the phone boards Ibadah and Panitia.
- The 31 phone-only boards, including AntreanVerifikasi, PermintaanDana and PersembahanSaya, have no web screen.
- The 13 web-only boards have no phone screen.
- The tablet boards are three separate screens that use `HalamanWeb` with its narrow nav below 860 px.

**i) The Android build-order fix lives in the file being deleted**
- `bingkai_perangkat.dart:62-64` defers its route rebuild with `scheduleMicrotask`. This is commit 19a71f9d, "setState during the first build on Android".
- **(inferred)** Similar ordering problems may resurface when providers notify during the first build. Riverpod forbids modifying a provider while widgets are building.

**j) Reset semantics change**
- `Tautan.buka` with `Cara.dorong` to a board already in the stack pops down to it and resets its state (`tautan.dart:118-133`).
- With shared persistent state, that "reset on re-entry" must go. Otherwise re-entering Main would erase posted transactions.
- `DenganGenerasi` keys must also go, or they will remount forms unexpectedly.

---
I sampled about 10 screens and did not read the rest. I did not check `rules_test`'s individual sweeps or the remaining `keadaan` readers line by line. I ran no build and no tests. The twin and tweak counts come from regex over the sources, so they may be off by a few.