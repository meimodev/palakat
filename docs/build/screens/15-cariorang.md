# Screens 15: CariOrang, WebCariOrang, AlurPenugasan, AlurJabatanKosong, WebAlurJabatanKosong, AlurPelimpahan, AlurBeranda, AlurModul

These eight boards are on the canvas page "Putaran 2 · Kerangka platform" (`p2`): the platform's people search and the six flows that show how posts, vacancies, delegations, the combined Beranda and modules behave. **CariOrang** (phone) and **WebCariOrang** (laptop) are the Operator's search across Data jemaat, Dokumen gereja and Keuangan. One tweak switches between what the Operator sees, what a Penatua Kolom 7 sees, and no result. The Operator also gets the entry to "Alur · Memulihkan akun anggota" (AlurPulihkan/WebAlurPulihkan, which link back here). Each result row opens its own board. The five phone **Alur** boards and one laptop Alur board are "flows with typed input and live refusals". Each opens on a list view and changes in place to a form or detail view under the same header, and records what was done in a Riwayat list, newest first. **AlurPenugasan**: the Pimpinan Jemaat (Pdt. Lidya Rondonuwu) records who holds a post, with a church decision and a start date that is not in the future (P08). **AlurJabatanKosong** / **WebAlurJabatanKosong**: the Operator Yanti Sumual runs the vacant post Penatua Kolom 2 until a holder is assigned. **AlurPelimpahan**: Pnt. Hendrik Rumagit delegates one task with an end date. **AlurBeranda**: one Beranda for a person with two posts, where the post is picked per action (Q31). **AlurModul**: modules are turned on in dependency order and turned off to Hanya baca with a reason. The Alur boards are reached only from the map PetaPlatform (link labels "Ponsel"/"Web") and the launcher. AlurModul is also reached from PemberiPersetujuan. Their back arrow leads to the matching main board (Penugasan, JabatanKosong/WebJabatanKosong, Pelimpahan, BerandaJabatan, Modul). Rules used throughout: an **up link** (phone back arrow, web breadcrumb) runs `kembaliKe('/X')`, which pops when the route directly below is `/X` or a child of `/X` and otherwise does `go('/X')`; every other board link is `push` and web side-nav items are `go`, all built with `Tautan(ke: …)`. None of these boards has child routes: their views change in place, because the header, title and back target never change between views, and changing view resets the body's scroll offset to the top. Each board keeps its state in its own `State`, so Back to it finds it as it was, and opening it fresh resets it, as reopening an artboard does. Nothing on these boards animates, "today" is 16/11/2026, and no board here has the `jabatanKosong` switch.

---

### CariOrang — 52 · Cari orang
- **Source** `docs/design/handoff/canvas/boards/CariOrang.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Phone 390×844 (frame radius 36) · interactive yes
- **Route** `/CariOrang`, no child routes (the tweak switches the result set in place) · **Widget** `CariOrangScreen` in `lib/screens/p2/cari_orang.dart`
- **Purpose** Operator, journey step 3 ("Cari orang", then "Alur · Memulihkan akun anggota"). The same search is also shown as a Penatua Kolom 7 sees it. Shows the platform rules:
  - "What a person sees follows the posts they hold. A Penatua Kolom sees only their Kolom. … The Operator sees everything, but seeing gives no authority": 5 results for the Operator, 2 (Kolom 7 only) for the Penatua.
  - "A module that is Tidak aktif leaves no trace in … search": the subtitle "Hasil hanya dari modul aktif…".
  - A match never opens hidden data, and the count never reveals out-of-scope data: the footnote.
  - The recovery link is the entry to P07 (the Operator requests recovery of a member's account), shown to the Operator only.
  - Badges use the status words of Data jemaat, Dokumen gereja and Keuangan.
- **Shell** Phone, no tab bar, header with back arrow (up link to `/BerandaJabatan`). Board root: 390×844, `kertas`, `tinta` text, sans 16/1.4 (`isi`); a column of a fixed header and a scrolling body.
- **Layout**
  1. Header: row, centred vertically, gap 8, padding 14 top, 12 sides, 8 bottom.
     - Back target 44×44, chevron centred (path `M15 6l-6 6 6 6`, 22 px, stroke 2, round caps, `tinta`), semantics "Kembali ke Beranda".
     - Column (flex 1): h1 "Cari orang" `judulLayar` (18/700); subtitle "Hasil hanya dari modul aktif dan dari yang boleh Anda lihat" 13 `tinta2`. The source sets 14 px and then 13 px; 13 wins.
  2. Body: flex 1, scrolls vertically, padding 8 top, 20 sides, 20 bottom. One column with gap 16 between every child below, rows included (sc-if/sc-for add no wrapper).
     a. Search field, a label wrapping the input: column gap 6.
        - Label "Cari nama, keluarga atau Kolom" 14 `tinta2`.
        - Input: read-only, full width, min height 48, padding 0 14, radius 12 (`isian`), 1 px `garisTegas`, `permukaan` field.
        - Value "Wenas", or "Rumengan" in "Tidak ada hasil", 14 `tinta2`: the input inherits the label's size and colour.
        - No placeholder, no icon, no clear button.
     b. (results states) Count line, 14 `tinta2`: "5 hasil untuk “Wenas”" (Dilihat Operator) or "2 hasil untuk “Wenas”" (Dilihat Penatua Kolom 7).
     c. (results states) One card per result. The whole card is one link.
        - Card: `permukaan`, 1 px `garis` (dibukukan line), radius 14, padding 12/16, min height 44; row, centred, gap 12; `tinta` text, no underline.
        - Left column (flex 1, min width 0, gap 2): name 16/600; context line 13 `tinta3`.
        - Badge, only when the result has one: flex none, 13/700, radius 6 (`lencana`), padding 3/9. Style per Components.
        - Chevron 18×18 (path `M9 6l6 6-6 6`, stroke `tinta3` 2, round caps).
        - Rows and their order in Mock data.
     d. (Dilihat Operator only) Text link "Orangnya kehilangan nomor ponsel? Pulihkan akun": as wide as its text, min height 44, text centred vertically, 14/700, `laut`, underlined; hover/pressed `lautTua`.
     e. (Tidak ada hasil only) Empty box, draf line (1.5 dashed `putus`), radius 14, padding 14/16, column gap 6:
        - "Tidak ada hasil untuk “Rumengan”" 16/700.
        - "Periksa ejaan, atau cari dengan nama keluarga." 14 `tinta2`.
     f. Footnote, always: 13 `tinta3` "Kecocokan nama tidak pernah membuka data yang tidak boleh Anda lihat, dan jumlah hasil tidak menyebut data di luar jangkauan Anda."
- **Components**
  - LencanaStatus/LencanaModul look for the badges:
    - "Aktif": `laut` field, `diLaut` text, 1.5 `laut` border (a person's status).
    - "Belum dikonfirmasi": draf, 1.5 dashed `putus`, `tinta2` text, no field.
    - "Diterbitkan" and "Dibukukan": `tinta` field, `permukaan` text, 1.5 `tinta` border.
  - Phone header with back (shell).
  - Not components: the result card (same shape as a ButirPerhatian "Perlu tindakan" card with chevron) and the read-only search field (a plain read-only `TextField`). The draf empty box uses the shared dashed painter.
- **Internal views and states** One view. Initial state `{ k: null }`. `k` would override the tweak, but nothing on the screen sets it, so the tweak alone decides. Three result sets:
  - `Dilihat Operator`: field "Wenas", count 5, five rows, recovery link, footnote.
  - `Dilihat Penatua Kolom 7`: field "Wenas", count 2, two rows, footnote. No recovery link.
  - `Tidak ada hasil`: field "Rumengan", the empty box, footnote. No count, no rows, no recovery link.
  - No sheets, toasts, banners or loading state.
- **Tweaks** `keadaan` (enum) · Keadaan panel. Options "Dilihat Operator", "Dilihat Penatua Kolom 7", "Tidak ada hasil"; default "Dilihat Operator". What each option shows is listed under Internal views.
- **Interactions** The logic class has no handlers of its own; only its links act. The search input is read-only on the board: typing does nothing and the keyboard does not open. Results change only through the tweak. Each result card is a link (Links out).
- **Motion** None. CSS declares `masuk`, `pudar`, `muncul`, `isi` but no element uses them. Route changes use the app-wide page transition (motion.md, `pindahLayar` 280 ms). Reduce motion: nothing to stop.
- **Links out**
  - Back arrow (no visible label, semantics "Kembali ke Beranda") → `/BerandaJabatan`, up link.
  - "Orangnya kehilangan nomor ponsel? Pulihkan akun" → `/AlurPulihkan`, push.
  - Result rows. These are built in JS by `hal()`, so the manifest's `links`/`jsLinks` do not list them; build them with `Tautan` all the same:
    - "Novita Wenas" (Data jemaat · Keluarga Wenas-Lasut · Kolom 7) → `/DataAnggota`, push.
    - "Keluarga Wenas-Lasut" → `/DataAnggota`, push.
    - "Ferry Wenas" → `/KonfirmasiKeluarga`, push.
    - "Novita Wenas" (Dokumen gereja · Surat keterangan 15/11/2026) → `/PermohonanSurat`, push.
    - "Kel. Wenas-Lasut" → `/Main`, push.
  - **Inbound** AlurPulihkan (its back arrow), PetaPlatform ("Ponsel").
- **Mock data**
  - Query: "Wenas" ("Rumengan" for no result). The viewer is the Operator (Yanti Sumual), or the Penatua Kolom 7 (Pnt. Hendrik Rumagit).
  - Rows, in order (name | context line | badge, style):
    1. "Novita Wenas" | "Data jemaat · Keluarga Wenas-Lasut · Kolom 7" | "Aktif", laut.
    2. "Keluarga Wenas-Lasut" | "Data jemaat · 4 orang · Kolom 7" | no badge.
    3. "Ferry Wenas" | "Data jemaat · Kolom 2" | "Belum dikonfirmasi", draf.
    4. "Novita Wenas" | "Dokumen gereja · Surat keterangan 15/11/2026" | "Diterbitkan", tinta.
    5. "Kel. Wenas-Lasut" | "Keuangan · Sampul syukur 08/11/2026" | "Dibukukan", tinta.
  - Dilihat Penatua Kolom 7 shows rows 1–2 only.
- **Prototype-only** The viewer switch ("Dilihat Operator" / "Dilihat Penatua Kolom 7") is a "Dilihat sebagai" device. It exists only as the tweak in the Keadaan panel; the screen has no chips for it. The panel may note that the search field holds a fixed sample query. No "Contoh:" button, no 123456, no "Di prototipe ini" hint.
- **Acceptance checks**
  1. Default tweak: the field shows "Wenas", then "5 hasil untuk “Wenas”", then five cards in the order of Mock data with badges "Aktif", none, "Belum dikonfirmasi", "Diterbitkan", "Dibukukan". The recovery link and the footnote follow.
  2. Panel → "Dilihat Penatua Kolom 7": "2 hasil untuk “Wenas”", only the cards "Novita Wenas" (Data jemaat) and "Keluarga Wenas-Lasut", no recovery link.
  3. Panel → "Tidak ada hasil": the field shows "Rumengan". There is no count line and no cards; a dashed box reads "Tidak ada hasil untuk “Rumengan”" / "Periksa ejaan, atau cari dengan nama keluarga."; the footnote is still there.
  4. Tapping the search field does not open a keyboard and its text cannot change.
  5. Tap "Ferry Wenas" → `/KonfirmasiKeluarga` opens; Back returns to CariOrang with the same tweak.
  6. Tap "Kel. Wenas-Lasut" → `/Main`. Tap the second "Novita Wenas" → `/PermohonanSurat`.
  7. Tap "Orangnya kehilangan nomor ponsel? Pulihkan akun" → `/AlurPulihkan`; its back arrow returns here by popping.
  8. Tap the back arrow → `/BerandaJabatan`.
- **Notes**
  - The two "Novita Wenas" rows are different records with different targets; key rows by index, not by name.
  - Inputs throughout this file show their value at 14 px `tinta2`, because the HTML input inherits its label's style. Copy the board.
  - All colours map to tokens; no 12 px text.

---

### WebCariOrang — Web · Cari orang
- **Source** `docs/design/handoff/canvas/boards/WebCariOrang.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Laptop page (preview 1440×1000, `expand: fill`) · interactive yes
- **Route** `/WebCariOrang`, no child routes · **Widget** `WebCariOrangScreen` in `lib/screens/p2/web_cari_orang.dart`
- **Purpose** Same as CariOrang, on the Operator's laptop (Operator is one of the three desk posts with a laptop layout, Q26). Same rules and states.
- **Shell** Web side nav, the **platform variant** (Operator): `navPlatform` (navigation.md 1.3) in `NavSamping` (components.md 4.3). WebAlurJabatanKosong uses it too, and later platform web boards should reuse this definition.
  - Board root: min height = window, row that wraps, `kertas`, `tinta` text, sans 15/1.45 (`isiWeb`).
  - Nav: flex 1 1 220 (≈220 wide at 1440), full height, padding 24/16, `permukaan`, 1 px `garis` right border, column gap 20.
    - Logo row, gap 10, padding 0 8: the mark, 26×26, drawn from this path data, `<rect x="2" y="2" width="20" height="20" rx="6" fill="none" stroke="laut" stroke-width="2" stroke-dasharray="3 3"/><path d="M12 2h4a6 6 0 0 1 6 6v8a6 6 0 0 1-6 6h-4z" fill="laut"/>`. Next to it a column: "palakat" 18/700, line-height 1.1, and "Jemaat Karunia" 13 `tinta3`.
    - Menu toggle (only below 860, see below).
    - Ten items, each a link, stacked with no gap between them: min height 44, padding 0 12, radius 10 (off-token), 15/600, no underline. Active item: `tinta` field, `permukaan` text. The others: transparent, `tinta` text. Items and targets, in order:
      1. "Beranda" → `/WebBerandaJabatan`
      2. "Keuangan" → `/WebBeranda`
      3. "Dokumen gereja" → `/WebDokumenGereja`
      4. "Pengumuman" → `/WebPengumuman`
      5. "Warta Jemaat" → `/WebWartaArsip`
      6. "Data jemaat" → `/WebDataAnggota`
      7. "Ibadah dan kegiatan" → `/Ibadah`
      8. "Panitia" → `/Panitia`
      9. "Pemberitahuan" → `/WebKotakMasuk`
      10. "Pengaturan" → `/WebPenugasan`
    - Here the active item is **Beranda**.
    - Footer: pushed to the bottom (margin-top auto), padding 12 top, 8 sides, 0 bottom, 1 px `garis` top border, 13 `tinta2`: "**Yanti Sumual** · Operator" (the name in `tinta`, 700).
    - Below 860 px wide the nav becomes a full-width top bar: row, wrap, centred, gap 0/12, padding 8/16, no right border, 1 px `garis` bottom border.
      - Logo on the left; toggle button on the right (margin-left auto, min height 44, padding 0 16, radius 14, 1.5 `tinta` border, `permukaan` field, 14/700) labelled "Menu". On the board it is a checkbox with `aria-label="Menu"`: `Semantics(label: 'Menu', toggled: open)`.
      - Open: the toggle has a `tinta` field and `permukaan` text and reads "Tutup menu". The item list (padding 8 0) and the footer (no top margin, padding-bottom 8) appear full width below.
      - Closed: the list and the footer are hidden.
  - Main: flex 999 1 560, min width 0, padding 28 top, clamp(16, 3 % of window width, 40) sides, 40 bottom, column gap 20.
