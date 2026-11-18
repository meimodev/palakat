# Screens 23: AlurUnit, WebAlurUnit, AlurDana, AlurIbadah, AlurPanitia, PemberiPersetujuan, KasUnit, WebKasUnit, AlurPanitiaBaru

These nine boards are the typed "Alur" flows of canvas page Putaran 5 · Kolaborasi (`p5`): money handled by units and committees (P09, P13–P16) and worship attendance. **AlurUnit** / **WebAlurUnit**: the Bendahara Kolom 7 (Deasy Tumbelaka) books only in Kolom 7's peruntukan on Kas Kolom 7, and the Bendahara Jemaat (Meiske Lumentut) clears the Kolom 7 Draf that blocks the October 2026 close by moving its date to November with a reason. **AlurDana**: a Permintaan dana from the Ketua Komisi Diakonia is approved or refused by the Ketua Jemaat and, once approved, booked by the Bendahara Jemaat as Uang Muka. **AlurIbadah**: a Kolom service is scheduled, its attendance counted, checked, set (Ditetapkan) and corrected with a reason. **AlurPanitiaBaru**: the Pimpinan Jemaat forms a Panitia (three different people plus a written church decision), then activates it; from there "Tetapkan Kas/Bank Panitia" opens **KasUnit** and "Lihat penutupan Panitia" opens **AlurPanitia**, which closes and archives Panitia Natal 2026. **PemberiPersetujuan** is the one-per-church approver table; once saved it offers "Aktifkan modul Persetujuan di aplikasi" (→ AlurModul). **KasUnit** / **WebKasUnit**: the Bendahara Jemaat gives a unit its own Kas/Bank, effective the next month. The seven phone boards use the plain phone header with back (to Main, PermintaanDana, Ibadah, Panitia, Modul, Lainnya); the two laptop boards use the platform web side nav with "Keuangan" active. Every board is a single in-place flow: no child routes, no timers, no motion. All are reached from the PetaPlatform sheet plus the parent boards named in each section.

Shared notes for this file:

- **Navigation words.** An *up link* (phone back arrow, web breadcrumb) runs `kembaliKe('/X')`: it pops when the route directly beneath is `/X` or a child of `/X`, otherwise it does `go('/X')` (`navigation.md`, kind up). Phone back arrows are `KepalaPonsel(kembaliKe: '<Target>', labelKembali: '<aria-label>')`. The two in-body board links (PemberiPersetujuan → AlurModul, AlurPanitiaBaru → KasUnit / AlurPanitia) are `push`; web side-nav items are `go`. All are `Tautan(ke: …)`. After a `push`, Back finds the board as it was left. A change of `v` or of the panel's "Dilihat sebagai" resets the body's scroll offset to the top (the choice of `21-aluranggota.md`).
- **Phone frame** (AlurUnit, AlurDana, AlurIbadah, AlurPanitia, PemberiPersetujuan, KasUnit, AlurPanitiaBaru): 390 × 844, background `kertas`, body `isi` (16, line-height 1.4) `tinta`. A column of a fixed header and a scrolling body. No tab bar, no bottom bar. (The manifest marks these boards `hasSideNav: true` only because they carry the shared web-link helper; they have no nav.)
  - Header (does not scroll, no fill, no rule): row, centred vertically, gap 8, padding 14 top / 12 sides / 8 bottom. Back target 44 × 44 with a centred chevron-left 22 px (SVG path `M15 6l-6 6 6 6`, viewBox 24, stroke `tinta` width 2, round caps), Semantics label given per board, built with `Tautan`. Title column (flex 1): h1 `judulLayar` 18/700, margin 0; under it the subtitle 13 `tinta2` (the board writes `font-size: 14px` then `13px`; 13 wins).
  - Body: scrolls vertically, padding 8 top / 20 sides / 20 bottom, one column with gap 16 (content width 350). Every block listed in a Layout is a direct child of that column, so blocks are 16 apart unless a section says otherwise.
