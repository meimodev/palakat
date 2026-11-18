# Screens 11: LihatDokumen, WebLihatDokumen, A4F01, A4F02a, A4F02b, A4F02c, A4F14, A4Sementara, A4Terbatas, Keputusan, Tanggal, WebTanggal

These twelve boards are the Bendahara Jemaat's supporting screens and printed pages. **LihatDokumen** (phone) and **WebLihatDokumen** (laptop) open the two files of the supporting document of BKU-2026-0147 inside the app (D07: nothing is downloaded), page and zoom them, and let the Bendahara verify them; they are reached from the Dokumen detail ("Lihat file"), from Kamera after an upload ("Lihat file dan verifikasi"), and on the laptop from WebDokumen, WebUnggah and the "Verifikasi" action of WebTransaksi and TabTransaksi (plus the map sheets PetaLayar and Cakupan), and they lead back to Dokumen/WebDokumen. The seven **A4** boards are the printed pages of the Oktober 2026 report pack: the official F01 (A4F01), the three landscape pages of F02 Buku Kas Umum (A4F02a/b/c, with the reversal shown as a negative figure, D12, and the closing note of D13), page 2 of the F14 attachments (A4F14), the provisional F01 (A4Sementara) and the TERBATAS copy for peruntukan Diakonia (A4Terbatas). They are static pages with no controls; A4F01 is opened by every "Unduh PDF" of the report screens, A4Terbatas by Terbatas/WebTerbatas, A4F02b/c by the decisions sheet, and A4F02a, A4F14, A4Sementara only from the launcher. **Keputusan** is the decisions sheet of the canvas page "Peta dan keputusan": the 35 numbered design decisions D01–D35, each row a link to the board that draws it. **Tanggal** (phone, from the Catat form in Main) and **WebTanggal** (laptop, from WebCatat and TabCatat) are the date picker for a transaction: a month calendar that refuses closed September and future dates, shows which report month the date falls in, and keeps Tanggal dokumen, Dicatat pada and Dibukukan pada as separate values; "Pakai …" returns to the form. One rule recurs: a **back-style link** (phone back arrow, web breadcrumb, and the "return to the form" actions named below) runs `kembaliKe('/X')`: pop when the route directly below is `/X` or a child of `/X`, otherwise `go('/X')`. All other links follow CONVENTIONS: `go` for side-nav changes, `push` for drill-ins. All boards share the design's "today", 16/11/2026, and its actor Meiske L., Bendahara.

---

### LihatDokumen — 40 · Lihat file dokumen pendukung
- **Source** `docs/design/handoff/canvas/boards/LihatDokumen.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 (frame radius 36) · interactive yes
- **Route** `/LihatDokumen`, no child routes (paging, zoom and verification change the view in place) · **Widget** `LihatDokumenScreen` in `lib/screens/lengkap/lihat_dokumen.dart`
- **Purpose** Bendahara Jemaat, journey step 2 ("19 · Dokumen pendukung"): open the uploaded files of a transaction's supporting document inside the app and verify them. Shows D07 (a document file opens inside the app, it is not downloaded to the device), the PanelDokumen rule "Uploaded is not verified; month close accepts only Terverifikasi or Dikecualikan" (status "Diunggah, belum diverifikasi" in `bata` until Verifikasi, then "Memenuhi syarat tutup buku November 2026."), D02 (a missing or unverified document blocks month close, not Bukukan), the glossary word "Terverifikasi" for a document, and R04/PitaJabatanKosong through `jabatanKosong`.
- **Shell** Phone, no tab bar. Full-screen dark viewer with its own header and back arrow. Board root: column 390×844, `kertas`, `tinta` text, sans 16/1.4. When `jabatanKosong` is on, the one-line PitaJabatanKosong strip sits on top (flex none, pushes the rest down). Below it, one layer filling the rest: column, `tinta` field, `permukaan` text (CONVENTIONS: #FFFFFF as text on `tinta` is `permukaan`).
- **Layout**
  0. (only `jabatanKosong`) Strip, `role=status`: full width, `tinta` field, `permukaan` text, padding 10/24/8, 13 px line-height 1.3, centred: "**Menjalankan jabatan kosong** · Bendahara Jemaat".
  1. Header: row, centre, gap 8, padding 14 top, 12 sides, 4 bottom. Back target 44×44, chevron icon (path `M15 6l-6 6 6 6`, 22 px, stroke 2, round caps, `permukaan`), semantics "Kembali ke Dokumen pendukung". Title (h1, flex 1): the file name in mono 16/600, `permukaan`: "nota-16-11.jpg" on page 1, "tanda-terima-16-11.jpg" on page 2.
  2. Viewer area: flex 1, scrolls both ways when content is larger, content centred both ways, padding 24. Inside, the photographed receipt ("paper"): width 230, no flex, field #FBFAF6 (illustration literal, allowed by CONVENTIONS), `tinta` text, padding 18/16, mono 13 line-height 1.55, shadow `0 12 32 rgba(0,0,0,.4)` (blur 32, offset y 12, black 40 %). Scaled by `zoom` around its centre (see Motion). Paper content top to bottom:
     - shop name centred 600; address centred 400;
     - dashed rule 1 px `tinta3` (#5E6A66), margin 8 above and below;
     - item rows: row, space-between, gap 8: left name, right amount (empty string when none);
     - dashed rule as above;
     - total row, space-between, 600: "TOTAL" | total;
     - date (margin-top 8); footer line.
     Contents per page in Mock data.
  3. Controls row: row, centred, gap 8, padding 10 top, 16 sides, 14 bottom. Four square buttons 44×44, radius 12, 1.5 `tinta3` border, transparent field, `permukaan` glyph 20/600 centred:
     - "‹" (semantics "Halaman sebelumnya"), then page label (min width 70, centred, 14 px, `permukaan`) "1 dari 2" / "2 dari 2", then "›" (semantics "Halaman berikutnya");
     - a 16 px spacer;
     - "−" (U+2212, semantics "Perkecil"), then zoom label (min width 52, centred, mono 14) "75%" … "200%", then "+" (semantics "Perbesar").
  4. Bottom panel (looks like LembarBawah but is fixed, not draggable): `permukaan` field, `tinta` text, top corners 22 (radius token `lembar`), padding 16 top, 20 sides, 20 bottom, column gap 8, full width:
     a. Row, space-between, gap 16, baseline: "BKU-2026-0147" (`kode` mono 13, `tinta2`) | "−Rp150.000" (`jumlah` mono 16/500, `tinta`).
     b. "Fotokopi warta jemaat" 16/600.
     c. Block: "Dokumen pendukung · 2 file" (14, `tinta2`); status 18/700: "Diunggah, belum diverifikasi" in `bata`, or "Terverifikasi (oleh Meiske L.)" in `tinta`; "Diunggah oleh Meiske L., 16/11/2026 10.41" (13, `tinta3`).
     d. Before verification: primary button "Verifikasi": full width, min height 52, radius 14, `laut` field, `diLaut` text 700, centred, padding 0 20, no border.
     e. After verification (replaces d): status line `role=status`, 14 `tinta2`: "Memenuhi syarat tutup buku November 2026."
     f. Text link "Tolak, lepaskan, atau catat pengecualian": min height 44, full width, centred, 700, `laut`, underlined (browser default: the `<a>` has no `text-decoration: none`; build as `TautanTeks`), `lautTua` on hover and press.
- **Components** Tombol (primary "Verifikasi"), PitaJabatanKosong (phone strip), PanelDokumen rules (status words and colours, no own widget here), LembarBawah look for the fixed bottom panel (radius 22, not a modal). Not a component: the dark file viewer (header, paper, paging/zoom controls), shared with WebLihatDokumen; build it once as a screen-local widget used by both boards.
- **Internal views and states** Initial state `{ hal: 0, zoom: 1, st: 'unggah' }`. Page 1 (`hal 0`, nota) / page 2 (`hal 1`, tanda terima). Zoom 0.75, 1, 1.25, 1.5, 1.75, 2. Status `unggah` (Verifikasi button) / `verif` (status line). `st` belongs to the whole document, not to one page: after verification both pages show "Terverifikasi". No sheets, toasts, dialogs or empty states.
- **Tweaks** `jabatanKosong` (boolean, default false) · Keadaan panel (global switch). On: strip 0 appears; the uploader line reads "Diunggah oleh Yanti Sumual, Operator, 16/11/2026 10.41"; text replacement is enabled on this board (`jk && true`), so after verification the status reads "Terverifikasi (oleh Yanti Sumual, Operator)" (the string has no date other than 16/11/2026, so it is swapped). Off: as drawn.
- **Interactions**
  - "‹" (`prev`): `hal = 0`, `zoom = 1`. Disabled on page 1.
  - "›" (`next`): `hal = 1`, `zoom = 1`. Disabled on page 2.
  - "+" (`besar`): `zoom = min(2, zoom + 0.25)`. Disabled when `zoom >= 2`.
  - "−" (`kecil`): `zoom = max(0.75, zoom − 0.25)`. Disabled when `zoom <= 0.75`.
  - Zoom label = `round(zoom × 100) + '%'`; page label = `(hal + 1) + ' dari 2'`.
  - "Verifikasi" (`verif`): `st = 'verif'` at once (no timer, no confirmation, no undo): status text and colour change, the button is replaced by the status line.
  - Paging always resets the zoom to 100 %. Verification state survives paging.
  - Disabled buttons do nothing and expose disabled semantics.
- **Motion**
  - Paper scale: CSS transition `transform .25s cubic-bezier(.2,.8,.2,1)` → `AnimatedScale` (or `TweenAnimationBuilder`) 250 ms, curve `PalakatMotion.keluar`, alignment centre, on every zoom change, including the reset to 1 when paging (the paper content swaps instantly, the scale animates back). Not a named keyframe; motion.md "transition" entry with the keluar curve.
  - Status line e: `muncul` 300 ms (opacity 0→1, y +8→0), CSS default easing `ease` (`Curves.ease`, not `keluar`), when it appears after Verifikasi.
  - Reduce motion: both instant.
  - Declared but unused: `masuk`, `pudar`, `isi`.
- **Links out** Back arrow (semantics "Kembali ke Dokumen pendukung") → `kembaliKe('/Dokumen')` (pops to `/Dokumen/rinci` when opened from there). "Tolak, lepaskan, atau catat pengecualian" → `kembaliKe('/Dokumen')`. **Inbound** Dokumen ("Lihat file"), Kamera ("Lihat file dan verifikasi"), Keputusan (row 7, D07), and the map sheets PetaLayar and Cakupan (links built in their logic classes, navigation.md 3.3).
- **Mock data** Transaction BKU-2026-0147 · −Rp150.000 · "Fotokopi warta jemaat" · supporting document with 2 files, uploaded by Meiske L. on 16/11/2026 10.41, status "Diunggah, belum diverifikasi" (same record as row 1 of Bukti). Page 1 file "nota-16-11.jpg": "TOKO SINAR" / "Jl. Pierre Tendean 7" / rows "Fotokopi warta" | "" and "300 lbr x 500" | "150.000" / "TOTAL" | "Rp150.000" / "16/11/2026" / "Terima kasih". Page 2 file "tanda-terima-16-11.jpg": "TANDA TERIMA" / "Jemaat Karunia" / rows "Diterima dari" | "" and "Bendahara" | "150.000" / "TOTAL" | "Rp150.000" / "16/11/2026" / "Penerima: Toko Sinar". Verifier "Meiske L." (or "Yanti Sumual, Operator" with `jabatanKosong`). Month: November 2026.
- **Prototype-only** none on the board. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. Open `/LihatDokumen` → dark `tinta` screen; title "nota-16-11.jpg" in mono; paper shows "TOKO SINAR" and "300 lbr x 500 … 150.000"; labels "1 dari 2" and "100%"; "‹" disabled.
  2. Tap "+" four times → labels 125%, 150%, 175%, 200%; each step scales the paper over 250 ms; at 200% "+" is disabled.
  3. Tap "−" until "75%" → "−" disabled; paper smaller than at 100%.
  4. At 150%, tap "›" → title "tanda-terima-16-11.jpg", paper "TANDA TERIMA … Penerima: Toko Sinar", label "2 dari 2", zoom back to "100%" (animated); "›" disabled, "‹" enabled.
  5. Panel shows "Diunggah, belum diverifikasi" in `bata` and "Diunggah oleh Meiske L., 16/11/2026 10.41"; tap "Verifikasi" → status "Terverifikasi (oleh Meiske L.)" in `tinta`, the button is gone, "Memenuhi syarat tutup buku November 2026." rises in over 300 ms.
  6. After 5, tap "‹" → page 1, status still "Terverifikasi (oleh Meiske L.)".
  7. Keadaan panel `jabatanKosong` on → strip "Menjalankan jabatan kosong · Bendahara Jemaat" above the header; uploader "Diunggah oleh Yanti Sumual, Operator, 16/11/2026 10.41"; after Verifikasi "Terverifikasi (oleh Yanti Sumual, Operator)".
  8. Open from `/Dokumen/rinci` ("Lihat file"), tap the back arrow → back on `/Dokumen/rinci`; same for "Tolak, lepaskan, atau catat pengecualian".
- **Notes** The board draws no disabled look for the viewer buttons (the inline `#FFFFFF` colour overrides the browser's disabled style), so a disabled "‹" looks like an enabled one; keep the look and expose `enabled: false` in semantics. CSS scaling of a centred element at 200 % pushes half the paper past the left edge, where scrolling cannot reach; reproduce with a centred `Transform.scale` clipped to the viewer area (do not add pinch-zoom or `InteractiveViewer`). The 250 ms transition duration is not a token duration; copy it. "300 lbr x 500" uses the letter x, not ×; keep verbatim. Dashed rules on the paper are `tinta3`, not the draft line `putus`: they are part of the photographed receipt, not line language. Manifest flags `hasSideNav: true` for this phone board; that is a false positive from the shared `rv0` helper, there is no side nav.