- **Layout** (inside Main)
  1. Title block:
     - Breadcrumb link "Beranda" 14/600, `laut`, underlined (hover `lautTua`).
     - h1 "Cari orang" `judulHalaman` (26/700), 2 above.
     - Subtitle "Hasil hanya dari modul aktif dan dari yang boleh Anda lihat" 14 `tinta2`.
  2. Content column: max width 880, at the start of Main (not centred), column gap 16.
     a. Search field: identical to CariOrang 2a (value 14 `tinta2`, read-only).
     b. Count line: identical to CariOrang 2b.
     c. Results in **one** card:
        - Card: `permukaan`, 1 px `garis`, radius 14, contents clipped.
        - Rows stacked with a 1 px `garis` rule above each. The first rule is hidden under the card's top border (the inner column has margin-top −1).
        - Row: one link, grid of three columns [flexible | auto | 20], gap 16, centred vertically, min height 52, padding 8/18, no underline, `tinta` text.
          - Column 1: a wrap row aligned on the baseline, gaps 2 vertical and 20 horizontal: name 15/600 (flex 1 1 260); context line 13 `tinta3` (flex 1.4 1 300). At 1440 they sit side by side; they wrap to two lines when the cell is narrower than about 580.
          - Column 2: the badge, right-aligned (empty for "Keluarga Wenas-Lasut"), the same badge styles as CariOrang.
          - Column 3: chevron 18 (`tinta3`).
     d. Recovery link: identical to CariOrang 2d (target differs, see Links).
     e. Empty box: identical to CariOrang 2e, except the title inherits 15/700.
     f. Footnote: identical to CariOrang 2f.
- **Components** The same badges as CariOrang, and the platform web side nav (shell). Not components: the results table card and the read-only search field.
- **Internal views and states** Same as CariOrang (initial state `{ k: null }`, three result sets by tweak). Nav toggle open/closed below 860 is local UI state, closed by default.
- **Tweaks** `keadaan` (enum) · Keadaan panel. "Dilihat Operator", "Dilihat Penatua Kolom 7", "Tidak ada hasil"; default "Dilihat Operator". Effects as CariOrang.
- **Interactions** No handlers in the logic class besides `navVals()`. The search input is read-only. The nav toggle opens and closes the drawer below 860; while it is open, system or browser Back closes it first and stays on the page (navigation.md 5.1).
- **Motion** None. CSS declares `muncul`, `isi`, `titik` but nothing uses them. Reduce motion: nothing to stop.
- **Links out**
  - Breadcrumb "Beranda" → `/WebBerandaJabatan`, up link.
  - Side nav: the ten items above, `go`. "Ibadah dan kegiatan" and "Panitia" open phone boards, shown in the device frame.
  - "Orangnya kehilangan nomor ponsel? Pulihkan akun" → `/WebAlurPulihkan`, push.
  - Result rows. `hal()` runs with `web = true`: a board in the phone-only platform list stays a phone board, `Main` becomes `WebBeranda`, and any other board gains the `Web` prefix. The manifest's `links` do not list them: `KonfirmasiKeluarga` and `WebPermohonanSurat` are in no manifest list (navigation.md 3.3 adds them as computed links), and `WebDataAnggota` and `WebBeranda` appear in `jsLinks` only through the side nav. Build each row with its own `Tautan` all the same:
    - "Novita Wenas" (Data jemaat) → `/WebDataAnggota`, push.
    - "Keluarga Wenas-Lasut" → `/WebDataAnggota`, push.
    - "Ferry Wenas" → `/KonfirmasiKeluarga`, push. This is a phone board, shown in the device frame.
    - "Novita Wenas" (Dokumen gereja) → `/WebPermohonanSurat`, push.
    - "Kel. Wenas-Lasut" → `/WebBeranda`, push.
  - **Inbound** PetaPlatform ("Web"), WebAlurPulihkan ("Cari orang").
- **Mock data** Same five rows, query and viewer as CariOrang; side-nav footer "Yanti Sumual · Operator".
- **Prototype-only** As CariOrang: the viewer switch lives only in the Keadaan panel.
- **Acceptance checks**
  1. At 1440: the nav is about 220 wide with ten items, and "Beranda" is filled `tinta` with `permukaan` text. The footer reads "Yanti Sumual · Operator" at the bottom of the nav.
  2. Default tweak: one card with five rows separated by `garis` rules and no rule above the first. Each row shows name and context side by side, the badge right-aligned, and a chevron.
  3. "Tidak ada hasil": the field shows "Rumengan", there is no card, and the dashed empty box shows.
  4. "Dilihat Penatua Kolom 7": "2 hasil untuk “Wenas”" and two rows; no recovery link.
  5. Click "Ferry Wenas" → `/KonfirmasiKeluarga` in the phone frame; Back returns.
  6. Click "Kel. Wenas-Lasut" → `/WebBeranda`. Click the first "Novita Wenas" → `/WebDataAnggota`.
  7. At 800 wide: the nav is a top bar with a "Menu" button. Tapping it shows the ten items and the footer, and the button reads "Tutup menu" on `tinta`. Browser Back now closes the menu and stays on `/WebCariOrang`.
  8. Click the breadcrumb "Beranda" → `/WebBerandaJabatan`. Click nav "Pengaturan" → `/WebPenugasan` (go).
- **Notes**
  - The nav footer stays "Yanti Sumual · Operator" when the tweak is "Dilihat Penatua Kolom 7". Keep it as drawn; the tweak only changes the results.
  - Nav radius 10 is off-token (CONVENTIONS allows it).
  - The page has no `jabatanKosong` banner.

---

