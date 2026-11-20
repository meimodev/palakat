# Screens 13: TabBeranda, TabTransaksi, TabCatat, PetaPlatform, AlurPengembalian, WebAlurPengembalian

These six boards are three small groups. **TabBeranda**, **TabTransaksi** and **TabCatat** ("Tablet · …", canvas page Web) are the Bendahara Jemaat's finance pages drawn at tablet width (834 × 1112). Each is a copy of its laptop board (WebBeranda, WebTransaksi, WebCatat) without the `jabatanKosong` vacancy tweak. Because 834 is below the 860 px breakpoint, the finance side nav is drawn collapsed into a top bar with a "Menu" button. Nothing links to the tablet boards (they are opened from the launcher), and every link on them leads into the laptop boards (`/Web…`), never to another tablet board. **PetaPlatform** ("Peta layar · Putaran 2–5", canvas page Peta dan keputusan) is a fixed 1280 × 2100 sheet. It lists the 55 platform screens of rounds 2 to 5 in four columns, each with "Ponsel" and "Web" links to its boards, and ends with two notes: what changed in round 1, and the decisions of 18/11/2026. One of its links opens **AlurPengembalian** ("102 · Alur · Pengembalian", phone). That flow has three steps: pick the original voucher, enter the refund (live refusal), then see the result as Dibukukan or Draf. It is also reached from the phone Pengembalian board ("Coba alurnya sampai dibukukan"), and its back arrow returns there. **WebAlurPengembalian** is the same flow on the laptop, under the platform side nav (10 items, "Keuangan" active), reached from WebPengembalian. In every section an **up link** is a phone back arrow or a web breadcrumb. It runs `kembaliKe('/X')`: pop when the route directly below is `/X` or a child of `/X`, otherwise `go('/X')`. Side-nav items use `go`; drill-ins use `push`. Today is 16/11/2026; the actor is Meiske L. (Meiske Lumentut), Bendahara Jemaat.

**Shared: the collapsed finance nav (all three tablet boards).** This is the web side nav of WebBeranda/WebTransaksi (see `02-awal.md`, `03-webrekonsiliasi.md`) as the `.pn` CSS draws it at 834 wide:
- Top bar: full width, `permukaan`, padding 8 × 16, bottom border 1 `garis`, no right border. It is a wrapping row, items centred, gap 0 × 12.
- Brand row (gap 10, padding 0 8): the 26 × 26 Palakat mark, then "palakat" (18 px, 700, line height 1.1) over "Jemaat Karunia" (`keterangan`, `tinta3`). Draw the mark from the board's SVG: rect 2,2,20,20 rx 6, no fill, stroke `laut` 2, dasharray 3 3; path `M12 2h4a6 6 0 0 1 6 6v8a6 6 0 0 1-6 6h-4z` filled `laut`.
- Toggle at the far right (margin-left auto): min height 44, padding 0 16, radius 14, 1.5 `tinta` border, `permukaan`, 700 14 px, label "Menu", Semantics label "Menu". Pressed, it reads "Tutup menu" on a `tinta` field with `permukaan` text.
- While open: the items show as a full-width block under the brand row (padding 8 0), then the footer, full width. The footer has margin-top 0, padding 12 8 8, a top border 1 `garis`, 13 px `tinta2`: "**Meiske L.** · Bendahara" / "Wewenang Bendahara aktif" (the name in strong `tinta`). The menu opens in the page flow and pushes the main content down. It is not an overlay. The open state belongs to the page and resets when the page is left.
- Items in order: "Beranda" → `/WebBeranda`, "Transaksi" → `/WebTransaksi`, "Uang Muka dan Titipan" → `/WebKewajiban`, "Rekonsiliasi" → `/WebRekonsiliasi`, "Bulan dan tutup buku" → `/WebTutupBuku`, "Laporan" → `/WebPaketLaporan`, "Pengaturan" → `/WebPengaturan`. Each item: min height 44, padding 0 12, radius 10 (off-token), 600, no underline. Active item: `tinta` field with `permukaan` text. Others: transparent with `tinta` text. All use `go`.
- On a window wider than 860 the same nav is the normal side column. It has flex-basis 220 and grows 1, padding 24 × 16, a right border 1 `garis`, a column with gap 20, and the footer pushed to the bottom.
- Main column: flex 999 1 560, padding top 28, sides clamp(16, 3 % of window width, 40) (25 at 834), bottom 40; a column. Page `kertas`, body `isiWeb` (15/1.45, `tinta`). Links `laut`, underlined (browser default), hover `lautTua`. Focus ring 2 `laut`, offset 2.
- No vacancy strip and no footer swap: these boards have no `jabatanKosong` tweak, so the global switch does nothing on them.

---

### TabBeranda — Tablet · Beranda

> Rules note: the three quick actions "+ Pendapatan", "− Belanja", "+ Persembahan" are all primary (`laut`) as drawn, against A01; logged in rules-checklist 4.2 and allowlisted in W3 (also WebBeranda).

- **Source** `docs/design/handoff/canvas/boards/TabBeranda.dc.html` · page Web (`web`) · form Tablet (preview 834×1112, `expand: fill`) · interactive yes
- **Route** `/TabBeranda`, no child routes · **Widget** `TabBerandaScreen` in `lib/screens/web/tab_beranda.dart`
- **Purpose** Bendahara Jemaat on a tablet: the home page, the entry point of journey step 2 (daily work). It is the same content as WebBeranda. Shows D03: one combined Saldo buku for all Kas/Bank, counting only booked transactions; drafts are kept out of the balance on a `draf` line. Shows the ButirPerhatian levels: "Perlu tindakan" with a counter, and a plain "Untuk diketahui". Shows the principle that what is not yet known prints "—", not Rp0, and that cash count and bank statement are never added together. Shows D29 (web side bar, here collapsed) and Q26 (the desk posts get the laptop layout, which also serves the tablet).
- **Shell** Tablet nav: the collapsed finance nav (shared section above), active **Beranda**. Main column gap 24.
- **Layout** main column, top to bottom (at 834 the content is 784 wide):
  1. *Header row* (wrap, centred, gap 12): h1 "Beranda" (`judulHalaman` 26/700, flex 1 1 200). Month pill link "November 2026 · Belum ditutup": min height 44, padding 0 16, radius 999, 1 `garisTegas` edge, `permukaan`, 600 `tinta`, centred, no underline.
  2. *Link row* (wrap, gap 0 × 22, margin-top −8, 14/600, each link at least 44 × 44, centred vertically): "Pemberitahuan" · "Cari dan tanya".
  3. *Quick actions* (wrap, gap 8). Each is a link: min height 44, padding 0 18, radius 12, 700, no underline.
     - Primary style (`laut` field, `diLaut` text): "+ Pendapatan", "− Belanja" (U+2212), "+ Persembahan".
     - Secondary style (1.5 `tinta` edge, `permukaan`, `tinta` text): "Rekonsiliasi", "Buat laporan sementara".
     At 834 all five fit on one or two lines.
  4. *Figures grid*: `auto-fit, minmax(min(360, 100%), 1fr)`, gap 24, top-aligned. Two columns of 380 at 834.
     - Left, balance block (column gap 6):
       - 14 `tinta2` "Saldo buku semua Kas/Bank".
       - Mono 500 "Rp38.415.000", size clamp(34, 4.4 % of window width, 56) (36.7 at 834), letter-spacing −1.5, line height 1.05.
       - 13 `tinta3` "Hanya transaksi yang sudah dibukukan".
       - `ramai` only, the draft pill (`draf` line): aligned start, margin-top 8, 1.5 dashed `putus`, radius 999, padding 6 14, 13 `tinta2`. Text: "Rp800.000" in mono, then " · 2 draf · belum masuk saldo".
     - Right, tile grid `auto-fit, minmax(min(150, 100%), 1fr)`, gap 12. At 834 this gives two tiles on row 1 and the third alone on row 2. Each tile: `permukaan`, 1 `garis`, radius 14, padding 14 16. Inside: label 13 `tinta2`; value mono 19/500, margin-top 2; caption 13 `tinta3`. Tiles:
       - "Pendapatan bulan ini" · "Rp7.540.000" · "tanpa titipan"
       - "Belanja bulan ini" · "Rp7.940.000" · "tanpa titipan"
       - "Surplus/Defisit bulan ini" · "−Rp400.000" · "hanya yang sudah dibukukan"
       With `sepi`, all three values are "Rp0".
  5. *Second grid* (same columns, gap 24, top-aligned):
     - Left (column gap 12):
       - Heading row (gap 8): h2 "Perlu tindakan" 17/700, then the counter: `bata` field, `diBata` 13/700, radius 999, min width 22, height 22, padding 0 6, centred. It shows the number of rows.
       - List card (`permukaan`, 1 `garis`, radius 14, padding 0 16). Each row is a link: min height 60, gap 12, top border 1 `garis` from the second row on, no underline, `tinta`. A row has a title (600), a subtitle (13), and a chevron at the right (18 × 18, path `M9 6l6 6-6 6`, stroke `tinta3` 2, round caps). The first row's subtitle is `bata` 700; the others are `tinta3` 400.
       - Rows:
         1. "Oktober 2026 belum ditutup" · "1 hambatan · bulan berikutnya untuk tutup buku" → `/WebTutupBuku`
         2. (`ramai`) "2 draf belum dibukukan" · "Belum masuk saldo · Rp800.000" → `/WebTransaksi`
         3. (`ramai`) "1 dokumen pendukung wajib, belum ada" · "BKU-2026-0143 · Rp600.000" → `/WebTransaksi`
         4. (`ramai`) "1 Mata Anggaran belum dipilih" · "Draf · Honor pemusik" → `/WebTransaksi`
       - Under the card, `sepi`: a dashed box (`draf` line, 1.5 dashed `putus`, radius 14, padding 14 16, 14 `tinta2`): "**Belum ada transaksi di November.** Bulan tanpa transaksi belum selesai: tiap Kas/Bank tetap perlu hitung kas atau rekening koran, lalu tutup buku." The bold part is `tinta`.
       - Under the card, `ramai`: h2 "Untuk diketahui" 17/700 (margin 8 0 6), then a plain link, 14 `tinta2`, underlined: "2 uang muka dengan sisa belum dipertanggungjawabkan · Rp1.150.000".
     - Right (column gap 12):
       - h2 "Posisi Kas & Bank" 17/700, followed inline by " · November 2026" (13/500 `tinta3`).
       - Table card: `permukaan`, 1 `garis`, radius 14, horizontal scroll inside the card. The table has min width 520 and 14 px text, so at 834 (column 380) it scrolls sideways.
       - Header cells (padding 12 16, 600 `tinta2`): "Kas/Bank" (left) | "Saldo buku" | "Hasil hitung kas" | "Saldo rekening koran" (the last three right-aligned).
       - Body cells: padding 12 16, top border 1 `garis`. Names 600; amounts mono, right-aligned. Rows:
         - "Kas" · "Rp8.420.000" · cell `tinta2`, right: "— " + 13 "Belum dihitung" + " · " + link 13/700 "Hitung kas" · empty.
         - "Bank BNI ··4821" · "Rp24.615.000" · empty · cell `tinta2`, right: "— " + 13 "Rekening koran belum diisi".
         - "Bank SulutGo ··1107" · "Rp5.380.000" · empty · "— Rekening koran belum diisi" (same style).
       - Caption 13 `tinta3`: "Hasil hitung kas dan saldo rekening koran tidak pernah dijumlahkan. Yang belum ada ditampilkan sebagai “—”, bukan Rp0."
- **Components** ButirPerhatian (Perlu tindakan rows with chevrons; "Untuk diketahui" plain), Tombol (quick actions: primary and secondary), GarisStatus (`draf` pill and `sepi` box). Repeated patterns, not components: figure tiles, the `bata` counter badge, the Kas & Bank table, the inline link row, the collapsed finance nav.
- **Internal views and states** No state object. Content comes from the `bulan` tweak only (ramai or sepi). The page-level menu toggle (open/closed) is the only local UI state.
- **Tweaks** (Keadaan panel)
  - `bulan` ("ramai" · "sepi", default "ramai"). `sepi` makes these changes:
    - the draft pill is hidden;
    - the three tiles read "Rp0";
    - Perlu tindakan keeps only the October row, and the counter reads "1";
    - the dashed "Belum ada transaksi di November." box shows;
    - "Untuk diketahui" and its link are hidden.
    Saldo buku "Rp38.415.000" and the Kas & Bank table do not change. `ramai` shows everything as listed in Layout, with counter "4".