### WebLihatDokumen — Web · Lihat file dokumen pendukung
- **Source** `docs/design/handoff/canvas/boards/WebLihatDokumen.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebLihatDokumen`, no child routes · **Widget** `WebLihatDokumenScreen` in `lib/screens/lengkap/web_lihat_dokumen.dart`
- **Purpose** Bendahara Jemaat on the laptop, journey step 2: the same in-app viewer and verification as LihatDokumen, with the viewer and the transaction panel side by side and the D07 sentence written under the title ("File dibuka di dalam aplikasi. Tidak ada yang diunduh ke perangkat.").
- **Shell** Web side nav (same as WebBukti in `06-bukti.md`; repeated here). Build it as `NavSamping(item: navKeuangan, aktif: 1, …)` with the shared list from `lib/shell/nav_item.dart` (navigation.md 1.3, components.md 4.3); the link test counts the seven nav targets through that list name:
  - Nav column: flex basis 220, padding 24/16, `permukaan`, 1 px `garis` right border, column gap 20.
  - Brand: Palakat mark 26×26 (rect 2,2,20,20 rx 6, 2 px dashed 3 3 `laut` stroke, plus the filled right half `M12 2h4a6 6 0 0 1 6 6v8a6 6 0 0 1-6 6h-4z` in `laut`) and "palakat" 18/700 line-height 1.1 over "Jemaat Karunia" 13 `tinta3`; padding 0 8, gap 10.
  - Items, exactly: Beranda → `/WebBeranda`, **Transaksi** → `/WebTransaksi` (active), Uang Muka dan Titipan → `/WebKewajiban`, Rekonsiliasi → `/WebRekonsiliasi`, Bulan dan tutup buku → `/WebTutupBuku`, Laporan → `/WebPaketLaporan`, Pengaturan → `/WebPengaturan`. Each min height 44, padding 0 12, radius 10, 600, no underline. Active: `tinta` field, `permukaan` text; others transparent, `tinta` text. All `go`.
  - Footer: margin-top auto, padding 12/8/0, 1 px `garis` top rule, 13 `tinta2`: "**Meiske L.** · Bendahara" / "Wewenang Bendahara aktif" (name `tinta`). With `jabatanKosong`: "**Yanti Sumual** · Operator" / "Menjalankan jabatan kosong Bendahara Jemaat".
  - At 860 px and below: the nav becomes a top bar (row, wrap, padding 8/16, no right border, 1 px `garis` bottom border) with a toggle at the right (min height 44, padding 0 16, radius 14, 1.5 `tinta` border, `permukaan`, 14/700, "Menu"; open: `tinta` field, `permukaan` text, "Tutup menu"); items and footer show full width below it when open.
  - Main column: flex 999 1 560, padding 28 top, clamp(16, 3vw, 40) sides, 40 bottom, column gap 20; `isiWeb` 15/1.45.
- **Layout**
  0. (only `jabatanKosong`) Web PitaJabatanKosong, first in main, `role=status`: `tinta` field, radius 14, padding 12/16, 14 px: "**Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15.**" then " Setiap tindakan dicatat sebagai dijalankan oleh Operator Yanti Sumual." in `diTinta2`.
  1. Title block: breadcrumb link "Dokumen pendukung" (14/600, `laut`, underlined `TautanTeks`, `lautTua` on hover); h1 "Lihat file" (`judulHalaman` 26/700, margin-top 2); "File dibuka di dalam aplikasi. Tidak ada yang diunduh ke perangkat." (14, `tinta2`).
  2. Row, wrap, gap 24, top-aligned:
     a. Viewer card: flex 999 1 480, min width 0, height 640, `tinta` field, `permukaan` text, radius 16 (`kartuBesar`), clips. File name line: padding 12 top, 16 sides, 0 bottom, mono 14 ("nota-16-11.jpg" / "tanda-terima-16-11.jpg"). Viewer area and paper exactly as LihatDokumen region 2. Controls row exactly as LihatDokumen region 3.
     b. Transaction panel (aside): flex 1 1 340, min width 0, `permukaan`, 1 px `garis` (dibukukan line), radius 14, padding 20, column gap 10. Contents as LihatDokumen region 4 a–f, except that the body size is 15 (uraian 15/600, amount mono 15/500) and "Tolak, lepaskan, atau catat pengecualian" leads to WebDokumen.
  At 1440 wide the viewer is about 776 wide and the panel 340; when the main content is narrower than 844 (windows below about 1130, and always at 860) the panel wraps below the viewer, both full width.
- **Components** Tombol (primary "Verifikasi"), PitaJabatanKosong (web banner), PanelDokumen rules, shared dark viewer (see LihatDokumen). Shared: web side nav.
- **Internal views and states** Same as LihatDokumen: initial `{ hal: 0, zoom: 1, st: 'unggah' }`; pages 1/2; zoom 0.75–2; status `unggah`/`verif`. No sheets or toasts.
- **Tweaks** `jabatanKosong` (boolean, default false) · Keadaan panel (global switch). On: banner 0, nav footer switches to Yanti Sumual, uploader line "Diunggah oleh Yanti Sumual, Operator, 16/11/2026 10.41"; text replacement enabled (`jk && true`), so the verified status reads "Terverifikasi (oleh Yanti Sumual, Operator)".
- **Interactions** Same handlers as LihatDokumen (`prev`, `next`, `besar`, `kecil`, `verif`), same limits and labels. Side-nav items and the two links as below.
- **Motion** Same as LihatDokumen: paper scale 250 ms keluar curve; status line `muncul` 300 ms with CSS `ease`. Declared but unused: `isi`, `titik`.
- **Links out** Breadcrumb "Dokumen pendukung" → `kembaliKe('/WebDokumen')`. "Tolak, lepaskan, atau catat pengecualian" → `kembaliKe('/WebDokumen')`. Side nav (go): Beranda `/WebBeranda`, Transaksi `/WebTransaksi`, Uang Muka dan Titipan `/WebKewajiban`, Rekonsiliasi `/WebRekonsiliasi`, Bulan dan tutup buku `/WebTutupBuku`, Laporan `/WebPaketLaporan`, Pengaturan `/WebPengaturan`. **Inbound** WebDokumen ("Lihat file"), WebUnggah ("Lihat file" on an attached file), and, from links built in logic classes (navigation.md 3.3): WebTransaksi and TabTransaksi (the "Verifikasi" action of the transaction panel), PetaLayar.
- **Mock data** Same as LihatDokumen (BKU-2026-0147, −Rp150.000, "Fotokopi warta jemaat", two files, Meiske L. 16/11/2026 10.41, both receipts). Banner date 16/11/2026 08.15.
- **Prototype-only** none. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. `/WebLihatDokumen` at 1440 → side nav "Transaksi" filled `tinta`; breadcrumb "Dokumen pendukung"; h1 "Lihat file"; viewer (dark, 640 high) left of the white panel on one row.
  2. Viewer shows "nota-16-11.jpg", "1 dari 2", "100%"; "+" ×4 → "200%" and "+" disabled; "›" → "tanda-terima-16-11.jpg", "2 dari 2", "100%".
  3. Panel: "BKU-2026-0147" mono `tinta2`, "−Rp150.000", "Diunggah, belum diverifikasi" in `bata`; click "Verifikasi" → "Terverifikasi (oleh Meiske L.)" in `tinta` and "Memenuhi syarat tutup buku November 2026." fades up.
  4. At 860 wide: nav is a top bar with "Menu"; the panel sits below the viewer; no horizontal page scroll.
  5. `jabatanKosong` on → banner "Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15." on top; footer "Yanti Sumual · Operator"; uploader "Yanti Sumual, Operator".
  6. Click breadcrumb after arriving from `/WebDokumen` → pops back to `/WebDokumen`; browser Back from `/WebLihatDokumen` does the same.
  7. Side nav "Laporan" → `/WebPaketLaporan` (go).
- **Notes** Same disabled-look and scaling notes as LihatDokumen. Radius 16 on the viewer card is `kartuBesar`. The active nav item is Transaksi although the breadcrumb is "Dokumen pendukung"; keep as drawn.

