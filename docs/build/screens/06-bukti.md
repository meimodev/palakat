# Screens 06: Bukti, WebBukti, Impor, WebImpor, Ekspor, WebEkspor, WebAI, Dokumen, WebDokumen, Draf, WebDraf

These eleven boards are the Bendahara Jemaat's back-office finance screens from the canvas pages "Keuangan · P2 dan P3" (`lanjut`) and "Pelengkap" (`lengkap`). Bukti/WebBukti list the Bukti Kas of November 2026 and the unused numbers in each series; Impor/WebImpor walk one spreadsheet (`kas-november.xlsx`) through the four import steps of D34; Ekspor/WebEkspor fake the preparation of the Jemaat's full export (2800 ms) and end on an honest "belum lengkap" result; WebAI is the laptop month-end page for October 2026 with the optional AI panel and its cost limit; Dokumen/WebDokumen decide supporting documents (verify, reject, exception, detach, retry); Draf/WebDraf handle a draft dated in closed September 2026 (refusal of Bukukan, Pindah tanggal, Batalkan, Hapus draf, edit conflict). The phone boards are reached from Lainnya (Bukti, Impor, Ekspor, Dokumen) and Main (Draf) and have no tab bar, only a header with a back arrow; the web boards sit under the standard side nav and are reached from WebTransaksi and the tablet TabTransaksi (WebBukti, WebImpor, WebDraf), WebPaketLaporan (WebBukti), WebPengaturan (WebEkspor), WebTutupBuku (WebAI, WebDokumen) and WebKasusBaru, WebKoreksi, WebLihatDokumen, WebUnggah (WebDokumen). In every section "up link" means the phone back arrow or the web breadcrumb above the h1: it pops when its target is the route directly beneath, otherwise it does `go` to the target. Drill-ins into other boards are `push`; side-nav items are `go`. All boards show the same "today": 16/11/2026, actor Meiske L., Bendahara.

---

### Bukti — 16 · Daftar Bukti Kas dan celah nomor
- **Source** `docs/design/handoff/canvas/boards/Bukti.dc.html` · page Keuangan · P2 dan P3 (`lanjut`) · form Phone 390×844 · interactive yes
- **Route** `/Bukti`, no child routes (the two chips switch content in place) · **Widget** `BuktiScreen` in `lib/screens/lanjut/bukti.dart`
- **Purpose** Bendahara Jemaat, journey step 5 ("15 · Laporan", A4 pages, "16 · Daftar Bukti Kas dan celah nomor"). Shows that every No. Bukti is listed, reversed transactions stay in the list, each row states its approval and supporting-document status, and the "Celah nomor" view lists numbers given out but never used (R03: 0111 and 0124 are unused numbers on the voucher list). LencanaStatus rule "Dibalik always carries the link" appears as the plain line "Dibalik oleh No. Bukti BKU-2026-0144".
- **Shell** Phone header with back, no tab bar. Phone root: `kertas` background, `tinta` text, `isi` (16/1.4). When `jabatanKosong` is on, a one-line PitaJabatanKosong strip sits above the header (see Layout 0).
- **Layout**
  0. (only when `jabatanKosong`) Strip, `role=status`: full-width `tinta` field, `permukaan` text, padding 10/24/8, 13 px line-height 1.3, centred: "**Menjalankan jabatan kosong** · Bendahara Jemaat". Not scrolled.
  1. Header row: padding 14 top, 12 sides, 8 bottom; gap 8. Back target 44×44 with chevron icon (`M15 6l-6 6 6 6`, 22 px, stroke 2, round caps, `tinta`), semantics "Kembali ke Lainnya". Title "Daftar Bukti Kas" (`judulLayar` 18/700); under it "November 2026 · Belum ditutup" (`keterangan` 13, `tinta2`).
  2. Chip row: padding 0 20 10. Two ChipPilihan chips "Daftar" and "Celah nomor": inline, min-height 44, padding 0 14, 8 px right margin, radius 999, border 1.5. Selected: `tinta` field and border, `permukaan` text. Unselected: `permukaan` field, `garisTegas` border, `tinta` text. Text 14/600. `aria-pressed` → selected semantics.
  3. Scroll area (fills the rest): padding 4 top, 20 sides, 24 bottom.
     - **Daftar view**: five cards, each 10 px below the previous: `permukaan`, 1 px `garis` (dibukukan), radius 14, padding 12/14, column gap 4. Line 1 (space-between, baseline, gap 8): left `kode` (mono 13, `tinta2`) "{No. Bukti} · {tanggal}", right `jumlah` (mono 16/500, `tinta`) amount. Line 2 Uraian 15/600. Optional line "{tanda}" 13 `tinta2`. Optional line "No. bukti asal " + mono value, 13 `tinta2`. Then "Persetujuan: {…}" 13 `tinta2` with a 1 px `garis` top rule, padding-top 6, margin-top 2. Then "Dokumen pendukung: {…}" 13, `tinta2` weight 400, or `bata` weight 700 when the document is missing (row 3 only). Rows below in Mock data. After the cards: caption "Contoh 5 dari 51. Transaksi yang dibalik tetap ada di daftar." 13 `tinta3`.
     - **Celah nomor view**: column, gap 10.
       a. Card terpilih: `permukaan`, 1.5 `tinta` border, radius 14, padding 14/16, gap 4. Title 15/700 "Seri Biasa · `BKU-2026-0001` sampai `0151`" (codes mono). "**3 nomor tanpa transaksi**" 14. Three lines 14 `tinta2`, each starting with the mono code in `tinta`: "BKU-2026-0111 · diberikan 14/10/2026 10.20, pembukuannya tidak selesai. Nomor ini tidak dipakai ulang." / "BKU-2026-0124 · diberikan 29/10/2026 16.05, pembukuannya tidak selesai. Nomor ini tidak dipakai ulang." / "BKU-2026-0126 · diberikan 30/10/2026 09.12, pembukuannya tidak selesai. Nomor ini tidak dipakai ulang."
       b. Card dibukukan (`permukaan`, 1 px `garis`, radius 14, padding 14/16): "Seri OPN Saldo awal pencatatan" 15/700; "Tidak ada celah" 14 `tinta2`.
       c. Same card: "Seri ADJ Penyesuaian" 15/700; "Belum pernah dipakai" 14 `tinta2`.
       d. Caption "Hanya terlihat oleh yang melihat seluruh Jemaat." 13 `tinta3`.
- **Components** ChipPilihan (view chips), PitaJabatanKosong (phone strip). Cards follow GarisStatus (dibukukan; terpilih for the series with gaps). Repeated pattern, not a component: Bukti Kas row card (code/date + amount, uraian, flags, approval line, document line).
- **Internal views and states** Initial state `{ tab: 'Daftar' }`. Views: Daftar (default), Celah nomor (chip). No sheets, toasts or empty states.
- **Tweaks** `jabatanKosong` (boolean, default false) · Keadaan panel (global switch). On: shows strip 0. Text replacement is disabled on this board (`jk && false`), so "terverifikasi (oleh Meiske L.)" stays.
- **Interactions** Chip "Daftar" → `tab = 'Daftar'`; chip "Celah nomor" → `tab = 'Celah nomor'`. Rows are not pressable. Back arrow → up link to `/Lainnya`.
- **Motion** Celah nomor content fades in with `pudar` 200 ms each time that chip is chosen (the view is rebuilt). Daftar has no animation. Chip colours change instantly.
- **Links out** Back arrow (no label, "Kembali ke Lainnya") → `/Lainnya`, up link. **Inbound** Lainnya.
- **Mock data** Rows (No. Bukti · tanggal · amount · uraian · tanda/asal · persetujuan · dokumen):
  1. BKU-2026-0147 · 16/11/2026 · −Rp150.000 · Fotokopi warta jemaat · — · "tidak diperlukan (aturan: transaksi rutin)" · "diunggah, belum diverifikasi"
  2. BKU-2026-0146 · 15/11/2026 · Rp3.450.000 · Persembahan Ibadah Minggu · — · "tidak diperlukan (aturan: Pendapatan)" · "terverifikasi (oleh Meiske L.)"
  3. BKU-2026-0143 · 11/11/2026 · −Rp600.000 · Sewa sound system · — · "tidak diperlukan (aturan: transaksi rutin)" · "wajib, belum ada" (`bata` 700)
  4. BKU-2026-0139 · 09/11/2026 · −Rp750.000 · Konsumsi rapat majelis · tanda "Dibalik oleh No. Bukti BKU-2026-0144" · "tidak diperlukan (aturan: transaksi rutin)" · "terverifikasi (oleh Meiske L.)"
  5. BKU-2026-0137 · 08/11/2026 · −Rp4.500.000 · Renovasi pastori, termin 1 · No. bukti asal KW-0412 · "sudah dicatat · Pdt. Lidya Rondonuwu, Ketua BPMJ" · "dikecualikan (alasan: kuitansi menyusul, oleh Ketua BPMJ)"
  Series: Biasa BKU-2026-0001…0151 with gaps 0111 (14/10/2026 10.20), 0124 (29/10/2026 16.05), 0126 (30/10/2026 09.12); OPN; ADJ. Amounts through `rp()`.
- **Prototype-only** none on the board. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. Open `/Bukti` → "Daftar" chip filled `tinta`, five cards, first card reads "BKU-2026-0147 · 16/11/2026" and "−Rp150.000".
  2. Third card's last line "Dokumen pendukung: wajib, belum ada" is `bata` and bold; other document lines are `tinta2` regular.
  3. Fourth card shows "Dibalik oleh No. Bukti BKU-2026-0144"; fifth shows "No. bukti asal KW-0412" with KW-0412 in mono.
  4. Tap "Celah nomor" → content fades in over 200 ms; first card has a 1.5 `tinta` border and lists BKU-2026-0111, 0124, 0126.
  5. Tap "Daftar" → list returns without animation.
  6. Keadaan panel `jabatanKosong` on → strip "Menjalankan jabatan kosong · Bendahara Jemaat" appears above the header; card 2 still says "terverifikasi (oleh Meiske L.)".
  7. Back arrow → `/Lainnya`.
- **Notes** Card title size 15 and 600/700 weights are off-token (no 15 style on phone); copy them. "Contoh 5 dari 51." is a design caption, not one of the listed prototype devices; keep it on screen as drawn. Phone copy is lower case ("tidak diperlukan…", "wajib, belum ada") where web capitalises; keep each board's casing. Row 4 uses a plain text line for Dibalik, not a badge or link (web uses a badge); keep the board. The code in "Dibalik oleh No. Bukti BKU-2026-0144" is sans inside that line; keep it sans (board wins over the mono rule for codes inside running text). Manifest lists keyframes `isi`, `masuk`, `muncul` that this board never uses.