### AlurPenugasan — 53 · Alur · Penugasan jabatan
- **Source** `docs/design/handoff/canvas/boards/AlurPenugasan.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Phone 390×844 (frame radius 36) · interactive yes
- **Route** `/AlurPenugasan`, no child routes (the list and the form change in place under one header) · **Widget** `AlurPenugasanScreen` in `lib/screens/p2/alur_penugasan.dart`
- **Purpose** Pimpinan Jemaat yang berwenang (Pdt. Lidya Rondonuwu, R01), journey step 2 ("Penugasan jabatan", "Alur · Penugasan jabatan"). Records who holds a post, from Jabatan kosong to having a holder, and records when an assignment ends. Shows:
  - P08: a future start date is refused; an assignment is recorded on or after its start date.
  - No self-assignment ("Anda tidak dapat menugaskan jabatan kepada diri sendiri.").
  - The assignment records a written church decision kept in Dokumen gereja; it is not an in-app approval (footnote; the same idea as P15).
  - LencanaModul post states: Aktif, Jabatan kosong.
  - TombolBersyarat with dates typed hh/bb/tttt, and RiwayatAlur.
- **Shell** Phone, no tab bar, header with back arrow (up link to `/Penugasan`). Root as CariOrang: 390×844, `kertas`, `tinta`, sans 16/1.4, fixed header + scrolling body.
- **Layout** The parts are **KitAlur (components.md 2.9)**, built in M1. The K-names below are kept because AlurJabatanKosong, AlurPelimpahan, AlurBeranda and AlurModul cite them; each maps to a KitAlur part and lists only what differs here.
  - K1 Header: KitAlur phone header. Here: semantics "Kembali ke Penugasan jabatan"; h1 "Alur · Penugasan jabatan"; subtitle "Dari jabatan kosong sampai ada pemegangnya".
  - K2 Body: KitAlur phone body.
  - K3 Status banner (`pesan`): KitAlur message banner.
  - K4 Card: KitAlur card with its head row and info rows. Padding 12/16 for list cards, 14/16 for summary and detail cards. The second line is a caption (13 `tinta3`), or a plain line (14 `tinta2`) where stated.
  - K5 Badge: KitAlur badge; post badges through `LencanaModul.jabatan` (components.md 3.2).
  - K6 Text field: KitAlur field; K6t is its textarea (`baris: 3`).
  - K7 Chip group: KitAlur chip group.
  - K8 Refusal line: KitAlur refusal line (14 px), directly above the button row.
  - K9 Action row: KitAlur button row holding the conditional button and the text buttons ("Batalkan", "Kembali").
  - K10 Secondary button: KitAlur secondary button. Outside a K9 row it is KitAlur's button outside a row (start-aligned, as wide as its label).
  - K11 Riwayat: KitAlur Riwayat.
  - K12 Footnote: KitAlur footnote (13 `tinta3`).

  View **daftar** (list), top to bottom:
  1. Status banner (K3), when `pesan` is set.
  2. Four post cards (K4, padding 12/16), in order (Mock data):
     - Title "{jabatan} {unit}" (e.g. "Syamas Kolom 3").
     - Badge "Jabatan kosong" (bata) or "Aktif" (laut).
     - Second line 13 `tinta3`: "Belum ada pemegang", or "{orang} · sejak {tanggal}".
     - Vacant cards: secondary button "Tugaskan" (K10, min height 48, start-aligned) under the text.
     - The third card (index 2, Ketua Komisi Diakonia), only while held: text button "Catat berakhir" (min height 44, `laut` 700, padding 0 16, start-aligned). No other card ever shows it.
  3. Footnote (K12): "Penugasan mencatat keputusan gereja; keputusannya sendiri ada di Dokumen gereja, bukan persetujuan di aplikasi."
  4. Riwayat (K11), once something has been recorded.

  View **form**, top to bottom:
  1. Summary card (K4, padding 14/16), two key/value rows: "Jabatan" | the selected post's name (e.g. "Syamas"); "Unit" | its unit (e.g. "Kolom 3").
  2. Field "Orang" (K6): placeholder "Nama orang"; helper "Ketik nama, atau pilih di bawah."
  3. Chip group "Dari Data jemaat" (K7): "Sym. Greis Mamahit", "Pnt. Altje Rompas", "Pdt. Lidya Rondonuwu".
  4. Field "Mulai" (K6): pre-filled "16/11/2026"; placeholder "hh/bb/tttt"; helper "Tanggal, bulan, tahun. Contoh: 16/11/2026."
  5. Chip group "Keputusan gereja" (K7): "SK BPMJ No. 14/2026", "Belum ada dokumen".
  6. Refusal line (K8), when shown: "Tidak dapat dilakukan: Catat penugasan." + cause.
  7. Action row (K9): TombolBersyarat "Catat penugasan"; text button "Batalkan".
- **Components** TombolBersyarat ("Catat penugasan"); Penolakan sentence (K8); ChipPilihan (K7); LencanaModul post badges "Aktif", "Jabatan kosong" (K5); Tombol secondary ("Tugaskan") and text ("Catat berakhir", "Batalkan"); RiwayatAlur (K11); phone header with back. K1–K12 are KitAlur (components.md 2.9), built in M1; this unit uses them and does not create or edit `lib/widgets/alur_kit.dart`.
- **Internal views and states**
  - Initial state (logic defaults merged into `state.a`): `{ pesan: '', riw: [], v: 'daftar', sel: 0, orang: '', mulai: '16/11/2026', dok: '', J: [['Syamas','Kolom 3','',''], ['Penatua','Kolom 2','',''], ['Ketua','Komisi Diakonia','Pnt. Hendrik Rumagit','01/03/2026'], ['Operator','Jemaat','Yanti Sumual','01/11/2026']] }`. A `J` row reads [jabatan, unit, holder, since]; an empty holder means vacant.
  - Views: `daftar` (list, initial) and `form` (assign the post `J[sel]`).
  - List sub-states: banner on or off; Riwayat hidden while `riw` is empty; each card vacant or held.
  - Form sub-states: refusal hidden or shown; button met or unmet.
  - No sheets, toasts or empty states.
- **Tweaks** `keadaan` (enum) · Keadaan panel. Options "Alur" only; default "Alur". It changes nothing on the screen; show it read-only.
- **Interactions**
  - "Tugaskan" on card *i* (`pilih`): `v = 'form'`, `sel = i`, `pesan = ''`. `orang` and `dok` are not reset here, but they are always empty on arrival, because every way back to the list clears them. `mulai` keeps whatever was typed last.
  - Field "Orang" (`onOrang`): every keystroke stores the raw text in `orang`; the banner text is untouched. Free text, any characters, no length limit.
  - Chip in "Dari Data jemaat": `orang` = the chip's name, `pesan = ''`. The text field must show the name (update its controller). A chip shows selected only while the field's text equals its name exactly.
  - Field "Mulai" (`onMulai`): every keystroke stores the raw text. It is typed, not formatted: no slashes are inserted and there is no length cap. Use `TextInputType.datetime`.
  - Chip in "Keputusan gereja": `dok` = the chip's text, `pesan = ''`.
  - Condition of "Catat penugasan", first unmet reason wins, with `o = orang.trim()`:
    1. `o` empty → "orang belum diisi."
    2. `o` contains "Lidya" (case-sensitive substring) → "Anda tidak dapat menugaskan jabatan kepada diri sendiri."
    3. `mulai.trim()` does not match `^\d\d/\d\d/\d{4}$`, or the month is not 1–12, or the day is not 1–31 → "tanggal mulai tidak dikenali. Contoh: 16/11/2026." Days per month are not checked: 31/02/2026 passes.
    4. The date as yyyymmdd is later than 20261116 → "tanggal mulai belum tiba. Penugasan dicatat pada atau setelah tanggal mulainya." Past dates pass.
    5. `dok` empty → "keputusan gereja belum dipilih."
    6. `dok` is "Belum ada dokumen" → "penugasan memerlukan keputusan tertulis gereja di Dokumen gereja."
  - When the refusal shows: only once the person has started, that is while raw `orang` is not empty or `dok` is chosen. The pre-filled date alone does not open with a refusal. A single space in "Orang" already shows "orang belum diisi.". The sentence updates on every keystroke.
  - "Catat penugasan" (`catatTugas`): on press the condition is re-computed from the latest state; if unmet, nothing happens. Because every keystroke updates state, the first press after typing acts. When met:
    - `J[sel]` holder = `o`, since = `mulai.trim()`.
    - `v = 'daftar'`, `orang = ''`, `dok = ''`. `mulai` is kept.
    - `pesan` = "{jabatan} {unit} dipegang {o} sejak {mulai}. Keputusan: {dok}." For example "Syamas Kolom 3 dipegang Sym. Greis Mamahit sejak 16/11/2026. Keputusan: SK BPMJ No. 14/2026."
    - A new Riwayat row is put first: "16/11/2026 · {pesan} Dicatat oleh Pdt. Lidya Rondonuwu."
    - The card turns "Aktif" with "{o} · sejak {mulai}". It has no button, unless it is card index 2, which shows "Catat berakhir".
  - "Catat berakhir" on card 2 (`akhiri`), immediate, with no confirmation:
    - Holder and since become empty.
    - `v = 'daftar'`, `orang = ''`, `dok = ''`.
    - `pesan` = "Ketua Komisi Diakonia: penugasan {holder} berakhir 16/11/2026. Jabatan ini menjadi Jabatan kosong." With the seed holder: "…penugasan Pnt. Hendrik Rumagit berakhir…".
    - Riwayat gets "16/11/2026 · {pesan} Dicatat oleh Pdt. Lidya Rondonuwu."
    - The card becomes "Jabatan kosong" / "Belum ada pemegang" with "Tugaskan".
  - "Batalkan" (`batal`): `v = 'daftar'`, `pesan = ''`, `orang = ''`, `dok = ''`. `sel` and `mulai` are kept.
  - Back arrow: leaves the board (Links out). System Back does the same.
- **Motion** None. CSS declares `masuk`, `pudar`, `muncul`, `isi` but nothing uses them; view swaps are instant. Reduce motion: nothing to stop.
- **Links out**
  - Back arrow (semantics "Kembali ke Penugasan jabatan") → `/Penugasan`, up link.
  - **Inbound** PetaPlatform ("Ponsel").
- **Mock data**
  - Posts:
    - "Syamas Kolom 3": vacant.
    - "Penatua Kolom 2": vacant.
    - "Ketua Komisi Diakonia": Pnt. Hendrik Rumagit, sejak 01/03/2026.
    - "Operator Jemaat": Yanti Sumual, sejak 01/11/2026.
  - People to choose: Sym. Greis Mamahit, Pnt. Altje Rompas, Pdt. Lidya Rondonuwu (the actor herself).
  - Decisions: "SK BPMJ No. 14/2026", "Belum ada dokumen".
  - Actor in Riwayat: Pdt. Lidya Rondonuwu. Today 16/11/2026 (20261116).
- **Prototype-only** None on the screen. The helper "Tanggal, bulan, tahun. Contoh: 16/11/2026." is in-app hint text, not a "Contoh:" button; keep it on the screen.
- **Acceptance checks**
  1. Fresh open: four cards.
     - "Syamas Kolom 3" and "Penatua Kolom 2": `bata`-outlined "Jabatan kosong", "Belum ada pemegang" and a "Tugaskan" button.
     - "Ketua Komisi Diakonia": `laut` "Aktif", "Pnt. Hendrik Rumagit · sejak 01/03/2026" and "Catat berakhir".
     - "Operator Jemaat": "Aktif", "Yanti Sumual · sejak 01/11/2026", no button.
     - No banner, no Riwayat.
  2. "Tugaskan" on Syamas → form with "Jabatan | Syamas", "Unit | Kolom 3". "Orang" is empty, "Mulai" shows "16/11/2026", no refusal line, and "Catat penugasan" is grey (`garis`/`tinta2`).
  3. Tap chip "Pdt. Lidya Rondonuwu" → the chip turns `tinta`, the field shows the name, and "Tidak dapat dilakukan: Catat penugasan. Anda tidak dapat menugaskan jabatan kepada diri sendiri." appears above the button.
  4. Tap "Sym. Greis Mamahit"; the refusal becomes "…keputusan gereja belum dipilih." Change Mulai to "17/11/2026" → "…tanggal mulai belum tiba. Penugasan dicatat pada atau setelah tanggal mulainya." Change it to "16-11-2026" → "…tanggal mulai tidak dikenali. Contoh: 16/11/2026."
  5. Mulai "16/11/2026", chip "Belum ada dokumen" → "…penugasan memerlukan keputusan tertulis gereja di Dokumen gereja." Chip "SK BPMJ No. 14/2026" → no refusal, the button turns `tinta`.
  6. Press "Catat penugasan" → the list shows. Banner: "Syamas Kolom 3 dipegang Sym. Greis Mamahit sejak 16/11/2026. Keputusan: SK BPMJ No. 14/2026." The Syamas card is "Aktif" with "Sym. Greis Mamahit · sejak 16/11/2026" and no button. Riwayat has one row: "16/11/2026 · Syamas Kolom 3 dipegang Sym. Greis Mamahit sejak 16/11/2026. Keputusan: SK BPMJ No. 14/2026. Dicatat oleh Pdt. Lidya Rondonuwu."
  7. "Tugaskan" on "Penatua Kolom 2", type "Pnt. Altje Rompas" by hand into Orang (Mulai still "16/11/2026"), pick "SK BPMJ No. 14/2026", and press immediately: it records on the first press, and the card reads "Pnt. Altje Rompas · sejak 16/11/2026".
  8. "Catat berakhir" on Ketua Komisi Diakonia → banner "Ketua Komisi Diakonia: penugasan Pnt. Hendrik Rumagit berakhir 16/11/2026. Jabatan ini menjadi Jabatan kosong."; the card is now vacant with "Tugaskan"; the new Riwayat row is on top.
  9. In the form, type a name then "Batalkan" → list without banner; "Tugaskan" again opens an empty "Orang" with no chip selected.
- **Notes**
  - The self-assignment check is a case-sensitive substring match on "Lidya" (a stand-in for "the signed-in person"). Reproduce it exactly: "lidya" passes.
  - The first refusal appears for a whitespace-only "Orang", because the trigger uses the untrimmed text. Keep it.
  - The enabled TombolBersyarat is `tinta`, not `laut` (it matches the component preview). "Tugaskan" is the secondary style.
  - Field values are 14 `tinta2` (inherited); placeholders are the platform default grey. Use `tinta3` for placeholders.
  - All colours map to tokens; no 12 px text.

---

### AlurJabatanKosong — 54 · Alur · Menjalankan jabatan kosong
- **Source** `docs/design/handoff/canvas/boards/AlurJabatanKosong.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Phone 390×844 (frame radius 36) · interactive yes
- **Route** `/AlurJabatanKosong`, no child routes (list and start form change in place) · **Widget** `AlurJabatanKosongScreen` in `lib/screens/p2/alur_jabatan_kosong.dart`
- **Purpose** Operator (Yanti Sumual), journey step 2 ("Menjalankan jabatan kosong", "Alur · Menjalankan jabatan kosong"). The Operator starts running the vacant post Penatua Kolom 2 with a required reason and an acknowledgement, verifies data from that post's queue, and stops automatically once a holder is assigned. Shows:
  - The PitaJabatanKosong rules: always visible while running; every action recorded "oleh {nama}, Operator · menjalankan jabatan kosong {jabatan}"; gone as soon as a holder is assigned.
  - The platform rule "no one verifies … their own family's", which still holds while running a vacant post: the third item is forwarded to Syamas Kolom 2.
  - P12: the reason must not be blank, with no minimum length.
  - RiwayatAlur: "An action run by an Operator for a vacant post says so in its row".
  - It mirrors R04 (the vacancy sample of the Bendahara post) for a Data jemaat post.
