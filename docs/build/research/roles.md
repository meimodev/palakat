# Roles, personas and modules for the real (dummy-data) app

Sources: `docs/design/platform-module-plan-2026-11-17.md` (PMP), `docs/build/navigation.md` (NAV), `docs/build/CONVENTIONS.md` (CONV), `docs/build/mock-data.md` (MD), `docs/build/screens/14-berandajabatan.md` (S14), `docs/design/handoff/04-decision-log.md` (DLOG). Anything marked **(inferred)** is my proposal and is not stated in the files.

## 1. Roles and posts, and who holds them in Jemaat Karunia

Role catalog: PMP §10. Who holds each post: MD §2.2 (people), §2.3 (Penugasan board), §2.20 and §2.21. Facts about the church: MD §2.1 says there are 12 Kolom, 11 of 12 Penatua posts are filled, and it names BIPRA Pemuda and Remaja, Komisi Diakonia and Pembangunan, and Panitia Natal 2026, HUT and Paskah 2026.

| Role (PMP §10) | Holder in the seed | Source |
|---|---|---|
| System administrator (Pengelola teknis) | none named. WebPengaturan has a "Belum ada Bendahara aktif" state that reads "Anda masuk sebagai Pengelola teknis. Hanya dapat melihat." | NAV 1.3 footer table |
| Onboarding reviewer (Petugas verifikasi) | "Petugas verifikasi / Tim Palakat · halaman internal" (WebVerifikasi). Verified Meiske on 15/09/2026 10.15 and revokes her in the vacancy scenario | MD 2.2, 4.2 |
| Authorized church officer (Pimpinan Jemaat yang berwenang) | Pdt. Lidya Rondonuwu, who is also Ketua Jemaat and Ketua BPMJ (R01) | MD 2.2; DLOG R01 |
| Ketua Jemaat | Pdt. Lidya Rondonuwu, since 01/01/2026 | MD 2.3 |
| Exception authority (Pemberi pengecualian) | Ketua BPMJ, which is Lidya | MD 2.1 |
| Bendahara Jemaat | Meiske Lumentut, since 15/09/2026, SK-BPMJ-04-2026. The boards draw two different successors: Yohanis Tumbelaka (from 16/11, SK-BPMJ-09-2026) and Deitje Kawengian (from 18/11) | MD 2.2, §3 row 18 |
| Checker (Pemeriksa kedua) | Pnt. Jefry Wowor, also Wakil Ketua BPMJ | MD 2.2 |
| Church Operator | Yanti Sumual, since 01/11/2026. She covers the vacant Penatua Kolom 2 post from 01/11, and the vacant Bendahara post in the scenario | MD 2.2, 4.2 |
| Sekretaris Jemaat | Olvie Pangemanan, since 03/11/2026, SK BPMJ No. 12/2026. There is also a "Menunggu verifikasi wewenang" state | MD 2.3, §3 row 40 |
| Penatua Kolom 7 | Pnt. Hendrik Rumagit. He is also Ketua Komisi Diakonia | MD 2.3 |
| Syamas Kolom 7 | Sym. Greis Mamahit. Hendrik has delegated "Verifikasi data Kolom 7" to her for 16–30/11/2026 | MD 2.3 Pelimpahan |
| Penatua Kolom 2 | Vacant. Pnt. Altje Rompas held it 01/01/2022–31/10/2026; AlurJabatanKosong assigns her again from 16/11 | MD 2.3, §3 row 16 |
| Syamas Kolom 3 | Vacant, "Belum ada yang menjalankan" | MD 2.3 |
| Unit treasurer, Kolom | Deasy Tumbelaka, Bendahara Kolom 7 (Kas Kolom 7) | MD 2.2, 2.4 |
| Unit treasurer, Komisi, and Fund-only viewer | Dkn. Olga Tamba: Bendahara Komisi Diakonia, with "Akses terbatas: Peruntukan Diakonia" | MD 2.2 |
| Panitia officers (Natal 2026) | Ketua Sdr. Stevi Lengkong, Sekretaris Sdri. Natalia Rumengan, Bendahara Sdr. Rivo Mandagi. Rivo is also "Ketua Pemuda" | MD 2.20 |
| Attendance counters | Yanti S. (Pintu depan), Greis M. (Pintu samping). Jefry and Olga are also listed as "Petugas penghitung" | MD 2.20, 2.2 |
| Member | Novita Wenas, Kolom 7, BIPRA Pemuda | MD 2.2 |
| Household representative | Agustina Lasut, for Keluarga Wenas-Lasut | MD 2.2 |
| Other non-officers | Ferry Wenas (unconfirmed import), Gabriel Wenas (child), Kevin Rompas (applicant, Kolom 2), Gabriela Rompas (Sidi), Yohanis Rompas (died 14/11/2026), Ibu Selvie Kalalo (advance holder) | MD 2.2 |
| Delegate | Greis, as above. A past delegation ran from Sekretaris to Yanti, 03–10/11 (ended) | MD 2.3 |
| External approver; in-app approver | Pdt. Lidya, the "outside approval" on PermintaanDana and the default approver under DL29 | MD 2.20 |