- **Interactions** None in the logic class (`renderVals` only builds lists). Every control is a link (below). The menu toggle opens and closes the nav block.
- **Motion** none (no keyframes on the board).
- **Links out**
  - "November 2026 · Belum ditutup" → `/WebPilihBulan` (push).
  - "Pemberitahuan" → `/WebPemberitahuan` (push); "Cari dan tanya" → `/WebCari` (push).
  - "+ Pendapatan", "− Belanja", "+ Persembahan" → `/WebTransaksi` (go).
  - "Rekonsiliasi" → `/WebRekonsiliasi` (go); "Buat laporan sementara" → `/WebLaporan` (push).
  - Perlu tindakan rows (built in JS): "Oktober 2026 belum ditutup" → `/WebTutupBuku` (go). The other three rows → `/WebTransaksi` (go).
  - "2 uang muka dengan sisa belum dipertanggungjawabkan · Rp1.150.000" → `/WebKewajiban` (go).
  - "Hitung kas" → `/WebHitungKas` (push).
  - Nav items (go): `/WebBeranda`, `/WebTransaksi`, `/WebKewajiban`, `/WebRekonsiliasi`, `/WebTutupBuku`, `/WebPaketLaporan`, `/WebPengaturan`.
  - **Inbound** none (launcher only).
- **Mock data**
  - Saldo buku Rp38.415.000 = Kas Rp8.420.000 + Bank BNI ··4821 Rp24.615.000 + Bank SulutGo ··1107 Rp5.380.000.
  - Drafts: 2, totalling Rp800.000. Pendapatan Rp7.540.000; Belanja Rp7.940.000; Surplus/Defisit −Rp400.000.
  - Oktober 2026 open with 1 hambatan. BKU-2026-0143 Rp600.000. Draf "Honor pemusik". 2 uang muka, Rp1.150.000.
  - Month "November 2026 · Belum ditutup". Church "Jemaat Karunia"; footer "Meiske L. · Bendahara". Use the same constants as WebBeranda.
- **Prototype-only** none. Keadaan panel: `bulan`.
- **Acceptance checks**
  1. Open `/TabBeranda` at 834 wide → the nav is a top bar with "palakat / Jemaat Karunia" and a "Menu" button. No item list shows until "Menu" is pressed; then the 7 items appear with "Beranda" on a `tinta` field, the button reads "Tutup menu", and the footer reads "Meiske L. · Bendahara / Wewenang Bendahara aktif".
  2. At 834 the balance "Rp38.415.000" renders at about 36.7 px, beside the tiles. The tiles show "Rp7.540.000" and "Rp7.940.000" on one row and "−Rp400.000" on the next. The dashed pill reads "Rp800.000 · 2 draf · belum masuk saldo".
  3. Perlu tindakan counter shows "4" on a `bata` pill. The first subtitle "1 hambatan · bulan berikutnya untuk tutup buku" is bold `bata`.
  4. Set `bulan` = sepi → the counter shows "1" with one row; the dashed "Belum ada transaksi di November. …" box shows; the tiles read "Rp0" three times; there is no pill and no "Untuk diketahui". The balance is still "Rp38.415.000".
  5. The Kas & Bank table scrolls horizontally inside its card at 834. No cell shows "Rp0"; the Kas row shows "— Belum dihitung · Hitung kas".
  6. "Hitung kas" opens `/WebHitungKas` and Back returns to `/TabBeranda`. "+ Persembahan" opens `/WebTransaksi`. "Oktober 2026 belum ditutup" opens `/WebTutupBuku`.
  7. Turning the global `jabatanKosong` on changes nothing on this board.
  8. At a 1280 window the nav becomes a 220 px side column and "Menu" is gone.
- **Notes**
  - Identical to WebBeranda except: no vacancy banner or footer swap, preview 834 × 1112, and the title. Build it as a thin screen over the same body widget and constants as WebBeranda, with the vacancy parts off. It keeps its own route and file.
  - Off-token: balance clamp 34–56 px, h2 17, tile value 19, nav radius 10, counter 22 high.
  - Three `laut` primary buttons on one page break "one primary button per screen"; copy the board.
  - All targets are laptop boards; there is no tablet version of any target. Follow the board.
  - The manifest marks `hasSideNav: false`; the board does have the nav (collapsed at 834).

---

### TabTransaksi — Tablet · Transaksi

