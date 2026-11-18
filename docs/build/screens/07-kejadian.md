# Screens 07: Kejadian, WebKejadian, FormatLaporan, WebFormatLaporan, AwalIsian, WebAwalIsian, Pengembalian, WebPengembalian, Pemberitahuan, WebPemberitahuan, Masuk, WebMasuk

These twelve boards are six phone/laptop pairs from the canvas page "Pelengkap" (`lengkap`), titles 22 to 27. They fill gaps around the Bendahara Jemaat's main journeys. Kejadian/WebKejadian list the incidents found after a month was closed (K-2026-01 and K-2026-02, both in closed September 2026) and record a financial settlement apart from the explanation. Resolving one does not lift the block on closing October 2026 (D11). FormatLaporan/WebFormatLaporan record the out-of-app approval of the report format, a precondition for the first month close (D14, C04). AwalIsian/WebAwalIsian are the identity-and-lists step of the initial setup (Nama Jemaat, Zona waktu, Kas/Bank, peruntukan, Lingkup, running advances and deposits) and end with "Terbitkan pengaturan awal". Pengembalian/WebPengembalian save a refund to a donor or from a supplier as a draft linked to its original voucher (D05, RD04). Pemberitahuan/WebPemberitahuan are the in-app notification list with per-type switches (D28, C06). Masuk/WebMasuk are sign-in with a phone number and six-digit code, ending on one of four outcomes switched by the tweak `setelahMasuk` (D25, P01). The phone boards have no tab bar. Each has a header with a back arrow, except Masuk, which is a bare sign-in page. The laptop boards sit under the standard web side nav, except WebMasuk, whose nav has the single item "Masuk". Phone boards are reached from TutupBuku, Tanggal, Lainnya, Awal, Main, AlurPengembalian, Keputusan, Keluar, Pemulihan and Sambungan. Web boards are reached from WebTutupBuku, WebKoreksi, WebTanggal, WebPaketLaporan, WebPengaturan, WebAwal, WebTransaksi, TabTransaksi, WebAlurPengembalian, WebBeranda, TabBeranda, WebKeluar, WebPemulihan and WebSambungan. The "Inbound" lines below are the manifest's; PetaLayar (all twelve) and Cakupan (Kejadian, Masuk) also link here from their logic class (navigation.md 3.3). In every section "up link" means the phone back arrow or the web breadcrumb above the h1, built as `Tautan(ke: 'X', cara: Cara.naik)`: it pops when the page directly beneath is `/X` or a child route of `/X`; otherwise it does `go('/X')`. Drill-ins into other boards are `push` (`Cara.dorong`, the default); side-nav items are `go` (`Cara.ganti`). Today is 16/11/2026 on every board, and the actor is Meiske L., Bendahara. Every `muncul .3s` on these twelve boards has no easing given, so it runs on CSS `ease` (`Curves.ease`), not `keluar`; only Kejadian's `masuk .28s` names `cubic-bezier(.2,.8,.2,1)`.

---

### Kejadian — 22 · Kejadian setelah tutup buku
- **Source** `docs/design/handoff/canvas/boards/Kejadian.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 · interactive yes
- **Route** `/Kejadian` (list) plus child route `/Kejadian/rinci` (the full-screen detail of the chosen Kejadian) · **Widget** `KejadianScreen` in `lib/screens/lengkap/kejadian.dart`
- **Purpose** Bendahara Jemaat at month end (journey step 4, reached from "2 · Akhir bulan" when October 2026 cannot be closed). Shows D11: recording the financial settlement of a Kejadian does not remove the blocker on the following month. Also shows the glossary rule "Kejadian = an incident after month close" (never "Peristiwa") and the permanent statement "Kejadian hanya mencatat…". The explanation and the financial settlement are recorded separately. The official figures of the closed month never change.
- **Shell** Phone header with back, no tab bar. Phone root: `kertas`, `tinta` text, `isi` 16/1.4, column. When `jabatanKosong` is on, the one-line PitaJabatanKosong strip sits above the header on both the list and the detail (it is outside the view container):
  0. Strip, `role=status`: full width, `tinta` field, `permukaan` text, padding 10/24/8, 13 px line-height 1.3, centred: "**Menjalankan jabatan kosong** · Bendahara Jemaat". Does not scroll.
- **Layout**
  - **List view** (`/Kejadian`), column filling the screen:
    1. Header row: padding 14 top, 12 sides, 8 bottom, gap 8. Back target 44×44 with chevron (path `M15 6l-6 6 6 6`, 22 px, stroke 2, round caps, `tinta`), semantics "Kembali ke Bulan". Title "Kejadian setelah tutup buku" (`judulLayar` 18/700). No subtitle.
    2. Scroll area (fills the rest): padding 8 top, 20 sides, 20 bottom; column gap **12** (the source writes `gap: 16px; gap: 12px`; the second wins).
       a. (only when `menghambatBulanBerikutnya`) Blocker statement, line language ditutup: `tinta` field, radius 14, padding 16, column gap 6. "Oktober 2026 tidak dapat ditutup" 16/700 `permukaan`. Next, 14 `diTinta`: "Kas punya selisih belum dijelaskan Rp85.000 yang berasal dari kejadian K-2026-01 di September 2026. November 2026 dan bulan sesudahnya ikut tertahan." Then 14 `diTinta`: "Aplikasi ini tidak menyediakan cara untuk memperbaikinya. " followed by bold `permukaan` "**Yang perlu memutuskan: BPMJ Jemaat Karunia.**"
       b. Two Kejadian cards, each a full-width pressable: `permukaan`, 1 px `garis` (dibukukan), radius 14, padding 14/16, column gap 4. Line 1 (space-between, centred, gap 16): code mono 13 `tinta2` ("K-2026-01") on the left and the status badge on the right. Line 2: title 15/600. Line 3: "September 2026 · Sudah ditutup" 13 `tinta3`. Cards are not highlighted when chosen on the phone; the logic computes a highlight, but this board never uses it.
       c. Status badge (both views): 13/700, radius 6, padding 3/9. "Belum ditindaklanjuti": `permukaan` field, 1.5 `tinta3` line, `tinta2` text. "Sudah ditindaklanjuti": `laut` field, 1.5 `laut` line, `diLaut` text.
       d. Caption 13 `tinta3`: "Kejadian dicatat dari transaksi di bulan yang sudah ditutup, lewat “Catat kejadian”."
  - **Detail view** (`/Kejadian/rinci`), column filling the screen:
    1. Header row as the list's, but the back control is a button with semantics "Kembali" (not a link) and the title is "Kejadian" (18/700).
    2. Scroll area: padding 8/20/20, column gap 16.
       a. Identity block (column gap 4): a wrapping row (gap 8) of code mono 13 `tinta2` "K-2026-01" plus the status badge (as list c). Under it the title 20/700 "Nota tercatat dua kali" (20 is off-token, copy it).
       b. Permanent statement, ditutup: `tinta` field, radius 14, padding 12/16, 14 `permukaan`: "Kejadian hanya mencatat. Kejadian tidak mengubah angka apa pun, tidak menghapus selisih, dan tidak menghilangkan hambatan tutup buku."
       c. "Penjelasan" 15/700, then the explanation 15 regular (column gap 4).
       d. Facts card: `permukaan`, 1 px `garis`, radius 14, padding 4/16. Five rows, space-between, gap 16, padding 11 0, 1 px `garis` top rule from the second row on. Key 14 `tinta2` (does not shrink); value 14/600 right-aligned, wraps. Keys in order: "Periode", "Transaksi", "Dampak pada rekonsiliasi", "Penanggung jawab", "Hasil eskalasi" (values in Mock data; Periode value is "September 2026 · Sudah ditutup").
       e. Settlement section (column gap 6): heading "Penyelesaian keuangan" 15/700 followed inline by " · dicatat terpisah dari penjelasan" 15/500 `tinta3`. Then one of:
          - **Not yet resolved**: IsianAlasan-style textarea, 2 rows fixed (no resize), full width, padding 12/14, radius 12, 1 px `garisTegas`, `permukaan`, body font inherited (16/1.4 on the phone). Placeholder "Apa yang diputuskan dan dilakukan, setelah ada keputusan Jemaat". Semantics "Penyelesaian keuangan". Under it the button "Catat penyelesaian keuangan": min-height 46, padding 0 20, radius 12, no border, 700, left-aligned in the column (hugs its text). Enabled: `tinta` field, `permukaan` text. Unmet: `garis` field, `tinta3` text.
          - **Resolved**: the settlement text 15 regular (enters with `muncul`). Then "Angka dan laporan resmi September 2026 tidak berubah." 13 `tinta3` (the month comes from the Kejadian's periode). Then, only when `menghambatBulanBerikutnya` is on and this is K-2026-01: "Hambatan tutup buku Oktober 2026 tetap ada." 14/700 `tinta`.
- **Components** LencanaStatus (the two "…ditindaklanjuti" badges, built with its shapes: `tinta3` line / `laut` field), TombolBersyarat ("Catat penyelesaian keuangan", without a reason sentence, see Notes), IsianAlasan (textarea), PitaJabatanKosong (phone strip), GarisStatus (ditutup for the two dark statements, dibukukan for cards). Repeated patterns, not components: Kejadian card (code + badge, title, period), key/value facts card.
- **Internal views and states** Initial state `{ buka: false, pilih: 'k1', selesai: {}, isi: '' }`. Views: List (`buka == false`, `/Kejadian`), Detail (`buka == true`, `/Kejadian/rinci`) for the Kejadian in `pilih`. Inside the detail: "not yet resolved" (form) or "resolved" (text). K-2026-02 is always resolved (it carries a fixed settlement, `beres`). K-2026-01 is resolved once `selesai.k1` is set. `selesai` and `pilih` must survive moving between `/Kejadian` and `/Kejadian/rinci`. Hold the board state in one object owned by the `/Kejadian` route and shared with its child; it resets only when `/Kejadian` is left. Opening `/Kejadian/rinci` directly shows K-2026-01. No sheets, toasts or empty states.
- **Tweaks** (Keadaan panel)
  - `jabatanKosong` (boolean, default false), the global switch. On: strip 0 appears above the header of both views. Text replacement is disabled on this board (`jk && false`), so "Meiske L., Bendahara" stays as Penanggung jawab of K-2026-02.
  - `menghambatBulanBerikutnya` (boolean, default true). On: list blocker statement 2a shows; the resolved K-2026-01 detail shows "Hambatan tutup buku Oktober 2026 tetap ada.". Off: both are hidden. Nothing else changes, including the "Dampak pada rekonsiliasi" text.
- **Interactions**
  - Kejadian card tap (`pick`) → `pilih = id`, `buka = true`, `isi = ''` → push `/Kejadian/rinci`.
  - Detail back button (`tutupRinci`) → `buka = false` → pop to `/Kejadian`. System Back does the same. Typed text that was not saved is lost (the next `pick` clears it anyway).
  - Textarea (`onIsi`) → `isi` = the text as typed, on every keystroke. No formatting, no length limit.
  - "Catat penyelesaian keuangan" (`simpan`): condition `isi.trim()` is not empty. Unmet: no effect; the board has no refusal text. Met: `selesai[pilih] = isi.trim()`, `isi = ''`. The form is replaced at once by the resolved text, and the badge (detail and list) becomes "Sudah ditindaklanjuti". The condition is re-checked on press from the latest text, so the first press after typing works. Once saved there is no edit or undo.
  - List back arrow → up link to `/TutupBuku`.
- **Motion**
  - Detail enters with `masuk` 280 ms, curve Cubic(0.2, 0.8, 0.2, 1): slide 24 px from the right plus fade. Use it as the `/Kejadian/rinci` page transition (motion.md `masuk`). Going back to the list has no animation (the list view has none).
  - Resolved settlement text (first line only) enters with `muncul` 300 ms (fade + 8 px rise), CSS default easing `ease` (`Curves.ease`, not `keluar`). It plays whenever that line appears: right after saving, and each time the detail of an already resolved Kejadian opens (K-2026-02 always), together with the route's `masuk`.
  - Button colour swaps instantly. Declared but unused: `isi`, `pudar`.
- **Links out** List back arrow (no label, "Kembali ke Bulan") → `/TutupBuku`, up link. **Inbound** Keputusan (D11), Lainnya, Tanggal, TutupBuku.
- **Mock data**
  - K-2026-01 · "Nota tercatat dua kali" · September 2026 · Transaksi BKU-2026-0031 · Penjelasan "Nota Toko Sinar Rp85.000 tercatat dua kali pada 22/09/2026. Ditemukan saat hitung kas 31/10/2026." · Dampak "Kas Oktober 2026: hasil hitung kas lebih Rp85.000 dari Saldo buku." · Penanggung jawab "Pdt. Lidya Rondonuwu, Ketua BPMJ" · Hasil eskalasi "Dibahas di rapat BPMJ 09/11/2026. Belum ada keputusan." · no settlement (typed by the user).
  - K-2026-02 · "Dokumen pendukung menyusul" · September 2026 · Transaksi BKU-2026-0019 · Penjelasan "Kuitansi asli diterima 12/10/2026, setelah September ditutup." · Dampak "Tidak ada." · Penanggung jawab "Meiske L., Bendahara" · Hasil eskalasi "Tidak perlu eskalasi." · settlement "Tidak ada penyelesaian keuangan; kuitansi dilampirkan sebagai dokumen susulan."
  - Blocker: unexplained Kas difference Rp85.000, October 2026 cannot close, November 2026 held, decider "BPMJ Jemaat Karunia".
- **Prototype-only** none on the board. Keadaan panel: `jabatanKosong`, `menghambatBulanBerikutnya`.
- **Acceptance checks**
  1. Open `/Kejadian` → title "Kejadian setelah tutup buku", dark statement "Oktober 2026 tidak dapat ditutup", two cards: K-2026-01 with outlined badge "Belum ditindaklanjuti", K-2026-02 with `laut` badge "Sudah ditindaklanjuti".
  2. Tap the K-2026-01 card → `/Kejadian/rinci` slides in from 24 px right over 280 ms; title "Nota tercatat dua kali"; facts card row "Transaksi" reads "BKU-2026-0031"; row "Hasil eskalasi" reads "Dibahas di rapat BPMJ 09/11/2026. Belum ada keputusan.".
  3. With the textarea empty or only spaces, "Catat penyelesaian keuangan" is `garis`/`tinta3` and pressing it changes nothing.
  4. Type "Selisih dicatat sebagai koreksi" → button turns `tinta`; one tap → textarea and button vanish, the text fades up, then "Angka dan laporan resmi September 2026 tidak berubah." and bold "Hambatan tutup buku Oktober 2026 tetap ada."; the badge reads "Sudah ditindaklanjuti".
  5. Header back → list (no animation); K-2026-01 badge is now "Sudah ditindaklanjuti" and the dark "Oktober 2026 tidak dapat ditutup" statement is still there (D11).
  6. Tap K-2026-02 → no form; text "Tidak ada penyelesaian keuangan; kuitansi dilampirkan sebagai dokumen susulan." and no "Hambatan…" line.
  7. Panel `menghambatBulanBerikutnya` off → the list statement disappears; resolved K-2026-01 detail no longer shows "Hambatan tutup buku Oktober 2026 tetap ada.".
  8. Panel `jabatanKosong` on → strip "Menjalankan jabatan kosong · Bendahara Jemaat" above the header on the list and on the detail.
  9. List back arrow → `/TutupBuku`; leaving and reopening `/Kejadian` resets K-2026-01 to "Belum ditindaklanjuti".
- **Notes** Off-token: title 20 px, 15 px headings and card titles, button height 46 (not `tombolUtama` 52), badge padding 3/9. The form's action uses `tinta` instead of the primary `laut`, and its unmet look is `garis`/`tinta3` where TombolBersyarat says `tinta2`; keep the board. The board shows no "Tidak dapat dilakukan: …" sentence for the unmet button. The board wins on what is shown, so add none, but give the button a semantics hint naming the empty field ("Penyelesaian keuangan"). The source codes "Transaksi" values (BKU-2026-0031) in sans. CONVENTIONS says every code is mono, so render that one value mono 14/600 (recommended); codes inside sentences stay sans. Placeholder colour is not set on the board; use `tinta3`.

### WebKejadian — Web · Kejadian setelah tutup buku
- **Source** `docs/design/handoff/canvas/boards/WebKejadian.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1100) · interactive yes
- **Route** `/WebKejadian`, no child routes (list and detail are always side by side) · **Widget** `WebKejadianScreen` in `lib/screens/lengkap/web_kejadian.dart`
- **Purpose** Same as Kejadian, on the laptop, journey step 4. D11. Reached from "Bulan dan tutup buku".
- **Shell** Web side nav, the standard one, shared by WebKejadian, WebFormatLaporan, WebAwalIsian, WebPengembalian and WebPemberitahuan (specified once here; WebMasuk has a variant):
  - Nav column: flex basis 220, padding 24/16, `permukaan`, 1 px `garis` right border, column gap 20.
  - Brand row (padding 0 8, gap 10): Palakat mark 26×26 (rect x2 y2 w20 h20 rx 6, 2 px `laut` stroke dashed 3 3, plus the filled right half `M12 2h4a6 6 0 0 1 6 6v8a6 6 0 0 1-6 6h-4z` in `laut`) beside "palakat" 18/700 line-height 1.1 over "Jemaat Karunia" 13 `tinta3`.
  - Items, exactly: Beranda → `/WebBeranda`, Transaksi → `/WebTransaksi`, Uang Muka dan Titipan → `/WebKewajiban`, Rekonsiliasi → `/WebRekonsiliasi`, Bulan dan tutup buku → `/WebTutupBuku`, Laporan → `/WebPaketLaporan`, Pengaturan → `/WebPengaturan`. Each min-height 44, padding 0 12, radius 10, weight 600, no underline. Active: `tinta` field, `permukaan` text; others transparent, `tinta` text. All `go`.
  - Footer: margin-top auto, padding 12/8/0, 1 px `garis` top rule, 13 `tinta2`: "**Meiske L.** · Bendahara" / "Wewenang Bendahara aktif" (name `tinta`). With `jabatanKosong`: "**Yanti Sumual** · Operator" / "Menjalankan jabatan kosong Bendahara Jemaat".
  - At 860 px wide and below (`@media (max-width: 860px)`, so 860 itself collapses) the nav becomes a full-width top bar (row, wrap, gap 0 12, centred, padding 8/16, `garis` bottom border, no right border): brand on the left, toggle pushed to the right (margin-left auto): min-height 44, padding 0 16, radius 14, 1.5 `tinta` line, `permukaan`, 14/700, "Menu" (semantics "Menu"). Items and footer are hidden. Open: toggle `tinta` field, `permukaan` text, "Tutup menu"; the items show full-width below (padding 8 0) and then the footer (margin-top 0, padding 12/8/8).
  - Main column: flex 999 1 560, padding 28 top, clamp(16, 3vw, 40) sides, 40 bottom, column gap 20; body `isiWeb` 15/1.45.
  - With `jabatanKosong` the first item of main is the web PitaJabatanKosong, `role=status`: `tinta` field, radius 14, padding 12/16, 14 px. "**Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15.**" then "Setiap tindakan dicatat sebagai dijalankan oleh Operator Yanti Sumual." in `diTinta2`.
  - On this board the active item is **Bulan dan tutup buku**.
