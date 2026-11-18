# Screens 04: Lainnya, MataAnggaran, WebMataAnggaran, Bendahara, WebPengaturan, Persembahan, WebPersembahan

These seven boards are the Bendahara Jemaat's settings and two of its daily tools. `Lainnya` is the phone's fifth tab: a settings hub with three inner views (Kas/Bank, Aturan, Riwayat aktivitas) and a list of drill-ins to almost every other phone finance board. From it the Bendahara opens `MataAnggaran` (review a draft Mata Anggaran version, fill in "Boleh untuk" on each row, mark it checked, publish it) and `Bendahara` (the active Bendahara, signed-in sessions, the handover to a new Bendahara, and the locked "Belum ada Bendahara aktif" state). `WebPengaturan` is the laptop version of the whole hub on one page, and it links to `WebMataAnggaran`, the laptop version of the publish flow. `Persembahan` and `WebPersembahan` record one Sunday offering made of several parts (cash, QRIS, bank transfer), each with its own owner (own money or Titipan for the Sinode) and its own Kas/Bank, then post it under one No. Bukti. The phone version is reached from the "Catatan lain" chips of `Main`, the laptop version from `WebCatat` and `TabCatat`. Every board here keeps its interaction state in one object owned by the board and held above its child routes, so going from `/X` to `/X/sub` and back keeps the state; the state is dropped when the board leaves the navigation stack, as a canvas board resets when it is reopened.

Shared phone pieces used below:

- **Phone header with back**: row, padding 14 12 8, gap 8. A 44 × 44 back control with a 22 px chevron (path `M15 6l-6 6 6 6`, stroke 2, round caps, `tinta`), then the title (`judulLayar` 18/700). A back control that is an `<a href>` to another board pops when that board is the previous route, otherwise `go`es to it.
- **Phone action bar**: `permukaan`, top border 1 `garis`, padding 12 20 22, column gap 8, pinned under the scrolling content.
- **LembarBawah (phone)**: scrim `tinta` at 45 % opacity (board: `rgba(19,32,28,.45)`), fades in with `pudar` 0.2 s; tapping the scrim closes the sheet. Sheet `permukaan`, top corners 22 (`radius-lembar`), padding 10 20 24, column gap 14, rises with `naik` 280 ms on `Cubic(0.2,0.8,0.2,1)`. Handle 40 × 4, radius 2, `garisTegas`, centred, 4 below.
- **Row chevron**: 18 px, path `M9 6l6 6-6 6`, stroke `tinta3` 2, round caps.
- **Chip (ChipPilihan)**: min height 44, 1.5 border. Selected: `tinta` field, `permukaan` text, `tinta` border. Unselected: `permukaan` field, `tinta` text, `garisTegas` border.

Shared web pieces:

- **Web side nav** (shell): `flex 1 1 220`, padding 24 16, `permukaan`, right border 1 `garis`, column gap 20. Logo row (padding 0 8, gap 10): the mark SVG 26 px (dashed `laut` rounded square, right half filled `laut`; path data on the board), then "palakat" 18/700 line-height 1.1 and "Jemaat Karunia" 13 `tinta3`. Items (built in JS on every board here, in this order): Beranda → `/WebBeranda`, Transaksi → `/WebTransaksi`, Uang Muka dan Titipan → `/WebKewajiban`, Rekonsiliasi → `/WebRekonsiliasi`, Bulan dan tutup buku → `/WebTutupBuku`, Laporan → `/WebPaketLaporan`, Pengaturan → `/WebPengaturan`; each min height 44, padding 0 12, radius 10, weight 600; the active item is a `tinta` field with `permukaan` text, the others transparent with `tinta` text. All nav items use `go`, the active one included: it stays a link (to `/WebPengaturan` on WebMataAnggaran and on WebPengaturan itself, to `/WebTransaksi` on WebPersembahan). Footer (`margin-top: auto`, padding 12 8 0, top border `garis`, 13 `tinta2`) differs per board. Below 860 px the nav becomes a top bar (row, padding 8 16, a 1 `garis` bottom border instead of the right border) with a "Menu" / "Tutup menu" toggle pushed to the right (`aria-label` "Menu", min height 44, padding 0 16, radius 14, 1.5 `tinta` border, 14/700; unchecked `permukaan` field; checked: `tinta` field, `permukaan` text) that shows the items (padding 8 0) and the footer (no top margin, 8 bottom padding) on full-width lines below the logo row.
- **Links** without their own colour (breadcrumbs, text links, the WebPengaturan link row) are `laut` and turn `lautTua` on hover (board CSS `a:hover`). Nav items and link-buttons with their own colour do not change on hover.
- **Web main column**: `flex 999 1 560`, padding 28, horizontal `clamp(16px, 3vw, 40px)`, bottom 40, column gap 20, body `isiWeb` (15/1.45).
- **PitaJabatanKosong (web)**, shown on boards where `jabatanKosong` is on: first child of main, `role=status`, `tinta` field, radius 14, padding 12 16, 14 px: **"Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15."** (700, `permukaan`) then " Setiap tindakan dicatat sebagai dijalankan oleh Operator Yanti Sumual." in `diTinta2`.
- **PitaJabatanKosong (phone)**: one line above the whole screen (outside the views, so it stays above sheets and view changes), `role=status`, `tinta` field, padding 10 24 8, 13 px, line-height 1.3, centred, `permukaan` text: **"Menjalankan jabatan kosong"** · Bendahara Jemaat.

---

### Lainnya — 7 · Lainnya dan pengaturan

- **Source** `docs/design/handoff/canvas/boards/Lainnya.dc.html` · page Ponsel (`ponsel`) · form Phone 390×844 · interactive yes
- **Route** `/Lainnya` plus child routes `/Lainnya/kas`, `/Lainnya/aturan`, `/Lainnya/riwayat` · **Widget** `LainnyaScreen` in `lib/screens/ponsel/lainnya.dart`
- **Purpose** The Bendahara Jemaat's "Lainnya" tab: read the church's fixed settings, deactivate a Kas/Bank from a future month, switch "Wajib pemeriksa kedua", read the activity history, and open every other settings and tools board. Not named in the handoff's Bendahara journey list; it is the phone hub from which journey steps 1 (Mata Anggaran), 5 (Laporan, Daftar Bukti Kas, Ekspor data Jemaat) and 6 (Bendahara dan sesi) are opened. Shows D29 (five bottom tabs with Catat in the centre), D23 (a settings change takes effect from a later month: the Nonaktifkan sheet and the switch both name the month), the Sakelar rule (a switch always states its starting month), master-file row 7 (a separate check only when "Wajib pemeriksa kedua" is on), D15 (the list "Uang yang masih berjalan").
- **Shell** Hub: phone tab bar, "Lainnya" active. Inner views: phone header with back (no tab bar).
  Tab bar: height 84, `permukaan`, top border 1 `garis`, five equal columns, padding-top 8. Items min height 52, column, gap 3, 13/600, `tinta3`, icon 22:
  1. "Beranda" (house, path `M4 11l8-7 8 7v9H4z`) → `/Main` (go).
  2. "Transaksi" (three lines `M5 7h14M5 12h14M5 17h9`) → `/Main` (go).
  3. Catat button, `aria-label` "Catat transaksi": circle 58 × 58, `laut` field, `diLaut` plus icon 24 (stroke 2.4, `M12 5v14M5 12h14`), 4 px `kertas` ring (content-box), lifted 22 px above the bar (`margin-top: -22px`) → `/Main` (go).
  4. "Bulan" (calendar: rect 4,5 16×15 rx 3, `M4 10h16M9 3v4M15 3v4`) → `/TutupBuku` (go).
  5. "Lainnya" (three filled dots r 2 at x 5/12/19): `laut` text and icon, not a link.
- **Layout**
  *Hub* (scroll area above the tab bar, padding 24 20 28, column gap 18; fades in with `pudar`):
  1. Title "Lainnya", `judulBesar` 22/700.
  2. Church card: `permukaan`, 1 `garis` (dibukukan line), radius 14, padding 14 16, gap 2. "Jemaat Karunia" 17/700 (off-token). "WITA · tahun buku mulai 1 Januari (tidak dapat diubah)" 14 `tinta2`. "Tanggal mulai pencatatan 15 September 2026" 14 `tinta2`.
  3. Note, 13 `tinta3`: "Pengaturan tidak diubah di tempat. Setiap perubahan berlaku mulai bulan tertentu dan tidak mengubah transaksi yang sudah dibukukan."
  4. Group card A (`permukaan`, 1 `garis`, radius 14, padding 0 16). Rows min height 60, separated by 1 `garis` top borders; title 15/600 `tinta`, subtitle 13 `tinta3`; pressable rows end with the row chevron, gap 12:
     - "Kas/Bank" · `{kasRingkas}` = "3 aktif · 1 nonaktif" · chevron · opens `/Lainnya/kas`.
     - "Peruntukan" · "Umum Jemaat · Diakonia · Pembangunan" (static).
     - "Lingkup" · "Jemaat · Kolom 3 · BIPRA Pemuda · Komisi Diakonia · Panitia Natal" (static).
     - "Mata Anggaran" · "Versi 2026.1 diterbitkan · versi 2026.2 masih draf" · chevron · link `/MataAnggaran`.
     - "Seri No. Bukti" · "BKU-2026-0001 Biasa · OPN Saldo awal pencatatan · ADJ Penyesuaian" with "BKU-2026-0001", "OPN" and "ADJ" in mono (static).
  5. Group card B, same style:
     - "Aturan persetujuan dan dokumen pendukung" · `{aturanRingkas}` · chevron · opens `/Lainnya/aturan`.
     - "Format laporan" · "Bawaan Palakat v1 · Persetujuan format: sudah dicatat" (static).
     - "Bendahara dan sesi" · "Meiske Lumentut · Wewenang Bendahara aktif" · chevron · link `/Bendahara`.
     - "Riwayat aktivitas" · "Siapa melakukan apa, dan kapan" · chevron · opens `/Lainnya/riwayat`.
  6. Group card C, same style, 15 link rows with chevron (first row has no top border): "Laporan" · "Paket Laporan Bulanan GMIM · F01 sampai F14"; "Daftar Bukti Kas" · "Semua No. Bukti dan celah nomor"; "Uang Muka dan Titipan" · "Uang yang masih berjalan"; "Impor" · "Dari file Excel atau CSV"; "Ekspor data Jemaat" · "Salinan lengkap milik Jemaat"; "Dokumen pendukung" · "Verifikasi, pengecualian, dokumen susulan"; "Pernyataan kesiapan" · "Per peruntukan · setelah ada bendahara unit (Putaran 5)"; "Kejadian setelah tutup buku" · "Catatan tentang bulan yang sudah ditutup"; "Persetujuan format laporan" · "Sudah dicatat · 03/10/2026"; "Cari" · "Dengan kata sehari-hari"; "Pemberitahuan" · "Sementara"; "Tambah dan ubah pengaturan" · "Kas/Bank, seri No. Bukti, aturan · berlaku mulai bulan tertentu"; "Wajib pemeriksa kedua" · "Aturan pilihan Jemaat"; "Persetujuan di luar aplikasi" · "Ganti catatan, dan yang terjadi bila transaksi diubah"; "Akun dan keluar" · "Meiske Lumentut · perangkat ini". Targets under Links out.
  7. Tab bar (above).

  *Kas/Bank* (`/Lainnya/kas`, slides in with `masuk`): header "Kas/Bank"; content padding 8 20 20, column gap 10:
  1. Four cards, each radius 14, padding 14 16, row gap 12, 2 px extra bottom margin: name 15/600, subtitle 13 `tinta3`, and a "Nonaktifkan" button when allowed (min height 44, padding 0 12, radius 10, 1.5 `garisTegas` border, `permukaan`, 14/700).
     - Active, untouched: `permukaan` field, 1 `garis` border, name `tinta`.
     - Scheduled to deactivate: `permukaan` field, 1.5 dashed `putus` border (draf line), no button.
     - Already inactive ("Kas Panitia HUT"): transparent field, 1.5 dashed `putus` border, name `tinta2`, no button.
  2. Note, 13 `tinta3`, 6 above: "Kas/Bank yang sudah dipakai tidak dapat dihilangkan, hanya dinonaktifkan. Yang nonaktif tetap tampil di transaksi dan laporan lamanya."

  *Nonaktifkan sheet* (LembarBawah over the Kas/Bank view; scrim `aria-label` "Kembali ke daftar Kas/Bank"):
  1. Handle.
  2. "Nonaktifkan {nama}" 18/700, then "Transaksi lama tidak berubah dan tetap tampil di laporannya." 14 `tinta2`.
  3. "Berlaku mulai" 14 `tinta2`, 8 below; chips "Desember 2026", "Januari 2027" (radius 999, padding 0 14, 8 apart, 14/600); then 8 below "Hanya bulan yang belum ditutup dan belum berjalan." 13 `tinta3`.
  4. Button "Nonaktifkan mulai {bulan}": min height 52, radius 14, `tinta` field, `permukaan` text, 700, centred.
  5. Text button "Kembali": min height 44, 700, centred.

  *Aturan* (`/Lainnya/aturan`, `masuk`): header "Aturan"; content padding 8 20 20, gap 16:
  1. Card (`permukaan`, 1 `garis`, radius 14, padding 4 16), three static rows (padding 12 0, `garis` dividers), title 15/600, text 14 `tinta2`: "Persetujuan di luar aplikasi" · "Wajib untuk Belanja Rp2.000.000 ke atas · berlaku mulai September 2026"; "Dokumen pendukung" · "Wajib untuk semua Belanja · Bendahara boleh memverifikasi unggahannya sendiri"; "Pemberi pengecualian" · "Ketua BPMJ".
  2. Card (`permukaan`, 1 `garis`, radius 14, padding 14 16, column gap 10). Row (align centre, gap 12): "Wajib pemeriksa kedua" 15/600 over `{mcStatus}` 13 `tinta3`; at the right the Sakelar: target 56 × 44 (`aria-pressed`, `aria-label` "Wajib pemeriksa kedua"), track 56 × 32, radius 16, 1.5 `tinta` border, field `permukaan` (off) or `tinta` (on); knob 23 × 23 circle at top 3, left 3 (off) or 28 (on), `tinta` (off) or `permukaan` (on). Track colour and knob position animate in 160 ms (`sentuh`).
     When on, below a 1 `garis` divider (padding-top 10, gap 6, appears with `muncul`): "**Berlaku mulai Desember 2026.** Sejak itu, Bukukan memerlukan orang kedua yang menandai sudah diperiksa. Pemeriksa kedua tidak boleh orang yang mencatat." 14 `tinta`; "Belum ada pemeriksa kedua yang ditunjuk. Tanpa itu, Bukukan akan ditolak mulai Desember 2026." 14/600 `bata`; "Transaksi November 2026 dan sebelumnya tidak terpengaruh." 13 `tinta3`.

  *Riwayat aktivitas* (`/Lainnya/riwayat`, `masuk`): header "Riwayat aktivitas"; list padding 8 20 20; rows padding 12 0, 1 `garis` top border except the first; line 1 15/600, line 2 13 `tinta3`. Six rows, see Mock data.
