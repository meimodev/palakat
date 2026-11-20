# Screens 02: Awal, WebAwal, Koreksi, WebKoreksi, WebBeranda, WebTransaksi

These six boards carry the Bendahara Jemaat from set-up into daily work, on phone and laptop. **Awal** (phone) and **WebAwal** (laptop) are the set-up checklist of Jemaat Karunia: six steps, the verification of the Bendahara's authority (phone only), and the split of the opening balance (Saldo awal pencatatan) into peruntukan, booked as No. Bukti OPN-2026-0001. Their "Mulai mencatat" leads into the app: Awal → `/Main`, WebAwal → `/WebBeranda`. **WebBeranda** is the laptop home: one combined Saldo buku, month figures, "Perlu tindakan" and the Kas & Bank position; its quick actions open **WebTransaksi**, the laptop transaction list with a detail side panel where a Draf is booked and every status (Draf, Dibukukan, Dibalik, Dibatalkan) can be inspected. From WebTransaksi (and from the phone Beranda `/Main`) the Bendahara opens one posted transaction, BKU-2026-0139 "Konsumsi rapat majelis", in **WebKoreksi** (laptop) or **Koreksi** (phone): record an approval made outside the app, correct it with a reversal (pembalikan) plus an optional correcting transaction, or, when the month is already closed, record a Kejadian setelah tutup buku. The four laptop boards share the web side nav. All figures are mock constants; nothing is saved beyond the running session.

Shared notes for this file:

- **Web side nav** (shared shell `shell/`, used by WebAwal, WebKoreksi, WebBeranda, WebTransaksi): `nav` column `flex 1 1 220px`, padding 24 × 16, `permukaan`, right edge 1 `garis`, column gap 20. Top: logo row (padding 0 8, gap 10): the mark (26 × 26 SVG from the board: dashed `laut` rounded square, right half filled `laut`), then "palakat" 18/700 line-height 1.1 and "Jemaat Karunia" 13 `tinta3`. Items, exactly in this order: **Beranda · Transaksi · Uang Muka dan Titipan · Rekonsiliasi · Bulan dan tutup buku · Laporan · Pengaturan** → `/WebBeranda`, `/WebTransaksi`, `/WebKewajiban`, `/WebRekonsiliasi`, `/WebTutupBuku`, `/WebPaketLaporan`, `/WebPengaturan` (all `go`; the board's own active item is kind self and does nothing, `navigation.md` quick reference). Item: min-height 44, padding 0 12, radius 10, weight 600; active = `tinta` field with `permukaan` text, others transparent with `tinta` text. Footer (margin-top auto, padding 12 8 0, top edge 1 `garis`, 13 `tinta2`): "**Meiske L.** · Bendahara" / "Wewenang Bendahara aktif" (name in `tinta`); when `jabatanKosong` is on (boards that have the switch): "**Yanti Sumual** · Operator" / "Menjalankan jabatan kosong Bendahara Jemaat". At 860 px wide and below (`@media (max-width: 860px)`, 860 included) the nav becomes the full-width top bar with the "Menu" / "Tutup menu" toggle; geometry in `navigation.md` 1.3 (identical `.pn` CSS on all four boards).
- **TombolBersyarat colours on these boards**: unmet = `garis` field with `tinta3` text (the component README says `tinta2`); met = `laut`/`diLaut`, except Koreksi's kejadian button (`tinta`/`permukaan`). Board wins.
- **Nothing animates out** (`motion.md`, rule 2 and "Screen change and page transitions"): views, sheets and cards vanish at once, and Back/pop is instant. The page underneath does not replay its entrance, although the board, which remounts it, does.
- **Web main column**: `flex 999 1 560px`, padding 28 top, `clamp(16, 3vw, 40)` sides, 40 bottom; column gap differs per board (given in each section). Page background `kertas`, body `isiWeb` (15, line-height 1.45).
- **Phone boards** are 390 × 844, background `kertas`, body `isi` (16, line-height 1.4).
- **Text links** (`<a>` without `text-decoration: none`): `laut`, underlined, `lautTua` while pressed/hovered. Focus: 2 px `laut` outline, 2 px offset.
- **Rupiah** always via `rp()`: `rp(-750000)` → `−Rp750.000`.
- **Board-level state survives child routes.** For Awal and Koreksi the board's state object (and any running timer) belongs to the board, not to one view: hold it in a `ChangeNotifier` created by a `ShellRoute` (or equivalent) around `/<Stem>` and its child routes, and dispose it (cancelling timers) only when the board is left for another stem.
- **jabatanKosong banner (web)**, used by WebKoreksi, WebBeranda, WebTransaksi: first child of `main`, `role=status` (live region), `tinta` field, radius 14, padding 12 × 16, 14 px: "**Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15.**" then, in `diTinta2`, " Setiap tindakan dicatat sebagai dijalankan oleh Operator Yanti Sumual." Bold part in `permukaan`. Component: PitaJabatanKosong (web form).

---

### Awal — 3 · Pengaturan awal dan saldo awal

- **Source** `docs/design/handoff/canvas/boards/Awal.dc.html` · page Ponsel (`ponsel`) · form Phone 390×844 · interactive yes
- **Route** `/Awal` (view `langkah`) plus child routes `/Awal/tunjuk` (Penunjukan Bendahara) and `/Awal/saldo` (Saldo awal pencatatan) · **Widget** `AwalScreen` in `lib/screens/ponsel/awal.dart`
- **Purpose** Bendahara Jemaat (Meiske Lumentut), journey "Bendahara Jemaat" step 1: before any finance action the church must finish six set-up steps. Shows that authority comes only from a verified church decision (Petugas verifikasi checks the BPMJ letter; cf. P07, where the same Petugas verifikasi handles the Bendahara's recovery), that the opening balance is not Pendapatan and must be split exactly per Kas/Bank, that empty is not Rp0 (Foundations principle 4, BatangPembagian), and that "Persetujuan format laporan" is still due before the first month close (D14: printed pages carry only one line recording that approval).
- **Shell** none on `/Awal` (no tab bar, no header; a logo row instead). `/Awal/tunjuk` and `/Awal/saldo`: phone header with back (44 × 44 button, chevron-left 22 px, `aria-label` "Kembali") + bottom action bar. Inside the phone device frame on wide windows.
- **Layout**

  **View `langkah` (`/Awal`)** — scroll column, padding 24 top / 20 sides / 28 bottom, gap 18; enters with `pudar` 200 ms.
  1. Logo row (gap 10): mark 26 × 26 (board SVG), word "palakat" 17/700.
  2. Title block: h1 "Pengaturan awal Jemaat" 24/700 line-height 1.2 (off-token 24), margin-bottom 4; under it 15 `tinta2` "Jemaat Karunia · {selesaiN} dari 6 langkah selesai" (`selesaiN` = number of steps in state `ok`: 3 at start).
  3. Text link "Isi identitas, Kas/Bank, peruntukan dan Lingkup", 15/700, min-height 44 → AwalIsian.
  4. Status block, one of:
     - **Not ready** (`!opn`): line `draf` (1.5 dashed `putus`), radius 14, padding 14 × 16, 14 `tinta2`: "**Belum ada tindakan keuangan yang tersedia.**" (bold in `tinta`) followed by `alasan`: wewenang `belum` → "Kirim surat penunjukan Bendahara untuk diverifikasi."; `tunggu` → "Menunggu Petugas verifikasi memeriksa penunjukan Bendahara."; `aktif` → "Tinggal satu langkah: bukukan saldo awal pencatatan."
     - **Ready** (`opn`): `tinta` field, radius 14, padding 16, column gap 10, enters with `muncul` 300 ms. "Jemaat siap mencatat." 700 `permukaan`; 14 `diTinta2` "Pencatatan dimulai 15 September 2026. Persetujuan format laporan masih perlu dicatat sebelum tutup buku pertama."; link-button "Mulai mencatat": min-height 48, radius 12, `permukaan` field, `tinta` text 700, centred → `/Main`.
  5. Steps card: `permukaan`, 1 `garis` edge, radius 16, padding 0 × 16. Six rows; each row is a button, full width, min-height 72, padding 10 × 0, gap 14, top divider 1 `garis` from the 2nd row on; opacity stays 1 even when disabled.
     - Left: circle 34 × 34, mono 15/600, content = step number, or "✓" when done. Circle look per step state: `ok` = `laut` field, `diLaut` "✓"; `kini` = `tinta` field, `permukaan` number; `tunggu` = transparent, 1.5 dashed `tinta` edge, `tinta` number; `kunci` and `nanti` = transparent, 1.5 dashed `putus` edge, `tinta3` number.
     - Middle: title 15/600 (`tinta3` when `kunci`, else `tinta`); subtitle 13, `laut` weight 700 when `kini`, else `tinta3` weight 400.
     - Right: chevron-right 18 px `tinta3` only when the row can be opened.
     - Rows (title · subtitle · state):
       1. "Identitas Jemaat" · "WITA · tahun buku mulai 1 Januari" · ok
       2. "Kas/Bank, peruntukan, Lingkup" · "3 Kas/Bank · 3 peruntukan · 4 Lingkup" · ok
       3. "Mata Anggaran" · "Versi 2026.1 diterbitkan · berlaku mulai September 2026" · ok
       4. "Penunjukan Bendahara" · wewenang `belum`: "Giliran Anda: kirim surat penunjukan" (kini) / `tunggu`: "Menunggu verifikasi wewenang · Petugas verifikasi" (tunggu) / `aktif`: "Wewenang Bendahara aktif" (ok)
       5. "Saldo awal pencatatan" · `opn`: "Dibukukan · OPN-2026-0001" (ok) / else `aktif`: "Giliran Anda: bagi saldo ke peruntukan" (kini) / else "Terbuka setelah wewenang Bendahara aktif" (kunci)
       6. "Persetujuan format laporan" · "Pimpinan Jemaat yang berwenang · wajib sebelum tutup buku pertama" · nanti

  **View `tunjuk` (`/Awal/tunjuk`)** — enters with `masuk` 280 ms.
  1. Header row (padding 14 12 8, gap 8): back button → `/Awal`; h1 "Penunjukan Bendahara" `judulLayar` (18/700).
  2. Scroll body (padding 8 20 20, gap 18):
     - Status block, centred column, gap 12, padding 12 0 4: an 88 × 88 icon (see Motion), then status title 18/700 centred (`role=status`, live region) and 14 `tinta2` centred text. Titles/texts: `belum` "Belum dikirim" / "Kirim surat penunjukan dari BPMJ untuk diverifikasi."; `tunggu` "Menunggu verifikasi wewenang" / "Petugas verifikasi sedang memeriksa surat penunjukan. Sampai selesai, belum ada tindakan keuangan yang tersedia."; `aktif` "Wewenang Bendahara aktif" / "Anda sekarang dapat mencatat, membukukan dan menutup buku untuk Jemaat Karunia."
     - Icons: `belum` circle r 38, stroke 3 `putus`, dash 5 6, no fill; `tunggu` same circle in `tinta`, rotating; `aktif` `laut` filled disc r 38 with 3 px `laut` ring and a `diLaut` check (path `M29 45l10 10 20-21`, stroke 5, round caps/joins).
     - Facts card: `permukaan`, 1 `garis`, radius 14, padding 4 × 16. Rows (padding 12 × 0, gap 16, divider 1 `garis` from row 2): key 14 `tinta2` left, value 14/600 right-aligned: "Yang ditunjuk" · "Meiske Lumentut"; "Yang menunjuk" · "BPMJ Jemaat Karunia"; "Surat penunjukan" · "SK-BPMJ-04-2026.pdf · Terlampir"; "Diverifikasi oleh" · `aktif` ? "Petugas verifikasi · 15/09/2026" : "Belum diverifikasi".
     - Caption 13 `tinta3`: "Akses teknis ke aplikasi saja tidak memberi wewenang Bendahara. Wewenang hanya berasal dari keputusan Jemaat yang sudah diverifikasi."
  3. Bottom bar (`permukaan`, top 1 `garis`, padding 12 20 22): `belum` → primary button "Kirim untuk diverifikasi" (full width, height 52, radius 14, `laut`, `diLaut` 700, centred); `tunggu` → centred text 14 `tinta2`, min-height 52: "Menunggu Petugas verifikasi. Tidak ada yang perlu Anda lakukan."; `aktif` → primary button "Lanjut ke saldo awal pencatatan" (same look, enters with `muncul` 300 ms).

  **View `saldo` (`/Awal/saldo`)** — enters with `masuk` 280 ms.
  1. Header row: back button → `/Awal`; title column: h1 "Saldo awal pencatatan" 18/700, 13 `tinta2` "Per 15 September 2026, tanggal mulai pencatatan".
  2. Scroll body (padding 8 20 20, gap 18). While `!opn`, a column (gap 18) of:
     - Kas block: 14 `tinta2` "Kas · jumlah terverifikasi"; mono 34/500, letter-spacing −1 "Rp3.200.000"; 13 `tinta3` "Sumber: berita acara hitung kas 14/09/2026 · Terlampir".
     - Split block (gap 10): "Bagi ke peruntukan" 15/700; **BatangPembagian** bar: height 18, radius 9, 1.5 dashed `putus` edge (inside the box), clip; three segments left to right, widths animate (see Motion): Umum Jemaat `tinta`, Diakonia `laut`, Pembangunan literal #86B5B8. Segment width = clamp(0–100 %, value ÷ max(3.200.000, total entered)). Under the bar a row, space-between, baseline: label 14/700 and figure mono 18/600, both in `sisaFg`: label "Pas dengan Kas" (`laut`) when total = Kas and no row empty; else "Lebih dari Kas" when total > Kas; else "Sisa belum dibagi". Figure `rp(|Kas − total|)` (never signed). Colour: pas → `laut`; not pas and difference 0 → `tinta`; else `bata`.
     - Rows card: `permukaan`, 1 `garis`, radius 14, padding 0 × 16; three rows (padding 12 × 0, divider from row 2; the swatch–label–field line is centred, gap 10): swatch 12 × 12 radius 3 (segment colour), label 15/600 (Umum Jemaat / Diakonia / Pembangunan, tied to the field), and an amount field 150 wide: mono, 1.5 solid `tinta` underline, "Rp" 14 `tinta3`, input 17/500 right-aligned, min-height 44, placeholder "—", numeric keyboard (IsianJumlah, phone variant). When a row is empty, below it (margin-top 8, space-between): 13/600 `bata` "Belum diisi. Kosong bukan Rp0." and buttons (gap 8, min-height 44, padding 0 12, radius 10, 14/700): "Isi Rp0" (`permukaan`, 1.5 `garisTegas` edge) and, only while the difference is positive, "Isi sisa" (`tinta` field, `permukaan` text).
     - Facts, 14 `tinta2`, gap 4: "Bank BNI ··4821 · Rp24.000.000 · sudah dibagi" / "Bank SulutGo ··1107 · Rp5.100.000 · sudah dibagi" / "Uang muka dan titipan yang masih berjalan: tidak ada".
     - Caption 13 `tinta3`: "Saldo awal bukan Pendapatan. Jumlah per peruntukan harus sama persis dengan tiap Kas/Bank, termasuk yang Rp0."
     When `opn`, instead:
     - OPN card: line `terpilih` (1.5 `tinta`), `permukaan`, radius 16, padding 18, gap 8, clip. Ink-sweep overlay `laut` over the whole card. Top row space-between: badge "Dibukukan" (LencanaStatus: `tinta` field, `permukaan` text, 13/700, radius 6, padding 4 × 10) and stamp "No. Bukti OPN-2026-0001" (mono 14/600 `laut`, 2 px `laut` edge, radius 8, padding 4 × 10, ends rotated −3°). Then 14 `tinta2` "Saldo awal pencatatan · semua Kas/Bank" (margin-top 6); mono 30/500 "Rp32.300.000"; 13 `tinta3` "Seri OPN · bukan Pendapatan · menjadi final setelah September 2026 ditutup".
     - Result card (`permukaan`, 1 `garis`, radius 14, padding 4 × 16, `muncul` 300 ms after 600 ms): rows padding 11 × 0, key 14 `tinta2`, value mono 14/500: "Kas" · "Rp3.200.000"; "Bank BNI ··4821" · "Rp24.000.000"; "Bank SulutGo ··1107" · "Rp5.100.000".
  3. Bottom bar (`permukaan`, top 1 `garis`, padding 12 20 22, gap 8): not pas and `!opn` → 14 `tinta2` "Tidak dapat dibukukan: {alasan}" where alasan = "jumlah per peruntukan belum sama dengan Kas." when the difference ≠ 0, else "masih ada peruntukan yang belum diisi."; pas and `!opn` → primary button "Periksa dan bukukan saldo awal" (height 52, radius 14, `laut`, `diLaut` 700, `muncul` 300 ms); `opn` → secondary button "Kembali ke pengaturan awal" (height 52, radius 14, 1.5 `tinta` edge, `permukaan`, 700).
- **Components** Tahapan-like step list (steps card; not the chip form of Tahapan, a vertical list), LencanaStatus (Dibukukan), BatangPembagian (split bar + remainder), IsianJumlah (three amount fields, phone variant with 1.5 underline), Tombol (primary/secondary), Penolakan-style sentence in the bottom bar. Repeated pattern: phone header with back; key–value facts card; bottom action bar.
- **Internal views and states** Initial state `{ screen: 'langkah', wewenang: 'belum', opn: false, bagi: { umum: '2000000', diak: '700000', bang: '' } }`, constant KAS = 3200000.
  - `langkah` (`/Awal`): not-ready box (3 variants by wewenang) or ready box (`opn`).
  - `tunjuk` (`/Awal/tunjuk`), reached from step row 4 (always openable: kini, tunggu or ok): three sub-states `belum`, `tunggu`, `aktif`.
  - `saldo` (`/Awal/saldo`), reached from step row 5 only when it is `kini` (wewenang `aktif`) or `ok` (`opn`): sub-states split form (not pas / pas) and booked (`opn`).
  - Deep link to `/Awal/saldo` while wewenang ≠ `aktif`: redirect to `/Awal` (the board never allows it).
- **Tweaks** none (no `data-props` tweaks). Keadaan panel: global switches only.
- **Interactions**
  - Step row tap (`buka`): opens the row's view only if it has a target (`tunjuk` for row 4, `saldo` for row 5) and its state is `kini`, `tunggu` or `ok`; rows 1–3 and 6 and a `kunci` row 5 are disabled buttons with no effect → `push('/Awal/tunjuk')` / `push('/Awal/saldo')`.
  - Back button (both child views) and "Kembali ke pengaturan awal" (`keLangkah`) → back to `/Awal` (`pop`, or `go('/Awal')` when nothing to pop).
  - "Lanjut ke saldo awal pencatatan" (`keLangkah`) → `go('/Awal')` (to the step list, **not** to saldo; see Notes).
  - "Kirim untuk diverifikasi" (`kirim`): wewenang → `tunggu` at once; cancels any earlier timer; starts a 2800 ms timer that sets wewenang → `aktif`. The timer fakes the Petugas verifikasi acting on another device. It keeps running if the person goes back to `/Awal`; cancel only when the board is left.
  - Amount field change (`b.on`): keep digits only, remove leading zeros (a lone "0" stays), cut to 11 digits; store the raw digits; display with dot thousands separators ("2000000" → "2.000.000"); empty stays empty (shows "—"). Implement as a `TextInputFormatter` with the caret kept at the end. Every keystroke recomputes total, difference, bar and button.
  - "Isi Rp0" (`b.nol`): that row = "0".
  - "Isi sisa" (`b.isiSisa`): that row = max(0, difference) (only visible while difference > 0).
  - "Periksa dan bukukan saldo awal" (`bukukan`): `opn` → true. No further check in the board (the button only exists while pas). Not undoable.
  - "Mulai mencatat" → `go('/Main')`.
- **Motion**
  - `/Awal` view: `pudar` 200 ms (opacity 0→1, default ease) when the route is built. The board replays it on every return from a child view; the prototype does not (shared note "Nothing animates out").
  - `/Awal/tunjuk`, `/Awal/saldo`: `masuk` 280 ms (= `pindahLayar`), translateX 24→0 + fade, curve `Cubic(0.2, 0.8, 0.2, 1)`. Back (arrow, `keLangkah` buttons, system) is instant: no reverse slide.
  - Ready box on `/Awal`, "Lanjut ke saldo awal pencatatan" button, "Periksa dan bukukan saldo awal" button: `muncul` 300 ms (translateY 8→0 + fade, ease) each time they appear.
  - Waiting icon: `putar`, 360° every 6 s, linear, infinite. Stops under reduce motion.
  - Active icon: `lingkar`, the 3 px ring draws from 12 o'clock clockwise (dash offset 239→0) in 700 ms ease-out; the check fades in (`pudar` 300 ms) after a 500 ms delay. The disc fill shows at once.
  - Split bar segments: width animates 450 ms with `Cubic(0.2, 0.8, 0.2, 1)` (`AnimatedContainer`, BatangPembagian; same duration as `kait`).
  - OPN card = the `tinta` motion: `sapu` overlay (`laut`, scaleX 0→1 from the left edge at opacity 0.2 for the first 65 %, then fades to 0; 700 ms ease-out, ignores pointer); `cap` stamp on "No. Bukti OPN-2026-0001", 550 ms with the standard curve after a 350 ms delay (opacity 0, scale 1.7, rotate −9° → at 55 % opacity 1, scale 0.94, rotate −3° → scale 1, rotate −3°; stays rotated). Result card `muncul` 300 ms after 600 ms. All replay whenever the saldo view is mounted with `opn` true.
  - Timer 2800 ms (fake verification).
- **Links out** "Isi identitas, Kas/Bank, peruntukan dan Lingkup" → `/AwalIsian` (push; AwalIsian's own back "Kembali ke langkah" returns). "Mulai mencatat" → `/Main` (go). **Inbound** AwalIsian, Masuk (manifest), plus PetaLayar and Cakupan (their links are built in JS; `navigation.md` 3.4).
- **Mock data** Jemaat Karunia; Meiske Lumentut; BPMJ Jemaat Karunia; SK-BPMJ-04-2026.pdf; Petugas verifikasi, verified 15/09/2026; start of recording 15 September 2026; first month September 2026; WITA, tahun buku from 1 Januari; 3 Kas/Bank · 3 peruntukan · 4 Lingkup; Mata Anggaran Versi 2026.1 (berlaku mulai September 2026); Kas Rp3.200.000 (berita acara hitung kas 14/09/2026); split Umum Jemaat Rp2.000.000, Diakonia Rp700.000, Pembangunan empty; Bank BNI ··4821 Rp24.000.000; Bank SulutGo ··1107 Rp5.100.000; total Rp32.300.000; No. Bukti OPN-2026-0001 (Seri OPN).
- **Prototype-only** none drawn on screen. The 2800 ms auto-verification stays as a timer (it stands for the Petugas verifikasi on another device); nothing goes to the Keadaan panel.
- **Acceptance checks**
  1. Open `/Awal` → "Jemaat Karunia · 3 dari 6 langkah selesai"; dashed box "Belum ada tindakan keuangan yang tersedia. Kirim surat penunjukan Bendahara untuk diverifikasi."; row 4 has a `tinta` circle "4", subtitle "Giliran Anda: kirim surat penunjukan" in bold `laut`, and the only chevron; row 5 title is `tinta3` with a dashed "5".
  2. Tap rows 1, 3, 5 or 6 → nothing happens. Tap row 4 → `/Awal/tunjuk` slides in from the right; title "Belum dikirim"; "Diverifikasi oleh" reads "Belum diverifikasi".
  3. Tap "Kirim untuk diverifikasi" → immediately "Menunggu verifikasi wewenang", rotating `tinta` dashed circle, bottom text "Menunggu Petugas verifikasi. Tidak ada yang perlu Anda lakukan."; 2800 ms later → "Wewenang Bendahara aktif", `laut` disc with check, "Petugas verifikasi · 15/09/2026", button "Lanjut ke saldo awal pencatatan".
  4. Press "Kirim untuk diverifikasi", go back at once to `/Awal` (row 4 shows dashed `tinta` circle and "Menunggu verifikasi wewenang · Petugas verifikasi"); after 2800 ms row 4 turns ✓, header "4 dari 6", row 5 "Giliran Anda: bagi saldo ke peruntukan" with chevron, and the dashed box reads "Belum ada tindakan keuangan yang tersedia. Tinggal satu langkah: bukukan saldo awal pencatatan."
  5. Open saldo → label "Sisa belum dibagi" and "Rp500.000" in `bata`; Pembangunan shows "—", "Belum diisi. Kosong bukan Rp0.", "Isi Rp0" and "Isi sisa"; bottom bar "Tidak dapat dibukukan: jumlah per peruntukan belum sama dengan Kas."; no book button.
  6. Tap "Isi sisa" → Pembangunan "500.000", bar fills to 100 % in 450 ms, "Pas dengan Kas" / "Rp0" in `laut`, button "Periksa dan bukukan saldo awal" rises in.
  7. Tap "Isi Rp0" instead → "0", label stays "Sisa belum dibagi" / "Rp500.000" `bata`, reason "jumlah per peruntukan belum sama dengan Kas.". Set Umum to "2500000" with Pembangunan empty → "Sisa belum dibagi" / "Rp0" in `tinta`, reason "masih ada peruntukan yang belum diisi.", only "Isi Rp0" offered.
  8. Type "3a000.000x" into Umum (Pembangunan empty) → field shows "3.000.000"; label "Lebih dari Kas" / "Rp500.000" in `bata`; "Isi sisa" hidden. A 12th digit is ignored.
  9. Book when pas → card with ink sweep, stamp "No. Bukti OPN-2026-0001" lands at ~350–900 ms tilted −3°, total "Rp32.300.000", then the three result rows; "Kembali ke pengaturan awal" → `/Awal` shows the dark "Jemaat siap mencatat." box and "5 dari 6"; row 5 "Dibukukan · OPN-2026-0001". "Mulai mencatat" → `/Main`.
  10. With reduce motion on, the waiting circle does not rotate and every entry animation finishes instantly.
- **Notes**
  - Off-token: h1 24 px, word mark 17 px, Kas figure 34 px, step circle 34, status icon 88, row min-height 72, swatch radius 3, bar radius 9, stamp radius 8, small buttons radius 10, amount field width 150. Copy them.
  - IsianJumlah asks for a 2 px `tinta` underline and a grey "0" hint; this board uses 1.5 and the placeholder "—". Use the board's.
  - #86B5B8 (Pembangunan segment and swatch) is the illustration colour CONVENTIONS allows for "Alih peruntukan"; this board uses it too. Keep the literal here as well.
  - The "Lanjut ke saldo awal pencatatan" handler returns to the step list (`keLangkah`), not to the saldo view, although the label says otherwise. Recommended: follow the board (row 5 is now highlighted "Giliran Anda"); flag for the design owner.
  - The book button is hidden, not disabled, while the split is not pas, and the refusal sentence reads "Tidak dapat dibukukan: …" rather than "Tidak dapat dilakukan: …". This departs from TombolBersyarat; follow the board.
  - The `tunggu` circle uses a dashed `tinta` edge (not in the line language); copy it.
  - The `aktif` disc is filled from the start, so the ring draw is barely visible; reproduce as drawn.
  - "Jemaat siap mencatat." uses a full `tinta` field (normally reserved for closed/official); copy it.

---

### WebAwal — Web · Saldo awal pencatatan

- **Source** `docs/design/handoff/canvas/boards/WebAwal.dc.html` · page Web (`web`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebAwal`, no child routes · **Widget** `WebAwalScreen` in `lib/screens/web/web_awal.dart`
- **Purpose** Bendahara Jemaat on the laptop, journey "Bendahara Jemaat" step 1: the same set-up checklist with authority already verified (step 4 done), and the opening balance split for all three Kas/Bank in one table. Same rules as Awal: empty is not Rp0, opening balance is not Pendapatan, each Kas/Bank must be pas before booking with seri OPN; D14 (format approval still due).
- **Shell** web side nav, active **Pengaturan**. Footer fixed "**Meiske L.** · Bendahara / Wewenang Bendahara aktif" (this board has no `jabatanKosong`). Main column gap 22.
- **Layout** (main column, top to bottom)
  1. Title block: h1 "Pengaturan awal Jemaat" `judulHalaman` (26/700); 14 `tinta2` status: `!opn` "Belum ada tindakan keuangan yang tersedia: tinggal satu langkah, bukukan saldo awal pencatatan." / `opn` "Jemaat siap mencatat. Persetujuan format laporan masih perlu dicatat sebelum tutup buku pertama."
  2. Link row (margin-top −8, wrap, gap 0 × 22, 14/600): text link "Identitas Jemaat dan daftar" (min 44 × 44).
  3. Steps grid: `auto-fit, minmax(min(150px, 100%), 1fr)`, gap 10 (six columns at 1440). Each card: column gap 6, padding 12, radius 12; `kini` card = `permukaan` with 1.5 `tinta` edge (`terpilih`), others transparent with 1 `garis` edge. Circle 30 × 30, mono 14/600, same state looks as Awal (`ok` `laut` + "✓" in `diLaut`; `kini` `tinta` + `permukaan` number; `nanti` dashed `putus` + `tinta3` number). Title 14/600 `tinta`; subtitle 13 `tinta3`. Cards are not pressable. Steps: 1 "Identitas Jemaat" · "WITA · tahun buku mulai 1 Januari" (ok); 2 "Kas/Bank, peruntukan, Lingkup" · "3 · 3 · 4" (ok); 3 "Mata Anggaran" · "Versi 2026.1 diterbitkan" (ok); 4 "Penunjukan Bendahara" · "Wewenang Bendahara aktif" (ok); 5 "Saldo awal pencatatan" · `!opn` "Giliran Anda" (kini) / `opn` "Dibukukan · OPN-2026-0001" (ok); 6 "Persetujuan format laporan" · "Wajib sebelum tutup buku pertama" (nanti).
  4. While `!opn`, the split section (column gap 14):
     - Heading row (wrap, baseline, gap 8 × 16): h2 "Saldo awal pencatatan" 19/700; 14 `tinta2` "Per 15 September 2026, tanggal mulai pencatatan · bulan pertama pencatatan: September 2026".
     - Table card: `permukaan`, 1 `garis`, radius 14, horizontal scroll; inner min-width 860. Grid columns `minmax(170px, 1.3fr) repeat(4, minmax(0, 1fr)) minmax(150px, 1.1fr)`, gap 14.
       - Header row (padding 12 × 18, 13/600 `tinta2`): "Kas/Bank" | "Jumlah terverifikasi" | "Umum Jemaat" | "Diakonia" | "Pembangunan" | "Sisa belum dibagi" (all but the first right-aligned).
       - Three rows (padding 10 × 18, top 1 `garis`, centred vertically): name 600 + source 13 `tinta3`; total mono 500 right; three input cells; remainder cell right-aligned: mono 600 `rp(|sisa|)` over 13/600 status, both `laut` when pas, else `bata`. Status: "Pas" / "Lebih dari jumlah terverifikasi" (sum > total) / "Belum habis dibagi" (sum < total) / "Ada sel belum diisi" (sum = total with an empty cell).
       - Input cell: full width, min-height 44, padding 0 × 10, radius 10, mono 15 right-aligned, placeholder "—", numeric; filled = `permukaan` with 1 `garisTegas` edge; empty = `bataLembut` with 1.5 dashed `bata` edge. Semantics label "{peruntukan} di {Kas/Bank}", e.g. "Pembangunan di Kas".
       - Total row (padding 12 × 18, top 1.5 `tinta`, 700): "Jumlah" | mono "Rp32.300.000" (fixed) | the three column sums, mono, right, padding-right 10 | empty.
     - Footer row (wrap, gap 14 × 28, centred): left (`flex 1 1 380px`) 14 `tinta2` "Saldo awal bukan Pendapatan. Jumlah per peruntukan harus sama persis dengan tiap Kas/Bank; sel kosong bukan Rp0, jadi isi `0` bila memang tidak ada. Uang muka dan titipan yang masih berjalan: tidak ada." (the "0" in mono). Right column (align end, gap 6): TombolBersyarat "Periksa dan bukukan saldo awal" (min-height 48, padding 0 × 22, radius 12, 700; met: `laut`/`diLaut`; unmet: `garis`/`tinta3`) and under it 13 `tinta2`: met "Semua Kas/Bank pas. Dibukukan dengan seri OPN." / unmet "Tidak dapat dibukukan: masih ada Kas/Bank yang belum pas."
  5. When `opn`, in place of 4: OPN card, aligned start, min-width min(520, 100 %), line `terpilih` (1.5 `tinta`), `permukaan`, radius 16, padding 22, gap 8, clip: `sapu` overlay; row (space-between, gap 12) badge "Dibukukan" (`tinta` field, `permukaan` 13/700, radius 6, padding 4 × 10) and stamp "No. Bukti OPN-2026-0001" (mono 14/600 `laut`, 2 px `laut` edge, radius 8, padding 4 × 10); 14 `tinta2` "Saldo awal pencatatan · semua Kas/Bank" (margin-top 6); mono 36/500 letter-spacing −1 "Rp32.300.000"; 13 `tinta3` "Seri OPN · bukan Pendapatan · menjadi final setelah September 2026 ditutup"; link-button "Mulai mencatat" (margin-top 10, aligned start, min-height 46, padding 0 × 20, radius 12, `laut`, `diLaut` 700).
- **Components** LencanaStatus (Dibukukan), TombolBersyarat (book button with its reason), IsianJumlah (table-cell variant), Tombol (link-button), Tahapan-like step cards. Repeated pattern: web data grid with header, rows and a 1.5 `tinta` total row.
- **Internal views and states** Initial state `{ opn: false, sel: { kas: ['2000000', '700000', ''], bni: ['20000000', '1500000', '2500000'], bsg: ['5100000', '0', '0'] } }`. Two views in place: split table (`!opn`) and booked card (`opn`). Per-row states: Pas / Lebih / Belum habis / Ada sel belum diisi. Button met/unmet. No way back from `opn` except leaving the page.
- **Tweaks** none. Keadaan panel: global switches only (the global `jabatanKosong` switch has no effect here).
- **Interactions**
  - Input change (`c.on`): digits only, leading zeros removed (a lone "0" stays), cut to **12** digits; stored raw, shown with dot thousands separators; recomputes the row remainder/status, column sums and the button condition on every keystroke.
  - "Periksa dan bukukan saldo awal" (`bukukan`): condition = every Kas/Bank row pas (remainder 0 and no empty cell). Re-checked on press from the latest input; the first press after typing the last digit must work (keep the button enabled for presses and re-check; do not rely on `onPressed: null`). Met → `opn` true. Unmet → nothing (the reason line is already visible).
  - Side nav items → `go`.
- **Motion** `sapu` 700 ms ease-out + `cap` 550 ms after 350 ms (the `tinta` motion, same as Awal, stamp ends at −3°); "Mulai mencatat" `muncul` 300 ms after 800 ms. Both run when the card appears.
- **Links out** "Identitas Jemaat dan daftar" → `/WebAwalIsian` (push; its breadcrumb "Pengaturan awal Jemaat" returns). "Mulai mencatat" → `/WebBeranda` (go). Side nav: Beranda `/WebBeranda`, Transaksi `/WebTransaksi`, Uang Muka dan Titipan `/WebKewajiban`, Rekonsiliasi `/WebRekonsiliasi`, Bulan dan tutup buku `/WebTutupBuku`, Laporan `/WebPaketLaporan`, Pengaturan `/WebPengaturan` (go). **Inbound** WebAwalIsian, WebMasuk, WebPengaturan (manifest), plus PetaLayar (`navigation.md` 3.4).
- **Mock data** Kas Rp3.200.000 "Berita acara hitung kas 14/09/2026" split Rp2.000.000 / Rp700.000 / empty; Bank BNI ··4821 Rp24.000.000 "Rekening koran 14/09/2026" split Rp20.000.000 / Rp1.500.000 / Rp2.500.000; Bank SulutGo ··1107 Rp5.100.000 "Rekening koran 14/09/2026" split Rp5.100.000 / Rp0 / Rp0; Jumlah Rp32.300.000; initial column sums Rp27.100.000 / Rp2.200.000 / Rp2.500.000; OPN-2026-0001; dates 15 September 2026, September 2026; Mata Anggaran Versi 2026.1; Meiske L.
- **Prototype-only** none.
- **Acceptance checks**
  1. Open `/WebAwal` → side nav "Pengaturan" active; step 5 card framed 1.5 `tinta` with `tinta` circle "5" and "Giliran Anda"; status line "Belum ada tindakan keuangan yang tersedia: tinggal satu langkah, bukukan saldo awal pencatatan."
  2. Table at start: Kas row remainder "Rp500.000" and "Belum habis dibagi" in `bata`; Kas × Pembangunan cell dashed `bata` on `bataLembut` showing "—"; BNI and SulutGo "Rp0" `laut` "Pas"; Jumlah row "Rp32.300.000", "Rp27.100.000", "Rp2.200.000", "Rp2.500.000"; button grey with "Tidak dapat dibukukan: masih ada Kas/Bank yang belum pas."
  3. Type "500000" in Kas × Pembangunan → cell shows "500.000" with a solid `garisTegas` edge; Kas row "Rp0" "Pas"; Pembangunan sum "Rp3.000.000"; button turns `laut`; reason "Semua Kas/Bank pas. Dibukukan dengan seri OPN."; the very next press books.
  4. Clear SulutGo × Diakonia ("0" → empty) → that cell turns dashed `bata`; SulutGo "Rp0" `bata` "Ada sel belum diisi"; button grey again.
  5. Type "30000000" in BNI × Umum → BNI "Rp10.000.000" `bata` "Lebih dari jumlah terverifikasi".
  6. Book → table replaced by the OPN card with sweep and tilted stamp; step 5 shows ✓ "Dibukukan · OPN-2026-0001"; status line becomes "Jemaat siap mencatat. …"; "Mulai mencatat" rises in at 800 ms and goes to `/WebBeranda`.
  7. At 860 px wide the side nav collapses behind "Menu"; the table scrolls horizontally inside its card (min-width 860).
- **Notes**
  - Off-token: h2 19 px, OPN figure 36 px, input radius 10, stamp radius 8, step card radius 12 used as card.
  - X03: each saldo-awal input is a 44 px field (its own semantics node), not a 23 px line centred in a 44 px box; the drawn figure does not move.
  - The empty cell uses dashed `bata` on `bataLembut`; the line language has `hambatan` as solid `bata`. Copy the board.
  - Phone limits amounts to 11 digits, web to 12. Keep each.
  - The manifest says `hasSideNav: false` for this board, but it has the side nav. Build the side nav.

---

### Koreksi — 4 · Koreksi, persetujuan, kejadian

- **Source** `docs/design/handoff/canvas/boards/Koreksi.dc.html` · page Ponsel (`ponsel`) · form Phone 390×844 · interactive yes
- **Route** `/Koreksi` (view `detail`, with the approval sheet as an overlay) plus child routes `/Koreksi/pembalikan` (state `koreksi`, the reversal form), `/Koreksi/hasil` (state `hasil`) and `/Koreksi/kejadian` (state `kejadian`) · **Widget** `KoreksiScreen` in `lib/screens/ponsel/koreksi.dart`
- **Purpose** Bendahara Jemaat on the phone, journey step 3: a posted transaction cannot be edited; it is corrected only by a reversal (with or without a correcting transaction), with a required reason (P12, IsianAlasan). An approval given outside the app is recorded as the Bendahara's statement, never an "Approve" (KartuPersetujuan). When the month is closed the correction is refused without offering to reopen (Penolakan) and a Kejadian setelah tutup buku can be recorded, which changes no figure (D11 wording in the banner). The vacancy switch shows the Operator running the post (R04, PitaJabatanKosong phone form).
- **Shell** phone, no tab bar. When `jabatanKosong` is on, a one-line banner is pinned above every view (and above the sheet's scrim). Detail view: phone header with back link to Beranda. Form and kejadian views: phone header with back button. Hasil view: title block without back, with a bottom bar.
- **Layout**

  **Pinned banner** (`jabatanKosong` on): `role=status`, `tinta` field, padding 10 top / 24 sides / 8 bottom, 13 px, line-height 1.3, centred, `permukaan` text: "**Menjalankan jabatan kosong** · Bendahara Jemaat". The views fill the space below it.

  **View `detail` (`/Koreksi`)** — enters with `pudar` 200 ms.
  1. Header (padding 14 12 8, gap 8): back link (44 × 44, chevron-left 22 `tinta`, `aria-label` "Kembali ke Beranda"); h1 mono 17/600 "BKU-2026-0139"; status badge (13/700, radius 6, padding 4 × 10, margin-right 8, 1.5 edge): not reversed "Dibukukan" (`tinta` field, `permukaan` text); reversed "Dibalik" (`permukaan`, `tinta2` text, `tinta3` edge).
  2. Scroll body (padding 8 20 24, gap 16):
     - Amount block: mono 34/500 letter-spacing −1 "−Rp750.000"; 600 "Konsumsi rapat majelis"; 14 `tinta2` "Belanja · {tgl}" (tgl "9 November 2026", or "9 Oktober 2026" when closed).
     - When reversed: secondary button (min-height 48, radius 12, 1.5 `tinta` edge, `permukaan`, padding 0 × 14, 600/14, text left-aligned as every board button without `text-align: center`) "Dibalik oleh No. Bukti BKU-2026-0144 · lihat rangkaian" (number in mono).
     - When closed: `tinta` banner, radius 12, padding 12 × 14, 14 `permukaan`: "**Oktober 2026 sudah ditutup.** Transaksi ini final dan laporan resminya dibekukan."
     - Facts card (`permukaan`, 1 `garis`, radius 14, padding 4 × 16; rows padding 11 × 0, gap 16, divider from row 2; key 14 `tinta2`, value 14/600 right): "Kas/Bank" · "Kas"; "Diambil dari peruntukan" · "Umum Jemaat"; "Lingkup" · "Jemaat"; "Mata Anggaran" · "Belanja 5.02.01.00 Alat tulis dan fotokopi"; "Versi Mata Anggaran" · "2026.1"; "Dibukukan pada" · "09/11/2026 14.12" (closed: "09/10/2026 14.12").
     - Approval card (KartuPersetujuan; radius 14, padding 14 × 16, gap 4): not recorded = transparent with `draf` line (1.5 dashed `putus`); recorded = `permukaan` with `dibukukan` line (1 `garis`). 14 `tinta2` "Persetujuan di luar aplikasi"; 700/15 "Persetujuan belum dicatat" / "Persetujuan sudah dicatat". When recorded (block `muncul` 300 ms, gap 2, margin-top 4): 14 "Pemberi persetujuan: **{apNama}**, {apJabatan}" ("Pemberi persetujuan:" in `tinta2`); 14 `tinta2` "08/11/2026 · cara: {apCara}"; 13 `tinta3` with a 1 dashed `garisTegas` top divider (margin-top 8, padding-top 8): "Dicatat oleh {plk}, 16/11/2026 11.20. Pernyataan Bendahara, bukan persetujuan di dalam aplikasi."; text link "Ganti catatan persetujuan" 14/700, min-height 44. When not recorded and the month is open and not reversed: secondary button "Catat persetujuan" (margin-top 8, min-height 44, radius 12, 1.5 `tinta`, `permukaan`, 700, centred).
     - Document card (`permukaan`, 1 `garis`, radius 14, padding 14 × 16): 14 `tinta2` "Dokumen pendukung"; 600/15 "Terverifikasi (oleh Meiske L.)"; when closed also 13 `tinta3` (margin-top 4) "Status saat tutup buku: Terverifikasi · Status sekarang: Terverifikasi".
     - Kejadian card (only when a kejadian was recorded **and** the month is closed): `terpilih` line (1.5 `tinta`), `permukaan`, radius 14, padding 14 × 16, `muncul` 300 ms. Row: 700/15 "Kejadian setelah tutup buku" + badge "Belum ditindaklanjuti" (13/700, 1.5 `tinta3` edge, `tinta2` text, radius 6, padding 3 × 9). 14 `tinta2` (margin-top 4) the typed explanation. 13 `tinta3` (margin-top 6) "Angka dan laporan resmi Oktober 2026 tidak berubah."
     - Actions when month open and not reversed (column gap 8): button "Koreksi dengan pembalikan" (height 52, radius 14, `tinta` field, `permukaan` 700, centred); link-button "Lampirkan dokumen pendukung" (min-height 48, radius 14, 1.5 `tinta`, `permukaan`, `tinta` 700, centred); caption 13 `tinta3` "Jumlah, tanggal, Kas/Bank, peruntukan, Lingkup dan Mata Anggaran tidak dapat diubah langsung."
     - Actions when month closed (gap 8): 14 `tinta2` "**Tidak dapat dilakukan: koreksi dengan pembalikan.** Oktober 2026 sudah ditutup. Yang masih dapat Anda lakukan:" (bold in `tinta`); button "Catat kejadian" (height 52, radius 14, `tinta` field, `permukaan`); link-button "Lampirkan dokumen pendukung" (as above); caption 13 `tinta3` "Dokumen susulan hanya mengubah Status sekarang, bukan laporan resmi."
     - Month open and reversed: no action block at all.

  **Approval sheet** (overlay on `/Koreksi`, not a route): scrim covering the view area, `tinta` at 45 % opacity, tap = close (`aria-label` "Kembali ke transaksi"), fades in 200 ms. Sheet at the bottom (LembarBawah): `permukaan`, top corners 22, padding 10 20 24, gap 14, rises 280 ms.
  1. Handle 40 × 4, radius 2, `garisTegas`, centred, margin-bottom 4.
  2. h2 "Catat persetujuan" 18/700; 14 `tinta2` "Anda mencatat persetujuan yang diberikan di luar aplikasi."
  3. Field "Pemberi persetujuan" (label 14 `tinta2`, margin-bottom 6; input min-height 48, radius 12, 1 `garisTegas`, `permukaan`, padding 0 × 14), prefilled "Pdt. Lidya Rondonuwu".
  4. Field "Jabatan", prefilled "Ketua BPMJ".
  5. "Cara" (14 `tinta2`, margin-bottom 6) + ChipPilihan: "surat" · "notulen rapat" · "pesan" (min-height 44, padding 0 × 14, margin-right 8, radius 999, 1.5 edge, 600/14; selected `tinta` field + `permukaan` text; unselected `permukaan` + `garisTegas` edge + `tinta` text). Default "notulen rapat".
  6. Row (min-height 44, top 1 `garis`, space-between): 14 `tinta2` "Tanggal persetujuan" · 600/15 "8 November 2026".
  7. Primary button "Catat persetujuan" (height 52, radius 14, `laut`, `diLaut`).
  8. Caption 13 `tinta3` "Catatan yang keliru digantikan catatan baru, tidak diubah."

  **View `koreksi` (`/Koreksi/pembalikan`)** — enters with `masuk` 280 ms.
  1. Header: back button → detail; h1 "Koreksi dengan pembalikan" 18/700.
  2. Scroll body (padding 8 20 20, gap 18):
     - 14 `tinta2` "Transaksi BKU-2026-0139 tetap tercatat. Sebuah pembalikan meniadakan pengaruhnya, lalu transaksi koreksi mencatat yang benar." (number in mono `tinta`).
     - IsianAlasan: label 14 `tinta2` "Alasan" + " · wajib" (`tinta` 700), margin-bottom 6; textarea 2 lines, padding 12 × 14, radius 12, 1 `garisTegas`, `permukaan`, no resize, hint "Contoh: Mata Anggaran keliru".
     - "Yang dibuat" (14 `tinta2`, margin-bottom 8) + two radio cards (full width, row centred, gap 12, min-height 60, margin-bottom 8, padding 10 × 14, radius 14, `permukaan`; selected edge 2 `tinta`, unselected 1 `garisTegas`; radio 20 × 20 circle with 2 `tinta` edge and a 10 px `tinta` dot when selected): "Pembalikan dan transaksi koreksi" / 13 `tinta3` "Keduanya dibukukan bersama, atau tidak sama sekali"; "Pembalikan saja" / "Transaksi ini seharusnya tidak ada". Titles 600/15.
     - Only with "Pembalikan dan transaksi koreksi": "Mata Anggaran pada transaksi koreksi" (14 `tinta2`, margin-bottom 8) + two option cards (full width, row centred, gap 12, no radio circle, min-height 56, margin-bottom 8, padding 8 × 14, radius 12, `permukaan`, same selected/unselected edges): mono 13 `tinta2` "Belanja 5.02.01.00" over 600/15 "Alat tulis dan fotokopi", right 13 `tinta3` "asal"; mono "Belanja 5.04.01.00" over "Konsumsi rapat", no right label. Default selected: the second.
     - Impact card (`permukaan`, 1 `garis`, radius 14, padding 14 × 16, gap 6): 700/15 "Yang ikut terdampak"; 14 `tinta2` lines "Bulan terdampak: November 2026 · Belum ditutup" / "Persetujuan pada transaksi asal tidak ikut pindah ke transaksi koreksi." / "Tidak ada uang muka, titipan atau pencocokan rekening koran yang terkait."
  3. Bottom bar (`permukaan`, top 1 `garis`, padding 12 20 22, gap 8): while the reason is blank, 14 `tinta2` "Isi alasan untuk melanjutkan."; TombolBersyarat (height 52, radius 14, 700, centred; met `laut`/`diLaut`, unmet `garis`/`tinta3`) labelled "Bukukan pembalikan dan koreksi" or, with "Pembalikan saja", "Bukukan pembalikan".

  **View `hasil` (`/Koreksi/hasil`)** — enters with `pudar` 200 ms. RangkaianKoreksi.
  1. Title block (padding 24 20 8): h1 "Koreksi dibukukan" `judulBesar` (22/700); 14 `tinta2` "Dua No. Bukti baru dibukukan bersama sebagai satu rangkaian." (with correction) / "Satu No. Bukti baru dibukukan." (reversal only).
  2. Scroll body (padding 12 20 20), stacked without gap:
     - Card "asal": `permukaan`, 1.5 `tinta3` edge, radius 14, padding 12 × 16. Row: mono 13 `tinta2` "BKU-2026-0139" + badge "Dibalik" (13/700, 1.5 `tinta3`, `tinta2`, radius 6, padding 3 × 9). Row (baseline, margin-top 4): 600/15 `tinta2` "Transaksi asal" + mono 500 `tinta2` "−Rp750.000". 13 `tinta3` "Belanja 5.02.01.00 Alat tulis dan fotokopi · tetap tampil di daftar dan laporan".
     - Connector: 2 px wide `tinta`, 18 high, margin-left 28.
     - Card "pembalikan": `permukaan`, 1.5 `tinta`, radius 14, padding 12 × 16: mono 13 `tinta2` "BKU-2026-0144" + badge "Dibukukan" (`tinta` field, `permukaan` 13/700, radius 6, padding 4 × 10); 600/15 "Pembalikan" + mono 500 "Rp750.000"; 13 `tinta3` "Pembalikan dari No. Bukti BKU-2026-0139 · tidak dapat diubah atau dibalik".
     - With correction only: connector, then card "koreksi" (same look): "BKU-2026-0145" + "Dibukukan"; "Transaksi koreksi" + "−Rp750.000"; 13 `tinta3` "Koreksi dari No. Bukti BKU-2026-0139 · Belanja {maBaru}" (maBaru "5.04.01.00 Konsumsi rapat" or "5.02.01.00 Alat tulis dan fotokopi").
     - Total row (margin-top 18, top 1.5 `tinta`, padding-top 12, space-between, baseline): 700/15 "Pengaruh pada Saldo buku Kas" + mono 20/600 "Rp0" (with correction) / "+Rp750.000" (reversal only).
     - 13 `tinta3` (margin-top 4) "Alasan: {alasan}" exactly as typed.
  3. Bottom bar: secondary button "Kembali ke transaksi asal" (full width, height 52, radius 14, 1.5 `tinta`, `permukaan`).

  **View `kejadian` (`/Koreksi/kejadian`)** — enters with `masuk` 280 ms.
  1. Header: back button → detail; h1 "Catat kejadian" 18/700.
  2. Scroll body (padding 8 20 20, gap 16):
     - `tinta` banner, radius 14, padding 14 × 16, 14 `permukaan`: "Kejadian setelah tutup buku hanya mencatat. Kejadian tidak mengubah angka apa pun, tidak menghapus selisih, dan tidak menghilangkan hambatan tutup buku."
     - Facts card: "Periode" · "Oktober 2026 · Sudah ditutup"; "Transaksi" · mono "BKU-2026-0139".
     - Textarea "Penjelasan" + " · wajib" (`tinta` 700), 3 lines, hint "Apa yang ditemukan, apa adanya".
     - Input "Dampak pada rekonsiliasi", hint "Misalnya: tidak ada" (min-height 48, radius 12, 1 `garisTegas`).
     - Input "Penanggung jawab", hint "Nama dan jabatan".
     - Caption 13 `tinta3` "Penyelesaian keuangan dicatat terpisah dari penjelasan, setelah ada keputusan Jemaat."
  3. Bottom bar: TombolBersyarat "Catat kejadian" (full width, height 52, radius 14; met `tinta` field + `permukaan` text; unmet `garis` + `tinta3`).
- **Components** LencanaStatus (Dibukukan, Dibalik, Belum ditindaklanjuti), KartuPersetujuan, LembarBawah, ChipPilihan (Cara), IsianAlasan (Alasan; Penjelasan as a 3-line variant), TombolBersyarat (both form buttons), Penolakan (closed-month refusal), RangkaianKoreksi (hasil), PitaJabatanKosong (phone, one line), Tombol. Repeated pattern: radio cards (Yang dibuat, Mata Anggaran choice — a two-item stand-in, not PemilihMataAnggaran); key–value facts card.
- **Internal views and states** Initial state `{ screen: 'detail', ap: false, apNama: 'Pdt. Lidya Rondonuwu', apJabatan: 'Ketua BPMJ', apCara: 'notulen rapat', alasan: '', mode: 'koreksi', ma: 1, dibalik: false, kejadian: '', kejadianAda: false }`. Derived: `tutup` = tweak bulanTransaksi is "Sudah ditutup"; month name "Oktober 2026" when closed, else "November 2026".
  - `detail`: open & not reversed (actions: Koreksi + Lampirkan; approval button); open & reversed (link to hasil, no actions, no approval button); closed (banner, refusal, Catat kejadian, Lampirkan, no approval button); closed with kejadian card.
  - `ap`: detail plus the approval sheet.
  - `koreksi` (`/Koreksi/pembalikan`): mode koreksi (MA choice shown) / balik; reason blank / filled.
  - `hasil` (`/Koreksi/hasil`): with correction (3 cards) / reversal only (2 cards).
  - `kejadian` (`/Koreksi/kejadian`): text blank / filled.
  - Deep links: `/Koreksi/hasil` only when `dibalik`; `/Koreksi/kejadian` only when closed; `/Koreksi/pembalikan` only when open and not reversed. Otherwise redirect to `/Koreksi`.
- **Tweaks** (Keadaan panel)
  - `jabatanKosong` (boolean, default off; the global switch): on → pinned banner "Menjalankan jabatan kosong · Bendahara Jemaat" on every view; "Dicatat oleh Yanti Sumual, Operator, 16/11/2026 11.20. …" in the recorded approval. "Terverifikasi (oleh Meiske L.)" does not change: the board's `tukarJk` swap is enabled (`jk && true`) but that text is static markup, not a value it rewrites, and no rewritten value contains "Meiske L.".
  - `bulanTransaksi` (enum "Belum ditutup" · "Sudah ditutup", default "Belum ditutup"): "Sudah ditutup" → dates become "9 Oktober 2026" and "09/10/2026 14.12"; closed banner; extra document line; closed-month refusal with "Catat kejadian"; approval button and Koreksi button gone; month name "Oktober 2026" in all sentences. The impact card in the form keeps "November 2026 · Belum ditutup" (static).
- **Interactions**
  - Back link in detail header → Beranda: `pop` when the previous page is `/Main`, else `go('/Main')`.
  - "Catat persetujuan" (card button, `bukaAp`) → screen `ap` (sheet opens).
  - Scrim tap (`keDetail`) → sheet closes; `ap` unchanged; typed field edits are kept. System/browser Back while the sheet is open does the same and stays on `/Koreksi` (`PopScope`, `navigation.md` 5.1).
  - Pemberi persetujuan / Jabatan fields (`onApNama`, `onApJabatan`): free text, live into state; no validation (blank is accepted).
  - Cara chip (`c.pick`) → `apCara` = that option.
  - Sheet "Catat persetujuan" (`simpanAp`) → sheet closes, `ap` true; card shows the recorded block with the current name, post and cara.
  - "Ganti catatan persetujuan" → `/Persetujuan` (push).
  - "Koreksi dengan pembalikan" (`keKoreksi`) → `push('/Koreksi/pembalikan')`.
  - Alasan (`onAlasan`) → `alasan` = text as typed (kept exactly, shown later as "Alasan: …"). Condition: `alasan.trim()` not empty.
  - "Yang dibuat" cards (`m.pick`) → `mode` = `koreksi` | `balik`. Mata Anggaran cards (`m.pick`) → `ma` = 0 | 1.
  - Book button (`bukukan`): re-checks the condition from the latest text; met → `dibalik` true and `go('/Koreksi/hasil')` (the form leaves the stack, so Back from hasil lands on detail); unmet → nothing. First press after typing must work.
  - "Dibalik oleh No. Bukti BKU-2026-0144 · lihat rangkaian" (`keHasil`) → `push('/Koreksi/hasil')`.
  - "Kembali ke transaksi asal" (`keDetail`) → `/Koreksi` (pop to detail).
  - "Catat kejadian" (detail, `keKejadian`) → `push('/Koreksi/kejadian')`.
  - Penjelasan (`onKejadian`) → `kejadian` = text. Condition `kejadian.trim()` not empty. "Dampak pada rekonsiliasi" and "Penanggung jawab" are uncontrolled (typed text is not stored or shown elsewhere).
  - Kejadian "Catat kejadian" (`simpanKejadian`): re-check; met → `kejadianAda` true, back to `/Koreksi` (pop). The card appears only while the month tweak is "Sudah ditutup".
  - "Lampirkan dokumen pendukung" (both blocks) → `/Kamera` (push).
- **Motion**
  - Detail: `pudar` 200 ms when the route is built (the board replays it on every return to detail; the prototype does not). Form and kejadian: `masuk` 280 ms (`pindahLayar`, standard curve); Back is instant, no reverse slide. Hasil: `pudar` 200 ms.
  - Sheet: scrim `pudar` 200 ms; sheet `naik` 280 ms (translateY 100 % → 0, standard curve). Closing (scrim, Back, "Catat persetujuan"): instant, sheet and scrim vanish at once; the detail underneath does not replay `pudar`.
  - Recorded approval block: `muncul` 300 ms. Kejadian card: `muncul` 300 ms.
  - Hasil chain, replayed each time hasil mounts: "Dibalik" badge `cap` 500 ms after 200 ms, default ease, **this board's variant without rotation** (scale 1.7 → 0.94 at 55 % → 1, opacity 0 → 1); first connector `tali` 250 ms after 500 ms (height 0 → 18); pembalikan card `balik` 500 ms after 700 ms, standard curve (from the top edge: perspective 700, rotateX −90° → 0, opacity 0 → 1); with correction: second connector `tali` 250 ms after 1200 ms, koreksi card `muncul` 400 ms after 1400 ms; total row and "Alasan:" line `muncul` 400 ms after 1700 ms. All elements stay hidden until their delay starts (fill-mode both).
  - No timers.
- **Links out** back arrow (aria "Kembali ke Beranda") → `/Main`; "Ganti catatan persetujuan" → `/Persetujuan` (push); "Lampirkan dokumen pendukung" → `/Kamera` (push, two places). **Inbound** Main ("Koreksi dengan pembalikan") (manifest), plus PetaLayar and Cakupan (JS-built links; `navigation.md` 3.4).
- **Mock data** BKU-2026-0139, −Rp750.000, "Konsumsi rapat majelis", Belanja, Kas, Umum Jemaat, Lingkup Jemaat, Belanja 5.02.01.00 Alat tulis dan fotokopi, Belanja 5.04.01.00 Konsumsi rapat, Versi 2026.1, booked 09/11/2026 14.12 (closed: 09/10/2026 14.12; dates 9 November / 9 Oktober 2026); approver Pdt. Lidya Rondonuwu, Ketua BPMJ, 08/11/2026 (sheet "8 November 2026"), cara surat / notulen rapat / pesan; recorded by Meiske L. (or Yanti Sumual, Operator) 16/11/2026 11.20; document Terverifikasi (oleh Meiske L.); reversal BKU-2026-0144 Rp750.000; correction BKU-2026-0145 −Rp750.000; effect Rp0 / +Rp750.000; months November 2026 (open), Oktober 2026 (closed).
- **Prototype-only** none. The hint "Contoh: Mata Anggaran keliru" is an IsianAlasan sample hint inside a text field, not a "Contoh:" button: keep it on screen.
- **Acceptance checks**
  1. Open `/Koreksi` (defaults) → header "BKU-2026-0139" with `tinta` badge "Dibukukan"; "Belanja · 9 November 2026"; dashed approval card "Persetujuan belum dicatat" with "Catat persetujuan"; buttons "Koreksi dengan pembalikan" and "Lampirkan dokumen pendukung".
  2. Tap "Catat persetujuan" → scrim fades, sheet rises in 280 ms with "Pdt. Lidya Rondonuwu", "Ketua BPMJ", chip "notulen rapat" selected; tap "surat", then the sheet button → sheet closes; card is solid with "Persetujuan sudah dicatat", "08/11/2026 · cara: surat", "Dicatat oleh Meiske L., 16/11/2026 11.20. Pernyataan Bendahara, bukan persetujuan di dalam aplikasi." and the link "Ganti catatan persetujuan".
  3. Open the sheet and tap the scrim → sheet closes; card still dashed "Persetujuan belum dicatat".
  4. Open the form → "Isi alasan untuk melanjutkan." and a grey "Bukukan pembalikan dan koreksi"; pressing does nothing; typing only spaces keeps it grey; typing "Mata Anggaran keliru" turns it `laut` and the first press opens hasil.
  5. Hasil with defaults → "Dua No. Bukti baru dibukukan bersama sebagai satu rangkaian."; three cards appear in sequence (badge stamp ~200 ms, flip ~700 ms, third card ~1400 ms, total ~1700 ms); third card "Koreksi dari No. Bukti BKU-2026-0139 · Belanja 5.04.01.00 Konsumsi rapat"; "Pengaruh pada Saldo buku Kas" "Rp0"; "Alasan: Mata Anggaran keliru". System Back → detail.
  6. Choose "Pembalikan saja" → Mata Anggaran group disappears, button "Bukukan pembalikan"; hasil shows two cards, "Satu No. Bukti baru dibukukan.", "+Rp750.000".
  7. After booking, detail shows badge "Dibalik" (outlined), the button "Dibalik oleh No. Bukti BKU-2026-0144 · lihat rangkaian", no "Koreksi dengan pembalikan", no "Catat persetujuan".
  8. Set bulanTransaksi "Sudah ditutup" → "Belanja · 9 Oktober 2026", "Dibukukan pada 09/10/2026 14.12", banner "Oktober 2026 sudah ditutup. Transaksi ini final dan laporan resminya dibekukan.", document line "Status saat tutup buku: Terverifikasi · Status sekarang: Terverifikasi", refusal "Tidak dapat dilakukan: koreksi dengan pembalikan. Oktober 2026 sudah ditutup. Yang masih dapat Anda lakukan:", button "Catat kejadian".
  9. Catat kejadian → grey button until Penjelasan has non-space text; type "Struk ganda ditemukan" and press → detail shows the framed card "Kejadian setelah tutup buku" / "Belum ditindaklanjuti" / "Struk ganda ditemukan" / "Angka dan laporan resmi Oktober 2026 tidak berubah."; switching the tweak back to "Belum ditutup" hides the card.
  10. Turn `jabatanKosong` on → one-line banner "Menjalankan jabatan kosong · Bendahara Jemaat" on detail, sheet, form, hasil and kejadian; recorded approval reads "Dicatat oleh Yanti Sumual, Operator, 16/11/2026 11.20. …"; document card still "Terverifikasi (oleh Meiske L.)".
- **Notes**
  - Off-token: h1 mono 17, amount 34, total 20; scrim `tinta` at 45 % alpha (board `rgba(19,32,28,.45)`): use `context.warna.tinta.withValues(alpha: .45)`.
  - The closed-month refusal is bold `tinta` here, while Penolakan (and WebKoreksi) use `bata` for "Tidak dapat dilakukan: …". Follow each board.
  - The form shows its reason "Isi alasan untuk melanjutkan." before typing starts and does not use the "Tidak dapat dilakukan: …" sentence (TombolBersyarat says otherwise). Follow the board.
  - The kejadian button has no reason line on the board. Added for rules A02/A03 (rules-checklist 4.1), not on the board: once any of the three fields (Penjelasan, Dampak pada rekonsiliasi, Penanggung jawab) holds text and Penjelasan is blank, TombolBersyarat shows "Tidak dapat dilakukan: Catat kejadian. Penjelasan belum diisi." above the button. The empty form shows none, as on the board.
  - The approval sheet accepts blank name/post; no condition in the board. Keep.
  - The primary actions on detail ("Koreksi dengan pembalikan", "Catat kejadian") use a `tinta` field, not `laut`, and the kejadian save button is `tinta` too. Copy.
  - The `cap` keyframe here has no rotation, unlike Awal/WebAwal/WebTransaksi. `motion.md` has both: this is `cap` variant B (scale only, `.5s .2s`, `ease`); the rotated No. Bukti stamp is variant A.
  - "Catat kejadian" banner text is `permukaan` on `tinta` (board #FFFFFF); Foundations would use `diTinta` for sentences on `tinta`. Use `permukaan` per the CONVENTIONS hex table.

---

### WebKoreksi — Web · Koreksi dengan pembalikan

- **Source** `docs/design/handoff/canvas/boards/WebKoreksi.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebKoreksi`, no child routes (form and result replace each other inside the right column) · **Widget** `WebKoreksiScreen` in `lib/screens/lengkap/web_koreksi.dart`
- **Purpose** Bendahara Jemaat on the laptop, journey step 3: the same correction of BKU-2026-0139 as Koreksi, in a two-column page: the original on the left, the reversal form or the closed-month refusal on the right. Same rules: reason required (P12), approval recorded not given (KartuPersetujuan), no reopening (Penolakan), vacancy banner (R04).
- **Shell** web side nav, active **Transaksi**; footer swaps with `jabatanKosong`. Main column gap 20. Breadcrumb "Transaksi" above the title.
- **Layout**
  1. When `jabatanKosong`: the web vacancy banner (shared notes).
  2. Title block: text link "Transaksi" 14/600; h1 (margin-top 2) mono 26/700 "BKU-2026-0139".
  3. Two columns (wrap, gap 28, top-aligned). **Left** (`flex 1 1 400px`, gap 14):
     - Original card: `permukaan`, 1.5 edge (`tinta`; `tinta3` once reversed), radius 14, padding 18, gap 4. Row (space-between, gap 16): badge 13/700, radius 6, padding 3 × 9, 1.5 edge: "Dibukukan" (`tinta` field, `permukaan`) / after booking "Dibalik oleh No. Bukti BKU-2026-0144" (`permukaan`, `tinta2` text, `tinta3` edge); mono 13 `tinta2` "BKU-2026-0139". Mono 32/500 letter-spacing −1 "−Rp750.000" (margin-top 4); 600 "Konsumsi rapat majelis"; 13 `tinta3` "Kas · diambil dari peruntukan Umum Jemaat · Lingkup Jemaat · {tgl}" (tgl "9 November 2026" / closed "9 Oktober 2026"); 13 `tinta3` "Belanja 5.02.01.00 Alat tulis dan fotokopi · Versi Mata Anggaran 2026.1".
     - When closed: `tinta` banner, radius 14, padding 12 × 16, 14 `permukaan`: "**Oktober 2026 sudah ditutup.** Transaksi ini final dan laporan resminya dibekukan."
     - Approval card (KartuPersetujuan, radius 14, padding 14 × 16, gap 4; dashed `putus` + transparent until recorded, then 1 `garis` + `permukaan`): 14 `tinta2` "Persetujuan di luar aplikasi"; 700 "Persetujuan belum dicatat" / "Persetujuan sudah dicatat". Recorded (only the first line enters with `muncul` 300 ms; the "Dicatat oleh" line shows at once): 14 "Pemberi persetujuan: **Pdt. Lidya Rondonuwu**, Ketua BPMJ · 08/11/2026 · cara: notulen rapat" (lead-in `tinta2`); 13 `tinta3` with 1 dashed `garisTegas` top divider (margin-top 6, padding-top 6) "Dicatat oleh {plk}, 16/11/2026 11.20. Pernyataan Bendahara, bukan persetujuan di dalam aplikasi." Not recorded, month open, not reversed: secondary button "Catat persetujuan" (min-height 46, padding 0 × 20, radius 12, 1.5 `tinta`, `permukaan`, 700, aligned start, margin-top 6).
     - Document card (`permukaan`, 1 `garis`, radius 14, padding 14 × 16): 14 `tinta2` "Dokumen pendukung"; 600 "Terverifikasi (oleh Meiske L.)".
     **Right** (`flex 999 1 480px`, gap 16), one of:
     - **Closed**: column gap 10: 15 px "**Tidak dapat dilakukan: koreksi dengan pembalikan.**" (`bata`) + " Oktober 2026 sudah ditutup. Yang masih dapat Anda lakukan:"; link-buttons (wrap, gap 8): "Catat kejadian" (min-height 46, padding 0 × 20, radius 12, `tinta` field, `permukaan` 700) and "Lampirkan dokumen pendukung" (same size, 1.5 `tinta`, `permukaan`, `tinta`); caption 13 `tinta3` "Dokumen susulan hanya mengubah Status sekarang, bukan laporan resmi."
     - **Form** (open, not booked): h2 "Koreksi dengan pembalikan" 19/700; 14 `tinta2` "Transaksi asal tetap tercatat. Sebuah pembalikan meniadakan pengaruhnya, lalu transaksi koreksi mencatat yang benar."; IsianAlasan "Alasan **· wajib**" (same textarea as Koreksi, hint "Contoh: Mata Anggaran keliru"); "Yang dibuat" (14 `tinta2`, margin-bottom 8) + ChipPilihan pills "Pembalikan dan transaksi koreksi" · "Pembalikan saja" (min-height 44, padding 0 × 14, margin 0 8 8 0, radius 999, 1.5 edge, 600/14; selected `tinta`/`permukaan`, unselected `permukaan` + `garisTegas` edge); only with correction: "Mata Anggaran pada transaksi koreksi" + chips with **radius 12**: "Belanja 5.02.01.00 Alat tulis dan fotokopi · asal" · "Belanja 5.04.01.00 Konsumsi rapat" (default the second); impact card (same three lines as Koreksi; gap 4; title 700); action row (wrap, gap 12): TombolBersyarat (min-height 46, padding 0 × 20, radius 12, 700; met `laut`/`diLaut`, unmet `garis`/`tinta3`) "Bukukan pembalikan dan koreksi" / "Bukukan pembalikan", and while the reason is blank, to its right, 14 `tinta2` "Isi alasan untuk melanjutkan."
     - **Result** (open, booked; RangkaianKoreksi with the left card as the first link): h2 "Koreksi dibukukan" 19/700 + 14 `tinta2` "Dua No. Bukti baru dibukukan bersama sebagai satu rangkaian. Transaksi asal tetap tampil di daftar dan laporan." / "Satu No. Bukti baru dibukukan. Transaksi asal tetap tampil di daftar dan laporan."; chain column: pembalikan card (`permukaan`, 1.5 `tinta`, radius 14, padding 12 × 16): mono 13 `tinta2` "BKU-2026-0144" + badge "Dibukukan" (`tinta`, padding 3 × 9); 600 "Pembalikan" + mono 500 "Rp750.000"; 13 `tinta3` "Pembalikan dari No. Bukti BKU-2026-0139 · tidak dapat diubah atau dibalik"; with correction: connector 2 × 18 `tinta`, margin-left 28 (static), then koreksi card "BKU-2026-0145" / "Dibukukan" / "Transaksi koreksi" / "−Rp750.000" / "Koreksi dari No. Bukti BKU-2026-0139 · Belanja {maBaru}"; total row (top 1.5 `tinta`, padding-top 12, space-between, baseline): 700 "Pengaruh pada Saldo buku Kas" + mono 22/600 "Rp0" / "+Rp750.000"; 13 `tinta3` "Alasan: {alasan}".
- **Components** LencanaStatus, KartuPersetujuan, IsianAlasan, ChipPilihan, TombolBersyarat, Penolakan, RangkaianKoreksi, PitaJabatanKosong (web), Tombol.
- **Internal views and states** Initial state `{ ap: false, alasan: '', mode: 'koreksi', ma: 1, jadi: false }`. Right column: Closed (tweak) / Form (`!tutup && !jadi`) / Result (`!tutup && jadi`). Approval card: not recorded (with or without button) / recorded. No way back from the result except leaving the page.
- **Tweaks** (Keadaan panel)
  - `jabatanKosong` (boolean, default off, global): web vacancy banner at the top of main; side-nav footer "Yanti Sumual · Operator / Menjalankan jabatan kosong Bendahara Jemaat"; "Dicatat oleh Yanti Sumual, Operator, 16/11/2026 11.20. …" in the recorded approval. "Terverifikasi (oleh Meiske L.)" does not change.
  - `bulanTransaksi` ("Belum ditutup" · "Sudah ditutup", default "Belum ditutup"): closed → date "9 Oktober 2026", closed banner under the original, approval button hidden, right column shows only the refusal with "Catat kejadian" and "Lampirkan dokumen pendukung".
- **Interactions**
  - "Catat persetujuan" (`catatAp`) → `ap` true at once (no sheet and no fields on web; fixed approver Pdt. Lidya Rondonuwu, Ketua BPMJ, notulen rapat).
  - Alasan (`onAlasan`) → `alasan` as typed; condition `alasan.trim()` not empty.
  - Mode chips (`c.pick`) → `mode` koreksi | balik. Mata Anggaran chips → `ma` 0 | 1.
  - Book button (`bukukan`): re-check from the latest text; met → `jadi` true (right column switches to the result; left card badge and edge change; approval button disappears); unmet → nothing. First press after typing must work.
  - "Transaksi" breadcrumb → `/WebTransaksi` (`pop` when it is the previous page, else `go`).
  - "Catat kejadian" → `/WebKejadian` (push). "Lampirkan dokumen pendukung" → `/WebDokumen` (push).
  - Side nav → `go`.
- **Motion** Recorded approval: the "Pemberi persetujuan" line `muncul` 300 ms (the "Dicatat oleh" line under it is not animated). Result: pembalikan card `muncul` 400 ms after 200 ms; koreksi card `muncul` 400 ms after 600 ms; total row `muncul` 400 ms after 1000 ms (default ease, hidden until their delay). The h2 block and the "Alasan: …" line are not animated: they show at once, before the cards. No stamp, flip or connector animation on web. The board also declares keyframes `isi` and `titik` but never uses them: build nothing for them. No timers.
- **Links out** "Transaksi" → `/WebTransaksi`; "Catat kejadian" → `/WebKejadian` (push); "Lampirkan dokumen pendukung" → `/WebDokumen` (push); side nav (7 items, go). **Inbound** TabTransaksi, WebTransaksi (manifest), plus PetaLayar (`navigation.md` 3.4).
- **Mock data** as Koreksi: BKU-2026-0139 −Rp750.000 "Konsumsi rapat majelis", Kas, Umum Jemaat, Lingkup Jemaat, 9 November 2026 / 9 Oktober 2026, Belanja 5.02.01.00 Alat tulis dan fotokopi, Versi 2026.1, Belanja 5.04.01.00 Konsumsi rapat; Pdt. Lidya Rondonuwu, Ketua BPMJ, 08/11/2026, notulen rapat; Meiske L. / Yanti Sumual, Operator, 16/11/2026 11.20; vacancy since 16/11/2026 08.15; BKU-2026-0144 Rp750.000; BKU-2026-0145 −Rp750.000; Rp0 / +Rp750.000.
- **Prototype-only** none (the "Contoh: …" text is a field hint; keep it).
- **Acceptance checks**
  1. Open `/WebKoreksi` → side nav "Transaksi" active; breadcrumb "Transaksi"; mono title "BKU-2026-0139"; left card with `tinta` badge "Dibukukan"; right column form with grey "Bukukan pembalikan dan koreksi" and "Isi alasan untuk melanjutkan." to its right.
  2. Press "Catat persetujuan" → card turns solid with "Pemberi persetujuan: Pdt. Lidya Rondonuwu, Ketua BPMJ · 08/11/2026 · cara: notulen rapat" and "Dicatat oleh Meiske L., 16/11/2026 11.20. …"; button gone.
  3. Type "Mata Anggaran keliru", press book (first press) → right column "Koreksi dibukukan" with two cards rising at 200 ms and 600 ms, total "Rp0" at 1000 ms, "Alasan: Mata Anggaran keliru"; left badge "Dibalik oleh No. Bukti BKU-2026-0144" outlined, card edge `tinta3`.
  4. Pick "Pembalikan saja" before booking → Mata Anggaran chips vanish, button "Bukukan pembalikan"; result shows one card, "Satu No. Bukti baru dibukukan. Transaksi asal tetap tampil di daftar dan laporan.", "+Rp750.000".
  5. Pick "Belanja 5.02.01.00 Alat tulis dan fotokopi · asal" → koreksi card reads "Koreksi dari No. Bukti BKU-2026-0139 · Belanja 5.02.01.00 Alat tulis dan fotokopi".
  6. bulanTransaksi "Sudah ditutup" → date "9 Oktober 2026", dark banner under the card, no approval button, right column only "Tidak dapat dilakukan: koreksi dengan pembalikan." in `bata` plus the two link-buttons; "Catat kejadian" → `/WebKejadian`.
  7. `jabatanKosong` on → dark banner "Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15. …" above the breadcrumb; side-nav footer "Yanti Sumual · Operator".
  8. "Transaksi" breadcrumb opened from `/WebTransaksi` returns there with Back history intact.
- **Notes**
  - Off-token: h1 mono 26, amount 32, h2 19, total 22, Mata Anggaran chips radius 12 (the later `border-radius` wins over 999).
  - The closed refusal is `bata` here, `tinta` on the phone. Follow each board.
  - Unlike the phone, web has no "Ganti catatan persetujuan" link, no approval sheet, no in-page kejadian form and no "back to original" button. Do not add them.
  - The form shows its reason before typing starts and words it "Isi alasan untuk melanjutkan." Follow the board.
  - The manifest marks this board `hasSideNav: true` while sibling boards are marked false; all four web boards in this file have the same side nav.

---

### WebBeranda — Web · Beranda

- **Source** `docs/design/handoff/canvas/boards/WebBeranda.dc.html` · page Web (`web`) · form Laptop page (preview 1440×1000) · interactive no
- **Route** `/WebBeranda`, no child routes · **Widget** `WebBerandaScreen` in `lib/screens/web/web_beranda.dart`
- **Purpose** Bendahara Jemaat's laptop home, journey step 2 (daily work) entry point. Shows D03 (one combined Saldo buku for all Kas/Bank, only booked transactions), drafts kept out of the balance (`draf` line), ButirPerhatian levels (Perlu tindakan with a counter, plain "Untuk diketahui"), "not yet known is not zero" ("—", principle 4) and that cash count and bank statement are never summed; D29 (web side bar), Q26 (laptop layout for a desk post); R04 vacancy banner.
- **Shell** web side nav, active **Beranda**; footer swaps with `jabatanKosong`. Main column gap 24.
- **Layout**
  1. When `jabatanKosong`: web vacancy banner.
  2. Header row (wrap, centred, gap 12): h1 "Beranda" 26/700 (`flex 1 1 200px`); month pill link "November 2026 · Belum ditutup" (min-height 44, padding 0 × 16, radius 999, 1 `garisTegas` edge, `permukaan`, 600 `tinta`, no underline).
  3. Link row (margin-top −8, gap 0 × 22, 14/600, each min 44 × 44): "Pemberitahuan" · "Cari dan tanya".
  4. Quick actions (wrap, gap 8; each min-height 44, padding 0 × 18, radius 12, 700, no underline): "+ Pendapatan", "− Belanja", "+ Persembahan" (`laut` field, `diLaut`); "Rekonsiliasi", "Buat laporan sementara" (1.5 `tinta` edge, `permukaan`, `tinta`).
  5. Grid `auto-fit, minmax(min(360px, 100%), 1fr)`, gap 24, top-aligned (two columns at 1440):
     - Left: balance block (gap 6): 14 `tinta2` "Saldo buku semua Kas/Bank"; mono 500, size `clamp(34, 4.4 % of window width, 56)`, letter-spacing −1.5, line-height 1.05 "Rp38.415.000"; 13 `tinta3` "Hanya transaksi yang sudah dibukukan"; `ramai` only: draft pill (aligned start, margin-top 8, 1.5 dashed `putus`, radius 999, padding 6 × 14, 13 `tinta2`) "Rp800.000 · 2 draf · belum masuk saldo" (amount mono).
     - Right: tiles grid `auto-fit, minmax(min(150px, 100%), 1fr)`, gap 12; each tile `permukaan`, 1 `garis`, radius 14, padding 14 × 16: label 13 `tinta2`, value mono 19/500 (margin-top 2), caption 13 `tinta3`. Tiles: "Pendapatan bulan ini" · Rp7.540.000 · "tanpa titipan"; "Belanja bulan ini" · Rp7.940.000 · "tanpa titipan"; "Surplus/Defisit bulan ini" · −Rp400.000 · "hanya yang sudah dibukukan" (`sepi`: all three "Rp0").
  6. Second grid (same columns, gap 24):
     - Left (gap 12): heading row (gap 8): h2 "Perlu tindakan" 17/700 + counter (`bata` field, `diBata` 13/700, radius 999, min-width 22, height 22, padding 0 × 6) showing the number of rows. List card (`permukaan`, 1 `garis`, radius 14, padding 0 × 16): each row is a link (min-height 60, gap 12, top 1 `garis` from row 2, no underline, `tinta`): title 600, subtitle 13, chevron-right 18 `tinta3`. Rows: (1) "Oktober 2026 belum ditutup" · "1 hambatan · bulan berikutnya untuk tutup buku" (subtitle `bata` 700) → WebTutupBuku; `ramai` adds (2) "2 draf belum dibukukan" · "Belum masuk saldo · Rp800.000"; (3) "1 dokumen pendukung wajib, belum ada" · "BKU-2026-0143 · Rp600.000"; (4) "1 Mata Anggaran belum dipilih" · "Draf · Honor pemusik" (subtitles `tinta3` 400) → all WebTransaksi. Under the card: `sepi` → dashed box (1.5 dashed `putus`, radius 14, padding 14 × 16, 14 `tinta2`) "**Belum ada transaksi di November.** Bulan tanpa transaksi belum selesai: tiap Kas/Bank tetap perlu hitung kas atau rekening koran, lalu tutup buku." (bold `tinta`); `ramai` → h2 "Untuk diketahui" 17/700 (margin 8 0 6) and a plain link, 14 `tinta2` underlined (stays `tinta2` on hover: the inline colour beats `a:hover`), "2 uang muka dengan sisa belum dipertanggungjawabkan · Rp1.150.000".
     - Right (gap 12): h2 "Posisi Kas & Bank" 17/700 + " · November 2026" (13/500 `tinta3`). Table card (`permukaan`, 1 `garis`, radius 14, horizontal scroll; table min-width 520, 14 px). Header cells padding 12 × 16, 600 `tinta2`: "Kas/Bank" (left) | "Saldo buku" | "Hasil hitung kas" | "Saldo rekening koran" (right). Body cells padding 12 × 16, top 1 `garis`: Kas · mono "Rp8.420.000" · "— " + 13 "Belum dihitung" + " · " + link 13/700 "Hitung kas" (cell `tinta2`, right) · empty; "Bank BNI ··4821" · "Rp24.615.000" · empty · "— " + 13 "Rekening koran belum diisi"; "Bank SulutGo ··1107" · "Rp5.380.000" · empty · "— Rekening koran belum diisi". Names 600. Caption 13 `tinta3`: "Hasil hitung kas dan saldo rekening koran tidak pernah dijumlahkan. Yang belum ada ditampilkan sebagai “—”, bukan Rp0."
- **Components** ButirPerhatian (Perlu tindakan rows; Untuk diketahui plain), Tombol (quick actions), PitaJabatanKosong (web). Repeated patterns: draft pill (`draf` line), figure tiles, counter badge, Kas & Bank table.
- **Internal views and states** No state object. Two content states from the `bulan` tweak (ramai / sepi) × vacancy on/off.
- **Tweaks** (Keadaan panel)
  - `jabatanKosong` (boolean, default off, global): vacancy banner; side-nav footer swap. Nothing else changes (the board's name swap is disabled).
  - `bulan` ("ramai" · "sepi", default "ramai"): `sepi` → draft pill hidden; tiles all "Rp0"; Perlu tindakan has only the October row and counter "1"; dashed "Belum ada transaksi di November." box shown; "Untuk diketahui" hidden. Saldo buku "Rp38.415.000" and the Kas & Bank table do not change.
- **Interactions** none in the logic class; every control is a link (below).
- **Motion** none.
- **Links out**
  - "November 2026 · Belum ditutup" → `/WebPilihBulan` (push).
  - "Pemberitahuan" → `/WebPemberitahuan` (push); "Cari dan tanya" → `/WebCari` (push).
  - "+ Pendapatan", "− Belanja", "+ Persembahan" → `/WebTransaksi` (go; a side-nav page).
  - "Rekonsiliasi" → `/WebRekonsiliasi` (go); "Buat laporan sementara" → `/WebLaporan` (push).
  - Perlu tindakan: "Oktober 2026 belum ditutup" → `/WebTutupBuku` (go); the three other rows → `/WebTransaksi` (go).
  - "2 uang muka dengan sisa belum dipertanggungjawabkan · Rp1.150.000" → `/WebKewajiban` (go).
  - "Hitung kas" → `/WebHitungKas` (push).
  - Side nav (7 items, go).
  - **Inbound** (84 boards; the manifest lists AIBulan instead of PetaLayar, but AIBulan's side-nav links are dead and PetaLayar's are JS-built, `navigation.md` 3.2): PetaLayar, TabBeranda, TabCatat, TabTransaksi, WebAI, WebAIFoto, WebAIMataAnggaran, WebAkunSaya, WebAlihPeruntukan, WebAlurDokumen, WebAlurJabatanKosong, WebAlurKeluarga, WebAlurMasuk, WebAlurPengembalian, WebAlurPulihkan, WebAlurSurat, WebAlurUnit, WebAlurWarta, WebAwal, WebAwalIsian, WebBagi, WebBantuanAI, WebBerandaJabatan, WebBukaNama, WebBukti, WebCari, WebCariOrang, WebCatat, WebDataAnggota, WebDataGanda, WebDokumen, WebDokumenGereja, WebDraf, WebEkspor, WebExcel, WebExcelTerbatas, WebFormatLaporan, WebHitungKas, WebImpor, WebImporBuku, WebJabatanKosong, WebKasUnit, WebKasus, WebKasusBaru, WebKeadaanUmum, WebKejadian, WebKeluar, WebKesiapan, WebKewajiban, WebKoreksi, WebKotakMasuk, WebLaporan, WebLaporanLintas, WebLihatDokumen, WebLihatTransaksi, WebMasuk, WebMataAnggaran, WebMemuat, WebPaketLaporan, WebPemberitahuan, WebPemeriksa, WebPemulihan, WebPengaturan, WebPengembalian, WebPengumuman, WebPenugasan, WebPermohonanSurat, WebPersembahan, WebPersembahanBernama, WebPersetujuan, WebPilihBulan, WebRekonIsi, WebRekonsiliasi, WebSambungan, WebSelesaikanUnit, WebSerahTerima, WebTanggal, WebTerbitDokumen, WebTransaksi, WebTutupBuku, WebUbahPengaturan, WebUnggah, WebWartaArsip, WebWartaEditor (mostly via the side nav).
- **Mock data** Saldo buku Rp38.415.000 = Kas Rp8.420.000 + Bank BNI ··4821 Rp24.615.000 + Bank SulutGo ··1107 Rp5.380.000; drafts Rp800.000 (2); Pendapatan Rp7.540.000; Belanja Rp7.940.000; Surplus/Defisit −Rp400.000; Oktober 2026 open with 1 hambatan; BKU-2026-0143 Rp600.000; Draf "Honor pemusik"; 2 uang muka Rp1.150.000; month November 2026 · Belum ditutup; Meiske L. / Yanti Sumual (Operator, since 16/11/2026 08.15).
- **Prototype-only** none.
- **Acceptance checks**
  1. Open `/WebBeranda` at 1440 → side nav "Beranda" active; balance "Rp38.415.000" at 56 px; dashed pill "Rp800.000 · 2 draf · belum masuk saldo"; tiles "Rp7.540.000", "Rp7.940.000", "−Rp400.000".
  2. Perlu tindakan counter shows "4" on a `bata` pill; first row subtitle "1 hambatan · bulan berikutnya untuk tutup buku" in bold `bata`; other subtitles `tinta3`.
  3. Set `bulan` = sepi → counter "1", one row, dashed box "Belum ada transaksi di November. …", tiles "Rp0" ×3, no draft pill, no "Untuk diketahui"; balance still "Rp38.415.000".
  4. Turn `jabatanKosong` on → vacancy banner at the top of main; side-nav footer "Yanti Sumual · Operator / Menjalankan jabatan kosong Bendahara Jemaat"; no other text changes.
  5. Kas row shows "— Belum dihitung · Hitung kas"; "Hitung kas" opens `/WebHitungKas` and Back returns. Bank rows show "— Rekening koran belum diisi"; no cell shows "Rp0".
  6. "+ Pendapatan" opens `/WebTransaksi` with "Transaksi" active in the side nav; "Oktober 2026 belum ditutup" opens `/WebTutupBuku`; "November 2026 · Belum ditutup" opens `/WebPilihBulan`.
  7. At 900 px the balance renders at 39.6 px (4.4 % of width); at 860 px the side nav collapses behind "Menu" and the Kas & Bank table scrolls inside its card.
- **Notes**
  - The three quick actions "+ Pendapatan", "− Belanja", "+ Persembahan" are all primary (`laut`) as drawn, against A01; logged in rules-checklist 4.2 and allowlisted in W3 (also TabBeranda).
  - Off-token: balance clamp 34–56 px (bigger than `jumlahUtama` 38), h2 17, tile value 19.
  - Three `laut` primary buttons on one page break "one primary button per screen"; copy the board.
  - The three quick actions open the Transaksi list, not the Catat form. Follow the board.
  - The "Perlu tindakan" rows and "Untuk diketahui" link are built in JavaScript; the manifest's `jsLinks` lists only the side nav, so the row targets above come from the source.
  - The manifest marks this board `interactive: false` and `hasSideNav: false`; it still has the side nav and links.

---

### WebTransaksi — Web · Transaksi dan koreksi

- **Source** `docs/design/handoff/canvas/boards/WebTransaksi.dc.html` · page Web (`web`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebTransaksi`, no child routes (the detail is a side panel, not a route) · **Widget** `WebTransaksiScreen` in `lib/screens/web/web_transaksi.dart`
- **Purpose** Bendahara Jemaat on the laptop, journey step 2–3: the month's transactions with every status (LencanaStatus shapes and the line language: Draf dashed, Dibukukan solid, Dibalik outlined, Dibatalkan struck), a detail panel listing what can be done and why not, and booking a Draf with the `tinta` motion. Shows C01 (Kas/Bank as a second line under Uraian on the web table), D02 (a missing document blocks month close, not Bukukan: BKU-2026-0143), "selected row = 3 px inner `laut` line on the left", D29, R04.
- **Shell** web side nav, active **Transaksi**; footer swaps with `jabatanKosong`. Main column gap 20.
- **Layout**
  1. When `jabatanKosong`: web vacancy banner.
  2. Header row (wrap, centred, gap 12): h1 "Transaksi" 26/700 (`flex 1 1 200px`); month pill "November 2026 · Belum ditutup" (as WebBeranda); "Impor" (min-height 44, padding 0 × 16, radius 12, 1.5 `tinta`, `permukaan`, 700); "+ Catat transaksi" (min-height 44, padding 0 × 18, radius 12, `laut`, `diLaut` 700).
  3. Link row (margin-top −8, gap 0 × 22, 14/600, each min 44 × 44): "Daftar Bukti Kas" · "Koreksi dengan pembalikan" · "Draf di bulan yang sudah ditutup" · "Pengembalian" · "Cari".
  4. Filter chips (wrap, gap 8; ChipPilihan pills: min-height 44, padding 0 × 16, radius 999, 1.5 edge, 600/14; selected `tinta`/`permukaan`, unselected `permukaan` + `garisTegas` + `tinta`): "Semua" · "Draf" · "Dibukukan" · "Dibalik" · "Dibatalkan".
  5. Two blocks (wrap, gap 24, top-aligned):
     - **Table** (`flex 999 1 520px`): card `permukaan`, 1 `garis`, radius 14, horizontal scroll; inner min-width 470. Columns `104px 88px minmax(0, 1fr) 124px`, gap 12. Header (padding 12 × 16, 13/600 `tinta2`): "Status" | "Tanggal" | "Uraian · No. Bukti · Kas/Bank" | "Jumlah (Rp)" (right). Rows are buttons: min-height 56, padding 8 × 16, top 1 `garis`, 14 px; background: selected `lautLembut` with a 3 px inner `laut` line on the left edge; Draf `kertas`; others `permukaan`. Cells: status badge (13/700, padding 3 × 9, radius 6; Draf: transparent, 1.5 dashed `putus`, `tinta2`; Dibukukan: `tinta` field, 1.5 `tinta` edge, `permukaan`; Dibalik: `permukaan`, 1.5 `tinta3`, `tinta2`; Dibatalkan: `kertas` field and edge, `tinta2`); date `tinta2`; Uraian 600 (wraps anywhere) + 13 `tinta2` "{No. Bukti in mono} · {Kas/Bank}" ("—" when no number) + optional 13 `tinta3` note; amount mono 500 right, `tinta3` for Draf and Dibatalkan, `tinta` otherwise, struck through for Dibatalkan.
     - Rows in board order (status · No. Bukti · date · Uraian · Kas/Bank · amount · note):
       0. Draf · — · 16/11/2026 · Fotokopi warta jemaat · Kas · −Rp150.000 · "Belum masuk saldo" (after booking: Dibukukan · BKU-2026-0147 · no note)
       1. Draf · — · 08/11/2026 · Honor pemusik · Bank BNI ··4821 · −Rp650.000 · "Belum masuk saldo · Mata Anggaran belum dipilih"
       2. Dibukukan · BKU-2026-0146 · 15/11/2026 · Persembahan Ibadah Minggu · Kas · Rp3.450.000 · —
       3. Dibukukan · BKU-2026-0143 · 11/11/2026 · Sewa sound system · Kas · −Rp600.000 · "Dokumen pendukung wajib, belum ada"
       4. Dibukukan · BKU-2026-0144 · 12/11/2026 · Pembalikan BKU-2026-0139 · Kas · Rp750.000 · "Pembalikan"
       5. Dibalik · BKU-2026-0139 · 09/11/2026 · Konsumsi rapat majelis · Kas · −Rp750.000 · "Dibalik oleh No. Bukti BKU-2026-0144"
       6. Dibatalkan · — · 05/11/2026 · Pembelian bunga altar · Kas · −Rp200.000 (struck) · "Tidak pernah dibukukan"
     - **Detail panel** (`aside`, `flex 1 1 360px`, gap 14), for the selected row:
       - Card (radius 16, padding 18, gap 6, clip): Draf = transparent with `draf` line (1.5 dashed `putus`); others = `permukaan` with `terpilih` line (1.5 `tinta`). Top row (space-between, gap 8): badge (same shapes as the table) with label "Draf · belum masuk saldo" for Draf, else the status word; right: mono 14 `tinta2` No. Bukti or "Belum ada No. Bukti" — replaced, only for row 0 just booked, by the stamp "No. Bukti BKU-2026-0147" (mono 14/600 `laut`, 2 px `laut` edge, radius 8, padding 4 × 10) plus the `sapu` overlay. Amount mono 32/500 letter-spacing −1 (`tinta2` for Draf and Dibatalkan, else `tinta`); Uraian 600; 13 `tinta3` "{Kas/Bank} · tanggal transaksi {date}".
       - Facts card (`permukaan`, 1 `garis`, radius 14, padding 4 × 16; rows padding 10 × 0, gap 16, divider from row 2; key 14 `tinta2`, value 14/600 right, `bata` when flagged else `tinta`). Rows per transaction in Mock data.
       - h2 "Yang dapat dilakukan" 15/700 (margin-top 4); actions (wrap, gap 8; min-height 44, padding 0 × 16, radius 12, 700/14): primary = `laut` + `diLaut`, no edge; others = `permukaan`, 1.5 `tinta`, `tinta`. Then 13 `tinta3` note (`catatan`).
       - h2 "Riwayat" 15/700 + lines 14 `tinta2` (gap 4).
- **Components** LencanaStatus (table and panel), ChipPilihan (filters), Tombol (header buttons, panel actions), PitaJabatanKosong (web), Penolakan-style note (row 1). Repeated patterns: web data table with selectable rows; detail side panel (web form of a bottom sheet); key–value facts card; the `tinta` booking card.
- **Internal views and states** Initial state `{ filter: 'Semua', pilih: 0, buku: false }`. Filter (5 values) × selected row (0–6) × row 0 booked or not. The panel always shows `data[pilih]`, even when the filter hides that row. Rows not matching the filter are removed from the table.
- **Tweaks** (Keadaan panel) `jabatanKosong` (boolean, default off, global): vacancy banner; side-nav footer swap. Riwayat and facts keep "Meiske L." (the board's name swap is disabled).
- **Interactions**
  - Filter chip (`c.pick`) → `filter` = that value; table shows only rows of that status ("Semua" = all). Selection unchanged.
  - Row press (`r.pick`) → `pilih` = row index; panel updates; row highlighted.
  - "Periksa dan bukukan" (row 0 as Draf; the only real button, `utama`) → `buku` true: row 0 becomes Dibukukan BKU-2026-0147 (badge, number, note removed, background `permukaan`/selected, amount `tinta` in the table and the panel), the panel card turns `permukaan` with the 1.5 `tinta` line and the badge reads "Dibukukan", facts add "Dibukukan pada · 16/11/2026 10.42", actions become Verifikasi (primary) / Lampirkan dokumen pendukung / Koreksi dengan pembalikan, note becomes "Jumlah, tanggal, Kas/Bank, peruntukan, Lingkup dan Mata Anggaran tidak dapat diubah lagi.", Riwayat gets two lines. No undo.
  - Every other action is a link (push), by label: "Verifikasi" → `/WebLihatDokumen`; "Lampirkan dokumen pendukung" → `/WebUnggah`; "Catat pengecualian" → `/WebDokumen`; "Koreksi dengan pembalikan" → `/WebKoreksi`; "Pilih Mata Anggaran" → `/WebCatat`; "Ubah" → `/WebCatat`; "Catat persetujuan" → `/WebPersetujuan`; "Batalkan" → `/WebDraf`; "Pindah tanggal" → `/WebDraf`; any other label ("Lihat transaksi asal", "Lihat pembalikan", "Lihat transaksi koreksi") → `/WebKoreksi`.
  - Per row: actions (primary marked *) and note:
    - Row 0 Draf: *Periksa dan bukukan (button), Ubah, Pindah tanggal, Batalkan · "Semua syarat terpenuhi. Pindah tanggal dan Batalkan memerlukan alasan."
    - Row 0 booked: *Verifikasi, Lampirkan dokumen pendukung, Koreksi dengan pembalikan · "Jumlah, tanggal, Kas/Bank, peruntukan, Lingkup dan Mata Anggaran tidak dapat diubah lagi."
    - Row 1: *Pilih Mata Anggaran, Catat persetujuan, Lampirkan dokumen pendukung, Ubah, Batalkan · "Tidak dapat dilakukan: Bukukan. Mata Anggaran belum dipilih dan persetujuan belum dicatat."
    - Row 2: Lampirkan dokumen pendukung, Koreksi dengan pembalikan · "Koreksi hanya lewat pembalikan, selama November 2026 belum ditutup."
    - Row 3: *Lampirkan dokumen pendukung, Catat pengecualian, Koreksi dengan pembalikan · "Menjadi hambatan tutup buku sampai dokumen terverifikasi atau dikecualikan dengan alasan."
    - Row 4: Lihat transaksi asal · "Pembalikan tidak dapat diubah atau dibalik."
    - Row 5: Lihat pembalikan, Lihat transaksi koreksi · "Transaksi asal tetap tampil di daftar dan laporan."
    - Row 6: no actions (heading still shown) · "Hanya dapat dilihat. Transaksi ini tidak pernah punya No. Bukti."
  - Riwayat rule: Draf → one line "{date} · Draf dicatat oleh Meiske L."; otherwise two lines "{Dibukukan pada value} · Dibukukan oleh Meiske L." (or just "Dibukukan oleh Meiske L." when there is no "Dibukukan pada") and "{date} · Draf dicatat oleh Meiske L.".
  - Header and link-row links: see Links out. Side nav → `go`.
- **Motion** Only when row 0 has just been booked and is selected (the `tinta` motion, as Awal): `sapu` overlay on the panel card 700 ms ease-out; `cap` stamp "No. Bukti BKU-2026-0147" 550 ms after 350 ms, standard curve, ends rotated −3°. Both replay each time row 0 is re-selected while booked. No `muncul` is used although the keyframe is declared. No timers.
- **Links out** "November 2026 · Belum ditutup" → `/WebPilihBulan` (push); "Impor" → `/WebImpor` (push); "+ Catat transaksi" → `/WebCatat` (push); "Daftar Bukti Kas" → `/WebBukti` (push); "Koreksi dengan pembalikan" → `/WebKoreksi` (push); "Draf di bulan yang sudah ditutup" → `/WebDraf` (push); "Pengembalian" → `/WebPengembalian` (push); "Cari" → `/WebCari` (push); panel action links as listed above (push); side nav (go). **Inbound** (52 boards; the manifest lists AIBulan instead of PetaLayar, but AIBulan's side-nav links are dead and PetaLayar's are JS-built, `navigation.md` 3.2): PetaLayar, TabBeranda, TabCatat, TabTransaksi, WebAI, WebAIFoto, WebAIMataAnggaran, WebAlihPeruntukan, WebAwal, WebAwalIsian, WebBagi, WebBantuanAI, WebBeranda, WebBukti, WebCari, WebCatat, WebDokumen, WebDraf, WebEkspor, WebExcel, WebExcelTerbatas, WebFormatLaporan, WebHitungKas, WebImpor, WebKasus, WebKasusBaru, WebKejadian, WebKeluar, WebKesiapan, WebKewajiban, WebKoreksi, WebLaporan, WebLihatDokumen, WebLihatTransaksi, WebMataAnggaran, WebMemuat, WebPaketLaporan, WebPemberitahuan, WebPemeriksa, WebPengaturan, WebPengembalian, WebPersembahan, WebPersetujuan, WebPilihBulan, WebRekonIsi, WebRekonsiliasi, WebSambungan, WebSerahTerima, WebTanggal, WebTutupBuku, WebUbahPengaturan, WebUnggah.
- **Mock data** Facts per row (key · value, † = `bata`):
  - Row 0: Diambil dari peruntukan · Umum Jemaat; Lingkup · Jemaat; Mata Anggaran · Belanja 5.02.01.00 Alat tulis dan fotokopi; Persetujuan · Tidak diperlukan (aturan: transaksi rutin); Dokumen pendukung · Diunggah, belum diverifikasi; after booking + Dibukukan pada · 16/11/2026 10.42.
  - Row 1: Diambil dari peruntukan · Umum Jemaat; Lingkup · Jemaat; Mata Anggaran · Mata Anggaran belum dipilih †; Persetujuan · Persetujuan belum dicatat †; Dokumen pendukung · Wajib, belum ada †.
  - Row 2: Masuk ke peruntukan · Umum Jemaat; Lingkup · Jemaat; Mata Anggaran · Pendapatan 1.3.53.07.00 Persembahan Ibadah Minggu; Versi Mata Anggaran · 2026.1; Dokumen pendukung · Terverifikasi (oleh Meiske L.); Dibukukan pada · 15/11/2026 12.20.
  - Row 3: Diambil dari peruntukan · Umum Jemaat; Lingkup · Panitia Natal; Mata Anggaran · Belanja 5.05.02.00 Sewa peralatan; Dokumen pendukung · Wajib, belum ada †; Dibukukan pada · 11/11/2026 16.05.
  - Row 4: Pembalikan dari · No. Bukti BKU-2026-0139; Alasan · Mata Anggaran keliru; Dibukukan pada · 12/11/2026 09.31.
  - Row 5: Dibalik oleh · No. Bukti BKU-2026-0144; Transaksi koreksi · No. Bukti BKU-2026-0145; Mata Anggaran · Belanja 5.02.01.00 Alat tulis dan fotokopi; Dibukukan pada · 09/11/2026 14.12.
  - Row 6: Alasan · Tercatat dua kali; Dibatalkan oleh · Meiske L.; Dibatalkan pada · 06/11/2026 08.02.
  - Plus: new number BKU-2026-0147; month November 2026; Meiske L.; Yanti Sumual (vacancy since 16/11/2026 08.15).
- **Prototype-only** none.
- **Acceptance checks**
  1. Open `/WebTransaksi` → side nav "Transaksi" active; filter "Semua" selected; row 0 highlighted `lautLembut` with a 3 px `laut` left line; panel card dashed, badge "Draf · belum masuk saldo", "Belum ada No. Bukti", "−Rp150.000" in `tinta2`; actions "Periksa dan bukukan" (`laut`), "Ubah", "Pindah tanggal", "Batalkan"; Riwayat "16/11/2026 · Draf dicatat oleh Meiske L.".
  2. Press "Periksa dan bukukan" → row 0 badge "Dibukukan", number "BKU-2026-0147", note gone; panel card solid with the sweep and the tilted stamp "No. Bukti BKU-2026-0147"; facts gain "Dibukukan pada 16/11/2026 10.42"; actions "Verifikasi", "Lampirkan dokumen pendukung", "Koreksi dengan pembalikan"; Riwayat "16/11/2026 10.42 · Dibukukan oleh Meiske L." then "16/11/2026 · Draf dicatat oleh Meiske L.".
  3. Select row 1 → three fact values in `bata` ("Mata Anggaran belum dipilih", "Persetujuan belum dicatat", "Wajib, belum ada"); note "Tidak dapat dilakukan: Bukukan. Mata Anggaran belum dipilih dan persetujuan belum dicatat."; "Pilih Mata Anggaran" is the `laut` action and opens `/WebCatat`.
  4. Filter "Dibalik" → table shows only "Konsumsi rapat majelis"; the panel still shows the previously selected row.
  5. Row 6 → amount "−Rp200.000" struck through in `tinta3`; badge on a `kertas` field; panel shows "Yang dapat dilakukan" with no buttons and "Hanya dapat dilihat. Transaksi ini tidak pernah punya No. Bukti."
  6. Row 5 "Lihat pembalikan" → `/WebKoreksi`; row 3 "Catat pengecualian" → `/WebDokumen`; row 0 booked "Verifikasi" → `/WebLihatDokumen`; Back returns to `/WebTransaksi`.
  7. Select row 2 then row 0 again (booked) → sweep and stamp replay.
  8. `jabatanKosong` on → vacancy banner and side-nav footer swap; Riwayat still says "Meiske L.".
  9. At 860 px the panel wraps below the table; the table keeps a 470 px minimum and scrolls inside its card.
- **Notes**
  - "+ Catat transaksi" (page header) and "Periksa dan bukukan" (detail aside, a column of the page) are both primary as drawn, against A01; logged in rules-checklist 4.2 and allowlisted in W3.
  - Off-token: amount 32 in the panel, stamp radius 8.
  - The Dibatalkan badge is a `kertas` field with a `kertas` edge here; LencanaStatus says a `garis` field. Follow the board (CONVENTIONS: board wins on what the screen shows) and log the mismatch.
  - Riwayat for rows 4 and 6 is generated by the same rule, so the reversal shows "12/11/2026 · Draf dicatat oleh Meiske L." and the cancelled row shows "Dibukukan oleh Meiske L." although it was never booked. Reproduce the board's rule exactly; flag for the design owner.
  - Rows are in the board's order, not sorted by date.
  - Column "Jumlah (Rp)" still prints "Rp" in each figure. Copy.
  - This board's figures differ from Koreksi/WebKoreksi on purpose: here BKU-2026-0139 is already reversed on 12/11/2026 09.31 with reason "Mata Anggaran keliru" and corrected by BKU-2026-0145; Koreksi starts before that reversal. Each screen keeps its own figures (record in `docs/build/mock-data.md`).
  - The manifest marks `hasSideNav: false`; the board has the side nav.