- **Source** `docs/design/handoff/canvas/boards/TabTransaksi.dc.html` · page Web (`web`) · form Tablet (preview 834×1112, `expand: fill`) · interactive yes
- **Route** `/TabTransaksi`, no child routes (the detail is a panel below the table, not a route) · **Widget** `TabTransaksiScreen` in `lib/screens/web/tab_transaksi.dart`
- **Purpose** Bendahara Jemaat on a tablet, journey steps 2 and 3. It is WebTransaksi at tablet width: the month's transactions in every status, in the LencanaStatus shapes and line language (Draf dashed, Dibukukan solid, Dibalik outlined, Dibatalkan struck). Below the table, a detail panel lists what can be done and why not. Booking a Draf plays the `tinta` motion. Shows C01 (Kas/Bank as a second line under Uraian), D02 (a missing document blocks month close, not Bukukan: BKU-2026-0143), and the rule that a selected row gets a 3 px inner `laut` line on the left. Also D29 and Q26.
- **Shell** Tablet nav: the collapsed finance nav, active **Transaksi**. Main column gap 20.
- **Layout** main column, top to bottom:
  1. *Header row* (wrap, centred, gap 12): h1 "Transaksi" (`judulHalaman`, flex 1 1 200), then three links:
     - Month pill "November 2026 · Belum ditutup" (as TabBeranda).
     - "Impor": min height 44, padding 0 16, radius 12, 1.5 `tinta` edge, `permukaan`, 700 `tinta`.
     - "+ Catat transaksi": min height 44, padding 0 18, radius 12, `laut` field, `diLaut` 700.
     At 834 the h1 takes the first line and the three links wrap to the next, or all four share one line if they fit.
  2. *Link row* (wrap, gap 0 × 22, margin-top −8, 14/600, each at least 44 × 44): "Daftar Bukti Kas" · "Koreksi dengan pembalikan" · "Draf di bulan yang sudah ditutup" · "Pengembalian" · "Cari".
  3. *Filter chips* (wrap, gap 8). ChipPilihan pills: min height 44, padding 0 16, radius 999, 1.5 edge, 600/14, `aria-pressed`. Selected: `tinta` field and edge, `permukaan` text. Unselected: `permukaan`, `garisTegas` edge, `tinta` text. Chips: "Semua" · "Draf" · "Dibukukan" · "Dibalik" · "Dibatalkan".
  4. *Table and panel* (wrap, gap 24, top-aligned). At 834 they stack: the table takes the full 784, the panel sits below it at full width. With at least 904 px of content they sit side by side.
     - **Table** (flex 999 1 520). Card: `permukaan`, 1 `garis`, radius 14, horizontal scroll; inner min width 470.
       - Grid columns `104px 88px minmax(0, 1fr) 124px`, gap 12.
       - Header (padding 12 16, 13/600 `tinta2`): "Status" | "Tanggal" | "Uraian · No. Bukti · Kas/Bank" | "Jumlah (Rp)" (right).
       - Rows are buttons (left-aligned text, same grid and gap, cells centred vertically): full width, min height 56, padding 8 16, no edge except a top border 1 `garis`, 14 px, `aria-pressed`.
       - Row background: selected `lautLembut` with an inner 3 px `laut` line on the left edge; an unselected Draf `kertas`; others `permukaan`.
       - Status badge (13/700, padding 3 9, radius 6):
         - Draf: transparent, 1.5 dashed `putus`, `tinta2` text.
         - Dibukukan: `tinta` field, 1.5 `tinta` edge, `permukaan` text.
         - Dibalik: `permukaan`, 1.5 `tinta3` edge, `tinta2` text.
         - Dibatalkan: `kertas` field and edge, `tinta2` text.
       - Date: `tinta2`.
       - Uraian 600 (wraps anywhere). Under it, 13 `tinta2`: "{No. Bukti in mono} · {Kas/Bank}", with "—" when there is no number. Then an optional 13 `tinta3` note.
       - Amount: mono 500, right-aligned. `tinta3` for Draf and Dibatalkan, `tinta` otherwise; struck through for Dibatalkan.
     - **Detail panel** (`aside`, flex 1 1 360, column gap 14), for `data[pilih]`:
       - Status card: radius 16, padding 18, column gap 6, clipped. Draf: transparent with the `draf` line (1.5 dashed `putus`). Others: `permukaan` with the `terpilih` line (1.5 `tinta`).
         - Top row (space-between, centred, gap 8): the badge, labelled "Draf · belum masuk saldo" for Draf, otherwise the status word. On the right, mono 14 `tinta2`: the No. Bukti or "Belum ada No. Bukti". Whenever row 0 is booked and selected (`pilih === 0 && buku`, the board's `baruBuku`), the plain number is replaced by the stamp "No. Bukti BKU-2026-0147" (mono 14/600 `laut`, 2 px `laut` edge, radius 8, padding 4 10).
         - Amount: mono 32/500, letter-spacing −1; `tinta2` for Draf and Dibatalkan, else `tinta`.
         - Uraian 600; then 13 `tinta3` "{Kas/Bank} · tanggal transaksi {date}".
         - The `sapu` overlay sits on top of this card while it plays.
       - Facts card: `permukaan`, 1 `garis`, radius 14, padding 4 16. Rows: padding 10 0, gap 16, a divider from row 2. Key 14 `tinta2`; value 14/600, right-aligned, `bata` when flagged, else `tinta`.
       - Then one column, gap 8, holding the next four parts. h2 "Yang dapat dilakukan" (15/700, margin-top 4). Actions wrap, gap 8 (the row stays, empty, when there are no actions). Each action: min height 44, padding 0 16, radius 12, 700/14. Primary: `laut` field, `diLaut` text, no edge. Others: `permukaan`, 1.5 `tinta` edge, `tinta`. Then the note, 13 `tinta3`.
       - Last in that column, a nested column with gap 4: h2 "Riwayat" (15/700, margin-top 4), then the lines in 14 `tinta2`.
- **Components** LencanaStatus (table and panel badges), ChipPilihan (filters), Tombol (header buttons, panel actions), Penolakan-style note ("Tidak dapat dilakukan: Bukukan. …" on row 1, all `tinta3` here). Repeated patterns, not components: the selectable web data table, the detail panel, the key–value facts card, the booking card with stamp.
- **Internal views and states** Initial state `{ filter: 'Semua', pilih: 0, buku: false }`.
  - Filter (5 values) × selected row (0–6) × row 0 booked or not.
  - The table removes rows that do not match the filter ("Semua" keeps all). The panel always shows `data[pilih]`, even when the filter hides that row.
  - No sheets or toasts.
- **Tweaks** none (`data-props` has only `$preview`). The global `jabatanKosong` switch has no effect here.
- **Interactions**
  - Filter chip → `filter` = that value. The selection is unchanged.
  - Row press → `pilih` = row index; the row highlights and the panel updates.
  - "Periksa dan bukukan" (row 0 while Draf; the only real button, primary) → `buku = true`. Row 0 becomes Dibukukan with No. Bukti BKU-2026-0147:
    - its note is removed and its row background becomes selected/`permukaan`;
    - facts gain "Dibukukan pada · 16/11/2026 10.42";
    - actions become *Verifikasi / Lampirkan dokumen pendukung / Koreksi dengan pembalikan;
    - the note becomes "Jumlah, tanggal, Kas/Bank, peruntukan, Lingkup dan Mata Anggaran tidak dapat diubah lagi.";
    - Riwayat gets two lines.
    There is no undo.
  - Every other action is a link (push), by label:
    - "Verifikasi" → `/WebLihatDokumen`
    - "Lampirkan dokumen pendukung" → `/WebUnggah`
    - "Catat pengecualian" → `/WebDokumen`
    - "Koreksi dengan pembalikan" → `/WebKoreksi`
    - "Pilih Mata Anggaran" → `/WebCatat`
    - "Ubah" → `/WebCatat`
    - "Catat persetujuan" → `/WebPersetujuan`
    - "Batalkan" → `/WebDraf`
    - "Pindah tanggal" → `/WebDraf`
    - any other label ("Lihat transaksi asal", "Lihat pembalikan", "Lihat transaksi koreksi") → `/WebKoreksi`
  - Rows in board order (status · No. Bukti · date · Uraian · Kas/Bank · amount · table note), then that row's panel actions (primary marked *) and panel note:
    0. Draf · — · 16/11/2026 · Fotokopi warta jemaat · Kas · −Rp150.000 · "Belum masuk saldo".
       - Actions: *Periksa dan bukukan (button), Ubah, Pindah tanggal, Batalkan.
       - Note: "Semua syarat terpenuhi. Pindah tanggal dan Batalkan memerlukan alasan."
       - Once booked: Dibukukan · BKU-2026-0147 · no table note. Actions *Verifikasi, Lampirkan dokumen pendukung, Koreksi dengan pembalikan; note as listed under "Periksa dan bukukan" above.
    1. Draf · — · 08/11/2026 · Honor pemusik · Bank BNI ··4821 · −Rp650.000 · "Belum masuk saldo · Mata Anggaran belum dipilih".
       - Actions: *Pilih Mata Anggaran, Catat persetujuan, Lampirkan dokumen pendukung, Ubah, Batalkan.
       - Note: "Tidak dapat dilakukan: Bukukan. Mata Anggaran belum dipilih dan persetujuan belum dicatat."
    2. Dibukukan · BKU-2026-0146 · 15/11/2026 · Persembahan Ibadah Minggu · Kas · Rp3.450.000 · —.
       - Actions: Lampirkan dokumen pendukung, Koreksi dengan pembalikan.
       - Note: "Koreksi hanya lewat pembalikan, selama November 2026 belum ditutup."
    3. Dibukukan · BKU-2026-0143 · 11/11/2026 · Sewa sound system · Kas · −Rp600.000 · "Dokumen pendukung wajib, belum ada".
       - Actions: *Lampirkan dokumen pendukung, Catat pengecualian, Koreksi dengan pembalikan.
       - Note: "Menjadi hambatan tutup buku sampai dokumen terverifikasi atau dikecualikan dengan alasan."
    4. Dibukukan · BKU-2026-0144 · 12/11/2026 · Pembalikan BKU-2026-0139 · Kas · Rp750.000 · "Pembalikan".
       - Actions: Lihat transaksi asal.
       - Note: "Pembalikan tidak dapat diubah atau dibalik."
    5. Dibalik · BKU-2026-0139 · 09/11/2026 · Konsumsi rapat majelis · Kas · −Rp750.000 · "Dibalik oleh No. Bukti BKU-2026-0144".
       - Actions: Lihat pembalikan, Lihat transaksi koreksi.
       - Note: "Transaksi asal tetap tampil di daftar dan laporan."
    6. Dibatalkan · — · 05/11/2026 · Pembelian bunga altar · Kas · −Rp200.000 (struck) · "Tidak pernah dibukukan".
       - Actions: none; the heading still shows.
       - Note: "Hanya dapat dilihat. Transaksi ini tidak pernah punya No. Bukti."
  - Riwayat rule:
    - Draf: one line, "{date} · Draf dicatat oleh Meiske L.".
    - Otherwise two lines: "{Dibukukan pada} · Dibukukan oleh Meiske L." (just "Dibukukan oleh Meiske L." when there is no "Dibukukan pada"), then "{date} · Draf dicatat oleh Meiske L.".
  - Header, link row and nav: see Links out.
- **Motion** Only while row 0 is booked and selected (`pilih === 0 && buku`). Together these form Gerak `tinta`:
  - `sapu` (motion.md `sapu`): a `laut` overlay over the status card, pinned to the left edge, pointer-transparent, 700 ms ease-out, fill both. Keyframes: 0 % scaleX 0, opacity .2; 65 % scaleX 1, opacity .2; 100 % scaleX 1, opacity 0.
  - `cap` (motion.md `cap`): the stamp, 550 ms after a 350 ms delay, curve `Cubic(0.2, 0.8, 0.2, 1)`, fill both. Keyframes: 0 % opacity 0, scale 1.7, rotate −9°; 55 % opacity 1, scale .94, rotate −3°; 100 % scale 1, rotate −3°. It ends tilted −3°.
  - Both start when that condition turns true. They replay each time row 0 is selected again while booked. Changing the filter does not replay them.
  - `muncul` is declared but unused. There are no timers. Under reduce motion both jump to their end state.
- **Links out**
  - "November 2026 · Belum ditutup" → `/WebPilihBulan` (push); "Impor" → `/WebImpor` (push); "+ Catat transaksi" → `/WebCatat` (push).
  - Link row (push): "Daftar Bukti Kas" → `/WebBukti`; "Koreksi dengan pembalikan" → `/WebKoreksi`; "Draf di bulan yang sudah ditutup" → `/WebDraf`; "Pengembalian" → `/WebPengembalian`; "Cari" → `/WebCari`.
  - Panel action links as in Interactions (push).
  - Nav items (go), as in the shared section.
  - **Inbound** none (launcher only).
- **Mock data** Facts per row (key · value; † marks a `bata` value):
  - Row 0: Diambil dari peruntukan · Umum Jemaat; Lingkup · Jemaat; Mata Anggaran · Belanja 5.02.01.00 Alat tulis dan fotokopi; Persetujuan · Tidak diperlukan (aturan: transaksi rutin); Dokumen pendukung · Diunggah, belum diverifikasi. After booking, add Dibukukan pada · 16/11/2026 10.42.
  - Row 1: Diambil dari peruntukan · Umum Jemaat; Lingkup · Jemaat; Mata Anggaran · Mata Anggaran belum dipilih †; Persetujuan · Persetujuan belum dicatat †; Dokumen pendukung · Wajib, belum ada †.
  - Row 2: Masuk ke peruntukan · Umum Jemaat; Lingkup · Jemaat; Mata Anggaran · Pendapatan 1.3.53.07.00 Persembahan Ibadah Minggu; Versi Mata Anggaran · 2026.1; Dokumen pendukung · Terverifikasi (oleh Meiske L.); Dibukukan pada · 15/11/2026 12.20.
  - Row 3: Diambil dari peruntukan · Umum Jemaat; Lingkup · Panitia Natal; Mata Anggaran · Belanja 5.05.02.00 Sewa peralatan; Dokumen pendukung · Wajib, belum ada †; Dibukukan pada · 11/11/2026 16.05.
  - Row 4: Pembalikan dari · No. Bukti BKU-2026-0139; Alasan · Mata Anggaran keliru; Dibukukan pada · 12/11/2026 09.31.
  - Row 5: Dibalik oleh · No. Bukti BKU-2026-0144; Transaksi koreksi · No. Bukti BKU-2026-0145; Mata Anggaran · Belanja 5.02.01.00 Alat tulis dan fotokopi; Dibukukan pada · 09/11/2026 14.12.
  - Row 6: Alasan · Tercatat dua kali; Dibatalkan oleh · Meiske L.; Dibatalkan pada · 06/11/2026 08.02.
  - Also: new number BKU-2026-0147; month November 2026; actor Meiske L. Share the constants with WebTransaksi.
- **Prototype-only** none. Keadaan panel: no board tweaks.
- **Acceptance checks**
  1. Open `/TabTransaksi` at 834 → collapsed nav with "Menu"; filter "Semua" selected; the table spans the content width, and the detail panel is below it, not beside it.
  2. Row 0 is highlighted `lautLembut` with a 3 px `laut` left line. The panel card is dashed, with badge "Draf · belum masuk saldo", "Belum ada No. Bukti" and "−Rp150.000" in `tinta2`. Actions: "Periksa dan bukukan" (`laut`), "Ubah", "Pindah tanggal", "Batalkan".
  3. Press "Periksa dan bukukan" → row 0 shows "Dibukukan" and "BKU-2026-0147" and its note is gone. The panel card turns solid; the `laut` sweep plays and the stamp "No. Bukti BKU-2026-0147" lands tilted. Facts gain "Dibukukan pada 16/11/2026 10.42". Riwayat reads "16/11/2026 10.42 · Dibukukan oleh Meiske L." then "16/11/2026 · Draf dicatat oleh Meiske L.".
  4. Select row 2, then row 0 again → the sweep and stamp replay.
  5. Filter "Dibalik" → only "Konsumsi rapat majelis" remains in the table; the panel still shows the previously selected row.
  6. Select row 1 → three `bata` fact values. "Pilih Mata Anggaran" is the `laut` action and opens `/WebCatat`; Back returns to `/TabTransaksi`.
  7. Row 6 → in the table, amount "−Rp200.000" struck through in `tinta3` and the badge on a `kertas` field; in the panel, "Belum ada No. Bukti", "−Rp200.000" in `tinta2` (not struck), and "Yang dapat dilakukan" with no buttons. Riwayat reads "Dibukukan oleh Meiske L." then "05/11/2026 · Draf dicatat oleh Meiske L.".
  8. "Pengembalian" in the link row opens `/WebPengembalian`.
  9. Reduce motion on → booking shows the solid card and the stamp at once, with no sweep.
- **Notes**
  - Identical to WebTransaksi except: no vacancy banner or footer swap, no `jabatanKosong` tweak, preview 834 × 1112, and the title. Build it over the same body widget and constants as WebTransaksi. It keeps its own state, route and file.
  - The panel stacks under the table at 834 because table basis 520 + gap 24 + panel basis 360 exceeds the 784 content width. This is the drawn tablet layout.
  - Off-token: panel amount 32, stamp radius 8.
  - The Dibatalkan badge is a `kertas` field with a `kertas` edge; LencanaStatus says a `garis` field. Follow the board.
  - The Riwayat rule gives the reversal (row 4) "12/11/2026 · Draf dicatat oleh Meiske L." and the cancelled row "Dibukukan oleh Meiske L.". Reproduce exactly, as on WebTransaksi.
  - Column "Jumlah (Rp)" still prints "Rp" in each figure. Rows are not sorted by date. Copy both.
  - The manifest marks `hasSideNav: false`; the board has the nav.

---

### TabCatat — Tablet · Catat transaksi

- **Source** `docs/design/handoff/canvas/boards/TabCatat.dc.html` · page Web (`web`) · form Tablet (preview 834×1112, `expand: fill`) · interactive yes
- **Route** `/TabCatat`, no child routes (the Mata Anggaran picker is inline; posting changes the page in place) · **Widget** `TabCatatScreen` in `lib/screens/web/tab_catat.dart`
- **Purpose** Bendahara Jemaat on a tablet, journey step 2: record a Pendapatan, Belanja or Pindah antar Kas/Bank, then check it and post it (Periksa dan bukukan), or leave as a draft. It is WebCatat at tablet width. Shows:
  - D01: Kas/Bank, peruntukan, Lingkup and Mata Anggaran are four separate fields, all empty at the start, never guessed from one another.
  - D02: a missing supporting document is information only ("menjadi hambatan tutup buku") and does not block posting.
  - PemilihMataAnggaran rules: group headings cannot be posted; "Simpan tanpa Mata Anggaran" has a dashed edge; there is no "Lainnya".
  - A transfer between Kas/Bank is neither Pendapatan nor Belanja, and a bank fee is a separate Belanja.
  - The approval rule "transaksi rutin".
  - The draf → dibukukan line change on the summary card and the No. Bukti stamp.
  - Q26.
- **Shell** Tablet nav: the collapsed finance nav, active **Transaksi**. Main column gap 20.
- **Layout** main column, top to bottom:
  1. *Title block*: breadcrumb link "Transaksi" (14/600 `laut`, underlined), then h1 "Catat transaksi" (`judulHalaman`, margin-top 2).
  2. *Link row* (wrap, gap 0 × 22, margin-top −8, 14/600, each at least 44 × 44): "Bagi ke beberapa Mata Anggaran" · "Persembahan" · "Alih peruntukan" · "Dari foto nota" · "Ganti catatan persetujuan" · "Tanggal transaksi" · "Usulan Mata Anggaran" · "Dari kalimat". At 834 this wraps (about two lines; the count depends on font metrics).
  3. *Kind chips* (wrap, gap 8, no margins): "Pendapatan" · "Belanja" · "Pindah antar Kas/Bank". ChipPilihan: inline, min height 44, padding 0 14, radius 999, 1.5 edge, 600/14, `aria-pressed`. Selected `tinta`/`permukaan`; unselected `permukaan`, `garisTegas` edge, `tinta` text. Default "Belanja".
  4. *Form and summary* (wrap, gap 28, top-aligned). At 834 they stack: the form at full width (784), the summary below it.
     **Form** (flex 999 1 480, column gap 18):
     a. *Jumlah*. Label "Jumlah (Rp)" (14 `tinta2`, label for the input). Then a row, max width 420: baseline-aligned, gap 8, mono, 2 px `tinta` underline, padding-bottom 4. In the row: "Rp" mono 24 `tinta3`, then the input. Input: mono 40/500, letter-spacing −1, no border, transparent, padding 0, min height 44, numeric keyboard, hint "0" (`tinta3`).
     b. *Field grid* `auto-fit, minmax(min(260, 100%), 1fr)`, gap 18. Two columns at 834. Each field has a label (14 `tinta2`, margin-bottom 8) above chips. Each chip is inline: min height 44, padding 0 14, margin 0 8 8 0, radius 999, 1.5 edge, 600/14, `aria-pressed`, same colours as the kind chips.
        - Kas/Bank field. Label "Kas/Bank" ("Dari Kas/Bank" in Pindah). Chips: "Kas", "Bank BNI ··4821", "Bank SulutGo ··1107".
        - Pindah only: "Ke Kas/Bank" with the same three chips. Under them, 13 `tinta3`: "Bukan Pendapatan dan bukan Belanja. Biaya bank dicatat sebagai Belanja tersendiri."
        - Pendapatan/Belanja only: peruntukan. Label "Diambil dari peruntukan" (Belanja) or "Masuk ke peruntukan" (Pendapatan), followed by `tinta3` " · uang siapa ini". Chips: "Umum Jemaat", "Diakonia", "Pembangunan".
        - Pendapatan/Belanja only: "Lingkup". Chips: "Jemaat", "Kolom 3", "BIPRA Pemuda", "Panitia Natal".
        In Belanja at 834: Kas/Bank | peruntukan on row 1, Lingkup on row 2. In Pindah: Dari | Ke.
     c. Pendapatan/Belanja only, *Mata Anggaran* (column gap 8):
        - Label row (wrap, centred, gap 10): "Mata Anggaran" 14 `tinta2` + `tinta3` " · untuk apa", then the tree badge: 13/700, radius 6, padding 3 9, `tinta` field, `permukaan` text, "Belanja" or "Pendapatan".
        - Picker card: `permukaan`, 1 `garis`, radius 14, padding 10 14. Contents, top to bottom:
          - Search input: Semantics label "Cari Mata Anggaran", hint "Cari nomor atau nama", full width, min height 44, padding 0 14, radius 12, 1 `garisTegas` edge, `kertas` background.
          - The list, one entry per row in board order:
            - Group heading (padding 10 0 4): code (mono 13 `tinta3`), a space, the name (strong 14 `tinta2`), a space, then 13 `tinta3` "· Judul kelompok, tidak dapat dibukukan". Not pressable.
            - Postable row: a button, full width, min height 44, padding 8 12, radius 10, margin-top 4, `permukaan`, baseline row, gap 12, `aria-pressed`. Edge: selected 2 `tinta`, else 1 `garis`. Text: "{tree} {code}" (mono 13 `tinta2`), then the name (600).
          - "Simpan tanpa Mata Anggaran": margin-top 10, min height 44, padding 0 16, radius 10, `draf` line (1.5 dashed `putus`), transparent, 700 `tinta2`.
     d. Pendapatan/Belanja only, *Pihak and Uraian* grid (same columns, gap 18). Two text inputs: min height 48, padding 0 14, radius 12, 1 `garisTegas` edge, `permukaan`. Labels: 14 `tinta2`, block, margin-bottom 6.
        - Pihak label: "Dibayar kepada" (Belanja) or "Diterima dari (boleh tanpa nama)" (Pendapatan).
        - Uraian label: "Uraian".
     e. *Footer row* (wrap, centred, gap 12 × 24, top border 1 `garis`, padding-top 14):
        - "Tanggal transaksi" (14 `tinta2`), a space, then strong "16 November 2026".
        - Document button: min height 44, padding 0 16, radius 12. Not attached: label "Lampirkan dokumen pendukung", 1.5 dashed `putus` edge, transparent, 600 `laut`. Attached: label "nota-16-11.jpg · Terlampir", 1 `garisTegas` edge, `permukaan`, 600 `tinta`.
     **Summary** (`aside`, flex 1 1 360, column gap 14):
     f. *Summary card*: radius 16, padding 18, column gap 6, clipped.
        - Before posting: transparent with the `draf` line (1.5 dashed `putus`). After posting: `permukaan` with 1.5 `tinta`.
        - Top row (space-between, centred, gap 16): the badge (13/700, radius 6, padding 3 9). Before posting: "Draf · belum masuk saldo", transparent, 1.5 dashed `putus`, `tinta2`. After posting: "Dibukukan", `tinta` field and edge, `permukaan` text.
        - After posting, the stamp at the right of the top row: "No. Bukti BKU-2026-0147", mono 14/600 `laut`, 2 `laut` edge, radius 8, padding 4 10.
        - Amount: mono 32/500, letter-spacing −1. `tinta2` before posting, `tinta` after. The value is `rp(amount × sign)`: Belanja negative, Pendapatan and Pindah positive. Empty shows "Rp0".
        - Summary line (600):
          - Pindah: "Dari {Dari name or …} ke {Ke name or …}" (U+2026).
          - Otherwise the Uraian, else the Pihak, else the kind name ("Belanja", "Pendapatan").
     g. Before posting only:
        - *Checks card*: `permukaan`, 1 `garis`, radius 14, padding 4 16. Each row: padding 10 0, gap 10, top-aligned, divider 1 `garis` from row 2, text 14/600. The icon is 20 × 20, drawn from the board's SVG:
          - met: filled `laut` circle r 11 with a `diLaut` tick `M7 12.5l3.2 3.2L17 9` (stroke 2.2, round). Semantics "Terpenuhi".
          - unmet: `bata` rounded square x 1 y 1, 22 × 22, rx 6, with a `diBata` "!" `M12 6.5v7M12 17v.5` (stroke 2.4, round). Semantics "Belum terpenuhi".
          - information: a dashed `tinta3` circle, r 10, stroke 2, dash 3 3. Semantics "Untuk diketahui".
          The rows are listed under Interactions.
        - *Refusal*, while any check is unmet: 14/600 `bata`, "Tidak dapat dilakukan: {n} syarat belum terpenuhi.".
        - *Buttons* (wrap, gap 8):
          - "Periksa dan bukukan": min height 46, padding 0 20, radius 12, no edge, 700. Met: `laut` field, `diLaut` text. Unmet: `garis` field, `tinta3` text.
          - "Simpan sebagai draf": a link styled as a secondary button. Min height 46, padding 0 20, radius 12, 1.5 `tinta` edge, `permukaan`, 700 `tinta`, centred.
     h. After posting only:
        - 14 `tinta2` "Dibukukan pada 16/11/2026 10.42 · tidak dapat diubah lagi."
        - Button "Catat lagi": min height 46, padding 0 20, radius 12, 1.5 `tinta` edge, `permukaan`, 700 `tinta`, aligned start.
- **Components** ChipPilihan (kind, Kas/Bank, Ke Kas/Bank, peruntukan, Lingkup); IsianJumlah (Jumlah, enlarged to 40 px); PemilihMataAnggaran (inline searchable list with group headings and "Simpan tanpa Mata Anggaran"); LencanaStatus (Draf · belum masuk saldo, Dibukukan); GarisStatus (`draf` card becoming `terpilih`; dashed document button); TombolBersyarat-like "Periksa dan bukukan" with a Penolakan line; Tombol (secondary "Simpan sebagai draf", "Catat lagi"). Repeated patterns, not components: the check row with three icons (as on Main's Periksa view), the inline link row, the collapsed finance nav.
- **Internal views and states**
  - Initial state: `{ jenis: 'belanja', jm: '', pihak: '', ur: '', akun: null, ke: null, per: null, ling: null, ma: null, cari: '', dok: false, posted: false }`. `jm` holds digits only; `akun` and `ke` are ids `kas`, `bni` or `bsg`; `ma` is a code.
  - Views by kind:
    - Pendapatan or Belanja: fields a, b (Kas/Bank, peruntukan, Lingkup), c, d, e.
    - Pindah: fields a, b (Dari, Ke + note), e.
  - Summary sub-states:
    - before posting: checks, refusal (when n > 0), two buttons;
    - after posting: stamp, solid card, "Dibukukan pada …", "Catat lagi".
  - The form stays visible after posting.
- **Tweaks** none (only `$preview`). The global `jabatanKosong` switch has no effect.
- **Interactions**
  - Kind chip → only when not posted: `jenis = k`, `ma = null`, `ke = null`, `cari = ''`. The amount, Kas/Bank, peruntukan, Lingkup, Pihak, Uraian and document are kept. Labels, the tree badge, the MA list, the sign of the amount and the checks change.
  - Amount input (`onJm`) → only when not posted. Keep digits only, strip all leading zeros, and keep at most 12 digits. Display with dot thousands separators while typing: "150000" → "150.000". Typing "0" alone leaves the field empty.
  - Kas/Bank, Ke Kas/Bank, peruntukan and Lingkup chips → only when not posted: set that field to the chip. Pressing the selected chip keeps it selected; there is no deselect.
  - MA search (`onCari`) → `cari` as typed. Matching is case-insensitive. Group headings always show. A postable row shows when the search is empty or when "{code} {name}" contains the query. With no match, only the headings remain; there is no empty message.
  - Postable MA row → only when not posted: `ma` = its code; its edge becomes 2 `tinta`.
  - "Simpan tanpa Mata Anggaran" → only when not posted: `ma = null`. It clears the choice and saves nothing.
  - Pihak, Uraian inputs → set `pihak` / `ur` as typed. They update the summary line. They also work after posting (no guard in the board).
  - Document button (`lampir`) → only when not posted: `dok = true`. There is no detach; pressing it again changes nothing.
  - Checks, recomputed on every change, in this order:
    - Pendapatan/Belanja:
      1. amount > 0 ? met "Jumlah {rp(amount)}" (positive, e.g. "Jumlah Rp150.000") : unmet "Jumlah belum diisi".
      2. Kas/Bank ? met "Kas/Bank: {name}" : unmet "Kas/Bank belum dipilih".
      3. peruntukan ? met "{peruntukan label}: {value}" (e.g. "Diambil dari peruntukan: Umum Jemaat") : unmet "Peruntukan belum dipilih".
      4. Lingkup ? met "Lingkup: {value}" : unmet "Lingkup belum dipilih".
      5. MA ? met "Mata Anggaran sudah dipilih" : unmet "Mata Anggaran belum dipilih · tetap bisa disimpan sebagai draf".
      6. always met: "Persetujuan: tidak diperlukan (aturan: transaksi rutin)".
      7. document ? met "Dokumen pendukung: diunggah, belum diverifikasi" : information "Dokumen pendukung: wajib, belum ada · menjadi hambatan tutup buku".
    - Pindah:
      1. the amount check as above.
      2. Dari and Ke set and different ? met "Dari {Dari} ke {Ke}" : unmet "Kas/Bank asal dan tujuan belum dipilih, dan harus berbeda".
      3. always met: "Bukan Pendapatan dan bukan Belanja".
      4. the document row as above.
    - n = number of unmet rows. Information rows never count.
  - "Periksa dan bukukan" → posts only when n = 0: `posted = true`. On press, re-check from the current state. The first press after the last input works. While n > 0 it does nothing; the refusal is already shown. The board sets the `disabled` attribute while n > 0, so Semantics must report it disabled. Draw it disabled, but keep `onPressed` re-checking, not `null` (TombolBersyarat).
  - "Simpan sebagai draf" → link to `/WebTransaksi`. It is always available and saves nothing.
  - "Catat lagi" (`lagi`) → reset everything except `jenis`: amount, Pihak, Uraian, Kas/Bank, Ke, peruntukan, Lingkup, MA and search all cleared; `dok = false`, `posted = false`. The summary returns to the dashed card.
- **Motion**
  - The stamp "No. Bukti BKU-2026-0147" enters with `muncul` (motion.md `muncul`: opacity 0 → 1, translateY 8 → 0), 400 ms, CSS default `ease` (`Curves.ease`, no curve given on the board), fill both, when `posted` turns true. It replays after "Catat lagi" and a new post (the stamp remounts).
  - The card's dashed → solid change and the badge swap are instant. There is no `sapu` sweep and no balance count on this board.
  - `isi` and `titik` are declared but unused. There are no timers. Reduce motion shows the stamp at once.
- **Links out**
  - Breadcrumb "Transaksi" → `kembaliKe('/WebTransaksi')` (up link; from the launcher this is `go`).
  - Link row (push):
    - "Bagi ke beberapa Mata Anggaran" → `/WebBagi`
    - "Persembahan" → `/WebPersembahan`
    - "Alih peruntukan" → `/WebAlihPeruntukan`
    - "Dari foto nota" → `/WebAIFoto`
    - "Ganti catatan persetujuan" → `/WebPersetujuan`
    - "Tanggal transaksi" → `/WebTanggal`
    - "Usulan Mata Anggaran" → `/WebAIMataAnggaran`
    - "Dari kalimat" → `/WebBantuanAI`
  - "Simpan sebagai draf" → `/WebTransaksi` (go; a side-nav page).
  - Nav items (go), as in the shared section.
  - **Inbound** none (launcher only).
- **Mock data**
  - Kas/Bank: Kas (`kas`), Bank BNI ··4821 (`bni`), Bank SulutGo ··1107 (`bsg`).
  - Peruntukan: Umum Jemaat, Diakonia, Pembangunan.
  - Lingkup: Jemaat, Kolom 3, BIPRA Pemuda, Panitia Natal.
  - Mata Anggaran, Belanja tree (headings marked H):
    - 5.00.00.00 BELANJA OPERASIONAL (H)
    - 5.01.02.00 Listrik, air dan telepon
    - 5.02.01.00 Alat tulis dan fotokopi
    - 5.03.03.00 Biaya administrasi bank
    - 4.00.00.00 BELANJA PELAYANAN (H)
    - 4.03.03.00 Diakonia duka
  - Mata Anggaran, Pendapatan tree:
    - 1.3.53.00.00 PERSEMBAHAN (H)
    - 1.3.53.07.00 Persembahan Ibadah Minggu
    - 1.3.53.09.00 Persembahan syukur
    - 1.4.10.00.00 SUMBANGAN (H)
    - 1.4.10.02.00 Sumbangan donatur
  - Date "16 November 2026"; file "nota-16-11.jpg"; new No. Bukti BKU-2026-0147; posted at 16/11/2026 10.42.
  - Share these with WebCatat.
- **Prototype-only** none. Keadaan panel: no board tweaks.
- **Acceptance checks**
  1. Open `/TabCatat` at 834:
     - "Belanja" is selected.
     - The summary card is below the form, dashed, with "Draf · belum masuk saldo", "Rp0" and "Belanja".
     - The checks show five `bata` rows, one met "Persetujuan: tidak diperlukan (aturan: transaksi rutin)" and one dashed information row.
     - The refusal reads "Tidak dapat dilakukan: 5 syarat belum terpenuhi." and "Periksa dan bukukan" is on `garis` with `tinta3` text.
  2. Type "a150000" in Jumlah → the field shows "150.000"; the card shows "−Rp150.000"; the first check reads "Jumlah Rp150.000"; the refusal says "4 syarat".
  3. Choose Kas, Umum Jemaat, Jemaat and "Belanja 5.02.01.00 Alat tulis dan fotokopi" → the refusal disappears and the button turns `laut`. Press once → the card turns solid with "Dibukukan"; the stamp "No. Bukti BKU-2026-0147" fades up; "Dibukukan pada 16/11/2026 10.42 · tidak dapat diubah lagi." and "Catat lagi" replace the checks and buttons.
  4. After posting, tapping chips, MA rows or the amount changes nothing. "Catat lagi" restores the empty form with "Belanja" still selected.
  5. Type "listrik" in "Cari nomor atau nama" → only "Belanja 5.01.02.00 Listrik, air dan telepon" remains, under "5.00.00.00 BELANJA OPERASIONAL"; the heading "4.00.00.00 BELANJA PELAYANAN" still shows with no rows.
  6. Choose "Pendapatan" → the badge reads "Pendapatan", the peruntukan label is "Masuk ke peruntukan · uang siapa ini", the Pihak label is "Diterima dari (boleh tanpa nama)", the MA choice is cleared, and the amount is positive.
  7. Choose "Pindah antar Kas/Bank" → peruntukan, Lingkup, MA, Pihak and Uraian disappear and "Ke Kas/Bank" appears with its note. Pick Kas and Kas → the unmet check reads "Kas/Bank asal dan tujuan belum dipilih, dan harus berbeda". Change Ke to Bank BNI → the check reads "Dari Kas ke Bank BNI ··4821" and the summary reads "Dari Kas ke Bank BNI ··4821".
  8. "Lampirkan dokumen pendukung" → the button reads "nota-16-11.jpg · Terlampir" with a solid edge; the last check becomes met "Dokumen pendukung: diunggah, belum diverifikasi".
  9. "Simpan sebagai draf" opens `/WebTransaksi`. "Dari foto nota" opens `/WebAIFoto` and Back returns to `/TabCatat` with the form as left.
- **Notes**
  - Identical to WebCatat except: no vacancy banner or footer swap, no `jabatanKosong` tweak, preview 834 × 1112, and the title. Build it over the same body widget and constants as WebCatat, with its own state, route and file.
  - The refusal shows on the empty form, and it counts the unmet conditions instead of naming the first one. Its whole sentence is `bata`. TombolBersyarat and Penolakan say otherwise; the board wins. Copy it.
  - The unmet button uses `tinta3` text (the Tombol "nonaktif" rule), not `tinta2`.
  - Posting uses only `muncul` on the stamp, not the full Gerak `tinta` (sweep + stamp + count). Keep the board.
  - Pihak, Uraian and the MA search stay editable after posting and still change the summary line. Reproduce; flag for the design owner.
  - "Simpan sebagai draf" is only a link; no draft appears in WebTransaksi.
  - Off-token: amount input 40 px (jumlahIsian is 30), "Rp" prefix 24, summary amount 32, stamp radius 8, MA row and "Simpan tanpa" radius 10, button height 46.
  - Duplicate inline values; the last one wins: kind chips margin 0; search input min height 44 and background `kertas`.
  - Amount keeps up to 12 digits here (11 on the Alur boards).

---

### PetaPlatform — Peta layar · Putaran 2–5

- **Source** `docs/design/handoff/canvas/boards/PetaPlatform.dc.html` · page Peta dan keputusan (`sistem`) · form Sheet 1280×2100 · interactive yes (links only)
- **Route** `/PetaPlatform`, no child routes · **Widget** `PetaPlatformScreen` in `lib/screens/sistem/peta_platform.dart`
- **Purpose** For anyone reviewing the design or the build. It is the screen map of the platform rounds 2 to 5, with a link to every board's phone and web version, a note on what changed in round 1, and the decisions of 18/11/2026. The decisions shown are Q25–Q32 (printed as 25–32) and R01 (Ketua Jemaat is the Pendeta). Also D25/P01 (sign-in by phone code), the RD04 mirror (refund to a donor), P02 (linking an account), P05 (lock screen) and P09 (in-app approvals). The text also cites older refs DL12, DL17, DL20 and DL26. `03-screens-and-flows.md` tells readers to start here ("Start on the page 'Peta dan keputusan'").
- **Shell** none. Sheet: a fixed 1280 × 2100 page that scrolls both ways, with links clickable.
- **Layout** The root is 1280 × 2100, padding 56, `kertas`, `tinta` text, body `isiWeb` (15/1.45), a column with gap 28.
  1. *Title block*:
     - "Peta layar · Putaran 2–5": 36/700, line height 1.1, letter-spacing −0.5 (off-token).
     - Under it, 15 `tinta2`, margin-top 4: "Brief versi 2, 18/11/2026. 56 layar: semuanya untuk ponsel, dan 30 di antaranya juga untuk laptop (Bendahara, Sekretaris Jemaat, Operator). Setiap layar hanya ada selama modulnya aktif."
  2. *Four columns*: grid `repeat(4, minmax(0, 1fr))`, gap 28, top-aligned; each column is 271 wide.
     - Column heading: 16/700 (`judulBagian`), padding-bottom 8.
     - Each entry: top border 1 `garis`, padding 8 0, column gap 2.
       - Line 1 (space-between, baseline, gap 12): the name, 700 14, then the links, 13 px, not shrinking. Links: "Ponsel" and/or "Web", `laut`, underlined, hover `lautTua`, separated by " · " in `tinta`.
       - Line 2: the states, 13 `tinta3`.
     - Entries in order (name | links | states):

     **Putaran 2 · Kerangka platform**
     | Entry | Links | States |
     | --- | --- | --- |
     | Beranda | Ponsel → `/BerandaJabatan` · Web → `/WebBerandaJabatan` | Beberapa jabatan · Bendahara Jemaat · Sekretaris Jemaat · Operator · Anggota jemaat · Jabatan dipilih otomatis · Dua jabatan dapat bertindak |
     | Modul | Ponsel → `/Modul` | Daftar modul · Mengaktifkan Data jemaat · Menonaktifkan Warta Jemaat · Dilihat jabatan lain |
     | Penugasan jabatan | Ponsel → `/Penugasan` · Web → `/WebPenugasan` | Daftar jabatan · Catat penugasan · Menugaskan diri sendiri · Menunggu verifikasi wewenang |
     | Menjalankan jabatan kosong | Ponsel → `/JabatanKosong` · Web → `/WebJabatanKosong` | Pita di setiap layar · Konfirmasi tutup buku · Tercatat di Riwayat · Wajib pemeriksa kedua · Jabatan sudah terisi |
     | Pelimpahan tugas | Ponsel → `/Pelimpahan` | Daftar pelimpahan · Buat pelimpahan · Berakhir sendiri |
     | Pemberitahuan | Ponsel → `/KotakMasuk` · Web → `/WebKotakMasuk` | Ada pemberitahuan · Semua sudah selesai · Hanya modul Keuangan |
     | Cari orang | Ponsel → `/CariOrang` · Web → `/WebCariOrang` | Dilihat Operator · Dilihat Penatua Kolom 7 · Tidak ada hasil |
     | Alur · Penugasan jabatan | Ponsel → `/AlurPenugasan` | Alur |
     | Alur · Menjalankan jabatan kosong | Ponsel → `/AlurJabatanKosong` · Web → `/WebAlurJabatanKosong` | Alur |
     | Alur · Pelimpahan tugas | Ponsel → `/AlurPelimpahan` | Alur |
     | Alur · Beranda gabungan | Ponsel → `/AlurBeranda` | Alur |
     | Alur · Modul | Ponsel → `/AlurModul` | Alur |
     | Alur · Masuk dan menghubungkan akun | Ponsel → `/AlurMasuk` · Web → `/WebAlurMasuk` | Alur |
     | Alur · Akun saya | Ponsel → `/AkunSaya` · Web → `/WebAkunSaya` | Alur |
     | Alur · Memulihkan akun anggota | Ponsel → `/AlurPulihkan` · Web → `/WebAlurPulihkan` | Alur |
     | Keadaan umum | Ponsel → `/KeadaanUmum` · Web → `/WebKeadaanUmum` | Memuat · Gagal memuat · Tanpa sambungan · Tidak berwenang · Modul tidak aktif · Sesi berakhir |

     **Putaran 3 · Sekretariat**
     | Entry | Links | States |
     | --- | --- | --- |
     | Dokumen gereja | Ponsel → `/DokumenGereja` · Web → `/WebDokumenGereja` | Daftar dokumen · Dokumen dengan revisi · Belum ada dokumen · Dilihat anggota jemaat |
     | Terbitkan dokumen | Ponsel → `/TerbitDokumen` · Web → `/WebTerbitDokumen` | Mengisi · Sedang diunggah · Gagal diunggah · Diterbitkan · Ralat sebagai revisi |
     | Permohonan surat | Ponsel → `/PermohonanSurat` · Web → `/WebPermohonanSurat` | Diajukan · Menerbitkan surat · Data jemaat tidak aktif · Diterbitkan · Tidak diterbitkan |
     | Pengumuman | Ponsel → `/Pengumuman` · Web → `/WebPengumuman` | Daftar · Draf · Diterbitkan · Diarsipkan sendiri · Ralat sebagai revisi |
     | Warta Jemaat · edisi 22/11/2026 | Ponsel → `/WartaEditor` · Web → `/WebWartaEditor` | Draf · Sudah diperiksa · Disetujui · Diterbitkan · Hanya Pengumuman yang aktif |
     | Tampilkan nama (pengecualian) | Ponsel → `/BukaNama` · Web → `/WebBukaNama` | Mengisi alasan · Alasan belum diisi · Tercatat · Bukan Sekretaris Jemaat |
     | Warta Jemaat | Ponsel → `/WartaArsip` · Web → `/WebWartaArsip` | Arsip edisi · Edisi dengan ralat · Dibaca anggota jemaat · Belum ada edisi |
     | Alur · Menerbitkan dokumen | Ponsel → `/AlurDokumen` · Web → `/WebAlurDokumen` | Alur |
     | Alur · Permohonan surat | Ponsel → `/AlurSurat` · Web → `/WebAlurSurat` | Alur |
     | Alur · Warta mingguan | Ponsel → `/AlurWarta` · Web → `/WebAlurWarta` | Alur |

     **Putaran 4 · Data jemaat**
     | Entry | Links | States |
     | --- | --- | --- |
     | Permohonan menjadi anggota | Ponsel → `/PermohonanAnggota` | Mengisi · Izin belum diberikan · Untuk anak · Diajukan · Dikembalikan · Diverifikasi · Tidak diterima |
     | Impor buku anggota | Ponsel → `/ImporBuku` · Web → `/WebImporBuku` | Ditampung · Lolos pengecekan · Sudah diimpor |
     | Konfirmasi keluarga | Ponsel → `/KonfirmasiKeluarga` | Belum dikonfirmasi · Dikonfirmasi di aplikasi · Formulir kertas diunggah · Aktif |
     | Verifikasi data | Ponsel → `/AntreanVerifikasi` | Antrean · Kembalikan dengan alasan · Milik keluarga sendiri · Jabatan kosong · Tidak ada yang menunggu |
     | Data anggota dan keluarga | Ponsel → `/DataAnggota` · Web → `/WebDataAnggota` | Dilihat Penatua Kolom 7 · Dilihat Sekretaris Jemaat · Belum dikonfirmasi · Meninggal dunia · Penatua Kolom lain |
     | Peristiwa | Ponsel → `/Peristiwa` | Mengajukan · Diajukan · Diverifikasi · Dikembalikan · Kematian · Pindah Kolom |
     | Tampilan nama saya di publikasi | Ponsel → `/TampilanNama` | Pilihan pribadi · Mengikuti bawaan keluarga · Masih mudah dikenali |
     | Cabut izin dan hapus data saya | Ponsel → `/CabutIzin` | Penjelasan · Konfirmasi · Permintaan lewat kertas · Sudah dihapus |
     | Kemungkinan data ganda | Ponsel → `/DataGanda` · Web → `/WebDataGanda` | Bandingkan · Gabungkan · Bukan orang yang sama |
     | Persembahan saya | Ponsel → `/PersembahanSaya` | Ada persembahan bernama · Rincian · Belum ada · Bukan persembahan saya |
     | Alur · Menjadi anggota | Ponsel → `/AlurAnggota` | Alur |
     | Alur · Peristiwa | Ponsel → `/AlurPeristiwa` | Alur |
     | Alur · Buku anggota | Ponsel → `/AlurKeluarga` · Web → `/WebAlurKeluarga` | Alur |
     | Alur · Data saya | Ponsel → `/AlurNama` | Alur |

     **Putaran 5 · Kolaborasi**
     | Entry | Links | States |
     | --- | --- | --- |
     | Keuangan Kolom 7 | Ponsel → `/KeuanganUnit` | Beranda unit · Dibukukan · Kas/Bank dikelola Bendahara Jemaat · Peruntukan lain · Pernyataan kesiapan · Tutup buku bukan wewenang unit |
     | Hambatan dari unit | Ponsel → `/SelesaikanUnit` · Web → `/WebSelesaikanUnit` | Hambatan · Mengisi alasan · Alasan belum diisi · Diselesaikan · Ada selisih |
     | Permintaan dana | Ponsel → `/PermintaanDana` | Menunggu persetujuan · Disetujui · Tidak disetujui · Kembali menunggu · Menyetujui permintaan sendiri · Di bawah batas · Persetujuan di luar aplikasi |
     | Panitia Natal 2026 | Ponsel → `/Panitia` | Perencanaan · Aktif · Penutupan keuangan · Sisa uang · Ditutup · Diarsipkan |
     | Ibadah dan kegiatan | Ponsel → `/Ibadah` | Draf · Dijadwalkan · Sedang berlangsung · Selesai · Ditutup · Ibadah seluruh Jemaat |
     | Jumlah kehadiran | Ponsel → `/Kehadiran` | Sedang dihitung · Sudah diperiksa · Ditetapkan · Koreksi · Petugas penghitung |
     | Laporan | Ponsel → `/LaporanLintas` · Web → `/WebLaporanLintas` | Seluruh Jemaat · Kolom 7 · Panitia Natal 2026 · Modul tidak aktif |
     | Persembahan bernama | Ponsel → `/PersembahanBernama` · Web → `/WebPersembahanBernama` | Tanpa nama · Pilih pemberi · Tercatat atas nama anggota · Belum dikonfirmasi · Dilihat jabatan lain |
     | Alur · Keuangan unit | Ponsel → `/AlurUnit` · Web → `/WebAlurUnit` | Alur |
     | Alur · Permintaan dana | Ponsel → `/AlurDana` | Alur |
     | Alur · Ibadah dan kehadiran | Ponsel → `/AlurIbadah` | Alur |
     | Alur · Panitia | Ponsel → `/AlurPanitia` | Alur |
     | Alur · Pemberi persetujuan | Ponsel → `/PemberiPersetujuan` | Alur |
     | Alur · Kas/Bank unit | Ponsel → `/KasUnit` · Web → `/WebKasUnit` | Alur |
     | Alur · Membentuk Panitia | Ponsel → `/AlurPanitiaBaru` | Alur |

     (These tables only list the content. On the sheet each entry is the two-line block described above, not a table row.)
  3. *Bottom grid* `minmax(0, 1.4fr) minmax(0, 1fr)`, gap 28, top-aligned:
     - **Left card** (`permukaan`, 1 `garis`, radius 14, padding 16 20, column gap 8):
       - Heading "Yang berubah di Putaran 1 (keuangan)" (700, 15).
       - Five paragraphs, 14 px, each a strong label then `tinta2` text:
         - "**Lingkup.** Komisi menjadi jenis Lingkup kelima (DL17): contoh di Pengaturan dan Pengaturan awal."
         - "**Pernyataan kesiapan.** Pindah ke Putaran 5; “penyiap” diganti bendahara unit (DL26). Bukan bagian pemeriksaan tutup buku V1."
         - "**Jabatan kosong.** Operator dapat menjalankan jabatan kosong, termasuk Bendahara Jemaat (DL12): pita di setiap layar dan nama Operator di konfirmasi tutup buku."
         - "**Pemberitahuan.** V1 tetap tanpa pemberitahuan dorong. Kotak Pemberitahuan untuk semua modul ada di Putaran 2; dorong lewat Firebase Cloud Messaging di Putaran 5 (DL20)."
         - "**Yang tidak berubah.** Layar keuangan V1, siklus bulanan, Paket Laporan, Bantuan AI dan kata-kata konfirmasi tutup buku."
       - A line of four links (14/700 `laut`, underlined), separated by " · " (the separators are plain 15 `tinta`): "Lihat keadaan jabatan kosong" · "Pernyataan kesiapan" · "Alur · Pengembalian" · "A4 · Warta Jemaat".
     - **Right card** (`draf` line: 1.5 dashed `putus`, radius 14, padding 16 20, column gap 8; no fill):
       - Heading "Diputuskan 18/11/2026" (700).
       - One paragraph, 14 `tinta2`, with the bold parts in strong (inherit `tinta2`, weight 700): "**25** Satu aplikasi untuk pelayan dan anggota. **26** Tata letak laptop hanya untuk Bendahara, Sekretaris Jemaat dan Operator; layar jabatan lain ponsel saja. **27** Warta Jemaat: templat A4 tetap sebagai PDF, juga dibaca di aplikasi. **28** Naskah izin data pribadi: naskah bawaan, belum ditinjau penasihat hukum. **29** Kategori BIPRA mengikuti ketentuan GMIM dan tidak diubah gereja: Anak sampai sebelum 12 tahun; Remaja 12 tahun sampai 17 tahun 364 hari; Pemuda 18 tahun ke atas dan belum pernah menikah; Bapa dan Ibu sudah menikah. **30** Label “Pelayan dan pengurus”. **31** Beranda gabungan; jabatan dipilih aplikasi per tindakan, dan ditanyakan bila dua jabatan berwenang. **32** Anggota hanya melihat persembahan bernama miliknya sendiri. **Ketua Jemaat** adalah Pendeta. **Masuk**: semua jabatan, termasuk Bendahara Jemaat, memakai kode ke nomor ponsel (WhatsApp atau SMS); email hanya cadangan untuk pemulihan akun. **Pengembalian kepada donatur** mengurangi Pendapatan di bulan uangnya dibayarkan. **Menghubungkan akun**: anggota mengisi nama dan tanggal lahir, Penatua Kolom memverifikasi. **Layar kunci**: pemberitahuan dorong hanya menyebut modul dan jenis pekerjaan, tanpa nama dan tanpa jumlah uang. **Persetujuan di aplikasi**: pemberi persetujuan ditetapkan menurut jabatan, sekali per gereja, tanpa batas jumlah."
     Below the bottom grid the page is empty `kertas` down to 2100.
- **Components** GarisStatus (the `draf` line on the decisions card). Repeated patterns, not components: the map entry (name, links, state list), the column heading, the note card.
- **Internal views and states** none (`renderVals` returns `{}`; no state object).
- **Tweaks** none. Keadaan panel: global switches only.
- **Interactions** none besides links.
- **Motion** none. The keyframes `isi`, `masuk`, `muncul` and `pudar` are declared but unused.
- **Links out** All 88 links are push, so Back returns to the map:
  - The 84 "Ponsel"/"Web" links listed in Layout 2.
  - "Lihat keadaan jabatan kosong" → `/JabatanKosong` (also linked as "Ponsel" in column 1).
  - "Pernyataan kesiapan" → `/Kesiapan`.
  - "Alur · Pengembalian" → `/AlurPengembalian`.
  - "A4 · Warta Jemaat" → `/A4Warta`.
  Every target must appear as `Tautan(ke: '…')`; the manifest lists 87 distinct targets (`JabatanKosong` is linked twice). **Inbound** none (launcher; the launcher should list it first under "Peta dan keputusan").
- **Mock data** Only the text above: brief version 2 dated 18/11/2026, the "56 layar … 30" count, four rounds, Panitia Natal 2026, Kolom 7, the Warta edition of 22/11/2026, Firebase Cloud Messaging, and the BIPRA ages 12 and 17 tahun 364 hari.
- **Prototype-only** none.
- **Acceptance checks**
  1. `/PetaPlatform` renders a fixed 1280 × 2100 sheet on `kertas`. On a 1024 window it scrolls horizontally and vertically, without scaling.
  2. Four column headings read "Putaran 2 · Kerangka platform", "Putaran 3 · Sekretariat", "Putaran 4 · Data jemaat", "Putaran 5 · Kolaborasi", with 16, 10, 14 and 15 entries.
  3. "Beranda" shows "Ponsel · Web". "Ponsel" opens `/BerandaJabatan` and Back returns to the map scrolled where it was. "Web" opens `/WebBerandaJabatan`.
  4. "Alur · Pengembalian" (bottom-left card) opens `/AlurPengembalian`; its back arrow then goes to `/Pengembalian`.
  5. The right card has a dashed `putus` edge and no fill. The left card has a solid `garis` edge on `permukaan`.
  6. A link test finds all 87 manifest targets as `Tautan(ke: '…')` in `peta_platform.dart`.
  7. Each "Ponsel"/"Web" link has a hit area of at least 44 × 44 without changing the drawn line height.
- **Notes**
  - The subtitle says "56 layar … 30 di antaranya juga untuk laptop", but the map lists 55 entries and 29 "Web" links. Copy the text as drawn; do not compute it. Flag it for the design owner.
  - Off-token: title 36 px with letter-spacing −0.5.
  - Inline links in dense rows: give each a 44 px hit area through `Tautan` without changing the line height (as in the Pengembalian note). Where neighbouring hit areas overlap, the nearer link wins.
  - "DL12", "DL17", "DL20", "DL26" refer to an older numbering; `04-decision-log.md` uses D/Q/P/R refs. Copy as drawn.
  - Several targets are phone boards linked from a desk context (Ibadah, Panitia, …); that is the map's purpose.

---

### AlurPengembalian — 102 · Alur · Pengembalian

- **Source** `docs/design/handoff/canvas/boards/AlurPengembalian.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 · interactive yes
- **Route** `/AlurPengembalian`, no child routes (the three steps replace the content under one fixed header) · **Widget** `AlurPengembalianScreen` in `lib/screens/lengkap/alur_pengembalian.dart`
- **Purpose** Bendahara Jemaat, journey step 3 ("25 · Pengembalian" and "Alur · Pengembalian"). A typed flow that records a refund from start to booking:
  - pick the original booked voucher (never changed);
  - enter the amount returned, the Kas/Bank and a required reason, with a live refusal;
  - book it, or save it as a Draf and book it later;
  - see its effect on Belanja/Pendapatan of November 2026 and on the combined Saldo buku.
  Shows D05/RD04: money back from a supplier is a negative Belanja in the month it is received. The RD04 mirror: money returned to a donor is a negative Pendapatan in the month it is paid out, on the same Mata Anggaran, linked to the original. A closed month is never reopened, and an open October is not used either: the refund goes to November. Also P12 (a reason must not be blank; no minimum length), D03 (Saldo buku semua Kas/Bank) and the TombolBersyarat rules.
- **Shell** Phone header with back, no tab bar, no vacancy strip.
  - Root: 390 × 844, `kertas`, `isi` (16/1.4). A column with a fixed header and a scrolling body.
  - Header (row, centred, gap 8, padding 14 12 8):
    - Back target 44 × 44: chevron 22 (path `M15 6l-6 6 6 6`, stroke 2, round), `tinta`, Semantics "Kembali ke Pengembalian".
    - Title column (flex 1): h1 "Alur · Pengembalian" (`judulLayar` 18/700). Under it, 13 `tinta2`: "Uang kembali dari pemasok, atau dikembalikan kepada donatur".
  - Body: fills the rest, scrolls vertically, padding 8 20 20, column gap 16.
- **Layout** The body shows one of three views, all stacked in the gap-16 column. Content width is 350.
  **View `pilih`** (start):
  1. 14 `tinta2` "Pilih transaksi asalnya. Transaksi asal tidak diubah."
  2. Three voucher cards (`permukaan`, 1 `garis`, radius 14, padding 12 16, column gap 6). Each card has:
     - a top row (space-between, centred, gap 16): the title (700), then the badge "Dibukukan" (LencanaStatus Dibukukan: 13/700, radius 6, padding 3 9, `tinta` field and 1.5 `tinta` edge, `permukaan` text, not shrinking);
     - a line, 13 `tinta3` (all sans, including the number): "{No. Bukti} · {date} · {amount} · {Mata Anggaran}";
     - a button, aligned start: min height 48, radius 14, 1.5 `tinta` edge, `permukaan`, 700 `tinta`, centred, padding 0 16.
     The cards:
     - "Pemeliharaan atap gedung" · "BKU-2026-0116 · 22/10/2026 · Rp5.500.000 · Belanja 5.08.02.00 Pemeliharaan gedung" · button "Catat uang kembali dari pemasok".
     - "Sewa sound system" · "BKU-2026-0143 · 11/11/2026 · Rp600.000 · Belanja 5.05.02.00 Sewa peralatan" · button "Catat uang kembali dari pemasok".
     - "Sumbangan donatur" · "BKU-2026-0121 · 28/10/2026 · Rp500.000 · Pendapatan 1.4.10.02.00 Sumbangan donatur" · button "Kembalikan kepada donatur".
  **View `isi`** (the chosen voucher x):
  1. *Original card* (`permukaan`, 1 `garis`, radius 14, padding 14 16, column gap 6):
     - Top row: x title (700) and the "Dibukukan" badge as above.
     - Three key–value rows (14, space-between, gap 16; key `tinta2`; value 600, right-aligned):
       - "No. Bukti" → No. Bukti in mono;
       - "Jumlah (Rp)" → the amount in mono, always without a sign, e.g. "Rp5.500.000";
       - "Mata Anggaran" → the MA (sans).
     - Month note, 13 `tinta3` (`aBulan`):
       - original dated October: "Oktober 2026 Belum ditutup, tetapi pengembalian tetap dicatat di bulan uangnya {diterima|dibayarkan}: November 2026.";
       - original dated November: "Transaksi asal dan pengembalian sama-sama di November 2026."
  2. *Rule note*: `lautLembut` field, radius 12, padding 12 14, 14 `tinta`. Strong `atJ`, a space, then `atT`.
     - `atJ`, pemasok: "Uang kembali dari pemasok mengurangi Belanja di bulan uangnya diterima."
     - `atJ`, donatur: "Pengembalian kepada donatur mengurangi Pendapatan di bulan uangnya dibayarkan."
     - `atT`: "Dicatat sebagai {Belanja|Pendapatan} negatif pada Mata Anggaran yang sama dan tertaut ke transaksi asal. Bulan yang sudah ditutup tidak dibuka lagi."
  3. *Amount* (a label wrapping a column, gap 6, 14 `tinta2`):
     - "Jumlah dikembalikan (Rp)".
     - Text input: full width, min height 48, padding 0 14, radius 12, 1 `garisTegas` edge, `permukaan`, hint "0". Its text is sans 14 `tinta2`, not mono: the input inherits font and colour from the wrapping label (`input{font:inherit;color:inherit}`). The board sets no `inputmode`, so keep the default text keyboard; the handler strips non-digits.
     - Helper, 13 `tinta3`: "Rp{digits with dots}", which reads "Rp0" while empty.
  4. *Kas/Bank* (column gap 6):
     - Label, 14 `tinta2`: "Masuk ke Kas/Bank" (pemasok) or "Keluar dari Kas/Bank" (donatur).
     - Chips (wrap, gap 8): "Kas", "Bank BNI ··4821". ChipPilihan: min height 44, padding 0 14, radius 999, 600/14, `aria-pressed`. Selected: `tinta` field, `permukaan` text, 1.5 `tinta` edge. Unselected: `permukaan`, `tinta` text, 1.5 `garisTegas` edge.
  5. *Date row* (14, space-between): "Tanggal transaksi" (`tinta2`) | "16/11/2026" (600). Fixed, not editable.
  6. 13 `tinta3`: "Tanggal transaksi adalah hari uangnya {diterima|dibayarkan}, bukan tanggal transaksi asal."
  7. *Alasan* (label column, gap 6, 14 `tinta2`):
     - "Alasan · wajib".
     - Textarea: 3 rows, min height 96, padding 12 14, radius 12, 1 `garisTegas` edge, `permukaan`, no resize, no hint. Its text inherits the label's 14 `tinta2` (`font: inherit; color: inherit`).
  8. *Refusal* (only when `sebabAda`), 14 px: strong `bata` "Tidak dapat dilakukan: Periksa dan bukukan.", a space, then the cause in `tinta`.
  9. *Buttons* (wrap, gap 8; each flex 1 1 150, max width 340, centred 700). At 350 wide they sit side by side at about 171 each.
     - "Periksa dan bukukan" (TombolBersyarat): min height 52, radius 14, no edge, padding 0 16. Met: `tinta` field, `permukaan` text. Unmet: `garis` field, `tinta2` text. Semantics: disabled while unmet.
     - "Simpan sebagai draf": min height 48, radius 14, 1.5 `tinta` edge, `permukaan`, `tinta`.
  10. *Back row*: text button "Kembali", min height 44, no edge, no fill, `laut` 700, centred, padding 0 16, flex 1 1 150, max width 340 (340 wide here).
  **View `hasil`**:
  1. *Result card* (`permukaan`, 1 `garis`, radius 14, padding 14 16, column gap 6):
     - Top row: title (700), "Uang kembali dari pemasok · {x title}" or "Pengembalian kepada donatur · {x title}". Then the status badge: "Dibukukan" (`tinta` shape as above) or "Draf" (LencanaStatus Draf: transparent, 1.5 dashed `putus`, `tinta2`).
     - Rows (14, as above):
       - "Jumlah (Rp)" → mono "−Rp{digits with dots}" (U+2212, always negative);
       - "Mata Anggaran" → x MA;
       - "{Masuk ke|Keluar dari} Kas/Bank" → the chosen Kas/Bank;
       - "Tanggal transaksi" → "16/11/2026";
       - "Terkait dengan" → x No. Bukti in mono.
     - Status note, 13 `tinta3`:
       - Dibukukan: "Dibukukan 16/11/2026 oleh Meiske L. · No. Bukti diberikan saat dibukukan · alasan: {trimmed reason}".
       - Draf: "Draf dicatat 16/11/2026 · alasan: {trimmed reason}".
  2. Only when Dibukukan, the *Pengaruhnya card* (same card style):
     - "Pengaruhnya" (700).
     - Row "{Belanja|Pendapatan} November 2026" → mono new figure.
     - Row "Saldo buku semua Kas/Bank" → mono new balance.
     - Then the month note `aBulan` (13 `tinta3`).
  3. Only when Draf:
     - 13 `tinta3` "Draf belum masuk saldo. Draf di bulan yang akan ditutup menghalangi tutup buku."
     - Button "Periksa dan bukukan": min height 52, radius 14, `tinta` field, `permukaan` 700, flex 1 1 150, max width 340.
  4. Button "Selesai": min height 48, radius 14, 1.5 `tinta` edge, `permukaan`, 700 `tinta`, flex 1 1 150, max width 340.
- **Components**
  - LencanaStatus (Dibukukan on cards; Draf/Dibukukan on the result).
  - ChipPilihan (Kas/Bank).
  - TombolBersyarat ("Periksa dan bukukan" in `isi`) with a Penolakan line: `bata` action, cause in `tinta`.
  - IsianAlasan ("Alasan · wajib", 3 rows here).
  - Tombol: secondary "Simpan sebagai draf" and "Selesai", text "Kembali", ink-filled "Periksa dan bukukan" on a draft.
  Repeated patterns, not components: the voucher card with an action button, the key–value card, the `lautLembut` rule note. The amount is a plain text field, not IsianJumlah.
- **Internal views and states**
  - Board state is `{ k: null }`, plus a flow object `a` that starts as `{ v: 'pilih', sel: 0, jml: '', kas: '', alasan: '', st: '' }`:
    - `v` ∈ `pilih` | `isi` | `hasil`;
    - `sel` is the voucher index 0–2;
    - `jml` holds digits only;
    - `kas` is `''`, `'Kas'` or `'Bank BNI ··4821'`;
    - `st` is `''`, `'Draf'` or `'Dibukukan'`.
  - Views: `pilih` (list); `isi` (form, with or without the refusal line); `hasil` as Dibukukan (with Pengaruhnya) or as Draf (with the note and the book button).
  - Each voucher has its own texts: pemasok for indexes 0 and 1, donatur for 2; an October month note for 0 and 2, November for 1.
  - The unused fields `pesan` and `riw` and the helpers `baris`, `hal`, `tgl`, `balik`, `catat` render nothing. Do not build them.
- **Tweaks** (Keadaan panel) `keadaan` (enum with the single option "Alur", default "Alur"). It has no visible effect. There is no `jabatanKosong` here.
- **Interactions**
  - Voucher button (`pilih`) → `v = 'isi'`, `sel = i`, and `jml`, `kas`, `alasan`, `st` cleared.
  - Amount input (`onJml`): keep digits only, remove leading zeros only when another digit follows ("007" → "7", "0" stays "0", "00" → "0"), keep at most 11 digits. Display with dot thousands separators ("200000" → "200.000"); the helper reads "Rp200.000". The amount is `n = +jml` (0 when empty).
  - Kas/Bank chip → `kas` = that name. There is no deselect.
  - Alasan textarea (`onAlasan`) → `alasan` exactly as typed.
  - Condition `a`, recomputed on every change. The first unmet one gives the cause:
    1. n ≤ 0 → "jumlah belum diisi."
    2. n > original amount → "jumlah melebihi {Belanja|Pendapatan} asalnya ({original})." That is "(Rp5.500.000)", "(Rp600.000)" or "(Rp500.000)".
    3. no Kas/Bank → "Kas/Bank belum dipilih."
    4. reason blank after trimming → "alasan belum diisi."
  - The refusal line shows only once something has been entered: `jml`, `kas` or `alasan` is non-empty (spaces count as entered). An empty form never opens with a refusal. Clearing everything hides it again.
  - "Periksa dan bukukan" (`buku`) → on press, re-check from the latest state. If all four conditions are met: `v = 'hasil'`, `st = 'Dibukukan'`. Otherwise nothing happens. The first press after the last keystroke works.
  - "Simpan sebagai draf" (`draf`) → if all four conditions are met: `v = 'hasil'`, `st = 'Draf'`. Otherwise nothing happens. The button never looks disabled and shows no reason of its own; the refusal line names only "Periksa dan bukukan". Compute it from the current state, not from the last render.
  - "Kembali" (in `isi`) and "Selesai" (in `hasil`) (`pulang`) → `v = 'pilih'`. The entered values stay in memory but are cleared on the next voucher pick.
  - "Periksa dan bukukan" on a draft (`bukuDraf`) → `st = 'Dibukukan'`, with no condition. The draft note and button disappear, the badge becomes "Dibukukan", the status note changes, and Pengaruhnya appears.
  - Figures in Pengaruhnya:
    - pemasok: Belanja November 2026 = Rp7.940.000 − n; Saldo buku = Rp38.415.000 + n (money comes in).
    - donatur: Pendapatan November 2026 = Rp7.540.000 − n; Saldo buku = Rp38.415.000 − n (money goes out).
  - Back arrow → `kembaliKe('/Pengembalian')`.
  - System Back leaves the board from any step, as on the canvas. The step is not a route.
- **Motion** none. The keyframes `isi`, `masuk`, `muncul` and `pudar` are declared but unused. Step changes, chip and button colour changes are instant. No timers.
- **Links out** Back arrow "Kembali ke Pengembalian" → `/Pengembalian` (up link via `kembaliKe`). **Inbound** Pengembalian ("Coba alurnya sampai dibukukan"), PetaPlatform ("Alur · Pengembalian").
- **Mock data** Originals (title · No. Bukti · date · amount · Mata Anggaran · kind):
  - Pemeliharaan atap gedung · BKU-2026-0116 · 22/10/2026 · Rp5.500.000 · Belanja 5.08.02.00 Pemeliharaan gedung · pemasok
  - Sewa sound system · BKU-2026-0143 · 11/11/2026 · Rp600.000 · Belanja 5.05.02.00 Sewa peralatan · pemasok
  - Sumbangan donatur · BKU-2026-0121 · 28/10/2026 · Rp500.000 · Pendapatan 1.4.10.02.00 Sumbangan donatur · donatur
  - Base figures: Belanja November 2026 Rp7.940.000; Pendapatan November 2026 Rp7.540.000; Saldo buku semua Kas/Bank Rp38.415.000 (same as Beranda).
  - Today 16/11/2026; Kas/Bank choices "Kas", "Bank BNI ··4821"; actor "Meiske L.".
- **Prototype-only** none. Keadaan panel: `keadaan` (Alur).
- **Acceptance checks**
  1. Open `/AlurPengembalian` → the header shows the back arrow, "Alur · Pengembalian" and "Uang kembali dari pemasok, atau dikembalikan kepada donatur". The body has the intro line and three cards, each with a "Dibukukan" badge. The buttons read "Catat uang kembali dari pemasok" (twice) and "Kembalikan kepada donatur".
  2. Tap the first card's button → the `isi` view shows:
     - original "BKU-2026-0116", "Rp5.500.000";
     - "Oktober 2026 Belum ditutup, tetapi pengembalian tetap dicatat di bulan uangnya diterima: November 2026.";
     - the `lautLembut` note starting "Uang kembali dari pemasok mengurangi Belanja …";
     - helper "Rp0", label "Masuk ke Kas/Bank";
     - no refusal, and "Periksa dan bukukan" on `garis` with `tinta2` text.
  3. Type "x6000000" → field "6.000.000", helper "Rp6.000.000", and the line "Tidak dapat dilakukan: Periksa dan bukukan. jumlah melebihi Belanja asalnya (Rp5.500.000)."
  4. Change the amount to "200000" → the cause becomes "Kas/Bank belum dipilih.". Tap "Kas" → "alasan belum diisi.". Type two spaces → unchanged. Type "Diskon pemasok" → the line disappears and the button turns `tinta`.
  5. Press "Periksa dan bukukan" once → the `hasil` view shows:
     - "Uang kembali dari pemasok · Pemeliharaan atap gedung" with badge "Dibukukan";
     - "−Rp200.000", "Masuk ke Kas/Bank" · "Kas", "Terkait dengan" · "BKU-2026-0116";
     - "Dibukukan 16/11/2026 oleh Meiske L. · No. Bukti diberikan saat dibukukan · alasan: Diskon pemasok";
     - Pengaruhnya "Belanja November 2026" "Rp7.740.000", "Saldo buku semua Kas/Bank" "Rp38.615.000".
  6. "Selesai" → back to the list. Tap "Kembalikan kepada donatur" → empty form with helper "Rp0" and label "Keluar dari Kas/Bank". Enter 500000, Bank BNI ··4821 and "Acara batal", then "Simpan sebagai draf" → the result shows:
     - a dashed "Draf" badge;
     - "Draf dicatat 16/11/2026 · alasan: Acara batal";
     - the draft note and a `tinta` "Periksa dan bukukan".
     Press that → badge "Dibukukan"; Pengaruhnya "Pendapatan November 2026" "Rp7.040.000", "Saldo buku semua Kas/Bank" "Rp37.915.000".
  7. With the amount empty, "Simpan sebagai draf" does nothing and no refusal appears.
  8. On "Sewa sound system" the month note reads "Transaksi asal dan pengembalian sama-sama di November 2026."; "600001" gives the cause "jumlah melebihi Belanja asalnya (Rp600.000)."
  9. Typing "0" → the field shows "0", the helper "Rp0", and the cause "jumlah belum diisi.".
  10. Back arrow → `/Pengembalian` (pop when opened from there; `go` when opened from PetaPlatform or the launcher).
- **Notes**
  - "Oktober 2026 Belum ditutup, …" has a capital "Belum" mid-sentence. Copy it verbatim.
  - The helper shows "Rp0" for an empty amount. IsianJumlah says the empty field shows a grey hint, not a value. The board wins.
  - The amount field is sans 14 `tinta2` (inherited from its label), not mono, and the No. Bukti in the list cards is sans inside the sentence. CONVENTIONS wants money and codes in mono; the board wins on what is shown. Mono is used where the board uses it: the key–value rows.
  - The result card keeps a solid `garis` edge even for a Draf; only the badge is dashed. The line language would make the card dashed. Keep the board; flag it.
  - The result says "No. Bukti diberikan saat dibukukan" but shows no new No. Bukti. Keep it.
  - The primary action is `tinta`, not `laut` (as on Pengembalian). Keep it.
  - "Simpan sebagai draf" silently refuses until all four conditions are met. Keep it; add a Semantics hint naming the first unmet cause.
  - The manifest marks `hasSideNav: true`; this phone board has no side nav (no `navVals`).
  - The phone subtitle sets font size 14 then 13; 13 wins.
  - Step views are not routes (header unchanged, as Impor's steps), so system Back leaves the flow. If reviewers want Back to return to the list, add a `PopScope` that runs `pulang` while `v ≠ 'pilih'`. That is not drawn; do not build it unless asked.

---

### WebAlurPengembalian — Web · Alur · Pengembalian

- **Source** `docs/design/handoff/canvas/boards/WebAlurPengembalian.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000, `expand: fill`) · interactive yes
- **Route** `/WebAlurPengembalian`, no child routes (steps change in place) · **Widget** `WebAlurPengembalianScreen` in `lib/screens/lengkap/web_alur_pengembalian.dart`
- **Purpose** Same as AlurPengembalian, on the laptop, for the Bendahara Jemaat (journey step 3). Reached from WebPengembalian ("Coba alurnya sampai dibukukan"). D05/RD04 and its mirror, P12, D03.
- **Shell** The **platform** web side nav. This is not the finance nav of WebPengembalian.
  - The box is the same as the finance nav: flex-basis 220 and grows 1, padding 24 × 16, `permukaan`, a right border 1 `garis`, a column with gap 20, the brand row "palakat / Jemaat Karunia", and the below-860 "Menu" top bar.
  - Items in order (each min height 44, padding 0 12, radius 10, 600, no underline; all `go`):
    1. "Beranda" → `/WebBerandaJabatan`
    2. "Keuangan" → `/WebBeranda` (**active**: `tinta` field, `permukaan` text)
    3. "Dokumen gereja" → `/WebDokumenGereja`
    4. "Pengumuman" → `/WebPengumuman`
    5. "Warta Jemaat" → `/WebWartaArsip`
    6. "Data jemaat" → `/WebDataAnggota`
    7. "Ibadah dan kegiatan" → `/Ibadah`
    8. "Panitia" → `/Panitia`
    9. "Pemberitahuan" → `/WebKotakMasuk`
    10. "Pengaturan" → `/WebPenugasan`
  - Footer (margin-top auto, padding 12 8 0, top border 1 `garis`, 13 `tinta2`): one line, "**Meiske Lumentut** · Bendahara Jemaat" (the name strong `tinta`). It does not swap; there is no `jabatanKosong`.
  - Main column: flex 999 1 560, padding 28 / clamp(16, 3 vw, 40) / 40, a column with gap 20, `isiWeb`.
- **Layout** main column, top to bottom:
  1. *Title block*:
     - breadcrumb link "Pengembalian" (14/600 `laut`, underlined);
     - h1 "Alur · Pengembalian" (`judulHalaman` 26/700, margin-top 2);
     - 14 `tinta2` "Uang kembali dari pemasok, atau dikembalikan kepada donatur".
  2. *Flow container*: max width 1120, column gap 16. It holds one view.
     - **`pilih`**: as AlurPengembalian `pilih`, with cards full width up to 1120. The card title is 15/700 (inherits `isiWeb`).
     - **`isi`**: a row (wrap, gap 20 vertical × 28 horizontal, top-aligned):
       - Left (flex 1.3 1 420, column gap 12): the original card (isi 1) and the rule note (isi 2).
       - Right (flex 1 1 340, column gap 12): amount (isi 3), Kas/Bank (isi 4), date row (isi 5), date note (isi 6), Alasan (isi 7), refusal (isi 8), buttons (isi 9), "Kembali" (isi 10).
       - At 1440 the content is 1120 wide: left about 608, right about 484. The two buttons sit side by side at about 238 each, and "Kembali" is 340 wide.
       - The columns stack once the content is narrower than 788.
       - The amount and Alasan fields inherit their label's 14 px `tinta2`, as on the phone (not the page's 15).
     - **`hasil`**: the same two-column row:
       - Left (flex 1.3 1 420, column gap 12): the result card (hasil 1).
       - Right (flex 1 1 340, column gap 12): Pengaruhnya (hasil 2) when Dibukukan; the draft note and "Periksa dan bukukan" (hasil 3) when Draf; then "Selesai" (hasil 4).
     Every element style, text and colour is as in AlurPengembalian.