- **Layout** (main column, top to bottom)
  1. Title block: breadcrumb link "Bulan dan tutup buku" (14/600, `laut`), then h1 "Kejadian setelah tutup buku" (`judulHalaman` 26/700, margin-top 2).
  2. (only when `menghambatBulanBerikutnya`) Blocker statement, same box and copy as Kejadian list 2a.
  3. Two-column row (wrap, gap 24, top-aligned):
     - **Left, list** (flex 1 1 360): one card, `permukaan`, 1 px `garis`, radius 14, clips its children. Two row buttons, full width, padding 14/18, column gap 4, each with a 1 px `garis` top rule (also the first one). Line 1: code mono 13 `tinta2` and badge (as Kejadian 2c), space-between, gap 16. Line 2: title 15/600. Line 3: "September 2026 · Sudah ditutup" 13 `tinta3`. Chosen row (`aria-pressed`): `lautLembut` field plus a 3 px `laut` bar on its inner left edge (inset shadow); others `permukaan`.
     - **Right, detail** (flex 999 1 520, column gap 16): regions a–e exactly as the Kejadian detail scroll area (identity block with 20/700 title, dark statement, Penjelasan, facts card, settlement section with textarea/button or resolved text). Body text is 15 here, so the textarea uses 15.
     Side by side when the main content is at least 904 px wide (window about 1200 px and up); below that the detail wraps under the list at full width.
- **Components** As Kejadian, with the web PitaJabatanKosong and the standard web side nav. The list row is a selectable row (GarisStatus terpilih rendered as `lautLembut` + `laut` bar).
- **Internal views and states** Initial `{ buka: false, pilih: 'k1', selesai: {}, isi: '' }`. One view: list plus the detail of `pilih` (K-2026-01 first). `buka` is set by `pick` but has no effect on web. Detail states "not yet resolved" / "resolved" as Kejadian.
- **Tweaks** (Keadaan panel) `jabatanKosong` (boolean, default false), global: web banner on top of main, nav footer switches to Yanti Sumual; text replacement disabled (`jk && false`). `menghambatBulanBerikutnya` (boolean, default true): region 2 and the "Hambatan tutup buku Oktober 2026 tetap ada." line, as Kejadian.
- **Interactions**
  - Row click (`pick`) → `pilih = id`, `isi = ''` (and `buka = true`, unused). The row becomes the chosen row; the detail switches in place. Unsaved typed text is dropped.
  - Textarea and "Catat penyelesaian keuangan": identical to Kejadian (condition `isi.trim()` not empty; save sets `selesai[pilih]`, clears `isi`). The list badge of that row updates at once.
  - Breadcrumb → up link to `/WebTutupBuku`.
