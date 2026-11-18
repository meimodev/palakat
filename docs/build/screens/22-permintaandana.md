# Screens 22: PermintaanDana, Panitia, Ibadah, Kehadiran, LaporanLintas, WebLaporanLintas, PersembahanBernama, WebPersembahanBernama, Kesiapan, WebKesiapan

These ten boards are on the canvas page "Putaran 5 · Kolaborasi" (`p5`). They are the work of units, committees and services around the Bendahara Jemaat. PermintaanDana is a fund request from a unit (Konsumsi Natal Pemuda) and how it is approved. Its back arrow returns to KeuanganUnit, and once approved it sends the payment to the Bendahara Jemaat's Main. Panitia is the life of Panitia Natal 2026 through six stages. It opens AlurPanitiaBaru and DokumenGereja. Ibadah (a Kolom service from Draf to Ditutup, plus a whole-church service) drills into Kehadiran, the people counter that never records names, and Kehadiran's back arrow returns to Ibadah. Ibadah and Panitia are also the "Ibadah dan kegiatan" and "Panitia" items of the platform web side nav, so the web boards (WebLaporanLintas and WebPersembahanBernama among them) open these phone boards in the device frame. LaporanLintas and WebLaporanLintas are the reports across modules, filtered by the reach of each post. PersembahanBernama and WebPersembahanBernama show how a named envelope gets its giver. They are reached from Persembahan and WebPersembahan, and they open the member's PersembahanSaya. Kesiapan and WebKesiapan are the readiness statements per peruntukan before month close. They are reached from TutupBuku, Lainnya and WebTutupBuku (plus the JS-built rows of Cakupan and PetaLayar), and their up link always returns to TutupBuku or WebTutupBuku.