- **Components** As AlurPengembalian, plus the platform web side nav.
- **Internal views and states** Same as AlurPengembalian: `{ k: null }` plus the flow object `{ v: 'pilih', sel: 0, jml: '', kas: '', alasan: '', st: '' }`, the same three views and sub-states. The menu toggle below 860 is page-local.
- **Tweaks** (Keadaan panel) `keadaan` (enum, single option "Alur", default "Alur"), no visible effect. No `jabatanKosong`.
- **Interactions** Identical to AlurPengembalian: voucher pick, `onJml` (digits only, leading zeros dropped before another digit, 11 digits max, dot separators), Kas/Bank chips, `onAlasan`, the four ordered conditions and causes, the refusal only after input starts, `buku` re-checked on press, `draf` only when all met, `pulang`, `bukuDraf`, and the same Pengaruhnya arithmetic. Breadcrumb → `kembaliKe('/WebPengembalian')`. Side nav → `go`.
- **Motion** none. The keyframes `isi`, `muncul` and `titik` are declared but unused. No timers.
- **Links out**
  - Breadcrumb "Pengembalian" → `/WebPengembalian` (up link).
  - Side nav (go): `/WebBerandaJabatan`, `/WebBeranda`, `/WebDokumenGereja`, `/WebPengumuman`, `/WebWartaArsip`, `/WebDataAnggota`, `/Ibadah`, `/Panitia`, `/WebKotakMasuk`, `/WebPenugasan`.
  - **Inbound** WebPengembalian.
