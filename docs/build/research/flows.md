# User flows for the real app (Jemaat Karunia)

All 199 board stems are covered: each one is either in a flow (sections 1 and 2), among the shared state screens, or in the not-app list (section 3). I checked this with a script against the stem list in `docs/build/navigation.md` §2.2. I edited no files.

**Sources:**
- `docs/build/navigation.md`:
  - §1.2–1.7: shells, the platform tree, the PetaLayar layout.
  - §2.2: the route table.
  - §3.3–3.4: the link graph.
  - §4.3: the journeys by role.
- `docs/build/screens/NN-*.md`, each board's **Purpose**, **Interactions**, **Links out**, **Acceptance checks**, **Prototype-only** and **Tweaks** fields.

"Inferred" marks my own reading. Everything else is stated in those files.

## 0. Facts that affect every flow

- **Personas named on the boards** (side-nav footers, nav §1.3 "Footer text", and the specs):
  - Meiske Lumentut, Bendahara Jemaat.
  - Yanti Sumual, Operator.
  - Olvie Pangemanan, Sekretaris Jemaat.
  - Pdt. Lidya Rondonuwu, Ketua Jemaat and Pimpinan Jemaat yang berwenang (R01).
  - Pnt. Hendrik Rumagit, Penatua Kolom 7 and Ketua Komisi Diakonia.
  - Dkn. Olga Tamba, Akses terbatas Diakonia.
  - Pnt. Jefry Wowor, Pemeriksa kedua (the Pemeriksa `masukSebagai` tweak).
  - Deasy Tumbelaka, Bendahara Kolom 7 (AlurUnit).
  - Novita Wenas, Anggota jemaat.
  - "Bendahara Komisi Diakonia", unnamed (the Kesiapan `masukSebagai` tweak).
  - Petugas verifikasi, Tim Palakat (WebVerifikasi).
  - Rivo Mandagi and Stevi Lengkong (Panitia officers) appear only as data.
- **Prototype devices that become real persona actions** (Prototype-only field):
  - "Dilihat sebagai" viewer pills on AlurPulihkan, AlurAnggota, AlurPeristiwa, AlurKeluarga, AlurUnit and AlurDana.
  - "Contoh:" buttons on AlurJabatanKosong ("pemegang jabatan ditugaskan"), AlurPanitia ("… dibukukan"), AlurMasuk and AkunSaya ("diverifikasi", "diizinkan").
  - The role tweak `masukSebagai` on Pemeriksa and Kesiapan.
  - These are the handoffs between personas in the flows below.
- **Static board and "Alur" board pairs are one screen (inferred).**
  - On the static board the main button changes nothing: Penugasan check 3 "still ten cards", Modul check 3, Pelimpahan check 3, Peristiwa chips inert.
  - The Alur board holds the working flow: typed input and refusals.
  - In the real app, build one screen per pair: the list from the static board, the behaviour from the Alur board.
  - Pairs (their Web twins pair the same way):
    - Penugasan/AlurPenugasan
    - Modul/AlurModul
    - Pelimpahan/AlurPelimpahan
    - JabatanKosong/AlurJabatanKosong
    - BerandaJabatan/AlurBeranda
    - Masuk/AlurMasuk
    - CariOrang/AlurPulihkan
    - DokumenGereja + TerbitDokumen/AlurDokumen
    - PermohonanSurat/AlurSurat
    - WartaEditor/AlurWarta
    - PermohonanAnggota/AlurAnggota
    - Peristiwa/AlurPeristiwa
    - ImporBuku/AlurKeluarga
    - TampilanNama + CabutIzin/AlurNama
    - KeuanganUnit/AlurUnit
    - PermintaanDana/AlurDana
    - Ibadah + Kehadiran/AlurIbadah
    - Panitia/AlurPanitia + AlurPanitiaBaru
    - Pengembalian/AlurPengembalian
- **The fixed sample voucher numbers (No. Bukti) collide (inferred from the checks).**
  - WebTransaksi books BKU-2026-0147, WebPersembahan 0148, WebPemeriksa 0151 and WebKasusBaru 0153.
  - KeuanganUnit and AlurUnit already show BKU-2026-0151.
  - Shared state needs one number sequence. Flow tests should assert "the next free number", not a literal.