- **Shell** Phone, no tab bar, header with back arrow (up link to `/JabatanKosong`). Root and body as AlurPenugasan (K1, K2).
- **Layout**
  - Header (K1): semantics "Kembali ke Menjalankan jabatan kosong"; h1 "Alur · Menjalankan jabatan kosong"; subtitle "Operator menjalankan Penatua Kolom 2 sampai ada pemegangnya" (13 `tinta2`).

  View **daftar**, top to bottom (sub-state `belum` = not running and not filled; `jalan` = running; `terisi` = filled):
  1. Status banner (K3), when `pesan` is set.
  2. (belum)
     - Vacancy card (K4, padding 14/16): "Penatua Kolom 2" 700 with badge "Jabatan kosong" (bata). Then "Kosong sejak 31/10/2026 · 3 data Kolom 2 menunggu verifikasi" 14 `tinta2`, then "Selama kosong, pekerjaan Kolom 2 tidak berjalan." 13 `tinta3`.
     - Action row (K9) with one button "Jalankan jabatan kosong": min height 52, radius 14, `tinta` field, `permukaan` text, 700, flex 1 1 150, max width 340. It always works (it only opens the form).
  3. (jalan) Running banner (PitaJabatanKosong, the full-banner form): `tinta` field, `permukaan` text, radius 14, padding 12/14, 14 px. "**Anda menjalankan jabatan kosong Penatua Kolom 2.**" then a space and "Setiap tindakan dicatat sebagai dijalankan oleh Operator Yanti Sumual." in `diTinta2`. Not a live region.
  4. (terisi) Filled notice (terpilih line): 1.5 `tinta` border, radius 12, `permukaan`, padding 12/14, 14 px: "**Penatua Kolom 2 sudah terisi:** Pnt. Altje Rompas, sejak 16/11/2026. Anda tidak lagi menjalankan jabatan ini."
  5. (jalan or terisi) Queue:
     - h2 "Menunggu verifikasi · Kolom 2" 16/700.
     - Three item cards (K4, padding 12/16), each: title 700 with a badge, either "Diajukan" (garis: 1.5 `tinta3` line, `tinta2` text) or "Diverifikasi" (laut). Then the second line 13 `tinta3`.
     - Under the text, either the button "Verifikasi data" or a refusal line (rules in Interactions):
       - "Verifikasi data": min height 52, radius 14, `tinta` field, `permukaan` text, 700, padding 0 16, start-aligned, not stretched.
       - Refusal line (K8): "Tidak dapat dilakukan: Verifikasi data." + cause.
     - Riwayat (K11), when it has rows (always, once running).
     - (jalan only) Action row (K9) with the prototype button "Contoh: pemegang jabatan ditugaskan" (text button). It moves to the Keadaan panel; see Prototype-only.
  6. Footnote (K12), always in this view: "Menjalankan jabatan kosong tidak memberi wewenang atas data keluarga sendiri, dan berakhir sendiri begitu pemegang jabatan ditugaskan."

  View **mulai** (start form), top to bottom:
  1. Card (K4, padding 14/16): "Penatua Kolom 2" 700 + badge "Jabatan kosong" (bata). Then 14 `tinta2`: "Anda akan menjalankan jabatan ini atas nama sendiri. Nama Anda, bukan nama jabatan, yang tercatat pada setiap tindakan."
  2. Field "Alasan · wajib" (K6t, textarea, 3 rows, min height 96, no placeholder, no helper).
  3. Acknowledgement checkbox. The whole row is the target: row, gap 12, aligned to the top, min height 44, 14 px `tinta`.
     - Checkbox 24×24, 2 down from the top, `laut` when checked.
     - Text: "Saya mengerti setiap tindakan saya tercatat sebagai dijalankan oleh Operator, dan jabatan ini kembali kepada pemegangnya begitu ditugaskan."
  4. Refusal line (K8), when shown: "Tidak dapat dilakukan: Jalankan jabatan kosong." + cause.
  5. Action row (K9): TombolBersyarat "Jalankan jabatan kosong"; text button "Batalkan".
- **Components** PitaJabatanKosong (the running banner, drawn inside the content as on the board); LencanaModul "Jabatan kosong"; LencanaStatus look "Diajukan"/"Diverifikasi"; IsianAlasan (3-row variant); TombolBersyarat; Penolakan sentences; Tombol (`tinta` "Verifikasi data"); RiwayatAlur; KitAlur (components.md 2.9).
- **Internal views and states**
  - Initial state (merged into `state.a`): `{ pesan: '', riw: [], v: 'daftar', alasan: '', paham: false, jalan: false, terisi: false, beres: [] }`. `beres` holds the indexes of verified queue items.
  - Views: `daftar`, `mulai`.
  - Sub-states of `daftar`:
    - `belum` (initial): vacancy card and start button only.
    - `jalan`: running banner, queue, Riwayat, the prototype trigger.
    - `terisi`: filled notice, queue with refusals, Riwayat.
  - `jalan` and `terisi` never hold together.
  - Each queue item is pending ("Diajukan") or verified ("Diverifikasi").
- **Tweaks** `keadaan` (enum) · Keadaan panel. Options "Alur" only; default "Alur". It changes nothing; show it read-only.
- **Interactions**
  - "Jalankan jabatan kosong" in `belum` (`keMulai`): `v = 'mulai'`, `pesan = ''`. `alasan` and `paham` keep earlier values; they are empty and false on first use.
  - "Alasan · wajib" (`onAlasan`): every keystroke stores the raw text. Free text, multi-line, no limit.
  - Checkbox row (`onPaham`): toggles `paham`. Tapping the text toggles it too.
  - Condition of "Jalankan jabatan kosong" (form), first unmet reason wins, with `al = alasan.trim()`:
    1. `al` empty → "alasan belum diisi."
    2. `paham` false → "pernyataan belum dicentang."
  - When the refusal shows: only while `al` is not empty or `paham` is true. Spaces alone do not open it; an empty form opens without it.
  - "Jalankan jabatan kosong" (`mulaiJalan`): re-checks on press and does nothing when unmet; the first press after typing acts. When met:
    - `v = 'daftar'`, `jalan = true`.
    - `pesan` = "Anda menjalankan jabatan kosong Penatua Kolom 2 sejak 16/11/2026."
    - New first Riwayat row: "16/11/2026 · Mulai menjalankan jabatan kosong Penatua Kolom 2 · alasan: {al} · Yanti Sumual, Operator". The reason is stored trimmed.
  - "Batalkan" (`batal`): `v = 'daftar'`, `pesan = ''`. `alasan` and `paham` stay as typed.
  - Queue item rules: the item is `i`, with refusal cause `a[2]`, which only item 3 has.
    - "Verifikasi data" shows when `jalan`, the item is not verified, and it has no cause.
    - The refusal shows when the item is not verified and either it has a cause or `terisi`.
    - Refusal text: when `terisi` and the item has no cause, "Anda tidak lagi menjalankan jabatan Penatua Kolom 2."; otherwise its own cause, "ini data keluarga Anda sendiri. Diteruskan kepada Syamas Kolom 2."
  - "Verifikasi data" on item *i* (`act`), immediate:
    - `beres += i`; the badge turns "Diverifikasi" (laut) and the button disappears.
    - New first Riwayat row: "16/11/2026 · Memverifikasi {title} · oleh Yanti Sumual, Operator · menjalankan jabatan kosong Penatua Kolom 2".
    - The banner `pesan` is left as it was.
  - Prototype trigger "Contoh: pemegang jabatan ditugaskan" (`isiJabatan`, Keadaan panel, enabled only while `jalan`):
    - `jalan = false`, `terisi = true`, `pesan = ''`.
    - New first Riwayat row: "16/11/2026 · Penatua Kolom 2 ditugaskan kepada Pnt. Altje Rompas · menjalankan jabatan kosong berakhir".
    - The running banner is replaced by the filled notice, and every pending item shows its refusal. Verified items stay "Diverifikasi". Nothing can restart the run, because `belum` needs `jalan` and `terisi` both false.
  - Back arrow: leaves the board.