### WebBukti — Web · Daftar Bukti Kas dan celah nomor
- **Source** `docs/design/handoff/canvas/boards/WebBukti.dc.html` · page Keuangan · P2 dan P3 (`lanjut`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebBukti`, no child routes · **Widget** `WebBuktiScreen` in `lib/screens/lanjut/web_bukti.dart`
- **Purpose** Bendahara Jemaat on the laptop, journey step 5. Same as Bukti plus a full table with "No. bukti asal" as its own column (codes from old records shown apart from No. Bukti), the reversal row itself (BKU-2026-0144), and a third view "Daftar perlu tindakan" that is explicitly unofficial. R03 numbers 0111 and 0124 in the gaps.
- **Shell** Web side nav (shared by all six web boards in this file; specified once here):
  - Nav column: flex basis 220, padding 24/16, `permukaan`, 1 px `garis` right border, column gap 20.
  - Brand: Palakat mark 26×26 (rect 2,2,20,20 rx 6, 2 px dashed 3 3 `laut` stroke + filled right half `laut`, from the board's SVG) and "palakat" 18/700 line-height 1.1 over "Jemaat Karunia" 13 `tinta3`; padding 0 8, gap 10.
  - Items, exactly: Beranda → `/WebBeranda`, Transaksi → `/WebTransaksi`, Uang Muka dan Titipan → `/WebKewajiban`, Rekonsiliasi → `/WebRekonsiliasi`, Bulan dan tutup buku → `/WebTutupBuku`, Laporan → `/WebPaketLaporan`, Pengaturan → `/WebPengaturan`. Each min-height 44, padding 0 12, radius 10, weight 600, no underline. Active: `tinta` field, `permukaan` text; others transparent, `tinta` text. All `go`.
  - Footer: margin-top auto, padding 12/8/0, 1 px `garis` top rule, 13 `tinta2`: "**Meiske L.** · Bendahara" / "Wewenang Bendahara aktif" (name `tinta`). With `jabatanKosong`: "**Yanti Sumual** · Operator" / "Menjalankan jabatan kosong Bendahara Jemaat".
  - Below 860 px the nav becomes a top bar (row, wrap, padding 8/16, bottom border `garis`), with a toggle button at the right: min-height 44, padding 0 16, radius 14, 1.5 `tinta` border, `permukaan`, 14/700, label "Menu"; when open it is `tinta` field / `permukaan` text labelled "Tutup menu" and the items and footer show full-width below.
  - Main column: flex 999 1 560, padding 28 top, clamp(16, 3vw, 40) sides, 40 bottom, column gap 20; body `isiWeb` 15/1.45.
  - With `jabatanKosong` the first item of main is the web PitaJabatanKosong: `tinta` field, radius 14, padding 12/16, 14 px, `role=status`: "**Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15.**" then "Setiap tindakan dicatat sebagai dijalankan oleh Operator Yanti Sumual." in `diTinta2`.
  - On this board the active item is **Laporan**.
- **Layout**
  1. Title block: breadcrumb link "Laporan" (14/600, `laut`); h1 "Daftar Bukti Kas" (`judulHalaman` 26/700, margin-top 2) followed inline by "· November 2026 · Belum ditutup" (15/500, `tinta3`).
  2. Chip row (wrap, gap 8): "Daftar Bukti Kas", "Celah nomor", "Daftar perlu tindakan". Min-height 44, padding 0 16, radius 999, 1.5 border, 14/600, colours as Bukti chips.
  3. **Daftar Bukti Kas view**:
     a. Table card: `permukaan`, 1 px `garis`, radius 14, scrolls horizontally; inner min-width 960. Grid columns 130 · 110 · 92 · 1fr · 130 · 0.9fr · 0.9fr, gap 14, padding 12/18. Header row 13/600 `tinta2`: "No. Bukti", "No. bukti asal", "Tanggal", "Uraian", "Jumlah (Rp)" (right-aligned), "Persetujuan", "Dokumen pendukung". Body rows: 1 px `garis` top rule, 14 px, baseline-aligned. Cells: No. Bukti as a `laut` link in mono 13; No. bukti asal mono 13 `tinta2` ("—" when none); Tanggal `tinta2`; Uraian, optionally followed by a badge (13/700, 1.5 `tinta3` border, `tinta2` text, radius 6, padding 0 6, no wrap); amount mono right-aligned `tinta`; Persetujuan 13 `tinta2`; Dokumen pendukung 13, `tinta2` or `bata` (row "Wajib, belum ada", weight stays 400 on web).
     b. Caption 13 `tinta3`: "Contoh 6 dari 51 baris. No. Bukti dibuat aplikasi; nomor dari catatan lama tampil terpisah sebagai No. bukti asal. Transaksi yang dibalik tetap ada di daftar."
  4. **Celah nomor view**: grid auto-fit, min column min(320, 100%), gap 16. Cards padding 16/18, gap 6, radius 14, `permukaan`: (a) 1.5 `tinta` border, same text as Bukti card a but title in body size 15/700; (b) 1 px `garis`, title "Seri OPN Saldo awal pencatatan · `OPN-2026-0001`", "Tidak ada celah"; (c) "Seri ADJ Penyesuaian", "Belum pernah dipakai". Caption 13 `tinta3`: "Daftar celah nomor hanya terlihat oleh yang melihat seluruh Jemaat. Akses terbatas per peruntukan tidak melihat halaman ini."
  5. **Daftar perlu tindakan view**: (a) dashed box (draf line 1.5 dashed `putus`, radius 14, padding 12/16): "**Daftar perlu tindakan (tidak resmi)**" and "Bukan bagian laporan resmi dan tidak mengubah jumlah apa pun." 14 `tinta2`. (b) Card `permukaan`, 1 px `garis`, radius 14, padding 0 18, three rows: wrap, gap 8/16, min-height 56, padding 8 0, 1 px `garis` top rule from the second row. Left (flex 1 1 320): title 600, sub 13 `tinta3`. Right: link "Lihat transaksi" 14/700, min-height 44.
- **Components** ChipPilihan (view chips), LencanaStatus (badges "Pembalikan", "Dibalik oleh BKU-2026-0144": `tinta3` line, `tinta2` text), ButirPerhatian "Perlu tindakan" rows (without chevron, link instead), PitaJabatanKosong. Shared: web side nav. Pattern: data table with horizontal scroll.
- **Internal views and states** Initial `{ tab: 'Daftar Bukti Kas' }`. Views: Daftar Bukti Kas, Celah nomor, Daftar perlu tindakan. No sheets or toasts.
- **Tweaks** `jabatanKosong` (boolean, default false) · Keadaan panel (global switch). On: web banner appears at top of main, nav footer switches to Yanti Sumual. Text replacement disabled (`jk && false`).
- **Interactions** Each chip → `tab = <its label>`. No other handlers.
- **Motion** none (keyframes `muncul`, `isi`, `titik` are declared but unused).
- **Links out** "Laporan" breadcrumb → `/WebPaketLaporan`, up link. Each No. Bukti cell (6 links) → `/WebTransaksi`, push. Each "Lihat transaksi" (3) → `/WebTransaksi`, push. Side nav as in Shell. **Inbound** TabTransaksi, WebPaketLaporan, WebTransaksi.
- **Mock data** Rows (No. Bukti · asal · tanggal · uraian [badge] · jumlah · persetujuan · dokumen):
  1. BKU-2026-0147 · — · 16/11/2026 · Fotokopi warta jemaat · −Rp150.000 · Tidak diperlukan (aturan: transaksi rutin) · Diunggah, belum diverifikasi
  2. BKU-2026-0146 · — · 15/11/2026 · Persembahan Ibadah Minggu · Rp3.450.000 · Tidak diperlukan (aturan: Pendapatan) · Terverifikasi (oleh Meiske L.)
  3. BKU-2026-0144 · — · 12/11/2026 · Pembalikan BKU-2026-0139 [Pembalikan] · Rp750.000 · Tidak diperlukan (aturan: pembalikan) · Tidak diperlukan (aturan: pembalikan)
  4. BKU-2026-0143 · — · 11/11/2026 · Sewa sound system · −Rp600.000 · Tidak diperlukan (aturan: transaksi rutin) · Wajib, belum ada (`bata`)
  5. BKU-2026-0139 · — · 09/11/2026 · Konsumsi rapat majelis [Dibalik oleh BKU-2026-0144] · −Rp750.000 · Tidak diperlukan (aturan: transaksi rutin) · Terverifikasi (oleh Meiske L.)
  6. BKU-2026-0137 · KW-0412 · 08/11/2026 · Renovasi pastori, termin 1 · −Rp4.500.000 · Sudah dicatat · Pdt. Lidya Rondonuwu, Ketua BPMJ · Dikecualikan (alasan: kuitansi menyusul, oleh Ketua BPMJ)
  Perlu tindakan: "1 dokumen pendukung wajib, belum ada" / "BKU-2026-0143 · Sewa sound system · Rp600.000"; "2 draf belum dibukukan" / "Belum masuk saldo · Rp800.000"; "1 Mata Anggaran belum dipilih" / "Draf · Honor pemusik". Series as Bukti plus OPN-2026-0001.
- **Prototype-only** none. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. `/WebBukti` at 1440 → side nav "Laporan" filled `tinta`; table with 6 rows, header "Jumlah (Rp)" right-aligned.
  2. Row 3 shows badge "Pembalikan" and amount "Rp750.000"; row 5 badge "Dibalik oleh BKU-2026-0144".
  3. Row 6 "No. bukti asal" cell reads "KW-0412"; other rows read "—".
  4. Click "BKU-2026-0147" → `/WebTransaksi`; browser Back returns to `/WebBukti`.
  5. Click "Celah nomor" → three cards; second card title ends "· OPN-2026-0001".
  6. Click "Daftar perlu tindakan" → dashed notice and three rows each with "Lihat transaksi".
  7. At 860 px wide the table scrolls horizontally inside its card, page does not; nav shows "Menu".
  8. `jabatanKosong` on → banner "Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15." on top; nav footer "Yanti Sumual · Operator".
- **Notes** Persetujuan colour logic exists (`pfg`) but all rows use `tinta2`. On web "Wajib, belum ada" is `bata` without bold (phone is bold); keep each. Breadcrumb "Laporan" plus active nav "Laporan": the page lives under Laporan, not Transaksi. WebPaketLaporan links here with the label "Celah nomor", but the board always opens on "Daftar Bukti Kas" (no deep-link state); keep. Codes inside running text are sans on the board ("Pembalikan BKU-2026-0139", the badge "Dibalik oleh BKU-2026-0144", the sub "BKU-2026-0143 · Sewa sound system · Rp600.000"); keep them sans (board wins); only the table cells and the Celah nomor spans are mono.

### Impor — 17 · Impor
- **Source** `docs/design/handoff/canvas/boards/Impor.dc.html` · page Keuangan · P2 dan P3 (`lanjut`) · form Phone 390×844 · interactive yes
- **Route** `/Impor`, no child routes (steps change in place) · **Widget** `ImporScreen` in `lib/screens/lanjut/impor.dart`
- **Purpose** Bendahara Jemaat importing a spreadsheet of transactions. Shows D34 (import words Ditampung, Lolos pengecekan, Sudah diimpor, Tidak diimpor), that nothing reaches the balance until the last step, the original value next to how it was read, a duplicate the person must decide on, and a refused row that keeps its reason.
- **Shell** Phone header with back, no tab bar; PitaJabatanKosong strip when on (as Bukti Layout 0).
- **Layout**
  1. Header (as Bukti): back → Lainnya; title "Impor"; sub "kas-november.xlsx · 5 baris".
  2. Step bar: padding 0 20 8, row of 4 segments, gap 4, each flex 1, height 6, radius 3. Segment i ≤ st: `tinta` fill, no border. Otherwise transparent with 1.5 dashed `putus` border (inside).
  3. Step text: padding 0 20 10. Line 1 15/700 "{st+1} dari 4 · {nama tahap}". Line 2 14 `tinta2` `ket` (see Interactions).
  4. Scroll list: padding 4/20/20. Five row cards, 10 px apart, radius 14, padding 12/14, column gap 6. At st 0: transparent with 1.5 dashed `putus` (draf); from st 1: `permukaan` with 1 px `garis`.
     - Top line (space-between): "Baris {n}" 13 `tinta2` | result badge 13/700, radius 6, padding 3/9.
     - "Di file: {nilai asli}" mono 13 `tinta2`.
     - One block with no gap inside: Uraian 15/600; "Dibaca sebagai: {…}" 13 `tinta2`; Mata Anggaran line 13 `tinta2`, or "Mata Anggaran belum dipilih" in `bata` when empty.
     - Optional note 13 `tinta`.
     - Optional decision buttons (row, gap 8): "Tetap impor" and "Tidak diimpor", each flex 1, min-height 44, radius 10, 1.5 `tinta` border, `permukaan`, 14/700, centred.
  5. Bottom bar (only while st < 3): padding 12/20/22, `permukaan`, 1 px `garis` top rule. One full-width button, min-height 52, radius 14, no border, 700, centred.
  Badge looks: default st 0 "Ditampung" transparent, `tinta2` text, 1.5 dashed `putus`; st 1 "Lolos pengecekan" and st 2 "Sudah diperiksa" transparent, `tinta2`, 1.5 solid `tinta3`; st 3 "Sudah diimpor" `tinta` field, `permukaan` text. Overrides from st ≥ 1: row 5 "Tidak diimpor" `permukaan`, `bata` text, 1.5 `bata` + note "Alasan: tanggal 31/11 tidak ada."; row 3 undecided "Mungkin ganda" `permukaan`, `tinta` text, 1.5 `tinta` + note "Tanggal, Kas/Bank dan jumlah sama dengan baris 2." + the two buttons; row 3 after "Tidak diimpor" → badge "Tidak diimpor" `permukaan`, `tinta2`, 1.5 `tinta3` + note "Alasan: sama dengan baris 2."; row 3 after "Tetap impor" → default badge of the step.
- **Components** Tahapan (here as the 6 px segment bar, not chips), LencanaStatus (result badges), TombolBersyarat (bottom button), PitaJabatanKosong. Pattern: import row card (original value, read value, Mata Anggaran, result).
- **Internal views and states** Initial `{ st: 0, ganda: '' }`. st 0 Ditampung → st 1 Lolos pengecekan (waits for the duplicate decision) → st 2 Sudah diperiksa → st 3 Sudah diimpor (bottom bar gone, final counts). `ganda`: '' | 'tetap' | 'tidak'.
- **Tweaks** `jabatanKosong` (boolean, default false) · Keadaan panel (global). On: strip only (text replacement disabled).
- **Interactions**
  - Bottom button `maju`: label by step: st 0 "Jalankan pengecekan" (`tinta` field, `permukaan` text); st 1 "Tandai sudah diperiksa" (`tinta`; while `ganda` is '' it looks disabled: `garis` field, `tinta3` text); st 2 "Impor" (`laut` field, `diLaut` text). Press: if st 1 and `ganda` is '' → nothing happens; else st + 1 (max 3). Keep the button focusable; `onPressed` re-checks the condition.
  - "Tetap impor" → `ganda = 'tetap'`; "Tidak diimpor" → `ganda = 'tidak'`. Buttons disappear after either; no undo.
  - `ket` text: st 0 "Belum ada yang masuk saldo."; st 1 undecided "Putuskan dulu baris yang mungkin ganda.", decided "Pengecekan selesai. Baca sekali lagi."; st 2 "Siap diimpor."; st 3 "4 baris sudah diimpor · 1 tidak diimpor." when `ganda = 'tetap'`, "3 baris sudah diimpor · 2 tidak diimpor." when 'tidak'.
- **Motion** none on this board (no transition on segments or cards; keyframes declared but unused).
- **Links out** Back arrow ("Kembali ke Lainnya") → `/Lainnya`, up link. **Inbound** Keputusan (D34), Lainnya.
- **Mock data** File `kas-november.xlsx`, 5 rows (Di file · Uraian · Dibaca sebagai · Mata Anggaran · kind):
  1. "02/11/26 · Persembahan Mgg · 3.100.000" · Persembahan Ibadah Minggu · "02/11/2026 · Kas · Rp3.100.000 masuk" · "Pendapatan 1.3.53.07.00 Persembahan Ibadah Minggu" · ok
  2. "04/11/26 · Bayar PLN · -1250000" · Bayar PLN · "04/11/2026 · Bank BNI ··4821 · Rp1.250.000 keluar" · "Belanja 5.01.02.00 Listrik, air dan telepon" · ok
  3. "4 Nop · PLN nov · 1.250.000,-" · PLN nov · same as row 2 · same as row 2 · possible duplicate
  4. "08/11/26 · Honor pemusik · 650rb" · Honor pemusik · "08/11/2026 · Kas · Rp650.000 keluar" · none ("Mata Anggaran belum dipilih") · ok
  5. "31/11/26 · ATK · 85.000" · ATK · "tanggal tidak terbaca · Kas · Rp85.000 keluar" · "Belanja 5.02.01.00 Alat tulis dan fotokopi" · refused
- **Prototype-only** none. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. Open → "1 dari 4 · Ditampung", first segment filled, three dashed; all cards dashed with transparent field; badges "Ditampung"; button "Jalankan pengecekan".
  2. Press it → "2 dari 4 · Lolos pengecekan", cards `permukaan` with 1 px solid `garis`, row 5 badge "Tidak diimpor" in `bata` with "Alasan: tanggal 31/11 tidak ada.", row 3 "Mungkin ganda" with two buttons, button in its unmet look (`garis` field, `tinta3` text), `ket` "Putuskan dulu baris yang mungkin ganda.".
  3. Press the unmet button → nothing changes.
  4. Press "Tidak diimpor" on row 3 → buttons go, badge "Tidak diimpor" (`tinta2`), note "Alasan: sama dengan baris 2.", button active, `ket` "Pengecekan selesai. Baca sekali lagi.".
  5. Press "Tandai sudah diperiksa" → "3 dari 4 · Sudah diperiksa", "Siap diimpor.", button "Impor" in `laut`.
  6. Press "Impor" → "4 dari 4 · Sudah diimpor", all segments filled, bottom bar gone, `ket` "3 baris sudah diimpor · 2 tidak diimpor.", rows 1, 2, 4 badge filled `tinta` "Sudah diimpor".
  7. Repeat with "Tetap impor" → final `ket` "4 baris sudah diimpor · 1 tidak diimpor." and row 3 "Sudah diimpor".
  8. Row 4 always shows "Mata Anggaran belum dipilih" in `bata`.
- **Notes** The disabled reason is the step caption above the list, not a "Tidak dapat dilakukan: …" sentence above the button as TombolBersyarat prescribes; the board wins, keep it (the caption is `tinta2`, full contrast). The raw file value "-1250000" keeps its ASCII hyphen: it is file content, not a formatted amount. The Mata Anggaran numbers inside "Pendapatan 1.3.53.07.00 Persembahan Ibadah Minggu" etc. are sans on the board (running label, not a code cell); keep sans. 15 px titles are off-token; copy. Radius 10 on the decision buttons and 3 on segments are off-token; copy.

### WebImpor — Web · Impor
- **Source** `docs/design/handoff/canvas/boards/WebImpor.dc.html` · page Keuangan · P2 dan P3 (`lanjut`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebImpor`, no child routes · **Widget** `WebImporScreen` in `lib/screens/lanjut/web_impor.dart`
- **Purpose** Same journey and decision (D34) as Impor, on the laptop: original and read values side by side in a table, with longer explanations.
- **Shell** Web side nav as WebBukti; active item **Transaksi**.
- **Layout**
  1. Title block: breadcrumb "Transaksi" (14/600 `laut`); h1 "Impor" (26/700) + inline "· kas-november.xlsx · 5 baris" (15/500 `tinta3`).
  2. Step panel: radius 16, padding 16/20, row wrap, centre-aligned, gap 12 vertical / 24 horizontal. st < 3: transparent, 1.5 dashed `putus`; st 3: `permukaan`, 1.5 solid `tinta`.
     - Tahapan chips (wrap, gap 6, 13/700): "1 · Ditampung", "2 · Lolos pengecekan", "3 · Sudah diperiksa", "4 · Sudah diimpor"; min-height 32, padding 0 12, radius 999. Reached (i ≤ st): `tinta` field, `permukaan` text, 1.5 `tinta` border. Not reached: transparent, `tinta3` text, 1.5 dashed `putus`.
     - `ket` (flex 1 1 280, 14 `tinta2`).
     - Button (st < 3): min-height 46, padding 0 20, radius 12, no border, 700; colours and labels as Impor.
  3. Table card: `permukaan`, 1 px `garis`, radius 14, horizontal scroll, inner min-width 980. Grid 50 · 1.2fr · 1.3fr · 1.1fr · 1.2fr, gap 16, padding 12/18. Header 13/600 `tinta2`: "Baris", "Nilai asli di file", "Dibaca sebagai", "Mata Anggaran", "Hasil". Rows: 1 px `garis` top rule, 14 px, top-aligned, row background `kertas` at st 0 and `permukaan` after. Cells: row number mono `tinta2`; original value mono 13 `tinta2` on three lines (date, text, amount); Uraian 600 over "Dibaca sebagai" text 13 `tinta2` (no prefix on web); Mata Anggaran 13 `tinta` or `bata` "Mata Anggaran belum dipilih"; Hasil column (column, gap 6, start-aligned): badge, optional note 13 `tinta2`, optional buttons (wrap, gap 6; min-height 44, padding 0 12, radius 10, 1.5 `tinta`, `permukaan`, 13/700).
  4. Caption 13 `tinta3`: "Baris yang masih ditampung belum masuk saldo dan menjadi hambatan tutup buku bulannya. Baris yang tidak diimpor tetap disimpan bersama alasannya."
  Badge looks as Impor, except the default badge background is `permukaan` instead of transparent at st 0–2. Row 5 note on web: "Alasan: tanggal 31/11 tidak ada. Perbaiki di file lalu impor lagi, atau catat sendiri." Row 3 buttons show only while st < 3.
- **Components** Tahapan (chips), LencanaStatus, TombolBersyarat, PitaJabatanKosong; shared web side nav. Pattern: data table.
- **Internal views and states** Initial `{ st: 0, ganda: '' }`; same four steps as Impor.
- **Tweaks** `jabatanKosong` (boolean, default false) · Keadaan panel (global). On: banner + nav footer; no text replacement.
- **Interactions** As Impor (`maju`, `tetap`, `tidak`), with web `ket` texts: st 0 "Nilai asli dan hasil bacaannya ditampilkan berdampingan. Belum ada yang masuk saldo."; st 1 undecided "Putuskan dulu baris yang mungkin ganda.", decided "Pengecekan selesai. Baca sekali lagi sebelum menandai sudah diperiksa."; st 2 "Sudah diperiksa. Impor mencatat baris yang lolos; baris tanpa Mata Anggaran masuk sebagai transaksi dengan Mata Anggaran belum dipilih."; st 3 "{4|3} baris sudah diimpor · {1|2} tidak diimpor. No. bukti asal dari file ditampilkan terpisah dari No. Bukti." (4/1 when `ganda = 'tetap'`, 3/2 when 'tidak').
- **Motion** none.
- **Links out** Breadcrumb "Transaksi" → `/WebTransaksi`, up link. Side nav. **Inbound** TabTransaksi, WebTransaksi.
- **Mock data** Same five rows as Impor; original values split on line breaks: "02/11/26 / Persembahan Mgg / 3.100.000", "04/11/26 / Bayar PLN / -1250000", "4 Nop / PLN nov / 1.250.000,-", "08/11/26 / Honor pemusik / 650rb", "31/11/26 / ATK / 85.000". Row 5 read value starts with a capital: "Tanggal tidak terbaca · Kas · Rp85.000 keluar".
- **Prototype-only** none. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. Open → chip "1 · Ditampung" filled, other three dashed; panel dashed; rows on `kertas`; badges "Ditampung" dashed.
  2. "Jalankan pengecekan" → chips 1–2 filled, rows `permukaan`, row 3 shows "Mungkin ganda" with two buttons, button in its unmet look (`garis` field, `tinta3` text) and inert.
  3. "Tetap impor" → row 3 badge "Lolos pengecekan", `ket` "Pengecekan selesai. Baca sekali lagi sebelum menandai sudah diperiksa.".
  4. "Tandai sudah diperiksa" then "Impor" → panel turns `permukaan` with 1.5 solid `tinta` border, all four chips filled, button gone, `ket` starts "4 baris sudah diimpor · 1 tidak diimpor.".
  5. Row 5 from step 2 on: "Tidak diimpor" in `bata` and the long web note.
  6. Original value column shows three lines per row in mono.
  7. At 860 px the table scrolls inside its card.
- **Notes** Same TombolBersyarat note as Impor. Mata Anggaran text is `tinta` on web, `tinta2` on phone; note text is `tinta2` on web, `tinta` on phone: keep each. Radius 16 panel = `radius-kartuBesar`.

### Ekspor — 18 · Ekspor data Jemaat
- **Source** `docs/design/handoff/canvas/boards/Ekspor.dc.html` · page Keuangan · P2 dan P3 (`lanjut`) · form Phone 390×844 · interactive yes
- **Route** `/Ekspor`, no child routes · **Widget** `EksporScreen` in `lib/screens/lanjut/ekspor.dart`
- **Purpose** Bendahara Jemaat, journey step 5. A full copy belonging to the Jemaat. Shows the Gerak rule "generation always looks in progress; success is never shown before it has happened", and an honest incomplete result naming what is missing.
- **Shell** Phone header with back, no tab bar; strip when `jabatanKosong`.
- **Layout**
  1. Header: back → Lainnya; title "Ekspor data Jemaat"; sub "Salinan lengkap milik Jemaat".
  2. Scroll area: padding 8/20/20, column gap 14.
     a. Contents card: `permukaan`, 1 px `garis`, radius 14, padding 0 16. Five items, padding 12 0, 1 px `garis` top rule from the second. Each: row (space-between, centred, gap 10) name 15/600 + status badge (13/700, radius 6, padding 3/9, no wrap); description 13 `tinta3`; while preparing, a progress track below: height 4, radius 2, `garis` track, margin-top 8, `laut` fill growing from 0 to full width.
     b. State `belum` only: 14 `tinta2` "Mencakup 15 September 2026 sampai hari ini. Bulan yang belum ditutup diekspor sebagai keadaan saat ini dan ditandai Belum ditutup."
     c. State `selesai` only: result card hambatan: `permukaan`, 1.5 `bata`, radius 14, padding 14/16, gap 4. "Ekspor belum lengkap" 16/700; "3 dari 214 dokumen pendukung tidak ikut:" 14; "2 file Ditahan (alasan keamanan)" 14 `tinta2`; "1 file gagal dibaca" 14 `tinta2`; "Daftar isi mencatat ketiganya beserta No. Bukti dan alasannya." 13 `tinta3`, margin-top 4.
  3. Bottom bar: padding 12/20/22, `permukaan`, 1 px `garis` top rule, column gap 8.
     - `belum`: primary "Buat ekspor" (min-height 52, radius 14, `laut`, `diLaut`, 700).
     - `jalan`: `role=status` text "Sedang disiapkan…" 700, centred in min-height 52.
     - `selesai`: primary button with `unduhTeks` (same style), then text button "Coba lagi" (min-height 44, no border, `laut` text, 700, centred).
  Badge looks: `belum` "Akan disertakan" and `jalan` "Sedang disiapkan": `permukaan`, `tinta2` text, 1.5 dashed `putus`. `selesai`: "Disertakan" `laut` field, `diLaut` text, 1.5 `laut`; Dokumen pendukung row "Belum lengkap" `permukaan`, `bata` text, 1.5 `bata`, and its description becomes "211 dari 214 file disertakan".
- **Components** LencanaStatus (item badges), Tombol (primary, text), PitaJabatanKosong; result card follows ButirPerhatian/hambatan line. Pattern: checklist with per-item progress.
- **Internal views and states** Initial `{ st: 'belum' }` (`diunduh` undefined). States `belum` → `jalan` (2800 ms) → `selesai`; in `selesai`, `diunduh` false/true.
- **Tweaks** `jabatanKosong` (boolean, default false) · Keadaan panel (global): strip only.
- **Interactions**
  - "Buat ekspor" (`buat`): `st = 'jalan'`, cancel any pending timer, start a 2800 ms timer that sets `st = 'selesai'` (fakes building the zip). Cancel the timer on dispose.
  - "Unduh ekspor (belum lengkap)" (`unduh`): `diunduh = true`; label becomes "Diunduh · ekspor-jemaat-karunia-2026-11-16.zip". No file is produced. Further presses change nothing.
  - "Coba lagi": same as `buat` (back to `jalan`, 2800 ms, `selesai` again). `diunduh` is not reset, so after a retry the button still reads "Diunduh · …".
- **Motion** Progress fills: `isi` (width 0 → 100 %), linear, fill-mode both, per item: Buku 1100 ms, Versi 1500 ms, Dokumen pendukung 2400 ms, Laporan 1900 ms, Daftar isi 2600 ms; they start when `jalan` begins and stay full until the 2800 ms timer ends. Result card: `muncul` 300 ms on entering `selesai`. Reduce motion: bars full at once; the 2800 ms wait stays.
- **Links out** Back arrow ("Kembali ke Lainnya") → `/Lainnya`, up link. **Inbound** Lainnya.
- **Mock data** Items: Buku "Semua transaksi, termasuk yang dibalik dan dibatalkan"; Versi "Mata Anggaran, pengaturan dan aturan per bulan"; Dokumen pendukung "214 file, masing-masing dengan checksum"; Laporan "Laporan resmi September dan Oktober 2026"; Daftar isi "Apa yang ada di ekspor ini, dan apa yang tidak". Counts 214 / 211 / 3 (2 Ditahan, 1 gagal dibaca). Range from 15 September 2026. File name ekspor-jemaat-karunia-2026-11-16.zip.
- **Prototype-only** none. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. Open → five badges "Akan disertakan" (dashed), coverage sentence, button "Buat ekspor".
  2. Press "Buat ekspor" → badges "Sedang disiapkan", five bars fill at different speeds, bottom shows "Sedang disiapkan…", no button.
  3. 2800 ms later → four badges "Disertakan" (`laut`), Dokumen pendukung "Belum lengkap" (`bata`) with "211 dari 214 file disertakan"; card with 1.5 `bata` border "Ekspor belum lengkap" rises in (`muncul` 300 ms).
  4. Press "Unduh ekspor (belum lengkap)" → label "Diunduh · ekspor-jemaat-karunia-2026-11-16.zip".
  5. Press "Coba lagi" → back to preparing, then result again after 2800 ms with label still "Diunduh · …".
  6. Leave the screen during preparing → no error, timer cancelled.
  7. Reduce motion on → bars appear full instantly; result still after 2800 ms.
- **Notes** `diunduh` survives "Coba lagi" in the board; keep it, and list it for design review. 16/700 card title and 15/600 item names are off-token; copy.

### WebEkspor — Web · Ekspor data Jemaat
- **Source** `docs/design/handoff/canvas/boards/WebEkspor.dc.html` · page Keuangan · P2 dan P3 (`lanjut`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebEkspor`, no child routes · **Widget** `WebEksporScreen` in `lib/screens/lanjut/web_ekspor.dart`
- **Purpose** Same as Ekspor, on the laptop under Pengaturan, with the No. Bukti of the missing files.
- **Shell** Web side nav as WebBukti; active item **Pengaturan**.
- **Layout**
  1. Title block: breadcrumb "Pengaturan"; h1 "Ekspor data Jemaat" (26/700); sub 14 `tinta2` "Salinan lengkap milik Jemaat: buku, versi pengaturan, dokumen pendukung, laporan, dan daftar isinya."
  2. Two-column grid: auto-fit, min column min(420, 100%), gap 24, top-aligned.
     a. Left contents card: `permukaan`, 1 px `garis`, radius 14, padding 4/18. Items: row, centred, gap 14, min-height 64, padding 8 0, top rule from second. Left block: name 600 (15), description 13 `tinta3`, progress track as Ekspor while `jalan`. Badge on the right, same looks as Ekspor.
     b. Right column (gap 14):
        - `belum`: primary "Buat ekspor" (min-height 52, radius 12, `laut`, `diLaut`, 700, full column width); below, 14 `tinta2` coverage sentence (same text as Ekspor).
        - `jalan`: `role=status` "Sedang disiapkan…" 17/700; "Anda boleh meninggalkan halaman ini. Ekspor tidak mengubah data apa pun." 14 `tinta2`.
        - `selesai`: card `permukaan`, 1.5 `bata`, radius 14, padding 16/18, gap 6: "Ekspor belum lengkap" 17/700; "3 dari 214 dokumen pendukung tidak ikut:" 14; "2 file Ditahan (alasan keamanan) · BKU-2026-0117, BKU-2026-0130" 14 `tinta2`; "1 file gagal dibaca · BKU-2026-0102" 14 `tinta2`; "Daftar isi mencatat ketiganya sebagai tidak disertakan, lengkap dengan alasannya." 13 `tinta3`, margin-top 4. Then a wrap row, gap 10: primary `unduhTeks` (min-height 48, padding 0 20, radius 12, `laut`) and secondary "Coba lagi" (min-height 48, padding 0 20, radius 12, 1.5 `tinta`, `permukaan`, 700).
- **Components** LencanaStatus, Tombol (primary, secondary), PitaJabatanKosong; shared side nav.
- **Internal views and states** As Ekspor.
- **Tweaks** `jabatanKosong` (boolean, default false) · Keadaan panel (global): banner + nav footer.
- **Interactions** As Ekspor (`buat` with 2800 ms timer cancelled on dispose; `unduh`; "Coba lagi" = `buat`; `diunduh` not reset).
- **Motion** As Ekspor: `isi` bars 1100/1500/2400/1900/2600 ms linear; `muncul` 300 ms on the result card.
- **Links out** Breadcrumb "Pengaturan" → `/WebPengaturan`, up link. Side nav. **Inbound** WebPengaturan.
- **Mock data** Items as Ekspor except Versi "Mata Anggaran 2026.1 dan 2026.2, pengaturan dan aturan per bulan", Laporan "Laporan resmi September dan Oktober 2026, PDF dan Excel", Daftar isi "Apa saja yang ada di ekspor ini, dan apa yang tidak". Missing files BKU-2026-0117, BKU-2026-0130 (Ditahan), BKU-2026-0102 (gagal dibaca).
- **Prototype-only** none. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. Open at 1440 → two columns; "Pengaturan" active in nav; right column "Buat ekspor" and the coverage sentence.
  2. Press → right column "Sedang disiapkan…" (17/700) and "Anda boleh meninggalkan halaman ini. …"; bars run.
  3. After 2800 ms → result card lists "BKU-2026-0117, BKU-2026-0130" and "BKU-2026-0102"; buttons "Unduh ekspor (belum lengkap)" and "Coba lagi" side by side.
  4. "Unduh …" → "Diunduh · ekspor-jemaat-karunia-2026-11-16.zip".
  5. At 860 px the grid falls to one column (contents above, actions below).
  6. Navigate away mid-run via the side nav → no late state update or error.
- **Notes** 17 px is an allowed off-token size. The No. Bukti codes in the result card ("BKU-2026-0117, BKU-2026-0130", "BKU-2026-0102") are drawn in the sans body font inside a running line. CONVENTIONS lets the board win on what the screen shows, and codes inside running text stay sans (as in `07-kejadian.md` and `11-lihatdokumen.md`): keep them sans, same size and colour as the line, and list it for design review.

### WebAI — Web · Bantuan AI akhir bulan
- **Source** `docs/design/handoff/canvas/boards/WebAI.dc.html` · page Keuangan · P2 dan P3 (`lanjut`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebAI`, no child routes · **Widget** `WebAIScreen` in `lib/screens/lanjut/web_ai.dart`
- **Purpose** Bendahara Jemaat preparing to close October 2026 (month end, the work of journey step 4; the journey list itself does not name this board). Shows that the one blocker is always a ButirPerhatian with a fix button, that AI suggestions are optional, dotted `laut` and italic (D31), with "AI kurang yakin, mohon dicek" when unsure, that AI never posts, verifies or closes, the monthly AI cost limit and its effect, and that tutup buku lives only on "Bulan dan tutup buku". Laptop pair of "36 · Bantuan AI akhir bulan" (AIBulan, specified elsewhere).
- **Shell** Web side nav as WebBukti; active item **Bulan dan tutup buku**.
- **Layout**
  1. Title block: breadcrumb "Bulan dan tutup buku"; h1 "Persiapan tutup buku Oktober 2026" (26/700).
  2. Two-part row (wrap, gap 24, top-aligned): left flex 999 1 480; right aside flex 1 1 400.
  3. Left column (gap 14):
     a. Heading row (gap 8): "Hambatan" 18/700 + count pill: `bata` field, `diBata` text, 13/700, radius 999, min-width 22, height 22, "1".
     b. Hambatan card: `permukaan`, 1.5 `bata`, radius 14, padding 16, gap 4. "Bank BNI ··4821 belum direkonsiliasi" 700; "Selisih belum dijelaskan Rp515.000 · 3 mutasi bank belum cocok" 14 `tinta2`; button-link "Buka rekonsiliasi": margin-top 8, start-aligned, min-height 44, padding 0 16, radius 12, `tinta` field, `permukaan` text, 700.
     c. "Untuk diketahui" 18/700 (margin-top 8).
     d. "2 uang muka dengan sisa belum dipertanggungjawabkan" 14 `tinta2` (plain, no frame).
     e. Only when AI is off (100 %): "AI sedang tidak tersedia: batas biaya AI per bulan tercapai. Ini tidak menghalangi tutup buku." 14 `tinta2`.
     f. Footer 13 `tinta3`, 1 px `garis` top rule, padding-top 12: "Tutup buku hanya dilakukan di halaman Bulan dan tutup buku, oleh Bendahara. Panel bantuan tidak punya tombol untuk itu."
  4. Aside AI panel: `lautLembut` field, radius 18, padding 18, column gap 14.
     a. Row (baseline, space-between, gap 12): "BANTUAN AI · PILIHAN" 13/700 `lautTua`, letter-spacing 0.3 | cost text 13 `tinta`.
     b. Cost bar: height 8, radius 4, `permukaan` track, `laut` fill at the percentage (max 100 %).
     c. Cost note 14/600 (hidden when empty).
     d. While AI is on: summary card KartuUsulanAI: `permukaan`, 1.5 dotted `laut`, radius 12, padding 14, gap 6. Tag "Usulan AI · ringkasan" (13/700 `lautTua`, 1.5 dotted `laut`, radius 6, padding 2/8, start-aligned). Italic 14 `lautTua`: "Selisih Rp515.000 di Bank BNI tampaknya terdiri dari satu setoran Rp500.000 yang belum muncul di rekening koran dan satu biaya administrasi Rp15.000 yang belum dicatat." Then "Angka resmi tetap yang ada di halaman rekonsiliasi." 13 `tinta2`.
     e. While AI is on: two suggestion cards (same frame, gap 8): tag; italic text; for the second card "AI kurang yakin, mohon dicek" 13/600; while undecided a wrap row (gap 8, centred): primary button (min-height 44, padding 0 16, radius 10, `laut`, `diLaut`, 14/700) with the card's label, secondary "Abaikan" (same size, 1.5 `tinta`, `permukaan`), caption 13 `tinta2`; once decided, a `role=status` line 14/600 `tinta` replaces the row.
     f. When AI is off: card `permukaan`, radius 12, padding 14, 14 `tinta2`: "**Bantuan AI berhenti sampai Desember 2026.** Rekonsiliasi, laporan dan tutup buku berjalan seperti biasa tanpa AI." (bold part `tinta`).
     g. Footer 13 `tinta2`: "AI hanya mengusulkan. AI tidak membukukan, memverifikasi, menutup buku, atau memberi angka resmi."
- **Components** ButirPerhatian (Hambatan card with fix button; "Untuk diketahui" plain), KartuUsulanAI (three cards), Tombol (primary/secondary), PitaJabatanKosong; shared side nav. Pattern: AI cost meter (bar + note), count pill.
- **Internal views and states** Initial `{ u: {} }` (`u[id]` = 'pakai' | 'abai'). AI on (biayaAI < 100 %) / AI off (100 %). Per suggestion: undecided / used / ignored.
- **Tweaks**
  - `jabatanKosong` (boolean, default false) · Keadaan panel (global): banner + nav footer; no text replacement.
  - `biayaAI` (enum `40%`, `75%`, `95%`, `100%`; default `75%`) · Keadaan panel. Cost text "Batas biaya AI per bulan · {rp(150000 × p)} dari Rp150.000", bar width p:
    - 40%: "… · Rp60.000 dari Rp150.000", bar 40 %, no note, AI cards shown.
    - 75%: "… · Rp112.500 dari Rp150.000", bar 75 %, note "Sudah melewati 70% dari batas bulan ini.", AI cards shown.
    - 95%: "… · Rp142.500 dari Rp150.000", bar 95 %, note "Hampir habis. AI memakai cara yang lebih hemat sampai akhir bulan.", AI cards shown.
    - 100%: "… · Rp150.000 dari Rp150.000", bar full, note "Batas tercapai.", summary and suggestion cards hidden, card 4f shown, left line 3e shown.
- **Interactions**
  - Card "Usulan AI · pencocokan": "Buka untuk dicocokkan" → `u.cocok = 'pakai'` → status "Dibuka di rekonsiliasi. Mutasi baru cocok setelah Anda menekan Cocokkan di sana." "Abaikan" → `u.cocok = 'abai'` → "Diabaikan. Tidak perlu alasan." Caption before deciding: "Belum mencocokkan apa pun."
  - Card "Usulan AI · mungkin perlu dicek": "Lihat keduanya" → `u.ganda = 'pakai'` → "Kedua transaksi dibuka berdampingan. Tidak ada yang diubah." "Abaikan" → "Diabaikan. Tidak perlu alasan." Caption "Hanya informasi."
  - No undo; neither button navigates. Decisions persist when `biayaAI` changes and come back if AI returns.
- **Motion** Decision status line: `muncul` 300 ms when it appears. Cost bar has no animation.
- **Links out** Breadcrumb "Bulan dan tutup buku" → `/WebTutupBuku`, up link. "Buka rekonsiliasi" → `/WebRekonsiliasi`, push. Side nav. **Inbound** WebTutupBuku.
- **Mock data** Month Oktober 2026; Bank BNI ··4821; difference Rp515.000 = Rp500.000 deposit + Rp15.000 admin fee; 3 unmatched bank lines; 2 advances with remainder; cost limit Rp150.000/month, AI stops until Desember 2026. Suggestion 1: "Mutasi bank “TARIK TUNAI −Rp2.000.000” (30/10) kemungkinan cocok dengan BKU-2026-0127 Pindah antar Kas/Bank: Bank BNI ke Kas." Suggestion 2: "BKU-2026-0101 dan draf “Toko Sinar okt” sama-sama Rp1.250.000 ke Toko Sinar pada 06/10/2026. Bisa jadi tercatat dua kali, bisa juga dua tagihan."
- **Prototype-only** none. Keadaan panel: `jabatanKosong`, `biayaAI`.
- **Acceptance checks**
  1. Default (75%) → "Batas biaya AI per bulan · Rp112.500 dari Rp150.000", bar three quarters, note "Sudah melewati 70% dari batas bulan ini.", three dotted cards.
  2. Second suggestion shows "AI kurang yakin, mohon dicek"; first does not.
  3. "Buka untuk dicocokkan" → buttons and caption vanish, status line rises in with the "Dibuka di rekonsiliasi…" sentence; URL unchanged.
  4. "Abaikan" on card 2 → "Diabaikan. Tidak perlu alasan.".
  5. `biayaAI` 100% → note "Batas tercapai.", dotted cards gone, "Bantuan AI berhenti sampai Desember 2026." card in panel, extra line under "Untuk diketahui".
  6. `biayaAI` 40% → no note line; text "Rp60.000 dari Rp150.000".
  7. "Buka rekonsiliasi" → `/WebRekonsiliasi`; Back returns.
  8. No control on the page closes the month.
- **Notes** Radius 18 on the AI panel is an allowed off-token value; radius 10 on suggestion buttons too. Dotted borders come from the shared dashed/dotted painter. The Hambatan card has no "HAMBATAN" label (ButirPerhatian says it should); the section heading "Hambatan" with the count stands for it; keep the board. Codes and amounts inside the AI texts (BKU-2026-0127, BKU-2026-0101, Rp515.000, −Rp2.000.000) are sans italic like the rest of the suggestion; keep the KartuUsulanAI text style for the whole line.

### Dokumen — 19 · Dokumen pendukung: verifikasi, pengecualian, penolakan
- **Source** `docs/design/handoff/canvas/boards/Dokumen.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 · interactive yes
- **Route** `/Dokumen` (list) and child route `/Dokumen/rinci` (the full-screen detail of the chosen transaction) · **Widget** `DokumenScreen` in `lib/screens/lengkap/dokumen.dart`
- **Purpose** Bendahara Jemaat, journey step 2. Decides supporting documents: D02 (missing document blocks month close, not Bukukan: "Menjadi hambatan tutup buku…"), D06 (Lepaskan file returns to "Wajib, belum ada"), D07 (Lihat file opens inside the app → LihatDokumen), EC07 (rejected file, status recalculated), PanelDokumen rules (uploaded is not verified; exception names reason and who granted it), P12 (reason must not be blank). A closed month keeps its status at closing; a late document changes only the current status.
- **Shell** Phone header with back (list: link to Lainnya; detail: button back to list), no tab bar; strip when `jabatanKosong`.
- **Layout**
  - **List view** (`/Dokumen`):
    1. Header: back → Lainnya ("Kembali ke Lainnya"); title "Dokumen pendukung"; sub "Yang perlu diputuskan" 13 `tinta2`.
    2. Scroll list: padding 8/20/20, column gap 10. Six row buttons, full width: `permukaan`, 1 px `garis`, radius 14, padding 14/16, column gap 3. Line 1 (space-between, baseline, gap 16): No. Bukti `kode` `tinta2` | amount mono 500. Uraian 15/600. Status 14: `tinta` weight 500 when settled (Terverifikasi, Dikecualikan, Tidak diperlukan) else `bata` weight 700. Month line 13 `tinta3`.
    3. Caption 13 `tinta3`: "Diunggah bukan terverifikasi. Tutup buku hanya menerima Terverifikasi atau Dikecualikan."
  - **Detail view** (`/Dokumen/rinci`):
    1. Header: back button 44×44 chevron, semantics "Kembali"; title "Dokumen pendukung" (no sub).
    2. Scroll content: padding 8/20/20, column gap 16.
       a. Transaction card terpilih: `permukaan`, 1.5 `tinta`, radius 14, padding 16, gap 4: No. Bukti `kode` `tinta2` | amount mono 500; Uraian 600 (16); month 13 `tinta3`.
       b. Status block (gap 4): "Dokumen pendukung" 14 `tinta2`; for the closed-month row only: "Status saat tutup buku: **Dikecualikan (alasan: kuitansi menyusul, oleh Ketua BPMJ)**" 14 and "Status sekarang:" 14; status text 20/700 (`tinta` when settled, else `bata`); explanation 14 `tinta2`.
       c. Form card (when a form is open): `permukaan`, 1 px `garis`, radius 14, padding 16, gap 10. Title 700; note 14 `tinta2`; label "Alasan **· wajib**" 14 `tinta2` (bold part `tinta`); IsianAlasan textarea 2 rows, padding 12/14, radius 12, 1 px `garisTegas`, `permukaan`, no resize; buttons (wrap, gap 8): primary (min-height 46, padding 0 20, radius 12, no border, 700; `tinta`/`permukaan` when a reason is typed, `garis`/`tinta3` when blank) and secondary "Kembali" (1.5 `tinta`, `permukaan`, `tinta` text, same size).
       d. Action buttons (wrap, gap 8), hidden while a form is open: min-height 48, padding 0 18, radius 12, 700. Primary style U: `laut` field, `diLaut` text, no border. Outline style O: `permukaan`, `tinta` text, 1.5 `tinta`.
       e. Link row (wrap, gap 22 horizontal, 14/700): "Lihat file", "Foto dengan kamera"; each min 44×44.
       f. Column, gap 6: "Riwayat keputusan" 15/700; history lines 14 `tinta2`, newest first; when empty "Belum ada file dan belum ada keputusan." 14 `tinta2`.
- **Components** PanelDokumen (status, explanation, actions, history), IsianAlasan + TombolBersyarat (form), Tombol (action buttons), RiwayatAlur (Riwayat keputusan), LencanaStatus-like status text, PitaJabatanKosong. Pattern: list row button.
- **Internal views and states** Initial state `{ pilih: 'a', buka: false, form: null, alasan: '', it: { a: {st:'unggah', hist:['16/11/2026 10.41 · nota-16-11.jpg diunggah oleh Meiske L.']}, b: {st:'kosong', hist:[]}, c: {st:'kecuali', hist:['22/10/2026 · Dikecualikan · alasan: kuitansi menyusul · oleh Ketua BPMJ']}, d: {st:'gagal', hist:['16/11/2026 11.05 · nota-sewa.jpg gagal diunggah · belum terlampir']}, e: {st:'tahan', hist:['15/11/2026 16.20 · scan-kuitansi.pdf ditahan (alasan keamanan)']}, f: {st:'tidak', hist:[]} } }`. The `it` map and `pilih` must survive moving between `/Dokumen` and `/Dokumen/rinci`: hold the board state in one object owned by the `/Dokumen` route and shared with its child; it resets only when `/Dokumen` is left.
  Status labels: kosong "Wajib, belum ada"; unggah "Diunggah, belum diverifikasi"; verif "Terverifikasi (oleh Meiske L.)"; kecuali "Dikecualikan"; gagal "Gagal diunggah"; tahan "Ditahan (alasan keamanan)"; tidak "Tidak diperlukan (aturan: Pindah antar Kas/Bank)".
  Explanation (detail 2b), first match wins: closed-month row → "Dokumen susulan disimpan dan mengubah Status sekarang. Laporan resmi Oktober 2026 tidak berubah."; tidak → "Aturan Jemaat tidak mewajibkan dokumen untuk transaksi ini."; gagal → "File belum terlampir. Coba lagi tidak membuat salinan ganda."; tahan → "File ini tidak dapat dibuka dan tidak dihitung sebagai dokumen pendukung. Tetap menjadi hambatan tutup buku."; verif/kecuali → "Memenuhi syarat tutup buku November 2026."; otherwise → "Menjadi hambatan tutup buku November 2026 sampai terverifikasi atau dikecualikan."
  Actions per status (no form open): kosong → [U "Lampirkan dokumen pendukung", O "Catat pengecualian"]; unggah → [U "Verifikasi", O "Tolak dengan alasan", O "Lepaskan file"]; gagal → [U "Coba lagi"]; tahan → [U "Lampirkan file lain"]; kecuali → [O "Lampirkan dokumen susulan" for the closed-month row, else O "Lampirkan dokumen pendukung"]; verif, tidak → none.
  Forms: `kecuali` title "Catat pengecualian", note "Pemberi pengecualian: Ketua BPMJ, sesuai pengaturan Jemaat. Anda mencatat keputusannya.", button "Catat pengecualian". `tolak` title "Tolak dengan alasan", note "Sementara (draf EC07). File yang ditolak tetap ada di Riwayat, dan statusnya dihitung lagi.", button "Tolak file ini".
- **Tweaks** `jabatanKosong` (boolean, default false) · Keadaan panel (global). On: strip, and text replacement is enabled (`jk && true`): in every shown string that contains "Meiske L." and whose only dates are 16/11/2026 (or has no date), "Meiske L." becomes "Yanti Sumual, Operator". So the verif label reads "Terverifikasi (oleh Yanti Sumual, Operator)", row a's history reads "16/11/2026 10.41 · nota-16-11.jpg diunggah oleh Yanti Sumual, Operator", and all new history lines name Yanti. Apply at render time; stored history keeps "Meiske L." so toggling back restores it.
- **Interactions**
  - List row tap (`pick`) → `pilih = id`, `buka = true`, `form = null` → push `/Dokumen/rinci`.
  - Detail back button / system Back (`tutupRinci`) → `buka = false`, `form = null` → pop to `/Dokumen`.
  - Action that changes status (`set(st, line)`): new status, history line prepended, `form = null`, `alasan = ''`. Lines: "Lampirkan dokumen pendukung" (kosong) → unggah, "16/11/2026 11.30 · nota baru diunggah oleh Meiske L."; "Verifikasi" → verif, "16/11/2026 11.32 · Terverifikasi oleh Meiske L."; "Lepaskan file" → kosong, "16/11/2026 11.33 · File dilepas oleh Meiske L. · tetap di Riwayat"; "Coba lagi" (gagal) → unggah, "16/11/2026 11.31 · nota-sewa.jpg diunggah oleh Meiske L."; "Lampirkan file lain" (tahan) → unggah, "16/11/2026 11.31 · kuitansi-foto.jpg diunggah oleh Meiske L."; from kecuali → unggah, "16/11/2026 11.30 · dokumen susulan diunggah oleh Meiske L." (closed row) or "16/11/2026 11.30 · nota diunggah oleh Meiske L." (others).
  - "Catat pengecualian" (action) → `form = 'kecuali'`, `alasan = ''`. "Tolak dengan alasan" → `form = 'tolak'`, `alasan = ''`.
  - Textarea → `alasan` on every keystroke. Primary form button enabled when `alasan.trim()` is not empty; press re-reads the latest text (the first press after typing works); blank does nothing.
    - Exception: → kecuali, line "16/11/2026 11.35 · Dikecualikan · alasan: {alasan trimmed} · oleh Ketua BPMJ · dicatat Meiske L.".
    - Reject: → kosong, line "16/11/2026 11.35 · File ditolak · alasan: {alasan trimmed} · oleh Meiske L.".
  - Form "Kembali" (`batalForm`) → `form = null` (typed text discarded on next open).
- **Motion** Detail view enters with `masuk` 280 ms, curve Cubic(0.2, 0.8, 0.2, 1) (slide 24 px from the right + fade): use it as the `/Dokumen/rinci` page transition; going back has no animation (instant). Form card `muncul` 300 ms when opened. Each history line `muncul` 300 ms when it first appears (all lines on opening the detail; afterwards only the new top line).
- **Links out** List back arrow → `/Lainnya`, up link. "Lihat file" → `/LihatDokumen`, push. "Foto dengan kamera" → `/Kamera`, push. **Inbound** Kamera, Keputusan (D02, D06), Lainnya, LihatDokumen.
- **Mock data** Rows (id · No. Bukti · uraian · amount · month · initial status):
  a BKU-2026-0147 · Fotokopi warta jemaat · −Rp150.000 · November 2026 · Belum ditutup · unggah
  b BKU-2026-0143 · Sewa sound system · −Rp600.000 · November 2026 · Belum ditutup · kosong
  c BKU-2026-0116 · Pemeliharaan atap gedung · −Rp5.500.000 · Oktober 2026 · Sudah ditutup · kecuali (closed month)
  d BKU-2026-0145 · Konsumsi rapat majelis · −Rp750.000 · November 2026 · Belum ditutup · gagal
  e BKU-2026-0140 · Bensin operasional · −Rp200.000 · November 2026 · Belum ditutup · tahan
  f BKU-2026-0142 · Pindah antar Kas/Bank: Kas ke Bank BNI · Rp1.000.000 · November 2026 · Belum ditutup · tidak
  Files nota-16-11.jpg, nota-sewa.jpg, scan-kuitansi.pdf, kuitansi-foto.jpg. People Meiske L., Ketua BPMJ.
- **Prototype-only** none. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. `/Dokumen` → six rows; row a status "Diunggah, belum diverifikasi" `bata` 700; rows c and f in `tinta` 500.
  2. Tap row a → detail slides in from the right; card BKU-2026-0147; status "Diunggah, belum diverifikasi" 20/700 `bata`; buttons "Verifikasi", "Tolak dengan alasan", "Lepaskan file".
  3. "Verifikasi" → status "Terverifikasi (oleh Meiske L.)" in `tinta`, "Memenuhi syarat tutup buku November 2026.", no buttons, new top history line "16/11/2026 11.32 · Terverifikasi oleh Meiske L.". Back → row a shows the new status.
  4. Row b → "Catat pengecualian" → form; primary in its unmet look (`garis` field, `tinta3` text); type a space → still unmet; type "kuitansi hilang" → primary turns `tinta` field, `permukaan` text → press once → status "Dikecualikan", history "16/11/2026 11.35 · Dikecualikan · alasan: kuitansi hilang · oleh Ketua BPMJ · dicatat Meiske L.".
  5. Row c → "Status saat tutup buku: Dikecualikan (alasan: kuitansi menyusul, oleh Ketua BPMJ)" and "Status sekarang:"; button "Lampirkan dokumen susulan" (outline).
  6. Row f → no buttons; "Belum ada file dan belum ada keputusan.".
  7. Row a → "Lepaskan file" → status "Wajib, belum ada" (D06).
  8. `jabatanKosong` on → row a history reads "…diunggah oleh Yanti Sumual, Operator"; row c history (22/10/2026) unchanged.
  9. "Lihat file" → `/LihatDokumen`; Back returns to the same detail.
- **Notes** "Sementara (draf EC07)" in the reject note is stale: EC07 and C05 were decided on 18/11/2026; keep the board copy verbatim and list it for design. The manifest marks this board `hasSideNav: true`; it has no side nav (the flag comes from `if (this.navVals)`). The list's `bg`/`sh` selection values are computed but unused on the phone. 20 px status text and 15 px titles are off-token; copy. "Lihat file" shows even when there is no file; keep. Detail header has no subtitle.

### WebDokumen — Web · Dokumen pendukung
- **Source** `docs/design/handoff/canvas/boards/WebDokumen.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebDokumen`, no child routes (detail is a side panel always visible) · **Widget** `WebDokumenScreen` in `lib/screens/lengkap/web_dokumen.dart`
- **Purpose** Same decisions as Dokumen (D02, D06, D07, EC07, P12) on the laptop: table of transactions on the left, the chosen one decided in a panel on the right.
- **Shell** Web side nav as WebBukti; active item **Transaksi**.
- **Layout**
  1. Title block: breadcrumb "Transaksi"; h1 "Dokumen pendukung" (26/700); sub 14 `tinta2` "Yang perlu diputuskan. Diunggah bukan terverifikasi; tutup buku hanya menerima Terverifikasi atau Dikecualikan."
  2. Row (wrap, gap 24, top-aligned):
     a. Table card (flex 999 1 480): `permukaan`, 1 px `garis`, radius 14, horizontal scroll. Six row buttons, `aria-pressed`, min-width 600, grid 130 · 1fr · 1fr · 130, gap 14, centred, min-height 64, padding 8/18, 1 px `garis` top rule on every row (the first too), 14 px. Cells: No. Bukti mono 13 `tinta`; Uraian 600 over month 13 `tinta3`; status (`tinta` 500 or `bata` 700); amount mono right-aligned. Selected row: `lautLembut` field and a 3 px `laut` inner line on the left edge; others `permukaan`.
     b. Aside panel (flex 1 1 380, column gap 16): same content as the Dokumen detail view 2a–2f, except the link row reads "Lihat file" and "Unggah file".
- **Components** As Dokumen, plus the selected-row rule (3 px `laut` left inner line); shared side nav.
- **Internal views and states** Same initial state as Dokumen (`pilih: 'a'`, so row a is selected and its panel shown on open; `buka` is set but unused). Same status labels, explanations, actions and forms.
- **Tweaks** `jabatanKosong` (boolean, default false) · Keadaan panel (global). On: banner, nav footer, and the same text replacement as Dokumen (enabled).
- **Interactions** Row click → `pilih = id`, `form = null` (an open form closes; typed reason kept but cleared when a form opens again). All panel handlers exactly as Dokumen (`set` actions and history lines, open forms, `onAlasan`, `simpan` with trim check, `batalForm`).
- **Motion** Form card `muncul` 300 ms; history lines `muncul` 300 ms on first appearance (all lines when another row is selected; afterwards only the new top line). Row selection changes instantly.
- **Links out** Breadcrumb "Transaksi" → `/WebTransaksi`, up link. "Lihat file" → `/WebLihatDokumen`, push. "Unggah file" → `/WebUnggah`, push. Side nav. **Inbound** WebKasusBaru, WebKoreksi, WebLihatDokumen, WebTutupBuku, WebUnggah.
- **Mock data** Same six rows, files and history as Dokumen.
- **Prototype-only** none. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. Open → row BKU-2026-0147 has `lautLembut` field and left `laut` line; panel shows its card and "Verifikasi", "Tolak dengan alasan", "Lepaskan file".
  2. Click row BKU-2026-0145 → panel "Gagal diunggah", "File belum terlampir. Coba lagi tidak membuat salinan ganda.", button "Coba lagi"; press → "Diunggah, belum diverifikasi" and table row updates.
  3. Row BKU-2026-0140 → "Lampirkan file lain" → status unggah, history "16/11/2026 11.31 · kuitansi-foto.jpg diunggah oleh Meiske L.".
  4. Open "Tolak dengan alasan" on a row, then click another row → form closes.
  5. "Tolak file ini" with reason "buram" → status "Wajib, belum ada", history "16/11/2026 11.35 · File ditolak · alasan: buram · oleh Meiske L.".
  6. "Unggah file" → `/WebUnggah`; Back returns.
  7. At 860 px the panel drops below the table; the table scrolls horizontally inside its card.
- **Notes** Same stale "Sementara (draf EC07)" note as Dokumen. No list caption on web (the rule is in the subtitle). No. Bukti is `tinta` here, `tinta2` on phone.

### Draf — 20 · Draf: pindah tanggal, batalkan, hapus
- **Source** `docs/design/handoff/canvas/boards/Draf.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 · interactive yes
- **Route** `/Draf`, no child routes (Pindah tanggal and Batalkan are a bottom sheet) · **Widget** `DrafScreen` in `lib/screens/lengkap/draf.dart`
- **Purpose** Bendahara Jemaat, journey step 2. A draft dated in closed September 2026: Penolakan "Tidak dapat dilakukan: Bukukan." with the available ways forward (Pindah tanggal, Batalkan) and never reopening a month; a reason is required for both (P12, IsianAlasan); a cancelled draft never had a No. Bukti and stays visible; only an empty draft may be deleted; StatusSimpan conflict rule (someone else changed it → load the latest version first).
- **Shell** Phone header with back to Beranda, no tab bar; strip when `jabatanKosong`.
- **Layout**
  1. Header: back link 44×44 chevron, semantics "Kembali ke Beranda"; title "Draf" (no sub).
  2. Scroll area: padding 8/20/20, column gap 16.
     a. Conflict card (tweak `konflik`, while state is draf and not loaded), `role=alert`: `permukaan`, 1.5 `tinta`, radius 14, padding 14/16, gap 8. 15 px "**Sudah diubah sejak Anda membukanya** (oleh {plk}, 16/11/2026 10.58, dari perangkat lain)."; 14 `tinta2` "Isian Anda tidak menimpa perubahan itu. Muat versi terbaru, lalu lanjutkan."; button "Muat versi terbaru" (min-height 46, padding 0 20, radius 12, `tinta` field, `permukaan` text, 700, start-aligned).
     b. Draft card (state draf): 1.5 dashed `putus`, radius 16, padding 18, gap 6. Badge "Draf · belum masuk saldo" (13/700, radius 6, padding 3/9, 1.5 dashed `putus`, `tinta2`); amount mono 30/500 `tinta2` (`jumlahIsian` size); Uraian 600; sub 13 `tinta3`; month line 13 `tinta3`.
     c. Refusal (state draf, month closed, not empty), 15 px: "**Tidak dapat dilakukan: Bukukan.**" in `bata`, then in `tinta` " September 2026 sudah ditutup, dan draf ini tidak pernah masuk laporannya. Yang masih dapat Anda lakukan: pindah tanggal ke bulan yang belum ditutup, atau batalkan."
     d. Cancelled card (state batal): `permukaan`, 1 px `garis`, radius 14, padding 18, gap 6. Badge "Dibatalkan" (`garis` field, `tinta2`, 13/700, radius 6, padding 3/9); "−Rp650.000" mono 30/500 `tinta3` struck through; "Honor pemusik" 600; "Alasan: {alasanAkhir}" 14 `tinta2`; "Dibatalkan oleh {plk}, 16/11/2026 11.20 · tidak pernah punya No. Bukti · hanya dapat dilihat" 13 `tinta3`.
     e. Deleted notice (state hapus), `role=status`: 1.5 dashed `putus`, radius 14, padding 18, 15 px: "**Draf kosong dihapus.** Hanya draf tanpa isian yang dapat dihapus; yang lain dibatalkan dengan alasan."
     f. Column, gap 6: "Riwayat" 15/700; lines 14 `tinta2`, newest first (no animation on these lines, unlike Dokumen).
  3. Bottom bar (state draf only): padding 12/20/22, `permukaan`, 1 px `garis` top rule, column gap 8, in order:
     - "Periksa dan bukukan" (only when the month is open and the draft is not empty): link styled primary, min-height 52, radius 14, `laut`, `diLaut`, 700, centred.
     - "Pindah tanggal" (not empty): secondary, min-height 48, radius 14, 1.5 `tinta`, `permukaan`, `tinta` text, 700; disabled while the conflict is unresolved.
     - "Batalkan" (not empty): same, same disabled rule.
     - "Hapus draf" (empty only): same style, never disabled.
  4. Sheet (when `sheet` is set) over the area below the strip: scrim = full-area button (semantics "Kembali ke draf"), `tinta` at 45 % opacity. Sheet at bottom: `permukaan`, top radius 22, padding 18/20/24, column gap 14:
     - Title `judulLayar` + note 14 `tinta2`.
     - Pindah only: "Pindah ke bulan" 14 `tinta2` (8 below), ChipPilihan chips "Oktober 2026 · Belum ditutup", "November 2026 · Belum ditutup" (min-height 44, padding 0 14, margins 0 8 8 0, radius 999, 1.5 border, 14/600; selected `tinta`/`permukaan`, unselected `permukaan`/`garisTegas` border/`tinta` text).
     - Label "Alasan **· wajib**" (14 `tinta2`, block, 6 below) and IsianAlasan textarea (2 rows, padding 12/14, radius 12, 1 px `garisTegas`).
     - Primary button full width: min-height 52, radius 14, no border, 700; `tinta`/`permukaan` when a reason is typed, `garis`/`tinta3` when blank.
     - Text button "Kembali": min-height 44, no border, `tinta` text, 700, centred.
- **Components** Penolakan (refusal), LencanaStatus (Draf dashed, Dibatalkan `garis` field), LembarBawah (sheet), ChipPilihan (months), IsianAlasan + TombolBersyarat (sheet), StatusSimpan (conflict card), Tombol, RiwayatAlur (Riwayat), PitaJabatanKosong.
- **Internal views and states** Initial `{ st: 'draf', bulan: 'September 2026', tgl: '28 September 2026', sheet: null, alasan: '', ke: 'November 2026', muat: false, hist: ['28/09/2026 16.10 · Draf dicatat oleh Meiske L.'] }` (`alasanAkhir` added on cancel). States: draf (closed month) → draf (open month after Pindah tanggal) → batal; or empty draf → hapus. Sheet: null | 'pindah' | 'batal'. Conflict: `konflik` tweak and not `muat`.
  Sheet texts: pindah title "Pindah tanggal", note "Hanya bulan sesudahnya yang belum ditutup. Draf tetap Draf, dan tanda sudah diperiksa atau persetujuan yang ada akan hilang.", button "Pindah tanggal ke {ke}". batal title "Batalkan draf", note "Draf yang dibatalkan tidak pernah punya No. Bukti dan tetap dapat dilihat bersama alasannya.", button "Batalkan draf".
- **Tweaks**
  - `jabatanKosong` (boolean, default false) · Keadaan panel (global). On: strip; `{plk}` = "Yanti Sumual, Operator" in the conflict and cancelled cards; text replacement enabled, so new history lines (dated 16/11/2026) read "oleh Yanti Sumual, Operator"; the 28/09/2026 line stays "Meiske L.".
  - `konflik` (boolean, default false) · Keadaan panel. On: conflict card shown at top (while draf and not loaded); "Pindah tanggal" and "Batalkan" disabled and their handlers do nothing. After "Muat versi terbaru" the card stays gone for this visit even if the tweak stays on.
  - `drafKosong` (boolean, default false) · Keadaan panel. On: amount "—", Uraian "Draf kosong", sub "Belum ada isian · dibuat 16/11/2026 11.02"; no refusal; bottom bar shows only "Hapus draf". Month line still follows `bulan` ("September 2026 · Sudah ditutup").
- **Interactions**
  - "Pindah tanggal" (`bukaPindah`): if no conflict → `sheet = 'pindah'`, `alasan = ''`. "Batalkan" (`bukaBatal`): if no conflict → `sheet = 'batal'`, `alasan = ''`.
  - Month chip → `ke = month` (default November 2026; the choice persists between openings).
  - Textarea → `alasan` per keystroke. Primary enabled when `alasan.trim()` is not empty; press re-reads the latest text; blank does nothing.
  - Confirm Pindah: `sheet = null`, `bulan = ke`, `tgl` = "16 November 2026" (November) or "31 Oktober 2026" (Oktober), history prepended "16/11/2026 11.20 · Pindah tanggal ke {ke} · alasan: {alasan trimmed} · oleh Meiske L.". Refusal disappears; month line "{ke} · Belum ditutup"; sub "Bank BNI ··4821 · tanggal transaksi {tgl}"; "Periksa dan bukukan" appears.
  - Confirm Batalkan: `sheet = null`, `st = 'batal'`, `alasanAkhir` = trimmed reason, history prepended "16/11/2026 11.20 · Dibatalkan · alasan: {alasan} · oleh Meiske L."; bottom bar disappears.
  - Scrim or "Kembali" (`tutupSheet`) → `sheet = null` (typed reason dropped on next open).
  - "Hapus draf" → `st = 'hapus'`; bottom bar disappears, history stays.
  - "Muat versi terbaru" → `muat = true`; buttons enabled.
  - System Back while the sheet is open closes the sheet first.
- **Motion** Scrim `pudar` 200 ms; sheet `muncul` 280 ms (fade + 8 px rise; the board does not slide it from off-screen); cancelled card and deleted notice `muncul` 300 ms when they appear. No exit animations.
- **Links out** Back arrow (no label, "Kembali ke Beranda") → `/Main`, up link. "Periksa dan bukukan" → `/Main`, `go` (the board links to Main's root, not to a Main sub-view). **Inbound** Main (link "1 draf di bulan yang sudah ditutup").
- **Mock data** Draft "Honor pemusik", −Rp650.000, Bank BNI ··4821, tanggal transaksi 28 September 2026, recorded 28/09/2026 16.10 by Meiske L.; empty draft created 16/11/2026 11.02; conflict by {plk} 16/11/2026 10.58; actions at 16/11/2026 11.20; months Oktober 2026 and November 2026 open, September 2026 closed.
- **Prototype-only** none on the board. Keadaan panel: `jabatanKosong`, `konflik`, `drafKosong`.
- **Acceptance checks**
  1. Open → dashed card "Draf · belum masuk saldo", "−Rp650.000", "September 2026 · Sudah ditutup"; refusal starting "Tidak dapat dilakukan: Bukukan." in `bata`; buttons "Pindah tanggal", "Batalkan"; no "Periksa dan bukukan".
  2. "Pindah tanggal" → scrim fades, sheet rises; chip "November 2026 · Belum ditutup" selected; button "Pindah tanggal ke November 2026" in its unmet look (`garis` field, `tinta3` text).
  3. Type "salah bulan" → button turns `tinta`; one press → sheet closes, month "November 2026 · Belum ditutup", sub "… tanggal transaksi 16 November 2026", refusal gone, "Periksa dan bukukan" shown, Riwayat top line "16/11/2026 11.20 · Pindah tanggal ke November 2026 · alasan: salah bulan · oleh Meiske L.".
  4. Choose "Oktober 2026 · Belum ditutup" instead → tanggal "31 Oktober 2026".
  5. "Batalkan" → reason "dobel" → "Batalkan draf" → card "Dibatalkan", struck "−Rp650.000", "Alasan: dobel", bottom bar gone.
  6. Tap the scrim → sheet closes, nothing changes.
  7. `konflik` on → alert card; "Pindah tanggal" and "Batalkan" look unchanged but pressing them opens no sheet; "Hapus draf" is not affected; "Muat versi terbaru" → card gone, buttons work.
  8. `drafKosong` on → "—", "Draf kosong", only "Hapus draf"; press → "Draf kosong dihapus." notice.
  9. `jabatanKosong` on, cancel → "Dibatalkan oleh Yanti Sumual, Operator, 16/11/2026 11.20 · …" and Riwayat "… · oleh Yanti Sumual, Operator".
- **Notes** The sheet's confirm button is `tinta`, not `laut`; keep the board. The pindah sheet offers Oktober even after moving to November (the note says only later months); keep. With `drafKosong` the Riwayat still shows "28/09/2026 16.10 · Draf dicatat oleh Meiske L." and the month line "September 2026 · Sudah ditutup" while the sub says created 16/11/2026; keep and list for design. "Hapus draf" is not disabled by the conflict; keep. While the conflict is unresolved, "Pindah tanggal" and "Batalkan" are `disabled` but keep their full look (the inline colours override the browser's disabled style): same `permukaan`/`tinta` look, no response to presses; the conflict card above them is the reason in full contrast. The board's "Kembali" button declares `laut` then `tinta`; the later wins: `tinta`. Card radius declared 14 then 16: 16 wins. The manifest marks `hasSideNav: true`; there is none. The TombolBersyarat refusal sentence is not drawn; the "· wajib" label carries the reason.

### WebDraf — Web · Draf: pindah tanggal dan batalkan
- **Source** `docs/design/handoff/canvas/boards/WebDraf.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebDraf`, no child routes (the sheet becomes a side panel) · **Widget** `WebDrafScreen` in `lib/screens/lengkap/web_draf.dart`
- **Purpose** Same as Draf on the laptop; LembarBawah rule "on web the same content is a side panel".
- **Shell** Web side nav as WebBukti; active item **Transaksi**.
- **Layout**
  1. Title block: breadcrumb "Transaksi"; h1 "Draf" (26/700).
  2. Row (wrap, gap 24, top-aligned):
     a. Left column (flex 999 1 460, gap 16): conflict card, draft card, refusal, cancelled card, deleted notice, all exactly as Draf 2a–2e; then (state draf) a wrap row of buttons, gap 8, in the same order and styles as the Draf bottom bar (the link "Periksa dan bukukan" 52 high, others 48, width fits content, padding 0 20); then "Riwayat" as Draf 2f.
     b. Side panel (only while `sheet` is set; flex 1 1 360): `permukaan`, 1 px `garis`, radius 14, padding 20, column gap 14; same content as the Draf sheet (title, note, month chips for pindah, reason, primary button full width, text button "Kembali"). No scrim.
- **Components** As Draf, with LembarBawah rendered as a side panel; shared side nav.
- **Internal views and states** Same initial state and states as Draf.
- **Tweaks** `jabatanKosong`, `konflik`, `drafKosong` exactly as Draf (Keadaan panel); `jabatanKosong` also switches the banner and nav footer.
- **Interactions** Identical to Draf (`bukaPindah`, `bukaBatal`, chips, `onAlasan`, `simpan`, `tutupSheet` via "Kembali", `hapus`, `muat`). Opening the panel while it is open for the other action switches its content and clears the reason.
- **Motion** Side panel `muncul` 300 ms when it opens; cancelled card and deleted notice `muncul` 300 ms.
- **Links out** Breadcrumb "Transaksi" → `/WebTransaksi`, up link. "Periksa dan bukukan" → `/WebCatat`, push. Side nav. **Inbound** TabTransaksi, WebTransaksi.
- **Mock data** As Draf.
- **Prototype-only** none. Keadaan panel: `jabatanKosong`, `konflik`, `drafKosong`.
- **Acceptance checks**
  1. Open at 1440 → "Transaksi" active; draft card, refusal and buttons in the left column; no panel.
  2. "Pindah tanggal" → panel rises in at the right (`muncul` 300 ms), no scrim; left column still usable.
  3. With the panel open press "Batalkan" → panel content changes to "Batalkan draf", reason empty.
  4. Pindah to November with a reason → panel closes; "Periksa dan bukukan" appears; click it → `/WebCatat`; Back returns.
  5. `konflik` on → alert card; Pindah/Batalkan keep their look but open no panel until "Muat versi terbaru".
  6. `drafKosong` on → only "Hapus draf"; press → "Draf kosong dihapus.".
  7. At 860 px the panel drops below the left column.
- **Notes** Same notes as Draf (tinta confirm button, Oktober offered after November, empty-draft history, Hapus not locked by conflict). Card radius 16 wins over 14.