- **Missing back links are kept on purpose** (§1.5): Main and WebBeranda have no link back to BerandaJabatan or WebBerandaJabatan. With a persona picker as the entry, each persona needs a home screen (question 6).
- **Phone-only platform boards are opened from web** (§1.5 `hal()` list of 26, and the navPlatform items "Ibadah dan kegiatan" and "Panitia").
  - For example, WebBerandaJabatan rows open AntreanVerifikasi, KonfirmasiKeluarga, PermintaanDana and PersembahanSaya.
  - These boards have no web layout (decision 26).

## 1. Finance flows (phase 1)

Each flow gives: persona · start · steps · boards (phone | web | tablet) · handoff · **end state** for the end-to-end test.

**F1 Set up the church book**
- **Persona:** Bendahara Jemaat.
- **Steps:**
  - Awal → `/Awal/tunjuk` (send the BPMJ letter) → wait for Petugas verifikasi.
  - AwalIsian (identity, Kas/Bank, peruntukan, Lingkup).
  - `/Awal/saldo` (opening balance per Kas/Bank) → MataAnggaran → "Mulai mencatat" (go to Main).
- **Boards:** Awal, AwalIsian | WebAwal, WebAwalIsian.
- **Handoff:** WebVerifikasi (Petugas verifikasi). Today a 2800 ms timer "stands for the Petugas verifikasi" (02-awal, Prototype-only).
- **End state:**
  - "6 dari 6 langkah".
  - Opening balance booked with seri OPN (WebAwal check 3).
  - Main can be opened.
- **Conflict:** in the story Meiske is already active since 15/09/2026 (Bendahara check 1), but Awal shows "3 dari 6" (question 2).

**F2 Record and book a transaction**
- **Persona:** Bendahara, starting at Main or WebBeranda.
- **Steps:**
  - Catat sheet → `/Main/catat` → Tanggal → `/Main/mata-anggaran` (or Bagi for a split).
  - Attach a document (Kamera).
  - `/Main/periksa` → Bukukan → `/Main/detail`. The alternative is "Simpan sebagai draf".
- **Boards:**
  - Phone: Main, Tanggal, Bagi, PilihBulan, Kamera.
  - Web: WebBeranda, WebTransaksi, WebCatat, WebTanggal, WebBagi, WebPilihBulan.
  - Tablet: TabBeranda, TabTransaksi, TabCatat. Their links open Web* boards (§1.4).
- **End state:**
  - The transaction is "Dibukukan" with the next No. Bukti.
  - Beranda "Saldo buku" (Rp38.415.000 baseline) and the "Bulan ini" tiles change by the amount.
  - The draft path adds to the dashed pill ("Rp800.000 · 2 draf").
  - The row appears in Transaksi, Bukti, Cari and the provisional report.

**F3 AI help while recording**
- **Persona:** Bendahara, from the Catat "Catatan lain" chips or the WebCatat links.
- **Steps:** ask for a suggestion → Pakai, Ubah or Abaikan.
- **Boards:** BantuanAI, AIFoto, AIMataAnggaran | WebBantuanAI, WebAIFoto, WebAIMataAnggaran.
- **End state:**
  - Draft fields are filled. Kas/Bank, peruntukan and Lingkup still read "Belum diisi" (D01).
  - The draft reads "Tersimpan · Draf". The AI never books.
- Fixed outcomes and the 1.3–1.4 s timers are acceptable.

**F4 Sunday offering in parts, with a named envelope**
- **Persona:** Bendahara.
- **Steps:** Persembahan (Tunai, QRIS, Transfer) → pick the Kas/Bank for QRIS → Bukukan → PersembahanBernama "Catat nama pemberi".
- **Boards:** Persembahan, PersembahanBernama | WebPersembahan, WebPersembahanBernama.
- **Handoff:** to Novita Wenas, PersembahanSaya.
- **End state:**
  - One No. Bukti.
  - Titipan Rp450.000 goes to DANA TRANSIT.
  - Novita's PersembahanSaya lists the envelope, visible only to the giver and the Bendahara (Q32).