DL31: the Sekretaris and Bendahara BPMJ are the same people as the Sekretaris and Bendahara Jemaat.

## 2. Proposed personas for the picker (inferred, built from the board footers and the BerandaJabatan views)

The facts behind the list:
- One app. What a person sees follows their posts, and "Anggota jemaat" is the base view (DLOG Q25).
- One combined Beranda with no post switcher. The app picks the post when exactly one post can act and asks when two can (Q31, S14).
- Only the Bendahara, Sekretaris and Operator have laptop layouts (Q26).
- BerandaJabatan has a `keadaan` view for exactly five people: Hendrik, Meiske, Olvie, Yanti and Novita (S14, MD 2.16).

| # | Persona | Posts | Platform | Home and navigation (facts from NAV) |
|---|---|---|---|---|
| 1 | Meiske Lumentut | Bendahara Jemaat | Phone, web, Android tablet | Phone: **Main** with the 5-tab finance bar (Beranda, Transaksi, Catat, Bulan, Lainnya; NAV 1.1). Web: **WebBeranda** with `navKeuangan`, 7 items (NAV 1.3). Tablet: TabBeranda, TabTransaksi and TabCatat, with the side nav collapsed behind "Menu" (NAV 1.4). Her BerandaJabatan view also exists and links into Main |
| 2 | Olvie Pangemanan | Sekretaris Jemaat | Phone, web | Phone: BerandaJabatan, header-back hierarchy, no tab bar (NAV 1.5). Web: WebBerandaJabatan with `navPlatform`, 10 items |
| 3 | Yanti Sumual | Operator, covering Penatua Kolom 2 (and the Bendahara post when it is vacant) | Phone, web | As Olvie. Her BerandaJabatan view shows the post chip "Menjalankan jabatan kosong: Penatua Kolom 2" |
| 4 | Pdt. Lidya Rondonuwu | Ketua Jemaat, Pimpinan Jemaat yang berwenang, Ketua BPMJ | Phone. Web only for WebPenugasan and WebLaporanLintas, the two web boards with her footer | BerandaJabatan. **No `keadaan` view is drawn for her**, so her home rows must come from the data (inferred) |
| 5 | Pnt. Hendrik Rumagit | Penatua Kolom 7, Ketua Komisi Diakonia | Phone. WebKeadaanUmum and WebDataAnggota carry his footer | BerandaJabatan "Beberapa jabatan", plus the "Jabatan dipilih otomatis" and "Dua jabatan dapat bertindak" moments |
| 6 | Novita Wenas | Anggota jemaat | Phone | BerandaJabatan "Anggota jemaat" |
| 7 | Deasy Tumbelaka | Bendahara Kolom 7 | Phone | KeuanganUnit. Its header arrow links to itself (NAV 1.2) |
| 8 | Dkn. Olga Tamba | Bendahara Komisi Diakonia, Fund-only viewer | Phone, web | Terbatas / WebTerbatas with `navTerbatas` (3 items, all pointing at itself). Masuk `setelahMasuk` names her (MD 2.21) |
| 9 | Pnt. Jefry Wowor | Pemeriksa kedua, Wakil Ketua BPMJ | Phone, web | Pemeriksa / WebPemeriksa (footer "Jemaat Karunia / Wajib pemeriksa kedua: hidup") |
| 10 | Sdr. Rivo Mandagi | Bendahara Panitia Natal, Ketua Pemuda | Phone | BerandaJabatan (inferred) |
| 11 | Sym. Greis Mamahit | Syamas Kolom 7, delegate, counter | Phone | BerandaJabatan (inferred) |
| 12 | Optional (ask): Sdr. Stevi Lengkong (Ketua Panitia), Agustina Lasut (household representative), Kevin Rompas (applicant), Petugas verifikasi (WebVerifikasi, `navVerifikasi`, internal Palakat page) | | | |