### A4F01 — A4 · F01 Laporan Perbendaharaan Bulanan
- **Source** `docs/design/handoff/canvas/boards/A4F01.dc.html` · page A4 · Laporan resmi (`a4`) · form A4 portrait 794×1123 · interactive no
- **Route** `/A4F01`, no child routes · **Widget** `A4F01Screen` in `lib/screens/a4/a4_f01.dart`
- **Purpose** Bendahara Jemaat, journey step 5 ("15 · Laporan", the A4 pages): the printed official monthly treasury report for Oktober 2026, frozen at month close. Shows D14 (no signature lines; only one line recording the approval of the report format, plus a sentence that wet signatures are added on paper by the person), C04 (final line names "Uang Muka diberikan", "Pengembalian sisa uang muka"), the reconciliation conclusion per Kas/Bank with cash count and bank statement printed separately, and the official-report identity (ID SNP-2026-10-01, frozen time, Mata Anggaran version).
- **Shell** A4 page: fixed 794×1123 white page (`permukaan`) centred on `kertas`, scaled down to fit narrower windows, scrolls; no app chrome, no back control (system/browser Back and the Keadaan panel). The paper always renders with `PalakatWarna.terang`, also under Gelap (components.md 4.7: a printed page does not follow the dark theme); only the `kertas` backdrop follows the theme.
- **Layout** Shared A4 frame (also used by A4F02a/b/c, A4F14, A4Sementara, A4Terbatas; landscape pages are 1123×794):
  - Page: padding 48 top, 52 sides, 0 bottom; column gap 14; clips overflow; sans 13 line-height 1.4, `tinta`.
  - Header: row, space-between, bottom-aligned, gap 24; 2 px `tinta` bottom border; padding-bottom 10. Left: form line 13/600, letter spacing 0.4, `tinta2`; title 20/700, letter spacing 0.2, `tinta`; subtitle 13. Right (no flex, right-aligned, mono 13, `tinta2`): three lines.
  - Footer: absolutely placed left 52, right 52, bottom 34; row, space-between, gap 24; 1 px `tinta` top border; padding-top 8; 13 `tinta2`. Left: "Palakat · format bawaan aplikasi, bukan formulir resmi GMIM · Jemaat Karunia". Right (no flex, mono): page label.
  - Report table (grid rows, column gap 10): header row padding 6 0, 1.5 `tinta` bottom border, 700; body rows padding 4 0, 1 px `garisTegas` bottom border; emphasised rows (opening, carry-over, totals) padding 4 0, 1.5 `tinta` bottom border, 700. Amount cells mono, right-aligned; code cells mono. Cells clip to their column (`min-width: 0`) and wrap.
  - Inline print tag (on F02 and F14): inline-block, 1 px `tinta` border, radius 4, padding 0 5, 600, no wrap; sits after the uraian text (Text.rich + WidgetSpan; wraps to the next line when it does not fit).
  On A4F01:
  1. Header: "F01 · LAPORAN RESMI" / "LAPORAN PERBENDAHARAAN BULANAN" / "Jemaat Karunia · Periode laporan 1–31 Oktober 2026 · seluruh Jemaat: semua peruntukan dan semua Kas/Bank". Right: "ID SNP-2026-10-01" / "Dibekukan 16/11/2026 11.05" / "Versi Mata Anggaran 2026.1".
  2. Summary table, 15 px, columns `1fr 190`: header "Baris" | "Oktober 2026" (right). Rows: **"Saldo awal Kas/Bank" Rp36.250.000** (emphasised); "Pendapatan ekonomi" Rp14.820.000; "Belanja ekonomi" −Rp11.455.000; "Dana Transit masuk" + " · titipan masuk" (`tinta2`) Rp2.400.000; "Dana Transit keluar" + " · titipan disalurkan" (`tinta2`) −Rp2.400.000; "Uang Muka diberikan" −Rp1.500.000; "Pengembalian sisa uang muka" Rp350.000; **"Saldo akhir Kas/Bank" Rp38.465.000** (emphasised).
  3. Reconciliation block, 15 px: title 700, margin 6 top, 2 bottom: "Posisi dan kesimpulan rekonsiliasi per 31 Oktober 2026". Table columns `1fr 150 190 110`: header "Kas/Bank" | "Saldo buku" (right) | "Pembanding" | "Selisih" (right). Rows: "Kas" | Rp8.750.000 | "Hitung kas Rp8.750.000" | Rp0; "Bank BNI ··4821" | Rp24.600.000 | "Rekening koran Rp24.100.000 + setoran dalam perjalanan Rp500.000" | Rp0; "Bank SulutGo ··1107" | Rp5.115.000 | "Rekening koran Rp5.115.000" | Rp0; emphasised "Jumlah" | Rp38.465.000 | (empty) | Rp0. "Pembanding" cells are sans. Under it (margin-top 6): "Ketiga Kas/Bank sudah dipastikan. Hasil hitung kas dan saldo rekening koran dicetak terpisah dan tidak dijumlahkan."
  4. Notes block, 15 px, column gap 6: "Catatan" 700; "Hanya transaksi yang sudah dibukukan. Pencatatan dimulai 15 September 2026; laporan ini tidak memuat kegiatan sebelum tanggal itu."; "Nama baris uang muka mengikuti format laporan yang disetujui 03/10/2026."; "Disiapkan oleh Meiske Lumentut, Bendahara. Persetujuan format laporan sudah dicatat: Pdt. Lidya Rondonuwu, Ketua BPMJ, 03/10/2026."; "Halaman ini tidak memuat tanda tangan. Tanda tangan basah, bila diminta, dibubuhkan di atas kertas oleh orangnya sendiri."
  5. Footer right: "F01 · halaman 1 dari 1".
- **Components** none of the 31 as widgets. GarisStatus "ditutup" meaning (official, frozen) is carried by the solid `tinta` rules. Repeated patterns: the shared A4 frame (header, footer, report table, print tag) — the frame is the `HalamanA4` scaffold in `lib/shell/` (components.md 4.7: `ukuran`, `kode`, `judul`, `subjudul`, `kanan`, `kakiKanan`, `isi`), plus a small screen-local table helper reused by all seven A4 boards.
- **Internal views and states** One static view. No state object.
- **Tweaks** none.
- **Interactions** none.
- **Motion** none.
- **Links out** none. **Inbound** Keputusan (row 14, D14), Laporan, TutupBuku, WebLaporan, WebPaketLaporan, WebTutupBuku (their "Unduh PDF" / "Halaman A4" links), and the map sheets PetaLayar and Cakupan ("Halaman A4" rows built in their logic classes, navigation.md 3.3).
- **Mock data** Jemaat Karunia; period 1–31 Oktober 2026; ID SNP-2026-10-01; frozen 16/11/2026 11.05; Mata Anggaran version 2026.1. Summary figures as in Layout 2 (36.250.000 + 14.820.000 − 11.455.000 + 2.400.000 − 2.400.000 − 1.500.000 + 350.000 = 38.465.000). Kas/Bank at 31/10/2026: Kas Rp8.750.000, Bank BNI ··4821 Rp24.600.000 (statement Rp24.100.000 + deposit in transit Rp500.000), Bank SulutGo ··1107 Rp5.115.000; total Rp38.465.000, all differences Rp0. People: Meiske Lumentut (Bendahara), Pdt. Lidya Rondonuwu (Ketua BPMJ); format approved 03/10/2026; recording started 15 September 2026.
- **Prototype-only** none. Keadaan panel: no tweaks.
- **Acceptance checks**
  1. `/A4F01` at 1440×1000 → a white 794-wide page centred on `kertas`; header "LAPORAN PERBENDAHARAAN BULANAN" with "ID SNP-2026-10-01" in mono at the right.
  2. Summary table: first and last rows bold with 1.5 `tinta` rules ("Rp36.250.000", "Rp38.465.000"); "Belanja ekonomi" shows "−Rp11.455.000" with U+2212.
  3. "Dana Transit masuk · titipan masuk": the suffix is `tinta2`.
  4. Reconciliation row "Bank BNI ··4821" shows "Rekening koran Rp24.100.000 + setoran dalam perjalanan Rp500.000" wrapped inside the 190 column; "Jumlah" row bold.
  5. No signature line anywhere; the last note reads "Halaman ini tidak memuat tanda tangan. …".
  6. Footer at 34 px above the page bottom: left text and "F01 · halaman 1 dari 1" in mono.
  7. At 390 wide the whole page is scaled to fit the width and scrolls vertically; no overflow error.
- **Notes** Title 20 px and table 15 px are off-token; copy. Radius 4 on print tags is an off-token small mark (CONVENTIONS). The page is paper: CONVENTIONS maps #FFFFFF background to `permukaan`, which turns dark under Gelap; `HalamanA4` therefore always renders the page with `PalakatWarna.terang` (components.md 4.7, decided, not optional), so printed pages stay black on white in both themes (only the `kertas` backdrop follows the theme). This "Gelap rule" applies to all seven A4 boards. Rupiah values come from `rp()`, but the "Pembanding" sentences are plain strings.

### A4F02a — A4 · F02 Buku Kas Umum, halaman 1 dari 3
- **Source** `docs/design/handoff/canvas/boards/A4F02a.dc.html` · page A4 · Laporan resmi (`a4`) · form A4 landscape 1123×794 · interactive no
- **Route** `/A4F02a`, no child routes · **Widget** `A4F02aScreen` in `lib/screens/a4/a4_f02a.dart`
- **Purpose** Bendahara Jemaat, journey step 5: page 1 of the printed general cash book for Oktober 2026. Shows C01 (on print, Kas/Bank is its own column), a split transaction printed once with all its No. MA (the receipt BKU-2026-0098, also with two Kas/Bank lines, and the payment BKU-2026-0101), transfers between Kas/Bank printed in both columns with an unchanged running balance (Setoran ke bank), the "Dibalik oleh" tag on the reversed original (BKU-2026-0105), and the carry-over row to page 2.
- **Shell** A4 page, landscape 1123×794 (shared frame, see A4F01). No chrome.
- **Layout**
  1. Header: "F02 · LAPORAN RESMI" / "BUKU KAS UMUM" / "Jemaat Karunia · Periode laporan 1–31 Oktober 2026 · semua Kas/Bank". Right: "ID SNP-2026-10-01" / "Dibekukan 16/11/2026 11.05" / "Versi Mata Anggaran 2026.1".
  2. Cash-book table at 13 px (page default, not 15). Columns `74 112 96 1fr 122 102 102 116`, gap 10 (the uraian column is 225 wide on this page). Header: "Tanggal" | "No. Bukti" | "No. MA" | "Uraian" | "Kas/Bank" | "Penerimaan" (right) | "Pengeluaran" (right) | "Saldo semua Kas/Bank" (right). No. Bukti and No. MA cells mono; amounts mono right; empty amount cells blank. Multi-value cells (two No. MA, two Kas/Bank) are two lines. First row emphasised: uraian "Saldo awal Kas/Bank", saldo Rp36.250.000. Eleven body rows (Mock data). Last row emphasised: uraian "Dipindahkan ke halaman 2" | Rp14.850.000 | Rp10.720.000 | Rp40.380.000.
  3. Footer right: "F02 · halaman 1 dari 3".
