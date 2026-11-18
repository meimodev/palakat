# Screens 16: AlurMasuk, WebAlurMasuk, AkunSaya, WebAkunSaya, AlurPulihkan, WebAlurPulihkan

These six boards are the account flows of the platform frame (canvas page Putaran 2 · Kerangka platform), each drawn for phone and laptop. **AlurMasuk** / **WebAlurMasuk** is sign-in for anyone before a post applies: a phone number, a six-digit code sent by WhatsApp or SMS, then, for a number not yet linked to Data jemaat, name and birth date that the Penatua Kolom verifies; it ends either "Menunggu verifikasi" (only Warta Jemaat until then) or "Terhubung" with "Buka Beranda" (→ BerandaJabatan / WebBerandaJabatan) and "Tambah email cadangan" (→ AkunSaya / WebAkunSaya). **AkunSaya** / **WebAkunSaya** is the person's own account: change the phone number (proven with a code to the new number), add or change the optional backup email (proven with a code to that email), sign other devices out, push-notification settings (phone only), and "Keluar", which returns to AlurMasuk / WebAlurMasuk. **AlurPulihkan** / **WebAlurPulihkan** is recovery for a member who lost their number and has no backup email: the Operator (Yanti Sumual) requests it with the new number, the Penatua Kolom 7 (Pnt. Hendrik Rumagit) confirms the identity, and only then the new number is set; it is reached from CariOrang / WebCariOrang. The phone boards use the plain phone header with back; the laptop boards use the platform web side nav. All six are typed flows with live refusals, no timers and no motion. All figures are mock constants; nothing is saved beyond the running session.

Shared notes for this file:

- **Phone frame** (AlurMasuk, AkunSaya, AlurPulihkan): 390 × 844, background `kertas`, body `isi` (16, line-height 1.4) `tinta`. A column of a fixed header and a scrolling body. No tab bar, no bottom bar.
  - Header (does not scroll, no fill, no rule, sits on `kertas`): row, centred vertically, gap 8, padding 14 top / 12 sides / 8 bottom. Back target 44 × 44 with a centred chevron-left 22 px (SVG path `M15 6l-6 6 6 6`, viewBox 24, stroke `tinta` width 2, round caps), Semantics label as given per board, built with `Tautan`. Title column (flex 1): h1 `judulLayar` 18/700, margin 0; under it the subtitle 13 `tinta2` (the board writes `font-size: 14px` then `13px`; 13 wins).
  - Body: scrolls vertically, padding 8 top / 20 sides / 20 bottom, one column with gap 16 (content width 350). Every block below is a direct child of that column, so blocks are always 16 apart.
- **Platform web side nav** (WebAlurMasuk, WebAkunSaya, WebAlurPulihkan). Same structure, sizes and below-860 collapse as the standard web side nav (`02-awal.md`, shared notes: `nav` flex 1 1 220, padding 24 × 16, `permukaan`, right rule 1 `garis`, gap 20; logo row with the 26 × 26 mark, "palakat" 18/700 line-height 1.1, "Jemaat Karunia" 13 `tinta3`; items min-height 44, padding 0 12, radius 10, 600, no underline; active `tinta` field with `permukaan` text, others transparent with `tinta` text; footer margin-top auto, padding 12 8 0, top rule 1 `garis`, 13 `tinta2`, bold part `tinta`; "Menu" / "Tutup menu" toggle below 860). Only the items and the footer differ. Items, exactly in this order, all `go`:
  1. "Beranda" → `/WebBerandaJabatan`
  2. "Keuangan" → `/WebBeranda`
  3. "Dokumen gereja" → `/WebDokumenGereja`
  4. "Pengumuman" → `/WebPengumuman`
  5. "Warta Jemaat" → `/WebWartaArsip`
  6. "Data jemaat" → `/WebDataAnggota`
  7. "Ibadah dan kegiatan" → `/Ibadah` (a phone board; there is no web layout, Q26)
  8. "Panitia" → `/Panitia` (a phone board)
  9. "Pemberitahuan" → `/WebKotakMasuk`
  10. "Pengaturan" → `/WebPenugasan`

  The active item and the footer text are given per board. None of the three has `jabatanKosong`.
- **Web main column**: `flex 999 1 560`, min-width 0, padding 28 top / `clamp(16, 3vw, 40)` sides / 40 bottom, column gap 20, page background `kertas`, body `isiWeb` (15, line-height 1.45). The page scrolls as a whole. First child is the title block: breadcrumb text link 14/600 (see text link below); h1 `judulHalaman` 26/700, margin-top 2; subtitle 14 `tinta2`. Second child is the content column (max-width per board, column gap 16). On web every size below that says "body size" is 15 instead of 16.
- **Shared parts**: KitAlur (components.md 2.9), built in M1. This file uses it and does not redefine it. The names used below (*Field*, *ChipPilihan pill*, *Refusal line*, *TombolBersyarat*, *Primary button*, *Secondary button*, *Text button*, *Button row*, *Text link*, *Card*, *Info row*, *Dashed box*, *Badge*, *Message banner*, *Riwayat*) are the KitAlur parts of the same name. Only these differ on the six boards:
  - *Refusal line*: directly above its TombolBersyarat row, except in AkunSaya / WebAkunSaya view `kodeBaru`, where a 13 `tinta3` note comes between them.
  - *Button row*: buttons without the 150/340 flex are noted where they occur; they are KitAlur's button outside a row.
  - *Info row*: phone numbers in values are IBM Plex Mono (weight given per row).
  - *Badge*: the variants used are `garis`, `laut` and `bata`.