**F5 Advances, deposits and reimbursements**
- **Persona:** Bendahara.
- **Steps:** Kewajiban → `/Kewajiban/kasus/:id` → Catat pertanggungjawaban or pengembalian. KasusBaru opens a new case.
- **Boards:** Kewajiban, KasusBaru | WebKewajiban (read-only table), WebKasus, WebKasusBaru.
- **End state:**
  - The remainder is recomputed (Panitia Natal Rp650.000 goes down).
  - A new case is listed with its due date.
  - Spending beyond the advance is refused and sent to Penggantian biaya.
  - The Beranda row "2 uang muka…" follows the count.

**F6 Second checker**
- **Personas:** the Bendahara records, Pnt. Jefry Wowor marks "Sudah diperiksa", the Bendahara books. Switching persona goes through the picker.
- **Where the rule is switched on:** Lainnya `/Lainnya/aturan`, or WebPengaturan.
- **Boards:** Pemeriksa | WebPemeriksa.
- **End state:**
  - The person who recorded the draft cannot mark it checked.
  - After the check and Bukukan the row is "Dibukukan".
  - Any change returns it to Draf.
- **Note:** switching the rule on shows "Hidup mulai Desember 2026" (D23). The seed must already have the rule on for the current month (question 5).

**F7 Record an approval given outside the app**
- **Persona:** Bendahara.
- **Entry points:** Persetujuan, Koreksi "Catat persetujuan", or the WebTransaksi detail "Catat persetujuan".
- **Boards:** Persetujuan | WebPersetujuan.
- **End state:**
  - KartuPersetujuan is solid, with giver, date and method.
  - "Ganti" keeps the old record in Riwayat as "Digantikan".
  - Changing the amount voids the approval ("Persetujuan belum dicatat").

**F8 Correct a booked transaction**
- **Persona:** Bendahara.
- **Steps:** transaction detail → Koreksi → `/Koreksi/pembalikan` (reason) → `/Koreksi/hasil`. For a closed month → `/Koreksi/kejadian`.
- **Boards:** Koreksi | WebKoreksi.
- **End state:**
  - The original reads "Dibalik oleh No. Bukti …".
  - The reversal (and the correction) get new numbers; the net effect is Rp0.
  - For a closed month: a refusal, never a reopen.

**F9 Refund**
- **Persona:** Bendahara.
- **Steps:** Pengembalian (to a donor or from a supplier) → AlurPengembalian through to booking.
- **Boards:** Pengembalian, AlurPengembalian | WebPengembalian, WebAlurPengembalian.
- **End state:**
  - A new transaction, linked to the original and no larger than it.
  - A supplier refund reduces Belanja in the month the money is received.

**F10 Draft dated in a closed month**
- **Persona:** Bendahara.
- **Steps:** Main Transaksi "1 draf di bulan yang sudah ditutup" → Draf → Pindah tanggal or Batalkan, with a reason.
- **Boards:** Draf | WebDraf.
- **End state:**
  - The draft moves to November and can be booked, or shows "Dibatalkan" with no No. Bukti.
  - The link on Main disappears.

**F11 Move money between peruntukan**
- **Persona:** Bendahara.
- **Boards:** AlihPeruntukan | WebAlihPeruntukan.
- **End state:**
  - The move is posted and the balances of both peruntukan change.
  - Refusals when source and target are the same, or when the amount exceeds the balance.

**F12 Supporting documents**
- **Persona:** Bendahara.
- **Steps:**
  - Dokumen → `/Dokumen/rinci` → Verifikasi, Tolak, Pengecualian or Lepaskan.
  - Capture through Kamera (`/tinjau`, `/unggah`); view through LihatDokumen.
- **Boards:** Dokumen, Kamera, LihatDokumen | WebDokumen, WebUnggah, WebLihatDokumen.
- **End state:**
  - Status "Terverifikasi (oleh Meiske L.)", or "Dikecualikan" with a reason.
  - That document's close blocker disappears from TutupBuku `/cek`.

**F13 Import transactions**
- **Persona:** Bendahara.
- **Steps:** Impor: Ditampung → Lolos pengecekan → Sudah diimpor.
- **Boards:** Impor | WebImpor.
- **End state:**
  - "4 baris sudah diimpor · 1 tidak diimpor".
  - The imported rows appear in Transaksi.

