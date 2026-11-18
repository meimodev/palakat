# Screens 21: AlurAnggota, AlurPeristiwa, AlurKeluarga, WebAlurKeluarga, AlurNama, KeuanganUnit, SelesaikanUnit, WebSelesaikanUnit

These eight boards come from two canvas pages. Five are member-data flows from "Putaran 4 · Data jemaat" (`p4`), each a "flow with typed input and live refusals" that plays a whole journey on one board. **AlurAnggota** is a membership request: the applicant (Novita Wenas) fills the form, the BIPRA category is calculated as she types, and the Penatua Kolom 7 (Pnt. Hendrik Rumagit) verifies it or returns it with a reason. Once it is Diverifikasi the applicant gets "Atur Tampilan nama saya", which opens **AlurNama**. There she picks how her name appears in publications, or withdraws consent and deletes her data. **AlurPeristiwa** is the same two-person flow for a life event (Baptisan, Sidi, Pernikahan) with a mandatory letter. **AlurKeluarga** (phone) and **WebAlurKeluarga** (laptop) show the Operator (Yanti Sumual) importing three rows of the paper member book. She completes a birth date, decides a possible duplicate (Novita Wenas, already present from AlurAnggota), imports, then enters the family's signed paper confirmation form; the Penatua Kolom 7 verifies it, because the person who entered the form may not verify it. Every phone Alur board's back arrow goes to DataAnggota; the web board's breadcrumb goes to WebDataAnggota. Three boards come from "Putaran 5 · Kolaborasi" (`p5`). **KeuanganUnit** is the Bendahara Kolom 7's (Deasy Tumbelaka) restricted finance home: six states by tweak, three of them also reachable by its buttons, and a link to KasUnit. **SelesaikanUnit** (phone) and **WebSelesaikanUnit** (laptop) show the Bendahara Jemaat (Meiske Lumentut) clearing the two Kolom 7 blockers that hold the October 2026 close, with a reason; they go back to TutupBuku / WebTutupBuku. KeuanganUnit and SelesaikanUnit share data: the Draf "Konsumsi ibadah Kolom" −Rp150.000 and "Rekonsiliasi Kas Kolom 7 · Oktober 2026" at Rp920.000. All eight are reached from the map PetaPlatform and the launcher. AlurAnggota is also reached from AlurMasuk / WebAlurMasuk ("Ajukan permohonan menjadi anggota"), AlurNama from AlurAnggota, KeuanganUnit from PermintaanDana's back arrow, and SelesaikanUnit / WebSelesaikanUnit from the Bendahara Jemaat row "1 hambatan dari unit" on BerandaJabatan / WebBerandaJabatan (a row built in the logic class, so it is in `navigation.md` 3.3, not in the manifest). No board here animates (keyframes are declared but never applied), none has a timer, none has `jabatanKosong`. "Today" is 16/11/2026.

Shared notes for this file:

- **Navigation words.** An *up link* (phone back arrow, web breadcrumb) runs `kembaliKe('/X')`. It pops when the route directly below is `/X` or a child of `/X`, and otherwise does `go('/X')`. Every other board link is `push`. Web side-nav items are `go`. All of them are built with `Tautan(ke: …)`. None of these boards has child routes. Views change in place under the same header, title and back target, and a view change resets the body's scroll offset to the top. Each board keeps its state in its own `State`, so Back to it finds it as it was, and opening it fresh resets it, as reopening an artboard does.
- **Phone frame** (all phone boards here): 390 × 844, `kertas` background, body `isi` (16, line-height 1.4) in `tinta`. A column with a fixed header and a scrolling body. No tab bar.
  - Header (does not scroll; no fill or rule): row, centred vertically, gap 8, padding 14 top / 12 sides / 8 bottom. The back target is 44 × 44 with a centred chevron-left at 22 px (SVG path `M15 6l-6 6 6 6`, viewBox 24, stroke `tinta` width 2, round caps). Its Semantics label is given per board, and it is built with `Tautan`. Title column (flex 1): h1 `judulLayar` 18/700, margin 0; under it the subtitle, 13 `tinta2`. The board writes `font-size: 14px` and then `13px`; 13 wins.
  - Body: scrolls vertically, padding 8 top / 20 sides / 20 bottom, one column with gap 16, content width 350. Every block listed under Layout is a direct child of that column, so blocks are always 16 apart (`sc-if`/`sc-for` add no wrapper).