- **Components** Sakelar (Aturan). ChipPilihan (sheet month chips). LembarBawah (Nonaktifkan sheet). Tombol: secondary small "Nonaktifkan"; dark `tinta` button "Nonaktifkan mulai …"; text "Kembali". Not components: the grouped settings list (card with 60 px rows and chevrons, reused from Lainnya-style hubs), the phone tab bar (shell), the history list.
- **Internal views and states** Initial state `{ screen: 'hub', sheet: null, bulan: 'Desember 2026', non: {}, mc: false }`.
  - Hub (`screen: 'hub'`): default.
  - Kas/Bank (`'kas'`): from the "Kas/Bank" row.
  - Nonaktifkan sheet (`sheet: <kas id>`): from a card's "Nonaktifkan"; not a route.
  - Aturan (`'aturan'`): from "Aturan persetujuan dan dokumen pendukung". Sub-state `mc` off/on.
  - Riwayat (`'riwayat'`): from "Riwayat aktivitas".
  - Per Kas/Bank: active · scheduled (`non[id]` = month) · inactive.
- **Tweaks** none. Keadaan panel: no board tweaks; global switches only.
- **Interactions**
  - `keKas` / `keAturan` / `keRiwayat`: push `/Lainnya/kas` / `aturan` / `riwayat`.
  - `keHub` (the back button of each inner view, `aria-label` "Kembali"): pop to `/Lainnya`; also closes the sheet.
  - Kas card "Nonaktifkan" (`buka`): opens the sheet for that Kas/Bank and resets the month to "Desember 2026".
  - Month chip (`pick`): selects that month; the main button text follows ("Nonaktifkan mulai Januari 2027").
  - "Nonaktifkan mulai {bulan}" (`nonaktifkan`): records `non[id] = bulan`, closes the sheet. The card turns dashed, loses its button, and its subtitle becomes "Aktif sampai akhir November 2026 · nonaktif mulai Desember 2026" (month Desember 2026) or "Aktif sampai akhir Desember 2026 · nonaktif mulai Januari 2027" (month Januari 2027). No confirmation, no undo.
  - Scrim or "Kembali" (`tutupSheet`): closes the sheet, nothing changes. System Back also closes it.
  - Sakelar (`toggleMc`): flips `mc`. Status line: off "Mati · Bendahara memeriksa dan membukukan sendiri", on "Hidup mulai Desember 2026". Hub row subtitle `aturanRingkas`: off "Wajib pemeriksa kedua: mati", on "Wajib pemeriksa kedua: hidup mulai Desember 2026".
  - No typed input, no timers.
- **Motion** Hub: `pudar` 0.2 s (CSS ease) on show. Inner views: `masuk` 280 ms, `Cubic(.2,.8,.2,1)` (fade in, slide from 24 px right) on show; use it as the push transition of the child routes. Sheet: scrim `pudar` 0.2 s, panel `naik` 280 ms. Aturan detail block: `muncul` 0.3 s (fade, rise 8 px, CSS ease) when the switch turns on. Sakelar: background and knob `left` transitions 160 ms (`sentuh`). Board declares no other keyframes.
- **Links out** All drill-ins use push; tab bar uses go. Bendahara, Bukti, Dokumen, Ekspor, FormatLaporan, Impor, Keluar, Laporan, MataAnggaran and UbahPengaturan link back to Lainnya; Kewajiban, Kesiapan, Kejadian, Cari, Pemberitahuan, Pemeriksa and Persetujuan do not, so system Back is the way back from them.
  - "Mata Anggaran" → `/MataAnggaran`; "Bendahara dan sesi" → `/Bendahara`.
  - "Laporan" → `/Laporan`; "Daftar Bukti Kas" → `/Bukti`; "Uang Muka dan Titipan" → `/Kewajiban`; "Impor" → `/Impor`; "Ekspor data Jemaat" → `/Ekspor`; "Dokumen pendukung" → `/Dokumen`; "Pernyataan kesiapan" → `/Kesiapan`; "Kejadian setelah tutup buku" → `/Kejadian`; "Persetujuan format laporan" → `/FormatLaporan`; "Cari" → `/Cari`; "Pemberitahuan" → `/Pemberitahuan`; "Tambah dan ubah pengaturan" → `/UbahPengaturan`; "Wajib pemeriksa kedua" → `/Pemeriksa`; "Persetujuan di luar aplikasi" → `/Persetujuan`; "Akun dan keluar" → `/Keluar`.
  - Tab bar: "Beranda", "Transaksi", Catat → `/Main` (go); "Bulan" → `/TutupBuku` (go).
  - **Inbound**: Bendahara, Bukti, Dokumen, Ekspor, FormatLaporan, Impor, KasUnit, Keluar, Laporan, Main, MataAnggaran, UbahPengaturan.
- **Mock data**
  - Church: Jemaat Karunia, WITA, tahun buku from 1 Januari, recording started 15 September 2026.
  - Kas/Bank: "Kas", "Bank BNI ··4821", "Bank SulutGo ··1107", each "Aktif · dipakai sejak September 2026"; "Kas Panitia HUT", "Nonaktif sejak November 2026 · tetap tampil di laporan lama". Summary "3 aktif · 1 nonaktif".
  - Peruntukan: Umum Jemaat, Diakonia, Pembangunan. Lingkup: Jemaat, Kolom 3, BIPRA Pemuda, Komisi Diakonia, Panitia Natal.
  - Series: BKU-2026-0001 (Biasa), OPN (Saldo awal pencatatan), ADJ (Penyesuaian).
  - Rules: approval outside the app for Belanja Rp2.000.000 and above from September 2026; supporting documents for all Belanja; exceptions by Ketua BPMJ.
  - Format: Bawaan Palakat v1, approval recorded 03/10/2026.
  - Bendahara: Meiske Lumentut.
  - Riwayat (line 1 / line 2): "Meiske L. membukukan BKU-2026-0146" / "15/11/2026 12.20 · Persembahan Ibadah Minggu"; "Meiske L. membuat pembalikan BKU-2026-0144" / "12/11/2026 09.31 · Alasan: Mata Anggaran keliru"; "Meiske L. menonaktifkan Kas Panitia HUT" / "28/10/2026 16.44 · berlaku mulai November 2026"; "Meiske L. menutup buku September 2026" / "05/10/2026 19.02 · Periode laporan 15–30 September 2026"; "Meiske L. mencatat persetujuan format laporan" / "03/10/2026 10.15 · Pemberi persetujuan: Pdt. Lidya Rondonuwu, Ketua BPMJ"; "Petugas verifikasi mengaktifkan wewenang Bendahara" / "15/09/2026 10.15 · Meiske Lumentut".
- **Prototype-only** none on this board.
- **Acceptance checks**
  1. Open `/Lainnya` → title "Lainnya", tab bar with "Lainnya" in `laut`, Kas/Bank row subtitle "3 aktif · 1 nonaktif", Aturan row subtitle "Wajib pemeriksa kedua: mati".
  2. Tap "Kas/Bank" → `/Lainnya/kas` slides in from the right in 280 ms; four cards; "Kas Panitia HUT" is dashed on a transparent field with no button; the other three have "Nonaktifkan".
  3. Tap "Nonaktifkan" on "Bank BNI ··4821" → sheet rises in 280 ms titled "Nonaktifkan Bank BNI ··4821", "Desember 2026" selected, button "Nonaktifkan mulai Desember 2026".
  4. Pick "Januari 2027", press the main button → sheet closes; the BNI card is dashed, without button, subtitle "Aktif sampai akhir Desember 2026 · nonaktif mulai Januari 2027".
  5. Open the sheet for "Kas", tap the scrim → sheet closes, Kas card unchanged.
  6. Hub → Aturan → tap the switch → knob slides right in 160 ms, status "Hidup mulai Desember 2026", the three-line block fades up with the `bata` sentence; back → hub row reads "Wajib pemeriksa kedua: hidup mulai Desember 2026".
  7. Riwayat shows six rows, first "Meiske L. membukukan BKU-2026-0146", last "Petugas verifikasi mengaktifkan wewenang Bendahara".
  8. Tap "Mata Anggaran" → `/MataAnggaran`; its back arrow returns to the hub; browser Back does the same.
  9. Tap "Bulan" → `/TutupBuku`; "Beranda", "Transaksi" and the centre button → `/Main`.
  10. Reduce motion on → views and the sheet appear without slide or fade.
- **Notes**
  - "Jemaat Karunia" is 17 px and row titles 15 px (off-token; copy).
  - `kasRingkas` is computed from the fixed list and stays "3 aktif · 1 nonaktif" after a deactivation is scheduled; that is correct (the account is still active this month).
  - Riwayat is static; it does not gain a row for a deactivation done in the session. Keep it static.
  - "Pemberitahuan · Sementara": decision C06 (18/11/2026) says Pemberitahuan is final and no longer labelled provisional. The board still says "Sementara". Recommended: keep the board copy (the board wins on copy) and list it for the product owner.
  - The dark `tinta` "Nonaktifkan mulai …" button is not the `laut` primary; copy the board.
  - "Persetujuan format laporan · Sudah dicatat · 03/10/2026" differs from WebPengaturan's "01/11/2026"; each screen keeps its own figure (mock-data.md).

---

### MataAnggaran — 8 · Terbitkan Mata Anggaran