**F14 Search and ask**
- **Persona:** Bendahara.
- **Boards:** Cari | WebCari.
- **End state:**
  - The total is computed from posted records (Rp10.950.000 for the seed query).
  - A transaction booked in F2 is found.

**F15 Month end: reconcile, count cash, close October**
- **Persona:** Bendahara.
- **Steps:**
  - TutupBuku → `/cek` → `/rekonsiliasi`: mark a deposit in transit, create the bank-fee transaction, confirm.
  - HitungKas `/banding` → RekonIsi (statement lines) → Kesiapan (exempt or declared).
  - `/konfirmasi` (hold the button) → `/ditutup`.
  - Optional AI help: AIBulan, WebAI.
- **Boards:**
  - Phone: TutupBuku, HitungKas, RekonIsi, Kesiapan, AIBulan.
  - Web: WebRekonsiliasi, WebHitungKas, WebRekonIsi, WebTutupBuku, WebKesiapan, WebAI.
- **Handoffs:**
  - The Bendahara Komisi Diakonia declares readiness (Kesiapan).
  - Kolom 7 blockers are resolved by the Bendahara in SelesaikanUnit and WebSelesaikanUnit (see F23).
  - The FormatLaporan approval is a close requirement.
- **End state:**
  - Difference Rp0, "Sudah dipastikan".
  - October "Sudah ditutup" (dark card); November becomes next to close.
  - The official report pack gets an ID.
  - Booking or correcting into October is refused afterwards.

**F16 Incident after close**
- **Persona:** Bendahara.
- **Entry points:** Koreksi `/kejadian`, the Tanggal refusal link, or TutupBuku → Kejadian `/rinci`.
- **Boards:** Kejadian | WebKejadian.
- **End state:**
  - The settlement is recorded with its explanation; the closed figures are unchanged.
  - The blocker on the next month stays (D11).

**F17 Reports**
- **Persona:** Bendahara.
- **Steps:**
  - Laporan `/rinci/:f` → LihatTransaksi.
  - Bukti (Daftar, Celah nomor).
  - FormatLaporan records the format approval.
- **Boards:** Laporan, LihatTransaksi, Bukti, FormatLaporan | WebLaporan, WebPaketLaporan, WebLihatTransaksi, WebBukti, WebFormatLaporan.
- **Generated outputs:** the A4 pages and WebExcel (section 3).
- **End state:**
  - A provisional ribbon before the close; the official ribbon and "Unduh PDF/Excel" after it.
  - Every report figure equals the sum of its listed transactions ("sama dengan angka di laporan").
  - The gaps view lists unused numbers.

**F18 Export the church's data**
- **Persona:** Bendahara.
- **Boards:** Ekspor | WebEkspor.
- **End state:**
  - "Diunduh · ekspor-jemaat-karunia-<date>.zip".
  - "Belum lengkap" lists the transactions whose files are missing. That is a real condition, coming from the F12 data.

**F19 Settings**
- **Persona:** Bendahara.
- **Steps:** Lainnya (`/kas`, `/aturan`, `/riwayat`) or WebPengaturan, then:
  - UbahPengaturan: add Kas/Bank, peruntukan or Lingkup.
  - MataAnggaran `/rinci`: Boleh untuk → diperiksa → terbitkan.
  - KasUnit: assign a Kas/Bank to a unit.
- **Boards:** Lainnya, UbahPengaturan, MataAnggaran, KasUnit | WebPengaturan, WebUbahPengaturan, WebMataAnggaran, WebKasUnit.
- **End state:**
  - Each change states "berlaku mulai <next month>" and adds a Riwayat line.
  - A deactivated Kas/Bank is shown dashed.
  - Mata Anggaran version 2026.2 is published from December.

**F20 Sessions, handover, sign-out**
- **Persona:** Bendahara.
- **Steps:**
  - Bendahara (`/serah`) or WebSerahTerima → the new Bendahara is pending → Petugas verifikasi activates.
  - Keluar `/keluar` or WebKeluar.
- **Boards:** Bendahara, Keluar | WebSerahTerima, WebKeluar.
- **End state:**
  - "Akhiri sesi" removes a session.
  - The handover shows "Menunggu verifikasi wewenang", then active.
  - "Keluar" returns to the persona picker with state kept (decided).