- **Components** none as widgets; shared A4 frame and print tag (LencanaStatus "Dibalik" meaning, print form).
- **Internal views and states** One static view.
- **Tweaks** none.
- **Interactions** none.
- **Motion** none.
- **Links out** none. **Inbound** none (reached from the launcher).
- **Mock data** Rows (Tanggal · No. Bukti · No. MA · Uraian [tag] · Kas/Bank · Penerimaan · Pengeluaran · Saldo):
  1. 04/10/2026 · BKU-2026-0098 · 1.3.53.07.00 / 1.3.55.01.00 · Persembahan Ibadah Minggu dan Diakonia · Kas / Bank BNI ··4821 · Rp4.150.000 · — · Rp40.400.000
  2. 04/10/2026 · BKU-2026-0099 · 2.1.01.02.00 · "Titipan untuk: Sinode · Sentralisasi" · Kas · Rp600.000 · — · Rp41.000.000
  3. 05/10/2026 · BKU-2026-0100 · 5.07.01.00 · Honorarium pelayan · Bank BNI ··4821 · — · Rp1.820.000 · Rp39.180.000
  4. 06/10/2026 · BKU-2026-0101 · 5.01.02.00 / 5.02.01.00 · Toko Sinar: listrik dan alat tulis, satu pembayaran · Bank BNI ··4821 · — · Rp1.250.000 · Rp37.930.000
  5. 06/10/2026 · BKU-2026-0102 · "—" · Setoran ke bank: ke Bank BNI ··4821 · Kas ke Bank BNI · Rp5.000.000 · Rp5.000.000 · Rp37.930.000
  6. 07/10/2026 · BKU-2026-0103 · "—" · "Uang Muka diberikan · Pnt. Jefry Wowor" · Kas · — · Rp400.000 · Rp37.530.000
  7. 08/10/2026 · BKU-2026-0104 · "—" · Setoran ke bank: ke Bank SulutGo ··1107 · Kas ke Bank SulutGo · Rp1.500.000 · Rp1.500.000 · Rp37.530.000
  8. 09/10/2026 · BKU-2026-0105 · 5.02.01.00 · Konsumsi rapat majelis [Dibalik oleh BKU-2026-0109] · Kas · — · Rp750.000 · Rp36.780.000
  9. 10/10/2026 · BKU-2026-0106 · "—" · "Pengembalian sisa uang muka · Panitia HUT Jemaat" · Kas · Rp350.000 · — · Rp37.130.000
  10. 11/10/2026 · BKU-2026-0107 · 1.3.53.07.00 · Persembahan Ibadah Minggu · Kas · Rp2.650.000 · — · Rp39.780.000
  11. 11/10/2026 · BKU-2026-0108 · 2.1.01.02.00 · "Titipan untuk: Sinode · Sentralisasi" · Kas · Rp600.000 · — · Rp40.380.000
  In this list "—" between amounts means an empty cell; a quoted "—" is printed. An uraian that itself contains " · " is quoted (print it without the quotes); the separator " · " between fields is not printed. Sums: receipts Rp14.850.000, payments Rp10.720.000.
- **Prototype-only** none. Keadaan panel: no tweaks.
- **Acceptance checks**
  1. `/A4F02a` → landscape 1123×794 white page; title "BUKU KAS UMUM"; eight column headers, the last "Saldo semua Kas/Bank" right-aligned.
  2. Row BKU-2026-0098 shows two No. MA lines and two Kas/Bank lines ("Kas", "Bank BNI ··4821").
  3. Row BKU-2026-0102 shows Rp5.000.000 in both Penerimaan and Pengeluaran and saldo Rp37.930.000 unchanged.
  4. Row BKU-2026-0105 shows the bordered tag "Dibalik oleh BKU-2026-0109" (radius 4, 600) after "Konsumsi rapat majelis".
  5. Last row bold "Dipindahkan ke halaman 2" with Rp14.850.000 · Rp10.720.000 · Rp40.380.000; footer "F02 · halaman 1 dari 3".
  6. At 1280×800 the page is shown at full size and scrolls vertically if needed; at 390 wide it is scaled to fit.
- **Notes** Table text is 13 px (page default); do not enlarge to 15 as on F01. Codes inside uraian text and tags ("Dibalik oleh BKU-2026-0109") are sans on the board while CONVENTIONS asks for mono codes; keep the board (sans inside running text). Rows are in date order, not No. Bukti order (0117 comes before 0112 on page 2); keep. Same Gelap rule as A4F01.

### A4F02b — A4 · F02 Buku Kas Umum, halaman 2 dari 3
- **Source** `docs/design/handoff/canvas/boards/A4F02b.dc.html` · page A4 · Laporan resmi (`a4`) · form A4 landscape 1123×794 · interactive no
- **Route** `/A4F02b`, no child routes · **Widget** `A4F02bScreen` in `lib/screens/a4/a4_f02b.dart`
- **Purpose** Bendahara Jemaat, journey step 5: page 2 of F02. Shows D12: the reversal BKU-2026-0109 is printed as a negative figure (−Rp750.000) in the same column (Pengeluaran) as its original BKU-2026-0105, followed by the correcting transaction BKU-2026-0110 tagged "Koreksi dari BKU-2026-0105".
- **Shell** A4 page, landscape (shared frame, see A4F01).
- **Layout** Same as A4F02a except:
  1. First emphasised row: uraian "Pindahan dari halaman 1" | Rp14.850.000 | Rp10.720.000 | Rp40.380.000.
  2. Eleven body rows (Mock data); BKU-2026-0109 carries the tag "Pembalikan", BKU-2026-0110 the tag "Koreksi dari BKU-2026-0105".
  3. Last emphasised row: "Dipindahkan ke halaman 3" | Rp23.070.000 | Rp17.320.000 | Rp42.000.000.
  4. Footer right "F02 · halaman 2 dari 3".
- **Components** As A4F02a (print tags "Pembalikan", "Koreksi dari …").
- **Internal views and states** One static view.
- **Tweaks** none.
- **Interactions** none.
- **Motion** none.
- **Links out** none. **Inbound** Keputusan (row 12, D12).
- **Mock data** Rows (same field order and legend as A4F02a):
  1. 12/10/2026 · BKU-2026-0109 · 5.02.01.00 · Pembalikan BKU-2026-0105 [Pembalikan] · Kas · — · −Rp750.000 · Rp41.130.000
  2. 12/10/2026 · BKU-2026-0110 · 5.04.01.00 · Konsumsi rapat majelis [Koreksi dari BKU-2026-0105] · Kas · — · Rp750.000 · Rp40.380.000
  3. 18/10/2026 · BKU-2026-0114 · 1.3.53.07.00 · Persembahan Ibadah Minggu · Kas · Rp2.400.000 · — · Rp42.780.000
  4. 18/10/2026 · BKU-2026-0115 · 1.4.10.02.00 · Sumbangan donatur · Bank BNI ··4821 · Rp700.000 · — · Rp43.480.000
  5. 18/10/2026 · BKU-2026-0117 · 2.1.01.02.00 · "Titipan untuk: Sinode · Sentralisasi" · Kas · Rp600.000 · — · Rp44.080.000
  6. 20/10/2026 · BKU-2026-0112 · "—" · "Uang Muka diberikan · Sdri. Natalia Rumengan" · Kas · — · Rp800.000 · Rp43.280.000
  7. 20/10/2026 · BKU-2026-0113 · 1.3.53.09.00 · Persembahan syukur · Kas · Rp1.220.000 · — · Rp44.500.000
  8. 22/10/2026 · BKU-2026-0116 · 5.08.02.00 · Pemeliharaan atap gedung · Bank BNI ··4821 · — · Rp5.500.000 · Rp39.000.000
  9. 25/10/2026 · BKU-2026-0119 · "—" · "Uang Muka diberikan · Ibu Selvie Kalalo" · Kas · — · Rp300.000 · Rp38.700.000
  10. 25/10/2026 · BKU-2026-0123 · 1.3.53.07.00 · Persembahan Ibadah Minggu · Kas · Rp2.700.000 · — · Rp41.400.000
  11. 25/10/2026 · BKU-2026-0125 · 2.1.01.02.00 · "Titipan untuk: Sinode · Sentralisasi" · Kas · Rp600.000 · — · Rp42.000.000
  Page sums: receipts +Rp8.220.000, payments +Rp6.600.000 (the −750.000 counts negative).
- **Prototype-only** none. Keadaan panel: no tweaks.
- **Acceptance checks**
  1. `/A4F02b` → first row bold "Pindahan dari halaman 1" with Rp14.850.000 · Rp10.720.000 · Rp40.380.000.
  2. Row BKU-2026-0109: Pengeluaran "−Rp750.000" (U+2212) and saldo Rp41.130.000; tag "Pembalikan".
  3. Row BKU-2026-0110: tag "Koreksi dari BKU-2026-0105", No. MA 5.04.01.00, Pengeluaran Rp750.000.
  4. Row BKU-2026-0112 shows No. MA "—" in mono.
  5. Last row "Dipindahkan ke halaman 3" Rp23.070.000 · Rp17.320.000 · Rp42.000.000; footer "F02 · halaman 2 dari 3".
  6. From `/Keputusan` row 12 → `/A4F02b`; Back returns to the sheet.
- **Notes** The negative figure must not be clipped or moved to Penerimaan (D12, IsianJumlah rule "never clipped to zero"). Same notes as A4F02a.

### A4F02c — A4 · F02 Buku Kas Umum, halaman 3 dari 3
- **Source** `docs/design/handoff/canvas/boards/A4F02c.dc.html` · page A4 · Laporan resmi (`a4`) · form A4 landscape 1123×794 · interactive no
- **Route** `/A4F02c`, no child routes · **Widget** `A4F02cScreen` in `lib/screens/a4/a4_f02c.dart`
- **Purpose** Bendahara Jemaat, journey step 5: last page of F02 with the closing totals, closing balance per Kas/Bank and the explanatory note. Shows D13 (advance settlements are not in F02; numbers missing from the sequence are listed in F12 Daftar Bukti Kas), the "31 baris" count, split payments printed once, reversals as negatives, and a Kas/Bank-to-Kas/Bank transfer (BKU-2026-0127).
- **Shell** A4 page, landscape (shared frame, see A4F01).
- **Layout** Same as A4F02a except:
  1. First emphasised row: "Pindahan dari halaman 2" | Rp23.070.000 | Rp17.320.000 | Rp42.000.000.
  2. Nine body rows (Mock data).
  3. Last emphasised row: "Jumlah dan saldo akhir Kas/Bank" | Rp29.260.000 | Rp27.045.000 | Rp38.465.000.
  4. Closing block (13 px): row, gap 32, top-aligned. Left (no flex): "Saldo akhir per Kas/Bank" (700, margin-bottom 2), then three rows (space-between, gap 28): "Kas" | Rp8.750.000; "Bank BNI ··4821" | Rp24.600.000; "Bank SulutGo ··1107" | Rp5.115.000 (amounts mono). Right (`tinta2`): "31 baris. Pembayaran yang dibagi ke beberapa Mata Anggaran dicetak satu kali dengan semua nomornya. Pembalikan dicetak sebagai angka negatif di kolom yang sama dengan transaksi asalnya. Nomor di antara BKU-2026-0098 dan BKU-2026-0133 yang tidak tampil di sini bukan arus kas/bank Oktober 2026; semuanya terdaftar di F12 Daftar Bukti Kas."
  5. Footer right "F02 · halaman 3 dari 3".