- **Source** `docs/design/handoff/canvas/boards/MataAnggaran.dc.html` · page Ponsel (`ponsel`) · form Phone 390×844 · interactive yes
- **Route** `/MataAnggaran` plus child route `/MataAnggaran/rinci` · **Widget** `MataAnggaranScreen` in `lib/screens/ponsel/mata_anggaran.dart`
- **Purpose** The Bendahara Jemaat reviews draft version 2026.2 of the Mata Anggaran list, fills in "Boleh untuk" (Milik sendiri, Titipan, Keduanya) on each postable row, marks the version checked and publishes it from December 2026. Bendahara journey step 1. Shows D22 (Boleh untuk is filled before publishing), D19 (only rows allowed for Titipan accept Titipan), the PemilihMataAnggaran rules (number and name as stored, always with the tree name; group headings cannot be posted to), the line language (dashed draft card, solid published card), D23 (a published version is never edited; a change becomes a new version from a later month).
- **Shell** Phone header with back (to Lainnya), no tab bar. PitaJabatanKosong (phone) above everything when `jabatanKosong` is on.
- **Layout**
  *Versi* (`/MataAnggaran`, fades in with `pudar`): header back link (`aria-label` "Kembali ke Lainnya") + "Versi Mata Anggaran"; content padding 8 20 20, column gap 12:
  1. Intro 14 `tinta2`: "Versi yang diterbitkan tidak pernah berubah. Perubahan menjadi versi baru yang berlaku mulai bulan berikutnya."
  2. Version 2026.2 card, the whole card pressable (opens Rinci), full width, radius 16, padding 16, column gap 4, clips its children. Draf: transparent field, 1.5 dashed `putus` (draf line). Sudah diperiksa and Diterbitkan: `permukaan` field, 1.5 solid `tinta` (terpilih line). Contents: row (space-between, gap 8) "Versi 2026.2" 18/700 + status badge; `{v2Teks}` 14 `tinta2`; "2 baris baru · 1 nama berubah · dibanding versi 2026.1" 13 `tinta3`. When Diterbitkan, a full-card `laut` overlay plays `sapu` (see Motion).
  3. Version 2026.1 card: `permukaan`, 1.5 solid `tinta`, radius 16, padding 16, gap 4. "Versi 2026.1" 18/700 + badge "Diterbitkan" (`tinta` field, `permukaan` text, radius 6, padding 4 10, 13/700). "Berlaku mulai September 2026 · {v1Sampai}" 14 `tinta2`. "Pendapatan 131 baris · Belanja 158 baris" 13 `tinta3`.

  Status badge (LencanaStatus, 13/700, radius 6, padding 3 9): Draf → transparent, `tinta2` text, 1.5 dashed `putus`; Sudah diperiksa → `permukaan`, `laut` text, 1.5 solid `laut`; Diterbitkan → `tinta` field, `permukaan` text, 1.5 solid `tinta`.

  *Rinci* (`/MataAnggaran/rinci`, `masuk`):
  1. Header: back button (`aria-label` "Kembali"), title "Versi 2026.2" (flex), the status badge with 8 right margin.
  2. Tab chips, padding 0 20 10: "Belanja", "Pendapatan" (radius 999, padding 0 16, 8 apart, 14/600).
  3. Scrolling list, padding 0 20 20. Each row padding 12 0, 1 `garis` top border:
     - Line 1 (baseline row, gap 8): code `"{tab} {No. MA}"`, e.g. "Belanja 5.00.00.00", mono 13 `tinta2`; then, if any, a tag ("Baru" or "Nama berubah"): 13/700 `laut` text, 1.5 `laut` border, radius 6, padding 1 7.
     - Line 2: name 15 px; group heading 700 `tinta2`; postable row 600 `tinta`.
     - Group heading: "Judul kelompok, tidak dapat dibukukan" 13 `tinta3`; no chips.
     - Postable row, 8 above: "Dapat dibukukan · Boleh untuk: " 13 `tinta2` followed by the value 600 (`tinta`) or "belum diisi" 600 `bata`; 6 below, three chips "Milik sendiri", "Titipan", "Keduanya" (radius 10, padding 0 12, 6 apart, 13/600).
     - After the rows, 13 `tinta3`, padding-top 12, `garis` top border: "Contoh 5 dari {158|131} baris. “Boleh untuk” diisi atas keputusan Pimpinan Jemaat yang berwenang. Baris yang dibiarkan kosong tidak dapat menerima titipan."
  4. Action bar: `{kakiTeks}` 14 `tinta2`, then by status: Draf → secondary "Tandai sudah diperiksa" (min height 52, radius 14, 1.5 `tinta` border, `permukaan`, 700, centred); Sudah diperiksa → primary "Terbitkan" (min height 52, radius 14, `laut` field, `diLaut` text, 700), appearing with `muncul`; Diterbitkan → no button.

  *Terbitkan sheet* (LembarBawah over Rinci; scrim `aria-label` "Kembali ke versi 2026.2"):
  1. Handle.
  2. "Terbitkan versi 2026.2?" 20/700 (off-token).
  3. Permanent statement box: `tinta` field (ditutup), `permukaan` text, radius 14, padding 14 16, 14 px: "**Versi yang diterbitkan tidak dapat diubah.** Perubahan berikutnya harus menjadi versi baru, berlaku mulai bulan yang lebih kemudian."
  4. 14 `tinta2`: "**Berlaku mulai Desember 2026.**" (700 `tinta`) " Transaksi sampai November 2026 tetap memakai versi 2026.1 dan tidak berubah."
  5. Primary "Terbitkan, berlaku mulai Desember 2026" (52, radius 14, `laut`, `diLaut`, 700).
  6. Text button "Kembali" (44, 700).
- **Components** LencanaStatus (Draf / Sudah diperiksa / Diterbitkan badges), ChipPilihan (tabs, Boleh untuk chips), LembarBawah, Tombol (secondary, primary, text), PitaJabatanKosong (phone). The "Baru"/"Nama berubah" tag and the Mata Anggaran row are board patterns.
- **Internal views and states** Initial state `{ screen: 'versi', st: 'draf', tab: 'Belanja', sheet: false, boleh: { '5.01.02.00': 'Milik sendiri', '5.03.03.00': 'Milik sendiri', '5.06.01.00': '', '4.03.03.00': 'Milik sendiri', '1.3.53.07.00': 'Milik sendiri', '1.3.53.09.00': 'Milik sendiri', '2.1.01.02.00': 'Titipan', '1.4.10.02.00': 'Keduanya' } }`.
  - Views: Versi (`/MataAnggaran`), Rinci (`/MataAnggaran/rinci`), Terbitkan sheet (over Rinci, not a route).
  - Status `st`: `draf` → `periksa` → `terbit`. Any change to "Boleh untuk" sends `periksa` back to `draf`. `terbit` is final.
  - Tab: Belanja / Pendapatan.
  - Derived texts:
    - `v2Teks`: before publishing "Belum berlaku · usulan berlaku mulai Desember 2026"; published "Berlaku mulai Desember 2026 · diterbitkan oleh Meiske L., 16/11/2026".
    - `v1Sampai`: before "versi yang sedang dipakai"; published "dipakai sampai November 2026".
    - `kakiTeks`: published "Diterbitkan. Versi ini tidak dapat diubah lagi."; checked "Sudah diperiksa. Mengubah isi mengembalikan versi ini ke Draf."; draft with n empty rows "{n} baris belum punya “Boleh untuk”. Boleh dibiarkan kosong; baris itu tidak dapat menerima titipan."; draft with none empty "Semua baris contoh sudah punya “Boleh untuk”." n counts empty values across both tabs (initially 1: 5.06.01.00).
