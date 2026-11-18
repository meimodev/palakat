# Screens 18: WartaEditor, WebWartaEditor, BukaNama, WebBukaNama, WartaArsip, WebWartaArsip, AlurDokumen, WebAlurDokumen

These eight boards are the Sekretaris Jemaat's publication work on the canvas page "Putaran 3 · Sekretariat" (`p3`), in phone/laptop pairs; the actor on every board is Olvie Pangemanan, Sekretaris Jemaat. WartaEditor/WebWartaEditor assemble the weekly Warta Jemaat edition of 22/11/2026 from data that already exists (published announcements, this week's services, the Ditetapkan attendance count, life events with names following Tampilan nama, and the finance summary of the closed month October 2026) and walk it through Draf → Sudah diperiksa → Disetujui → Diterbitkan; the laptop board adds a live preview of page 1 of the PDF, and both open the A4 page `A4Warta` ("Lihat PDF"). From the "Peristiwa jemaat" card they open BukaNama/WebBukaNama, where only the Sekretaris Jemaat can record, with a required reason, an exception that prints a member's name although the member chose "Tanpa nama". WartaArsip/WebWartaArsip are the archive of published editions (plus a linked correction, the member's reading view and the empty state); their "Susun edisi …" buttons open the editor, and the editor's back control and "Buat ralat" return to the archive. AlurDokumen/WebAlurDokumen are a typed flow, reached only from the platform map (`PetaPlatform`), that publishes a church document with its signed copy (the first upload attempt always fails once) and then publishes a correction as a new revision, with live refusals and a growing Riwayat; their back control returns to DokumenGereja/WebDokumenGereja. In every section "up link" means the phone back arrow, the web breadcrumb above the h1, and any button the section names as one: it pops when its target, or one of the target's child routes, is the route directly beneath; otherwise it does `go` to the target. Drill-ins into other boards are `push`; side-nav items are `go`. Every navigating control is built with `Tautan(ke: '<Stem>', cara: …)`: up links `Cara.naik`, drill-ins `Cara.dorong` (the default), side-nav items `Cara.ganti` (navigation.md, quick reference). When a board's own tweak (`keadaan`) is changed in the Keadaan panel, reset that board's state to its initial object (on the canvas the board's `state.k` would otherwise keep overriding the tweak). None of these boards has `jabatanKosong`, a timer, or a running animation, and none carries a prototype-only device.

---

### WartaEditor — 66 · Warta Jemaat · edisi 22/11/2026
- **Source** `docs/design/handoff/canvas/boards/WartaEditor.dc.html` · page Putaran 3 · Sekretariat (`p3`) · form Phone 390×844 · interactive yes
- **Route** `/WartaEditor`, no child routes (the five states replace each other in place under the same header) · **Widget** `WartaEditorScreen` in `lib/screens/p3/warta_editor.dart`
- **Purpose** Sekretaris Jemaat, journey step 3 ("Pengumuman", "Warta Jemaat · edisi 22/11/2026", "Alur · Warta mingguan", "A4 · Warta Jemaat edisi 22/11/2026"). The edition is composed from existing records, never retyped ("tidak diketik ulang"), and passes four statuses, each run by the Sekretaris herself and each recorded. Shows Q27 (one fixed A4 template, published as PDF and readable in the app), P17 (the announcements going into the edition come from Pengumuman), P18 (after "Sudah diperiksa" or "Disetujui" the content is locked; to change it the edition returns to Draf: "Kembali ke Draf"), and the platform rules: a module that is not active leaves no trace (state "Hanya Pengumuman yang aktif"), names in publications follow Tampilan nama (with the exception link to BukaNama), attendance is a count only ("Jumlah saja. Tidak ada nama."), only closed months feed the finance summary, and what is published never changes silently ("ralat menjadi revisi yang tertaut").
- **Shell** Phone header with back (`KepalaPonsel`, components.md 4.1 and navigation.md 1.2; each board passes its own back target and label), no tab bar. Phone root 390×844, `kertas` background, `tinta` text, `isi` 16/1.4, column: fixed header, then one scroll area. The phone primitives defined here are reused by BukaNama, WartaArsip and AlurDokumen:
  - **Header** (fixed, not scrolled): row, centre, gap 8, padding 14 top, 12 sides, 8 bottom. Back target 44×44 with chevron (path `M15 6l-6 6 6 6`, 22 px box on a 24 viewBox, stroke 2, round caps, `tinta`); its semantics label is the board's `aria-label`. Then a column (flex 1): h1 `judulLayar` 18/700, wraps if long; under it the subtitle `keterangan` 13 `tinta2` (the board writes `font-size: 14px` then `13px`; 13 wins).
  - **Scroll area**: fills the rest, vertical scroll, padding 8 top, 20 sides, 20 bottom; one inner column (not stretched in height) with gap 16 between all its children.
  - **Status badge** (LencanaStatus shape): `flex: none`, 13/700, radius 6 (`PalakatRadius.lencana`), padding 3/9, 1.5 line. Variants used in this file: `draf` 1.5 dashed `putus`, `tinta2` text, no fill; `lautg` `permukaan` field, 1.5 solid `laut`, `laut` text; `laut` `laut` field and line, `diLaut` text; `tinta` `tinta` field and line, `permukaan` text; `abu` `garis` field and line, `tinta2` text; `garis` `permukaan` field, 1.5 solid `tinta3`, `tinta2` text; `bata` `permukaan` field, 1.5 solid `bata`, `bata` text.
  - **Card** (line `dibukukan`): `permukaan`, 1 px `garis`, radius 14, padding 14/16, column gap 6. **Dashed card** (line `draf`): no fill (the `kertas` shows), 1.5 dashed `putus`, radius 14, padding 14/16, column gap 6.
  - **Button row**: row, wrap, gap 8. Every button in it: flex 1 1 150, max width 340, text centred, 16/700 (size inherited from the root), padding 0 16. Primary: min-height 52, radius 14, no line, `tinta` field, `permukaan` text. Primary-laut: same with `laut` field, `diLaut` text. Secondary: min-height 48, radius 14, 1.5 `tinta` line, `permukaan` field, `tinta` text. Text button: min-height 44, no line, no fill, `laut` text. On the 350 px content width two buttons sit side by side at 171 each; a lone button is 340 wide, left-aligned.
  - **Key–value row**: row, space-between, gap 16, 14 px; label `tinta2`; value right-aligned, weight 600, `tinta`.
- **Layout**
  1. Header: back semantics "Kembali ke Warta Jemaat"; h1 "Warta Jemaat · edisi 22/11/2026"; subtitle "Disusun dari data yang sudah ada; tidak diketik ulang".
  2. Scroll area, content per state (`keadaan`, see Internal views). The building blocks:
     a. **Edition row**: row, space-between, centre, gap 16: "Edisi 22/11/2026" 16/700, then the status badge of the state.
     b. **Section cards** (Card, `dibukukan`), each starting with a heading block: title 16/700 over a source line `keterangan` 13 `tinta3`; then body lines 14 `tinta2` (13 `tinta3` where stated):
        - **Pengumuman** / "dari Pengumuman" / "Kerja bakti halaman gereja · Pendaftaran katekisasi sidi 2027".
        - **Ibadah minggu ini** / "dari Ibadah dan kegiatan" / "Minggu 22/11/2026: Subuh 05.00 · Pagi 09.00 · Malam 18.00".
        - **Jumlah kehadiran** / "hanya yang Ditetapkan" / "Minggu 15/11/2026: 412 orang (Subuh 96 · Pagi 231 · Malam 85)" / 13 `tinta3` "Jumlah saja. Tidak ada nama."
        - **Peristiwa jemaat** / "nama mengikuti Tampilan nama" / "Syukur HUT pernikahan: " followed by bold (700) `tinta` "Keluarga Wenas-Lasut — Kolom 7" / "Sampul syukur: " followed by bold `tinta` "Tanpa nama" then ", Kolom 4" / text link "Tampilkan nama (pengecualian)": 14/700 `laut` (hover `lautTua`), underlined (browser default, the board sets no decoration), min-height 44, text vertically centred and left-aligned; the target spans the full card width (the link is a stretched item of the card column).
        - **Ringkasan keuangan** / "dari bulan yang Sudah ditutup" / key–value row "Pendapatan Oktober 2026" | "Rp14.820.000" / key–value row "Belanja Oktober 2026" | "Rp11.455.000" (values mono, weight 600, 14) / 13 `tinta3` "Dari laporan resmi Oktober 2026, ditutup 16/11/2026. Bulan yang belum ditutup tidak dapat dimasukkan."
     c. **Step lines**: plain text lines without a card (sizes per state).
     d. **Button row** per state.
- **Components** LencanaStatus (badges "Draf", "Sudah diperiksa", "Disetujui", "Diterbitkan"), GarisStatus `dibukukan` (section cards), Tombol (primary `tinta`, primary `laut` for "Terbitkan", secondary, text button), TampilanNama rule (Peristiwa card copy and exception link). Repeated pattern, not a component: section card "title / source line / content"; key–value money row.
- **Internal views and states** Initial state `{ k: null }`; the shown state is `k ?? tweak keadaan`, unknown values fall back to the first option. Five views, top to bottom inside the scroll column:
  - `Draf` (k0): edition row with badge `draf` "Draf"; the five section cards in the order above; button row: primary "Tandai sudah diperiksa", secondary "Lihat PDF" (link).
  - `Sudah diperiksa` (k1): badge `lautg` "Sudah diperiksa"; the same five cards (the exception link included); line 13 `tinta3` "Diperiksa oleh Olvie Pangemanan, 20/11/2026 14.05."; button row: primary "Setujui untuk diterbitkan", text button "Kembali ke Draf".
  - `Disetujui` (k2): badge `laut` "Disetujui"; no section cards; line 14 `tinta2` "Disetujui oleh Olvie Pangemanan, 20/11/2026 14.20."; line 13 `tinta3` "Sekretaris Jemaat menjalankan setiap langkah sendiri; tiap langkah tetap dicatat."; button row: primary-laut "Terbitkan", text button "Kembali ke Draf".
  - `Diterbitkan` (k3): badge `tinta` "Diterbitkan"; no cards; line 14 `tinta2` "Diterbitkan 21/11/2026 17.00 untuk semua anggota. Edisi ini tidak berubah lagi; ralat menjadi revisi yang tertaut."; button row: secondary "Lihat PDF" (link), secondary "Buat ralat" (link).
  - `Hanya Pengumuman yang aktif` (k4): badge `draf` "Draf"; only the Pengumuman card; line 13 `tinta3` "Bagian dari modul yang tidak aktif tidak tampil dan tidak meninggalkan tempat kosong."; button row: primary "Tandai sudah diperiksa" alone (340 wide). No "Lihat PDF".
  No sheets, toasts, banners or empty states.
- **Tweaks** `keadaan` (enum; options "Draf", "Sudah diperiksa", "Disetujui", "Diterbitkan", "Hanya Pengumuman yang aktif"; default "Draf") · Keadaan panel. Each option opens the view of the same name above; changing it resets `k` to null.
- **Interactions** (`go0`…`go3` set `k`; `go4` exists but nothing calls it)
  - "Tandai sudah diperiksa" (k0 and k4) → `k = 'Sudah diperiksa'`. From k4 this shows the full k1 view with all five cards, as the board does.
  - "Setujui untuk diterbitkan" (k1) → `k = 'Disetujui'`.
  - "Terbitkan" (k2) → `k = 'Diterbitkan'`.
  - "Kembali ke Draf" (k1, k2) → `k = 'Draf'`.
  - No typed input, no validation, no refusals, no timers. The section cards are not pressable.
- **Motion** None. The board declares `masuk`, `pudar`, `muncul` and `isi` but no element runs them: build nothing for them. State changes swap instantly.
- **Links out** Back arrow → `/WartaArsip`, up link. "Tampilkan nama (pengecualian)" (k0, k1) → `/BukaNama`, push. "Lihat PDF" (k0, k3) → `/A4Warta`, push. "Buat ralat" (k3) → `/WartaArsip`, up link. **Inbound** BerandaJabatan (row "Warta Jemaat edisi 22/11/2026"), KotakMasuk (row "Warta edisi 22/11/2026 belum diterbitkan"), BukaNama, PetaPlatform, WartaArsip. The first two are links built from row data in those boards' logic classes; the manifest's inbound list misses them (navigation.md 3.4 has the full set).
- **Mock data** Edition "Edisi 22/11/2026" (Minggu, 22 November 2026). Announcements: "Kerja bakti halaman gereja", "Pendaftaran katekisasi sidi 2027". Services Minggu 22/11/2026: Subuh 05.00, Pagi 09.00, Malam 18.00. Attendance Minggu 15/11/2026: 412 (Subuh 96, Pagi 231, Malam 85). Events: Syukur HUT pernikahan, Keluarga Wenas-Lasut — Kolom 7; Sampul syukur, Tanpa nama, Kolom 4. Finance October 2026 (closed 16/11/2026): Pendapatan Rp14.820.000, Belanja Rp11.455.000 (the same figures as A4F01 and A4Warta; share one constant). Warta prints Belanja positive ("Rp11.455.000") while A4F01 prints "−Rp11.455.000" (mock-data.md): format it here without the minus. Steps: diperiksa 20/11/2026 14.05, disetujui 20/11/2026 14.20, diterbitkan 21/11/2026 17.00, all by Olvie Pangemanan. Put the edition content in `lib/mock/` and share it with WebWartaEditor.
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/WartaEditor` → header "Warta Jemaat · edisi 22/11/2026"; badge "Draf" with a dashed `putus` line; five cards in the order Pengumuman, Ibadah minggu ini, Jumlah kehadiran, Peristiwa jemaat, Ringkasan keuangan; buttons "Tandai sudah diperiksa" and "Lihat PDF" side by side.
  2. Ringkasan keuangan shows "Rp14.820.000" and "Rp11.455.000" right-aligned in mono; Peristiwa jemaat shows "Keluarga Wenas-Lasut — Kolom 7" and "Tanpa nama" in bold `tinta`.
  3. Tap "Tandai sudah diperiksa" → badge "Sudah diperiksa" (solid `laut` line, `laut` text); "Diperiksa oleh Olvie Pangemanan, 20/11/2026 14.05." under the cards; buttons "Setujui untuk diterbitkan" and "Kembali ke Draf"; no "Lihat PDF".
  4. Tap "Setujui untuk diterbitkan" → badge "Disetujui" on a `laut` field; the cards are gone; "Disetujui oleh Olvie Pangemanan, 20/11/2026 14.20."; "Terbitkan" is a `laut` button.
  5. Tap "Terbitkan" → badge "Diterbitkan" on a `tinta` field; text "Diterbitkan 21/11/2026 17.00 untuk semua anggota. Edisi ini tidak berubah lagi; ralat menjadi revisi yang tertaut."; buttons "Lihat PDF" and "Buat ralat".
  6. From "Disetujui", tap "Kembali ke Draf" → the Draf view with all five cards.
  7. In Draf tap "Tampilkan nama (pengecualian)" → `/BukaNama`; its "Batalkan" returns to `/WartaEditor` still in Draf. In Sudah diperiksa do the same → returns still in Sudah diperiksa.
  8. Tap "Lihat PDF" → `/A4Warta`; Back returns to the same state.
  9. Panel `keadaan` = "Hanya Pengumuman yang aktif" → only the Pengumuman card, the note "Bagian dari modul yang tidak aktif tidak tampil dan tidak meninggalkan tempat kosong." and one 340 px button; tapping it shows the full Sudah diperiksa view.
  10. Back arrow → `/WartaArsip`; in Diterbitkan, "Buat ralat" → `/WartaArsip`.
- **Notes** Off-token: none beyond the shared phone header subtitle (14 then 13 → 13). Ambiguities, all kept as drawn: the exception link still shows in "Sudah diperiksa" although P18 locks the content (recording an exception does not edit the content); "Disetujui" and "Diterbitkan" hide the section cards; k4 → "Tandai sudah diperiksa" lands on a view with all modules. `A4Warta` always shows the published footer, even when opened from Draf. The logic class also builds unused helpers (`rp`, `hal`, `baris`): ignore them.

### WebWartaEditor — Web · Warta Jemaat · edisi 22/11/2026
- **Source** `docs/design/handoff/canvas/boards/WebWartaEditor.dc.html` · page Putaran 3 · Sekretariat (`p3`) · form Laptop page (preview 1440×1250) · interactive yes
- **Route** `/WebWartaEditor`, no child routes · **Widget** `WebWartaEditorScreen` in `lib/screens/p3/web_warta_editor.dart`
- **Purpose** Sekretaris Jemaat on the laptop, journey step 3. Same as WartaEditor, plus a page-1 preview that is "the same as the PDF": modules that are not active are not printed and names follow Tampilan nama (Q27, P17, P18, module-absence and display-name rules).
- **Shell** Web side nav, variant `navPlatform` with the Sekretaris footer: `NavSamping(item: navPlatform, aktif: …)` inside `HalamanWeb` (main gap 20), navigation.md 1.3, components.md 4.3–4.4 (shared by the four web boards in this file; specified once here):
  - Root: `kertas` background, `tinta` text, `isiWeb` 15/1.45; row, wrap, min-height the full window. Links `laut`, hover `lautTua`. Keyboard focus on buttons, links and inputs: 2 px solid `laut` outline, 2 px offset (give textareas the same ring).
  - Nav column: flex 1 1 220 (effectively 220 wide), padding 24/16, `permukaan`, 1 px `garis` right border, column gap 20.
  - Brand: row, centre, gap 10, padding 0 8. Palakat mark 26×26 from the board's SVG (rect x 2, y 2, 20×20, rx 6, no fill, 2 px `laut` stroke dashed 3 3; path `M12 2h4a6 6 0 0 1 6 6v8a6 6 0 0 1-6 6h-4z` filled `laut`); then "palakat" 18/700 line-height 1.1 over "Jemaat Karunia" 13 `tinta3`.
  - Items, exactly, in order: Beranda → `/WebBerandaJabatan`, Keuangan → `/WebBeranda`, Dokumen gereja → `/WebDokumenGereja`, Pengumuman → `/WebPengumuman`, Warta Jemaat → `/WebWartaArsip`, Data jemaat → `/WebDataAnggota`, Ibadah dan kegiatan → `/Ibadah`, Panitia → `/Panitia`, Pemberitahuan → `/WebKotakMasuk`, Pengaturan → `/WebPenugasan`. Each min-height 44, padding 0 12, radius 10, 15/600, no underline, text vertically centred. Active: `tinta` field, `permukaan` text; others transparent, `tinta` text. All `go`. ("Ibadah dan kegiatan" and "Panitia" open phone boards, as on the canvas.)
  - Footer: margin-top auto, padding 12/8/0, 1 px `garis` top rule, 13 `tinta2`: "**Olvie Pangemanan** · Sekretaris Jemaat" (name bold, `tinta`), one line. No other footer variant.
  - At 860 px and below the nav becomes a top bar (row, wrap, centre, padding 8/16, gap 0/12, no right border, 1 px `garis` bottom border) with a toggle pushed to the right: min-height 44, padding 0 16, radius 14, 1.5 `tinta` line, `permukaan`, 14/700, label "Menu"; when open: `tinta` field, `permukaan` text, label "Tutup menu", and the items (padding 8/0) and footer (no top margin, padding-bottom 8) show full width below the brand. Closed: items and footer hidden.
  - Main column: flex 999 1 560, min-width 0, padding 28 top, clamp(16, 3vw, 40) sides, 40 bottom, column gap 20.
  - Title block: breadcrumb link 14/600 `laut`, underlined (browser default); h1 `judulHalaman` 26/700, margin-top 2; subtitle 14 `tinta2`.
  - On this board the active item is **Warta Jemaat** (`aktif: 4`).
- **Layout**
  1. Title block: breadcrumb "Warta Jemaat"; h1 "Warta Jemaat · edisi 22/11/2026"; subtitle "Disusun dari data yang sudah ada; tidak diketik ulang".
  2. Row: wrap, gap 24, items aligned to the top.
     a. Left column (flex 1 1 520, min-width 0, max width 880, column gap 16): exactly the five state views of WartaEditor (edition row, section cards, step lines, button rows; same copy, colours, radii and spacing) at web body size: titles and buttons 15/700, the Ringkasan values mono 14/600, cards and buttons as on the phone (buttons max 340 each).
     b. Right, aside (flex 1 1 300, min-width 0, max width 480, column gap 10):
        - Header row: space-between, centre, gap 16: h2 "Pratinjau halaman 1" 16/700; then badge `draf` "Belum diterbitkan" in every state except Diterbitkan, where it is badge `tinta` "Diterbitkan".
        - Page: `permukaan`, 1 px `garisTegas` line, no radius, aspect ratio 210:297, padding 28 top/bottom and 26 sides, column gap 14, content clipped. Text `tinta`:
          - Masthead, centred: "WARTA JEMAAT" 18/700, letter-spacing 0.5; "GMIM Jemaat Karunia · Minggu, 22 November 2026" (board 12 px → 13).
          - Sections, each a heading then body. Heading: 700, letter-spacing 0.4, upper-case (render the string upper-cased), 1 px `tinta` bottom rule, padding-bottom 2, margin-bottom 4 (board 12 px → 13). Body: board 12 px → 13, `tinta`.
          - "Pengumuman": "Kerja bakti halaman gereja, Sabtu 21/11/2026." line break "Pendaftaran katekisasi sidi 2027 dibuka." (always shown)
          - Only when not "Hanya Pengumuman yang aktif" (`lengkap`): "Ibadah minggu ini": "Subuh 05.00 · Pagi 09.00 · Malam 18.00"; "Jumlah kehadiran 15/11/2026": "412 orang: Subuh 96 · Pagi 231 · Malam 85"; "Peristiwa jemaat": "Syukur HUT pernikahan: Keluarga Wenas-Lasut — Kolom 7" line break "Sampul syukur: Tanpa nama, Kolom 4"; "Ringkasan keuangan Oktober 2026": two rows, space-between, gap 16: "Pendapatan" | mono "Rp14.820.000"; "Belanja" | mono "Rp11.455.000".
        - Caption 13 `tinta3`: "Yang tampil di sini sama dengan PDF: bagian dari modul yang tidak aktif tidak dicetak, dan nama mengikuti Tampilan nama."
     At 1440 the columns are about 668 and 448 wide; at 1280 about 589 and 370. The two need 844 of content width (520 + 24 + 300): below a window width of about 1133 (side nav present) and at every width of 860 and below, the aside wraps under the left column (up to 480 wide, left-aligned). Just above 1133 the aside is about 300 wide.
- **Components** As WartaEditor, plus a second badge in the aside. Shared: web side nav. Pattern, not a component: the miniature A4 page (aspect-ratio box with section headings).
- **Internal views and states** Initial state `{ k: null }`; same five views as WartaEditor in the left column. The aside always shows; it derives `lengkap` = state ≠ "Hanya Pengumuman yang aktif" and `belum` = state ≠ "Diterbitkan". In "Disetujui" the preview still shows all sections although the left column shows no cards.
- **Tweaks** `keadaan` (enum; options "Draf", "Sudah diperiksa", "Disetujui", "Diterbitkan", "Hanya Pengumuman yang aktif"; default "Draf") · Keadaan panel. Changes the left column as in WartaEditor; "Diterbitkan" also swaps the aside badge to "Diterbitkan"; "Hanya Pengumuman yang aktif" leaves only the Pengumuman section in the preview. Changing it resets `k`.
- **Interactions** Same handlers as WartaEditor ("Tandai sudah diperiksa", "Setujui untuk diterbitkan", "Terbitkan", "Kembali ke Draf"), each also updating the aside. Toggle "Menu"/"Tutup menu" below 860 px. No typed input, no timers.
- **Motion** None. Keyframes `muncul`, `isi`, `titik` are declared but unused.
- **Links out** Breadcrumb "Warta Jemaat" → `/WebWartaArsip`, up link. "Tampilkan nama (pengecualian)" → `/WebBukaNama`, push. "Lihat PDF" → `/A4Warta`, push. "Buat ralat" → `/WebWartaArsip`, up link. Side nav as in Shell (go). **Inbound** PetaPlatform, WebBerandaJabatan (row "Warta Jemaat edisi 22/11/2026"), WebKotakMasuk (row "Warta edisi 22/11/2026 belum diterbitkan"), WebBukaNama, WebWartaArsip. The two row links are built in those boards' logic classes and are missing from the manifest's inbound list (navigation.md 3.4).
- **Mock data** Same edition content as WartaEditor (shared constants). Preview-only wording: "Kerja bakti halaman gereja, Sabtu 21/11/2026.", "Pendaftaran katekisasi sidi 2027 dibuka.", "GMIM Jemaat Karunia · Minggu, 22 November 2026", "412 orang: Subuh 96 · Pagi 231 · Malam 85".
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. `/WebWartaEditor` at 1440 → side nav "Warta Jemaat" filled `tinta`; footer "Olvie Pangemanan · Sekretaris Jemaat"; left column in Draf; aside header "Pratinjau halaman 1" with badge "Belum diterbitkan" (dashed).
  2. The preview page has a 1 px `garisTegas` line, A4 proportions, masthead "WARTA JEMAAT" and five sections headed "PENGUMUMAN", "IBADAH MINGGU INI", "JUMLAH KEHADIRAN 15/11/2026", "PERISTIWA JEMAAT", "RINGKASAN KEUANGAN OKTOBER 2026", each with a `tinta` rule under the heading; no preview text is smaller than 13.
  3. Click "Tandai sudah diperiksa", "Setujui untuk diterbitkan", "Terbitkan" in turn → the left column goes through the three views as on the phone; after "Terbitkan" the aside badge reads "Diterbitkan" on a `tinta` field.
  4. Panel `keadaan` = "Hanya Pengumuman yang aktif" → left shows only the Pengumuman card and the note; the preview shows only "PENGUMUMAN"; the badge still reads "Belum diterbitkan".
  5. Click "Tampilkan nama (pengecualian)" → `/WebBukaNama`; its breadcrumb "Warta Jemaat" returns here with the same state.
  6. Click the breadcrumb "Warta Jemaat" → `/WebWartaArsip`.
  7. At 860 px wide → top bar with "Menu"; the aside sits below the left column; no horizontal page scroll. Click "Menu" → label "Tutup menu", ten items listed.
- **Notes** The preview uses 12 px text in 11 places (masthead subtitle, five section headings, five section bodies, rows included): render them at 13 as CONVENTIONS requires. At 13 the content still fits the A4 box at 1440 and 1280 wide; where the aside is narrower (about 300 px near 1130 wide) the page clips its bottom, as the board's `overflow: hidden` does at 12 px too: keep the clipping, do not let the box grow. CONVENTIONS lists #C9DAD9 as an illustration colour "in A4Warta and WebWartaEditor": this board does not use it (it occurs only in Cari and WebCari), so nothing to keep here. The preview's section order (Pengumuman first) differs from the A4Warta page (Ibadah first): keep each board's own order.

### BukaNama — 67 · Tampilkan nama (pengecualian)
- **Source** `docs/design/handoff/canvas/boards/BukaNama.dc.html` · page Putaran 3 · Sekretariat (`p3`) · form Phone 390×844 · interactive yes
- **Route** `/BukaNama`, no child routes · **Widget** `BukaNamaScreen` in `lib/screens/p3/buka_nama.dart`
- **Purpose** Sekretaris Jemaat, journey step 4 ("Tampilkan nama (pengecualian)"). A member of Kolom 4 chose "Tanpa nama"; the edition of 22/11/2026 will print "Kel. Mamahit — Kolom 4" because a church decision requires it. Shows the TampilanNama rules (the member's choice must be followed; only the Sekretaris Jemaat may show a name as an exception, with a reason, recorded in Riwayat; the change applies to this edition only), P12 (a required reason must not be blank), IsianAlasan (the action is unavailable until the reason is filled), and Penolakan for a post without the authority.
- **Shell** Phone header with back, no tab bar (WartaEditor Shell primitives).
- **Layout**
  1. Header: back semantics "Kembali ke Warta Jemaat"; h1 "Tampilkan nama (pengecualian)"; subtitle "Hanya Sekretaris Jemaat, dengan alasan, dan tercatat".
  2. Scroll area (column gap 16), content per state:
     a. **Summary card** (Card `dibukukan`; states Mengisi alasan and Alasan belum diisi): key–value rows "Edisi" | "Warta Jemaat 22/11/2026"; "Pilihan anggota" | "Tanpa nama"; "Akan diterbitkan sebagai" | "Kel. Mamahit — Kolom 4"; then 13 `tinta3` "Tampilan nama pilihan anggota wajib diikuti. Pengecualian hanya untuk keperluan resmi, tata kelola, hukum atau pertanggungjawaban."
     b. **Reason field** (IsianAlasan): column, gap 6, 14 `tinta2`: label "Alasan · wajib"; textarea, read-only, 3 rows, full width, min-height 96, padding 12/14, radius 12, 1 px `garisTegas` line, `permukaan` field, no resize; its text inherits 14 `tinta2` from the label. Semantics label "Alasan · wajib".
     c. **Button row**: primary "Catat pengecualian" (or its disabled form: `garis` field, `tinta2` text, not pressable) and text button "Batalkan" (a link, no underline).
     d. **Disabled reason** (state Alasan belum diisi only), below the button row: 13 `tinta3` "Tidak dapat dilakukan: alasan belum diisi."
     e. **Record card** (Card `dibukukan`; state Tercatat): header row space-between, centre, gap 16: "Pengecualian tampilan nama" 16/700 + badge `tinta` "Tercatat"; key–value rows "Pilihan anggota" | "Tanpa nama"; "Diterbitkan sebagai" | "Kel. Mamahit — Kolom 4"; "Edisi" | "Warta Jemaat 22/11/2026"; line 14 `tinta2` "Alasan: persembahan khusus pembangunan diumumkan atas keputusan Sidang Majelis Jemaat 08/11/2026."; line 13 `tinta3` "Oleh Olvie Pangemanan, Sekretaris Jemaat · 20/11/2026 13.50 · anggota sudah diberi tahu." After the card, 13 `tinta3` "Pilihan anggota di Data jemaat tidak berubah. Edisi berikutnya kembali memakai “Tanpa nama”."
     f. **Refusal** (state Bukan Sekretaris Jemaat; Penolakan): one 15 px paragraph: bold (700) `bata` "Tidak dapat dilakukan: Tampilkan nama." then a space and `tinta` "hanya Sekretaris Jemaat yang dapat mencatat pengecualian tampilan nama." Then a button row with secondary "Kembali" (a link, no underline), 340 wide.
- **Components** IsianAlasan (reason textarea), Tombol (primary, disabled primary, text, secondary), LencanaStatus shape ("Tercatat", `tinta`), Penolakan (refusal sentence with "Kembali"), GarisStatus `dibukukan` (summary and record cards), TampilanNama rule (copy). Pattern: key–value rows.
- **Internal views and states** Initial state `{ k: null }`; shown state `k ?? tweak keadaan`. `form` = state is Mengisi alasan or Alasan belum diisi.
  - `Mengisi alasan` (k0): a; b with the text "Persembahan khusus pembangunan diumumkan atas keputusan Sidang Majelis Jemaat 08/11/2026."; c with "Catat pengecualian" enabled (primary `tinta`) and "Batalkan".
  - `Alasan belum diisi` (k1): a; b empty; c with "Catat pengecualian" disabled and "Batalkan"; d.
  - `Tercatat` (k2): e only.
  - `Bukan Sekretaris Jemaat` (k3): f only.
  No sheets, toasts or banners.
- **Tweaks** `keadaan` (enum; options "Mengisi alasan", "Alasan belum diisi", "Tercatat", "Bukan Sekretaris Jemaat"; default "Mengisi alasan") · Keadaan panel. Each option opens the view of the same name; changing it resets `k`.
- **Interactions** "Catat pengecualian" (k0) → `k = 'Tercatat'` (`go2`). The disabled button in k1 does nothing and takes no focus. The textarea is read-only in both states: no typing, so k0 and k1 are reached only from the panel. No timers.
- **Motion** None. Keyframes `isi`, `masuk`, `muncul`, `pudar` declared, unused.
- **Links out** Back arrow, "Batalkan" (k0, k1) and "Kembali" (k3) → `/WartaEditor`, up links. **Inbound** PetaPlatform, WartaEditor.
- **Mock data** Edition "Warta Jemaat 22/11/2026"; member choice "Tanpa nama"; published as "Kel. Mamahit — Kolom 4"; reason "Persembahan khusus pembangunan diumumkan atas keputusan Sidang Majelis Jemaat 08/11/2026." (record line starts lower-case "persembahan …"); recorded by Olvie Pangemanan, Sekretaris Jemaat, 20/11/2026 13.50; Sidang Majelis Jemaat 08/11/2026. Share with WebBukaNama.
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/BukaNama` → summary card with "Akan diterbitkan sebagai" | "Kel. Mamahit — Kolom 4"; textarea "Alasan · wajib" holding the reason; "Catat pengecualian" filled `tinta`; "Batalkan" in `laut`.
  2. The textarea cannot be edited.
  3. Tap "Catat pengecualian" → the summary and form disappear; card "Pengecualian tampilan nama" with badge "Tercatat" on `tinta`; line "Oleh Olvie Pangemanan, Sekretaris Jemaat · 20/11/2026 13.50 · anggota sudah diberi tahu."; note ending "kembali memakai “Tanpa nama”." with curly quotes.
  4. Panel `keadaan` = "Alasan belum diisi" → empty textarea; "Catat pengecualian" on a `garis` field with `tinta2` text, pressing does nothing; "Tidak dapat dilakukan: alasan belum diisi." below the buttons.
  5. Panel `keadaan` = "Bukan Sekretaris Jemaat" → "Tidak dapat dilakukan: Tampilkan nama." bold in `bata`, followed by "hanya Sekretaris Jemaat yang dapat mencatat pengecualian tampilan nama."; a "Kembali" secondary button; no form.
  6. Tap "Batalkan" (opened from WartaEditor) → pops to `/WartaEditor` in its previous state; open `/BukaNama` directly and tap "Kembali" (k3) → `go` to `/WartaEditor`.
  7. Back arrow → `/WartaEditor`.
- **Notes** Off-token: the refusal paragraph is 15 px on a phone (the web body size): copy it. The disabled reason sits below the buttons in `tinta3`, not above them in the Penolakan form "Tidak dapat dilakukan: ‹tindakan›." that TombolBersyarat prescribes: keep the board. The read-only textarea is the board's choice; do not make it editable (it would invent a k0/k1 switch the board does not have). The Tercatat view has no button; only the back arrow leaves it.

### WebBukaNama — Web · Tampilkan nama (pengecualian)
- **Source** `docs/design/handoff/canvas/boards/WebBukaNama.dc.html` · page Putaran 3 · Sekretariat (`p3`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebBukaNama`, no child routes · **Widget** `WebBukaNamaScreen` in `lib/screens/p3/web_buka_nama.dart`
- **Purpose** Sekretaris Jemaat on the laptop, journey step 4. Same as BukaNama.
- **Shell** Web side nav `navPlatform` (WebWartaEditor Shell); active item **Warta Jemaat** (`aktif: 4`). The footer reads "Olvie Pangemanan · Sekretaris Jemaat" in every state, including "Bukan Sekretaris Jemaat".
- **Layout**
  1. Title block: breadcrumb "Warta Jemaat" (goes to the editor, not to the archive); h1 "Tampilkan nama (pengecualian)"; subtitle "Hanya Sekretaris Jemaat, dengan alasan, dan tercatat".
  2. Container: max width 1120, column gap 16.
     a. Two-column row: wrap, row gap 20, column gap 28, items aligned to the top. Left (flex 1.3 1 420, min-width 0, column gap 12): the summary card (BukaNama 2a) in states k0 and k1. Right (flex 1 1 340, min-width 0, column gap 12): reason field, button row, and (k1) disabled reason, as BukaNama 2b–2d. At 1440 the columns are about 608 and 484 wide (the two buttons about 238 each); at 860 they still sit side by side (about 431 and 349); below a content width of 788 the right column wraps under the left. With the side nav beside the content that happens for windows from 861 to about 1072 px; without it (860 and below) below about 839 px.
     b. Below the row (k2): record card and note as BukaNama 2e, full container width.
     c. Below the row (k3): refusal paragraph (15 px, the web body size) and the "Kembali" button row as BukaNama 2f.
     All copy, colours, radii and paddings as BukaNama, at web body size 15 (card titles and buttons 15/700; key–value rows and textarea 14).
- **Components** As BukaNama. Shared: web side nav.
- **Internal views and states** Initial state `{ k: null }`; the same four views as BukaNama. In k2 and k3 the two-column row is empty (zero height) but still takes its place in the container, so the content starts 16 px below the top of the container: keep that 16 px.
- **Tweaks** `keadaan` (enum; options "Mengisi alasan", "Alasan belum diisi", "Tercatat", "Bukan Sekretaris Jemaat"; default "Mengisi alasan") · Keadaan panel. As BukaNama.
- **Interactions** "Catat pengecualian" (k0) → `k = 'Tercatat'`. Disabled button inert. Textarea read-only. Toggle "Menu" below 860 px. No timers.
- **Motion** None. Keyframes `isi`, `muncul`, `titik` declared, unused.
- **Links out** Breadcrumb "Warta Jemaat", "Batalkan" (k0, k1) and "Kembali" (k3) → `/WebWartaEditor`, up links. Side nav (go) as in WebWartaEditor Shell. **Inbound** PetaPlatform, WebWartaEditor.
- **Mock data** Same as BukaNama (shared constants).
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. `/WebBukaNama` at 1440 → side nav "Warta Jemaat" filled; summary card on the left, reason textarea and "Catat pengecualian" / "Batalkan" on the right.
  2. Click "Catat pengecualian" → both columns empty out; the record card "Pengecualian tampilan nama" with "Tercatat" spans the container below them.
  3. Panel `keadaan` = "Alasan belum diisi" → empty textarea, disabled button, "Tidak dapat dilakukan: alasan belum diisi." under the buttons in the right column.
  4. Panel `keadaan` = "Bukan Sekretaris Jemaat" → refusal sentence and "Kembali"; footer still names Olvie Pangemanan.
  5. Click the breadcrumb "Warta Jemaat" → `/WebWartaEditor`.
  6. At 860 px → "Menu" top bar; the two columns still side by side; no horizontal scroll. At 700 px and at 1000 px (side nav visible) → the right column sits under the summary card.
- **Notes** The breadcrumb label "Warta Jemaat" names the module but targets the editor; the side-nav item of the same name targets the archive. Keep both as drawn. The footer contradicts the "Bukan Sekretaris Jemaat" state: keep it.

### WartaArsip — 68 · Warta Jemaat
- **Source** `docs/design/handoff/canvas/boards/WartaArsip.dc.html` · page Putaran 3 · Sekretariat (`p3`) · form Phone 390×844 · interactive yes
- **Route** `/WartaArsip`, no child routes · **Widget** `WartaArsipScreen` in `lib/screens/p3/warta_arsip.dart`
- **Purpose** Sekretaris Jemaat (journey step 3) and Anggota jemaat (journey step 3, "Warta Jemaat"). The list of published editions, each kept exactly as published; a correction is a separate, linked revision and the original stays as it was; names stay as each member chose at publication time, so moving Kolom or changing the choice later does not change old editions (TampilanNama). Shows Q27 (the edition readable in the app), P03 (a member, verified or not, can read Warta Jemaat), and the platform rule that what is published never changes silently.
- **Shell** Phone header with back, no tab bar (WartaEditor Shell primitives).
- **Layout**
  1. Header: back semantics "Kembali ke Beranda"; h1 "Warta Jemaat"; subtitle "Edisi yang sudah diterbitkan, persis seperti saat diterbitkan".
  2. Scroll area (column gap 16), content per state:
     a. **Edition rows** (states Arsip edisi and Dibaca anggota jemaat): four separate row cards, 16 apart. Each: `permukaan`, 1 px `garis`, radius 14, padding 12/16, min-height 44, row, centre, gap 12, `tinta` text, no underline. Left column (flex 1, min-width 0, gap 2): edition 16/600 over a line 13 `tinta3`. Then the status badge. Then a chevron 18 px (path `M9 6l6 6-6 6`, stroke `tinta3` 2, round caps). Rows, in order:
        1. "Edisi 15/11/2026" · "Diterbitkan 14/11/2026 17.00" · badge `tinta` "Diterbitkan"
        2. "Edisi 08/11/2026" · "Diterbitkan 07/11/2026 · 1 ralat" · badge `tinta` "Diterbitkan"
        3. "Edisi 01/11/2026" · "Diterbitkan 31/10/2026" · badge `abu` "Diarsipkan"
        4. "Edisi 25/10/2026" · "Diterbitkan 24/10/2026" · badge `abu` "Diarsipkan"
     b. **Compose button** (state Arsip edisi): button row with primary "Susun edisi 22/11/2026" (a link, no underline), 340 wide.
     c. **Member note** (state Dibaca anggota jemaat): 13 `tinta3` "Anggota membaca edisi yang ditujukan untuknya. Nama tampil sesuai pilihan tiap anggota saat edisi itu diterbitkan; pindah Kolom atau mengubah pilihan kemudian tidak mengubah edisi lama."
     d. **Edition with correction** (state Edisi dengan ralat):
        - Card (`dibukukan`): header row "Edisi 08/11/2026" 16/700 + badge `tinta` "Diterbitkan"; line 14 `tinta2` "Diterbitkan 07/11/2026 17.00 · tidak diubah"; button row with secondary "Unduh PDF" (a `<button>`, flex 1 1 150, max 340; inside the card's 316 px inner width it fills the card, 316 wide).
        - Dashed card (`draf`): header row "Ralat (revisi edisi 08/11/2026)" 16/700 + badge `tinta` "Diterbitkan"; line 14 `tinta2` "Jadwal ibadah Kolom 5 dipindah ke Kamis 12/11/2026."; line 13 `tinta3` "Tertaut ke edisi asli, yang tetap tampil apa adanya. Diterbitkan 09/11/2026 08.30 oleh Olvie Pangemanan."
     e. **Empty state** (state Belum ada edisi): dashed card (`draf`): "Belum ada edisi yang diterbitkan" 16/700; 14 `tinta2` "Edisi pertama dapat disusun dari pengumuman yang sudah diterbitkan." Then button row with primary "Susun edisi pertama" (a link), 340 wide.
- **Components** LencanaStatus shapes ("Diterbitkan" `tinta`, "Diarsipkan" `abu` = the "Dibatalkan" shape), GarisStatus `dibukukan` (rows, edition card) and `draf` (correction card, empty state), Tombol (primary links, secondary "Unduh PDF"). Pattern, not a component: chevron list row card.
- **Internal views and states** Initial state `{ k: null }`; shown state `k ?? tweak keadaan`; `daftar` = state is Arsip edisi or Dibaca anggota jemaat.
  - `Arsip edisi` (k0): a + b.
  - `Edisi dengan ralat` (k1): d.
  - `Dibaca anggota jemaat` (k2): a + c (no compose button).
  - `Belum ada edisi` (k3): e.
- **Tweaks** `keadaan` (enum; options "Arsip edisi", "Edisi dengan ralat", "Dibaca anggota jemaat", "Belum ada edisi"; default "Arsip edisi") · Keadaan panel. Each option opens the view of the same name; changing it resets `k`.
- **Interactions**
  - "Unduh PDF" (k1) → `go1`, which sets `k = 'Edisi dengan ralat'`, the state already shown: nothing visible happens. Build it as a no-op press (nothing is downloaded, D07).
  - Edition rows (k0, k2) → each row's link points to this same board (`WartaArsip.dc.html`): on the canvas it reloads the board unchanged. Build each row as a pressable 44+ px target whose press does nothing; do not push a duplicate route. They are not in the manifest links (navigation.md kind **self**: `Tautan(ke: 'WartaArsip')` does nothing on the current board, so it may be used).
  - No typed input, no timers.
- **Motion** None. Keyframes `isi`, `masuk`, `muncul`, `pudar` declared, unused.
- **Links out** Back arrow → `/BerandaJabatan`, up link. "Susun edisi 22/11/2026" (k0) and "Susun edisi pertama" (k3) → `/WartaEditor`, push. **Inbound** AlurMasuk, AlurWarta, BerandaJabatan (row "Warta Jemaat edisi 15/11/2026", built in its logic class and missing from the manifest's inbound list; navigation.md 3.4), PetaPlatform, WartaEditor.
- **Mock data** Editions: 15/11/2026 (published 14/11/2026 17.00, Diterbitkan); 08/11/2026 (published 07/11/2026 17.00, 1 ralat, Diterbitkan); 01/11/2026 (published 31/10/2026, Diarsipkan); 25/10/2026 (published 24/10/2026, Diarsipkan). Correction of 08/11/2026: "Jadwal ibadah Kolom 5 dipindah ke Kamis 12/11/2026.", published 09/11/2026 08.30 by Olvie Pangemanan. Next edition to compose: 22/11/2026. Share with WebWartaArsip.
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/WartaArsip` → four row cards in the order 15/11, 08/11, 01/11, 25/10; the first two with "Diterbitkan" on `tinta`, the last two with "Diarsipkan" on `garis`; row 2 reads "Diterbitkan 07/11/2026 · 1 ralat"; button "Susun edisi 22/11/2026" below.
  2. Tap a row → nothing changes and no route is pushed.
  3. Tap "Susun edisi 22/11/2026" → `/WartaEditor`; its back arrow pops back here.
  4. Panel `keadaan` = "Edisi dengan ralat" → solid card "Edisi 08/11/2026" with "Unduh PDF", then a dashed card "Ralat (revisi edisi 08/11/2026)" with badge "Diterbitkan"; tapping "Unduh PDF" changes nothing.
  5. Panel `keadaan` = "Dibaca anggota jemaat" → the four rows and the member note; no compose button.
  6. Panel `keadaan` = "Belum ada edisi" → dashed card "Belum ada edisi yang diterbitkan" and "Susun edisi pertama", which opens `/WartaEditor`.
  7. Back arrow → `/BerandaJabatan`.
- **Notes** The correction card uses the dashed `draf` line while its badge says "Diterbitkan" (the line language reserves dashed for what can still change): keep the board. The badge `abu` ("Diarsipkan") has a 1.5 `garis` line on a `garis` field, so it reads as a flat field.

### WebWartaArsip — Web · Warta Jemaat
- **Source** `docs/design/handoff/canvas/boards/WebWartaArsip.dc.html` · page Putaran 3 · Sekretariat (`p3`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebWartaArsip`, no child routes · **Widget** `WebWartaArsipScreen` in `lib/screens/p3/web_warta_arsip.dart`
- **Purpose** Sekretaris Jemaat on the laptop, journey step 3; the landing page of the side-nav item "Warta Jemaat" on every web board with the `navPlatform` side nav (30 boards, rounds 2 to 5). Same as WartaArsip.
- **Shell** Web side nav `navPlatform` (WebWartaEditor Shell); active item **Warta Jemaat** (`aktif: 4`, a self link here).
- **Layout**
  1. Title block: breadcrumb "Beranda"; h1 "Warta Jemaat"; subtitle "Edisi yang sudah diterbitkan, persis seperti saat diterbitkan".
  2. Container: max width 880, column gap 16.
     a. **Edition table** (states Arsip edisi and Dibaca anggota jemaat): one card, `permukaan`, 1 px `garis`, radius 14, clipped. Four rows, rules between rows only (the board hides the first row's top rule under the card edge). Each row: grid of three columns (flexible, auto, 20 px), gap 16, centre, min-height 52, padding 8/18, 1 px `garis` top rule, `tinta` text, no underline. Column 1: wrap row, baseline, gap 2 vertical / 20 horizontal: edition 15/600 (flex 1 1 260) then the published line 13 `tinta3` (flex 1.4 1 300); at 1440 they sit side by side, on narrow widths the line wraps under the edition. Column 2: the badge, right-aligned. Column 3: chevron 18 (as WartaArsip). Rows and badges as WartaArsip 2a.
     b–e. As WartaArsip 2b–2e (compose button, member note, edition with correction, empty state), same copy and styles at web body size 15; buttons 340 wide max.
- **Components** As WartaArsip. Shared: web side nav. Pattern: web list table with chevron rows.
- **Internal views and states** Initial state `{ k: null }`; same four views as WartaArsip.
- **Tweaks** `keadaan` (enum; options "Arsip edisi", "Edisi dengan ralat", "Dibaca anggota jemaat", "Belum ada edisi"; default "Arsip edisi") · Keadaan panel. As WartaArsip.
- **Interactions** As WartaArsip: "Unduh PDF" is a no-op; each table row links to this same board (`hal('WartaArsip')` → `WebWartaArsip.dc.html`): press does nothing, no duplicate route. Toggle "Menu" below 860 px. No typed input, no timers.
- **Motion** None. Keyframes `isi`, `muncul`, `titik` declared, unused.
- **Links out** Breadcrumb "Beranda" → `/WebBerandaJabatan`, up link. "Susun edisi 22/11/2026" (k0) and "Susun edisi pertama" (k3) → `/WebWartaEditor`, push. Side nav (go) as in WebWartaEditor Shell; its "Warta Jemaat" item is this board (go to the current route does nothing). **Inbound** PetaPlatform, WebAkunSaya, WebAlurDokumen, WebAlurJabatanKosong, WebAlurKeluarga, WebAlurMasuk, WebAlurPengembalian, WebAlurPulihkan, WebAlurSurat, WebAlurUnit, WebAlurWarta, WebBerandaJabatan, WebBukaNama, WebCariOrang, WebDataAnggota, WebDataGanda, WebDokumenGereja, WebImporBuku, WebJabatanKosong, WebKasUnit, WebKeadaanUmum, WebKotakMasuk, WebLaporanLintas, WebPengumuman, WebPenugasan, WebPermohonanSurat, WebPersembahanBernama, WebSelesaikanUnit, WebTerbitDokumen, WebWartaEditor (most through the side nav).
- **Mock data** Same editions and correction as WartaArsip (shared constants).
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. `/WebWartaArsip` at 1440 → nav "Warta Jemaat" filled; one card holding four rows with no rule above the first; each row shows edition, published line, badge right-aligned, chevron.
  2. Click "Susun edisi 22/11/2026" → `/WebWartaEditor`; its breadcrumb "Warta Jemaat" returns here.
  3. Click a row → nothing happens.
  4. Panel `keadaan` = "Edisi dengan ralat" → the two cards as on the phone, max 880 wide.
  5. Panel `keadaan` = "Belum ada edisi" → empty-state card and "Susun edisi pertama".
  6. Click the breadcrumb "Beranda" → `/WebBerandaJabatan`.
  7. At 860 px → "Menu" top bar; at 600 px the published line wraps under the edition inside each row; no horizontal scroll.
- **Notes** Row text: the edition inherits 15 px web body (600), unlike the phone's 16.

### AlurDokumen — 69 · Alur · Menerbitkan dokumen
- **Source** `docs/design/handoff/canvas/boards/AlurDokumen.dc.html` · page Putaran 3 · Sekretariat (`p3`) · form Phone 390×844 · interactive yes
- **Route** `/AlurDokumen` (list) plus child routes `/AlurDokumen/terbit` (publish form, view `form`) and `/AlurDokumen/ralat` (correction form, view `ralat`) · **Widget** `AlurDokumenScreen` in `lib/screens/p3/alur_dokumen.dart`
- **Purpose** Sekretaris Jemaat, journey step 1 ("Dokumen gereja", "Terbitkan dokumen", "Alur · Menerbitkan dokumen"); a flow with typed input and live refusals. Publish a church document (type, title, document date, audience, signed copy), then publish a correction ("Ralat") that becomes a new revision while the current one stays openable and is marked “Digantikan”. Shows: a published document never changes silently, a correction is always a new revision (platform rule; glossary "Revisi"); the signature is on the document, there is no in-app approval for church documents; the document date cannot be in the future (today 16/11/2026); a failed upload keeps the input on screen and the file stays not attached (badge "Gagal diunggah", line "file belum terlampir"; EC07, D35); TombolBersyarat (one button, one first-unmet reason, re-checked on press, no refusal on an empty form); RiwayatAlur (newest first, who and which post).
- **Shell** Phone header with back, no tab bar (WartaEditor Shell primitives). The same header (back to Dokumen gereja) shows on all three routes.
- **Layout**
  1. Header: back semantics "Kembali ke Dokumen gereja"; h1 "Alur · Menerbitkan dokumen"; subtitle "Dari mengisi sampai terbit, lalu ralat sebagai revisi".
  2. **List** (`/AlurDokumen`, view `daftar`), scroll column gap 16:
     a. Status banner (only when `pesan` is not empty; the shared `Pesan`, components.md 2.8): `lautLembut` field, radius 12, padding 12/14, 14 px `tinta`, live-region semantics (`role=status`). Text = `pesan`.
     b. Document cards, one per entry of `D`, newest first: `permukaan`, 1 px `garis`, radius 14, padding 12/16, column gap 6. Header row (space-between, centre, gap 16): title 16/700 + badge `tinta` ("Diterbitkan" when the revision number is 1, otherwise "Revisi {n}"). Line 13 `tinta3`: "{jenis} · {tanggal} · {untuk}", plus " · revisi {n−1} tetap dapat dibuka" when n > 1. Text button "Ralat": min-height 44, no line, `laut` 700, padding 0 16, hugs its text, left-aligned (so its label sits 16 px in from the card text).
     c. Button row: primary "Terbitkan dokumen", 340 wide.
     d. Note 13 `tinta3`: "Dokumen yang sudah diterbitkan tidak pernah diubah diam-diam; ralat selalu menjadi revisi baru."
     e. Riwayat (only when `riw` is not empty): h2 "Riwayat" 16/700; card `permukaan`, 1 px `garis`, radius 14, padding 4/16, column; one row per entry, newest first: padding 8/0, 1 px `garis` top rule (also above the first row, 3 px under the card's top edge, as drawn), 13 `tinta3`, text = the entry.
  3. **Publish form** (`/AlurDokumen/terbit`, view `form`), scroll column gap 16:
     a. "Jenis dokumen": column gap 6; label 14 `tinta2`; chips (ChipPilihan) in a wrap row, gap 8: "Keputusan dan surat edaran", "Notulen rapat", "Tata gereja dan liturgi". Chip: min-height 44, padding 0 14, radius 999, 14/600, 1.5 line; selected `tinta` field and line, `permukaan` text; unselected `permukaan` field, `garisTegas` line, `tinta` text; pressed semantics.
     b. "Judul": label column (gap 6, 14 `tinta2`); input full width, min-height 48, padding 0 14, radius 12, 1 px `garisTegas` line, `permukaan` (`IsianTeks`, components.md 2.8, label gap 6); hint "Judul dokumen" in `tinta3`; typed text inherits 14 `tinta2` from the label. Semantics label "Judul".
     c. "Tanggal dokumen": same input with hint "hh/bb/tttt"; under it 13 `tinta3` "Tanggal yang tertulis di dokumennya." Keyboard `TextInputType.datetime`. Semantics label "Tanggal dokumen".
     d. "Ditujukan untuk": label and chips as (a): "Semua anggota", "Pelayan dan pengurus", "Kolom 7".
     e. File panel (dashed card, `draf`): header row "Salinan bertanda tangan" 16/700 + badge by file state: none → `bata` "Wajib, belum ada"; failed → `bata` "Gagal diunggah"; attached → `garis` "Terlampir". Then:
        - none: 13 `tinta3` "Tanda tangan ada di dokumennya. Tidak ada persetujuan di aplikasi untuk dokumen gereja."; secondary button "Pilih file" (min-height 48, radius 14, 1.5 `tinta`, `permukaan`, 700, padding 0 16, hugs its text, left-aligned).
        - failed: 14 px line: bold `bata` "Gagal diunggah." then a space and `tinta` "Isian Anda masih ada di layar ini; file belum terlampir."; primary button "Coba lagi" (min-height 52, radius 14, `tinta` field, `permukaan` text, 700, padding 0 16, hugs its text, left-aligned).
        - attached: 13 `tinta3` "salinan-bertanda-tangan.pdf · 1 halaman".
     f. Refusal (only when `sebab` shows, see Interactions): 14 px line: bold `bata` "Tidak dapat dilakukan: Terbitkan." then a space and the reason in `tinta`.
     g. Button row: "Terbitkan" (TombolBersyarat: min-height 52, radius 14, no line, 700, centred; met → `tinta` field, `permukaan` text; unmet → `garis` field, `tinta2` text; still pressable, disabled semantics while unmet) and text button "Batalkan". Side by side, 171 each.
  4. **Correction form** (`/AlurDokumen/ralat`, view `ralat`), scroll column gap 16:
     a. Card (`dibukukan`, padding 14/16, gap 6): header row = the selected document's title 16/700 + badge `tinta` "Diterbitkan" (always this word, whatever the revision number); line 13 `tinta3` "Revisi yang sekarang tetap dapat dibuka dan diberi tanda “Digantikan”."
     b. "Yang diralat · wajib" (IsianAlasan): label column (gap 6, 14 `tinta2`); textarea 3 rows, full width, min-height 96, padding 12/14, radius 12, 1 px `garisTegas`, `permukaan`, no resize, no hint, text inherits 14 `tinta2`. Semantics label "Yang diralat · wajib".
     c. File panel exactly as 3e (same states and copy).
     d. Refusal (only when `sebab2` shows): bold `bata` "Tidak dapat dilakukan: Terbitkan revisi." then the reason.
     e. Button row: "Terbitkan revisi" (TombolBersyarat, as 3g) and text button "Batalkan".
- **Components** TombolBersyarat ("Terbitkan", "Terbitkan revisi"), Penolakan (refusal lines), ChipPilihan (jenis, untuk), IsianAlasan ("Yang diralat · wajib"), LencanaStatus shapes ("Diterbitkan", "Revisi n", "Wajib, belum ada", "Gagal diunggah", "Terlampir"), RiwayatAlur (Riwayat card), PanelDokumen rules (file panel: failure in `bata` with a next step), GarisStatus `dibukukan`/`draf`, Tombol. Pattern: status banner `lautLembut`.
- **Internal views and states** Initial state `{ k: null }`; the flow state `a` starts as (verbatim) `{ pesan: '', riw: [], v: 'daftar', sel: 0, jenis: '', judul: '', tgl: '', untuk: '', file: '', ralat: '', D: [['Surat edaran jadwal ibadah Natal 2026', 'Keputusan dan surat edaran · 12/11/2026 · Semua anggota', 1]] }` (`D` entries are [judul, "jenis · tanggal · untuk", revision number]; `file` is `''`, `'gagal'` or `'ada'`). One state object for the board, owned above its child routes and shared by `/AlurDokumen`, `/AlurDokumen/terbit` and `/AlurDokumen/ralat`; dropped when no `/AlurDokumen…` route is left. The route decides the view (`v`): `daftar` ↔ `/AlurDokumen`, `form` ↔ `/terbit`, `ralat` ↔ `/ralat`. Opening `/AlurDokumen/terbit` or `/AlurDokumen/ralat` directly behaves as if reached from the list (fields reset, `sel` 0). In-place states: banner on/off, Riwayat on/off, file none/failed/attached, refusal on/off, button met/unmet.
- **Tweaks** `keadaan` (enum; one option "Alur"; default "Alur") · Keadaan panel. Changes nothing on screen; show it as a single, fixed option.
- **Interactions** (every handler of the logic class)
  - "Terbitkan dokumen" (`keForm`) → `v = 'form'`, `pesan = ''`, `jenis`, `judul`, `tgl`, `untuk`, `file` all `''` (`ralat` and `sel` untouched); push `/AlurDokumen/terbit`.
  - "Ralat" on document i (`ke('ralat', …)`) → `v = 'ralat'`, `pesan = ''`, `sel = i`, `ralat = ''`, `file = ''`; push `/AlurDokumen/ralat`.
  - "Batalkan" on either form (`batal`) and system Back from either child route → `v = 'daftar'`, `pesan = ''`; typed values stay in state but are reset the next time a form opens; pop to `/AlurDokumen`.
  - Chip press (`pil`) → sets `jenis` or `untuk` to that label and `pesan = ''`. Pressing the selected chip keeps it selected (no deselect).
  - Typing in "Judul", "Tanggal dokumen", "Yang diralat · wajib" (`ketik`) → stores the raw text on every change. No mask, no auto-slash, no length limit; leading and trailing spaces are kept in state and trimmed only when checked and published.
  - "Pilih file" / "Coba lagi" (`pilihFile`, `sekaliGagal` = true) → if `file` is `''` it becomes `'gagal'`, otherwise `'ada'`. So the first attempt after opening either form always fails and "Coba lagi" always attaches. Instant: no timer, no progress state.
  - Conditions of "Terbitkan", checked in this order, first unmet reason only:
    1. no `jenis` → "jenis dokumen belum dipilih."
    2. `judul` empty after trim → "judul belum diisi."
    3. `tgl` (trimmed) not exactly `dd/dd/dddd` (`^(\d\d)\/(\d\d)\/(\d{4})$`), or month outside 1–12, or day outside 1–31 → "tanggal dokumen tidak dikenali. Contoh: 16/11/2026." (no month-length check: "31/02/2026" passes)
    4. date later than 16/11/2026 (compared as yyyymmdd with 20261116) → "tanggal dokumen belum tiba."
    5. no `untuk` → "penerima belum dipilih."
    6. `file` ≠ `'ada'` → "salinan bertanda tangan belum terlampir."
    The refusal line shows only once any of `jenis`, `judul`, `tgl`, `untuk`, `file` is non-empty (a title of only spaces or a failed file counts); an untouched form shows no refusal.
  - Conditions of "Terbitkan revisi", in order: `ralat` empty after trim → "yang diralat belum diisi."; `file` ≠ `'ada'` → "salinan bertanda tangan revisi belum terlampir.". The refusal shows once `ralat` or `file` is non-empty.
  - Press on "Terbitkan" / "Terbitkan revisi": the handler re-reads the current state and runs only when its conditions are met; otherwise nothing happens (no new message, no focus move). The first press after the last keystroke must succeed when the input is complete (onChanged updates state synchronously before the press).
  - "Terbitkan", met → `teks` = "{judul trimmed} diterbitkan untuk {untuk}."; prepend `[judul trimmed, "{jenis} · {tgl trimmed} · {untuk}", 1]` to `D`; `pesan = teks`; prepend "16/11/2026 · {teks} Oleh Olvie Pangemanan, Sekretaris Jemaat." to `riw`; `v = 'daftar'`; pop to `/AlurDokumen`.
  - "Terbitkan revisi", met → copy `D`, add 1 to `D[sel]`'s revision number n; `teks` = "{title of D[sel]}: revisi {n} diterbitkan. Yang diralat: {ralat trimmed}"; `pesan = teks`; prepend "16/11/2026 · {teks}" to `riw` (no "Oleh …" suffix); `v = 'daftar'`; pop to `/AlurDokumen`.
  - The header back arrow on any of the three routes → `/DokumenGereja` (up link: from a child route it is `go`, dropping the flow state).
- **Motion** None in the board: views swap instantly and the keyframes `isi`, `masuk`, `muncul`, `pudar` are declared but unused. The board route `/AlurDokumen` enters like every phone board route (`masuk`, `pindahLayar` 280 ms, curve `keluar`; motion.md "Screen change and page transitions"). The child routes `/AlurDokumen/terbit` and `/AlurDokumen/ralat` have **no** transition, because the board puts no animation on those views' roots (motion.md: "If the root element has no animation, there is no transition"); pop back is instant. Nothing animates inside the views.
- **Links out** Back arrow → `/DokumenGereja`, up link. No other link; the two child routes are internal. **Inbound** PetaPlatform.
- **Mock data** Seed document "Surat edaran jadwal ibadah Natal 2026" · "Keputusan dan surat edaran · 12/11/2026 · Semua anggota" · revision 1 (the same document as DokumenGereja/TerbitDokumen; share the title and the "jenis · tanggal · untuk" line). DokumenGereja shows this document as "Revisi 2" while this flow seeds it at revision 1 (badge "Diterbitkan"): keep each board's own revision number. Document types "Keputusan dan surat edaran", "Notulen rapat", "Tata gereja dan liturgi"; audiences "Semua anggota", "Pelayan dan pengurus", "Kolom 7". File "salinan-bertanda-tangan.pdf · 1 halaman". Today 16/11/2026. Actor Olvie Pangemanan, Sekretaris Jemaat. Share with WebAlurDokumen.
- **Prototype-only** none. "Contoh: 16/11/2026." is part of an app refusal sentence, not a prototype "Contoh:" button: keep it on screen. Keadaan panel: `keadaan` (one option).
- **Acceptance checks**
  1. Open `/AlurDokumen` → one card "Surat edaran jadwal ibadah Natal 2026", badge "Diterbitkan", line "Keputusan dan surat edaran · 12/11/2026 · Semua anggota", "Ralat" button; "Terbitkan dokumen" 340 wide; the note; no banner, no Riwayat.
  2. Tap "Terbitkan dokumen" → `/AlurDokumen/terbit`; no chip selected; file badge "Wajib, belum ada" in `bata`; "Terbitkan" on a `garis` field with `tinta2` text; no refusal line. Tap "Terbitkan" → nothing changes.
  3. Tap "Notulen rapat" → chip filled `tinta`; refusal "Tidak dapat dilakukan: Terbitkan. judul belum diisi." appears above the buttons.
  4. Type "Notulen rapat majelis November" in Judul → reason "tanggal dokumen tidak dikenali. Contoh: 16/11/2026."; type "20/11/2026" in Tanggal → "tanggal dokumen belum tiba."; change it to "14/11/2026" → "penerima belum dipilih."
  5. Tap "Pelayan dan pengurus" → "salinan bertanda tangan belum terlampir."; tap "Pilih file" → badge "Gagal diunggah", line "Gagal diunggah. Isian Anda masih ada di layar ini; file belum terlampir." and "Coba lagi"; Judul and Tanggal keep their text.
  6. Tap "Coba lagi" → badge "Terlampir", "salinan-bertanda-tangan.pdf · 1 halaman"; refusal gone; "Terbitkan" filled `tinta`.
  7. Tap "Terbitkan" once → back on `/AlurDokumen`; banner "Notulen rapat majelis November diterbitkan untuk Pelayan dan pengurus."; new top card "Notulen rapat majelis November" with line "Notulen rapat · 14/11/2026 · Pelayan dan pengurus"; Riwayat row "16/11/2026 · Notulen rapat majelis November diterbitkan untuk Pelayan dan pengurus. Oleh Olvie Pangemanan, Sekretaris Jemaat."
  8. Tap "Ralat" on "Surat edaran jadwal ibadah Natal 2026" → `/AlurDokumen/ralat`, card titled with it (`pesan` cleared). Type "Jam ibadah malam" → refusal "Tidak dapat dilakukan: Terbitkan revisi. salinan bertanda tangan revisi belum terlampir."; "Pilih file" fails, "Coba lagi" attaches; "Terbitkan revisi" → list with that card's badge "Revisi 2", line "Keputusan dan surat edaran · 12/11/2026 · Semua anggota · revisi 1 tetap dapat dibuka", banner "Surat edaran jadwal ibadah Natal 2026: revisi 2 diterbitkan. Yang diralat: Jam ibadah malam", and that text (with the date prefix) as the new top Riwayat row.
  9. On `/AlurDokumen/terbit` with input, system Back → `/AlurDokumen` with no banner; tap "Terbitkan dokumen" again → empty form.
  10. Header back arrow on `/AlurDokumen` → `/DokumenGereja`.
- **Notes** Typed text in the inputs and the textarea inherits 14 px `tinta2` from their labels (the board's `input{font:inherit;color:inherit}` and the textarea's inline `font: inherit; color: inherit`): copy that, do not enlarge to 16. The unmet button uses `tinta2` on `garis` (TombolBersyarat README), not `tinta3` as the Tombol README says: keep the board. An empty form shows an unmet button without a reason, which is the TombolBersyarat rule ("formulir kosong tidak dibuka dengan penolakan") even though CONVENTIONS asks for a reason next to every disabled action; keep the board. The upload is instant, not "always in progress" as the motion rule wants: keep the board, no fake progress. Do not apply the shared hh/bb/tttt input mask here: the board validates raw text, and a mask would hide some refusals. The `balik` helper and `fileSt`'s parameter are internal; `rp`, `hal`, `baris` are unused.

### WebAlurDokumen — Web · Alur · Menerbitkan dokumen
- **Source** `docs/design/handoff/canvas/boards/WebAlurDokumen.dc.html` · page Putaran 3 · Sekretariat (`p3`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebAlurDokumen`, no child routes (list, publish form and correction form replace each other in place under the same title block) · **Widget** `WebAlurDokumenScreen` in `lib/screens/p3/web_alur_dokumen.dart`
- **Purpose** Sekretaris Jemaat on the laptop, journey step 1. Same flow, rules and decisions as AlurDokumen.
- **Shell** Web side nav `navPlatform` (WebWartaEditor Shell); active item **Dokumen gereja** (`aktif: 2`).
- **Layout**
  1. Title block: breadcrumb "Dokumen gereja"; h1 "Alur · Menerbitkan dokumen"; subtitle "Dari mengisi sampai terbit, lalu ralat sebagai revisi".
  2. Container: max width 1120, column gap 16, content per view:
     a. View `daftar`: exactly AlurDokumen 2a–2e (banner, document cards, "Terbitkan dokumen" max 340, note, Riwayat), full container width, at web body size 15 (card titles 15/700, "Ralat" and buttons 15/700; Riwayat heading 16/700).
     b. View `form`: a two-column row (wrap, row gap 20, column gap 28, top-aligned). Left (flex 1.3 1 420, min-width 0, column gap 12): "Jenis dokumen" chips, "Judul", "Tanggal dokumen" with its helper, "Ditujukan untuk" chips (AlurDokumen 3a–3d). Right (flex 1 1 340, min-width 0, column gap 12): file panel, refusal, button row "Terbitkan" / "Batalkan" (AlurDokumen 3e–3g).
     c. View `ralat`: the same two-column row. Left: the selected document's card and the "Yang diralat · wajib" textarea (AlurDokumen 4a–4b). Right: file panel, refusal, "Terbitkan revisi" / "Batalkan" (4c–4e).
     At 1440 the columns are about 608 and 484 wide; at 860 they stay side by side (about 431 and 349); below a content width of 788 the right column wraps under the left (windows from 861 to about 1072 px with the side nav beside the content, and below about 839 px).
- **Components** As AlurDokumen. Shared: web side nav.
- **Internal views and states** Same initial state objects and in-place states as AlurDokumen; here the three views are in-page state `v`, not routes. Browser Back leaves the board (as on other web boards).
- **Tweaks** `keadaan` (enum; one option "Alur"; default "Alur") · Keadaan panel. No visible effect.
- **Interactions** Every handler exactly as AlurDokumen (keForm, Ralat, Batalkan, chip picks, typing, pilihFile with the one forced failure, the same ordered conditions, refusal visibility and the same published texts, re-check on press), except that view changes happen in place instead of push/pop. Toggle "Menu" below 860 px.
- **Motion** None. Keyframes `isi`, `muncul`, `titik` declared, unused.
- **Links out** Breadcrumb "Dokumen gereja" → `/WebDokumenGereja`, up link. Side nav (go) as in WebWartaEditor Shell. **Inbound** PetaPlatform.
- **Mock data** Same as AlurDokumen (shared constants).
- **Prototype-only** none. Keadaan panel: `keadaan` (one option).
- **Acceptance checks**
  1. `/WebAlurDokumen` at 1440 → nav "Dokumen gereja" filled; breadcrumb "Dokumen gereja"; the seed document card and "Terbitkan dokumen".
  2. Click "Terbitkan dokumen" → in place, the form in two columns: chips and fields left; "Salinan bertanda tangan" panel with "Wajib, belum ada", and the "Terbitkan" / "Batalkan" buttons right; the URL stays `/WebAlurDokumen`.
  3. Fill "Keputusan dan surat edaran", "Surat edaran Adven", "17/11/2026", "Semua anggota" → refusal "Tidak dapat dilakukan: Terbitkan. tanggal dokumen belum tiba."; change the date to "16/11/2026" → "salinan bertanda tangan belum terlampir."
  4. "Pilih file" → "Gagal diunggah"; "Coba lagi" → "Terlampir"; "Terbitkan" → list with banner "Surat edaran Adven diterbitkan untuk Semua anggota.", the new card on top with line "Keputusan dan surat edaran · 16/11/2026 · Semua anggota", and the Riwayat row "16/11/2026 · Surat edaran Adven diterbitkan untuk Semua anggota. Oleh Olvie Pangemanan, Sekretaris Jemaat."
  5. "Ralat" on any card → correction form in two columns with the card and textarea left; "Batalkan" → list without banner.
  6. Click the breadcrumb "Dokumen gereja" → `/WebDokumenGereja`.
  7. At 700 px wide → "Menu" top bar; the form's right column sits under the left; no horizontal scroll.
- **Notes** Same notes as AlurDokumen (inherited 14 px `tinta2` input text, unmet button colours, no reason on an empty form, instant upload, no input mask).
