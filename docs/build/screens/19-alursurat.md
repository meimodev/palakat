# Screens 19: AlurSurat, WebAlurSurat, AlurWarta, WebAlurWarta, A4Warta, PermohonanAnggota, ImporBuku, WebImporBuku

These eight boards belong to two canvas pages. The first five are on "Putaran 3 · Sekretariat" (`p3`) and are the Sekretaris Jemaat's work, done by Olvie Pangemanan. **AlurSurat** (phone) and **WebAlurSurat** (laptop) are a typed flow for letter requests. She opens one of three requests from members, reads the member's verified data, types the outgoing letter number, attaches the signed copy, and then either issues the letter or records "Tidak diterbitkan" with a reason. The list then shows the new status, a status note and a Riwayat. **AlurWarta** (phone) and **WebAlurWarta** (laptop) are a typed flow for the weekly Warta Jemaat of 22/11/2026. She picks which published announcements go in (P17), writes a new announcement, records a name-display exception, and moves the edition through Draf → Sudah diperiksa → Disetujui → Diterbitkan, where content is locked after review (P18). After publishing, a correction is a linked ralat. **A4Warta** is the fixed A4 page of that edition (Q27). It is reached from "Lihat PDF" on WartaEditor/WebWartaEditor and from PetaPlatform. The last three are on "Putaran 4 · Data jemaat" (`p4`). **PermohonanAnggota** (phone) is a member's own membership request, shown in seven states through its `keadaan` tweak. **ImporBuku** (phone) and **WebImporBuku** (laptop) are the Operator's import of a paper member book, in three states (D34). They link on to DataGanda/WebDataGanda and KonfirmasiKeluarga. Inbound links (navigation.md): AlurSurat, WebAlurSurat, AlurWarta and WebAlurWarta are reached only from PetaPlatform or the launcher; A4Warta from WartaEditor/WebWartaEditor and PetaPlatform; PermohonanAnggota also from AntreanVerifikasi (its rows "Permohonan menjadi anggota · Novita Wenas" and "Permohonan menjadi anggota · Kevin Rompas"); ImporBuku also from BerandaJabatan and WebImporBuku also from WebBerandaJabatan (the row "Buku anggota: 318 baris sudah diimpor"). In every section an **up link** is a phone back arrow or a web breadcrumb. It runs `kembaliKe('/X')`: pop when the route directly below is `/X` or a child of `/X`, otherwise `go('/X')`. Side-nav items use `go`; drill-ins use `push`. In code (navigation.md): the phone back arrow is `KepalaPonsel(kembaliKe: 'X', labelKembali: 'Kembali ke …')`; a breadcrumb is `Tautan(ke: 'X', cara: Cara.naik)`; the side nav is `NavSamping(item: navPlatform, aktif: <index>, …)`, whose items are `Cara.ganti`; a drill-in is `Tautan(ke: 'X')` (default push). Today is 16/11/2026. None of these boards has the `jabatanKosong` tweak, so the global switch changes nothing here.

**Shared rules for all eight boards.**

- *No child routes.* Every view change happens in place under the same header or title block, as on the canvas. System Back leaves the board from any view. On every view change (`v`, `k` or the panel tweak), jump the scroll area to the top. The canvas keeps the old offset, which can leave the reader below the end of a shorter view; the same choice is made in `14-berandajabatan.md`.
- *Tweak views* (PermohonanAnggota, ImporBuku, WebImporBuku). The board state is `{ k: null }`. The view shown is `k ?? keadaan`, where `keadaan` is the panel's tweak value. In-board buttons set `k` to one of the tweak's options and do not move the panel's value. Changing `keadaan` in the Keadaan panel, or leaving the route, resets `k` to null. This is the rule of `14-berandajabatan.md`.
- *Flow state* (AlurSurat, AlurWarta and their web twins). The board state is `{ k: null }` plus a flow object `a`, which holds everything that changes. It lives for the life of the route and is dropped when the route is left.
- *Phone frame* (AlurSurat, AlurWarta, PermohonanAnggota, ImporBuku): 390 × 844, `kertas`, `tinta`, `isi` 16/1.4. A column with a fixed header and a scrolling body. There is no tab bar.
  - *Phone header* (row, centred, gap 8, padding 14 12 8):
    - Back target 44 × 44: chevron 22 (path `M15 6l-6 6 6 6`, stroke 2, round cap, `tinta`), with Semantics label "Kembali ke …".
    - Title column (flex 1): h1 `judulLayar` (18/700), then the subtitle in 13 `tinta2`. The source writes `font-size: 14px; … font-size: 13px`, and 13 wins.
  - *Body*: fills the rest and scrolls vertically, padding 8 20 20. Inside is one column with gap 16. Content width is 350.
- *Laptop page* (WebAlurSurat, WebAlurWarta, WebImporBuku): `kertas`, `isiWeb` 15/1.45, min height the window, a wrapping row of nav and main.
  - Side nav: the **platform side nav**, specified once under WebBerandaJabatan in `14-berandajabatan.md`. It has the brand row, ten items, a footer and the below-860 "Menu" top bar.
    - Items, in order: Beranda → `/WebBerandaJabatan`, Keuangan → `/WebBeranda`, Dokumen gereja → `/WebDokumenGereja`, Pengumuman → `/WebPengumuman`, Warta Jemaat → `/WebWartaArsip`, Data jemaat → `/WebDataAnggota`, Ibadah dan kegiatan → `/Ibadah`, Panitia → `/Panitia`, Pemberitahuan → `/WebKotakMasuk`, Pengaturan → `/WebPenugasan`.
    - The active item has a `tinta` field and `permukaan` text. All items use `go`.
    - Each board below names its active item and its footer.
  - Main: flex 999 1 560, padding 28 / clamp(16, 3 vw, 40) / 40, a column with gap 20.
  - *Web title block*: the breadcrumb link (14/600 `laut`, `lautTua` on hover, underlined, an up link), the h1 `judulHalaman` 26/700 with margin-top 2, then the subtitle in 14 `tinta2`.
  - Below the title block sits the content column: max width 1120, column gap 16.
  - *Two-column row*: wrap, gap 20 vertical × 28 horizontal, aligned to the top.
    - Left: flex 1.3 1 420, column gap 12. Right: flex 1 1 340, column gap 12.
    - At 1440 the content is 1120 wide, so left is about 608 and right about 484. The columns stack when the content is narrower than 788.
    - At 860 the content is 808, so the columns still sit side by side.
- *Parts*: KitAlur (components.md 2.9), built in M1. This file uses it and does not redefine it. The names used below (*Ink primary*, *Secondary*, *Text button*, *button row*, *TombolBersyarat*, *Refusal line*, *Status note*, *Card*, *Key–value row*, *Badge*, *Field*, *ChipPilihan*, *Riwayat*) are the KitAlur parts: ink primary = primary, status note = message banner, key–value row = info row. Only these differ on the eight boards:
  - *Sea primary*: the ink primary's shape on a `laut` field with `diLaut` text (`Tombol(jenis: JenisTombol.utama)`). It is used only for the Warta "Terbitkan".
  - *Card*: padding 12 16 in lists, 14 16 for detail cards.
  - *Badge*: six of the seven `LS` shapes are used: `garis` (the "Belum ditutup" shape), `tinta`, `laut` (the "Sudah dipastikan" shape), `lautg` (the "Sudah diperiksa" shape), `bata` and `draf`. `abu` is unused here.
  - *Field*: the keyboard is plain text.

---

### AlurSurat — 70 · Alur · Permohonan surat

- **Source** `docs/design/handoff/canvas/boards/AlurSurat.dc.html` · page Putaran 3 · Sekretariat (`p3`) · form Phone 390×844 · interactive yes
- **Route** `/AlurSurat`, no child routes (the three views replace the body under one fixed header) · **Widget** `AlurSuratScreen` in `lib/screens/p3/alur_surat.dart`
- **Purpose** Sekretaris Jemaat (Olvie Pangemanan), journey step 2 ("Permohonan surat", "Alur · Permohonan surat"). It handles letter requests from start to finish: open a request, check the member's verified data (she reads Data jemaat and does not change it), type the number from the outgoing-letters book, attach the signed copy, then issue the letter or record "Tidak diterbitkan" with a reason.
  - It shows the platform rules "Diverifikasi" for member data and "Sekretaris Jemaat membaca, tidak mengubah".
  - The signature is on the document; there is no in-app approval for church documents (01-foundations: never draw a signature; P09 approvals are only for requests such as Permintaan dana).
  - Other rules shown: P12 (a reason must not be blank, no minimum length), the TombolBersyarat rules, and RiwayatAlur.
  - An issued letter's visibility is limited to "anggota, keluarganya dan pelayan yang menaunginya".
- **Shell** Phone header with back, no tab bar. Back label "Kembali ke Permohonan surat". Title "Alur · Permohonan surat". Subtitle "Dari permohonan anggota sampai surat diterbitkan atau tidak".
- **Layout** The body column (gap 16) shows one of three views.
  **View `daftar`** (start):
  1. *Status note* (only when `pesan` is not empty): `pesan` text (see Interactions).
  2. *Three request cards* (list card, padding 12 16, gap 6). Each card has:
     - a top row (space-between, centred, gap 16): title `{jenis} · {nama}` (16/700; it wraps to two lines at 350), then a badge;
     - a 13 `tinta3` line;
     - only while the request is Diajukan, a secondary button "Buka permohonan", aligned to the start.
     The badge shape follows the status: "Diajukan" → `garis`, "Diterbitkan" → `tinta`, "Tidak diterbitkan" → `bata`.
     Initial cards:
     - "Surat keterangan · Novita Wenas" · Diajukan · "Diajukan 14/11/2026 · untuk melamar pekerjaan"
     - "Atestasi keluar · Keluarga Lasut" · Diajukan · "Diajukan 15/11/2026 · pindah ke Jemaat lain"
     - "Surat keterangan · Agustina Lasut" · Diajukan · "Dicatat Operator di kantor, 16/11/2026"
  3. 13 `tinta3`: "Permohonan datang dari anggota, atau dicatat Operator di kantor untuk anggota tanpa ponsel."
  4. *Riwayat* (only when there are rows), with the h2 and the card 16 apart.
  **View `buka`** (request p):
  1. *Detail card* (padding 14 16, gap 6):
     - Top row: `{jenis} · {nama}` (700) and the badge "Diajukan" (`garis`, always this text).
     - Key–value rows: "Nama" → nama; "Keluarga · Kolom" → keluarga (for example "Wenas-Lasut · Kolom 7"); "Status" → "Aktif".
     - 13 `tinta3`: "Diambil dari Data jemaat yang sudah Diverifikasi. Sekretaris Jemaat membaca, tidak mengubah."
  2. *Nomor surat* field: label "Nomor surat"; input with hint "Contoh: 027/SKet/XI/2026"; helper "Sesuai buku agenda surat keluar."
  3. *File slot*: 1.5 dashed `putus` edge (the draf line), no fill, radius 14, padding 14 16, column gap 6.
     - Top row (space-between, centred, gap 16): "Salinan bertanda tangan" (700) and a badge:
       - "Wajib, belum ada" (`bata`) while no file;
       - "Terlampir" (`garis`) once attached.
     - Empty: 13 `tinta3` "Tanda tangan ada di dokumennya. Tidak ada persetujuan di aplikasi untuk dokumen gereja.", then the secondary button "Pilih file", aligned to the start.
     - Attached: 13 `tinta3` "salinan-bertanda-tangan.pdf · 1 halaman". There is no button, so the file cannot be removed.
     - The edge stays dashed in both states.
  4. *Refusal line* (when shown): "Tidak dapat dilakukan: Terbitkan surat." + cause.
  5. *Button row*:
     - "Terbitkan surat" (TombolBersyarat) and "Tidak diterbitkan" (secondary) share the first row at about 171 each.
     - "Kembali" (text button) wraps below at 340.
  **View `tolak`** (request p):
  1. *Card* (padding 14 16, gap 6):
     - Top row: `{jenis} · {nama}` (700) and "Diajukan" (`garis`).
     - 13 `tinta3`: "Pemohon diberi tahu, dengan alasannya."
  2. *Alasan* field: label "Alasan · wajib" (plain text, no bold part), textarea.
  3. *Refusal line* "Tidak dapat dilakukan: Catat tidak diterbitkan." This line never shows (see Notes).
  4. *Button row*: "Catat tidak diterbitkan" (TombolBersyarat) and "Kembali" (text button), side by side at about 171 each.