**F21 Finance notifications**
- **Persona:** Bendahara.
- **Boards:** Pemberitahuan | WebPemberitahuan.
- **End state:**
  - The unread count drops when an item is opened.
  - Switching a type off hides it, but blockers stay on Beranda.

**F22 Restricted (Diakonia) access**
- **Persona:** Dkn. Olga Tamba.
- **Steps:** Terbatas `/transaksi/:no` → "Unduh PDF" (A4Terbatas).
- **Boards:** Terbatas | WebTerbatas, WebExcelTerbatas.
- **End state:**
  - Only the Diakonia parts are visible; no other peruntukan.
  - A Diakonia transaction booked in F2 appears.

**F23 Unit finance (Kolom 7)**
- **Persona:** Deasy Tumbelaka.
- **Steps:** KeuanganUnit → Catat transaksi, or Rekonsiliasi Kas Kolom 7 → Kesiapan "Nyatakan siap".
- **Boards:** KeuanganUnit, AlurUnit | WebAlurUnit.
- **Handoff to the Bendahara Jemaat:**
  - Two Kolom 7 items block October: a Draf dated 28/10 and an unconfirmed cash reconciliation.
  - She resolves them in SelesaikanUnit or WebSelesaikanUnit, with a required reason.
- **End state:**
  - The unit books only on its own Kas/Bank.
  - Once the Bendahara resolves the items, TutupBuku `/cek` no longer shows the "hambatan dari unit".

**F24 Fund request**
- **Personas and steps:**
  - Pnt. Hendrik (Ketua Komisi Diakonia) asks.
  - Pdt. Lidya approves, or records "tidak disetujui".
  - Meiske presses "Catat pembayaran" (go to Main) and books it as Uang Muka diberikan.
- **Boards:** AlurDana, PermintaanDana (phone only). Lidya sets the approver table in PemberiPersetujuan.
- **End state:**
  - The request reads "Disetujui oleh …", then "Dibayar".
  - A new Uang Muka case appears in Kewajiban.
  - The requester never approves their own request.

**F25 The Operator runs the vacant Bendahara post**
- **Persona:** Yanti Sumual.
- **Steps:** JabatanKosong or AlurJabatanKosong (reason and acknowledgement) → finance screens carry the PitaJabatanKosong banner.
- **Boards:** JabatanKosong, AlurJabatanKosong | WebJabatanKosong, WebAlurJabatanKosong.
- **Handoff:** the Pimpinan assigns a holder (AlurPenugasan), and the Operator's running stops.
- **End state:**
  - Every action is recorded "oleh Yanti Sumual, Operator · menjalankan jabatan kosong …".
  - The close confirmation names the Operator.
- The global `jabatanKosong` tweak becomes this real state (question 4). It swaps the footer on the 38 web boards in nav §1.3 "Footer text" and shows the PitaJabatanKosong strip on the phone finance boards.

## 2. Platform flows (later phases)

**P1 Combined home and inbox**
- **Persona:** any post holder.
- **Boards:** BerandaJabatan (with the AlurBeranda "Sebagai …" choice), KotakMasuk | WebBerandaJabatan, WebKotakMasuk.
- **End state:** "Perlu tindakan" rows reflect real open items and disappear when the linked work is done. Row links are listed in §3.3 (computed links).

**P2 My account**
- **Persona:** any.
- **Boards:** AkunSaya (phone number change, backup email, devices, push permission) | WebAkunSaya.
- **End state:**
  - Banner "Email cadangan disimpan.".
  - A removed device is gone.
  - Sign-out returns to the picker.