## 3. Modules and screens per persona

Taken from the role journeys in NAV 4.3, the board footers in NAV 1.3, the row targets in S14 and the board data in MD.

- **Meiske. Finance, Unit finance (church side), Panitia leftover money.**
  - Phone: Main (`/catat`, `/transaksi`, `/mata-anggaran`, `/periksa`, `/detail`), TutupBuku, Lainnya, Awal, AwalIsian, MataAnggaran, Bagi, Persembahan, PersembahanBernama, Kewajiban, KasusBaru, Dokumen, Kamera, LihatDokumen, Draf, Koreksi, Persetujuan, AlihPeruntukan, Pengembalian, AlurPengembalian, HitungKas, RekonIsi, Kejadian, AIBulan, Laporan, LihatTransaksi, Bukti, Impor, Ekspor, FormatLaporan, UbahPengaturan, Bendahara, Keluar, KasUnit, SelesaikanUnit, Kesiapan, AlurUnit, Cari, Pemberitahuan, BantuanAI, AIFoto, AIMataAnggaran, Tanggal, PilihBulan, Sambungan, Memuat.
  - A4 pages: A4F01, A4F02a, A4F02b, A4F02c, A4F14, A4Sementara, A4Terbatas.
  - Web: all 52 `navKeuangan` boards, plus WebKasUnit, WebSelesaikanUnit, WebPersembahanBernama, WebAlurUnit and WebAlurPengembalian (footer "Meiske Lumentut · Bendahara Jemaat"), plus WebKesiapan.
  - Also: books fund-request payments as Uang Muka (AlurDana) and approves the Panitia's leftover money (Panitia board, 05/01/2027) (MD 2.20).
- **Olvie. Church documents, Announcements, Warta, read-only Membership (DL24).**
  - DokumenGereja, TerbitDokumen, AlurDokumen, PermohonanSurat, AlurSurat, Pengumuman, WartaArsip, WartaEditor, BukaNama, AlurWarta, A4Warta, KotakMasuk, AkunSaya. Each has a `Web*` twin (her footer is on 12 web boards, NAV 1.3).
  - Approves services when there is no Ketua Jemaat (DL11).
- **Yanti. Core and Membership as Operator; sees everything (DL25).**
  - ImporBuku, AlurKeluarga, DataGanda, JabatanKosong, AlurJabatanKosong, CariOrang, AlurPulihkan. All seven have web twins with her footer.
  - KonfirmasiKeluarga (enters paper forms), PermohonanSurat (letter requests made at the office), Pengumuman drafts, CabutIzin (records deletion requests), AntreanVerifikasi for Kolom 2 (as cover), Kehadiran (counter).
  - While the Bendahara post is vacant, every finance screen, with the strip and band.
- **Lidya. Core governance, In-app approvals, Panitia, Services, Reports.**
  - Modul, AlurModul, Penugasan, AlurPenugasan, WebPenugasan, Pelimpahan, AlurPelimpahan, PemberiPersetujuan, AlurPanitiaBaru, Panitia (moves its stages), PermintaanDana (approving), AlurDana, Ibadah (approves Jemaat-wide services such as Minggu Adven I, MD 2.20), Kehadiran, LaporanLintas, WebLaporanLintas.
  - Also: approves the report format and finance exceptions.
- **Hendrik. Membership verifier, Services and Attendance for Kolom 7, Komisi Diakonia fund requests.**
  - AntreanVerifikasi, KonfirmasiKeluarga, DataAnggota (+ WebDataAnggota), Peristiwa, AlurPeristiwa, AlurAnggota (verifier side), Ibadah, Kehadiran, AlurIbadah, AlurPulihkan (confirms), CabutIzin (deleted Ferry on 17/11), PermintaanDana / AlurDana (submits Rp750.000 as Ketua Komisi Diakonia), Pelimpahan (to Greis), KeadaanUmum (+ web), AkunSaya.