- **Components** LencanaStatus (request badges, file-slot badge); TombolBersyarat ("Terbitkan surat", "Catat tidak diterbitkan"); Penolakan (the refusal line); IsianAlasan ("Alasan · wajib", 3 rows here); RiwayatAlur (Riwayat); Tombol (secondary "Buka permohonan", "Pilih file", "Tidak diterbitkan"; text "Kembali"). Repeated patterns that are not components: the request card with an action button, the key–value detail card, the dashed file slot (PanelDokumen-like, but built as drawn), and the status note.
- **Internal views and states**
  - The flow object `a` starts as `{ pesan: '', riw: [], v: 'daftar', sel: 0, no: '', file: '', alasan: '', P: [ ['Surat keterangan','Novita Wenas','Diajukan 14/11/2026 · untuk melamar pekerjaan','Diajukan','Wenas-Lasut · Kolom 7'], ['Atestasi keluar','Keluarga Lasut','Diajukan 15/11/2026 · pindah ke Jemaat lain','Diajukan','Lasut · Kolom 4'], ['Surat keterangan','Agustina Lasut','Dicatat Operator di kantor, 16/11/2026','Diajukan','Wenas-Lasut · Kolom 7'] ] }`.
    - Each entry of `P` is [jenis, nama, keterangan, status, keluarga·kolom].
    - `v` ∈ `daftar` | `buka` | `tolak`.
    - `file` ∈ `''` | `'ada'`. The `'gagal'` value is unreachable (see Notes).
  - Views:
    - `daftar`, with or without the status note and the Riwayat; each card is Diajukan (with its button), Diterbitkan or Tidak diterbitkan.
    - `buka`: empty, typing, refused, or file attached and met.
    - `tolak`: empty or filled.
  - Unused helpers (`balik`, `tgl`, `chip`, `pil`, `baris`, `hal`, `rp`) render nothing. Do not build them.
- **Tweaks** (Keadaan panel) `keadaan`: enum with the single option "Alur", default "Alur". It has no visible effect.
- **Interactions**
  - "Buka permohonan" on card i → `v = 'buka'`, `sel = i`. It clears `no`, `file`, `alasan` and `pesan`.
  - Nomor surat input (`onNo`) → `no` exactly as typed. There is no format, mask or length check, and the keyboard is plain text.
  - "Pilih file" (`pilihFile`) → `file = 'ada'` at once. There is no timer and no file picker; the file is a fake.
  - Condition `ok` for "Terbitkan surat", in order. The first unmet one is the cause:
    1. `no` blank after trimming → "nomor surat belum diisi."
    2. `file ≠ 'ada'` → "salinan bertanda tangan belum terlampir."
  - The refusal line shows only when `no` is non-empty (spaces count) or `file` is non-empty. An untouched form shows no refusal.
  - "Terbitkan surat" (`terbit`) re-checks `ok` from the latest state on press; if it is unmet, nothing happens. If met, with N = `no` trimmed:
    - the status of request `sel` becomes "Diterbitkan";
    - its keterangan becomes "No. {N} · 16/11/2026 · hanya anggota, keluarganya dan pelayan yang menaunginya yang melihat";
    - `pesan` becomes "{jenis} {nama} diterbitkan dengan No. {N}." (for example "Surat keterangan Novita Wenas diterbitkan dengan No. 027/SKet/XI/2026.");
    - a Riwayat row is prepended: "16/11/2026 · {pesan} Oleh Olvie Pangemanan, Sekretaris Jemaat.";
    - `v = 'daftar'`, and `no`, `file`, `alasan` are cleared.
  - "Tidak diterbitkan" (`keTolak`) → `v = 'tolak'`, `pesan = ''`. `no`, `file` and `alasan` are kept, so a reason typed earlier in `tolak` (then "Kembali") is still in the textarea.
  - "Kembali" in `buka` (`pulang`) → `v = 'daftar'`, `pesan = ''`. The typed values stay in memory but are cleared by the next "Buka permohonan".
  - Alasan textarea (`onAlasan`) → `alasan` exactly as typed.
  - Condition `ok2` for "Catat tidak diterbitkan": `alasan` is not blank after trimming. There is no cause text and no refusal line.
  - "Catat tidak diterbitkan" (`tolak`) re-checks `ok2` on press; if it is unmet, nothing happens. If met, with A = `alasan` trimmed:
    - the status becomes "Tidak diterbitkan";
    - the keterangan becomes "Alasan: {A}";
    - `pesan` becomes "{jenis} {nama} tidak diterbitkan · alasan: {A}.";
    - a Riwayat row is prepended: "16/11/2026 · {pesan} Oleh Olvie Pangemanan, Sekretaris Jemaat.";
    - `v = 'daftar'`, and `no`, `file`, `alasan` are cleared.
  - "Kembali" in `tolak` (`keBuka`) → `v = 'buka'`, `pesan = ''`. `no`, `file` and `alasan` are kept, so the number and the attached file are still there.
  - A card that is Diterbitkan or Tidak diterbitkan has no button and cannot be reopened.
  - Back arrow → `kembaliKe('/PermohonanSurat')`.
- **Motion** none. The keyframes `isi`, `masuk`, `muncul` and `pudar` are declared but unused. View changes, badge changes and button colour changes are instant. There are no timers.
- **Links out** Back arrow "Kembali ke Permohonan surat" → `/PermohonanSurat` (up link: `KepalaPonsel(kembaliKe: 'PermohonanSurat', labelKembali: 'Kembali ke Permohonan surat')`, which builds `Tautan(ke: 'PermohonanSurat', cara: Cara.naik)`; a bare `Tautan(ke: 'PermohonanSurat')` would push). **Inbound** PetaPlatform ("Alur · Permohonan surat" → "Ponsel").
- **Mock data**
  - Requests: "Surat keterangan" for Novita Wenas (Wenas-Lasut · Kolom 7, applied 14/11/2026, "untuk melamar pekerjaan"); "Atestasi keluar" for Keluarga Lasut (Lasut · Kolom 4, applied 15/11/2026, "pindah ke Jemaat lain"); "Surat keterangan" for Agustina Lasut (Wenas-Lasut · Kolom 7, recorded by the Operator at the office 16/11/2026).
  - Status "Aktif".
  - File "salinan-bertanda-tangan.pdf · 1 halaman".
  - Sample number in the hint "027/SKet/XI/2026".
  - Actor "Olvie Pangemanan, Sekretaris Jemaat". Today 16/11/2026.
- **Prototype-only** none. The "Contoh: 027/SKet/XI/2026" text is an input hint, not a "Contoh:" button, so it stays on the screen. Keadaan panel: `keadaan` (Alur).
- **Acceptance checks**
  1. Open `/AlurSurat` → the header shows "Alur · Permohonan surat" and the subtitle. Below are three cards, each with a `garis` badge "Diajukan" and the button "Buka permohonan", then the note "Permohonan datang dari anggota, …". There is no status note and no Riwayat.
  2. "Buka permohonan" on Novita Wenas →
     - the detail card shows "Surat keterangan · Novita Wenas", Nama "Novita Wenas", "Keluarga · Kolom" "Wenas-Lasut · Kolom 7" and Status "Aktif";
     - Nomor surat is empty with the hint "Contoh: 027/SKet/XI/2026";
     - the file slot badge reads "Wajib, belum ada" in `bata`;
     - there is no refusal, and "Terbitkan surat" is on `garis` with `tinta2` text.
  3. Type one space → "Tidak dapat dilakukan: Terbitkan surat. nomor surat belum diisi.". Replace it with "027/SKet/XI/2026" → the cause becomes "salinan bertanda tangan belum terlampir."
  4. "Pilih file" → the badge is "Terlampir" (`garis`) and the line reads "salinan-bertanda-tangan.pdf · 1 halaman". "Pilih file" is gone, the refusal disappears and the button turns `tinta`.
  5. Press "Terbitkan surat" once → the list shows:
     - the status note "Surat keterangan Novita Wenas diterbitkan dengan No. 027/SKet/XI/2026.";
     - the first card with a `tinta` badge "Diterbitkan", the line "No. 027/SKet/XI/2026 · 16/11/2026 · hanya anggota, keluarganya dan pelayan yang menaunginya yang melihat", and no button;
     - Riwayat with the row "16/11/2026 · Surat keterangan Novita Wenas diterbitkan dengan No. 027/SKet/XI/2026. Oleh Olvie Pangemanan, Sekretaris Jemaat."
  6. On "Atestasi keluar · Keluarga Lasut", tap "Buka permohonan" then "Tidak diterbitkan":
     - The card shows "Pemohon diberi tahu, dengan alasannya.". "Catat tidak diterbitkan" is grey and pressing it does nothing. No refusal line appears, even after typing spaces.
     - Type "Belum ada surat dari jemaat tujuan" → the button turns `tinta`.
     - Press it → the card badge is "Tidak diterbitkan" (`bata`) with the line "Alasan: Belum ada surat dari jemaat tujuan". The status note reads "Atestasi keluar Keluarga Lasut tidak diterbitkan · alasan: Belum ada surat dari jemaat tujuan.". Riwayat has two rows, with this one on top.
  7. In `buka`, type a number and attach the file, tap "Tidak diterbitkan", then "Kembali" → back in `buka` with the number and "Terlampir" kept.
  8. "Kembali" in `buka`, then "Buka permohonan" on the same card → the number is empty and the badge reads "Wajib, belum ada" again.
  9. Back arrow → `/PermohonanSurat` (`go`, since nothing links here from there).
- **Notes**
  - Two parts of the board are dead code:
    - `fileSt(false)`: the "Gagal diunggah." branch ("Isian Anda masih ada di layar ini; file belum terlampir." with "Coba lagi") cannot be reached. Do not build a trigger for it.
    - `sebab2` is `al && !al`, so the refusal for "Catat tidak diterbitkan" ("alasan terlalu pendek.") never shows.
  - The second point conflicts with "a disabled action always shows its reason". The board wins: show no line. If a reason is wanted later, the text would be "Tidak dapat dilakukan: Catat tidak diterbitkan. alasan belum diisi."
  - The letter number is rendered in sans, as drawn, although CONVENTIONS sets codes in mono. Keep sans; it is the letter's own number, not a Palakat code.
  - Primaries are `tinta` fields, not the `laut` primary of Tombol. Keep the board.
  - Typed text is 14 `tinta2` because it inherits the label. `13-tabberanda.md` describes the same field as 16 `tinta`. KitAlur's field (components.md 2.9) settles it: the CSS gives 14 `tinta2`.
  - The badge in the `buka` and `tolak` cards is hard-coded "Diajukan". This is correct, because only Diajukan requests can be opened.

### WebAlurSurat — Web · Alur · Permohonan surat