- **Motion** Resolved settlement text `muncul` 300 ms (`ease`) when the resolved block mounts: after saving, or when switching from an unresolved Kejadian to a resolved one. Switching between two resolved Kejadian (K-2026-01 saved, then K-2026-02) keeps the element mounted in the browser and does not replay it: key the `Gerak` on the resolved state, not on `pilih` (motion.md rule 3). No `masuk` on web. Row highlight swaps instantly. Declared but unused: `isi`, `titik`.
- **Links out** Breadcrumb "Bulan dan tutup buku" → `/WebTutupBuku`, up link. Side nav as in Shell. **Inbound** WebKoreksi, WebTanggal, WebTutupBuku.
- **Mock data** Same as Kejadian.
- **Prototype-only** none. Keadaan panel: `jabatanKosong`, `menghambatBulanBerikutnya`.
- **Acceptance checks**
  1. `/WebKejadian` at 1440 → nav item "Bulan dan tutup buku" filled `tinta`; blocker statement under the h1; K-2026-01 row has a `lautLembut` field and a 3 px `laut` left bar; the detail on the right shows "Nota tercatat dua kali".
  2. Click the K-2026-02 row → it takes the highlight; detail shows "Dokumen pendukung menyusul" and the fixed settlement text fades up.
  3. On K-2026-01 type "abc", click K-2026-02, click K-2026-01 → textarea is empty.
  4. On K-2026-01 save "Selisih dicatat sebagai koreksi" → left row badge becomes "Sudah ditindaklanjuti" immediately; blocker statement stays.
  5. Panel `menghambatBulanBerikutnya` off → statement under the h1 disappears.
  6. At 1280 the two columns sit side by side; at 860 the nav shows "Menu" and the detail sits under the list with no horizontal scroll.
  7. Breadcrumb → `/WebTutupBuku`; browser Back returns.
  8. `jabatanKosong` on → banner "Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15." at the top; footer "Yanti Sumual · Operator".
- **Notes** Every list row has a top rule, including the first, so the card shows a 1 px rule directly under its own top border. Copy it as drawn. Phone notes apply (button colours, mono for the Transaksi value, no reason sentence, placeholder `tinta3`).