- **Components** As A4F02a.
- **Internal views and states** One static view.
- **Tweaks** none.
- **Interactions** none.
- **Motion** none.
- **Links out** none. **Inbound** Keputusan (row 13, D13).
- **Mock data** Rows (same field order and legend as A4F02a):
  1. 26/10/2026 · BKU-2026-0120 · 5.07.01.00 · Honorarium pelayan · Bank BNI ··4821 · — · Rp1.820.000 · Rp40.180.000
  2. 26/10/2026 · BKU-2026-0130 · "—" · Setoran ke bank: ke Bank BNI ··4821 · Kas ke Bank BNI · Rp2.690.000 · Rp2.690.000 · Rp40.180.000
  3. 27/10/2026 · BKU-2026-0118 · 1.3.53.09.00 · Persembahan syukur · Bank BNI ··4821 · Rp500.000 · — · Rp40.680.000
  4. 27/10/2026 · BKU-2026-0122 · 4.03.04.00 · Diakonia sakit · Kas · — · Rp300.000 · Rp40.380.000
  5. 28/10/2026 · BKU-2026-0121 · 1.4.10.02.00 · Sumbangan donatur · Bank BNI ··4821 · Rp500.000 · — · Rp40.880.000
  6. 30/10/2026 · BKU-2026-0127 · "—" · Pindah antar Kas/Bank: Bank BNI ke Kas · Bank BNI ke Kas · Rp2.000.000 · Rp2.000.000 · Rp40.880.000
  7. 30/10/2026 · BKU-2026-0128 · 2.1.01.02.00 · "Penyaluran · Titipan untuk: Sinode" · Bank BNI ··4821 · — · Rp2.400.000 · Rp38.480.000
  8. 31/10/2026 · BKU-2026-0131 · "—" · Setoran ke bank: ke Bank BNI ··4821 · Kas ke Bank BNI · Rp500.000 · Rp500.000 · Rp38.480.000
  9. 31/10/2026 · BKU-2026-0133 · 5.03.03.00 · Biaya administrasi bank · Bank BNI ··4821 · — · Rp15.000 · Rp38.465.000
  Totals for the month: receipts Rp29.260.000, payments Rp27.045.000, closing Rp38.465.000 (= F01). 31 rows over the three pages (11 + 11 + 9).
- **Prototype-only** none. Keadaan panel: no tweaks.
- **Acceptance checks**
  1. `/A4F02c` → first row "Pindahan dari halaman 2"; nine body rows; last row "Jumlah dan saldo akhir Kas/Bank" Rp29.260.000 · Rp27.045.000 · Rp38.465.000.
  2. Row BKU-2026-0127 shows Kas/Bank "Bank BNI ke Kas" and Rp2.000.000 in both amount columns.
  3. Closing block: three Kas/Bank lines with mono amounts summing to Rp38.465.000; the note starts "31 baris." in `tinta2`.
  4. The closing block and table fit above the footer (no clipping of the note) at 1123×794.
  5. Footer "F02 · halaman 3 dari 3".
- **Notes** Page height is tight: the page header, 12 table rows (column header, "Pindahan dari halaman 2", 9 body rows, the total row; several body rows wrap to two lines in the 225-wide uraian column) and the closing block must fit between the 48 top padding and the footer (its rule sits about 61 px above the page bottom); build the rows at exactly padding 4 0 and 13/1.4 so nothing is clipped by the page's overflow clip. Same notes as A4F02a.

### A4F14 — A4 · F14 Lampiran, halaman 2 dari 3
- **Source** `docs/design/handoff/canvas/boards/A4F14.dc.html` · page A4 · Laporan resmi (`a4`) · form A4 portrait 794×1123 · interactive no
- **Route** `/A4F14`, no child routes · **Widget** `A4F14Screen` in `lib/screens/a4/a4_f14.dart`
- **Purpose** Bendahara Jemaat, journey step 5: page 2 of F14 "Lampiran Laporan Bulanan". Shows C04 (the title, attachment names, and an empty attachment printed as "Nihil", never a blank page), the document exception printed with reason and who granted it (PanelDokumen: an exception always names reason and grantor), status printed as at month close, and the reversal/correction chain of BKU-2026-0105.
- **Shell** A4 page, portrait (shared frame, see A4F01).
- **Layout**
  1. Header: "F14 · LAPORAN RESMI" / "LAMPIRAN LAPORAN BULANAN" / "Jemaat Karunia · Periode laporan 1–31 Oktober 2026". Right: "ID SNP-2026-10-01" / "Dibekukan 16/11/2026 11.05" / "Versi Mata Anggaran 2026.1".
  2. Attachment 4, 15 px: title "4 · Penggantian Biaya" (700, margin-bottom 2); box: 1 px `tinta` border, no radius, padding 10/14, 600: "Nihil".
  3. Attachment 5, 15 px: title "5 · Pengecualian Dokumen Pendukung" (700, margin 6 top, 2 bottom). Table columns `120 1fr 120`: header "No. Bukti" | "Uraian, alasan dan pemberi pengecualian" | "Jumlah" (right). One body row: "BKU-2026-0116" (mono) | "Pemeliharaan atap gedung" + second line in `tinta2` "Alasan: kuitansi menyusul · Pemberi pengecualian: Ketua BPMJ · dicatat 22/10/2026" | "−Rp5.500.000" (mono, right). Under it (margin-top 6, `tinta2`): "Status dicetak seperti saat tutup buku. Dokumen susulan tidak mengubah halaman ini."
  4. Attachment 6, 15 px: title "6 · Pembalikan dan Koreksi" (700, margin 6/0/2). Table columns `120 100 1fr 120`: header "No. Bukti" | "Tanggal" | "Uraian" | "Pengeluaran" (right). Three body rows (no total row): "BKU-2026-0105" | "09/10/2026" | "Konsumsi rapat majelis · No. MA 5.02.01.00" + print tag "Dibalik" | "Rp750.000"; "BKU-2026-0109" | "12/10/2026" | "Pembalikan BKU-2026-0105 · alasan: Mata Anggaran keliru" | "−Rp750.000"; "BKU-2026-0110" | "12/10/2026" | "Transaksi koreksi · Konsumsi rapat majelis · No. MA 5.04.01.00" | "Rp750.000".
  5. Attachment 7, 15 px: title "7 · Saldo Awal Pencatatan" (700, margin 6/0/2); box "Nihil" as in 2; under it (margin-top 6, `tinta2`): "Lampiran tanpa isi dicetak sebagai “Nihil”, bukan halaman kosong."
  6. Footer right "F14 · halaman 2 dari 3".
- **Components** none as widgets; shared A4 frame; print tag "Dibalik".
- **Internal views and states** One static view.
- **Tweaks** none.
- **Interactions** none.
- **Motion** none.
- **Links out** none. **Inbound** none (launcher only).
- **Mock data** Exception: BKU-2026-0116, Pemeliharaan atap gedung, −Rp5.500.000, reason "kuitansi menyusul", granted by Ketua BPMJ, recorded 22/10/2026. Reversal chain: BKU-2026-0105 (09/10/2026, 5.02.01.00, Rp750.000, Dibalik), BKU-2026-0109 (12/10/2026, −Rp750.000, alasan "Mata Anggaran keliru"), BKU-2026-0110 (12/10/2026, 5.04.01.00, Rp750.000). Attachments 4 and 7: Nihil.
- **Prototype-only** none. Keadaan panel: no tweaks.
- **Acceptance checks**
  1. `/A4F14` → title "LAMPIRAN LAPORAN BULANAN"; sections numbered 4, 5, 6, 7 in that order.
  2. Sections 4 and 7 show a bordered box "Nihil" (1 px `tinta`, square corners, 600).
  3. Section 5 row: second line "Alasan: kuitansi menyusul · Pemberi pengecualian: Ketua BPMJ · dicatat 22/10/2026" in `tinta2`; amount "−Rp5.500.000".
  4. Section 6: three rows; first carries the tag "Dibalik"; second amount "−Rp750.000"; no total row.
  5. Footer "F14 · halaman 2 dari 3".
- **Notes** Pages 1 and 3 of F14 are not drawn and must not be invented (R03 says attachment 2 on page 1 reads "Nihil"). The exception amount is printed negative (−Rp5.500.000) while F02 prints the same payment as Rp5.500.000 in Pengeluaran; keep each page's figure. "Nihil" boxes have no radius; keep. Annex 6 tags BKU-2026-0105 only "Dibalik", without "Dibalik oleh No. Bukti …" (rule S02); build as drawn, logged in rules-checklist.md 4.2 (its reversal is the next row). Same Gelap rule as A4F01.

### A4Sementara — A4 · F01 Laporan sementara
- **Source** `docs/design/handoff/canvas/boards/A4Sementara.dc.html` · page A4 · Laporan sementara (`a4s`) · form A4 portrait 794×1123 · interactive no
- **Route** `/A4Sementara`, no child routes · **Widget** `A4SementaraScreen` in `lib/screens/a4s/a4_sementara.dart`
- **Purpose** Bendahara Jemaat, journey step 5: the printed provisional F01 for Oktober 2026 before month close. Shows the PitaLaporan provisional rule (dashed box, "Bukan laporan resmi. Angka masih dapat berubah"), GarisStatus draf (dashed = not final), no official ID ("Belum punya ID laporan resmi"), the reconciliation conclusion not yet official, and no "Disiapkan oleh"/signature lines.
- **Shell** A4 page, portrait (shared frame, see A4F01).
- **Layout** Same as A4F01 except:
  1. Header left line "F01 · LAPORAN SEMENTARA · BUKAN LAPORAN RESMI"; title and subtitle as A4F01. Right: "Belum punya ID laporan resmi" / "Dibuat 14/11/2026 09.20" / "Versi Mata Anggaran 2026.1".
  2. New box after the header: 1.5 dashed `tinta3` border, radius 8, padding 10/14, 15 px: "**Laporan sementara.** Bukan laporan resmi. Angka masih dapat berubah sampai Oktober 2026 ditutup; file resmi dibuat setelah tutup buku."
  3. Summary table: identical rows and figures to A4F01 region 2.
  4. Reconciliation block: identical table to A4F01 region 3; the sentence under it is "Kesimpulan rekonsiliasi baru menjadi resmi setelah tutup buku."
  5. Notes block: "Catatan" and only the first two lines of A4F01 ("Hanya transaksi yang sudah dibukukan. …" and "Nama baris uang muka mengikuti format laporan yang disetujui 03/10/2026."). No "Disiapkan oleh" line, no signature line.
  6. Footer right "F01 · halaman 1 dari 1".
- **Components** PitaLaporan (provisional, print form: the dashed box). Shared A4 frame.
- **Internal views and states** One static view.
- **Tweaks** none.
- **Interactions** none.
- **Motion** none.
- **Links out** none. **Inbound** none (launcher only).
- **Mock data** Same figures as A4F01 (Saldo awal Rp36.250.000 … Saldo akhir Rp38.465.000; Kas Rp8.750.000, BNI Rp24.600.000, SulutGo Rp5.115.000). Created 14/11/2026 09.20; no report ID.
- **Prototype-only** none. Keadaan panel: no tweaks.
- **Acceptance checks**
  1. `/A4Sementara` → header line "F01 · LAPORAN SEMENTARA · BUKAN LAPORAN RESMI"; right meta "Belum punya ID laporan resmi" and "Dibuat 14/11/2026 09.20" in mono.
  2. Dashed box (1.5 dashed, radius 8) directly under the header starting with bold "Laporan sementara."
  3. Summary and reconciliation figures equal A4F01's.
  4. Sentence under the reconciliation table: "Kesimpulan rekonsiliasi baru menjadi resmi setelah tutup buku."
  5. "Catatan" has exactly two lines; the words "Disiapkan oleh" and "tanda tangan" do not appear.
