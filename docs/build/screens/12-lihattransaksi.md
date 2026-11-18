# Screens 12: LihatTransaksi, WebLihatTransaksi, AIMataAnggaran, WebAIMataAnggaran, WebUnggah, WebExcelTerbatas, Memuat, WebMemuat, Keluar, WebKeluar

These ten boards are supporting screens of the Bendahara Jemaat from the canvas page "Pelengkap" (`lengkap`), mostly in phone/laptop pairs. LihatTransaksi/WebLihatTransaksi open a figure of the official October 2026 report (F05 or F07) and list the posted transactions that make it up, with reversals as negative figures and split payments by their share; they are reached from Laporan and WebPaketLaporan and lead on to PilihBulan/WebPilihBulan. AIMataAnggaran/WebAIMataAnggaran show the AI suggestion of a Mata Anggaran for a draft Belanja of −Rp480.000 (one line, a split over two lines, or an unsure pair), which can be used, overridden ("Pilih sendiri" → Bagi/WebBagi), ignored, or goes stale when the Uraian changes; they are reached from Main and from WebCatat/TabCatat. WebUnggah fakes uploading up to three supporting-document files for BKU-2026-0143 (1500 ms each, one optional failure with "Coba lagi"), reached from WebDokumen ("Unggah file") and from the "Lampirkan dokumen pendukung" row action of WebTransaksi/TabTransaksi, and leading back to WebDokumen. WebExcelTerbatas previews the TERBATAS Excel file of the Diakonia restricted copy (sheets F02, F03, F05, F07, F12), reached from WebTerbatas "Unduh Excel". Memuat/WebMemuat show the loading skeleton, the "Data belum dapat dimuat" failure with a 1400 ms retry, and a Bukukan that did not happen and is retried safely; no app screen links to them: they are reached from the map sheets PetaLayar and Cakupan (links built in those boards' logic class, `navigation.md` 3.3) and from the launcher. Keluar/WebKeluar show the account card and sign-out from this device with a confirmation, ending on "Anda sudah keluar" and a "Masuk" link; they are reached from Lainnya and WebPengaturan. The map sheet PetaLayar links to every board here, and the sheet Cakupan also links to LihatTransaksi, AIMataAnggaran, WebUnggah, Memuat and WebMemuat; those links are not in the manifest, so each **Inbound** line lists them from `navigation.md`. In every section "up link" means the phone back arrow or the web breadcrumb above the h1 (and, where stated, a button that returns to the same parent): it pops when its target, or one of the target's child routes, is the route directly beneath; otherwise it does `go` to the target. Drill-ins into other boards are `push`; side-nav items are `go`. "Today" on all boards is 16/11/2026, actor Meiske L., Bendahara. Where a board's own tweak (`usulan`, `gagalUnggah`, `keadaan`) is changed in the Keadaan panel, reset that board's state to its initial object and cancel its timers (see each board's Notes); `jabatanKosong` never resets state.

---

### LihatTransaksi — 42 · Lihat transaksi di balik angka laporan
- **Source** `docs/design/handoff/canvas/boards/LihatTransaksi.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 · interactive yes
- **Route** `/LihatTransaksi`, no child routes (the chips switch the figure in place) · **Widget** `LihatTransaksiScreen` in `lib/screens/lengkap/lihat_transaksi.dart`
- **Purpose** Bendahara Jemaat, journey step 5 ("15 · Laporan", then the figure behind a report line). Picks one figure of the official October 2026 report and lists only the booked transactions that make it, then proves the sum equals the report figure. Shows D12 (a reversal appears as a negative figure in the same list; the original stays, flagged "Dibalik oleh …") and the split rule of "6 · Bagi ke beberapa Mata Anggaran" (a payment split over several Mata Anggaran appears with its share only, flagged "Bagian dari pembayaran …"). D30 (reports readable on the phone).
- **Shell** Phone header with back, no tab bar. Phone root: `kertas` background, `tinta` text, `isi` (16/1.4). With `jabatanKosong` a one-line PitaJabatanKosong strip sits above the header (Layout 0).
- **Layout**
  0. (only when `jabatanKosong`) Strip, `role=status`, not scrolled: full-width `tinta` field, `permukaan` text, padding 10/24/8, 13 px line-height 1.3, centred: "**Menjalankan jabatan kosong** · Bendahara Jemaat".
  1. Header row (fixed): padding 14 top, 12 sides, 8 bottom; gap 8. Back target 44×44 with chevron (path `M15 6l-6 6 6 6`, 22 px box, stroke 2, round caps, `tinta`), semantics "Kembali ke Laporan". Title "Lihat transaksi" (`judulLayar` 18/700); under it "Dari angka di laporan" (`keterangan` 13, `tinta2`).
  2. Chip row (fixed, not scrolled): padding 0 20 4; chips wrap. Three ChipPilihan chips, in order "Honorarium pelayan", "Alat tulis dan fotokopi", "Persembahan Ibadah Minggu". Each: inline, min-height 44, padding 0 14, margin 0 8 8 0, radius 999, border 1.5, text 14/600. Selected: `tinta` field and border, `permukaan` text. Unselected: `permukaan` field, `garisTegas` border, `tinta` text. `aria-pressed` → selected semantics. At 390 wide the chips break onto several lines; let them wrap.
  3. Scroll area (fills the rest): padding 8 top, 20 sides, 20 bottom; column gap 14 (the board writes gap 16 then 14; 14 wins).
     a. Report heading block: line 1 `keterangan` 13 `tinta3` "{laporan} · Oktober 2026 · Laporan resmi" (e.g. "F07 · Realisasi Belanja Menurut Mata Anggaran · Oktober 2026 · Laporan resmi"); line 2 the report line name, 16/700 (e.g. "Belanja 5.02.01.00 Alat tulis dan fotokopi"); line 3 the report figure, mono 32/500, letter-spacing −1, `tinta` (e.g. "Rp250.000").
     b. Transactions card (GarisStatus `dibukukan`): `permukaan`, 1 px `garis`, radius 14, padding 0 16. One block per transaction: padding 12 0, 1 px `garis` top rule from the second block on. Line 1 (space-between, baseline, gap 16): left `kode` (mono 13, `tinta2`) "{No. Bukti} · {tanggal}", right `jumlah` (mono 16/500, `tinta`) the amount, negative with U+2212. Line 2 Uraian 15/600. Optional badge below (only when the row has one): inline, margin-top 4, 13/700, radius 6, padding 3/9, 1.5 solid `tinta3` line, `tinta2` text (LencanaStatus "Dibalik" shape).
     c. Check line: row, centre, gap 8, 16/700, `laut`: check icon 20 px (path `M5 12.5l4.5 4.5L19 7.5`, stroke `laut` 2.5, round caps and joins) then "Jumlah {n} baris {total} · sama dengan angka di laporan".
     d. Note `keterangan` 13 `tinta3`: "Hanya transaksi yang sudah dibukukan. Pembalikan tetap tampil sebagai angka negatif; transaksi asalnya tidak dihilangkan. Yang dibagi ke beberapa Mata Anggaran tampil dengan bagiannya saja."
     e. Text link "Buka Transaksi Oktober 2026": min-height 44, 16/700, `laut` (hover `lautTua`), left-aligned.
- **Components** ChipPilihan (figure chips), LencanaStatus shape for the three row badges ("Dibalik oleh …", "Pembalikan", "Bagian dari …"), GarisStatus `dibukukan` (transactions card), PitaJabatanKosong (strip). Repeated pattern, not a component: transaction block (code · date + amount, uraian, optional badge); the "sum equals report" check line with a ✓ icon.
- **Internal views and states** Initial state `{ pilih: 'atk' }`. One view whose content follows `pilih` ∈ `hon`, `atk`, `pim`. No sheets, toasts or empty states.
- **Tweaks** `jabatanKosong` (boolean, default false) · Keadaan panel (global switch). On: strip 0 appears. Text replacement is disabled on this board (`jk && false`); no string here names Meiske L. anyway.
- **Interactions** Chip "Honorarium pelayan" → `pilih = 'hon'`; "Alat tulis dan fotokopi" → `pilih = 'atk'`; "Persembahan Ibadah Minggu" → `pilih = 'pim'`. Each re-renders blocks a–c for that line. Rows are not pressable. No typed input, no timers.
- **Motion** Each transaction block runs `muncul` 300 ms (fade in, rise 8 px, default ease) when it appears; key the blocks by `pilih` and index so they replay when a chip changes the list. Keyframes `masuk`, `pudar`, `isi` are declared but unused: build nothing for them.
- **Links out** Back arrow → `/Laporan`, up link (pops when `/Laporan` or `/Laporan/rinci/:f` is directly beneath). "Buka Transaksi Oktober 2026" → `/PilihBulan`, push. **Inbound** Laporan ("Lihat transaksi di balik sebuah angka"), PetaLayar, Cakupan.
- **Mock data** Three report lines (chip label · report · line name · figure), with their transactions (No. Bukti · tanggal · Uraian · badge · jumlah):
  - `hon` "Honorarium pelayan" · "F07 · Realisasi Belanja Menurut Mata Anggaran" · "Belanja 5.07.01.00 Honorarium pelayan" · Rp3.640.000
    1. BKU-2026-0100 · 05/10/2026 · Honorarium pelayan · — · Rp1.820.000
    2. BKU-2026-0120 · 26/10/2026 · Honorarium pelayan · — · Rp1.820.000
    Check: "Jumlah 2 baris Rp3.640.000 · sama dengan angka di laporan".
  - `atk` (default) "Alat tulis dan fotokopi" · "F07 · Realisasi Belanja Menurut Mata Anggaran" · "Belanja 5.02.01.00 Alat tulis dan fotokopi" · Rp250.000
    1. BKU-2026-0101 · 06/10/2026 · Toko Sinar: listrik dan alat tulis · "Bagian dari pembayaran Rp1.250.000" · Rp250.000
    2. BKU-2026-0105 · 09/10/2026 · Konsumsi rapat majelis · "Dibalik oleh BKU-2026-0109" · Rp750.000
    3. BKU-2026-0109 · 12/10/2026 · Pembalikan BKU-2026-0105 · "Pembalikan" · −Rp750.000
    Check: "Jumlah 3 baris Rp250.000 · sama dengan angka di laporan".
  - `pim` "Persembahan Ibadah Minggu" · "F05 · Realisasi Pendapatan Menurut Mata Anggaran" · "Pendapatan 1.3.53.07.00 Persembahan Ibadah Minggu" · Rp10.950.000
    1. BKU-2026-0098 · 04/10/2026 · Persembahan Ibadah Minggu dan Diakonia · "Bagian dari penerimaan Rp4.150.000" · Rp3.200.000
    2. BKU-2026-0107 · 11/10/2026 · Persembahan Ibadah Minggu · — · Rp2.650.000
    3. BKU-2026-0114 · 18/10/2026 · Persembahan Ibadah Minggu · — · Rp2.400.000
    4. BKU-2026-0123 · 25/10/2026 · Persembahan Ibadah Minggu · — · Rp2.700.000
    Check: "Jumlah 4 baris Rp10.950.000 · sama dengan angka di laporan".
  Compute the check line from the rows (count and `rp(sum)`), as the board does; the sums match the stated figures. Share these three lines with WebLihatTransaksi in `lib/mock/`.
- **Prototype-only** none. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. Open `/LihatTransaksi` → chip "Alat tulis dan fotokopi" is filled `tinta`; heading line reads "F07 · Realisasi Belanja Menurut Mata Anggaran · Oktober 2026 · Laporan resmi"; figure "Rp250.000"; three blocks.
  2. Block 3 reads "BKU-2026-0109 · 12/10/2026", amount "−Rp750.000" (U+2212), badge "Pembalikan"; block 2 badge "Dibalik oleh BKU-2026-0109"; block 1 badge "Bagian dari pembayaran Rp1.250.000".
  3. The check line reads "Jumlah 3 baris Rp250.000 · sama dengan angka di laporan" in `laut` with a check icon.
  4. Tap "Persembahan Ibadah Minggu" → heading starts "F05 · Realisasi Pendapatan Menurut Mata Anggaran", name "Pendapatan 1.3.53.07.00 Persembahan Ibadah Minggu", figure "Rp10.950.000", four blocks fading in, check "Jumlah 4 baris Rp10.950.000 · sama dengan angka di laporan".
  5. Tap "Honorarium pelayan" → two blocks without badges, figure "Rp3.640.000".
  6. Tap "Buka Transaksi Oktober 2026" → `/PilihBulan`; Back returns to `/LihatTransaksi` with the same chip selected.
  7. Back arrow → `/Laporan`.
  8. `jabatanKosong` on → strip "Menjalankan jabatan kosong · Bendahara Jemaat" above the header; nothing else changes.
- **Notes** The header subtitle sets font-size 14 then 13: use 13. Off-token: report figure mono 32 (copy it). The badges use the LencanaStatus "Dibalik" shape for notes that are not statuses ("Bagian dari …"); keep it, since the board does. The data object also carries `lap`, `rp`, `rbg`, `sh` per chip for the web list; the phone ignores them. Whether the DC framework replays `muncul` on reused rows is unknown; replaying on every chip change is the recommended choice. The link reads "Buka Transaksi Oktober 2026", but PilihBulan takes no parameter and always opens on November 2026 (flagged in `09-rekonisi.md`); keep both boards as drawn.

### WebLihatTransaksi — Web · Lihat transaksi di balik angka laporan
- **Source** `docs/design/handoff/canvas/boards/WebLihatTransaksi.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebLihatTransaksi`, no child routes (the figure list is in-page state) · **Widget** `WebLihatTransaksiScreen` in `lib/screens/lengkap/web_lihat_transaksi.dart`
- **Purpose** Bendahara Jemaat on the laptop, journey step 5. Same as LihatTransaksi: the list of report figures on the left, the transactions of the chosen figure on the right. D12, split rule of Bagi; the selected-row rule of the foundations (3 px inner `laut` line on the left edge).
- **Shell** Web side nav (shared by the six web boards in this file; specified once here):
  - Root: `kertas` background, `tinta` text, `isiWeb` 15/1.45; row, wrap, min-height full window. Links `laut`, hover `lautTua`. Keyboard focus: 2 px solid `laut` outline, 2 px offset.
  - Nav column: flex 1 1 220, padding 24/16, `permukaan`, 1 px `garis` right border, column gap 20.
  - Brand: Palakat mark 26×26 (from the board's SVG: rect 2,2,20,20 rx 6, no fill, 2 px `laut` stroke dashed 3 3; path `M12 2h4a6 6 0 0 1 6 6v8a6 6 0 0 1-6 6h-4z` filled `laut`) and "palakat" 18/700 line-height 1.1 over "Jemaat Karunia" 13 `tinta3`; padding 0 8, gap 10.
  - Items, exactly, in order: Beranda → `/WebBeranda`, Transaksi → `/WebTransaksi`, Uang Muka dan Titipan → `/WebKewajiban`, Rekonsiliasi → `/WebRekonsiliasi`, Bulan dan tutup buku → `/WebTutupBuku`, Laporan → `/WebPaketLaporan`, Pengaturan → `/WebPengaturan`. Each min-height 44, padding 0 12, radius 10, 15/600, no underline. Active: `tinta` field, `permukaan` text; others transparent, `tinta` text. All `go`.
  - Footer: margin-top auto, padding 12/8/0, 1 px `garis` top rule, 13 `tinta2`: "**Meiske L.** · Bendahara" / "Wewenang Bendahara aktif" (name `tinta`, bold). With `jabatanKosong` (boards that have it): "**Yanti Sumual** · Operator" / "Menjalankan jabatan kosong Bendahara Jemaat".
  - At 860 px and below the nav becomes a top bar (row, wrap, padding 8/16, gap 0/12, no right border, 1 px `garis` bottom border) with a toggle at the right: min-height 44, padding 0 16, radius 14, 1.5 `tinta` border, `permukaan`, 14/700, label "Menu"; when open it is `tinta` field, `permukaan` text, label "Tutup menu", and the items (padding 8/0) and footer (padding-bottom 8) show full-width below the brand.
  - Main column: flex 999 1 560, min-width 0, padding 28 top, clamp(16, 3vw, 40) sides, 40 bottom, column gap 20.
  - With `jabatanKosong` the first item of main is the web PitaJabatanKosong: `tinta` field, radius 14, padding 12/16, 14 px, `role=status`: "**Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15.**" then, after a space, "Setiap tindakan dicatat sebagai dijalankan oleh Operator Yanti Sumual." in `diTinta2`.
  - Title block pattern (all six web boards): breadcrumb link 14/600 `laut`; h1 `judulHalaman` 26/700, margin-top 2; optional subtitle 14 `tinta2`.
  - On this board the active item is **Laporan**.
- **Layout**
  1. Title block: breadcrumb "Laporan"; h1 "Lihat transaksi"; subtitle "Setiap angka di laporan membuka transaksi yang membentuknya."
  2. Two-column row: wrap, gap 24, items aligned to the top. At 1440 the two columns sit side by side (left ≈ 380, right takes the rest); at 860 the right column wraps below the list.
     a. Left, figure list (flex 1 1 380, min-width 0): card `permukaan`, 1 px `garis`, radius 14, clip. Header "Angka di laporan Oktober 2026" padding 12/18, 13/600 `tinta2`. Then three full-width row buttons in the chip order (Honorarium pelayan, Alat tulis dan fotokopi, Persembahan Ibadah Minggu): row, centre, gap 12, min-height 60, padding 8/18, no border except 1 px `garis` top rule, text left. Cells: report id mono 13 `tinta2` ("F07", "F07", "F05"); name 15/600, flex 1; figure mono 15/500 ("Rp3.640.000", "Rp250.000", "Rp10.950.000"). Selected row: `lautLembut` field plus a 3 px inner `laut` line on the left edge; others `permukaan`, no line. `aria-pressed` → selected semantics.
     b. Right, detail (flex 999 1 440, min-width 0, column gap 14): exactly regions 3a–3e of LihatTransaksi (heading block, transactions card, check line, note, link "Buka Transaksi Oktober 2026"), at web body size: line-name and link 15/700, uraian 15/600, amounts mono 15/500 (inherit), figure mono 32/500 letter-spacing −1.
- **Components** LencanaStatus shape (row badges), GarisStatus `dibukukan` (transactions card), PitaJabatanKosong (web banner). Shared: web side nav. Pattern: selectable list rows with the selected-row line (not ChipPilihan on web).
- **Internal views and states** Initial `{ pilih: 'atk' }`. One view; the right column follows `pilih`. No sheets, toasts or empty states.
- **Tweaks** `jabatanKosong` (boolean, default false) · Keadaan panel (global switch). On: web banner at the top of main, nav footer switches to Yanti Sumual. Text replacement disabled (`jk && false`).
- **Interactions** Each list row → `pilih = <its id>` (`hon`, `atk`, `pim`). No other handlers, no typed input, no timers.
- **Motion** Transaction blocks `muncul` 300 ms on appear, replayed when the selected row changes (as LihatTransaksi). Keyframes `isi` and `titik` are declared but unused.
- **Links out** Breadcrumb "Laporan" → `/WebPaketLaporan`, up link. "Buka Transaksi Oktober 2026" → `/WebPilihBulan`, push. Side nav as in Shell. **Inbound** WebPaketLaporan ("Lihat transaksi di balik sebuah angka"), PetaLayar.
- **Mock data** Same three report lines and transactions as LihatTransaksi (shared constants). List rows show the report id (first three characters of the report label: "F07", "F07", "F05") and the figure.
- **Prototype-only** none. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. `/WebLihatTransaksi` at 1440 → side nav "Laporan" filled `tinta`; list row "Alat tulis dan fotokopi" has a `lautLembut` field and a 3 px `laut` line on its left edge; right column shows figure "Rp250.000" and three blocks.
  2. Click row "Persembahan Ibadah Minggu" → its row becomes selected, the previous one loses the field and line; right column shows "Rp10.950.000" and four blocks.
  3. Block "BKU-2026-0109 · 12/10/2026" shows "−Rp750.000" and badge "Pembalikan" (with `atk` selected).
  4. Click "Laporan" breadcrumb → `/WebPaketLaporan`.
  5. Click "Buka Transaksi Oktober 2026" → `/WebPilihBulan`; browser Back returns with the same row selected.
  6. At 860 px wide the nav shows "Menu" and the detail column sits below the list; no horizontal page scroll.
  7. `jabatanKosong` on → banner "Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15." at the top of main; footer "Yanti Sumual · Operator".
- **Notes** Breadcrumb "Laporan" with nav "Laporan" active. List figures in mono at body size 15 (inherited), weight 500. As on the phone, WebPilihBulan opens on November 2026 although the link reads "Oktober 2026" (flagged in `09-rekonisi.md`).

### AIMataAnggaran — 43 · Bantuan AI: usulan Mata Anggaran dan pembagian
- **Source** `docs/design/handoff/canvas/boards/AIMataAnggaran.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 · interactive yes
- **Route** `/AIMataAnggaran`, no child routes (the suggestion, the chosen lines and the ignored state replace each other in place) · **Widget** `AIMataAnggaranScreen` in `lib/screens/lengkap/ai_mata_anggaran.dart`
- **Purpose** Bendahara Jemaat, journey step 2 (daily recording, "14 · Bantuan AI saat mencatat"). A draft Belanja of −Rp480.000 at Toko Sinar has no Mata Anggaran; the AI suggests one line, a split over two lines whose sum equals the payment, or (unsure) two candidates the Bendahara must pick from. Shows D31 (an AI suggestion has a dotted `laut` edge and italic text), the KartuUsulanAI rules (no value until used; "kurang yakin, mohon dicek"), a stale suggestion that cannot be used after the draft changed, that using, changing or ignoring needs no reason, that the AI suggestion is not stored as the decision, and the PemilihMataAnggaran rule that a draft may be saved without a Mata Anggaran but not booked.
- **Shell** Phone header with back, no tab bar. Phone root `kertas`, `tinta`, `isi` 16/1.4. With `jabatanKosong` the PitaJabatanKosong strip above the header (as LihatTransaksi Layout 0).
- **Layout**
  0. (only when `jabatanKosong`) Strip as LihatTransaksi.
  1. Header row (fixed): as LihatTransaksi, back semantics "Kembali ke isian"; title "Belanja" (`judulLayar`); subtitle "Pilih Mata Anggaran" (`keterangan` 13 `tinta2`).
  2. Scroll area (fills the rest): padding 8 top, 20 sides, 20 bottom; column gap 16. Top to bottom:
     a. Draft card (GarisStatus `draf`): 1.5 dashed `putus` line, radius 16, padding 18, column gap 6. Badge (LencanaStatus Draf): left-aligned, 13/700, radius 6, padding 3/9, 1.5 dashed `putus` line, `tinta2` text "Draf · belum masuk saldo". Amount "−Rp480.000" mono 30/500 (`jumlahIsian`) in `tinta2`. Line `keterangan` 13 `tinta3` "Belanja · Toko Sinar · Kas · diambil dari peruntukan Umum Jemaat · Lingkup Jemaat".
     b. Uraian field: label "Uraian" 14 `tinta2` (a `<label for>`: it is the input's semantics label), 6 below it the input: full width, min-height 48, padding 0 14, radius 12, 1 px `garisTegas` border, `permukaan`, text 16 `tinta`. Value per `usulan` (Mock data) until typed.
     c. Mata Anggaran group (column gap 6): label "Mata Anggaran" 14 `tinta2`, then one of:
        - Not chosen (state `ada` or `abai`): box 1.5 dashed `putus`, radius 14, padding 12/16, 16/700 `bata`: "Mata Anggaran belum dipilih".
        - Chosen (state `pakai`): card GarisStatus `terpilih` (`permukaan`, 1.5 `tinta` line), radius 14, padding 4/16, runs `muncul` 300 ms. One row per chosen line: space-between, baseline, gap 16, padding 10/0, 1 px `garis` top rule from the second row; left "Belanja {No. MA} {nama}" 16/600; right amount mono 16/500, not shrinking. Below the card: `keterangan` 13 `tinta3` "Mata Anggaran sudah dipilih oleh Meiske L. Usulan AI tidak tersimpan sebagai keputusan." Then text button "Ganti pilihan": min-height 44, no padding, left-aligned, 16/700 `laut`.
     d. AI panel (only in state `ada`): `lautLembut` field, radius 16, padding 14/16, column gap 10.
        - Eyebrow "BANTUAN AI · PILIHAN" 13/700 `lautTua`, letter-spacing 0.3.
        - Suggestion card (KartuUsulanAI, line `usulanAI`): `permukaan`, 1.5 dotted `laut` line, radius 12, padding 12/14, column gap 6. Label badge left-aligned: 13/700 `lautTua`, 1.5 dotted `laut` line, radius 6, padding 2/8, text per mode (Mock data). Then one row per suggested line: row, centre, gap 10, padding 8/0, 1 px dotted `garisTegas` top rule on every row including the first. Left (flex 1): "Belanja {No. MA} {nama}" italic 16/600 `lautTua`; under it the amount mono 13 `tinta2` (empty in the unsure mode, so the line takes no height). Right (unsure mode only): button "Pilih ini": min-height 44, padding 0 14, radius 10, 1.5 `tinta` line, `permukaan`, 14/700; inert while the suggestion is stale (see Notes for its look). In the split mode a last line `keterangan` 13 `tinta3`: "Rp300.000 + Rp180.000 = Rp480.000, sama persis dengan jumlah pembayaran."
        - Stale block (only while stale): "Usulan lama — draf sudah berubah. Usulan ini tidak dapat dipakai." 14/600 `tinta`; then full-width button "Buat usulan baru": min-height 44, radius 12, 1.5 `laut` line, `permukaan`, 16/700 `lautTua`, centred.
        - Action row (only while fresh): row, gap 8. "Pakai" (only when the AI is sure: modes Satu baris and Bagi ke dua baris): flex 1, min-height 46, radius 12, no line, `laut` field, `diLaut` text, 16/700, centred. "Pilih sendiri" link: flex 1.3, min-height 46, 15/700, no wrap, radius 12, 1.5 `tinta` line, `permukaan`, `tinta` text, centred. "Abaikan": flex 1, min-height 46, radius 12, 1.5 `tinta` line, `permukaan`, 16/700, centred. The CSS flex values are proportions with basis 0: in Flutter use `Expanded` flex 10 / 13 / 10 (13 / 10 when "Pakai" is absent).
        - Footnote `keterangan` 13 `tinta2`: "AI hanya memilih dari baris yang dapat dibukukan dan boleh untuk uang milik sendiri. Memakai, mengganti atau mengabaikan usulan tidak perlu alasan."
     e. Ignored sentence (only in state `abai`): 14 `tinta2`, runs `muncul` 300 ms: "Usulan diabaikan. Draf boleh disimpan tanpa Mata Anggaran, tetapi belum dapat dibukukan."
- **Components** LencanaStatus (Draf badge), GarisStatus (`draf` card, `terpilih` chosen card, dashed "belum dipilih" box), KartuUsulanAI (AI panel and suggestion card with its label), Tombol (Pakai primary; Pilih sendiri, Abaikan, Pilih ini, Buat usulan baru secondary; Ganti pilihan text), PitaJabatanKosong. Repeated pattern: Mata Anggaran line row "Belanja {No. MA} {nama}" + amount.
- **Internal views and states** Initial state `{ ur: null, dasar: null, st: 'ada', pilihan: null }`. Derived: `ur` shown = `ur ?? DEF[usulan]`; stale (`basi`) = `st == 'ada'` and shown `ur` ≠ (`dasar ?? DEF[usulan]`); `ragu` = `usulan == 'AI kurang yakin'`. Views:
  - Suggestion fresh (`st 'ada'`, not stale): c "belum dipilih" + d with the action row.
  - Suggestion stale (`st 'ada'`, stale): c "belum dipilih" + d with the stale block instead of the action row; "Pilih ini" inert.
  - Chosen (`st 'pakai'`): c chosen card + sentence + "Ganti pilihan"; no AI panel.
  - Ignored (`st 'abai'`): c "belum dipilih" + e; no AI panel.
  Three modes from the `usulan` tweak decide the default Uraian, the label and the suggested lines. No sheets or toasts.
- **Tweaks**
  - `jabatanKosong` (boolean, default false) · Keadaan panel (global switch). On: strip 0; the chosen sentence names "Yanti Sumual, Operator" instead of "Meiske L." (see Interactions). The board runs the text replacement (`jk && true`), but no other string here contains "Meiske L.".
  - `usulan` (enum "Satu baris" · "Bagi ke dua baris" · "AI kurang yakin", default "Satu baris") · Keadaan panel.
    - "Satu baris": Uraian "Kertas HVS dan tinta printer"; label "Usulan AI · Mata Anggaran"; one line "Belanja 5.02.01.00 Alat tulis dan fotokopi" / "Rp480.000"; Pakai, Pilih sendiri, Abaikan.
    - "Bagi ke dua baris": Uraian "Kertas HVS Rp300.000 dan token listrik Rp180.000"; label "Usulan AI · bagi ke 2 Mata Anggaran"; lines "Belanja 5.02.01.00 Alat tulis dan fotokopi" / "Rp300.000" and "Belanja 5.01.02.00 Listrik, air dan telepon" / "Rp180.000"; the sum sentence; Pakai, Pilih sendiri, Abaikan.
    - "AI kurang yakin": Uraian "Keperluan ibadah padang"; label "Usulan AI · kurang yakin, mohon dicek"; lines "Belanja 5.04.01.00 Konsumsi rapat" and "Belanja 5.05.02.00 Sewa peralatan" without amounts, each with "Pilih ini"; no Pakai; Pilih sendiri, Abaikan.
    Changing `usulan` resets the board state to the initial object (see Notes).
- **Interactions**
  - Uraian input, on every keystroke (`onChanged`, no debounce) → `ur = value`. While `st == 'ada'`, any text different from the suggestion's basis makes the suggestion stale at once (action row disappears, stale block appears, "Pilih ini" inert); typing the basis text back exactly makes it fresh again. In states `pakai` and `abai` typing changes nothing else. Free text, no formatting.
  - "Pakai" → only if not stale and not unsure: `st = 'pakai'`. The chosen card lists every suggested line with its amount (one or two rows).
  - "Pilih ini" on row i (unsure mode) → only if not stale: `st = 'pakai'`, `pilihan = i`. The chosen card shows that one line with amount "Rp480.000" (the board fills an empty amount with Rp480.000).
  - "Abaikan" → `st = 'abai'`.
  - "Buat usulan baru" (stale) → `dasar = current Uraian`, `st = 'ada'`: the suggestion is fresh again for the new text; its lines and label stay those of the mode (no AI delay is faked).
  - "Ganti pilihan" (chosen) → `st = 'ada'`, `pilihan = null`, `dasar = current Uraian`: the AI panel returns fresh and the box reads "Mata Anggaran belum dipilih".
  - Chosen sentence: "Mata Anggaran sudah dipilih oleh {pelaku} Usulan AI tidak tersimpan sebagai keputusan." with pelaku "Meiske L." (its own full stop ends the sentence). With `jabatanKosong`: "Mata Anggaran sudah dipilih oleh Yanti Sumual, Operator. Usulan AI tidak tersimpan sebagai keputusan." (the full stop after "Operator" is added; see Notes).
  - No TombolBersyarat, no refusal sentence, no timers. There is no control to leave state `abai` other than the tweak reset.
- **Motion** Chosen card `muncul` 300 ms when state becomes `pakai`; ignored sentence `muncul` 300 ms when state becomes `abai`. Keyframes `masuk`, `pudar`, `isi` are declared but unused.
- **Links out** Back arrow → `/Main`, up link (pops when `/Main` or one of its child routes, e.g. `/Main/catat`, is directly beneath). "Pilih sendiri" → `/Bagi`, push. **Inbound** Main (chip "Usulan Mata Anggaran" under "Catatan lain" in the Catat sheet), PetaLayar, Cakupan.
- **Mock data** Draft: −Rp480.000, Belanja, Toko Sinar, Kas, peruntukan Umum Jemaat, Lingkup Jemaat. Default Uraian per mode: "Kertas HVS dan tinta printer"; "Kertas HVS Rp300.000 dan token listrik Rp180.000"; "Keperluan ibadah padang". Mata Anggaran lines: 5.02.01.00 Alat tulis dan fotokopi; 5.01.02.00 Listrik, air dan telepon; 5.04.01.00 Konsumsi rapat; 5.05.02.00 Sewa peralatan. Amounts Rp480.000; Rp300.000 + Rp180.000. Actor Meiske L. / Yanti Sumual, Operator. Share with WebAIMataAnggaran.
- **Prototype-only** none. Keadaan panel: `jabatanKosong`, `usulan`.
- **Acceptance checks**
  1. Open `/AIMataAnggaran` (Satu baris) → Uraian "Kertas HVS dan tinta printer"; `bata` box "Mata Anggaran belum dipilih"; AI panel label "Usulan AI · Mata Anggaran", italic `lautTua` "Belanja 5.02.01.00 Alat tulis dan fotokopi", "Rp480.000"; buttons "Pakai", "Pilih sendiri", "Abaikan" in one row.
  2. Tap "Pakai" → AI panel disappears; a `tinta`-edged card fades in with "Belanja 5.02.01.00 Alat tulis dan fotokopi" / "Rp480.000"; sentence "Mata Anggaran sudah dipilih oleh Meiske L. Usulan AI tidak tersimpan sebagai keputusan."; "Ganti pilihan" shown.
  3. Tap "Ganti pilihan" → AI panel back with the action row; box "Mata Anggaran belum dipilih".
  4. Type one character into Uraian → immediately "Usulan lama — draf sudah berubah. Usulan ini tidak dapat dipakai." and "Buat usulan baru"; the action row is gone. Delete that character → action row returns.
  5. With the edited text, tap "Buat usulan baru" → action row returns; Uraian keeps the edited text.
  6. `usulan` "Bagi ke dua baris" → label "Usulan AI · bagi ke 2 Mata Anggaran", two lines "Rp300.000" and "Rp180.000", sentence "Rp300.000 + Rp180.000 = Rp480.000, sama persis dengan jumlah pembayaran."; "Pakai" → chosen card with two rows.
  7. `usulan` "AI kurang yakin" → label "Usulan AI · kurang yakin, mohon dicek", two lines without amounts each with "Pilih ini", no "Pakai"; "Pilih ini" on "Sewa peralatan" → chosen card "Belanja 5.05.02.00 Sewa peralatan" / "Rp480.000".
  8. Tap "Abaikan" → panel gone; "Usulan diabaikan. Draf boleh disimpan tanpa Mata Anggaran, tetapi belum dapat dibukukan." fades in; box still "Mata Anggaran belum dipilih".
  9. Tap "Pilih sendiri" → `/Bagi`; Back returns with the same state.
  10. `jabatanKosong` on, then "Pakai" → strip shown; sentence "Mata Anggaran sudah dipilih oleh Yanti Sumual, Operator. Usulan AI tidak tersimpan sebagai keputusan."
- **Notes**
  - Recommended: reset the board state when `usulan` changes. On the canvas state survives a tweak change, which leaves `abai` with no way back and, after "Pakai" in a sure mode then switching to "AI kurang yakin", indexes a missing line (`U[null]`, a crash). `jabatanKosong` does not reset.
  - The chosen sentence template relies on "Meiske L." ending in a full stop; with `jabatanKosong` the board renders "…oleh Yanti Sumual, Operator Usulan AI…" without one. Add the full stop (recommended).
  - "Pilih ini" while stale: the board only sets `disabled` (browser default greyed text). Draw it disabled per Tombol: `garis` line, `tinta3` text; its reason is the stale sentence directly below the card.
  - "Pakai" has a grey disabled colour in the logic (`garis` field, `tinta3` text when stale), but it is never visible while stale; build only the `laut` look.
  - KartuUsulanAI lists actions "Pakai, Ubah, Abaikan"; the board uses "Pakai, Pilih sendiri, Abaikan". The board wins.
  - The AI panel radius is 16 here (CONVENTIONS mentions 18 on some AI panels); copy 16. The draft card writes radius 14 then 16: use 16 (`kartuBesar`). Footnote colour is written `tinta3` then `tinta2`: `tinta2` wins.
  - The No. MA inside "Belanja 5.02.01.00 Alat tulis dan fotokopi" stays in the running label font (italic sans in the suggestion, sans in the chosen card) as drawn, not mono.

### WebAIMataAnggaran — Web · Bantuan AI: usulan Mata Anggaran dan pembagian
- **Source** `docs/design/handoff/canvas/boards/WebAIMataAnggaran.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebAIMataAnggaran`, no child routes · **Widget** `WebAIMataAnggaranScreen` in `lib/screens/lengkap/web_ai_mata_anggaran.dart`
- **Purpose** Bendahara Jemaat on the laptop, journey step 2. Same as AIMataAnggaran, with the AI suggestion as a side panel beside the form ("Usulan AI berdiri di samping isian"), per the rule that a phone sheet or block becomes a side panel on web. D31.
- **Shell** Web side nav as WebLihatTransaksi; active item **Transaksi**. `jabatanKosong` banner and footer as there.
- **Layout**
  1. Title block: breadcrumb "Catat transaksi"; h1 "Pilih Mata Anggaran"; subtitle "Usulan AI berdiri di samping isian dan belum mengisi apa pun sampai dipakai."
  2. Two-column row: wrap, gap 24, aligned to the top. Side by side at 1440 and 1280; at 860 the aside wraps below the form.
     a. Left form column (flex 999 1 440, min-width 0, column gap 16): AIMataAnggaran regions 2a (draft card), 2b (Uraian; input text 15), 2c (Mata Anggaran group: "belum dipilih" box or chosen card + sentence + "Ganti pilihan"), with web body size 15 where the phone inherits 16.
     b. Right aside (flex 1 1 380, min-width 0, column gap 14): AIMataAnggaran region 2d (AI panel, identical structure, copy and colours) and region 2e (ignored sentence).
- **Components** Same as AIMataAnggaran. Shared: web side nav.
- **Internal views and states** Same as AIMataAnggaran (initial `{ ur: null, dasar: null, st: 'ada', pilihan: null }`; views fresh, stale, chosen, ignored).
- **Tweaks** `jabatanKosong` (boolean, default false) · Keadaan panel (global switch): banner, nav footer, and the chosen sentence names "Yanti Sumual, Operator" (text replacement enabled, `jk && true`). `usulan` (enum "Satu baris" · "Bagi ke dua baris" · "AI kurang yakin", default "Satu baris") · Keadaan panel: exactly as AIMataAnggaran; changing it resets the board state.
- **Interactions** Same handlers and rules as AIMataAnggaran: Uraian `onChanged` → stale check; "Pakai", "Pilih ini", "Abaikan", "Buat usulan baru", "Ganti pilihan". No timers.
- **Motion** Chosen card and ignored sentence `muncul` 300 ms. Keyframes `isi`, `titik` declared but unused.
- **Links out** Breadcrumb "Catat transaksi" → `/WebCatat`, up link. "Pilih sendiri" → `/WebBagi`, push. Side nav. **Inbound** TabCatat, WebCatat (both "Usulan Mata Anggaran"), PetaLayar.
- **Mock data** Same as AIMataAnggaran.
- **Prototype-only** none. Keadaan panel: `jabatanKosong`, `usulan`.
- **Acceptance checks**
  1. `/WebAIMataAnggaran` at 1440 → nav "Transaksi" active; form on the left, AI panel on the right at the same top line.
  2. Click "Pakai" → aside empties; left shows the `tinta`-edged chosen card fading in and "Ganti pilihan".
  3. Type into Uraian → aside shows the stale sentence and "Buat usulan baru" at once; "Pakai" row gone.
  4. `usulan` "AI kurang yakin" → aside rows each with "Pilih ini"; no "Pakai".
  5. `usulan` "Bagi ke dua baris", "Pakai" → chosen card rows "Belanja 5.02.01.00 Alat tulis dan fotokopi" / "Rp300.000" and "Belanja 5.01.02.00 Listrik, air dan telepon" / "Rp180.000".
  6. "Abaikan" → ignored sentence in the aside; left box "Mata Anggaran belum dipilih".
  7. "Pilih sendiri" → `/WebBagi`; "Catat transaksi" → `/WebCatat`.
  8. At 860 px → "Menu" toggle; the AI panel sits below the form.
  9. `jabatanKosong` on → banner; footer "Yanti Sumual · Operator"; after "Pakai" the sentence names "Yanti Sumual, Operator."
- **Notes** Same notes as AIMataAnggaran (state reset on `usulan`, the added full stop, the disabled "Pilih ini" look, radius 16).

### WebUnggah — Web · Unggah dokumen pendukung
- **Source** `docs/design/handoff/canvas/boards/WebUnggah.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebUnggah`, no child routes (files and status change in place) · **Widget** `WebUnggahScreen` in `lib/screens/lengkap/web_unggah.dart`
- **Purpose** Bendahara Jemaat on the laptop, journey step 2 ("19 · Dokumen pendukung"). Attaching files to BKU-2026-0143 Sewa sound system, whose supporting document is "Wajib, belum ada". Shows D02 (a missing document blocks month close, not Bukukan: "Tutup buku menunggu Terverifikasi atau Dikecualikan"), the PanelDokumen rules (uploaded is not verified; Gagal diunggah in `bata` with a next step), EC07 (a failed file is never read as attached; the status stays "Wajib, belum ada"), the Gerak rule that upload always looks in progress and success never shows early, and StatusSimpan's "Coba lagi never creates a duplicate".
- **Shell** Web side nav as WebLihatTransaksi; active item **Transaksi**. `jabatanKosong` banner and footer as there.
- **Layout**
  1. Title block: breadcrumb "Dokumen pendukung"; h1 "Unggah dokumen pendukung"; subtitle 14 `tinta2` "BKU-2026-0143 · Sewa sound system · Rp600.000".
  2. Two-column row: wrap, gap 24, aligned to the top. Side by side at 1440 and 1280; at 860 the aside wraps below.
     a. Left column (flex 999 1 460, min-width 0, column gap 16):
        - Drop zone (GarisStatus `draf`): 1.5 dashed `putus` line, radius 16, padding 32/20, column, centred, gap 10, text centred. Upload icon 36 px (path `M12 16V5M7.5 9.5L12 5l4.5 4.5M5 19h14`, stroke `tinta2` 1.8, round caps and joins). "Tarik file ke sini" 15/700. "Foto nota, tangkapan layar bukti transfer, atau PDF." 14 `tinta2`. While fewer than three files: button "Pilih file": min-height 46, padding 0 20, radius 12, no line, `tinta` field, `permukaan` text, 15/700. After three files the button is gone (see Prototype-only).
        - Empty message (no files yet) 14 `tinta2`: "Belum ada file. Dokumen pendukung transaksi ini masih “Wajib, belum ada”." (curly quotes).
        - File list card: `permukaan`, 1 px `garis`, radius 14, padding 0 16 (hide the card while the list is empty; see Notes). One row per file: row, centre, gap 14, padding 12/0, 1 px `garis` top rule from the second row, runs `muncul` 300 ms when added.
          - Thumbnail 44×56 (illustration): paper #FBFAF6, 1 px `garisTegas` line, radius 4, column centred, gap 4, padding 0 7; four 2 px bars: `tinta` full width, `putus` full width, `putus` 70 %, `tinta` 50 % aligned right.
          - Text (flex 1, min-width 0): file name mono 14/600 `tinta`; status line 14: status text in the state's colour and weight, then " · {size}" in `tinta3` weight 400. States: uploading "Sedang diunggah…" `tinta2` 500; failed "Gagal diunggah · belum terlampir" `bata` 700; attached "Terlampir" `tinta` 600. While uploading, a progress bar 6 below: height 6, radius 3, `garis` track, clipped; `laut` fill growing from 0 to full width over 1500 ms linear (`isi`).
          - Right: failed → button "Coba lagi": min-height 44, padding 0 14, radius 12, 1.5 `bata` line, `permukaan`, `bata` 15/700. Attached → link "Lihat file": min-height 44, 15/700 `laut`.
     b. Aside (flex 1 1 340, min-width 0): card `permukaan`, 1 px `garis`, radius 14, padding 20, column gap 10.
        - "Dokumen pendukung · {jumlah}" 14 `tinta2`, then status 20/700 `bata`: "Wajib, belum ada" (no file attached) or "Diunggah, belum diverifikasi" (at least one attached).
        - 14 `tinta2`: "Terlampir bukan terverifikasi. Tutup buku menunggu Terverifikasi atau Dikecualikan."
        - 14 `tinta2`: "File yang gagal diunggah tidak pernah terbaca sebagai terlampir. Coba lagi tidak membuat salinan ganda."
        - Only when at least one file is attached: primary link button "Lanjut ke verifikasi": min-height 46, padding 0 20, radius 12, `laut` field, `diLaut` text, 15/700, centred, full width; runs `muncul` 300 ms when it appears.
- **Components** PanelDokumen (file rows with status, size and progress), Tombol (Pilih file, Coba lagi, Lanjut ke verifikasi), GarisStatus `draf` (drop zone), PitaJabatanKosong. Pattern: document thumbnail 44×56 (also in Kamera and LihatDokumen).
- **Internal views and states** Initial state `{ files: [], sudahGagal: false }`; each file `{ n, u, st }` with `st` ∈ `unggah`, `gagal`, `lampir`. Views: empty (no files: empty message, aside "Wajib, belum ada"); uploading rows; failed row; attached rows (aside "Diunggah, belum diverifikasi" and "Lanjut ke verifikasi"); full (three files, "Pilih file" gone). Derived: `jumlah` = "{k} file terlampir" when k attached > 0, else "belum ada file terlampir".
- **Tweaks**
  - `jabatanKosong` (boolean, default false) · Keadaan panel (global switch): banner and nav footer. Text replacement disabled (`jk && false`).
  - `gagalUnggah` (boolean, default false) · Keadaan panel. Off: every upload ends "Terlampir". On: the first upload to finish after it is on ends "Gagal diunggah · belum terlampir" (once per board session; `sudahGagal` then stays true); later uploads and every retry succeed. Changing it resets the board state (see Notes).
- **Interactions**
  - "Pilih file" → if fewer than three files: append the next sample file in order (Mock data) with `st 'unggah'`, then after 1500 ms (fakes the upload): fails if `gagalUnggah` is on and no file has failed yet (set `sudahGagal = true`, `st 'gagal'`), otherwise `st 'lampir'`. Each file has its own timer; adding several quickly runs them in parallel. No real file picker opens.
  - "Coba lagi" on a failed row → `st 'unggah'` (progress bar restarts), then after 1500 ms `st 'lampir'` (a retry never fails). Same row, same name: no duplicate row.
  - Cancel pending timers when the screen is disposed or the state resets.
  - The drop zone itself is not a drop target in the prototype ("Tarik file ke sini" is copy only).
- **Motion** File row `muncul` 300 ms on add (not replayed on status change: key rows by file name). Progress fill `isi` 1500 ms linear, forwards, restarted on retry; it matches the 1500 ms timer. "Lanjut ke verifikasi" `muncul` 300 ms when it first appears. Under reduce motion the bar is full at once, but the status still waits the full 1500 ms (success never shows early). Keyframe `titik` declared but unused.
- **Links out** Breadcrumb "Dokumen pendukung" → `/WebDokumen`, up link. "Lanjut ke verifikasi" → `/WebDokumen`, up link (same target as the breadcrumb). "Lihat file" (each attached row) → `/WebLihatDokumen`, push. Side nav. **Inbound** WebDokumen ("Unggah file"), WebTransaksi and TabTransaksi (row action "Lampirkan dokumen pendukung", built from their `TUJU` table), PetaLayar, Cakupan.
- **Mock data** Transaction BKU-2026-0143 · Sewa sound system · Rp600.000 (as in WebBukti, where its document is "Wajib, belum ada"). Sample files, in order: "nota-sewa-sound.jpg" 1,2 MB; "kuitansi-cv-nada-prima.pdf" 340 KB; "tanda-terima.jpg" 880 KB.
- **Prototype-only** "Contoh ini berhenti di tiga file." (13 `tinta3`, shown in the drop zone after three files) is a prototype limit, not app copy: in the screen just hide "Pilih file" after three files; show the sentence in the Keadaan panel as a labelled hint. Keadaan panel: `jabatanKosong`, `gagalUnggah`, the hint.
- **Acceptance checks**
  1. `/WebUnggah` → nav "Transaksi" active; aside "Dokumen pendukung · belum ada file terlampir" and "Wajib, belum ada" in `bata`; empty message with curly quotes; no "Lanjut ke verifikasi".
  2. Click "Pilih file" → row "nota-sewa-sound.jpg", "Sedang diunggah… · 1,2 MB", bar filling; after 1500 ms the row reads "Terlampir · 1,2 MB" with "Lihat file"; aside "Dokumen pendukung · 1 file terlampir", "Diunggah, belum diverifikasi"; "Lanjut ke verifikasi" fades in.
  3. Click "Pilih file" two more times → rows "kuitansi-cv-nada-prima.pdf" (status "… · 340 KB") and "tanda-terima.jpg" (status "… · 880 KB") in that order; "Pilih file" is gone; aside count reaches "3 file terlampir" after the timers.
  4. `gagalUnggah` on, "Pilih file" → after 1500 ms "Gagal diunggah · belum terlampir · 1,2 MB" in `bata` bold with "Coba lagi"; aside still "Wajib, belum ada"; no "Lanjut ke verifikasi".
  5. Then "Coba lagi" → the same row shows "Sedang diunggah…" with a fresh bar; after 1500 ms "Terlampir"; still one row for that file.
  6. With `gagalUnggah` on, the second file succeeds.
  7. "Lihat file" → `/WebLihatDokumen`; "Lanjut ke verifikasi" and the breadcrumb → `/WebDokumen`.
  8. Leaving the page during an upload throws no error after 1500 ms (timer cancelled).
  9. `jabatanKosong` on → banner and footer "Yanti Sumual · Operator".
- **Notes**
  - The board always renders the file list card, which with no files is an empty 2 px bordered strip; hiding it while the list is empty is the recommended choice.
  - The status "Diunggah, belum diverifikasi" stays `bata` like "Wajib, belum ada" (both still block month close). Keep it.
  - Recommended: reset `{ files: [], sudahGagal: false }` and cancel timers when `gagalUnggah` changes, so the failure can be replayed; on the canvas state survives the tweak.
  - The subtitle "BKU-2026-0143 · Sewa sound system · Rp600.000" is drawn in sans; keep it as a running label. Off-token: status 20/700; radius 16 drop zone (`kartuBesar`), 4 thumbnail, 3 progress bar; #FBFAF6 is the permitted illustration paper colour.
  - The drop zone writes radius 14 then 16: 16 wins.

### WebExcelTerbatas — Web · Contoh file Excel TERBATAS
- **Source** `docs/design/handoff/canvas/boards/WebExcelTerbatas.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebExcelTerbatas`, no child routes (sheet tabs switch in place) · **Widget** `WebExcelTerbatasScreen` in `lib/screens/lengkap/web_excel_terbatas.dart`
- **Purpose** Shows what the Excel file of a TERBATAS copy for the restricted Diakonia access contains (journey: "12 · Akses terbatas per peruntukan", opened from WebTerbatas "Unduh Excel"; also Bendahara step 5, report pack). Shows D27 (a TERBATAS copy contains F02, F03, F05, F07 and F12, nothing else), D26 (restricted access still sees Mata Anggaran), PitaLaporan's "a restricted copy is titled TERBATAS", and the file rules: rows 1–4 identify the report, negatives keep the minus, zero is 0, missing is blank, No. MA and No. Bukti are text.
- **Shell** Web side nav as WebLihatTransaksi; active item **Laporan**. No `jabatanKosong` on this board: footer always "**Meiske L.** · Bendahara" / "Wewenang Bendahara aktif".
- **Layout**
  1. Title block: breadcrumb "Laporan"; h1 "Contoh file Excel TERBATAS"; subtitle 14 `tinta2` "File dibuat khusus untuk bagian peruntukan Diakonia. Bukan versi tersembunyi dari file seluruh Jemaat."
  2. Spreadsheet window: `permukaan`, 1 px `garisTegas` line, radius 10, clipped, column.
     a. Title bar: padding 10/14, 1 px `garis` bottom rule; row, wrap, baseline, gap 6/16. File name mono 14/600 "Paket-Laporan-GMIM_Jemaat-Karunia_2026-10_TERBATAS-Diakonia.xlsx"; then 13 `tinta3` "TERBATAS · Akses terbatas: Peruntukan Diakonia · hanya lembar yang punya bagian Diakonia".
     b. Grid (scrolls horizontally inside the window): inner min-width per sheet (below); all text mono 13 unless stated.
        - Column-letter row: `kertas` field, 1 px `garisTegas` bottom rule. Cells: first blank, then "A", "B", … one per sheet column; padding 4/8, centred, `tinta2`, 1 px `garis` right rule.
        - Then rows 1… : each a grid row with 1 px `garis` bottom rule; each cell padding 6/8 with 1 px `garis` right rule. Column 0 (44 px) is the row number: centred, `tinta2` on `kertas`, mono, no wrap.
        - Rows 1–4 (identification, one text in column A, other cells blank): text does not wrap and runs over the blank cells to its right, like Excel. Row 1 = the sheet's report name in capitals, 700 (e.g. "REALISASI PENDAPATAN MENURUT MATA ANGGARAN"); row 2 "Jemaat Karunia"; row 3 "Periode laporan: 01/10/2026 s.d. 31/10/2026"; row 4 "Laporan resmi · SNP-2026-10-01 · TERBATAS · Akses terbatas: Peruntukan Diakonia". These texts are sans (Plus Jakarta Sans 13).
        - Row 5: blank.
        - Row 6: column headers, 700, `kertas` row field, left-aligned, sans.
        - Rows 7…: data. Cell rules: a value starting "Rp" or "−Rp" is an amount: shown without "Rp", "−Rp" becomes a leading hyphen-minus "-" (e.g. "−Rp300.000" → "-300.000", "Rp0" → "0"), right-aligned, mono. Codes (start "BKU-", "OPN-", "ADJ-", or digit-dot-digit such as "1.3.55.01.00") are mono, left. Everything else (dates, names, statuses) sans, left, wrapping. Blank cells in amount columns are right-aligned (no visible effect). Rows marked as totals are 700; others 400. Row field `permukaan`.
        - Column widths: "44px" + each board width + 28 px; `minmax(0, 1fr)` columns take the rest.
     c. Sheet tabs bar: `kertas` field, 1 px `garisTegas` top rule, scrolls horizontally. Tabs in order "F02", "F03", "F05", "F07", "F12": each min-height 44, padding 0 16, 1 px `garis` right rule, mono 13 `tinta`. Selected: `permukaan` field, 700, a 3 px inner `laut` line on the bottom edge; others transparent, 500. `aria-pressed` → selected semantics.
  3. Notes grid: auto-fit columns min(280, 100 %), gap 12/28, 14 `tinta2`, bold parts `tinta`:
     - "**Baris 1 sampai 4** selalu memuat judul, Jemaat, Periode laporan dan ID laporan resmi, supaya lembar yang dicetak sendiri tetap dapat dikenali."
     - "**Angka negatif** memakai tanda minus dan tidak dipotong ke nol. **Nol** ditulis 0. **Yang tidak ada** dibiarkan kosong, bukan 0."
     - "**Nomor Mata Anggaran dan No. Bukti** disimpan sebagai teks, persis seperti tersimpan, supaya Excel tidak mengubahnya menjadi tanggal atau angka."
- **Components** none of the 31 directly. Patterns: spreadsheet preview (column letters, row numbers, sheet tabs); selected tab with the 3 px bottom `laut` line (foundations rule).
- **Internal views and states** Initial state `{ pilih: 'F05' }`. One view per sheet tab (five). If `pilih` is not one of the five, fall back to F02 (the board's guard).
- **Tweaks** none (`data-props` has only `$preview`). Keadaan panel shows no board tweaks.
- **Interactions** Sheet tab → `pilih = <its id>`; the grid redraws for that sheet. No other handlers, no typed input, no timers.
- **Motion** none (keyframes `isi`, `muncul`, `titik` declared but unused).
- **Links out** Breadcrumb "Laporan" → `/WebPaketLaporan`, up link. Side nav. **Inbound** WebTerbatas ("Unduh Excel"), PetaLayar.
- **Mock data** Identification rows as above. Sheets (row 1 title; column headers; data rows as displayed; **B** = bold total row; min-width; column template):
  - F02 "BUKU KAS UMUM" and F03 "BUKU KAS PEMBANTU" (identical data; F02 is a copy of F03): headers Tanggal · No. Bukti · No. MA · Penerimaan · Pengeluaran · Saldo Diakonia. Rows: **B** (blank) · (blank) · (blank) · (blank) · (blank) · 3.050.000; 04/10/2026 · BKU-2026-0098 · 1.3.55.01.00 · 950.000 · (blank) · 4.000.000; 27/10/2026 · BKU-2026-0122 · 4.03.04.00 · (blank) · 300.000 · 3.700.000. Columns 44 · 112 · 146 · 158 · 148 · 148 · 158; min-width 914. Letters A–F.
  - F05 "REALISASI PENDAPATAN MENURUT MATA ANGGARAN": headers No. MA · Nama Mata Anggaran · Oktober 2026. Rows: 1.3.55.01.00 · Persembahan Diakonia · 950.000; **B** (blank) · Jumlah Pendapatan peruntukan Diakonia · 950.000. Columns 44 · 178 · 1fr · 198; min-width 720. Letters A–C.
  - F07 "REALISASI BELANJA MENURUT MATA ANGGARAN": same headers as F05. Rows: 4.03.03.00 · Diakonia duka · 0; 4.03.04.00 · Diakonia sakit · 300.000; **B** (blank) · Jumlah Belanja peruntukan Diakonia · 300.000. Columns as F05; min-width 720.
  - F12 "DAFTAR BUKTI KAS": headers No. Bukti · Tanggal · Bagian Diakonia · Dokumen pendukung saat tutup buku. Rows: BKU-2026-0098 · 04/10/2026 · 950.000 · Terverifikasi; BKU-2026-0122 · 27/10/2026 · -300.000 · Terverifikasi. Columns 44 · 158 · 128 · 188 · 1fr; min-width 818. Letters A–D.
  Row numbering: identification 1–4, blank 5, headers 6, data from 7 (F02/F03 rows 7–9, F05 7–8, F07 7–9, F12 7–8).
- **Prototype-only** none. Keadaan panel: no tweaks.
- **Acceptance checks**
  1. `/WebExcelTerbatas` → nav "Laporan" active; tab bar shows exactly F02, F03, F05, F07, F12; F05 is selected (`permukaan`, bold, 3 px `laut` bottom line).
  2. F05 grid: row 1 "REALISASI PENDAPATAN MENURUT MATA ANGGARAN" bold and unwrapped across columns; row 4 "Laporan resmi · SNP-2026-10-01 · TERBATAS · Akses terbatas: Peruntukan Diakonia"; row 6 "No. MA | Nama Mata Anggaran | Oktober 2026" on `kertas`; row 7 "1.3.55.01.00 | Persembahan Diakonia | 950.000" with the amount right-aligned; row 8 bold "Jumlah Pendapatan peruntukan Diakonia | 950.000".
  3. Column-letter row reads blank, A, B, C for F05; row-number column reads 1 to 8.
  4. Click F12 → row 8 amount cell reads "-300.000"; status "Terverifikasi" in sans.
  5. Click F07 → row 7 amount "0"; row 9 bold "Jumlah Belanja peruntukan Diakonia | 300.000".
  6. Click F03 → letters A–F; row 7 bold with only "3.050.000" in column F; F02 shows the same grid with title "BUKU KAS UMUM".
  7. At 860 px, F03 scrolls horizontally inside the window (min-width 914); the page does not scroll sideways.
  8. "Laporan" breadcrumb → `/WebPaketLaporan`.
- **Notes**
  - The board defines the whole-Jemaat data for F01–F14 (`LAP`) but overwrites it with the TERBATAS data (`LAP = LAPT`) before rendering. Build only the five TERBATAS sheets; the full file is the separate board WebExcel.
  - Each sheet's `sub` and `kaki` texts are defined but never rendered: build nothing for them.
  - The opening-balance row of F02/F03 has no label (the Uraian column is removed in the TERBATAS copy); copy as drawn.
  - Amounts in cells use an ASCII hyphen-minus ("-300.000"), as a spreadsheet cell shows a number; this is not the app's `rp()` formatter. Keep it.
  - Reached from WebTerbatas (restricted Diakonia user), the board still shows the Bendahara side nav and footer, and its breadcrumb goes to WebPaketLaporan (so it does `go` there, as WebTerbatas is beneath). Keep the board; flag for design.
  - Off-token radius 10 on the window. How spilled identification text meets the blank cells' vertical lines: either order is acceptable; the board paints the lines over the text.

### Memuat — 44 · Memuat, gagal memuat, Bukukan tidak terjadi
- **Source** `docs/design/handoff/canvas/boards/Memuat.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 · interactive yes
- **Route** `/Memuat`, no child routes (the `keadaan` tweak picks the Beranda view or the Periksa view; no control on the board moves between them) · **Widget** `MemuatScreen` in `lib/screens/lengkap/memuat.dart`
- **Purpose** Bendahara Jemaat, daily work (journey step 2) and the "Keadaan umum" journey. Three honest states: Beranda loading (Rangka skeleton, no provisional figure), Beranda failed to load (no balance shown, so an empty figure is never read as zero; retry), and a Bukukan the server did not confirm (the transaction stays Draf, no No. Bukti used; "Coba lagi" is safe and books once). Shows D03 (Beranda opens with one combined Saldo buku), the Rangka and StatusSimpan rules, and the Gerak rule that success is never shown before it has happened.
- **Shell** Phone, no tab bar. Beranda view: phone home header without back (title and month pill). Periksa view: phone header with back and a fixed bottom action bar. Root `kertas`, `tinta`, `isi` 16/1.4. No `jabatanKosong`.
- **Layout**
  - **Beranda view** (states `muat`, `gagal`, `ada`):
    1. Header (fixed): row, space-between, centre, padding 24/20/8. h1 "Beranda" `judulBesar` 22/700. Month pill (not pressable): "November 2026" 14/600 `tinta2`, 1 px `garisTegas` line, radius 999, padding 6/12.
    2. Scroll area: padding 8/20/20, column gap 16. One of:
       - Loading (`muat`), Rangka, `role=status` (semantics "Memuat"), column gap 16: "Memuat saldo dan transaksi…" 14 `tinta2`; bar 62 % × 44 radius 8 (balance); card `permukaan`, 1 px `garis`, radius 14, padding 16, column gap 14, holding three rows (space-between, centre, gap 16) of a 44 % × 16 bar and a 26 % × 16 bar; then a column gap 10: bar 34 % × 18 (section title) and two cards (`permukaan`, 1 px `garis`, radius 14, padding 14/16, column gap 8) each with a 58 % × 14 and a 32 % × 14 bar. Every bar: `garis` field, radius 8, hidden from semantics, pulsing `denyut`. Percent widths are of the containing box.
       - Failed (`gagal`): card `role=alert`, `bataLembut` field, 1.5 solid `bata` line (`hambatan`), radius 14, padding 16, column gap 6: "Data belum dapat dimuat" 17/700; "Server tidak menjawab. Pembukuan Anda tidak berubah." 14 `tinta2`; button "Coba lagi": min-height 52, min-width 140, padding 0 20, margin-top 6, left-aligned, radius 14, `tinta` field, `permukaan` 16/700. Below the card: 14 `tinta2` "Saldo tidak ditampilkan sampai data berhasil dimuat, supaya angka kosong tidak terbaca sebagai nol."
       - Loaded (`ada`), column gap 16, runs `muncul` 300 ms. First a heading block of three lines with no gap between them: "Saldo buku · semua Kas/Bank" 14 `tinta2`; "Rp38.415.000" mono 36/500, letter-spacing −1; "Hanya transaksi yang sudah dibukukan" 13 `tinta3`. Card `permukaan`, 1 px `garis`, radius 14, padding 4/16; rows space-between, gap 16, padding 12/0, 1 px `garis` top rule from row 2: "Kas" / "Rp8.420.000"; "Bank BNI ··4821" / "Rp24.615.000"; "Bank SulutGo ··1107" / "Rp5.380.000" (amounts mono 16/400). Then link button "Buka Beranda": min-height 48, padding 0 20, radius 14, 1.5 `tinta` line, `permukaan`, `tinta` 16/700, centred, full width.
  - **Periksa view** (states `aksi`, `buku`):
    1. Header (fixed): back target 44×44 with chevron as LihatTransaksi, semantics "Kembali ke Beranda"; title "Periksa dan bukukan" `judulLayar`; no subtitle.
    2. Scroll area: padding 8/20/20, column gap 16. One of:
       - Not booked (`aksi`): alert card as the failed card (`role=alert`, `bataLembut`, 1.5 `bata`, radius 14, padding 16, gap 6): "Bukukan tidak terjadi: server tidak menjawab." 17/700; "Transaksi ini masih Draf dan belum masuk saldo. Belum ada No. Bukti yang dipakai." 14 `tinta2`. Draft card (GarisStatus `draf`): 1.5 dashed `putus`, radius 16, padding 18, column gap 6: badge "Draf · belum masuk saldo" (LencanaStatus Draf, as AIMataAnggaran); "−Rp85.000" mono 30/500 `tinta2`; "Air minum untuk rapat" 16/600; `keterangan` 13 `tinta3` "Kas · Belanja 5.04.01.00 Konsumsi rapat · 16 November 2026". Then 14 `tinta2` "Coba lagi aman: tidak membuat transaksi kedua dan tidak memakai dua No. Bukti."
       - Booked (`buku`): card GarisStatus `terpilih` (`permukaan`, 1.5 `tinta` line), radius 16, padding 18, column gap 6, runs `muncul` 300 ms. Top row space-between, centre, gap 16: badge "Dibukukan" (LencanaStatus: 13/700, radius 6, padding 3/9, `tinta` field, `permukaan` text, no line: the board draws none, so it is 3 px smaller than the `tinta` shape with its 1.5 line); stamp "No. Bukti BKU-2026-0155" mono 14/600 `laut`, 2 px `laut` line, radius 8, padding 4/10, runs `muncul` 400 ms. "−Rp85.000" mono 30/500 `tinta`; "Air minum untuk rapat" 16/600; 13 `tinta3` "Dibukukan pada 16/11/2026 11.52 · satu kali".
    3. Bottom bar (fixed): padding 12/20/22, `permukaan`, 1 px `garis` top rule, column gap 8. `aksi`: button "Coba lagi" (min-height 52, radius 14, `tinta` field, `permukaan` 16/700, full width), then text link "Biarkan sebagai draf" (min-height 44, `laut` 16/700, centred). `buku`: link button "Kembali ke Beranda" (min-height 48, radius 14, 1.5 `tinta` line, `permukaan`, 16/700, centred, full width).
- **Components** Rangka (loading), StatusSimpan failure banner pattern (`bataLembut` + `bata` line + "Coba lagi"), LencanaStatus (Draf, Dibukukan), GarisStatus (`draf`, `terpilih`, `dibukukan` balance card), Tombol. Pattern: No. Bukti stamp (laut-edged mono label).
- **Internal views and states** Initial state `{ st: null }`; the shown state is `st ?? map[keadaan]` with "Sedang memuat" → `muat`, "Gagal memuat" → `gagal`, "Bukukan tidak terjadi" → `aksi`. States: `muat`, `gagal`, `ada` (Beranda view); `aksi`, `buku` (Periksa view). `muat` reached by the tweak shows the skeleton indefinitely (no timer).
- **Tweaks** `keadaan` (enum "Sedang memuat" · "Gagal memuat" · "Bukukan tidak terjadi", default "Sedang memuat") · Keadaan panel. "Sedang memuat": Beranda view, skeleton. "Gagal memuat": Beranda view, failed card. "Bukukan tidak terjadi": Periksa view, not-booked alert and draft. Changing it resets `st` to null and cancels the timer (see Notes).
- **Interactions**
  - "Coba lagi" in the failed card → `st = 'muat'` (skeleton), then after 1400 ms (fakes the reload) `st = 'ada'` (balances fade in). Cancel the timer on dispose or tweak change.
  - "Coba lagi" in the bottom bar (`aksi`) → `st = 'buku'` immediately (no delay on the board): the booked card replaces the alert and the draft, the bar shows "Kembali ke Beranda".
  - No typed input.
- **Motion** Skeleton bars `denyut` 1.4 s ease-in-out, infinite (opacity 1 → 0.45 → 1); stops under reduce motion (bars stay at full opacity). Loaded content `muncul` 300 ms. Booked card `muncul` 300 ms; No. Bukti stamp `muncul` 400 ms, fill both (hidden until it starts). Timer 1400 ms as above. Keyframes `masuk`, `pudar`, `isi` declared but unused. The board does not use the `tinta` booking motion here; do not add it.
- **Links out** "Buka Beranda" → `/Main`, go. Back arrow → `/Main`, up link. "Biarkan sebagai draf" → `/Main`, up link. "Kembali ke Beranda" → `/Main`, up link. (Memuat is opened from PetaLayar, Cakupan or the launcher, never from Main, so in practice these do `go`.) **Inbound** PetaLayar, Cakupan (map sheets; no app screen links here).
- **Mock data** Saldo buku Rp38.415.000 = Kas Rp8.420.000 + Bank BNI ··4821 Rp24.615.000 + Bank SulutGo ··1107 Rp5.380.000. Month November 2026. Draft: −Rp85.000, "Air minum untuk rapat", Kas, Belanja 5.04.01.00 Konsumsi rapat, 16 November 2026. Booked: No. Bukti BKU-2026-0155, 16/11/2026 11.52. These balances differ from other Beranda boards; keep this board's figures (list in `mock-data.md`).
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. `/Memuat` (default) → header "Beranda" and pill "November 2026"; "Memuat saldo dan transaksi…" and pulsing grey bars; no figure; after 5 s still loading.
  2. `keadaan` "Gagal memuat" → alert "Data belum dapat dimuat" with "Coba lagi"; sentence "Saldo tidak ditampilkan …"; no balance.
  3. Tap "Coba lagi" → skeleton at once; 1400 ms later "Rp38.415.000" and the three Kas/Bank rows fade in with "Buka Beranda".
  4. "Buka Beranda" → `/Main`.
  5. `keadaan` "Bukukan tidak terjadi" → header "Periksa dan bukukan" with back; alert "Bukukan tidak terjadi: server tidak menjawab."; dashed draft card "−Rp85.000"; bottom "Coba lagi" and "Biarkan sebagai draf".
  6. Tap bottom "Coba lagi" → booked card with "Dibukukan", stamp "No. Bukti BKU-2026-0155", "Dibukukan pada 16/11/2026 11.52 · satu kali"; bottom "Kembali ke Beranda".
  7. After step 6, switch `keadaan` to "Gagal memuat" → the failed card shows (state reset).
  8. Reduce motion on → bars static; loaded content appears without fade.
  9. Back arrow, "Biarkan sebagai draf", "Kembali ke Beranda" → `/Main`.
- **Notes**
  - Recommended: reset `st` to null whenever `keadaan` changes. On the canvas a handler-set `st` overrides the tweak until the board is reopened.
  - The board draws Beranda without the tab bar; do not add one.
  - Primary-looking actions here ("Coba lagi") use a `tinta` field, not `laut`; keep the board.
  - Off-token: 17/700 alert titles, 36 mono balance (jumlahUtama is 38), radius 8 on bars and stamp. The draft card writes radius 14 then 16 (16 wins); the booked card writes `garis` 1 px then `tinta` 1.5 and radius 14 then 16 (the later values win).

### WebMemuat — Web · Memuat, gagal memuat, Bukukan tidak terjadi
- **Source** `docs/design/handoff/canvas/boards/WebMemuat.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebMemuat`, no child routes · **Widget** `WebMemuatScreen` in `lib/screens/lengkap/web_memuat.dart`
- **Purpose** Bendahara Jemaat on the laptop. Same three states as Memuat inside the web page.
- **Shell** Web side nav as WebLihatTransaksi; active item **Beranda** in both views (see Notes). No `jabatanKosong`: footer always Meiske L.
- **Layout**
  - **Beranda view** (`muat`, `gagal`, `ada`):
    1. h1 "Beranda" `judulHalaman` 26/700, no breadcrumb, no subtitle, no month pill (the phone's "November 2026" pill is not drawn on web).
    2. Content column, max-width 560, column gap 16: the same Loading, Failed and Loaded blocks as Memuat (identical copy, sizes, colours, bars; text at web size 15 where the phone inherits 16). "Buka Beranda" link button as on the phone (min-height 48, radius 14, secondary).
  - **Periksa view** (`aksi`, `buku`):
    1. Title block: breadcrumb "Transaksi"; h1 "Periksa dan bukukan".
    2. Content column, max-width 560, column gap 16: the same not-booked block (alert, draft card, sentence) or booked card as Memuat.
    3. Action row at the end of the content column: wrap, gap 8. `aksi`: button "Coba lagi" (min-height 46, padding 0 20, radius 12, `tinta` field, `permukaan` 15/700) and link button "Biarkan sebagai draf" (min-height 46, padding 0 20, radius 12, 1.5 `tinta` line, `permukaan`, `tinta` 15/700). `buku`: link button "Kembali ke Transaksi" (same secondary style).
- **Components** Same as Memuat. Shared: web side nav.
- **Internal views and states** Same as Memuat (initial `{ st: null }`, states `muat`, `gagal`, `ada`, `aksi`, `buku`).
- **Tweaks** `keadaan` (enum "Sedang memuat" · "Gagal memuat" · "Bukukan tidak terjadi", default "Sedang memuat") · Keadaan panel; as Memuat, reset `st` on change.
- **Interactions** Same as Memuat: failed "Coba lagi" → `muat`, then 1400 ms → `ada`; Periksa "Coba lagi" → `buku` at once.
- **Motion** Same as Memuat: `denyut` 1.4 s infinite on bars; `muncul` 300 ms on loaded content and booked card; `muncul` 400 ms both on the stamp. Keyframes `isi`, `titik` declared but unused.
- **Links out** "Buka Beranda" → `/WebBeranda`, go. Breadcrumb "Transaksi" → `/WebTransaksi`, up link. "Biarkan sebagai draf" and "Kembali ke Transaksi" → `/WebTransaksi`, up link. Side nav. **Inbound** PetaLayar, Cakupan (map sheets; no app screen links here).
- **Mock data** Same as Memuat.
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. `/WebMemuat` at 1440 → nav "Beranda" active; h1 "Beranda"; skeleton in a column no wider than 560, pulsing.
  2. `keadaan` "Gagal memuat" → failed card; "Coba lagi" → skeleton, then after 1400 ms "Rp38.415.000" and three rows; "Buka Beranda" → `/WebBeranda`.
  3. `keadaan` "Bukukan tidak terjadi" → breadcrumb "Transaksi", h1 "Periksa dan bukukan", alert, draft card, buttons "Coba lagi" and "Biarkan sebagai draf" side by side.
  4. "Coba lagi" → booked card with stamp "No. Bukti BKU-2026-0155"; only "Kembali ke Transaksi" remains.
  5. "Kembali ke Transaksi", "Biarkan sebagai draf" and the breadcrumb → `/WebTransaksi`.
  6. At 860 px → "Menu" toggle; content column full width up to 560.
- **Notes** Side-nav active item stays "Beranda" even in the Periksa view, whose breadcrumb is "Transaksi"; the board fixes index 0. Keep it (flag for design). Same state-reset recommendation as Memuat.

### Keluar — 45 · Akun dan keluar
- **Source** `docs/design/handoff/canvas/boards/Keluar.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 · interactive yes
- **Route** `/Keluar` (Akun, with the confirmation sheet as an overlay) plus child route `/Keluar/keluar` (state `keluar`, the full-screen "Anda sudah keluar") · **Widget** `KeluarScreen` in `lib/screens/lengkap/keluar.dart`
- **Purpose** Bendahara Jemaat (and anyone: "Alur · Akun saya … sign-out" journey; Bendahara step 6 "9 · Bendahara, sesi, serah terima"). Account summary, this device's session, the way to other sessions, and signing out of this device only, with a confirmation that says what is kept and what is lost. Shows P01 (sign-in with a code sent to a phone number), P04 (changing the phone number from Akun saya), and that signing out does not change the Bendahara authority.
- **Shell** Phone header with back, fixed bottom bar, no tab bar. Root `kertas`, `tinta`, `isi` 16/1.4. No `jabatanKosong`.
- **Layout**
  - **Akun view** (states `akun` and `tanya`):
    1. Header (fixed): back target as LihatTransaksi, semantics "Kembali ke Lainnya"; title "Akun" `judulLayar`; no subtitle.
    2. Scroll area: padding 8/20/20, column gap 16:
       a. Profile card: `permukaan`, 1 px `garis`, radius 14, padding 16, column gap 2. "Meiske Lumentut" 18/700; "Bendahara · Jemaat Karunia · Wewenang Bendahara aktif" 14 `tinta2`; 13 `tinta3` "Masuk dengan kode ke nomor ponsel · " followed by link "Ganti nomor ponsel" 13/700 `laut` (inline; give it a 44 px tall target).
       b. Sessions card: `permukaan`, 1 px `garis`, radius 14, padding 4/16. Row 1 (space-between, centre, gap 16, padding 12/0): "Perangkat ini" 16/600 over "Masuk sejak 16/11/2026 08.02" 13 `tinta3`; badge "Sedang dipakai" (LencanaStatus `peran`) 13/700, radius 6, padding 3/9, 1.5 `tinta` line, `tinta` text, no fill, no wrap, not shrinking. Row 2, a link: min-height 52, 1 px `garis` top rule, space-between, centre: "Sesi di perangkat lain" 16/600 `tinta`; chevron 18 px (path `M9 6l6 6-6 6`, stroke `tinta3` 2, round caps).
       c. 14 `tinta2`: "Keluar hanya mengakhiri sesi di perangkat ini. Wewenang Bendahara tidak berubah."
    3. Bottom bar (fixed): padding 12/20/22, `permukaan`, 1 px `garis` top rule. Button "Keluar dari perangkat ini": full width, min-height 48, radius 14, 1.5 `tinta` line, `permukaan`, `tinta` 16/700, centred.
    4. Confirmation sheet (state `tanya`, overlay over the whole Akun view, not a route): scrim fills the screen, `tinta` at 45 % opacity, pressable (semantics "Kembali ke Akun"), fades in `pudar` 200 ms. Sheet at the bottom: `permukaan`, top corners 22 (`lembar`), no handle, padding 18/20/24, column gap 12, enters with `muncul` 280 ms. One block with no gap inside: title "Keluar dari perangkat ini?" `judulLayar` (h2) over 14 `tinta2` "Yang sudah dibukukan dan draf yang sudah tersimpan tetap aman. Isian yang belum tersimpan akan hilang."; button "Keluar" (min-height 52, padding 0 20, radius 14, `tinta` field, `permukaan` 16/700, full width); text button "Kembali" (min-height 44, `tinta` 16/700, centred, full width).
  - **Keluar view** (`/Keluar/keluar`): full screen, column, vertically centred, padding 0 28, gap 20; enters with `pudar` 250 ms. h1 "Anda sudah keluar" 24/700, line-height 1.2, 6 below; 15 `tinta2` "Sesi di perangkat ini berakhir. Masuk lagi kapan saja dengan kode yang dikirim ke nomor ponsel Anda."; link button "Masuk": min-height 52, padding 0 20, radius 14, `laut` field, `diLaut` 16/700, centred, full width. No header, no back arrow.
- **Components** LembarBawah (confirmation sheet), Tombol (secondary "Keluar dari perangkat ini", `tinta`-field "Keluar", text "Kembali", primary `laut` "Masuk"), badge "Sedang dipakai" (LencanaStatus `peran`). Pattern: settings link row with chevron.
- **Internal views and states** Initial state `{ st: 'akun' }`. States: `akun` (Akun view), `tanya` (Akun view + sheet), `keluar` (child route). The logic also derives `biasa` (`st == 'akun'`), unused on the phone.
- **Tweaks** none. Keadaan panel shows no board tweaks.
- **Interactions**
  - "Keluar dari perangkat ini" → `st = 'tanya'` (sheet opens).
  - Scrim or "Kembali" → `st = 'akun'` (sheet closes). System Back while the sheet is open also closes the sheet (not the screen).
  - "Keluar" → `st = 'keluar'`: close the sheet (set `/Keluar` back to `akun`), then navigate to `/Keluar/keluar` (go, with a 250 ms fade transition instead of the default screen change). Back from there returns to `/Keluar` in state `akun`.
  - No typed input, no timers.
- **Motion** Scrim `pudar` 200 ms; sheet `muncul` 280 ms (fade in, rise 8 px; duration = `pindahLayar`, CSS `ease`); closing removes scrim and sheet at once (no exit motion); Keluar view `pudar` 250 ms. Keyframes `masuk`, `isi` declared but unused.
- **Links out** Back arrow → `/Lainnya`, up link (pops when `/Lainnya` or one of its child routes is directly beneath). "Ganti nomor ponsel" → `/AkunSaya`, push. "Sesi di perangkat lain" → `/Bendahara`, push. "Masuk" → `/Masuk`, go. **Inbound** Lainnya ("Akun dan keluar"), PetaLayar.
- **Mock data** Meiske Lumentut, Bendahara, Jemaat Karunia, "Wewenang Bendahara aktif"; this device signed in since 16/11/2026 08.02.
- **Prototype-only** none. Keadaan panel: no tweaks.
- **Acceptance checks**
  1. `/Keluar` → header "Akun"; card "Meiske Lumentut"; row "Perangkat ini · Masuk sejak 16/11/2026 08.02" with badge "Sedang dipakai"; bottom "Keluar dari perangkat ini".
  2. Tap "Keluar dari perangkat ini" → scrim fades in, sheet "Keluar dari perangkat ini?" rises with "Keluar" and "Kembali".
  3. Tap the scrim → sheet closes; open again and tap "Kembali" → closes; open again and press system Back → closes, still on `/Keluar`.
  4. Tap "Keluar" → `/Keluar/keluar` fades in: "Anda sudah keluar", sentence, "Masuk" in `laut`.
  5. "Masuk" → `/Masuk`.
  6. "Ganti nomor ponsel" → `/AkunSaya`; "Sesi di perangkat lain" → `/Bendahara`; each returns with Back.
  7. Back arrow → `/Lainnya`.
- **Notes** The "Keluar" confirm button uses a `tinta` field (Tombol reserves that look for the permanent hold button); it is a plain press here. Keep the board. "Kembali" is written `laut` then `tinta`: `tinta` wins. The sheet uses the board's `muncul` (8 px rise) rather than a full slide-up; keep 280 ms. The signed-out view's 15 px text is written 14 then 15: 15 wins. Off-token: 24/700 h1.

### WebKeluar — Web · Akun dan keluar
- **Source** `docs/design/handoff/canvas/boards/WebKeluar.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebKeluar`, no child routes (the confirmation is a side panel; the signed-out card replaces the main column in place, the side nav stays) · **Widget** `WebKeluarScreen` in `lib/screens/lengkap/web_keluar.dart`
- **Purpose** Bendahara Jemaat on the laptop. Same as Keluar; the confirmation is a side panel beside the account column instead of a sheet. P01, P04.
- **Shell** Web side nav as WebLihatTransaksi; active item **Pengaturan**. No `jabatanKosong`: footer always Meiske L.
- **Layout**
  - **Akun view** (states `akun`, `tanya`):
    1. Title block: breadcrumb "Pengaturan"; h1 "Akun".
    2. Row: wrap, gap 24, aligned to the top.
       a. Account column (flex 999 1 420, max-width 560, min-width 0, column gap 16): profile card, sessions card and sentence exactly as Keluar 2a–2c (web body 15). Then, only in state `akun`: button "Keluar dari perangkat ini": min-height 46, padding 0 20, radius 12, 1.5 `tinta` line, `permukaan`, `tinta` 15/700, left-aligned (not full width).
       b. Confirmation panel (state `tanya` only): flex 1 1 320, max-width 420, min-width 0, `permukaan`, 1.5 `tinta` line (GarisStatus `terpilih`), radius 14, padding 20, column gap 12, enters with `muncul` 300 ms. Same title, sentence, "Keluar" and "Kembali" buttons as the Keluar sheet. At 1440 and 860 it sits to the right of the account column.
  - **Keluar view** (state `keluar`): main holds a centring box (flex 1, centred both ways, padding 40/0) with a card: width 100 %, max-width 440, `permukaan`, 1 px `garis`, radius 18, padding clamp(24, 4vw, 40), column gap 20: h1 "Anda sudah keluar" 24/700 line-height 1.2, 6 below; 15 `tinta2` sentence as Keluar; "Masuk" link button as Keluar (`laut`). No breadcrumb. The side nav stays visible.
- **Components** Tombol, side panel in place of LembarBawah (web rule), badge "Sedang dipakai". Shared: web side nav.
- **Internal views and states** Initial `{ st: 'akun' }`; states `akun` (button visible), `tanya` (button hidden, panel visible), `keluar` (centred card).
- **Tweaks** none.
- **Interactions** "Keluar dari perangkat ini" → `st = 'tanya'`. "Kembali" → `st = 'akun'`. "Keluar" → `st = 'keluar'` (in place, no route change). No timers, no typed input.
- **Motion** Confirmation panel `muncul` 300 ms on open; "Kembali" removes it at once (no exit motion). No motion on the signed-out card. Keyframes `isi`, `titik` declared but unused.
- **Links out** Breadcrumb "Pengaturan" → `/WebPengaturan`, up link. "Ganti nomor ponsel" → `/WebAkunSaya`, push. "Sesi di perangkat lain" → `/WebSerahTerima`, push. "Masuk" → `/WebMasuk`, go. Side nav. **Inbound** WebPengaturan ("Akun dan keluar"), PetaLayar.
- **Mock data** Same as Keluar.
- **Prototype-only** none. Keadaan panel: no tweaks.
- **Acceptance checks**
  1. `/WebKeluar` at 1440 → nav "Pengaturan" active; breadcrumb "Pengaturan"; h1 "Akun"; button "Keluar dari perangkat ini" under the sentence.
  2. Click it → the button disappears; a `tinta`-edged panel "Keluar dari perangkat ini?" fades in to the right.
  3. "Kembali" → panel gone, button back.
  4. "Keluar" → main shows the centred card "Anda sudah keluar"; side nav still shown.
  5. "Masuk" → `/WebMasuk`.
  6. "Ganti nomor ponsel" → `/WebAkunSaya`; "Sesi di perangkat lain" → `/WebSerahTerima`; breadcrumb → `/WebPengaturan`.
  7. At 860 px → "Menu" toggle; account column and panel still side by side (420 + 24 + 320 fits).
- **Notes** The signed-out view keeps the side nav with "Meiske L. · Bendahara" visible; keep the board, flag for design. The panel writes 1 px `garis` then 1.5 `tinta` (the later wins). Card radius written 14 then 18: 18 wins (off-token). "Kembali" `tinta` text as on the phone.
