# Screens 20: KonfirmasiKeluarga, AntreanVerifikasi, DataAnggota, WebDataAnggota, Peristiwa, TampilanNama, CabutIzin, DataGanda, WebDataGanda, PersembahanSaya

These ten boards are the member-data module on the canvas page "Putaran 4 · Data jemaat" (`p4`), titles 74 to 81 plus two laptop pairs. **DataAnggota** / **WebDataAnggota** (76) is the hub: one person's record (Novita Wenas: family, birth date, marital status, display name, the BIPRA category the app computes, Kolom history, life events) as the Penatua Kolom 7 sees it, plus the read-only view of the Sekretaris Jemaat, a record still "Belum dikonfirmasi", a deceased member and the refusal for another Kolom. From it the Penatua opens **Peristiwa** (77, "Ajukan peristiwa": submit, submitted, verified, returned, death, Kolom move) and **KonfirmasiKeluarga** (74, a family imported from the paper book confirms its data and gives consent in the app or on a signed paper form, then the Penatua verifies it). **AntreanVerifikasi** (75) is the Penatua's queue; its rows open PermohonanAnggota, KonfirmasiKeluarga and Peristiwa, and it shows the "returned with reason" case, the own-family refusal, the Operator running the vacant Penatua Kolom 2 post and the empty queue. The member's own screens are **TampilanNama** (78, how my name appears in publications), **CabutIzin** (79, withdraw consent and delete my data, including a paper request the Penatua confirms) and **PersembahanSaya** (81, only the gifts recorded in my name); PersembahanSaya links to TampilanNama. **DataGanda** / **WebDataGanda** (80) is the Operator's comparison of two records that may be the same person, opened from the paper-book import. Every phone board has the plain phone header with a back arrow and no tab bar: DataAnggota and PersembahanSaya go back to `/BerandaJabatan`, the other six phone boards go back to `/DataAnggota`. The two laptop boards use the platform web side nav with "Data jemaat" active. Common rules for all ten: the board state is only `{ k: null }`; the view shown is `k ?? keadaan` (the panel's tweak value); in-board buttons set `k` to one of the tweak's options and never move the panel's value; `k` survives while the board stays in the navigation stack (Back returns to the same view) and resets to null when the board leaves the stack or when `keadaan` is changed in the Keadaan panel. Views change in place under the same header, so no board here has child routes, and on every view change the scroll area jumps to the top (as recommended in `14-berandajabatan.md`). No board here has typed input (every field is read-only, as drawn), a timer, a running animation, the `jabatanKosong` tweak or a prototype-only device. "Up link" means the phone back arrow, the web breadcrumb, and any button this file names as one: it pops when its target, or one of the target's child routes, is the route directly beneath; otherwise it does `go` to the target. Drill-ins into other boards are `push`; side-nav items are `go`. Every navigating control is built with `Tautan(ke: '<Stem>')`. Today is 16/11/2026 on every board (some result views are dated 17/11/2026, as drawn).

## Shared parts (exact board values, used by every board below)

- **Phone frame**: 390 × 844, `kertas` field, `tinta` text, `isi` 16 / line-height 1.4. A column: fixed header, then a scroll area filling the rest. No tab bar, no bottom bar.
  - Header (does not scroll, no fill, no rule): row, centred vertically, gap 8, padding 14 top / 12 sides / 8 bottom. Back target 44 × 44 with a centred chevron-left 22 px (SVG path `M15 6l-6 6 6 6`, viewBox 24, stroke `tinta` width 2, round caps), Semantics label per board, built with `Tautan`. Title column (flex 1): h1 `judulLayar` 18/700, margin 0 (long titles wrap to two lines; let them); under it the subtitle 13 `tinta2` (the board writes `font-size: 14px` then `13px`; 13 wins).
  - Scroll area: vertical scroll, padding 8 top / 20 sides / 20 bottom, one column with gap **16** between every direct item (content width 350). Every block named in a Layout list below is a direct item, so blocks are always 16 apart.
- **Platform web side nav** (WebDataAnggota, WebDataGanda): exactly the platform variant specified under WebBerandaJabatan in `14-berandajabatan.md` (nav 220, `permukaan`, right rule `garis`, logo row, items min-height 44 / padding 0 12 / radius 10 / 600, active `tinta` field with `permukaan` text, footer at the bottom with a top rule, 13 `tinta2` with the name in 700 `tinta`; at 860 px and narrower (the boards' `@media (max-width:860px)`, so 860 itself is collapsed) the nav becomes a top bar with the "Menu" / "Tutup menu" toggle). Items, in this order, all `go`: "Beranda" → `/WebBerandaJabatan`, "Keuangan" → `/WebBeranda`, "Dokumen gereja" → `/WebDokumenGereja`, "Pengumuman" → `/WebPengumuman`, "Warta Jemaat" → `/WebWartaArsip`, "Data jemaat" → `/WebDataAnggota`, "Ibadah dan kegiatan" → `/Ibadah`, "Panitia" → `/Panitia`, "Pemberitahuan" → `/WebKotakMasuk`, "Pengaturan" → `/WebPenugasan`. On both boards the active item is **Data jemaat** (index 5). Footers differ per board.
- **Web main column**: flex 999 1 560, min-width 0, padding 28 top / clamp(16, 3 vw, 40) sides / 40 bottom, column gap 20, `isiWeb` 15 / line-height 1.45. First child the title block: breadcrumb text link 14/600 `laut`, underlined, `lautTua` on hover/press; h1 `judulHalaman` 26/700, margin-top 2; subtitle 14 `tinta2`. Second child the content column: max-width **880**, left-aligned, column gap 16. On web every "body size" below is 15 instead of 16.
- **Card** (GarisStatus `dibukukan`): `permukaan`, 1 `garis` edge, radius 14 (`kartu`), padding 14 top/bottom × 16 sides, column gap 6.
  - *Head row*: space-between, centred, gap 16. Title 700 body size `tinta` (it may wrap); badge on the right, never shrinks or wraps.
  - *Info row*: space-between, gap 16, 14 px. Label `tinta2` left; value right-aligned 600 `tinta`.
  - *Line 14*: 14 `tinta2` (`pendamping`). *Line 13*: 13 `tinta3` (`keterangan`).
- **Dashed card** (GarisStatus `draf`): 1.5 dashed `putus` edge (shared dash painter), radius 14, padding 14 × 16, column gap 6, no fill (`kertas` shows through).
- **Notice box, outlined** (GarisStatus `terpilih`): 1.5 solid `tinta` edge, radius 12 (`isian`), `permukaan`, padding 12 × 14, 14 px `tinta`, lead phrase in 700.
- **Notice box, soft**: `lautLembut` field, no edge, radius 12, padding 12 × 14, 14 px `tinta`, lead phrase in 700.
- **Badge** (LencanaStatus shape; the boards' `LS` table): 13/700, radius 6 (`lencana`), padding 3 × 9, 1.5 line, never shrinks. `draf`: dashed `putus` line, no field, `tinta2` text. `garis`: solid `tinta3` line, `permukaan` field, `tinta2` text. `tinta`: `tinta` field and line, `permukaan` text. `laut`: `laut` field and line, `diLaut` text. `bata`: solid `bata` line, `permukaan` field, `bata` text. `abu`: `garis` field and line, `tinta2` text. (`lautg` is in the table but unused in this file.)
- **Buttons** (Tombol; text inherits the body size, weight 700, centred, horizontal padding 16, labels wrap to centred lines):
  - Primary: min-height 52, radius 14, no line, `tinta` field, `permukaan` text.
  - Secondary: min-height 48, radius 14, 1.5 `tinta` line, `permukaan` field, `tinta` text.
  - Text: min-height 44, no line, no field, `laut` text.
  - Disabled look (CabutIzin only): min-height 52, radius 14, no line, `garis` field, `tinta2` text.
  - Link-buttons (an `<a>` drawn as a button) look exactly like the button they copy, no underline.
  - *Button row*: wrap, gap 8 both ways, left-aligned. Each button is `flex: 1 1 150px; max-width: 340px`: at least 150 wide, buttons on one line share it equally, none wider than 340. On the phone (350): one button is 340 wide; two share a line at 171 each; a third wraps to its own line at 340. Buttons on the same line stretch to the tallest one (a secondary next to a primary is 52 tall). On web (880): two buttons are 340 each.
- **Row card** (AntreanVerifikasi; same as BerandaJabatan's row card): a full-width pressable link. `permukaan`, 1 `garis`, radius 14, padding 12 × 16, min-height 44, row, centred, gap 12, no underline. Text column (flex 1, min-width 0, gap 2): title 16/600 `tinta`, subtitle 13 `tinta3` (both wrap). Optional badge. Then a chevron 18 px (path `M9 6l6 6-6 6`, stroke `tinta3` 2, round caps).
- **Read-only field** (Peristiwa, AntreanVerifikasi, PersembahanSaya): a label column, gap 6: label 14 `tinta2`; box full width, radius 12, 1 `garisTegas` edge, `permukaan`. Single line: min-height 48, padding 0 14, text vertically centred. Multi-line (textarea): min-height 96 (3 rows), padding 12 × 14, wraps. The value text inherits the label's style: **14 px `tinta2`** (the board sets `font: inherit; color: inherit`). Not editable (the boards mark them `readonly`): no caret, no keyboard; focusable and selectable like a read-only input. Semantics: label + value, read-only.
- **Refusal line** (Penolakan), as drawn on these boards: one paragraph, **15 px**: "Tidak dapat dilakukan: ‹tindakan›." bold 700 `bata`, a space, then the reason 400 `tinta`.

---

### KonfirmasiKeluarga — 74 · Konfirmasi keluarga
- **Source** `docs/design/handoff/canvas/boards/KonfirmasiKeluarga.dc.html` · page Putaran 4 · Data jemaat (`p4`) · form Phone 390×844 · interactive yes
- **Route** `/KonfirmasiKeluarga`, no child routes (the four `keadaan` views change in place) · **Widget** `KonfirmasiKeluargaScreen` in `lib/screens/p4/konfirmasi_keluarga.dart`
- **Purpose** Penatua Kolom (journey step 1: "Verifikasi data", "Konfirmasi keluarga", "Data anggota dan keluarga") and Operator (BerandaJabatan's "4 formulir kertas belum dimasukkan" opens this board). A family imported from the paper member book stays out of every publication until it confirms its data and gives consent (Izin) — in the app by the Wakil keluarga, or on a signed paper form the Operator enters for a family without a phone — and the Penatua Kolom 7 verifies it. Shows the platform rules "Anyone Belum dikonfirmasi never appears in a publication" and "Filling in is not verifying", Q28 (the consent text is versioned: "naskah versi 1"), and that after verification names follow the chosen Tampilan nama.
- **Shell** Phone header with back, no tab bar. Back semantics "Kembali ke Data jemaat" → `/DataAnggota` (up link).
- **Layout**
  1. Header: h1 "Konfirmasi keluarga"; subtitle "Keluarga dari buku anggota mengonfirmasi datanya dan memberi izin".
  2. Scroll area, per view:
     - **"Belum dikonfirmasi"** (k0):
       a. Card: head "Keluarga Wenas-Lasut" + badge `draf` "Belum dikonfirmasi"; line 14 "Kolom 7 · 4 orang: Ferry, Agustina, Novita, Gabriel"; line 13 "Diimpor 12/11/2026 dari buku anggota. Tidak tampil di Warta, surat atau laporan mana pun."
       b. Line 14 `tinta2`: "Dua jalan konfirmasi:"
       c. Button row: two **secondary** buttons, 171 each on one line: "Keluarga mengonfirmasi di aplikasi" and "Unggah formulir kertas bertanda tangan". Each label wraps to about three centred lines; both buttons take the taller height.
     - **"Dikonfirmasi di aplikasi"** (k1):
       a. Card: head "Keluarga Wenas-Lasut" + badge `garis` "Menunggu verifikasi"; line 14 "Kolom 7 · 4 orang: Ferry, Agustina, Novita, Gabriel"; line 13 "Wakil keluarga Agustina Lasut mengonfirmasi data 4 orang dan memberi izin, 16/11/2026 19.30."
       b. Line 13 `tinta3`: "Berikutnya: verifikasi Penatua Kolom 7."
       c. Button row: **primary** "Verifikasi data" and **secondary link-button** "Kembalikan dengan alasan", 171 each, both 52 tall.
     - **"Formulir kertas diunggah"** (k2):
       a. Card: head "Keluarga Wenas-Lasut" + badge `garis` "Menunggu verifikasi"; line 14 "Kolom 7 · 4 orang: Ferry, Agustina, Novita, Gabriel"; line 13 "Formulir kertas bertanda tangan diunggah Pnt. Hendrik Rumagit, 16/11/2026. Dimasukkan oleh Operator Yanti Sumual untuk keluarga tanpa ponsel."
       b. Card: head "formulir-wenas-lasut.jpg" (700, sans) + badge `garis` "Terlampir"; line 13 "Memuat izin penggunaan data pribadi naskah versi 1."
       c. Button row: **primary** "Verifikasi data", 340 wide.
     - **"Aktif"** (k3):
       a. Card: head "Keluarga Wenas-Lasut" + badge `laut` "Aktif"; line 14 "Kolom 7 · 4 orang: Ferry, Agustina, Novita, Gabriel"; line 13 "Diverifikasi oleh Pnt. Hendrik Rumagit, 17/11/2026 19.05. Sejak sekarang nama keluarga dapat tampil sesuai Tampilan nama yang dipilih."
       b. Button row: **secondary link-button** "Buka data keluarga", 340 wide.
- **Components** LencanaStatus (badges `draf`, `garis`, `laut`), GarisStatus (`dibukukan` cards), Tombol (primary, secondary, secondary as link). Patterns: card with head row, button row.
- **Internal views and states** Initial state `{ k: null }`. View = `k ?? keadaan`: k0 "Belum dikonfirmasi" (initial), k1 "Dikonfirmasi di aplikasi", k2 "Formulir kertas diunggah", k3 "Aktif". No sheets, toasts, banners, empty states or typed input.
- **Tweaks** `keadaan` (enum; options "Belum dikonfirmasi", "Dikonfirmasi di aplikasi", "Formulir kertas diunggah", "Aktif"; default "Belum dikonfirmasi") · Keadaan panel. Each option shows the view of the same name (Layout 2); changing it resets `k`. Global `jabatanKosong`: no effect.
- **Interactions**
  - "Keluarga mengonfirmasi di aplikasi" (`go1`) → `k = 'Dikonfirmasi di aplikasi'`: the k1 view shows at once (stands for the Wakil keluarga confirming on her own phone; no timer). Scroll to top.
  - "Unggah formulir kertas bertanda tangan" (`go2`) → `k = 'Formulir kertas diunggah'`: k2 view at once (no file picker, no upload timer).
  - "Verifikasi data" (`go3`, in k1 and k2) → `k = 'Aktif'`: k3 view. Nothing else is recorded.
  - "Kembalikan dengan alasan" (k1) → push `/AntreanVerifikasi` (it opens on that board's own panel value, default "Antrean"; it does not pre-select AntreanVerifikasi's "Kembalikan dengan alasan" view). Back returns here, still in k1.
  - "Buka data keluarga" (k3) → `/DataAnggota`, up link (same target as the back arrow).
  - Back arrow → `/DataAnggota`, up link.
- **Motion** None. Keyframes `masuk`, `pudar`, `muncul`, `isi` are declared but no element uses them; view swaps are instant. Route transitions use the app default (motion.md). Focus ring per CONVENTIONS.
- **Links out** Back arrow ("Kembali ke Data jemaat") → `/DataAnggota`, up link. "Kembalikan dengan alasan" → `/AntreanVerifikasi`, push. "Buka data keluarga" → `/DataAnggota`, up link. **Inbound** DataAnggota, ImporBuku, PetaPlatform, WebDataAnggota, WebImporBuku; also the BerandaJabatan/WebBerandaJabatan rows "12 anggota Kolom 7 belum dikonfirmasi" and "4 formulir kertas belum dimasukkan", the CariOrang/WebCariOrang row "Ferry Wenas" and the AntreanVerifikasi row "Konfirmasi keluarga · Wenas-Lasut" (built in logic, not in the manifest; `navigation.md` 3.3).
- **Mock data** Keluarga Wenas-Lasut, Kolom 7, 4 orang: Ferry, Agustina, Novita, Gabriel; imported 12/11/2026 from the member book. Wakil keluarga Agustina Lasut confirmed data of 4 people and gave consent 16/11/2026 19.30. Paper form uploaded by Pnt. Hendrik Rumagit 16/11/2026, entered by Operator Yanti Sumual; file "formulir-wenas-lasut.jpg", consent text "naskah versi 1". Verified by Pnt. Hendrik Rumagit 17/11/2026 19.05. Keep in `lib/mock/seed_jemaat.dart` (`mock-data.md` 2.18) with the other boards of this file.
- **Prototype-only** None on the board. The two k0 buttons stand for events on another device or on paper, but they are not "Contoh:" buttons, so they stay on screen as drawn. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/KonfirmasiKeluarga` with defaults → header "Konfirmasi keluarga"; card "Keluarga Wenas-Lasut" with a dashed badge "Belum dikonfirmasi"; "Dua jalan konfirmasi:" above two outlined buttons side by side.
  2. Tap "Keluarga mengonfirmasi di aplikasi" → badge "Menunggu verifikasi" with a solid `tinta3` edge; line "Wakil keluarga Agustina Lasut mengonfirmasi data 4 orang dan memberi izin, 16/11/2026 19.30."; caption "Berikutnya: verifikasi Penatua Kolom 7."; a dark "Verifikasi data" and an outlined "Kembalikan dengan alasan", equal height.
  3. Then tap "Verifikasi data" → badge "Aktif" on `laut`; line starting "Diverifikasi oleh Pnt. Hendrik Rumagit, 17/11/2026 19.05."; one outlined button "Buka data keluarga" 340 wide. The panel still reads "Belum dikonfirmasi".
  4. Panel `keadaan` = "Formulir kertas diunggah" → two cards; the second titled "formulir-wenas-lasut.jpg" with badge "Terlampir" and "Memuat izin penggunaan data pribadi naskah versi 1."; one dark button "Verifikasi data".
  5. In k1 tap "Kembalikan dengan alasan" → `/AntreanVerifikasi` opens (pushed); system Back returns here, still showing "Menunggu verifikasi" with the app line.
  6. In k3 tap "Buka data keluarga" → `/DataAnggota`.
  7. After any in-board change, set the panel to "Aktif" → the Aktif view shows (`k` was reset).
  8. Back arrow (semantics "Kembali ke Data jemaat") → `/DataAnggota`.
- **Notes** The k0 card is a solid `dibukukan` card although its badge is `draf`, while DataAnggota draws Ferry Wenas's unconfirmed record as a dashed card; keep each board. Primary "Verifikasi data" uses `tinta`, not the `laut` primary of Tombol; keep the board (same choice as `14-berandajabatan.md`). k2 says the form was "diunggah Pnt. Hendrik Rumagit" and "Dimasukkan oleh Operator Yanti Sumual" in the same line; copy verbatim. The Aktif date 17/11/2026 is one day after "today"; copy. The head row "Keluarga Wenas-Lasut" next to the 150 px badge wraps to two lines; let it. `rp()` and `baris()` are defined and unused. Manifest `hasSideNav: true` is a false positive (the class only checks `navVals`).

### AntreanVerifikasi — 75 · Verifikasi data
- **Source** `docs/design/handoff/canvas/boards/AntreanVerifikasi.dc.html` · page Putaran 4 · Data jemaat (`p4`) · form Phone 390×844 · interactive yes
- **Route** `/AntreanVerifikasi`, no child routes · **Widget** `AntreanVerifikasiScreen` in `lib/screens/p4/antrean_verifikasi.dart`
- **Purpose** Penatua Kolom 7 Pnt. Hendrik Rumagit (journey step 1, "Verifikasi data"; reached from BerandaJabatan's "5 data menunggu verifikasi"). The verification queue of his Kolom only. Shows the platform rules "A Penatua Kolom sees only their Kolom" and "no one verifies their own submission or their own family's" (the own-family case goes to the Syamas; P09's spirit), P12 (a reason is required to return a case), and the Operator visibly running the vacant Penatua Kolom 2 post (PitaJabatanKosong).
- **Shell** Phone header with back, no tab bar. Back semantics "Kembali ke Data jemaat" → `/DataAnggota` (up link).
- **Layout**
  1. Header: h1 "Verifikasi data"; subtitle "Hanya data Kolom 7; milik keluarga sendiri pergi ke Syamas".
  2. Scroll area, per view:
     - **"Antrean"** (k0): five row cards (shared Row card), 16 apart, then a caption. Rows (title · subtitle · badge (style) · target):
       1. "Permohonan menjadi anggota · Novita Wenas" · "Diajukan 16/11/2026 · izin data pribadi diberikan" · "Diajukan" (`garis`) · `/PermohonanAnggota`
       2. "Konfirmasi keluarga · Wenas-Lasut" · "4 orang dari buku anggota" · "Diajukan" (`garis`) · `/KonfirmasiKeluarga`
       3. "Peristiwa: Baptisan · Gabriel Wenas" · "Diajukan 15/11/2026" · "Diajukan" (`garis`) · `/Peristiwa`
       4. "Peristiwa: Pindah Kolom · Keluarga Lasut" · "Dari Kolom 4 ke Kolom 7 · berlaku 01/12/2026" · "Diajukan" (`garis`) · `/Peristiwa`
       5. "Perubahan data · Keluarga Rumagit" · "Milik keluarga Anda sendiri · diteruskan ke Syamas Kolom 7" · "Ke Syamas" (`abu`) · this board (see Interactions)
       Caption 13 `tinta3`: "Anda melihat data lengkap hanya untuk anggota dan keluarga Kolom 7, serta permohonan pindah ke Kolom 7."
     - **"Kembalikan dengan alasan"** (k1):
       a. Card: head "Peristiwa: Baptisan · Gabriel Wenas" + badge `garis` "Diajukan"; line 14 "Diajukan Novita Wenas, 15/11/2026"; info rows "Tanggal baptisan" | "08/11/2026", "Lampiran" | "surat-baptis.jpg".
       b. Read-only multi-line field, label "Alasan · wajib", value "Nama di surat baptis “Gabriel J. Wenas”; mohon samakan." (14 `tinta2`, min-height 96).
       c. Button row: **primary** "Kembalikan" and **secondary** "Verifikasi data" share line 1 (171 each, both 52 tall); **text** button "Tidak diterima" on line 2, 340 wide, 44 tall.
     - **"Milik keluarga sendiri"** (k2):
       a. Card: head "Perubahan data · Keluarga Rumagit" + badge `garis` "Diajukan"; line 14 "Diajukan Pnt. Hendrik Rumagit, 14/11/2026".
       b. Refusal line (15 px): "**Tidak dapat dilakukan: Verifikasi data.**" then "ini data keluarga Anda sendiri." (lower-case "ini", as drawn).
       c. Line 13 `tinta3`: "Diteruskan kepada Sym. Greis Mamahit, Syamas Kolom 7. Mengisi sendiri bukan berarti memverifikasi sendiri."
       No buttons.
     - **"Jabatan kosong"** (k3):
       a. PitaJabatanKosong banner: `tinta` field, `permukaan` text, radius 14, padding 12 × 14, 14 px, no edge: "**Penatua Kolom 2: jabatan kosong.**" then, in `diTinta2`, "Verifikasi Kolom 2 dijalankan Operator Yanti Sumual sampai ada pemegang jabatan."
       b. Two row cards:
          1. "Permohonan menjadi anggota · Kevin Rompas" · "Kolom 2 · diajukan 15/11/2026" · "Diajukan" (`garis`) · `/PermohonanAnggota`
          2. "Peristiwa: Kematian · Yohanis Rompas" · "Kolom 2 · diajukan keluarga 16/11/2026" · "Diajukan" (`garis`) · `/Peristiwa`
       No caption.
     - **"Tidak ada yang menunggu"** (k4): Dashed card: "Tidak ada data yang menunggu verifikasi" (700 body size); line 14 `tinta2` "Permohonan, perubahan data dan peristiwa dari Kolom 7 akan muncul di sini."
- **Components** LencanaStatus (`garis` "Diajukan", `abu` "Ke Syamas"), Penolakan (k2), PitaJabatanKosong (k3 banner), IsianAlasan (k1, read-only), Tombol (primary, secondary, text), GarisStatus (`dibukukan` cards and rows, `draf` empty state). Pattern: Row card list.
- **Internal views and states** Initial state `{ k: null }`. View = `k ?? keadaan`: k0 "Antrean" (initial), k1 "Kembalikan dengan alasan", k2 "Milik keluarga sendiri", k3 "Jabatan kosong", k4 "Tidak ada yang menunggu" (the empty state). The reason field is read-only and pre-filled. No sheets, toasts or timers.
- **Tweaks** `keadaan` (enum; options "Antrean", "Kembalikan dengan alasan", "Milik keluarga sendiri", "Jabatan kosong", "Tidak ada yang menunggu"; default "Antrean") · Keadaan panel. Each option shows the view of the same name; changing it resets `k`. Global `jabatanKosong`: no effect (the k3 banner is part of the view, not the global switch).
- **Interactions**
  - Rows 1–4 (k0) and both rows (k3) → push their target board (Links out). No state change.
  - Row 5 "Perubahan data · Keluarga Rumagit" (k0): its link points to this same board (`navigation.md` kind self). Build it as `Tautan(ke: 'AntreanVerifikasi')` with an in-board effect. Recommended: pressing it sets `k = 'Milik keluarga sendiri'` (the view drawn for exactly this case) and scrolls to top; no route is pushed. See Notes.
  - "Kembalikan", "Verifikasi data", "Tidak diterima" (k1, all `go0`) → `k = 'Antrean'`: the queue shows at once. Nothing is recorded, the queue still lists five rows, no message.
  - Back arrow → `/DataAnggota`, up link.
- **Motion** None. Declared and unused: `masuk`, `pudar`, `muncul`, `isi`. View swaps are instant.
- **Links out** Back arrow ("Kembali ke Data jemaat") → `/DataAnggota`, up link. Rows (built in the logic class with `hal()`, phone targets because `web = false`; push): "Permohonan menjadi anggota · Novita Wenas" → `/PermohonanAnggota`; "Konfirmasi keluarga · Wenas-Lasut" → `/KonfirmasiKeluarga`; "Peristiwa: Baptisan · Gabriel Wenas" → `/Peristiwa`; "Peristiwa: Pindah Kolom · Keluarga Lasut" → `/Peristiwa`; "Perubahan data · Keluarga Rumagit" → self (see Interactions); "Permohonan menjadi anggota · Kevin Rompas" → `/PermohonanAnggota`; "Peristiwa: Kematian · Yohanis Rompas" → `/Peristiwa`. **Inbound** KonfirmasiKeluarga, PetaPlatform; also the BerandaJabatan/WebBerandaJabatan row "5 data menunggu verifikasi" (built in logic).
- **Mock data** Queue of Kolom 7: Novita Wenas membership request 16/11/2026 (consent given); Keluarga Wenas-Lasut confirmation (4 people from the member book); Baptisan of Gabriel Wenas submitted 15/11/2026 by Novita Wenas, baptism date 08/11/2026, attachment "surat-baptis.jpg", return reason "Nama di surat baptis “Gabriel J. Wenas”; mohon samakan."; Pindah Kolom of Keluarga Lasut from Kolom 4 to Kolom 7, effective 01/12/2026; Perubahan data of Keluarga Rumagit submitted 14/11/2026 by Pnt. Hendrik Rumagit, forwarded to Sym. Greis Mamahit, Syamas Kolom 7. Kolom 2 (vacant Penatua Kolom 2, run by Operator Yanti Sumual): Kevin Rompas membership request 15/11/2026; Kematian of Yohanis Rompas submitted by the family 16/11/2026. BerandaJabatan counts this queue as "2 permohonan · 2 peristiwa · 1 perubahan data" while the board lists 1 permohonan, 1 konfirmasi keluarga, 2 peristiwa and 1 perubahan data; each board keeps its own figures, as board-local constants (this pair is not yet a row of `mock-data.md` section 3).
- **Prototype-only** None on the board. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/AntreanVerifikasi` with defaults → five row cards in the order listed, four with an outlined "Diajukan" badge and the last with a flat `abu` badge "Ke Syamas" (`garis` field and line, `tinta2` text), each with a chevron; caption "Anda melihat data lengkap hanya untuk anggota dan keluarga Kolom 7, serta permohonan pindah ke Kolom 7."
  2. Tap "Konfirmasi keluarga · Wenas-Lasut" → `/KonfirmasiKeluarga` pushed; Back returns to the queue.
  3. Tap "Peristiwa: Pindah Kolom · Keluarga Lasut" → `/Peristiwa` pushed.
  4. Tap "Perubahan data · Keluarga Rumagit" → same route; view shows the refusal "Tidak dapat dilakukan: Verifikasi data." in `bata` 700 followed by "ini data keluarga Anda sendiri." and the Syamas line.
  5. Panel "Kembalikan dengan alasan" → field "Alasan · wajib" shows "Nama di surat baptis “Gabriel J. Wenas”; mohon samakan." and cannot be edited; "Kembalikan" (dark) and "Verifikasi data" (outlined) share a line, "Tidak diterima" (`laut` text) below; tap "Tidak diterima" → the queue view.
  6. Panel "Jabatan kosong" → dark banner starting "Penatua Kolom 2: jabatan kosong." and two Kolom 2 rows; tap "Peristiwa: Kematian · Yohanis Rompas" → `/Peristiwa`.
  7. Panel "Tidak ada yang menunggu" → dashed card "Tidak ada data yang menunggu verifikasi" only.
  8. Back arrow → `/DataAnggota`.
- **Notes**
  - Row 5's link targets this same board (`r[4] = 'AntreanVerifikasi'`). On the canvas a press reloads the board, which resets `k` and shows the panel's value. The recommended behaviour (open the "Milik keluarga sendiri" view, whose card is this very case) is a deliberate deviation chosen so the own-family refusal is reachable by tapping, as the user asked for a fully navigable prototype. List it as a deviation in the review.
  - The row targets are built in the logic class; the manifest lists only `DataAnggota` for this board (its `jsLinks` is empty). `navigation.md` 3.3 adds them as computed links (PermohonanAnggota, KonfirmasiKeluarga, Peristiwa), which `gen_boards.py` merges into the board's out-links, so the link test does ask for them: wire every row with `Tautan(ke: …)` exactly as listed.
  - The refusal line is 15 px on a 16 px phone board (off-token; other Penolakan lines are 14). Copy 15. Penolakan says a refusal offers the available step; here the case is already forwarded, so there is none; keep.
  - The three k1 buttons record nothing; no feedback was drawn, so add none.
  - In k3 the header still says "Hanya data Kolom 7…" while the viewer is the Operator; keep the board.
  - `rp()` unused; manifest `hasSideNav` is a false positive.

### DataAnggota — 76 · Data anggota dan keluarga
- **Source** `docs/design/handoff/canvas/boards/DataAnggota.dc.html` · page Putaran 4 · Data jemaat (`p4`) · form Phone 390×844 · interactive yes
- **Route** `/DataAnggota`, no child routes · **Widget** `DataAnggotaScreen` in `lib/screens/p4/data_anggota.dart`
- **Purpose** Penatua Kolom 7 (journey step 1, "Data anggota dan keluarga") and, read-only, the Sekretaris Jemaat. One record per person; the family keeps its history. Shows the platform rules "A Penatua Kolom sees only their Kolom" and "The Sekretaris Jemaat reads Data jemaat without changing it", Q29 / P10 / P11 (BIPRA is computed from birth date and marital status, fixed by GMIM; the Penatua Kolom may correct one person with a recorded reason), Kolom history kept with end dates, that a deceased member is never deleted (the post becomes Jabatan kosong), and that an unconfirmed record appears nowhere else.
- **Shell** Phone header with back, no tab bar. Back semantics "Kembali ke Beranda" → `/BerandaJabatan` (up link).
- **Layout**
  1. Header: h1 "Data anggota dan keluarga"; subtitle "Satu data untuk setiap orang; keluarga menyimpan riwayatnya".
  2. Scroll area, per view:
     - **"Dilihat Penatua Kolom 7"** (k0): a grid `repeat(auto-fit, minmax(300px, 1fr))`, gap 16, items top-aligned; on the phone (350) it is one column, so the four cards stack 16 apart:
       a. *Person card*: head "Novita Wenas" + badge `laut` "Aktif"; info rows "Keluarga" | "Wenas-Lasut · Wakil keluarga: Agustina Lasut" (the value wraps, right-aligned), "Tanggal lahir" | "14/03/1996", "Status pernikahan" | "Belum pernah menikah", "Tampilan nama" | "Keluarga + Kolom".
       b. *BIPRA card*: title "Kategori BIPRA" (700, no badge on that line); head row "Pemuda" (600, not 700) + badge `garis` "Dihitung dari data"; line 13 "Dasar: 30 tahun dan belum pernah menikah."; line 13 "Anak: sampai sebelum 12 tahun. Remaja: 12 tahun sampai 17 tahun 364 hari. Pemuda: 18 tahun ke atas dan belum pernah menikah. Bapa atau Ibu: sudah menikah. Yang pernah menikah tetap Bapa atau Ibu; yang belum pernah menikah tetap Pemuda, berapa pun umurnya. Aturan ini dari ketentuan GMIM; gereja tidak mengubahnya."; line 13 "Penatua Kolom dapat mengoreksi kategori satu orang dengan alasan yang tercatat."
       c. *Kolom card*: title "Kolom" (700); info rows "Kolom 7" | "sejak 01/06/2021", "Kolom 4" | "12/02/2009 – 31/05/2021" (en dash with spaces); line 13 "Penugasan lama disimpan dengan tanggal berakhirnya. Transaksi lama tetap pada Lingkup aslinya."
       d. *Peristiwa card*: title "Peristiwa" (700); info rows "Baptisan" | "19/05/1996 · Diverifikasi", "Sidi" | "13/04/2014 · Diverifikasi", "Pernikahan" | "—"; then text link "Ajukan peristiwa": 14/700 `laut`, underlined (the global `a` style), `lautTua` on hover/press, min-height 44, text vertically centred and left-aligned, the target spans the card width.
     - **"Dilihat Sekretaris Jemaat"** (k1):
       a. Outlined notice box: "**Hanya baca.** Sekretaris Jemaat membaca seluruh Data jemaat untuk surat dan Warta, tetapi tidak mengubah atau memverifikasinya."
       b. The same four-card grid as k0, unchanged (including the "Ajukan peristiwa" link; see Notes).
     - **"Belum dikonfirmasi"** (k2):
       a. Dashed card: head "Ferry Wenas" + badge `draf` "Belum dikonfirmasi"; line 14 "Dari buku anggota Kolom 7 · diimpor 12/11/2026"; line 13 "Hanya Penatua Kolom 7 dan Operator yang melihat data ini. Tidak tampil di publikasi, surat, pencarian jabatan lain atau laporan."
       b. Button row: **secondary link-button** "Lihat konfirmasi keluarga", 340 wide.
     - **"Meninggal dunia"** (k3): Card: head "Yohanis Rompas" + badge `tinta` "Meninggal dunia"; line 14 "Kolom 2 · 03/02/1948 – 14/11/2026"; line 13 "Tidak pernah dihapus. Riwayat keluarga, jabatan, persembahan dan pelayanan tetap tersimpan. Akun dinonaktifkan, pemberitahuan dihentikan, dan jabatan Penatua Kolom 2 menjadi Jabatan kosong." No buttons.
     - **"Penatua Kolom lain"** (k4): Refusal line (15 px): "**Tidak dapat dilakukan: Buka data anggota.**" then "Novita Wenas bukan anggota Kolom Anda."; line 13 `tinta3` "Penatua Kolom melihat data lengkap hanya untuk Kolomnya sendiri. Yang sudah diterbitkan tetap dapat dibaca di Warta Jemaat." Nothing else.
- **Components** LencanaStatus (`laut` "Aktif", `garis` "Dihitung dari data", `draf` "Belum dikonfirmasi", `tinta` "Meninggal dunia"), GarisStatus (`dibukukan` cards, `draf` unconfirmed card, `terpilih` read-only notice), Penolakan (k4), Tombol (secondary link). Patterns: card with info rows, responsive card grid, in-card text link.
- **Internal views and states** Initial state `{ k: null }`. View = `k ?? keadaan`: k0 "Dilihat Penatua Kolom 7" (initial), k1 "Dilihat Sekretaris Jemaat", k2 "Belum dikonfirmasi", k3 "Meninggal dunia", k4 "Penatua Kolom lain". The board has no handlers that change `k` (no `goN` is bound), so only the panel changes the view.
- **Tweaks** `keadaan` (enum; options "Dilihat Penatua Kolom 7", "Dilihat Sekretaris Jemaat", "Belum dikonfirmasi", "Meninggal dunia", "Penatua Kolom lain"; default "Dilihat Penatua Kolom 7") · Keadaan panel. Each option shows the view of the same name (Layout 2). Global `jabatanKosong`: no effect.
- **Interactions** No state handlers. Links only:
  - "Ajukan peristiwa" (k0, k1) → push `/Peristiwa`.
  - "Lihat konfirmasi keluarga" (k2) → push `/KonfirmasiKeluarga`.
  - Back arrow → `/BerandaJabatan`, up link.
- **Motion** None. Declared and unused: `masuk`, `pudar`, `muncul`, `isi`.
- **Links out** Back arrow ("Kembali ke Beranda") → `/BerandaJabatan`, up link. "Ajukan peristiwa" → `/Peristiwa`, push. "Lihat konfirmasi keluarga" → `/KonfirmasiKeluarga`, push. **Inbound** AlurAnggota, AlurKeluarga, AlurNama, AlurPeristiwa, AntreanVerifikasi, CabutIzin, DataGanda, ImporBuku, KonfirmasiKeluarga, Peristiwa, PermohonanAnggota, PetaPlatform, TampilanNama; also the CariOrang rows "Novita Wenas" and "Keluarga Wenas-Lasut" (built in logic, not in the manifest; `navigation.md` 3.3).
- **Mock data** Novita Wenas: Aktif; Keluarga Wenas-Lasut, Wakil keluarga Agustina Lasut; born 14/03/1996; "Belum pernah menikah"; Tampilan nama "Keluarga + Kolom"; BIPRA Pemuda, computed ("Dasar: 30 tahun dan belum pernah menikah."); Kolom 7 since 01/06/2021, Kolom 4 from 12/02/2009 to 31/05/2021; Baptisan 19/05/1996 Diverifikasi, Sidi 13/04/2014 Diverifikasi, Pernikahan none ("—"). Ferry Wenas: Belum dikonfirmasi, from the Kolom 7 member book, imported 12/11/2026. Yohanis Rompas: Kolom 2, 03/02/1948 – 14/11/2026, Meninggal dunia, held Penatua Kolom 2 (now vacant). Share with WebDataAnggota (identical figures).
- **Prototype-only** None on the board ("Dilihat Penatua Kolom 7" / "Dilihat Sekretaris Jemaat" are tweak options, already in the panel). Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/DataAnggota` with defaults → four stacked cards: "Novita Wenas" with `laut` badge "Aktif", "Kategori BIPRA" with "Pemuda" and badge "Dihitung dari data", "Kolom" with "12/02/2009 – 31/05/2021", "Peristiwa" with "Pernikahan" | "—".
  2. Tap "Ajukan peristiwa" (underlined `laut`) → `/Peristiwa` pushed; Back returns here.
  3. Panel "Dilihat Sekretaris Jemaat" → an outlined box starting "Hanya baca." above the same four cards.
  4. Panel "Belum dikonfirmasi" → a dashed card "Ferry Wenas" with a dashed badge; tap "Lihat konfirmasi keluarga" → `/KonfirmasiKeluarga`.
  5. Panel "Meninggal dunia" → card "Yohanis Rompas" with a `tinta`-filled badge "Meninggal dunia" and "Kolom 2 · 03/02/1948 – 14/11/2026".
  6. Panel "Penatua Kolom lain" → only the refusal "Tidak dapat dilakukan: Buka data anggota." (`bata`, 700) + "Novita Wenas bukan anggota Kolom Anda." and the 13 px explanation.
  7. Back arrow (semantics "Kembali ke Beranda") → `/BerandaJabatan`.
- **Notes** The Sekretaris view (k1) keeps the "Ajukan peristiwa" link although the notice says "Hanya baca"; keep the board as drawn (the link only opens the Peristiwa board) and list it for review. Refusal 15 px on phone (off-token); copy. The `minmax(300px, 1fr)` grid is one column on the phone; build it once with WebDataAnggota (a wrap of cards, 2 columns when the content width is at least 616). `rp()` and `baris()` unused; manifest `hasSideNav` is a false positive.

### WebDataAnggota — Web · Data anggota dan keluarga
- **Source** `docs/design/handoff/canvas/boards/WebDataAnggota.dc.html` · page Putaran 4 · Data jemaat (`p4`) · form Laptop page (preview 1440×1050) · interactive yes
- **Route** `/WebDataAnggota`, no child routes · **Widget** `WebDataAnggotaScreen` in `lib/screens/p4/web_data_anggota.dart`
- **Purpose** Same as DataAnggota on the laptop. It is the "Data jemaat" side-nav target of every platform web board (30 inbound boards). Note the footer shows the Penatua Kolom 7, a phone post under Q26; the layout still opens on web (Q26: "its screens still open on web without a laptop layout"). Same rules and decisions as DataAnggota.
- **Shell** Platform web side nav (Shared parts), active item **Data jemaat**. Footer: "**Pnt. Hendrik Rumagit** · Penatua Kolom 7".
- **Layout** (main column)
  1. Title block: breadcrumb "Beranda" → `/WebBerandaJabatan` (up link); h1 "Data anggota dan keluarga"; subtitle 14 `tinta2` "Satu data untuk setiap orang; keluarga menyimpan riwayatnya".
  2. Content column (max-width 880, gap 16), views exactly as DataAnggota Layout 2 with web sizes (card titles and button text 15/700; info rows 14; lines 14 and 13; refusal 15; badges 13):
     - k0 / k1: the four-card grid is **two columns** at the drawn width: `repeat(auto-fit, minmax(300px, 1fr))`, gap 16, top-aligned (each card keeps its own height). Row 1: Person card | BIPRA card; row 2: Kolom card | Peristiwa card. At 1440 and 1280 the content column is 880, each column 432. Two columns whenever the content column is at least 616 wide (2 × 300 + 16), one column below; three columns never fit (932 > 880). At 860 (nav collapsed to the top bar) the content column is about 808, still two columns.
     - k1: the outlined "Hanya baca." notice spans the content column above the grid.
     - k2: dashed Ferry Wenas card (full content width), then the secondary link-button "Lihat konfirmasi keluarga", 340 wide, left-aligned.
     - k3: Yohanis Rompas card, full content width.
     - k4: refusal line and 13 px explanation.
- **Components** As DataAnggota, plus the platform side nav (shell).
- **Internal views and states** Initial state `{ k: null }`; views as DataAnggota (no bound handlers). Nav drawer open/closed (at 860 px and narrower only) is local UI state, closed on load.
- **Tweaks** `keadaan` (enum; same five options; default "Dilihat Penatua Kolom 7") · Keadaan panel; effects as DataAnggota. Global `jabatanKosong`: no effect.
- **Interactions** "Ajukan peristiwa" → push `/Peristiwa` (the phone board; it has no web layout). "Lihat konfirmasi keluarga" → push `/KonfirmasiKeluarga` (phone board). Breadcrumb "Beranda" → up link to `/WebBerandaJabatan`. Side-nav items → `go`; the active "Data jemaat" item targets this same board: stay, reset `k`, scroll to top. Menu toggle (at 860 px and narrower) opens and closes the drawer.
- **Motion** None. Declared and unused: `muncul`, `isi`, `titik`. The drawer opens instantly (a CSS checkbox swap, no transition).
- **Links out** Breadcrumb "Beranda" → `/WebBerandaJabatan`, up link. "Ajukan peristiwa" → `/Peristiwa`, push. "Lihat konfirmasi keluarga" → `/KonfirmasiKeluarga`, push. Side nav (go): Beranda → `/WebBerandaJabatan`, Keuangan → `/WebBeranda`, Dokumen gereja → `/WebDokumenGereja`, Pengumuman → `/WebPengumuman`, Warta Jemaat → `/WebWartaArsip`, Data jemaat → `/WebDataAnggota` (self), Ibadah dan kegiatan → `/Ibadah`, Panitia → `/Panitia`, Pemberitahuan → `/WebKotakMasuk`, Pengaturan → `/WebPenugasan`. **Inbound** PetaPlatform, WebAkunSaya, WebAlurDokumen, WebAlurJabatanKosong, WebAlurKeluarga, WebAlurMasuk, WebAlurPengembalian, WebAlurPulihkan, WebAlurSurat, WebAlurUnit, WebAlurWarta, WebBerandaJabatan, WebBukaNama, WebCariOrang, WebDataGanda, WebDokumenGereja, WebImporBuku, WebJabatanKosong, WebKasUnit, WebKeadaanUmum, WebKotakMasuk, WebLaporanLintas, WebPengumuman, WebPenugasan, WebPermohonanSurat, WebPersembahanBernama, WebSelesaikanUnit, WebTerbitDokumen, WebWartaArsip, WebWartaEditor.
- **Mock data** Identical to DataAnggota (shared constants).
- **Prototype-only** None. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/WebDataAnggota` at 1440 → side nav with "Data jemaat" on a `tinta` field and footer "Pnt. Hendrik Rumagit · Penatua Kolom 7"; breadcrumb "Beranda"; h1 "Data anggota dan keluarga".
  2. Defaults → two columns: "Novita Wenas" next to "Kategori BIPRA", "Kolom" next to "Peristiwa"; the content column is 880 wide, left-aligned.
  3. Tap "Ajukan peristiwa" → `/Peristiwa` (phone board in its device frame); Back returns.
  4. Panel "Belum dikonfirmasi" → "Lihat konfirmasi keluarga" 340 wide opens `/KonfirmasiKeluarga`.
  5. Panel "Penatua Kolom lain" → only the refusal and its explanation under the title block.
  6. Resize to 860 → nav becomes a top bar with "Menu"; tap → "Tutup menu" on a `tinta` field, the ten items and the footer show; the grid is still two columns.
  7. Resize to 600 → the grid is one column; no horizontal overflow.
  8. Side nav "Pemberitahuan" → `/WebKotakMasuk` (go); breadcrumb "Beranda" → `/WebBerandaJabatan`.
- **Notes** Web buttons and card titles inherit 15 px. Nav radius 10 is off-token; copy. The two in-content links lead to phone boards: they are literal hrefs `Peristiwa.dc.html` and `KonfirmasiKeluarga.dc.html` in the markup (not built with `hal()`, which would also keep both as phone boards). Same k1 "Hanya baca" / "Ajukan peristiwa" note as DataAnggota.

### Peristiwa — 77 · Peristiwa
- **Source** `docs/design/handoff/canvas/boards/Peristiwa.dc.html` · page Putaran 4 · Data jemaat (`p4`) · form Phone 390×844 · interactive yes
- **Route** `/Peristiwa`, no child routes · **Widget** `PeristiwaScreen` in `lib/screens/p4/peristiwa.dart`
- **Purpose** Anggota jemaat (journey step 3, "Peristiwa": a member or family submits a life event) and Penatua Kolom (journey step 2, the verifier side). An event changes the member record only after the Penatua Kolom verifies it. Shows P11 (a verified Pernikahan moves both spouses to Bapa and Ibu from the wedding date), that a birth is not automatically a baptism and an event is not automatically published in Warta Jemaat, that a death never deletes the person, never publishes the cause, and leaves the post vacant (not filled automatically), and that a Kolom move is verified by both Penatua Kolom and does not move posts.
- **Shell** Phone header with back, no tab bar. Back semantics "Kembali ke Data jemaat" → `/DataAnggota` (up link).
- **Layout**
  1. Header: h1 "Peristiwa"; subtitle "Diajukan anggota atau keluarga, diverifikasi Penatua Kolom".
  2. Scroll area, per view:
     - **"Mengajukan"** (k0):
       a. Event-type chips (ChipPilihan look, display only): wrap row, gap 8. Each chip: min-height 44, padding 0 14, radius 999 (`chip`), 600/14, 1.5 edge. Unselected: `permukaan`, `garisTegas` edge, `tinta` text. Selected: `tinta` field and edge, `permukaan` text. In order: "Kelahiran", "Baptisan" (selected), "Sidi", "Pernikahan", "Kematian", "Pindah Kolom", "Atestasi masuk", "Atestasi keluar", "Tinggal sementara".
       b. Form card: `permukaan`, 1 `garis`, radius 14, padding 14 × 16, column gap **12**, three read-only single-line fields: "Untuk" = "Gabriel Wenas"; "Tanggal baptisan" = "08/11/2026"; "Lampiran" = "surat-baptis.jpg".
       c. Line 13 `tinta3`: "Kelahiran tidak otomatis berarti baptisan. Peristiwa tidak otomatis tampil di Warta Jemaat."
       d. Button row: **primary** "Ajukan peristiwa", 340 wide.
     - **"Diajukan"** (k1): Card: head "Baptisan · Gabriel Wenas" + badge `garis` "Diajukan"; line 14 "Diajukan Novita Wenas, 15/11/2026"; line 13 "Data anggota belum berubah sampai peristiwa ini Diverifikasi oleh Penatua Kolom 7." No buttons.
     - **"Diverifikasi"** (k2): Card: head "Baptisan · Gabriel Wenas" + badge `laut` "Diverifikasi"; line 14 "08/11/2026"; line 13 "Diverifikasi oleh Pnt. Hendrik Rumagit, 17/11/2026. Tercatat di data Gabriel Wenas."; line 13 "Peristiwa Pernikahan yang Diverifikasi mengubah Kategori BIPRA kedua mempelai menjadi Bapa dan Ibu sejak tanggal pernikahan." No buttons.
     - **"Dikembalikan"** (k3):
       a. Card: head "Baptisan · Gabriel Wenas" + badge `bata` "Dikembalikan"; line 14 "Alasan: nama di surat baptis “Gabriel J. Wenas”; mohon samakan."; line 13 "Oleh Pnt. Hendrik Rumagit, 16/11/2026".
       b. Button row: **primary** "Ubah dan ajukan lagi", 340 wide.
     - **"Kematian"** (k4):
       a. Card: head "Kematian · Yohanis Rompas" + badge `laut` "Diverifikasi"; line 14 "14/11/2026 · diajukan keluarga"; line 13 "Status menjadi Meninggal dunia; orangnya tidak dihapus. Sebab kematian tidak pernah tampil di publikasi. Jabatan Penatua Kolom 2 menjadi Jabatan kosong dan tidak diisi otomatis."
       b. Button row: **secondary link-button** "Lihat penugasan jabatan", 340 wide.
     - **"Pindah Kolom"** (k5): Card: head "Pindah Kolom · Keluarga Lasut" + badge `garis` "Diajukan"; info rows "Dari" | "Kolom 4", "Ke" | "Kolom 7", "Berlaku" | "01/12/2026", "Siapa" | "Seluruh keluarga (3 orang)"; line 13 "Diverifikasi oleh Penatua Kolom asal dan tujuan. Jabatan tidak ikut pindah. Penugasan Kolom 4 disimpan dengan tanggal berakhirnya." No buttons.
- **Components** ChipPilihan (display only), LencanaStatus (`garis` "Diajukan", `laut` "Diverifikasi", `bata` "Dikembalikan"), GarisStatus (`dibukukan` cards), Tombol (primary, secondary link). Pattern: read-only field.
- **Internal views and states** Initial state `{ k: null }`. View = `k ?? keadaan`: k0 "Mengajukan" (initial), k1 "Diajukan", k2 "Diverifikasi", k3 "Dikembalikan", k4 "Kematian", k5 "Pindah Kolom". The chips are `<span>`s and the fields are `readonly`: nothing on the form can be changed.
- **Tweaks** `keadaan` (enum; options "Mengajukan", "Diajukan", "Diverifikasi", "Dikembalikan", "Kematian", "Pindah Kolom"; default "Mengajukan") · Keadaan panel. Each option shows the view of the same name; changing it resets `k`. Global `jabatanKosong`: no effect.
- **Interactions**
  - "Ajukan peristiwa" (k0, `go1`) → `k = 'Diajukan'`: k1 view at once. No validation (the fields are pre-filled), no timer.
  - "Ubah dan ajukan lagi" (k3, `go0`) → `k = 'Mengajukan'`: the form shows again, unchanged.
  - "Lihat penugasan jabatan" (k4) → push `/Penugasan`.
  - Chips: not pressable (display only; no pressed state, no target). Read-only fields: focusable, not editable.
  - Back arrow → `/DataAnggota`, up link.
- **Motion** None. Declared and unused: `masuk`, `pudar`, `muncul`, `isi`.
- **Links out** Back arrow ("Kembali ke Data jemaat") → `/DataAnggota`, up link. "Lihat penugasan jabatan" → `/Penugasan`, push. **Inbound** DataAnggota, PetaPlatform, WebDataAnggota; also AntreanVerifikasi rows "Peristiwa: Baptisan · Gabriel Wenas", "Peristiwa: Pindah Kolom · Keluarga Lasut", "Peristiwa: Kematian · Yohanis Rompas" (built in logic).
- **Mock data** Baptisan of Gabriel Wenas on 08/11/2026, attachment "surat-baptis.jpg", submitted by Novita Wenas 15/11/2026, returned by Pnt. Hendrik Rumagit 16/11/2026 with reason "nama di surat baptis “Gabriel J. Wenas”; mohon samakan.", verified by Pnt. Hendrik Rumagit 17/11/2026. Kematian of Yohanis Rompas on 14/11/2026, submitted by the family, Diverifikasi; Penatua Kolom 2 becomes vacant. Pindah Kolom of Keluarga Lasut, Kolom 4 → Kolom 7, effective 01/12/2026, whole family (3 people). Event types: Kelahiran, Baptisan, Sidi, Pernikahan, Kematian, Pindah Kolom, Atestasi masuk, Atestasi keluar, Tinggal sementara.
- **Prototype-only** None. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/Peristiwa` with defaults → nine chips with "Baptisan" filled `tinta`; fields "Untuk" "Gabriel Wenas", "Tanggal baptisan" "08/11/2026", "Lampiran" "surat-baptis.jpg" in 14 px `tinta2`; dark "Ajukan peristiwa".
  2. Tap the chip "Sidi" → nothing changes. Tap into a field → no keyboard, value unchanged.
  3. Tap "Ajukan peristiwa" → card "Baptisan · Gabriel Wenas" with badge "Diajukan" and "Diajukan Novita Wenas, 15/11/2026"; no buttons.
  4. Panel "Dikembalikan" → `bata` outlined badge "Dikembalikan" and "Alasan: nama di surat baptis “Gabriel J. Wenas”; mohon samakan."; tap "Ubah dan ajukan lagi" → the form view.
  5. Panel "Kematian" → `laut` badge "Diverifikasi" on "Kematian · Yohanis Rompas"; tap "Lihat penugasan jabatan" → `/Penugasan` pushed; Back returns.
  6. Panel "Pindah Kolom" → info rows Dari "Kolom 4", Ke "Kolom 7", Berlaku "01/12/2026", Siapa "Seluruh keluarga (3 orang)".
  7. Panel "Diverifikasi" → the two 13 px lines including "Peristiwa Pernikahan yang Diverifikasi mengubah Kategori BIPRA kedua mempelai menjadi Bapa dan Ibu sejak tanggal pernikahan."
  8. Back arrow → `/DataAnggota`.
- **Notes** The chips are display-only on the board (spans, not buttons) because the form below is drawn for Baptisan only; keep them non-interactive and give the group Semantics "Jenis peristiwa: Baptisan dipilih". The field values inherit the label's 14 px `tinta2`, not the 16 px `tinta` of an input elsewhere; copy. The typed version of this flow is AlurPeristiwa (another file). The return reason starts with a lower-case "nama" here and an upper-case "Nama" in AntreanVerifikasi; copy each verbatim.

### TampilanNama — 78 · Tampilan nama saya di publikasi
- **Source** `docs/design/handoff/canvas/boards/TampilanNama.dc.html` · page Putaran 4 · Data jemaat (`p4`) · form Phone 390×844 · interactive yes
- **Route** `/TampilanNama`, no child routes · **Widget** `TampilanNamaScreen` in `lib/screens/p4/tampilan_nama.dart`
- **Purpose** Anggota jemaat Novita Wenas (journey step 2, "Tampilan nama saya di publikasi"). How the member's name appears in Warta Jemaat and other publications. Shows the TampilanNama component rules: seven forms; the member's choice must be followed and no format or editor can weaken it; a more private personal choice beats the family default; warn "Masih mudah dikenali" when a form still points to one person; a change applies to the next publication and old editions do not change.
- **Shell** Phone header with back, no tab bar. Back semantics "Kembali ke Data jemaat" → `/DataAnggota` (up link).
- **Layout**
  1. Header: h1 "Tampilan nama saya di publikasi" (wraps to two lines); subtitle "Pilihan Anda wajib diikuti di Warta Jemaat dan publikasi lain".
  2. Scroll area, per view:
     - **"Pilihan pribadi"** (k0):
       a. Group label 14 `tinta2`: "Pilihan pribadi".
       b. Seven radio rows, 16 apart (each a direct item of the column). Row: the whole row is the target (`label`), `permukaan`, 1 `garis` edge, radius 14, padding 10 × 14, min-height 44, row centred, gap 12, text **15 px** `tinta`. Radio 22 × 22 (TampilanNama component look: unselected = circle with 1.5 `tinta3` edge, no fill; selected = circle with a 6 px `tinta` ring around a `permukaan` centre). Then the form name (flex 1) and on the right the sample 13 `tinta3`. Rows (form · sample): "Nama lengkap" · "Novita Wenas"; "Nama keluarga" · "Kel. Wenas-Lasut"; "Keluarga + Kolom" · "Kel. Wenas-Lasut — Kolom 7" (selected); "Kolom" · "Kolom 7"; "BIPRA" · "Pemuda"; "BIPRA + Kolom" · "Pemuda — Kolom 7"; "Tanpa nama" · "Tanpa nama".
       c. Preview box: `lautLembut` field, no edge, radius 14, padding 14 × 16, column gap 6: 13 `tinta3` "Lihat tampilan nama saya"; then 15 px "Syukur HUT pernikahan: " + bold 700 sample of the selected row (initially "**Kel. Wenas-Lasut — Kolom 7**").
       d. Line 13 `tinta3`: "Pilihan pribadi yang lebih tertutup mengalahkan bawaan keluarga untuk kegiatan Anda sendiri. Perubahan berlaku untuk publikasi berikutnya; edisi lama tidak berubah."
     - **"Mengikuti bawaan keluarga"** (k1):
       a. Card: head "Bawaan keluarga" + badge `garis` "Nama keluarga"; line 14 "Diatur Wakil keluarga Agustina Lasut. Anda belum memilih sendiri."
       b. Preview box (as above): "Lihat tampilan nama saya" / 15 px "Sampul syukur: " + "**Kel. Wenas-Lasut**".
       c. Button row: **secondary** "Buat pilihan pribadi", 340 wide.
     - **"Masih mudah dikenali"** (k2):
       a. Card: head "Pilihan pribadi" + badge `garis` "BIPRA + Kolom"; then 15 px "Tampil sebagai: " + "**Remaja — Kolom 11**".
       b. Dashed note (GarisStatus `draf`): 1.5 dashed `putus`, radius 14, padding 12 × 14, 14 px: "**Masih mudah dikenali.**" then, in `tinta2`, "Kolom 11 hanya punya satu anggota Remaja. Pilih “Kolom” atau “Tanpa nama” bila tidak ingin dikenali."
       c. Button row: **secondary** "Ubah pilihan", 340 wide.
- **Components** TampilanNama (radio rows, preview, warning; the radio is `PilihanBulat`, `components.md`), LencanaStatus (`garis`), GarisStatus (`dibukukan` cards and rows, `draf` warning), Tombol (secondary).
- **Internal views and states** Initial state `{ k: null, mode: 'Keluarga + Kolom' }` (`mode` is new, see Interactions). View = `k ?? keadaan`: k0 "Pilihan pribadi" (initial), k1 "Mengikuti bawaan keluarga", k2 "Masih mudah dikenali". Inside k0, the selected radio (`mode`). `mode` returns to "Keluarga + Kolom" whenever k0 is shown anew (the canvas re-creates the radios each time the view appears) and when the tweak changes.
- **Tweaks** `keadaan` (enum; options "Pilihan pribadi", "Mengikuti bawaan keluarga", "Masih mudah dikenali"; default "Pilihan pribadi") · Keadaan panel. Each option shows the view of the same name; changing it resets `k` and `mode`. Global `jabatanKosong`: no effect.
- **Interactions**
  - Radio row (k0): tap anywhere on the row → that row becomes selected (single choice; the native radios on the board do this). Recommended: the preview's bold part shows the selected row's sample at once, e.g. "Tanpa nama" → "Syukur HUT pernikahan: **Tanpa nama**". No save button exists; nothing else changes (DataAnggota keeps "Keluarga + Kolom").
  - "Buat pilihan pribadi" (k1, `go0`) and "Ubah pilihan" (k2, `go0`) → `k = 'Pilihan pribadi'`: the k0 view with "Keluarga + Kolom" selected.
  - Back arrow → `/DataAnggota`, up link. When this board was opened from PersembahanSaya, the arrow therefore does `go('/DataAnggota')`; system Back still pops to PersembahanSaya.
- **Motion** None. Declared and unused: `masuk`, `pudar`, `muncul`, `isi`. The radio changes instantly.
- **Links out** Back arrow ("Kembali ke Data jemaat") → `/DataAnggota`, up link. **Inbound** PermohonanAnggota, PersembahanSaya, PetaPlatform.
- **Mock data** Novita Wenas; Kel. Wenas-Lasut; Kolom 7; BIPRA Pemuda; family default "Nama keluarga" set by Wakil keluarga Agustina Lasut; sample sentences "Syukur HUT pernikahan:" and "Sampul syukur:". The k2 warning is about a different member: "BIPRA + Kolom" shown as "Remaja — Kolom 11", the only Remaja in Kolom 11.
- **Prototype-only** None. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/TampilanNama` with defaults → label "Pilihan pribadi", seven bordered rows; only "Keluarga + Kolom" shows the thick `tinta` ring; preview "Syukur HUT pernikahan: Kel. Wenas-Lasut — Kolom 7" with the name in bold.
  2. Tap the row text "Tanpa nama" → its radio fills, "Keluarga + Kolom" empties, preview reads "Syukur HUT pernikahan: Tanpa nama".
  3. Panel "Mengikuti bawaan keluarga" → card "Bawaan keluarga" with badge "Nama keluarga"; preview "Sampul syukur: Kel. Wenas-Lasut"; tap "Buat pilihan pribadi" → the radio list with "Keluarga + Kolom" selected.
  4. Panel "Masih mudah dikenali" → "Tampil sebagai: Remaja — Kolom 11"; dashed note starting "Masih mudah dikenali." with the curly-quoted “Kolom” and “Tanpa nama”; tap "Ubah pilihan" → radio list.
  5. Every radio row is at least 44 tall and its label is part of the target.
  6. Back arrow → `/DataAnggota`.
- **Notes**
  - The board's preview text is static: on the canvas the native radios move but the preview keeps "Kel. Wenas-Lasut — Kolom 7". Updating the bold sample with the selected row is a recommended deviation (the component is defined as "a choice … with a preview", and the samples are on the rows). List it in the review.
  - The board leaves the radios with the browser's default look; use the TampilanNama component's drawn radio (`preview.html`) so the colours come from tokens.
  - 15 px row and preview text on a 16 px phone board is off-token; copy 15. The preview label is `tinta3` on the board and `tinta2` in the component preview; keep the board.
  - PersembahanSaya says this member's choice is "Tanpa nama" while DataAnggota and this board start at "Keluarga + Kolom"; each board keeps its own value (`mock-data.md`).

### CabutIzin — 79 · Cabut izin dan hapus data saya
- **Source** `docs/design/handoff/canvas/boards/CabutIzin.dc.html` · page Putaran 4 · Data jemaat (`p4`) · form Phone 390×844 · interactive yes
- **Route** `/CabutIzin`, no child routes · **Widget** `CabutIzinScreen` in `lib/screens/p4/cabut_izin.dart`
- **Purpose** Anggota jemaat (journey step 2, "Cabut izin dan hapus data saya"), and the Penatua Kolom 7 for a paper request. A member's right to withdraw consent (Izin) and have their data deleted, with what is deleted and what stays (finance records keep the name as booked; published Warta and documents stay exactly as published). Shows P19 (a paper request to delete data is confirmed by the Penatua Kolom before it is carried out), the glossary distinction Izin ≠ Persetujuan, and that a deceased member is never deleted this way.
- **Shell** Phone header with back, no tab bar. Back semantics "Kembali ke Data jemaat" → `/DataAnggota` (up link).
- **Layout**
  1. Header: h1 "Cabut izin dan hapus data saya" (may wrap to two lines); subtitle "Hak anggota; data dihapus setelah dikonfirmasi".
  2. Scroll area:
     - **Explanation** (shown in k0 and k1, `jelas = ki < 2`, always first):
       a. Card: title "Yang dihapus" (700, no badge); line 14 "Data pribadi Anda, riwayat keluarga dan Kolom, peristiwa, jabatan yang sedang dipegang (menjadi Jabatan kosong), dan akun Anda."
       b. Dashed card: title "Yang tetap ada" (700); line 14 "Catatan keuangan Jemaat tetap menyimpan nama seperti yang tercatat, sebagai bagian dari pembukuan gereja. Warta Jemaat dan dokumen yang sudah diterbitkan tetap persis seperti saat diterbitkan."
     - **"Penjelasan"** (k0), after the explanation: button row with **secondary** "Lanjutkan" and **text link-button** "Kembali" (`laut`, no underline), 171 each on one line (both 48 tall).
     - **"Konfirmasi"** (k1), after the explanation:
       a. Statement checkbox: the whole row is the target (`label`): row, gap 12, top-aligned, min-height 44, 14 px `tinta`. Checkbox 24 × 24, margin-top 2 (shared checkbox: unchecked 1.5 `garisTegas` edge on `permukaan`, radius 4; checked `laut` field with a `diLaut` tick). Text: "Saya mengerti data saya akan dihapus dan tidak dapat dikembalikan. Untuk menjadi anggota lagi saya harus mengajukan permohonan baru."
       b. Button row: "Cabut izin dan hapus data saya" (TombolBersyarat, 171, min-height 52; unmet look = Disabled look `garis` / `tinta2`; met look = primary `tinta` / `permukaan`; label wraps to two lines) and **text** button "Kembali" (171, stretched to 52).
       c. Line 13 `tinta3`: "Tombol aktif setelah pernyataan di atas dicentang."
     - **"Permintaan lewat kertas"** (k2), no explanation:
       a. Card: head "Permintaan hapus · Ferry Wenas" + badge `garis` "Menunggu konfirmasi Penatua"; line 14 "Dicatat Operator Yanti Sumual dari surat bertanda tangan, 16/11/2026."; line 13 "Permintaan lewat kertas dikonfirmasi Penatua Kolom 7 sebelum dijalankan."
       b. Button row: **primary** "Konfirmasi permintaan", 340 wide.
     - **"Sudah dihapus"** (k3), no explanation: Card: head "Catatan penghapusan" + badge `abu` "Selesai"; info rows "Dihapus pada" | "17/11/2026 20.15", "Atas permintaan" | "anggota sendiri", "Dijalankan oleh" | "Pnt. Hendrik Rumagit"; line 13 "Catatan ini tidak memuat data pribadi. Orangnya tidak lagi punya status; anggota yang meninggal dunia tidak pernah dihapus dengan cara ini." No buttons.
- **Components** TombolBersyarat (k1), Tombol (secondary, primary, text), GarisStatus (`dibukukan` and `draf` cards), LencanaStatus (`garis`, `abu`), `KotakCentang` (`components.md`). Pattern: statement checkbox as a plain label row (no box, no edge, text 400), not TutupBuku's bordered 600 box in `01-main.md`.
- **Internal views and states** Initial state `{ k: null, centang: false }` (`centang` is new, see Interactions). View = `k ?? keadaan`: k0 "Penjelasan" (initial), k1 "Konfirmasi", k2 "Permintaan lewat kertas", k3 "Sudah dihapus". `centang` resets to false every time k1 is shown anew (the canvas re-creates the checkbox) and when the tweak changes.
- **Tweaks** `keadaan` (enum; options "Penjelasan", "Konfirmasi", "Permintaan lewat kertas", "Sudah dihapus"; default "Penjelasan") · Keadaan panel. "Penjelasan" and "Konfirmasi" show the explanation cards plus their own part; the other two show only their card. Changing it resets `k` and `centang`. Global `jabatanKosong`: no effect.
- **Interactions**
  - "Lanjutkan" (k0, `go1`) → `k = 'Konfirmasi'`, scroll to top.
  - "Kembali" (k0, a link) → `/DataAnggota`, up link.
  - Statement checkbox (k1) → toggles `centang`. The whole row toggles it.
  - "Cabut izin dan hapus data saya" (k1): condition `centang == true`. Unmet: the disabled look; it stays focusable and pressable (Semantics disabled, `aria-disabled` pattern, never `onPressed: null`); pressing does nothing. Met: primary look; recommended press → `k = 'Sudah dihapus'` (the k3 record), scroll to top. The first press after ticking works. No "Tidak dapat dilakukan" line: the board's reason is the caption below the button, always visible. Build: `TombolBersyarat(label: 'Cabut izin dan hapus data saya', tindakan: 'Cabut izin dan hapus data saya', alasan: centang ? '' : 'Tombol aktif setelah pernyataan di atas dicentang.', onPressed: …, sudahMulai: false, warnaSiap: JenisTombol.tinta, teksBelumRedup: false)`; `sudahMulai: false` keeps the widget from drawing its own sentence, while Semantics still reads the caption as the hint.
  - "Kembali" (k1, `go0`) → `k = 'Penjelasan'`.
  - "Konfirmasi permintaan" (k2, `go3`) → `k = 'Sudah dihapus'`.
  - Back arrow → `/DataAnggota`, up link.
- **Motion** None. Declared and unused: `masuk`, `pudar`, `muncul`, `isi`. The checkbox and button look change instantly.
- **Links out** Back arrow ("Kembali ke Data jemaat") → `/DataAnggota`, up link. "Kembali" (k0) → `/DataAnggota`, up link. **Inbound** PetaPlatform only (reach it from there or from the launcher).
- **Mock data** Paper request "Permintaan hapus · Ferry Wenas", recorded by Operator Yanti Sumual from a signed letter on 16/11/2026, awaiting the Penatua Kolom 7. Deletion record: deleted 17/11/2026 20.15, at the member's own request, carried out by Pnt. Hendrik Rumagit.
- **Prototype-only** None. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/CabutIzin` with defaults → card "Yang dihapus" (solid) and dashed card "Yang tetap ada"; below them "Lanjutkan" (outlined) and "Kembali" (`laut` text) side by side.
  2. Tap "Lanjutkan" → the same two cards, then the unticked statement, a grey "Cabut izin dan hapus data saya" with `tinta2` text, "Kembali", and the caption "Tombol aktif setelah pernyataan di atas dicentang."
  3. Press the grey button → nothing happens; it can still take keyboard focus.
  4. Tap the statement text → the checkbox ticks (`laut`); the button turns `tinta` with `permukaan` text; press it once → "Catatan penghapusan" with badge "Selesai" and "Dihapus pada" | "17/11/2026 20.15".
  5. In "Konfirmasi" tap "Kembali" → the "Penjelasan" view; tap "Lanjutkan" again → the checkbox is unticked.
  6. Panel "Permintaan lewat kertas" → no explanation cards; card "Permintaan hapus · Ferry Wenas" with badge "Menunggu konfirmasi Penatua"; tap "Konfirmasi permintaan" → the deletion record.
  7. "Kembali" in "Penjelasan" and the back arrow → `/DataAnggota`.
- **Notes**
  - On the board the button is a plain HTML `disabled` button that never turns on (the checkbox is not wired), although the caption says it turns on once ticked. Wiring it as a TombolBersyarat and sending its press to the "Sudah dihapus" view are recommended deviations; list them in the review. The caption sits below the button and is not phrased "Tidak dapat dilakukan: …" as TombolBersyarat asks; keep the board's caption (same choice as TutupBuku in `01-main.md`).
  - The k3 record says "Atas permintaan anggota sendiri" yet "Dijalankan oleh Pnt. Hendrik Rumagit"; copy verbatim.
  - k2 head row: the long badge "Menunggu konfirmasi Penatua" (about 230 px) leaves the title "Permintaan hapus · Ferry Wenas" under 90 px, so the title wraps over several lines and its longest word may not fit. Recommended: let the title wrap by word; if the title column would be narrower than its longest word, move the badge under the title (left-aligned) instead of overflowing the card.
  - The deletion date 17/11/2026 is after "today"; copy.

### DataGanda — 80 · Kemungkinan data ganda
- **Source** `docs/design/handoff/canvas/boards/DataGanda.dc.html` · page Putaran 4 · Data jemaat (`p4`) · form Phone 390×844 · interactive yes
- **Route** `/DataGanda`, no child routes · **Widget** `DataGandaScreen` in `lib/screens/p4/data_ganda.dart`
- **Purpose** Operator Yanti Sumual (journey step 1: "Impor buku anggota", "Alur · Buku anggota", "Kemungkinan data ganda"). Two records that may be the same person (one from a membership request, one from the paper member book) are compared side by side and never merged automatically; merging keeps the finance, post, family, service and activity history of both; "not the same person" stops the pair being offered again. Shows the platform rules "One person has one account" and "The Operator sees everything, but seeing gives no authority".
- **Shell** Phone header with back, no tab bar. Back semantics "Kembali ke Data jemaat" → `/DataAnggota` (up link).
- **Layout**
  1. Header: h1 "Kemungkinan data ganda"; subtitle "Bandingkan dulu; tidak pernah digabung sendiri".
  2. Scroll area:
     a. **Comparison** (every view): grid `repeat(auto-fit, minmax(300px, 1fr))`, gap 16, top-aligned (one column on the phone), two cards:
        - Card A: head "Novita Wenas" + badge `laut` "Aktif"; info rows "Tanggal lahir" | "14/03/1996", "Kolom" | "Kolom 7", "Asal data" | "Permohonan menjadi anggota".
        - Card B: head "Novita Wenas" + badge `draf` "Belum dikonfirmasi"; info rows "Tanggal lahir" | "14/03/1996", "Kolom" | "Kolom 7", "Asal data" | "Buku anggota · baris 23".
     b. Per view:
        - **"Bandingkan"** (k0): button row with **primary** "Gabungkan" and **secondary** "Bukan orang yang sama", 171 each, both 52 tall ("Bukan orang yang sama" wraps to two lines).
        - **"Gabungkan"** (k1): soft notice box: "**Digabungkan menjadi satu orang.** Riwayat keuangan, jabatan, keluarga, pelayanan dan Riwayat aktivitas keduanya tetap ada."; then line 13 `tinta3` "Oleh Yanti Sumual, Operator · 17/11/2026 09.20".
        - **"Bukan orang yang sama"** (k2): outlined notice box: "**Ditandai: bukan orang yang sama.** Keduanya tetap sebagai dua orang dan tidak ditawarkan lagi sebagai data ganda."
- **Components** LencanaStatus (`laut`, `draf`), GarisStatus (`dibukukan` cards, `terpilih` notice), Tombol (primary, secondary). Pattern: side-by-side comparison grid.
- **Internal views and states** Initial state `{ k: null }`. View = `k ?? keadaan`: k0 "Bandingkan" (initial), k1 "Gabungkan", k2 "Bukan orang yang sama". The comparison cards stay the same in every view. No way back to k0 inside the board (only the panel or leaving).
- **Tweaks** `keadaan` (enum; options "Bandingkan", "Gabungkan", "Bukan orang yang sama"; default "Bandingkan") · Keadaan panel. Each option shows the view of the same name; changing it resets `k`. Global `jabatanKosong`: no effect.
- **Interactions**
  - "Gabungkan" (`go1`) → `k = 'Gabungkan'`: the merge notice replaces the buttons at once. No confirmation step, no timer.
  - "Bukan orang yang sama" (`go2`) → `k = 'Bukan orang yang sama'`.
  - Back arrow → `/DataAnggota`, up link.
- **Motion** None. Declared and unused: `masuk`, `pudar`, `muncul`, `isi`.
- **Links out** Back arrow ("Kembali ke Data jemaat") → `/DataAnggota`, up link. **Inbound** ImporBuku, PetaPlatform.
- **Mock data** Two records of Novita Wenas, both born 14/03/1996, both Kolom 7: A Aktif, from "Permohonan menjadi anggota"; B Belum dikonfirmasi, from "Buku anggota · baris 23". Merged by Yanti Sumual, Operator, 17/11/2026 09.20. Share with WebDataGanda.
- **Prototype-only** None. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/DataGanda` with defaults → two stacked cards both titled "Novita Wenas": the first with `laut` badge "Aktif" and "Permohonan menjadi anggota", the second with a dashed badge "Belum dikonfirmasi" and "Buku anggota · baris 23"; below them "Gabungkan" (dark) and "Bukan orang yang sama" (outlined) side by side.
  2. Tap "Gabungkan" → the buttons disappear; a `lautLembut` box starting "Digabungkan menjadi satu orang." and the line "Oleh Yanti Sumual, Operator · 17/11/2026 09.20"; both cards still shown.
  3. Set the panel to another option and then back to "Bandingkan" → the buttons are back (`k` was reset by the change). Choosing the value the panel already shows is not a change and resets nothing.
  4. Tap "Bukan orang yang sama" → an outlined `tinta` box starting "Ditandai: bukan orang yang sama."
  5. Back arrow → `/DataAnggota`.
- **Notes** Card B is a solid card although its badge is `draf`; keep. The merge has no confirmation although it joins two records; none was drawn, so add none. The phone board is the Operator's, but its back arrow goes to the Penatua's DataAnggota ("Kembali ke Data jemaat"); keep. The merge date 17/11/2026 is after "today"; copy.

### WebDataGanda — Web · Kemungkinan data ganda
- **Source** `docs/design/handoff/canvas/boards/WebDataGanda.dc.html` · page Putaran 4 · Data jemaat (`p4`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebDataGanda`, no child routes · **Widget** `WebDataGandaScreen` in `lib/screens/p4/web_data_ganda.dart`
- **Purpose** Same as DataGanda on the laptop, for the Operator (a desk post with a laptop layout, Q26). Reached from WebImporBuku.
- **Shell** Platform web side nav (Shared parts), active item **Data jemaat**. Footer: "**Yanti Sumual** · Operator".
- **Layout** (main column)
  1. Title block: breadcrumb "Data jemaat" → `/WebDataAnggota` (up link); h1 "Kemungkinan data ganda"; subtitle 14 `tinta2` "Bandingkan dulu; tidak pernah digabung sendiri".
  2. Content column (max-width 880, gap 16): same as DataGanda Layout 2 with web sizes (titles and button text 15/700):
     a. Comparison grid: **two columns** side by side at 1440, 1280 and 860 (each 432 at 880; one column when the content column is under 616). Card A left, card B right, top-aligned.
     b. k0: "Gabungkan" (primary) and "Bukan orang yang sama" (secondary), 340 each on one line, left-aligned, both 52 tall. k1: the soft notice box (full content width) and the 13 px line. k2: the outlined notice box.
- **Components** As DataGanda, plus the platform side nav.
- **Internal views and states** As DataGanda (`{ k: null }`, three views). Nav drawer open/closed at 860 px and narrower, closed on load.
- **Tweaks** `keadaan` (enum; "Bandingkan", "Gabungkan", "Bukan orang yang sama"; default "Bandingkan") · Keadaan panel; effects as DataGanda. Global `jabatanKosong`: no effect.
- **Interactions** As DataGanda ("Gabungkan" → k1, "Bukan orang yang sama" → k2). Breadcrumb "Data jemaat" → up link to `/WebDataAnggota`. Side-nav items → `go` (the active "Data jemaat" item also goes to `/WebDataAnggota`, which is not this board). Menu toggle at 860 px and narrower.
- **Motion** None. Declared and unused: `muncul`, `isi`, `titik`. Drawer opens instantly.
- **Links out** Breadcrumb "Data jemaat" → `/WebDataAnggota`, up link. Side nav (go): Beranda → `/WebBerandaJabatan`, Keuangan → `/WebBeranda`, Dokumen gereja → `/WebDokumenGereja`, Pengumuman → `/WebPengumuman`, Warta Jemaat → `/WebWartaArsip`, Data jemaat → `/WebDataAnggota`, Ibadah dan kegiatan → `/Ibadah`, Panitia → `/Panitia`, Pemberitahuan → `/WebKotakMasuk`, Pengaturan → `/WebPenugasan`. **Inbound** PetaPlatform, WebImporBuku.
- **Mock data** Identical to DataGanda.
- **Prototype-only** None. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/WebDataGanda` at 1440 → nav with "Data jemaat" active and footer "Yanti Sumual · Operator"; breadcrumb "Data jemaat"; h1 "Kemungkinan data ganda"; the two "Novita Wenas" cards side by side.
  2. Tap "Bukan orang yang sama" → the outlined box "Ditandai: bukan orang yang sama. …" under the cards; the buttons are gone.
  3. Panel "Gabungkan" → soft box "Digabungkan menjadi satu orang. …" and "Oleh Yanti Sumual, Operator · 17/11/2026 09.20".
  4. Breadcrumb "Data jemaat" → `/WebDataAnggota` (up link: pops when `/WebDataAnggota` is directly beneath, otherwise `go`, so opened from WebImporBuku or the launcher it replaces the stack).
  5. Resize to 860 → nav top bar with "Menu"; cards still side by side; at 600 the cards stack.
- **Notes** The breadcrumb names the module ("Data jemaat"), not "Beranda" as on WebDataAnggota; copy. Web buttons inherit 15 px. Nav radius 10 is off-token; copy.

### PersembahanSaya — 81 · Persembahan saya
- **Source** `docs/design/handoff/canvas/boards/PersembahanSaya.dc.html` · page Putaran 4 · Data jemaat (`p4`) · form Phone 390×844 · interactive yes
- **Route** `/PersembahanSaya`, no child routes · **Widget** `PersembahanSayaScreen` in `lib/screens/p4/persembahan_saya.dart`
- **Purpose** Anggota jemaat Novita Wenas (journey step 3, "Persembahan saya"; reached from BerandaJabatan's "Persembahan saya" row and from PersembahanBernama). Only gifts recorded in the member's name (named envelopes), visible to the giver and the Bendahara Jemaat only; collection-bag offerings are never recorded per person (Q32 and the platform rule on givers' names). A member who believes a gift is wrongly in their name sends a note to the Bendahara Jemaat; the finance record does not change by itself.
- **Shell** Phone header with back, no tab bar. Back semantics "Kembali ke Beranda" → `/BerandaJabatan` (up link).
- **Layout**
  1. Header: h1 "Persembahan saya"; subtitle "Hanya persembahan yang dicatat atas nama Anda".
  2. Scroll area, per view:
     - **"Ada persembahan bernama"** (k0):
       a. Soft notice box: "**Yang melihat halaman ini: Anda dan Bendahara Jemaat.** Penatua, Syamas, Sekretaris Jemaat dan Operator tidak melihatnya."
       b. Gift card 1, **pressable** (a link wrapping the card, no underline, `tinta` text): Card: head "Sampul syukur" (700) + amount right "Rp100.000" (IBM Plex Mono 500, body size 16, `tinta`); line 13 "01/11/2026 · Ibadah Minggu Pagi · Umum Jemaat".
       c. Gift card 2 (not pressable): head "Persembahan persepuluhan" + "Rp300.000" (mono 500); line 13 "04/10/2026 · Ibadah Minggu Pagi · Umum Jemaat".
       d. Gift card 3 (not pressable): head "Sampul syukur" + "Rp150.000" (mono 500); line 13 "20/09/2026 · Ibadah Minggu Pagi · Diakonia".
       e. Line 13 `tinta3`: "Persembahan di kantong persembahan tidak dicatat per orang dan tidak tampil di sini. Yang tampil hanya yang sudah Dibukukan."
     - **"Rincian"** (k1):
       a. Card: head "Sampul syukur" + badge `tinta` "Dibukukan"; info rows "Jumlah (Rp)" | "Rp100.000" (mono 500, 14), "Tanggal transaksi" | "01/11/2026", "Diterima di" | "Ibadah Minggu Pagi", "Masuk ke peruntukan" | "Umum Jemaat", "No. Bukti" | "BKU-2026-0132" (see Notes: mono 500).
       b. Line 13 `tinta3`: "Di Warta Jemaat nama Anda mengikuti Tampilan nama yang Anda pilih: Tanpa nama."
       c. Button row: line 1 **secondary link-button** "Ubah Tampilan nama" and **secondary** "Bukan persembahan saya" (171 each, labels wrap); line 2 **text** button "Kembali", 340 wide.
     - **"Belum ada"** (k2): Dashed card: "Belum ada persembahan atas nama Anda" (700); line 14 `tinta2` "Bila Anda memberi dengan sampul bernama, Bendahara Jemaat mencatatnya atas nama Anda. Persembahan itu tampil di sini setelah dibukukan." No notice box, no buttons.
     - **"Bukan persembahan saya"** (k3):
       a. Card: head "Sampul syukur" + "Rp100.000" (mono 500); line 13 "01/11/2026 · BKU-2026-0132".
       b. Read-only multi-line field, label "Keterangan · wajib", value "Saya tidak memberi sampul pada tanggal ini." (14 `tinta2`, min-height 96).
       c. Line 13 `tinta3`: "Dikirim ke Bendahara Jemaat. Catatan keuangan tidak berubah; Bendahara yang melepas nama Anda bila memang keliru."
       d. Button row: **primary** "Kirim ke Bendahara Jemaat" and **text** "Batalkan", 171 each on one line (both 52 tall).
- **Components** LencanaStatus (`tinta` "Dibukukan"), GarisStatus (`dibukukan` cards, `draf` empty state), IsianAlasan (k3, read-only), Tombol (primary, secondary, secondary link, text). Patterns: soft notice box, money in mono, card as link.
- **Internal views and states** Initial state `{ k: null }`. View = `k ?? keadaan`: k0 "Ada persembahan bernama" (initial), k1 "Rincian", k2 "Belum ada" (empty state), k3 "Bukan persembahan saya". The note field is read-only and pre-filled.
- **Tweaks** `keadaan` (enum; options "Ada persembahan bernama", "Rincian", "Belum ada", "Bukan persembahan saya"; default "Ada persembahan bernama") · Keadaan panel. Each option shows the view of the same name; changing it resets `k`. Global `jabatanKosong`: no effect.
- **Interactions**
  - Gift card 1 (k0): the card is `<a href="PersembahanSaya.dc.html" onClick="{{go1}}">`. Press → `k = 'Rincian'`, scroll to top; no route is pushed (the link targets this same board). Build it as `Tautan(ke: 'PersembahanSaya', …)` so the link test finds the manifest link, and make sure the self-link neither pushes a duplicate route nor resets `k` after `go1` runs. Cards 2 and 3 are not pressable.
  - "Ubah Tampilan nama" (k1) → push `/TampilanNama`.
  - "Bukan persembahan saya" (k1, `go3`) → `k = 'Bukan persembahan saya'`.
  - "Kembali" (k1, `go0`) → `k = 'Ada persembahan bernama'`.
  - "Kirim ke Bendahara Jemaat" (k3, `go0`) → `k = 'Ada persembahan bernama'`: back to the list, unchanged (the gift is still listed), no confirmation message.
  - "Batalkan" (k3, `go1`) → `k = 'Rincian'`.
  - Back arrow → `/BerandaJabatan`, up link.
- **Motion** None. Declared and unused: `masuk`, `pudar`, `muncul`, `isi`. The pressable card has no press feedback (no ripple, no pressed colour; `motion.md` rule 9), only the keyboard focus ring.
- **Links out** Back arrow ("Kembali ke Beranda") → `/BerandaJabatan`, up link. Gift card "Sampul syukur Rp100.000 01/11/2026 · Ibadah Minggu Pagi · Umum Jemaat" → `/PersembahanSaya` (self, in place, see Interactions). "Ubah Tampilan nama" → `/TampilanNama`, push. **Inbound** PersembahanBernama, PetaPlatform, WebPersembahanBernama; also the BerandaJabatan/WebBerandaJabatan row "Persembahan saya" (built in logic).
- **Mock data** Novita Wenas's named gifts: Sampul syukur Rp100.000, 01/11/2026, Ibadah Minggu Pagi, peruntukan Umum Jemaat, No. Bukti BKU-2026-0132, Dibukukan; Persembahan persepuluhan Rp300.000, 04/10/2026, Ibadah Minggu Pagi, Umum Jemaat; Sampul syukur Rp150.000, 20/09/2026, Ibadah Minggu Pagi, Diakonia. Her Tampilan nama here: "Tanpa nama". Note text: "Saya tidak memberi sampul pada tanggal ini." Amounts through `rp()` (`rp(100000)` → "Rp100.000").
- **Prototype-only** None. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/PersembahanSaya` with defaults → `lautLembut` box starting "Yang melihat halaman ini: Anda dan Bendahara Jemaat."; three cards with mono amounts "Rp100.000", "Rp300.000", "Rp150.000"; caption about the collection bag.
  2. Tap the first card → same route (no new history entry); card "Sampul syukur" with a `tinta`-filled badge "Dibukukan", "No. Bukti" | "BKU-2026-0132", caption ending "Tanpa nama."
  3. Tap the second card → nothing happens.
  4. In Rincian tap "Bukan persembahan saya" → read-only field "Keterangan · wajib" with "Saya tidak memberi sampul pada tanggal ini."; tap "Batalkan" → Rincian; tap "Kembali" → the list.
  5. In "Bukan persembahan saya" tap "Kirim ke Bendahara Jemaat" → the list, still three cards.
  6. In Rincian tap "Ubah Tampilan nama" → `/TampilanNama` pushed; system Back returns here, still on Rincian.
  7. Panel "Belum ada" → only the dashed card "Belum ada persembahan atas nama Anda".
  8. Back arrow → `/BerandaJabatan`.
- **Notes**
  - The board draws the No. Bukti value "BKU-2026-0132" in sans 600 inside its info row; CONVENTIONS wants codes in mono. Recommended: mono 500 for this stand-alone value (like the "Jumlah (Rp)" row above it); keep sans in the running line "01/11/2026 · BKU-2026-0132" (k3).
  - The first card both links to this same board and runs `go1`; on the canvas the press could also reload the board. The in-place switch to Rincian is the intent; build it that way.
  - The "Jumlah (Rp)" label already names the currency while the value repeats "Rp"; copy verbatim.
  - "Tanpa nama" here differs from DataAnggota's "Keluarga + Kolom" for the same member; each board keeps its own figure (`mock-data.md`).
  - `rp()` is defined but the amounts are literal strings on the board; render them through the shared `rp()` so they read identically.