- **Source** `docs/design/handoff/canvas/boards/WebAlurSurat.dc.html` · page Putaran 3 · Sekretariat (`p3`) · form Laptop page (preview 1440×1000, `expand: fill`) · interactive yes
- **Route** `/WebAlurSurat`, no child routes · **Widget** `WebAlurSuratScreen` in `lib/screens/p3/web_alur_surat.dart`
- **Purpose** Same as AlurSurat on the laptop, for the Sekretaris Jemaat. Sekretaris Jemaat is a desk post with a laptop layout (Q26). The decisions are the same as AlurSurat.
- **Shell** Platform side nav with **"Dokumen gereja" active** (the third item; `NavSamping(item: navPlatform, aktif: 2, …)`). Footer: "**Olvie Pangemanan** · Sekretaris Jemaat", with the name strong `tinta`.
- **Layout** Main column, top to bottom:
  1. *Web title block*: breadcrumb "Permohonan surat" (→ `/WebPermohonanSurat`), h1 "Alur · Permohonan surat", subtitle "Dari permohonan anggota sampai surat diterbitkan atau tidak".
  2. *Content column* (max 1120, gap 16), holding one view:
     - **`daftar`**: as AlurSurat `daftar` (status note, three cards, note, Riwayat). The cards stretch to 1120 and the titles are 15/700 on one line.
     - **`buka`**: a two-column row.
       - Left: the detail card (`buka` 1) and the Nomor surat field (`buka` 2).
       - Right: the file slot (`buka` 3), the refusal line (`buka` 4) and the button row (`buka` 5).
       - In the 484 right column all three buttons sit on one row at about 156 each: "Terbitkan surat", "Tidak diterbitkan", "Kembali".
     - **`tolak`**: a single column, the same as AlurSurat `tolak`, full width up to 1120. The two buttons are 340 each, left-aligned.
     Every style, text and colour is as in AlurSurat. The text base is 15 instead of 16, and inputs inherit 14 from their labels.
- **Components** As AlurSurat, plus the platform side nav.
- **Internal views and states** Identical to AlurSurat: the same flow object `a` and initial `P`, and the views `daftar`, `buka` and `tolak`. The below-860 menu toggle is page-local and not saved.
- **Tweaks** (Keadaan panel) `keadaan` (enum, single option "Alur", default "Alur"). It has no visible effect.
- **Interactions** Identical to AlurSurat: the open, `onNo`, `pilihFile` (instant), `ok` with its two ordered causes, the refusal shown only after input, `terbit`/`tolak` re-checked on press, `keTolak`, `pulang` and `keBuka` with their keep and clear rules, and the same `pesan` and Riwayat texts.
  - Breadcrumb → `kembaliKe('/WebPermohonanSurat')`.
  - Side-nav items → `go`.
  - Menu toggle below 860 px → open or close the item list and footer.
- **Motion** none. The keyframes `isi`, `muncul` and `titik` are declared but unused. There are no timers.
- **Links out**
  - Breadcrumb "Permohonan surat" → `/WebPermohonanSurat` (up link).
  - Side nav (go): `/WebBerandaJabatan`, `/WebBeranda`, `/WebDokumenGereja` (active), `/WebPengumuman`, `/WebWartaArsip`, `/WebDataAnggota`, `/Ibadah`, `/Panitia`, `/WebKotakMasuk`, `/WebPenugasan`.
  - **Inbound** PetaPlatform ("Alur · Permohonan surat" → "Web").
- **Mock data** Same as AlurSurat. The footer reads "Olvie Pangemanan", "Sekretaris Jemaat".
- **Prototype-only** none. Keadaan panel: `keadaan` (Alur).
- **Acceptance checks**
  1. `/WebAlurSurat` at 1440 → the 10-item side nav has "Dokumen gereja" active, and the footer reads "Olvie Pangemanan · Sekretaris Jemaat". The page shows the breadcrumb "Permohonan surat", the h1 "Alur · Permohonan surat" and three full-width request cards.
  2. "Buka permohonan" on Agustina Lasut → the detail card and Nomor surat are on the left. The file slot and three buttons are on the right, in one row. "Keluarga · Kolom" reads "Wenas-Lasut · Kolom 7".
  3. Type "028/SKet/XI/2026" → "Tidak dapat dilakukan: Terbitkan surat. salinan bertanda tangan belum terlampir." sits above the buttons in the right column. Tap "Pilih file", then press "Terbitkan surat" once → the list shows the status note "Surat keterangan Agustina Lasut diterbitkan dengan No. 028/SKet/XI/2026." and the third card is "Diterbitkan".
  4. "Tidak diterbitkan" on another request → a single-column form. "Catat tidak diterbitkan" stays grey until a non-blank reason is typed.
  5. At 860 → the "Menu" top bar shows, and the `buka` columns still sit side by side. At 700 they stack, with the file slot under the Nomor surat field, and there is no horizontal scroll.
  6. "Dokumen gereja" → `/WebDokumenGereja`; "Panitia" → `/Panitia` (a phone board in its frame); breadcrumb → `/WebPermohonanSurat`.
- **Notes** All AlurSurat notes apply. "Ibadah dan kegiatan" and "Panitia" link to phone boards (Q26); follow the board.

### AlurWarta — 71 · Alur · Warta mingguan

- **Source** `docs/design/handoff/canvas/boards/AlurWarta.dc.html` · page Putaran 3 · Sekretariat (`p3`) · form Phone 390×844 · interactive yes
- **Route** `/AlurWarta`, no child routes (the four views replace the body under one fixed header) · **Widget** `AlurWartaScreen` in `lib/screens/p3/alur_warta.dart`
- **Purpose** Sekretaris Jemaat (Olvie Pangemanan), journey step 3 ("Pengumuman", "Warta Jemaat · edisi 22/11/2026", "Alur · Warta mingguan", "A4 · Warta Jemaat edisi 22/11/2026"). One edition of the weekly Warta goes from Draf to published, with these rules:
  - P17: the Sekretaris picks per edition which **published** announcements go in. An announcement not addressed to all members carries a caution when picked.
  - P18: after "Sudah diperiksa" or "Disetujui" the content is locked; changing it means returning to Draf.
  - TampilanNama: a member's name choice is followed. Only the Sekretaris may show a name as an exception, with a reason, recorded in Riwayat.
  - Foundations: what is published never changes silently, and a correction is a linked revision ("ralat").
  - Only Diverifikasi life events appear: Baptisan · Gabriel Wenas is left out while still Diajukan.
  - Q30: the audience label is "Pelayan dan pengurus".
  - P12: reasons and the "Yang diralat" text must not be blank.
  - Also typed dates as hh/bb/tttt, TombolBersyarat and RiwayatAlur.
- **Shell** Phone header with back, no tab bar. Back label "Kembali ke Warta Jemaat". Title "Alur · Warta mingguan". Subtitle "Dari pengumuman sampai edisi 22/11/2026 terbit".
- **Layout** The body column (gap 16) shows one of four views.
  **View `warta`** (start), top to bottom:
  1. *Edition row* (space-between, centred, gap 16): "Edisi 22/11/2026" (16/700) and the status badge. The badge shape follows the status:
     - "Draf" → `draf`;
     - "Sudah diperiksa" → `lautg`;
     - "Disetujui" → `laut`;
     - "Diterbitkan" → `tinta`.
  2. *Status note* (only when `pesan` is not empty).
  3. *Pengumuman card* (detail card, padding 14 16, gap 6):
     - Heading block: "Pengumuman" (700) over 13 `tinta3` "Sekretaris Jemaat memilih dari pengumuman yang Diterbitkan".
     - One row per announcement whose status is Diterbitkan, in list order. Each row:
       - A wrapping row, items centred, gap 6 vertical × 12 horizontal, with a 1 `garis` top rule and padding-top 8.
       - Text column (flex 1 1 180, min width 0): `{judul} · {waktu or isi}` (600/14), then 13 `tinta3` `Ditujukan untuk: {penerima}`. When the item is picked and the audience is not "Semua anggota", " · perhatikan: Warta dibaca semua anggota" is added.
       - ChipPilihan toggle with `aria-pressed`. Picked: "Masuk edisi ini" (selected look). Not picked: "Tidak masuk" (unselected look).
       - Wrap rule (CSS wrap with a 180 basis): if 180 + 12 + chip width fits the row, the chip sits at the right and the text takes the rest. Otherwise the chip drops under the text, aligned to the start. At 316 inner width "Tidak masuk" fits on the line and "Masuk edisi ini" wraps under the text.
     - The initial rows:
       - "Kerja bakti halaman gereja · Sabtu, 21/11/2026 pukul 07.00" / "Ditujukan untuk: Semua anggota" / "Masuk edisi ini";
       - "Rapat pelayan khusus · Rabu, 25/11/2026 pukul 19.00" / "Ditujukan untuk: Pelayan dan pengurus" / "Tidak masuk".
     - Only while Draf: the text button "Tulis pengumuman", aligned to the start.
  4. *Peristiwa jemaat card* (detail card):
     - Heading block: "Peristiwa jemaat" over 13 `tinta3` "hanya yang Diverifikasi; nama mengikuti Tampilan nama".
     - 14 `tinta2`: "Syukur HUT pernikahan: " then strong `tinta` "Keluarga Wenas-Lasut — Kolom 7".
     - 14 `tinta2`: "Sampul syukur: " then strong `tinta` `namaTeks`. That is "Tanpa nama, Kolom 4", or after the exception "Kel. Mamahit — Kolom 4 (pengecualian tercatat)".
     - Only while Draf and no exception is recorded: the text button "Tampilkan nama (pengecualian)", aligned to the start.
     - 13 `tinta3`: "Tidak masuk: Baptisan · Gabriel Wenas, masih Diajukan."
  5. *Ringkasan keuangan card* (detail card):
     - Heading block: "Ringkasan keuangan" over 13 `tinta3` "dari bulan yang Sudah ditutup".
     - Key–value rows with mono values: "Pendapatan Oktober 2026" → "Rp14.820.000"; "Belanja Oktober 2026" → "Rp11.455.000".
  6. *Status actions* (one of these):
     - Draf: a button row with "Tandai sudah diperiksa" (ink primary, 340).
     - Sudah diperiksa: a button row with "Setujui untuk diterbitkan" (ink primary) and "Kembali ke Draf" (text button), about 171 each. The primary label wraps to two lines.
     - Disetujui: a button row with "Terbitkan" (**sea primary**: `laut` field, `diLaut` text) and "Kembali ke Draf" (text button).
     - Diterbitkan: 14 `tinta2` "Diterbitkan untuk semua anggota. Edisi ini tidak berubah lagi; ralat menjadi revisi yang tertaut.", then a button row with "Buat ralat" (secondary, 340).
  7. *Lock note* (Sudah diperiksa and Disetujui only): 13 `tinta3` "Untuk mengubah isinya, kembalikan edisi ke Draf lebih dulu."
  8. *Ralat card* (only after a ralat is published; detail card):
     - Top row: "Ralat (revisi edisi 22/11/2026)" (700) and the badge "Diterbitkan" (`tinta`).
     - 14 `tinta2`: the ralat text.
     - 13 `tinta3`: "Tertaut ke edisi asli, yang tetap tampil apa adanya."
  9. *Riwayat* (when there are rows).
  **View `umum`** (write an announcement):
  1. Field "Judul": input with hint "Judul pengumuman".
  2. Field "Isi": textarea.
  3. *Ditujukan untuk*: a column (gap 6) with the label in 14 `tinta2`, then wrapping chips (gap 8): "Semua anggota", "Pelayan dan pengurus", "Kolom 7". None is selected at first.
  4. Field "Berakhir pada": input with hint "hh/bb/tttt"; helper "Boleh kosong. Setelah tanggal ini pengumuman diarsipkan sendiri."
  5. 13 `tinta3`: "Hanya Sekretaris Jemaat yang menerbitkan. Sekretaris Jemaat juga yang memilih pengumuman mana yang masuk ke tiap edisi Warta."
  6. *Refusal line* "Tidak dapat dilakukan: Terbitkan." + cause.
  7. *Button row*:
     - "Terbitkan" (TombolBersyarat, ink when met) and "Simpan sebagai draf" (secondary) share a row.
     - "Batalkan" (text button) wraps below at 340.
  **View `nama`** (name exception):
  1. *Card* (detail card) with key–value rows:
     - "Edisi" → "Warta Jemaat 22/11/2026";
     - "Pilihan anggota" → "Tanpa nama";
     - "Akan diterbitkan sebagai" → "Kel. Mamahit — Kolom 4";
     - then 13 `tinta3` "Tampilan nama pilihan anggota wajib diikuti. Pengecualian hanya untuk keperluan resmi, tata kelola, hukum atau pertanggungjawaban."
  2. Field "Alasan · wajib": textarea.
  3. *Refusal line* "Tidak dapat dilakukan: Catat pengecualian." This line never shows (see Notes).
  4. *Button row*: "Catat pengecualian" (TombolBersyarat) and "Batalkan" (text button).
  **View `ralat`**:
  1. *Card*:
     - Top row: "Warta Jemaat · edisi 22/11/2026" (700) and "Diterbitkan" (`tinta`).
     - 13 `tinta3`: "Edisi asli tidak diubah. Ralat diterbitkan sebagai revisi yang tertaut."
  2. Field "Yang diralat · wajib": textarea.
  3. *Refusal line* "Tidak dapat dilakukan: Terbitkan ralat." This line never shows (see Notes).
  4. *Button row*: "Terbitkan ralat" (TombolBersyarat) and "Batalkan" (text button).
