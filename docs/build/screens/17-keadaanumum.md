# Screens 17: KeadaanUmum, WebKeadaanUmum, DokumenGereja, WebDokumenGereja, TerbitDokumen, WebTerbitDokumen, PermohonanSurat, WebPermohonanSurat, Pengumuman, WebPengumuman

These ten boards are five phone/laptop pairs. KeadaanUmum/WebKeadaanUmum (canvas page "Putaran 2 · Kerangka platform") show the one pattern every module uses for its general states: loading skeleton, failed to load, offline, not authorised, module switched off, and session ended; they lead back to BerandaJabatan/WebBerandaJabatan or to sign-in (AlurMasuk/WebAlurMasuk). The other eight boards (canvas page "Putaran 3 · Sekretariat") are the Sekretaris Jemaat's desk, Olvie Pangemanan: DokumenGereja/WebDokumenGereja is the church document archive (list, a document with a superseded revision, empty, and the member's view), which opens TerbitDokumen/WebTerbitDokumen to publish a signed copy or a correction as a new revision; PermohonanSurat/WebPermohonanSurat handles letter requests (attestation, certificate) for one member and goes back to DokumenGereja; Pengumuman/WebPengumuman holds announcements (list, draft, published, auto-archived, correction as revision) that the Warta Jemaat later picks from. Every board has a single `keadaan` tweak and the same state model: initial state `{ k: null }`, the view shown is `k ?? keadaan` (an unknown value falls back to the first option), and each in-board button sets `k` to one option name; nothing is typed (every field is read-only and pre-filled), there are no timers, and no CSS animation is applied (the declared keyframes are unused). All views of a board share its header, title and back target, so there are no child routes: the view swaps in place. Changing the `keadaan` tweak in the Keadaan panel, or leaving the route, resets `k` to null (on the canvas a handler-set `k` would hide later tweak changes until the board is reopened). On every view change (a button or the tweak) the phone scroll area, or the web page, jumps to the top: the canvas keeps the old offset clamped to the new content, which on a short window can leave the reader mid-page; this is the same choice as 14-berandajabatan.md. In every section "up link" means the phone back arrow, the web breadcrumb above the h1, or a button that returns to that same parent: it pops when its target (or one of the target's child routes) is the route directly beneath, otherwise it does `go` to the target; drill-ins to other boards are `push`, side-nav items are `go`. Build every navigating control as `Tautan(ke: '<Stem>', cara: …)`: up links `Cara.naik`, drill-ins `Cara.dorong` (the default), `go` links and side-nav items `Cara.ganti` (navigation.md, quick reference); a phone back arrow is `KepalaPonsel(kembaliKe: '<Stem>', labelKembali: '<aria-label>')` and a web side nav is `NavSamping(item: navPlatform, aktif: <index>, pengguna: …)` inside `HalamanWeb` (components.md 4.1, 4.3, 4.4); the link test finds the targets by those forms. Several list rows link to their own board (`hal('<Stem>')` with no target): such a self-link changes nothing visible on the canvas, so it is a pressable row with touch feedback (`sentuh`) that neither navigates nor changes state, and `Tautan` must treat a target equal to the current route as a no-op rather than pushing a second copy. "Today" is 16/11/2026, the church Jemaat Karunia. None of these boards has `jabatanKosong` or any prototype device; the Keadaan panel holds only `keadaan`.

---

### KeadaanUmum — 61 · Keadaan umum
- **Source** `docs/design/handoff/canvas/boards/KeadaanUmum.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Phone 390×844 · interactive yes
- **Route** `/KeadaanUmum`, no child routes (the six states replace the body in place under one header) · **Widget** `KeadaanUmumScreen` in `lib/screens/p2/keadaan_umum.dart`
- **Purpose** Anyone with an account, in any module: journey "Anyone, before a post applies", step 4 ("Keadaan umum": loading, failed, offline, not authorised, module off, session ended). One pattern for six states every module reuses. Shows: the Rangka rules (shape of content first, never a provisional figure, name or status; "Not yet known is not zero"); D35 and master-file row 5 (offline: what is shown stays readable, input stays on the screen, nothing is stored on the device to send later); the Penolakan form for a refusal with a way forward ("What a person sees follows the posts they hold", Q25; post assignment is not changed from here); the platform rule that a module Tidak aktif leaves no trace (the module is not named); P01 (session ended → sign in again with the phone code, AlurMasuk). Listed in decision log §8 as a screen added 18/11/2026.
- **Shell** Phone header with back, no tab bar, no `jabatanKosong`: `LayarPonsel` with `KepalaPonsel(judul: 'Keadaan umum', anakJudul: 'Satu pola untuk semua modul', kembaliKe: 'BerandaJabatan', labelKembali: 'Kembali ke Beranda')`; the other four phone boards pass their own title, subtitle, target and label (each board's Header and Links out lines). Root: 390×844, clipped, `kertas` field, `tinta` text, `isi` 16/1.4 (Plus Jakarta Sans). Column: fixed header, then a scroll area filling the rest. Links `laut`, `lautTua` while pressed. Keyboard focus: 2 px solid `laut` outline, 2 px offset. This header and scroll area are the shared phone frame of all five phone boards in this file.
- **Layout**
  1. Header (fixed): row, centre, gap 8, padding 14 top / 12 sides / 8 bottom. Back target 44×44, centred chevron (path `M15 6l-6 6 6 6`, 22 px box on a 24 viewBox, stroke 2, round caps, `tinta`, hidden from semantics), semantics label "Kembali ke Beranda". Text column (flex 1): h1 "Keadaan umum" `judulLayar` 18/700, margin 0; subtitle "Satu pola untuk semua modul" `keterangan` 13 `tinta2` (the source writes 14 then 13; 13 wins).
  2. Scroll area: vertical scroll, padding 8 top / 20 sides / 20 bottom (content width 350); inside, a full-width column (`flex: none`: it takes its content's height, never grows or shrinks to the viewport), gap 16. Exactly one state block shows; each block's children are direct items of this gap-16 column.
     - **Shared controls** (named here, used by every board in this file):
       - *Button row* (`BarisLentur`): row, wrap, gap 8, start-aligned; each button flex 1 1 150, max-width 340. On the phone a single button is 340 wide and left-aligned (10 px free on the right); two buttons share the line at 171 each and their labels may wrap to two lines. On web a single button is 340 wide; two share one line, each (column width − 8) / 2 capped at 340: 340 in an 880 or 1120 column, about 330 in WebTerbitDokumen's 668 form column, about 300 in WebPengumuman's 608 Draf column. Buttons on one line stretch to the height of the tallest (CSS default `align-items: stretch`): next to a 52 ink button an outline or text button is 52 high too (Pengumuman's "Simpan sebagai draf", the "Batalkan" text buttons).
       - *Ink button* (`Tombol(jenis: tinta, ukuran: besar)`; the boards draw their main action this way, not in `laut`): min-height 52, radius 14, no border, `tinta` field, `permukaan` label 16/700 (15/700 on web), centred, padding 0 16.
       - *Outline button* (`Tombol(jenis: kedua, ukuran: sedang)`): min-height 48, radius 14, 1.5 solid `tinta` line, `permukaan` field, `tinta` label 16/700 (15/700 on web), centred, padding 0 16.
       - *Text button* (`Tombol(jenis: teks)`): min-height 44, no border, no field, `laut` label 16/700 (15/700 on web), centred, padding 0 16.
       - *Disabled button*: min-height 52, radius 14, no border, `garis` field, `tinta2` label 700, centred, padding 0 16, not pressable.
       - A bold run inside a sentence is weight 700.
     - **Memuat** (Rangka): skeleton column, gap 12, live region `role=status` with semantics label "Memuat": three blocks, full width (350), `garis` field, radius 12, heights 72, 56, 56; blocks hidden from semantics; static (no pulse). This is the Rangka preview form (components.md "Boards vs preview": full width, radius 12, no pulse), not Memuat's partial-width radius-8 pulsing blocks: build `Rangka` with `RangkaBalok(lebar: 1, tinggi: 72 / 56 / 56, radius: 12)` and keep it still (motion.md). Then caption `keterangan` 13 `tinta3`: "Bentuk isi tampil lebih dulu; tidak ada angka sementara yang bisa disangka angka sebenarnya."
     - **Gagal memuat**: failure banner: `bataLembut` field, 1 px solid `bata` line, radius 12, padding 12/14, 14 px `tinta`: "**Gagal memuat.** Tidak ada yang berubah pada data Anda." Then button row: ink button "Coba lagi".
     - **Tanpa sambungan**: dashed banner (GarisStatus `draf`): 1.5 dashed `putus` line, no field (`kertas` shows), radius 14, padding 12/14, 14 px: "**Tidak ada sambungan.**" then, after a space, in `tinta2`: "Yang sudah tampil tetap bisa dibaca. Isian tetap di layar; tidak ada yang disimpan di perangkat untuk dikirim nanti." Then button row: ink button "Coba lagi".
     - **Tidak berwenang** (Penolakan): 15 px line: "**Tidak dapat dilakukan: Buka halaman ini.**" in `bata` 700, a space, then "jabatan Anda tidak melihat data ini." in `tinta` 400. Caption 13 `tinta3`: "Bila ini keliru, hubungi Pimpinan Jemaat yang berwenang; penugasan jabatan tidak diubah dari sini." Button row: outline button (a link) "Kembali ke Beranda".
     - **Modul tidak aktif**: dashed card: 1.5 dashed `putus`, no field, radius 14, padding 14/16, column gap 6: "Halaman ini tidak tersedia" 16/700; "Tautan yang Anda buka menuju bagian yang tidak dipakai Jemaat Karunia." 14 `tinta2`. Caption 13 `tinta3`: "Nama modulnya tidak disebut: modul yang tidak aktif tidak meninggalkan jejak." Button row: outline button (a link) "Kembali ke Beranda".
     - **Sesi berakhir**: card GarisStatus `terpilih`: 1.5 solid `tinta` line, `permukaan` field, radius 12, padding 12/14, 14 px: "**Sesi Anda berakhir.** Masuk lagi untuk melanjutkan. Isian yang belum tersimpan tidak ikut tersimpan." Button row: ink button (a link) "Masuk lagi".
- **Components** Rangka (Memuat), Penolakan (Tidak berwenang: refused action in `bata`, cause in `tinta`, plus an available step), StatusSimpan failure pattern (Gagal memuat banner on `bataLembut` with "Coba lagi"), GarisStatus `draf` (offline banner, module-off card) and `terpilih` (session card), Tombol (ink, outline). LencanaModul rule (module off leaves no trace). Shared pattern: button row.
- **Internal views and states** Initial `{ k: null }`; view = `k ?? keadaan`. Six views, one per option, all reached from the tweak; Memuat is also reached from "Coba lagi" in Gagal memuat and Tanpa sambungan. Memuat shows indefinitely (no timer completes it). No sheets, toasts, or empty states beyond these.
- **Tweaks** `keadaan` (enum "Memuat" · "Gagal memuat" · "Tanpa sambungan" · "Tidak berwenang" · "Modul tidak aktif" · "Sesi berakhir", default "Memuat") · Keadaan panel. Each option shows the block of the same name in region 2; header unchanged. Changing it resets `k` to null.
- **Interactions**
  - "Coba lagi" (Gagal memuat) → `k = 'Memuat'`: the skeleton replaces the banner at once and stays.
  - "Coba lagi" (Tanpa sambungan) → `k = 'Memuat'`, same effect.
  - Every other control is a link (see Links out). No typed input, no validation, no timers.
- **Motion** None on the board. Keyframes `masuk`, `pudar`, `muncul`, `isi` are declared but no element uses them; do not add them. The skeleton does not pulse (Rangka allows a slow `denyut`, but the board draws none). State changes swap instantly. The route itself enters with the shared phone route transition (`masuk`, x 24 → 0 and opacity 0 → 1, `pindahLayar` 280 ms; navigation.md 5.3), as every phone board in this file does; under reduce motion that transition completes at once. Nothing else moves.
- **Links out**
  - Back arrow (no visible text, semantics "Kembali ke Beranda") → `/BerandaJabatan`, up link.
  - "Kembali ke Beranda" (Tidak berwenang and Modul tidak aktif) → `/BerandaJabatan`, up link.
  - "Masuk lagi" (Sesi berakhir) → `/AlurMasuk`, `go` (the session is over; do not keep this board on the stack).
  - **Inbound** PetaPlatform (and the launcher).
- **Mock data** Church name "Jemaat Karunia"; role "Pimpinan Jemaat yang berwenang". No figures, people, dates or codes.
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. `/KeadaanUmum` (default) → header "Keadaan umum" / "Satu pola untuk semua modul"; three `garis` blocks 72, 56, 56 high, radius 12, full width; caption "Bentuk isi tampil lebih dulu; …"; screen reader announces "Memuat"; after 5 s nothing has changed.
  2. `keadaan` "Gagal memuat" → banner "Gagal memuat. Tidak ada yang berubah pada data Anda." on `bataLembut` with a 1 px `bata` edge; "Coba lagi" 340 wide, `tinta` field.
  3. Tap "Coba lagi" → the skeleton appears immediately and stays (no timer).
  4. `keadaan` "Tanpa sambungan" → dashed banner starting "Tidak ada sambungan."; "Coba lagi" → skeleton.
  5. `keadaan` "Tidak berwenang" → "Tidak dapat dilakukan: Buka halaman ini." bold `bata` at 15 px followed by "jabatan Anda tidak melihat data ini."; tap "Kembali ke Beranda" → `/BerandaJabatan`.
  6. `keadaan` "Modul tidak aktif" → dashed card "Halaman ini tidak tersedia"; no module name appears anywhere on the screen.
  7. `keadaan` "Sesi berakhir" → card with a 1.5 `tinta` edge "Sesi Anda berakhir. …"; tap "Masuk lagi" → `/AlurMasuk`.
  8. With `keadaan` "Gagal memuat", tap "Coba lagi" (now Memuat), then set `keadaan` to "Sesi berakhir" → the session card shows (state reset).
  9. Back arrow → `/BerandaJabatan`.
- **Notes**
  - The main actions are `tinta` fields, not `laut` (foundations: one primary in `laut`). Keep the board.
  - Failure banner uses a 1 px `bata` line and radius 12, where `hambatan` is 1.5 and banners are radius 14; the session card is radius 12 too. Copy the board. components.md (Rangka) lists KeadaanUmum and WebKeadaanUmum under its "Failure card" (`role="alert"`, 1.5 `bata`, radius 14, title 17/700 "Data belum dapat dimuat", button with `margin-top` 6 and `min-width` 140); these two boards do not draw that card: build the banner and the separate button row above.
  - The 15 px refusal line is off the phone scale; copy it. The cause starts lower case ("jabatan Anda …"); keep it.
  - The captions under Memuat and Modul tidak aktif read like design notes but are drawn inside the screen and are not one of the four prototype devices; keep them on screen.
  - "Coba lagi" never completes the reload on this board (unlike Memuat's 1400 ms); do not invent a timer.

### WebKeadaanUmum — Web · Keadaan umum
- **Source** `docs/design/handoff/canvas/boards/WebKeadaanUmum.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebKeadaanUmum`, no child routes · **Widget** `WebKeadaanUmumScreen` in `lib/screens/p2/web_keadaan_umum.dart`
- **Purpose** Same as KeadaanUmum, on the laptop. Same decisions (Rangka, D35, Penolakan, module leaves no trace, P01).
- **Shell** Web side nav, platform variant `navPlatform` (navigation.md 1.3; shared by the five web boards in this file; specified once here). Build: `HalamanWeb(jarak: 20, nav: NavSamping(item: navPlatform, aktif: <index>, pengguna: <footer>))`; `aktif` is 0 (Beranda) on WebKeadaanUmum, 2 (Dokumen gereja) on WebDokumenGereja, WebTerbitDokumen and WebPermohonanSurat, 3 (Pengumuman) on WebPengumuman (the boards' `navVals()` index).
  - Root: `kertas` field, `tinta` text, `isiWeb` 15/1.45; row, wrap, min-height the window height. Links `laut`, `lautTua` on hover and press (inline-coloured links such as nav items and link buttons keep their own colour). Focus: 2 px `laut` outline, 2 px offset.
  - Nav column: flex 1 1 220 (about 221 wide at 1440), padding 24/16, `permukaan` field, 1 px `garis` right border, column gap 20.
  - Brand row: padding 0 8, gap 10, centred vertically. Mark 26×26 drawn from the board's SVG (rect x 2, y 2, 20×20, rx 6, no fill, 2 px `laut` stroke dashed 3 3; path `M12 2h4a6 6 0 0 1 6 6v8a6 6 0 0 1-6 6h-4z` filled `laut`; hidden from semantics). Text: "palakat" 18/700, line-height 1.1, over "Jemaat Karunia" 13 `tinta3`.
  - Items, exactly, in order, all `go`: Beranda → `/WebBerandaJabatan`; Keuangan → `/WebBeranda`; Dokumen gereja → `/WebDokumenGereja`; Pengumuman → `/WebPengumuman`; Warta Jemaat → `/WebWartaArsip`; Data jemaat → `/WebDataAnggota`; Ibadah dan kegiatan → `/Ibadah`; Panitia → `/Panitia`; Pemberitahuan → `/WebKotakMasuk`; Pengaturan → `/WebPenugasan`. Each: min-height 44, padding 0 12, radius 10, 15/600, no underline, label centred vertically. Active: `tinta` field, `permukaan` label. Others: no field, `tinta` label. The active item stays a link to its listed target: on WebDokumenGereja and WebPengumuman that is the board itself (no-op); on WebKeadaanUmum the active "Beranda" goes to `/WebBerandaJabatan`, and on WebTerbitDokumen and WebPermohonanSurat the active "Dokumen gereja" goes to `/WebDokumenGereja` (both `go`).
  - Footer: margin-top auto (pinned to the bottom of the nav), padding 12 top / 8 sides / 0 bottom, 1 px `garis` top rule, 13 `tinta2`: "**{name}** · {post}", name bold `tinta`. On this board "**Pnt. Hendrik Rumagit** · Penatua Kolom 7"; on the four Sekretariat web boards "**Olvie Pangemanan** · Sekretaris Jemaat".
  - At 860 px wide and below: the nav becomes a full-width top bar (row, wrap, centred, gap 0/12, padding 8/16, no right border, 1 px `garis` bottom border). A toggle sits at the right of the brand row: min-height 44, padding 0 16, radius 14, 1.5 `tinta` line, `permukaan` field, 14/700, label "Menu", semantics "Menu" with toggled state; when open: `tinta` field, `permukaan` label "Tutup menu", and the items (padding 8/0) and the footer (margin-top 0, padding-bottom 8) appear full width under the brand row. Closed, items and footer are hidden. Main then takes the full width below.
  - Main column: flex 999 1 560, min-width 0, padding 28 top / clamp(16, 3 % of window width, 40) sides / 40 bottom, column gap 20. At 1440 the content width is about 1139.
  - Title block (all five web boards): breadcrumb link 14/600 `laut`; h1 `judulHalaman` 26/700, margin-top 2; subtitle 14 `tinta2`.
  - Active item on this board: **Beranda** (`aktif: 0`; it links to `/WebBerandaJabatan`, not to this board).
- **Layout**
  1. Title block: breadcrumb "Beranda"; h1 "Keadaan umum"; subtitle "Satu pola untuk semua modul".
  2. State column: max-width 880, column gap 16. The six blocks exactly as KeadaanUmum region 2 (same copy, colours, sizes, radii, live region "Memuat"), with body text inheriting 15 where the phone inherits 16 (button labels 15/700, "Halaman ini tidak tersedia" 15/700). Skeleton blocks and banners span 880; buttons are 340 wide. Link targets are the web boards (see Links out).
- **Components** As KeadaanUmum (Rangka, Penolakan, failure banner pattern, GarisStatus `draf`/`terpilih`, Tombol). Shared: platform web side nav.
- **Internal views and states** As KeadaanUmum: `{ k: null }`, six in-place views.
- **Tweaks** `keadaan` (enum "Memuat" · "Gagal memuat" · "Tanpa sambungan" · "Tidak berwenang" · "Modul tidak aktif" · "Sesi berakhir", default "Memuat") · Keadaan panel. Same effects as KeadaanUmum; resets `k`.
- **Interactions** As KeadaanUmum: both "Coba lagi" → `k = 'Memuat'` (no timer). Nav toggle (≤860 px) opens and closes the item list. No typed input.
- **Motion** None. Keyframes `muncul`, `isi`, `titik` declared, unused. No skeleton pulse. Nav drawer opens instantly (CSS display toggle). As a laptop page the route has no enter transition, so the side nav stays still (navigation.md 5.3); this holds for all five web boards in this file. The nav's "Ibadah dan kegiatan" and "Panitia" open phone boards, which enter with the phone route transition.
- **Links out**
  - Breadcrumb "Beranda" → `/WebBerandaJabatan`, up link.
  - "Kembali ke Beranda" (Tidak berwenang, Modul tidak aktif) → `/WebBerandaJabatan`, up link.
  - "Masuk lagi" (Sesi berakhir) → `/WebAlurMasuk`, `go`.
  - Side nav: the ten items above, `go`.
  - **Inbound** PetaPlatform.
- **Mock data** As KeadaanUmum, plus the nav footer person "Pnt. Hendrik Rumagit · Penatua Kolom 7".
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. `/WebKeadaanUmum` at 1440 → nav with ten items, "Beranda" filled `tinta`; footer "Pnt. Hendrik Rumagit · Penatua Kolom 7"; skeleton of three blocks 880 wide; caption under it.
  2. `keadaan` "Gagal memuat" → banner and "Coba lagi" (340 wide); tap → skeleton, stays.
  3. `keadaan` "Tidak berwenang" → "Kembali ke Beranda" → `/WebBerandaJabatan`.
  4. `keadaan` "Sesi berakhir" → "Masuk lagi" → `/WebAlurMasuk`.
  5. Nav "Dokumen gereja" → `/WebDokumenGereja`; "Ibadah dan kegiatan" → `/Ibadah` (a phone board, shown in the device frame).
  6. At 860 px: nav is a top bar with "palakat" and a "Menu" toggle; tap → "Tutup menu" on a `tinta` field and the ten items listed below; no horizontal page scroll.
  7. At 1280 px: no overflow; state column still 880 max.
- **Notes**
  - The footer shows a Penatua Kolom 7 on a laptop page, although Q26 designs laptop layouts only for Bendahara Jemaat, Sekretaris Jemaat and Operator, and the nav marks "Beranda" active on a page that is not Beranda. Keep both as drawn.
  - "Ibadah dan kegiatan" and "Panitia" open phone boards (no laptop layout exists, Q26); they render in the phone frame.
  - Same off-token and primary-colour notes as KeadaanUmum. Nav item radius 10 is off-token; copy it.

### DokumenGereja — 62 · Dokumen gereja
- **Source** `docs/design/handoff/canvas/boards/DokumenGereja.dc.html` · page Putaran 3 · Sekretariat (`p3`) · form Phone 390×844 · interactive yes
- **Route** `/DokumenGereja`, no child routes · **Widget** `DokumenGerejaScreen` in `lib/screens/p3/dokumen_gereja.dart`
- **Purpose** Sekretaris Jemaat, journey step 1 ("Dokumen gereja", then "Terbitkan dokumen"); also the member's view ("Dilihat anggota jemaat"). The archive of every church document: decisions and circulars, minutes, liturgy, letters for members, committee asset handovers. Shows: what is published never changes silently, a correction is a linked revision and the old revision stays openable (platform rule; glossary "Revisi", not "Versi"); Q30 (audience label "Pelayan dan pengurus"); Q25 (one app, the member sees only documents addressed to them); P15 and P16 (a Panitia's written decision and its asset handover record live here; inbound from Panitia); finance supporting documents are not stored here but on the transaction; no in-app approval of church documents.
- **Shell** Phone header with back (the shared phone frame of KeadaanUmum), no tab bar, no `jabatanKosong`.
- **Layout**
  1. Header as KeadaanUmum region 1: back target with semantics "Kembali ke Beranda"; h1 "Dokumen gereja"; subtitle "Arsip dokumen seluruh Jemaat yang dipelihara Sekretaris Jemaat" (13 `tinta2`, wraps to two lines).
  2. Scroll area as KeadaanUmum region 2 (padding 8/20/20, column gap 16). Items in this order, each present only in the views named:
     a. Filter chips (Daftar dokumen, Dilihat anggota jemaat): row, wrap, gap 8. Three ChipPilihan-look labels, not pressable on the board: inline, min-height 44, padding 0 14, radius 999, 1.5 line, 14/600, label centred vertically. "Semua jenis" selected look (`tinta` field and line, `permukaan` label); "Tahun 2026" and "Ditujukan untuk: semua" unselected look (`garisTegas` line, `permukaan` field, `tinta` label). At 390 the third chip wraps to a second line.
     b. Document rows (Daftar dokumen, Dilihat anggota jemaat). **Phone list row** (named here; reused by PermohonanSurat and Pengumuman): a pressable card, GarisStatus `dibukukan`: `permukaan` field, 1 px `garis` line, radius 14, padding 12/16, min-height 44; row, centre, gap 12, `tinta` text, no underline. Text column (flex 1, min-width 0, gap 2): title 16/600; meta `keterangan` 13 `tinta3`. Then the badge (flex none). Then a chevron 18×18 (path `M9 6l6 6-6 6`, stroke `tinta3` 2, round caps, hidden from semantics). Rows are separated by the column gap 16 (each row is its own card). Semantics: one link per row.
        **Badges** (named here; LencanaStatus shapes, used across this file): 13/700, radius 6, padding 3/9, 1.5 line.
        - *Ink badge* (`BentukLencana.tinta`, board `LS.tinta`): `tinta` field and line, `permukaan` label (LencanaStatus "Dibukukan" shape).
        - *Line badge* (`garis`, `LS.garis`): `permukaan` field, solid `tinta3` line, `tinta2` label ("Dibalik / Sedang dikerjakan" shape).
        - *Grey badge* (`abu`, `LS.abu`): `garis` field and line, `tinta2` label ("Dibatalkan" shape).
        - *Bata badge* (`bata`, `LS.bata`): `permukaan` field, solid `bata` line, `bata` label ("Perlu dipastikan lagi" shape).
        - *Dashed badge* (`draf`, `LS.draf`): no field (the surface under it shows), dashed `putus` line, `tinta2` label ("Draf" shape).
        Rows in Daftar dokumen (title / meta / badge):
        1. "SK BPMJ No. 14/2026 · Penugasan Syamas Kolom 3" / "Keputusan dan surat edaran · 18/11/2026 · Pelayan dan pengurus" / ink "Diterbitkan"
        2. "Surat edaran jadwal ibadah Natal 2026" / "Keputusan dan surat edaran · 12/11/2026 · Semua anggota" / ink "Revisi 2"
        3. "Notulen rapat BPMJ 08/11/2026" / "Notulen rapat · Pelayan dan pengurus" / ink "Diterbitkan"
        4. "Tata ibadah Minggu Adven I" / "Tata gereja dan liturgi · Semua anggota" / ink "Diterbitkan"
        5. "Surat keterangan · Novita Wenas" / "Surat untuk anggota · 15/11/2026 · hanya anggota dan keluarganya" / ink "Diterbitkan"
        6. "Serah terima aset Panitia Paskah 2026" / "Serah terima aset panitia · 30/04/2026 · Pelayan dan pengurus" / ink "Diterbitkan"
        In Dilihat anggota jemaat only rows 2, 4 and 5 show, in that order.
     c. (Daftar dokumen) Button row: ink button (a link) "Terbitkan dokumen".
     d. (Dokumen dengan revisi; no chips, no rows)
        - Current revision, **solid card** (named here): `permukaan`, 1 px `garis`, radius 14, padding 14/16, column gap 6. Top row: space-between, centre, gap 16: "Surat edaran jadwal ibadah Natal 2026" 16/700 and ink badge "Revisi 2". Then "Keputusan dan surat edaran · 12/11/2026 · Ditujukan untuk: Semua anggota" 14 `tinta2`. Then "Revisi yang berlaku. Diterbitkan oleh Olvie Pangemanan, 14/11/2026 09.10." 13 `tinta3`. Then, inside the card, button row: outline button "Buka salinan bertanda tangan" (316 wide, the card's inner width: 350 minus 1 px edges and 16 padding).
        - Superseded revision, **dashed card** (named here, GarisStatus `draf`): 1.5 dashed `putus`, no field, radius 14, padding 14/16, column gap 6. Top row as above: "Revisi 1" 16/700 and grey badge "Digantikan oleh revisi 2". Then "Diterbitkan 12/11/2026 16.40" 14 `tinta2`. Then "Tetap dapat dibuka. Dokumen yang sudah diterbitkan tidak pernah diubah diam-diam; ralat selalu menjadi revisi baru." 13 `tinta3`.
        - Button row: outline button (a link) "Terbitkan revisi baru".
     e. (Belum ada dokumen; no chips, no rows) Dashed card, column gap 6: "Belum ada dokumen" 16/700; "Mulai dengan menerbitkan satu dokumen: surat keputusan, notulen rapat, tata ibadah, atau surat untuk anggota." 14 `tinta2`. Button row: ink button (a link) "Terbitkan dokumen".
     f. (Dilihat anggota jemaat) After the three rows: caption 13 `tinta3` "Anggota hanya melihat dokumen yang ditujukan untuknya. Dokumen pendukung keuangan tidak disimpan di sini; itu ada pada transaksinya." No publish button.
- **Components** LencanaStatus shapes (ink, grey badges), ChipPilihan look (static filter labels), GarisStatus `dibukukan` (rows, current revision) and `draf` (superseded revision, empty state), Tombol (ink, outline). Patterns: phone list row, the revision pair (current solid card over the superseded dashed card).
- **Internal views and states** Initial `{ k: null }`; view = `k ?? keadaan`. Views: Daftar dokumen (chips, six rows, "Terbitkan dokumen"); Dokumen dengan revisi (two revision cards, "Terbitkan revisi baru"); Belum ada dokumen (empty card, "Terbitkan dokumen"); Dilihat anggota jemaat (chips, three rows, member caption). Each is reached only from the tweak; no in-board control moves between them.
- **Tweaks** `keadaan` (enum "Daftar dokumen" · "Dokumen dengan revisi" · "Belum ada dokumen" · "Dilihat anggota jemaat", default "Daftar dokumen") · Keadaan panel. Effects as in Internal views. Changing it resets `k`.
- **Interactions**
  - "Buka salinan bertanda tangan" → `k = 'Dokumen dengan revisi'`, the view already shown: no visible change. Give it touch feedback only; do not open a viewer.
  - Each document row → self-link (no navigation, no state change; touch feedback).
  - Chips: not pressable.
  - No typed input, no timers.
- **Motion** None. Keyframes `masuk`, `pudar`, `muncul`, `isi` declared, unused. Route changes use the shared `pindahLayar`.
- **Links out**
  - Back arrow (semantics "Kembali ke Beranda") → `/BerandaJabatan`, up link.
  - "Terbitkan dokumen" (Daftar dokumen, Belum ada dokumen) → `/TerbitDokumen`, push.
  - "Terbitkan revisi baru" (Dokumen dengan revisi) → `/TerbitDokumen`, push.
  - Rows → own board (no-op).
  - **Inbound** AlurDokumen, Panitia, PermohonanSurat (its back arrow), PetaPlatform, TerbitDokumen (back arrow, "Lihat di Dokumen gereja", "Terbitkan revisi 2").
- **Mock data** The six documents above (titles, kinds, dates 18/11/2026, 12/11/2026, 15/11/2026, 30/04/2026, audiences). Revisions of "Surat edaran jadwal ibadah Natal 2026": Revisi 1 published 12/11/2026 16.40; Revisi 2 published by Olvie Pangemanan 14/11/2026 09.10. People: Olvie Pangemanan (Sekretaris Jemaat), Novita Wenas (member). Shared with TerbitDokumen, PermohonanSurat and their web twins: put the document list in `lib/mock/` once.
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. `/DokumenGereja` (default) → chips "Semua jenis" (filled), "Tahun 2026", "Ditujukan untuk: semua" (third on a second line); six row cards 16 px apart, the second with ink badge "Revisi 2"; ink button "Terbitkan dokumen" 340 wide at the end.
  2. Tap "Terbitkan dokumen" → `/TerbitDokumen`; Back returns here.
  3. Tap any row → nothing changes (no route change).
  4. `keadaan` "Dokumen dengan revisi" → no chips or rows; solid card "Surat edaran jadwal ibadah Natal 2026" + "Revisi 2"; dashed card "Revisi 1" + grey "Digantikan oleh revisi 2"; outline "Terbitkan revisi baru" → `/TerbitDokumen`.
  5. Tap "Buka salinan bertanda tangan" → no visible change.
  6. `keadaan` "Belum ada dokumen" → dashed card "Belum ada dokumen" and "Terbitkan dokumen"; no chips.
  7. `keadaan` "Dilihat anggota jemaat" → chips, then exactly "Surat edaran jadwal ibadah Natal 2026", "Tata ibadah Minggu Adven I", "Surat keterangan · Novita Wenas"; member caption; no "Terbitkan dokumen".
  8. Back arrow → `/BerandaJabatan`.
- **Notes**
  - Phone subtitle: the source writes 14 then 13; 13 wins.
  - Filter chips are static labels on the board; keep them non-pressable (no filtering logic).
  - "SK BPMJ No. 14/2026" and dates are plain sans in the row title; keep (they are part of a title, not a code cell).
  - Row 1 is dated 18/11/2026, after "today" (16/11/2026); keep (mock-data.md, item 35).
  - The member's view keeps the Sekretaris header and back target as drawn.

### WebDokumenGereja — Web · Dokumen gereja
- **Source** `docs/design/handoff/canvas/boards/WebDokumenGereja.dc.html` · page Putaran 3 · Sekretariat (`p3`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebDokumenGereja`, no child routes · **Widget** `WebDokumenGerejaScreen` in `lib/screens/p3/web_dokumen_gereja.dart`
- **Purpose** Same as DokumenGereja, at the Sekretaris Jemaat's desk (Q26: laptop layout for the Sekretaris). Same decisions.
- **Shell** Platform web side nav as WebKeadaanUmum; active item **Dokumen gereja** (`aktif: 2`, a self-link here); footer "**Olvie Pangemanan** · Sekretaris Jemaat".
- **Layout**
  1. Title block: breadcrumb "Beranda"; h1 "Dokumen gereja"; subtitle "Arsip dokumen seluruh Jemaat yang dipelihara Sekretaris Jemaat".
  2. Content column: max-width 880, column gap 16. Same items and views as DokumenGereja region 2, with these differences:
     a. Chips: identical; all three fit on one line.
     b. Documents as one table card instead of separate cards. **Web table** (named here; reused by WebPermohonanSurat and WebPengumuman): card `permukaan`, 1 px `garis`, radius 14, clipped; inside, a column of rows with no rule above the first row (the source shifts the column up 1 px under the card edge). Row: pressable, 3-column grid (flexible, content width, 20), gap 16, centre, min-height 52, padding 8/18, 1 px `garis` top rule, `tinta` text. Cell 1: row, wrap, baseline, gap 2 vertical / 20 horizontal: title 15/600 (flex 1 1 260, min-width 0) then meta 13 `tinta3` (flex 1.4 1 300, min-width 0); at 880 both sit on one line; when the cell is narrower than about 580 the meta drops under the title. Cell 2: the badge, right-aligned. Cell 3: chevron 18 `tinta3`. Rows, badges and the member filter (rows 2, 4, 5) as DokumenGereja.
     c–f. As DokumenGereja c–f, at web body size (card titles 15/700, button labels 15/700), cards span 880, buttons 340 wide. Link targets are the web boards.
- **Components** As DokumenGereja; the rows use the web table pattern. Shared: platform web side nav.
- **Internal views and states** As DokumenGereja (`{ k: null }`, four in-place views).
- **Tweaks** `keadaan` (enum "Daftar dokumen" · "Dokumen dengan revisi" · "Belum ada dokumen" · "Dilihat anggota jemaat", default "Daftar dokumen") · Keadaan panel. Same effects; resets `k`.
- **Interactions** As DokumenGereja: "Buka salinan bertanda tangan" → `k = 'Dokumen dengan revisi'` (no visible change); rows are self-links to `/WebDokumenGereja` (no-op). Nav toggle at ≤860 px.
- **Motion** None. Keyframes `muncul`, `isi`, `titik` declared, unused.
- **Links out**
  - Breadcrumb "Beranda" → `/WebBerandaJabatan`, up link.
  - "Terbitkan dokumen" (Daftar dokumen, Belum ada dokumen) → `/WebTerbitDokumen`, push.
  - "Terbitkan revisi baru" → `/WebTerbitDokumen`, push.
  - Rows and the active nav item → own board (no-op). Side nav as WebKeadaanUmum, `go`.
  - **Inbound** PetaPlatform, WebAkunSaya, WebAlurDokumen, WebAlurJabatanKosong, WebAlurKeluarga, WebAlurMasuk, WebAlurPengembalian, WebAlurPulihkan, WebAlurSurat, WebAlurUnit, WebAlurWarta, WebBerandaJabatan, WebBukaNama, WebCariOrang, WebDataAnggota, WebDataGanda, WebImporBuku, WebJabatanKosong, WebKasUnit, WebKeadaanUmum, WebKotakMasuk, WebLaporanLintas, WebPengumuman, WebPenugasan, WebPermohonanSurat, WebPersembahanBernama, WebSelesaikanUnit, WebTerbitDokumen, WebWartaArsip, WebWartaEditor (most through the platform side nav).
- **Mock data** As DokumenGereja; nav footer Olvie Pangemanan · Sekretaris Jemaat.
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. `/WebDokumenGereja` at 1440 → nav "Dokumen gereja" filled `tinta`; chips on one line; one table card with six rows, title and meta on one line each, badges right-aligned before the chevron; no rule above the first row.
  2. "Terbitkan dokumen" → `/WebTerbitDokumen`; browser Back returns.
  3. `keadaan` "Dokumen dengan revisi" → the two revision cards 880 wide; "Terbitkan revisi baru" → `/WebTerbitDokumen`.
  4. `keadaan` "Dilihat anggota jemaat" → table with exactly three rows and the member caption; no publish button.
  5. `keadaan` "Belum ada dokumen" → dashed empty card and "Terbitkan dokumen".
  6. Breadcrumb "Beranda" → `/WebBerandaJabatan`.
  7. At 860 px: "Menu" top bar; at narrow content widths the meta line moves under the title; no horizontal scroll.
- **Notes** Breadcrumb "Beranda" while the nav marks "Dokumen gereja" active; keep. Same notes as DokumenGereja.

### TerbitDokumen — 63 · Terbitkan dokumen
- **Source** `docs/design/handoff/canvas/boards/TerbitDokumen.dc.html` · page Putaran 3 · Sekretariat (`p3`) · form Phone 390×844 · interactive yes
- **Route** `/TerbitDokumen`, no child routes · **Widget** `TerbitDokumenScreen` in `lib/screens/p3/terbit_dokumen.dart`
- **Purpose** Sekretaris Jemaat, journey step 1 ("Terbitkan dokumen"). Publishing a church document means uploading the signed copy and choosing the audience; there is no in-app approval and no imitation signature ("Tanda tangan ada di dokumennya"). Publishing is refused until the signed copy is attached (disabled button with its reason, Tombol/TombolBersyarat rule); upload always looks in progress and is "not attached" until done, and a failed upload keeps the input (Gerak rule; EC07 and D06: the document stays "Wajib, belum ada"); once published the addressees get an in-app notification (D28); a correction never edits the published document silently: it becomes Revisi 2 with a required statement of what is corrected (platform revision rule; P12 reason not blank). Q30 audience options.
- **Shell** Phone header with back (shared phone frame), no tab bar, no `jabatanKosong`.
- **Layout**
  1. Header: back target, semantics "Kembali ke Dokumen gereja"; h1 "Terbitkan dokumen"; subtitle "Unggah salinan bertanda tangan, pilih untuk siapa".
  2. Scroll area (padding 8/20/20, column gap 16). **Document form card** (named here; shown in Mengisi, Sedang diunggah, Gagal diunggah, Ralat sebagai revisi): solid card (`permukaan`, 1 px `garis`, radius 14, padding 14/16), column gap 12. **Field** (named here; reused by PermohonanSurat and Pengumuman): a label column, gap 6, 14 `tinta2`: label text, then a read-only field, full width, min-height 48, padding 0 14, radius 12, 1 px `garisTegas` line, `permukaan` field; the value inherits the label's 14 px `tinta2`. Fields:
     - "Jenis dokumen" = "Keputusan dan surat edaran"
     - "Judul" = "Surat edaran jadwal ibadah Natal 2026"
     - A grid of auto-fit columns at least 300 wide, gap 16, top-aligned (on the phone the card inner width is 316: one column):
       - "Tanggal dokumen" = "12/11/2026"
       - "Ditujukan untuk" = "Semua anggota", then hint 13 `tinta3` "Semua anggota · Pelayan dan pengurus · satu Kolom, BIPRA atau Komisi"
     Views (items after the header, in order):
     - **Mengisi**: form card. Signed-copy card: dashed card (1.5 dashed `putus`, no field, radius 14, padding 14/16, column gap 6): top row (space-between, centre, gap 16) "Salinan bertanda tangan" 16/700 and bata badge "Wajib, belum ada"; caption 13 `tinta3` "Tanda tangan ada di dokumennya. Tidak ada persetujuan di aplikasi untuk dokumen gereja."; button row inside: outline button "Pilih file" (315 wide, the dashed card's inner width). Then button row: disabled button "Terbitkan" (340 wide). Then reason 13 `tinta3` "Tidak dapat dilakukan: salinan bertanda tangan belum dilampirkan." (below the button).
     - **Sedang diunggah**: form card. Upload card: solid card, column gap 6: top row "surat-edaran-natal-2026.pdf" 16/700 and line badge "Sedang diunggah…"; progress bar: height 8, radius 4, 1.5 dashed `putus` edge drawn inside the box, clipped; fill `laut`, full height, 62 % of the inner width, static; caption 13 `tinta3` "Belum terlampir sampai unggahan selesai." No buttons in this view.
     - **Gagal diunggah**: form card. Failure banner (`bataLembut`, 1 px `bata`, radius 12, padding 12/14, 14 px): "**Gagal diunggah.** Isian Anda masih ada di layar ini; file belum terlampir." Button row: ink button "Coba lagi".
     - **Diterbitkan** (no form card): solid card, column gap 6: top row "Surat edaran jadwal ibadah Natal 2026" 16/700 and ink badge "Diterbitkan"; "Ditujukan untuk: Semua anggota · 12/11/2026" 14 `tinta2`; "Diterbitkan oleh Olvie Pangemanan, 12/11/2026 16.40. Anggota yang dituju menerima pemberitahuan." 13 `tinta3`. Then button row (outside the card): outline button (a link) "Lihat di Dokumen gereja" and text button "Terbitkan revisi baru", side by side at 171 each, labels wrapping to two lines.
     - **Ralat sebagai revisi**: dashed banner (1.5 dashed `putus`, no field, radius 14, padding 12/14, 14 px): "**Ralat menjadi Revisi 2.**" then, after a space, in `tinta2`: "Revisi 1 tetap tampil sebagai “Digantikan oleh revisi 2”." Then the form card. Then (outside the card) a field with a text area: label "Yang diralat · wajib"; text area read-only, 3 rows, min-height 96, padding 12/14, radius 12, 1 px `garisTegas`, `permukaan`, no resize, value "Jam ibadah malam Natal: 19.00, bukan 18.00." (14 `tinta2`). Then button row: ink button (a link) "Terbitkan revisi 2" and text button "Batalkan", side by side at 171 each.
- **Components** GarisStatus (`dibukukan` form and published cards, `draf` signed-copy card and revision banner), LencanaStatus shapes (bata "Wajib, belum ada", line "Sedang diunggah…", ink "Diterbitkan"), Tombol (ink, outline, text, disabled), TombolBersyarat (the disabled "Terbitkan" with its reason), PanelDokumen pattern (required document, upload progress bar, failure with "Coba lagi"), IsianAlasan look ("Yang diralat · wajib"), failure banner pattern. Pattern: read-only field.
- **Internal views and states** Initial `{ k: null }`; view = `k ?? keadaan`. Five views: Mengisi (form, required signed copy, disabled publish); Sedang diunggah (tweak, "Pilih file" or "Coba lagi"; no way forward on the board); Gagal diunggah (tweak only); Diterbitkan (tweak, or "Batalkan" from Ralat); Ralat sebagai revisi (tweak, or "Terbitkan revisi baru" from Diterbitkan).
- **Tweaks** `keadaan` (enum "Mengisi" · "Sedang diunggah" · "Gagal diunggah" · "Diterbitkan" · "Ralat sebagai revisi", default "Mengisi") · Keadaan panel. Each option shows the view of the same name. Resets `k`.
- **Interactions**
  - "Pilih file" (Mengisi) → `k = 'Sedang diunggah'` (fakes choosing a file; no file picker opens). The upload never completes: no timer.
  - "Coba lagi" (Gagal diunggah) → `k = 'Sedang diunggah'`.
  - "Terbitkan" (Mengisi): condition "signed copy attached" is never met in this view; the button is drawn disabled with the reason below it. Build it as TombolBersyarat in its unmet look: a press re-checks, stays unmet, and changes nothing; semantics: disabled, with the reason as hint. TombolBersyarat would draw its own sentence above the button; pass `sudahMulai: false` so it draws none, and draw the board's 13 `tinta3` line below the button as a separate item of the column (gap 16).
  - "Terbitkan revisi baru" (Diterbitkan) → `k = 'Ralat sebagai revisi'`.
  - "Batalkan" (Ralat sebagai revisi) → `k = 'Diterbitkan'`.
  - Fields are read-only (focusable, not editable, no keyboard). No typed input, no validation.
- **Motion** None. The progress bar is a static 62 % fill; the declared keyframe `isi` (width 0 → 100 %) is not applied, nor are `masuk`, `pudar`, `muncul`. Do not animate or complete the upload.
- **Links out**
  - Back arrow (semantics "Kembali ke Dokumen gereja") → `/DokumenGereja`, up link.
  - "Lihat di Dokumen gereja" (Diterbitkan) → `/DokumenGereja`, up link.
  - "Terbitkan revisi 2" (Ralat sebagai revisi) → `/DokumenGereja`, up link.
  - **Inbound** DokumenGereja ("Terbitkan dokumen", "Terbitkan revisi baru"), PetaPlatform.
- **Mock data** Document "Surat edaran jadwal ibadah Natal 2026", Keputusan dan surat edaran, dated 12/11/2026, for Semua anggota; file "surat-edaran-natal-2026.pdf" at 62 %; published by Olvie Pangemanan 12/11/2026 16.40; correction "Jam ibadah malam Natal: 19.00, bukan 18.00."
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. `/TerbitDokumen` (default) → form card with four read-only fields stacked; dashed card "Salinan bertanda tangan" + bata "Wajib, belum ada"; grey "Terbitkan" button; under it "Tidak dapat dilakukan: salinan bertanda tangan belum dilampirkan."
  2. Tap "Terbitkan" → nothing changes.
  3. Tap "Pilih file" → upload card "surat-edaran-natal-2026.pdf", line badge "Sedang diunggah…", bar filled 62 % in `laut` inside a dashed edge, "Belum terlampir sampai unggahan selesai."; after 5 s unchanged.
  4. `keadaan` "Gagal diunggah" → failure banner "Gagal diunggah. Isian Anda masih ada di layar ini; file belum terlampir." with the form still filled; "Coba lagi" → upload view.
  5. `keadaan` "Diterbitkan" → card with ink "Diterbitkan" and "Diterbitkan oleh Olvie Pangemanan, 12/11/2026 16.40. …"; tap "Terbitkan revisi baru" → banner "Ralat menjadi Revisi 2." and the "Yang diralat · wajib" text area.
  6. In the Ralat view tap "Batalkan" → Diterbitkan view.
  7. Tap "Terbitkan revisi 2" → DokumenGereja (pops if it is beneath).
  8. Tap "Lihat di Dokumen gereja" → DokumenGereja.
- **Notes**
  - Field values inherit 14 px `tinta2` from their label (`input{font:inherit;color:inherit}`); copy that, do not use 16 `tinta`.
  - The disabled reason sits below the button in `tinta3`, where TombolBersyarat puts it above and Penolakan colours "Tidak dapat dilakukan:" in `bata`. Keep the board. The reason shows at once because the form is already filled, which matches the rule.
  - The disabled button label is `tinta2` (Tombol's disabled rule says `tinta3`); keep `tinta2` (it is the TombolBersyarat unmet look).
  - Links carry no state: "Terbitkan revisi baru" on DokumenGereja opens this board in its tweak value (default Mengisi), not in the Ralat view; "Terbitkan revisi 2" returns to DokumenGereja in its own default, whose list already shows "Revisi 2".
  - Radius 4 on the progress bar is off-token; copy it.

### WebTerbitDokumen — Web · Terbitkan dokumen
- **Source** `docs/design/handoff/canvas/boards/WebTerbitDokumen.dc.html` · page Putaran 3 · Sekretariat (`p3`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebTerbitDokumen`, no child routes · **Widget** `WebTerbitDokumenScreen` in `lib/screens/p3/web_terbit_dokumen.dart`
- **Purpose** Same as TerbitDokumen at the desk, plus a preview of what the recipients see (they never see drafts, failed uploads, or documents addressed to others).
- **Shell** Platform web side nav as WebKeadaanUmum; active item **Dokumen gereja** (`aktif: 2`; it goes to `/WebDokumenGereja`); footer "**Olvie Pangemanan** · Sekretaris Jemaat".
- **Layout**
  1. Title block: breadcrumb "Dokumen gereja"; h1 "Terbitkan dokumen"; subtitle "Unggah salinan bertanda tangan, pilih untuk siapa".
  2. Two-column row: wrap, gap 24, top-aligned. Side by side when the content width is at least 844 (window about 1133 px and wider); below that the aside wraps under the form.
     a. Form column: flex 1 1 520, min-width 0, max-width 880, column gap 16. The five views of TerbitDokumen region 2, identical copy, colours and sizes, body inheriting 15 (card titles 15/700, button labels 15/700; field values stay 14). At 1440 the column is about 668 wide and the card inner about 634, so "Tanggal dokumen" and "Ditujukan untuk" sit side by side (two columns of about 309); narrower, they stack. Buttons up to 340 wide; in Diterbitkan and Ralat the two buttons sit side by side.
     b. Aside "Yang dilihat penerima": flex 1 1 300, min-width 0, max-width 480 (about 448 at 1440), column gap 10, shown in every view.
        - h2 "Yang dilihat penerima" `judulBagian` 16/700.
        - Solid card, column gap 6: top row (space-between, centre, gap 16) "Surat edaran jadwal ibadah Natal 2026" 15/700 and a badge: in Diterbitkan the ink badge "Diterbitkan"; in every other view the dashed badge "Belum diterbitkan". Then "Keputusan dan surat edaran · 12/11/2026" 14 `tinta2`. Then two pair rows (space-between, gap 16, 14 px): "Ditujukan untuk" (`tinta2`) | "Semua anggota" (600, right-aligned); "Lampiran" | "Salinan bertanda tangan (PDF)".
        - Caption 13 `tinta3`: "Penerima melihat judul, tanggal dan salinan bertanda tangan. Mereka tidak melihat draf, unggahan yang gagal, atau dokumen yang ditujukan untuk orang lain."
- **Components** As TerbitDokumen, plus the dashed badge "Belum diterbitkan" and pair rows in the preview card. Shared: platform web side nav.
- **Internal views and states** As TerbitDokumen (`{ k: null }`, five views). The aside badge follows the view: `belumTerbit` = view is not Diterbitkan.
- **Tweaks** `keadaan` (enum "Mengisi" · "Sedang diunggah" · "Gagal diunggah" · "Diterbitkan" · "Ralat sebagai revisi", default "Mengisi") · Keadaan panel. Same effects, plus the aside badge; resets `k`.
- **Interactions** As TerbitDokumen: "Pilih file" and "Coba lagi" → Sedang diunggah (no timer); disabled "Terbitkan" does nothing; "Terbitkan revisi baru" → Ralat sebagai revisi; "Batalkan" → Diterbitkan. Nav toggle at ≤860 px.
- **Motion** None. Keyframes `muncul`, `isi`, `titik` declared, unused; progress bar static at 62 %.
- **Links out**
  - Breadcrumb "Dokumen gereja" → `/WebDokumenGereja`, up link.
  - "Lihat di Dokumen gereja" → `/WebDokumenGereja`, up link.
  - "Terbitkan revisi 2" → `/WebDokumenGereja`, up link.
  - Side nav as WebKeadaanUmum, `go`.
  - **Inbound** PetaPlatform, WebDokumenGereja.
- **Mock data** As TerbitDokumen; aside attachment "Salinan bertanda tangan (PDF)".
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. `/WebTerbitDokumen` at 1440 → form column left, aside "Yang dilihat penerima" right with dashed "Belum diterbitkan"; "Tanggal dokumen" and "Ditujukan untuk" side by side.
  2. "Pilih file" → upload card with the 62 % bar; aside badge still "Belum diterbitkan".
  3. `keadaan` "Diterbitkan" → aside badge ink "Diterbitkan"; buttons "Lihat di Dokumen gereja" and "Terbitkan revisi baru" side by side.
  4. "Terbitkan revisi baru" → Ralat view; aside back to "Belum diterbitkan".
  5. "Terbitkan revisi 2" → `/WebDokumenGereja`.
  6. At 1280 px → aside still beside the form, date and audience fields stacked; at 1000 px → aside below the form.
  7. At 860 px → "Menu" top bar, aside below the form, no horizontal scroll.
- **Notes** The preview card's "Lampiran" row reads "Salinan bertanda tangan (PDF)" even before a file is attached; keep. Same notes as TerbitDokumen.

### PermohonanSurat — 64 · Permohonan surat
- **Source** `docs/design/handoff/canvas/boards/PermohonanSurat.dc.html` · page Putaran 3 · Sekretariat (`p3`) · form Phone 390×844 · interactive yes
- **Route** `/PermohonanSurat`, no child routes · **Widget** `PermohonanSuratScreen` in `lib/screens/p3/permohonan_surat.dart`
- **Purpose** Sekretaris Jemaat, journey step 2 ("Permohonan surat", then "Alur · Permohonan surat"); the member's own side is in AlurSurat (Anggota journey step 3). Requests for an attestation or a certificate for one member arrive from the member or are recorded by the Operator at the office for members without a phone. Shows: the Sekretaris reads Data jemaat and never changes it (platform rule); every module may be absent (Data jemaat Tidak aktif: the member's data is typed here and used only for this letter); a letter needs the signed copy (no in-app signature); a letter is seen only by the member, the family and the pelayan over them; a refusal records a reason (P12) and notifies the requester in the app (D28); a member Belum dikonfirmasi, whose data still comes from the paper book, gets no letter.
- **Shell** Phone header with back (shared phone frame), no tab bar, no `jabatanKosong`.
- **Layout**
  1. Header: back target, semantics "Kembali ke Dokumen gereja"; h1 "Permohonan surat"; subtitle "Atestasi dan surat keterangan untuk satu anggota".
  2. Scroll area (padding 8/20/20, column gap 16). Views:
     - **Diajukan**: three phone list rows (DokumenGereja 2b), each with the line badge "Diajukan":
       1. "Surat keterangan · Novita Wenas" / "Diajukan anggota 14/11/2026 · untuk melamar pekerjaan"
       2. "Atestasi · Keluarga Lasut" / "Dicatat Operator Yanti Sumual 15/11/2026"
       3. "Atestasi · Ferry Wenas" / "Diajukan 13/11/2026"
       Then caption 13 `tinta3` "Permohonan datang dari anggota, atau dicatat Operator di kantor untuk anggota tanpa ponsel."
     - **Menerbitkan surat**: request card (solid card, column gap 6): top row "Surat keterangan · Novita Wenas" 16/700 and line badge "Diajukan"; three pair rows (space-between, gap 16, 14 px; label `tinta2`, value 600 right-aligned): "Nama" | "Novita Wenas"; "Keluarga · Kolom" | "Wenas-Lasut · Kolom 7"; "Status" | "Aktif · sidi 2014"; caption 13 `tinta3` "Diambil dari Data jemaat yang sudah diverifikasi Penatua Kolom 7. Sekretaris membaca, tidak mengubah." Then signed-copy card (dashed card, column gap 6): top row "Salinan bertanda tangan" 16/700 and bata badge "Wajib, belum ada"; button row inside: outline button "Pilih file". Then button row: text button "Tidak diterbitkan".
     - **Data jemaat tidak aktif**: dashed banner (1.5 dashed `putus`, radius 14, padding 12/14, 14 px): "**Modul Data jemaat belum aktif.**" then, after a space, in `tinta2`: "Data anggota diketik di sini dan hanya dipakai untuk surat ini." Then a form card (solid card, column gap 12) with three read-only fields (TerbitDokumen field pattern): "Nama" = "Novita Wenas"; "Keluarga · Kolom" = "Wenas-Lasut · Kolom 7"; "Keperluan" = "Melamar pekerjaan". Then button row: outline button "Pilih file salinan bertanda tangan".
     - **Diterbitkan**: solid card, column gap 6: top row "Surat keterangan · Novita Wenas" 16/700 and ink badge "Diterbitkan"; "No. 027/SKet/XI/2026 · 15/11/2026" 14 `tinta2`; "Diterbitkan oleh Olvie Pangemanan. Hanya anggota, keluarganya dan pelayan yang menaunginya yang dapat melihat." 13 `tinta3`; button row inside the card: outline button "Buka salinan bertanda tangan".
     - **Tidak diterbitkan**: solid card, column gap 6: top row "Atestasi · Ferry Wenas" 16/700 and bata badge "Tidak diterbitkan"; "Alasan: anggota belum dikonfirmasi; data masih dari buku anggota." 14 `tinta2`; "Dicatat oleh Olvie Pangemanan, 16/11/2026. Pemohon menerima pemberitahuan beserta alasannya." 13 `tinta3`. No buttons.
- **Components** Phone list row, LencanaStatus shapes (line "Diajukan", bata "Wajib, belum ada" and "Tidak diterbitkan", ink "Diterbitkan"), GarisStatus (`dibukukan` cards, `draf` signed-copy card and module banner), Tombol (outline, text), read-only fields. Pattern: label/value pair rows. LencanaModul rule (Data jemaat absent).
- **Internal views and states** Initial `{ k: null }`; view = `k ?? keadaan`. Five views: Diajukan (list; tweak only); Menerbitkan surat (tweak only); Data jemaat tidak aktif (tweak only); Diterbitkan (tweak, "Pilih file", "Pilih file salinan bertanda tangan", "Buka salinan bertanda tangan"); Tidak diterbitkan (tweak, "Tidak diterbitkan").
- **Tweaks** `keadaan` (enum "Diajukan" · "Menerbitkan surat" · "Data jemaat tidak aktif" · "Diterbitkan" · "Tidak diterbitkan", default "Diajukan") · Keadaan panel. Each option shows the view of the same name. Resets `k`.
- **Interactions**
  - "Pilih file" (Menerbitkan surat) → `k = 'Diterbitkan'` at once (fakes attaching the signed copy and publishing; no upload view, no timer).
  - "Tidak diterbitkan" (Menerbitkan surat) → `k = 'Tidak diterbitkan'` (the result card is the board's other sample, Ferry Wenas; no reason is typed here).
  - "Pilih file salinan bertanda tangan" (Data jemaat tidak aktif) → `k = 'Diterbitkan'`.
  - "Buka salinan bertanda tangan" (Diterbitkan) → `k = 'Diterbitkan'`: no visible change; touch feedback only.
  - List rows (Diajukan) → self-links: no navigation, no state change.
  - No typed input, no timers.
- **Motion** None. Keyframes `masuk`, `pudar`, `muncul`, `isi` declared, unused.
- **Links out**
  - Back arrow (semantics "Kembali ke Dokumen gereja") → `/DokumenGereja`, up link (DokumenGereja does not link here, so usually `go`).
  - Rows → own board (no-op).
  - **Inbound** AlurSurat, PetaPlatform, and three links built in logic classes that the manifest misses (navigation.md 3.3): BerandaJabatan (rows "3 permohonan surat", "2 permohonan surat dicatat di kantor", "Permohonan surat keterangan"), KotakMasuk (rows "3 permohonan surat", "Surat keterangan Novita Wenas diterbitkan"), CariOrang (result row "Novita Wenas"); all push.
- **Mock data** Requests: Surat keterangan · Novita Wenas (by the member, 14/11/2026, "untuk melamar pekerjaan"); Atestasi · Keluarga Lasut (recorded by Operator Yanti Sumual, 15/11/2026); Atestasi · Ferry Wenas (13/11/2026). Novita Wenas: Keluarga Wenas-Lasut, Kolom 7, Aktif · sidi 2014, Keperluan "Melamar pekerjaan". Letter No. 027/SKet/XI/2026 dated 15/11/2026 by Olvie Pangemanan (matches the DokumenGereja row "Surat keterangan · Novita Wenas", dated 15/11/2026). Refusal recorded by Olvie Pangemanan 16/11/2026. Verifier post Penatua Kolom 7.
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. `/PermohonanSurat` (default) → three row cards with line badge "Diajukan", the second "Atestasi · Keluarga Lasut" / "Dicatat Operator Yanti Sumual 15/11/2026"; caption below.
  2. Tap a row → nothing changes.
  3. `keadaan` "Menerbitkan surat" → request card with "Nama | Novita Wenas", "Keluarga · Kolom | Wenas-Lasut · Kolom 7", "Status | Aktif · sidi 2014"; dashed card with bata "Wajib, belum ada" and "Pilih file"; text button "Tidak diterbitkan".
  4. Tap "Pilih file" → card "Surat keterangan · Novita Wenas" + ink "Diterbitkan", "No. 027/SKet/XI/2026 · 15/11/2026".
  5. Set `keadaan` to "Menerbitkan surat" again, tap "Tidak diterbitkan" → card "Atestasi · Ferry Wenas" + bata "Tidak diterbitkan" and "Alasan: anggota belum dikonfirmasi; data masih dari buku anggota."
  6. `keadaan` "Data jemaat tidak aktif" → dashed banner "Modul Data jemaat belum aktif. …", three read-only fields, "Pilih file salinan bertanda tangan" → Diterbitkan view.
  7. Back arrow → `/DokumenGereja`.
- **Notes**
  - No control moves from the list to "Menerbitkan surat" (rows only reload the board); reviewers switch views in the Keadaan panel. Do not invent a row target.
  - The letter number is plain sans 14 in the board although CONVENTIONS makes codes mono; the board wins on what the screen shows. Keep sans.
  - The refusal result is about Ferry Wenas while the request being handled is Novita Wenas; keep the board's sample.
  - Field values inherit 14 px `tinta2` (as TerbitDokumen).

### WebPermohonanSurat — Web · Permohonan surat
- **Source** `docs/design/handoff/canvas/boards/WebPermohonanSurat.dc.html` · page Putaran 3 · Sekretariat (`p3`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebPermohonanSurat`, no child routes · **Widget** `WebPermohonanSuratScreen` in `lib/screens/p3/web_permohonan_surat.dart`
- **Purpose** Same as PermohonanSurat at the Sekretaris desk.
- **Shell** Platform web side nav as WebKeadaanUmum; active item **Dokumen gereja** (`aktif: 2`; it goes to `/WebDokumenGereja`); footer "**Olvie Pangemanan** · Sekretaris Jemaat".
- **Layout**
  1. Title block: breadcrumb "Dokumen gereja"; h1 "Permohonan surat"; subtitle "Atestasi dan surat keterangan untuk satu anggota".
  2. Content column: max-width 1120, column gap 16. Views as PermohonanSurat with these differences:
     - **Diajukan**: the three requests in one web table (WebDokumenGereja 2b) with line badges "Diajukan"; then the caption.
     - **Menerbitkan surat**: two-column row, wrap, gap 20 vertical / 28 horizontal, top-aligned. Left: flex 1.3 1 420, min-width 0, column gap 12, holding the request card. Right: flex 1 1 340, min-width 0, column gap 12, holding the signed-copy card and then the button row with text button "Tidak diterbitkan". At 1440 the columns are about 608 and 484 wide; they stack when the content is narrower than 788.
     - **Data jemaat tidak aktif**, **Diterbitkan**, **Tidak diterbitkan**: single column as the phone, cards full content width (up to 1120), buttons 340 wide.
     Body text inherits 15 (card titles and button labels 15/700); field values 14.
- **Components** As PermohonanSurat, with the web table for the list. Shared: platform web side nav.
- **Internal views and states** As PermohonanSurat (`{ k: null }`, five views).
- **Tweaks** `keadaan` (enum "Diajukan" · "Menerbitkan surat" · "Data jemaat tidak aktif" · "Diterbitkan" · "Tidak diterbitkan", default "Diajukan") · Keadaan panel. Same effects; resets `k`.
- **Interactions** As PermohonanSurat: "Pilih file" → Diterbitkan; "Tidak diterbitkan" → Tidak diterbitkan; "Pilih file salinan bertanda tangan" → Diterbitkan; "Buka salinan bertanda tangan" → no visible change; rows are self-links to `/WebPermohonanSurat` (no-op). Nav toggle at ≤860 px.
- **Motion** None. Keyframes `muncul`, `isi`, `titik` declared, unused.
- **Links out**
  - Breadcrumb "Dokumen gereja" → `/WebDokumenGereja`, up link.
  - Rows → own board (no-op). Side nav as WebKeadaanUmum, `go`.
  - **Inbound** PetaPlatform, WebAlurSurat, and the computed links (navigation.md 3.3) from WebBerandaJabatan, WebKotakMasuk and WebCariOrang.
- **Mock data** As PermohonanSurat.
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. `/WebPermohonanSurat` at 1440 → nav "Dokumen gereja" active; breadcrumb "Dokumen gereja"; one table with three rows, badge "Diajukan" right-aligned.
  2. `keadaan` "Menerbitkan surat" → request card left (about 608 wide), signed-copy card and "Tidak diterbitkan" right.
  3. "Pilih file" → Diterbitkan card full width with "No. 027/SKet/XI/2026 · 15/11/2026".
  4. "Tidak diterbitkan" (from Menerbitkan surat) → Ferry Wenas refusal card.
  5. Breadcrumb → `/WebDokumenGereja`.
  6. At 860 px → "Menu" top bar; in Menerbitkan surat the two columns stack; no horizontal scroll.
- **Notes** Same as PermohonanSurat.

### Pengumuman — 65 · Pengumuman
- **Source** `docs/design/handoff/canvas/boards/Pengumuman.dc.html` · page Putaran 3 · Sekretariat (`p3`) · form Phone 390×844 · interactive yes
- **Route** `/Pengumuman`, no child routes · **Widget** `PengumumanScreen` in `lib/screens/p3/pengumuman.dart`
- **Purpose** Sekretaris Jemaat, journey step 3 ("Pengumuman", before "Warta Jemaat · edisi 22/11/2026"); the Operator drafts. Announcements stand on their own; the Warta Jemaat takes from them (P17: the Sekretaris picks published announcements per edition, "Masuk ke Warta edisi 22/11/2026"). Shows: the Operator drafts, only the Sekretaris Jemaat publishes (authority by post); an optional end date after which the announcement archives itself and stays readable; a published announcement is corrected only as a revision (platform revision rule); Q30 audience "Pelayan dan pengurus"; P03 (unverified accounts still see announcements addressed to all members).
- **Shell** Phone header with back (shared phone frame), no tab bar, no `jabatanKosong`.
- **Layout**
  1. Header: back target, semantics "Kembali ke Beranda"; h1 "Pengumuman"; subtitle "Berdiri sendiri; Warta Jemaat mengambil dari sini".
  2. Scroll area (padding 8/20/20, column gap 16). Views:
     - **Daftar**: four phone list rows (DokumenGereja 2b):
       1. "Kerja bakti halaman gereja" / "Semua anggota · berakhir pada 20/11/2026" / ink badge "Diterbitkan"
       2. "Pendaftaran katekisasi sidi 2027" / "Semua anggota · tanpa tanggal berakhir" / dashed badge "Draf"
       3. "Rapat pelayan khusus" / "Pelayan dan pengurus · berakhir pada 25/11/2026" / dashed badge "Draf"
       4. "Latihan paduan suara Kolom 7" / "Kolom 7 · berakhir 15/11/2026" / grey badge "Diarsipkan"
       Then button row: ink button "Tulis pengumuman".
     - **Draf**: form card (solid card, column gap 12) with read-only fields (TerbitDokumen field pattern): "Judul" = "Kerja bakti halaman gereja"; "Isi" = text area (read-only, 3 rows, min-height 96, padding 12/14, radius 12, 1 px `garisTegas`, `permukaan`, no resize, 14 `tinta2`) "Sabtu, 21 November 2026 pukul 07.00. Membawa alat kebersihan masing-masing."; then a grid (auto-fit columns at least 300, gap 16; one column on the phone): "Ditujukan untuk" = "Semua anggota"; "Berakhir pada" = "20/11/2026" with hint 13 `tinta3` "Boleh kosong. Setelah tanggal ini pengumuman diarsipkan sendiri." Then caption 13 `tinta3` "Draf oleh Operator Yanti Sumual. Hanya Sekretaris Jemaat yang menerbitkan." Then button row: ink button "Terbitkan" and outline button "Simpan sebagai draf", side by side at 171 each.
     - **Diterbitkan**: solid card, column gap 6: top row "Kerja bakti halaman gereja" 16/700 and ink badge "Diterbitkan"; "Ditujukan untuk: Semua anggota · Berakhir pada 20/11/2026" 14 `tinta2`; "Diterbitkan oleh Olvie Pangemanan, 16/11/2026 08.15. Masuk ke Warta edisi 22/11/2026." 13 `tinta3`. Then button row (outside the card): outline button "Ralat".
     - **Diarsipkan sendiri**: dashed card, column gap 6: top row "Latihan paduan suara Kolom 7" 16/700 and grey badge "Diarsipkan"; "Berakhir pada 15/11/2026" 14 `tinta2`; "Diarsipkan sendiri pada tanggal berakhirnya. Tetap dapat dibaca di arsip." 13 `tinta3`. No buttons.
     - **Ralat sebagai revisi**: dashed banner (as TerbitDokumen): "**Ralat menjadi Revisi 2.** Revisi 1 tetap tampil sebagai “Digantikan oleh revisi 2”." (second sentence `tinta2`). Then a form card (column gap 12) with one field: "Isi" = text area "Sabtu, 21 November 2026 pukul 06.30. Membawa alat kebersihan masing-masing." Then button row: ink button "Terbitkan revisi 2" and text button "Batalkan", side by side at 171 each.
- **Components** Phone list row, LencanaStatus shapes (ink "Diterbitkan", dashed "Draf", grey "Diarsipkan"), GarisStatus (`dibukukan` list rows, form and published card; `draf` archived card and revision banner), Tombol (ink, outline, text), read-only fields and text area.
- **Internal views and states** Initial `{ k: null }`; view = `k ?? keadaan`. Five views: Daftar (tweak, "Simpan sebagai draf"); Draf (tweak, "Tulis pengumuman"); Diterbitkan (tweak, "Terbitkan", "Terbitkan revisi 2", "Batalkan"); Diarsipkan sendiri (tweak only); Ralat sebagai revisi (tweak, "Ralat").
- **Tweaks** `keadaan` (enum "Daftar" · "Draf" · "Diterbitkan" · "Diarsipkan sendiri" · "Ralat sebagai revisi", default "Daftar") · Keadaan panel. Each option shows the view of the same name. Resets `k`.
- **Interactions**
  - "Tulis pengumuman" (Daftar) → `k = 'Draf'` (the form opens pre-filled with Yanti Sumual's draft).
  - "Terbitkan" (Draf) → `k = 'Diterbitkan'`.
  - "Simpan sebagai draf" (Draf) → `k = 'Daftar'`.
  - "Ralat" (Diterbitkan) → `k = 'Ralat sebagai revisi'`.
  - "Terbitkan revisi 2" (Ralat) → `k = 'Diterbitkan'`.
  - "Batalkan" (Ralat) → `k = 'Diterbitkan'`.
  - List rows → self-links: no navigation, no state change.
  - No typed input, no validation, no timers.
- **Motion** None. Keyframes `masuk`, `pudar`, `muncul`, `isi` declared, unused.
- **Links out**
  - Back arrow (semantics "Kembali ke Beranda") → `/BerandaJabatan`, up link.
  - Rows → own board (no-op).
  - **Inbound** PetaPlatform, and the computed links (navigation.md 3.3) from BerandaJabatan (rows "2 pengumuman masih Draf", "1 pengumuman berakhir pada 20/11/2026", "2 pengumuman untuk Kolom 7") and KotakMasuk (row "Pengumuman “Kerja bakti” berakhir 20/11/2026"); all push.
- **Mock data** Announcements: "Kerja bakti halaman gereja" (Semua anggota, ends 20/11/2026, published by Olvie Pangemanan 16/11/2026 08.15, in Warta edition 22/11/2026; text 07.00, corrected to 06.30 in Revisi 2); "Pendaftaran katekisasi sidi 2027" (Semua anggota, no end date, Draf); "Rapat pelayan khusus" (Pelayan dan pengurus, ends 25/11/2026, Draf); "Latihan paduan suara Kolom 7" (Kolom 7, ended 15/11/2026, Diarsipkan). Drafted by Operator Yanti Sumual. Share these with WebPengumuman (and the Warta boards, which pick from them) in `lib/mock/`.
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. `/Pengumuman` (default) → four row cards: "Kerja bakti halaman gereja" with ink "Diterbitkan", two rows with dashed "Draf", "Latihan paduan suara Kolom 7" with grey "Diarsipkan"; ink "Tulis pengumuman" at the end.
  2. Tap "Tulis pengumuman" → form with "Judul", "Isi", "Ditujukan untuk", "Berakhir pada" (stacked), caption "Draf oleh Operator Yanti Sumual. …", buttons "Terbitkan" and "Simpan sebagai draf" side by side.
  3. Tap "Simpan sebagai draf" → back to the list (same route).
  4. "Tulis pengumuman" → "Terbitkan" → card with ink "Diterbitkan" and "… Masuk ke Warta edisi 22/11/2026."; outline "Ralat".
  5. Tap "Ralat" → banner "Ralat menjadi Revisi 2." and "Isi" with "pukul 06.30"; "Batalkan" → Diterbitkan; "Ralat" → "Terbitkan revisi 2" → Diterbitkan.
  6. `keadaan` "Diarsipkan sendiri" → dashed card "Latihan paduan suara Kolom 7" + grey "Diarsipkan", no buttons.
  7. Tap a list row → nothing changes.
  8. Back arrow → `/BerandaJabatan`.
- **Notes**
  - Draft rows sit in solid-edged cards (`garis` line) with only the badge dashed; GarisStatus would draw a draft's card dashed. Keep the board.
  - The correction view has no "Yang diralat · wajib" field (TerbitDokumen has one); keep the board.
  - After "Terbitkan revisi 2" the published card shows no revision mark and the 07.00 text is not shown there; keep (the board has one published card).
  - "Tulis pengumuman" opens a draft attributed to the Operator, although the person acting is the Sekretaris; keep.
  - Field values inherit 14 px `tinta2`.

### WebPengumuman — Web · Pengumuman
- **Source** `docs/design/handoff/canvas/boards/WebPengumuman.dc.html` · page Putaran 3 · Sekretariat (`p3`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebPengumuman`, no child routes · **Widget** `WebPengumumanScreen` in `lib/screens/p3/web_pengumuman.dart`
- **Purpose** Same as Pengumuman at the Sekretaris desk, plus a preview of what members see while drafting (drafts are never visible to members; the preview equals what goes into the Warta Jemaat).
- **Shell** Platform web side nav as WebKeadaanUmum; active item **Pengumuman** (`aktif: 3`, a self-link here); footer "**Olvie Pangemanan** · Sekretaris Jemaat".
- **Layout**
  1. Title block: breadcrumb "Beranda"; h1 "Pengumuman"; subtitle "Berdiri sendiri; Warta Jemaat mengambil dari sini".
  2. Content column: max-width 1120, column gap 16. Views as Pengumuman with these differences:
     - **Daftar**: the four announcements in one web table (WebDokumenGereja 2b), badges as on the phone; then button row with ink "Tulis pengumuman" (340 wide).
     - **Draf**: two-column row, wrap, gap 20 vertical / 28 horizontal, top-aligned.
       - Left: flex 1.3 1 420, min-width 0, column gap 12 (about 608 wide at 1440): the form card (card inner about 574, so "Ditujukan untuk" and "Berakhir pada" stack in one column), the caption "Draf oleh Operator Yanti Sumual. Hanya Sekretaris Jemaat yang menerbitkan.", the button row "Terbitkan" (ink) + "Simpan sebagai draf" (outline), about 300 each.
       - Right: flex 1 1 340, min-width 0, column gap 12 (about 484 at 1440): h2 "Yang dilihat anggota" `judulBagian` 16/700; solid card, column gap 6: top row "Kerja bakti halaman gereja" 15/700 and dashed badge "Belum diterbitkan"; "Sabtu, 21 November 2026 pukul 07.00. Membawa alat kebersihan masing-masing." 14 `tinta2`; "Ditujukan untuk: Semua anggota · tampil sampai 20/11/2026" 13 `tinta3`. Then caption 13 `tinta3` "Sama seperti yang masuk ke Warta Jemaat. Draf tidak pernah terlihat anggota."
       - The columns stack when the content is narrower than 788.
     - **Diterbitkan**, **Diarsipkan sendiri**, **Ralat sebagai revisi**: single column as the phone, cards full content width (up to 1120), buttons up to 340 wide.
     Body text inherits 15 (card titles and button labels 15/700); field values 14.
- **Components** As Pengumuman, with the web table for the list and a preview card with the dashed badge "Belum diterbitkan". Shared: platform web side nav.
- **Internal views and states** As Pengumuman (`{ k: null }`, five views).
- **Tweaks** `keadaan` (enum "Daftar" · "Draf" · "Diterbitkan" · "Diarsipkan sendiri" · "Ralat sebagai revisi", default "Daftar") · Keadaan panel. Same effects; resets `k`.
- **Interactions** As Pengumuman: "Tulis pengumuman" → Draf; "Terbitkan" → Diterbitkan; "Simpan sebagai draf" → Daftar; "Ralat" → Ralat sebagai revisi; "Terbitkan revisi 2" and "Batalkan" → Diterbitkan; rows are self-links to `/WebPengumuman` (no-op). Nav toggle at ≤860 px.
- **Motion** None. Keyframes `muncul`, `isi`, `titik` declared, unused.
- **Links out**
  - Breadcrumb "Beranda" → `/WebBerandaJabatan`, up link.
  - Rows and the active nav item → own board (no-op). Side nav as WebKeadaanUmum, `go`.
  - **Inbound** PetaPlatform, WebAkunSaya, WebAlurDokumen, WebAlurJabatanKosong, WebAlurKeluarga, WebAlurMasuk, WebAlurPengembalian, WebAlurPulihkan, WebAlurSurat, WebAlurUnit, WebAlurWarta, WebBerandaJabatan, WebBukaNama, WebCariOrang, WebDataAnggota, WebDataGanda, WebDokumenGereja, WebImporBuku, WebJabatanKosong, WebKasUnit, WebKeadaanUmum, WebKotakMasuk, WebLaporanLintas, WebPenugasan, WebPermohonanSurat, WebPersembahanBernama, WebSelesaikanUnit, WebTerbitDokumen, WebWartaArsip, WebWartaEditor (most through the platform side nav).
- **Mock data** As Pengumuman; preview "tampil sampai 20/11/2026".
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. `/WebPengumuman` at 1440 → nav "Pengumuman" filled `tinta`; table with four rows; ink "Tulis pengumuman" 340 wide.
  2. "Tulis pengumuman" → form left with stacked "Ditujukan untuk"/"Berakhir pada"; right "Yang dilihat anggota" with dashed "Belum diterbitkan" and the announcement text.
  3. "Terbitkan" → single full-width card with ink "Diterbitkan" and outline "Ralat".
  4. "Ralat" → revision banner and "Isi" with "pukul 06.30"; "Terbitkan revisi 2" → Diterbitkan.
  5. "Simpan sebagai draf" (from Draf) → table again.
  6. Breadcrumb "Beranda" → `/WebBerandaJabatan`; nav "Dokumen gereja" → `/WebDokumenGereja`.
  7. At 860 px → "Menu" top bar; in Draf the preview column sits under the form; no horizontal scroll.
- **Notes** Same as Pengumuman. Breadcrumb "Beranda" with the nav item "Pengumuman" active; keep.