- **Novita. Member self-service.**
  - PermohonanAnggota, AlurAnggota, TampilanNama, AlurNama, CabutIzin, Peristiwa (submits Gabriel's Baptism), PermohonanSurat (request), WartaArsip, Pengumuman (Kolom 7), DokumenGereja (its "Dilihat anggota jemaat" rows), PersembahanSaya, AlurMasuk, KeadaanUmum.
- **Deasy:** KeuanganUnit, AlurUnit, and drafts that SelesaikanUnit shows as blockers.
- **Olga:** Terbatas, WebTerbatas, WebExcelTerbatas, A4Terbatas, Kesiapan / WebKesiapan (`masukSebagai` "Bendahara Komisi Diakonia", 22-permintaandana.md).
- **Jefry:** Pemeriksa, WebPemeriksa, Kewajiban / WebKasus (`masukSebagai` "Pemeriksa kedua", 05-kewajiban.md), Kesiapan (Umum Jemaat attested 02/11).
- **Rivo:** PermintaanDana ("Konsumsi Natal Pemuda" Rp1.500.000), Panitia / AlurPanitia (Bendahara), Kesiapan (preparer for Pembangunan), holder of the Panitia Natal advance (Kewajiban).
- **Greis:** AntreanVerifikasi as delegate, the Keluarga Rumagit change forwarded to the Syamas (no self-verification), Ibadah approver, Kehadiran counter.
- **Stevi:** Panitia, AlurPanitia. **Agustina:** KonfirmasiKeluarga (confirmed 16/11 19.30).

Navigation facts the planner must handle:
- **No way back from finance to the platform home.** Main has no link to BerandaJabatan, and `navKeuangan` has no item for WebBerandaJabatan (NAV 1.5): "do not add a link" applied to the prototype.
- **Unit-finance and approval screens are phone-only.** `navPlatform` sends "Ibadah dan kegiatan" and "Panitia" to phone boards (NAV 1.3). 26 boards are phone-only (NAV 1.5 `hal()`).
- **The boards never hide nav items by module** (NAV 1.5), even though PMP §8 rule 4 says navigation shows only active modules.

## 4. Vacant posts and Operator cover with real data

Rules:
- **Who may cover.** An Operator may act in any vacant post, the Bendahara included (DL12). Each action is audited as "acting for vacant post", and the cover ends when someone is assigned (PMP §5, §6.1).
- **Maker/checker.** It still needs two distinct people. The covering Operator cannot be the checker (PMP §6.1 "Vacancy cover in Finance").
- **Routing.** Items go by the assignments in force, so nothing waits on an empty post (PMP §6.1, Membership).

What the seed expresses as real conditions (facts, MD 2.3, 2.16, 2.18, 4.2):
1. **Penatua Kolom 2, vacant now.** Altje's term ended 31/10/2026, and Yanti has covered since 01/11.
   - Yanti's home shows "3 data Kolom 2 menunggu verifikasi" with a `bata` badge reading "Jabatan kosong", which leads to JabatanKosong.
   - AntreanVerifikasi for Kolom 2 holds Kevin Rompas's application and the death of Yohanis Rompas.
   - AlurJabatanKosong holds Ferry Wenas's application, Gabriela Rompas's Sidi, and a change for Keluarga Sumual. That is **Yanti's own family**, so the self-verification refusal applies.
   - When Lidya assigns Altje again (Penugasan), the cover should end and the items should move to her **(inferred, as a shared-state action)**.
2. **Syamas Kolom 3, vacant with no cover.** An Operator could take it over **(inferred)**.
3. **Bendahara Jemaat.** In the prototype this was a global switch (`jabatanKosong`, R04), not seed data.
   - Real path: the Petugas verifikasi revokes Meiske at BPMJ's request (16/11 08.10, "semua sesi diakhiri"), and the Operator takes over at 08.15.
   - Yanti then sees these on every finance screen:
     - the phone strip "Menjalankan jabatan kosong · Bendahara Jemaat";
     - the web band "Anda menjalankan jabatan kosong … sejak … Setiap tindakan dicatat sebagai dijalankan oleh Operator Yanti Sumual.";
     - the side-nav footer "Yanti Sumual · Operator / Menjalankan jabatan kosong Bendahara Jemaat";
     - the close confirmation "Ditutup oleh Yanti Sumual, Operator …";
     - the checker refusal "Yang dapat memeriksa: Pnt. Jefry Wowor.";
     - a Riwayat line.
   - Filling the post ends the cover.
   - With real data, `tukarJk`'s string swap becomes simply the recorded actor of each action **(inferred)**.
   - Open points: who triggers the revocation in the app, whether the seed starts filled or vacant, and which successor to use (Yohanis Tumbelaka or Deitje Kawengian, MD §3 row 18).
4. **Another self-verification case.** The Keluarga Rumagit change (Hendrik's own household) is forwarded to Syamas Greis (MD 2.18).

## 5. Module phases in build order (PMP §12; phase grouping inferred)

| Phase | Contents | Personas enabled | Depends on |
|---|---|---|---|
| 0 Core | Picker and session; Person, Unit, RoleAssignment, capability check (role, scope, period, delegation, vacancy, module status; PMP §5, §11); audit and Riwayat; module registry; notification inbox; real clock with the seed shifted relative to today. Screens: BerandaJabatan / WebBerandaJabatan, AkunSaya, KotakMasuk, KeadaanUmum, Keluar | all (shell) | — |
| 1 Finance (A2–A10, DL9) | Every Bendahara board, phone, web and tablet; A4 pages; Fund-only viewer (Terbatas); checker (Pemeriksa); vacancy cover in finance (PMP: part of slice 1) | Meiske, Olga, Jefry, Yanti (cover) | 0 |
| 2 C1 Operator and delegation | Penugasan, JabatanKosong, Pelimpahan, Modul, CariOrang, AlurPulihkan | Lidya, Yanti | 0 |
| 3 Secretariat (B1–B3) | Documents, Announcements, Warta without member data, letters with typed details | Olvie | 0 |
| 4 Membership (M1–M2) | Import, households, consent, verification queue, life events, masking, withdrawal and deletion | Hendrik, Novita, Yanti, Greis, Agustina | 0 |
| 5 Collaboration | C2 Unit finance (KeuanganUnit, AlurUnit, KasUnit, SelesaikanUnit, Kesiapan), needing 1 and D17/EC09; C3 In-app approvals (PermintaanDana, AlurDana, PemberiPersetujuan), needing 1; C4 Panitia, whose asset handover needs 3; C5 Services and Attendance (Ibadah, Kehadiran, AlurIbadah); C7 LaporanLintas and search, needing 1, 3 and 4. C6 push is out of scope for dummy data **(inferred)** | Deasy, Rivo, Stevi, Lidya, Greis | as noted |
| 6 Joins | J1 Party-to-Person (PersembahanBernama, PersembahanSaya), needing 1 and 4; J2 Warta masking, BukaNama, TampilanNama and letters from member records, needing 3 and 4; J3 Warta finance section and offering-to-service link, needing 1, 3 and C5 | all | as noted |

PMP's recommended order after Finance is B1–B2, then M1, then the rest. The Modul board draws different dependencies (MD 2.17):
- Warta needs Pengumuman.
- **Ibadah needs Data jemaat.** PMP §6 says only "Core; uses Membership when on".
- Kehadiran needs Ibadah.
- Keuangan unit needs Keuangan plus a unit-run Kas/Bank.
- Persetujuan di aplikasi needs the approver table.

## Conflicts to put to the user (do not assume)
1. Which personas go in the picker (the core 11, or with Stevi, Agustina, Kevin and Petugas verifikasi)?
2. Should the Bendahara's home be Main or BerandaJabatan? Should the app add the missing link from finance back to the platform home?
3. Should phone-only personas be on web, in a phone frame or hidden?
4. Bendahara vacancy: does the seed start filled or vacant, who revokes, and which successor?
5. Starting module status: the Modul board shows Data jemaat, Ibadah and Kehadiran off and Panitia read-only, but those boards behave as active (MD §3 row 33).
6. Are Masuk, Pemulihan, AlurMasuk, Awal (first-run) and WebVerifikasi kept as flows now that the picker is the only entry?
7. Novita is an active member since 2021 but also replays applying (§3 row 31). Should Kevin be the applicant?
8. Ferry Wenas is in Kolom 7 on some boards and Kolom 2 on others (row 28).
9. What made Penatua Kolom 2 vacant: Altje's term ending or Yohanis Rompas's death (row 16)?
10. Kehadiran shows Hendrik finalizing the Sunday count, but DL30 and DL11 give that to the Ketua Jemaat.

I did not read the board HTML or the screen specs other than 14, 05 and 22. The per-persona screen lists come from the journeys, footers and mock data, so a few boards may be assigned to the wrong persona.