- **Components**
  - LencanaStatus: edition badge (Draf / Sudah diperiksa / Disetujui / Diterbitkan) and the ralat badges.
  - ChipPilihan: the announcement toggles and "Ditujukan untuk".
  - TombolBersyarat: "Terbitkan" (announcement), "Catat pengecualian", "Terbitkan ralat".
  - Penolakan: the announcement refusal.
  - IsianAlasan: "Alasan · wajib", "Yang diralat · wajib".
  - TampilanNama: the rule shown by the exception view.
  - RiwayatAlur: Riwayat.
  - Tombol: ink primaries, the sea primary "Terbitkan", secondary "Buat ralat" and "Simpan sebagai draf", text buttons.
  - Repeated patterns that are not components: the section card with a heading and caption, the announcement row with its toggle, the status note, and the lock note.
- **Internal views and states**
  - The flow object `a` starts as `{ pesan: '', riw: [], v: 'warta', st: 'Draf', U: [ ['Kerja bakti halaman gereja','Sabtu, 21/11/2026 pukul 07.00','Semua anggota','Diterbitkan',true], ['Rapat pelayan khusus','Rabu, 25/11/2026 pukul 19.00','Pelayan dan pengurus','Diterbitkan',false] ], uj: '', ui: '', uUntuk: '', uAkhir: '', nama: false, alasan: '', ralat: '', ralatTeks: '' }`.
    - Each entry of `U` is [judul, waktu-or-isi, penerima, status, masuk].
    - `v` ∈ `warta` | `umum` | `nama` | `ralat`.
    - `st` ∈ `Draf` | `Sudah diperiksa` | `Disetujui` | `Diterbitkan`.
  - Views and sub-states:
    - `warta` × four statuses, each with or without the status note, the ralat card and Riwayat;
    - `umum`: empty, refused (five causes) or met;
    - `nama`: empty or filled;
    - `ralat`: empty or filled.
  - Unused helpers (`balik`, `baris`, `hal`, `rp`) render nothing.
- **Tweaks** (Keadaan panel) `keadaan` (enum, single option "Alur", default "Alur"). It has no visible effect.
- **Interactions**
  - *Announcement toggle* (`u.balik`):
    - Only while `st == 'Draf'`. In any other status the tap does nothing: no visual change and no message.
    - In Draf it flips `masuk` for that item, clears `pesan`, and prepends a Riwayat row: "16/11/2026 · Pengumuman “{judul}” {dikeluarkan dari | dipilih masuk ke} edisi 22/11/2026 · Olvie Pangemanan". "dikeluarkan dari" is used when the item was in.
  - "Tulis pengumuman" (`keUmum`) → `v = 'umum'`, `pesan = ''`. The form keeps earlier `uj`, `ui`, `uUntuk` and `uAkhir` if they were not saved.
  - Judul (`onUj`), Isi (`onUi`) and Berakhir pada (`onUAkhir`) store their text exactly as typed. Berakhir pada is free text: there is no mask and no auto-slash.
  - A "Ditujukan untuk" chip → `uUntuk` = that option and `pesan = ''`. There is no deselect.
  - Condition `okU` for "Terbitkan", in order. The first unmet one is the cause:
    1. `uj` blank after trimming → "judul belum diisi."
    2. `ui` blank after trimming → "isi belum diisi."
    3. no `uUntuk` → "penerima belum dipilih."
    4. `uAkhir` not blank and not a valid date → "tanggal berakhir tidak dikenali. Contoh: 30/11/2026."
    5. `uAkhir` not blank and on or before 16/11/2026 → "tanggal berakhir harus setelah hari ini (16/11/2026)."
  - A valid date matches exactly `dd/mm/yyyy` after trimming: two-digit day, two-digit month and four-digit year, with month 1–12 and day 1–31. There is no per-month day check, so "31/02/2027" passes. It is compared as yyyymmdd against 20261116. "1/12/2026" is not recognised.
  - The refusal line shows when any of `uj`, `ui`, `uUntuk`, `uAkhir` is non-empty (spaces count).
  - "Terbitkan" (`uTerbit`) re-checks `okU` on press; if it is unmet, nothing happens. If met, with J = `uj` trimmed, I = `ui` trimmed and P = `uUntuk`:
    - `masuk = (P == 'Semua anggota')`;
    - `[J, I, P, 'Diterbitkan', masuk]` is appended to `U`;
    - `uj`, `ui`, `uUntuk` and `uAkhir` are cleared and `v = 'warta'`;
    - `pesan` is "Pengumuman “J” diterbitkan untuk Semua anggota dan dipilih masuk ke Warta edisi 22/11/2026." when P is Semua anggota, otherwise "Pengumuman “J” diterbitkan untuk {P}. Belum dipilih masuk Warta; Anda dapat memilihnya di edisi ini.";
    - a Riwayat row "16/11/2026 · {pesan}" is prepended, with no actor suffix.
    The new row appears last in the Pengumuman card as "J · I".
  - "Simpan sebagai draf" (`uDraf`) has **no condition**. It appends `[J, I, P, 'Draf', false]`, clears the form and sets `v = 'warta'`. `pesan` and the Riwayat row read "Pengumuman “J” disimpan sebagai Draf; belum terlihat anggota." A Draf announcement does not appear in the Pengumuman card. With an empty title the text reads "Pengumuman “” …", as on the canvas.
  - "Batalkan" in `umum`, `nama` and `ralat` (`pulang`) → `v = 'warta'`, `pesan = ''`. Typed values are kept, except that `ralat` is cleared on the next "Buat ralat".
  - "Tampilkan nama (pengecualian)" (`keNama`) → `v = 'nama'`, `pesan = ''`.
  - Alasan (`onAlasan`) → `alasan` exactly as typed. Condition `okN`: `alasan` is not blank after trimming. There is no cause text.
  - "Catat pengecualian" (`catatNama`) re-checks `okN` on press; if it is unmet, nothing happens. If met, with A = `alasan` trimmed:
    - `nama = true`, `alasan = ''`, `v = 'warta'`;
    - `pesan` becomes "Pengecualian tampilan nama tercatat; anggota diberi tahu. Edisi berikutnya kembali memakai “Tanpa nama”.";
    - a Riwayat row is prepended: "16/11/2026 · Pengecualian tampilan nama · Kel. Mamahit — Kolom 4 · alasan: {A} · Olvie Pangemanan, Sekretaris Jemaat".
    After this, "Sampul syukur" reads "Kel. Mamahit — Kolom 4 (pengecualian tercatat)" and the exception button is gone for good.
  - Status steps (`langkah`, no conditions). Each sets `st`, clears `pesan`, and prepends "16/11/2026 · {text} · Olvie Pangemanan, Sekretaris Jemaat":
    - "Tandai sudah diperiksa" → `st = 'Sudah diperiksa'`, text "Edisi 22/11/2026 ditandai Sudah diperiksa".
    - "Setujui untuk diterbitkan" → `st = 'Disetujui'`, text "Edisi 22/11/2026 Disetujui untuk diterbitkan".
    - "Terbitkan" (sea primary) → `st = 'Diterbitkan'`, text "Edisi 22/11/2026 Diterbitkan untuk semua anggota".
    - "Kembali ke Draf" (in Sudah diperiksa and Disetujui) → `st = 'Draf'`, text "Edisi 22/11/2026 dikembalikan ke Draf".
    There is no way back from Diterbitkan.
  - "Buat ralat" (`keRalat`) → `v = 'ralat'`, `ralat = ''`, `pesan = ''`.
  - Yang diralat (`onRalat`) → `ralat` exactly as typed. Condition `okR`: `ralat` is not blank after trimming. There is no cause text.
  - "Terbitkan ralat" (`terbitRalat`) re-checks `okR` on press; if it is unmet, nothing happens. If met, with R = `ralat` trimmed:
    - `ralatTeks = R`, `ralat = ''`, `pesan = ''`, `v = 'warta'`;
    - a Riwayat row is prepended: "16/11/2026 · Ralat edisi 22/11/2026 diterbitkan sebagai revisi: {R}".
    A second ralat replaces the text in the one ralat card.
  - Back arrow → `kembaliKe('/WartaArsip')`.
- **Motion** none. The keyframes `isi`, `masuk`, `muncul` and `pudar` are declared but unused. Badge, chip and view changes are instant. There are no timers.
- **Links out** Back arrow "Kembali ke Warta Jemaat" → `/WartaArsip` (up link). **Inbound** PetaPlatform ("Alur · Warta mingguan" → "Ponsel").
- **Mock data**
  - Edition 22/11/2026, which starts as Draf.
  - Announcements: "Kerja bakti halaman gereja" (Sabtu, 21/11/2026 pukul 07.00, Semua anggota, picked) and "Rapat pelayan khusus" (Rabu, 25/11/2026 pukul 19.00, Pelayan dan pengurus, not picked).
  - Audiences: "Semua anggota", "Pelayan dan pengurus", "Kolom 7".
  - Peristiwa: "Syukur HUT pernikahan: Keluarga Wenas-Lasut — Kolom 7"; the thanksgiving envelope "Tanpa nama, Kolom 4", whose exception name is "Kel. Mamahit — Kolom 4"; excluded "Baptisan · Gabriel Wenas, masih Diajukan".
  - Finance: Pendapatan Oktober 2026 Rp14.820.000; Belanja Oktober 2026 Rp11.455.000. These are the same as A4Warta.
  - Actor "Olvie Pangemanan, Sekretaris Jemaat". Today 16/11/2026, compared as 20261116.