- **Motion** None. CSS declares `masuk`, `pudar`, `muncul`, `isi` but nothing uses them. Reduce motion: nothing to stop.
- **Links out**
  - Back arrow (semantics "Kembali ke Menjalankan jabatan kosong") → `/JabatanKosong`, up link.
  - **Inbound** PetaPlatform ("Ponsel").
- **Mock data**
  - Operator Yanti Sumual; post Penatua Kolom 2, vacant since 31/10/2026, with 3 items waiting.
  - Queue (title | second line | own refusal):
    1. "Permohonan menjadi anggota · Ferry Wenas" | "Diajukan 14/11/2026 · izin data pribadi diberikan" | none.
    2. "Peristiwa: Sidi · Gabriela Rompas" | "Diajukan 12/11/2026" | none.
    3. "Perubahan data · Keluarga Sumual" | "Diajukan 15/11/2026" | "ini data keluarga Anda sendiri. Diteruskan kepada Syamas Kolom 2."
  - New holder: Pnt. Altje Rompas, sejak 16/11/2026.
- **Prototype-only** The button "Contoh: pemegang jabatan ditugaskan" (it stands for the Pimpinan assigning a holder on another device) is **not** drawn on the screen. The Keadaan panel shows it as a labelled action, "Contoh: pemegang jabatan ditugaskan", enabled only while the screen is in `jalan`, and running `isiJabatan` on this screen's state. The board's own action row for it is omitted.
- **Acceptance checks**
  1. Fresh open: the vacancy card ("Penatua Kolom 2", `bata` badge "Jabatan kosong", "Kosong sejak 31/10/2026 · 3 data Kolom 2 menunggu verifikasi") with a `tinta` button "Jalankan jabatan kosong" and the footnote. No queue, no Riwayat.
  2. Press it → the form shows, with no refusal line and a grey "Jalankan jabatan kosong".
  3. Tick the box only → "Tidak dapat dilakukan: Jalankan jabatan kosong. alasan belum diisi." Untick it and type "   " → no refusal. Type "Penatua Kolom 2 belum ada" with the box unticked → "…pernyataan belum dicentang."
  4. With text "Penatua Kolom 2 belum ada" and the box ticked:
     - The button turns `tinta`; press once → list.
     - Banner: "Anda menjalankan jabatan kosong Penatua Kolom 2 sejak 16/11/2026."
     - The dark running banner.
     - Three "Diajukan" items: items 1–2 with "Verifikasi data", item 3 with "Tidak dapat dilakukan: Verifikasi data. ini data keluarga Anda sendiri. Diteruskan kepada Syamas Kolom 2."
     - Riwayat row "16/11/2026 · Mulai menjalankan jabatan kosong Penatua Kolom 2 · alasan: Penatua Kolom 2 belum ada · Yanti Sumual, Operator".
  5. "Verifikasi data" on item 1 → its badge reads "Diverifikasi" on `laut` and its button is gone. The new top Riwayat row is "16/11/2026 · Memverifikasi Permohonan menjadi anggota · Ferry Wenas · oleh Yanti Sumual, Operator · menjalankan jabatan kosong Penatua Kolom 2". The banner is still shown.
  6. Panel → "Contoh: pemegang jabatan ditugaskan":
     - The banner and the dark banner disappear, replaced by "Penatua Kolom 2 sudah terisi: Pnt. Altje Rompas, sejak 16/11/2026. Anda tidak lagi menjalankan jabatan ini."
     - Item 2 shows "…Anda tidak lagi menjalankan jabatan Penatua Kolom 2."; item 1 stays "Diverifikasi"; item 3 keeps its own reason.
     - The panel action is now disabled.
  7. The screen itself never shows a button labelled "Contoh: …".
  8. "Batalkan" in the form returns to the list unchanged; reopening the form shows the earlier reason and tick.
- **Notes**
  - The running banner sits inside the scrolling content, not pinned above the screen as PitaJabatanKosong prescribes; the board wins.
  - RiwayatAlur says a typed reason is recorded "exactly as typed", but the board stores it trimmed. Keep the board.
  - The cause sentences start in lower case after the period ("ini data keluarga…"), following the TombolBersyarat pattern; keep them.
  - "Verifikasi data" and the start button are `tinta`, not `laut`; keep them.

---

### WebAlurJabatanKosong — Web · Alur · Menjalankan jabatan kosong
- **Source** `docs/design/handoff/canvas/boards/WebAlurJabatanKosong.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Laptop page (preview 1440×1000, `expand: fill`) · interactive yes
- **Route** `/WebAlurJabatanKosong`, no child routes · **Widget** `WebAlurJabatanKosongScreen` in `lib/screens/p2/web_alur_jabatan_kosong.dart`
- **Purpose** Same as AlurJabatanKosong, on the Operator's laptop (Q26).
- **Shell** The platform web side nav, as WebCariOrang (same ten items, logo, footer "Yanti Sumual · Operator", below-860 drawer). Here the active item is **Pengaturan** (index 9, `tinta` field). Main as WebCariOrang.
- **Layout** (inside Main)
  1. Title block:
     - Breadcrumb link "Menjalankan jabatan kosong" 14/600 `laut`, underlined.
     - h1 "Alur · Menjalankan jabatan kosong" `judulHalaman` 26/700, 2 above.
     - Subtitle "Operator menjalankan Penatua Kolom 2 sampai ada pemegangnya" 14 `tinta2`.
  2. Content column: max width 1120, at the start of Main (not centred), column gap 16. The same two views and the same regions as AlurJabatanKosong, with these differences:
     - Text inherits 15 px where the phone has 16: card titles 15/700, button labels 15/700. Sizes set explicitly (13, 14, 16) stay the same, and "Menunggu verifikasi · Kolom 2" and "Riwayat" stay 16/700.
     - Buttons in action rows grow to at most 340 (flex 1 1 150), so "Jalankan jabatan kosong" in `belum` is 340 wide.
     - The vacancy card, the running banner, the filled notice, the form card, the textarea and the checkbox row span the content width (up to 1120).
     - (jalan or terisi) The queue and the Riwayat sit in **two columns**: a row that wraps, row gap 20, column gap 28, aligned to the top.
       - Left column (flex 1.3 1 420, min width 0, column gap 12): h2 "Menunggu verifikasi · Kolom 2" and the three item cards.
       - Right column (flex 1 1 340, min width 0, column gap 12): h2 "Riwayat" and the Riwayat card (K11). The prototype trigger row sits below it on the board and moves to the panel here too.
       - At 1440 (content 1120) the columns are about 608 and 484 wide. They stack when the content is narrower than about 788.
     - The footnote follows below the columns, at full width.
- **Components** As AlurJabatanKosong, plus the platform web side nav (shell).
- **Internal views and states** Identical to AlurJabatanKosong; the logic class is the same apart from `web = true`, which links nothing here. Same initial state. Nav drawer open/closed below 860 is local UI state.
- **Tweaks** `keadaan` (enum) · Keadaan panel. "Alur" only; default "Alur"; changes nothing.
- **Interactions** Identical to AlurJabatanKosong (start, reason, checkbox, conditions, refusals, verify, the prototype trigger, cancel), with the same sentences and Riwayat texts. Also the nav drawer toggle below 860; while it is open, system or browser Back closes it first (navigation.md 5.1).
- **Motion** None. CSS declares `muncul`, `isi`, `titik` but nothing uses them. Reduce motion: nothing to stop.
- **Links out**
  - Breadcrumb "Menjalankan jabatan kosong" → `/WebJabatanKosong`, up link.
  - Side nav (`go`): "Beranda" → `/WebBerandaJabatan`, "Keuangan" → `/WebBeranda`, "Dokumen gereja" → `/WebDokumenGereja`, "Pengumuman" → `/WebPengumuman`, "Warta Jemaat" → `/WebWartaArsip`, "Data jemaat" → `/WebDataAnggota`, "Ibadah dan kegiatan" → `/Ibadah`, "Panitia" → `/Panitia`, "Pemberitahuan" → `/WebKotakMasuk`, "Pengaturan" → `/WebPenugasan` (the active item; tapping it still navigates).
  - **Inbound** PetaPlatform ("Web").
- **Mock data** As AlurJabatanKosong; nav footer "Yanti Sumual · Operator".
- **Prototype-only** As AlurJabatanKosong: "Contoh: pemegang jabatan ditugaskan" goes to the Keadaan panel, enabled only while running; it is not drawn in the right column.
- **Acceptance checks**
  1. At 1440: "Pengaturan" is the filled nav item. The breadcrumb reads "Menjalankan jabatan kosong" above the 26 px h1.
  2. Fresh open: the vacancy card spans the content width and the start button is 340 wide.
  3. Start with a reason and the tick:
     - The queue sits on the left (about 608 wide) and the Riwayat on the right (about 484), tops aligned.
     - The banner "Anda menjalankan jabatan kosong Penatua Kolom 2 sejak 16/11/2026." and the dark banner sit above the columns, at full width.
  4. At 900 wide (nav still beside the page, content about 626, under the 788 breakpoint): the Riwayat column stacks under the queue.
  5. At 800 wide: the nav is a top bar with "Menu"; the page still has no horizontal scroll.
  6. Panel trigger → the filled notice and the refusals, exactly as on the phone.
  7. Breadcrumb → `/WebJabatanKosong`; nav "Data jemaat" → `/WebDataAnggota` (go).
- **Notes**
  - The active nav item is "Pengaturan" because the jabatan-kosong settings live under Pengaturan → WebPenugasan. Keep it.
  - Radius 10 on nav items is off-token (allowed).

---

### AlurPelimpahan — 55 · Alur · Pelimpahan tugas
- **Source** `docs/design/handoff/canvas/boards/AlurPelimpahan.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Phone 390×844 (frame radius 36) · interactive yes
- **Route** `/AlurPelimpahan`, no child routes · **Widget** `AlurPelimpahanScreen` in `lib/screens/p2/alur_pelimpahan.dart`
- **Purpose** Listed in the journey of the Pimpinan Jemaat yang berwenang (step 2, "Pelimpahan tugas", "Alur · Pelimpahan tugas"). The actor on this board is Pnt. Hendrik Rumagit, Penatua Kolom 7, delegating one of his own tasks. Shows the rules of delegation:
  - One task at a time.
  - Always an end date after today; it ends by itself on that date.
  - Never to oneself.
  - While active, both people can act and every action records who acted.
  - The recipient is told in Pemberitahuan (in-app, D28).
  - Ending early is recorded.
  - TombolBersyarat with dates typed hh/bb/tttt (the component preview uses this very form).