**P3 Sign-in, account linking, own recovery**
- **Boards:** Masuk, AlurMasuk, Pemulihan | WebMasuk, WebAlurMasuk, WebPemulihan.
- Replaced by the persona picker as the only entry (question 1).
- Their outcomes show the landing page per role, which is useful for picker homes (nav §3.4 #44):
  - "Buka Beranda" → Main (go).
  - "Buka peruntukan Diakonia" → Terbatas (go).
  - "Lihat langkah pengaturan awal" → Awal.

**P4 Recover a member's account (two people)**
- **Personas and steps:** Yanti finds the person and enters the new number; Hendrik confirms the identity.
- **Boards:** CariOrang, AlurPulihkan | WebCariOrang, WebAlurPulihkan.
- **End state:**
  - Hendrik sees "Tidak ada pemulihan akun yang menunggu Anda".
  - The Operator sees the completed status.

**P5 Modules**
- **Persona:** Lidya.
- **Boards:** Modul/AlurModul, phone only. Modules are turned on in dependency order; turning one off makes it Hanya baca and needs a reason.
- **End state:**
  - The module is Aktif.
  - Turning it off leaves the "Modul tidak aktif" state on its screens (KeadaanUmum). That is a real condition.

**P6 Posts, delegation and approvers**
- **Steps:**
  - Lidya assigns posts in Penugasan/AlurPenugasan; no one can assign a post to themselves.
  - Hendrik delegates in Pelimpahan/AlurPelimpahan, with an end date, within his own unit.
  - Lidya sets PemberiPersetujuan.
- **Web:** WebPenugasan.
- **End state:**
  - The holder is recorded and the vacancy ends.
  - A delegation ends by itself on its date.

**P7 Church documents**
- **Persona:** Olvie.
- **Steps:** DokumenGereja → TerbitDokumen (a signed copy is required) → AlurDokumen `/terbit`, `/ralat`.
- **Web:** WebDokumenGereja, WebTerbitDokumen, WebAlurDokumen.
- **End state:**
  - The document is "Diterbitkan".
  - A Ralat becomes "Revisi 2" while the old version stays openable.
  - Members see only documents addressed to them.

**P8 Letter request**
- **Personas and steps:**
  - Novita requests a letter, or the Operator records the request for her.
  - Olvie checks Data jemaat, types the letter number, attaches the signed copy and issues it.
- **Boards:** PermohonanSurat, AlurSurat | WebPermohonanSurat, WebAlurSurat.
- **End state:**
  - "No. 027/SKet/XI/2026".
  - The member's inbox shows "Surat keterangan … diterbitkan".

**P9 Announcements and the weekly Warta**
- **Personas and steps:**
  - Yanti drafts an announcement and Olvie publishes it.
  - Olvie composes the 22/11 edition: Draf → diperiksa → disetujui → terbitkan.
  - Olvie records a name exception.
- **Boards:** Pengumuman, WartaEditor, AlurWarta, BukaNama, WartaArsip | WebPengumuman, WebWartaEditor, WebAlurWarta, WebBukaNama, WebWartaArsip. Output: A4Warta.
- **End state:**
  - The edition shows in WartaArsip as "Diterbitkan".
  - Names follow each member's TampilanNama.
  - The Warta's finance and attendance figures come from the F15 and P15 data.

**P10 Member book import and family confirmation**
- **Personas and steps:**
  - Yanti imports in ImporBuku/AlurKeluarga: check → duplicates → import.
  - DataGanda: merge, or mark not the same person.
  - KonfirmasiKeluarga: the family confirms.
  - Hendrik verifies from AntreanVerifikasi.
- **Web:** WebImporBuku, WebAlurKeluarga, WebDataGanda.
- **End state:**
  - The family badge reads "Aktif".
  - The Beranda count "12 anggota … belum dikonfirmasi" drops.

**P11 Become a member**
- **Personas and steps:** Novita applies in PermohonanAnggota/AlurAnggota; Hendrik verifies in AntreanVerifikasi.
- **End state:** the record is "Aktif" and BIPRA is computed (Pemuda).

**P12 Life events**
- **Personas and steps:** Novita submits in Peristiwa/AlurPeristiwa (attachment required); Hendrik verifies; DataAnggota is updated.
- **Web:** WebDataAnggota.
- **End state:** the record changes only after verification. A Pernikahan moves both spouses.

**P13 My name and my data**
- **Persona:** Novita.
- **Boards:** TampilanNama, AlurNama, CabutIzin.
- **End state:**
  - The next Warta preview prints the chosen name form.
  - After consent is withdrawn, finance records keep the booked name.

**P14 My giving**
- **Persona:** Novita.
- **Board:** PersembahanSaya, fed by F4.

**P15 Worship and attendance**
- **Personas and steps:**
  - Hendrik approves the service in Ibadah and assigns a counter.
  - The counter counts in Kehadiran.
  - Hendrik presses "Tetapkan".
- **Also:** AlurIbadah.
- **End state:** the count is fixed and appears in the Warta and in LaporanLintas.

**P16 Committees**
- **Persona:** Lidya.
- **Steps:**
  - AlurPanitiaBaru: a decision document from P7 and three different officers.
  - Panitia.
  - Closing through AlurPanitia: advances settled (F5), leftover money returned (F11).
- **End state:** Ditutup → Diarsipkan.

**P17 Cross-module report**
- **Personas:** Lidya, Hendrik, Panitia officers.
- **Boards:** LaporanLintas | WebLaporanLintas.
- **End state:** figures are limited to what the viewer is allowed to see.

**Shared state screens** (not flows; shown only when the condition really happens):
- KeadaanUmum and WebKeadaanUmum: loading, failed, offline, not authorised, module off, session ended.
- Memuat, WebMemuat, Sambungan, WebSambungan.
- With in-memory data, only "Tidak berwenang" and "Modul tidak aktif" can really happen (inferred).
- Offline, failed load, "server did not confirm" and session ended become reusable widgets that nothing triggers, since staged faults are dropped by decision.

## 3. Boards that are not app screens

| Boards | What they are | What they become |
| --- | --- | --- |
| PetaLayar, Cakupan, Keputusan, PetaPlatform | Design sheets (`sistem`, nav §1.7; Purpose says "not an app screen") | Dropped |
| Launcher `/`, `_komponen`, PanelKeadaan, BingkaiPerangkat (not boards) | Prototype chrome (nav §4, §5.2) | Dropped; the persona picker replaces the launcher |
| A4F01, A4F02a, A4F02b, A4F02c, A4F14, A4Sementara | Printed F01, F02 and F14 pages, and the provisional F01 | A document view generated from data (F17): A4Sementara before the close; A4F01, F02 and F14 after |
| A4Terbatas | The TERBATAS copy, F05 and F07 | Generated document for F22 |
| A4Warta | The published Warta PDF | Generated document for P9 |
| WebExcel, WebExcelTerbatas | Pictures of a downloaded .xlsx | Generated file, or a preview, for F17 and F22 |
| WebVerifikasi | Internal Palakat team page (footer "Tim Palakat · halaman internal") | Question 3: a persona, or keep the timer |
| Tweaks and devices: `keadaan`, `bulan` sepi, `gagalSimpan`, `sambunganKembali`, `gagalUnggah`, `konflik`, `biayaAI`, `usulan`, `adaHambatan`, `jenis`, `setelahMasuk`, `masukSebagai`, "Ulangi contoh", the "Di prototipe ini" hints | Keadaan panel | A data situation in the seed, a persona, or dropped as a staged fault |

## 4. Questions the planner must put to the user

1. The sign-in boards (Masuk, AlurMasuk, Pemulihan and their Web twins): with the picker as the only entry, drop them, or keep them as screens that are never reached at start? Should Sambungan "Masuk lagi" and Keluar "Masuk" then open the picker?
2. The set-up flow F1 does not fit the running story (Meiske active since 15/09/2026, September closed). Use a second church in the seed, a "fresh" persona, or show set-up as completed?
3. Petugas verifikasi (WebVerifikasi): a picker persona who does the activation, or keep the 2800 ms timer?
4. Who is the Bendahara in the seed: Meiske active, or the post vacant with Yanti running it (`jabatanKosong`)? Both cannot hold at once.
5. The second-checker rule (F6) and other D23 "from next month" changes: should the seed have them already in force?
6. Home per persona: does the Bendahara land on Main/WebBeranda or on BerandaJabatan? Do people with several posts land on BerandaJabatan?
7. Phone-only platform boards reached from the web nav (Ibadah, Panitia, AntreanVerifikasi, …): show the phone layout on web, or hide them on web?

**Not checked:** I read the acceptance checks only up to the first three or four per board, and I did not read every Interactions block in full. End states come from those checks and from the Purpose lines. I did not check the seed data against `docs/build/mock-data.md` or `docs/design`.