- **Prototype-only** none. Keadaan panel: `keadaan` (Alur).
- **Acceptance checks**
  1. Open `/AlurWarta` → the page shows:
     - "Edisi 22/11/2026" with a dashed "Draf" badge;
     - the Pengumuman card with "Kerja bakti …" on "Masuk edisi ini" (`tinta`) and "Rapat pelayan khusus …" on "Tidak masuk", then "Tulis pengumuman";
     - "Sampul syukur: Tanpa nama, Kolom 4" and "Tampilkan nama (pengecualian)";
     - Rp14.820.000 and Rp11.455.000 in mono;
     - "Tandai sudah diperiksa"; no Riwayat.
  2. Tap "Tidak masuk" on "Rapat pelayan khusus" →
     - the chip reads "Masuk edisi ini";
     - the caption reads "Ditujukan untuk: Pelayan dan pengurus · perhatikan: Warta dibaca semua anggota";
     - Riwayat shows "16/11/2026 · Pengumuman “Rapat pelayan khusus” dipilih masuk ke edisi 22/11/2026 · Olvie Pangemanan".
  3. "Tandai sudah diperiksa" →
     - the badge reads "Sudah diperiksa" (`laut` line and text);
     - "Setujui untuk diterbitkan" and "Kembali ke Draf" show, with the lock note under them;
     - "Tulis pengumuman" and "Tampilkan nama (pengecualian)" are gone;
     - tapping either announcement chip changes nothing.
  4. "Setujui untuk diterbitkan" → a `laut` badge "Disetujui" and a `laut` button "Terbitkan". Press it →
     - the badge reads "Diterbitkan" (`tinta`);
     - the text "Diterbitkan untuk semua anggota. …" and "Buat ralat" show;
     - the lock note is gone;
     - Riwayat lists the steps newest first.
  5. "Buat ralat" → "Terbitkan ralat" is grey. Type "Kerja bakti mulai pukul 07.30" → the button turns `tinta`. Press it → the card "Ralat (revisi edisi 22/11/2026)" shows with "Diterbitkan" and the text, and Riwayat's top row is "16/11/2026 · Ralat edisi 22/11/2026 diterbitkan sebagai revisi: Kerja bakti mulai pukul 07.30".
  6. Fresh board, then "Tulis pengumuman":
     - Type Judul "Latihan paduan suara" → "Tidak dapat dilakukan: Terbitkan. isi belum diisi."
     - Isi "Kamis, 19/11/2026 pukul 18.00" → "penerima belum dipilih."
     - Tap "Kolom 7" → the button turns `tinta`.
     - Berakhir pada "1/12/2026" → "tanggal berakhir tidak dikenali. Contoh: 30/11/2026."
     - "16/11/2026" → "tanggal berakhir harus setelah hari ini (16/11/2026)."
     - "30/11/2026" → met.
  7. Press "Terbitkan" once → the warta view shows:
     - the status note "Pengumuman “Latihan paduan suara” diterbitkan untuk Kolom 7. Belum dipilih masuk Warta; Anda dapat memilihnya di edisi ini.";
     - a third row "Latihan paduan suara · Kamis, 19/11/2026 pukul 18.00" / "Ditujukan untuk: Kolom 7" / "Tidak masuk".
     The same with "Semua anggota" gives "… diterbitkan untuk Semua anggota dan dipilih masuk ke Warta edisi 22/11/2026." and "Masuk edisi ini".
  8. "Tulis pengumuman", type only Judul "Rapat komisi", then "Simpan sebagai draf" → the status note reads "Pengumuman “Rapat komisi” disimpan sebagai Draf; belum terlihat anggota." and no new row appears in the card.
  9. "Tampilkan nama (pengecualian)" → "Catat pengecualian" is grey and pressing it does nothing. Type "Permintaan resmi keluarga" and press once →
     - the status note reads "Pengecualian tampilan nama tercatat; anggota diberi tahu. Edisi berikutnya kembali memakai “Tanpa nama”.";
     - "Sampul syukur" reads "Kel. Mamahit — Kolom 4 (pengecualian tercatat)";
     - the exception button is gone.
  10. Back arrow → `/WartaArsip`.
- **Notes**
  - `sebabN` and `sebabR` are `x && !x`, so "Tidak dapat dilakukan: Catat pengecualian." and "Tidak dapat dilakukan: Terbitkan ralat." never show. The board wins: the grey button has no reason line.
  - "Simpan sebagai draf" saves without any check. Keep it; it is the board's behaviour.
  - The status steps have no condition and no second person. Keep the board: one actor does every step on this flow.
  - "Berakhir pada" is free text, not the hh/bb/tttt mask some boards use. It is checked while typing, as TombolBersyarat requires.
  - "Berakhir pada" is checked but never stored: `simpan` builds the new `U` entry without `uAkhir` and then clears it, so the expiry date is shown nowhere after saving. The audience is stored and shown as "Ditujukan untuk: {P}".
  - The sea primary "Terbitkan" is the only `laut` primary on this board; every other primary is `tinta`. Keep it as drawn.
  - The Riwayat rows have three different actor endings: status steps and the name exception end " · Olvie Pangemanan, Sekretaris Jemaat"; toggles end " · Olvie Pangemanan" without the post; saved announcements (published or Draf) and ralat rows have no actor. Copy each verbatim.
  - The phone chip wrap is computed from the text basis of 180. Do not simply put the text and the chip in a Row.

### WebAlurWarta — Web · Alur · Warta mingguan

- **Source** `docs/design/handoff/canvas/boards/WebAlurWarta.dc.html` · page Putaran 3 · Sekretariat (`p3`) · form Laptop page (preview 1440×1250, `expand: fill`) · interactive yes
- **Route** `/WebAlurWarta`, no child routes · **Widget** `WebAlurWartaScreen` in `lib/screens/p3/web_alur_warta.dart`
- **Purpose** Same as AlurWarta on the laptop, for the Sekretaris Jemaat (Q26). P17, P18, TampilanNama, linked revisions, Q30, P12.
- **Shell** Platform side nav with **"Warta Jemaat" active** (the fifth item; `NavSamping(item: navPlatform, aktif: 4, …)`). Footer: "**Olvie Pangemanan** · Sekretaris Jemaat".
- **Layout** Main column:
  1. *Web title block*: breadcrumb "Warta Jemaat" (→ `/WebWartaArsip`), h1 "Alur · Warta mingguan", subtitle "Dari pengumuman sampai edisi 22/11/2026 terbit".
  2. *Content column* (max 1120, gap 16), holding one view:
     - **`warta`**:
       - The edition row and the status note, full width (`warta` 1–2).
       - Then a two-column row:
         - Left: the Pengumuman card, the Peristiwa jemaat card and the Ringkasan keuangan card (`warta` 3–5).
         - Right: the status actions (`warta` 6), the lock note (7), the ralat card (8) and Riwayat (9, h2 and card 12 apart).
       - In the 484 right column, "Setujui untuk diterbitkan" and "Kembali ke Draf" sit side by side at about 238.
       - In the 608 left column, each announcement keeps its chip on the same line as its text.
     - **`umum`**: a two-column row.
       - Left: Judul, Isi, Ditujukan untuk and Berakhir pada (`umum` 1–4).
       - Right: the note (`umum` 5), the refusal line (6) and the button row (7). "Terbitkan", "Simpan sebagai draf" and "Batalkan" sit on one row at about 156 each, and "Simpan sebagai draf" wraps to two lines.
     - **`nama`**: a two-column row.
       - Left: the exception card (`nama` 1).
       - Right: the Alasan field, the (dead) refusal line and the button row (`nama` 2–4).
     - **`ralat`**: a single column, as AlurWarta `ralat`, full width up to 1120. Buttons are 340 each.
     Every style, text and colour is as in AlurWarta, on a 15 base. Inputs and textareas inherit 14 `tinta2`.
- **Components** As AlurWarta, plus the platform side nav.
- **Internal views and states** Identical to AlurWarta (the same flow object and initial `U`, four views, four statuses). The below-860 menu toggle is page-local.
- **Tweaks** (Keadaan panel) `keadaan` (enum, single option "Alur", default "Alur"). It has no visible effect.
- **Interactions** Identical to AlurWarta:
  - toggles only in Draf, with their Riwayat rows;
  - `keUmum`, the typed fields, the audience chips and the five ordered `okU` causes, with the refusal shown only after input;
  - `uTerbit` re-checked on press and auto-picked for "Semua anggota"; `uDraf` unguarded;
  - `keNama` and `catatNama`; `langkah` ×4; `keRalat` and `terbitRalat`; `pulang`.
  Breadcrumb → `kembaliKe('/WebWartaArsip')`. Side nav → `go`. Menu toggle below 860 px.
- **Motion** none. The keyframes `isi`, `muncul` and `titik` are declared but unused. There are no timers.
- **Links out**
  - Breadcrumb "Warta Jemaat" → `/WebWartaArsip` (up link).
  - Side nav (go): `/WebBerandaJabatan`, `/WebBeranda`, `/WebDokumenGereja`, `/WebPengumuman`, `/WebWartaArsip` (active), `/WebDataAnggota`, `/Ibadah`, `/Panitia`, `/WebKotakMasuk`, `/WebPenugasan`.
  - **Inbound** PetaPlatform ("Alur · Warta mingguan" → "Web").
- **Mock data** Same as AlurWarta. Footer "Olvie Pangemanan", "Sekretaris Jemaat".
- **Prototype-only** none. Keadaan panel: `keadaan` (Alur).
- **Acceptance checks**
  1. `/WebAlurWarta` at 1440 → "Warta Jemaat" is active in the side nav and the breadcrumb reads "Warta Jemaat". "Edisi 22/11/2026" with "Draf" spans the full width. The three cards are on the left and "Tandai sudah diperiksa" is on the right.
  2. Toggle "Rapat pelayan khusus" in → the caution caption appears, and a Riwayat row appears in the right column under the button.
  3. Run "Tandai sudah diperiksa" → "Setujui untuk diterbitkan" → "Terbitkan" → the right column shows "Diterbitkan untuk semua anggota. …" and "Buat ralat". Riwayat has four rows, newest first: the three steps on top, the toggle row of check 2 at the bottom. Between the steps, the lock note shows only in "Sudah diperiksa" and "Disetujui".
  4. Re-open `/WebAlurWarta` (fresh state, Draf: "Tulis pengumuman" exists only in Draf), then "Tulis pengumuman" → the fields are on the left and the note and buttons on the right. With Judul and Isi filled and no audience → "Tidak dapat dilakukan: Terbitkan. penerima belum dipilih." sits above the three buttons.
  5. "Batalkan", then "Tampilkan nama (pengecualian)" → the exception card is on the left and Alasan with "Catat pengecualian" on the right.
  6. At 860 → the "Menu" top bar shows and the columns still sit side by side. At 700 they stack with no horizontal scroll.
  7. "Warta Jemaat" in the nav → `/WebWartaArsip` (go); breadcrumb → `/WebWartaArsip`.
- **Notes** All AlurWarta notes apply. The preview height is 1250 because the `warta` view is the longest; the page scrolls as a whole.

### A4Warta — A4 · Warta Jemaat edisi 22/11/2026