- **Platform web side nav** (WebAlurKeluarga, WebSelesaikanUnit). Built as in `16-alurmasuk.md` shared notes.
  - `nav`: flex 1 1 220, padding 24 × 16, `permukaan`, right rule 1 `garis`, column gap 20.
  - Logo row: gap 10, padding 0 8. The 26 × 26 mark (rect x2 y2 20 × 20 rx 6, stroke `laut` 2 dashed 3 3; right half path `M12 2h4a6 6 0 0 1 6 6v8a6 6 0 0 1-6 6h-4z` filled `laut`). Beside it "palakat" 18/700 at line-height 1.1, and "Jemaat Karunia" 13 `tinta3` under it.
  - Items: min-height 44, padding 0 12, radius 10, 600, no underline. The active item is a `tinta` field with `permukaan` text; the others are transparent with `tinta` text.
  - Footer: margin-top auto, padding 12 8 0, top rule 1 `garis`, 13 `tinta2`, with the name in bold `tinta`.
  - At 860 and narrower (the board's `@media (max-width:860px)`, so 860 itself is collapsed) the nav becomes a full-width top bar (row, wrap, centred, column gap 12, padding 8 × 16, bottom rule 1 `garis`, no right rule). Its "Menu" toggle (min-height 44, padding 0 16, radius 14, 1.5 `tinta` edge, `permukaan`, 700/14) is pushed to the right. Open, the toggle reads "Tutup menu" with a `tinta` field and `permukaan` text, and the items and footer show as full-width rows below.
  - Items, exactly in this order, all `go`:
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

  The active item and the footer are given per board.
- **Web main column**: flex 999 1 560, min-width 0, padding 28 top / `clamp(16, 3vw, 40)` sides / 40 bottom, column gap 20, page `kertas`, body `isiWeb` (15, line-height 1.45). The page scrolls as a whole.
  - Title block: breadcrumb text link 14/600, `laut`, underlined, `lautTua` on hover/press; h1 `judulHalaman` 26/700, margin-top 2; subtitle 14 `tinta2`.
  - Content column: max-width 1120, column gap 16.
  - On web every size written below as "body size" is 15 instead of 16.
  - *Two-column row* (where a board uses one): wrap, gap 20 vertical × 28 horizontal, top-aligned. Left `flex 1.3 1 420`, right `flex 1 1 340`, both min-width 0 and column gap 12. At 1440 the columns are about 608 and 484 wide. At 860 the main column is 808 wide, so they stay side by side. Below about 788 they stack.
- **Shared parts**: KitAlur (components.md 2.9), built in M1. This file uses it and does not redefine it. The names used below (*Field*, *Textarea*, *Pill group*, *Refusal line*, *TombolBersyarat*, *Primary button*, *Secondary button*, *Text button*, *Button row*, *Card*, *Info row*, *Dashed box*, *Dashed note*, *Badge*, *Message banner*, *Riwayat*) are the KitAlur parts: textarea = field with `baris: 3`, pill group = chip group. Only these differ on these boards:
  - *Field*: date fields are plain text: no input mask, no digit filter, no length limit.
  - *Pill group*: picking a pill always clears the message banner (`pesan = ''`).
  - *Refusal line*: 15 px where noted (`ukuranTeks: 15`); 14 elsewhere.
  - *Info row*: amounts in values are IBM Plex Mono 14/500.
  - *Badge*: all six `LS` shapes are used: `draf`, `garis`, `tinta`, `laut`, `bata`, `abu`.
  - *Checkbox row*: row, top-aligned, gap 12, min-height 44, 14 `tinta`; the whole row is the target. Checkbox 24 × 24, margin-top 2; checked fill `laut` with a `diLaut` tick (`accent-color: laut`); unchecked has a 2 `garisTegas` edge.
  - *Date check* (all typed dates here): trim, then it must match `^(\d\d)/(\d\d)/(\d{4})$` with month 1–12 and day 1–31. There is no month-length check, so "31/02/1996" passes. Compare dates as `yyyymmdd` integers against today, 20261116.
- **"Dilihat sebagai"** (AlurAnggota, AlurPeristiwa, AlurKeluarga, WebAlurKeluarga): KitAlur `DilihatSebagai` (components.md 2.9), under "Alat prototipe" in the Keadaan panel, never on screen. It calls the board's `pick`: it sets `akt` and clears `pesan`, and every other field, `st` and Riwayat are kept. The body then starts with the message banner.
- **Tweak `keadaan` on the five Alur boards**: enum, the single option `Alur`, default `Alur`. It changes nothing on screen (the logic's `k0`/`go0` are never used in the markup). The Keadaan panel lists it as a single fixed choice.
- **Tweak `keadaan` on KeuanganUnit / SelesaikanUnit / WebSelesaikanUnit**: the view shown is `k ?? keadaan`, and an unknown value falls back to the first option. In-board buttons set `k` to an option name. Changing the tweak in the Keadaan panel resets `k` to null. On the canvas a handler-set `k` hides later tweak changes until the board is reopened.

---

### AlurAnggota — 82 · Alur · Menjadi anggota

- **Source** `docs/design/handoff/canvas/boards/AlurAnggota.dc.html` · page Putaran 4 · Data jemaat (`p4`) · form Phone 390×844 (frame radius 36) · interactive yes
- **Route** `/AlurAnggota`, no child routes (the views change in place: the applicant's form or status, and the Penatua's queue, return form or empty box) · **Widget** `AlurAnggotaScreen` in `lib/screens/p4/alur_anggota.dart`
- **Purpose** Anggota jemaat journey step 1 ("Permohonan menjadi anggota", "Alur · Menjadi anggota") and the verifier side of Penatua Kolom journey step 2. The applicant, Novita Wenas, has no Data jemaat record yet (P02, "no match leads to the membership request"). She enters name, birth date, sex, marital status and Kolom and gives consent; the Penatua of the chosen Kolom verifies or returns the request with a reason. Shows:
  - P10/P11/Q29: the BIPRA category is calculated from birth date, sex and marital status, never typed (pattern "Calculated category").
  - Q28: the versioned default consent text, "Naskah bawaan · versi 1".
  - P12: a return reason must not be blank, with no minimum length.
  - Pattern "Two-person step": the requester sees "menunggu Penatua Kolom 7".
  - The rule that a Penatua verifies only their own Kolom and not their own family.
  - The rule that unverified data is never published.
- **Shell** Phone header with back. Semantics "Kembali ke Data jemaat", up link to `/DataAnggota`. Title "Alur · Menjadi anggota"; subtitle "Dari mengisi sendiri sampai Diverifikasi Penatua Kolom". No tab bar. The header does not change with the actor or the view.
- **Layout** (body column, gap 16)
  1. (Board: "Dilihat sebagai" pills "Pemohon" · "Penatua Kolom 7". Not on screen; see shared notes.)
  2. Message banner, only while `pesan` is set.
  3. **Applicant form** (`akt = 'Pemohon'` and `st` is empty or "Dikembalikan"):
     a. Only when `st = 'Dikembalikan'`: dashed note with bold "Dikembalikan Penatua Kolom 7." and then, in `tinta2`, the reason the Penatua typed (`kembali`).
     b. Field "Nama lengkap", placeholder "Nama sesuai surat baptis", no hint.
     c. Field "Tanggal lahir", placeholder "hh/bb/tttt", hint "Contoh: 14/03/1996." (a format hint; keep it on screen).
     d. Pill group "Jenis kelamin": "Perempuan" · "Laki-laki".
     e. Pill group "Status pernikahan": "Belum pernah menikah" · "Sudah menikah" (one line at 350).
     f. Only when the BIPRA category can be calculated (see Interactions), a card:
        - Head row: "Kategori BIPRA" 700, and a badge with the category. The badge is 13/700, radius 6, padding 3 × 9, with a 1.5 `tinta` edge, `tinta` text and no fill. This is the `terpilih` line; it is not one of the LencanaStatus variants.
        - Under it, 13 `tinta3`, the basis sentence.
     g. Pill group "Kolom": "Kolom 7" · "Kolom 4".
     h. Consent card, column gap 6:
        - "Izin penggunaan data pribadi" 700 body size.
        - 13 `tinta3` "Naskah bawaan · versi 1 · 12/11/2026".
        - 14 `tinta2` "Data ini dipakai Jemaat Karunia untuk pelayanan, surat dan Warta Jemaat. Nama saya di publikasi mengikuti Tampilan nama yang saya pilih. Saya dapat mencabut izin dan meminta data saya dihapus."
        - Checkbox row "Saya memberi izin penggunaan data pribadi saya."
     i. Refusal line (when shown): "Tidak dapat dilakukan: Ajukan." + reason.
     j. Button row: TombolBersyarat "Ajukan" (340 wide).
  4. **Applicant status** (`akt = 'Pemohon'` and `st` is "Diajukan" or "Diverifikasi"):
     a. Card. Head row "Permohonan menjadi anggota" + a badge reading `st`: "Diajukan" uses `garis`, "Diverifikasi" uses `laut`. Under it, 14 `tinta2`, `stKet`:
        - Diajukan: "Diajukan 16/11/2026 · menunggu Penatua Kolom 7". The Kolom name follows the chosen Kolom: "… menunggu Penatua Kolom 4".
        - Diverifikasi: "Aktif sejak 16/11/2026 · Diverifikasi Pnt. Hendrik Rumagit".
     b. 13 `tinta3` "Selama belum Diverifikasi, data ini tidak tampil di Warta Jemaat, surat atau laporan mana pun." (shown in both states).
     c. Only when Diverifikasi: a button row with the secondary link-button "Atur Tampilan nama saya": min-height 48, 340 wide, label centred, no underline. It is `Tautan(ke: 'AlurNama')`.
  5. **Penatua, request waiting** (`akt = 'Penatua Kolom 7'`, `st = 'Diajukan'`, chosen Kolom is Kolom 7, `v ≠ 'kembali'`):
     a. Card. Head row "Permohonan menjadi anggota" + `garis` badge "Diajukan". Info rows:
        - "Nama" → the typed name.
        - "Tanggal lahir" → the typed date, as typed.
        - "Status pernikahan" → the chosen status.
        - "Kategori BIPRA" → the calculated category.
        - "Kolom" → "Kolom 7".
        - "Izin data pribadi" → "Diberikan · naskah versi 1".
     b. 13 `tinta3` "Anda memverifikasi hanya data Kolom 7, dan bukan data keluarga Anda sendiri."
     c. Button row: primary "Verifikasi data" and secondary "Kembalikan dengan alasan", one line at 171 each; the second label wraps to two lines.
  6. **Penatua, return form** (same as 5 but `v = 'kembali'`):
     a. Card with only its head row: "Permohonan menjadi anggota" + `garis` badge "Diajukan".
     b. Textarea "Alasan · wajib".
     c. (The board has a refusal slot "Tidak dapat dilakukan: Kembalikan." but its condition can never be true, so it never shows.)
     d. Button row: TombolBersyarat "Kembalikan" and text button "Batal", one line at 171 each.
  7. **Penatua, nothing waiting** (`akt = 'Penatua Kolom 7'` and not case 5/6): dashed box with "Tidak ada data yang menunggu verifikasi" 700 and, under it, 14 `tinta2` `kosongTeks`:
     - `st = 'Diajukan'` with Kolom 4: "Pengajuan ini ditujukan ke Kolom 4; hanya Penatua Kolom itu yang melihatnya."
     - `st = 'Diverifikasi'`: "Sudah Diverifikasi."
     - otherwise (empty or Dikembalikan): "Pengajuan dari Kolom 7 akan muncul di sini."
  8. Riwayat, only when it has rows; shown to both actors.
- **Components**
  - ChipPilihan: jenis kelamin, status pernikahan, Kolom.
  - TombolBersyarat: "Ajukan", "Kembalikan". Penolakan: refusal line.
  - Tombol: primary "Verifikasi data"; secondary "Kembalikan dengan alasan" and the "Atur Tampilan nama saya" link-button; text "Batal".
  - LencanaStatus-shaped badges: "Diajukan", "Diverifikasi", and the BIPRA badge.
  - IsianAlasan (textarea) and RiwayatAlur.
  - GarisStatus lines: card `dibukukan`, dashed note/box `draf`.
  - Message banner.
  - Patterns: two-person step; calculated category; checkbox consent row; info rows.
- **Internal views and states** Initial state `{ k: null, a: { pesan: '', riw: [], v: 'isi', akt: 'Pemohon', nama: '', lahir: '', jk: '', nikah: '', kolom: '', izin: false, st: '', alasan: '', kembali: '', sentuh: false, file: '' } }`. `file` and the board's file helpers are unused here. `v` is "isi" or "kembali" (only the Penatua's return form uses it). `st` runs '' → "Diajukan" → "Diverifikasi", or "Diajukan" → "Dikembalikan" → "Diajukan" again. The branches are Layout 3–7. Both actors share one state: switching the actor keeps all fields, `st`, `v` and Riwayat.
- **Tweaks** `keadaan`: options `Alur`, default `Alur`, no visible effect. Keadaan panel.
- **Interactions**
  - Actor (panel "Dilihat sebagai", `pick`) → `akt` = "Pemohon" or "Penatua Kolom 7", `pesan = ''`.
  - Nama typing (`onNama`) → `nama` as typed, `sentuh = true`. Tanggal lahir typing (`onLahir`) → `lahir` as typed, `sentuh = true`.
  - Pills (`jkPil`, `nikahPil`, `kolomPil`) → set `jk` / `nikah` / `kolom`, `pesan = ''`. They do not set `sentuh`.
  - Checkbox (`onIzin`) → toggles `izin`.
  - BIPRA card: shown when the date is valid, before today, and both `jk` and `nikah` are set. Age `u = floor((20261116 − yyyymmdd) / 10000)`, i.e. completed years on 16/11/2026.
    - Category: "Sudah menikah" → "Bapa" (Laki-laki) or "Ibu" (Perempuan). Otherwise `u < 12` → "Anak", `u < 18` → "Remaja", else "Pemuda".
    - Basis: "Dasar: {u} tahun pada 16/11/2026, {nikah in lower case}. Dihitung sendiri; berubah sendiri saat umur atau status pernikahan berubah." For 14/03/1996 that is "Dasar: 30 tahun pada 16/11/2026, belum pernah menikah. …".
    - Recomputed on every change.
  - "Ajukan" (TombolBersyarat). Condition, first unmet reason:
    1. name blank after trimming → "nama belum diisi."
    2. date not valid → "tanggal lahir tidak dikenali. Contoh: 14/03/1996."
    3. date on or after 16/11/2026 → "tanggal lahir harus sebelum hari ini."
    4. no `jk` → "jenis kelamin belum dipilih."
    5. no `nikah` → "status pernikahan belum dipilih."
    6. no `kolom` → "Kolom belum dipilih."
    7. `izin` unchecked → "izin penggunaan data pribadi belum diberikan."

    The refusal line shows only once `sentuh` is true, i.e. after the first keystroke in Nama or Tanggal lahir. It then stays for the rest of the board's life, even if both fields are cleared. Tapping pills or the checkbox alone never shows it.

    Press when met (`ajukan`):
    - `st = 'Diajukan'`, `v = 'isi'`.
    - `pesan` = "Diajukan. Penatua Kolom 7 diberi tahu lewat Pemberitahuan." (with Kolom 4: "Diajukan. Penatua Kolom 4 diberi tahu lewat Pemberitahuan.").
    - Riwayat gains "16/11/2026 · Permohonan menjadi anggota diajukan · Novita Wenas". The name is always "Novita Wenas", whatever was typed.
  - "Verifikasi data" (`verif`, unconditional) → `st = 'Diverifikasi'`, `pesan = ''`. Riwayat gains "16/11/2026 · Permohonan menjadi anggota Diverifikasi · Pnt. Hendrik Rumagit, Penatua Kolom 7". The Penatua then sees "Sudah Diverifikasi."
  - "Kembalikan dengan alasan" (`keKembali`) → `v = 'kembali'`, `pesan = ''`, `alasan = ''`.
  - Textarea (`onAlasan`) → `alasan` as typed.
  - "Kembalikan" (TombolBersyarat). Condition: `alasan` not blank after trimming. No reason sentence is ever shown. Press when met (`kembalikan`):
    - `st = 'Dikembalikan'`, `v = 'isi'`, `kembali` = trimmed reason, `alasan = ''`, `pesan = ''`.
    - Riwayat gains "16/11/2026 · Permohonan menjadi anggota dikembalikan · alasan: {reason} · Pnt. Hendrik Rumagit".
    - The Penatua sees "Pengajuan dari Kolom 7 akan muncul di sini.". The applicant sees the form again with all earlier values kept, under the dashed "Dikembalikan …" note. Because `sentuh` is still true and all fields are valid, "Ajukan" is `tinta` straight away and no refusal shows.
  - "Batal" (`batalK`) → `v = 'isi'`, `pesan = ''`; back to the waiting card.
  - Re-submitting after Dikembalikan works like the first "Ajukan". The dashed note disappears because it shows only while `st = 'Dikembalikan'`.
  - No timers.
- **Motion** none. Keyframes `masuk`, `pudar`, `muncul`, `isi` are declared but never applied. Nothing to switch off under reduce motion.
- **Links out**
  - Header back "Kembali ke Data jemaat" → `/DataAnggota`, up link.
  - "Atur Tampilan nama saya" (applicant, after Diverifikasi) → `/AlurNama`, push.
  - **Inbound** AlurMasuk and WebAlurMasuk ("Ajukan permohonan menjadi anggota"), PetaPlatform ("Ponsel").
- **Mock data**
  - Applicant Novita Wenas, the expected entry: 14/03/1996, Perempuan, Belum pernah menikah → Pemuda, 30 years, Kolom 7. She is the record AlurKeluarga later finds as a possible duplicate.
  - Pnt. Hendrik Rumagit, Penatua Kolom 7.
  - Consent text "Naskah bawaan · versi 1 · 12/11/2026".
  - Kolom options Kolom 7 and Kolom 4. Today 16/11/2026.
- **Prototype-only** "Dilihat sebagai" pills (Pemohon · Penatua Kolom 7) → Keadaan panel, "Alat prototipe", default Pemohon. The hint "Contoh: 14/03/1996." is a field hint, not a "Contoh:" button, so it stays on screen. The panel also carries the tweak `keadaan`, "Semua layar", inbound links and the canvas title.
- **Acceptance checks**
  1. Open `/AlurAnggota`:
     - no "Dilihat sebagai" pills on screen;
     - empty form, no BIPRA card;
     - "Ajukan" with a `garis` field and `tinta2` text, no refusal line;
     - the panel shows "Dilihat sebagai: Pemohon".
  2. Tap "Perempuan" and tick the checkbox → still no refusal line. Type "N" in Nama → "Tidak dapat dilakukan: Ajukan. tanggal lahir tidak dikenali. Contoh: 14/03/1996."
  3. Nama "Novita Wenas" (typed text sans 14 `tinta2`, like the label), date "14/03/1996", "Belum pernah menikah" → BIPRA card "Pemuda", "Dasar: 30 tahun pada 16/11/2026, belum pernah menikah. Dihitung sendiri; berubah sendiri saat umur atau status pernikahan berubah."; tap "Sudah menikah" → "Ibu".
  4. Date "16/11/2026" → "… tanggal lahir harus sebelum hari ini." and the BIPRA card disappears. "16/11/2014", not married → "Remaja"; "01/06/2015" → "Anak".
  5. Valid data, "Kolom 7", consent ticked → "Ajukan" turns `tinta`. One press:
     - the form is replaced by the card "Permohonan menjadi anggota" with an outlined "Diajukan" and "Diajukan 16/11/2026 · menunggu Penatua Kolom 7";
     - banner "Diajukan. Penatua Kolom 7 diberi tahu lewat Pemberitahuan.";
     - Riwayat "16/11/2026 · Permohonan menjadi anggota diajukan · Novita Wenas".
  6. Panel "Penatua Kolom 7" → the banner is gone, and the card shows rows "Novita Wenas", "14/03/1996", "Belum pernah menikah", "Pemuda", "Kolom 7", "Diberikan · naskah versi 1".
  7. "Kembalikan dengan alasan" → textarea and a grey "Kembalikan", which does nothing when pressed. Type "Tanggal lahir keliru" and press:
     - the Penatua sees "Pengajuan dari Kolom 7 akan muncul di sini.";
     - Riwayat top row "16/11/2026 · Permohonan menjadi anggota dikembalikan · alasan: Tanggal lahir keliru · Pnt. Hendrik Rumagit";
     - panel "Pemohon" → dashed "Dikembalikan Penatua Kolom 7. Tanggal lahir keliru" above the filled form.
  8. Re-submit, then as Penatua press "Verifikasi data":
     - the Penatua sees "Sudah Diverifikasi.";
     - as Pemohon: `laut` badge "Diverifikasi", "Aktif sejak 16/11/2026 · Diverifikasi Pnt. Hendrik Rumagit" and "Atur Tampilan nama saya";
     - that button opens `/AlurNama`, and system Back returns here with the state kept.
  9. Fresh board: choose "Kolom 4" and submit → status "… menunggu Penatua Kolom 4"; as Penatua, "Pengajuan ini ditujukan ke Kolom 4; hanya Penatua Kolom itu yang melihatnya."
  10. Header back → `/DataAnggota`.
- **Notes**
  - The "Kembalikan" refusal can never show (the board's condition is `al && !al`). The board wins on what is shown, so no visible sentence. Give the grey button a Semantics hint "alasan belum diisi." so a screen reader hears the reason (TombolBersyarat rule).
  - The "Ajukan" refusal appears only after typing in Nama or Tanggal lahir, not after picking pills. Keep.
  - The Riwayat row always names "Novita Wenas", whatever name was typed. Keep.
  - The back arrow goes to Data jemaat even for an applicant who came from sign-in (AlurMasuk). Keep the board.
  - Kolom 4 is a dead end: no Kolom 4 actor exists. Keep.
  - Decision log section 7 says the screens state that the consent text has not been reviewed by counsel. This board shows only "Naskah bawaan · versi 1 · 12/11/2026". Keep; flag for design.
  - The date check has no month-length test. Keep it identical.
  - Off-token: none; no 12 px text. The h1 subtitle's 14→13 is resolved to 13.

### AlurPeristiwa — 83 · Alur · Peristiwa

- **Source** `docs/design/handoff/canvas/boards/AlurPeristiwa.dc.html` · page Putaran 4 · Data jemaat (`p4`) · form Phone 390×844 (frame radius 36) · interactive yes
- **Route** `/AlurPeristiwa`, no child routes · **Widget** `AlurPeristiwaScreen` in `lib/screens/p4/alur_peristiwa.dart`
- **Purpose** A member (Novita Wenas) reports a life event (Baptisan, Sidi or Pernikahan) for herself or her child, with the letter or certificate as a mandatory attachment. The Penatua Kolom 7 verifies it or returns it with a reason. Penatua Kolom journey step 2 ("Peristiwa", "Alur · Peristiwa" verifier side) and Anggota jemaat step 3. Shows:
  - P11: a verified Pernikahan moves both spouses to Bapa and Ibu from the wedding date. This is the note under "Pernikahan".
  - P12: the return reason is not blank.
  - The two-person step.
  - The rule that unverified data stays out of Warta, letters and reports.
  - TampilanNama: after verification the event can go into Warta under the family's display name.
- **Shell** Phone header with back. Semantics "Kembali ke Data jemaat", up link to `/DataAnggota`. Title "Alur · Peristiwa"; subtitle "Dari mengajukan sampai Diverifikasi dan boleh masuk Warta". No tab bar.
- **Layout** (body column, gap 16)
  1. (Board: "Dilihat sebagai" pills "Pemohon" · "Penatua Kolom 7" → panel.)
  2. Message banner.
  3. **Applicant form** (`akt = 'Pemohon'` and `st` is empty or "Dikembalikan"):
     a. Only when Dikembalikan: dashed note, bold "Dikembalikan Penatua Kolom 7." + `tinta2` reason. Same as AlurAnggota.
     b. Pill group "Jenis peristiwa": "Baptisan" · "Sidi" · "Pernikahan".
     c. Only when "Pernikahan" is picked: 13 `tinta3` "Setelah Diverifikasi, Kategori BIPRA kedua mempelai menjadi Bapa dan Ibu sejak tanggal pernikahan."
     d. Pill group "Untuk siapa": "Gabriel Wenas (anak)" · "Saya sendiri" (one line at 350).
     e. Field "Tanggal peristiwa", placeholder "hh/bb/tttt", hint "Tanggal yang tertulis di suratnya."
     f. Dashed box (attachment):
        - Head row: "Surat atau piagam" 700 + a badge. Without a file it is "Wajib, belum ada" (`bata`); with one, "Terlampir" (`garis`).
        - Without a file: secondary button "Pilih file", as wide as its label (not the 150/340 rule), left-aligned (`align-self: flex-start`), min-height 48.
        - With a file: 13 `tinta3` "1 file terlampir".
     g. Refusal line: "Tidak dapat dilakukan: Ajukan." + reason.
     h. Button row: TombolBersyarat "Ajukan".
  4. **Applicant status** (Diajukan or Diverifikasi):
     a. Card. Head row "Peristiwa" + badge `st` (`garis` "Diajukan" / `laut` "Diverifikasi"). Under it, 14 `tinta2`:
        - Diajukan: "Diajukan 16/11/2026 · menunggu Penatua Kolom 7".
        - Diverifikasi: "Diverifikasi 16/11/2026 · dapat masuk Warta Jemaat; nama mengikuti Tampilan nama keluarga".
     b. 13 `tinta3` "Selama belum Diverifikasi, data ini tidak tampil di Warta Jemaat, surat atau laporan mana pun."
     c. No button in either state; the board's Diverifikasi slot is empty.
  5. **Penatua, waiting** (`akt = 'Penatua Kolom 7'`, `st = 'Diajukan'`, `v ≠ 'kembali'`):
     a. Card. Head row "Peristiwa" + `garis` "Diajukan". Info rows:
        - "Jenis" → chosen type.
        - "Untuk" → chosen person.
        - "Tanggal peristiwa" → typed date.
        - "Lampiran" → "1 file".
     b. 13 `tinta3` "Anda memverifikasi hanya data Kolom 7, dan bukan data keluarga Anda sendiri."
     c. Button row: primary "Verifikasi data" + secondary "Kembalikan dengan alasan" (171 each).
  6. **Penatua, return form** (`v = 'kembali'`): card with only the head row "Peristiwa" + "Diajukan"; textarea "Alasan · wajib"; (dead refusal slot "Tidak dapat dilakukan: Kembalikan."); button row TombolBersyarat "Kembalikan" + text "Batal".
  7. **Penatua, nothing waiting**: dashed box "Tidak ada data yang menunggu verifikasi" 700 + 14 `tinta2`. After verification: "Sudah Diverifikasi."; otherwise: "Pengajuan dari Kolom 7 akan muncul di sini." The Kolom is fixed to Kolom 7 on this board, so the "ditujukan ke …" text cannot occur.
  8. Riwayat.
- **Components** ChipPilihan, TombolBersyarat ("Ajukan", "Kembalikan"), Penolakan, Tombol (primary "Verifikasi data"; secondary "Kembalikan dengan alasan", "Pilih file"; text "Batal"), LencanaStatus-shaped badges ("Wajib, belum ada", "Terlampir", "Diajukan", "Diverifikasi"), IsianAlasan, RiwayatAlur, message banner. The attachment box is the "supporting document" pattern: badge plus "Pilih file". The two-person step pattern.
- **Internal views and states** Initial state `{ k: null, a: { pesan: '', riw: [], v: 'isi', akt: 'Pemohon', jenis: '', untuk: '', tanggal: '', kolom: 'Kolom 7', izin: true, st: '', alasan: '', kembali: '', sentuh: false, file: '' } }`. `izin` is fixed and unused. `kolom` is fixed to "Kolom 7" and only feeds the Kolom name into `stKet` and the banner. `file` is '' or 'ada'. The branches are as in Layout. Both actors share one state.
- **Tweaks** `keadaan`: options `Alur`, default `Alur`, no visible effect. Keadaan panel.
- **Interactions**
  - Actor (panel, `pick`) → `akt`, `pesan = ''`.
  - Pills (`jenisPil`, `untukPil`) → set `jenis` / `untuk`, `pesan = ''`.
  - Date typing (`onTanggal`) → `tanggal` as typed, `sentuh = true`.
  - "Pilih file" (`pilihFile`) → `file = 'ada'` immediately. There is no picker, no upload progress and no failure (`sekaliGagal` is false). The file cannot be removed.
  - "Ajukan" condition, first unmet reason:
    1. no `jenis` → "jenis peristiwa belum dipilih."
    2. no `untuk` → "orangnya belum dipilih."
    3. date not valid → "tanggal peristiwa tidak dikenali. Contoh: 08/11/2026."
    4. date after 16/11/2026 → "tanggal peristiwa belum tiba." (today itself is allowed)
    5. no file → "surat atau piagam belum terlampir."

    The refusal line shows once any of these is true: `sentuh`, a file, a `jenis`, or an `untuk`. So the first pill tap already shows it.

    Press when met (`ajukan`):
    - `st = 'Diajukan'`, `v = 'isi'`, `pesan` = "Diajukan. Penatua Kolom 7 diberi tahu lewat Pemberitahuan.".
    - Riwayat gains "16/11/2026 · Peristiwa diajukan · Novita Wenas".
  - "Verifikasi data" (`verif`) → `st = 'Diverifikasi'`, `pesan = ''`. Riwayat gains "16/11/2026 · Peristiwa Diverifikasi · Pnt. Hendrik Rumagit, Penatua Kolom 7".
  - "Kembalikan dengan alasan" → `v = 'kembali'`, `pesan = ''`, `alasan = ''`. Textarea → `alasan`.
  - "Kembalikan" condition: trimmed `alasan` not blank, with no sentence. Press → `st = 'Dikembalikan'`, `v = 'isi'`, `kembali` = trimmed reason, `alasan = ''`, `pesan = ''`. Riwayat gains "16/11/2026 · Peristiwa dikembalikan · alasan: {reason} · Pnt. Hendrik Rumagit". The applicant's earlier choices, date and file are kept.
  - "Batal" → `v = 'isi'`, `pesan = ''`.
  - No timers.
- **Motion** none (keyframes `masuk`, `pudar`, `muncul`, `isi` declared, unused).
- **Links out**
  - Header back "Kembali ke Data jemaat" → `/DataAnggota`, up link.
  - **Inbound** PetaPlatform ("Ponsel").
- **Mock data** Novita Wenas (applicant, named in Riwayat); Gabriel Wenas (her child, "Gabriel Wenas (anak)"); Pnt. Hendrik Rumagit, Penatua Kolom 7; example date 08/11/2026; today 16/11/2026; Kolom 7.
- **Prototype-only** "Dilihat sebagai" pills (Pemohon · Penatua Kolom 7) → Keadaan panel, default Pemohon. Plus `keadaan`, "Semua layar", inbound links and the canvas title.
- **Acceptance checks**
  1. Open:
     - pills absent;
     - the "Baptisan · Sidi · Pernikahan" and "Gabriel Wenas (anak) · Saya sendiri" groups, and an empty date;
     - dashed "Surat atau piagam" with a `bata` "Wajib, belum ada" and "Pilih file";
     - "Ajukan" grey, no refusal.
  2. Tap "Pernikahan" → the BIPRA note appears under the pills, and the refusal reads "Tidak dapat dilakukan: Ajukan. orangnya belum dipilih."
  3. "Saya sendiri" → "… tanggal peristiwa tidak dikenali. Contoh: 08/11/2026."; "20/11/2026" → "… tanggal peristiwa belum tiba."; "16/11/2026" → "… surat atau piagam belum terlampir."
  4. "Pilih file" → badge "Terlampir" (outlined), "1 file terlampir", the button disappears, the refusal goes, "Ajukan" turns `tinta`. One press → status card "Peristiwa" / "Diajukan" / "Diajukan 16/11/2026 · menunggu Penatua Kolom 7", the banner, and Riwayat "16/11/2026 · Peristiwa diajukan · Novita Wenas".
  5. Panel "Penatua Kolom 7" → rows "Pernikahan", "Saya sendiri", "16/11/2026", "1 file".
  6. "Verifikasi data":
     - the Penatua sees "Sudah Diverifikasi.";
     - as Pemohon, a `laut` "Diverifikasi" and "Diverifikasi 16/11/2026 · dapat masuk Warta Jemaat; nama mengikuti Tampilan nama keluarga", with no button.
  7. Fresh run, return with reason "Piagam buram" → the applicant sees "Dikembalikan Penatua Kolom 7. Piagam buram" above the form, with the previous choices and "Terlampir" kept.
  8. Header back → `/DataAnggota`.
- **Notes**
  - "Pilih file" attaches instantly. Foundations say uploads always look in progress, but the board shows no progress. Keep the board.
  - "Kembalikan" has no visible reason sentence (dead condition). Add the Semantics hint "alasan belum diisi.", as on AlurAnggota.
  - The applicant status shows no next step after Diverifikasi (empty `pAktif` branch). Keep.
  - No 12 px text. Subtitle 14→13.

### AlurKeluarga — 84 · Alur · Buku anggota

- **Source** `docs/design/handoff/canvas/boards/AlurKeluarga.dc.html` · page Putaran 4 · Data jemaat (`p4`) · form Phone 390×844 (frame radius 36) · interactive yes
- **Route** `/AlurKeluarga`, no child routes · **Widget** `AlurKeluargaScreen` in `lib/screens/p4/alur_keluarga.dart`
- **Purpose** Operator journey step 1 ("Impor buku anggota", "Alur · Buku anggota", "Kemungkinan data ganda") and the Penatua's verification of a family. The Operator Yanti Sumual brings three rows of the paper member book of Kolom 7 into Data jemaat:
  - one row passed the checks;
  - one birth year is incomplete and must be typed;
  - one is a possible duplicate of Novita Wenas (from the membership request), which is never merged automatically.

  The rows enter as "Belum dikonfirmasi" and are visible only to Penatua and Operator. The Operator then attaches the family's signed paper confirmation form, which carries consent, consent text version 1. The Penatua Kolom 7 verifies it; the Operator cannot verify what she entered herself. Shows:
  - D34: the import words "Lolos pengecekan".
  - Q28: consent on paper.
  - The two-person step.
  - The rule that nothing is published before confirmation and consent.
- **Shell** Phone header with back. Semantics "Kembali ke Data jemaat", up link to `/DataAnggota`. Title "Alur · Buku anggota"; subtitle "Operator mengimpor; keluarga mengonfirmasi; Penatua memverifikasi". No tab bar.
- **Layout** (body column, gap 16)
  1. (Board: "Dilihat sebagai" pills "Operator" · "Penatua Kolom 7" → panel.)
  2. Message banner.
  3. **Operator, before import** (`akt = 'Operator'` and `st` empty):
     a. Loose info row (not in a card): "Sumber" → "Buku anggota Kolom 7 · 2019–2026".
     b. Card. Head row "Ferry Wenas" + `garis` badge "Lolos pengecekan". Under it 13 `tinta3` "Di buku: WENAS FERRY, lhr 3-8-71, Kol 7 · dibaca sebagai 03/08/1971".
     c. Card. Head row "Agustina Lasut" + badge: "Perlu dilengkapi" (`bata`) until the typed date is valid and before today, then "Lolos pengecekan" (`garis`). Then:
        - 13 `tinta3` "Di buku: LASUT AGUSTINA (istri), 12-12-74 · tahun tidak lengkap".
        - Field "Tanggal lahir", placeholder "hh/bb/tttt", hint "Ketik lengkap sesuai keterangan keluarga." (inside the card, under the column gap 6).
     d. Card. Head row "Novita Wenas" + `bata` badge "Kemungkinan data ganda". Then:
        - 13 `tinta3` "Sudah ada dari Permohonan menjadi anggota: Novita Wenas, 14/03/1996, Kolom 7. Tidak pernah digabung sendiri."
        - Pill group "Keputusan Anda": "Gabungkan" · "Bukan orang yang sama".
     e. 13 `tinta3` "Belum ada yang tersimpan sebagai data jemaat sampai Anda mengimpor."
     f. Refusal line: "Tidak dapat dilakukan: Impor." + reason.
     g. Button row: TombolBersyarat "Impor 3 baris". The label is fixed.
  4. **Operator, after import** (`akt = 'Operator'` and `st` set):
     a. Dashed note: bold "Masuk sebagai Belum dikonfirmasi." + `tinta2` "Hanya Penatua Kolom 7 dan Operator yang melihatnya. Tidak ada yang tampil di publikasi sampai keluarganya mengonfirmasi dan memberi izin." It shows in every post-import state, Aktif included.
     b. Card. Head row "Keluarga Wenas-Lasut" + badge `st`:
        - "Belum dikonfirmasi" → `draf`; "Menunggu verifikasi" → `garis`; "Aktif" → `laut`.
        - Under it, 14 `tinta2`, `stKet`:
          - Belum dikonfirmasi: "Kolom 7 · {n} · diimpor 16/11/2026".
          - Menunggu verifikasi: "Formulir kertas dimasukkan 16/11/2026 · menunggu Penatua Kolom 7".
          - Aktif: "Diverifikasi Pnt. Hendrik Rumagit, 16/11/2026. Nama keluarga dapat tampil sesuai Tampilan nama yang dipilih."
        - `n` is "3 orang", or "3 orang (Novita Wenas digabung dengan data yang sudah ada)" when "Gabungkan" was chosen.
     c. Only while Belum dikonfirmasi:
        - Dashed box. Head row "Formulir konfirmasi bertanda tangan" + badge "Wajib, belum ada" (`bata`) / "Terlampir" (`garis`). Then secondary "Pilih file" (intrinsic width, left-aligned, min-height 48) or 13 `tinta3` "1 file terlampir".
        - Checkbox row "Formulir memuat izin penggunaan data pribadi, naskah versi 1."
        - Refusal line "Tidak dapat dilakukan: Kirim untuk diverifikasi." + reason.
        - Button row: TombolBersyarat "Kirim untuk diverifikasi".
     d. Only while Menunggu verifikasi:
        - A refusal paragraph at **15 px**: bold `bata` "Tidak dapat dilakukan: Verifikasi data." + `tinta` "yang memasukkan formulir tidak memverifikasinya sendiri." No button goes with it.
        - Then 13 `tinta3` "Menunggu Pnt. Hendrik Rumagit, Penatua Kolom 7."
     e. In Aktif: only a and b.
  5. **Penatua, waiting** (`akt = 'Penatua Kolom 7'` and `st = 'Menunggu verifikasi'`):
     a. Card. Head row "Konfirmasi keluarga · Wenas-Lasut" + `garis` "Menunggu verifikasi". Info rows:
        - "Anggota keluarga" → `n`.
        - "Formulir" → "Terlampir · memuat izin data pribadi".
        - "Dimasukkan oleh" → "Yanti Sumual, Operator".
     b. Button row: primary "Verifikasi data" alone, 340 wide.
  6. **Penatua, nothing waiting**: dashed box "Tidak ada data yang menunggu verifikasi" 700 + 14 `tinta2`. Aktif: "Keluarga Wenas-Lasut sudah Aktif."; otherwise: "Keluarga dari buku anggota muncul di sini setelah mengonfirmasi datanya."
  7. Riwayat.
- **Components** TombolBersyarat ("Impor 3 baris", "Kirim untuk diverifikasi"), Penolakan (including the standalone 15 px one), ChipPilihan ("Keputusan Anda"), Tombol (secondary "Pilih file", primary "Verifikasi data"), LencanaStatus-shaped badges, GarisStatus (cards `dibukukan`, dashed note/box `draf`), RiwayatAlur, message banner, checkbox row, info rows. The duplicate card is the inline form of DataGanda's decision.
- **Internal views and states** Initial state `{ k: null, a: { pesan: '', riw: [], v: 'buku', akt: 'Operator', lahir2: '', ganda: '', file: '', izinF: false, st: '' } }`. `v` is never used for branching. `st` runs '' → "Belum dikonfirmasi" → "Menunggu verifikasi" → "Aktif". The branches are as in Layout. Both actors share state.
- **Tweaks** `keadaan`: options `Alur`, default `Alur`, no visible effect. Keadaan panel.
- **Interactions**
  - Actor (panel, `pick`) → `akt` = "Operator" or "Penatua Kolom 7", `pesan = ''`.
  - Agustina's date (`onLahir2`) → `lahir2` as typed (no `sentuh` flag).
  - "Keputusan Anda" pills → `ganda` = "Gabungkan" or "Bukan orang yang sama", `pesan = ''`.
  - "Impor 3 baris" condition, first unmet reason:
    1. `lahir2` blank after trimming → "tanggal lahir Agustina Lasut belum lengkap."
    2. date not valid → "tanggal lahir tidak dikenali. Contoh: 12/12/1974."
    3. date on or after today → "tanggal lahir harus sebelum hari ini."
    4. no `ganda` → "kemungkinan data ganda belum diputuskan."

    The refusal shows while `lahir2` is not empty or a `ganda` choice exists. So picking "Gabungkan" first shows reason 1. The test is on the raw text, so a lone space already shows "tanggal lahir Agustina Lasut belum lengkap." (reason 1 trims, the show test does not).

    Press when met (`impor`):
    - `st = 'Belum dikonfirmasi'`, `file = ''`, `pesan = ''`.
    - Riwayat gains "16/11/2026 · Buku anggota Kolom 7 diimpor: {n} · Yanti Sumual, Operator".
  - "Pilih file" → `file = 'ada'` instantly (never fails, cannot be removed).
  - Checkbox (`onIzinF`) → toggles `izinF`.
  - "Kirim untuk diverifikasi" condition, first unmet reason:
    1. no file → "formulir bertanda tangan belum terlampir."
    2. `izinF` unchecked → "formulir harus memuat izin penggunaan data pribadi."

    The refusal shows while a file exists or the box is ticked.

    Press when met (`kirim`):
    - `st = 'Menunggu verifikasi'`, `pesan` = "Penatua Kolom 7 diberi tahu lewat Pemberitahuan.".
    - Riwayat gains "16/11/2026 · Formulir konfirmasi Keluarga Wenas-Lasut dimasukkan · Yanti Sumual, Operator".
  - "Verifikasi data" (Penatua, `verif`, unconditional) → `st = 'Aktif'`, `pesan = ''`. Riwayat gains "16/11/2026 · Keluarga Wenas-Lasut Diverifikasi dan Aktif · Pnt. Hendrik Rumagit, Penatua Kolom 7".
  - No timers.
- **Motion** none (keyframes `masuk`, `pudar`, `muncul`, `isi` declared, unused).
- **Links out**
  - Header back "Kembali ke Data jemaat" → `/DataAnggota`, up link.
  - **Inbound** PetaPlatform ("Ponsel").
- **Mock data**
  - Source "Buku anggota Kolom 7 · 2019–2026".
  - Ferry Wenas: book line "WENAS FERRY, lhr 3-8-71, Kol 7", read as 03/08/1971.
  - Agustina Lasut (istri): book line "LASUT AGUSTINA (istri), 12-12-74", expected 12/12/1974.
  - Novita Wenas: existing record 14/03/1996, Kolom 7, from Permohonan menjadi anggota.
  - Keluarga Wenas-Lasut; Yanti Sumual, Operator; Pnt. Hendrik Rumagit, Penatua Kolom 7; consent text version 1; today 16/11/2026.
- **Prototype-only** "Dilihat sebagai" pills (Operator · Penatua Kolom 7) → Keadaan panel, default Operator. Plus `keadaan`, "Semua layar", inbound links and the canvas title.
- **Acceptance checks**
  1. Open → Operator view:
     - row "Sumber · Buku anggota Kolom 7 · 2019–2026";
     - three cards, with "Agustina Lasut" showing `bata` "Perlu dilengkapi";
     - "Impor 3 baris" grey, no refusal.
  2. Tap "Gabungkan" → "Tidak dapat dilakukan: Impor. tanggal lahir Agustina Lasut belum lengkap." Type "12-12-74" → "… tanggal lahir tidak dikenali. Contoh: 12/12/1974."
  3. Type "12/12/1974" → the badge turns to outlined "Lolos pengecekan", the refusal goes, the button turns `tinta`.
  4. Press:
     - dashed "Masuk sebagai Belum dikonfirmasi. …";
     - card "Keluarga Wenas-Lasut" with a dashed "Belum dikonfirmasi" badge and "Kolom 7 · 3 orang (Novita Wenas digabung dengan data yang sudah ada) · diimpor 16/11/2026";
     - the formulir box;
     - Riwayat "16/11/2026 · Buku anggota Kolom 7 diimpor: 3 orang (Novita Wenas digabung dengan data yang sudah ada) · Yanti Sumual, Operator".
  5. Tick the checkbox → "Tidak dapat dilakukan: Kirim untuk diverifikasi. formulir bertanda tangan belum terlampir."; "Pilih file" → "Terlampir", the refusal goes. Press "Kirim untuk diverifikasi":
     - banner "Penatua Kolom 7 diberi tahu lewat Pemberitahuan.";
     - badge "Menunggu verifikasi";
     - the 15 px "Tidak dapat dilakukan: Verifikasi data. yang memasukkan formulir tidak memverifikasinya sendiri." and "Menunggu Pnt. Hendrik Rumagit, Penatua Kolom 7.".
  6. Panel "Penatua Kolom 7" → card "Konfirmasi keluarga · Wenas-Lasut" with "3 orang (…)", "Terlampir · memuat izin data pribadi", "Yanti Sumual, Operator". "Verifikasi data" → "Keluarga Wenas-Lasut sudah Aktif.", and Riwayat shows three rows, newest first.
  7. Panel "Operator" → `laut` "Aktif" and "Diverifikasi Pnt. Hendrik Rumagit, 16/11/2026. Nama keluarga dapat tampil sesuai Tampilan nama yang dipilih." The dashed "Masuk sebagai Belum dikonfirmasi." note is still above it.
  8. Fresh board, panel "Penatua Kolom 7" first → "Keluarga dari buku anggota muncul di sini setelah mengonfirmasi datanya.", no Riwayat.
  9. Header back → `/DataAnggota`.
- **Notes**
  - The "Masuk sebagai Belum dikonfirmasi." note stays visible after the family is Aktif, which reads oddly. Keep the board; flag for design.
  - The Operator's "Tidak dapat dilakukan: Verifikasi data." is a refusal with no button. It is 15 px where other refusals are 14. Copy the board.
  - "Impor 3 baris" keeps its label when the duplicate is merged, and `n` still says "3 orang (…)". Keep.
  - Badge "Belum dikonfirmasi" uses the draf line, correct per GarisStatus.
  - No 12 px text. Subtitle 14→13.

### WebAlurKeluarga — Web · Alur · Buku anggota

- **Source** `docs/design/handoff/canvas/boards/WebAlurKeluarga.dc.html` · page Putaran 4 · Data jemaat (`p4`) · form Laptop page (preview 1440×1000, `expand: fill`) · interactive yes
- **Route** `/WebAlurKeluarga`, no child routes · **Widget** `WebAlurKeluargaScreen` in `lib/screens/p4/web_alur_keluarga.dart`
- **Purpose** The same import, confirmation and verification as AlurKeluarga, on the laptop where the Operator works (Q26). Same decisions: D34, Q28, the two-person step.
- **Shell** Platform web side nav. Active item **Data jemaat** (index 6 in the list, 0-based index 5). Footer: bold "Yanti Sumual" + " · Operator". The footer stays the same when the panel views the board as the Penatua.
- **Layout**
  1. Title block:
     - breadcrumb "Data jemaat" (up link → `/WebDataAnggota`);
     - h1 "Alur · Buku anggota";
     - subtitle "Operator mengimpor; keluarga mengonfirmasi; Penatua memverifikasi".
  2. Content column (max-width 1120, gap 16), body size 15. Order:
     a. (pills → panel)
     b. banner
     c. one branch
     d. Riwayat
  3. **Operator, before import**: a two-column row.
     - Left: the "Sumber" row and the cards Ferry Wenas, Agustina Lasut (with its date field) and Novita Wenas (with "Keputusan Anda"). Content as AlurKeluarga Layout 3a–d.
     - Right: 13 `tinta3` "Belum ada yang tersimpan sebagai data jemaat sampai Anda mengimpor.", the refusal line "Tidak dapat dilakukan: Impor. …", and the button row "Impor 3 baris" (340 wide).
  4. **Operator, after import**: a two-column row.
     - Left: the dashed note "Masuk sebagai Belum dikonfirmasi. …" and the card "Keluarga Wenas-Lasut" with badge and `stKet`.
     - Right, only while Belum dikonfirmasi: the formulir dashed box, the checkbox row, the refusal line and "Kirim untuk diverifikasi".
     - Right, only while Menunggu verifikasi: the 15 px refusal "Tidak dapat dilakukan: Verifikasi data. yang memasukkan formulir tidak memverifikasinya sendiri." and 13 `tinta3` "Menunggu Pnt. Hendrik Rumagit, Penatua Kolom 7."
     - Right, in Aktif: empty (the row still reserves the column).
  5. **Penatua, waiting**: single blocks in the 1120 column. The card "Konfirmasi keluarga · Wenas-Lasut" stretches to the full column width; button row "Verifikasi data" (340).
  6. **Penatua, nothing waiting**: dashed box across the column.
  7. Riwayat across the column, below the two columns.
- **Components** As AlurKeluarga, plus the platform web side nav.
- **Internal views and states** Same as AlurKeluarga (same initial state, same branches).
- **Tweaks** `keadaan`: options `Alur`, default `Alur`, no visible effect. Keadaan panel.
- **Interactions** Same as AlurKeluarga, handler for handler: same conditions, refusal sentences, messages and Riwayat rows. Side nav and the "Menu" toggle work as the shared shell.
- **Motion** none. The keyframes `muncul`, `isi`, `titik` are declared and unused.
- **Links out**
  - Breadcrumb "Data jemaat" → `/WebDataAnggota`, up link.
  - Side nav, all `go`: the ten items in the shared notes (`/WebBerandaJabatan`, `/WebBeranda`, `/WebDokumenGereja`, `/WebPengumuman`, `/WebWartaArsip`, `/WebDataAnggota`, `/Ibadah`, `/Panitia`, `/WebKotakMasuk`, `/WebPenugasan`).
  - **Inbound** PetaPlatform ("Web").
- **Mock data** Same as AlurKeluarga.
- **Prototype-only** "Dilihat sebagai" (Operator · Penatua Kolom 7) → Keadaan panel, default Operator. Plus `keadaan`, "Semua layar", inbound links and the canvas title.
- **Acceptance checks**
  1. `/WebAlurKeluarga` at 1440:
     - nav "Data jemaat" on a `tinta` field, footer "Yanti Sumual · Operator";
     - breadcrumb "Data jemaat";
     - left column (~608 wide) with "Sumber" and three cards, right column (~484) with the note and a grey "Impor 3 baris".
  2. "12/12/1974" + "Bukan orang yang sama" → "Impor 3 baris":
     - left shows the dashed note and "Keluarga Wenas-Lasut" with "Kolom 7 · 3 orang · diimpor 16/11/2026";
     - right shows the formulir box, checkbox and grey "Kirim untuk diverifikasi";
     - Riwayat "16/11/2026 · Buku anggota Kolom 7 diimpor: 3 orang · Yanti Sumual, Operator" spans the column below.
  3. Attach, tick, "Kirim untuk diverifikasi" → the banner above the two columns; the right column shows the 15 px refusal and "Menunggu Pnt. Hendrik Rumagit, Penatua Kolom 7."
  4. Panel "Penatua Kolom 7" → the card spans the whole 1120 column; "Verifikasi data" → "Keluarga Wenas-Lasut sudah Aktif."; the footer still reads "Yanti Sumual · Operator".
  5. At 860 → the "Menu" top bar, and the two columns still side by side. At 390 → stacked (cards above the button), no horizontal scroll.
  6. Breadcrumb → `/WebDataAnggota`; side nav "Keuangan" → `/WebBeranda`, "Ibadah dan kegiatan" → `/Ibadah`; Back returns here with the state kept.
- **Notes**
  - The footer identity does not follow the panel's "Dilihat sebagai". Keep it static.
  - Cards in the Penatua view stretch to 1120 px. Keep; flag for design.
  - The same notes as AlurKeluarga apply. No 12 px text.

### AlurNama — 85 · Alur · Data saya

- **Source** `docs/design/handoff/canvas/boards/AlurNama.dc.html` · page Putaran 4 · Data jemaat (`p4`) · form Phone 390×844 (frame radius 36) · interactive yes
- **Route** `/AlurNama`, no child routes. The three views `nama` / `hapus` / `sudah` change in place under the same header. · **Widget** `AlurNamaScreen` in `lib/screens/p4/alur_nama.dart`
- **Purpose** Anggota jemaat journey step 2 ("Tampilan nama saya di publikasi", "Alur · Data saya", "Cabut izin dan hapus data saya"). The member Novita Wenas picks one of the seven display-name forms, sees a live preview, and gets "Masih mudah dikenali" when the form still points at one person. Or she withdraws consent and deletes her data, after reading what is deleted and what stays. Shows:
  - the TampilanNama component rules: seven forms; applies from the next publication; only the Sekretaris Jemaat can show a name as an exception, with a reason;
  - Q28: consent can be withdrawn;
  - the rule that financial records keep the name and published Warta and documents stay unchanged.
- **Shell** Phone header with back. Semantics "Kembali ke Data jemaat", up link to `/DataAnggota`. Title "Alur · Data saya"; subtitle "Memilih tampilan nama; mencabut izin dan menghapus data". No tab bar. No "Dilihat sebagai" (one actor).
- **Layout** (body column, gap 16)
  - **View `nama`** (initial):
    1. Message banner (only in this view).
    2. Pill group "Tampilan nama saya di publikasi", seven pills in this order: "Nama lengkap" · "Nama keluarga" · "Keluarga + Kolom" · "Kolom" · "BIPRA" · "BIPRA + Kolom" · "Tanpa nama". They wrap to about three lines at 350. "Keluarga + Kolom" is selected at the start.
    3. Preview panel: `lautLembut` field, radius 12, padding 12 × 14, 14 px, no edge.
       - First line 13 `tinta3` "Lihat tampilan nama saya".
       - Second line "Syukur ulang tahun: " in `tinta`, followed by the preview in bold 700.
    4. Only when "BIPRA + Kolom" is picked: dashed box (body size 16, column gap 6, two lines): "Masih mudah dikenali." 700, then `tinta2` "Kolom 7 hanya punya dua anggota Pemuda."
    5. Button row: TombolBersyarat "Simpan pilihan" (340).
    6. 13 `tinta3` "Berlaku untuk publikasi berikutnya; edisi yang sudah diterbitkan tidak berubah. Hanya Sekretaris Jemaat yang dapat menampilkan nama sebagai pengecualian, dengan alasan, dan Anda diberi tahu."
    7. Button row: text button "Cabut izin dan hapus data saya" (340 wide, `laut` 700, centred).
    8. Riwayat (only in this view, only with rows).
  - **View `hapus`**:
    1. Card, column gap 6: "Yang dihapus" 700; 14 `tinta2` "Data pribadi Anda, riwayat keluarga dan Kolom, peristiwa, jabatan yang sedang dipegang (menjadi Jabatan kosong), dan akun Anda."
    2. Dashed box: "Yang tetap ada" 700; 14 `tinta2` "Catatan keuangan Jemaat tetap menyimpan nama seperti yang tercatat, sebagai bagian dari pembukuan gereja. Warta Jemaat dan dokumen yang sudah diterbitkan tetap persis seperti saat diterbitkan."
    3. Checkbox row "Saya mengerti data saya akan dihapus dan tidak dapat dikembalikan. Untuk menjadi anggota lagi saya harus mengajukan permohonan baru."
    4. (Refusal slot "Tidak dapat dilakukan: Cabut izin dan hapus data saya." is always empty and never shows.)
    5. Button row: TombolBersyarat "Cabut izin dan hapus data saya" + text button "Kembali", one line at 171 each. The first label wraps to centred lines (about two: "Cabut izin dan" / "hapus data saya") and the button grows.
  - **View `sudah`**:
    1. Card. Head row "Catatan penghapusan" + `abu` badge "Selesai". Then:
       - info row "Dihapus pada" → "16/11/2026";
       - info row "Atas permintaan" → "anggota sendiri";
       - 13 `tinta3` "Catatan ini tidak memuat data pribadi. Orangnya tidak lagi punya status di Data jemaat."
    2. (Board: 13 `tinta3` "Layar ini hanya contoh: setelah penghapusan, akun tidak dapat lagi masuk." Not on screen; it goes to the panel, see Prototype-only.)
- **Components** TampilanNama (pill group plus preview plus the "Masih mudah dikenali" warning; the README suggests `RadioListTile`, but the board draws ChipPilihan pills, so follow the board), ChipPilihan, TombolBersyarat ("Simpan pilihan", "Cabut izin dan hapus data saya"), Tombol (text "Cabut izin dan hapus data saya", "Kembali"), LencanaStatus-shaped `abu` badge "Selesai", RiwayatAlur, message banner, checkbox row, GarisStatus `dibukukan`/`draf`.
- **Internal views and states** Initial state `{ k: null, a: { pesan: '', riw: [], v: 'nama', bentuk: 'Keluarga + Kolom', simpan: 'Keluarga + Kolom', paham: false } }`.
  - `bentuk` is the highlighted pill; `simpan` is the saved choice.
  - Views: `nama` → `hapus` (text button) → `sudah` (TombolBersyarat). `hapus` → `nama` ("Kembali").
  - `sudah` has no exit on screen; header back or reopening the board leaves it.
- **Tweaks** `keadaan`: options `Alur`, default `Alur`, no visible effect. Keadaan panel.
- **Interactions**
  - Pill (`bentukPil[].pick`) → `bentuk` = that form, `pesan = ''` (the banner disappears).
  - Preview text (`pratinjau`) by form:
    - "Nama lengkap" → "Novita Wenas"
    - "Nama keluarga" → "Kel. Wenas-Lasut"
    - "Keluarga + Kolom" → "Kel. Wenas-Lasut — Kolom 7"
    - "Kolom" → "Anggota Kolom 7"
    - "BIPRA" → "Anggota Pemuda"
    - "BIPRA + Kolom" → "Anggota Pemuda Kolom 7"
    - "Tanpa nama" → "Tanpa nama"
  - Warning (`kenal`): only for "BIPRA + Kolom".
  - "Simpan pilihan" (TombolBersyarat): met when `bentuk ≠ simpan`. There is no reason sentence. Press when met (`simpanNama`):
    - `simpan = bentuk`, `pesan` = "Tampilan nama disimpan: {bentuk}.".
    - Riwayat gains "16/11/2026 · Tampilan nama diubah menjadi {bentuk} · Novita Wenas".
    - The button turns grey again.
  - Text button "Cabut izin dan hapus data saya" (`keHapus`) → `v = 'hapus'`, `pesan = ''`, `paham = false`. Each visit starts unticked.
  - Checkbox (`onPaham`) → toggles `paham`.
  - TombolBersyarat "Cabut izin dan hapus data saya" (`hapus`): met when `paham`. There is no reason sentence. Press → `v = 'sudah'`.
  - "Kembali" (`pulang`) → `v = 'nama'`, `pesan = ''`; the selection and Riwayat are kept.
  - No timers.
- **Motion** none (keyframes `masuk`, `pudar`, `muncul`, `isi` declared, unused).
- **Links out**
  - Header back "Kembali ke Data jemaat" → `/DataAnggota`, up link. When opened from AlurAnggota the route below is AlurAnggota, so this does `go('/DataAnggota')`; system Back still returns to AlurAnggota.
  - **Inbound** AlurAnggota ("Atur Tampilan nama saya"), PetaPlatform ("Ponsel").
- **Mock data**
  - Novita Wenas, Keluarga Wenas-Lasut, Kolom 7, BIPRA Pemuda.
  - The previews listed under Interactions.
  - "Kolom 7 hanya punya dua anggota Pemuda".
  - Deletion date 16/11/2026, "anggota sendiri".
- **Prototype-only** "Layar ini hanya contoh: setelah penghapusan, akun tidak dapat lagi masuk." (view `sudah`) is a prototype explanation of the same kind as "Di prototipe ini: …". It goes to the Keadaan panel as a labelled note, shown while the view is `sudah`. No "Dilihat sebagai", no "Contoh:" button, no code. The panel also carries `keadaan`, "Semua layar", inbound links and the canvas title.
- **Acceptance checks**
  1. Open:
     - "Keluarga + Kolom" selected;
     - preview "Syukur ulang tahun: **Kel. Wenas-Lasut — Kolom 7**";
     - "Simpan pilihan" grey; no banner, no Riwayat.
  2. Tap "BIPRA + Kolom" → preview "Anggota Pemuda Kolom 7", the dashed "Masih mudah dikenali." / "Kolom 7 hanya punya dua anggota Pemuda.", and "Simpan pilihan" turns `tinta`.
  3. Tap "Tanpa nama" → preview "Tanpa nama", the warning goes. "Simpan pilihan":
     - banner "Tampilan nama disimpan: Tanpa nama.";
     - Riwayat "16/11/2026 · Tampilan nama diubah menjadi Tanpa nama · Novita Wenas";
     - the button grey again.
  4. Tap "Nama lengkap" → the banner disappears, the preview reads "Novita Wenas", and the button is `tinta`. Tap "Tanpa nama" again → the button is grey.
  5. "Cabut izin dan hapus data saya" (text) → view `hapus`: card "Yang dihapus", dashed "Yang tetap ada", an unticked checkbox, a grey TombolBersyarat and "Kembali". Pressing grey does nothing.
  6. Tick → the button turns `tinta`. Press → "Catatan penghapusan" with `abu` "Selesai", "Dihapus pada 16/11/2026", "Atas permintaan anggota sendiri". The "Layar ini hanya contoh …" note is in the panel, not on screen.
  7. From `hapus`, "Kembali" → view `nama` with the earlier selection and Riwayat. Re-entering `hapus` shows the checkbox unticked.
  8. Header back → `/DataAnggota`.
- **Notes**
  - Neither TombolBersyarat shows a reason sentence (the board has none for "Simpan pilihan", and an always-empty one for the delete). This conflicts with the TombolBersyarat rule. The board wins on what is shown. Give the buttons Semantics hints: "pilihan ini sudah tersimpan." and "centang dulu pernyataan di atas.".
  - The "Layar ini hanya contoh …" line is moved to the panel. This is a judgement call (it is not literally "Di prototipe ini"); the app would never show it.
  - The "Masih mudah dikenali" box text is 16 px (no size set on the board), not 14 like the other dashed notes. Copy the board.
  - The irreversible delete uses a `tinta` TombolBersyarat with no hold and no second confirmation. Keep the board.
  - No 12 px text. Subtitle 14→13.

### KeuanganUnit — 86 · Keuangan Kolom 7

- **Source** `docs/design/handoff/canvas/boards/KeuanganUnit.dc.html` · page Putaran 5 · Kolaborasi (`p5`) · form Phone 390×844 (frame radius 36) · interactive yes
- **Route** `/KeuanganUnit`, no child routes (six views, by tweak and by buttons, in place) · **Widget** `KeuanganUnitScreen` in `lib/screens/p5/keuangan_unit.dart`
- **Purpose** Bendahara unit journey step 1 ("Keuangan Kolom 7", "Alur · Keuangan unit", "Pernyataan kesiapan per peruntukan"). Deasy Tumbelaka, Bendahara Kolom 7, sees the same finance screens restricted to the peruntukan Kolom 7 and the Kas/Bank the unit manages. Shows:
  - P14: the Bendahara Jemaat decides which Kas/Bank a unit manages, so money of Kolom 7 held in a Jemaat bank account is booked by the Bendahara Jemaat.
  - A unit treasurer does not book outside its peruntukan and does not make an Alih peruntukan (cf. D04).
  - The readiness statement per peruntukan, which must be restated after an October change.
  - Tutup buku belongs to the Bendahara Jemaat for the whole Jemaat (D08).
  - The unit uses the Jemaat's single No. Bukti series.
  - The role ribbon (PitaPeran).
- **Shell** Phone header with back. Semantics "Kembali ke Keuangan"; the target is this same board (see Links out). Title "Keuangan Kolom 7"; subtitle "Layar keuangan yang sama, terbatas pada peruntukan dan Kas/Bank unit". No tab bar.
- **Layout** (body column, gap 16). Every view starts with:
  - **Role ribbon** (PitaPeran, `terpilih` line): 1.5 solid `tinta` edge, radius 12, `permukaan`, padding 12 × 14, 14 px `tinta`, one paragraph. Bold "Keuangan unit: Kolom 7." then " Anda membukukan hanya di peruntukan Kolom 7, pada Kas/Bank yang dikelola Kolom 7."

  Then per view:
  - **"Beranda unit"** (`k0`):
    1. Card. Head row "Kas Kolom 7" 700 + "Rp1.240.000" in mono 16/500 (`jumlah`). Under it 13 `tinta3` "Dikelola oleh Kolom 7 · saldo buku, hanya yang sudah dibukukan".
    2. Card. Head row "Perlu tindakan" + `bata` badge "2". Under it 14 `tinta2` "1 draf belum dibukukan · hitung kas November belum diisi". The card is not pressable.
    3. Button row: primary "Catat transaksi" + secondary "Rekonsiliasi Kas Kolom 7" (171 each; the second label wraps to two lines).
  - **"Dibukukan"** (`k1`):
    1. Card. Head row "BKU-2026-0151" + `tinta` badge "Dibukukan". Info rows:
       - "Persembahan Ibadah Kolom" → mono 14/500 "Rp320.000";
       - "Masuk ke peruntukan" → "Kolom 7";
       - "Kas/Bank" → "Kas Kolom 7 · dikelola oleh Kolom 7".

       Then 13 `tinta3` "Dibukukan oleh Deasy Tumbelaka, Bendahara Kolom 7 · 17/11/2026 20.10. No. Bukti dari seri Jemaat yang sama."
    2. No buttons.
  - **"Kas/Bank dikelola Bendahara Jemaat"** (`k2`):
    1. Card. Head row "Draf · Konsumsi ibadah Kolom" 700 + mono 16/500 "−Rp150.000" (U+2212), no badge. Info rows "Diambil dari peruntukan" → "Kolom 7"; "Kas/Bank" → "Bank BNI ··4821 · dikelola oleh Bendahara Jemaat".
    2. Refusal paragraph at **15 px**: "Tidak dapat dilakukan: Bukukan." + " Bank BNI ··4821 dikelola oleh Bendahara Jemaat, bukan oleh Kolom 7."
    3. 13 `tinta3` "Uang Kolom 7 yang ada di Kas/Bank Jemaat dibukukan oleh Bendahara Jemaat."
    4. Text link "Kas/Bank mana yang dikelola unit": 700/14, `laut`, underlined (`lautTua` on hover/press), min-height 44, text vertically centred and left-aligned. It is an `inline-flex` item of the body's flex column, so it is stretched to the column width (350): a tap anywhere on that 44-high strip opens it (as the text link in `16-alurmasuk.md`).
    5. Button row: primary "Kirim ke Bendahara Jemaat untuk dibukukan" + secondary "Ubah Kas/Bank" (171 each; the first label wraps to about three lines).
  - **"Peruntukan lain"** (`k3`):
    1. Card. Head row "Draf · Bantuan duka" + mono 16/500 "−Rp200.000". Info rows "Diambil dari peruntukan" → "Diakonia"; "Kas/Bank" → "Kas Kolom 7".
    2. 15 px refusal "Tidak dapat dilakukan: Bukukan." + " peruntukan Diakonia bukan peruntukan Kolom 7."
    3. 13 `tinta3` "Bendahara unit tidak membukukan di luar peruntukannya dan tidak membuat Alih peruntukan."
    4. Button row: primary "Kirim ke Bendahara Jemaat untuk dibukukan" + secondary "Ubah peruntukan".
  - **"Pernyataan kesiapan"** (`k4`):
    1. Card. Head row "Rekonsiliasi Kas Kolom 7 · Oktober 2026" (wraps, about three lines beside the badge at 316) + `laut` badge "Sudah dipastikan". Info rows, mono 14/500:
       - "Saldo buku" → "Rp920.000"
       - "Hasil hitung kas" → "Rp920.000"
       - "Selisih belum dijelaskan" → "Rp0"
    2. Card. Head row "Pernyataan kesiapan · Kolom 7" + `bata` badge "Belum ada". Then 13 `tinta3` "Perubahan pada transaksi Oktober di peruntukan ini membuat pernyataan perlu dinyatakan lagi.", then a button row inside the card: primary "Nyatakan siap" (316 wide, the card's inner width).
  - **"Tutup buku bukan wewenang unit"** (`k5`):
    1. 15 px refusal "Tidak dapat dilakukan: Tutup buku." + " tutup buku dilakukan Bendahara Jemaat untuk seluruh Jemaat."
    2. 13 `tinta3` "Bendahara unit menyiapkan: membukukan, merekonsiliasi Kas/Bank unit, dan menyatakan siap."
    3. No buttons.
- **Components**
  - PitaPeran (role ribbon).
  - LencanaStatus: "Dibukukan" (`tinta`), "Sudah dipastikan" (`laut`), "Belum ada" (`bata`), count "2" (`bata`).
  - Penolakan (15 px variant), Tombol (primary/secondary), text link.
  - Card / info rows; ButirPerhatian shape for "Perlu tindakan".
- **Internal views and states** Initial state `{ k: null }`. The view shown is `k ?? keadaan` (shared notes). Buttons set `k`:
  - "Catat transaksi" → "Dibukukan".
  - "Rekonsiliasi Kas Kolom 7" → "Pernyataan kesiapan".
  - In `k2`/`k3`: both buttons → "Beranda unit".
  - "Nyatakan siap" → "Beranda unit".

  No typed input, no sheets, no toasts.
- **Tweaks** `keadaan`, Keadaan panel. Options, with what each shows:
  - "Beranda unit" (default): balance, Perlu tindakan and two buttons.
  - "Dibukukan": the posted BKU-2026-0151.
  - "Kas/Bank dikelola Bendahara Jemaat": the Draf on Bank BNI ··4821, refused.
  - "Peruntukan lain": the Draf on Diakonia, refused.
  - "Pernyataan kesiapan": the confirmed reconciliation and "Belum ada".
  - "Tutup buku bukan wewenang unit": the refusal only.

  Changing it resets `k` to null.
- **Interactions**
  - `go1` "Catat transaksi" → `k = 'Dibukukan'`.
  - `go4` "Rekonsiliasi Kas Kolom 7" → `k = 'Pernyataan kesiapan'`.
  - `go0` "Kirim ke Bendahara Jemaat untuk dibukukan", "Ubah Kas/Bank", "Ubah peruntukan", "Nyatakan siap" → `k = 'Beranda unit'`. None shows a message.
  - Header back → resets `k` to null (see Links out).
  - Each view change resets the body scroll to the top. No refusals react to input; the refusal lines are static. No timers.
- **Motion** none (keyframes `masuk`, `pudar`, `muncul`, `isi` declared, unused).
- **Links out**
  - Header back "Kembali ke Keuangan" → the board links to itself (`KeuanganUnit.dc.html`; `navigation.md` kind **self**). Build it as `KepalaPonsel(kembaliKe: 'KeuanganUnit', labelKembali: 'Kembali ke Keuangan', diSini: () => setState(() => k = null))`. The target is the current route, so the back `Tautan` does not push a second copy and calls `diSini` instead (components.md 1.6). On the canvas the self-link reloads the board, so the tap resets `k` to null and shows the panel's current option. System/browser Back still pops to the previous route (e.g. PermintaanDana).
  - "Kas/Bank mana yang dikelola unit" (view `k2`) → `/KasUnit`, push. Back returns to this view.
  - **Inbound** PermintaanDana (its back arrow "Kembali ke Keuangan", an up link), PetaPlatform ("Ponsel").
- **Mock data**
  - Kolom 7; Deasy Tumbelaka, Bendahara Kolom 7.
  - Kas Kolom 7 Rp1.240.000; Perlu tindakan 2 ("1 draf belum dibukukan · hitung kas November belum diisi").
  - BKU-2026-0151: Persembahan Ibadah Kolom Rp320.000, peruntukan Kolom 7, Kas Kolom 7, 17/11/2026 20.10.
  - Draf "Konsumsi ibadah Kolom" −Rp150.000, peruntukan Kolom 7, Bank BNI ··4821 (managed by the Bendahara Jemaat).
  - Draf "Bantuan duka" −Rp200.000, peruntukan Diakonia, Kas Kolom 7.
  - Rekonsiliasi Kas Kolom 7 · Oktober 2026: Saldo buku Rp920.000, Hasil hitung kas Rp920.000, Selisih Rp0, "Sudah dipastikan".
  - Pernyataan kesiapan · Kolom 7 "Belum ada".
  - The same Draf and reconciliation appear on SelesaikanUnit.
- **Prototype-only** None of the four devices. Keadaan panel: `keadaan`, "Semua layar", inbound links, canvas title.
- **Acceptance checks**
  1. Open → the role ribbon, then "Kas Kolom 7" with mono "Rp1.240.000", "Perlu tindakan" with a `bata` badge "2", and the buttons "Catat transaksi" / "Rekonsiliasi Kas Kolom 7".
  2. "Catat transaksi" → "BKU-2026-0151" with a `tinta` "Dibukukan", "Rp320.000", "Kas Kolom 7 · dikelola oleh Kolom 7" and the "… 17/11/2026 20.10 …" footnote. Header back → Beranda unit; the route stays `/KeuanganUnit`.
  3. "Rekonsiliasi Kas Kolom 7" → the reconciliation card with `laut` "Sudah dipastikan" and "Rp0", plus "Pernyataan kesiapan · Kolom 7" with `bata` "Belum ada". "Nyatakan siap" → Beranda unit.
  4. Panel "Kas/Bank dikelola Bendahara Jemaat":
     - "−Rp150.000" with U+2212;
     - the 15 px refusal "Tidak dapat dilakukan: Bukukan. Bank BNI ··4821 dikelola oleh Bendahara Jemaat, bukan oleh Kolom 7.";
     - "Kas/Bank mana yang dikelola unit" → `/KasUnit`, and Back returns to this same view.
  5. Panel "Peruntukan lain" → "Draf · Bantuan duka", "−Rp200.000", "Diakonia", the refusal "… peruntukan Diakonia bukan peruntukan Kolom 7."; "Ubah peruntukan" → Beranda unit.
  6. Panel "Tutup buku bukan wewenang unit" → ribbon, the refusal "Tidak dapat dilakukan: Tutup buku. tutup buku dilakukan Bendahara Jemaat untuk seluruh Jemaat." and the note; no buttons.
  7. After "Catat transaksi", choosing "Peruntukan lain" in the panel shows "Peruntukan lain" (the tweak change resets `k`).
- **Notes**
  - The back arrow targets this board itself. Implemented as a reset plus a no-op route, it does nothing visible in the default view. Keep the board; flag for design (probably meant as the up link to a Keuangan home).
  - "Catat transaksi" leads straight to an already posted record; there is no Catat form on this board. Keep.
  - The Draf cards in `k2`/`k3` have the solid `dibukukan` edge and no Draf badge, against the line language (a Draf is dashed). Keep the board; flag.
  - The `bata` count badge on "Perlu tindakan" breaks ButirPerhatian ("`bata` only for hambatan and failures; Perlu tindakan is a plain card"). Keep; flag.
  - "BKU-2026-0151" is drawn in sans 700. CONVENTIONS makes every code mono; render it mono 16/600 (no 700 cut is bundled), the same size and colour, as recommended in `06-bukti.md`/`07-kejadian.md`.
  - The footnote date 17/11/2026 20.10 is after "today" (16/11/2026). Keep the board's figure; list it in `mock-data.md`.
  - Refusal lines here are 15 px, not 14 (15 is the `isiWeb` size). Copy the board.
  - No 12 px text. Subtitle 14→13.

### SelesaikanUnit — 87 · Hambatan dari unit

- **Source** `docs/design/handoff/canvas/boards/SelesaikanUnit.dc.html` · page Putaran 5 · Kolaborasi (`p5`) · form Phone 390×844 (frame radius 36) · interactive yes
- **Route** `/SelesaikanUnit`, no child routes (five views in place) · **Widget** `SelesaikanUnitScreen` in `lib/screens/p5/selesaikan_unit.dart`
- **Purpose** Bendahara Jemaat journey step 6 ("9 · Bendahara, sesi, serah terima", "Alur · Kas/Bank unit", "87 · Hambatan dari unit"). Meiske Lumentut cannot close October 2026 because Kolom 7 left two things open: a Draf dated 28/10/2026 and an unconfirmed cash reconciliation. She resolves them on the unit's behalf with a mandatory reason, and Bendahara Kolom 7 Deasy Tumbelaka is notified. Both resolutions are listed as exceptions, with the reason, in the close confirmation. Shows:
  - P12 / IsianAlasan: a reason is required for Pindah tanggal and Batalkan.
  - Penolakan: a refusal names the steps that are available.
  - Only months that are Belum ditutup can receive a moved Draf.
  - Resolving for a unit never hides a cash difference: a difference stays a Hambatan until explained.
- **Shell** Phone header with back. Semantics "Kembali ke Tutup buku", up link to `/TutupBuku`. Title "Hambatan dari unit"; subtitle "Supaya satu unit tidak menahan tutup buku seluruh Jemaat". No tab bar.
- **Layout** (body column, gap 16)
  - **"Hambatan"** (`k0`):
    1. Dashed note: bold "Tutup buku Oktober 2026 terhalang 2 hal dari Kolom 7." + `tinta2` "Bendahara Jemaat dapat menyelesaikannya dengan alasan; Bendahara Kolom 7 diberi tahu."
    2. Card. Head row "Draf · Konsumsi ibadah Kolom" + `draf` badge "Draf". Then:
       - 14 `tinta2` "Kolom 7 · bertanggal 28/10/2026 · " followed by mono 14/500 "−Rp150.000" (U+2212; the span sets no colour, so it is `tinta2` too);
       - 13 `tinta3` "Dicatat Deasy Tumbelaka, Bendahara Kolom 7. Menghalangi tutup buku Oktober 2026.";
       - button row: secondary "Pindah tanggal" + secondary "Batalkan" (inside the card, 154 each).
    3. Card. Head row "Rekonsiliasi Kas Kolom 7 · Oktober 2026" (wraps) + `garis` badge "Sedang dikerjakan". Then:
       - info rows "Saldo buku" → "Rp920.000" and "Hasil hitung kas (dicatat unit 31/10/2026)" → "Rp920.000" (mono 14/500);
       - 13 `tinta3` "Bendahara Kolom 7 belum memastikan.";
       - button row: secondary "Pastikan dari hitung kas unit" (316).
  - **"Mengisi alasan"** (`k1`):
    1. Card. Head row "Pindah tanggal · Konsumsi ibadah Kolom" + `draf` "Draf". Then:
       - info row "Tanggal transaksi baru" → "02/11/2026";
       - 13 `tinta3` "Hanya bulan yang Belum ditutup. Draf tetap Draf; tidak ada yang dibukukan."
    2. Textarea "Alasan · wajib", **read-only**, pre-filled "Bendahara Kolom 7 sedang di luar kota; nota baru diterima November."
    3. Button row: primary "Pindah tanggal" + text button "Kembali" (171 each).
  - **"Alasan belum diisi"** (`k2`):
    1. Textarea "Alasan · wajib", read-only, empty. The "Pindah tanggal" card is not shown in this view.
    2. Button row: "Pindah tanggal" in the unmet look (`garis` field, `tinta2` text, min-height 52) + text button "Kembali".
    3. Under the row, 13 `tinta3` "Tidak dapat dilakukan: alasan belum diisi." (plain, not the bold `bata` refusal form).
  - **"Diselesaikan"** (`k3`):
    1. Card. Head row "Konsumsi ibadah Kolom" + `draf` "Draf". Then:
       - 14 `tinta2` "Dipindah ke 02/11/2026";
       - 13 `tinta3` "Diselesaikan oleh Bendahara Jemaat (alasan: Bendahara Kolom 7 sedang di luar kota; nota baru diterima November) · Meiske Lumentut, 16/11/2026 10.40".
    2. Card. Head row "Rekonsiliasi Kas Kolom 7 · Oktober 2026" + `laut` "Sudah dipastikan". Then 13 `tinta3` "Dipastikan dari hitung kas yang dicatat unit. Diselesaikan oleh Bendahara Jemaat (alasan: sama) · 16/11/2026 10.42".
    3. 13 `tinta3` "Pemberitahuan terkirim ke Deasy Tumbelaka. Keduanya tampil di konfirmasi tutup buku di bawah pengecualian, beserta alasannya."
    4. No buttons.
  - **"Ada selisih"** (`k4`):
    1. Card. Head row "Rekonsiliasi Kas Kolom 7 · Oktober 2026" + `garis` "Sedang dikerjakan". Info rows:
       - "Saldo buku" → mono 14/500 "Rp920.000";
       - "Hasil hitung kas" → mono 14/500 "Rp870.000";
       - "Selisih belum dijelaskan" → mono 14/**600** in `bata`: "Rp50.000". The inner span sets no weight, so it inherits the value's 600.
    2. 15 px refusal "Tidak dapat dilakukan: Pastikan rekonsiliasi." + " selisih belum dijelaskan Rp50.000." The amount inside the sentence is sans.
    3. 13 `tinta3` "Menyelesaikan untuk unit tidak pernah menyembunyikan selisih. Selisih tetap menjadi Hambatan sampai dijelaskan."
    4. No buttons.
- **Components**
  - LencanaStatus: "Draf" (`draf`), "Sedang dikerjakan" (`garis`), "Sudah dipastikan" (`laut`).
  - IsianAlasan (read-only textarea), Penolakan, TombolBersyarat look (k2's unmet "Pindah tanggal").
  - Tombol (secondary, primary, text).
  - Card / info rows; GarisStatus `draf` note.
- **Internal views and states** Initial state `{ k: null }`; view = `k ?? keadaan`. Buttons:
  - In `k0`, "Pindah tanggal", "Batalkan" and "Pastikan dari hitung kas unit" all → "Mengisi alasan".
  - In `k1`, "Pindah tanggal" → "Diselesaikan"; "Kembali" → "Hambatan".
  - In `k2`, "Kembali" → "Hambatan"; the grey "Pindah tanggal" does nothing.

  "Alasan belum diisi" and "Ada selisih" are reached only from the panel. Nothing is typed.
- **Tweaks** `keadaan`, Keadaan panel. Options:
  - "Hambatan" (default): the blocker note and two blocker cards.
  - "Mengisi alasan": the move form with the pre-filled reason.
  - "Alasan belum diisi": the empty reason, grey button and the plain refusal.
  - "Diselesaikan": the two resolved cards and the notification note.
  - "Ada selisih": the reconciliation with Rp50.000 difference, refused.

  Changing it resets `k`.
- **Interactions**
  - `go1` from the three `k0` buttons → `k = 'Mengisi alasan'`.
  - `go3` "Pindah tanggal" (primary in `k1`) → `k = 'Diselesaikan'`.
  - `go0` "Kembali" (`k1`, `k2`) → `k = 'Hambatan'`.
  - The `k2` "Pindah tanggal" is HTML `disabled`; make it a pressable no-op with Semantics "disabled" (TombolBersyarat rule), not `onPressed: null`.
  - The textareas are read-only: focusable and selectable, not editable.
  - No timers, no messages.
- **Motion** none (keyframes `masuk`, `pudar`, `muncul`, `isi` declared, unused).
- **Links out**
  - Header back "Kembali ke Tutup buku" → `/TutupBuku`, up link.
  - **Inbound** PetaPlatform ("Ponsel"); BerandaJabatan, the Bendahara Jemaat row "1 hambatan dari unit" (push; a computed row link, `navigation.md` 3.3). TutupBuku does not link here, so the header back does `go('/TutupBuku')` unless TutupBuku is directly below.
- **Mock data**
  - October 2026 being closed.
  - Draf "Konsumsi ibadah Kolom", Kolom 7, dated 28/10/2026, −Rp150.000, recorded by Deasy Tumbelaka, Bendahara Kolom 7; new date 02/11/2026.
  - Rekonsiliasi Kas Kolom 7 · Oktober 2026: Saldo buku Rp920.000; Hasil hitung kas Rp920.000 (recorded by the unit 31/10/2026), or Rp870.000 in "Ada selisih" with Selisih Rp50.000.
  - Reason "Bendahara Kolom 7 sedang di luar kota; nota baru diterima November".
  - Meiske Lumentut, Bendahara Jemaat; 16/11/2026 10.40 and 10.42.
- **Prototype-only** None of the four devices. Keadaan panel: `keadaan`, "Semua layar", inbound links, canvas title.
- **Acceptance checks**
  1. Open:
     - dashed "Tutup buku Oktober 2026 terhalang 2 hal dari Kolom 7. …";
     - the Draf card with a dashed "Draf" badge, "Kolom 7 · bertanggal 28/10/2026 · −Rp150.000" (amount mono), and "Pindah tanggal" / "Batalkan";
     - the reconciliation card "Sedang dikerjakan" with "Pastikan dari hitung kas unit".
  2. "Batalkan" → "Mengisi alasan": "Pindah tanggal · Konsumsi ibadah Kolom", "Tanggal transaksi baru 02/11/2026", and the read-only reason "Bendahara Kolom 7 sedang di luar kota; nota baru diterima November." (typing does not change it).
  3. Primary "Pindah tanggal" → "Diselesaikan":
     - "Dipindah ke 02/11/2026" and "… · Meiske Lumentut, 16/11/2026 10.40";
     - `laut` "Sudah dipastikan" and "… (alasan: sama) · 16/11/2026 10.42";
     - the notification note.
  4. Panel "Alasan belum diisi" → empty textarea, grey "Pindah tanggal" (pressing it does nothing), "Kembali", and below them 13 `tinta3` "Tidak dapat dilakukan: alasan belum diisi."; "Kembali" → Hambatan.
  5. Panel "Ada selisih" → "Rp870.000", the difference "Rp50.000" in `bata` mono, and the 15 px "Tidak dapat dilakukan: Pastikan rekonsiliasi. selisih belum dijelaskan Rp50.000."; no buttons.
  6. Header back → `/TutupBuku`. From `/BerandaJabatan` (panel "Bendahara Jemaat"), the row "1 hambatan dari unit" opens `/SelesaikanUnit`; system Back returns to BerandaJabatan.
- **Notes**
  - "Batalkan" and "Pastikan dari hitung kas unit" both open the Pindah tanggal form. That is a board shortcut; keep it.
  - The `k2` refusal is plain 13 `tinta3` under the buttons, not the Penolakan form above the button. Keep the board; flag.
  - The reason fields are read-only on all states; the prototype does not let the reason be typed. Keep.
  - The "Draf" title prefix and the dashed badge sit on a solid-edged card. Keep.
  - 15 px refusals; no 12 px text. Subtitle 14→13.

### WebSelesaikanUnit — Web · Hambatan dari unit

- **Source** `docs/design/handoff/canvas/boards/WebSelesaikanUnit.dc.html` · page Putaran 5 · Kolaborasi (`p5`) · form Laptop page (preview 1440×1000, `expand: fill`) · interactive yes
- **Route** `/WebSelesaikanUnit`, no child routes · **Widget** `WebSelesaikanUnitScreen` in `lib/screens/p5/web_selesaikan_unit.dart`
- **Purpose** The same blocker resolution as SelesaikanUnit, on the Bendahara Jemaat's laptop (Q26). Same decisions and rules.
- **Shell** Platform web side nav. Active item **Keuangan** (0-based index 1). Footer: bold "Meiske Lumentut" + " · Bendahara Jemaat".
- **Layout**
  1. Title block:
     - breadcrumb "Tutup buku" (up link → `/WebTutupBuku`);
     - h1 "Hambatan dari unit";
     - subtitle "Supaya satu unit tidak menahan tutup buku seluruh Jemaat".
  2. Content column (max-width 1120, gap 16), body size 15:
     - **"Hambatan"**: same blocks as SelesaikanUnit `k0`, stacked in one column. Cards stretch to the full column (1120 at 1440, inner 1086). Their buttons are 340 wide each, left-aligned ("Pindah tanggal" and "Batalkan" side by side; "Pastikan dari hitung kas unit" alone).
     - **"Mengisi alasan"**: a two-column row. Left: the "Pindah tanggal · Konsumsi ibadah Kolom" card. Right: the read-only textarea "Alasan · wajib" with the pre-filled reason, and the button row primary "Pindah tanggal" + text "Kembali" (two buttons in ~484: 238 each).
     - **"Alasan belum diisi"**, **"Diselesaikan"**, **"Ada selisih"**: same blocks as SelesaikanUnit `k2`, `k3`, `k4`, stacked in one column, cards full column width. In "Alasan belum diisi" the empty read-only textarea also spans the whole column (1120 at 1440); the grey "Pindah tanggal" and "Kembali" are 340 each, left-aligned, with the plain 13 `tinta3` line under them.
- **Components** As SelesaikanUnit, plus the platform web side nav.
- **Internal views and states** Same as SelesaikanUnit (initial `{ k: null }`; same buttons and targets).
- **Tweaks** `keadaan` (same five options, default "Hambatan"), Keadaan panel. Same effects; resets `k`.
- **Interactions** Same as SelesaikanUnit, handler for handler. Side nav and the "Menu" toggle work as the shared shell.
- **Motion** none (keyframes `muncul`, `isi`, `titik` declared, unused).
- **Links out**
  - Breadcrumb "Tutup buku" → `/WebTutupBuku`, up link.
  - Side nav, all `go`: the ten items in the shared notes.
  - **Inbound** PetaPlatform ("Web"); WebBerandaJabatan, the Bendahara Jemaat row "1 hambatan dari unit" (push; a computed row link, `navigation.md` 3.3). WebTutupBuku does not link here.
- **Mock data** Same as SelesaikanUnit.
- **Prototype-only** None. Keadaan panel: `keadaan`, "Semua layar", inbound links, canvas title.
- **Acceptance checks**
  1. `/WebSelesaikanUnit` at 1440:
     - nav "Keuangan" on a `tinta` field, footer "Meiske Lumentut · Bendahara Jemaat";
     - breadcrumb "Tutup buku", h1 "Hambatan dari unit";
     - the dashed note and two cards across the 1120 column, with 340-wide buttons.
  2. "Pindah tanggal" → two columns: the card left (~608), the reason and "Pindah tanggal" / "Kembali" right (~484).
  3. Primary "Pindah tanggal" → "Diselesaikan" blocks with "16/11/2026 10.40" and "16/11/2026 10.42".
  4. Panel "Alasan belum diisi" → grey "Pindah tanggal" does nothing; the line "Tidak dapat dilakukan: alasan belum diisi." is under the buttons.
  5. Panel "Ada selisih" → `bata` mono "Rp50.000" and the 15 px refusal.
  6. At 860 → the "Menu" top bar, and "Mengisi alasan" still in two columns. At 390 → stacked, no horizontal scroll.
  7. Breadcrumb → `/WebTutupBuku`; side nav "Keuangan" → `/WebBeranda`; Back returns here in the same view.
- **Notes**
  - Single-block views stretch cards to 1120 px. Keep; flag for design.
  - The same notes as SelesaikanUnit apply. No 12 px text.