- **Notes** The dashed box uses `tinta3` (#5E6A66), not the draft line colour `putus`; copy the board (it maps to a token). Radius 8 is an off-token small mark. Same Gelap rule as A4F01.

### A4Terbatas — A4 · Salinan TERBATAS, peruntukan Diakonia
- **Source** `docs/design/handoff/canvas/boards/A4Terbatas.dc.html` · page A4 · Salinan TERBATAS (`a4t`) · form A4 portrait 794×1123 · interactive no
- **Route** `/A4Terbatas`, no child routes · **Widget** `A4TerbatasScreen` in `lib/screens/a4t/a4_terbatas.dart`
- **Purpose** A person with restricted access (Akses terbatas, peruntukan Diakonia), opened from Terbatas/WebTerbatas ("Unduh PDF"): the printed TERBATAS copy with F05 (income) and F07 (spending) for Diakonia only. Shows D26 (restricted access still sees Mata Anggaran), D27 (a TERBATAS copy is made for the restricted access and contains only its forms; F05 and F07 drawn here), PitaLaporan "A restricted copy is titled TERBATAS", and what is left out of the copy.
- **Shell** A4 page, portrait (shared frame, see A4F01).
- **Layout**
  1. Header: "F05 dan F07 · LAPORAN RESMI · TERBATAS" / "REALISASI MENURUT MATA ANGGARAN" / "Jemaat Karunia · Periode laporan 1–31 Oktober 2026". Right: "ID SNP-2026-10-01" / "Dibekukan 16/11/2026 11.05" / "Versi Mata Anggaran 2026.1".
  2. TERBATAS box: 2 px solid `tinta` border, no radius, padding 10/14, 15 px: "**TERBATAS · Akses terbatas: Peruntukan Diakonia.** File ini dibuat khusus untuk bagian peruntukan Diakonia. Ini bukan versi tersembunyi dari file seluruh Jemaat."
  3. F05, 15 px: title "F05 · Pendapatan peruntukan Diakonia" (700, margin-bottom 2). Table `150 1fr 170`: header "No. MA" | "Nama Mata Anggaran" | "Oktober 2026" (right). Row "1.3.55.01.00" (mono) | "Persembahan Diakonia" | "Rp950.000". Emphasised total: (empty) | "Jumlah Pendapatan peruntukan Diakonia" | "Rp950.000".
  4. F07, 15 px: title "F07 · Belanja peruntukan Diakonia" (700, margin 6/0/2). Same columns. Rows "4.03.03.00" | "Diakonia duka" | "Rp0"; "4.03.04.00" | "Diakonia sakit" | "Rp300.000". Emphasised total: "Jumlah Belanja peruntukan Diakonia" | "Rp300.000".
  5. Balance table, 15 px, columns `1fr 170`: header "Saldo peruntukan Diakonia" | "Oktober 2026" (right). Row "Saldo awal" | "Rp3.050.000"; emphasised "Saldo akhir" | "Rp3.700.000".
  6. Left-out block, 15 px, column gap 6: "Yang tidak ada di salinan ini" (700); "Baris peruntukan lain tidak dicetak, juga tidak sebagai Rp0."; "Jumlah seluruh transaksi, uraian, pelaku, file dokumen pendukung dan celah nomor tidak disertakan."; "Baris bernilai Rp0 di atas adalah baris yang boleh dipakai peruntukan Diakonia dan memang tidak ada transaksinya."
  7. Footer right "F05 dan F07 · TERBATAS · halaman 1 dari 1".
- **Components** PitaLaporan (restricted copy, print form: the 2 px box titled TERBATAS). Shared A4 frame.
- **Internal views and states** One static view.
- **Tweaks** none.
- **Interactions** none.
- **Motion** none.
- **Links out** none. **Inbound** Terbatas ("Unduh PDF"), WebTerbatas ("Unduh PDF").
- **Mock data** Peruntukan Diakonia, Oktober 2026: income 1.3.55.01.00 Persembahan Diakonia Rp950.000; spending 4.03.03.00 Diakonia duka Rp0, 4.03.04.00 Diakonia sakit Rp300.000; opening Rp3.050.000, closing Rp3.700.000 (3.050.000 + 950.000 − 300.000). Same report ID and frozen time as A4F01.
- **Prototype-only** none. Keadaan panel: no tweaks.
- **Acceptance checks**
  1. `/A4Terbatas` → header line "F05 dan F07 · LAPORAN RESMI · TERBATAS"; title "REALISASI MENURUT MATA ANGGARAN".
  2. The 2 px `tinta` box starts with bold "TERBATAS · Akses terbatas: Peruntukan Diakonia."
  3. F07 shows "Diakonia duka" with "Rp0" (a row allowed for Diakonia with no transactions), and total "Rp300.000".
  4. "Saldo akhir" row bold "Rp3.700.000".
  5. No other peruntukan, no uraian, no names of actors appear on the page.
  6. From `/Terbatas`, "Unduh PDF" → `/A4Terbatas`; Back returns to `/Terbatas`.
- **Notes** The page prints official ID SNP-2026-10-01, the same as the full F01; keep. Same Gelap rule as A4F01.

### Keputusan — Keputusan desain
- **Source** `docs/design/handoff/canvas/boards/Keputusan.dc.html` · page Peta dan keputusan (`sistem`) · form Sheet 1280×1320 · interactive yes (links only)
- **Route** `/Keputusan`, no child routes · **Widget** `KeputusanScreen` in `lib/screens/sistem/keputusan.dart`
- **Purpose** Reviewers of the design (not an app screen): the canvas sheet listing the 35 numbered design decisions D01–D35 (decided by the product owner 17/11/2026, confirmed 18/11/2026), grouped by topic, each row opening the board that draws it; plus the notes of 18/11/2026 (the intro paragraph summarises Q25–Q32, Q28 consent text, P01, P02, P05, P06, P07, P09, P10 and the donor mirror of RD04; the dashed box names RD04 and EC07, C04, C05, C03 and what is still open).
- **Shell** Sheet: fixed-width page (1280 wide, at least 1320 high), `kertas` background, scrolls both ways, no app chrome. Reached from the launcher (canvas page "Peta dan keputusan").
- **Layout**
  - Root: padding 56, column gap 32, sans 15/1.45 (`isiWeb`), `tinta`.
  1. Header: row, space-between, bottom-aligned, gap 40.
     - Left: title "Keputusan desain" 36/700, line-height 1.1, letter spacing −0.5; paragraph (15, `tinta2`, margin-top 4), verbatim: "35 pilihan yang semula belum dikonfirmasi. Tiap baris membuka layar tempat pilihan itu digambar. Fondasi, token dan komponen kini ada di sistem desain Palakat. Brief versi 2 (18/11/2026) menambah putaran 2–5; layarnya ada di halaman Putaran 2 sampai 5 ; pertanyaan 25–32 diputuskan 18/11/2026 (lihat Peta layar · Putaran 2–5). Naskah izin data pribadi memakai naskah bawaan yang belum ditinjau penasihat hukum. Diputuskan juga 18/11/2026: anggota dan pelayan lain masuk dengan kode ke nomor ponsel; akun dihubungkan ke Data jemaat lewat nama dan tanggal lahir yang diverifikasi Penatua Kolom; pemberitahuan dorong di layar kunci hanya menyebut modul dan jenis pekerjaan; pemberi persetujuan ditetapkan menurut jabatan, sekali per gereja; pengembalian kepada donatur mengurangi Pendapatan di bulan uangnya dibayarkan; Kategori BIPRA: Anak sampai sebelum 12 tahun, Remaja 12 tahun sampai 17 tahun 364 hari, Pemuda 18 tahun ke atas dan belum pernah menikah, Bapa dan Ibu sudah menikah (yang pernah menikah tetap Bapa atau Ibu; yang belum pernah menikah tetap Pemuda). Email cadangan tidak wajib; tanpa email, Operator memulihkan akun setelah Penatua Kolom memastikan identitas."
     - Right (no flex): badge "Diputuskan pemilik produk · 17/11/2026": `tinta` field, `permukaan` text 14/700, radius 8, padding 8/14 (GarisStatus "ditutup": final).
  2. Grid of three equal columns (each about 365 wide), gap 36, top-aligned. Each column is a column of groups, gap 28. Group: heading 16/700 (`judulBagian`), padding-bottom 8, 1.5 `tinta` bottom rule; then rows. Row: link, row layout, gap 10, padding 9 0, 1 px `garis` bottom rule, 14 px `tinta`, no underline, no hover colour; number cell fixed width 24, mono 13 `tinta2`; text wraps.
     - Column 1: "Harian" rows 1–7; "Akhir bulan" rows 8–14.
     - Column 2: "Uang Muka, Titipan, Penggantian biaya" rows 15–20; "Pengaturan dan akses" rows 21–28.
     - Column 3: "Tampilan dan struktur" rows 29–35 (row 32 is plain text, not a link, with a trailing " Lihat sistem desain Palakat, tema Gelap." in `tinta3`); then (still in column 3, after a 28 gap) a box: 1.5 dashed `putus` border (draf line), radius 14, padding 14/16, column gap 6, 14 px: title 700 "Dipastikan 18/11/2026, dan yang masih terbuka" and five lines in `tinta2` (Mock data).
- **Components** none of the 31 as widgets. Uses GarisStatus lines (dashed box = draf, "still open"; `tinta` badge = ditutup). Repeated pattern: numbered decision row (number + sentence) as a full-width link.
- **Internal views and states** One static view. No state.
- **Tweaks** none.
- **Interactions** none besides the links.
- **Motion** none. Declared but unused: `masuk`, `pudar`, `muncul`, `isi`.
- **Links out** Every linked row → push to its board, by row number and visible text (the number is part of the target):
  1 "Kas/Bank, peruntukan dan Lingkup tidak pernah terisi lebih dulu." → `/Main` · 2 "Dokumen pendukung yang belum ada menghalangi tutup buku, bukan Bukukan." → `/Dokumen` · 3 "Beranda dibuka dengan satu Saldo buku gabungan semua Kas/Bank." → `/Main` · 4 "Alih peruntukan wajib menyebut dasar keputusan." → `/AlihPeruntukan` · 5 "Pengembalian mengurangi Belanja di bulan uangnya diterima (RD04, 18/11/2026)." → `/Pengembalian` · 6 "File yang dilepas membuat dokumen pendukung kembali “Wajib, belum ada”." → `/Dokumen` · 7 "File dokumen dibuka di dalam aplikasi, tidak diunduh ke perangkat." → `/LihatDokumen` · 8 "Tutup buku dikonfirmasi dengan menahan tombol sampai penuh." → `/TutupBuku` · 9 "Hitung kas diisi per pecahan uang." → `/HitungKas` · 10 "Hasil hitung kas boleh disimpan walau ada selisih." → `/HitungKas` · 11 "Menyelesaikan Kejadian tidak dengan sendirinya membuka hambatan bulan berikutnya." → `/Kejadian` · 12 "Pembalikan dicetak sebagai angka negatif di kolom yang sama dengan transaksi asalnya." → `/A4F02b` · 13 "Pertanggungjawaban uang muka tidak masuk F02; ia terdaftar di F12." → `/A4F02c` · 14 "Halaman cetak tanpa tanda tangan; hanya satu baris catatan persetujuan format." → `/A4F01` · 15 "Daftarnya bernama “Uang yang masih berjalan”." → `/Kewajiban` · 16 "Belanja melebihi uang muka ditolak dan dicatat sebagai Penggantian biaya." → `/Kewajiban` · 17 "Klaim harus dicek sebelum dapat dibayar." → `/Kewajiban` · 18 "Uang Muka tidak meminta Mata Anggaran sampai dipertanggungjawabkan." → `/KasusBaru` · 19 "Titipan tidak meminta peruntukan; hanya Mata Anggaran yang boleh untuk Titipan." → `/KasusBaru` · 20 "Ketiganya wajib punya dokumen pendukung; menghalangi tutup buku, bukan pembukuan." → `/KasusBaru` · 21 "Serah terima dimulai oleh Bendahara yang sedang aktif." → `/Bendahara` · 22 "Bendahara mengisi “Boleh untuk” per baris Mata Anggaran sebelum menerbitkan." → `/MataAnggaran` · 23 "Perubahan pengaturan berlaku mulai bulan berikutnya." → `/UbahPengaturan` · 24 "Perubahan seri No. Bukti berlaku mulai Januari 2027." → `/UbahPengaturan` · 25 "Semua jabatan masuk dengan kode yang dikirim ke nomor ponsel (WhatsApp atau SMS); email hanya cadangan untuk pemulihan akun (diputuskan 18/11/2026)." → `/Masuk` · 26 "Akses terbatas tetap melihat Mata Anggaran dan Lingkup." → `/Terbatas` · 27 "Salinan TERBATAS berisi F02, F03, F05, F07 dan F12." → `/WebPaketLaporan` · 28 "Pemberitahuan hanya di dalam aplikasi." → `/Pemberitahuan` · 29 "Ponsel: lima tab bawah dengan Catat di tengah. Web: bilah samping." → `/PetaLayar` · 30 "Laporan dapat dibaca di ponsel sebagai kartu bertumpuk." → `/Laporan` · 31 "Usulan AI: tepi titik-titik warna Laut dan huruf miring." → `/BantuanAI` · 32 "Di tema gelap, bulan yang sudah ditutup adalah blok paling terang." (no link) · 33 "Jumlah pada jawaban pencarian dihitung dari catatan yang ditampilkan." → `/Cari` · 34 "Hasil impor memakai kata Ditampung, Lolos pengecekan, Sudah diimpor, Tidak diimpor." → `/Impor` · 35 "Tanpa sambungan, isian tetap di layar; tidak ada yang disimpan di perangkat untuk dikirim nanti." → `/Sambungan`.
  26 distinct targets (matches the manifest). **Inbound** none (launcher only).
- **Mock data** Row n is decision Dn of `04-decision-log.md`. Box lines (verbatim, `tinta2`): "RD04 dan EC07 diputuskan 18/11/2026: pengembalian mengurangi Belanja di bulan diterima; file yang ditolak saat diunggah tidak disimpan." / "Nama baris dan judul laporan dipastikan seperti yang digambar." / "Label “Alih peruntukan” dan semua kata di glossary dipastikan. Tema gelap dipastikan." / "Baris Mata Anggaran di semua contoh masih karangan, belum dari sumber Jemaat." / "Cara Belanja dari pertanggungjawaban uang muka tampil di F01, F07 dan F09. Dua pertanggungjawaban di layar Uang Muka (Rp700.000) bertanggal November 2026, jadi laporan Oktober mencetak Rp0 dan lampiran 2 Nihil."
- **Prototype-only** The whole sheet is a design artefact, not an app screen; keep it as drawn (it is a board of its own). Keadaan panel: no tweaks.
- **Acceptance checks**
  1. `/Keputusan` → title "Keputusan desain" 36/700; badge "Diputuskan pemilik produk · 17/11/2026" in a `tinta` field at the top right.
  2. Three columns with headings "Harian", "Akhir bulan" | "Uang Muka, Titipan, Penggantian biaya", "Pengaturan dan akses" | "Tampilan dan struktur"; numbers 1–35 in mono `tinta2`.
  3. Click row 7 → `/LihatDokumen` opens (push); Back returns to `/Keputusan` at the same scroll position.
  4. Click row 12 → `/A4F02b`; row 14 → `/A4F01`; row 27 → `/WebPaketLaporan`.
  5. Row 32 is not focusable or clickable; its suffix "Lihat sistem desain Palakat, tema Gelap." is `tinta3`.
  6. The dashed box at the bottom of column 3 has five `tinta2` lines, the last ending "lampiran 2 Nihil."
  7. Each linked row is at least 44 px tall; keyboard Tab moves through rows 1–35 (skipping 32) with a 2 px `laut` focus outline.
  8. In a 1024-wide window the sheet keeps its 1280 width and scrolls horizontally.
- **Notes** Row height on the board is about 38 px (padding 9 + 14×1.45); `Tautan` makes each row a 44 px target, which can make the sheet taller than 1320: let the sheet grow in height rather than clip. Title 36 px and badge radius 8 are off-token; copy. The intro paragraph contains "Putaran 2 sampai 5 ;" with a space before the semicolon; copy is verbatim, so keep it (likely a removed link; flag to design). The badge says 17/11/2026 while the text says decisions were confirmed 18/11/2026; keep both.

### Tanggal — 41 · Tanggal transaksi dan tanggal dokumen
- **Source** `docs/design/handoff/canvas/boards/Tanggal.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 (frame radius 36) · interactive yes
- **Route** `/Tanggal`, no child routes (month changes and the document-date input are in place) · **Widget** `TanggalScreen` in `lib/screens/lengkap/tanggal.dart`
- **Purpose** Bendahara Jemaat, journey step 2 (Catat form of "1 · Harian"): pick the Tanggal transaksi of a Belanja draft. Shows that the transaction date decides the report month ("masuk laporan … 2026"); the refusal of a closed month (September 2026, Penolakan form with an available step "Kejadian setelah tutup buku", never reopening a month); the refusal of dates after today 16 November 2026; that choosing a date in Oktober 2026 (the month being closed) puts the transaction in the October report and turns a confirmed October reconciliation into "Perlu dipastikan lagi"; and that Tanggal dokumen, Dicatat pada and Dibukukan pada are separate values ("Not yet known is —" for Dibukukan pada).
- **Shell** Phone header with back, no tab bar, fixed bottom action bar. Board root: column 390×844, `kertas`, `tinta`, sans 16/1.4. PitaJabatanKosong strip on top when `jabatanKosong`.
- **Layout**
  0. (only `jabatanKosong`) Strip as LihatDokumen region 0.
  1. Header: row, centre, gap 8, padding 14 top, 12 sides, 8 bottom. Back target 44×44, chevron (`M15 6l-6 6 6 6`, 22, stroke 2, round caps, `tinta`), semantics "Kembali ke isian". Title block: h1 "Tanggal transaksi" (`judulLayar` 18/700); "Belanja · draf" (13, `tinta2`).
  2. Scroll area (fills between header and action bar): padding 8 top, 20 sides, 20 bottom; column gap 16.
     a. Month bar: row, centre, gap 8. Left button "‹" 44×44, radius 12, 1 px `garisTegas` border, `permukaan` field, 20 px glyph, semantics "Bulan sebelumnya". Centre (flex 1, centred): month name 17/700 ("November 2026"); under it the status badge 13/700, radius 6, padding 3/9, 1.5 `tinta` border: "Belum ditutup" (`permukaan` field, `tinta` text) or "Sudah ditutup" (`tinta` field, `permukaan` text). Right button "›" same style, semantics "Bulan berikutnya".
     b. Calendar: weekday row (7 equal columns, gap 4, 13 px `tinta3`, centred, padding-bottom 6): "Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min". Day grid: 7 equal columns, gap 4 (cells about 46 wide). Leading blank cells for the weekday of the 1st (Monday first; hidden, not focusable). Day cells: buttons, height 44, radius 12, no padding, number centred, inherit 16 px:
        - selected: `tinta` field, `permukaan` text, 1.5 `tinta` border, 700; semantics selected;
        - today (16 November, not selected): `permukaan` field, `tinta` text, 1.5 `tinta` border, 700;
        - selectable: `permukaan` field, `tinta` text, 1 px `garis` border, 500;
        - not selectable: transparent, no border, text `tinta3`, 500, disabled. The board draws these numbers in #808D87 (`putus`, a line token); rules-checklist.md 4.1 fixes this breach of C03: use `tinta3`, keep the transparent field and no border.
     c. Message under the grid (zero or one: each depends on the month shown, so at most one is visible; source order below):
        - September only: 15 px: "**Tidak dapat dipilih: September 2026 sudah ditutup.**" (bold part in `bata`) then " Yang masih dapat Anda lakukan: pilih tanggal di bulan yang belum ditutup, atau catat sebagai " + link "Kejadian setelah tutup buku" (700, `laut`, underlined `TautanTeks`, `lautTua` on hover) + ".".
        - Desember only: 14 `tinta2`: "Tidak dapat dipilih: tanggal setelah hari ini, 16 November 2026."
        - November only (with or without a selection): 13 `tinta3`: "Hari ini 16 November 2026. Tanggal sesudahnya belum dapat dipilih."
        - Oktober with a selected day only: card `permukaan`, 1.5 `tinta` border (terpilih), radius 14, padding 12/16, 14 px: "**Masuk laporan Oktober 2026**, bulan berikutnya untuk tutup buku. Rekonsiliasi Oktober yang sudah dipastikan menjadi “Perlu dipastikan lagi”."
     d. Detail card: `permukaan`, 1 px `garis`, radius 14, padding 4 16. Four rows, 1 px `garis` rule between rows, each padding 12 0:
        - Row, space-between, gap 16, baseline: left "Tanggal transaksi" (600) over sub (13 `tinta3`) "masuk laporan {Bulan} 2026" for the month shown (for example "masuk laporan November 2026", "masuk laporan Oktober 2026") or "menentukan bulan laporan" when none; right value 700, right-aligned: "{d} {Bulan} 2026" (for example "14 November 2026", no leading zero) or "Belum dipilih".
        - Column, gap 8: "Tanggal dokumen" (600) over "Tanggal pada nota. Tidak memengaruhi bulan laporan." (13 `tinta3`); two ChipPilihan chips "Sama dengan tanggal transaksi" and "Berbeda" (inline, min height 44, padding 0 14, margin right 8 and bottom 8, radius 999, 1.5 border, 14/600; selected `tinta` field/border, `permukaan` text; unselected `permukaan` field, `garisTegas` border, `tinta` text; semantics pressed); when "Berbeda" is chosen, a text input below: semantics label "Tanggal dokumen", numeric keyboard, hint "hh/bb/tttt", min height 48, padding 0 14, radius 12, 1 px `garisTegas` border, `permukaan`, mono 16, full width up to 220.
        - Row: "Dicatat pada" (600) over "otomatis" (13 `tinta3`); right "16/11/2026 11.40" mono 14.
        - Row: "Dibukukan pada" (600) over "otomatis, saat Bukukan" (13 `tinta3`); right "—" mono 14.
  3. Action bar (not scrolled): `permukaan`, 1 px `garis` top rule, padding 12 top, 20 sides, 22 bottom, column gap 8, full-width child:
     - with a selected date: primary link-button "Pakai 14 November 2026" (label "Pakai " + date): min height 52, radius 14, `laut` field, `diLaut` 700, centred, padding 0 20;
     - without: disabled button "Pilih tanggal dulu": same size, `garis` field, `tinta3` text, 700.
- **Components** ChipPilihan (document-date chips), Penolakan form (September refusal in `bata` with the available step), LencanaStatus-like month badge (see Notes), GarisStatus terpilih (October card), Tombol primary (Pakai), PitaJabatanKosong. Not components: month calendar grid, date text input, detail rows (label + caption + value).
- **Internal views and states** Initial state `{ bln: 10, hari: 14, dok: 'sama', dokTeks: '' }` (`bln` is the JS month index: 8 September, 9 Oktober, 10 November, 11 Desember; year fixed 2026). Derived: `tutup = bln == 8`, `nanti = bln == 11`, a day is selectable when not `tutup`, not `nanti` and not (November and day > 16); `sel` = `hari` if set and selectable, else none. Month views: September (all disabled, "Sudah ditutup", refusal), Oktober (all 31 selectable; card once a day is picked), November (1–16 selectable, 16 marked as today, caption), Desember (all disabled, future refusal). Grid shapes for 2026: September starts Selasa (1 blank, 30 days), Oktober starts Kamis (3 blanks, 31), November starts Minggu (6 blanks, 30; six rows), Desember starts Selasa (1 blank, 31). Document date: `sama` (no input) / `beda` (input shown). Action: Pakai (selection) / Pilih tanggal dulu (none). No sheets or toasts.
- **Tweaks** `jabatanKosong` (boolean, default false) · Keadaan panel (global switch). On: strip 0 only. Text replacement disabled (`jk && false`); the board has no names anyway.
- **Interactions**
  - "‹" (`prev`): if `bln > 8`: `bln − 1`, `hari = null`. Disabled at September.
  - "›" (`next`): if `bln < 11`: `bln + 1`, `hari = null`. Disabled at Desember.
  - Day cell (`pick`): if selectable, `hari = d`; disabled cells do nothing. Changing month always clears the selection, so coming back to November shows no selection ("Belum dipilih", "Pilih tanggal dulu").
  - Chip "Sama dengan tanggal transaksi" → `dok = 'sama'` (input hidden); chip "Berbeda" → `dok = 'beda'` (input shown). `dokTeks` is kept while hidden and reappears.
  - Document date input (`onDok`), every keystroke: remove every character that is not a digit or "/", then cut to 10 characters; store and show the result. No automatic slashes, no date validation, no effect on the report month or on Pakai ("1a2/11/20269" → "12/11/2026").
  - "Pakai {tanggal}" → back to the Catat form (`kembaliKe('/Main')`). The chosen date is not carried into Main (each board keeps its own state).
  - "Pilih tanggal dulu" is disabled: no handler; its label is its reason.
  - "Kejadian setelah tutup buku" → push `/Kejadian`.
- **Motion** October card: `muncul` 300 ms (opacity 0→1, y +8→0), CSS default easing `ease` (`Curves.ease`), when it appears (October shown and a day picked); picking another October day keeps it without replaying; leaving October and coming back hides it until a day is picked, then it replays. Cell, chip and badge changes are instant. Reduce motion: instant. Declared but unused: `masuk`, `pudar`, `isi`.
- **Links out** Back arrow (semantics "Kembali ke isian") → `kembaliKe('/Main')` (pops to `/Main/catat`). "Pakai …" → `kembaliKe('/Main')`. "Kejadian setelah tutup buku" → `/Kejadian`, push. **Inbound** Main (Catat form, "16 November 2026 Ubah"), and the map sheets PetaLayar and Cakupan (links built in their logic classes, navigation.md 3.3).
- **Mock data** Today 16 November 2026 (16/11/2026); draft type "Belanja · draf"; default selected date 14 November 2026; Dicatat pada 16/11/2026 11.40; Dibukukan pada "—"; September 2026 closed; Oktober 2026 open and next to close; Desember 2026 in the future.
- **Prototype-only** none. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. Open `/Tanggal` → "November 2026" with badge "Belum ditutup"; six week rows starting with six blanks; cell 14 is a `tinta` field with `permukaan` text; cell 16 has a 1.5 `tinta` border and bold text; cells 17–30 have no field or border, `tinta3` numbers, and are disabled; caption "Hari ini 16 November 2026. Tanggal sesudahnya belum dapat dipilih."; button "Pakai 14 November 2026".
  2. Tap 3 → row value "3 November 2026", sub "masuk laporan November 2026", button "Pakai 3 November 2026". Tap 20 → nothing changes.
  3. Tap "‹" → "Oktober 2026", three blanks, no selection; no message under the grid; row "Belum dipilih" / "menentukan bulan laporan"; action "Pilih tanggal dulu" (`garis` field, `tinta3` text, disabled).
  4. Tap 6 → card "Masuk laporan Oktober 2026, bulan berikutnya untuk tutup buku. …" rises in over 300 ms; row value "6 Oktober 2026", sub "masuk laporan Oktober 2026"; button "Pakai 6 Oktober 2026"; tap 7 → card stays without replaying.
  5. Tap "‹" → "September 2026", badge "Sudah ditutup" (`tinta` field); every day disabled; "Tidak dapat dipilih: September 2026 sudah ditutup." in `bata`; "‹" disabled; link "Kejadian setelah tutup buku" opens `/Kejadian`.
  6. Tap "›" three times → "Desember 2026"; every day disabled; "Tidak dapat dipilih: tanggal setelah hari ini, 16 November 2026."; "›" disabled.
  7. Tap "Berbeda" → chip filled `tinta`; input with hint "hh/bb/tttt" appears; type "1a2/11/20269" → shows "12/11/2026".
  8. Tap "Sama dengan tanggal transaksi" → input hidden; tap "Berbeda" → "12/11/2026" is still there.
  9. Opened from `/Main/catat`, tap "Pakai 14 November 2026" → back on `/Main/catat`; the back arrow does the same.
  10. `jabatanKosong` on → strip "Menjalankan jabatan kosong · Bendahara Jemaat" above the header; nothing else changes.
- **Notes** Disabled day numbers are #808D87 (`putus`) on the board, but CONVENTIONS reserves `putus` for lines; rules-checklist.md 4.1 decides to fix this in the prototype: draw them in `tinta3` (transparent field, no border kept). The month badge does not follow LencanaStatus ("Belum ditutup" should be a `tinta3` line with `tinta2` text); the board draws a 1.5 `tinta` line and `tinta` text; keep the board. The action bar swaps a link for a different disabled button and shows no "Tidak dapat dilakukan: …" sentence, unlike TombolBersyarat; keep the board, the label "Pilih tanggal dulu" is the reason. TombolBersyarat says typed dates are checked while typing; this board does not check the document date; keep as drawn (no error text). Main shows "16 November 2026" while this board opens on 14 November; keep each. Month 17 px is off-token. Buttons "‹"/"›" have no disabled look on the board (inline colours win); keep and expose disabled semantics. Manifest `hasSideNav: true` is a false positive.

### WebTanggal — Web · Tanggal transaksi dan tanggal dokumen
- **Source** `docs/design/handoff/canvas/boards/WebTanggal.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebTanggal`, no child routes · **Widget** `WebTanggalScreen` in `lib/screens/lengkap/web_tanggal.dart`
- **Purpose** Bendahara Jemaat on the laptop, journey step 2 (WebCatat, TabCatat): same as Tanggal, with the rule stated under the title: "Tanggal transaksi menentukan bulan laporan. Tanggal dokumen, dicatat dan dibukukan disimpan terpisah."
- **Shell** Web side nav exactly as WebLihatDokumen (same items, **Transaksi** active, same footer, same ≤ 860 px top bar with "Menu"/"Tutup menu", same main column and web PitaJabatanKosong banner).
- **Layout**
  0. (only `jabatanKosong`) Web banner as WebLihatDokumen region 0.
  1. Title block: breadcrumb link "Catat transaksi" (14/600, `laut`, underlined `TautanTeks`, `lautTua` on hover); h1 "Tanggal transaksi" (`judulHalaman` 26/700, margin-top 2); "Tanggal transaksi menentukan bulan laporan. Tanggal dokumen, dicatat dan dibukukan disimpan terpisah." (14, `tinta2`).
  2. Row, wrap, gap 28, top-aligned:
     a. Calendar column: flex 1 1 380, max width 460, min width 0, column gap 14: month bar, weekday row, day grid and messages exactly as Tanggal region 2 a–c (day numbers inherit 15 px; cells about 51 wide at 1440). On one row with b it stays about 380 wide; when wrapped it grows to 460.
     b. Detail column: flex 999 1 380, min width 0, column gap 14: the detail card exactly as Tanggal region 2 d (body 15 px; input mono 15); under it a plain row holding the action: "Pakai {tanggal}" link-button or disabled "Pilih tanggal dulu", same style as Tanggal region 3 but as wide as its label (not full width), no action bar.
  At 1440 and at 860 the two columns sit side by side (380 + 28 + rest); in windows where the main content is narrower than 788 (about 861–1080 wide with the side nav) the detail column wraps below.
- **Components** As Tanggal, plus the shared web side nav.
- **Internal views and states** Same as Tanggal: initial `{ bln: 10, hari: 14, dok: 'sama', dokTeks: '' }`, same months, same derived rules.
- **Tweaks** `jabatanKosong` (boolean, default false) · Keadaan panel (global switch). On: banner 0 and nav footer "Yanti Sumual · Operator / Menjalankan jabatan kosong Bendahara Jemaat". Text replacement disabled (`jk && false`).
- **Interactions** Same handlers as Tanggal (`prev`, `next`, day `pick`, chips, `onDok` with the same filter and 10-character cut). "Pakai {tanggal}" → `kembaliKe('/WebCatat')`. "Kejadian setelah tutup buku" → push `/WebKejadian`.
- **Motion** Same as Tanggal (October card `muncul` 300 ms). Declared but unused: `isi`, `titik`.
- **Links out** Breadcrumb "Catat transaksi" → `kembaliKe('/WebCatat')`. "Pakai …" → `kembaliKe('/WebCatat')`. "Kejadian setelah tutup buku" → `/WebKejadian`, push. Side nav (go): Beranda `/WebBeranda`, Transaksi `/WebTransaksi`, Uang Muka dan Titipan `/WebKewajiban`, Rekonsiliasi `/WebRekonsiliasi`, Bulan dan tutup buku `/WebTutupBuku`, Laporan `/WebPaketLaporan`, Pengaturan `/WebPengaturan`. **Inbound** WebCatat ("Tanggal transaksi"), TabCatat ("Tanggal transaksi"), and the map sheets PetaLayar and Cakupan (links built in their logic classes, navigation.md 3.3).
- **Mock data** Same as Tanggal; banner date 16/11/2026 08.15.
- **Prototype-only** none. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. `/WebTanggal` at 1440 → side nav "Transaksi" active; breadcrumb "Catat transaksi"; calendar column about 380 wide on the left, detail card on the right; "Pakai 14 November 2026" button sized to its label under the card.
  2. Calendar behaves as Tanggal checks 1–6 (same cells, refusals, card, disabled arrows).
  3. September refusal link "Kejadian setelah tutup buku" → `/WebKejadian`.
  4. "Berbeda" → input "hh/bb/tttt" (max 220 wide); typing "ab12/1" shows "12/1".
  5. From `/WebCatat`, "Pakai …" or the breadcrumb → pops back to `/WebCatat`; from `/TabCatat` → goes to `/WebCatat`.
  6. At 860 wide: nav top bar with "Menu"; no horizontal page scroll; calendar cells stay 44 high.
  7. `jabatanKosong` on → banner on top and nav footer "Yanti Sumual · Operator".
- **Notes** Same notes as Tanggal. The board's "Pakai" sits in a `display: flex` row, so it is not stretched; keep it content-width (unlike the phone).