- **Source** `docs/design/handoff/canvas/boards/A4Warta.dc.html` · page Putaran 3 · Sekretariat (`p3`) · form A4 portrait (794×1123) · interactive no (the canvas flags it interactive, but there is no state and no handler)
- **Route** `/A4Warta`, no child routes · **Widget** `A4WartaScreen` in `lib/screens/p3/a4_warta.dart`
- **Purpose** The published Warta Jemaat of Minggu 22 November 2026 as the one fixed A4 template (Q27: one fixed template published as a PDF and readable in the app; no church-editable layout). It is read by every member and opened by the Sekretaris Jemaat with "Lihat PDF" from WartaEditor. Names follow Tampilan nama ("Sampul syukur: Tanpa nama, Kolom 4"). Attendance is a count only, with no names (foundations). The finance summary is from the official October report.
- **Shell** A4 page: a fixed 794 × 1123 white page (`permukaan`) centred on `kertas`, scaled down to fit narrower windows, and scrolling. There is no header and no back control: leave with system or browser Back.
- **Layout** The page: padding 56 60 0, a column with gap 20, sans 14/1.45 `tinta`. Overflow is clipped.
  1. *Masthead* (centred, 2 `tinta` bottom rule, padding-bottom 12):
     - "WARTA JEMAAT" (30/700, letter-spacing 1);
     - "GMIM Jemaat Karunia · Minggu, 22 November 2026" (15).
  2. *Sections*. Each is a heading plus a column of lines with gap 3.
     - Heading: 13/700, letter-spacing 0.5, upper case, a 1.5 `tinta` bottom rule, padding-bottom 3, margin-bottom 6. Write the text as in the source and upper-case it in code. Flutter has no text-transform, so `toUpperCase()` the string.
     - A two-part line is a row (space-between, gap 16): the label, then the value in mono, not shrinking.
     The sections:
     a. "Ibadah minggu ini": Ibadah Subuh `05.00` · Ibadah Pagi `09.00` · Ibadah Malam `18.00`.
     b. "Pengumuman", in paragraphs:
        - strong "Kerja bakti halaman gereja." + " Sabtu, 21 November 2026 pukul 07.00. Membawa alat kebersihan masing-masing."
        - strong "Pendaftaran katekisasi sidi 2027." + " Dibuka sampai 31 Desember 2026 di Sekretariat Jemaat."
     c. "Peristiwa jemaat": "Syukur HUT pernikahan: Keluarga Wenas-Lasut — Kolom 7" · "Sampul syukur: Tanpa nama, Kolom 4".
     d. "Jumlah kehadiran · Minggu, 15 November 2026": Ibadah Subuh `96` · Ibadah Pagi `231` · Ibadah Malam `85`, then a total row "Jumlah" `412`. The total row is 700, with a 1 `tinta` top rule and padding-top 3.
     e. "Ringkasan keuangan · Oktober 2026": Pendapatan `Rp14.820.000` · Belanja `Rp11.455.000`, then a `tinta2` line "Dari laporan resmi Oktober 2026. Laporan lengkap ada pada Bendahara Jemaat."
  3. *Footer*, pinned:
     - Absolute: left 60, right 60, bottom 36.
     - A row, space-between, gap 24, with a 1 `tinta` top rule and padding-top 8. Text is `tinta2` at 12 px in the source; use 13 (see Notes).
     - Left: "Diterbitkan 21/11/2026 oleh Sekretaris Jemaat · nama mengikuti Tampilan nama pilihan anggota".
     - Right, in mono and not shrinking: "Edisi 22/11/2026 · halaman 1 dari 1".
- **Components** none from the design system. Repeated patterns: the A4 section heading with its rule, and the label–value line with a mono value. Share these with the other A4 pages if that page widget already exists.
- **Internal views and states** One static page. No state object (`stateInit` null).
- **Tweaks** none (no `data-props` tweaks). The Keadaan panel shows only the global switches and links.
- **Interactions** none. Pinch or browser zoom only, as for every A4 page.
- **Motion** none. The keyframes `isi`, `masuk`, `muncul` and `pudar` are declared but unused.
- **Links out** none (manifest `links` and `jsLinks` are empty). **Inbound** WartaEditor ("Lihat PDF", two places), WebWartaEditor ("Lihat PDF", two places), PetaPlatform ("A4 · Warta Jemaat"). These links push; Back returns to them.
- **Mock data**
  - Edition Minggu 22 November 2026, published 21/11/2026 by the Sekretaris Jemaat. Church "GMIM Jemaat Karunia".
  - Services: Subuh 05.00, Pagi 09.00, Malam 18.00.
  - Announcements: Kerja bakti halaman gereja (Sabtu, 21 November 2026 pukul 07.00) and Pendaftaran katekisasi sidi 2027 (until 31 Desember 2026, Sekretariat Jemaat).
  - Peristiwa: Keluarga Wenas-Lasut — Kolom 7; Tanpa nama, Kolom 4.
  - Attendance 15 November 2026: 96 + 231 + 85 = 412.
  - Oktober 2026: Pendapatan Rp14.820.000, Belanja Rp11.455.000.
- **Prototype-only** none.
- **Acceptance checks**
  1. `/A4Warta` on a 1440 window → one 794 × 1123 white page centred on `kertas`, with the masthead "WARTA JEMAAT" over "GMIM Jemaat Karunia · Minggu, 22 November 2026" and a 2 px rule under it.
  2. Five section headings read, in this order and in capitals: "IBADAH MINGGU INI", "PENGUMUMAN", "PERISTIWA JEMAAT", "JUMLAH KEHADIRAN · MINGGU, 15 NOVEMBER 2026", "RINGKASAN KEUANGAN · OKTOBER 2026". Each has a 1.5 `tinta` rule.
  3. The times 05.00, 09.00 and 18.00, the counts 96, 231, 85 and 412, and the amounts Rp14.820.000 and Rp11.455.000 are mono and right-aligned. The "Jumlah 412" row is bold and has a rule above it.
  4. The footer sits 36 from the page bottom with a rule above it. It reads "Diterbitkan 21/11/2026 oleh Sekretaris Jemaat · nama mengikuti Tampilan nama pilihan anggota" on the left and, in mono, "Edisi 22/11/2026 · halaman 1 dari 1" on the right. The text is 13 px.
  5. On a 390-wide window the page scales down to fit the width, keeps its proportions, and scrolls vertically.
  6. From WartaEditor, "Lihat PDF" → `/A4Warta`. Browser Back → `/WartaEditor`.
- **Notes**
  - The footer uses 12 px text, below the 13 px minimum. Use 13, which is one of CONVENTIONS' twelve 12 px places.
  - Off-token sizes: 30 px masthead, 15 px subtitle, letter-spacing 1 and 0.5. Copy them.
  - CONVENTIONS lists #C9DAD9 as an illustration colour "in A4Warta". It does not occur in this board's source, so nothing here needs it.
  - The page content (the second announcement "Pendaftaran katekisasi sidi 2027", no "Rapat pelayan khusus") differs from AlurWarta's list. Each board keeps its own content.
  - The page is white on `kertas` in both themes. Keep the A4 page light in the dark theme, as for the other A4 boards; it is paper.

### PermohonanAnggota — 72 · Permohonan menjadi anggota

- **Source** `docs/design/handoff/canvas/boards/PermohonanAnggota.dc.html` · page Putaran 4 · Data jemaat (`p4`) · form Phone 390×844 · interactive yes
- **Route** `/PermohonanAnggota`, no child routes (the seven states replace the body under one fixed header) · **Widget** `PermohonanAnggotaScreen` in `lib/screens/p4/permohonan_anggota.dart`
- **Purpose** Anggota jemaat (Novita Wenas), journey step 1 ("Permohonan menjadi anggota", "Alur · Menjadi anggota"). A person with no matching record (P02) fills in their own membership request; the Penatua Kolom then verifies it. The board shows:
  - P10/P11: marital status is a field on the form, and with the birth date it gives "Kategori BIPRA: Pemuda".
  - Q28: a versioned default consent text, "Naskah versi 1 · 12/11/2026"; "Izin" is the word for consent.
  - A parent or guardian giving consent for a child.
  - The two-person rule: filling in is not verifying, and the requester is not a member until Diverifikasi ("Verifikasi bukan persetujuan keuangan dan tidak dilakukan oleh pemohon sendiri").
  - Returned and refused outcomes.
  - The way on to Tampilan nama.
- **Shell** Phone header with back, no tab bar. Back label "Kembali ke Data jemaat". Title "Permohonan menjadi anggota". Subtitle "Diisi sendiri, lalu diverifikasi Penatua Kolom".
- **Layout** The body column (gap 16) shows the view for `k ?? keadaan`.
  **Form card** (used by Mengisi and Izin belum diberikan): a detail card (padding 14 16) whose column gap is **12**. All fields are read-only inputs (the field style, typed-text style 14 `tinta2`, no cursor):
  1. "Nama lengkap" → "Novita Wenas".
  2. A grid `repeat(auto-fit, minmax(300, 1fr))` with gap 16, holding "Tanggal lahir" → "14/03/1996" and "Jenis kelamin" → "Perempuan". At 316 inner width it is one column, so the two fields stack 16 apart. They sit side by side only when the card is 616 or wider.
  3. "Status pernikahan" → "Belum pernah menikah", helper "Bersama tanggal lahir menentukan Kategori BIPRA: Pemuda".
  4. "Keluarga" → "Wenas-Lasut", helper "Setiap orang tetap punya datanya sendiri, termasuk anak".
  5. "Kolom" → "Kolom 7".
  **Consent card** (detail card, gap 6):
  - "Izin penggunaan data pribadi" (700);
  - 13 `tinta3` "Naskah versi 1 · 12/11/2026";
  - 14 `tinta2` "Data ini dipakai Jemaat Karunia untuk pelayanan, surat dan Warta Jemaat. Nama saya di publikasi mengikuti Tampilan nama yang saya pilih. Saya dapat mencabut izin dan meminta data saya dihapus.";
  - a checkbox row: a label row, gap 12, aligned to the top, min height 44, 14 `tinta`. The whole row is the target. The checkbox is the shared `KotakCentang` (components.md: 24 × 24, radius 4; unticked 1.5 `garisTegas` edge on `permukaan`; ticked `laut` fill with the `centang` icon in `diLaut`) with margin-top 2, then the statement.
  **Views**:
  - **Mengisi**: the form card; the consent card with a ticked checkbox and "Saya memberi izin penggunaan data pribadi saya."; a button row with "Ajukan permohonan" (ink primary, 340).
  - **Izin belum diberikan**: the same form card; the consent card with an **unticked** checkbox; a button row with "Ajukan permohonan" disabled (`garis` field, `tinta2` text, truly disabled). Under the button, 13 `tinta3`: "Tidak dapat dilakukan: izin penggunaan data pribadi belum diberikan."
  - **Untuk anak**: a form card (gap 12) with read-only fields "Nama anak" → "Gabriel Wenas", "Tanggal lahir" → "02/09/2019", "Orang tua atau wali" → "Novita Wenas". Then the consent card with a ticked checkbox and "Sebagai orang tua atau wali, saya memberi izin penggunaan data pribadi anak ini.", and "Ajukan permohonan" (ink primary).
  - **Diajukan**: a detail card (gap 6) with:
    - a top row "Permohonan menjadi anggota" (700) and the badge "Diajukan" (`garis`);
    - 14 `tinta2` "Diajukan 16/11/2026 10.12";
    - 13 `tinta3` "Berikutnya: Pnt. Hendrik Rumagit, Penatua Kolom 7, memverifikasi data ini. Anda belum menjadi anggota sampai permohonan Diverifikasi."
    There is no button.
  - **Dikembalikan**: a card with:
    - a top row "Permohonan menjadi anggota" and the badge "Dikembalikan" (`bata`);
    - 14 `tinta2` "Alasan: tanggal lahir berbeda dengan surat baptis. Mohon diperiksa lagi.";
    - 13 `tinta3` "Oleh Pnt. Hendrik Rumagit, 17/11/2026 08.40".
    Then a button row with "Ubah dan ajukan lagi" (ink primary, 340).
  - **Diverifikasi**: a card with:
    - a top row "Novita Wenas" (700) and the badge "Diverifikasi" (`laut`: `laut` field, `diLaut` text);
    - 14 `tinta2` "Anggota jemaat · Keluarga Wenas-Lasut · Kolom 7";
    - 13 `tinta3` "Diverifikasi oleh Pnt. Hendrik Rumagit, 17/11/2026 19.05. Verifikasi bukan persetujuan keuangan dan tidak dilakukan oleh pemohon sendiri."
    Then a button row with the link "Atur tampilan nama saya": secondary look, min height 48, 340 wide, content centred, no underline.
  - **Tidak diterima**: a card with:
    - a top row "Permohonan menjadi anggota" and the badge "Tidak diterima" (`bata`);
    - 14 `tinta2` "Alasan: pemohon tercatat sebagai anggota aktif jemaat lain; perlu atestasi masuk.";
    - 13 `tinta3` "Oleh Pnt. Hendrik Rumagit, 17/11/2026. Data yang diisi tidak menjadi data anggota."
    There is no button.