- **TombolBersyarat behaviour, all boards**: the board wraps each conditional handler so a press re-reads the latest input and runs the action only when the condition holds; pressing while unmet does nothing (no extra message, no shake). The first press after the input becomes valid works. When the refusal line shows is board-specific and given in each section; it is not always "after typing starts".
- **Phone number input** (AlurMasuk, AkunSaya, AlurPulihkan and web twins): phone keyboard; every change keeps digits only and cuts to 13 characters (`replace(/\D/g, '').slice(0, 13)`), so "0812-3456" becomes "08123456" and letters vanish. Valid when it matches `^08\d{8,11}$` (10 to 13 digits starting "08").
- **Six-digit code input** (pattern "Six-digit code entry", `02-components.md`): number keyboard, one-time-code autofill hint; every change keeps digits only, max 6. Placeholder "••••••". State `kode` (string) and `salah` (wrong attempts). Condition, first unmet reason: (1) `salah >= 3` → "terlalu banyak percobaan. Minta kode baru."; (2) fewer than 6 digits → "kode belum lengkap.". The refusal line shows reason (1) whenever locked; otherwise it shows "kode tidak cocok. Sisa percobaan: N." (N = 3 − `salah`) only while `salah > 0` and the field is empty; otherwise nothing (so "kode belum lengkap." is never shown). On press with 6 digits and not locked: "123456" succeeds; anything else adds 1 to `salah` and empties the field.
- **Board state**: each board keeps one state object in its screen `State`, as on the canvas. None of the six has child routes: every step or view changes in place under the same header (as Pemulihan in `09-rekonisi.md`). A `push` to another board and Back keeps the state; leaving with `go` and coming back starts fresh. System or browser Back from any view leaves the board (it pops to the previous route; it never steps back through the board's own views). The header arrow and breadcrumb are up links (`kembaliKe`): they pop only when their target is directly below, otherwise `go` to it, so they can land somewhere other than system Back.
- **Tweak, all six**: `keadaan`, enum, options `Alur`, default `Alur`. It is the only option and changes nothing on screen (the logic's `k0` / `go0` values are not used in the markup). The Keadaan panel lists it as a single fixed choice.
- **Motion, all six**: none. The boards declare keyframes (`masuk`, `pudar`, `muncul`, `isi` on phone; `muncul`, `isi`, `titik` on web) but no element uses them and there are no CSS transitions. Step and view changes are instant; do not add a transition. Reduce motion has nothing to stop here.
- **Prototype-only devices on these boards** go to the Keadaan panel ("Alat prototipe" group, each labelled with the board's own words). Each device control calls the screen's own handler, so the screen reacts exactly as it does on the canvas. When a device is removed from the screen, the space it took is removed too (no empty gap).
- **No `jabatanKosong`** on any of the six (manifest `hasJabatanKosong: false`); the global switch has no effect here. The manifest's `hasSideNav: true` on the three phone boards is a false positive of the generator (the logic class shares `renderVals` with the web boards); phone boards have no side nav.

---

### AlurMasuk — 58 · Alur · Masuk dan menghubungkan akun

- **Source** `docs/design/handoff/canvas/boards/AlurMasuk.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Phone 390×844 · interactive yes
- **Route** `/AlurMasuk`, no child routes (the four steps `nomor`, `kode`, `kenal`, `tunggu` change in place under the fixed header) · **Widget** `AlurMasukScreen` in `lib/screens/p2/alur_masuk.dart`
- **Purpose** Anyone, before a post applies: journey "Anyone, before a post applies", step 1. A person signs in with their phone number and a six-digit code sent by WhatsApp or SMS; a number not yet linked to Data jemaat is linked by name and birth date, verified by the Penatua Kolom. Shows P01 / D25 (code to a phone number, one person one account for all posts; Q31 one combined Beranda), P02 (one match → Penatua Kolom verifies; no match → membership request), P03 (until verified: only Warta Jemaat and announcements for all members), P06 (backup email optional, recovery only), and the "Six-digit code entry" pattern.
- **Shell** Phone header with back (Semantics "Kembali ke Beranda" → BerandaJabatan). Title "Alur · Masuk dan menghubungkan akun"; subtitle "Nomor ponsel, kode, lalu data jemaat yang diverifikasi Penatua". No tab bar. Inside the phone device frame on wide windows.
- **Layout** (body column, gap 16; exactly one step block at a time)

  **Step `nomor`** (initial)
  1. Title block (one child, no inner gap): "Masuk ke Palakat" 22/700 (`judulBesar`); under it "Jemaat Karunia" 14 `tinta2`.
  2. Field "Nomor ponsel", placeholder "08…", hint "Contoh: 081234567890" (a format hint; keep it on screen).
  3. Pill group, label "Kirim kode lewat": ChipPilihan pills "WhatsApp" · "SMS" (WhatsApp selected at start).
  4. Refusal line (only when shown, see Interactions): "Tidak dapat dilakukan: Kirim kode." + reason.
  5. Button row: TombolBersyarat "Kirim kode" (flex 150 / max 340).
  6. 13 `tinta3`: "Satu orang satu akun, untuk semua jabatan. Nomor ponsel hanya dipakai untuk masuk."
  7. Text link "Tidak bisa menerima kode? Pemulihan akun": 14/700, min-height 44, text vertically centred and left-aligned; the target spans the column width (an `inline-flex` item stretched by the flex column), so a tap anywhere on that 44-high strip opens it.

  **Step `kode`**
  1. 14 `tinta2` sentence: "Kode 6 angka dikirim ke {hp} lewat {kanal}. Kode hanya berlaku sebentar dan sekali pakai." ({hp} as typed, plain digits in the sans face; {kanal} "WhatsApp" or "SMS").
  2. Field "Kode 6 angka", placeholder "••••••", no hint on screen (the board's hint "Di prototipe ini kode yang benar adalah 123456." goes to the panel).
  3. Refusal line (when shown): "Tidak dapat dilakukan: Masuk." + reason.
  4. Button row: TombolBersyarat "Masuk"; secondary button "Kirim ulang kode"; text button "Ganti nomor" (all three flex 150 / max 340: at phone width "Masuk" and "Kirim ulang kode" share line 1, "Ganti nomor" is alone on line 2).

  **Step `kenal`**
  1. Info card (GarisStatus `terpilih`): 1.5 `tinta` edge, radius 12, `permukaan`, padding 12 × 14, 14 `tinta`: bold "Nomor ini belum terhubung dengan Data jemaat." then " Isi nama dan tanggal lahir Anda; Penatua Kolom memastikan itu memang Anda."
  2. Field "Nama lengkap", placeholder "Nama sesuai surat baptis", no hint.
  3. Field "Tanggal lahir", placeholder "hh/bb/tttt", no hint on screen (the board's "Di prototipe ini: Novita Wenas, 14/03/1996." goes to the panel).
  4. Refusal line (when shown): "Tidak dapat dilakukan: Cari data saya." + reason.
  5. Button row: TombolBersyarat "Cari data saya".
  6. Result, one of (or none before the first search, and none again after any edit of name or date):
     - *Found* (`cari = 'ya'`): card; head row "Satu data cocok" + badge `garis` "Kolom 7"; under it 13 `tinta3` "Rinciannya tidak ditampilkan sampai Penatua Kolom 7 memverifikasi." Then a button row with primary button "Ajukan untuk diverifikasi".
     - *Not found* (`cari = 'tidak'`): dashed box: "Tidak ada data yang cocok" 700; 14 `tinta2` "Periksa ejaan dan tanggal lahir. Bila Anda belum terdaftar, ajukan permohonan menjadi anggota." Then a button row with secondary link-button "Ajukan permohonan menjadi anggota" (→ AlurAnggota).

  **Step `tunggu`**
  1. Status card: head row "Akun Anda" + badge showing `st`: "Menunggu verifikasi" (`garis` variant) or "Terhubung" (`laut` variant). Under it 14 `tinta2`: "Diajukan 16/11/2026 · menunggu Penatua Kolom 7" (waiting) or "Terhubung dengan data Novita Wenas · Keluarga Wenas-Lasut · Kolom 7." (linked).
  2. While waiting: 13 `tinta3` "Sampai diverifikasi, Anda hanya melihat Warta Jemaat dan pengumuman untuk semua anggota."; button row with secondary link-button "Buka Warta Jemaat" (the board's text button "Contoh: diverifikasi" beside it goes to the panel, so "Buka Warta Jemaat" is alone on its line: 340 wide, 48 tall).
  3. When linked: button row with primary link-button "Buka Beranda" and secondary link-button "Tambah email cadangan" (171 each on one line); then 13 `tinta3` "Email cadangan tidak wajib. Dipakai hanya bila nomor ponsel Anda hilang."
- **Components** TombolBersyarat ("Kirim kode", "Masuk", "Cari data saya"), Penolakan (refusal lines), ChipPilihan (Kirim kode lewat), Tombol (primary `tinta` "Ajukan untuk diverifikasi", "Buka Beranda"; secondary "Kirim ulang kode", "Ajukan permohonan menjadi anggota", "Buka Warta Jemaat", "Tambah email cadangan"; text "Ganti nomor"), LencanaStatus-shaped badges ("Kolom 7", "Menunggu verifikasi", "Terhubung"). Patterns: six-digit code entry, field with hint, info card, result card, dashed empty box.
- **Internal views and states** Initial state `{ k: null, a: { pesan: '', riw: [], v: 'nomor', hp: '', kanal: 'WhatsApp', kode: '', salah: 0, nama: '', lahir: '', cari: '', st: '' } }`. Views by `v`: `nomor` (initial), `kode` (after "Kirim kode"), `kenal` (after code 123456), `tunggu` (after "Ajukan untuk diverifikasi"). Inside `kenal`: no result / found / not found (`cari` '' · 'ya' · 'tidak'). Inside `tunggu`: waiting / linked (`st`). There is no way back from `kenal` or `tunggu` to an earlier step except leaving the board. `pesan` and `riw` exist in the state but nothing on this board shows them.
- **Tweaks** `keadaan` (options `Alur`, default `Alur`; no visible effect). Keadaan panel.
- **Interactions**
  - Nomor ponsel typing (`onHp`): phone number input rule (digits only, max 13).
  - "Kirim kode" condition, first unmet reason: (1) empty → "nomor ponsel belum diisi."; (2) not `^08\d{8,11}$` → "nomor ponsel tidak dikenali. Contoh: 081234567890.". The refusal line shows only while the field is not empty (so in practice only reason 2 is ever seen). Press when met (`kirim`) → `v = 'kode'`, `kode = ''`, `salah = 0`.
  - Pill "WhatsApp" / "SMS" (`pick`) → `kanal` = that name, `pesan = ''`. Changes the {kanal} word on the `kode` step.
  - Kode typing (`onKode`): digits only, max 6.
  - "Masuk" (`cek`): six-digit code rule (shared notes). Met and "123456" → `v = 'kenal'`, `pesan = ''`. Met and any other code → `salah + 1`, field emptied → refusal "Tidak dapat dilakukan: Masuk. kode tidak cocok. Sisa percobaan: 2." (then 1). Typing a digit hides that line again. After the third wrong code: "Tidak dapat dilakukan: Masuk. terlalu banyak percobaan. Minta kode baru." stays, and "Masuk" stays unmet even with six digits.
  - "Kirim ulang kode" (`ulang`, unconditional) → `kode = ''`, `salah = 0` (the refusal disappears, "Masuk" unmet); it also sets `pesan` to "Kode baru dikirim lewat {kanal}." which this board never displays.
  - "Ganti nomor" (`keNomor`) → `v = 'nomor'`, `pesan = ''`, `kode = ''`, `salah = 0`; the number and the chosen channel stay filled in.
  - Nama typing (`onNama`) → `nama` as typed, `cari = ''` (any result disappears). Tanggal lahir typing (`onLahir`) → `lahir` exactly as typed (no filtering, no automatic slashes; use a keyboard that offers "/", e.g. `TextInputType.datetime`), `cari = ''`.
  - "Cari data saya" condition, first unmet reason: (1) name blank after trimming → "nama belum diisi."; (2) date not exactly `dd/mm/yyyy` after trimming (two-digit day, two-digit month, four-digit year; month 1–12, day 1–31, no month-length check, so "31/02/1996" passes) → "tanggal lahir tidak dikenali. Contoh: 14/03/1996."; (3) date on or after 16/11/2026 → "tanggal lahir harus sebelum hari ini.". The refusal line shows while either field is not empty, tested untrimmed: a name of only spaces shows "Tidak dapat dilakukan: Cari data saya. nama belum diisi.". Press when met (`cariData`) → `cari = 'ya'` if the name contains "novita" (any case) and the date is 14/03/1996, else `cari = 'tidak'`.
  - "Ajukan untuk diverifikasi" (`ajukan`, unconditional) → `v = 'tunggu'`, `st = 'Menunggu verifikasi'`.
  - Panel device "Contoh: diverifikasi" (`verif`) → `st = 'Terhubung'`.
  - No timers.
- **Motion** none (see shared notes).
- **Links out**
  - Header back "Kembali ke Beranda" → `/BerandaJabatan`, up link (pop when BerandaJabatan is directly beneath, else `go`).
  - "Tidak bisa menerima kode? Pemulihan akun" → `/Pemulihan`, push.
  - "Ajukan permohonan menjadi anggota" → `/AlurAnggota`, push.
  - "Buka Warta Jemaat" → `/WartaArsip`, push.
  - "Buka Beranda" → `/BerandaJabatan`, go (sign-in finished).
  - "Tambah email cadangan" → `/AkunSaya`, push.
  - **Inbound** AkunSaya, KeadaanUmum, Masuk, PetaPlatform.
- **Mock data** Jemaat Karunia; today 16/11/2026; the matching record Novita Wenas, born 14/03/1996, Keluarga Wenas-Lasut, Kolom 7; the verifier "Penatua Kolom 7"; accepted code 123456; format examples 081234567890 and 14/03/1996.
- **Prototype-only** On the board: the hint "Di prototipe ini kode yang benar adalah 123456." (step `kode`), the hint "Di prototipe ini: Novita Wenas, 14/03/1996." (step `kenal`), the text button "Contoh: diverifikasi" (step `tunggu`, waiting). Keadaan panel, "Alat prototipe": the two hints as labelled notes (shown while their step is on screen), and a button "Contoh: diverifikasi" available only while `v = 'tunggu'` and `st = 'Menunggu verifikasi'`, calling `verif`. Plus the tweak `keadaan`, "Semua layar", the inbound links and the canvas title.
- **Acceptance checks**
  1. Open `/AlurMasuk` → "Masuk ke Palakat", empty "Nomor ponsel", "WhatsApp" pill filled `tinta`, "Kirim kode" in `garis` with `tinta2` text, no refusal line; pressing it does nothing.
  2. Type "0812" → refusal "Tidak dapat dilakukan: Kirim kode. nomor ponsel tidak dikenali. Contoh: 081234567890."; type "345678" (field "0812345678") → refusal gone, button `tinta`; the first press opens step `kode` with "Kode 6 angka dikirim ke 0812345678 lewat WhatsApp. Kode hanya berlaku sebentar dan sekali pakai."
  3. Typing "08-12 ab" in the number field shows "0812". Choosing "SMS" before "Kirim kode" makes the sentence end "lewat SMS. …".
  4. Type "111111", press "Masuk" → field empty, "Tidak dapat dilakukan: Masuk. kode tidak cocok. Sisa percobaan: 2."; two more wrong codes → "… terlalu banyak percobaan. Minta kode baru."; typing "123456" keeps "Masuk" grey and pressing it does nothing; "Kirim ulang kode" → refusal gone, field empty.
  5. Type "123456", press "Masuk" → step `kenal` with the `tinta`-edged card "Nomor ini belum terhubung dengan Data jemaat. …".
  6. Name "novita wenas", date "14/3/1996" → "Tidak dapat dilakukan: Cari data saya. tanggal lahir tidak dikenali. Contoh: 14/03/1996."; date "14/03/1996" → press "Cari data saya" → card "Satu data cocok" with badge "Kolom 7" and "Ajukan untuk diverifikasi". Adding a letter to the name removes the card.
  7. Date "16/11/2026" → "… tanggal lahir harus sebelum hari ini."; name "Budi", date "01/01/1990", press → dashed "Tidak ada data yang cocok"; "Ajukan permohonan menjadi anggota" opens `/AlurAnggota`.
  8. "Ajukan untuk diverifikasi" → card "Akun Anda" with outlined badge "Menunggu verifikasi", "Diajukan 16/11/2026 · menunggu Penatua Kolom 7", "Buka Warta Jemaat" (→ `/WartaArsip`); no "Contoh:" button on screen.
  9. Panel "Contoh: diverifikasi" → badge "Terhubung" in a `laut` field, "Terhubung dengan data Novita Wenas · Keluarga Wenas-Lasut · Kolom 7.", "Buka Beranda" (→ `/BerandaJabatan`) and "Tambah email cadangan" (→ `/AkunSaya`).
  10. From step `nomor` with a number typed, "Tidak bisa menerima kode? Pemulihan akun" opens `/Pemulihan`; Back returns to step `nomor` with the number still filled in. The header back arrow opens `/BerandaJabatan`.
- **Notes**
  - "kode belum lengkap." is never displayed: while the code is incomplete the button is grey with no sentence. This breaks TombolBersyarat ("the reason appears after the person starts filling in") and CONVENTIONS accessibility ("a disabled action always shows its reason"). The board wins on what is visible; on every conditional button of this file, give the first unmet reason as the button's Semantics hint whenever the refusal line is hidden, so a screen reader still hears why it does nothing. (Hiding the line while a form is still empty, e.g. "nomor ponsel belum diisi.", follows the rule.)
  - "Kirim ulang kode" sets a `pesan` that no element shows, so resending has no confirmation on screen. Keep the board (no banner); flag for design.
  - TombolBersyarat "met" is a `tinta` field here, not the `laut` primary of Tombol. Keep the board (all Alur boards do this).
  - The badge "Kolom 7" is a LencanaStatus shape used for a location, not a status. Keep.
  - The date input does not insert slashes and accepts impossible days such as 31/02. Keep the board's check exactly.
  - The {hp} in the code sentence is plain sans text, not mono. Keep.
  - The flow person (Novita Wenas) differs from the person shown on AkunSaya (Pnt. Hendrik Rumagit) that "Tambah email cadangan" opens; each screen keeps its own board's person (`mock-data.md`).
  - No 12 px text on this board. Off-token: none besides the shared radii.

### WebAlurMasuk — Web · Alur · Masuk dan menghubungkan akun

- **Source** `docs/design/handoff/canvas/boards/WebAlurMasuk.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Laptop page (preview 1440×1000, `expand: fill`) · interactive yes
- **Route** `/WebAlurMasuk`, no child routes (steps change in place) · **Widget** `WebAlurMasukScreen` in `lib/screens/p2/web_alur_masuk.dart`
- **Purpose** Sign-in and account linking on the laptop, for the desk posts (Bendahara Jemaat, Sekretaris Jemaat, Operator; Q26) and anyone who opens Palakat in a browser. Same journey step and decisions as AlurMasuk: P01 / D25, P02, P03, P06, Q31.
- **Shell** Platform web side nav; active item **Beranda** (index 0). Footer: bold "Belum masuk" (`tinta`) + " · Jemaat Karunia" (`tinta2`). All ten items are drawn and work even though the person is not signed in (see Notes).
- **Layout**
  1. Title block: breadcrumb "Beranda" (text link → WebBerandaJabatan); h1 "Alur · Masuk dan menghubungkan akun"; subtitle "Nomor ponsel, kode, lalu data jemaat yang diverifikasi Penatua".
  2. Content column: max-width **560**, column gap 16, left-aligned in the main column. It holds exactly the step blocks of AlurMasuk (`nomor`, `kode`, `kenal`, `tunggu`) with the same copy, order, controls and colours, at body size 15. Button rows are 560 wide: one button 340; two share the line (276 each); the three code-step buttons fit on one line (about 181 each: (560 − 2 × 8) / 3, all 52 tall).
- **Components** Same as AlurMasuk, plus the platform web side nav.
- **Internal views and states** Same as AlurMasuk (same initial state object and views).
- **Tweaks** `keadaan` (options `Alur`, default `Alur`; no visible effect). Keadaan panel.
- **Interactions** Same as AlurMasuk, handler for handler, with the same refusal sentences and the same code rule. Side-nav items and "Menu" / "Tutup menu" as the shared shell.
- **Motion** none.
- **Links out**
  - Breadcrumb "Beranda" → `/WebBerandaJabatan`, up link.
  - Side nav, all `go`: "Beranda" → `/WebBerandaJabatan`, "Keuangan" → `/WebBeranda`, "Dokumen gereja" → `/WebDokumenGereja`, "Pengumuman" → `/WebPengumuman`, "Warta Jemaat" → `/WebWartaArsip`, "Data jemaat" → `/WebDataAnggota`, "Ibadah dan kegiatan" → `/Ibadah`, "Panitia" → `/Panitia`, "Pemberitahuan" → `/WebKotakMasuk`, "Pengaturan" → `/WebPenugasan`.
  - "Tidak bisa menerima kode? Pemulihan akun" → `/WebPemulihan`, push.
  - "Ajukan permohonan menjadi anggota" → `/AlurAnggota` (the phone board; no web twin exists), push.
  - "Buka Warta Jemaat" → `/WebWartaArsip`, push.
  - "Buka Beranda" → `/WebBerandaJabatan`, go.
  - "Tambah email cadangan" → `/WebAkunSaya`, push.
  - **Inbound** PetaPlatform, WebAkunSaya, WebKeadaanUmum, WebMasuk.
- **Mock data** Same as AlurMasuk (Jemaat Karunia, Novita Wenas 14/03/1996, Keluarga Wenas-Lasut, Kolom 7, today 16/11/2026, code 123456).
- **Prototype-only** Same three devices as AlurMasuk (hint "Di prototipe ini kode yang benar adalah 123456.", hint "Di prototipe ini: Novita Wenas, 14/03/1996.", button "Contoh: diverifikasi"), moved to the Keadaan panel the same way.
- **Acceptance checks**
  1. `/WebAlurMasuk` at 1440 → side nav with "Beranda" filled `tinta`, footer "Belum masuk · Jemaat Karunia"; breadcrumb "Beranda"; h1 26/700; "Masuk ke Palakat" block in a column 560 wide.
  2. Type "081234567890" → "Kirim kode" turns `tinta`; press → "Kode 6 angka dikirim ke 081234567890 lewat WhatsApp. …"; "Masuk", "Kirim ulang kode" and "Ganti nomor" sit on one line.
  3. Three wrong codes → "Tidak dapat dilakukan: Masuk. terlalu banyak percobaan. Minta kode baru."; "Kirim ulang kode" clears it; "123456" → step `kenal`.
  4. "Novita Wenas" + "14/03/1996" → "Satu data cocok"; "Ajukan untuk diverifikasi" → "Menunggu verifikasi"; panel "Contoh: diverifikasi" → "Terhubung", "Buka Beranda" → `/WebBerandaJabatan`, "Tambah email cadangan" → `/WebAkunSaya`.
  5. Not found → "Ajukan permohonan menjadi anggota" opens the phone board `/AlurAnggota` (in the device frame); Back returns with the step and inputs kept.
  6. "Tidak bisa menerima kode? Pemulihan akun" → `/WebPemulihan`; "Buka Warta Jemaat" (waiting) → `/WebWartaArsip`.
  7. At 860 → nav collapses to the top bar with "Menu"; opening it shows the ten items and "Belum masuk · Jemaat Karunia"; the 560 column still fits without horizontal scroll. At 390 the column fills the width.
- **Notes**
  - A signed-out page shows the full signed-in side nav with "Beranda" active (WebMasuk and WebPemulihan use a signed-out nav instead). Keep the board; flag for design.
  - Same TombolBersyarat / refusal notes as AlurMasuk ("kode belum lengkap." never shown; `pesan` of "Kirim ulang kode" never shown).
  - "Ibadah dan kegiatan" and "Panitia" open phone boards (no laptop layout, Q26); they render in the device frame.

### AkunSaya — 59 · Alur · Akun saya

- **Source** `docs/design/handoff/canvas/boards/AkunSaya.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Phone 390×844 · interactive yes
- **Route** `/AkunSaya`, no child routes (the six views `akun`, `ganti`, `kodeBaru`, `email`, `kodeEmail`, `keluar` change in place under the fixed header) · **Widget** `AkunSayaScreen` in `lib/screens/p2/akun_saya.dart`
- **Purpose** Any signed-in person on the phone (here Pnt. Hendrik Rumagit, Penatua Kolom 7 and Ketua Komisi Diakonia): journey "Anyone, before a post applies", step 3. Shows P04 (phone number change: code to the new number; afterwards the old number no longer signs in and other devices are signed out; the app never says a number belongs to someone else), P06 (backup email optional, proven by a code to that email, used only for recovery), P07 (without an email the Operator recovers the account after the Penatua Kolom confirms identity), P05 and D28 (push: lock screen shows only module and type of work; push settings exist only on the phone), Q31 (one account for all posts; posts are assigned by the Pimpinan Jemaat yang berwenang, not changed here), and signing out of this device only.
- **Shell** Phone header with back (Semantics "Kembali ke Beranda" → BerandaJabatan). Title "Alur · Akun saya"; subtitle "Nomor ponsel, perangkat, pemberitahuan dorong, keluar". No tab bar.
- **Layout** (body column, gap 16; one view at a time)

  **View `akun`** (initial)
  1. Message banner (only while `pesan` is set).
  2. Identity card (card, column gap 6):
     - Name "Pnt. Hendrik Rumagit" 700 16.
     - Info rows: "Nomor ponsel" → mono 500 "0812 ···· 7890" (masked: first 4 digits, " ···· ", last 4); "Email cadangan" → "Belum diisi" (sans 600; once saved, the masked email, see Interactions); "Jabatan" → "Penatua Kolom 7 · Ketua Komisi Diakonia".
     - 13 `tinta3`: "Nomor ponsel dipakai untuk masuk. Email cadangan tidak wajib; dipakai hanya untuk pemulihan akun bila nomor hilang. Tanpa email, akun dipulihkan Operator setelah Penatua Kolom memastikan identitas Anda."
     - 13 `tinta3`: "Jabatan ditugaskan oleh Pimpinan Jemaat yang berwenang; tidak diubah dari sini."
     - Button row (wrap, gap 8), both secondary buttons at **intrinsic width** (no flex): "Ganti nomor ponsel"; "Tambah email cadangan" (reads "Ganti email cadangan" once an email is saved). At phone width they wrap onto two lines, left-aligned.
  3. Devices card (card, column gap 6): title "Perangkat yang masuk" 700; info row "Perangkat ini" → "sedang dipakai" (sans 600); then one row per other device (row, centred, gap 12): name 14 `tinta2` (flex 1, min-width 0, wraps) + text button "Keluarkan" (intrinsic width, top-aligned with `align-self: flex-start`). Seed: one device "Ponsel lain · Samsung A15 · terakhir 12/11/2026". With no other device only the "Perangkat ini" row remains (no empty-state text).
  4. Button row: secondary button "Keluar" (flex 150 / max 340, so 340 wide).
  5. Push card (card, column gap 6), title "Pemberitahuan dorong" 700, then by `izin`:
     - *Not yet asked* (`izin` '' or 'minta'): 14 `tinta2` "Supaya Anda tahu ada pekerjaan baru tanpa membuka aplikasi."; button row with primary button "Izinkan pemberitahuan" (flex 150 / max 340, so it fills the card's 316 inner width). (The board's second row with text buttons "Contoh: diizinkan" · "Contoh: ditolak", shown while `izin = 'minta'`, goes to the panel.)
     - *Refused* (`izin = 'tolak'`): dashed box with padding **12 × 14** (not 14 × 16), 14 px: bold `tinta` "Pemberitahuan dorong mati di pengaturan ponsel." + " " + `tinta2` "Pekerjaan tetap tampil di Beranda dan Pemberitahuan."
     - *Allowed* (`izin = 'ya'`): three module rows "Data jemaat", "Ibadah dan kegiatan", "Keuangan unit"; each row: centred, gap 12, 1 `garis` top rule, padding-top 8: name 15 `tinta` (flex 1) + a pill switch (Semantics switch, checked = on, label = the module name): min-height 44, padding 0 14, radius 999, 600/14, 1.5 edge; on: "Aktif" on a `tinta` field with `permukaan` text and `tinta` edge; off: "Mati" on `permukaan`, `tinta` text, `garisTegas` edge. All on at start. Then 13 `tinta3` "Yang tampil di layar kunci"; then the lock-screen sample (PratinjauLayarKunci): `tinta` field, radius 12, padding 10 × 14, 14 `permukaan`: "Palakat" 700 on line 1, "Data jemaat: 1 data menunggu verifikasi" on line 2; then 13 `tinta3` "Hanya modul dan jenis pekerjaannya. Tidak ada nama orang dan tidak ada jumlah uang di layar kunci."
  6. 13 `tinta3` (outside the card): "Bila pemberitahuan dorong gagal terkirim, pekerjaan di aplikasi tetap berjalan."
  7. Riwayat (only when there are rows).

  **View `ganti`**
  1. Card: info row "Nomor sekarang" → mono 500 masked number; 13 `tinta3` "Kode dikirim ke nomor yang baru, supaya terbukti nomor itu milik Anda."
  2. Field "Nomor ponsel baru", placeholder "08…", hint "Contoh: 081298765432" (format hint, keep).
  3. Refusal line (when shown): "Tidak dapat dilakukan: Kirim kode ke nomor baru." + reason.
  4. Button row: TombolBersyarat "Kirim kode ke nomor baru"; text button "Batalkan" (both flex 150 / max 340; one line, 171 each).

  **View `kodeBaru`**
  1. 14 `tinta2`: "Kode 6 angka dikirim ke {hpBaru}. Kode hanya berlaku sebentar dan sekali pakai." ({hpBaru} unmasked, plain sans).
  2. Field "Kode 6 angka", placeholder "••••••", no hint on screen (123456 hint goes to the panel).
  3. Refusal line (when shown): "Tidak dapat dilakukan: Ganti nomor ponsel." + reason.
  4. 13 `tinta3`: "Setelah diganti, nomor lama tidak dapat dipakai untuk masuk dan perangkat lain dikeluarkan."
  5. Button row: TombolBersyarat "Ganti nomor ponsel"; text button "Batalkan". (No "Kirim ulang kode" here.)

  **View `email`**
  1. Card: info row "Email cadangan sekarang" → masked email or "Belum diisi" (sans 600); 13 `tinta3` "Kode dikirim ke email itu, supaya terbukti email itu milik Anda."
  2. Field "Email cadangan", placeholder "nama@contoh.id", hint "Tidak wajib. Dipakai hanya untuk pemulihan akun." (email keyboard).
  3. Refusal line (when shown): "Tidak dapat dilakukan: Kirim kode ke email." + reason.
  4. Button row: TombolBersyarat "Kirim kode ke email"; text button "Batalkan".

  **View `kodeEmail`**
  1. 14 `tinta2`: "Kode 6 angka dikirim ke {emBaru}. Kode hanya berlaku sebentar dan sekali pakai."
  2. Field "Kode 6 angka", placeholder "••••••", no hint on screen.
  3. Refusal line (when shown): "Tidak dapat dilakukan: Simpan email cadangan." + reason.
  4. Button row: TombolBersyarat "Simpan email cadangan"; text button "Batalkan".

  **View `keluar`**
  1. Card: "Keluar dari perangkat ini?" 18/700 (`judulLayar`); 14 `tinta2` "Isian yang belum tersimpan di layar akan hilang. Data yang sudah tersimpan tidak berubah."
  2. Button row: primary link-button "Keluar" (→ AlurMasuk); text button "Batal".
- **Components** TombolBersyarat (four conditional buttons), Penolakan, Tombol (secondary "Ganti nomor ponsel", "Tambah/Ganti email cadangan", "Keluar"; primary `tinta` "Izinkan pemberitahuan" and link "Keluar"; text "Keluarkan", "Batalkan", "Batal"), PratinjauLayarKunci (lock-screen sample), RiwayatAlur (Riwayat), message banner. Not a component: the module pill switch (ChipPilihan look with switch semantics; it is not Sakelar, which needs an effective-month sentence), info rows, the six-digit code entry pattern.
- **Internal views and states** Initial state `{ k: null, a: { pesan: '', riw: [], v: 'akun', izin: '', mati: [], dev: ['Ponsel lain · Samsung A15 · terakhir 12/11/2026'], hp: '', hpBaru: '', kode: '', salah: 0, em: null, emBaru: '' } }`. Derived: current number = `hp` or "081234567890"; current email = `em` if not null, else '' (none). Views by `v`: `akun`, `ganti`, `kodeBaru`, `email`, `kodeEmail`, `keluar`. Inside `akun`: banner on/off, device list (1 or 0 rows), push state `izin` '' / 'minta' / 'tolak' / 'ya', module switches (`mati` = modules turned off), email label "Tambah" / "Ganti", Riwayat on/off.
- **Tweaks** `keadaan` (options `Alur`, default `Alur`; no visible effect). Keadaan panel.
- **Interactions**
  - "Ganti nomor ponsel" in the identity card (`keGanti`) → `v = 'ganti'`, `pesan = ''`, `hpBaru = ''`, `kode = ''`, `salah = 0`.
  - Nomor ponsel baru typing (`onHpBaru`): phone number input rule (digits only, max 13).
  - "Kirim kode ke nomor baru" condition, first unmet reason: (1) empty → "nomor baru belum diisi."; (2) not `^08\d{8,11}$` → "nomor ponsel tidak dikenali. Contoh: 081298765432."; (3) equal to the current number → "nomor baru sama dengan nomor sekarang.". Refusal line shows while the field is not empty. Press when met (`kirim`) → `v = 'kodeBaru'`, `kode = ''`, `salah = 0`.
  - Kode typing (`onKode`, both code views): digits only, max 6.
  - "Ganti nomor ponsel" in `kodeBaru` (`gantiNomor`): six-digit code rule. "123456" → `v = 'akun'`, `hp = hpBaru`, `dev = []` (other devices gone), `pesan` = "Nomor ponsel diganti. Perangkat lain dikeluarkan dan harus masuk lagi dengan nomor baru.", Riwayat gains "16/11/2026 · Nomor ponsel diganti menjadi {masked new number} · oleh Pnt. Hendrik Rumagit". Wrong code → `salah + 1`, field emptied. After three wrong codes only "Batalkan" helps (then "Ganti nomor ponsel" again starts fresh).
  - "Tambah email cadangan" / "Ganti email cadangan" (`keEmail`) → `v = 'email'`, `pesan = ''`, `emBaru = ''`, `kode = ''`, `salah = 0`.
  - Email typing (`onEmBaru`): stored exactly as typed (no filtering).
  - "Kirim kode ke email" condition, first unmet reason: (1) empty → "email belum diisi."; (2) not matching `^[^@\s]+@[^@\s]+\.[^@\s]+$` (so any space fails) → "email tidak dikenali. Contoh: nama@contoh.id."; (3) exactly equal (case-sensitive string compare) to the current email → "email itu sudah menjadi email cadangan Anda.". Refusal line shows while the field is not empty. Press when met (`kirimEm`) → `v = 'kodeEmail'`, `kode = ''`, `salah = 0`.
  - "Simpan email cadangan" (`simpanEm`): six-digit code rule. "123456" → `v = 'akun'`, `em` = typed email trimmed, `pesan` = "Email cadangan disimpan.", Riwayat gains "16/11/2026 · Email cadangan ditambahkan · oleh Pnt. Hendrik Rumagit" ("diganti" instead of "ditambahkan" when an email existed before). The card then shows the masked email: first character + "···" + everything from "@" (e.g. "hendrik@contoh.id" → "h···@contoh.id"), and the button reads "Ganti email cadangan". Wrong code → `salah + 1`, field emptied.
  - "Keluarkan" on a device row → that row removed, `pesan` = "Perangkat itu dikeluarkan. Ia harus masuk lagi dengan kode baru." (no Riwayat row).
  - "Keluar" (secondary, in `akun`; `keKeluar`) → `v = 'keluar'`, `pesan = ''`.
  - "Batalkan" (in `ganti`, `kodeBaru`, `email`, `kodeEmail`) and "Batal" (in `keluar`) (`pulang`) → `v = 'akun'`, `pesan = ''`. Typed values are not cleared until the next `keGanti` / `keEmail`.
  - "Izinkan pemberitahuan" (`minta`) → `izin = 'minta'`. The screen does not change (the board only adds its "Contoh:" buttons, which live in the panel); the panel's two answers become available.
  - Panel "Contoh: diizinkan" (`beri`) → `izin = 'ya'`. Panel "Contoh: ditolak" (`tolak`) → `izin = 'tolak'`. There is no way back from either.
  - Module pill (`balik`) → toggles that module in `mati`: "Aktif" ↔ "Mati". The lock-screen sample does not change.
  - `pesan` is cleared only by view changes (`ke…`, `pulang`); `minta`, the module pills and the panel answers leave it as it is. A new message replaces the old one.
  - No timers.
- **Motion** none.
- **Links out**
  - Header back "Kembali ke Beranda" → `/BerandaJabatan`, up link.
  - "Keluar" (link-button in view `keluar`) → `/AlurMasuk`, go (the session ends; the stack is replaced).
  - **Inbound** AlurMasuk, BerandaJabatan, Keluar, Pemulihan, PetaPlatform.
- **Mock data** Pnt. Hendrik Rumagit; "Penatua Kolom 7 · Ketua Komisi Diakonia"; phone 081234567890 shown "0812 ···· 7890"; backup email none ("Belum diisi"); other device "Ponsel lain · Samsung A15 · terakhir 12/11/2026"; modules "Data jemaat", "Ibadah dan kegiatan", "Keuangan unit"; lock-screen line "Data jemaat: 1 data menunggu verifikasi"; today 16/11/2026; accepted code 123456; format example 081298765432; email placeholder nama@contoh.id.
- **Prototype-only** On the board: hint "Di prototipe ini kode yang benar adalah 123456." (views `kodeBaru` and `kodeEmail`); text buttons "Contoh: diizinkan" and "Contoh: ditolak" (push card while `izin = 'minta'`). Keadaan panel, "Alat prototipe": the hint as a labelled note while a code view is shown; buttons "Contoh: diizinkan" (`beri`) and "Contoh: ditolak" (`tolak`), available only in view `akun` while `izin = 'minta'` (on the board they sit inside the `akun` view's push card). Plus the tweak `keadaan`, "Semua layar", inbound links, canvas title.
- **Acceptance checks**
  1. Open `/AkunSaya` → card "Pnt. Hendrik Rumagit", "Nomor ponsel 0812 ···· 7890" (mono), "Email cadangan Belum diisi", "Jabatan Penatua Kolom 7 · Ketua Komisi Diakonia"; buttons "Ganti nomor ponsel" and "Tambah email cadangan"; device row "Ponsel lain · Samsung A15 · terakhir 12/11/2026" with "Keluarkan"; no banner, no Riwayat.
  2. "Keluarkan" → the row disappears; banner "Perangkat itu dikeluarkan. Ia harus masuk lagi dengan kode baru."; only "Perangkat ini · sedang dipakai" remains.
  3. "Ganti nomor ponsel" → "Nomor sekarang 0812 ···· 7890"; type "081234567890" → "Tidak dapat dilakukan: Kirim kode ke nomor baru. nomor baru sama dengan nomor sekarang."; type "081298765432" → button `tinta`; first press → "Kode 6 angka dikirim ke 081298765432. Kode hanya berlaku sebentar dan sekali pakai."
  4. Wrong code three times → "Tidak dapat dilakukan: Ganti nomor ponsel. terlalu banyak percobaan. Minta kode baru."; "Batalkan" → view `akun`.
  5. Correct path with "123456" → banner "Nomor ponsel diganti. Perangkat lain dikeluarkan dan harus masuk lagi dengan nomor baru.", number "0812 ···· 5432", no other device, Riwayat "16/11/2026 · Nomor ponsel diganti menjadi 0812 ···· 5432 · oleh Pnt. Hendrik Rumagit".
  6. "Tambah email cadangan" → "Email cadangan sekarang Belum diisi"; type "hendrik" → "… email tidak dikenali. Contoh: nama@contoh.id."; "hendrik@contoh.id" → "Kirim kode ke email" → "123456" → "Simpan email cadangan" → banner "Email cadangan disimpan.", row "h···@contoh.id", button "Ganti email cadangan", Riwayat top row "16/11/2026 · Email cadangan ditambahkan · oleh Pnt. Hendrik Rumagit".
  7. "Izinkan pemberitahuan" → screen unchanged; panel offers "Contoh: diizinkan" / "Contoh: ditolak". "Contoh: diizinkan" → three rows with "Aktif" pills, "Yang tampil di layar kunci" and the dark sample "Palakat / Data jemaat: 1 data menunggu verifikasi"; tapping "Keuangan unit" shows "Mati" outlined. Fresh board, "Izinkan pemberitahuan" then panel "Contoh: ditolak" → dashed "Pemberitahuan dorong mati di pengaturan ponsel. Pekerjaan tetap tampil di Beranda dan Pemberitahuan."
  8. "Keluar" → view "Keluar dari perangkat ini?"; "Batal" → back to `akun`; "Keluar" again then the `tinta` "Keluar" → `/AlurMasuk` at step `nomor`.
  9. Header back arrow → `/BerandaJabatan`. No "Contoh:" button and no "123456" text appear on the screen in any view.
- **Notes**
  - Same code-entry gap as AlurMasuk: "kode belum lengkap." is never displayed; put it in the button's Semantics hint.
  - Riwayat rows omit the post used ("oleh Pnt. Hendrik Rumagit", not "· Penatua Kolom 7"), against RiwayatAlur "each row has … the post used". Keep the board.
  - The two card buttons have no flex and wrap at intrinsic width; "Keluar" below uses flex. Keep both as drawn.
  - The lock-screen sample stays the same when "Data jemaat" is switched "Mati". Keep.
  - The refused-push dashed box uses padding 12 × 14, unlike the 14 × 16 dashed boxes elsewhere. Copy it.
  - Mono numbers are weight 500 inside a 600 value. No 12 px text on this board.

### WebAkunSaya — Web · Alur · Akun saya

- **Source** `docs/design/handoff/canvas/boards/WebAkunSaya.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Laptop page (preview 1440×1000, `expand: fill`) · interactive yes
- **Route** `/WebAkunSaya`, no child routes (views change in place) · **Widget** `WebAkunSayaScreen` in `lib/screens/p2/web_akun_saya.dart`
- **Purpose** Akun saya on the laptop for a desk post, here Olvie Pangemanan, Sekretaris Jemaat. Same as AkunSaya except push: P05 "push settings exist only on the phone", so the laptop only says where they are set. P04, P06, P07, Q31, sign-out.
- **Shell** Platform web side nav; active item **Beranda** (index 0). Footer: bold "Olvie Pangemanan" + " · Sekretaris Jemaat".
- **Layout**
  1. Title block: breadcrumb "Beranda" (→ WebBerandaJabatan); h1 "Alur · Akun saya"; subtitle "Nomor ponsel, perangkat, pemberitahuan dorong, keluar".
  2. Content column: max-width **1120**, column gap 16. One view at a time:

  **View `akun`**
  1. Message banner (only while `pesan` is set), full column width.
  2. Two-column row: wrap, gap 20 (between lines) × 28 (between columns), top-aligned.
     - Left column (`flex 1.3 1 420`, min-width 0, column gap **12**): the identity card, the devices card and the "Keluar" button row of AkunSaya (items 2–4), with Olvie's data: name "Olvie Pangemanan"; "Nomor ponsel" → mono 500 "0813 ···· 2204"; "Email cadangan" → "o···@contoh.id"; "Jabatan" → "Sekretaris Jemaat"; the same two 13 `tinta3` notes; buttons "Ganti nomor ponsel" and "Ganti email cadangan" (intrinsic width; on one line at 1440); device row "Ponsel lain · Samsung A15 · terakhir 12/11/2026" + "Keluarkan"; "Keluar" secondary (340 wide).
     - Right column (`flex 1 1 340`, min-width 0, column gap 12): card with title "Pemberitahuan dorong" 700 and 14 `tinta2` "Diatur dari aplikasi di ponsel Anda. Di laptop, pekerjaan baru tampil di Beranda dan Pemberitahuan." (no buttons, no switches, no lock-screen sample); then Riwayat (h2 + card) when there are rows.
     - At 1440 the columns are about 608 and 484 wide. They stay side by side while the content column is at least 788 (420 + 28 + 340); narrower, the right column wraps under the left. In window widths: side by side from about 1073 up and at 839–860 (nav collapsed, so true at the 860 check); stacked at 861–1072 (the expanded nav takes the room) and below 839.
     - The phone's sentence "Bila pemberitahuan dorong gagal terkirim, …" is not on this board.

  **Views `ganti`, `kodeBaru`, `email`, `kodeEmail`, `keluar`**: exactly as AkunSaya, at body size 15, one column directly in the 1120 content column (cards and inputs stretch to the column width; button rows keep max 340 per button).
- **Components** As AkunSaya without PratinjauLayarKunci and the module switches, plus the platform web side nav.
- **Internal views and states** Same initial state object as AkunSaya. Derived: current number = `hp` or "081355512204"; current email = `em` if not null, else "olvie@contoh.id". `izin` and `mati` exist but nothing on this board shows or changes them.
- **Tweaks** `keadaan` (options `Alur`, default `Alur`; no visible effect). Keadaan panel.
- **Interactions** Same handlers, conditions, refusal sentences and messages as AkunSaya, with these differences: the "same number" check compares with 081355512204; the "same email" check compares with olvie@contoh.id, so typing "olvie@contoh.id" gives "email itu sudah menjadi email cadangan Anda."; Riwayat rows end "· oleh Olvie Pangemanan"; saving an email writes "Email cadangan diganti" (an email exists from the start). No push handlers are reachable. Side nav and "Menu" toggle as the shared shell.
- **Motion** none.
- **Links out**
  - Breadcrumb "Beranda" → `/WebBerandaJabatan`, up link.
  - Side nav, all `go`, the ten items as in the shared notes.
  - "Keluar" (link-button in view `keluar`) → `/WebAlurMasuk`, go.
  - **Inbound** PetaPlatform, WebAlurMasuk, WebBerandaJabatan, WebKeluar, WebPemulihan.
- **Mock data** Olvie Pangemanan, Sekretaris Jemaat; phone 081355512204 shown "0813 ···· 2204"; backup email olvie@contoh.id shown "o···@contoh.id"; device "Ponsel lain · Samsung A15 · terakhir 12/11/2026"; today 16/11/2026; code 123456.
- **Prototype-only** On the board: the hint "Di prototipe ini kode yang benar adalah 123456." in `kodeBaru` and `kodeEmail` → Keadaan panel note, as AkunSaya. No "Contoh:" buttons on this board. Plus the tweak `keadaan`, "Semua layar", inbound links, canvas title.
- **Acceptance checks**
  1. `/WebAkunSaya` at 1440 → nav "Beranda" active, footer "Olvie Pangemanan · Sekretaris Jemaat"; two columns: left identity card ("0813 ···· 2204", "o···@contoh.id", "Sekretaris Jemaat", "Ganti email cadangan"), devices card, "Keluar"; right "Pemberitahuan dorong" card with "Diatur dari aplikasi di ponsel Anda. …".
  2. "Ganti email cadangan" → "Email cadangan sekarang o···@contoh.id"; type "olvie@contoh.id" → "Tidak dapat dilakukan: Kirim kode ke email. email itu sudah menjadi email cadangan Anda."
  3. Type "olvie.p@contoh.id" → "Kirim kode ke email" → "123456" → "Simpan email cadangan" → banner "Email cadangan disimpan." above both columns; Riwayat appears in the right column: "16/11/2026 · Email cadangan diganti · oleh Olvie Pangemanan".
  4. "Ganti nomor ponsel" with "081355512204" → "… nomor baru sama dengan nomor sekarang."; with "081298765432" and code "123456" → "0812 ···· 5432", device row gone, Riwayat "16/11/2026 · Nomor ponsel diganti menjadi 0812 ···· 5432 · oleh Olvie Pangemanan" on top.
  5. "Keluar" → "Keluar dari perangkat ini?"; "Keluar" → `/WebAlurMasuk`.
  6. At 860 → "Menu" top bar; the two columns still side by side. At 390 → the right column sits under the left, no horizontal scroll.
  7. Breadcrumb "Beranda" and side-nav items open their routes; Back returns to this page.
- **Notes**
  - The side nav marks "Beranda" active on an account page; there is no account item in the nav. Keep the board.
  - Changing the email to "olvie.p@contoh.id" shows the same mask "o···@contoh.id"; the change is visible only in Riwayat and the banner. Keep.
  - Form views stretch inputs to the 1120 column (about 1120 px wide at 1440). Keep the board; flag for design.
  - Same code-entry and Riwayat notes as AkunSaya. No 12 px text.

### AlurPulihkan — 60 · Alur · Memulihkan akun anggota

- **Source** `docs/design/handoff/canvas/boards/AlurPulihkan.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Phone 390×844 · interactive yes
- **Route** `/AlurPulihkan`, no child routes (one view `utama`; its content depends on the viewing actor and the request state) · **Widget** `AlurPulihkanScreen` in `lib/screens/p2/alur_pulihkan.dart`
- **Purpose** Two-person recovery of a member's account when the member lost their number and has no backup email. Journeys: Operator step 3 ("Cari orang", "Alur · Memulihkan akun anggota") and Penatua Kolom step 4 (confirming identity). The Operator (Yanti Sumual) finds the person and enters the new number the person brought to the church office; the Penatua Kolom 7 (Pnt. Hendrik Rumagit) confirms or rejects. Shows P07 (no one recovers alone; the Operator cannot recover their own account; Bendahara Jemaat goes through the Petugas verifikasi with BPMJ), P04 (old devices signed out, old number valid until confirmed), the "Two-person step" pattern and RiwayatAlur.
- **Shell** Phone header with back (Semantics "Kembali ke Cari orang" → CariOrang). Title "Alur · Memulihkan akun anggota"; subtitle "Untuk orang yang kehilangan nomor ponselnya dan tidak punya email cadangan". No tab bar. The header does not change with the viewing actor.
- **Layout** (body column, gap 16)
  1. (Board: "Dilihat sebagai" label 14 `tinta2` with pills "Operator" · "Penatua Kolom 7". Not on screen; it goes to the panel.)
  2. Message banner (only while `pesan` is set).
  3. **Operator, no request yet** (`akt = 'Operator'` and `st` empty):
     - Field "Nama orangnya", placeholder "Nama lengkap", no hint on screen (the board's "Di prototipe ini: Novita Wenas." goes to the panel).
     - Button row: secondary button "Cari orang" (flex 150 / max 340).
     - Result, when searched: *found* → card: head row "Novita Wenas" + badge `laut` "Aktif"; info rows "Kolom" → "Kolom 7"; "Nomor lama" → mono 500 "0812 ···· 7741"; "Email cadangan" → "Belum diisi". *Not found* → dashed box with only "Tidak ada orang dengan nama itu" 700.
     - Field "Nomor ponsel baru", placeholder "08…", hint "Nomor yang dibawa orangnya ke kantor gereja."
     - Refusal line (when shown): "Tidak dapat dilakukan: Minta kepastian Penatua Kolom." + reason.
     - Button row: TombolBersyarat "Minta kepastian Penatua Kolom".
     - 13 `tinta3`: "Operator tidak memulihkan akun seorang diri, dan tidak memulihkan akunnya sendiri. Bendahara Jemaat dipulihkan lewat Petugas verifikasi bersama BPMJ."
  4. **Operator, request made** (`akt = 'Operator'` and `st` set): status card: head row "Pemulihan akun · Novita Wenas" + badge with `st`: "Menunggu Penatua Kolom 7" (`garis` variant), "Dipulihkan" (`laut`), "Tidak dipastikan" (`bata`). Under it 14 `tinta2`:
     - waiting: "Diminta 16/11/2026 · menunggu Pnt. Hendrik Rumagit, Penatua Kolom 7. Nomor lama masih berlaku sampai dipastikan."
     - Dipulihkan: "Nomor baru dipasang 16/11/2026. Semua perangkat lama dikeluarkan. Novita Wenas masuk dengan kode ke nomor barunya."
     - Tidak dipastikan: "Penatua Kolom 7 tidak memastikan identitasnya. Nomor lama tetap berlaku dan tidak ada yang berubah."
     The form is gone; there is no new-request button.
  5. **Penatua Kolom 7, request waiting** (`akt = 'Penatua Kolom 7'` and `st = 'Menunggu Penatua Kolom 7'`):
     - Card: head row "Pemulihan akun · Novita Wenas" + badge `garis` "Menunggu Anda"; info rows "Diminta oleh" → "Yanti Sumual, Operator"; "Nomor ponsel baru" → mono, weight **600** (no 500 here) masked new number.
     - Checkbox row: row, top-aligned, gap 12, min-height 44, 14 `tinta`, whole row is the target: checkbox 24 × 24, margin-top 2, checked fill `laut`; text "Saya sudah bertemu atau berbicara langsung dengan orang ini, dan nomor baru itu memang miliknya."
     - Refusal line while unchecked: "Tidak dapat dilakukan: Pastikan identitas. centang dulu bahwa Anda sudah memastikan orangnya." (shown from the start, before any input).
     - Button row: TombolBersyarat "Pastikan identitas"; secondary button "Bukan orangnya" (one line, 171 each).
  6. **Penatua Kolom 7, nothing waiting** (any other `st`): dashed box with only "Tidak ada pemulihan akun yang menunggu Anda" 700.
  7. Riwayat (only when there are rows; shown to both actors).
- **Components** TombolBersyarat ("Minta kepastian Penatua Kolom", "Pastikan identitas"), Penolakan, Tombol (secondary "Cari orang", "Bukan orangnya"), LencanaStatus-shaped badges ("Aktif", "Menunggu Anda", "Menunggu Penatua Kolom 7", "Dipulihkan", "Tidak dipastikan"), RiwayatAlur, message banner. Pattern: two-person step (requester sees "menunggu {jabatan}"; nothing changes until the second person acts); checkbox confirmation row.
- **Internal views and states** Initial state `{ k: null, a: { pesan: '', riw: [], v: 'utama', akt: 'Operator', nama: '', cari: '', hp: '', st: '', kenal: false, alasan: '' } }` (`alasan` unused). One view `utama`; four content branches by (`akt`, `st`) as in Layout 3–6; inside branch 3, search result none / found / not found (`cari`). State is shared by both actors: switching the actor keeps every field, `st` and Riwayat.
- **Tweaks** `keadaan` (options `Alur`, default `Alur`; no visible effect). Keadaan panel.
- **Interactions**
  - Actor (panel "Dilihat sebagai", `pick`) → `akt` = "Operator" or "Penatua Kolom 7", `pesan = ''`.
  - Nama typing (`onNama`) → `nama` as typed, `cari = ''` (the result disappears and the person must be searched again).
  - "Cari orang" (`cariOrang`, unconditional) → `cari = 'ya'` if the name contains "novita" (any case), else `cari = 'tidak'` (an empty name gives "Tidak ada orang dengan nama itu").
  - Nomor ponsel baru typing (`onHp`): phone number input rule (digits only, max 13).
  - "Minta kepastian Penatua Kolom" condition, first unmet reason: (1) person not found (`cari` ≠ 'ya') → "orangnya belum ditemukan."; (2) number empty → "nomor ponsel baru belum diisi."; (3) not `^08\d{8,11}$` → "nomor ponsel tidak dikenali. Contoh: 081298765432.". Refusal line shows while the name or the number is not empty. Press when met (`minta`) → `st = 'Menunggu Penatua Kolom 7'`, `pesan` = "Penatua Kolom 7 diberi tahu lewat Pemberitahuan.", Riwayat gains "16/11/2026 · Pemulihan akun Novita Wenas diminta · nomor baru {masked} · Yanti Sumual, Operator".
  - Checkbox (`onKenal`) → toggles `kenal`.
  - "Pastikan identitas" condition: `kenal` checked, else "centang dulu bahwa Anda sudah memastikan orangnya." (always shown while unchecked). Press when met (`pasti`) → `st = 'Dipulihkan'`, `kenal = false`, `pesan` = "Identitas dipastikan. Nomor baru dipasang.", Riwayat gains "16/11/2026 · Identitas Novita Wenas dipastikan · akun dipulihkan · Pnt. Hendrik Rumagit, Penatua Kolom 7". The Penatua then sees "Tidak ada pemulihan akun yang menunggu Anda".
  - "Bukan orangnya" (`tolak`, unconditional, works without the checkbox) → `st = 'Tidak dipastikan'`, `kenal = false`, `pesan` = "Pemulihan tidak dijalankan.", Riwayat gains "16/11/2026 · Identitas tidak dipastikan · pemulihan akun Novita Wenas tidak dijalankan · Pnt. Hendrik Rumagit, Penatua Kolom 7".
  - Masked number: first 4 digits + " ···· " + last 4 (081298765432 → "0812 ···· 5432"). The Penatua card falls back to 081298765432 when no number was typed (not reachable in practice).
  - No timers.
- **Motion** none.
- **Links out**
  - Header back "Kembali ke Cari orang" → `/CariOrang`, up link.
  - **Inbound** CariOrang, PetaPlatform.
- **Mock data** Novita Wenas (status "Aktif", Kolom 7, old number "0812 ···· 7741", backup email "Belum diisi"); Yanti Sumual, Operator; Pnt. Hendrik Rumagit, Penatua Kolom 7; today 16/11/2026; example number 081298765432.
- **Prototype-only** On the board: "Dilihat sebagai" pills (Operator · Penatua Kolom 7) and the hint "Di prototipe ini: Novita Wenas.". Keadaan panel, "Alat prototipe": "Dilihat sebagai" (KitAlur `DilihatSebagai`) as a two-option choice (default Operator) calling `pick`, and the hint as a labelled note while the Operator form is shown. Plus the tweak `keadaan`, "Semua layar", inbound links, canvas title.
- **Acceptance checks**
  1. Open `/AlurPulihkan` → no "Dilihat sebagai" pills on screen; the Operator form with empty "Nama orangnya", "Cari orang", empty "Nomor ponsel baru", grey "Minta kepastian Penatua Kolom", no refusal line; panel shows "Dilihat sebagai: Operator".
  2. Type "Nov" → "Tidak dapat dilakukan: Minta kepastian Penatua Kolom. orangnya belum ditemukan."; "Cari orang" → dashed "Tidak ada orang dengan nama itu". Type "Novita", "Cari orang" → card "Novita Wenas" with `laut` badge "Aktif", "Kolom 7", "0812 ···· 7741", "Belum diisi"; refusal now "… nomor ponsel baru belum diisi."
  3. Number "0812" → "… nomor ponsel tidak dikenali. Contoh: 081298765432."; "081298765432" → button `tinta`; press → form replaced by "Pemulihan akun · Novita Wenas" with outlined badge "Menunggu Penatua Kolom 7" and "Diminta 16/11/2026 · menunggu Pnt. Hendrik Rumagit, Penatua Kolom 7. …"; banner "Penatua Kolom 7 diberi tahu lewat Pemberitahuan."; Riwayat "16/11/2026 · Pemulihan akun Novita Wenas diminta · nomor baru 0812 ···· 5432 · Yanti Sumual, Operator".
  4. Panel "Penatua Kolom 7" → banner gone; card "Menunggu Anda", "Diminta oleh Yanti Sumual, Operator", "Nomor ponsel baru 0812 ···· 5432"; refusal "Tidak dapat dilakukan: Pastikan identitas. centang dulu bahwa Anda sudah memastikan orangnya."; "Pastikan identitas" grey and does nothing.
  5. Tick the checkbox (tapping the sentence works too) → refusal gone, button `tinta`; press → dashed "Tidak ada pemulihan akun yang menunggu Anda", banner "Identitas dipastikan. Nomor baru dipasang.", Riwayat two rows, the "dipastikan" row on top.
  6. Panel "Operator" → status badge "Dipulihkan" in a `laut` field and "Nomor baru dipasang 16/11/2026. Semua perangkat lama dikeluarkan. Novita Wenas masuk dengan kode ke nomor barunya."
  7. Fresh board, request made, as Penatua "Bukan orangnya" without ticking → banner "Pemulihan tidak dijalankan."; as Operator the badge reads "Tidak dipastikan" in `bata` outline with "Penatua Kolom 7 tidak memastikan identitasnya. Nomor lama tetap berlaku dan tidak ada yang berubah."
  8. Fresh board, panel "Penatua Kolom 7" first → dashed "Tidak ada pemulihan akun yang menunggu Anda", no Riwayat.
  9. Header back arrow → `/CariOrang`.
- **Notes**
  - The Penatua's refusal line shows before any input, which breaks TombolBersyarat "an empty form does not open with a refusal". Keep the board (it is a checkbox, and the line explains the grey button).
  - After a request the Operator has no way to start another one on this board. Keep.
  - The checkbox row's text is `tinta` 14 (not the `tinta2` field label colour). Draw the 24 × 24 checkbox as `KotakCentang` (`components.md`): radius 4, unchecked 1.5 `garisTegas` on `permukaan`, checked `laut` fill with the `diLaut` tick (the board's native `accent-color: laut`).
  - "Nomor ponsel baru" in the Penatua card is mono at weight 600, unlike the 500 mono elsewhere. Copy the board.
  - No 12 px text on this board.

### WebAlurPulihkan — Web · Alur · Memulihkan akun anggota

- **Source** `docs/design/handoff/canvas/boards/WebAlurPulihkan.dc.html` · page Putaran 2 · Kerangka platform (`p2`) · form Laptop page (preview 1440×1000, `expand: fill`) · interactive yes
- **Route** `/WebAlurPulihkan`, no child routes · **Widget** `WebAlurPulihkanScreen` in `lib/screens/p2/web_alur_pulihkan.dart`
- **Purpose** The same recovery on the laptop, where the Operator works (Q26). Same decisions as AlurPulihkan: P07, P04, two-person step.
- **Shell** Platform web side nav; active item **Data jemaat** (index 5). Footer: bold "Yanti Sumual" + " · Operator" (stays the same when the panel views the board as the Penatua).
- **Layout**
  1. Title block: breadcrumb "Cari orang" (→ WebCariOrang); h1 "Alur · Memulihkan akun anggota"; subtitle "Untuk orang yang kehilangan nomor ponselnya dan tidak punya email cadangan".
  2. Content column: max-width **1120**, column gap 16. Same branches and order as AlurPulihkan (pills → panel; banner; one branch; Riwayat), at body size 15, with one difference: the Operator form is a two-column row (wrap, gap 20 × 28, top-aligned):
     - Left (`flex 1.3 1 420`, min-width 0, column gap 12): field "Nama orangnya", the "Cari orang" button row, and the found card or the not-found dashed box.
     - Right (`flex 1 1 340`, min-width 0, column gap 12): field "Nomor ponsel baru" with its hint, the refusal line, the "Minta kepastian Penatua Kolom" button row, and the 13 `tinta3` Operator note.
     - At 1440 about 608 and 484 wide; side by side while the content column is at least 788, which in window widths means from about 1073 up and at 839–860 (nav collapsed, so true at 860); stacked at 861–1072 and below 839.
     The status card, the Penatua card, checkbox row, buttons and dashed boxes are single blocks in the 1120 column (cards stretch to the column width).
- **Components** As AlurPulihkan, plus the platform web side nav.
- **Internal views and states** Same as AlurPulihkan (same initial state, same branches).
- **Tweaks** `keadaan` (options `Alur`, default `Alur`; no visible effect). Keadaan panel.
- **Interactions** Same as AlurPulihkan, handler for handler, with the same conditions, refusal sentences, messages and Riwayat rows. Side nav and "Menu" toggle as the shared shell.
- **Motion** none.
- **Links out**
  - Breadcrumb "Cari orang" → `/WebCariOrang`, up link.
  - Side nav, all `go`, the ten items as in the shared notes.
  - **Inbound** PetaPlatform, WebCariOrang.
- **Mock data** Same as AlurPulihkan.
- **Prototype-only** Same as AlurPulihkan: "Dilihat sebagai" (Operator · Penatua Kolom 7) and the hint "Di prototipe ini: Novita Wenas." go to the Keadaan panel.
- **Acceptance checks**
  1. `/WebAlurPulihkan` at 1440 → nav "Data jemaat" active, footer "Yanti Sumual · Operator"; breadcrumb "Cari orang"; the Operator form in two columns: name and "Cari orang" left, new number and "Minta kepastian Penatua Kolom" right.
  2. "Novita" → "Cari orang" → card "Novita Wenas" in the left column; "081298765432" → right-column button `tinta`; press → status card "Menunggu Penatua Kolom 7" across the column, banner and Riwayat row as AlurPulihkan.
  3. Panel "Penatua Kolom 7" → card "Menunggu Anda" with the always-visible refusal; tick, "Pastikan identitas" → "Tidak ada pemulihan akun yang menunggu Anda"; footer still "Yanti Sumual · Operator".
  4. Panel "Operator" → badge "Dipulihkan" (`laut` field).
  5. At 860 → "Menu" top bar; the Operator form still two columns. At 390 → stacked (name block above the number block), no horizontal scroll.
  6. Breadcrumb "Cari orang" → `/WebCariOrang`; side-nav "Data jemaat" → `/WebDataAnggota`, "Pengaturan" → `/WebPenugasan`.
- **Notes**
  - The footer identity does not follow the panel's "Dilihat sebagai" (the board's devices are not tied to the nav). Keep it static.
  - The status and Penatua cards stretch to 1120 px at 1440. Keep the board; flag for design.
  - Same refusal note as AlurPulihkan. No 12 px text.