- **Mock data** Same as AlurPengembalian. Footer name "Meiske Lumentut", post "Bendahara Jemaat".
- **Prototype-only** none. Keadaan panel: `keadaan` (Alur).
- **Acceptance checks**
  1. `/WebAlurPengembalian` at 1440 → a 10-item side nav with "Keuangan" active and footer "Meiske Lumentut · Bendahara Jemaat". Breadcrumb "Pengembalian", h1 "Alur · Pengembalian", three voucher cards.
  2. "Catat uang kembali dari pemasok" on "Sewa sound system" → the original card and rule note on the left, the form on the right; month note "Transaksi asal dan pengembalian sama-sama di November 2026.".
  3. Enter "700000" → the line "Tidak dapat dilakukan: Periksa dan bukukan." (bold `bata`) followed by "jumlah melebihi Belanja asalnya (Rp600.000)." (`tinta`); "Periksa dan bukukan" on `garis` with `tinta2` text.
  4. Enter "600000", choose "Bank BNI ··4821", Alasan "Batal sewa", press "Periksa dan bukukan" once → the result card on the left shows "−Rp600.000". Pengaruhnya on the right shows "Belanja November 2026" "Rp7.340.000" and "Saldo buku semua Kas/Bank" "Rp39.015.000", then "Selesai".
  5. "Simpan sebagai draf" on a valid donor form → a dashed "Draf" badge, the draft note and a `tinta` "Periksa dan bukukan" on the right. Pressing it shows Pengaruhnya.
  6. "Keuangan" → `/WebBeranda`; "Ibadah dan kegiatan" → `/Ibadah` (a phone board in its frame); breadcrumb → `/WebPengembalian`.
  7. At 860 → "Menu" top bar; the `isi` columns still sit side by side (788 ≤ 808). At 700 they stack with the form under the original card, and there is no horizontal scroll.
- **Notes**
  - It uses the platform nav (round 2) with "Keuangan" active and the full name "Meiske Lumentut". WebPengembalian, which links here, uses the finance nav with "Meiske L.". Keep each board's nav.
  - "Ibadah dan kegiatan" and "Panitia" link to phone boards (Q26: those posts are phone only). Follow the board.
  - All AlurPengembalian notes apply (the "Rp0" helper, a sans amount field, a solid result card for Draf, the `tinta` primary, the silent "Simpan sebagai draf").