- **Components**
  - LencanaStatus: Diajukan (`garis`), Dikembalikan and Tidak diterima (`bata`), Diverifikasi (`laut`).
  - Tombol: the ink primary "Ajukan permohonan" and "Ubah dan ajukan lagi"; the disabled "Ajukan permohonan" with its reason; the secondary link "Atur tampilan nama saya".
  - The consent card is a repeated pattern, not a component (it also appears on CabutIzin and AlurAnggota). Build it once as a shared widget if those specs do.
  - Read-only fields use the shared field look.
  - KotakCentang (components.md, shared primitive): the consent checkbox, inside a full-row target.
- **Internal views and states**
  - Board state `{ k: null }`. The view is `k ?? keadaan`: Mengisi, Izin belum diberikan, Untuk anak, Diajukan, Dikembalikan, Diverifikasi or Tidak diterima.
  - Plus a local tick `izin` that drives only the checkbox's own look: true on entering Mengisi or Untuk anak, false on entering Izin belum diberikan, reset to that value every time the view is shown anew (the canvas re-creates the native checkbox). See Interactions and Notes.
  - The logic class has no flow object (`E = {}`).
- **Tweaks** (Keadaan panel) `keadaan`, enum, default "Mengisi". What each option shows:
  - "Mengisi": the filled form, consent ticked, an active "Ajukan permohonan".
  - "Izin belum diberikan": the same form, consent unticked, a disabled "Ajukan permohonan" and the 13 `tinta3` reason under it.
  - "Untuk anak": the child form ("Gabriel Wenas", 02/09/2019, guardian "Novita Wenas"), the guardian consent ticked, an active button.
  - "Diajukan": the submitted card (16/11/2026 10.12) naming the next verifier.
  - "Dikembalikan": the returned card with its reason and "Ubah dan ajukan lagi".
  - "Diverifikasi": the member card "Novita Wenas" and "Atur tampilan nama saya".
  - "Tidak diterima": the refused card. There is no way forward on this board.
- **Interactions**
  - "Ajukan permohonan" in Mengisi or Untuk anak (`go3`) → `k = 'Diajukan'`. No checks, nothing recorded, no timer.
  - "Ajukan permohonan" in Izin belum diberikan → disabled. Nothing happens.
  - "Ubah dan ajukan lagi" in Dikembalikan (`go0`) → `k = 'Mengisi'`. The form shows the same values; the birth date is not changed.
  - "Atur tampilan nama saya" in Diverifikasi → push `/TampilanNama` (`Tautan(ke: 'TampilanNama')`).
  - Checkbox row (the whole row) → toggles `izin`, which changes only the box. The view, the button and the reason line stay as drawn for the view: in Mengisi and Untuk anak "Ajukan permohonan" stays active even when unticked; in Izin belum diberikan it stays disabled even when ticked. This is the board's behaviour (a native checkbox with no handler), as for the checkbox in `14-berandajabatan.md`.
  - Back arrow → `kembaliKe('/DataAnggota')` (`KepalaPonsel(kembaliKe: 'DataAnggota', labelKembali: 'Kembali ke Data jemaat')`).
- **Motion** none. The keyframes `isi`, `masuk`, `muncul` and `pudar` are declared but unused. View changes are instant (with the scroll-to-top rule). There are no timers.
- **Links out**
  - Back arrow "Kembali ke Data jemaat" → `/DataAnggota` (up link).
  - "Atur tampilan nama saya" → `/TampilanNama` (push).
  - **Inbound** PetaPlatform ("Permohonan menjadi anggota" → "Ponsel"); AntreanVerifikasi (rows "Permohonan menjadi anggota · Novita Wenas" and "Permohonan menjadi anggota · Kevin Rompas", push). Opened from AntreanVerifikasi, the back arrow does `go('/DataAnggota')`, since `/AntreanVerifikasi` is below.
- **Mock data**
  - Applicant: Novita Wenas; born 14/03/1996; Perempuan; "Belum pernah menikah", so BIPRA Pemuda (P10); Keluarga Wenas-Lasut; Kolom 7.
  - Child: Gabriel Wenas, born 02/09/2019, guardian Novita Wenas.
  - Consent: "Naskah versi 1 · 12/11/2026".
  - Submitted 16/11/2026 10.12. Verifier Pnt. Hendrik Rumagit, Penatua Kolom 7.
  - Returned 17/11/2026 08.40 ("tanggal lahir berbeda dengan surat baptis"). Verified 17/11/2026 19.05. Refused 17/11/2026 ("anggota aktif jemaat lain; perlu atestasi masuk").
- **Prototype-only** none. Keadaan panel: `keadaan` (seven options).
- **Acceptance checks**
  1. `/PermohonanAnggota` (Mengisi) → the header reads "Permohonan menjadi anggota" / "Diisi sendiri, lalu diverifikasi Penatua Kolom". The form shows "Novita Wenas", "14/03/1996" stacked above "Perempuan", "Belum pernah menikah" with "Bersama tanggal lahir menentukan Kategori BIPRA: Pemuda", "Wenas-Lasut" and "Kolom 7". The consent card shows "Naskah versi 1 · 12/11/2026" and a ticked box. "Ajukan permohonan" is on `tinta`.
  2. The fields are read-only: tapping one opens no keyboard and the text cannot change.
  3. "Ajukan permohonan" → the card "Permohonan menjadi anggota" with a `garis` badge "Diajukan", "Diajukan 16/11/2026 10.12" and "Berikutnya: Pnt. Hendrik Rumagit, Penatua Kolom 7, …". The panel still reads "Mengisi".
  4. Panel → "Izin belum diberikan" → the box is unticked, "Ajukan permohonan" is grey and does nothing, and the line under it reads "Tidak dapat dilakukan: izin penggunaan data pribadi belum diberikan." Tap the statement text → the box ticks (`laut`); the button stays grey and disabled and the line stays. Panel → "Mengisi" → the box is ticked again.
  5. Panel → "Untuk anak" → "Gabriel Wenas", "02/09/2019", "Novita Wenas" and the guardian statement. "Ajukan permohonan" → Diajukan.
  6. Panel → "Dikembalikan" → a `bata` badge "Dikembalikan" with the reason line. "Ubah dan ajukan lagi" → the Mengisi form.
  7. Panel → "Diverifikasi" → "Novita Wenas" with a `laut` badge "Diverifikasi" and "Anggota jemaat · Keluarga Wenas-Lasut · Kolom 7". "Atur tampilan nama saya" → `/TampilanNama`, and Back returns here.
  8. Panel → "Tidak diterima" → a `bata` badge "Tidak diterima", the reason "Alasan: pemohon tercatat sebagai anggota aktif jemaat lain; perlu atestasi masuk." and no button.
  9. Back arrow → `/DataAnggota`.
- **Notes**
  - The checkbox in the source is an uncontrolled native checkbox with no handler. In the browser it toggles but changes nothing, while the button state is fixed per view. The board wins: build exactly that. Wiring the tick to switch Mengisi ↔ Izin belum diberikan would be a deviation; if design wants it, flag it in the review rather than building it.
  - The board draws the browser-default checkbox (no `accent-color` on this board). Use the shared `KotakCentang` look from components.md, as every other checkbox in the prototype does.
  - The reason in Izin belum diberikan is 13 `tinta3` and sits **under** the button, not as the `bata` Penolakan line above it. The board wins; keep it as drawn.
  - The returned, verified and refused dates (17/11/2026) are after "today" (16/11/2026). They are sample future outcomes; keep them.
  - The applicant's back arrow goes to Data jemaat, an officer's board. That is the source's link; keep it.
  - Primaries are `tinta` fields, not `laut`.
  - The Untuk anak form has no BIPRA line or marital status field: a child at 7 is Anak, but it is not drawn. Add nothing.

### ImporBuku — 73 · Impor buku anggota

- **Source** `docs/design/handoff/canvas/boards/ImporBuku.dc.html` · page Putaran 4 · Data jemaat (`p4`) · form Phone 390×844 · interactive yes
- **Route** `/ImporBuku`, no child routes (the three states change the body in place) · **Widget** `ImporBukuScreen` in `lib/screens/p4/impor_buku.dart`
- **Purpose** Operator (Yanti Sumual), journey step 1 ("Impor buku anggota", "Alur · Buku anggota", "Kemungkinan data ganda"). The paper member book of Kolom 7 is held, checked, then imported. The board shows:
  - D34: the import words Ditampung, Lolos pengecekan, Sudah diimpor, Tidak diimpor.
  - P11: marital status is read from the paper book.
  - Possible duplicates are flagged, never merged automatically.
  - A row without a birth date is not imported, and the reason is recorded.
  - Imported people are "Belum dikonfirmasi": visible only to the Penatua Kolom 7 and the Operator, and never in a publication until the family confirms and gives consent (foundations).
  - The BIPRA category is not computed until the missing fields are completed.
- **Shell** Phone header with back, no tab bar. Back label "Kembali ke Data jemaat". Title "Impor buku anggota". Subtitle "Operator memasukkan buku anggota kertas; belum ada yang menjadi anggota aktif".
- **Layout** The body column (gap 16):
  1. Key–value row "Sumber" → "Buku anggota Kolom 7 · 2019–2026".
  2. Key–value row "Baris" → `ring`:
     - "28 baris · belum ada yang diimpor" in Ditampung and Lolos pengecekan;
     - "28 baris · 26 sudah diimpor · 1 kemungkinan ganda · 1 tidak diimpor" in Sudah diimpor.
  3. *Four row cards*: radius 14, padding 12 16, column gap 4.
     - Rows 1–2 are solid: `permukaan` field, 1 `garis` edge.
     - Rows 3–4 are dashed: a 1.5 dashed `putus` edge (the draf line) and no fill.
     - Each card has:
       - a top row (space-between, centred, gap 16): the name (700) and a badge;
       - 13 `tinta3` "Di buku: " followed by the book text in **mono**;
       - 14 `tinta` "Dibaca sebagai: {baca}";
       - 13 `tinta3` `ket`. When `ket` is empty, draw nothing, but keep the trailing 4 gap, because the empty div still takes a gap in the source.
     - Rows (name · book text · read as · ket):
       1. "Ferry Wenas" · "WENAS FERRY, lhr 3-8-71, Kol 7" · "Ferry Wenas · 03/08/1971 · Kolom 7" · (none)
       2. "Agustina Lasut" · "LASUT AGUSTINA (istri), 12-12-74" · "Agustina Lasut · 12/12/1974 · Kolom 7" · (none)
       3. "Novita Wenas" · "WENAS NOVITA, 14-3-96" · "Novita Wenas · 14/03/1996 · Kolom 7" · "Kemungkinan data ganda: sudah ada Novita Wenas, Aktif" (only from Lolos pengecekan on)
       4. "—" · "RUMAGIT H., tgl lhr tdk terbaca" · "Tanggal lahir tidak terbaca" · "Tidak diimpor: tanggal lahir wajib. Dicatat dengan alasannya." (always)
     - Badges by state:

       | Row | Ditampung | Lolos pengecekan | Sudah diimpor |
       | --- | --- | --- | --- |
       | Ferry Wenas, Agustina Lasut | "Ditampung" (`draf`) | "Lolos pengecekan" (`lautg`) | "Sudah diimpor" (`tinta`) |
       | Novita Wenas | "Ditampung" (`draf`) | "Kemungkinan data ganda" (`bata`) | "Kemungkinan data ganda" (`bata`) |
       | — | "Tidak diimpor" (`bata`) | "Tidak diimpor" (`bata`) | "Tidak diimpor" (`bata`) |
  4. *State block*:
     - **Ditampung**:
       - a button row with "Jalankan pengecekan" (ink primary, 340);
       - 13 `tinta3` "Belum ada yang tersimpan sebagai data jemaat.";
       - 13 `tinta3` "Tanggal lahir, jenis kelamin dan status pernikahan dibaca dari buku. Yang kosong dilengkapi keluarga saat mengonfirmasi; sampai itu Kategori BIPRA orangnya belum dihitung."
     - **Lolos pengecekan**:
       - 13 `tinta3` "Kemungkinan data ganda ditandai, tidak pernah digabung sendiri.";
       - a button row with "Impor 26 baris" (ink primary) and the link "Tinjau kemungkinan data ganda" (secondary look, min height 48, centred, no underline). They sit side by side at about 171 each, and the link label wraps to two lines.
     - **Sudah diimpor**:
       - a note box: 1.5 dashed `putus` edge, no fill, radius 14, padding 12 14, 14 px. It reads strong `tinta` "26 orang masuk sebagai Belum dikonfirmasi.", a space, then `tinta2` "Hanya Penatua Kolom 7 dan Operator yang dapat melihatnya. Tidak ada yang tampil di publikasi sampai keluarganya mengonfirmasi dan memberi izin.";
       - a button row with the link "Lihat konfirmasi keluarga" (secondary look, 340).