- **Shell** Phone, no tab bar, header with back arrow (up link to `/Pelimpahan`). Root and body as AlurPenugasan (K1, K2).
- **Layout**
  - Header (K1): semantics "Kembali ke Pelimpahan tugas"; h1 "Alur · Pelimpahan tugas"; subtitle "Untuk sementara, dengan tanggal berakhir".

  View **daftar**, top to bottom:
  1. Status banner (K3), when `pesan` is set.
  2. (no delegation yet, `st` empty)
     - Empty box, draf line (1.5 dashed `putus`), radius 14, padding 14/16, column gap 6: "Belum ada pelimpahan" 16/700; "Limpahkan satu tugas kepada pelayan lain bila Anda berhalangan. Pelimpahan selalu punya tanggal berakhir." 14 `tinta2`.
     - Action row (K9) with "Buat pelimpahan": min height 52, radius 14, `tinta` field, `permukaan` text, 700, flex 1 1 150, max width 340. It always works (it opens the form).
  3. (a delegation exists, `st` is `aktif` or `usai`)
     - Delegation card (K4, padding 14/16):
       - Head: the task (e.g. "Verifikasi data Kolom 7") 700 + badge "Aktif" (laut) or "Berakhir" (abu: `garis` field, `tinta2` text, 1.5 `garis` border).
       - Line 14 `tinta2`: "Penatua Kolom 7 → {kepada}".
       - Line 13 `tinta3`: "Berlaku sampai {sampai} · berakhir sendiri pada tanggalnya" (aktif) or "Diakhiri 16/11/2026 oleh Pnt. Hendrik Rumagit" (usai).
     - (aktif) Action row (K9) with the secondary button "Akhiri sekarang" (K10 style, min height 48, flex 1 1 150, max width 340). Then footnote (K12): "Selama pelimpahan aktif, Anda dan penerima sama-sama dapat menjalankan tugas ini. Setiap tindakan mencatat siapa yang menjalankannya."
     - (usai) Action row (K9) with the secondary button "Buat pelimpahan baru" (same style).
  4. Riwayat (K11), when it has rows.

  View **form**, top to bottom:
  1. Chip group "Dilimpahkan kepada" (K7): "Sym. Greis Mamahit", "Pnt. Hendrik Rumagit".
  2. Chip group "Tugas" (K7): "Verifikasi data Kolom 7", "Menyetujui jadwal ibadah Kolom 7".
  3. Field "Berlaku sampai" (K6): empty, placeholder "hh/bb/tttt", helper "Wajib. Pelimpahan berakhir sendiri pada tanggal ini."
  4. Refusal line (K8), when shown: "Tidak dapat dilakukan: Buat pelimpahan." + cause.
  5. Action row (K9): TombolBersyarat "Buat pelimpahan"; text button "Batalkan".
- **Components** TombolBersyarat; Penolakan sentences; ChipPilihan; LencanaModul post-style badges "Aktif"/"Berakhir"; Tombol secondary ("Akhiri sekarang", "Buat pelimpahan baru") and `tinta` ("Buat pelimpahan" in the empty state); RiwayatAlur; the draf empty box; KitAlur (components.md 2.9).
- **Internal views and states**
  - Initial state (merged into `state.a`): `{ pesan: '', riw: [], v: 'daftar', kepada: '', tugas: '', sampai: '', st: '' }`.
  - Views: `daftar`, `form`.
  - `st`: `''` means no delegation (empty box), `'aktif'` (card + "Akhiri sekarang"), `'usai'` (card + "Buat pelimpahan baru").
  - The card shows the current `tugas`, `kepada` and `sampai` from state (see Notes).
- **Tweaks** `keadaan` (enum) · Keadaan panel. "Alur" only; default "Alur"; changes nothing.
- **Interactions**
  - "Buat pelimpahan" (empty state) and "Buat pelimpahan baru" (`keForm`): `v = 'form'`, `pesan = ''`, `kepada = ''`, `tugas = ''`, `sampai = ''`. `st` is unchanged.
  - Chip in "Dilimpahkan kepada": `kepada` = the name, `pesan = ''`. Chip in "Tugas": `tugas` = the task, `pesan = ''`.
  - Field "Berlaku sampai" (`onSampai`): every keystroke stores the raw text; typed, not formatted, no length cap; `TextInputType.datetime`.
  - Condition of "Buat pelimpahan", first unmet reason wins, with `t` = the parsed `sampai` (same parser as AlurPenugasan: `^\d\d/\d\d/\d{4}$` after trim, month 1–12, day 1–31, as yyyymmdd):
    1. `kepada` empty → "penerima belum dipilih."
    2. `kepada` is "Pnt. Hendrik Rumagit" → "tugas tidak dapat dilimpahkan kepada diri sendiri."
    3. `tugas` empty → "tugas belum dipilih."
    4. `sampai.trim()` empty → "tanggal berakhir belum diisi."
    5. `t` unparseable → "tanggal berakhir tidak dikenali. Contoh: 30/11/2026."
    6. `t` ≤ 20261116 → "tanggal berakhir harus setelah hari ini (16/11/2026)." Today itself is refused.
  - When the refusal shows: only while `kepada`, `tugas` or the raw `sampai` is not empty. The empty form opens without a refusal.
  - "Buat pelimpahan" (`buat`): re-checks on press and does nothing when unmet; the first press after typing acts. When met:
    - `v = 'daftar'`, `st = 'aktif'`.
    - `pesan` = "{kepada} diberi tahu lewat Pemberitahuan." For example "Sym. Greis Mamahit diberi tahu lewat Pemberitahuan."
    - New first Riwayat row: "16/11/2026 · Pelimpahan dibuat: {tugas} kepada {kepada} sampai {sampai.trim()}".
  - "Akhiri sekarang" (`akhiri`), immediate, with no confirmation:
    - `st = 'usai'`, `pesan = ''`.
    - New first Riwayat row: "16/11/2026 · Pelimpahan diakhiri: {tugas} kembali hanya kepada Pnt. Hendrik Rumagit".
    - The badge turns "Berakhir" and the line reads "Diakhiri 16/11/2026 oleh Pnt. Hendrik Rumagit".
  - "Batalkan" (`batal`): `v = 'daftar'`, `pesan = ''`. The form values stay in state.
  - Back arrow: leaves the board.
- **Motion** None. CSS declares `masuk`, `pudar`, `muncul`, `isi` but nothing uses them. Reduce motion: nothing to stop.
- **Links out**
  - Back arrow (semantics "Kembali ke Pelimpahan tugas") → `/Pelimpahan`, up link.
  - **Inbound** PetaPlatform ("Ponsel").
- **Mock data**
  - Delegator: Pnt. Hendrik Rumagit, Penatua Kolom 7. Recipients: Sym. Greis Mamahit, and Pnt. Hendrik Rumagit himself (refused).
  - Tasks: "Verifikasi data Kolom 7", "Menyetujui jadwal ibadah Kolom 7".
  - Today 16/11/2026. The example end date in the refusal: 30/11/2026.