### FormatLaporan — 23 · Persetujuan format laporan
- **Source** `docs/design/handoff/canvas/boards/FormatLaporan.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 · interactive yes
- **Route** `/FormatLaporan`, no child routes (the form turns into the record in place) · **Widget** `FormatLaporanScreen` in `lib/screens/lengkap/format_laporan.dart`
- **Purpose** Bendahara Jemaat, before the first month close (journey steps 4–5). The report format "Bawaan Palakat · v1" (F01–F14) is approved outside the app by the Pimpinan Jemaat yang berwenang; the Bendahara only records who, how and when. Shows D14 (no signatures on printed pages, only the line recording the format approval) and C04 (F14 attachment names, an empty attachment printed "Nihil"). Follows KartuPersetujuan: no "Approve", no imitation signature. Until recorded it is a month-close blocker.
- **Shell** Phone header with back, no tab bar. Root as Kejadian; strip 0 (PitaJabatanKosong, same copy) above the header when `jabatanKosong`.
- **Layout**
  1. Header row (padding 14/12/8, gap 8): back target 44×44 chevron, semantics "Kembali ke Lainnya". Title "Format laporan" (18/700); under it "Wajib sebelum tutup buku pertama · contoh 3 Oktober 2026" (`keterangan` 13, `tinta2`).
  2. Scroll area: padding 8/20/20, column gap 16. Top part is the **Belum** state or the **Ada** state; then three fixed cards.
     - **Belum** (not yet recorded):
       a. Blocker card, line language hambatan: `permukaan`, 1.5 `bata` line, radius 14, padding 14/16. "Persetujuan format: belum dicatat" 16/700; "Hambatan tutup buku sampai dicatat. Pimpinan Jemaat yang berwenang menyetujui format di luar aplikasi; Anda mencatatnya di sini." 14 `tinta2`.
       b. Field "Pemberi persetujuan" label 14 `tinta2` followed by bold `tinta` " · wajib", margin-bottom 6. Input: full width, min-height 48, padding 0 14, radius 12, 1 px `garisTegas`, `permukaan`, body 16. Placeholder "Nama lengkap". Empty at start.
       c. Field "Jabatan" (same label style, no "wajib"). Input as b, prefilled "Ketua BPMJ".
       d. "Cara" 14 `tinta2`, margin-bottom 8. ChipPilihan chips "surat", "notulen rapat", "pesan" (lower case as drawn): inline, min-height 44, padding 0 14, margin 0 8 8 0, radius 999, 1.5 line, 14/600. Selected: `tinta` field and line, `permukaan` text. Unselected: `permukaan`, `garisTegas` line, `tinta` text. Default "notulen rapat". `aria-pressed`.
       e. Fact row: min-height 44, 1 px `garis` top rule, space-between, centred, gap 16: "Tanggal persetujuan" 14 `tinta2` / "3 Oktober 2026" 16/600. Not editable.
       f. TombolBersyarat "Catat persetujuan format": full width, min-height 52, radius 14, padding 0 20, centred 700. Met: `laut` field, `diLaut` text. Unmet: `garis` field, `tinta3` text.
     - **Ada** (recorded):
       a. Record card, terpilih: `permukaan`, 1.5 `tinta` line, radius 14, padding 16, column gap 4, enters with `muncul`. "Persetujuan format: sudah dicatat" 17/700. "Pemberi persetujuan:" (15, `tinta2`) + " **{nama}**, {jabatan}" (15 `tinta`, name bold). "03/10/2026 · cara: {cara}" 14 `tinta2`. Footnote 13 `tinta3`, separated by a 1 px dashed `garisTegas` top rule, margin-top 8, padding-top 8: "Dicatat oleh Meiske L., 03/10/2026 11.40. Persetujuan diberikan di luar aplikasi. Catatan yang keliru digantikan catatan baru, tidak diubah."
       b. Confirmation block: `lautLembut` field, no line, radius 14, padding 14/16, 16/600: "Syarat tutup buku “persetujuan format laporan sudah dicatat” terpenuhi."
     - **Always** (below either state):
       g. Card (dibukukan: `permukaan`, 1 px `garis`, radius 14, padding 16, column gap 6): "Format laporan" 14 `tinta2`; "Bawaan Palakat · v1" 18/700; "Empat belas laporan, F01 sampai F14. Format ini buatan aplikasi dan tidak mengaku sama dengan formulir asli GMIM." 14 `tinta2`; a wrapping row (gap 8, margin-top 6) of two secondary link-buttons "Lihat contoh PDF" and "Lihat contoh Excel": min-height 46, padding 0 20, radius 12, 1.5 `tinta` line, `permukaan`, `tinta` 700, no underline. Then "Contoh memuat angka negatif, Rp0 dan isian kosong supaya cara cetaknya ikut dinilai." 13 `tinta3`.
       h. Card (same frame, gap 4): "Lampiran F14" 16/700; eight lines 14 `tinta2`: "1. Uang Muka", "2. Rincian Pertanggungjawaban Uang Muka", "3. Penghitungan Persembahan", "4. Penggantian Biaya", "5. Pengecualian Dokumen Pendukung", "6. Pembalikan dan Koreksi", "7. Saldo Awal Pencatatan", "8. Hasil Pengecekan Otomatis"; then "Lampiran tanpa isi dicetak sebagai “Nihil”." 13 `tinta3`, margin-top 4.
       i. Card (same frame, gap 4): "Penanda tangan, dari pengaturan" 16/700; "Bendahara · Meiske Lumentut" 14 `tinta2`; "Ketua BPMJ · [NAMA DARI PENGATURAN]" 14 `tinta2`; "Laporan mencetak nama dan garis kosong. Tidak ada tanda tangan tiruan." 13 `tinta3`, margin-top 4.
- **Components** KartuPersetujuan (Belum card a + form → Ada record card), TombolBersyarat ("Catat persetujuan format"), ChipPilihan ("Cara"), Tombol secondary ("Lihat contoh PDF", "Lihat contoh Excel"), PitaJabatanKosong, GarisStatus (hambatan, terpilih, dibukukan). Pattern: label + text input with "· wajib".
- **Internal views and states** Initial `{ st: 'belum', nama: '', jabatan: 'Ketua BPMJ', cara: 'notulen rapat' }`. Views: Belum (form) and Ada (record), switched by `st`. Ada is final on this board (no way back except leaving the route). No sheets or toasts.
- **Tweaks** `jabatanKosong` (boolean, default false), Keadaan panel (global switch). On: strip 0 above the header. Text replacement disabled (`jk && false`): "Dicatat oleh Meiske L., 03/10/2026 11.40" stays.
- **Interactions**
  - "Pemberi persetujuan" input (`onNama`) → `nama` as typed, every keystroke.
  - "Jabatan" input (`onJabatan`) → `jabatan` as typed (may be emptied; no check).
  - Chip tap → `cara = <chip label>`.
  - "Catat persetujuan format" (`simpan`): one condition, `nama.trim()` not empty. Unmet: no effect, no refusal text. Met: `st = 'ada'`. The record shows `nama` and `jabatan` exactly as typed (not trimmed) and the chosen `cara`. Re-checked on press, so the first press after typing works.
  - Back arrow → up link to `/Lainnya`.
- **Motion** Record card a enters with `muncul` 300 ms when `st` becomes `ada`. Chip and button colour swaps are instant. Declared but unused: `isi`, `masuk`, `pudar`.
- **Links out** Back arrow ("Kembali ke Lainnya") → `/Lainnya`, up link. "Lihat contoh PDF" → `/Laporan`, push. "Lihat contoh Excel" → `/WebExcel`, push (a laptop board, as drawn). **Inbound** Lainnya.
- **Mock data** Format "Bawaan Palakat · v1", fourteen reports F01–F14; approval date 3 Oktober 2026 / 03/10/2026; recorded by Meiske L. at 03/10/2026 11.40; default Jabatan "Ketua BPMJ", default Cara "notulen rapat"; signers "Bendahara · Meiske Lumentut", "Ketua BPMJ · [NAMA DARI PENGATURAN]"; eight F14 attachments as listed.
- **Prototype-only** none. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. Open `/FormatLaporan` → `bata`-edged card "Persetujuan format: belum dicatat"; Jabatan field reads "Ketua BPMJ"; chip "notulen rapat" filled `tinta`; "Catat persetujuan format" is `garis`/`tinta3`.
  2. Pressing the button with "Pemberi persetujuan" empty or only spaces does nothing.
  3. Type "Pdt. Lidya Rondonuwu" → button turns `laut`; tap chip "surat"; tap the button once → the form is replaced by the record card (fades up): "Pemberi persetujuan: **Pdt. Lidya Rondonuwu**, Ketua BPMJ", "03/10/2026 · cara: surat".
  4. Under the record: `lautLembut` block "Syarat tutup buku “persetujuan format laporan sudah dicatat” terpenuhi.".
  5. Card "Lampiran F14" lists eight numbered lines, "1. Uang Muka" to "8. Hasil Pengecekan Otomatis", then "Lampiran tanpa isi dicetak sebagai “Nihil”.".
  6. "Lihat contoh PDF" → `/Laporan`; Back returns to `/FormatLaporan`. "Lihat contoh Excel" → `/WebExcel`.
  7. `jabatanKosong` on → strip above header; footnote still "Dicatat oleh Meiske L., 03/10/2026 11.40.".
  8. Back arrow → `/Lainnya`.
- **Notes** The not-yet-recorded card uses the hambatan line (1.5 `bata`) where KartuPersetujuan says dashed; keep the board (it is a close blocker here). The footnote rule is 1 px dashed `garisTegas`, not `putus`; copy it. "17 px" title is off-token (listed in CONVENTIONS). "[NAMA DARI PENGATURAN]" is drawn copy (the Ketua BPMJ's name is not set yet); keep it verbatim. Subtitle declares 14 then 13 px; 13 wins. No reason sentence for the unmet button (board wins); add a semantics hint "Pemberi persetujuan · wajib". With an empty Jabatan the record reads "**nama**, " with a trailing comma; that is what the board does. Placeholder colour `tinta3`.

### WebFormatLaporan — Web · Persetujuan format laporan
- **Source** `docs/design/handoff/canvas/boards/WebFormatLaporan.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebFormatLaporan`, no child routes · **Widget** `WebFormatLaporanScreen` in `lib/screens/lengkap/web_format_laporan.dart`
- **Purpose** Same as FormatLaporan, on the laptop; reached from Laporan and Pengaturan. D14, C04.
- **Shell** Standard web side nav (see WebKejadian); active item **Laporan**. Web PitaJabatanKosong banner first in main when `jabatanKosong`.
- **Layout**
  1. Title block: breadcrumb "Laporan" (14/600 `laut`); h1 "Format laporan" (26/700, margin-top 2); under it "Wajib dicatat sebelum tutup buku pertama." 14 `tinta2`.
  2. Two-column row (wrap, gap 24, top-aligned):
     - **Left** (flex 999 1 460, column gap 16): cards g, h, i exactly as FormatLaporan (body 15 instead of 16 where inherited). Here "Lihat contoh PDF" goes to `/WebPaketLaporan`.
     - **Right, aside** (flex 1 1 380, column gap 14): the Belum form (a blocker card, b Pemberi persetujuan, c Jabatan, d Cara chips, e Tanggal persetujuan row, f button) or the Ada record (a record card, b `lautLembut` block), identical to FormatLaporan.
     Side by side from about 1150 px window width; below that the aside wraps under the cards, so the form comes after the three cards.
- **Components** As FormatLaporan, plus the web side nav and web PitaJabatanKosong.
- **Internal views and states** Initial `{ st: 'belum', nama: '', jabatan: 'Ketua BPMJ', cara: 'notulen rapat' }`. Views Belum / Ada as FormatLaporan.
- **Tweaks** `jabatanKosong` (boolean, default false), Keadaan panel (global): banner and nav footer; text replacement disabled.
- **Interactions** Identical to FormatLaporan (`onNama`, `onJabatan`, chips, `simpan` with condition `nama.trim()` not empty). Breadcrumb → up link to `/WebPaketLaporan`.
- **Motion** Record card `muncul` 300 ms on save. Declared but unused: `isi`, `titik`.
- **Links out** Breadcrumb "Laporan" → `/WebPaketLaporan`, up link. "Lihat contoh PDF" → `/WebPaketLaporan`, push. "Lihat contoh Excel" → `/WebExcel`, push. Side nav as in Shell. **Inbound** WebPaketLaporan, WebPengaturan.
- **Mock data** Same as FormatLaporan.
- **Prototype-only** none. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. `/WebFormatLaporan` at 1440 → nav "Laporan" active; left column three cards starting "Bawaan Palakat · v1"; right column the `bata`-edged "Persetujuan format: belum dicatat" and the form.
  2. Type a name, click "Catat persetujuan format" once → right column shows the record card and the `lautLembut` confirmation; left column unchanged.
  3. "Lihat contoh PDF" → `/WebPaketLaporan`; "Lihat contoh Excel" → `/WebExcel`; Back returns each time.
  4. At 860 → nav collapses to "Menu"; the form sits under the "Penanda tangan, dari pengaturan" card; no horizontal scroll.
  5. `jabatanKosong` on → banner at the top of main and footer "Yanti Sumual · Operator".
- **Notes** The subtitle differs from the phone ("Wajib dicatat sebelum tutup buku pertama." vs "Wajib sebelum tutup buku pertama · contoh 3 Oktober 2026"); keep each board's text. The PDF target differs from the phone (WebPaketLaporan vs Laporan); keep each. Root text is 15/1.45 on web, so the inputs, "Catat persetujuan format", the two link-buttons, the "3 Oktober 2026" value, the confirmation block and the titles without an explicit size ("Persetujuan format: belum dicatat", "Lampiran F14", "Penanda tangan, dari pengaturan") are 15 here; the chips stay 14 (set explicitly). Phone notes apply.

### AwalIsian — 24 · Pengaturan awal: identitas dan daftar
- **Source** `docs/design/handoff/canvas/boards/AwalIsian.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 · interactive yes
- **Route** `/AwalIsian`, no child routes · **Widget** `AwalIsianScreen` in `lib/screens/lengkap/awal_isian.dart`
- **Purpose** Bendahara Jemaat, journey step 1 ("3 · Pengaturan awal dan saldo awal" → "24 · Pengaturan awal: identitas dan daftar" → "8 · Terbitkan Mata Anggaran"). Sets the church identity and the lists Kas/Bank, peruntukan and Lingkup (always separate fields, never guessed from each other), plus advances and deposits still running at the start date. "None" is recorded as none, not left empty. Publishing locks the setup; later changes go through Pengaturan and take effect from a given month (D23). The "only one peruntukan and one Lingkup" note is the one case where the two fields fill themselves (exception to D01).
- **Shell** Phone header with back, no tab bar. No `jabatanKosong` strip on this board. Root: `kertas`, `tinta`, `isi` 16/1.4.
- **Layout**
  1. Header row (padding 14/12/8, gap 8): back target 44×44 chevron, semantics "Kembali ke langkah". Title "Pengaturan awal Jemaat" (18/700); under it "Identitas, Kas/Bank, peruntukan, Lingkup" 13 `tinta2`.
  2. Scroll area: padding 8/20/20, column gap 16.
     a. Identity card (dibukukan: `permukaan`, 1 px `garis`, radius 14, padding 16, column gap 12):
        - "Nama Jemaat" label 14 `tinta2`, margin-bottom 6; input full width, min-height 48, padding 0 14, radius 12, 1 px `garisTegas`, `permukaan`; value "Jemaat Karunia".
        - "Zona waktu" 14 `tinta2`, margin-bottom 8; ChipPilihan "WIB", "WITA", "WIT" (chip style as FormatLaporan d); default "WITA".
        - Three fact rows, each space-between, gap 16, 1 px `garis` top rule, padding-top 10: "Tahun buku" 14 `tinta2` / "Mulai 1 Januari · tidak dapat diubah" 16/600 right-aligned; "Tanggal mulai pencatatan" / "15 September 2026" 600; "Bulan pertama pencatatan" / "September 2026 · dari tanggal mulai" 600 right-aligned.
     b. Five list cards in this order, each `permukaan`, 1 px `garis`, radius 14, padding 16, column gap 8, 14 px below the previous (the last also has 14 px, plus the 16 px column gap):
        - Title 16/700 and caption 13 `tinta3`.
        - Item chips (wrap): inline, min-height 44, padding 0 4 0 14, margin 0 8 8 0, radius 999, 1.5 `tinta` line, no fill (the card's `permukaan` shows), 14/600, gap 2. Each chip holds its text and, while not published, a remove button 44×44 with a 16 px cross (path `M6 6l12 12M18 6L6 18`, stroke 2.4, round caps, `tinta3`), semantics "Keluarkan {item}". Once published the chip keeps its 0 4 0 14 padding, so the text sits 4 px from the right edge; copy it.
        - The chip container is always present, also when the list is empty, so an empty list leaves two 8 px gaps (16 px) between the caption and the empty line. Each chip's 8 px bottom margin adds to the 8 px gap above the add row.
        - Empty line (only when the list is empty), 14/600: for Kas/Bank, Peruntukan, Lingkup "Belum ada. Paling sedikit satu." in `bata`; for the two running lists "Tidak ada. Dicatat sebagai tidak ada, bukan dikosongkan." in `tinta2`.
        - Add row (only while not published): input (as above, flex 1, semantics = card title, placeholder per card) plus "Tambah" secondary button (min-height 48, padding 0 16, radius 12, 1.5 `tinta` line, `permukaan`, 700); gap 8.
        Cards (title · caption · placeholder · initial items):
        1. "Kas/Bank" · "Tempat uang berada. Jangan memakai nama peruntukan atau Lingkup." · "Misalnya: Bank SulutGo ··1107" · Kas, Bank BNI ··4821
        2. "Peruntukan" · "Uang siapa, bukan untuk apa." · "Misalnya: Diakonia" · Umum Jemaat
        3. "Lingkup" · "Jemaat, Kolom, BIPRA, Komisi atau Panitia." · "Misalnya: Kolom 3" · Jemaat
        4. "Uang muka yang masih berjalan" · "Per penerima dan peruntukan, pada tanggal mulai pencatatan." · "Penerima · peruntukan · jumlah" · none
        5. "Titipan yang masih dipegang" · "Per pihak yang berhak, pada tanggal mulai pencatatan." · "Titipan untuk · jumlah" · none
     c. (only when exactly one peruntukan and one Lingkup) Dashed note, line language draf: 1.5 dashed `putus`, radius 14, padding 12/16, 14 `tinta2`: "Hanya ada satu peruntukan dan satu Lingkup. Saat mencatat, keduanya terisi sendiri dan diringkas; keduanya tetap tercatat di setiap transaksi." Visible at start.
     d. (not published) Reason line 14 `tinta2` (`alasan`, see Interactions), then TombolBersyarat "Terbitkan pengaturan awal": full width, min-height 52, radius 14, padding 0 20, centred 700; met `laut`/`diLaut`, unmet `garis`/`tinta3`.
     e. (published) Result card, terpilih: `permukaan`, 1.5 `tinta` line, radius 14, padding 16, enters with `muncul`. "Pengaturan awal diterbitkan" 16/700; "Berlaku mulai September 2026. Perubahan berikutnya dilakukan lewat Pengaturan dan berlaku mulai bulan tertentu. Yang sudah dipakai hanya dapat dinonaktifkan." 14 `tinta2`.
- **Components** ChipPilihan (Zona waktu), TombolBersyarat (Terbitkan pengaturan awal, with its reason line), Tombol secondary (Tambah), GarisStatus (dibukukan cards, draf note, terpilih result). Repeated pattern, not a component: removable item chip (text + 44×44 cross); "list card with add row".
- **Internal views and states** Initial `{ nama: 'Jemaat Karunia', zona: 'WITA', terbit: false, isi: {}, d: { kas: ['Kas', 'Bank BNI ··4821'], per: ['Umum Jemaat'], ling: ['Jemaat'], um: [], tt: [] } }` (`isi` holds the five add-row texts by key). States: editing (`terbit == false`) and published (`terbit == true`: remove buttons, add rows, reason line and button disappear; result card e shows; the name input and Zona chips stay visible but no longer change). Per card: empty / not empty. Note c: shown / hidden.
- **Tweaks** none. Keadaan panel shows only the global switches (this board has no `jabatanKosong`).
- **Interactions**
  - Nama Jemaat (`onNama`) → `nama` as typed, ignored once published.
  - Zona chip → `zona`, ignored once published.
  - Add-row input (`b.on`) → `isi[key]` as typed.
  - "Tambah" (`tambah`): does nothing when published or when the text is blank after trim. Otherwise it appends the trimmed text to that list and clears the input. Duplicates are allowed; there is no Enter-to-add.
  - Remove cross (`buang`) → removes that item by position; ignored once published. Removing the last Kas/Bank, peruntukan or Lingkup shows its `bata` empty line.
  - Reason line `alasan`, first match wins: Nama Jemaat blank after trim → "Nama Jemaat belum diisi."; any of Kas/Bank, peruntukan, Lingkup empty → "Kas/Bank, peruntukan dan Lingkup masing-masing perlu paling sedikit satu."; otherwise "Setelah diterbitkan, perubahan dilakukan lewat Pengaturan dan berlaku mulai bulan tertentu." Shown from the start (it is also the neutral warning when the form is valid).
  - "Terbitkan pengaturan awal" (`terbitkan`): condition, in order: Nama Jemaat not blank, then Kas/Bank, peruntukan and Lingkup each have at least one item, and not already published. Met → `terbit = true`. Unmet → no effect. Re-checked on press, so the first press after typing works.
  - Note c recomputes on every change: shown only when peruntukan and Lingkup each have exactly one item.
  - Back arrow → up link to `/Awal`.
- **Motion** Result card e `muncul` 300 ms when published. Items appear and disappear without animation. Declared but unused: `isi`, `masuk`, `pudar`.
- **Links out** Back arrow ("Kembali ke langkah") → `/Awal`, up link. **Inbound** Awal.
- **Mock data** Jemaat Karunia; zona WITA; tahun buku from 1 Januari; start date 15 September 2026; first month September 2026; Kas/Bank: Kas, Bank BNI ··4821; peruntukan: Umum Jemaat; Lingkup: Jemaat; advances: none; deposits: none. Example placeholders: Bank SulutGo ··1107, Diakonia, Kolom 3.
- **Prototype-only** none. Keadaan panel: no tweaks.
- **Acceptance checks**
  1. Open `/AwalIsian` → "WITA" chip filled; Kas/Bank card shows chips "Kas" and "Bank BNI ··4821" each with a cross; the two running-list cards show "Tidak ada. Dicatat sebagai tidak ada, bukan dikosongkan." in `tinta2`; dashed note visible; reason "Setelah diterbitkan, perubahan dilakukan lewat Pengaturan dan berlaku mulai bulan tertentu."; button `laut`.
  2. Remove "Umum Jemaat" → Peruntukan card shows `bata` "Belum ada. Paling sedikit satu."; dashed note disappears; reason becomes "Kas/Bank, peruntukan dan Lingkup masing-masing perlu paling sedikit satu."; button `garis`/`tinta3` and pressing it does nothing.
  3. Type "  Diakonia  " in Peruntukan, tap "Tambah" → chip "Diakonia" (trimmed), input cleared; dashed note returns.
  4. Add "Kolom 3" to Lingkup → dashed note disappears (two Lingkup).
  5. Clear Nama Jemaat → reason "Nama Jemaat belum diisi." and button unmet.
  6. With a valid form tap "Terbitkan pengaturan awal" once → crosses, add rows, reason and button disappear; card "Pengaturan awal diterbitkan" fades up; tapping "WIB" no longer changes the selection.
  7. Tapping "Tambah" with an empty input changes nothing.
  8. Back arrow → `/Awal`.
- **Notes** The reason line is always visible and is not in the "Tidak dapat dilakukan: …" form TombolBersyarat prescribes; keep the board's sentences. The list cards use `margin-bottom: 14px` inside a column with gap 16, so the gap after the last list card is 30 px. Copy it. The published state leaves the name input focusable but inert. Prefer marking it read-only in Flutter so the caret does not suggest editing (it looks the same). Placeholder colour `tinta3`.

### WebAwalIsian — Web · Pengaturan awal: identitas dan daftar
- **Source** `docs/design/handoff/canvas/boards/WebAwalIsian.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1250) · interactive yes
- **Route** `/WebAwalIsian`, no child routes · **Widget** `WebAwalIsianScreen` in `lib/screens/lengkap/web_awal_isian.dart`
- **Purpose** Same as AwalIsian, on the laptop, journey step 1.
- **Shell** Standard web side nav (see WebKejadian); active item **Pengaturan**. Footer fixed to "**Meiske L.** · Bendahara" / "Wewenang Bendahara aktif" (no `jabatanKosong` on this board, no banner).
- **Layout**
  1. Title block: breadcrumb "Pengaturan awal Jemaat" (14/600 `laut`, min-height 44, inline); h1 "Identitas dan daftar" (26/700, margin-top 2).
  2. Two-column row (wrap, gap 24, top-aligned):
     - **Left** (flex 1 1 360, column gap 16): identity card (AwalIsian a), dashed note (c, when shown), reason line + "Terbitkan pengaturan awal" (d) or the result card (e).
     - **Right** (flex 999 1 460): the five list cards (AwalIsian b), each 14 px below the previous.
     Side by side from about 1130 px window width; below that the five list cards wrap under the button, so the publish button comes before the lists.
- **Components** As AwalIsian, plus the web side nav.
- **Internal views and states** Initial state identical to AwalIsian. Same editing / published states.
- **Tweaks** none. Keadaan panel: global switches only (the nav footer ignores `jabatanKosong` here).
- **Interactions** Identical to AwalIsian. Breadcrumb → up link to `/WebAwal`.
- **Motion** Result card `muncul` 300 ms on publish. Declared but unused: `isi`, `titik`.
- **Links out** Breadcrumb "Pengaturan awal Jemaat" → `/WebAwal`, up link. Side nav as in Shell. **Inbound** WebAwal.
- **Mock data** Same as AwalIsian.
- **Prototype-only** none.
- **Acceptance checks**
  1. `/WebAwalIsian` at 1440 → nav "Pengaturan" active; h1 "Identitas dan daftar"; left column identity card, dashed note, reason, `laut` button; right column five list cards.
  2. Remove "Kas" and "Bank BNI ··4821" → Kas/Bank card shows `bata` "Belum ada. Paling sedikit satu."; reason "Kas/Bank, peruntukan dan Lingkup masing-masing perlu paling sedikit satu."; button unmet.
  3. Add "Bank SulutGo ··1107" → chip appears; button met.
  4. Click "Terbitkan pengaturan awal" → result card fades up in the left column; all crosses and add rows vanish in the right column.
  5. At 860 → "Menu" nav; the list cards follow the button; no horizontal scroll.
  6. Panel `jabatanKosong` on → nothing changes on this board.
  7. Breadcrumb → `/WebAwal`.
- **Notes** The order on narrow web (button before lists) is what the board's wrap gives; keep it. The preview is 1250 tall; at 1440×1000 the page scrolls. Root text is 15/1.45 on web, so the inputs, "Tambah", the three fact values, "Terbitkan pengaturan awal" and the result title "Pengaturan awal diterbitkan" are 15 here; the list-card titles stay 16 and the chips 14 (set explicitly). AwalIsian notes apply.

### Pengembalian — 25 · Pengembalian
- **Source** `docs/design/handoff/canvas/boards/Pengembalian.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 · interactive yes
- **Route** `/Pengembalian`, no child routes (the two kinds are chips switching in place) · **Widget** `PengembalianScreen` in `lib/screens/lengkap/pengembalian.dart`
- **Purpose** Bendahara Jemaat, journey step 3 ("25 · Pengembalian" and "Alur · Pengembalian"). A refund is recorded as a new transaction linked to the original voucher, never as a change to it. Shows D05 / RD04: money back from a supplier reduces Belanja in the month it is received. RD04 mirror: money returned to a donor is negative Pendapatan in the month it is paid out, on the same Mata Anggaran. Closed months are never reopened. The amount may not exceed the original (refusal). A reason is required with no minimum length (P12). It is saved as a Draf, not posted.
- **Shell** Phone header with back, no tab bar. Root as Kejadian; strip 0 above the header when `jabatanKosong`.
- **Layout**
  1. Header row (padding 14/12/8, gap 8): back target 44×44 chevron, semantics "Kembali ke Beranda". Title "Pengembalian" (18/700); under it "Terkait dengan transaksi asal" 13 `tinta2`.
  2. Kind chips (fixed, not scrolled): padding 0 20 6. Two ChipPilihan: "Kembali kepada donatur" (default), "Uang kembali dari pemasok". Chip style here: min-height 44, padding 0 12, margin 0 6 6 0, radius 999, 1.5 line, 13/600 (smaller than standard). Selected `tinta`/`permukaan`; unselected `permukaan`, `garisTegas` line, `tinta` text. `aria-pressed`.
  3. Scroll area: padding 8/20/20, column gap 16.
     a. Rule note, line language draf: 1.5 dashed `putus`, radius 14, padding 12/16, 14. Bold `tinta` "{atJ}", a space, `tinta2` "{atT} Bulan yang sudah ditutup tidak dibuka lagi.", a space, then inline link "Coba alurnya sampai dibukukan" 14/700 `laut`. Texts per kind in Mock data.
     b. Original voucher card, terpilih: `permukaan`, 1.5 `tinta` line, radius 14, padding 16, column gap 4. Row (space-between, centred, gap 16): badge "Dibukukan · transaksi asal" (`tinta` field, `permukaan` text, 13/700, radius 6, padding 3/9) and the No. Bukti mono 13 `tinta2`. Amount mono 26/500 `tinta`, margin-top 4 (donatur positive, pemasok negative). Uraian 16/600. "{jenis} · {Kas/Bank}" 13 `tinta3`.
     c. (after saving, for this kind) Link line plus draft card (RangkaianKoreksi):
        - Link line: 2 px wide, 20 px tall, `tinta`, 28 px from the left edge, margins −8 top and bottom, so it floats 8 px below card b and 8 px above the draft card.
        - Draft card, line language draf: 1.5 dashed `putus`, radius 16, no fill (`kertas` shows through), padding 16, column gap 4, enters with `muncul`. Badge "Draf · belum masuk saldo" (1.5 dashed `putus` line, `tinta2` text, 13/700, radius 6, padding 3/9, left-aligned). Amount mono 26/500 `tinta2`, margin-top 4: the saved amount, always positive (`rp(j)`). "{baru}" 16/600. "Terkait dengan No. Bukti {no} · {arah}" 13 `tinta3`. "Alasan: {alasan}" 14 `tinta2`.
        - Under it 14 `tinta2`: "Transaksi asal tidak diubah. Draf ini diperiksa dan dibukukan seperti transaksi lain; setelah dibukukan ia tampil sebagai angka negatif pada Mata Anggaran yang sama di bulan ini."
     d. (before saving, for this kind) Form:
        - IsianJumlah: label "Jumlah (Rp)" 14 `tinta2` followed by " · paling banyak {maks}" `tinta3` (maks "Rp500.000" or "Rp5.500.000"); the label is inline, with no margin below it. Then a row (baseline, gap 6, mono, 2 px `tinta` underline, padding-bottom 4): "Rp" mono 20 `tinta3` and the input mono 30/500 (`jumlahIsian`), transparent, no border, min-height 44, numeric keyboard, hint "0" in `tinta3`.
        - (only when the amount exceeds the original) Refusal 14/600 `bata`: "Tidak dapat dilakukan: melebihi jumlah transaksi asal."
        - IsianAlasan: label "Alasan" 14 `tinta2` + bold `tinta` " · wajib", margin-bottom 6; textarea 2 rows fixed, padding 12/14, radius 12, 1 px `garisTegas`, `permukaan`, no placeholder.
        - TombolBersyarat "Simpan sebagai draf": full width, min-height 52, radius 14, padding 0 20, centred 700; met `tinta` field / `permukaan` text; unmet `garis` / `tinta3`.
- **Components** ChipPilihan (kind, compact variant), LencanaStatus ("Dibukukan · transaksi asal" in the Dibukukan shape, "Draf · belum masuk saldo" in the Draf shape), RangkaianKoreksi (original + 2 px `tinta` link + draft, its refund use), IsianJumlah, IsianAlasan, TombolBersyarat, Penolakan-like refusal line, PitaJabatanKosong, GarisStatus (draf note and card, terpilih original).
- **Internal views and states** Initial `{ tab: 'donatur', jm: '', alasan: '', jadi: {} }` (`jm` = digits only; `jadi` = saved drafts by kind, `{ jm: number, alasan: string }`). Views per kind: form (no draft for this kind) or linked draft (draft saved). The two kinds keep their own draft: saving on donatur leaves the pemasok form open. Sub-state: refusal line shown when the amount is over the maximum.
- **Tweaks** `jabatanKosong` (boolean, default false), Keadaan panel (global switch). On: strip 0. Text replacement disabled.
- **Interactions**
  - Kind chip (`pick`) → `tab = kind`, `jm = ''`, `alasan = ''`. This runs also when the chip is already selected: tapping the selected chip empties the amount and the Alasan. A saved draft of the other kind is kept and shows again when its chip is chosen.
  - Amount input (`onJm`): keep digits only, drop leading zeros, at most 11 digits; display with dot thousands separators while typing ("500000" → "500.000"). Typing "0" alone leaves the field empty.
  - Over-limit check: amount > original (500000 or 5500000) → refusal line shows at once, button unmet.
  - Alasan textarea (`onAlasan`) → `alasan` as typed.
  - "Simpan sebagai draf" (`simpan`): conditions in order: amount > 0, amount ≤ original, `alasan.trim()` not empty. Unmet → no effect (only the over-limit case shows a sentence). Met → `jadi[tab] = { jm, alasan: trimmed }`, `jm = ''`, `alasan = ''`; the form is replaced by the link line, draft card and note. Re-checked on press from the latest input, so the first press after typing works. No undo.
  - Back arrow → up link to `/Main`.
- **Motion** Draft card `muncul` 300 ms (`ease`) when the draft block mounts: on save, and when switching from a kind that shows its form to a kind with a saved draft. When both kinds have a draft, switching between them keeps the element mounted and does not replay it: key the `Gerak` on "draft shown", not on `tab` (motion.md rule 3). The link line appears with it, without its own motion. Chip and button colour swaps are instant. Declared but unused: `isi`, `masuk`, `pudar`.
- **Links out** Back arrow ("Kembali ke Beranda") → `/Main`, up link. "Coba alurnya sampai dibukukan" → `/AlurPengembalian`, push. **Inbound** AlurPengembalian, Keputusan (D05), Main.
- **Mock data**
  - Donatur: chip "Kembali kepada donatur"; original BKU-2026-0121 · "Sumbangan donatur" · Rp500.000 · "Pendapatan 1.4.10.02.00 Sumbangan donatur · Bank BNI ··4821"; new "Pengembalian kepada donatur" · "keluar dari Bank BNI ··4821". atJ "Pengembalian kepada donatur mengurangi Pendapatan di bulan uangnya dibayarkan." atT "Dicatat sebagai Pendapatan negatif pada Mata Anggaran yang sama dan tertaut ke transaksi asal."
  - Pemasok: chip "Uang kembali dari pemasok"; original BKU-2026-0116 · "Pemeliharaan atap gedung" · −Rp5.500.000 · "Belanja 5.08.02.00 Pemeliharaan gedung · Bank BNI ··4821"; new "Uang kembali dari pemasok" · "masuk ke Bank BNI ··4821". atJ "Uang kembali dari pemasok mengurangi Belanja di bulan uangnya diterima." atT "Dicatat sebagai Belanja negatif pada Mata Anggaran yang sama dan tertaut ke transaksi asal."
- **Prototype-only** none. "Coba alurnya sampai dibukukan" is a real link to the flow board; keep it on screen. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. Open `/Pengembalian` → chip "Kembali kepada donatur" filled; original card "Dibukukan · transaksi asal", "BKU-2026-0121", amount "Rp500.000"; label "Jumlah (Rp) · paling banyak Rp500.000"; button unmet.
  2. Type "a1b50000" → field shows "150.000".
  3. Type "500001" → field "500.001", `bata` line "Tidak dapat dilakukan: melebihi jumlah transaksi asal.", button unmet; change to "200000" → line disappears.
  4. With amount "200.000" and Alasan blank or spaces → button unmet; type "Acara batal" → button `tinta`; one tap → the 2 px `tinta` link line appears (no motion) and the dashed draft card fades up: badge "Draf · belum masuk saldo", "Rp200.000", "Pengembalian kepada donatur", "Terkait dengan No. Bukti BKU-2026-0121 · keluar dari Bank BNI ··4821", "Alasan: Acara batal"; the form is gone.
  5. Tap "Uang kembali dari pemasok" → original "−Rp5.500.000", "BKU-2026-0116"; empty form with "paling banyak Rp5.500.000"; rule note changes to "Uang kembali dari pemasok mengurangi Belanja di bulan uangnya diterima."
  6. Tap "Kembali kepada donatur" again → the saved donor draft is still shown.
  7. "Coba alurnya sampai dibukukan" → `/AlurPengembalian`; Back returns.
  8. `jabatanKosong` on → strip above the header.
  9. Back arrow → `/Main`.
- **Notes** The draft amount is shown positive (as drawn) although the rule note says it will appear negative once posted; keep the board. The refusal puts the whole sentence in `bata` 600, where Penolakan prescribes `bata` for "Tidak dapat dilakukan:" and the cause in `tinta`; keep the board. The primary button is `tinta`, not `laut`; keep it. Draft card radius 16 (`kartuBesar`), not 14 (the source sets both; the last wins). No reason sentence for the other unmet conditions (board wins); add a semantics hint "Jumlah (Rp)" / "Alasan · wajib" for the first unmet one. The inline link sits inside a paragraph: give it a 44 px tall hit area without changing the line height (Tautan does this). Uraian lines inherit 16/600.

### WebPengembalian — Web · Pengembalian
- **Source** `docs/design/handoff/canvas/boards/WebPengembalian.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebPengembalian`, no child routes · **Widget** `WebPengembalianScreen` in `lib/screens/lengkap/web_pengembalian.dart`
- **Purpose** Same as Pengembalian, on the laptop, journey step 3; reached from Transaksi. D05, RD04.
- **Shell** Standard web side nav (see WebKejadian); active item **Transaksi**. Web PitaJabatanKosong banner first in main when `jabatanKosong`.
- **Layout**
  1. Title block: breadcrumb "Transaksi" (14/600 `laut`); h1 "Pengembalian" (26/700, margin-top 2). No subtitle.
  2. Rule note (Pengembalian 3a), directly under the title block (main gap 20); the link goes to `/WebAlurPengembalian`.
  3. Kind chips: wrapping row, gap 8; standard ChipPilihan (min-height 44, padding 0 14, 14/600, no margins).
  4. Two-column row (wrap, gap 24, top-aligned):
     - **Left** (flex 999 1 420, column gap 16): original voucher card (3b), and after saving the link line, draft card and note (3c).
     - **Right, aside** (flex 1 1 380, column gap 14): the form (3d) until a draft of this kind is saved; then the aside is empty.
     Side by side from about 1110 px window width; below that the form wraps under the original card.
- **Components** As Pengembalian, plus the web side nav and web PitaJabatanKosong.
- **Internal views and states** Initial `{ tab: 'donatur', jm: '', alasan: '', jadi: {} }`. Same views per kind as Pengembalian.
- **Tweaks** `jabatanKosong` (boolean, default false), Keadaan panel (global): banner and nav footer; text replacement disabled.
- **Interactions** Identical to Pengembalian (`pick`, `onJm`, `onAlasan`, `simpan`, same conditions and formatting). Breadcrumb → up link to `/WebTransaksi`.
- **Motion** Draft card `muncul` 300 ms as Pengembalian. Declared but unused: `isi`, `titik`.
- **Links out** Breadcrumb "Transaksi" → `/WebTransaksi`, up link. "Coba alurnya sampai dibukukan" → `/WebAlurPengembalian`, push. Side nav as in Shell. **Inbound** TabTransaksi, WebAlurPengembalian, WebTransaksi.
- **Mock data** Same as Pengembalian.
- **Prototype-only** none. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. `/WebPengembalian` at 1440 → nav "Transaksi" active; dashed rule note above the chips; original card left, form right.
  2. Enter "300000" and Alasan "Kelebihan bayar" on the donor kind, click "Simpan sebagai draf" → draft card appears under the original in the left column; right column becomes empty.
  3. Switch to "Uang kembali dari pemasok" → form returns on the right with "paling banyak Rp5.500.000"; original "−Rp5.500.000".
  4. Enter "6000000" on pemasok → "6.000.000" and the `bata` refusal line.
  5. "Coba alurnya sampai dibukukan" → `/WebAlurPengembalian`; breadcrumb → `/WebTransaksi`.
  6. At 860 → "Menu" nav; form under the original card; no horizontal scroll.
  7. `jabatanKosong` on → banner and footer "Yanti Sumual · Operator".
- **Notes** After saving, the right column is empty space at wide widths; that is the board. Root text is 15/1.45 on web, so the Uraian and new-transaction lines (600), the Alasan textarea and "Simpan sebagai draf" are 15 here; amounts (26, 30), "Rp" (20), badges and chips keep their explicit sizes. Phone notes apply.

### Pemberitahuan — 26 · Pemberitahuan
- **Source** `docs/design/handoff/canvas/boards/Pemberitahuan.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 · interactive yes
- **Route** `/Pemberitahuan`, no child routes · **Widget** `PemberitahuanScreen` in `lib/screens/lengkap/pemberitahuan.dart`
- **Purpose** Bendahara Jemaat, any time. The round-1 notification list, in-app only (D28, final per C06). No WhatsApp, SMS, email or lock-screen push; push arrives in round 5 (P05). Switching a type off hides it here but never hides a blocker, which stays on Beranda and in month-close readiness.
- **Shell** Phone header with back, no tab bar. Root as Kejadian; strip 0 above the header when `jabatanKosong`.
- **Layout**
  1. Header row (padding 14/12/8, gap 8): back target 44×44 chevron, semantics "Kembali ke Beranda". Title "Pemberitahuan" (18/700). No subtitle.
  2. Scroll area: padding 8/20/20, column gap 16.
     a. Note, draf line: 1.5 dashed `putus`, radius 14, padding 12/16, 14. "**Hanya di dalam aplikasi.**" then `tinta2`: "Beranda sudah memuat semuanya di “Perlu tindakan”. Ini hanya daftar di dalam aplikasi: tanpa WhatsApp, SMS, email, atau pemberitahuan ke layar kunci. Kotak Pemberitahuan untuk semua modul ada di Putaran 2, dan pemberitahuan dorong lewat Firebase Cloud Messaging di Putaran 5."
     b. Row (space-between, centred, gap 16): "Belum dibaca · {n}" (`judulBagian` 16/700) and the text button "Tandai semua dibaca" (`laut` 14/700, min-height 44, padding 0 4, right-aligned, no field).
     c. List card: `permukaan`, 1 px `garis`, radius 14, padding 0 16. Each visible notification is a full-width pressable row: top-aligned, gap 12, min-height 64, padding 12 0, 1 px `garis` top rule from the second visible row. Left: dot 10×10 circle, margin-top 6, `laut` when unread, transparent when read. Middle (fills): title 15, weight 700 unread / 500 read; under it the detail 13 `tinta3`. Right: time 13 `tinta3`, no wrap. When no type is switched on, the card holds only "Semua jenis pemberitahuan dimatikan." 14 `tinta2`, padding 18 0.
     d. "Yang ditampilkan" 16/700.
     e. Settings card: `permukaan`, 1 px `garis`, radius 14, padding 0 16. Four rows: centred, gap 12, min-height 60, 1 px `garis` top rule from the second. Left: name 15/600, under it 13 `tinta3`. Right: Sakelar. Target 56×44 (padding 6 0), track 56×32, radius 16, 1.5 `tinta` line. On: `tinta` track, `permukaan` knob at 28 px from the inner left edge. Off: `permukaan` track, `tinta` knob at 3 px. Knob 23×23 circle, 3 px from the inner top. Semantics: toggle "Pemberitahuan {name}" with pressed state.
     f. Caption 13 `tinta3`: "Mematikan pemberitahuan tidak menyembunyikan hambatan: semuanya tetap ada di Beranda dan di kesiapan tutup buku."
- **Components** Sakelar (four type switches), Tombol text button ("Tandai semua dibaca"), PitaJabatanKosong, GarisStatus (draf note, dibukukan cards). Pattern, not a component: notification row (dot, bold-when-unread title, detail, time).
- **Internal views and states** Initial `{ baca: {}, atur: { tindak: true, tempo: true, file: true, ai: false } }`. Visible rows = notifications whose type is on, in source order (n1–n4 at start; n5 hidden because "Bantuan AI" is off). "Belum dibaca · n" counts visible unread rows (4 at start). Empty state when all four types are off. No sheets, no navigation from rows.
- **Tweaks** `jabatanKosong` (boolean, default false), Keadaan panel (global switch). On: strip 0. Text replacement disabled.
- **Interactions**
  - Notification row tap (`buka`) → marks that one read: dot clears, title weight 500, count drops by one. No navigation and no un-read.
  - "Tandai semua dibaca" (`semua`) → marks all five read, including the hidden n5 (if "Bantuan AI" is switched on later, n5 appears already read). Count becomes 0.
  - Sakelar tap (`pick`) → flips that type. Rows of that type disappear or reappear at their original position; the top rule is recomputed so the first visible row has none; the count is recomputed.
  - Back arrow → up link to `/Main`.
- **Motion** Sakelar: track colour and knob position animate over 160 ms (`sentuh`, motion.md `sentuh`; the board uses CSS transitions `background .16s` and `left .16s`, easing `ease` → `AnimatedContainer` / `AnimatedPositioned` with `Curves.ease`). The knob colour (`tinta` ↔ `permukaan`) is not transitioned: it swaps at once. Rows appear, disappear and change weight instantly. Declared but unused: `isi`, `masuk`, `muncul`, `pudar`.
- **Links out** Back arrow ("Kembali ke Beranda") → `/Main`, up link. **Inbound** Keputusan (D28), Lainnya.
- **Mock data** Notifications (id · type · title · detail · time):
  1. n1 · tindak · "Oktober 2026 belum ditutup" · "1 hambatan · bulan berikutnya untuk tutup buku" · "Hari ini 08.00"
  2. n2 · file · "File Excel laporan gagal dibuat" · "Laporan resmi September 2026 · cukup dibuat lagi" · "Hari ini 07.42"
  3. n3 · tempo · "Uang muka lewat jatuh tempo" · "Retret Pemuda · sisa Rp500.000 · jatuh tempo 10/11/2026" · "11/11/2026"
  4. n4 · tindak · "1 dokumen pendukung wajib, belum ada" · "BKU-2026-0143 · Sewa sound system" · "11/11/2026"
  5. n5 · ai · "AI sedang tidak tersedia" · "Pencatatan berjalan seperti biasa" · "09/11/2026"
  Types (key · name · detail · default): tindak · "Perlu tindakan" · "Hambatan, draf, dokumen pendukung" · on; tempo · "Jatuh tempo" · "Uang muka dan titipan" · on; file · "File laporan" · "Siap diunduh atau gagal dibuat" · on; ai · "Bantuan AI" · "Tidak tersedia, batas biaya" · off.
- **Prototype-only** none. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. Open `/Pemberitahuan` → "Belum dibaca · 4"; four rows with `laut` dots and bold titles, first "Oktober 2026 belum ditutup" / "Hari ini 08.00"; "AI sedang tidak tersedia" is not listed; "Bantuan AI" switch off.
  2. Tap the row "File Excel laporan gagal dibuat" → its dot disappears, title regular, header "Belum dibaca · 3".
  3. Switch "Perlu tindakan" off → rows n1 and n4 disappear; the knob slides left over 160 ms; header "Belum dibaca · 1" (n3 only, n2 is read).
  4. Switch "Bantuan AI" on → "AI sedang tidak tersedia" appears last, unread; count +1.
  5. Tap "Tandai semua dibaca" → all dots gone, "Belum dibaca · 0".
  6. Switch all four types off → card shows only "Semua jenis pemberitahuan dimatikan."; "Belum dibaca · 0".
  7. `jabatanKosong` on → strip above the header.
  8. Back arrow → `/Main`.
- **Notes** The switches carry no "berlaku mulai …" sentence that Sakelar asks for; these are display preferences, not settings with an effective month. Keep the board. Row titles 15 px and setting names 15/600 are off-token on the phone (no 15 style); copy them. The back arrow goes to Main ("Kembali ke Beranda") though Main does not link here: the board is opened from Lainnya and Keputusan. Follow the up-link rule (`go('/Main')` when Main is not directly beneath, which is the usual case).

### WebPemberitahuan — Web · Pemberitahuan
- **Source** `docs/design/handoff/canvas/boards/WebPemberitahuan.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebPemberitahuan`, no child routes · **Widget** `WebPemberitahuanScreen` in `lib/screens/lengkap/web_pemberitahuan.dart`
- **Purpose** Same as Pemberitahuan, on the laptop; reached from Beranda. D28, C06, P05.
- **Shell** Standard web side nav (see WebKejadian); active item **Beranda**. Web PitaJabatanKosong banner first in main when `jabatanKosong`.
- **Layout**
  1. h1 "Pemberitahuan" (26/700, margin 0). No breadcrumb.
  2. Note "Hanya di dalam aplikasi." (Pemberitahuan 2a), same copy.
  3. Two-column row (wrap, gap 24, top-aligned):
     - **Left** (flex 999 1 460, column gap 12): "Belum dibaca · {n}" row with "Tandai semua dibaca" (2b), then the list card (2c).
     - **Right, aside** (flex 1 1 340, column gap 12): "Yang ditampilkan" (2d), settings card with four Sakelar rows (2e), caption (2f).
     Side by side from about 1110 px window width; below that the settings wrap under the list.
- **Components** As Pemberitahuan, plus the web side nav and web PitaJabatanKosong.
- **Internal views and states** Initial `{ baca: {}, atur: { tindak: true, tempo: true, file: true, ai: false } }`. Same derived rows, count and empty state.
- **Tweaks** `jabatanKosong` (boolean, default false), Keadaan panel (global): banner and nav footer; text replacement disabled.
- **Interactions** Identical to Pemberitahuan (`buka`, `semua`, `pick`). No back control; the side nav is the way out.
- **Motion** Sakelar track and knob 160 ms (`sentuh`). Declared but unused: `isi`, `muncul`, `titik`.
- **Links out** Side nav only (as in Shell). **Inbound** TabBeranda, WebBeranda.
- **Mock data** Same as Pemberitahuan.
- **Prototype-only** none. Keadaan panel: `jabatanKosong`.
- **Acceptance checks**
  1. `/WebPemberitahuan` at 1440 → nav "Beranda" active; list left with "Belum dibaca · 4"; switches right.
  2. Click "Uang muka lewat jatuh tempo" → dot gone, count 3.
  3. Toggle "Perlu tindakan" off → "Oktober 2026 belum ditutup" and "1 dokumen pendukung wajib, belum ada" disappear; "File Excel laporan gagal dibuat" is now first and has no top rule.
  4. Toggle all off → "Semua jenis pemberitahuan dimatikan." in the list card.
  5. At 860 → "Menu" nav; settings under the list; no horizontal scroll.
  6. `jabatanKosong` on → banner and footer "Yanti Sumual · Operator".
- **Notes** Phone notes apply. Row titles and names are 15 px, which is `isiWeb` on web.

### Masuk — 27 · Masuk dan menunggu verifikasi
- **Source** `docs/design/handoff/canvas/boards/Masuk.dc.html` · page Pelengkap (`lengkap`) · form Phone 390×844 · interactive yes
- **Route** `/Masuk`, no child routes (the three steps change in place under the logo) · **Widget** `MasukScreen` in `lib/screens/lengkap/masuk.dart`
- **Purpose** Anyone, before a post applies (journey "Anyone", step 1, compact version of "Alur · Masuk dan menghubungkan akun"). Sign-in with a phone number and a six-digit code by WhatsApp or SMS, no password (D25 revised, P01). One account for all of a person's posts (Q31). The outcome shows that an account alone grants no finance authority: authority comes only from a verified church decision (Petugas verifikasi after the BPMJ's appointment letter). A system administrator never gets Bendahara authority. Restricted access lands on its peruntukan (D26). Links to recovery (P07) and to account linking (P02).
- **Shell** none: no header, no back arrow, no tab bar, no `jabatanKosong`. Full-screen `permukaan` page over the `kertas` root.
- **Layout** Scroll area: padding 72 top, 24 sides, 24 bottom; column gap 36.
  1. Logo row (gap 12): Palakat mark 40×40 (same SVG as the web nav mark) and "palakat" 30/700, letter-spacing −0.5.
  2. **Step "email"** (phone number; the state name is historical), column gap 14:
     - h1 "Masuk" 24/700, margin-bottom 4; "Satu akun untuk semua jabatan Anda di Jemaat." 15 `tinta2`.
     - Label "Nomor ponsel" 14 `tinta2`, margin-bottom 6; input full width, min-height 48, padding 0 14, radius 12, 1 px `garisTegas`, `permukaan`, phone keyboard, autofill telephone number, placeholder "08…" (`tinta3`).
     - TombolBersyarat "Kirim kode masuk": full width, min-height 52, radius 14, centred 700; met `laut`/`diLaut`, unmet `garis`/`tinta3`.
     - "Kode enam angka dikirim ke nomor ponsel Anda lewat WhatsApp atau SMS. Tidak ada kata sandi yang perlu diingat." 13 `tinta3`.
     - Link "Tidak bisa menerima kode? Pemulihan akun" 14/700 `laut`, min-height 44, left-aligned.
     - Link "Belum terhubung dengan Data jemaat? Hubungkan akun", same style.
  3. **Step "kode"** (enters with `muncul`), column gap 14:
     - h1 "Masukkan kode" 24/700, margin-bottom 4; "Dikirim ke " 15 `tinta2` followed by the number in bold `tinta` (digits exactly as typed, no grouping).
     - Label "Kode enam angka"; input full width, min-height 60, radius 12, 1 px `garisTegas`, `permukaan`, mono 26, letter-spacing 8, centred, numeric keyboard, one-time-code autofill. Empty at start.
     - TombolBersyarat "Masuk" (same style as "Kirim kode masuk").
     - Text button "Pakai nomor lain": min-height 44, full width, centred, `laut` 700, no field.
  4. **Step "hasil"**: one of four outcomes by the tweak `setelahMasuk`, each a column gap 14 entering with `muncul`; in every outcome the h1 has margin-bottom 6 above its 15 px line:
     - **Menunggu verifikasi wewenang**: dashed ring 72×72 (viewBox 88: circle r 38, 4 px `tinta` stroke dashed 6 7, no fill, static). h1 "Menunggu verifikasi wewenang" 24/700 line-height 1.2, margin-bottom 6; "Anda sudah masuk, tetapi belum ada tindakan keuangan yang tersedia." 15. Card (`permukaan`, 1 px `garis`, radius 14, padding 14/16, gap 6), two 14 px lines: "**Mengapa:** wewenang Bendahara hanya berasal dari keputusan Jemaat yang sudah diverifikasi. Akun saja tidak memberi wewenang." and "**Yang perlu bertindak:** Petugas verifikasi, setelah BPMJ mengirim surat penunjukan Anda." Secondary link-button "Lihat langkah pengaturan awal": full width, min-height 48, radius 14, 1.5 `tinta` line, `permukaan`, `tinta` 700, centred.
     - **Bendahara**: h1 "Jemaat Karunia" 24/700; "Meiske Lumentut · Wewenang Bendahara aktif" 15. Primary link-button "Buka Beranda": full width, min-height 52, radius 14, `laut` field, `diLaut` 700, centred.
     - **Akses terbatas**: h1 "Jemaat Karunia"; "Dkn. Olga Tamba · Akses terbatas: Peruntukan Diakonia" 15. Primary link-button "Buka peruntukan Diakonia" (as "Buka Beranda").
     - **Administrator sistem**: h1 "Anda masuk sebagai administrator sistem" 24/700 line-height 1.2; "Tidak ada tindakan keuangan yang tersedia." 15. Card as above: "**Mengapa:** administrator sistem mengurus sisi teknis, dan tidak dapat bertindak sebagai Bendahara atau pemberi persetujuan. Akses teknis saja tidak pernah memberi wewenang Bendahara." and "**Yang memegang pembukuan:** Bendahara Jemaat Karunia, lewat penunjukan yang sudah diverifikasi." No button.
- **Components** TombolBersyarat ("Kirim kode masuk", "Masuk"), Tombol (primary link-buttons, secondary "Lihat langkah pengaturan awal", text "Pakai nomor lain"), Palakat logo. Pattern "Six-digit code entry" (02-components), simplified here: digits only, six long; this board has no wrong-code path.
- **Internal views and states** Initial `{ tahap: 'email', email: '', kode: '' }` (`email` holds the phone number digits). Steps: `email` → `kode` → `hasil`. `hasil` has four variants chosen by the tweak, read live (changing the tweak while on `hasil` swaps the outcome at once; on earlier steps nothing visible changes).
- **Tweaks** `setelahMasuk` (enum, default "Menunggu verifikasi wewenang"; options "Menunggu verifikasi wewenang", "Bendahara", "Akses terbatas", "Administrator sistem"), Keadaan panel. Each option selects the matching outcome in step 4. No `jabatanKosong` on this board.
- **Interactions**
  - Phone input (`onEmail`) → keep digits only, at most 13. Valid when it matches `^08\d{8,11}$` (starts with 08, 10 to 13 digits).
  - "Kirim kode masuk" (`kirim`): condition valid number. Unmet → no effect, no sentence. Met → `tahap = 'kode'` (the code field keeps its value, empty the first time). Re-checked on press, so the first press after typing works. There is no fake sending delay.
  - Code input (`onKode`) → digits only, at most 6.
  - "Masuk" (`masuk`): condition exactly 6 digits. Any six digits are accepted. Met → `tahap = 'hasil'`.
  - "Pakai nomor lain" (`ulang`) → `tahap = 'email'`, `kode = ''`; the number stays in the field.
  - No back control on any step. System Back leaves the board (steps are not routes).
- **Motion** Step "kode" and every outcome in step 4 enter with `muncul` 300 ms (fade + 8 px rise, `ease`) when shown. Changing `setelahMasuk` while on step "hasil" mounts the new outcome, so it plays `muncul` again (key on the outcome name). Step "email" has none, also when returning to it. The dashed ring does not move. Button colour swaps are instant. Declared but unused: `isi`, `masuk`, `pudar`.
- **Links out** "Tidak bisa menerima kode? Pemulihan akun" → `/Pemulihan`, push. "Belum terhubung dengan Data jemaat? Hubungkan akun" → `/AlurMasuk`, push. "Lihat langkah pengaturan awal" → `/Awal`, push. "Buka Beranda" → `/Main`, go (entering the app). "Buka peruntukan Diakonia" → `/Terbatas`, go. **Inbound** Keluar, Keputusan (D25), Pemulihan, Sambungan.
- **Mock data** Jemaat Karunia; Meiske Lumentut (Bendahara, authority active); Dkn. Olga Tamba (restricted access, Peruntukan Diakonia); actors Petugas verifikasi and BPMJ. Number and code are typed by the user (no seed).
- **Prototype-only** none on the board. The handoff's "code 123456" device is not used here: any six digits pass, so do not restrict the field to 123456. Keadaan panel: `setelahMasuk`.
- **Acceptance checks**
  1. Open `/Masuk` → white page, logo "palakat" 30 px, h1 "Masuk", "Kirim kode masuk" `garis`/`tinta3`; no header and no back arrow.
  2. Type "0812-3456-789" → field shows "08123456789"; button turns `laut`.
  3. With "0812345" the button stays unmet and pressing it does nothing; "+62812345678" becomes "62812345678" and stays unmet.
  4. Press "Kirim kode masuk" → step "Masukkan kode" fades up; "Dikirim ke **08123456789**".
  5. Type "12a34" → "1234", button unmet; type "56" → "123456", button `laut`; press → outcome "Menunggu verifikasi wewenang" with the dashed ring and "Lihat langkah pengaturan awal".
  6. From step "kode" with "123" typed, "Pakai nomor lain" → step "Masuk" with the number still filled; pressing "Kirim kode masuk" again shows an empty code field.
  7. Panel `setelahMasuk` = "Bendahara" while on the outcome → "Jemaat Karunia", "Meiske Lumentut · Wewenang Bendahara aktif", "Buka Beranda" → `/Main`.
  8. `setelahMasuk` = "Akses terbatas" → "Buka peruntukan Diakonia" → `/Terbatas`; "Administrator sistem" → no button.
  9. "Tidak bisa menerima kode? Pemulihan akun" → `/Pemulihan`; "Belum terhubung dengan Data jemaat? Hubungkan akun" → `/AlurMasuk`; Back returns to `/Masuk`.
- **Notes** h1 24 px and logo text 30 px are off-token; copy them (24 is listed in CONVENTIONS, 30 matches `jumlahIsian` size only by chance). The state and handler names say "email" but the field is a phone number since D25 was revised; the screen says "Nomor ponsel". No reason sentence for unmet buttons (board wins); semantics hint "Nomor ponsel" / "Kode enam angka". The kode step's subtitle declares 14 then 15 px; 15 wins. "Buka Beranda" and "Buka peruntukan Diakonia" use `go` because they enter the app after sign-in; Back from there should not return to the code step.

### WebMasuk — Web · Masuk dan menunggu verifikasi
- **Source** `docs/design/handoff/canvas/boards/WebMasuk.dc.html` · page Pelengkap (`lengkap`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebMasuk`, no child routes · **Widget** `WebMasukScreen` in `lib/screens/lengkap/web_masuk.dart`
- **Purpose** Same as Masuk, on the laptop. D25, P01.
- **Shell** Web side nav, signed-out variant: same column, brand and collapse behaviour as the standard nav (see WebKejadian), but one item only, "Masuk" → `/WebMasuk` (active, `tinta` field, `permukaan` text; `go`, a no-op on this page). Footer (same box) reads only "Belum masuk" 13 `tinta2`. No `jabatanKosong`.
- **Layout** Main column (standard padding and gap):
  1. Centring wrapper: fills the main column's height (the page is at least the window height), centres its child both ways, padding 40 top and bottom.
  2. Sign-in card: full width up to 440, `permukaan`, 1 px `garis`, radius 18, padding clamp(24, 4vw, 40), column gap 32. Inside, the same content as Masuk: logo row (mark 40×40, "palakat" 30/700 letter-spacing −0.5), then step "email", "kode" or "hasil" with identical copy, controls and sizes. Body text here inherits 15.
- **Components** As Masuk, plus the signed-out web side nav.
- **Internal views and states** Initial `{ tahap: 'email', email: '', kode: '' }`. Same steps and outcomes as Masuk.
- **Tweaks** `setelahMasuk` (enum, same options and default as Masuk), Keadaan panel. Same effect.
- **Interactions** Identical to Masuk (`onEmail`, `kirim`, `onKode`, `masuk`, `ulang`, same rules).
- **Motion** As Masuk: `muncul` 300 ms on step "kode" and each outcome. Declared but unused: `isi`, `titik`.
- **Links out** "Tidak bisa menerima kode? Pemulihan akun" → `/WebPemulihan`, push. "Belum terhubung dengan Data jemaat? Hubungkan akun" → `/WebAlurMasuk`, push. "Lihat langkah pengaturan awal" → `/WebAwal`, push. "Buka Beranda" → `/WebBeranda`, go. "Buka peruntukan Diakonia" → `/WebTerbatas`, go. Side nav "Masuk" → `/WebMasuk` (build it with `Tautan(ke: 'WebMasuk')` so the link test finds it). **Inbound** WebKeluar, WebPemulihan, WebSambungan.
- **Mock data** Same as Masuk.
- **Prototype-only** none; any six digits pass. Keadaan panel: `setelahMasuk`.
- **Acceptance checks**
  1. `/WebMasuk` at 1440 → nav with only "Masuk" (active) and footer "Belum masuk"; a 440-wide card centred in the main area with the logo and "Masuk".
  2. Type "081234567890" → "Kirim kode masuk" `laut`; press → "Masukkan kode" fades up in the card.
  3. Enter "654321", press "Masuk" → default outcome "Menunggu verifikasi wewenang"; "Lihat langkah pengaturan awal" → `/WebAwal`.
  4. Tweak "Bendahara" → "Buka Beranda" → `/WebBeranda`; tweak "Akses terbatas" → "Buka peruntukan Diakonia" → `/WebTerbatas`.
  5. "Tidak bisa menerima kode? Pemulihan akun" → `/WebPemulihan`; "Belum terhubung dengan Data jemaat? Hubungkan akun" → `/WebAlurMasuk`.
  6. At 860 → nav collapses to a top bar with "Menu"; opening it shows "Masuk" and "Belum masuk"; the card stays centred, at full main width up to 440, with no horizontal scroll.
- **Notes** Card radius 18 is off-token (the AI-panel radius); copy it. The card's content gap is 32 here vs 36 on the phone; keep each. Masuk notes apply.