- **Components** LencanaStatus (the import badges, in the shapes above); GarisStatus `draf` (dashed row cards and the note box) and `dibukukan` (solid cards); Tombol (ink primaries; secondary-look links). Repeated pattern that is not a component: the import row card (source text in mono, then the reading, then the note).
- **Internal views and states** Board state `{ k: null }`. The view is `k ?? keadaan`: Ditampung, Lolos pengecekan or Sudah diimpor. The row data is fixed; only badges, `ket`, `ring` and the state block change.
- **Tweaks** (Keadaan panel) `keadaan`, enum, default "Ditampung":
  - "Ditampung": `ring` "28 baris · belum ada yang diimpor". Rows 1–3 show "Ditampung" and row 4 "Tidak diimpor". Novita has no `ket`. The block shows "Jalankan pengecekan" and the two notes.
  - "Lolos pengecekan": the same `ring`. Rows 1–2 show "Lolos pengecekan", row 3 "Kemungkinan data ganda" with its `ket`, and row 4 "Tidak diimpor". The block shows the duplicate note, "Impor 26 baris" and "Tinjau kemungkinan data ganda".
  - "Sudah diimpor": `ring` "28 baris · 26 sudah diimpor · 1 kemungkinan ganda · 1 tidak diimpor". Rows 1–2 show "Sudah diimpor", row 3 "Kemungkinan data ganda" and row 4 "Tidak diimpor". The block shows the Belum dikonfirmasi note and "Lihat konfirmasi keluarga".
- **Interactions**
  - "Jalankan pengecekan" (`go1`) → `k = 'Lolos pengecekan'`. It is instant, with no progress and no timer.
  - "Impor 26 baris" (`go2`) → `k = 'Sudah diimpor'`. It is instant.
  - "Tinjau kemungkinan data ganda" → push `/DataGanda`.
  - "Lihat konfirmasi keluarga" → push `/KonfirmasiKeluarga`.
  - Back arrow → `kembaliKe('/DataAnggota')`.
  - There is no way back from Sudah diimpor except the panel.
- **Motion** none. The keyframes `isi`, `masuk`, `muncul` and `pudar` are declared but unused. There are no timers.
- **Links out**
  - Back arrow "Kembali ke Data jemaat" → `/DataAnggota` (up link).
  - "Tinjau kemungkinan data ganda" → `/DataGanda` (push).
  - "Lihat konfirmasi keluarga" → `/KonfirmasiKeluarga` (push).
  - **Inbound** PetaPlatform ("Impor buku anggota" → "Ponsel"); BerandaJabatan (row "Buku anggota: 318 baris sudah diimpor", push). The row's "318" is BerandaJabatan's own figure; this board keeps its 28 rows.
- **Mock data**
  - Source "Buku anggota Kolom 7 · 2019–2026"; 28 rows; 26 imported; 1 possible duplicate; 1 not imported.
  - People: Ferry Wenas (03/08/1971, Kolom 7); Agustina Lasut (12/12/1974, Kolom 7, "(istri)"); Novita Wenas (14/03/1996, Kolom 7), a possible duplicate of the existing active Novita Wenas; "RUMAGIT H." with an unreadable birth date.
  - Audience for imported people: Penatua Kolom 7 and the Operator.
- **Prototype-only** none. Keadaan panel: `keadaan` (Ditampung, Lolos pengecekan, Sudah diimpor).
- **Acceptance checks**
  1. `/ImporBuku` (Ditampung) → "Sumber" reads "Buku anggota Kolom 7 · 2019–2026" and "Baris" reads "28 baris · belum ada yang diimpor". There are four cards:
     - two solid, two dashed;
     - Ferry, Agustina and Novita have a dashed "Ditampung" badge; "—" has a `bata` "Tidak diimpor";
     - the book texts are in mono;
     - Novita shows no duplicate line.
  2. The Ditampung block shows "Jalankan pengecekan", "Belum ada yang tersimpan sebagai data jemaat." and the BIPRA note.
  3. "Jalankan pengecekan" → Ferry and Agustina read "Lolos pengecekan" (`laut` line and text). Novita reads "Kemungkinan data ganda" (`bata`) with "Kemungkinan data ganda: sudah ada Novita Wenas, Aktif". The buttons "Impor 26 baris" and "Tinjau kemungkinan data ganda" show. The panel still reads "Ditampung".
  4. "Impor 26 baris" → "Baris" reads "28 baris · 26 sudah diimpor · 1 kemungkinan ganda · 1 tidak diimpor". Ferry and Agustina read "Sudah diimpor" (`tinta`). The dashed note "26 orang masuk sebagai Belum dikonfirmasi. …" and "Lihat konfirmasi keluarga" show.
  5. Change the panel to "Lolos pengecekan" → that view, with the local `k` reset.
  6. "Tinjau kemungkinan data ganda" → `/DataGanda`; "Lihat konfirmasi keluarga" → `/KonfirmasiKeluarga`; Back returns here.
  7. Back arrow → `/DataAnggota`.
- **Notes**
  - "Lolos pengecekan" uses the `lautg` shape (the "Sudah diperiksa" look), and "Sudah diimpor" uses `tinta`. Keep the board's mapping.
  - The name of row 4 is the dash "—" (not known).
  - The book text is mono although it is not a code. It marks a raw transcription; keep it.
  - Primaries are `tinta` fields.

### WebImporBuku — Web · Impor buku anggota

- **Source** `docs/design/handoff/canvas/boards/WebImporBuku.dc.html` · page Putaran 4 · Data jemaat (`p4`) · form Laptop page (preview 1440×1100, `expand: fill`) · interactive yes
- **Route** `/WebImporBuku`, no child routes · **Widget** `WebImporBukuScreen` in `lib/screens/p4/web_impor_buku.dart`
- **Purpose** Same as ImporBuku on the laptop, for the Operator (a desk post, Q26). D34, P11, duplicates flagged and not merged, Belum dikonfirmasi not published.
- **Shell** Platform side nav with **"Data jemaat" active** (the sixth item; `NavSamping(item: navPlatform, aktif: 5, …)`). Footer: "**Yanti Sumual** · Operator".
- **Layout** Main column:
  1. *Web title block*: breadcrumb "Data jemaat" (→ `/WebDataAnggota`), h1 "Impor buku anggota", subtitle "Operator memasukkan buku anggota kertas; belum ada yang menjadi anggota aktif".
  2. *Content column* (max 1120, gap 16) holding one two-column row:
     - Left (608 at 1440): "Sumber", "Baris" and the four row cards, each as ImporBuku 1–3, stacked 12 apart (16 on the phone). Card titles are 15/700.
     - Right (484): the state block, as ImporBuku 4, its parts 12 apart.
       - In Lolos pengecekan, "Impor 26 baris" and "Tinjau kemungkinan data ganda" sit side by side at about 238 each, and the link wraps to two lines.
       - In Sudah diimpor, the dashed note fills the column, with "Lihat konfirmasi keluarga" (340) under it.
     Every style, text and colour is as in ImporBuku, on a 15 base. The columns stack below 788 of content.
- **Components** As ImporBuku, plus the platform side nav.
- **Internal views and states** Identical to ImporBuku: `{ k: null }`, with the view `k ?? keadaan`. The below-860 menu toggle is page-local.
- **Tweaks** (Keadaan panel) `keadaan`, enum "Ditampung" / "Lolos pengecekan" / "Sudah diimpor", default "Ditampung". Each option changes the screen exactly as on ImporBuku.
- **Interactions**
  - "Jalankan pengecekan" → `k = 'Lolos pengecekan'`.
  - "Impor 26 baris" → `k = 'Sudah diimpor'`.
  - "Tinjau kemungkinan data ganda" → push `/WebDataGanda`.
  - "Lihat konfirmasi keluarga" → push `/KonfirmasiKeluarga` (the phone board).
  - Breadcrumb → `kembaliKe('/WebDataAnggota')`.
  - Side nav → `go`. Menu toggle below 860 px.
- **Motion** none. The keyframes `isi`, `muncul` and `titik` are declared but unused. There are no timers.
- **Links out**
  - Breadcrumb "Data jemaat" → `/WebDataAnggota` (up link).
  - "Tinjau kemungkinan data ganda" → `/WebDataGanda` (push).
  - "Lihat konfirmasi keluarga" → `/KonfirmasiKeluarga` (push).
  - Side nav (go): `/WebBerandaJabatan`, `/WebBeranda`, `/WebDokumenGereja`, `/WebPengumuman`, `/WebWartaArsip`, `/WebDataAnggota` (active), `/Ibadah`, `/Panitia`, `/WebKotakMasuk`, `/WebPenugasan`.
  - **Inbound** PetaPlatform ("Impor buku anggota" → "Web"); WebBerandaJabatan (row "Buku anggota: 318 baris sudah diimpor", push).
- **Mock data** Same as ImporBuku. Footer "Yanti Sumual", "Operator".
- **Prototype-only** none. Keadaan panel: `keadaan` (three options).
- **Acceptance checks**
  1. `/WebImporBuku` at 1440 → "Data jemaat" is active and the footer reads "Yanti Sumual · Operator". The breadcrumb reads "Data jemaat" and the h1 "Impor buku anggota". The four row cards are on the left and "Jalankan pengecekan" with its two notes on the right.
  2. "Jalankan pengecekan" → the badges change as in ImporBuku check 3, and the right column shows "Impor 26 baris" beside "Tinjau kemungkinan data ganda".
  3. "Tinjau kemungkinan data ganda" → `/WebDataGanda`, and Back returns.
  4. Panel → "Sudah diimpor" → the "Baris" line reads "28 baris · 26 sudah diimpor · 1 kemungkinan ganda · 1 tidak diimpor". "Lihat konfirmasi keluarga" → `/KonfirmasiKeluarga`, a phone board in its device frame.
  5. At 860 → the "Menu" top bar shows and the columns stay side by side. At 700 the state block drops under the cards, with no horizontal scroll.
  6. "Data jemaat" in the nav and the breadcrumb → `/WebDataAnggota`.
- **Notes**
  - "Lihat konfirmasi keluarga" goes to the **phone** board KonfirmasiKeluarga, because there is no WebKonfirmasiKeluarga: Penatua Kolom work is phone-only (Q26). Follow the board.
  - "Ibadah dan kegiatan" and "Panitia" in the side nav also open phone boards.
  - All ImporBuku notes apply.