- **Platform web side nav** (WebAlurUnit, WebKasUnit). `NavSamping(item: navPlatform, aktif: 1, …)` (`navigation.md` 1.3). Same structure, sizes and below-860 collapse as the standard web side nav (`02-awal.md` shared notes; also `16-alurmasuk.md`): nav `flex 1 1 220`, padding 24 × 16, `permukaan`, right rule 1 `garis`, column gap 20. Logo row (gap 10, padding 0 8): 26 × 26 mark (rounded square radius 6, 2 px dashed `laut` stroke, dash 3 3, right half filled `laut`; render the board's SVG), "palakat" 18/700 line-height 1.1, "Jemaat Karunia" 13 `tinta3`. Items: min-height 44, padding 0 12, radius 10, 600, no underline; active `tinta` field with `permukaan` text, others transparent with `tinta` text. Footer: margin-top auto, padding 12 8 0, top rule 1 `garis`, 13 `tinta2`: bold `tinta` "Meiske Lumentut" + " · Bendahara Jemaat". Items, exactly in this order, all `go`:
  1. "Beranda" → `/WebBerandaJabatan`
  2. "Keuangan" → `/WebBeranda` (**active on both boards**)
  3. "Dokumen gereja" → `/WebDokumenGereja`
  4. "Pengumuman" → `/WebPengumuman`
  5. "Warta Jemaat" → `/WebWartaArsip`
  6. "Data jemaat" → `/WebDataAnggota`
  7. "Ibadah dan kegiatan" → `/Ibadah` (a phone board, Q26)
  8. "Panitia" → `/Panitia` (a phone board)
  9. "Pemberitahuan" → `/WebKotakMasuk`
  10. "Pengaturan" → `/WebPenugasan`

  At 860 px and below (`max-width: 860px`) the nav becomes a top bar (full width, row, wrap, items centred, gap 0 × 12, padding 8 × 16, bottom rule 1 `garis`, no right rule): logo left, toggle right (pushed by an auto left margin): min-height 44, padding 0 16, radius 14, 1.5 `tinta` edge, `permukaan`, 700/14, label "Menu"; when open `tinta` field, `permukaan` text, label "Tutup menu", and the items list (padding 8 0) and the footer (padding-bottom 8) show full width below. The footer does not follow the panel's "Dilihat sebagai".
- **Web main column**: `flex 999 1 560`, min-width 0, padding 28 top / `clamp(16, 3vw, 40)` sides / 40 bottom, column gap 20, page background `kertas`, body `isiWeb` (15, line-height 1.45). The page scrolls as a whole. First child is the title block: breadcrumb text link 14/600 `laut`, underlined, `lautTua` on hover/press (the boards' `a:hover`); h1 `judulHalaman` 26/700, margin-top 2; subtitle 14 `tinta2` (14 on web, not 13). Second child is the content column: max-width 1120, column gap 16. On web every "body size" below is 15 instead of 16 (button labels, card titles, mono row amounts). At 1440 the nav is about 221 wide, the main column about 1219, the content column 1120.
- **Two-column form row** (web, where noted): wrap row, gap 20 vertical × 28 horizontal, top-aligned. Left `flex 1.3 1 420`, right `flex 1 1 340`, both min-width 0, each a column with gap 12 (not 16). At 1440 about 608 and 484 wide; still side by side at 860 (content about 808 ≥ 788); stacked below that.
- **Shared parts**: KitAlur (components.md 2.9), built in M1. This file uses it and does not redefine it. The names used below (*Field*, *Reason textarea*, *ChipPilihan pill*, *Refusal line*, *TombolBersyarat*, *Primary button*, *Secondary button*, *Text button*, *Button row*, *Card*, *Info row*, *Dashed box*, *Notice box*, *Badge*, *Message banner*, *Riwayat*) are the KitAlur parts (badge variants by the boards' `LS` names): reason textarea = field with `baris: 3` and label "Alasan · wajib". Only these differ on the nine boards:
  - *ChipPilihan pill*: no pill is ever pre-selected (D01).
  - *Button row*: buttons marked "intrinsic" are KitAlur's button outside a row (`align-self: flex-start`, as wide as the label).
  - *Info row*: money values are IBM Plex Mono (weight given per row).
  - *Dashed box*: padding and content are given per use.
  - *Message banner*: typing never clears it; picking a pill or changing view does (each section says which).
  - *"Dilihat sebagai"* (AlurUnit, WebAlurUnit, AlurDana and the other boards whose section names it): KitAlur `DilihatSebagai`, in the Keadaan panel, never on screen.
- **Typed-input rules** used below:
  - *Digits* (`angka`): on every change the value keeps digits only, drops leading zeros (a lone "0" stays "0"), and is cut to 11 digits. Where noted, the field shows the value with dot thousands separators ("1500000" → "1.500.000"); caret at the end. Numeric keyboard.
  - *Free text* (`ketik`): stored as typed; checks use the trimmed value.
  - *Date* (hh/bb/tttt): typed freely, no auto-formatting. Accepted only as exactly `dd/mm/yyyy` after trimming (two-digit day and month), day 1–31, month 1–12 (no per-month check: 31/02/2026 passes). Compared as yyyymmdd with today 16/11/2026.
  - *Time* (jj.mm): accepted only as `^([01]\d|2[0-3])\.[0-5]\d$` after trimming ("19.00" yes; "19:00", "7.00" no).
  - *Rupiah hint* (`rpT`): "Rp" + the digits with dot thousands, "Rp0" when empty.
- **TombolBersyarat behaviour, all boards**: the board wraps each conditional handler so a press re-reads the latest input and runs the action only when the condition holds; pressing while unmet does nothing (no extra message, no shake). Because the condition is recomputed on every keystroke, the first press after the input becomes valid works. When the refusal line shows is board-specific and given per section.
- **State**: each board keeps its own state in its screen, starting from the initial state given per section; leaving the route and opening it again starts fresh. "Today" is 16/11/2026 everywhere.
- **Tweak, all nine boards**: `keadaan`, options `Alur`, default `Alur`. It has no visible effect; show it in the Keadaan panel as a one-option choice.
- **Motion, all nine boards**: none. The board CSS declares keyframes (phone: `isi`, `masuk`, `muncul`, `pudar`; web: `isi`, `muncul`, `titik`) but no element uses them, and there are no transitions and no `setTimeout`. Views and states switch instantly. Nothing to stop under reduce motion.
- No 12 px text on any of the nine boards. No `jabatanKosong` (no `tukarJk`). Every board colour maps to a token.

### AlurUnit — 94 · Alur · Keuangan unit

- **Source** `docs/design/handoff/canvas/boards/AlurUnit.dc.html` · page Putaran 5 · Kolaborasi (`p5`) · form Phone 390×844 · interactive yes
- **Route** `/AlurUnit`, no child routes (the Kolom 7 form and the Bendahara Jemaat "Pindah tanggal" steps change in place under one header) · **Widget** `AlurUnitScreen` in `lib/screens/p5/alur_unit.dart`
- **Purpose** Two posts on one unit's money. The Bendahara Kolom 7 (Deasy Tumbelaka) records Pendapatan or Belanja for Kolom 7 and may book only on a Kas/Bank that Kolom 7 manages (P14: the unit books only on its own Kas/Bank; D01: Jenis and Kas/Bank are never pre-filled). The Bendahara Jemaat (Meiske Lumentut) sees that a Kolom 7 Draf dated 28/10/2026 blocks the October 2026 close and resolves it by moving the draft's date to 02/11/2026 with a required reason (P12: not blank, no minimum length); the unit treasurer is notified. Journey: Bendahara unit and committee officers step 1 ("Keuangan Kolom 7", "Alur · Keuangan unit"). (Bendahara Jemaat step 6 "87 · Hambatan dari unit" is SelesaikanUnit, not this board.) Shows GarisStatus draf vs dibukukan, the "terpilih" scope box and RiwayatAlur.
- **Shell** Phone header with back: Semantics "Kembali ke Keuangan" → Main. Title "Alur · Keuangan unit"; subtitle "Bendahara Kolom 7 membukukan; Bendahara Jemaat menyelesaikan hambatan". No tab bar. The header does not change with the viewing actor.
- **Layout** (body column, gap 16)
  1. (Board: "Dilihat sebagai" label 14 `tinta2` with pills "Bendahara Kolom 7" · "Bendahara Jemaat". Not on screen; it goes to the panel.)
  2. Message banner (only while `pesan` is set).
  3. **Bendahara Kolom 7** (`akt = 'Bendahara Kolom 7'`), in this order:
     a. Scope box (GarisStatus `terpilih`): 1.5 `tinta` edge, radius 12, `permukaan`, padding 12 × 14, 14 px: bold "Keuangan unit: Kolom 7." then " Anda membukukan hanya di peruntukan Kolom 7, pada Kas/Bank yang dikelola Kolom 7."
     b. Pills "Jenis": "Pendapatan" · "Belanja".
     c. Field "Jumlah (Rp)", placeholder "0", digits rule with dot separators; hint under it = Rupiah hint ("Rp0" when empty, "Rp50.000" after "50000").
     d. Pills "Kas/Bank": "Kas Kolom 7" · "Kas (dikelola Jemaat)".
     e. Field "Uraian", placeholder "Contoh: Persembahan Ibadah Kolom", free text, no hint.
     f. Refusal line "Tidak dapat dilakukan: Bukukan." + reason (when shown, see Interactions).
     g. Button row: TombolBersyarat "Bukukan" (340).
     h. h2 `judulBagian` "Peruntukan Kolom 7 · November 2026".
     i. Booked rows, each a compact card: `permukaan`, 1 `garis`, radius 14, padding 10 × 16, column gap 2. Top line: space-between, centred, gap 16: title 600 body size left; amount IBM Plex Mono body size weight 400 (inherited) right. Under it 13 `tinta3` sub-line. First row always "Persembahan Ibadah Kolom" · "Rp320.000" · "BKU-2026-0151 · 12/11/2026 · Dibukukan". Rows booked in this session follow it, newest first.
     j. Draft box (dashed box, padding 14 × 16, column gap 6; always shown): head row "Konsumsi ibadah Kolom" 700 + `draf` badge "Draf"; under it 14 `tinta2`: before resolution "28/10/2026 · Rp185.000 · belum masuk saldo · menghalangi tutup buku Oktober 2026"; after the Bendahara Jemaat moved it "Dipindah ke 02/11/2026 oleh Bendahara Jemaat · alasan: {alasan}".
  4. **Bendahara Jemaat, blocker** (`akt = 'Bendahara Jemaat'`, not resolved, view `utama`):
     a. Dashed box, padding 12 × 14, 14 px: bold "Tutup buku Oktober 2026 terhalang 1 hal dari Kolom 7." then a space and `tinta2` "Bendahara Jemaat dapat menyelesaikannya dengan alasan; Bendahara Kolom 7 diberi tahu."
     b. Card (solid `garis` edge): head "Konsumsi ibadah Kolom" + `draf` badge "Draf"; info rows "Tanggal transaksi" → "28/10/2026"; "Jumlah (Rp)" → mono 500 "Rp185.000"; "Dicatat oleh" → "Deasy Tumbelaka, Bendahara Kolom 7"; then 13 `tinta3` "Draf di bulan yang akan ditutup menghalangi tutup buku seluruh Jemaat."
     c. Button row: primary "Pindah tanggal ke November" (340).
  5. **Bendahara Jemaat, reason** (view `alasan`, not resolved):
     a. Card: head "Pindah tanggal · Konsumsi ibadah Kolom" + `draf` badge "Draf"; info row "Tanggal transaksi baru" → "02/11/2026"; 13 `tinta3` "Hanya bulan yang Belum ditutup. Draf tetap Draf; tidak ada yang dibukukan."
     b. Reason textarea "Alasan · wajib".
     c. (A refusal line "Tidak dapat dilakukan: Pindah tanggal." exists in the source but its condition can never be true; it never shows. Do not build it.)
     d. Button row: TombolBersyarat "Pindah tanggal" + text button "Kembali" (171 each).
  6. **Bendahara Jemaat, resolved** (`beres` set):
     a. Card: head "Konsumsi ibadah Kolom" + `draf` badge "Draf"; 14 `tinta2` "Dipindah ke 02/11/2026"; 13 `tinta3` "Diselesaikan oleh Bendahara Jemaat (alasan: {alasan}) · Meiske Lumentut, 16/11/2026".
     b. Notice box: bold "Tidak ada hambatan dari unit." then " Oktober 2026 dapat diperiksa untuk tutup buku."
  7. Riwayat (when there are rows; shown to both actors).
- **Components** TombolBersyarat ("Bukukan", "Pindah tanggal"), Penolakan, ChipPilihan (Jenis, Kas/Bank), LencanaStatus shape (`draf` "Draf"), GarisStatus (`terpilih` scope box, `draf` dashed draft and blocker boxes, `dibukukan` rows and cards), IsianAlasan look (textarea), Tombol (primary "Pindah tanggal ke November", text "Kembali"), RiwayatAlur, message banner, notice box. The Jumlah field is a plain field with an "Rp…" hint, not the IsianJumlah underline look. Pattern: compact booked row (title + mono amount + sub-line).
- **Internal views and states** Initial state `{ k: null, a: { pesan: '', riw: [], v: 'utama', akt: 'Bendahara Kolom 7', jenis: '', jml: '', kas: '', ur: '', buku: [], beres: '', alasan: '' } }`. Branches: Kolom 7 form (region 3, whatever `v` is); Bendahara Jemaat blocker (4), reason (5), resolved (6). State is shared by both actors: switching keeps every field, the reason view, `beres` and Riwayat. Unused helpers in the source (`tgl`, `balik`, `baris`) need nothing.
- **Tweaks** `keadaan` (options `Alur`, default `Alur`; no visible effect). Keadaan panel.
- **Interactions**
  - Actor (panel "Dilihat sebagai", `pick`) → `akt` = "Bendahara Kolom 7" or "Bendahara Jemaat", `pesan = ''`.
  - Jenis pill / Kas/Bank pill (`pick`) → sets `jenis` / `kas`, `pesan = ''` (the "Dibukukan…" banner goes away when a new entry starts with a pill). Pills cannot be unselected, only switched.
  - Jumlah typing (`onJml`) → digits rule; field shows dot separators; hint follows.
  - Uraian typing (`onUr`) → free text.
  - "Bukukan" condition, first unmet reason: (1) no Jenis → "jenis belum dipilih."; (2) amount 0 or empty → "jumlah belum diisi."; (3) no Kas/Bank → "Kas/Bank belum dipilih."; (4) Kas/Bank is not "Kas Kolom 7" → "Kas/Bank ini tidak dikelola Kolom 7."; (5) Uraian blank after trim → "uraian belum diisi.". The refusal line shows as soon as any of Jenis, Jumlah, Kas/Bank, Uraian is non-empty (a space in Uraian counts), never on the empty form.
  - Press when met (`bukukan`) → a new row is put first in the session list (so it shows directly under the BKU-2026-0151 row): title = Uraian trimmed, amount = "Rp{jumlah}" for Pendapatan or "−Rp{jumlah}" (U+2212) for Belanja, sub-line "No. Bukti baru · 16/11/2026 · Dibukukan · {Jenis}"; Jenis, Jumlah, Kas/Bank, Uraian cleared; `pesan` = "Dibukukan di peruntukan Kolom 7."; Riwayat gains "16/11/2026 · Dibukukan: {Jenis} Rp{jumlah} · {Uraian} · Deasy Tumbelaka, Bendahara Kolom 7" (the Riwayat amount has no minus sign).
  - "Pindah tanggal ke November" (`keAlasan`) → `v = 'alasan'`, `pesan = ''`, `alasan = ''`.
  - Reason typing (`onAlasan`) → free text.
  - "Pindah tanggal" condition: reason not blank after trim. No refusal line ever shows (see Notes). Press when met (`pindah`) → `v = 'utama'`, `beres` = trimmed reason, `alasan = ''`, `pesan` = "Deasy Tumbelaka diberi tahu lewat Pemberitahuan.", Riwayat gains "16/11/2026 · Draf Konsumsi ibadah Kolom dipindah ke 02/11/2026 · Diselesaikan oleh Bendahara Jemaat (alasan: {alasan})".
  - "Kembali" (`pulang`) → `v = 'utama'`, `pesan = ''`; the typed reason is kept in state but cleared on the next "Pindah tanggal ke November".
  - No timers. No way to undo the move.
- **Motion** none (shared note).
- **Links out**
  - Header back "Kembali ke Keuangan" → `/Main`, up link.
  - **Inbound** PetaPlatform.
- **Mock data** Deasy Tumbelaka, Bendahara Kolom 7; Meiske Lumentut, Bendahara Jemaat; peruntukan Kolom 7, November 2026; Kas/Bank "Kas Kolom 7" and "Kas (dikelola Jemaat)"; booked row "Persembahan Ibadah Kolom", Rp320.000, BKU-2026-0151, 12/11/2026; Draf "Konsumsi ibadah Kolom", 28/10/2026, Rp185.000, moved to 02/11/2026; month being closed Oktober 2026; today 16/11/2026. KeuanganUnit and SelesaikanUnit show other figures for BKU-2026-0151 and the blocking draft (`mock-data.md` conflicts 7 and 14); keep this board's.
- **Prototype-only** On the board: "Dilihat sebagai" pills (Bendahara Kolom 7 · Bendahara Jemaat). Keadaan panel, "Alat prototipe": "Dilihat sebagai" as a two-option choice (default Bendahara Kolom 7) calling `pick`. Plus the tweak `keadaan`, "Semua layar", inbound links, canvas title. The placeholder "Contoh: Persembahan Ibadah Kolom" is an input placeholder, not a device: keep it on screen.
- **Acceptance checks**
  1. Open `/AlurUnit` → no "Dilihat sebagai" pills on screen; scope box "Keuangan unit: Kolom 7. …", unselected Jenis and Kas/Bank pills, empty "Jumlah (Rp)" with hint "Rp0", grey "Bukukan", no refusal line; row "Persembahan Ibadah Kolom · Rp320.000 · BKU-2026-0151 · 12/11/2026 · Dibukukan"; dashed "Konsumsi ibadah Kolom" with "Draf" and "28/10/2026 · Rp185.000 · belum masuk saldo · menghalangi tutup buku Oktober 2026"; no Riwayat.
  2. Pick "Belanja" → "Tidak dapat dilakukan: Bukukan. jumlah belum diisi."; type "abc50000" → field "50.000", hint "Rp50.000", reason "Kas/Bank belum dipilih."; pick "Kas (dikelola Jemaat)" → "Kas/Bank ini tidak dikelola Kolom 7."; pick "Kas Kolom 7" → "uraian belum diisi."
  3. Uraian "Konsumsi rapat Kolom" → refusal gone, "Bukukan" `tinta`; first press → form empty again (hint "Rp0", no refusal), banner "Dibukukan di peruntukan Kolom 7.", second row "Konsumsi rapat Kolom · −Rp50.000 · No. Bukti baru · 16/11/2026 · Dibukukan · Belanja"; Riwayat "16/11/2026 · Dibukukan: Belanja Rp50.000 · Konsumsi rapat Kolom · Deasy Tumbelaka, Bendahara Kolom 7".
  4. Pick "Pendapatan" → banner disappears; the refusal "Tidak dapat dilakukan: Bukukan. jumlah belum diisi." shows again.
  5. Panel "Bendahara Jemaat" → dashed "Tutup buku Oktober 2026 terhalang 1 hal dari Kolom 7. …", card with "28/10/2026", "Rp185.000", "Deasy Tumbelaka, Bendahara Kolom 7", primary "Pindah tanggal ke November"; Riwayat from step 3 still shown.
  6. "Pindah tanggal ke November" → card "Pindah tanggal · Konsumsi ibadah Kolom", "Tanggal transaksi baru 02/11/2026", empty "Alasan · wajib", grey "Pindah tanggal" with no refusal line, "Kembali"; typing three spaces keeps it grey; "Kembali" returns to step 5's view.
  7. Again, reason "Konsumsi untuk ibadah 2 November", "Pindah tanggal" → "Dipindah ke 02/11/2026", "Diselesaikan oleh Bendahara Jemaat (alasan: Konsumsi untuk ibadah 2 November) · Meiske Lumentut, 16/11/2026", notice "Tidak ada hambatan dari unit. Oktober 2026 dapat diperiksa untuk tutup buku.", banner "Deasy Tumbelaka diberi tahu lewat Pemberitahuan.", Riwayat top row "16/11/2026 · Draf Konsumsi ibadah Kolom dipindah ke 02/11/2026 · Diselesaikan oleh Bendahara Jemaat (alasan: Konsumsi untuk ibadah 2 November)".
  8. Panel "Bendahara Kolom 7" → banner gone; draft box line "Dipindah ke 02/11/2026 oleh Bendahara Jemaat · alasan: Konsumsi untuk ibadah 2 November".
  9. Header back → `/Main`.
- **Notes**
  - The source computes the "Pindah tanggal" refusal as `al && !al`, which is never true, so a blank reason leaves the button grey with no sentence. Keep the board (the empty-form rule allows it); give the button the Semantics hint "Alasan · wajib belum diisi" while unmet so the reason is still announced.
  - On the Bendahara Jemaat side the Draf is drawn in solid-edged cards (`dibukukan` line) with a dashed "Draf" badge, while GarisStatus says a draft is dashed. Keep the board; flag for design.
  - "No. Bukti baru" is the board's stand-in for the number a new booking gets. Keep the words; do not invent a number.
  - Booked-row amounts are mono at weight 400 (inherited), unlike the 500 used on the blocker card. Copy the board.
  - Inputs show their value at 14 `tinta2` (shared note).

### WebAlurUnit — Web · Alur · Keuangan unit

- **Source** `docs/design/handoff/canvas/boards/WebAlurUnit.dc.html` · page Putaran 5 · Kolaborasi (`p5`) · form Laptop page (preview 1440×1000, `expand: fill`) · interactive yes
- **Route** `/WebAlurUnit`, no child routes · **Widget** `WebAlurUnitScreen` in `lib/screens/p5/web_alur_unit.dart`
- **Purpose** The same unit-finance flow on the laptop, where the Bendahara Jemaat works (Q26; the Bendahara Kolom 7 side is shown for completeness). Same decisions as AlurUnit: P14, D01, P12, GarisStatus.
- **Shell** Platform web side nav; active item **Keuangan** (index 1). Footer bold "Meiske Lumentut" + " · Bendahara Jemaat" (stays the same when the panel views the board as Bendahara Kolom 7).
- **Layout**
  1. Title block: breadcrumb "Keuangan" (→ WebBeranda); h1 "Alur · Keuangan unit"; subtitle 14 `tinta2` "Bendahara Kolom 7 membukukan; Bendahara Jemaat menyelesaikan hambatan".
  2. Content column (max-width 1120, gap 16), same branches and order as AlurUnit at body size 15:
     a. (Board: "Dilihat sebagai" pills → panel.)
     b. Message banner.
     c. **Bendahara Kolom 7**: the scope box as a full-width block (1120 at 1440), then a two-column form row (shared note):
        - Left (column gap 12): pills "Jenis", field "Jumlah (Rp)" with its hint, pills "Kas/Bank", field "Uraian", refusal line, button row "Bukukan" (340). Inputs stretch to the column (about 608 at 1440).
        - Right (column gap 12): h2 "Peruntukan Kolom 7 · November 2026", the booked rows, the dashed draft box, with the same copy as AlurUnit 3h–3j (titles 15/600, amounts mono 15/400).
     d. **Bendahara Jemaat**: blocker, reason and resolved blocks exactly as AlurUnit 4–6, each a single block in the 1120 column (dashed box, cards, notice box and textarea stretch to 1120; buttons keep `flex 1 1 150; max-width 340`, so "Pindah tanggal" and "Kembali" are 340 each on one line).
     e. Riwayat (stretches to 1120).
- **Components** As AlurUnit, plus the platform web side nav and the two-column form row.
- **Internal views and states** Same as AlurUnit (same initial state, same branches).
- **Tweaks** `keadaan` (options `Alur`, default `Alur`; no visible effect). Keadaan panel.
- **Interactions** Same as AlurUnit, handler for handler, with the same conditions, refusal sentences, messages and Riwayat rows. Side nav and "Menu" toggle as the shared shell.
- **Motion** none.
- **Links out**
  - Breadcrumb "Keuangan" → `/WebBeranda`, up link.
  - Side nav, all `go`, the ten items in the shared notes.
  - **Inbound** PetaPlatform.
- **Mock data** Same as AlurUnit; footer Meiske Lumentut, Bendahara Jemaat; church Jemaat Karunia.
- **Prototype-only** Same as AlurUnit: "Dilihat sebagai" (Bendahara Kolom 7 · Bendahara Jemaat) goes to the Keadaan panel.
- **Acceptance checks**
  1. `/WebAlurUnit` at 1440 → nav "Keuangan" active, footer "Meiske Lumentut · Bendahara Jemaat"; breadcrumb "Keuangan"; scope box across the column; form left (about 608), "Peruntukan Kolom 7 · November 2026" with the BKU-2026-0151 row and the dashed draft right (about 484).
  2. Same entry as AlurUnit check 2–3 → new row appears in the right column under BKU-2026-0151; banner above the scope box; Riwayat below the two columns.
  3. Panel "Bendahara Jemaat" → blocker box and Draf card across 1120; "Pindah tanggal ke November" 340 wide; footer unchanged.
  4. Reason flow as AlurUnit checks 6–7 → "Pindah tanggal" and "Kembali" side by side; result card, notice box and banner as AlurUnit.
  5. At 860 → "Menu" top bar, the Kolom 7 form still two columns; at 390 → columns stacked, no horizontal scroll.
  6. Breadcrumb "Keuangan" → `/WebBeranda`; nav "Panitia" → `/Panitia` (in the phone frame). Both do `go` here (WebBeranda is never directly beneath), so only browser Back on web returns here (state fresh); on iOS/Android there is no page beneath.
- **Notes**
  - Same refusal, line-language and "No. Bukti baru" notes as AlurUnit.
  - Bendahara Jemaat cards stretch to 1120 at 1440. Keep the board; flag for design.
  - The footer identity does not follow the panel's "Dilihat sebagai". Keep it static.

### AlurDana — 95 · Alur · Permintaan dana

- **Source** `docs/design/handoff/canvas/boards/AlurDana.dc.html` · page Putaran 5 · Kolaborasi (`p5`) · form Phone 390×844 · interactive yes
- **Route** `/AlurDana`, no child routes (the request form, the decision and the booking change in place) · **Widget** `AlurDanaScreen` in `lib/screens/p5/alur_dana.dart`
- **Purpose** A fund request across three posts. The Ketua Komisi Diakonia (Pnt. Hendrik Rumagit) asks for money from the Diakonia peruntukan; the Ketua Jemaat (Pdt. Lidya Rondonuwu) approves it or records "tidak disetujui" with a reason; the Bendahara Jemaat (Meiske Lumentut) books an approved request as Uang Muka diberikan. Shows P13 (approval is not payment; an approved request is always booked as an advance), P09 (the requester never approves their own request), P12 (reason not blank), the in-app approval wording "Disetujui oleh {nama}" (01-foundations), the two-person step. Journey: Bendahara unit and committee officers step 2 ("Permintaan dana", "Alur · Permintaan dana"). (Pimpinan Jemaat step 3 "Permintaan dana (approving)" is PermintaanDana, not this board.)
- **Shell** Phone header with back: Semantics "Kembali ke Permintaan dana" → PermintaanDana. Title "Alur · Permintaan dana"; subtitle "Diajukan unit, disetujui Ketua Jemaat, dibukukan Bendahara Jemaat". No tab bar.
- **Layout** (body column, gap 16; blocks appear by actor and status `st`)
  1. (Board: "Dilihat sebagai" label with pills "Ketua Komisi Diakonia" · "Ketua Jemaat" · "Bendahara Jemaat". Not on screen; it goes to the panel.)
  2. Message banner (only while `pesan` is set).
  3. **Request form** (Ketua Komisi Diakonia, while `st` is empty or "Tidak disetujui"):
     a. Field "Keperluan", placeholder "Contoh: Kunjungan diakonia Desember", free text.
     b. Field "Jumlah (Rp)", placeholder "0", digits rule with dot separators, hint = Rupiah hint.
     c. Info row (standalone): "Diambil dari peruntukan" → "Diakonia".
     d. Only after a refusal by the Ketua Jemaat: dashed box, padding 12 × 14, 14 px: bold "Tidak disetujui." then a space and `tinta2` the recorded reason.
     e. Refusal line "Tidak dapat dilakukan: Ajukan." + reason (when shown).
     f. Button row: TombolBersyarat "Ajukan permintaan" (340).
  4. **Request card** (whenever `st` is "Menunggu persetujuan", "Disetujui" or "Dibukukan", except for the Bendahara Jemaat while it waits): card; head "Permintaan dana · {Keperluan}" 700 + badge:
     - "Menunggu persetujuan" → `draf` badge;
     - "Disetujui" → `laut` badge reading "Disetujui oleh Pdt. Lidya Rondonuwu";
     - "Dibukukan" → `tinta` badge.
     Info rows "Jumlah (Rp)" → mono weight 600 (inherited) Rupiah value; "Diajukan oleh" → "Pnt. Hendrik Rumagit, Ketua Komisi Diakonia". Then 13 `tinta3`:
     - waiting: "Diajukan 16/11/2026 · menunggu Ketua Jemaat"
     - approved: "Disetujui di aplikasi oleh orang yang masuk sendiri, 16/11/2026."
     - booked: "Dibukukan Bendahara Jemaat sebagai Uang Muka diberikan, 16/11/2026. Pertanggungjawabannya dicatat pada kasus Uang Muka."
  5. **Own request, waiting** (Ketua Komisi Diakonia, "Menunggu persetujuan"): a refusal line at **15 px**: bold `bata` "Tidak dapat dilakukan: Setujui." + " permintaan ini Anda ajukan sendiri." (`tinta`); then 13 `tinta3` "Menunggu Pdt. Lidya Rondonuwu, Ketua Jemaat." No button.
  6. **Decision** (Ketua Jemaat, "Menunggu persetujuan", view `utama`): button row: primary "Setujui" + secondary "Tidak disetujui" (171 each; the secondary stretches to the row's 52).
  7. **Refusal reason** (Ketua Jemaat, "Menunggu persetujuan", view `tolak`): reason textarea "Alasan · wajib"; (a "Tidak dapat dilakukan: Tidak disetujui." line exists in the source but can never show); button row TombolBersyarat "Catat tidak disetujui" + text button "Kembali".
  8. **Approved note** (any actor, "Disetujui"): dashed box, padding 12 × 14, 14 px: bold "Disetujui bukan berarti sudah dibayar." then `tinta2` " Uang baru keluar ketika Bendahara Jemaat membukukannya."
  9. **Book** (Bendahara Jemaat, "Disetujui"): button row: primary "Bukukan sebagai Uang Muka" (340).
  10. **Nothing to book** (Bendahara Jemaat, any status except "Disetujui" and "Dibukukan"): dashed box, padding 14 × 16, gap 6: "Belum ada yang perlu dibukukan" 700; 14 `tinta2` "Permintaan dana muncul di sini setelah Disetujui."
  11. Riwayat (when there are rows; all actors).

  What each actor sees, by status: empty → Komisi: form; Ketua: nothing but Riwayat (empty body); Bendahara: box 10. Waiting → Komisi: card + 5; Ketua: card + 6 or 7; Bendahara: box 10 (no card). Tidak disetujui → Komisi: form with box 3d; Ketua: Riwayat only; Bendahara: box 10. Disetujui → all: card + 8; Bendahara also 9. Dibukukan → all: card only.
- **Components** TombolBersyarat ("Ajukan permintaan", "Catat tidak disetujui"), Penolakan (form refusal; the 15 px own-request refusal), Tombol (primary "Setujui", "Bukukan sebagai Uang Muka"; secondary "Tidak disetujui"; text "Kembali"), LencanaStatus shapes (`draf`, `laut`, `tinta`), GarisStatus (`draf` dashed boxes, `dibukukan` card), IsianAlasan look, RiwayatAlur, message banner. Pattern: two-person step (requester sees "menunggu Ketua Jemaat").
- **Internal views and states** Initial state `{ k: null, a: { pesan: '', riw: [], v: 'utama', akt: 'Ketua Komisi Diakonia', perlu: '', jml: '', st: '', alasan: '', tolak: '' } }`. Views `utama` and `tolak` (the latter only matters for the Ketua Jemaat while waiting). Status `st`: '' → "Menunggu persetujuan" → "Disetujui" → "Dibukukan", or → "Tidak disetujui" → (resubmit) "Menunggu persetujuan". Shared by all actors.
- **Tweaks** `keadaan` (options `Alur`, default `Alur`; no visible effect). Keadaan panel.
- **Interactions**
  - Actor (panel "Dilihat sebagai", `pick`) → `akt` = one of the three, `pesan = ''`.
  - Keperluan typing (`onPerlu`) → free text. Jumlah typing (`onJml`) → digits rule, dot separators, hint follows.
  - "Ajukan permintaan" condition, first unmet reason: (1) Keperluan blank after trim → "keperluan belum diisi."; (2) amount 0 or empty → "jumlah belum diisi.". The refusal line shows once Keperluan or Jumlah is non-empty. Press when met (`ajukan`) → `st = 'Menunggu persetujuan'`, `pesan` = "Ketua Jemaat diberi tahu lewat Pemberitahuan.", Riwayat gains "16/11/2026 · Permintaan dana Rp{jumlah} · {Keperluan trimmed} diajukan · Pnt. Hendrik Rumagit, Ketua Komisi Diakonia". Keperluan and Jumlah are kept (the card title shows Keperluan as typed).
  - "Setujui" (`setuju`, unconditional) → `st = 'Disetujui'`, `pesan = ''`, Riwayat gains "16/11/2026 · Permintaan dana Disetujui oleh Pdt. Lidya Rondonuwu, Ketua Jemaat".
  - "Tidak disetujui" (`keTolak`) → `v = 'tolak'`, `pesan = ''`, `alasan = ''`.
  - Reason typing (`onAlasan`) → free text. "Catat tidak disetujui" condition: reason not blank after trim (no sentence ever shows). Press when met (`tolakkan`) → `st = 'Tidak disetujui'`, `v = 'utama'`, `tolak` = trimmed reason, `alasan = ''`, `pesan = ''`, Riwayat gains "16/11/2026 · Permintaan dana tidak disetujui · alasan: {alasan} · Pdt. Lidya Rondonuwu".
  - "Kembali" (`pulang`) → `v = 'utama'`, `pesan = ''`.
  - "Bukukan sebagai Uang Muka" (`bayar`, unconditional) → `st = 'Dibukukan'`, `pesan = ''`, Riwayat gains "16/11/2026 · Uang Muka diberikan Rp{jumlah} dibukukan · Meiske Lumentut, Bendahara Jemaat".
  - After "Tidak disetujui", the Komisi form shows again with the old values; "Ajukan permintaan" resubmits (same handler, same Riwayat wording, `tolak` kept but box 3d hidden because the status is no longer "Tidak disetujui").
  - No timers.
- **Motion** none.
- **Links out**
  - Header back "Kembali ke Permintaan dana" → `/PermintaanDana`, up link.
  - **Inbound** PetaPlatform.
- **Mock data** Pnt. Hendrik Rumagit, Ketua Komisi Diakonia; Pdt. Lidya Rondonuwu, Ketua Jemaat; Meiske Lumentut, Bendahara Jemaat; peruntukan "Diakonia"; today 16/11/2026. Example used in checks: "Kunjungan diakonia Desember", Rp1.500.000.
- **Prototype-only** On the board: "Dilihat sebagai" pills (Ketua Komisi Diakonia · Ketua Jemaat · Bendahara Jemaat). Keadaan panel, "Alat prototipe": "Dilihat sebagai" as a three-option choice (default Ketua Komisi Diakonia) calling `pick`. Plus `keadaan`, "Semua layar", inbound links, canvas title. The placeholder "Contoh: Kunjungan diakonia Desember" stays on screen.
- **Acceptance checks**
  1. Open `/AlurDana` → panel "Dilihat sebagai: Ketua Komisi Diakonia"; form "Keperluan", "Jumlah (Rp)" with hint "Rp0", "Diambil dari peruntukan · Diakonia", grey "Ajukan permintaan", no refusal line.
  2. Jumlah "1500000" → field "1.500.000", hint "Rp1.500.000", "Tidak dapat dilakukan: Ajukan. keperluan belum diisi."; Keperluan "Kunjungan diakonia Desember" → button `tinta`.
  3. Press → card "Permintaan dana · Kunjungan diakonia Desember" with dashed badge "Menunggu persetujuan", "Rp1.500.000", "Diajukan oleh Pnt. Hendrik Rumagit, Ketua Komisi Diakonia", "Diajukan 16/11/2026 · menunggu Ketua Jemaat"; banner "Ketua Jemaat diberi tahu lewat Pemberitahuan."; 15 px "Tidak dapat dilakukan: Setujui. permintaan ini Anda ajukan sendiri." and "Menunggu Pdt. Lidya Rondonuwu, Ketua Jemaat."; Riwayat "16/11/2026 · Permintaan dana Rp1.500.000 · Kunjungan diakonia Desember diajukan · Pnt. Hendrik Rumagit, Ketua Komisi Diakonia".
  4. Panel "Bendahara Jemaat" → banner gone, no card, dashed "Belum ada yang perlu dibukukan".
  5. Panel "Ketua Jemaat" → card + "Setujui" / "Tidak disetujui". "Tidak disetujui" → "Alasan · wajib", grey "Catat tidak disetujui" (no sentence), "Kembali". Reason "Anggaran Desember sudah penuh" → press → only Riwayat remains; top row "16/11/2026 · Permintaan dana tidak disetujui · alasan: Anggaran Desember sudah penuh · Pdt. Lidya Rondonuwu".
  6. Panel "Ketua Komisi Diakonia" → form with the old values and dashed "Tidak disetujui. Anggaran Desember sudah penuh"; "Ajukan permintaan" `tinta`; press → waiting card again.
  7. Panel "Ketua Jemaat", "Setujui" → `laut` badge "Disetujui oleh Pdt. Lidya Rondonuwu" (badge not overflowing, see Notes), "Disetujui di aplikasi oleh orang yang masuk sendiri, 16/11/2026.", dashed "Disetujui bukan berarti sudah dibayar. Uang baru keluar ketika Bendahara Jemaat membukukannya."
  8. Panel "Bendahara Jemaat" → card, note and "Bukukan sebagai Uang Muka"; press → `tinta` badge "Dibukukan", "Dibukukan Bendahara Jemaat sebagai Uang Muka diberikan, 16/11/2026. Pertanggungjawabannya dicatat pada kasus Uang Muka.", note and button gone; Riwayat top "16/11/2026 · Uang Muka diberikan Rp1.500.000 dibukukan · Meiske Lumentut, Bendahara Jemaat".
  9. Header back → `/PermintaanDana`.
- **Notes**
  - The `laut` badge "Disetujui oleh Pdt. Lidya Rondonuwu" is about 275 px wide; with the 16 gap and the title's longest word it does not fit the 316 px card head row (350 − 2 border − 32 padding) (the HTML overflows). Recommended: lay the head row out so that when the badge does not fit beside the title, the badge drops to its own line under the title, left-aligned (a `LayoutBuilder` or `Wrap`); keep side-by-side otherwise. Never shrink or wrap the badge text.
  - The own-request refusal is 15 px on a 16 px phone board (Penolakan is 14 elsewhere). Copy 15.
  - The Ketua Jemaat sees an empty body before any request and after a refusal (only Riwayat, if any). Keep the board.
  - The "Catat tidak disetujui" refusal is dead code (`al && !al`), as on AlurUnit; add the Semantics hint "Alasan · wajib belum diisi" while unmet.
  - Status words "Menunggu persetujuan", "Disetujui …", "Dibukukan" use LencanaStatus shapes not listed in its table (approval words). Copy the board's variants.

### AlurIbadah — 96 · Alur · Ibadah dan kehadiran

- **Source** `docs/design/handoff/canvas/boards/AlurIbadah.dc.html` · page Putaran 5 · Kolaborasi (`p5`) · form Phone 390×844 · interactive yes
- **Route** `/AlurIbadah`, no child routes (the three views `jadwal`, `hitung`, `koreksi` change in place under one header) · **Widget** `AlurIbadahScreen` in `lib/screens/p5/alur_ibadah.dart`
- **Purpose** A Kolom 7 service from scheduling to a set attendance figure. Journey: Penatua Kolom step 3 ("Ibadah dan kegiatan", "Jumlah kehadiran", "Alur · Ibadah dan kehadiran"). Shows: a Kolom service is approved by the Penatua Kolom 7 (Pnt. Hendrik Rumagit), while a whole-church service is scheduled by the Sekretaris Jemaat and approved by the Ketua Jemaat (refused here); attendance is counts only ("Jumlah saja. Tidak ada nama, …"); counting → "Sudah diperiksa" → "Ditetapkan"; a set figure is never edited, only corrected with a reason (P12). No actor switch: the board is one person's flow.
- **Shell** Phone header with back: Semantics "Kembali ke Ibadah dan kegiatan" → Ibadah. Title "Alur · Ibadah dan kehadiran"; subtitle "Dari menjadwalkan sampai Jumlah kehadiran Ditetapkan". No tab bar.
- **Layout** (body column, gap 16)
  1. Message banner: present in the source but no handler ever sets a message, so it never shows. Build nothing.
  2. **View `jadwal`, not yet scheduled** (`st` empty):
     a. Pills "Ibadah": "Ibadah Kolom 7" · "Ibadah seluruh Jemaat".
     b. Field "Tanggal", placeholder "hh/bb/tttt", hint "Hari ini atau sesudahnya.", date rule.
     c. Field "Jam", placeholder "jj.mm", hint "Contoh: 19.00", time rule.
     d. Field "Tempat", placeholder "Contoh: rumah Kel. Wenas-Lasut", free text.
     e. Refusal line "Tidak dapat dilakukan: Jadwalkan." + reason.
     f. Button row: TombolBersyarat "Jadwalkan" (340).
  3. **View `jadwal`, scheduled** (`st` set): card: head "{Ibadah}" (the chosen pill, falls back to "Ibadah Kolom 7") 700 + badge `st`: "Dijadwalkan" → `lautg`; "Ditutup" → `tinta`. 14 `tinta2` "{Tanggal} · {Jam} · {Tempat}" (each trimmed). 13 `tinta3`: while Dijadwalkan "Disetujui oleh Pnt. Hendrik Rumagit, Penatua Kolom 7. Masuk ke Warta Jemaat bila ditujukan untuk semua anggota."; when Ditutup "Jumlah kehadiran Ditetapkan: {total} orang.". While Dijadwalkan only: button row primary "Catat jumlah kehadiran" (340).
  4. **View `hitung`**:
     a. Card: head "{Ibadah}" + badge: count state empty → `draf` "Sedang dihitung"; "Sudah diperiksa" → `lautg`; "Ditetapkan" → `tinta`. 14 `tinta2` "{Tanggal} · {Jam} · {Tempat}".
     b. While counting: three fields "Laki-laki", "Perempuan", "Anak", placeholder "0", digits rule **without** separators (the value shows raw, e.g. "1200"). They sit in a grid `repeat(auto-fit, minmax(300px, 1fr))`, gap 16: at 350 wide one column, so they stack 16 apart (on a wider window they would share a row; keep one column inside the phone frame).
     c. Total card (card shape): head row "Jumlah kehadiran" 700 left, total in IBM Plex Mono 22/500 right (plain number, no separators; "0" at start); 13 `tinta3` "Jumlah saja. Tidak ada nama, tidak ada daftar yang tidak hadir."
     d. While counting: refusal line "Tidak dapat dilakukan: Tandai sudah diperiksa." + "jumlah kehadiran masih nol." (when shown); button row TombolBersyarat "Tandai sudah diperiksa" + text button "Kembali".
     e. While "Sudah diperiksa": button row primary "Tetapkan" + text button "Ubah angka".
     f. While "Ditetapkan": 13 `tinta3` "Angka yang Ditetapkan tidak diubah; perbaikan dicatat sebagai koreksi dengan alasan."; button row secondary "Koreksi" + text button "Kembali".
  5. **View `koreksi`**:
     a. Card: head "Koreksi jumlah kehadiran" + `tinta` badge "Ditetapkan"; info row "Angka sekarang" → mono weight 600 (inherited) current total.
     b. Field "Jumlah yang benar", placeholder "0", digits rule without separators.
     c. Reason textarea "Alasan · wajib".
     d. Refusal line "Tidak dapat dilakukan: Catat koreksi." + reason.
     e. Button row TombolBersyarat "Catat koreksi" + text button "Batal".
  6. Riwayat (when there are rows; in every view).
- **Components** TombolBersyarat ("Jadwalkan", "Tandai sudah diperiksa", "Catat koreksi"), Penolakan, ChipPilihan (Ibadah), LencanaStatus shapes (`draf` "Sedang dihitung", `lautg` "Dijadwalkan"/"Sudah diperiksa", `tinta` "Ditetapkan"/"Ditutup"), GarisStatus (`dibukukan` cards), IsianAlasan look, Tombol (primary "Catat jumlah kehadiran", "Tetapkan"; secondary "Koreksi"; text "Kembali", "Ubah angka", "Batal"), RiwayatAlur. Pattern: big mono total card.
- **Internal views and states** Initial state `{ k: null, a: { pesan: '', riw: [], v: 'jadwal', jenis: '', tgl: '', jam: '', tempat: '', st: '', l: '', p: '', a: '', hst: '', kor: '', alasan: '' } }` (`korSah` absent until a correction). Views: `jadwal` (form or scheduled card), `hitung` (counting / checked / set), `koreksi`. Service status `st`: '' → "Dijadwalkan" → "Ditutup". Count status `hst`: '' ("Sedang dihitung") → "Sudah diperiksa" → "Ditetapkan" (and back to '' by "Ubah angka"). Total = the last correction (`korSah`) if any, else Laki-laki + Perempuan + Anak.
- **Tweaks** `keadaan` (options `Alur`, default `Alur`; no visible effect). Keadaan panel.
- **Interactions**
  - Ibadah pill (`pick`) → `jenis`, `pesan = ''`.
  - Tanggal / Jam / Tempat typing → free text (`ketik`), checked as in the rules.
  - "Jadwalkan" condition, first unmet reason: (1) no Ibadah → "ibadah belum dipilih."; (2) "Ibadah seluruh Jemaat" → "ibadah seluruh Jemaat dijadwalkan Sekretaris Jemaat dan disetujui Ketua Jemaat."; (3) date not recognised → "tanggal tidak dikenali. Contoh: 19/11/2026."; (4) before 16/11/2026 → "tanggal sudah lewat." (today itself passes); (5) time not recognised → "jam tidak dikenali. Contoh: 19.00."; (6) Tempat blank after trim → "tempat belum diisi.". The refusal line shows once any of Ibadah, Tanggal, Jam, Tempat is non-empty. Press when met (`jadwalkan`) → `st = 'Dijadwalkan'`, `pesan = ''`, Riwayat gains "16/11/2026 · {Ibadah} {Tanggal} {Jam} dijadwalkan · Disetujui oleh Pnt. Hendrik Rumagit" (e.g. "Ibadah Kolom 7 19/11/2026 19.00 dijadwalkan · …"). The form is replaced by the card.
  - "Catat jumlah kehadiran" (`keHitung`) → `v = 'hitung'`, `pesan = ''`.
  - Laki-laki / Perempuan / Anak typing → digits rule; the total updates on every keystroke.
  - "Tandai sudah diperiksa" condition: total > 0, else "jumlah kehadiran masih nol." — shown only when at least one of the three fields is non-empty and the total is 0 (e.g. "0" typed); never on empty fields. Press when met (`periksa`) → `hst = 'Sudah diperiksa'`, Riwayat gains "16/11/2026 · Jumlah kehadiran {total} orang ditandai Sudah diperiksa". The fields disappear.
  - "Ubah angka" (`ubah`) → `hst = ''`: fields return with their values.
  - "Tetapkan" (`tetapkan`, unconditional) → `hst = 'Ditetapkan'`, `st = 'Ditutup'`, Riwayat gains "16/11/2026 · Jumlah kehadiran Ditetapkan: {total} orang · Pnt. Hendrik Rumagit". View stays `hitung`.
  - "Kembali" (both, `pulang`) → `v = 'jadwal'`, `pesan = ''`. From the counting state this keeps the typed numbers; once Ditutup the `jadwal` card has no button back to the count (see Notes).
  - "Koreksi" (`keKoreksi`) → `v = 'koreksi'`, `pesan = ''`, `kor = ''`, `alasan = ''`.
  - "Jumlah yang benar" typing → digits rule. Reason typing → free text.
  - "Catat koreksi" condition, first unmet: (1) number not > 0 → "jumlah yang benar belum diisi."; (2) reason blank after trim → "alasan belum diisi.". Shown once the number or the trimmed reason is non-empty. Press when met (`koreksi`) → `v = 'hitung'`, `korSah` = the number, `alasan = ''`, Riwayat gains "16/11/2026 · Koreksi jumlah kehadiran: {old total} menjadi {new} orang · alasan: {alasan}". The total card and the Ditutup card sentence now use the corrected number; the count badge stays "Ditetapkan".
  - "Batal" (`keHitung`) → `v = 'hitung'`, `pesan = ''`.
  - No timers.
- **Motion** none.
- **Links out**
  - Header back "Kembali ke Ibadah dan kegiatan" → `/Ibadah`, up link.
  - **Inbound** PetaPlatform.
- **Mock data** Pnt. Hendrik Rumagit, Penatua Kolom 7; services "Ibadah Kolom 7", "Ibadah seluruh Jemaat"; Sekretaris Jemaat and Ketua Jemaat named by post only; today 16/11/2026; example date 19/11/2026, time 19.00, place "rumah Kel. Wenas-Lasut" (placeholder). Example counts used in checks: 12, 18, 7 (total 37), corrected to 39.
- **Prototype-only** none on this board (the "Contoh: …" texts are a placeholder and a hint, not buttons). Keadaan panel: `keadaan`, "Semua layar", inbound links, canvas title.
- **Acceptance checks**
  1. Open `/AlurIbadah` → no banner; Ibadah pills unselected, "Tanggal" (placeholder "hh/bb/tttt", hint "Hari ini atau sesudahnya."), "Jam" (hint "Contoh: 19.00"), "Tempat", grey "Jadwalkan", no refusal line.
  2. Pick "Ibadah seluruh Jemaat" → "Tidak dapat dilakukan: Jadwalkan. ibadah seluruh Jemaat dijadwalkan Sekretaris Jemaat dan disetujui Ketua Jemaat."; pick "Ibadah Kolom 7" → "tanggal tidak dikenali. Contoh: 19/11/2026."
  3. Tanggal "15/11/2026" → "tanggal sudah lewat."; "19/11/2026" with Jam "19:00" → "jam tidak dikenali. Contoh: 19.00."; "19.00" → "tempat belum diisi."; Tempat "rumah Kel. Wenas-Lasut" → button `tinta`.
  4. "Jadwalkan" → card "Ibadah Kolom 7" with `lautg` badge "Dijadwalkan", "19/11/2026 · 19.00 · rumah Kel. Wenas-Lasut", "Disetujui oleh Pnt. Hendrik Rumagit, Penatua Kolom 7. …", "Catat jumlah kehadiran"; Riwayat "16/11/2026 · Ibadah Kolom 7 19/11/2026 19.00 dijadwalkan · Disetujui oleh Pnt. Hendrik Rumagit".
  5. "Catat jumlah kehadiran" → dashed badge "Sedang dihitung", three stacked fields, total "0", grey "Tandai sudah diperiksa", no refusal; type "0" in Laki-laki → "Tidak dapat dilakukan: Tandai sudah diperiksa. jumlah kehadiran masih nol."
  6. 12 / 18 / 7 → total "37" (mono 22); press → badge "Sudah diperiksa", fields gone, "Tetapkan" + "Ubah angka"; Riwayat top "… Jumlah kehadiran 37 orang ditandai Sudah diperiksa". "Ubah angka" → fields back with 12, 18, 7; press again.
  7. "Tetapkan" → `tinta` badge "Ditetapkan", the note, "Koreksi" + "Kembali"; Riwayat top "16/11/2026 · Jumlah kehadiran Ditetapkan: 37 orang · Pnt. Hendrik Rumagit".
  8. "Koreksi" → "Koreksi jumlah kehadiran" with "Ditetapkan", "Angka sekarang 37"; reason "Anak sekolah minggu terlewat" alone → "… jumlah yang benar belum diisi."; number "39" → button `tinta`; press → back to the count, total "39"; Riwayat top "16/11/2026 · Koreksi jumlah kehadiran: 37 menjadi 39 orang · alasan: Anak sekolah minggu terlewat".
  9. "Kembali" → card badge `tinta` "Ditutup", "Jumlah kehadiran Ditetapkan: 39 orang.", no button.
  10. Header back → `/Ibadah`.
- **Notes**
  - Once Ditutup, "Kembali" leaves the count view with no way back to it (no "Catat jumlah kehadiran" on a closed service). Keep the board; flag.
  - A correction may equal the current figure (39 → 39 is accepted). Keep the board.
  - The board has no `pesan` messages at all; the banner slot is dead. Do not invent messages.
  - The date field does not auto-insert slashes although TombolBersyarat's README says dates are typed as hh/bb/tttt and checked while typing; the board checks the full pattern only. Copy the board.
  - The attendance fields and totals show raw digits (no thousands separator), unlike money fields. Copy the board.

### AlurPanitia — 97 · Alur · Panitia

- **Source** `docs/design/handoff/canvas/boards/AlurPanitia.dc.html` · page Putaran 5 · Kolaborasi (`p5`) · form Phone 390×844 · interactive yes
- **Route** `/AlurPanitia`, no child routes (the four Panitia states change in place) · **Widget** `AlurPanitiaScreen` in `lib/screens/p5/alur_panitia.dart`
- **Purpose** Closing Panitia Natal 2026: from Aktif through "Penutupan keuangan" to Ditutup and Diarsipkan. Shows P16 (close only after advances are accounted for and leftover money is returned to the general fund; the asset handover record is attached when there are assets and does not block closing), the Alih peruntukan back to "Umum Jemaat" by the Bendahara Jemaat, the "Ditutup" (tinta) vs "Diarsipkan" (grey) states. Journey: Bendahara unit and committee officers step 3 ("Panitia Natal 2026", "Alur · Panitia"). Actors named in Riwayat: Stevi Lengkong (Ketua Panitia), Rivo Mandagi (Bendahara Panitia), Meiske Lumentut (Bendahara Jemaat).
- **Shell** Phone header with back: Semantics "Kembali ke Panitia" → Panitia. Title "Alur · Panitia"; subtitle "Panitia Natal 2026 dari Aktif sampai Diarsipkan". No tab bar.
- **Layout** (body column, gap 16)
  1. Message banner: present but never set by any handler. Build nothing.
  2. Panitia card (always): head "Panitia Natal 2026" 700 + badge by status: "Aktif" `laut`; "Penutupan keuangan" `draf`; "Ditutup" `tinta`; "Diarsipkan" `abu`. 14 `tinta2` "Ketua: Stevi Lengkong · Bendahara: Rivo Mandagi". 13 `tinta3`: Aktif "Membukukan di peruntukan Panitia Natal 2026."; Penutupan keuangan "Tidak ada transaksi baru selain yang menyelesaikan penutupan."; Ditutup "Ditutup 16/11/2026."; Diarsipkan "Diarsipkan 16/11/2026."
  3. **Aktif**: button row primary "Mulai penutupan keuangan" (340).
  4. **Penutupan keuangan**:
     a. h2 `judulBagian` "Uang harus selesai sebelum Panitia ditutup".
     b. Advance card: head "Uang Muka · Dekorasi Natal" + badge `bata` "Belum dipertanggungjawabkan" / `laut` "Sudah dipertanggungjawabkan"; info row "Diberikan" → mono 500 "Rp300.000". (Board: text button "Contoh: pertanggungjawaban dibukukan", intrinsic width, while not accounted for → panel.)
     c. Leftover card: head "Sisa uang Panitia" + badge `bata` "Belum dikembalikan" / `laut` "Sudah dikembalikan"; info row "Saldo peruntukan Panitia Natal 2026" → mono 500 "Rp350.000"; 13 `tinta3` "Sisa dikembalikan ke peruntukan Umum Jemaat lewat Alih peruntukan oleh Bendahara Jemaat." (Board: text button "Contoh: alih peruntukan dibukukan" while not returned → panel.)
     d. Asset handover box (dashed box, padding 14 × 16, gap 6): head "Serah terima aset · bila ada" 700 + badge `draf` "Belum dilampirkan" / `garis` "Terlampir"; field "Tanggal serah terima", placeholder "hh/bb/tttt", hint "Sesuai berita acara.", date rule; while no file: secondary button "Pilih file berita acara" (intrinsic width); with file: 13 `tinta3` "berita-acara-serah-terima.pdf"; then 13 `tinta3` "Tidak menghalangi penutupan. Lampirkan bila Panitia punya aset yang diserahkan."
     e. Refusal line "Tidak dapat dilakukan: Tutup Panitia." + reason (shown whenever unmet, from the first moment).
     f. Button row TombolBersyarat "Tutup Panitia" (340).
  5. **Ditutup**: 13 `tinta3` "Panitia yang Ditutup tidak dapat membukukan lagi. Riwayat dan laporannya tetap dapat dibaca."; button row secondary "Arsipkan" (340).
  6. **Diarsipkan**: 13 `tinta3` "Diarsipkan: tidak tampil di daftar Panitia aktif, tetap dapat dicari dan dibaca."
  7. Riwayat (when there are rows).
- **Components** LencanaStatus shapes (`laut`, `draf`, `tinta`, `abu`, `bata`, `garis`), GarisStatus (`dibukukan` cards, `draf` handover box), TombolBersyarat ("Tutup Panitia"), Penolakan, Tombol (primary "Mulai penutupan keuangan"; secondary "Pilih file berita acara", "Arsipkan"), RiwayatAlur. Pattern: closing checklist of cards with state badges.
- **Internal views and states** Initial state `{ k: null, a: { pesan: '', riw: [], v: 'utama', st: 'Aktif', um: false, sisa: false, file: '', tglST: '' } }`. One view; content by `st`: "Aktif" → "Penutupan keuangan" → "Ditutup" → "Diarsipkan". Inside Penutupan keuangan: `um` (advance accounted), `sisa` (leftover returned), `file` ('' / 'ada'), `tglST`. The source's `fileSt` helper also defines a 'gagal' upload state, but it is switched off here (`fileSt(false)`) and its labels are overridden; do not build it.
- **Tweaks** `keadaan` (options `Alur`, default `Alur`; no visible effect). Keadaan panel.
- **Interactions**
  - "Mulai penutupan keuangan" (`mulaiTutup`) → `st = 'Penutupan keuangan'`, Riwayat gains "16/11/2026 · Penutupan keuangan Panitia Natal 2026 dimulai · Stevi Lengkong, Ketua Panitia".
  - Panel "Contoh: pertanggungjawaban dibukukan" (`umBeres`) → `um = true` (badge "Sudah dipertanggungjawabkan"), Riwayat gains "16/11/2026 · Pertanggungjawaban Uang Muka Dekorasi Natal dibukukan · Rivo Mandagi, Bendahara Panitia".
  - Panel "Contoh: alih peruntukan dibukukan" (`sisaBeres`) → `sisa = true` (badge "Sudah dikembalikan"), Riwayat gains "16/11/2026 · Sisa Rp350.000 dialihkan ke peruntukan Umum Jemaat · Meiske Lumentut, Bendahara Jemaat".
  - "Pilih file berita acara" (`pilihFile`) → `file = 'ada'` at once (no OS file picker): badge "Terlampir", file name line replaces the button. There is no remove.
  - Tanggal serah terima typing (`onTglST`) → free text, date rule.
  - "Tutup Panitia" condition, first unmet reason: (1) advance not accounted → "masih ada Uang Muka yang belum dipertanggungjawabkan."; (2) leftover not returned → "sisa uang Panitia belum dikembalikan."; (3) date typed but not recognised → "tanggal serah terima tidak dikenali. Contoh: 16/11/2026."; (4) date after 16/11/2026 → "tanggal serah terima belum tiba.". An empty date and no file are fine. The refusal line shows whenever unmet (even before any input). Press when met (`tutup`) → `st = 'Ditutup'`, Riwayat gains "16/11/2026 · Panitia Natal 2026 Ditutup · berita acara serah terima aset {tanggal} terlampir" when a file is attached, else "16/11/2026 · Panitia Natal 2026 Ditutup · tanpa berita acara serah terima aset".
  - "Arsipkan" (`arsip`) → `st = 'Diarsipkan'`, Riwayat gains "16/11/2026 · Panitia Natal 2026 Diarsipkan".
  - No timers; nothing can be undone.
- **Motion** none.
- **Links out**
  - Header back "Kembali ke Panitia" → `/Panitia`, up link.
  - **Inbound** AlurPanitiaBaru ("Lihat penutupan Panitia"), PetaPlatform.
- **Mock data** Panitia Natal 2026; Ketua Stevi Lengkong, Bendahara Rivo Mandagi (Sekretaris Natalia Rumengan not shown); Uang Muka "Dekorasi Natal" Rp300.000; saldo peruntukan Panitia Natal 2026 Rp350.000; peruntukan "Umum Jemaat"; Meiske Lumentut, Bendahara Jemaat; file "berita-acara-serah-terima.pdf"; today 16/11/2026. Panitia shows other money figures for Panitia Natal 2026 (`mock-data.md` conflict 34); keep this board's.
- **Prototype-only** On the board: two text buttons "Contoh: pertanggungjawaban dibukukan" and "Contoh: alih peruntukan dibukukan" (they stand for bookings made elsewhere). Keadaan panel, "Alat prototipe": both buttons with these exact labels, each shown only while the Panitia is in "Penutupan keuangan" and its item is not yet done, calling `umBeres` / `sisaBeres`. Plus `keadaan`, "Semua layar", inbound links, canvas title.
- **Acceptance checks**
  1. Open `/AlurPanitia` → card "Panitia Natal 2026" with `laut` badge "Aktif", "Ketua: Stevi Lengkong · Bendahara: Rivo Mandagi", "Membukukan di peruntukan Panitia Natal 2026.", "Mulai penutupan keuangan"; no Riwayat.
  2. Press → dashed badge "Penutupan keuangan"; heading, advance card (`bata` "Belum dipertanggungjawabkan", "Rp300.000"), leftover card (`bata` "Belum dikembalikan", "Rp350.000"), dashed handover box (dashed "Belum dilampirkan", "Pilih file berita acara"); refusal "Tidak dapat dilakukan: Tutup Panitia. masih ada Uang Muka yang belum dipertanggungjawabkan." already visible; grey "Tutup Panitia"; no "Contoh:" button on screen; Riwayat "16/11/2026 · Penutupan keuangan Panitia Natal 2026 dimulai · Stevi Lengkong, Ketua Panitia".
  3. Panel "Contoh: pertanggungjawaban dibukukan" → `laut` "Sudah dipertanggungjawabkan", reason "sisa uang Panitia belum dikembalikan.", the panel button disappears.
  4. Panel "Contoh: alih peruntukan dibukukan" → `laut` "Sudah dikembalikan", refusal gone, button `tinta`.
  5. Tanggal "17/11/2026" → "… tanggal serah terima belum tiba."; "1/11/2026" → "… tanggal serah terima tidak dikenali. Contoh: 16/11/2026."; "16/11/2026" → met.
  6. "Pilih file berita acara" → badge "Terlampir" (`garis`), "berita-acara-serah-terima.pdf" in place of the button.
  7. "Tutup Panitia" → `tinta` badge "Ditutup", "Ditutup 16/11/2026.", closing note, "Arsipkan"; Riwayat top "16/11/2026 · Panitia Natal 2026 Ditutup · berita acara serah terima aset 16/11/2026 terlampir".
  8. "Arsipkan" → grey (`abu`) badge "Diarsipkan", "Diarsipkan 16/11/2026.", "Diarsipkan: tidak tampil di daftar Panitia aktif, tetap dapat dicari dan dibaca."; five Riwayat rows.
  9. Fresh board, steps 2–4 without date or file, "Tutup Panitia" → Riwayat "… Ditutup · tanpa berita acara serah terima aset".
  10. Header back → `/Panitia`.
- **Notes**
  - The "Tutup Panitia" refusal shows before any input, which breaks TombolBersyarat's "an empty form does not open with a refusal". Keep the board: the blockers are not typed input, and the line explains the grey button.
  - With a file but an empty date the Riwayat string is "berita acara serah terima aset  terlampir" (two spaces). HTML collapses the double space, so the board shows one: collapse to one space; the words stay.
  - The flow cannot finish on screen without the panel's two "Contoh:" buttons. That is intended (they stand for bookings on other boards); the panel must show them prominently while relevant.
  - Even after AlurPanitiaBaru forms a different Panitia, this board always shows Panitia Natal 2026. Keep.

### PemberiPersetujuan — 98 · Alur · Pemberi persetujuan

- **Source** `docs/design/handoff/canvas/boards/PemberiPersetujuan.dc.html` · page Putaran 5 · Kolaborasi (`p5`) · form Phone 390×844 · interactive yes
- **Route** `/PemberiPersetujuan`, no child routes (one view `tabel`) · **Widget** `PemberiPersetujuanScreen` in `lib/screens/p5/pemberi_persetujuan.dart`
- **Purpose** The approver table, set once per church by the Pimpinan Jemaat yang berwenang (Pdt. Lidya Rondonuwu): for requests from Kolom, BIPRA, Komisi and Panitia, either that unit's own head or the Ketua Jemaat. Shows P09 (approver set by post, no amount limits, requester never approves their own request; a vacant approver post makes requests wait). Journey: Pimpinan Jemaat step 3 ("Alur · Pemberi persetujuan"). After saving, it leads to activating the in-app approval module (AlurModul).
- **Shell** Phone header with back: Semantics "Kembali ke Modul" → Modul. Title "Alur · Pemberi persetujuan"; subtitle "Jabatan mana yang menyetujui permintaan dari tiap jenis unit". No tab bar.
- **Layout** (body column, gap 16)
  1. Message banner (only while `pesan` is set).
  2. 14 `tinta2` intro: "Diisi sekali oleh Pimpinan Jemaat yang berwenang. Berlaku untuk Permintaan dana dan persetujuan lain di aplikasi."
  3. Four row cards, in this order (card: `permukaan`, 1 `garis`, radius 14, padding **12** × 16, column gap **8**): title 700 body size "Permintaan dari {unit}", then a wrap row (gap 8) of two pills:
     - "Permintaan dari Kolom": "Penatua Kolom" · "Ketua Jemaat"
     - "Permintaan dari BIPRA": "Ketua BIPRA" · "Ketua Jemaat"
     - "Permintaan dari Komisi": "Ketua Komisi" · "Ketua Jemaat"
     - "Permintaan dari Panitia": "Ketua Panitia" · "Ketua Jemaat"
  4. 13 `tinta3`: "Yang mengajukan tidak pernah menyetujui pengajuannya sendiri, walau jabatannya tercantum di sini. Bila jabatan pemberi persetujuan kosong, permintaan menunggu sampai ada pemegangnya."
  5. Refusal line "Tidak dapat dilakukan: Simpan tabel." + reason (when shown).
  6. Button row TombolBersyarat "Simpan tabel" (340).
  7. After saving (until the next pill change): button row with a secondary link-button "Aktifkan modul Persetujuan di aplikasi" (340, `flex 1 1 150`).
  8. Riwayat (when there are rows).
- **Components** ChipPilihan (four groups inside cards), TombolBersyarat ("Simpan tabel"), Penolakan, secondary link-button (Tombol), GarisStatus `dibukukan` row cards, RiwayatAlur, message banner. Pattern: approver table as one card per unit type with two choices.
- **Internal views and states** Initial state `{ k: null, a: { pesan: '', riw: [], v: 'tabel', T: { Kolom: '', BIPRA: '', Komisi: '', Panitia: '' }, simpan: false } }`. One view; `simpan` true after saving shows region 7.
- **Tweaks** `keadaan` (options `Alur`, default `Alur`; no visible effect). Keadaan panel.
- **Interactions**
  - Any pill (`pick`) → sets that row's choice, `simpan = false` (the link-button hides), `pesan = ''` (banner hides). Choices cannot be cleared, only switched.
  - "Simpan tabel" condition: all four rows chosen. Reason "belum ada pemberi persetujuan untuk {list}." where {list} is the unchosen rows in order Kolom, BIPRA, Komisi, Panitia joined with ", " (e.g. "BIPRA, Komisi, Panitia"). The line shows only while one to three rows are unchosen: not on the untouched table (all four empty), never when all are chosen.
  - Press when met (`simpan`) → `simpan = true`, `pesan` = "Tabel pemberi persetujuan disimpan.", Riwayat gains "16/11/2026 · Tabel pemberi persetujuan disimpan: Kolom → {pilihan}; BIPRA → {pilihan}; Komisi → {pilihan}; Panitia → {pilihan} · Pdt. Lidya Rondonuwu" (arrow is U+2192). Pressing again without changes saves again (another banner set, another Riwayat row).
  - No timers.
- **Motion** none.
- **Links out**
  - "Aktifkan modul Persetujuan di aplikasi" → `/AlurModul`, push.
  - Header back "Kembali ke Modul" → `/Modul`, up link.
  - **Inbound** Modul, PetaPlatform.
- **Mock data** Pdt. Lidya Rondonuwu (Pimpinan Jemaat yang berwenang, Ketua Jemaat); unit types Kolom, BIPRA, Komisi, Panitia; posts Penatua Kolom, Ketua BIPRA, Ketua Komisi, Ketua Panitia, Ketua Jemaat; today 16/11/2026.
- **Prototype-only** none. Keadaan panel: `keadaan`, "Semua layar", inbound links, canvas title.
- **Acceptance checks**
  1. Open `/PemberiPersetujuan` → intro, four cards "Permintaan dari Kolom/BIPRA/Komisi/Panitia" with no pill selected, note, grey "Simpan tabel", no refusal line, no link-button, no Riwayat.
  2. Kolom "Penatua Kolom" → "Tidak dapat dilakukan: Simpan tabel. belum ada pemberi persetujuan untuk BIPRA, Komisi, Panitia."
  3. BIPRA "Ketua Jemaat", Komisi "Ketua Komisi" → "… untuk Panitia."; Panitia "Ketua Panitia" → refusal gone, button `tinta`.
  4. Press → banner "Tabel pemberi persetujuan disimpan." at the top; "Aktifkan modul Persetujuan di aplikasi" below the button; Riwayat "16/11/2026 · Tabel pemberi persetujuan disimpan: Kolom → Penatua Kolom; BIPRA → Ketua Jemaat; Komisi → Ketua Komisi; Panitia → Ketua Panitia · Pdt. Lidya Rondonuwu".
  5. Panitia → "Ketua Jemaat" → banner and link-button gone; button still `tinta`; press → second Riwayat row on top ending "Panitia → Ketua Jemaat · Pdt. Lidya Rondonuwu".
  6. "Aktifkan modul Persetujuan di aplikasi" → `/AlurModul`; Back returns with the table as left. Header back → `/Modul`.
- **Notes**
  - Row cards use padding 12 × 16 and gap 8 (not the 14 × 16 / 6 of other cards). Copy.
  - The link-button disappears on any change, so a changed table must be saved again before "Aktifkan…" is offered. Keep.
  - No 12 px text; no off-token values.

### KasUnit — 99 · Alur · Kas/Bank unit

- **Source** `docs/design/handoff/canvas/boards/KasUnit.dc.html` · page Putaran 5 · Kolaborasi (`p5`) · form Phone 390×844 · interactive yes
- **Route** `/KasUnit`, no child routes (views `daftar` and `tambah` change in place) · **Widget** `KasUnitScreen` in `lib/screens/p5/kas_unit.dart`
- **Purpose** The Bendahara Jemaat (Meiske Lumentut) assigns a Kas/Bank to a unit. Shows P14 (the Bendahara Jemaat sets which Kas/Bank a unit manages; effective from the next month; a unit without a unit treasurer cannot be given one), D23 and the "Effective-from sentence" pattern (02-components). Journey: Bendahara Jemaat step 6 ("Alur · Kas/Bank unit"). Reached from AlurPanitiaBaru ("Tetapkan Kas/Bank Panitia"), KeuanganUnit and Modul.
- **Shell** Phone header with back: Semantics "Kembali ke Pengaturan" → Lainnya. Title "Alur · Kas/Bank unit"; subtitle "Menetapkan Kas/Bank yang dikelola sebuah unit". No tab bar.
- **Layout** (body column, gap 16)
  1. **View `daftar`**:
     a. Message banner (only while `pesan` is set; it lives inside this view).
     b. Kas/Bank cards (card shape with padding **12** × 16, gap 6): head row name 700 + badge; 13 `tinta3` line under it. Fixed rows, in order:
        - "Kas" · `laut` "Aktif" · "Dikelola Jemaat"
        - "Bank BNI ··4821" · `laut` "Aktif" · "Dikelola Jemaat"
        - "Bank SulutGo ··1107" · `laut` "Aktif" · "Dikelola Jemaat"
        - "Kas Kolom 7" · `laut` "Aktif" · "Dikelola oleh Kolom 7 · Bendahara: Deasy Tumbelaka"
        Then each Kas/Bank added in this session, oldest first: "{nama}" · `draf` "Berlaku mulai Desember 2026" · "Dikelola oleh {unit}".
     c. Button row primary "Tambah Kas/Bank unit" (340).
     d. 13 `tinta3` "Bendahara unit membukukan hanya pada Kas/Bank yang dikelola unitnya. Kas/Bank lain tetap pada Bendahara Jemaat."
     e. Riwayat (when there are rows; only in this view).
  2. **View `tambah`**:
     a. Field "Nama Kas/Bank", placeholder "Contoh: Kas Panitia Natal 2026", free text.
     b. Pills "Dikelola oleh": "Panitia Natal 2026" · "Kolom 4" · "Komisi Diakonia".
     c. Info row (standalone): "Berlaku mulai" → "Desember 2026".
     d. 13 `tinta3` "Perubahan pengaturan berlaku mulai bulan berikutnya."
     e. Refusal line "Tidak dapat dilakukan: Simpan." + reason (when shown).
     f. Button row TombolBersyarat "Simpan" + text button "Batalkan" (171 each).
- **Components** LencanaStatus shapes (`laut` "Aktif", `draf` "Berlaku mulai Desember 2026"), GarisStatus `dibukukan` cards, ChipPilihan, TombolBersyarat ("Simpan"), Penolakan, Tombol (primary "Tambah Kas/Bank unit", text "Batalkan"), RiwayatAlur, message banner. Pattern: Effective-from sentence ("Berlaku mulai Desember 2026" row + "Perubahan pengaturan berlaku mulai bulan berikutnya.").
- **Internal views and states** Initial state `{ k: null, a: { pesan: '', riw: [], v: 'daftar', nama: '', unit: '', K: [] } }`. Views `daftar` (list) and `tambah` (form). `K` = Kas/Bank added in the session.
- **Tweaks** `keadaan` (options `Alur`, default `Alur`; no visible effect). Keadaan panel.
- **Interactions**
  - "Tambah Kas/Bank unit" (`keTambah`) → `v = 'tambah'`, `pesan = ''`, `nama = ''`, `unit = ''` (a fresh form every time).
  - Nama typing (`onNama`) → free text. Unit pill (`pick`) → `unit`, `pesan = ''`.
  - "Simpan" condition, first unmet reason: (1) Nama blank after trim → "nama Kas/Bank belum diisi."; (2) no unit → "unit belum dipilih."; (3) "Komisi Diakonia" → "Komisi Diakonia belum punya bendahara unit.". The refusal line shows once Nama or the unit is non-empty. Press when met (`simpan`) → `v = 'daftar'`, a new card appended at the end of the list (name = Nama trimmed, sub-line "Dikelola oleh {unit}", `draf` badge "Berlaku mulai Desember 2026"), `pesan` = "{nama trimmed} dikelola oleh {unit}, berlaku mulai Desember 2026.", Riwayat gains "16/11/2026 · {nama} dikelola oleh {unit}, berlaku mulai Desember 2026. Oleh Meiske Lumentut, Bendahara Jemaat."
  - "Batalkan" (`pulang`) → `v = 'daftar'`, `pesan = ''`; nothing added.
  - Duplicate names are accepted. No timers.
- **Motion** none.
- **Links out**
  - Header back "Kembali ke Pengaturan" → `/Lainnya`, up link.
  - **Inbound** AlurPanitiaBaru ("Tetapkan Kas/Bank Panitia"), KeuanganUnit, Modul, PetaPlatform.
- **Mock data** Kas/Bank "Kas", "Bank BNI ··4821", "Bank SulutGo ··1107" (Dikelola Jemaat), "Kas Kolom 7" (Kolom 7, Bendahara Deasy Tumbelaka); units "Panitia Natal 2026", "Kolom 4", "Komisi Diakonia" (no unit treasurer); effective month Desember 2026; Meiske Lumentut, Bendahara Jemaat; today 16/11/2026.
- **Prototype-only** none (the "Contoh: Kas Panitia Natal 2026" text is a placeholder). Keadaan panel: `keadaan`, "Semua layar", inbound links, canvas title.
- **Acceptance checks**
  1. Open `/KasUnit` → four cards with `laut` "Aktif": "Kas", "Bank BNI ··4821", "Bank SulutGo ··1107" ("Dikelola Jemaat") and "Kas Kolom 7" ("Dikelola oleh Kolom 7 · Bendahara: Deasy Tumbelaka"); "Tambah Kas/Bank unit"; the note; no banner, no Riwayat.
  2. "Tambah Kas/Bank unit" → empty "Nama Kas/Bank", three unselected pills, "Berlaku mulai · Desember 2026", "Perubahan pengaturan berlaku mulai bulan berikutnya.", grey "Simpan", "Batalkan", no refusal line.
  3. Pick "Komisi Diakonia" → "Tidak dapat dilakukan: Simpan. nama Kas/Bank belum diisi."; Nama "Kas Diakonia" → "… Komisi Diakonia belum punya bendahara unit."
  4. Pick "Panitia Natal 2026", Nama "Kas Panitia Natal 2026" → `tinta` "Simpan"; first press → list, banner "Kas Panitia Natal 2026 dikelola oleh Panitia Natal 2026, berlaku mulai Desember 2026.", fifth card "Kas Panitia Natal 2026" with dashed badge "Berlaku mulai Desember 2026" and "Dikelola oleh Panitia Natal 2026"; Riwayat "16/11/2026 · Kas Panitia Natal 2026 dikelola oleh Panitia Natal 2026, berlaku mulai Desember 2026. Oleh Meiske Lumentut, Bendahara Jemaat."
  5. "Tambah Kas/Bank unit" → banner gone, form empty; "Batalkan" → list unchanged, five cards.
  6. Header back → `/Lainnya`.
- **Notes**
  - The back label says "Pengaturan" while the target is Lainnya ("7 · Lainnya dan pengaturan"). Keep both.
  - Kas/Bank cards use padding 12 × 16. Copy.
  - A unit picked when it already manages a Kas/Bank is not checked. Keep.

### WebKasUnit — Web · Alur · Kas/Bank unit

- **Source** `docs/design/handoff/canvas/boards/WebKasUnit.dc.html` · page Putaran 5 · Kolaborasi (`p5`) · form Laptop page (preview 1440×1000, `expand: fill`) · interactive yes
- **Route** `/WebKasUnit`, no child routes · **Widget** `WebKasUnitScreen` in `lib/screens/p5/web_kas_unit.dart`
- **Purpose** The same assignment on the laptop, where the Bendahara Jemaat works (Q26). Same decisions as KasUnit: P14, D23, Effective-from sentence. Journey: Bendahara Jemaat step 6, listed with KasUnit under "Alur · Kas/Bank unit".
- **Shell** Platform web side nav; active item **Keuangan** (index 1). Footer bold "Meiske Lumentut" + " · Bendahara Jemaat".
- **Layout**
  1. Title block: breadcrumb "Pengaturan" (→ WebPengaturan); h1 "Alur · Kas/Bank unit"; subtitle 14 `tinta2` "Menetapkan Kas/Bank yang dikelola sebuah unit".
  2. Content column (max-width 1120, gap 16), at body size 15:
     a. **View `daftar`**: identical to KasUnit 1a–1e (banner, the four fixed cards plus any added in the session, "Tambah Kas/Bank unit" 340, note, Riwayat), each a single block across the 1120 column (cards stretch to 1120).
     b. **View `tambah`**: a two-column form row (shared note):
        - Left (column gap 12): field "Nama Kas/Bank", pills "Dikelola oleh", info row "Berlaku mulai · Desember 2026", 13 `tinta3` "Perubahan pengaturan berlaku mulai bulan berikutnya."
        - Right (column gap 12): refusal line (when shown), then button row TombolBersyarat "Simpan" + text "Batalkan". At 1440 the right column is about 484 wide, so "Simpan" and "Batalkan" share one line (238 each).
- **Components** As KasUnit, plus the platform web side nav and the two-column form row.
- **Internal views and states** Same as KasUnit.
- **Tweaks** `keadaan` (options `Alur`, default `Alur`; no visible effect). Keadaan panel.
- **Interactions** Same as KasUnit, handler for handler, same conditions, messages and Riwayat rows. Side nav and "Menu" toggle as the shared shell.
- **Motion** none.
- **Links out**
  - Breadcrumb "Pengaturan" → `/WebPengaturan`, up link.
  - Side nav, all `go`, the ten items in the shared notes.
  - **Inbound** PetaPlatform.
- **Mock data** Same as KasUnit.
- **Prototype-only** none. Keadaan panel: `keadaan`, "Semua layar", inbound links, canvas title.
- **Acceptance checks**
  1. `/WebKasUnit` at 1440 → nav "Keuangan" active, footer "Meiske Lumentut · Bendahara Jemaat"; breadcrumb "Pengaturan"; four `laut` "Aktif" cards across 1120; "Tambah Kas/Bank unit" 340 wide.
  2. "Tambah Kas/Bank unit" → form left (name, pills, "Berlaku mulai · Desember 2026", note), grey "Simpan" and "Batalkan" right on one line, no refusal.
  3. Pick "Kolom 4" → right column "Tidak dapat dilakukan: Simpan. nama Kas/Bank belum diisi." above the buttons; Nama "Kas Kolom 4" → `tinta`; press → list with banner "Kas Kolom 4 dikelola oleh Kolom 4, berlaku mulai Desember 2026." and a fifth card with dashed "Berlaku mulai Desember 2026"; Riwayat row as KasUnit.
  4. At 860 → "Menu" top bar, the form still two columns; at 390 → stacked (buttons under the note), no horizontal scroll.
  5. Breadcrumb "Pengaturan" → `/WebPengaturan`; nav "Pengaturan" → `/WebPenugasan`. Both do `go` here (WebPengaturan is never directly beneath), so only browser Back on web returns here (state fresh).
- **Notes**
  - The breadcrumb goes to WebPengaturan (finance settings) while the nav item "Pengaturan" goes to WebPenugasan; "Keuangan" is the active item. Keep the board.
  - List cards stretch to 1120 at 1440. Keep; flag for design.

### AlurPanitiaBaru — 100 · Alur · Membentuk Panitia

- **Source** `docs/design/handoff/canvas/boards/AlurPanitiaBaru.dc.html` · page Putaran 5 · Kolaborasi (`p5`) · form Phone 390×844 · interactive yes
- **Route** `/AlurPanitiaBaru`, no child routes (views `isi` and `ada` change in place) · **Widget** `AlurPanitiaBaruScreen` in `lib/screens/p5/alur_panitia_baru.dart`
- **Purpose** Forming a Panitia, by the Pimpinan Jemaat yang berwenang (Pdt. Lidya Rondonuwu, named in Riwayat). Shows P15 (needs a written church decision in Dokumen gereja and three different people as Ketua, Sekretaris and Bendahara; starts in Perencanaan and cannot book until activated; its peruntukan is created on activation). Journey: Pimpinan Jemaat step 3 ("Alur · Membentuk Panitia"). After activation it hands over to KasUnit (give the Panitia a Kas/Bank) and AlurPanitia (how a Panitia is closed).
- **Shell** Phone header with back: Semantics "Kembali ke Panitia" → Panitia. Title "Alur · Membentuk Panitia"; subtitle "Dari keputusan gereja sampai Panitia Aktif". No tab bar.
- **Layout** (body column, gap 16)
  1. **View `isi`** (form; no banner in this view):
     a. Field "Nama Panitia", placeholder "Contoh: Panitia Paskah 2027", free text.
     b. Pills "Ketua": "Stevi Lengkong" · "Rivo Mandagi".
     c. Pills "Sekretaris": "Natalia Rumengan" · "Stevi Lengkong".
     d. Pills "Bendahara": "Rivo Mandagi" · "Stevi Lengkong".
     e. Pills "Keputusan gereja": "SK BPMJ No. 15/2026" · "Belum ada dokumen".
     f. Refusal line "Tidak dapat dilakukan: Bentuk Panitia." + reason (when shown).
     g. Button row TombolBersyarat "Bentuk Panitia" (340).
  2. **View `ada`** (formed):
     a. Message banner (only while `pesan` is set; lives in this view).
     b. Card: head "{Nama Panitia}" (as typed) 700 + badge: "Perencanaan" `draf` / "Aktif" `laut`; 14 `tinta2` "Ketua: {ketua} · Sekretaris: {sekretaris} · Bendahara: {bendahara}"; 13 `tinta3`: Perencanaan "Dibentuk 16/11/2026 · keputusan: {keputusan}"; Aktif "Aktif sejak 16/11/2026 · peruntukan {Nama Panitia trimmed} dibuat."
     c. While Perencanaan: 13 `tinta3` "Selama Perencanaan, Panitia belum dapat membukukan. Peruntukannya dibuat saat diaktifkan."; button row primary "Aktifkan Panitia" (340).
     d. While Aktif: button row with two secondary link-buttons "Tetapkan Kas/Bank Panitia" and "Lihat penutupan Panitia" (171 each on one line; each label wraps to two centred lines inside its 48+ px button).
     e. Riwayat (when there are rows; only in this view).
- **Components** TombolBersyarat ("Bentuk Panitia"), Penolakan, ChipPilihan (four groups), LencanaStatus shapes (`draf` "Perencanaan", `laut` "Aktif"), GarisStatus `dibukukan` card, Tombol (primary "Aktifkan Panitia"; secondary link-buttons), RiwayatAlur, message banner.
- **Internal views and states** Initial state `{ k: null, a: { pesan: '', riw: [], v: 'isi', nama: '', ketua: '', sek: '', bend: '', dok: '', st: '' } }`. Views `isi` → `ada`; in `ada`, `st` "Perencanaan" → "Aktif". There is no way back to the form.
- **Tweaks** `keadaan` (options `Alur`, default `Alur`; no visible effect). Keadaan panel.
- **Interactions**
  - Nama typing (`onNama`) → free text. Each pill (`pick`) → sets `ketua` / `sek` / `bend` / `dok`, `pesan = ''`.
  - "Bentuk Panitia" condition, first unmet reason: (1) Nama blank after trim → "nama Panitia belum diisi."; (2) no Ketua → "Ketua belum dipilih."; (3) no Sekretaris → "Sekretaris belum dipilih."; (4) Sekretaris = Ketua → "Ketua, Sekretaris dan Bendahara harus tiga orang yang berbeda."; (5) no Bendahara → "Bendahara belum dipilih."; (6) Bendahara = Ketua or = Sekretaris → "Ketua, Sekretaris dan Bendahara harus tiga orang yang berbeda."; (7) no Keputusan gereja → "keputusan gereja belum dipilih."; (8) "Belum ada dokumen" → "pembentukan Panitia memerlukan keputusan tertulis gereja di Dokumen gereja.". The refusal line shows once Nama or any pill is non-empty. Only two trios pass: Stevi / Natalia / Rivo and Rivo / Natalia / Stevi.
  - Press when met (`bentuk`) → `v = 'ada'`, `st = 'Perencanaan'`, Riwayat gains "16/11/2026 · {Nama trimmed} dibentuk · Ketua {ketua}, Sekretaris {sekretaris}, Bendahara {bendahara} · {keputusan} · Pdt. Lidya Rondonuwu". No banner.
  - "Aktifkan Panitia" (`aktifkan`, unconditional) → `st = 'Aktif'`, `pesan` = "Ketua, Sekretaris dan Bendahara Panitia diberi tahu lewat Pemberitahuan.", Riwayat gains "16/11/2026 · {Nama trimmed} Aktif · peruntukan dibuat".
  - No timers.
- **Motion** none.
- **Links out**
  - "Tetapkan Kas/Bank Panitia" → `/KasUnit`, push.
  - "Lihat penutupan Panitia" → `/AlurPanitia`, push.
  - Header back "Kembali ke Panitia" → `/Panitia`, up link.
  - **Inbound** Panitia, PetaPlatform.
- **Mock data** Stevi Lengkong, Natalia Rumengan, Rivo Mandagi; decision "SK BPMJ No. 15/2026"; Pdt. Lidya Rondonuwu; today 16/11/2026. Example name used in checks: "Panitia Paskah 2027" (the placeholder's own example).
- **Prototype-only** none (the "Contoh: Panitia Paskah 2027" text is a placeholder). Keadaan panel: `keadaan`, "Semua layar", inbound links, canvas title.
- **Acceptance checks**
  1. Open `/AlurPanitiaBaru` → empty "Nama Panitia", four unselected pill groups, grey "Bentuk Panitia", no refusal line, no banner, no Riwayat.
  2. Nama "Panitia Paskah 2027" → "Tidak dapat dilakukan: Bentuk Panitia. Ketua belum dipilih."; Ketua "Stevi Lengkong", Sekretaris "Stevi Lengkong" → "… Ketua, Sekretaris dan Bendahara harus tiga orang yang berbeda."
  3. Sekretaris "Natalia Rumengan" → "Bendahara belum dipilih."; Bendahara "Stevi Lengkong" → "… harus tiga orang yang berbeda."; "Rivo Mandagi" → "keputusan gereja belum dipilih."; "Belum ada dokumen" → "pembentukan Panitia memerlukan keputusan tertulis gereja di Dokumen gereja."; "SK BPMJ No. 15/2026" → button `tinta`.
  4. First press → card "Panitia Paskah 2027" with dashed "Perencanaan", "Ketua: Stevi Lengkong · Sekretaris: Natalia Rumengan · Bendahara: Rivo Mandagi", "Dibentuk 16/11/2026 · keputusan: SK BPMJ No. 15/2026", Perencanaan note, "Aktifkan Panitia"; no banner; Riwayat "16/11/2026 · Panitia Paskah 2027 dibentuk · Ketua Stevi Lengkong, Sekretaris Natalia Rumengan, Bendahara Rivo Mandagi · SK BPMJ No. 15/2026 · Pdt. Lidya Rondonuwu".
  5. "Aktifkan Panitia" → banner "Ketua, Sekretaris dan Bendahara Panitia diberi tahu lewat Pemberitahuan.", `laut` "Aktif", "Aktif sejak 16/11/2026 · peruntukan Panitia Paskah 2027 dibuat.", two link-buttons side by side; Riwayat top "16/11/2026 · Panitia Paskah 2027 Aktif · peruntukan dibuat".
  6. "Tetapkan Kas/Bank Panitia" → `/KasUnit`; Back → this board still Aktif with banner and Riwayat.
  7. "Lihat penutupan Panitia" → `/AlurPanitia`; Back returns.
  8. Header back → `/Panitia`.
- **Notes**
  - The two link-buttons are 171 wide with 16 padding, so each label wraps to two lines. Keep the board (centred text, min-height 48 grows).
  - KasUnit does not offer the new Panitia by name (its unit pills are fixed: "Panitia Natal 2026", "Kolom 4", "Komisi Diakonia"), and AlurPanitia shows Panitia Natal 2026. Keep each board's own data.
  - The card title shows the name as typed (untrimmed); the stKet sentence and Riwayat use the trimmed name. Copy the board.
  - The badge "Perencanaan" uses the `draf` (dashed) shape although nothing about money is pending. Keep the board.