**Shared rules for the eight `keadaan` boards** (all except Kesiapan and WebKesiapan):
- The state is `{ k: null }`, and the view shown is `k ?? keadaan`. An unknown value falls back to the first option.
- In-board buttons set `k` to one option name and do not move the panel's value. Changing `keadaan` in the Keadaan panel, or leaving the route, resets `k` to null.
- Views swap in place under the same header, so there are no child routes. On every view change the scroll area jumps to the top (spec 14's choice).
- Nothing is typed. There are no timers, sheets or toasts, and no view-change animation: the declared keyframes are unused (`masuk`, `pudar`, `muncul`, `isi` on the phone boards; `muncul`, `isi`, `titik` on the web boards).

**Link rules (all ten boards):**
- An "up link" is a phone back arrow or a web breadcrumb. It runs `kembaliKe('/X')`: pop when the route directly beneath is `/X` or a child of `/X`, otherwise `go('/X')`.
- Drill-ins are `push`. Side-nav items are `go`.

**Shared facts for all ten boards:**
- None of them has `jabatanKosong`, so the global switch changes nothing here.
- None of them has a prototype device.
- Today is 16/11/2026 and the church is Jemaat Karunia.

---

### PermintaanDana — 88 · Permintaan dana
- **Source** `docs/design/handoff/canvas/boards/PermintaanDana.dc.html` · page Putaran 5 · Kolaborasi (`p5`) · form Phone 390×844 · interactive yes
- **Route** `/PermintaanDana`, no child routes · **Widget** `PermintaanDanaScreen` in `lib/screens/p5/permintaan_dana.dart`
- **Purpose** The approver of a unit's fund request, here Pdt. Lidya Rondonuwu as Ketua Jemaat for peruntukan Umum Jemaat. It is step 3 of the journey "Pimpinan Jemaat yang berwenang" ("Permintaan dana (approving)") and step 2 of the journey "Bendahara unit and committee officers". It shows these decisions:
  - P09: the approver is set by post in the church's approver table, and a requester never approves their own request.
  - P13: approval is not payment. P13 says the Bendahara Jemaat books an approved request as an advance (Uang Muka diberikan); the board's note calls it "Belanja tersendiri" (see Notes).
  - BertindakSebagai: another post never opens a way to approve one's own submission.
  - KartuPersetujuan: an approval recorded outside the app stays the Bendahara's statement.
  - A request below a church threshold needs no approval. This conflicts with P09; see Notes.
- **Shell** Phone header with back, no tab bar. Root: 390×844, clipped, `kertas` field, `tinta` text, `isi` 16/1.4 (Plus Jakarta Sans). It is a column with a fixed header and a scroll area that fills the rest. Links are `laut`, `lautTua` while pressed. Keyboard focus is a 2 px solid `laut` outline with a 2 px offset. This is the shared phone frame of all seven phone boards in this file (Kesiapan included, whose scroll column gap is 12 instead of 16); it is the same as KeadaanUmum in `17-keadaanumum.md`.
- **Layout**
  1. Header (fixed): a row, centred, gap 8, padding 14 top / 12 sides / 8 bottom.
     - Back target 44×44 with a centred chevron: path `M15 6l-6 6 6 6`, 22 px box on a 24 viewBox, stroke 2, round caps, `tinta`, hidden from semantics. Semantics label "Kembali ke Keuangan".
     - Text column (flex 1): h1 "Permintaan dana" (`judulLayar` 18/700, margin 0), then the subtitle "Minta, periksa, setujui, bayar, verifikasi: lima tindakan yang terpisah" (`keterangan` 13, `tinta2`). The source writes 14 then 13; 13 wins.
  2. Scroll area: vertical scroll, padding 8 top / 20 sides / 20 bottom, so the content is 350 wide. It holds one column with gap 16, and every block below is a direct item of it.

  **Shared parts**: KitAlur (components.md 2.9), built in M1. This file uses it and does not redefine it. Kesiapan and WebKesiapan draw their own cards, specified in their sections. The names used below are KitAlur parts: *fact card* = card (its header row = card head row, a *fact row* = info row, *plain line* and *caption* as in the kit), *status chip* = badge, *button row*, *ink button* = primary, *outline button* = secondary (a button or a link), *text button*, *refusal line*, *terpilih note*, *dashed note*, *text link*. Only these differ on these boards:
  - *Refusal line*: **15 px** (`Penolakan(…, ukuranTeks: 15)`), not the kit's 14.
  - *Fact card*: a money value in a fact row is mono 500.
  - *Ink button*: the boards draw their main action this way, not in `laut`.
  - *Button row* on web (WebPersembahanBernama's right column): one button is 340 wide. Two buttons share the column width minus 8, capped at 340 each: about 238 each at 1440, 208 at 1280, 170 at 860, and 340 each only where the column is 688 or wider (when it has wrapped under the transaction card).

  **Views**, one per `keadaan` option. Each lists the direct items of the gap-16 column.
  - **Menunggu persetujuan** (k0):
    1. Fact card. Title "Permintaan dana · Konsumsi Natal Pemuda". `draf` chip "Menunggu persetujuan".
       - Rows: "Jumlah (Rp)" | mono "Rp1.500.000"; "Diambil dari peruntukan" | "Umum Jemaat"; "Diajukan oleh" | "Sdr. Rivo Mandagi, Ketua Pemuda".
       - Caption: "Pemberi persetujuan menurut tabel Jemaat: Ketua Jemaat untuk peruntukan Umum Jemaat."
    2. Button row: ink "Setujui", then outline "Tidak disetujui", 171 each.
  - **Disetujui** (k1):
    1. The same fact card with a `laut` chip "Disetujui oleh Pdt. Lidya Rondonuwu". Caption: "Disetujui di aplikasi oleh orang yang masuk sendiri, 17/11/2026 09.15."
    2. Dashed note: "**Disetujui bukan berarti sudah dibayar.** Pembayarannya adalah Belanja tersendiri yang dibukukan Bendahara Jemaat."
    3. Button row: outline link "Catat pembayaran" (340 wide).
  - **Tidak disetujui** (k2): the same fact card with a `bata` chip "Tidak disetujui". After the three rows comes the plain line "Alasan: rincian konsumsi belum dilampirkan.", then the caption "Oleh Pdt. Lidya Rondonuwu, 17/11/2026 09.20". There are no buttons.
  - **Kembali menunggu** (k3): the same fact card with a `draf` chip "Menunggu persetujuan". The Jumlah row still reads "Rp1.500.000" (see Notes). Caption: "Jumlah diubah dari Rp1.500.000 menjadi Rp1.800.000 setelah disetujui. Persetujuan lama tidak berlaku lagi dan tetap ada di Riwayat." There are no buttons.
  - **Menyetujui permintaan sendiri** (k4):
    1. The fact card as k0 without its caption: chip, title and three rows only.
    2. Refusal line: "**Tidak dapat dilakukan: Setujui.**" then "permintaan ini Anda ajukan sendiri sebagai Ketua Pemuda."
    3. Caption: "Jabatan Anda yang lain tidak membuka jalan menyetujui permintaan sendiri."
    There are no buttons.
  - **Di bawah batas** (k5): fact card. Title "Permintaan dana · Alat tulis". `garis` chip "Tidak diperlukan". Row "Jumlah (Rp)" | mono "Rp85.000". Caption: "Tidak diperlukan (aturan: di bawah batas Rp250.000 yang ditetapkan Jemaat)."
  - **Persetujuan di luar aplikasi** (k6): fact card. Title "Persetujuan di luar aplikasi". `garis` chip "Persetujuan sudah dicatat".
    - Plain line: "Pemberi persetujuan: Pdt. Lidya Rondonuwu, Ketua BPMJ · 08/11/2026 · notulen rapat".
    - Caption: "Dicatat oleh Meiske L. Catatan lama ini tetap pernyataan Bendahara dan tidak pernah diubah menjadi “Disetujui oleh” di aplikasi."
- **Components**
  - LencanaStatus shapes for the request chips.
  - Penolakan (the self-approval refusal).
  - KartuPersetujuan (k6, recorded: solid line, "Dicatat oleh …").
  - GarisStatus `draf` (dashed note) and `dibukukan` (fact cards).
  - Tombol: ink, outline and outline-link.
  - BertindakSebagai rule in k4.
  - Repeated pattern, not a component: the fact card.
- **Internal views and states** Seven views, one per option, all reached from the tweak. "Disetujui" and "Tidak disetujui" are also reached from k0's buttons. The initial state is `{ k: null }`, so the view is "Menunggu persetujuan".
- **Tweaks** `keadaan` (enum "Menunggu persetujuan" · "Disetujui" · "Tidak disetujui" · "Kembali menunggu" · "Menyetujui permintaan sendiri" · "Di bawah batas" · "Persetujuan di luar aplikasi", default "Menunggu persetujuan") · Keadaan panel. Each option shows the view of the same name, and changing it resets `k`.
- **Interactions**
  - "Setujui" (k0) sets `k = 'Disetujui'`. There is no confirmation step and no timer.
  - "Tidak disetujui" (k0) sets `k = 'Tidak disetujui'`.
  - Buttons give `sentuh` press feedback.
  - There is no typed input, no validation and no TombolBersyarat.
  - The `rp()` helper and the `baris()`/`hal()` helpers are defined and unused.
- **Motion** None. View changes are instant.
- **Links out**
  - Back arrow ("Kembali ke Keuangan") → `/KeuanganUnit`, up link.
  - "Catat pembayaran" (k1) → `/Main`, `go`.
  - **Inbound** AlurDana, PetaPlatform (manifest). The row "Permintaan dana Komisi Diakonia" of BerandaJabatan and WebBerandaJabatan also opens it; those rows are built in JS (spec 14).
- **Mock data**
  - The request "Konsumsi Natal Pemuda": Rp1.500.000, changed to Rp1.800.000 in k3; peruntukan Umum Jemaat; requested by Sdr. Rivo Mandagi, Ketua Pemuda.
  - The approver Pdt. Lidya Rondonuwu (Ketua Jemaat, Ketua BPMJ). Approved 17/11/2026 09.15. Refused 17/11/2026 09.20 with the reason "rincian konsumsi belum dilampirkan".
  - The request "Alat tulis" Rp85.000, with the threshold Rp250.000.
  - An outside approval of 08/11/2026 from "notulen rapat", recorded by Meiske L.
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/PermintaanDana` and the header reads "Permintaan dana". The fact card shows a dashed chip "Menunggu persetujuan", "Rp1.500.000" in mono, "Umum Jemaat" and "Sdr. Rivo Mandagi, Ketua Pemuda". "Setujui" (`tinta`) and "Tidak disetujui" (outline) sit side by side, 171 wide each.
  2. Tap "Setujui" and the chip turns `laut` with "Disetujui oleh Pdt. Lidya Rondonuwu". The caption ends "17/11/2026 09.15.", the dashed note "Disetujui bukan berarti sudah dibayar." appears, and so does "Catat pembayaran" (340 wide). The panel still shows "Menunggu persetujuan".
  3. "Catat pembayaran" → `/Main` (go).
  4. From the start, tap "Tidak disetujui" to get a `bata` outline chip, "Alasan: rincian konsumsi belum dilampirkan." and "Oleh Pdt. Lidya Rondonuwu, 17/11/2026 09.20". No button is shown.
  5. Panel "Menyetujui permintaan sendiri" shows "Tidak dapat dilakukan: Setujui." in `bata`, the cause in `tinta`, and no "Setujui" button.
  6. Panel "Di bawah batas" shows "Permintaan dana · Alat tulis", the chip "Tidak diperlukan" with a `tinta3` line, and "Rp85.000".
  7. Panel "Persetujuan di luar aplikasi" shows the chip "Persetujuan sudah dicatat" and the curly-quoted “Disetujui oleh”.
  8. After "Setujui", set the panel to "Tidak disetujui" and that view shows (`k` reset). The back arrow goes to `/KeuanganUnit`.
  9. At 390 wide, no view overflows horizontally, including the long `laut` chip in "Disetujui".
- **Notes**
  - **Chip overflow.** On the phone the header row's chip is `flex: none`. "Disetujui oleh Pdt. Lidya Rondonuwu" (about 290 px) plus the longest title word overflows the 316 px card on the canvas. Build every fact-card header in this file as a title (flexible, wrapping) plus a chip. When the chip and the title's longest word do not fit, the chip drops under the title, left-aligned, 6 px below. Never overflow. The same applies to Panitia's "Disetujui oleh Meiske Lumentut" and this board's "Persetujuan sudah dicatat".
  - **Two amounts in "Kembali menunggu".** The Jumlah row shows Rp1.500.000 while the caption says the amount became Rp1.800.000. Keep the board as drawn and flag it for design review.
  - **Threshold against P09.** "Di bawah batas" states a church threshold of Rp250.000, while P09 says "No amount limits". Keep the board.
  - **Refusals without a step.** The refusal in k4 offers no available step (Penolakan asks for one), and "Kembali menunggu" has no "Setujui" button. Keep both as drawn.
  - **Dates after today.** Both approval dates (17/11/2026) are after today (16/11/2026). Keep.
  - **Payment link.** "Catat pembayaran" jumps into the Bendahara Jemaat's finance home (P13: the Bendahara Jemaat books the payment), not to a payment form.
  - **Belanja against P13.** The dashed note in "Disetujui" says "Pembayarannya adalah Belanja tersendiri", while P13 says an approved request is always booked as an advance (Uang Muka diberikan). Keep the board's words and flag them.
  - **`bata` for a refusal by the approver.** The "Tidak disetujui" chip uses the `bata` shape, which GarisStatus and ButirPerhatian keep for hambatan and kegagalan. Keep the board.
  - The manifest's `hasSideNav: true` is a false positive (the class only checks `navVals`).

### Panitia — 89 · Panitia Natal 2026
- **Source** `docs/design/handoff/canvas/boards/Panitia.dc.html` · page Putaran 5 · Kolaborasi (`p5`) · form Phone 390×844 · interactive yes
- **Route** `/Panitia`, no child routes · **Widget** `PanitiaScreen` in `lib/screens/p5/panitia.dart`
- **Purpose** Committee officers and the Pimpinan Jemaat yang berwenang. It is step 3 ("Panitia Natal 2026") of the journey "Bendahara unit and committee officers". It shows:
  - P15: a Panitia is formed from a written decision (SK in Dokumen gereja) with three different officers. It starts in Perencanaan and cannot book until activated.
  - P16: it is closed once advances are accounted for and leftover money is returned to the general fund (here "Alih peruntukan ke Umum Jemaat"). The asset handover is attached and does not block closing.
  - Tahapan: the stages of a Panitia.
  - Penolakan: no ordinary booking during financial closing.
  - The rule that an archived Panitia is read-only and never deleted.
  - Q26: phone only. The web side nav item "Panitia" opens this phone board.
- **Shell** Phone header with back (the shared phone frame defined under PermintaanDana). Back semantics label "Kembali ke Beranda". h1 "Panitia Natal 2026"; subtitle "Unit sementara dengan peruntukannya sendiri".
- **Layout** Scroll column, gap 16, with the views below. Every view starts with the stage row.
  - *Stage row* (Tahapan): a row that wraps, gap 6. Six chips: "1 · Perencanaan", "2 · Aktif", "3 · Acara selesai", "4 · Penutupan keuangan", "5 · Ditutup", "6 · Diarsipkan". Each chip has min-height 30, padding 0 10, radius 999 and 13/700 text, with the label centred vertically.
    - A reached stage has a `tinta` field, `permukaan` text and a 1.5 solid `tinta` line.
    - A stage not reached has no field, `tinta3` text and a 1.5 dashed `putus` line.
    - Reached stages per view: Perencanaan 1; Aktif 1–2; Penutupan keuangan 1–4; Sisa uang 1–4; Ditutup 1–5; Diarsipkan 1–6.
  - *Committee card* (fact card without a chip): title "Panitia Natal 2026".
    - Rows: "Ketua" | "Sdr. Stevi Lengkong"; "Sekretaris" | "Sdri. Natalia Rumengan"; "Bendahara" | "Sdr. Rivo Mandagi"; "Peruntukan" | "Panitia Natal"; "Dasar" | "SK BPMJ No. 11/2026 · Dokumen gereja".

  **Views:**
  - **Perencanaan** (k0):
    1. Stage row.
    2. Committee card.
    3. Caption: "Dibuat oleh Pimpinan Jemaat yang berwenang dari SK-nya. Hanya ia yang memindahkan tahap."
    4. Text link "Membentuk Panitia baru".
  - **Aktif** (k1):
    1. Stage row.
    2. Committee card.
    3. Fact card. Header: "Saldo buku peruntukan Panitia Natal" (700) | mono "Rp4.350.000". Caption: "Bendahara Panitia membukukan di peruntukan ini, pada Kas Panitia Natal yang dikelolanya."
  - **Penutupan keuangan** (k2):
    1. Stage row.
    2. Fact card. Header: "Sisa uang" | mono "Rp650.000".
       - Rows: "Uang Muka belum dipertanggungjawabkan" | mono "Rp0"; "Aset tersisa" | "2 lampu sorot, 1 pohon Natal".
    3. Refusal line: "**Tidak dapat dilakukan: Bukukan.**" then "Panitia Natal 2026 sedang dalam Penutupan keuangan."
    4. Caption: "Sejak tahap ini Bendahara Panitia tidak membukukan transaksi biasa. Sisa uang dan aset harus punya tujuan yang disetujui."
  - **Sisa uang** (k3):
    1. Stage row.
    2. Fact card. Header "Sisa uang Rp650.000", all in sans 700 (see Notes), with a `laut` chip "Disetujui oleh Meiske Lumentut".
       - Row "Tujuan" | "Alih peruntukan ke Umum Jemaat".
       - Caption "Tujuan sisa uang disetujui Bendahara Jemaat, 05/01/2027."
    3. Fact card. Header "Serah terima aset" with a `tinta` chip "Diterbitkan".
       - Plain line "Dokumen gereja · Serah terima aset panitia · kepada Komisi Pembangunan".
       - Text link "Buka di Dokumen gereja", inside the card as its last item.
  - **Ditutup** (k4):
    1. Stage row.
    2. Fact card. Header "Laporan pertanggungjawaban akhir" with a `tinta` chip "Diterbitkan". Caption "Peruntukan Panitia Natal bersaldo Rp0 dan dinonaktifkan untuk transaksi baru."
  - **Diarsipkan** (k5):
    1. Stage row (all six filled).
    2. Terpilih note: "**Hanya baca.** Panitia yang sudah diarsipkan tidak dihapus; riwayat keuangan dan dokumennya tetap dapat dibuka."
- **Components**
  - Tahapan (stage row).
  - LencanaStatus shapes ("Disetujui oleh …", "Diterbitkan").
  - Penolakan.
  - GarisStatus `dibukukan` (cards) and `terpilih` (read-only note).
  - Text links.
  - Patterns, not components: the fact card and the committee card.
- **Internal views and states** Six views, reached only from the tweak; no button changes the view. The initial state is `{ k: null }`, so the view is "Perencanaan". Stage 3 "Acara selesai" has no view of its own.
- **Tweaks** `keadaan` (enum "Perencanaan" · "Aktif" · "Penutupan keuangan" · "Sisa uang" · "Ditutup" · "Diarsipkan", default "Perencanaan") · Keadaan panel. Each option shows the view of the same name, with the stage row filled as listed.
- **Interactions** No handlers are bound; `go0`–`go5` exist and are unused. The only pressable items are the links and the back arrow. There is no typed input.
- **Motion** None.
- **Links out**
  - Back arrow ("Kembali ke Beranda") → `/BerandaJabatan`, up link.
  - "Membentuk Panitia baru" (k0) → `/AlurPanitiaBaru`, `push`. Its back arrow returns here.
  - "Buka di Dokumen gereja" (k3) → `/DokumenGereja`, `push`.
  - **Inbound** AlurPanitia, AlurPanitiaBaru, PetaPlatform, and the "Panitia" side-nav item of 30 platform web boards: WebAkunSaya, WebAlurDokumen, WebAlurJabatanKosong, WebAlurKeluarga, WebAlurMasuk, WebAlurPengembalian, WebAlurPulihkan, WebAlurSurat, WebAlurUnit, WebAlurWarta, WebBerandaJabatan, WebBukaNama, WebCariOrang, WebDataAnggota, WebDataGanda, WebDokumenGereja, WebImporBuku, WebJabatanKosong, WebKasUnit, WebKeadaanUmum, WebKotakMasuk, WebLaporanLintas, WebPengumuman, WebPenugasan, WebPermohonanSurat, WebPersembahanBernama, WebSelesaikanUnit, WebTerbitDokumen, WebWartaArsip, WebWartaEditor.
- **Mock data**
  - Panitia Natal 2026: Ketua Sdr. Stevi Lengkong, Sekretaris Sdri. Natalia Rumengan, Bendahara Sdr. Rivo Mandagi. Peruntukan Panitia Natal on SK BPMJ No. 11/2026, with Kas Panitia Natal.
  - Money: Saldo buku Rp4.350.000; Sisa uang Rp650.000; Uang Muka outstanding Rp0; final balance Rp0.
  - Assets "2 lampu sorot, 1 pohon Natal", handed over to Komisi Pembangunan.
  - The destination of the leftover money, approved by Meiske Lumentut on 05/01/2027.
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/Panitia` and the stage row shows "1 · Perencanaan" filled `tinta` and five dashed chips. The committee card lists the three officers, and "Membentuk Panitia baru" is shown.
  2. "Membentuk Panitia baru" → `/AlurPanitiaBaru` (push), and its back returns to `/Panitia`.
  3. Panel "Aktif" shows two filled stages and "Saldo buku peruntukan Panitia Natal" with "Rp4.350.000" in mono.
  4. Panel "Penutupan keuangan" shows four filled stages, "Rp650.000", "Rp0", the assets line, and "Tidak dapat dilakukan: Bukukan." in `bata`.
  5. Panel "Sisa uang" shows a `laut` chip "Disetujui oleh Meiske Lumentut" that does not overflow the card. "Buka di Dokumen gereja" → `/DokumenGereja`.
  6. Panel "Ditutup" shows five filled stages and "Laporan pertanggungjawaban akhir" with a `tinta` chip "Diterbitkan".
  7. Panel "Diarsipkan" shows all six stages filled and the 1.5 `tinta` note starting "Hanya baca."
  8. Back arrow → `/BerandaJabatan`.
- **Notes**
  - **Sans money figure.** "Sisa uang Rp650.000" in k3 is one sans 700 string. CONVENTIONS asks for mono money, but the board wins: keep it sans, and flag it.
  - **Sans SK number.** "SK BPMJ No. 11/2026" is a document reference and stays sans as drawn.
  - **Current stage is filled.** The current stage chip is filled like a done one; Tahapan has no separate "current" look. Keep.
  - **Approval after today.** The approval date 05/01/2027 is after today. Keep.
  - **Chip overflow.** The chip in k3 follows the chip-wrap rule in PermintaanDana's Notes.
  - The manifest's `hasSideNav: true` is a false positive.

### Ibadah — 90 · Ibadah dan kegiatan
- **Source** `docs/design/handoff/canvas/boards/Ibadah.dc.html` · page Putaran 5 · Kolaborasi (`p5`) · form Phone 390×844 · interactive yes
- **Route** `/Ibadah`, no child routes · **Widget** `IbadahScreen` in `lib/screens/p5/ibadah.dart`
- **Purpose** The Penatua Kolom (Pnt. Hendrik Rumagit), step 3 of the journey "Penatua Kolom": "Ibadah dan kegiatan", then "Jumlah kehadiran". It shows:
  - The life cycle of a service: Draf, Dijadwalkan, Sedang berlangsung, Selesai, Ditutup.
  - Approval by the Penatua or Syamas of the Kolom it is meant for. A whole-church service or a Panitia activity is approved by the Ketua Jemaat, or by the Sekretaris Jemaat when there is none.
  - That the approver also assigns the attendance counter.
  - That there is no list of service officers.
  - Q26: phone only, also opened from the web side nav item "Ibadah dan kegiatan".
- **Shell** Phone header with back (shared phone frame). Back label "Kembali ke Beranda". h1 "Ibadah dan kegiatan"; subtitle "Jadwal dan persetujuan; tanpa daftar petugas pelayanan".
- **Layout** Scroll column, gap 16.
  - *Service card* (fact card), used by the first five views. Title "Ibadah Kolom 7" with a status chip.
    - Rows: "Jenis" | "Ibadah Kolom"; "Waktu" | "Kamis, 19/11/2026 19.00"; "Ditujukan untuk" | "Kolom 7"; "Tempat" | "Kel. Wenas-Lasut".
    - Then one caption per view.

  **Views:**
  - **Draf** (k0):
    1. Service card. `draf` chip "Draf". Caption "Disetujui oleh Penatua atau Syamas dari Kolom yang dituju: Pnt. Hendrik Rumagit atau Sym. Greis Mamahit."
    2. Button row: ink "Setujui dan jadwalkan" (340 wide).
  - **Dijadwalkan** (k1):
    1. Service card. `lautg` chip "Dijadwalkan". Caption "Disetujui oleh Pnt. Hendrik Rumagit, 16/11/2026. Yang menyetujui juga menugaskan petugas penghitung kehadiran."
    2. Button row: outline link "Tugaskan penghitung kehadiran".
  - **Sedang berlangsung** (k2):
    1. Service card. `laut` chip "Sedang berlangsung". Caption "Jumlah kehadiran sedang dihitung."
    2. Button row: outline link "Buka jumlah kehadiran".
  - **Selesai** (k3): service card. `garis` chip "Selesai". Caption "Jumlah kehadiran: Sudah diperiksa, belum Ditetapkan." There is no button.
  - **Ditutup** (k4): service card. `tinta` chip "Ditutup". Caption "Jumlah kehadiran Ditetapkan: 38 orang. Persembahan dicatat di Keuangan sebagai Persembahan Ibadah Kolom." There is no button.
  - **Ibadah seluruh Jemaat** (k5): fact card. Title "Ibadah Minggu Adven I" with a `lautg` chip "Dijadwalkan".
    - Rows: "Waktu" | "Minggu, 29/11/2026 · Subuh, Pagi, Malam"; "Ditujukan untuk" | "Semua anggota". There are no Jenis or Tempat rows.
    - Caption "Ibadah seluruh Jemaat dan kegiatan Panitia disetujui oleh Ketua Jemaat: Pdt. Lidya Rondonuwu, 15/11/2026. Bila tidak ada Ketua Jemaat: Sekretaris Jemaat atau yang ditunjuk."
    - There is no button.
- **Components**
  - LencanaStatus shapes (Draf dashed, Dijadwalkan `laut` line, Sedang berlangsung `laut` field, Selesai `tinta3` line, Ditutup `tinta` field).
  - Tombol (ink, outline link).
  - GarisStatus `dibukukan`.
  - Pattern, not a component: the fact card.
- **Internal views and states** Six views from the tweak. "Dijadwalkan" is also reached from "Setujui dan jadwalkan". The initial state is `{ k: null }`, so the view is "Draf".
- **Tweaks** `keadaan` (enum "Draf" · "Dijadwalkan" · "Sedang berlangsung" · "Selesai" · "Ditutup" · "Ibadah seluruh Jemaat", default "Draf") · Keadaan panel. Each option shows the view of the same name, and changing it resets `k`.
- **Interactions** "Setujui dan jadwalkan" sets `k = 'Dijadwalkan'` immediately, with no confirmation and no timer. There is no typed input.
- **Motion** None.
- **Links out**
  - Back arrow → `/BerandaJabatan`, up link.
  - "Tugaskan penghitung kehadiran" (k1) → `/Kehadiran`, `push`.
  - "Buka jumlah kehadiran" (k2) → `/Kehadiran`, `push`.
  - **Inbound** AlurIbadah, Kehadiran, PetaPlatform, and the "Ibadah dan kegiatan" side-nav item of the same 30 platform web boards listed under Panitia. The JS-built row "Ibadah Kolom 7, 19/11/2026" of BerandaJabatan and WebBerandaJabatan also opens it.
- **Mock data**
  - "Ibadah Kolom 7": an Ibadah Kolom on Kamis, 19/11/2026 19.00 for Kolom 7 at Kel. Wenas-Lasut.
  - Approvers Pnt. Hendrik Rumagit and Sym. Greis Mamahit. Approved 16/11/2026. Attendance 38 orang.
  - "Ibadah Minggu Adven I" on Minggu, 29/11/2026, at the Subuh, Pagi and Malam services, for Semua anggota. Approved by Pdt. Lidya Rondonuwu on 15/11/2026.
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/Ibadah` and the card "Ibadah Kolom 7" shows a dashed chip "Draf", the four rows, and the ink button "Setujui dan jadwalkan" 340 wide.
  2. Tap it and the chip becomes "Dijadwalkan" (`laut` line, `laut` text), with the caption "Disetujui oleh Pnt. Hendrik Rumagit, 16/11/2026. …" and "Tugaskan penghitung kehadiran".
  3. "Tugaskan penghitung kehadiran" → `/Kehadiran` (push). Kehadiran's back returns to `/Ibadah`.
  4. Panel "Sedang berlangsung" shows a `laut`-filled chip and "Buka jumlah kehadiran" → `/Kehadiran`.
  5. Panel "Ditutup" shows a `tinta` chip and "Jumlah kehadiran Ditetapkan: 38 orang. …", with no button.
  6. Panel "Ibadah seluruh Jemaat" shows "Ibadah Minggu Adven I" with only the Waktu and Ditujukan untuk rows.
  7. Back arrow → `/BerandaJabatan`.
- **Notes**
  - **Different services.** Kehadiran shows "Ibadah Minggu pagi · 15/11/2026", not the Ibadah Kolom 7 this board links from. Each board keeps its own data.
  - **Dates after today.** The views Sedang berlangsung, Selesai and Ditutup keep the date 19/11/2026, which is after today. Keep.
  - **Ink main action.** The main action is ink (`tinta`), not the `laut` primary of Tombol. Keep the board.
  - **Link opens the default view.** "Tugaskan penghitung kehadiran" opens Kehadiran in its default view ("Sedang dihitung"), not "Petugas penghitung". Keep (a plain link).

### Kehadiran — 91 · Jumlah kehadiran
- **Source** `docs/design/handoff/canvas/boards/Kehadiran.dc.html` · page Putaran 5 · Kolaborasi (`p5`) · form Phone 390×844 · interactive yes
- **Route** `/Kehadiran`, no child routes · **Widget** `KehadiranScreen` in `lib/screens/p5/kehadiran.dart`
- **Purpose** The attendance counter (petugas penghitung) and the Penatua Kolom who checks and confirms the count. It is step 3 of the journey "Penatua Kolom". It shows:
  - Attendance is counted as people, never names: no named attendance list, no absent list, no score per person.
  - Counts per door stay separate inside, and reports use only the total.
  - The steps Sedang dihitung, Sudah diperiksa, Ditetapkan. Only a confirmed count goes into Warta Jemaat and reports.
  - A correction keeps both values.
  - The counter cannot confirm (Penolakan).
- **Shell** Phone header with back (shared phone frame). Back label "Kembali ke Ibadah dan kegiatan". h1 "Jumlah kehadiran"; subtitle "Menghitung orang, tidak pernah mencatat nama".
- **Layout** Scroll column, gap 16.
  1. *Count card* (fact card), shown in the views Sedang dihitung, Sudah diperiksa and Ditetapkan (`atas = ki < 3`).
     - Header: "Ibadah Minggu pagi · 15/11/2026" with a status chip. The chip is `laut` "Sedang dihitung" in k0, `lautg` "Sudah diperiksa" in k1, and `tinta` "Ditetapkan" in k2.
     - Rows: "Pintu depan · Yanti S." | mono 500 `{n}` (initially "142"); "Pintu samping · Greis M." | mono 500 "89".
     - Total row: 16/700, a 1.5 solid `tinta` line on top, padding-top 6, space-between, gap 16. "Jumlah" on the left; on the right mono **500** `{n + 89}` (initially "231").
     - Caption "Jumlah per pos tetap terpisah di dalam; yang dipakai laporan hanya jumlahnya."
  2. View blocks:
     - **Sedang dihitung** (k0):
       - *Counter card*: `permukaan` field, 1 px `garis` line, radius 14, padding 12/16, a row centred vertically with gap 12.
         - "Pintu depan" (flex 1, 600).
         - Minus button: 44×44, radius 12, 1.5 `garisTegas` line, `permukaan` field, `tinta` "−" (U+2212) 22/600 centred, semantics "Kurangi satu".
         - Value: mono 20/600, min-width 48, centred, `{n}`.
         - Plus button: 44×44, radius 12, no border, `tinta` field, `permukaan` "+" 22/600, semantics "Tambah satu".
       - Button row: outline button "Kirim untuk diperiksa" (340 wide).
     - **Sudah diperiksa** (k1): caption "Diperiksa oleh Pnt. Hendrik Rumagit, yang menyetujui ibadah ini.", then a button row with ink "Tetapkan" and text button "Kembalikan ke penghitung", 171 each.
     - **Ditetapkan** (k2): caption "Ditetapkan oleh Pnt. Hendrik Rumagit, 15/11/2026 11.20. Hanya jumlah yang Ditetapkan masuk ke Warta Jemaat dan laporan."
     - **Koreksi** (k3), with no count card:
       - Fact card "Koreksi jumlah" with a `tinta` chip "Ditetapkan".
       - Rows: "Jumlah semula" | mono "231"; "Jumlah koreksi" | mono "236".
       - Plain line "Alasan: lembar pos balkon terlambat diserahkan."
       - Caption "Oleh Pnt. Hendrik Rumagit, 16/11/2026 08.05. Kedua nilai disimpan."
     - **Petugas penghitung** (k4), with no count card:
       - Terpilih note: "**Petugas penghitung kehadiran** untuk ibadah ini saja. Anda dapat menghitung; memeriksa dan menetapkan dilakukan yang menyetujui ibadah."
       - Refusal line: "**Tidak dapat dilakukan: Tetapkan.**" then "penghitung tidak menetapkan jumlah."
  3. Footer caption in every view, last: "Tidak ada daftar hadir bernama, daftar yang tidak hadir, atau nilai kehadiran per orang."
- **Components**
  - LencanaStatus shapes (Sedang dihitung `laut` field, Sudah diperiksa `laut` line, Ditetapkan `tinta` field).
  - Tombol (ink, outline, text).
  - Penolakan.
  - GarisStatus `terpilih` and `dibukukan`.
  - Patterns, not components: the stepper counter (no design-system component; PenghitungPecahan is for cash denominations, not this) and the fact card with a `tinta` total rule.
- **Internal views and states** Five views. The initial state is `{ k: null }`; the count is `state.n`, absent at start, which reads as 142.
  - "Sudah diperiksa" is reached from "Kirim untuk diperiksa".
  - "Ditetapkan" is reached from "Tetapkan".
  - "Sedang dihitung" is reached from "Kembalikan ke penghitung".
  - "Koreksi" and "Petugas penghitung" are reached only from the tweak.
  - `n` survives view changes and tweak changes. It resets to 142 only when the route is left.
- **Tweaks** `keadaan` (enum "Sedang dihitung" · "Sudah diperiksa" · "Ditetapkan" · "Koreksi" · "Petugas penghitung", default "Sedang dihitung") · Keadaan panel. Each option shows the view of the same name. The first three show the count card with the chip listed above; the last two hide it. Changing the tweak resets `k` and keeps `n`.
- **Interactions**
  - "+" sets `n = n + 1`.
  - "−" sets `n = max(0, n − 1)`, so it never goes below 0.
  - Both update the counter value, the "Pintu depan · Yanti S." row and "Jumlah" at once.
  - "Kirim untuk diperiksa" sets `k = 'Sudah diperiksa'`.
  - "Tetapkan" sets `k = 'Ditetapkan'`.
  - "Kembalikan ke penghitung" sets `k = 'Sedang dihitung'`.
  - Every button gives `sentuh` press feedback.
  - There are no timers, no typed input and no long-press repeat.
  - The counted value is not frozen after "Ditetapkan": returning to "Sedang dihitung" through the tweak lets it be counted again. This is canvas behaviour; keep it.
- **Motion** None. Number changes are instant.
- **Links out**
  - Back arrow ("Kembali ke Ibadah dan kegiatan") → `/Ibadah`, up link.
  - **Inbound** Ibadah, PetaPlatform.
- **Mock data**
  - "Ibadah Minggu pagi · 15/11/2026".
  - Pintu depan, counted by Yanti S.: 142 at start. Pintu samping, counted by Greis M.: 89. Total 231.
  - Checker and confirmer Pnt. Hendrik Rumagit. Confirmed 15/11/2026 11.20.
  - Correction from 231 to 236 on 16/11/2026 08.05, with the reason "lembar pos balkon terlambat diserahkan".
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/Kehadiran` and the count card shows the chip "Sedang dihitung" on `laut`, "142", "89" and "Jumlah" "231" under a 1.5 `tinta` rule. The counter shows "142" between "−" and "+".
  2. Tap "+" three times and the counter, the Pintu depan row and Jumlah read "145", "145" and "234".
  3. "Kirim untuk diperiksa" changes the chip to "Sudah diperiksa" (`laut` line). The counter card is gone, Jumlah still reads "234", and "Tetapkan" and "Kembalikan ke penghitung" are shown.
  4. "Kembalikan ke penghitung" brings the counter back, still showing "145".
  5. "Kirim untuk diperiksa", then "Tetapkan", shows a `tinta` chip "Ditetapkan", the caption "Ditetapkan oleh Pnt. Hendrik Rumagit, 15/11/2026 11.20. …", and no buttons.
  6. Panel "Koreksi" shows no count card, and "Koreksi jumlah" shows 231 and 236 in mono.
  7. Panel "Petugas penghitung" shows the terpilih note and "Tidak dapat dilakukan: Tetapkan.", with no counter.
  8. The footer caption "Tidak ada daftar hadir bernama, …" is in every view.
  9. "−" pressed repeatedly never shows a negative number.
  10. Back arrow → `/Ibadah`.
- **Notes**
  - **Hard-coded correction.** "Jumlah semula 231" in Koreksi is a fixed value and does not follow `n`.
  - **Chip colours.** The `laut` field on "Sedang dihitung" differs from LencanaStatus "Sedang dikerjakan" (`tinta3` line). Keep the board.
  - **Off-token sizes.** Counter sizes 20 and 22 px are off-token; copy them.
  - **Live count.** Give the counter value `Semantics(liveRegion: true)` so the new count is read out. The board has no aria-live; this adds no visible change.

### LaporanLintas — 92 · Laporan
- **Source** `docs/design/handoff/canvas/boards/LaporanLintas.dc.html` · page Putaran 5 · Kolaborasi (`p5`) · form Phone 390×844 · interactive yes
- **Route** `/LaporanLintas`, no child routes · **Widget** `LaporanLintasScreen` in `lib/screens/p5/laporan_lintas.dart`
- **Purpose** Any post that reads reports across modules: Ketua Jemaat, Penatua Kolom 7, Panitia officers. It shows:
  - Q25: what a person sees follows their posts. The data is filtered by the reach of each post.
  - D30: reports read on the phone as stacked cards.
  - The rule that there is no free report builder, and that reports never contain attendance per person or attendance combined with offerings.
  - Only confirmed (Ditetapkan) attendance and only booked money are counted.
  - A switched-off module makes its reports disappear while finance reports remain.
- **Shell** Phone header with back (shared phone frame). Back label "Kembali ke Beranda". h1 "Laporan"; subtitle "Dari data yang sah, disaring menurut jangkauan tiap jabatan".
- **Layout** Scroll column, gap 16.
  1. *Dimension chips*: a row that wraps, gap 8. Seven static chips: "Jemaat", "Kolom", "BIPRA", "Komisi", "Panitia", "Peruntukan", "Kas/Bank".
     - Each chip: min-height 44, padding 0 14, radius 999, 1.5 solid `garisTegas`, `permukaan` field, 14/600 `tinta`, label centred vertically.
     - None is selected and none is pressable: they are spans. On 350 width they wrap, by estimate to two lines ("Jemaat" to "Komisi", then "Panitia" to "Kas/Bank"); let the row wrap naturally rather than fixing a line count.
  2. *Stats grid* (only when `adaStat = ki < 2`, that is Seluruh Jemaat and Kolom 7): a grid with `repeat(auto-fit, minmax(300, 1fr))`, gap 16, items top-aligned. On the phone that is one column of four cards, each 350 wide.
     - Each stat card: `permukaan`, 1 px `garis`, radius 14, padding 14/16, a column with gap 6. Label 13 `tinta3`; value mono 26/500; sub-line 13 `tinta3`.
     - Cards in order:
       - "Anggota aktif" | `{s0}` | `{k0t}`
       - "Keluarga" | `{s1}` | "dengan riwayat Kolom"
       - "Peristiwa diverifikasi · November 2026" | `{s2}` | "2 kelahiran · 3 baptisan · 1 pernikahan · 1 kematian"
       - "Jumlah kehadiran Minggu 15/11/2026" | `{s3}` | "hanya yang Ditetapkan"
     - Values per view: Seluruh Jemaat s0 "1.284", k0t "di 12 Kolom", s1 "412", s2 "7", s3 "412". Kolom 7 s0 "96", k0t "Kolom 7 saja", s1 "31", s2 "2", s3 "38".
  3. *Money card* (fact card, always shown). Header: `{uj}` 700 | mono 500 `{uv}`. Caption `{uk}`. Values per view:
     - Seluruh Jemaat: "Saldo buku semua Kas/Bank" · "Rp38.415.000" · "Keuangan · hanya yang sudah dibukukan".
     - Kolom 7: "Saldo buku peruntukan Kolom 7" · "Rp1.240.000" · "Keuangan unit · Kas Kolom 7".
     - Panitia Natal 2026: "Saldo buku peruntukan Panitia Natal" · "Rp4.350.000" · "Panitia · tahap Aktif".
     - Modul tidak aktif: as Seluruh Jemaat.
  4. *Module-off note* (only in Modul tidak aktif): a dashed note "**Data jemaat dan Jumlah kehadiran belum aktif.** Laporannya tidak tampil. Laporan keuangan tetap tersedia."
  5. Footer caption, always shown: "Tidak ada penyusun laporan bebas. Laporan tidak pernah memuat kehadiran per orang atau gabungan kehadiran dengan persembahan."
- **Components**
  - ChipPilihan, unselected look only, static.
  - GarisStatus `dibukukan` (stat and money cards) and `draf` (module-off note).
  - LencanaModul rule (module off).
  - Patterns, not components: the stat card (label / big mono value / sub-line) and the auto-fit card grid.
- **Internal views and states** Four views, from the tweak only. The initial state is `{ k: null }`, so the view is "Seluruh Jemaat". What each view shows:
  - Seluruh Jemaat and Kolom 7: stats, then money.
  - Panitia Natal 2026: money only.
  - Modul tidak aktif: money, then the note.
- **Tweaks** `keadaan` (enum "Seluruh Jemaat" · "Kolom 7" · "Panitia Natal 2026" · "Modul tidak aktif", default "Seluruh Jemaat") · Keadaan panel. Each option sets the reach as listed in Layout.
- **Interactions** None: no handlers are bound, and the chips are not pressable. The only control is the back arrow.
- **Motion** None.
- **Links out**
  - Back arrow → `/BerandaJabatan`, up link.
  - **Inbound** PetaPlatform.
- **Mock data** As in Layout:
  - Seluruh Jemaat: 1.284 active members in 12 Kolom; 412 families; 7 verified events in November 2026 (2 births, 3 baptisms, 1 marriage, 1 death); attendance 412 on Sunday 15/11/2026.
  - Kolom 7: 96 members, 31 families, 2 events, attendance 38.
  - Book balances: Rp38.415.000 for all Kas/Bank, the same as WebBeranda and BerandaJabatan; Kolom 7 Rp1.240.000, the same as KeuanganUnit; Panitia Natal Rp4.350.000, the same as Panitia.
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/LaporanLintas` and seven chips appear, with no chip selected and none pressable. Four stat cards are stacked: "1.284" with "di 12 Kolom", "412", "7", "412". The money card reads "Saldo buku semua Kas/Bank" "Rp38.415.000".
  2. Panel "Kolom 7" shows the stats "96" with "Kolom 7 saja", "31", "2", "38", and the money card "Saldo buku peruntukan Kolom 7" "Rp1.240.000".
  3. Panel "Panitia Natal 2026" shows no stat cards and the money card "Saldo buku peruntukan Panitia Natal" "Rp4.350.000" with "Panitia · tahap Aktif".
  4. Panel "Modul tidak aktif" shows no stat cards, the money card for all Kas/Bank, and the dashed note "Data jemaat dan Jumlah kehadiran belum aktif. …".
  5. The footer caption shows in every view.
  6. Back arrow → `/BerandaJabatan`.
- **Notes**
  - **Kolom 7 events caption.** The Kolom 7 view keeps the caption "2 kelahiran · 3 baptisan · 1 pernikahan · 1 kematian" (7 events) under the value "2". Copy as drawn and flag it.
  - **Kolom 7 attendance.** The Kolom 7 attendance "38" matches Ibadah's Ibadah Kolom 7 of 19/11/2026, but the label says Minggu 15/11/2026. Keep and flag.
  - **Inactive modules named.** The module-off note names the inactive modules. That conflicts with the LencanaModul rule that a Tidak aktif module leaves no trace (compare KeadaanUmum, "Nama modulnya tidak disebut"). Keep the board and flag it.
  - **Static chips.** The dimension chips look like unselected ChipPilihan but are not interactive. Do not add a selection.
  - **Off-token size.** The mono value 26 px is off-token; copy it.

### WebLaporanLintas — Web · Laporan
- **Source** `docs/design/handoff/canvas/boards/WebLaporanLintas.dc.html` · page Putaran 5 · Kolaborasi (`p5`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebLaporanLintas`, no child routes · **Widget** `WebLaporanLintasScreen` in `lib/screens/p5/web_laporan_lintas.dart`
- **Purpose** Same as LaporanLintas on the laptop, seen as Pdt. Lidya Rondonuwu, Ketua Jemaat. Same decisions (Q25, the reach filter, no free report builder, module off). Q26: the Ketua Jemaat is not one of the three desk posts, yet a laptop layout is drawn (see Notes).
- **Shell** Platform web side nav exactly as WebKeadaanUmum in `17-keadaanumum.md`: root, brand row, ten items, footer, the below-860 top bar with the "Menu"/"Tutup menu" toggle, the main column and the title block.
  - Items in order, all `go`: Beranda, Keuangan, Dokumen gereja, Pengumuman, Warta Jemaat, Data jemaat, Ibadah dan kegiatan, Panitia, Pemberitahuan, Pengaturan.
  - The active item is **Beranda** (`tinta` field, `permukaan` label).
  - Footer: "**Pdt. Lidya Rondonuwu** · Ketua Jemaat".
- **Layout**
  1. Title block:
     - Breadcrumb "Beranda" (underlined text link, 14/600 `laut`).
     - h1 "Laporan" (`judulHalaman` 26/700, margin-top 2).
     - Subtitle "Dari data yang sah, disaring menurut jangkauan tiap jabatan" (14 `tinta2`).
  2. Content column, max-width 880, column gap 16. Its blocks are the same as LaporanLintas regions 1–5, with the same copy, values, colours, radii and conditions; body text inherits 15 (titles 15/700).
     - The stats grid `minmax(300, 1fr)` gives **two columns** at 880 (two cards per row, about 432 each) and at 808 (860 window). Two rows of two cards. Just above 860 the side nav returns and takes about 220: from 861 to about 889 wide the content is under 616, so the grid falls to **one column** of four cards. Let `auto-fit` decide; do not fix the column count.
     - The chips stay on one line at 880. They wrap where the content is narrower than about 630 (861 to about 900 wide).
- **Components** As LaporanLintas, plus the platform web side nav.
- **Internal views and states** As LaporanLintas: `{ k: null }`, four views from the tweak.
- **Tweaks** `keadaan` (enum "Seluruh Jemaat" · "Kolom 7" · "Panitia Natal 2026" · "Modul tidak aktif", default "Seluruh Jemaat") · Keadaan panel. The effects are those of LaporanLintas.
- **Interactions** No board handlers. The nav toggle (860 px and below) opens and closes the item list.
- **Motion** None. Keyframes `muncul`, `isi` and `titik` are declared and unused. The nav drawer opens instantly.
- **Links out**
  - Breadcrumb "Beranda" → `/WebBerandaJabatan`, up link.
  - Side nav (`go`): Beranda → `/WebBerandaJabatan` (active item; tapping it still navigates); Keuangan → `/WebBeranda`; Dokumen gereja → `/WebDokumenGereja`; Pengumuman → `/WebPengumuman`; Warta Jemaat → `/WebWartaArsip`; Data jemaat → `/WebDataAnggota`; Ibadah dan kegiatan → `/Ibadah` (phone board in the device frame); Panitia → `/Panitia` (phone board); Pemberitahuan → `/WebKotakMasuk`; Pengaturan → `/WebPenugasan`.
  - **Inbound** PetaPlatform.
- **Mock data** As LaporanLintas, plus the nav footer person "Pdt. Lidya Rondonuwu · Ketua Jemaat".
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. At 1440 wide, open `/WebLaporanLintas`. The nav shows ten items with "Beranda" filled `tinta`, and the footer reads "Pdt. Lidya Rondonuwu · Ketua Jemaat". The content is at most 880 wide. The stat cards sit two per row, and the money card reads "Rp38.415.000".
  2. Panel "Kolom 7" shows the values 96 / 31 / 2 / 38 and "Rp1.240.000".
  3. Panel "Modul tidak aktif" shows no stat grid, plus the dashed note.
  4. Breadcrumb "Beranda" → `/WebBerandaJabatan`. Nav "Panitia" → `/Panitia`, shown in the phone frame.
  5. At 860 px the nav becomes a top bar with "Menu". Tapping it shows "Tutup menu" and the ten items. The stat grid is still two columns, and there is no horizontal scroll.
  6. At 1280 px there is no overflow, and the stat cards sit two per row.
  7. At 870 px (side nav shown) the stat cards stack in one column, with no horizontal scroll.
- **Notes**
  - **Active item.** "Beranda" is marked active on a page that is not Beranda. Keep as drawn.
  - **Q26.** A laptop layout drawn for the Ketua Jemaat is outside Q26. Keep it.
  - **Same flags as the phone.** The notes of LaporanLintas (Kolom 7 caption, the "38" figure, the module-off naming) apply here too.

### PersembahanBernama — 93 · Persembahan bernama
- **Source** `docs/design/handoff/canvas/boards/PersembahanBernama.dc.html` · page Putaran 5 · Kolaborasi (`p5`) · form Phone 390×844 · interactive yes
- **Route** `/PersembahanBernama`, no child routes · **Widget** `PersembahanBernamaScreen` in `lib/screens/p5/persembahan_bernama.dart`
- **Purpose** The Bendahara Jemaat attaching a giver to a named envelope, and what another post sees. It shows:
  - Q32: only a gift in a named envelope is recorded per person. It is visible only to the giver and the Bendahara Jemaat. Bag and unnamed offerings are never recorded per person.
  - The giver is picked from Data jemaat, Active members only. An unconfirmed member cannot be linked (Penolakan).
  - The giver's name is not part of the amount, so it can be set or removed without a reversal, with each change in Riwayat.
  - TampilanNama: the name in Warta Jemaat follows the giver's own choice.
  - A record keeps the name after the member withdraws consent.
  - It links to the member's own view, PersembahanSaya.
- **Shell** Phone header with back (shared phone frame). Back label "Kembali ke Keuangan". h1 "Persembahan bernama"; subtitle "Nama pemberi dicatat hanya bila sampulnya bernama".
- **Layout** Scroll column, gap 16.
  1. *Transaction card* (fact card, every view). Header: "Sampul syukur" 700 | mono "Rp100.000".
     - Rows: "Tanggal transaksi" | "01/11/2026"; "Diterima di" | "Ibadah Minggu Pagi"; "Masuk ke peruntukan" | "Umum Jemaat".
  2. View blocks:
     - **Tanpa nama** (k0):
       - Fact card "Pemberi" with a `draf` chip "Tanpa nama". Caption "Bawaan. Persembahan kantong dan sampul tanpa nama tidak dicatat per orang."
       - Button row: outline button "Catat nama pemberi" (340).
     - **Pilih pemberi** (k1):
       - *Field*: a `<label>` that wraps the label text, the input and the helper; a column with gap 6, 14 px `tinta2`.
         - Label "Pemberi (anggota)". It is the input's semantics label.
         - Read-only input showing "Novita Wenas": full width, min-height 48, padding 0 14, radius 12, 1 px `garisTegas`, `permukaan` field. The value inherits the label's font: 14 px `tinta2`.
         - Helper "Cari di Data jemaat · hanya anggota yang Aktif" 13 `tinta3`.
       - *Info box*: `lautLembut` field, no line, radius 12, padding 12/14, 14 px `tinta`: "**Nama ini hanya dilihat pemberinya dan Bendahara Jemaat.** Tidak tampil di laporan, dan tidak tampil bagi Penatua, Syamas, Sekretaris Jemaat atau Operator."
       - Caption "Bila anggota ini kelak mencabut izin dan datanya dihapus, catatan keuangan tetap menyimpan nama seperti yang tercatat."
       - Button row: ink "Simpan", then text button "Batalkan", 171 each.
     - **Tercatat atas nama anggota** (k2):
       - Fact card "Pemberi" with a `garis` chip "Novita Wenas".
         - Captions "Tampil di “Persembahan saya” milik Novita Wenas setelah transaksi ini Dibukukan." and "Di Warta Jemaat namanya mengikuti Tampilan nama yang ia pilih: Tanpa nama."
       - Caption "Nama pemberi bukan bagian dari jumlah: dapat dicatat atau dilepas tanpa pembalikan, dan setiap perubahan tercatat di Riwayat."
       - Button row: outline link "Lihat yang dilihat anggota", then text button "Lepas nama", 171 each. The outline label may wrap to two lines.
     - **Belum dikonfirmasi** (k3):
       - Refusal line "**Tidak dapat dilakukan: Catat nama pemberi.**" then "data Ferry Wenas masih Belum dikonfirmasi."
       - Caption "Namanya tetap boleh ditulis di Uraian sebagai catatan pembukuan, tetapi tidak ditautkan ke orangnya sampai datanya Diverifikasi."
       - Button row: text button "Kembali" (340).
     - **Dilihat jabatan lain** (k4):
       - Terpilih note "**Nama pemberi tidak ditampilkan.** Hanya pemberinya dan Bendahara Jemaat yang melihatnya."
       - Fact card "Pemberi" with an `abu` chip "Tidak ditampilkan". Caption "Jumlah dan peruntukannya tetap tampil sesuai wewenang jabatan Anda."
- **Components**
  - LencanaStatus shapes (Tanpa nama `draf`; the name `garis`; Tidak ditampilkan `abu`).
  - Penolakan.
  - Tombol (ink, outline, outline link, text).
  - GarisStatus `dibukukan`, `terpilih`.
  - TampilanNama rule (k2 caption).
  - Patterns, not components: the read-only field, the `lautLembut` info box and the fact card.
- **Internal views and states** Five views. The initial state is `{ k: null }`, so the view is "Tanpa nama".
  - "Pilih pemberi" is reached from "Catat nama pemberi".
  - "Tercatat atas nama anggota" is reached from "Simpan".
  - "Tanpa nama" is reached from "Batalkan", "Lepas nama" and "Kembali".
  - "Belum dikonfirmasi" and "Dilihat jabatan lain" are reached only from the tweak.
- **Tweaks** `keadaan` (enum "Tanpa nama" · "Pilih pemberi" · "Tercatat atas nama anggota" · "Belum dikonfirmasi" · "Dilihat jabatan lain", default "Tanpa nama") · Keadaan panel. Each option shows the view of the same name below the transaction card, and changing it resets `k`.
- **Interactions**
  - "Catat nama pemberi" sets `k = 'Pilih pemberi'`.
  - "Simpan" sets `k = 'Tercatat atas nama anggota'`. There is no validation, because the field is always filled.
  - "Batalkan" sets `k = 'Tanpa nama'`.
  - "Lepas nama" sets `k = 'Tanpa nama'`, with no confirmation.
  - "Kembali" (k3) sets `k = 'Tanpa nama'`.
  - The read-only field does nothing when tapped: no picker, no keyboard. It stays focusable.
  - There are no timers.
- **Motion** None.
- **Links out**
  - Back arrow ("Kembali ke Keuangan") → `/Main`, up link.
  - "Lihat yang dilihat anggota" (k2) → `/PersembahanSaya`, `push`.
  - **Inbound** Persembahan, PetaPlatform.
- **Mock data**
  - The envelope "Sampul syukur": Rp100.000, 01/11/2026, received at Ibadah Minggu Pagi, peruntukan Umum Jemaat.
  - Giver Novita Wenas, whose Tampilan nama is "Tanpa nama".
  - Unconfirmed member Ferry Wenas.
- **Prototype-only** none. The read-only "Novita Wenas" field stands in for the member picker; keep it on screen as drawn. It is not one of the handoff's listed devices. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. Open `/PersembahanBernama` and "Sampul syukur" "Rp100.000" (mono) is above the "Pemberi" card with a dashed chip "Tanpa nama", and "Catat nama pemberi" is shown.
  2. Tap "Catat nama pemberi" to get the field "Pemberi (anggota)" showing "Novita Wenas", the `lautLembut` box, "Simpan" and "Batalkan". The transaction card is still at the top.
  3. "Simpan" gives the chip "Novita Wenas" (`tinta3` line), the caption with the curly-quoted “Persembahan saya”, and "Lihat yang dilihat anggota" next to "Lepas nama".
  4. "Lihat yang dilihat anggota" → `/PersembahanSaya` (push). System or browser Back returns here, still in "Tercatat atas nama anggota" (the route stays under the push, so `k` is kept). PersembahanSaya's own back arrow ("Kembali ke Beranda") is its up link to `/BerandaJabatan`, not back here.
  5. "Lepas nama" brings back the "Tanpa nama" view.
  6. Panel "Belum dikonfirmasi" shows "Tidak dapat dilakukan: Catat nama pemberi." in `bata` with "data Ferry Wenas masih Belum dikonfirmasi." in `tinta`. "Kembali" → the Tanpa nama view.
  7. Panel "Dilihat jabatan lain" shows the 1.5 `tinta` note and the grey-field chip "Tidak ditampilkan".
  8. Back arrow → `/Main`.
- **Notes**
  - **Field value colour.** The read-only input inherits 14 px `tinta2` from its label (the board's `input { font: inherit; color: inherit }`). Copy that, even though input values elsewhere are 16 `tinta`.
  - **Header after Belum dikonfirmasi.** In "Belum dikonfirmasi" the refusal stands alone without the "Pemberi" card. Keep.
  - **Capital P.** "Ibadah Minggu Pagi" (capital P) differs from Kehadiran's "Ibadah Minggu pagi". Keep each board's text.

### WebPersembahanBernama — Web · Persembahan bernama
- **Source** `docs/design/handoff/canvas/boards/WebPersembahanBernama.dc.html` · page Putaran 5 · Kolaborasi (`p5`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebPersembahanBernama`, no child routes · **Widget** `WebPersembahanBernamaScreen` in `lib/screens/p5/web_persembahan_bernama.dart`
- **Purpose** Same as PersembahanBernama on the laptop for Meiske Lumentut, Bendahara Jemaat (a desk post, Q26). Same decisions (Q32, TampilanNama, Penolakan for an unconfirmed member).
- **Shell** Platform web side nav as WebKeadaanUmum (`17-keadaanumum.md`).
  - Ten items, with **Keuangan** active (`tinta` field, `permukaan` label).
  - Footer "**Meiske Lumentut** · Bendahara Jemaat".
  - Below 860 px, the "Menu" top bar.
- **Layout**
  1. Title block:
     - Breadcrumb "Keuangan" (underlined text link, 14/600 `laut`).
     - h1 "Persembahan bernama" (26/700, margin-top 2).
     - Subtitle "Nama pemberi dicatat hanya bila sampulnya bernama" (14 `tinta2`).
  2. Content, max-width 1120, column gap 16, holding one row that wraps with gap 20 (between lines) / 28 (between columns), items top-aligned.
     - Left column (flex 1.3 1 420, min-width 0, column gap 12): the transaction card, as on the phone, with 15 px body.
     - Right column (flex 1 1 340, min-width 0, column gap **12**): the five view blocks exactly as PersembahanBernama region 2. Same copy, chips, field, info box, captions, buttons and handlers. Labels are 15/700 and buttons max 340 each.
     - Widths: at 1440 the left column is about 608 and the right about 484. At 1280 they are about 530 and 425. At 860 they are about 431 and 349, still on one line. The right column wraps under the transaction card wherever the content is under 788: below about 840 wide, and also from 861 to about 1072 wide, where the side nav is back and takes about 220. Let the wrap row decide; do not switch at a fixed breakpoint.
- **Components** As PersembahanBernama, plus the platform web side nav.
- **Internal views and states** As PersembahanBernama: `{ k: null }`, five views, the same transitions.
- **Tweaks** `keadaan` (enum "Tanpa nama" · "Pilih pemberi" · "Tercatat atas nama anggota" · "Belum dikonfirmasi" · "Dilihat jabatan lain", default "Tanpa nama") · Keadaan panel. The effects are those of PersembahanBernama.
- **Interactions**
  - The handlers of PersembahanBernama (`go0`, `go1`, `go2` on the same buttons).
  - The nav toggle (860 px and below).
- **Motion** None. Keyframes `muncul`, `isi` and `titik` are declared and unused.
- **Links out**
  - Breadcrumb "Keuangan" → `/WebBeranda`, up link.
  - "Lihat yang dilihat anggota" (k2) → `/PersembahanSaya`, `push`. It is a phone board, shown in the device frame.
  - Side nav (`go`): Beranda → `/WebBerandaJabatan`; Keuangan → `/WebBeranda` (active item; tapping it still navigates); Dokumen gereja → `/WebDokumenGereja`; Pengumuman → `/WebPengumuman`; Warta Jemaat → `/WebWartaArsip`; Data jemaat → `/WebDataAnggota`; Ibadah dan kegiatan → `/Ibadah`; Panitia → `/Panitia`; Pemberitahuan → `/WebKotakMasuk`; Pengaturan → `/WebPenugasan`.
  - **Inbound** PetaPlatform, WebPersembahan.
- **Mock data** As PersembahanBernama, plus the nav footer "Meiske Lumentut · Bendahara Jemaat".
- **Prototype-only** none. Keadaan panel: `keadaan`.
- **Acceptance checks**
  1. At 1440, open `/WebPersembahanBernama`. Nav "Keuangan" is filled `tinta` and the footer reads "Meiske Lumentut · Bendahara Jemaat". The transaction card is on the left (about 608) and the "Pemberi" card with "Catat nama pemberi" on the right.
  2. "Catat nama pemberi" → the field "Novita Wenas" plus "Simpan"/"Batalkan" in the right column. The left card is unchanged.
  3. "Simpan" then "Lihat yang dilihat anggota" → `/PersembahanSaya` in the phone frame.
  4. Breadcrumb "Keuangan" → `/WebBeranda`.
  5. At 860 px: a top bar with "Menu". Both columns still sit side by side, and there is no horizontal scroll. At 1000 px (side nav shown) the right column sits under the transaction card at full width (about 720), and after "Catat nama pemberi" the buttons "Simpan" and "Batalkan" are 340 each.
  6. Panel "Dilihat jabatan lain" shows the note and the "Tidak ditampilkan" chip in the right column.
- **Notes**
  - **Platform nav for a finance board.** The Bendahara Jemaat is shown with the platform side nav (Keuangan active), not the finance side nav. Keep the board.
  - **Same flags as the phone.** The PersembahanBernama notes (the field's inherited 14 `tinta2`) apply.

### Kesiapan — 101 · Pernyataan kesiapan per peruntukan
- **Source** `docs/design/handoff/canvas/boards/Kesiapan.dc.html` · page Putaran 5 · Kolaborasi (`p5`) · form Phone 390×844 · interactive yes
- **Route** `/Kesiapan`, no child routes. The exemption form opens inline in its row, not as a route. **Widget** `KesiapanScreen` in `lib/screens/p5/kesiapan.dart`
- **Purpose** Two roles, switched by the tweak.
  - The Bendahara Jemaat (Meiske L.) before closing October 2026. It is reached from the link "Pernyataan kesiapan" under "Tutup buku Oktober 2026" on TutupBuku (step 4 of the journey "Bendahara Jemaat", which does not name this board), and from the row "Pernyataan kesiapan" of Lainnya.
  - A unit treasurer (Dkn. Olga Tamba, Bendahara Komisi Diakonia) declaring their peruntukan ready. It is step 1 of the journey "Bendahara unit and committee officers".
  - It shows:
    - A missing or outdated statement is a month-close Hambatan.
    - The Bendahara may exempt (Bebaskan) a peruntukan only with a typed reason. This is IsianAlasan and P12: not blank, no minimum length.
    - An exemption is listed as an exception in the month-close confirmation.
    - A statement is not an approval and does not close the books.
    - A change to that month's transactions makes the statement need renewing.
- **Shell** Phone header with back (shared phone frame). Back label "Kembali ke Bulan". h1 "Pernyataan kesiapan"; subtitle (13 `tinta2`) "Oktober 2026 · masuk sebagai {siapa}". `siapa` is "Meiske L., Bendahara" or "Dkn. Olga Tamba, Bendahara Komisi Diakonia"; the long form wraps to two lines.
- **Layout** Scroll area, padding 8/20/20. Column gap **12**: the source writes `gap: 16px; gap: 12px` and the later value wins.
  1. Bendahara only (`masukSebagai` = "Bendahara"):
     - *Hambatan card*, while any peruntukan is `lagi` or `belum` (GarisStatus `hambatan`): `permukaan` field, 1.5 solid `bata` line (it overrides the 1 px `garis` written first), radius 14, padding 14/16. It has no inner gap.
       - "Hambatan tutup buku Oktober 2026" at 16/700.
       - Directly under it, at 14 `tinta2`: "{kurangN} peruntukan belum punya pernyataan kesiapan yang berlaku. Minta bendahara unitnya menyatakan siap, atau bebaskan dengan alasan." `kurangN` is the count over all three peruntukan, 2 at start.
     - *Done card*, when none is outstanding: `lautLembut` field, no line, radius 14, padding 14/16, 16/600, appearing with `muncul`. Text: "Pernyataan kesiapan semua peruntukan sudah ada", then, if any are exempted, " · {bebasN} dibebaskan, tercatat sebagai pengecualian di konfirmasi tutup buku", then ".".
  2. Unit treasurer only (`masukSebagai` = "Bendahara Komisi Diakonia"): an intro line at 14 `tinta2`: "Anda menyatakan bahwa catatan peruntukan Diakonia untuk Oktober 2026 sudah lengkap menurut Anda. Ini bukan persetujuan dan tidak menutup buku; tutup buku tetap dilakukan Bendahara."
  3. Row list: a plain block in which each row card has margin-bottom 12. The last row therefore leaves 12 px plus the 12 gap above the footer.
     - The Bendahara sees three rows, in order: Umum Jemaat, Diakonia, Pembangunan. The unit treasurer sees only Diakonia.
     - *Row card*: `permukaan`, 1 px `garis`, radius 14, padding 14/16, a column with gap 8.
       - Head: a row that wraps, space-between, centred vertically, gap 8. "Peruntukan {name}" at 16/700, then a status chip (13/700, radius 6, padding 3/9).
       - Status chip by state:
         - `ada`: "Sudah dinyatakan siap", `laut` field, `diLaut` text, 1.5 `laut` line.
         - `lagi`: "Perlu dinyatakan lagi", `permukaan` field, `bata` text, 1.5 `bata` line.
         - `belum`: "Pernyataan kesiapan belum ada", `permukaan` field, `bata` text, 1.5 `bata` line.
         - `bebas`: "Dibebaskan", `permukaan` field, `tinta` text, 1.5 `tinta` line.
       - Line (14 `tinta2`) by state:
         - `ada`: "Oleh Pnt. Jefry Wowor · 02/11/2026" for Umum Jemaat; for the others "Oleh {person} · 16/11/2026" (so "Oleh Dkn. Olga Tamba · 16/11/2026").
         - `lagi`: "Dinyatakan 01/11/2026, lalu ada transaksi Oktober yang berubah. Pernyataan lama tidak berlaku lagi."
         - `belum`: "Bendahara unit: {person}" (Pembangunan: "Bendahara unit: Sdr. Rivo Mandagi").
         - `bebas`: "Oleh Bendahara · alasan: {the reason as saved}".
       - "Bebaskan": an outline button, min-height 48, radius 14, 1.5 `tinta`, `permukaan`, 700, padding 0 18, start-aligned at its own width. Shown when the viewer is the Bendahara, the state is `lagi` or `belum`, and the form is not open on this row.
       - "Nyatakan siap": a primary button, min-height 52, radius 14, `laut` field, `diLaut` label 700, padding 0 18, start-aligned. Shown when the viewer is the unit treasurer and the state is `lagi` or `belum`.
       - *Exemption form* (only on the row whose id equals `form`): a column with gap 8, a 1 px `garis` rule on top, padding-top 10, appearing with `muncul`.
         - Label "Alasan membebaskan **· wajib**" at 14 `tinta2`; the "· wajib" run is bold `tinta`. It is the semantics label of the field.
         - Field: multi-line, exactly two lines tall (min and max 2 lines), full width, padding 12/14, radius 12, 1 px `garisTegas` line, `permukaan` field, 16 `tinta`, not resizable. It starts empty with no hint text.
         - Buttons: a row that wraps, gap 8.
           - "Bebaskan dengan alasan ini": min-height 46, padding 0 20, radius 12, no border, 700. When the reason is filled it has a `tinta` field and `permukaan` label. When the reason is blank it has a `garis` field, a `tinta3` label and is not pressable.
           - "Kembali": min-height 46, padding 0 20, radius 12, 1.5 `tinta` line, `permukaan`, `tinta` 700.
  4. Footer caption, 13 `tinta3`: "Berlaku setelah Jemaat punya bendahara unit (Putaran 5). Perubahan pada transaksi bulan itu membuat pernyataan perlu dinyatakan lagi."
- **Components**
  - ButirPerhatian Hambatan, as a plain `bata`-line card with no "HAMBATAN" label or fix button; see Notes.
  - LencanaStatus shapes ("Sudah dinyatakan siap" is the "Sudah dipastikan" shape; "Perlu dinyatakan lagi" is the "Perlu dipastikan lagi" shape).
  - IsianAlasan (the reason field and its guarded button).
  - Tombol (primary `laut` "Nyatakan siap", secondary "Bebaskan", "Kembali").
  - GarisStatus `hambatan` and `dibukukan`.
  - Gerak `muncul`.
  - Patterns, not components: the row card with an inline form, and the `lautLembut` done card.
- **Internal views and states** The initial state is `{ f: { umum: 'ada', diak: 'lagi', bang: 'belum' }, form: null, alasan: '', als: {} }`.
  - Bendahara list view: hambatan or done card, then three rows.
  - Inline exemption form, open on one row at a time.
  - Unit treasurer view: intro line plus the Diakonia row.
  - Done state: the done card replaces the hambatan card.
  - There are no sheets, toasts or empty states.
- **Tweaks** `masukSebagai` (enum "Bendahara" · "Bendahara Komisi Diakonia", default "Bendahara") · Keadaan panel.
  - "Bendahara": subtitle "… masuk sebagai Meiske L., Bendahara"; the hambatan or done card; all three rows with "Bebaskan" where outstanding.
  - "Bendahara Komisi Diakonia": subtitle "… masuk sebagai Dkn. Olga Tamba, Bendahara Komisi Diakonia"; no hambatan or done card; the intro line; only the Diakonia row, with "Nyatakan siap" while it is outstanding.
  - Switching the tweak keeps `f` and `als`, so the statement Olga makes shows to the Bendahara, and closes the form (`form = null`, `alasan = ''`); see Notes.
- **Interactions**
  - "Bebaskan" (row X) sets `form = X` and `alasan = ''`. The form opens under row X with `muncul`, and X's "Bebaskan" hides. Opening it on another row moves the form there and clears the text.
  - Typing in the reason field sets `alasan` on every change (no formatting). The condition `ok` is `alasan.trim()` not empty, so spaces alone stay blank.
  - "Bebaskan dengan alasan ini":
    - When `ok` is false it does nothing. Give it a press handler that re-checks, not `onPressed: null`, so it stays focusable (TombolBersyarat's Flutter rule). The board sets the HTML `disabled` attribute while blank, so its semantics must still report it as disabled (`Semantics(enabled: false)`) until `ok`.
    - When `ok` is true: `als[X] = alasan.trim()`, `f[X] = 'bebas'`, `form = null`, `alasan = ''`. The row shows "Dibebaskan" and "Oleh Bendahara · alasan: {trimmed text}", and the hambatan count drops by one.
    - The condition is re-read from the latest text when pressed, so the first press after typing works.
    - There is no refusal sentence (see Notes).
  - "Kembali" (form) sets `form = null`. The typed text is left in state but cleared the next time a form opens.
  - "Nyatakan siap" (row X, unit treasurer) sets `f[X] = 'ada'`, `form = null` and `alasan = ''`. The chip becomes "Sudah dinyatakan siap" with "Oleh Dkn. Olga Tamba · 16/11/2026", and the button hides.
  - When the last outstanding row is resolved (Bendahara view) the hambatan card is replaced by the done card, which appears with `muncul`.
  - A row in `ada` or `bebas` has no action and cannot be undone. Leaving the route resets everything.
  - There are no timers.
- **Motion**
  - `muncul`, 300 ms, CSS ease (fade from 0 and rise 8 px), runs each time the exemption form is inserted.
  - `muncul`, 300 ms, runs each time the done card is inserted (after the last row is resolved, or when switching back to the Bendahara view with everything resolved).
  - The motion is in `motion.md`. Under reduce motion it shows instantly. Declared and unused: `masuk`, `pudar`, `isi`.
- **Links out**
  - Back arrow ("Kembali ke Bulan") → `/TutupBuku`, up link.
  - **Inbound** Lainnya, PetaPlatform, TutupBuku (manifest), plus the JS-built rows of Cakupan and PetaLayar.
- **Mock data**
  - Month Oktober 2026.
  - Peruntukan Umum Jemaat, stated by Pnt. Jefry Wowor on 02/11/2026.
  - Peruntukan Diakonia: treasurer Dkn. Olga Tamba (Bendahara Komisi Diakonia), stated 01/11/2026 and then outdated.
  - Peruntukan Pembangunan: treasurer Sdr. Rivo Mandagi, no statement.
  - Viewer Meiske L., Bendahara. A new statement is dated 16/11/2026.
- **Prototype-only** none. The role switch is the `masukSebagai` tweak. Keadaan panel: `masukSebagai`.
- **Acceptance checks**
  1. Open `/Kesiapan` and the subtitle reads "Oktober 2026 · masuk sebagai Meiske L., Bendahara". The 1.5 `bata` card shows "2 peruntukan belum punya pernyataan kesiapan yang berlaku. …". Three rows appear:
     - Umum Jemaat with a `laut` chip "Sudah dinyatakan siap" and "Oleh Pnt. Jefry Wowor · 02/11/2026".
     - Diakonia "Perlu dinyatakan lagi" with "Bebaskan".
     - Pembangunan "Pernyataan kesiapan belum ada", "Bendahara unit: Sdr. Rivo Mandagi" and "Bebaskan".
  2. Tap "Bebaskan" on Diakonia and the form fades and rises in under that row. That row's "Bebaskan" is gone, and "Bebaskan dengan alasan ini" is grey and does nothing when tapped.
  3. Type three spaces and the button stays grey. Type "Laporan unit menyusul" and it turns `tinta`. One press gives Diakonia the chip "Dibebaskan" (`tinta` line) and "Oleh Bendahara · alasan: Laporan unit menyusul". The form closes and the card reads "1 peruntukan …".
  4. Exempt Pembangunan with any reason and the `bata` card is replaced, with `muncul`, by "Pernyataan kesiapan semua peruntukan sudah ada · 2 dibebaskan, tercatat sebagai pengecualian di konfirmasi tutup buku."
  5. Open a form, type text, press "Kembali", then open it again: the form closes, then reopens with an empty field.
  6. Reopen the route and set the panel to "Bendahara Komisi Diakonia". The subtitle reads "… masuk sebagai Dkn. Olga Tamba, Bendahara Komisi Diakonia". There is no `bata` card, the intro line appears, and only "Peruntukan Diakonia" shows, with the `laut` button "Nyatakan siap".
  7. Tap "Nyatakan siap" and the chip reads "Sudah dinyatakan siap" with "Oleh Dkn. Olga Tamba · 16/11/2026", and no button. Switch the panel to "Bendahara" and Diakonia keeps that state; the card reads "1 peruntukan …".
  8. Back arrow → `/TutupBuku`.
  9. With reduce motion on, the form and the done card appear without the rise.
- **Notes**
  - **Form across the tweak.** On the canvas an open form stays open when the tweak switches to the unit treasurer, showing a Bendahara-only action next to "Nyatakan siap". Recommended: the tweak switch closes the form and keeps `f` and `als`.
  - **Disabled without a refusal sentence.** The guarded button has no "Tidak dapat dilakukan" sentence; the full-contrast "· wajib" in the label is the stated reason. Keep the board. Do not add a refusal sentence; keep the grey look while blank.
  - **Plain hambatan card.** It lacks ButirPerhatian's "HAMBATAN" label and fix button. Keep the board.
  - **Design-round words in copy.** "(Putaran 5)" in the footer is design-round wording inside app copy. Copy it verbatim.
  - **Done text without exemptions.** The done text without exemptions ("… sudah ada.") cannot occur here: Pembangunan can only be exempted. Implement both branches anyway.
  - **Reason as typed.** The saved reason is trimmed before it is shown, while RiwayatAlur says "recorded exactly as typed". Keep the board's trim.
  - The manifest's `hasSideNav: true` is a false positive.

### WebKesiapan — Web · Pernyataan kesiapan per peruntukan
- **Source** `docs/design/handoff/canvas/boards/WebKesiapan.dc.html` · page Putaran 5 · Kolaborasi (`p5`) · form Laptop page (preview 1440×1000) · interactive yes
- **Route** `/WebKesiapan`, no child routes · **Widget** `WebKesiapanScreen` in `lib/screens/p5/web_kesiapan.dart`
- **Purpose** Same as Kesiapan on the laptop. For the Bendahara Jemaat, a desk post, it is reached from WebTutupBuku's link row "Pernyataan kesiapan". The decisions are the same as Kesiapan.
- **Shell** Finance web side nav, the standard shell specified in `02-awal.md` (shared notes), with the same ≤860 px "Menu" collapse.
  - Seven items, `go`, in order: Beranda, Transaksi, Uang Muka dan Titipan, Rekonsiliasi, **Bulan dan tutup buku** (active: `tinta` field, `permukaan` label), Laporan, Pengaturan.
  - Footer: "**Meiske L.** · Bendahara", a line break, then "Wewenang Bendahara aktif" (13 `tinta2`, name bold `tinta`). It is fixed: this board has no `jabatanKosong`, and the footer does not change with `masukSebagai`.
  - Root: `kertas`, `isiWeb` 15/1.45. Main column: flex 999 1 560, padding 28 / clamp(16, 3 % of window width, 40) / 40, column gap 20.
- **Layout**
  1. Title block:
     - Breadcrumb "Bulan dan tutup buku" (underlined text link, 14/600 `laut`).
     - h1 "Pernyataan kesiapan " (26/700, margin-top 2), followed inline by "· Oktober 2026" at 15/500 `tinta3`.
     - Subtitle (14 `tinta2`): "Masuk sebagai {siapa}. Berlaku setelah Jemaat punya bendahara unit (Putaran 5)." `siapa` is as in Kesiapan.
  2. Body: a row that wraps, gap 24, items top-aligned, no max-width.
     - Left (flex 999 1 480, min-width 0): the row list exactly as Kesiapan region 3, with the same cards, chips, lines, buttons, inline form and `muncul`. Card titles stay 16/700 (written explicitly); other text inherits 15 where the phone inherits 16 (field text 15).
     - Aside (flex 1 1 340, min-width 0, column gap 14):
       - Bendahara: the hambatan card or the done card, as Kesiapan region 1, but at the web body size: the title "Hambatan tutup buku Oktober 2026" is 15/700 and the done text 15/600 (no size is written, so they inherit 15). The hambatan's second line stays 14 `tinta2`.
       - Unit treasurer: the intro line, as Kesiapan region 2.
       - Then a 13 `tinta3` caption: "Perubahan pada transaksi bulan itu membuat pernyataan perlu dinyatakan lagi. Yang dibebaskan tampil sebagai pengecualian di konfirmasi tutup buku."
     - Widths: at 1440 (content about 1139) the left is about 775 and the aside 340. At 1280 they are about 619 and 340. At 860 (content about 808, which is less than 844) the aside wraps under the rows at full width. It also wraps from 861 to about 1132 wide, where the side nav is back and takes about 220, leaving less than 844. Let the wrap row decide.
- **Components** As Kesiapan, plus the finance web side nav.
- **Internal views and states** As Kesiapan: the same initial state `{ f: { umum: 'ada', diak: 'lagi', bang: 'belum' }, form: null, alasan: '', als: {} }`, the same views and the inline form.
- **Tweaks** `masukSebagai` (enum "Bendahara" · "Bendahara Komisi Diakonia", default "Bendahara") · Keadaan panel. It has the same effects as Kesiapan (subtitle, rows, aside content). The switch keeps `f`/`als` and closes the form.
- **Interactions**
  - Every Kesiapan handler, with the same conditions and effects: Bebaskan, typing, "Bebaskan dengan alasan ini" with its trim check and first press after typing, Kembali, Nyatakan siap.
  - The nav toggle (860 px and below).
- **Motion** `muncul` 300 ms on the inline form and on the done card, as in Kesiapan. Keyframes `isi` and `titik` are declared and unused.
- **Links out**
  - Breadcrumb "Bulan dan tutup buku" → `/WebTutupBuku`, up link.
  - Side nav (`go`): Beranda → `/WebBeranda`; Transaksi → `/WebTransaksi`; Uang Muka dan Titipan → `/WebKewajiban`; Rekonsiliasi → `/WebRekonsiliasi`; Bulan dan tutup buku → `/WebTutupBuku` (active item; tapping it still navigates); Laporan → `/WebPaketLaporan`; Pengaturan → `/WebPengaturan`.
  - **Inbound** WebTutupBuku (manifest), plus the JS-built row of PetaLayar.
- **Mock data** As Kesiapan, plus the nav footer "Meiske L. · Bendahara / Wewenang Bendahara aktif".
- **Prototype-only** none. Keadaan panel: `masukSebagai`.
- **Acceptance checks**
  1. At 1440, open `/WebKesiapan`. The nav "Bulan dan tutup buku" is filled `tinta` and the footer shows "Meiske L. · Bendahara" over "Wewenang Bendahara aktif". The h1 reads "Pernyataan kesiapan" with "· Oktober 2026" in small grey. Three rows are on the left, and the aside on the right shows the `bata` card "2 peruntukan …" above the caption.
  2. "Bebaskan" on Pembangunan opens the form in that card. With an empty field the button is grey. Type "Belum ada bendahara unit" and press: the row shows "Dibebaskan", and the aside reads "1 peruntukan …".
  3. Exempt Diakonia as well and the aside shows the `lautLembut` done card with "· 2 dibebaskan, …" (with `muncul`).
  4. Panel "Bendahara Komisi Diakonia" (fresh route): the subtitle reads "Masuk sebagai Dkn. Olga Tamba, Bendahara Komisi Diakonia. …", one row with "Nyatakan siap", and the intro line in the aside. The footer still says "Meiske L.".
  5. Breadcrumb → `/WebTutupBuku`. Nav "Rekonsiliasi" → `/WebRekonsiliasi`.
  6. At 860 px the nav collapses to "Menu" and the aside sits under the rows at full width, with no horizontal scroll. At 1000 px (side nav shown) the aside is also under the rows. At 1280 the two columns sit side by side.
  7. The aside's hambatan title reads at 15/700, smaller than the 16/700 "Peruntukan …" titles on the left.
- **Notes**
  - **Footer and nav for Olga.** The footer and the finance nav stay Meiske L.'s even when viewing as Dkn. Olga Tamba. Q26 gives a unit treasurer no laptop layout. Keep both as drawn and flag them.
  - **Same flags as the phone.** The Kesiapan notes apply: the form closes on a tweak switch, there is no refusal sentence, and "(Putaran 5)" in the copy.