- **Prototype-only** None. The automatic end on the date is not simulated on this board (Pelimpahan's tweak "Berakhir sendiri" shows it).
- **Acceptance checks**
  1. Fresh open: the dashed box "Belum ada pelimpahan" with its sentence, and a `tinta` button "Buat pelimpahan". No Riwayat.
  2. Open the form: no chip selected, an empty date, no refusal, a grey "Buat pelimpahan".
  3. Tap "Pnt. Hendrik Rumagit" → "Tidak dapat dilakukan: Buat pelimpahan. tugas tidak dapat dilimpahkan kepada diri sendiri."
  4. Tap "Sym. Greis Mamahit" → "…tugas belum dipilih."; tap "Verifikasi data Kolom 7" → "…tanggal berakhir belum diisi."
  5. Type "16/11/2026" → "…tanggal berakhir harus setelah hari ini (16/11/2026)."; type "31/13/2026" → "…tanggal berakhir tidak dikenali. Contoh: 30/11/2026."
  6. Type "30/11/2026" → no refusal and the button turns `tinta`. Press once →
     - Banner "Sym. Greis Mamahit diberi tahu lewat Pemberitahuan."
     - Card "Verifikasi data Kolom 7" / "Aktif" / "Penatua Kolom 7 → Sym. Greis Mamahit" / "Berlaku sampai 30/11/2026 · berakhir sendiri pada tanggalnya".
     - "Akhiri sekarang", the footnote, and Riwayat "16/11/2026 · Pelimpahan dibuat: Verifikasi data Kolom 7 kepada Sym. Greis Mamahit sampai 30/11/2026".
  7. "Akhiri sekarang" →
     - The banner is gone; the badge reads "Berakhir" on a `garis` field; the line reads "Diakhiri 16/11/2026 oleh Pnt. Hendrik Rumagit".
     - The button is now "Buat pelimpahan baru".
     - The new top Riwayat row is "16/11/2026 · Pelimpahan diakhiri: Verifikasi data Kolom 7 kembali hanya kepada Pnt. Hendrik Rumagit".
  8. "Buat pelimpahan baru" → the form opens empty.
- **Notes**
  - **Board quirk.** On the board, "Buat pelimpahan baru" clears `tugas`/`kepada`/`sampai`. If the person then presses "Batalkan", the ended card is drawn with an empty title, "Penatua Kolom 7 → " and no name. Recommended: keep a snapshot of the last created delegation (task, recipient, end date) for the card, separate from the form fields, so the ended card keeps its text. This is the only deviation from the logic in this file; everything else follows the board.
  - The empty-state button is `tinta`, not `laut`; keep it.

---

### AlurBeranda — 56 · Alur · Beranda gabungan
- **Source** `docs/design/handoff/canvas/boards/AlurBeranda.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Phone 390×844 (frame radius 36) · interactive yes
- **Route** `/AlurBeranda`, no child routes (the three items open in place under the same header) · **Widget** `AlurBerandaScreen` in `lib/screens/p2/alur_beranda.dart`
- **Purpose** Anyone with several posts; journey "Anyone, before a post applies", step 2 ("Beranda": one combined home for all posts). The person here is Pnt. Hendrik Rumagit, who holds Penatua Kolom 7 and Ketua Komisi Diakonia. Shows:
  - Q31 and BertindakSebagai: one Beranda with no post switcher; each item names its post ("Sebagai …").
  - With exactly one post in authority, the app uses it and says "Anda bertindak sebagai Penatua Kolom 7".
  - With two posts in authority, it asks; the post used is recorded in Riwayat and cannot be changed.
  - Another post never opens a way to approve one's own request (P09: a requester never approves their own request).
  - ButirPerhatian "Perlu tindakan".
- **Shell** Phone, no tab bar, header with back arrow (up link to `/BerandaJabatan`). Root and body as AlurPenugasan (K1, K2).
- **Layout**
  - Header (K1): semantics "Kembali ke Beranda"; h1 "Alur · Beranda gabungan"; subtitle "Satu Beranda; jabatan dipilih per tindakan".

  View **beranda**, top to bottom:
  1. Person card (BertindakSebagai): `permukaan`, 1 px `garis`, radius 14, padding 12/14, column gap 8.
     - Column: "Pnt. Hendrik Rumagit" 16/700; "Jabatan Anda" 13 `tinta3`.
     - A wrap row, gap 6, of two post badges: 13/700, radius 6, padding 3/9, 1.5 `tinta` border (terpilih line), `permukaan` field, `tinta` text. "Penatua Kolom 7", "Ketua Komisi Diakonia". They are not buttons.
  2. Status banner (K3), when `pesan` is set.
  3. h2 `judulBagian` 16/700: "Perlu tindakan · {n}", where n is the number of items still open (3, 2 or 1).
  4. One button card per open item (ButirPerhatian "Perlu tindakan"), in order a, b, c:
     - Card: `permukaan`, 1 px `garis`, radius 14, padding 12/16, min height 44, full width, row, centred, gap 12, left-aligned.
     - Column (flex 1, gap 2): title 16/600; "Sebagai …" line 13 `tinta3`.
     - Chevron 18 (`tinta3`).
  5. (no item left; unreachable on this board) Empty box, draf line, radius 14, padding 14/16, gap 6: "Tidak ada yang perlu tindakan" 16/700; "Pekerjaan dari semua jabatan Anda akan muncul di sini." 14 `tinta2`.
  6. Riwayat (K11), when it has rows.

  View **a** (verify a baptism, one post in authority), top to bottom:
  1. Detail card (K4, padding 14/16):
     - Head: "Verifikasi data · Peristiwa: Baptisan" 700 + badge "Diajukan" (garis).
     - Line 14 `tinta2`: "Gabriel Wenas · Keluarga Wenas-Lasut · Kolom 7".
     - Key/value: "Diajukan oleh" | "Novita Wenas, 15/11/2026".
  2. Post banner: `lautLembut` field, radius 12, padding 12/14, 14 px: "**Anda bertindak sebagai Penatua Kolom 7.**" then a space and "Hanya jabatan ini yang berwenang memverifikasi data Kolom 7." in `tinta2`. Not a live region.
  3. Action row (K9): "Verifikasi data" (min height 52, radius 14, `tinta` field, `permukaan` text, 700, flex 1 1 150, max width 340; always enabled); text button "Kembali".

  View **b** (approve a schedule, two posts in authority), top to bottom:
  1. Detail card (K4, padding 14/16):
     - Head: "Setujui jadwal · Ibadah Kolom 7 bersama Komisi Diakonia" 700 + badge "Draf" (draf).
     - Line 14 `tinta2`: "Kamis, 19/11/2026 19.00 · rumah Kel. Wenas-Lasut".
  2. Notice (terpilih line): 1.5 `tinta` border, radius 12, `permukaan`, padding 12/14, 14 px: "**Dua jabatan Anda dapat menyetujui ini.** Pilih salah satu. Jabatan yang Anda pilih tercatat di Riwayat dan tidak dapat diubah setelahnya."
  3. Chip group "Bertindak sebagai" (K7): "Penatua Kolom 7", "Ketua Komisi Diakonia".
  4. Refusal line (K8) "Tidak dapat dilakukan: Setujui jadwal." + cause: never shown on this board (its cause is always empty). Do not build it.
  5. Action row (K9): TombolBersyarat "Setujui jadwal"; text button "Kembali".

  View **c** (own fund request, refused), top to bottom:
  1. Detail card (K4, padding 14/16):
     - Head: "Permintaan dana · Komisi Diakonia" 700 + badge "Diajukan" (garis).
     - Key/value "Jumlah (Rp)" | "Rp750.000" (mono 14/600).
     - Key/value "Diajukan oleh" | "Pnt. Hendrik Rumagit, Ketua Komisi Diakonia".
  2. Refusal (Penolakan), **15 px**: "Tidak dapat dilakukan: Setujui." in `bata` 700, a space, then "permintaan ini Anda ajukan sendiri. Jabatan Anda yang lain tidak membuka jalan menyetujuinya." in `tinta`.
  3. "Menunggu Pdt. Lidya Rondonuwu, Ketua Jemaat." 13 `tinta3`.
  4. Action row (K9) with only the secondary button "Kembali" (K10 style: min height 48, 1.5 `tinta`, flex 1 1 150, max width 340). There is no approve button.
- **Components** BertindakSebagai (person card with post badges, "Sebagai …" lines, "Anda bertindak sebagai …" banner, the two-post choice); ButirPerhatian "Perlu tindakan" rows; LencanaStatus look "Diajukan", "Draf"; ChipPilihan; TombolBersyarat ("Setujui jadwal"); Penolakan (view c); Tombol (`tinta` "Verifikasi data", text and secondary "Kembali"); RiwayatAlur; KitAlur (components.md 2.9). BertindakSebagai says the post choice uses outlined buttons, but the board uses ChipPilihan; the board wins.
- **Internal views and states**
  - Initial state (merged into `state.a`): `{ pesan: '', riw: [], v: 'beranda', beres: [], jab: '' }`. `beres` holds the keys of finished items: `'a'`, `'b'`.
  - Views: `beranda`, `a`, `b`, `c`.
  - Item c can never be finished, so the count goes 3 → 2 → 1 and the empty state is unreachable.
  - In view b the button is met or unmet depending on `jab`.
- **Tweaks** `keadaan` (enum) · Keadaan panel. "Alur" only; default "Alur"; changes nothing.
- **Interactions**
  - Item card (`buka`): `v` = its key (`'a'`, `'b'`, `'c'`), `pesan = ''`. Finished items are not listed, so they cannot be reopened.
  - "Kembali" in any view (`pulang`): `v = 'beranda'`, `pesan = ''`. `jab` is kept.
  - "Verifikasi data" (`selesaiA`, no condition):
    - `v = 'beranda'`, `beres += 'a'`.
    - `pesan` = "Baptisan · Gabriel Wenas diverifikasi · Pnt. Hendrik Rumagit, Penatua Kolom 7".
    - New first Riwayat row: "16/11/2026 · Baptisan · Gabriel Wenas diverifikasi · Pnt. Hendrik Rumagit, Penatua Kolom 7".
  - Chip in "Bertindak sebagai": `jab` = the post, `pesan = ''`. It cannot be cleared.
  - Condition of "Setujui jadwal": `jab` is set. No reason sentence is ever shown (see Notes).
  - "Setujui jadwal" (`selesaiB`): re-checks on press and does nothing while no post is chosen. When met:
    - `v = 'beranda'`, `beres += 'b'`.
    - `pesan` = "Jadwal ibadah Kolom 7 disetujui · Pnt. Hendrik Rumagit, {jab}".
    - Riwayat gets "16/11/2026 · {pesan}".
  - View c has no action besides "Kembali".
  - Back arrow: leaves the board.
- **Motion** None. CSS declares `masuk`, `pudar`, `muncul`, `isi` but nothing uses them. Reduce motion: nothing to stop.
- **Links out**
  - Back arrow (semantics "Kembali ke Beranda") → `/BerandaJabatan`, up link.
  - **Inbound** PetaPlatform ("Ponsel").
- **Mock data**
  - Person: Pnt. Hendrik Rumagit, posts Penatua Kolom 7 and Ketua Komisi Diakonia.
  - Items (key | title | second line):
    - a | "Baptisan · Gabriel Wenas menunggu verifikasi" | "Sebagai Penatua Kolom 7".
    - b | "Jadwal ibadah Kolom 7 bersama Komisi Diakonia" | "Sebagai Penatua Kolom 7 atau Ketua Komisi Diakonia".
    - c | "Permintaan dana Komisi Diakonia" | "Sebagai Ketua Komisi Diakonia · pengajuan Anda sendiri".
  - Baptism: Gabriel Wenas, Keluarga Wenas-Lasut, Kolom 7, submitted by Novita Wenas on 15/11/2026.
  - Schedule: Kamis, 19/11/2026 19.00, rumah Kel. Wenas-Lasut.
  - Fund request: Rp750.000, submitted by Pnt. Hendrik Rumagit as Ketua Komisi Diakonia, awaiting Pdt. Lidya Rondonuwu, Ketua Jemaat.
- **Prototype-only** None.
- **Acceptance checks**
  1. Fresh open: the person card with two `tinta`-outlined post badges, then "Perlu tindakan · 3" and three cards with the "Sebagai …" lines of Mock data. No banner, no Riwayat.
  2. Tap item a → the detail card, the `lautLembut` banner "Anda bertindak sebagai Penatua Kolom 7. …", "Verifikasi data" and "Kembali".
  3. Press "Verifikasi data" →
     - Back on the list with the banner "Baptisan · Gabriel Wenas diverifikasi · Pnt. Hendrik Rumagit, Penatua Kolom 7".
     - "Perlu tindakan · 2"; item a gone.
     - Riwayat row "16/11/2026 · Baptisan · Gabriel Wenas diverifikasi · Pnt. Hendrik Rumagit, Penatua Kolom 7".
  4. Tap item b → the "Draf" badge, the notice, two unselected chips and a grey "Setujui jadwal". Pressing it does nothing and shows no refusal.
  5. Choose "Ketua Komisi Diakonia" → the button turns `tinta`. Press → the list with "Perlu tindakan · 1" and the banner "Jadwal ibadah Kolom 7 disetujui · Pnt. Hendrik Rumagit, Ketua Komisi Diakonia". Riwayat has 2 rows, newest on top.
  6. Tap item c → "Rp750.000" in mono, the 15 px refusal "Tidak dapat dilakukan: Setujui. permintaan ini Anda ajukan sendiri. …", "Menunggu Pdt. Lidya Rondonuwu, Ketua Jemaat." and only an outlined "Kembali". Kembali → the list; the banner is cleared.
  7. Item c stays in the list for good; the empty box never appears.
- **Notes**
  - In view b the disabled "Setujui jadwal" has no "Tidak dapat dilakukan" sentence (the logic sets an empty cause), against the TombolBersyarat/Accessibility rule. Keep the board visually. Add a semantics-only hint on the button using the notice's own words, "Pilih salah satu.", so the reason is read out.
  - The view-c refusal is 15 px while other refusals are 14; copy 15.
  - The empty state is drawn but unreachable; build it anyway (no tweak opens it).
  - "Verifikasi data" is `tinta`, not `laut`; keep it.

---

### AlurModul — 57 · Alur · Modul
- **Source** `docs/design/handoff/canvas/boards/AlurModul.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Phone 390×844 (frame radius 36) · interactive yes
- **Route** `/AlurModul`, no child routes (the activate and deactivate views change in place) · **Widget** `AlurModulScreen` in `lib/screens/p2/alur_modul.dart`
- **Purpose** Pimpinan Jemaat yang berwenang (Pdt. Lidya Rondonuwu), journey step 1 ("Modul", "Alur · Modul"). Turns modules on one at a time, in dependency order, and off to Hanya baca with a required reason. Shows the LencanaModul rules and the platform rules:
  - Every module may be absent; a Tidak aktif module leaves no trace in navigation, search, notifications or empty states (footnote).
  - Turning a module off deletes nothing: it becomes Hanya baca.
  - Activating creates no data by itself.
  - P12: the reason must not be blank, with no minimum length.
  - It is the target of PemberiPersetujuan's "Aktifkan modul Persetujuan di aplikasi".
- **Shell** Phone, no tab bar, header with back arrow (up link to `/Modul`). Root and body as AlurPenugasan (K1, K2).
- **Layout**
  - Header (K1): semantics "Kembali ke Modul"; h1 "Alur · Modul"; subtitle "Mengaktifkan dan menonaktifkan, satu per satu".

  View **daftar**, top to bottom:
  1. Status banner (K3), when `pesan` is set.
  2. Six module cards (K4, padding 12/16), in order (Mock data). Each card:
     - Head: name 700 + badge in the module's state: "Aktif" (laut), "Tidak aktif" (draf), "Hanya baca" (garis: 1.5 `tinta3` line, `tinta2` text, `permukaan`).
     - Second line 13 `tinta3`, the first that applies:
       - the module has a dependency → "Perlu: {dependency} aktif";
       - it is Hanya baca → "Riwayat tetap dapat dibaca";
       - otherwise → "Tidak bergantung pada modul lain".
     - Under it, one of:
       - "Aktifkan modul": secondary (K10, min height 48, start-aligned), when the module is not Aktif (Tidak aktif or Hanya baca).
       - "Nonaktifkan modul": text button (min height 44, `laut` 700, padding 0 16, start-aligned), when it is Aktif and is not the first card (Keuangan never shows a button).
  3. Footnote (K12): "Modul yang tidak aktif tidak tampil di navigasi, pencarian, pemberitahuan atau keadaan kosong mana pun."
  4. Riwayat (K11), when it has rows.

  View **aktif** (activate the selected module), top to bottom:
  1. Card (K4, padding 14/16):
     - Head: "Aktifkan modul: {nama}" 700 + badge "Tidak aktif" (draf), always this badge.
     - (module has a dependency) Key/value "Harus aktif lebih dulu" | "{dependency}".
     - 13 `tinta3`: "Mengaktifkan modul membuka layarnya bagi jabatan yang berwenang. Tidak ada data yang dibuat sendiri oleh aplikasi."
  2. Refusal line (K8), when the dependency is not Aktif: "Tidak dapat dilakukan: Aktifkan modul." + "modul {dependency} harus aktif lebih dulu."
  3. Action row (K9): TombolBersyarat "Aktifkan modul"; text button "Kembali".

  View **mati** (deactivate the selected module), top to bottom:
  1. Card (K4, padding 14/16):
     - Head: "Nonaktifkan modul: {nama}" 700 + badge "Aktif" (laut).
     - 14 `tinta2`: "Menonaktifkan tidak menghapus apa pun. Modul menjadi **Hanya baca**: yang sudah ada tetap dapat dibaca, tetapi tidak ada yang baru." ("Hanya baca" bold.)
  2. Field "Alasan · wajib" (K6t, textarea, 3 rows, min height 96).
  3. Refusal line (K8) "Tidak dapat dilakukan: Nonaktifkan modul." + cause: never shown (see Notes).
  4. Action row (K9): TombolBersyarat "Nonaktifkan modul"; text button "Kembali".
- **Components** LencanaModul ("Aktif", "Tidak aktif", "Hanya baca"); TombolBersyarat (both forms); Penolakan sentence (dependency); IsianAlasan (3-row variant); Tombol secondary ("Aktifkan modul" on cards) and text ("Nonaktifkan modul", "Kembali"); RiwayatAlur; KitAlur (components.md 2.9).
- **Internal views and states**
  - Initial state (merged into `state.a`): `{ pesan: '', riw: [], v: 'daftar', sel: 3, alasan: '', M: [['Keuangan','Aktif',''], ['Pengumuman','Aktif',''], ['Warta Jemaat','Aktif','Pengumuman'], ['Data jemaat','Tidak aktif',''], ['Ibadah dan kegiatan','Tidak aktif','Data jemaat'], ['Jumlah kehadiran','Tidak aktif','Ibadah dan kegiatan']] }`. An `M` row reads [name, state, dependency].
  - Views: `daftar`, `aktif`, `mati`.
  - Module states: Aktif, Tidak aktif, Hanya baca.
  - The `aktif` form is met or unmet by its dependency; the `mati` form by its reason.
- **Tweaks** `keadaan` (enum) · Keadaan panel. "Alur" only; default "Alur"; changes nothing.
- **Interactions**
  - Card "Aktifkan modul" on module *i*: `v = 'aktif'`, `sel = i`, `pesan = ''`. `alasan` is not touched.
  - Card "Nonaktifkan modul" on module *i*: `v = 'mati'`, `sel = i`, `alasan = ''`, `pesan = ''`.
  - "Kembali" (`pulang`): `v = 'daftar'`, `pesan = ''`.
  - Condition of "Aktifkan modul": the selected module has no dependency, or its dependency's state is exactly "Aktif". "Hanya baca" counts as not active.
    - The refusal "modul {dependency} harus aktif lebih dulu." shows at once on opening the view. Nothing is typed in this view, so it does not wait for input.
  - "Aktifkan modul" (form): re-checks on press and does nothing when unmet. When met:
    - The module becomes "Aktif"; `v = 'daftar'`, `alasan = ''`.
    - `pesan` = "Modul {nama} aktif sejak 16/11/2026."
    - New first Riwayat row: "16/11/2026 · Modul {nama} aktif sejak 16/11/2026. Oleh Pdt. Lidya Rondonuwu."
  - "Alasan · wajib" (`onAlasan`): every keystroke stores the raw text.
  - Condition of "Nonaktifkan modul": `alasan.trim()` is not empty. There is no minimum length (P12).
  - "Nonaktifkan modul" (form): re-checks on press and does nothing when unmet; the first press after typing acts. When met:
    - The module becomes "Hanya baca"; `v = 'daftar'`, `alasan = ''`.
    - `pesan` = "Modul {nama} dinonaktifkan dan menjadi Hanya baca · alasan: {alasan trimmed}."
    - Riwayat gets "16/11/2026 · {pesan} Oleh Pdt. Lidya Rondonuwu."
    - The card now shows "Hanya baca" with "Aktifkan modul". The second line is "Riwayat tetap dapat dibaca", or "Perlu: … aktif" when the module has a dependency.
  - Nothing cascades: turning off Pengumuman leaves Warta Jemaat Aktif, and turning off Data jemaat leaves Ibadah dan kegiatan as it is. Only activation checks dependencies.
  - Back arrow: leaves the board.
- **Motion** None. CSS declares `masuk`, `pudar`, `muncul`, `isi` but nothing uses them. Reduce motion: nothing to stop.
- **Links out**
  - Back arrow (semantics "Kembali ke Modul") → `/Modul`, up link.
  - **Inbound** PemberiPersetujuan ("Aktifkan modul Persetujuan di aplikasi"), PetaPlatform ("Ponsel").
- **Mock data**
  - Modules (name | state | dependency | second line | button):
    1. "Keuangan" | Aktif | none | "Tidak bergantung pada modul lain" | no button.
    2. "Pengumuman" | Aktif | none | "Tidak bergantung pada modul lain" | "Nonaktifkan modul".
    3. "Warta Jemaat" | Aktif | Pengumuman | "Perlu: Pengumuman aktif" | "Nonaktifkan modul".
    4. "Data jemaat" | Tidak aktif | none | "Tidak bergantung pada modul lain" | "Aktifkan modul".
    5. "Ibadah dan kegiatan" | Tidak aktif | Data jemaat | "Perlu: Data jemaat aktif" | "Aktifkan modul".
    6. "Jumlah kehadiran" | Tidak aktif | Ibadah dan kegiatan | "Perlu: Ibadah dan kegiatan aktif" | "Aktifkan modul".
  - Actor: Pdt. Lidya Rondonuwu. Today 16/11/2026.
- **Prototype-only** None.
- **Acceptance checks**
  1. Fresh open: six cards as in Mock data. Keuangan has no button. Pengumuman and Warta Jemaat show the `laut` text button "Nonaktifkan modul"; the other three show the outlined "Aktifkan modul" and a dashed "Tidak aktif" badge. The footnote is shown; Riwayat is not.
  2. "Aktifkan modul" on Ibadah dan kegiatan → the card shows "Aktifkan modul: Ibadah dan kegiatan", "Harus aktif lebih dulu | Data jemaat", and at once "Tidak dapat dilakukan: Aktifkan modul. modul Data jemaat harus aktif lebih dulu." The button is grey and pressing it does nothing.
  3. Kembali, then "Aktifkan modul" on Data jemaat → no dependency row, no refusal, a `tinta` button. Press →
     - The list with the banner "Modul Data jemaat aktif sejak 16/11/2026.".
     - Data jemaat is "Aktif" with "Nonaktifkan modul".
     - Riwayat "16/11/2026 · Modul Data jemaat aktif sejak 16/11/2026. Oleh Pdt. Lidya Rondonuwu."
  4. Now "Aktifkan modul" on Ibadah dan kegiatan has no refusal and activates.
  5. "Nonaktifkan modul" on Pengumuman → an empty textarea, no refusal, a grey button. Type "  " → still grey, no refusal. Type "Diganti Warta Jemaat" and press once →
     - Banner "Modul Pengumuman dinonaktifkan dan menjadi Hanya baca · alasan: Diganti Warta Jemaat.".
     - The card shows "Hanya baca" (solid `tinta3` line), "Riwayat tetap dapat dibaca" and "Aktifkan modul".
  6. After step 5, Warta Jemaat is still "Aktif".
  7. "Aktifkan modul" on Pengumuman (Hanya baca) → the form badge reads "Tidak aktif" and activation works; the card returns to "Aktif".
- **Notes**
  - The deactivate form's refusal is dead code (`al && !al`, text "alasan terlalu pendek."). Do not build it: P12 forbids a minimum length. As a result the disabled "Nonaktifkan modul" shows no reason while the field is empty or only spaces. Add a semantics-only hint, "Alasan · wajib", on the button.
  - The activate form always shows the badge "Tidak aktif", even for a Hanya baca module. Keep the board and flag it to design.
  - There is no cascade on deactivation (Warta Jemaat stays Aktif without Pengumuman); keep it.
  - All colours map to tokens; no 12 px text.