- **Tweaks** `jabatanKosong` (boolean, default off) — Keadaan panel, the global `jabatanKosong` switch. On: the phone PitaJabatanKosong line shows above the screen (and stays above the sheet's scrim), and "Meiske L." in strings dated only 16/11/2026 becomes "Yanti Sumual, Operator" (`tukarJk` enabled), so the published text reads "Berlaku mulai Desember 2026 · diterbitkan oleh Yanti Sumual, Operator, 16/11/2026". Nothing else changes.
- **Interactions**
  - Version 2026.2 card (`keRinci`): push `/MataAnggaran/rinci`. Works in every status.
  - Back in Rinci (`keVersi`): pop to `/MataAnggaran` (also closes the sheet).
  - Tab chip: switches the list; status unchanged.
  - Boleh untuk chip (`pick`): ignored when published (chips also carry disabled semantics). Otherwise tapping an unselected option sets it; tapping the selected option clears the row to empty ("belum diisi" in `bata`). Either way `st` becomes `draf` (so a checked version drops back to Draf and the "Terbitkan" button is replaced by "Tandai sudah diperiksa").
  - "Tandai sudah diperiksa" (`periksa`): `st = periksa`. Allowed even with empty rows (empty is allowed; such rows cannot take Titipan).
  - "Terbitkan" (`bukaTerbit`): opens the sheet.
  - Scrim / "Kembali" (`tutupSheet`): closes the sheet.
  - "Terbitkan, berlaku mulai Desember 2026" (`terbitkan`): `st = terbit`, closes the sheet, pops to `/MataAnggaran` where the 2026.2 card sweeps.
  - No typed input, no timers.
- **Motion** Versi view `pudar` 0.2 s; Rinci `masuk` 280 ms (push transition); "Terbitkan" button `muncul` 0.3 s when it appears; sheet scrim `pudar` 0.2 s and panel `naik` 280 ms; published card overlay `sapu` 0.7 s ease-out, fill both: a `laut` layer over the whole card scales X 0 → 1 from the left at 20 % opacity (0–65 %), then fades to 0 (65–100 %). `sapu` is the card sweep of the `tinta` motion. The board also declares `cap` (no rotation variant) but never uses it.
- **Links out** Back arrow "Kembali ke Lainnya" → `/Lainnya` (pop if previous, else go). **Inbound**: Keputusan, Lainnya.
- **Mock data**
  - Versions: 2026.1 Diterbitkan, from September 2026, "Pendapatan 131 baris · Belanja 158 baris". 2026.2 Draf, proposed from December 2026, "2 baris baru · 1 nama berubah". Published by "Meiske L., 16/11/2026".
  - Belanja rows (No. MA, name, tag, initial Boleh untuk): 5.00.00.00 "BELANJA OPERASIONAL" (group heading); 5.01.02.00 "Listrik, air dan telepon" — Milik sendiri; 5.03.03.00 "Biaya administrasi bank" — Milik sendiri; 5.06.01.00 "Internet dan langganan aplikasi", Baru — empty; 4.03.03.00 "Diakonia duka dan sakit", Nama berubah — Milik sendiri.
  - Pendapatan rows: 1.3.53.00.00 "PERSEMBAHAN" (group heading); 1.3.53.07.00 "Persembahan Ibadah Minggu" — Milik sendiri; 1.3.53.09.00 "Persembahan syukur" — Milik sendiri; 2.1.01.02.00 "DANA TRANSIT Sentralisasi Sinode", Baru — Titipan; 1.4.10.02.00 "Sumbangan donatur" — Keduanya.
- **Prototype-only** none.
- **Acceptance checks**
  1. Open `/MataAnggaran` → 2026.2 card dashed with badge "Draf" and "Belum berlaku · usulan berlaku mulai Desember 2026"; 2026.1 card reads "Berlaku mulai September 2026 · versi yang sedang dipakai".
  2. Tap the 2026.2 card → `/MataAnggaran/rinci`, Belanja tab, five rows; "Belanja 5.06.01.00" reads "Boleh untuk: belum diisi" in `bata`; footer "1 baris belum punya “Boleh untuk”. Boleh dibiarkan kosong; baris itu tidak dapat menerima titipan." above "Tandai sudah diperiksa".
  3. Tap "Titipan" on that row → value "Titipan", footer "Semua baris contoh sudah punya “Boleh untuk”."
  4. Press "Tandai sudah diperiksa" → header badge "Sudah diperiksa" (`laut` line), footer "Sudah diperiksa. Mengubah isi mengembalikan versi ini ke Draf.", "Terbitkan" fades up.
  5. Tap the selected "Milik sendiri" on 5.01.02.00 → that row reads "belum diisi", badge back to "Draf", button back to "Tandai sudah diperiksa".
  6. Check again → "Terbitkan" → sheet; press "Terbitkan, berlaku mulai Desember 2026" → back on `/MataAnggaran`; 2026.2 card has a solid `tinta` line, badge "Diterbitkan", a `laut` sweep over 700 ms, text "Berlaku mulai Desember 2026 · diterbitkan oleh Meiske L., 16/11/2026"; 2026.1 reads "Berlaku mulai September 2026 · dipakai sampai November 2026".
  7. Open Rinci after publishing → chips do not respond; footer "Diterbitkan. Versi ini tidak dapat diubah lagi." with no button.
  8. Pendapatan tab → "Pendapatan 1.3.53.00.00" "PERSEMBAHAN" shows "Judul kelompok, tidak dapat dibukukan" and no chips; "Pendapatan 2.1.01.02.00" carries the "Baru" tag.
  9. `jabatanKosong` on → the line "Menjalankan jabatan kosong · Bendahara Jemaat" sits above the header; after publishing the card reads "… diterbitkan oleh Yanti Sumual, Operator, 16/11/2026".
- **Notes**
  - The sheet title is 20 px; the 2026.1 badge uses padding 4 10 while other badges use 3 9 (copy both).
  - The `sapu` overlay sits inside an `sc-if` of the Versi view, so on the board it replays every time the Versi view is shown while published (for example after visiting Rinci). Motion is meant only for a change of status: recommended to play it once, on the return after "Terbitkan", and show the plain published card afterwards.
  - The board has no visual disabled style on the chips after publishing; give them disabled semantics only.
  - On the board the sheet sits inside the content area, below the jabatanKosong line. Build the sheet as an overlay inside the board's content area (not a root `showModalBottomSheet`) so that line stays uncovered.
  - Phone rows prefix the tree name to the number ("Belanja 5.06.01.00") in mono; web shows the number only.

---

### WebMataAnggaran — Web · Terbitkan Mata Anggaran

- **Source** `docs/design/handoff/canvas/boards/WebMataAnggaran.dc.html` · page Web (`web`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebMataAnggaran`, no child routes (the publish confirmation is an inline panel) · **Widget** `WebMataAnggaranScreen` in `lib/screens/web/web_mata_anggaran.dart`
- **Purpose** Laptop version of MataAnggaran for the Bendahara Jemaat: the whole version on one page as a table, with the three-step Tahapan and an inline confirmation. Bendahara journey step 1. Same decisions as MataAnggaran (D22, D19, PemilihMataAnggaran rules, D23), plus the Tahapan component (steps of a Mata Anggaran version) and the web rule that the phone's bottom sheet becomes in-page content.
- **Shell** Web side nav, active item "Pengaturan". Footer: jabatanKosong off "**Meiske L.** · Bendahara" / "Wewenang Bendahara aktif" (two lines, name 700 `tinta`); on "**Yanti Sumual** · Operator" / "Menjalankan jabatan kosong Bendahara Jemaat".
- **Layout** Main column, top to bottom:
  1. PitaJabatanKosong (web), only when `jabatanKosong` is on.
  2. Breadcrumb link "Pengaturan" 14/600 `laut` (hover `lautTua`), then title "Mata Anggaran" `judulHalaman` 26/700, 2 above.
  3. Version card: clips its children, radius 16, padding 18 20, wrapping row, align centre, gap 14 vertical / 28 horizontal. Draf: transparent field, 1.5 dashed `putus`; Sudah diperiksa and Diterbitkan: `permukaan`, 1.5 solid `tinta`. `sapu` overlay when published. Three blocks:
     - Block A (`flex 1 1 260`): "Versi 2026.2" 20/700 + status badge (same three looks as MataAnggaran, gap 10); below, `{vTeks}` 14 `tinta2`.
     - Block B, Tahapan (gap 8, 13/600): three chips "1 · Draf", "2 · Sudah diperiksa", "3 · Diterbitkan", min height 32, padding 0 12, radius 999. A step at or before the current one: `tinta` field, `permukaan` text, 1.5 solid `tinta`. A later step: transparent, `tinta3` text, 1.5 dashed `putus`.
     - Block C (column, right-aligned, gap 6): Draf → secondary "Tandai sudah diperiksa" (min height 46, padding 0 20, radius 12, 1.5 `tinta` border, `permukaan`, 700). Sudah diperiksa and no confirmation open → primary "Terbitkan" (46, padding 0 20, radius 12, `laut`, `diLaut`, 700). Otherwise nothing.
  4. Confirmation panel (only while open; appears with `muncul`): `tinta` field (ditutup: permanent statement), `permukaan` text, radius 16, padding 18 20, wrapping row, gap 14 28. Text block (`flex 1 1 380`): "Versi yang diterbitkan tidak dapat diubah." 18/700; "Perubahan berikutnya harus menjadi versi baru. Versi 2026.2 berlaku mulai Desember 2026; transaksi sampai November 2026 tetap memakai versi 2026.1." 14 `diTinta`. Button "Terbitkan, berlaku mulai Desember 2026": `permukaan` field, `tinta` text, min height 46, padding 0 20, radius 12, 700. Text button "Kembali": `permukaan` text, min height 46, padding 0 12, 700.
  5. Tab row (wrap, gap 8): chips "Belanja · 158 baris", "Pendapatan · 131 baris" (min height 44, padding 0 16, radius 999, 14/600); then `{kosongTeks}` (`flex 1 1 260`, 14 `tinta2`, 8 left padding).
  6. Table card: `permukaan`, 1 `garis`, radius 14, scrolls horizontally, inner min width 860. Grid columns 170 px | `minmax(0, 1.4fr)` | 190 px | 330 px, gap 16.
     - Header row (padding 12 18, 13/600 `tinta2`): "No. MA", "Nama Mata Anggaran", "Jenis baris", "Boleh untuk".
     - Body rows (min height 56, padding 6 18, 1 `garis` top border, align centre): group heading on `kertas`, postable row on `permukaan`. No. MA mono 14. Name weight 700 (heading) or 500, then a space and the tag if any ("Baru"/"Nama berubah", same tag as phone, no wrap). Jenis 14 `tinta2`: "Judul kelompok, tidak dapat dibukukan" or "Dapat dibukukan". Boleh untuk (postable rows only): chips "Milik sendiri", "Titipan", "Keduanya" in a row, gap 6, min height 44, padding 0 12, radius 10, 13/600. Selected: `tinta` field/`permukaan` text. Unselected: `permukaan`, `tinta` text, border `garisTegas` when the row has a value, `bata` when the row is empty (the "garis bata" the hint mentions).
  7. Footnote 13 `tinta3`: "Contoh 6 dari {158|131} baris {Belanja|Pendapatan}. Nomor dan nama ditampilkan persis seperti tersimpan. Hanya baris bertanda “Dapat dibukukan” yang dapat dipilih pada transaksi, tidak ditebak dari akhiran nomornya. Baris tanpa “Boleh untuk” tidak dapat menerima titipan."
- **Components** LencanaStatus, Tahapan, ChipPilihan (tabs, Boleh untuk), Tombol (secondary, primary, the light button on the dark panel, text), PitaJabatanKosong (web), web side nav. The confirmation panel is the web form of the phone's LembarBawah content.
- **Internal views and states** Initial state `{ st: 'draf', tab: 'Belanja', konfirmasi: false, boleh: { '5.01.02.00': 'Milik sendiri', '5.03.03.00': 'Milik sendiri', '5.06.01.00': '', '4.03.03.00': 'Milik sendiri', '2.2.01.02.00': 'Titipan', '1.3.53.07.00': 'Milik sendiri', '1.3.53.09.00': 'Milik sendiri', '2.1.01.02.00': 'Titipan', '1.4.10.02.00': 'Keduanya', '1.4.10.03.00': '' } }`.
  - Status `draf` → `periksa` → `terbit`; `konfirmasi` open/closed while `periksa`.
  - `vTeks`: before publishing "2 baris baru · 1 nama berubah dibanding versi 2026.1 · usulan berlaku mulai Desember 2026"; published "Berlaku mulai Desember 2026 · diterbitkan oleh Meiske L., 16/11/2026 · tidak dapat diubah".
  - `kosongTeks`: n > 0 "{n} baris belum punya “Boleh untuk” (ditandai garis bata). Diisi atas keputusan Pimpinan Jemaat yang berwenang."; n = 0 "Semua baris contoh sudah punya “Boleh untuk”." n counts both tabs (initially 2: 5.06.01.00 and 1.4.10.03.00).
- **Tweaks** `jabatanKosong` (boolean, default off) — Keadaan panel, global switch. On: web PitaJabatanKosong above the breadcrumb; nav footer shows Yanti Sumual; `tukarJk` enabled, so the published `vTeks` reads "… diterbitkan oleh Yanti Sumual, Operator, 16/11/2026 · tidak dapat diubah".
- **Interactions**
  - Tab chip: switches rows and the footnote's count and tree name.
  - Boleh untuk chip (`pick`): ignored when published; else select, or clear when the selected chip is tapped; sets `st = draf` and closes the confirmation.
  - "Tandai sudah diperiksa" (`periksa`): `st = periksa`; Tahapan fills step 2.
  - "Terbitkan" (`bukaTerbit`): opens the confirmation panel; the "Terbitkan" button disappears while it is open.
  - "Kembali" (`batalTerbit`): closes the panel; "Terbitkan" returns.
  - "Terbitkan, berlaku mulai Desember 2026" (`terbitkan`): `st = terbit`, panel closes, all three steps filled, card turns solid and sweeps, chips stop responding.
  - No typed input, no timers.
- **Motion** Confirmation panel `muncul` 0.3 s on open. Card overlay `sapu` 0.7 s ease-out on the change to Diterbitkan (one `laut` layer over the version card, same keyframes as MataAnggaran). No other animation; no screen transition inside the board.
- **Links out** Breadcrumb "Pengaturan" → `/WebPengaturan` (pop if previous, else go). Side nav items (go). **Inbound**: WebPengaturan.
- **Mock data** Same versions and dates as MataAnggaran. Six rows per tab:
  - Belanja: 5.00.00.00 "BELANJA OPERASIONAL" (heading); 5.01.02.00 "Listrik, air dan telepon" — Milik sendiri; 5.03.03.00 "Biaya administrasi bank" — Milik sendiri; 5.06.01.00 "Internet dan langganan aplikasi", Baru — empty; 4.03.03.00 "Diakonia duka dan sakit", Nama berubah — Milik sendiri; 2.2.01.02.00 "DANA TRANSIT Penyaluran Sentralisasi Sinode", Baru — Titipan.
  - Pendapatan: 1.3.53.00.00 "PERSEMBAHAN" (heading); 1.3.53.07.00 "Persembahan Ibadah Minggu" — Milik sendiri; 1.3.53.09.00 "Persembahan syukur" — Milik sendiri; 2.1.01.02.00 "DANA TRANSIT Sentralisasi Sinode", Baru — Titipan; 1.4.10.02.00 "Sumbangan donatur" — Keduanya; 1.4.10.03.00 "Sumbangan natura", Baru — empty.
- **Prototype-only** none.
- **Acceptance checks**
  1. Open `/WebMataAnggaran` at 1440 → nav "Pengaturan" active; card dashed with "Draf"; Tahapan shows "1 · Draf" filled and steps 2–3 dashed; hint "2 baris belum punya “Boleh untuk” (ditandai garis bata). …".
  2. Row 5.06.01.00 shows three unselected chips with `bata` borders; tap "Milik sendiri" → that row's other chips turn `garisTegas`; hint "1 baris belum punya …".
  3. Press "Tandai sudah diperiksa" → badge "Sudah diperiksa", step 2 filled, "Terbitkan" shown.
  4. Press "Terbitkan" → dark panel fades up; "Terbitkan" button gone. Press "Kembali" → panel gone, "Terbitkan" back.
  5. Open the panel, change any chip → panel closes, badge "Draf", button "Tandai sudah diperiksa".
  6. Publish → badge "Diterbitkan", three steps filled, card solid `tinta` with a 700 ms `laut` sweep, `vTeks` "Berlaku mulai Desember 2026 · diterbitkan oleh Meiske L., 16/11/2026 · tidak dapat diubah"; chips no longer respond.
  7. Pendapatan tab → footnote "Contoh 6 dari 131 baris Pendapatan. …"; heading row on `kertas`.
  8. Window 860 wide → side nav collapses behind "Menu"; the table scrolls sideways inside its card.
  9. `jabatanKosong` on → dark banner above the breadcrumb and the Yanti Sumual footer.
- **Notes**
  - No. MA is mono 14 (the `kode` token is 13; copy 14). Version title 20 px (off-token).
  - Tahapan chips are 32 tall and weight 600; the component says 30 and 700. Copy the board.
  - The manifest lists `hasSideNav: false` only because the nav is built in JS; the board has the standard side nav.
  - Web shows two rows the phone does not (2.2.01.02.00, 1.4.10.03.00), so the counts differ from the phone; keep each board's own rows.

---

### Bendahara — 9 · Bendahara, sesi, serah terima

- **Source** `docs/design/handoff/canvas/boards/Bendahara.dc.html` · page Ponsel (`ponsel`) · form Phone 390×844 · interactive yes
- **Route** `/Bendahara` plus child route `/Bendahara/serah` · **Widget** `BendaharaScreen` in `lib/screens/ponsel/bendahara.dart`
- **Purpose** The active Bendahara Jemaat sees their authority and signed-in sessions, ends other sessions, and starts the handover to a new Bendahara; the board also shows the locked state when no Bendahara is active. Bendahara journey step 6. Shows D21 (the handover is started by the active Bendahara), P07 (account recovery returns access to the same person; changing the person is always a handover), R04 (revocation 16/11/2026 08.10), master-file row 12 (no current Bendahara: read-only with the "Belum ada Bendahara aktif" banner, and the Operator may run the vacant post), PitaPeran (locking state), RangkaianKoreksi (the 2 px `tinta` connector between the old and new Bendahara).
- **Shell** Utama: phone header with back (to Lainnya). Serah: phone header with back (to Utama) and the phone action bar. Kosong: no header, no tab bar.
- **Layout**
  *Kosong* (tweak "Belum ada Bendahara aktif"; scroll, padding 24 20 28, gap 18; no entry animation):
  1. Locking panel (PitaPeran, ditutup field): `tinta`, `permukaan` text, radius 16, padding 18, gap 8. "Belum ada Bendahara aktif" 19/700 (off-token). "Wewenang Meiske Lumentut dicabut pada 16/11/2026 08.10 oleh Petugas verifikasi, atas permintaan BPMJ. Semua sesinya sudah diakhiri." 14 `diTinta`. "**Yang perlu bertindak: BPMJ Jemaat Karunia.**" (`permukaan`) " BPMJ menunjuk Bendahara baru dan mengirim surat penunjukannya untuk diverifikasi." 14 `diTinta`. "Sementara itu, Operator Jemaat dapat " + link "menjalankan jabatan kosong" (`permukaan`, 700, underlined) + " ini. Setiap tindakannya tercatat atas namanya." 14 `diTinta`.
  2. 15 px: "**Semua data hanya dapat dilihat.** Mencatat, membukukan, rekonsiliasi dan tutup buku tidak tersedia sampai ada Bendahara aktif."
  3. Card (`permukaan`, 1 `garis`, radius 14, padding 4 16), three rows space-between, gap 16, padding 12 0, `garis` dividers; label 14 `tinta2`: "Saldo buku semua Kas/Bank" | "Rp38.415.000" mono 14/500; "Draf yang tertinggal" | "2 · belum masuk saldo" 14/600; "Bulan berikutnya untuk tutup buku" | "Oktober 2026" 14/600.
  4. 13 `tinta3`: "Riwayat tetap mencatat Meiske Lumentut sebagai pelaku semua tindakannya. Bendahara baru tidak mewarisi persetujuan yang pernah dicatat."

  *Utama* (`/Bendahara`, `pudar`): header back link (`aria-label` "Kembali ke Lainnya") + "Bendahara dan sesi"; content padding 8 20 24, gap 18:
  1. Active Bendahara card (terpilih line): `permukaan`, 1.5 solid `tinta`, radius 16, padding 16, gap 4. Row: `{namaAktif}` 18/700 + badge "Wewenang Bendahara aktif" (`laut` field, `diLaut` text, radius 6, padding 4 10, 13/700). `{aktifSejak}` 14 `tinta2`. After a handover: 13 `tinta3`, top border 1 dashed `garisTegas`, 8 above and inside: "Sebelumnya: Meiske Lumentut · wewenang berakhir 16/11/2026. Riwayat tetap mencatatnya sebagai pelaku."
  2. Sessions: "Sesi yang sedang masuk" `judulBagian` 16/700; 8 below, card (`permukaan`, 1 `garis`, radius 14, padding 0 16); rows min height 60, `garis` top border after the first: name 15/600, subtitle 13 `tinta3`, and "Akhiri sesi" for every session except "Ponsel ini" (min height 44, padding 0 12, radius 10, 1.5 `garisTegas`, `permukaan`, 14/700).
  3. Before a handover only: secondary button "Serah terima Bendahara" (min height 52, radius 14, 1.5 `tinta`, `permukaan`, 700, centred); 8 below, 13 `tinta3`: "Pemulihan akun mengembalikan akses orang yang sama dan tidak memerlukan penunjukan baru. Mengganti orangnya selalu lewat serah terima."

  *Serah terima* (`/Bendahara/serah`, `masuk`): header back button (`aria-label` "Kembali") + "Serah terima Bendahara"; content padding 8 20 20, gap 6:
  1. Old Bendahara card: `permukaan`, radius 14, padding 14 16; border 1.5 solid `tinta` before, 1.5 solid `tinta3` after. Row: "Meiske Lumentut" 700 + badge (13/700, radius 6, padding 3 9, 1.5 border): before "Wewenang Bendahara aktif" (`laut` field, `diLaut` text, `laut` border); after "Wewenang berakhir" (`permukaan`, `tinta2` text, `tinta3` border). Subtitle 13 `tinta3`: before "Tetap aktif sampai Bendahara baru diverifikasi"; after "Berakhir 16/11/2026 · semua sesi diakhiri".
  2. Connector: 2 × 22 `tinta` bar, 28 from the left (RangkaianKoreksi "linked to").
  3. New Bendahara card: radius 14, padding 14 16, gap 10; before activation transparent with 1.5 dashed `putus` (draf), after `permukaan` with 1.5 solid `tinta`. Row: "Bendahara baru" 700 + badge: "Belum dikirim" or "Menunggu verifikasi wewenang" (transparent, `tinta2` text, 1.5 dashed `putus`), or "Wewenang Bendahara aktif" (`laut` field and border, `diLaut` text).
     - Belum: label "Nama yang ditunjuk" 14 `tinta2`, 6 below; text input min height 48, padding 0 14, radius 12, 1 `garisTegas`, `permukaan`, value `{nama}`. Then 14 `tinta2`: "Surat penunjukan baru: " + "**SK-BPMJ-09-2026.pdf · Terlampir**" (700 `tinta`).
     - Tunggu: row gap 12: spinner 34 × 34 (viewBox 88: circle r 38, stroke `tinta` 6, dash 9 10, rotating, see Motion), then `role=status` 14: "**{nama}** · menunggu Petugas verifikasi memeriksa surat penunjukan."
     - Aktif: `role=status` 14, appears with `muncul`: "**{nama}** · aktif sejak 16/11/2026 · SK-BPMJ-09-2026".
  4. Explainer, 14 above, 14 `tinta2`, gap 6: "Yang terjadi saat wewenang berpindah" 700 `tinta`; "Semua sesi Bendahara lama diakhiri saat itu juga."; "Bendahara baru tidak mewarisi persetujuan yang pernah dicatat Bendahara lama."; "Riwayat tetap mencatat Bendahara lama sebagai pelaku tindakannya."; "Sampai verifikasi selesai, Bendahara lama tetap aktif. Tidak pernah ada dua Bendahara aktif."
  5. Action bar: Belum → if the name is blank, "Isi nama yang ditunjuk." 14 `tinta2`; then "Kirim untuk diverifikasi" (min height 52, radius 14, 700, centred; enabled look `laut`/`diLaut`, unmet look `garis`/`tinta3`). Tunggu → centred 14 `tinta2`, min height 52: "Menunggu verifikasi wewenang. Tidak ada yang perlu Anda lakukan." Aktif → secondary "Lihat Bendahara dan sesi" (52, radius 14, 1.5 `tinta`, `permukaan`, 700), appearing with `muncul`.
- **Components** PitaPeran (Kosong panel), LencanaModul (post badges Aktif / Berakhir), RangkaianKoreksi (old card, 2 px connector, new card), TombolBersyarat ("Kirim untuk diverifikasi"), Tombol (secondary, "Akhiri sesi"), text input (`size-isian` 48). The waiting spinner is a board pattern.
- **Internal views and states** Initial state `{ screen: 'utama', tahap: 'belum', nama: 'Yohanis Tumbelaka', sesi: ['Ponsel ini', 'Chrome di laptop'] }`.
  - Kosong: whenever the tweak is "Belum ada Bendahara aktif", on either route; replaces Utama and Serah.
  - Utama (`/Bendahara`), Serah (`/Bendahara/serah`).
  - `tahap`: `belum` → `tunggu` → `aktif` (after 2800 ms). After `aktif`: Utama shows the new name, `aktifSejak` "Aktif sejak 16/11/2026 · SK-BPMJ-09-2026", the "Sebelumnya" note, sessions replaced by one row "Belum ada sesi" / "Semua sesi Meiske Lumentut diakhiri 16/11/2026" (no button), and no handover button. Before: "Meiske Lumentut", "Aktif sejak 15/09/2026 · SK-BPMJ-04-2026".
  - Sessions list shrinks as sessions are ended.
- **Tweaks** `keadaan` (enum "Bendahara aktif" · "Belum ada Bendahara aktif", default "Bendahara aktif") — Keadaan panel. "Bendahara aktif": Utama / Serah as above. "Belum ada Bendahara aktif": only the Kosong view, whatever the route and `tahap`.
- **Interactions**
  - "Akhiri sesi" (`akhiri`): removes that session row at once; no confirmation.
  - "Serah terima Bendahara" (`keSerah`): push `/Bendahara/serah`.
  - Back in Serah, and "Lihat Bendahara dan sesi" (`keUtama`): pop to `/Bendahara`.
  - Name input (`onNama`): every keystroke updates `nama`; no formatting, no length limit. The condition is `nama.trim()` not empty; the value is shown as typed.
  - "Kirim untuk diverifikasi" (`kirim`), TombolBersyarat: (1) name not blank, else stays in its unmet look with "Isi nama yang ditunjuk." above and the press does nothing. The condition is re-read at press time, so the first press after typing works. When met: `tahap = tunggu`, then a 2800 ms timer (replaces any running one) sets `tahap = aktif`. The timer fakes the Petugas verifikasi checking the appointment letter. It belongs to the board, not the Serah route: going back to Utama during the wait keeps it running and Utama updates when it fires; cancel it only when the board leaves the stack.
  - Link "menjalankan jabatan kosong" (Kosong): push `/JabatanKosong`.
- **Motion** Utama `pudar` 0.2 s; Serah `masuk` 280 ms (push transition); spinner `putar` 6 s linear, infinite (stops under reduce motion); aktif status line and "Lihat Bendahara dan sesi" `muncul` 0.3 s. The board declares `tali` (height 0 → 22, the connector growing) and `cap` but uses neither; draw the connector static.
- **Links out** Back link "Kembali ke Lainnya" → `/Lainnya` (pop if previous, else go); "menjalankan jabatan kosong" → `/JabatanKosong` (push). **Inbound**: Keluar, Keputusan, Lainnya.
- **Mock data** Meiske Lumentut, active since 15/09/2026, SK-BPMJ-04-2026, authority ended 16/11/2026. New Bendahara default "Yohanis Tumbelaka", letter "SK-BPMJ-09-2026.pdf", active 16/11/2026. Sessions "Ponsel ini" ("Sesi ini · aktif sekarang") and "Chrome di laptop" ("Terakhir dipakai 14/11/2026 20.15"). Kosong: revoked 16/11/2026 08.10 by Petugas verifikasi at BPMJ's request; Saldo buku "Rp38.415.000"; 2 drafts; next month to close "Oktober 2026".
- **Prototype-only** none listed by the handoff. The 2800 ms auto-verification stands for another person (Petugas verifikasi) and stays on screen as the board has it.
- **Acceptance checks**
  1. Open `/Bendahara` → card "Meiske Lumentut" with `laut` badge "Wewenang Bendahara aktif" and "Aktif sejak 15/09/2026 · SK-BPMJ-04-2026"; two sessions; "Akhiri sesi" only on "Chrome di laptop".
  2. Press "Akhiri sesi" → the "Chrome di laptop" row disappears.
  3. Press "Serah terima Bendahara" → `/Bendahara/serah` slides in; input shows "Yohanis Tumbelaka"; new card dashed with "Belum dikirim"; "Kirim untuk diverifikasi" in `laut`.
  4. Clear the input (or type only spaces) → "Isi nama yang ditunjuk." appears above a `garis` button; pressing does nothing.
  5. Type "Rina Pangkey" and press at once → badge "Menunggu verifikasi wewenang", rotating dashed circle, "Rina Pangkey · menunggu Petugas verifikasi memeriksa surat penunjukan.", footer "Menunggu verifikasi wewenang. Tidak ada yang perlu Anda lakukan."
  6. 2800 ms later → old card "Wewenang berakhir" with "Berakhir 16/11/2026 · semua sesi diakhiri"; new card solid with `laut` badge; "Rina Pangkey · aktif sejak 16/11/2026 · SK-BPMJ-09-2026"; "Lihat Bendahara dan sesi" fades up.
  7. Press it → `/Bendahara` shows "Rina Pangkey", "Aktif sejak 16/11/2026 · SK-BPMJ-09-2026", the dashed-topped "Sebelumnya: …" note, one session row "Belum ada sesi", no handover button.
  8. Start the handover, press back during the wait → Utama still shows Meiske; after 2800 ms it switches to the new name.
  9. Tweak `keadaan` = "Belum ada Bendahara aktif" (on `/Bendahara` or `/Bendahara/serah`) → only the dark panel view; "menjalankan jabatan kosong" opens `/JabatanKosong`.
  10. Reduce motion on → the spinner does not turn; views appear without slide.
- **Notes**
  - "Belum ada Bendahara aktif" is 19 px (off-token).
  - The "Sebelumnya" divider is 1 px dashed `garisTegas`, not the 1.5 `putus` draf line; copy the board.
  - The unmet reason "Isi nama yang ditunjuk." is not in the "Tidak dapat dilakukan: …" form of TombolBersyarat. Copy the board's sentence.
  - The Kosong view has no back control on the board; system and browser Back still return. Do not add one.
  - Second session differs from WebPengaturan ("Chrome di laptop" 14/11/2026 20.15 here, "Ponsel Android" 16/11/2026 10.42 there); keep each.

---

### WebPengaturan — Web · Pengaturan

- **Source** `docs/design/handoff/canvas/boards/WebPengaturan.dc.html` · page Web (`web`) · form Laptop page (preview 1440×1300) · interactive yes
- **Route** `/WebPengaturan`, no child routes · **Widget** `WebPengaturanScreen` in `lib/screens/web/web_pengaturan.dart`
- **Purpose** Laptop settings page for the Bendahara Jemaat: everything on the phone's Lainnya hub, Kas/Bank, Aturan, Bendahara dan sesi and Riwayat aktivitas on one page, plus links to the laptop settings boards. Also shows the read-only state when no Bendahara is active (viewed by the technical administrator). Not named in the handoff's journey list; it is the laptop hub from which Bendahara journey steps 1 and 6 are opened. Shows D21, D23 (deactivation and the switch start from a later month), R04 and master-file row 12 (the locked state), Q26 (laptop layout for the Bendahara desk post), the Sakelar rule.
- **Shell** Web side nav, active item "Pengaturan". Footer `{penggunaTeks}` (plain 13 `tinta2`): "Bendahara aktif" → "Meiske L. · Bendahara · Wewenang Bendahara aktif"; "Belum ada Bendahara aktif" → "Anda masuk sebagai Pengelola teknis. Hanya dapat melihat."
- **Layout** Main column:
  1. Title "Pengaturan" 26/700; below, 14 `tinta2`: "Pengaturan tidak diubah di tempat. Setiap perubahan berlaku mulai bulan tertentu dan tidak mengubah transaksi yang sudah dibukukan."
  2. Link row, pulled up 8 (wrap, gap 0 22, 14/600 `laut`, each min 44 × 44): "Tambah dan ubah", "Persetujuan format laporan", "Wajib pemeriksa kedua", "Serah terima Bendahara", "Akun dan keluar".
  3. Locked banner (only "Belum ada Bendahara aktif"; PitaPeran, ditutup field): `tinta`, `permukaan` text, radius 16, padding 18 20, gap 6. "Belum ada Bendahara aktif" 19/700. 14 `diTinta`: "Wewenang Meiske Lumentut dicabut pada 16/11/2026 08.10 oleh Petugas verifikasi. Semua data hanya dapat dilihat. " + "**Yang perlu bertindak: BPMJ Jemaat Karunia**" (`permukaan`) + ", dengan menunjuk Bendahara baru dan mengirim surat penunjukannya untuk diverifikasi."
  4. Two-column grid: `repeat(auto-fit, minmax(min(420px, 100%), 1fr))`, gap 20, items top-aligned (two columns at 1440, one column when the content is narrower than about 860). Each column is a column of cards, gap 20. Every card: `permukaan`, 1 `garis`, radius 14, padding 16 18 (Kas/Bank and Bendahara: 16 18 6); section titles 17/700 (off-token).
     Left column:
     - a. "Jemaat Karunia" with link "Pengaturan awal Jemaat" (14/600, min 44) on the right (baseline, space-between); "WITA · tahun buku mulai 1 Januari (tidak dapat diubah)" 14 `tinta2`; "Tanggal mulai pencatatan 15 September 2026 · bulan pertama pencatatan September 2026" 14 `tinta2`; link "Ekspor data Jemaat" (14/600, 4 above, min 44).
     - b. "Kas/Bank" (6 below): four rows min height 56 with `garis` top borders, gap 12: name 600 (`tinta2` for the inactive one, else `tinta`), subtitle 13 `tinta3`, and "Nonaktifkan" for allowed rows (min 44, padding 0 12, radius 10, 1.5 `garisTegas`, `permukaan`, 14/700; disabled when no Bendahara is active). Then 13 `tinta3`, padding 10 0: "Yang sudah dipakai hanya dapat dinonaktifkan, berlaku mulai bulan berikutnya yang belum berjalan."
     - c. Gap-10 card with three blocks separated by `garis` (padding-top 10): "Peruntukan" / "Umum Jemaat · Diakonia · Pembangunan"; "Lingkup" / "Jemaat · Kolom 3 · BIPRA Pemuda · Komisi Diakonia · Panitia Natal"; "Seri No. Bukti" / "BKU-2026-0001 Biasa · OPN-2026-0001 Saldo awal pencatatan · ADJ-2026-0001 Penyesuaian" (14 `tinta2`, the three codes mono `tinta`) / "Nomor dibuat aplikasi saat Bukukan, tidak pernah diketik." 13 `tinta3`.
     Right column:
     - d. "Mata Anggaran" with link "Buka versi 2026.2"; "Versi 2026.1 · Diterbitkan · berlaku mulai September 2026" and "Versi 2026.2 · Draf · usulan berlaku mulai Desember 2026", 14 `tinta2`.
     - e. "Aturan persetujuan dan dokumen pendukung" (gap 10); 14 `tinta2`: "Persetujuan di luar aplikasi wajib untuk Belanja Rp2.000.000 ke atas. Dokumen pendukung wajib untuk semua Belanja; Bendahara boleh memverifikasi unggahannya sendiri. Pemberi pengecualian: Ketua BPMJ."; then, below a `garis` divider (padding-top 10), row: "Wajib pemeriksa kedua" 600 over `{mcStatus}` 13 `tinta3`, and the Sakelar (same dimensions and colours as Lainnya; disabled when no Bendahara is active). When on, `muncul`, 14: "**Berlaku mulai Desember 2026.** " + "Belum ada pemeriksa kedua yang ditunjuk; tanpa itu Bukukan akan ditolak mulai Desember 2026." (600 `bata`) + " Transaksi sebelumnya tidak terpengaruh."
     - f. "Format laporan" with link "Lihat laporan"; "Bawaan Palakat v1 · Persetujuan format: sudah dicatat · 01/11/2026" 14 `tinta2`.
     - g. "Bendahara dan sesi": card border 1 `garis` (active) or 1.5 solid `tinta` (none active). Header row (wrap, space-between, gap 8 12, 8 below): title + badge (13/700, radius 6, padding 4 10, `permukaan` text, 1.5 border): "Wewenang Bendahara aktif" on `laut` / "Belum ada Bendahara aktif" on `tinta`. `{benSub}` 14 `tinta2`, padding-bottom 10: active "Meiske Lumentut · aktif sejak 15/09/2026 · SK-BPMJ-04-2026" (the locked text is under Tweaks). Session rows (active only): min 56, `garis` top border; name 600, subtitle 13 `tinta3`; "Akhiri sesi" for all but "Browser ini" (same style as Nonaktifkan). Active only, a final row (`garis` top border, padding 12 0 10, wrap, gap 10 16): link-button "Serah terima Bendahara" (min 44, padding 0 16, radius 12, 1.5 `tinta`, `permukaan`, 14/700 `tinta`, no underline) and 13 `tinta3` (`flex 1 1 200`): "Bendahara baru memerlukan surat penunjukan baru dan tidak mewarisi persetujuan yang pernah dicatat."
  5. "Riwayat aktivitas" 17/700, 10 below a table card (`permukaan`, 1 `garis`, radius 14, horizontal scroll, inner min width 640). Grid 160 px | 190 px | `minmax(0, 1fr)`, gap 16. Header (padding 12 18, 14/600 `tinta2`): "Waktu", "Pelaku", "Tindakan". Rows (padding 12 18, `garis` top border, 14 px): time mono 13 `tinta2`, actor 600, action.
- **Components** PitaPeran (locked banner), Sakelar, LencanaModul (Bendahara badge), Tombol (secondary small buttons, link-button), web side nav. The settings cards, the Kas/Bank and session rows and the history table are board patterns.
- **Internal views and states** Initial state `{ non: {}, mc: false, sesi: ['Browser ini', 'Ponsel Android'] }`. One page, no internal views. Per Kas/Bank: active · scheduled (`non[id] = true`) · inactive. Switch off/on. Sessions list. Tweak-driven Bendahara aktif / Belum ada.
- **Tweaks** `keadaan` (enum "Bendahara aktif" · "Belum ada Bendahara aktif", default "Bendahara aktif") — Keadaan panel. "Belum ada Bendahara aktif": locked banner under the link row; Nonaktifkan buttons and the switch disabled (they keep their look but give disabled semantics and ignore presses); Bendahara card gets the 1.5 `tinta` border, badge "Belum ada Bendahara aktif", `benSub` "Meiske Lumentut · Wewenang dicabut 16/11/2026 · Riwayat tetap mencatatnya sebagai pelaku tindakannya.", no sessions, no handover row; Riwayat gets a new first row "16/11/2026 08.10 · Petugas verifikasi · Mencabut wewenang Bendahara Meiske Lumentut · semua sesi diakhiri" and drops every row dated 16/11/2026 (the "Membukukan BKU-2026-0147" row); nav footer "Anda masuk sebagai Pengelola teknis. Hanya dapat melihat." The link row and the other links stay active.
- **Interactions**
  - "Nonaktifkan" (`non`): marks that Kas/Bank scheduled at once (no sheet, no month choice); subtitle becomes "Aktif sampai akhir November 2026 · nonaktif mulai Desember 2026"; button gone. Disabled in the locked state.
  - Sakelar (`toggleMc`): only when a Bendahara is active; flips `mc`. Status off "Mati · Bendahara memeriksa dan membukukan sendiri", on "Hidup mulai Desember 2026".
  - "Akhiri sesi" (`akhiri`): removes the "Ponsel Android" row.
  - No typed input, no timers.
- **Motion** Switch-on sentence `muncul` 0.3 s. Sakelar track background and knob 160 ms (`sentuh`). Nothing else.
- **Links out** Drill-ins use push (each target links back to Pengaturan): "Tambah dan ubah" → `/WebUbahPengaturan`; "Persetujuan format laporan" → `/WebFormatLaporan`; "Wajib pemeriksa kedua" → `/WebPemeriksa`; "Serah terima Bendahara" (link row and Bendahara card) → `/WebSerahTerima`; "Akun dan keluar" → `/WebKeluar`; "Pengaturan awal Jemaat" → `/WebAwal`; "Ekspor data Jemaat" → `/WebEkspor`; "Buka versi 2026.2" → `/WebMataAnggaran`; "Lihat laporan" → `/WebLaporan`. Side nav items (go); "Pengaturan" is the current page. **Inbound**: AIBulan, TabBeranda, TabCatat, TabTransaksi, WebAI, WebAIFoto, WebAIMataAnggaran, WebAlihPeruntukan, WebAwal, WebAwalIsian, WebBagi, WebBantuanAI, WebBeranda, WebBukti, WebCari, WebCatat, WebDokumen, WebDraf, WebEkspor, WebExcel, WebExcelTerbatas, WebFormatLaporan, WebHitungKas, WebImpor, WebKasUnit, WebKasus, WebKasusBaru, WebKejadian, WebKeluar, WebKesiapan, WebKewajiban, WebKoreksi, WebLaporan, WebLihatDokumen, WebLihatTransaksi, WebMataAnggaran, WebMemuat, WebPaketLaporan, WebPemberitahuan, WebPemeriksa, WebPengembalian, WebPersembahan, WebPersetujuan, WebPilihBulan, WebRekonIsi, WebRekonsiliasi, WebSambungan, WebSerahTerima, WebTanggal, WebTransaksi, WebTutupBuku, WebUbahPengaturan, WebUnggah (mostly through the side nav).
- **Mock data**
  - Kas/Bank: "Kas", "Bank BNI ··4821", "Bank SulutGo ··1107" ("Aktif · dipakai sejak September 2026"); "Kas Panitia HUT" ("Nonaktif sejak November 2026 · tetap tampil di laporan lama").
  - Series BKU-2026-0001, OPN-2026-0001, ADJ-2026-0001. Format approval 01/11/2026. Mata Anggaran 2026.1 / 2026.2 as on MataAnggaran.
  - Bendahara: Meiske Lumentut, active since 15/09/2026, SK-BPMJ-04-2026. Sessions "Browser ini" ("Sesi ini · aktif sekarang"), "Ponsel Android" ("Terakhir dipakai 16/11/2026 10.42").
  - Riwayat (Waktu · Pelaku · Tindakan): 16/11/2026 10.42 · Meiske L. · "Membukukan BKU-2026-0147"; 12/11/2026 09.31 · Meiske L. · "Membuat pembalikan BKU-2026-0144 · alasan: Mata Anggaran keliru"; 28/10/2026 16.44 · Meiske L. · "Menonaktifkan Kas Panitia HUT · berlaku mulai November 2026"; 05/10/2026 19.02 · Meiske L. · "Menutup buku September 2026"; 03/10/2026 10.15 · Meiske L. · "Mencatat persetujuan format laporan"; 15/09/2026 10.15 · Petugas verifikasi · "Mengaktifkan wewenang Bendahara untuk Meiske Lumentut".
- **Prototype-only** none.
- **Acceptance checks**
  1. Open `/WebPengaturan` at 1440 → nav "Pengaturan" active; two card columns; three "Nonaktifkan" buttons; Bendahara badge "Wewenang Bendahara aktif" on `laut` over "Meiske Lumentut · aktif sejak 15/09/2026 · SK-BPMJ-04-2026"; Riwayat six rows starting "16/11/2026 10.42".
  2. Press "Nonaktifkan" on "Kas" → its subtitle reads "Aktif sampai akhir November 2026 · nonaktif mulai Desember 2026" and its button is gone.
  3. Toggle "Wajib pemeriksa kedua" → status "Hidup mulai Desember 2026"; the sentence with the `bata` part fades up.
  4. Press "Akhiri sesi" on "Ponsel Android" → row removed; "Browser ini" stays without a button.
  5. Tweak "Belum ada Bendahara aktif" → dark banner under the link row; Nonaktifkan and switch do nothing; Bendahara card 1.5 `tinta` line, badge "Belum ada Bendahara aktif", no sessions, no "Serah terima Bendahara" button in the card; Riwayat first row "16/11/2026 08.10 · Petugas verifikasi · Mencabut wewenang Bendahara Meiske Lumentut · semua sesi diakhiri", no "Membukukan BKU-2026-0147"; nav footer "Anda masuk sebagai Pengelola teknis. Hanya dapat melihat."
  6. Click "Buka versi 2026.2" → `/WebMataAnggaran`; its breadcrumb "Pengaturan" returns.
  7. Window 860 wide → nav behind "Menu"; cards in one column; the history table (inner min width 640) still fits. Below about 680 px wide it scrolls sideways inside its card.
- **Notes**
  - Section titles 17 px, banner title 19 px (off-token).
  - Format approval date 01/11/2026 here vs 03/10/2026 on Lainnya (and Lainnya's Riwayat 03/10/2026). Keep each board's own figure; list in mock-data.md.
  - Last booking BKU-2026-0147 at 16/11/2026 10.42 here vs BKU-2026-0146 at 15/11/2026 12.20 on Lainnya; keep each.
  - The web deactivation has no month choice (always from Desember 2026) while the phone offers two months; copy each.
  - The board has no `jabatanKosong` tweak.

---

### Persembahan — 10 · Persembahan dengan beberapa bagian

- **Source** `docs/design/handoff/canvas/boards/Persembahan.dc.html` · page Keuangan · P2 dan P3 (`lanjut`) · form Phone 390×844 · interactive yes
- **Route** `/Persembahan` plus child route `/Persembahan/hasil` · **Widget** `PersembahanScreen` in `lib/screens/lanjut/persembahan.dart`
- **Purpose** The Bendahara Jemaat records the Sunday offering of 15 November 2026 as one transaction in three parts (Tunai, QRIS, Transfer bank), each with its owner (Milik sendiri, or Titipan untuk: Sinode) and its own Kas/Bank, adds named envelopes, picks the counters, then posts it with one No. Bukti. Bendahara journey step 2. Shows D01 (Kas/Bank is never pre-filled: QRIS starts without one), D19 (Titipan goes to the DANA TRANSIT row, not to Pendapatan), Q32 (named envelopes seen only by the giver and the Bendahara Jemaat), master-file row 7 (one combined "Periksa dan bukukan"), TombolBersyarat, and the `tinta` motion on posting.
- **Shell** Isi: phone header with back (to Main, `aria-label` "Kembali ke Beranda") and the phone action bar; no tab bar. Hasil: no header, no back control. PitaJabatanKosong (phone) above both when `jabatanKosong` is on.
- **Layout**
  *Isi* (`/Persembahan`, `pudar`):
  1. Header: back link; title column "Persembahan" 18/700 and "Ibadah Minggu · 15 November 2026" 13 `tinta2`.
  2. Scrolling content, padding 8 20 20, gap 16:
     - a. Totals: "Jumlah (Rp) · semua bagian" 14 `tinta2`; `{total}` mono 36/500, letter-spacing −1, line-height 1.15 (off-token); "Milik sendiri {sendiri} · Titipan {titipan}" 13 `tinta2` with both amounts mono.
     - b. Three part cards (`permukaan`, 1 `garis`, radius 14, padding 14 16, column gap 10):
       - Row (gap 10): label (the part name, 15/700, flex 1, tied to the input) and the amount field, 160 wide, mono, 1.5 `tinta` underline, baseline row gap 4: "Rp" 14 `tinta3`, input mono 18/500 right-aligned, min height 44, numeric keyboard, placeholder "—".
       - "Uang siapa" 13 `tinta2`, 6 below; chips "Milik sendiri", "Titipan untuk: Sinode" (radius 10, padding 0 12, 6 apart, 13/600).
       - "Masuk ke Kas/Bank" 13 `tinta2`, 6 below; chips "Kas", "Bank BNI ··4821", "Bank SulutGo ··1107" (radius 999, padding 0 12, 6 apart, 13/600). They wrap onto two lines at 390 with run spacing 0: the board gives each chip only a 6 px right margin, so "Bank SulutGo ··1107" sits directly under the first line.
       - Mata Anggaran line 13 `tinta3`: Milik sendiri → "Pendapatan 1.3.53.07.00 Persembahan Ibadah Minggu"; Titipan → "Pendapatan 2.1.01.02.00 DANA TRANSIT Sentralisasi Sinode".
     - c. Sampul bernama card (`permukaan`, 1 `garis`, radius 14, padding 12 16, gap 8): "Sampul bernama" 15/600; "Bagian dari jumlah di atas; tidak menambah total. Nama hanya dilihat pemberinya dan Bendahara Jemaat." 13 `tinta3`. Envelope rows (`garis` top border, padding-top 6, gap 12): name 15 (flex), amount mono 15, text button "Lepas nama" (min 44, padding 0 10, `laut` 14/700). When envelopes exceed the total: 14 px "**Tidak dapat dilakukan: Periksa dan bukukan.**" (700 `bata`) + " Jumlah sampul bernama melebihi jumlah persembahan." (`tinta`). Action row (wrap, gap 4 16): secondary small "Catat nama pemberi" (min 44, padding 0 16, radius 14, 1.5 `tinta`, `permukaan`, 14/700; hidden once two envelopes are listed) and link "Aturan nama pemberi" (14/700 `laut`, min 44).
     - d. Counters: "Petugas penghitung" 14 `tinta2`, 8 below; multi-select chips "Dkn. Olga Tamba", "Pnt. Jefry Wowor", "Meiske L." (radius 999, padding 0 14, margin right 8 bottom 8, 14/600). Then the attached sheet box: radius 12, 1 `garisTegas`, `permukaan`, padding 12 14: "lembar-penghitungan-15-11.jpg · Terlampir" 14/600; "Lembar penghitungan persembahan · Diunggah, belum diverifikasi" 13 `tinta2`.
  3. Action bar: when unmet, "Tidak dapat dilakukan: {alasan}" 14/600 `bata`; button "Periksa dan bukukan" (min height 52, radius 14, 700, centred; met `laut`/`diLaut`, unmet `garis`/`tinta3`).

  *Hasil* (`/Persembahan/hasil`, `masuk`):
  1. Top block padding 24 20 8: "Sudah dibukukan" `judulBesar` 22/700; "Satu persembahan, satu No. Bukti, {bagianN} bagian." 14 `tinta2`.
  2. Scrolling content, padding 12 20 20, gap 16:
     - a. Posted card (terpilih line): `permukaan`, 1.5 solid `tinta`, radius 16, padding 18, gap 6, clips children; `sapu` overlay. Row space-between: badge "Dibukukan" (`tinta` field, `permukaan`, radius 6, padding 4 10, 13/700) and the stamp "No. Bukti BKU-2026-0148" (mono 14/600 `laut`, 2 `laut` border, radius 8, padding 4 10, stamped with `cap`, ends rotated −3°). `{total}` mono 30/500, margin-top 6 on top of the card's 6 gap. "Persembahan Ibadah Minggu" 600.
     - b. Card (`permukaan`, 1 `garis`, radius 14, padding 4 16), two rows space-between, gap 12, padding 12 0, divider `garis`: "Pendapatan bulan ini" 15/600 / "Bagian milik sendiri" 13 `tinta3` | "+ {sendiri}" mono 500; "Titipan untuk: Sinode" 15/600 / "Uang titipan untuk pihak lain, bukan Pendapatan" 13 `tinta3` | "+ {titipan}" mono 500.
     - c. Next-step box (draf line: 1.5 dashed `putus`), radius 14, padding 14 16, gap 8: 14 px "**{tunaiKas} tunai sekarang ada di Kas.**" + " Bila disetor, catat sebagai Pindah antar Kas/Bank. Setoran ke bank bukan Pendapatan baru." Then link-button "Catat setoran ke bank": min height 44, radius 12, 1.5 `tinta`, `permukaan`, `tinta` 16/700, centred, no underline.
- **Components** IsianJumlah (part amounts; board sizes, see Notes), ChipPilihan (owner, Kas/Bank, counters), TombolBersyarat ("Periksa dan bukukan"), Penolakan (envelope overflow sentence), LencanaStatus ("Dibukukan"), Tombol (secondary, text, link-button), PitaJabatanKosong (phone). Named-envelope rows and the attached-file box are board patterns.
- **Internal views and states** Initial state `{ posted: false, petugas: ['Dkn. Olga Tamba'], bagian: [{ id: 'tunai', n: 'Tunai', v: '2350000', milik: 'sendiri', akun: 'kas' }, { id: 'qris', n: 'QRIS', v: '800000', milik: 'sendiri', akun: '' }, { id: 'tf', n: 'Transfer bank', v: '450000', milik: 'titipan', akun: 'bni' }] }`; `sampul` absent (empty list).
  - Isi (`posted: false`) and Hasil (`posted: true`).
  - Within Isi: button met/unmet with reason; envelopes 0, 1 or 2; overflow sentence on/off.
  - Derived: `sendiri` = sum of Milik sendiri parts; `titipan` = sum of Titipan parts; `total` = both; `bagianN` = parts with a value above 0; `tunaiKas` = sum of parts whose Kas/Bank is Kas (whatever their name).
- **Tweaks** `jabatanKosong` (boolean, default off) — Keadaan panel, global switch. On: the phone PitaJabatanKosong line above Isi and Hasil. `tukarJk` is disabled on this board, so no name changes (the counter chip stays "Meiske L.").
- **Interactions**
  - Amount input (`on`), per keystroke: keep digits only, strip leading zeros before another digit (a lone "0" stays), cap at 11 digits, store the digits, display them with dot thousands ("2350000" → "2.350.000"), caret at the end. Empty is allowed (shows "—", counts as 0). Totals update live.
  - Owner chip: sets that part's owner; the Mata Anggaran line, `sendiri` and `titipan` follow.
  - Kas/Bank chip: sets that part's Kas/Bank (tapping the selected one keeps it; there is no clear).
  - Counter chip: toggles that person in or out; any number may be selected, including none.
  - "Catat nama pemberi" (`tambahSampul`): appends the next sample envelope by count: first "Novita Wenas" Rp100.000, then "Agustina Lasut" Rp250.000; the button hides at two.
  - "Lepas nama" (`hapus`): removes that envelope.
  - Envelope overflow: when the envelopes add up to more than `total`, the overflow sentence shows in the card. On the board it does not change the button.
  - "Periksa dan bukukan" (`bukukan`), TombolBersyarat, first unmet reason wins, sentence above the button "Tidak dapat dilakukan: {alasan}":
    1. Total is 0 → "semua bagian masih kosong."
    2. The first part with a value above 0 and no Kas/Bank → "Kas/Bank untuk bagian {nama} belum dipilih." (initially "Kas/Bank untuk bagian QRIS belum dipilih.")
    3. No counter selected → "petugas penghitung belum dipilih."
    When met: `posted = true`, go to `/Persembahan/hasil` with `replace` so Back leaves the board instead of returning to an editable form. The board has no way back from Hasil to Isi (`isIsi` is `!posted`): because `/Persembahan/hasil` is nested under `/Persembahan`, make sure the Isi page is not left under Hasil (for example, `/Persembahan` shows Hasil or redirects to `/Persembahan/hasil` while `posted` is true), so that Back from Hasil reaches the route before the board. Keep the button pressable while unmet and re-check on press; the first press after typing works because state updates per keystroke.
  - "Catat setoran ke bank": go to `/Main`.
  - Back link: pop to `/Main` if previous, else go.
- **Motion** Isi `pudar` 0.2 s. Hasil `masuk` 280 ms. On Hasil, the `tinta` motion in three parts: card overlay `sapu` 0.7 s ease-out (laut layer scales in from the left at 20 % opacity, then fades out); stamp `cap` 0.55 s `Cubic(.2,.8,.2,1)`, delay 0.35 s, fill both (opacity 0 / scale 1.7 / rotate −9° → 55 %: opacity 1 / scale 0.94 / rotate −3° → scale 1 / rotate −3°); then `muncul` 0.3 s on the Pendapatan row at 0.5 s, the Titipan row at 0.7 s, the dashed box at 0.9 s (hidden until each starts). No timers.
- **Links out** Back "Kembali ke Beranda" → `/Main`; "Aturan nama pemberi" → `/PersembahanBernama` (push); "Catat setoran ke bank" → `/Main` (go). **Inbound**: Main (the "Catatan lain" chip "Persembahan").
- **Mock data** Ibadah Minggu, 15 November 2026. Parts: Tunai Rp2.350.000 Milik sendiri → Kas; QRIS Rp800.000 Milik sendiri → (none); Transfer bank Rp450.000 Titipan untuk: Sinode → Bank BNI ··4821. Initial totals: total Rp3.600.000, Milik sendiri Rp3.150.000, Titipan Rp450.000. Mata Anggaran 1.3.53.07.00 Persembahan Ibadah Minggu; 2.1.01.02.00 DANA TRANSIT Sentralisasi Sinode. Kas/Bank: Kas, Bank BNI ··4821, Bank SulutGo ··1107. Counters: Dkn. Olga Tamba (selected), Pnt. Jefry Wowor, Meiske L. Envelopes: Novita Wenas Rp100.000, Agustina Lasut Rp250.000. File "lembar-penghitungan-15-11.jpg". No. Bukti BKU-2026-0148.
- **Prototype-only** "Catat nama pemberi" fills fixed sample names instead of opening the giver picker (PersembahanBernama "Pilih pemberi"). It is not one of the handoff's listed devices; keep it on screen as drawn.
- **Acceptance checks**
  1. Open `/Persembahan` → total "Rp3.600.000", "Milik sendiri Rp3.150.000 · Titipan Rp450.000"; QRIS has no Kas/Bank chip selected; footer "Tidak dapat dilakukan: Kas/Bank untuk bagian QRIS belum dipilih." above a `garis` button.
  2. Tap "Bank BNI ··4821" on QRIS → reason gone, button `laut`.
  3. In Tunai type "0012a345" → field shows "12.345"; total "Rp1.262.345".
  4. Switch Transfer bank to "Milik sendiri" → its line reads "Pendapatan 1.3.53.07.00 Persembahan Ibadah Minggu"; "Titipan Rp0".
  5. Empty all three fields → "Tidak dapat dilakukan: semua bagian masih kosong."
  6. With Kas/Bank chosen for every part, deselect "Dkn. Olga Tamba" → "Tidak dapat dilakukan: petugas penghitung belum dipilih."
  7. Press "Catat nama pemberi" twice → rows "Novita Wenas Rp100.000" and "Agustina Lasut Rp250.000"; the button disappears; "Lepas nama" on Novita removes it and the button returns.
  8. Lower the parts to total Rp300.000 with both envelopes listed → the overflow sentence appears.
  9. From the initial state pick "Bank BNI ··4821" for QRIS and press "Periksa dan bukukan" → `/Persembahan/hasil`: "Sudah dibukukan", "Satu persembahan, satu No. Bukti, 3 bagian.", 700 ms sweep, stamp "No. Bukti BKU-2026-0148" lands tilted, rows rise at 0.5/0.7/0.9 s; "+ Rp3.150.000", "+ Rp450.000", "Rp2.350.000 tunai sekarang ada di Kas."
  10. Press "Catat setoran ke bank" → `/Main`; browser Back does not return to the editable form.
- **Notes**
  - Off-token sizes: total 36 px (Isi) and 30 px (Hasil), part inputs 18 px with a 1.5 underline (IsianJumlah says `jumlahIsian` 30 and a 2 px underline). Copy the board.
  - The Mata Anggaran numbers in the part lines are not mono on the board; CONVENTIONS says every No. MA is mono. Recommended: render the number part ("1.3.53.07.00", "2.1.01.02.00") in mono 13.
  - The refusal sentence lacks the "{tindakan}." part of the TombolBersyarat form. Copy the board's sentence.
  - The envelope overflow sentence says "Tidak dapat dilakukan: Periksa dan bukukan." but the board does not block the button. Follow the board (button stays enabled) and list it for the product owner.
  - After "Lepas nama" on the first envelope, the board's next "Catat nama pemberi" adds by count, so "Agustina Lasut" can appear twice. Recommended: add the first sample name not already listed.
  - `tunaiKas` counts every part sent to Kas, so choosing Kas for QRIS gives "Rp3.150.000 tunai …"; keep the board's arithmetic.
  - Initial button is unmet on open (the form is pre-filled), which TombolBersyarat allows because the fields are already filled in.
  - The board sets `disabled` on "Periksa dan bukukan" while unmet (also on WebPersembahan). The TombolBersyarat guideline asks for a button that stays pressable and re-checks (`onPressed` not null) so the reason can be read out; follow the guideline. A press while unmet does nothing.

---

### WebPersembahan — Web · Persembahan

- **Source** `docs/design/handoff/canvas/boards/WebPersembahan.dc.html` · page Keuangan · P2 dan P3 (`lanjut`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebPersembahan`, no child routes (posting changes the page in place) · **Widget** `WebPersembahanScreen` in `lib/screens/lanjut/web_persembahan.dart`
- **Purpose** Laptop version of Persembahan for the Bendahara Jemaat: parts as a row of cards and a summary panel on the right that turns from draft to posted. Bendahara journey step 2. Same decisions as Persembahan (D01, D19, Q32, master-file row 7), with the posted state shown by the line language (dashed → solid) and a fading stamp.
- **Shell** Web side nav, active item "Transaksi". Footer as WebMataAnggaran (Meiske L. / Yanti Sumual by `jabatanKosong`).
- **Layout** Main column:
  1. PitaJabatanKosong (web) when `jabatanKosong` is on.
  2. Breadcrumb "Transaksi" 14/600 `laut`; title "Persembahan" 26/700 followed by " · Ibadah Minggu · 15 November 2026" 15/500 `tinta3` (same line).
  3. Body: wrapping row, gap 24, top-aligned.
     - Left (`flex 999 1 560`): grid `repeat(auto-fit, minmax(min(250px, 100%), 1fr))`, gap 16 (three cards across at 1440). Part card: `permukaan`, 1 `garis`, radius 14, padding 16, column gap 12. Label 16/700. Amount row: mono, 2 `tinta` underline, padding-bottom 4, baseline gap 6: "Rp" 16 `tinta3`, input mono 26/500 left-aligned, min height 44, numeric keyboard, placeholder "—". "Uang siapa" 13 `tinta2` + wrapping chips (gap 6, radius 10) "Milik sendiri", "Titipan untuk: Sinode". "Masuk ke Kas/Bank" 13 `tinta2` + wrapping chips (gap 6, radius 999) "Kas", "Bank BNI ··4821", "Bank SulutGo ··1107". Mata Anggaran line 13 `tinta3` (same texts as phone).
     - Right aside (`flex 1 1 320`, column gap 14):
       - a. Summary card: radius 16, padding 18, gap 8. Draft: transparent, 1.5 dashed `putus`; posted: `permukaan`, 1.5 solid `tinta`. Row space-between: badge (13/700, radius 6, padding 3 9) "Draf · belum masuk saldo" (transparent, `tinta2`, 1.5 dashed `putus`) or "Dibukukan" (`tinta` field, `permukaan`, 1.5 `tinta`); when posted, the stamp "No. Bukti BKU-2026-0148" (mono 14/600 `laut`, 2 `laut` border, radius 8, padding 4 10, appears with `muncul` 0.4 s, no rotation). `{total}` mono 34/500, letter-spacing −1. Rows space-between 14 px: "Milik sendiri · menjadi Pendapatan" (`tinta2`) | `{sendiri}` mono; "Titipan untuk: Sinode · bukan Pendapatan" (`tinta2`) | `{titipan}` mono.
       - b. Sampul bernama card: identical to the phone card (copy, sizes, rows, overflow sentence, "Catat nama pemberi", link "Aturan nama pemberi").
       - c. Card (`permukaan`, 1 `garis`, radius 14, padding 14 16, 14 px): "Lembar penghitungan persembahan · Terlampir" 600; "Petugas penghitung: Dkn. Olga Tamba, Pnt. Jefry Wowor" `tinta2`. Static.
       - d. Draft only: "Tidak dapat dilakukan: {alasan}" 14/600 `bata` when unmet; button "Periksa dan bukukan" (min height 50, radius 12, 700, centred; met `laut`/`diLaut`, unmet `garis`/`tinta3`).
       - e. Posted only, `muncul` 0.3 s: dashed box (1.5 dashed `putus`, radius 14, padding 14 16, 14 px): "**{tunaiKas} tunai sekarang ada di Kas.**" + " Setoran ke bank dicatat sebagai Pindah antar Kas/Bank, bukan Pendapatan baru." No button.
- **Components** IsianJumlah, ChipPilihan, TombolBersyarat, LencanaStatus (Draf · belum masuk saldo / Dibukukan), Penolakan (envelope overflow), Tombol, PitaJabatanKosong (web), web side nav.
- **Internal views and states** Initial state `{ posted: false, bagian: [{ id: 'tunai', n: 'Tunai', v: '2350000', milik: 'sendiri', akun: 'kas' }, { id: 'qris', n: 'QRIS', v: '800000', milik: 'sendiri', akun: '' }, { id: 'tf', n: 'Transfer bank', v: '450000', milik: 'titipan', akun: 'bni' }] }`; `sampul` empty. Draft and Posted, same page. No counter state on web.
- **Tweaks** `jabatanKosong` (boolean, default off) — Keadaan panel, global switch. On: web PitaJabatanKosong, nav footer Yanti Sumual. `tukarJk` disabled; no other change.
- **Interactions**
  - Amount input: same digit rules as Persembahan (digits only, no leading zeros, max 11, dot thousands). Ignored once posted (make the fields read-only after posting; they keep their look).
  - Owner and Kas/Bank chips: as Persembahan; ignored once posted.
  - "Catat nama pemberi" / "Lepas nama" / overflow sentence: as Persembahan.
  - "Periksa dan bukukan" (`bukukan`), TombolBersyarat, first unmet reason: (1) total 0 → "semua bagian masih kosong."; (2) first part with value and no Kas/Bank → "Kas/Bank untuk bagian {nama} belum dipilih.". No counter condition on web. When met: `posted = true`; the reason and button go, the summary card turns solid, badge "Dibukukan", stamp fades in, dashed note fades in. Re-check on press; the first press after typing works.
  - No timers.
- **Motion** Stamp `muncul` 0.4 s (fill both) on posting; dashed note `muncul` 0.3 s. No sweep or `cap` on web. The board declares `isi` (width 0 → 100 %) and `titik` (opacity pulse) but uses neither.
- **Links out** Breadcrumb "Transaksi" → `/WebTransaksi` (pop if previous, else go); "Aturan nama pemberi" → `/WebPersembahanBernama` (push); side nav (go). **Inbound**: TabCatat, WebCatat (their "Persembahan" link).
- **Mock data** As Persembahan (parts, totals Rp3.600.000 / Rp3.150.000 / Rp450.000, envelopes, No. Bukti BKU-2026-0148), plus the static counters line "Dkn. Olga Tamba, Pnt. Jefry Wowor".
- **Prototype-only** "Catat nama pemberi" sample names, as Persembahan.
- **Acceptance checks**
  1. Open `/WebPersembahan` at 1440 → nav "Transaksi" active; three part cards in one row; summary card dashed with "Draf · belum masuk saldo" and "Rp3.600.000"; "Tidak dapat dilakukan: Kas/Bank untuk bagian QRIS belum dipilih." above a `garis` button.
  2. Pick "Kas" for QRIS → reason gone, button `laut`.
  3. Press "Periksa dan bukukan" → summary card solid `tinta` line, badge "Dibukukan", "No. Bukti BKU-2026-0148" fades up; button gone; dashed note "Rp3.150.000 tunai sekarang ada di Kas. Setoran ke bank dicatat sebagai Pindah antar Kas/Bank, bukan Pendapatan baru."
  4. After posting, typing in Tunai or pressing an owner chip changes nothing.
  5. Empty all amounts before posting → "Tidak dapat dilakukan: semua bagian masih kosong."
  6. Window 860 wide → nav behind "Menu"; the aside wraps below the part cards.
  7. `jabatanKosong` on → the dark banner above the breadcrumb, footer "Yanti Sumual · Operator".
  8. Breadcrumb "Transaksi" → `/WebTransaksi`.
- **Notes**
  - Total 34 px, inputs 26 px (off-token); copy.
  - On the board the envelope buttons still work after posting (only `set()` is locked). Recommended: also ignore "Catat nama pemberi" and "Lepas nama" once posted, since a posted record does not change.
  - Counters are fixed text on web, a chooser on the phone; the web has no counter condition. Keep each.
  - Mata Anggaran numbers in the part lines: render in mono, as for Persembahan.
