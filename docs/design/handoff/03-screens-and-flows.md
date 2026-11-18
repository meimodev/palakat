# Screens and flows

Inventory of every board on the Palakat design canvas, generated from the canvas files on 18 November 2026. Board titles and state names are the Indonesian labels used on the canvas; do not translate them in code or tickets.

Canvas: https://claude.ai/artifact/J8KD2YST4nhJUNkSFrNZuF

## Totals

| Form | Boards |
| --- | --- |
| Phone (390 × 844) | 101 |
| Laptop (1440 wide, fluid) | 86 |
| A4 page (portrait 794 × 1123, or landscape) | 8 |
| Sheet (maps and decisions) | 4 |
| **All boards** | **199** |

34 of the boards are flows with typed input and live refusals (the "Alur" boards of rounds 2 to 5 and the refund flow). The round-one finance boards are click-through prototypes with their own state.

## How to read the canvas

- **Start on the page "Peta dan keputusan".** "Peta layar" maps the finance screens, "Peta layar · Putaran 2–5" maps the platform screens with a link to every board, "Cakupan keadaan" lists which states are drawn for each finance object, and "Keputusan desain" lists the numbered design decisions with a link to the board that shows each one.
- **Play a board** with the play button in the canvas toolbar, then pick the board from the list. Links between boards work in play mode.
- **States** are switched with the board's tweak (the sliders icon in the canvas toolbar). The inventory below lists the options. Changing a tweak saves it as the board's new default, so set it back when you are done.
- **Phone and laptop boards share content.** A laptop board has the same file name with the prefix `Web`.

## Phone and laptop

Only three desk posts have a designed laptop layout: Bendahara Jemaat, Sekretaris Jemaat and Operator. Every other post is designed for the phone. Those phone screens still open in a browser, but no laptop layout is drawn for them.

Below 860 px a laptop page collapses its side navigation into a drawer behind a "Menu" button.

## Prototype devices that are not part of the app

These exist only so one board can show a whole journey. Do not build them.

| Device | Where | What it stands for |
| --- | --- | --- |
| "Dilihat sebagai" chips | Two-sided flows (requester and verifier) | Two different people on two different devices |
| Buttons starting with "Contoh:" | Sign-in, push permission | Something that happens outside the screen: the phone grants a permission, a Penatua verifies |
| The code 123456 | Sign-in, phone number change, backup email | The six-digit code the person receives |
| "Di prototipe ini: …" hints | Search and matching steps | The one sample record that matches |

## Sample data used on every board

The "today" of the design is 16/11/2026. The church is Jemaat Karunia. October 2026 is the month being closed; September 2026 is already closed.

| Person | Post |
| --- | --- |
| Meiske Lumentut | Bendahara Jemaat |
| Olvie Pangemanan | Sekretaris Jemaat |
| Yanti Sumual | Operator |
| Pdt. Lidya Rondonuwu | Ketua Jemaat, Ketua BPMJ, the approving "Pimpinan Jemaat yang berwenang" |
| Pnt. Jefry Wowor | Wakil Ketua BPMJ, second checker |
| Pnt. Hendrik Rumagit | Penatua Kolom 7 and Ketua Komisi Diakonia |
| Deasy Tumbelaka | Bendahara Kolom 7 |
| Stevi Lengkong, Natalia Rumengan, Rivo Mandagi | Ketua, Sekretaris, Bendahara of Panitia Natal 2026 |
| Novita Wenas | Member, Keluarga Wenas-Lasut, Kolom 7 |

All names are invented. The Mata Anggaran rows in the samples are invented too; a church's own list replaces them at setup.

## Journeys by role

Each line names the boards that carry the journey, in order. Titles are as they appear on the canvas.

**Anyone, before a post applies**

1. "Alur · Masuk dan menghubungkan akun": phone number, six-digit code, then name and birth date, verified by the Penatua Kolom.
2. "Beranda" (page Putaran 2): one combined home for all posts a person holds.
3. "Alur · Akun saya": phone number, optional backup email, devices, push settings, sign-out.
4. "Keadaan umum": loading, failed, offline, not authorised, module off, session ended.

**Bendahara Jemaat (phone and laptop)**

1. "3 · Pengaturan awal dan saldo awal", "24 · Pengaturan awal: identitas dan daftar", "8 · Terbitkan Mata Anggaran".
2. "1 · Harian: catat sampai bukukan", with "6 · Bagi ke beberapa Mata Anggaran", "10 · Persembahan dengan beberapa bagian", "11 · Uang Muka, Titipan, Penggantian biaya", "19 · Dokumen pendukung", "20 · Draf".
3. "4 · Koreksi, persetujuan, kejadian", "25 · Pengembalian" and "Alur · Pengembalian", "31 · Alih peruntukan".
4. "2 · Akhir bulan: rekonsiliasi dan tutup buku", with "5 · Hitung kas" and "30 · Rekonsiliasi: isi rekening koran dan cocok sebagian".
5. "15 · Laporan", the A4 pages, "16 · Daftar Bukti Kas dan celah nomor", "18 · Ekspor data Jemaat".
6. "9 · Bendahara, sesi, serah terima", "Alur · Kas/Bank unit", "87 · Hambatan dari unit".

**Sekretaris Jemaat (phone and laptop)**

1. "Dokumen gereja", "Terbitkan dokumen", "Alur · Menerbitkan dokumen".
2. "Permohonan surat", "Alur · Permohonan surat".
3. "Pengumuman", "Warta Jemaat · edisi 22/11/2026", "Alur · Warta mingguan", "A4 · Warta Jemaat edisi 22/11/2026".
4. "Tampilkan nama (pengecualian)".

**Operator (phone and laptop)**

1. "Impor buku anggota", "Alur · Buku anggota", "Kemungkinan data ganda".
2. "Menjalankan jabatan kosong", "Alur · Menjalankan jabatan kosong"; on finance boards switch `jabatanKosong` on.
3. "Cari orang", "Alur · Memulihkan akun anggota".

**Pimpinan Jemaat yang berwenang (phone)**

1. "Modul", "Alur · Modul".
2. "Penugasan jabatan", "Alur · Penugasan jabatan", "Pelimpahan tugas", "Alur · Pelimpahan tugas".
3. "Alur · Pemberi persetujuan", "Alur · Membentuk Panitia", "Permintaan dana" (approving).

**Penatua Kolom (phone)**

1. "Verifikasi data", "Konfirmasi keluarga", "Data anggota dan keluarga".
2. "Peristiwa", "Alur · Peristiwa" (verifier side), "Alur · Menjadi anggota" (verifier side).
3. "Ibadah dan kegiatan", "Jumlah kehadiran", "Alur · Ibadah dan kehadiran".
4. "Alur · Memulihkan akun anggota" (confirming identity).

**Bendahara unit and committee officers (phone)**

1. "Keuangan Kolom 7", "Alur · Keuangan unit", "Pernyataan kesiapan per peruntukan".
2. "Permintaan dana", "Alur · Permintaan dana".
3. "Panitia Natal 2026", "Alur · Panitia".

**Anggota jemaat (phone)**

1. "Permohonan menjadi anggota", "Alur · Menjadi anggota".
2. "Tampilan nama saya di publikasi", "Alur · Data saya", "Cabut izin dan hapus data saya".
3. "Peristiwa", "Permohonan surat", "Warta Jemaat", "Persembahan saya".

## Inventory by canvas page

Columns: the board title as shown on the canvas; its file in the canvas project; the form; whether it is a typed flow; and the states it can be switched to. A state list such as "keadaan: A · B · C" is the board's tweak named `keadaan` with those options. `jabatanKosong (on/off)` switches a finance screen into "Operator runs the vacant Bendahara post".

### Ponsel

Finance round 1, phone: the nine core prototypes. 9 boards.

| Board | File | Form | Flow | States |
| --- | --- | --- | --- | --- |
| 1 · Harian: catat sampai bukukan | `Main.dc.html` | Phone |  | jabatanKosong (on/off); bulan: ramai · sepi; gagalSimpan (on/off) |
| 2 · Akhir bulan: rekonsiliasi dan tutup buku | `TutupBuku.dc.html` | Phone |  | jabatanKosong (on/off); gagalDiCekTerakhir (on/off) |
| 3 · Pengaturan awal dan saldo awal | `Awal.dc.html` | Phone |  |  |
| 4 · Koreksi, persetujuan, kejadian | `Koreksi.dc.html` | Phone |  | jabatanKosong (on/off); bulanTransaksi: Belum ditutup · Sudah ditutup |
| 5 · Hitung kas | `HitungKas.dc.html` | Phone |  | jabatanKosong (on/off); contohTerisi (on/off) |
| 6 · Bagi ke beberapa Mata Anggaran | `Bagi.dc.html` | Phone |  | jabatanKosong (on/off) |
| 7 · Lainnya dan pengaturan | `Lainnya.dc.html` | Phone |  |  |
| 8 · Terbitkan Mata Anggaran | `MataAnggaran.dc.html` | Phone |  | jabatanKosong (on/off) |
| 9 · Bendahara, sesi, serah terima | `Bendahara.dc.html` | Phone |  | keadaan: Bendahara aktif · Belum ada Bendahara aktif |

### Web

Finance round 1, laptop: the twelve core pages. 12 boards.

| Board | File | Form | Flow | States |
| --- | --- | --- | --- | --- |
| Web · Beranda | `WebBeranda.dc.html` | Laptop |  | jabatanKosong (on/off); bulan: ramai · sepi |
| Web · Transaksi dan koreksi | `WebTransaksi.dc.html` | Laptop |  | jabatanKosong (on/off) |
| Web · Rekonsiliasi | `WebRekonsiliasi.dc.html` | Laptop |  | jabatanKosong (on/off) |
| Web · Tutup buku | `WebTutupBuku.dc.html` | Laptop |  | jabatanKosong (on/off); adaHambatan (on/off) |
| Web · Saldo awal pencatatan | `WebAwal.dc.html` | Laptop |  |  |
| Web · Laporan F01 | `WebLaporan.dc.html` | Laptop |  | jabatanKosong (on/off); jenis: sementara · resmi |
| Web · Hitung kas | `WebHitungKas.dc.html` | Laptop |  | jabatanKosong (on/off) |
| Web · Terbitkan Mata Anggaran | `WebMataAnggaran.dc.html` | Laptop |  | jabatanKosong (on/off) |
| Web · Pengaturan | `WebPengaturan.dc.html` | Laptop |  | keadaan: Bendahara aktif · Belum ada Bendahara aktif |
| Tablet · Beranda | `TabBeranda.dc.html` | Laptop |  | bulan: ramai · sepi |
| Tablet · Transaksi | `TabTransaksi.dc.html` | Laptop |  |  |
| Tablet · Catat transaksi | `TabCatat.dc.html` | Laptop |  |  |

### Peta dan keputusan

Maps and decision sheets (read these first on the canvas). 4 boards.

| Board | File | Form | Flow | States |
| --- | --- | --- | --- | --- |
| Peta layar | `PetaLayar.dc.html` | Sheet |  |  |
| Cakupan keadaan | `Cakupan.dc.html` | Sheet |  |  |
| Keputusan desain | `Keputusan.dc.html` | Sheet |  |  |
| Peta layar · Putaran 2–5 | `PetaPlatform.dc.html` | Sheet |  |  |

### Keuangan · P2 dan P3

Finance, later slices: offerings, advances, restricted access, second checker, AI, reports, import, export. 19 boards.

| Board | File | Form | Flow | States |
| --- | --- | --- | --- | --- |
| 10 · Persembahan dengan beberapa bagian | `Persembahan.dc.html` | Phone |  | jabatanKosong (on/off) |
| 11 · Uang Muka, Titipan, Penggantian biaya | `Kewajiban.dc.html` | Phone |  | jabatanKosong (on/off) |
| 12 · Akses terbatas per peruntukan | `Terbatas.dc.html` | Phone |  |  |
| 13 · Wajib pemeriksa kedua | `Pemeriksa.dc.html` | Phone |  | masukSebagai: Bendahara · Pemeriksa kedua; adaPemeriksaKedua (on/off) |
| 14 · Bantuan AI saat mencatat | `BantuanAI.dc.html` | Phone |  | jabatanKosong (on/off); keadaanAI: tersedia · biaya 70% · batas biaya tercapai · sedang tidak tersedia |
| Web · Uang Muka dan Titipan | `WebKewajiban.dc.html` | Laptop |  | jabatanKosong (on/off) |
| Web · Paket Laporan F01–F14 | `WebPaketLaporan.dc.html` | Laptop |  | jabatanKosong (on/off); salinan: Seluruh Jemaat · TERBATAS · Peruntukan Diakonia |
| Web · Daftar Bukti Kas dan celah nomor | `WebBukti.dc.html` | Laptop |  | jabatanKosong (on/off) |
| Web · Impor | `WebImpor.dc.html` | Laptop |  | jabatanKosong (on/off) |
| Web · Ekspor data Jemaat | `WebEkspor.dc.html` | Laptop |  | jabatanKosong (on/off) |
| Web · Bantuan AI akhir bulan | `WebAI.dc.html` | Laptop |  | jabatanKosong (on/off); biayaAI: 40% · 75% · 95% · 100% |
| 15 · Laporan | `Laporan.dc.html` | Phone |  | jabatanKosong (on/off); jenis: resmi · sementara |
| 16 · Daftar Bukti Kas dan celah nomor | `Bukti.dc.html` | Phone |  | jabatanKosong (on/off) |
| 17 · Impor | `Impor.dc.html` | Phone |  | jabatanKosong (on/off) |
| 18 · Ekspor data Jemaat | `Ekspor.dc.html` | Phone |  | jabatanKosong (on/off) |
| Web · Persembahan | `WebPersembahan.dc.html` | Laptop |  | jabatanKosong (on/off) |
| Web · Akses terbatas | `WebTerbatas.dc.html` | Laptop |  |  |
| Web · Wajib pemeriksa kedua | `WebPemeriksa.dc.html` | Laptop |  | masukSebagai: Bendahara · Pemeriksa kedua |
| Web · Contoh file Excel | `WebExcel.dc.html` | Laptop |  | jabatanKosong (on/off) |

### Pelengkap

Finance, supporting screens: evidence, drafts, incidents, refunds, sign-in, search, settings, AI, general states. 61 boards.

| Board | File | Form | Flow | States |
| --- | --- | --- | --- | --- |
| 19 · Dokumen pendukung: verifikasi, pengecualian, penolakan | `Dokumen.dc.html` | Phone |  | jabatanKosong (on/off) |
| 20 · Draf: pindah tanggal, batalkan, hapus | `Draf.dc.html` | Phone |  | jabatanKosong (on/off); konflik (on/off); drafKosong (on/off) |
| 22 · Kejadian setelah tutup buku | `Kejadian.dc.html` | Phone |  | jabatanKosong (on/off); menghambatBulanBerikutnya (on/off) |
| 23 · Persetujuan format laporan | `FormatLaporan.dc.html` | Phone |  | jabatanKosong (on/off) |
| 24 · Pengaturan awal: identitas dan daftar | `AwalIsian.dc.html` | Phone |  |  |
| 25 · Pengembalian | `Pengembalian.dc.html` | Phone |  | jabatanKosong (on/off) |
| 26 · Pemberitahuan | `Pemberitahuan.dc.html` | Phone |  | jabatanKosong (on/off) |
| 27 · Masuk dan menunggu verifikasi | `Masuk.dc.html` | Phone |  | setelahMasuk: Menunggu verifikasi wewenang · Bendahara · Akses terbatas · Administrator sistem |
| 28 · Cari dan tanya | `Cari.dc.html` | Phone |  | jabatanKosong (on/off) |
| Web · Dokumen pendukung | `WebDokumen.dc.html` | Laptop |  | jabatanKosong (on/off) |
| Web · Draf: pindah tanggal dan batalkan | `WebDraf.dc.html` | Laptop |  | jabatanKosong (on/off); konflik (on/off); drafKosong (on/off) |
| Web · Kejadian setelah tutup buku | `WebKejadian.dc.html` | Laptop |  | jabatanKosong (on/off); menghambatBulanBerikutnya (on/off) |
| Web · Persetujuan format laporan | `WebFormatLaporan.dc.html` | Laptop |  | jabatanKosong (on/off) |
| Web · Pengaturan awal: identitas dan daftar | `WebAwalIsian.dc.html` | Laptop |  |  |
| Web · Pengembalian | `WebPengembalian.dc.html` | Laptop |  | jabatanKosong (on/off) |
| Web · Pemberitahuan | `WebPemberitahuan.dc.html` | Laptop |  | jabatanKosong (on/off) |
| Web · Masuk dan menunggu verifikasi | `WebMasuk.dc.html` | Laptop |  | setelahMasuk: Menunggu verifikasi wewenang · Bendahara · Akses terbatas · Administrator sistem |
| Web · Cari dan tanya | `WebCari.dc.html` | Laptop |  | jabatanKosong (on/off) |
| Web · Catat transaksi | `WebCatat.dc.html` | Laptop |  | jabatanKosong (on/off) |
| Web · Koreksi dengan pembalikan | `WebKoreksi.dc.html` | Laptop |  | jabatanKosong (on/off); bulanTransaksi: Belum ditutup · Sudah ditutup |
| Web · Verifikasi wewenang (halaman internal) | `WebVerifikasi.dc.html` | Laptop |  |  |
| 29 · Persetujuan: ganti catatan, gugur karena perubahan | `Persetujuan.dc.html` | Phone |  | jabatanKosong (on/off) |
| 30 · Rekonsiliasi: isi rekening koran dan cocok sebagian | `RekonIsi.dc.html` | Phone |  | jabatanKosong (on/off); wajibPemeriksaKedua (on/off); bukuBerubah (on/off) |
| 31 · Alih peruntukan | `AlihPeruntukan.dc.html` | Phone |  | jabatanKosong (on/off) |
| 32 · Pengaturan: tambah dan ubah, berlaku mulai bulan tertentu | `UbahPengaturan.dc.html` | Phone |  |  |
| 33 · Pemilih bulan dan daftar kosong | `PilihBulan.dc.html` | Phone |  | jabatanKosong (on/off) |
| 34 · Pemulihan akun | `Pemulihan.dc.html` | Phone |  |  |
| 35 · Bantuan AI dari foto nota | `AIFoto.dc.html` | Phone |  | jabatanKosong (on/off) |
| 36 · Bantuan AI akhir bulan | `AIBulan.dc.html` | Phone |  | jabatanKosong (on/off); biayaAI: 40% · 75% · 95% · 100% |
| Web · Persetujuan: ganti catatan dan perubahan | `WebPersetujuan.dc.html` | Laptop |  | jabatanKosong (on/off) |
| Web · Rekonsiliasi: isi rekening koran dan cocok sebagian | `WebRekonIsi.dc.html` | Laptop |  | jabatanKosong (on/off); wajibPemeriksaKedua (on/off); bukuBerubah (on/off) |
| Web · Alih peruntukan | `WebAlihPeruntukan.dc.html` | Laptop |  | jabatanKosong (on/off) |
| Web · Pengaturan: tambah dan ubah | `WebUbahPengaturan.dc.html` | Laptop |  |  |
| Web · Pemilih bulan dan daftar kosong | `WebPilihBulan.dc.html` | Laptop |  | jabatanKosong (on/off) |
| Web · Pemulihan akun | `WebPemulihan.dc.html` | Laptop |  |  |
| Web · Bantuan AI dari foto nota | `WebAIFoto.dc.html` | Laptop |  | jabatanKosong (on/off) |
| Web · Bagi ke beberapa Mata Anggaran | `WebBagi.dc.html` | Laptop |  | jabatanKosong (on/off) |
| Web · Uang Muka dan Titipan: catat pada kasus | `WebKasus.dc.html` | Laptop |  | jabatanKosong (on/off) |
| Web · Serah terima Bendahara | `WebSerahTerima.dc.html` | Laptop |  | keadaan: Bendahara aktif · Belum ada Bendahara aktif |
| 37 · Kasus baru: Uang Muka, Titipan, Penggantian biaya | `KasusBaru.dc.html` | Phone |  | jabatanKosong (on/off) |
| Web · Kasus baru: Uang Muka, Titipan, Penggantian biaya | `WebKasusBaru.dc.html` | Laptop |  | jabatanKosong (on/off) |
| 38 · Sambungan terputus dan sesi berakhir | `Sambungan.dc.html` | Phone |  | keadaan: Tidak ada sambungan · Sesi berakhir: lama tidak dipakai · Sesi berakhir: diakhiri dari perangkat lain · Sesi berakhir: wewenang berpindah; sambunganKembali (on/off) |
| Web · Sambungan terputus dan sesi berakhir | `WebSambungan.dc.html` | Laptop |  | keadaan: Tidak ada sambungan · Sesi berakhir: lama tidak dipakai · Sesi berakhir: diakhiri dari perangkat lain · Sesi berakhir: wewenang berpindah; sambunganKembali (on/off) |
| 39 · Foto dokumen pendukung | `Kamera.dc.html` | Phone |  | gagalUnggah (on/off) |
| 40 · Lihat file dokumen pendukung | `LihatDokumen.dc.html` | Phone |  | jabatanKosong (on/off) |
| Web · Lihat file dokumen pendukung | `WebLihatDokumen.dc.html` | Laptop |  | jabatanKosong (on/off) |
| 41 · Tanggal transaksi dan tanggal dokumen | `Tanggal.dc.html` | Phone |  | jabatanKosong (on/off) |
| Web · Tanggal transaksi dan tanggal dokumen | `WebTanggal.dc.html` | Laptop |  | jabatanKosong (on/off) |
| 42 · Lihat transaksi di balik angka laporan | `LihatTransaksi.dc.html` | Phone |  | jabatanKosong (on/off) |
| Web · Lihat transaksi di balik angka laporan | `WebLihatTransaksi.dc.html` | Laptop |  | jabatanKosong (on/off) |
| 43 · Bantuan AI: usulan Mata Anggaran dan pembagian | `AIMataAnggaran.dc.html` | Phone |  | jabatanKosong (on/off); usulan: Satu baris · Bagi ke dua baris · AI kurang yakin |
| Web · Bantuan AI: usulan Mata Anggaran dan pembagian | `WebAIMataAnggaran.dc.html` | Laptop |  | jabatanKosong (on/off); usulan: Satu baris · Bagi ke dua baris · AI kurang yakin |
| Web · Bantuan AI dari kalimat | `WebBantuanAI.dc.html` | Laptop |  | jabatanKosong (on/off); keadaanAI: tersedia · biaya 70% · batas biaya tercapai · sedang tidak tersedia |
| Web · Unggah dokumen pendukung | `WebUnggah.dc.html` | Laptop |  | jabatanKosong (on/off); gagalUnggah (on/off) |
| Web · Contoh file Excel TERBATAS | `WebExcelTerbatas.dc.html` | Laptop |  |  |
| 44 · Memuat, gagal memuat, Bukukan tidak terjadi | `Memuat.dc.html` | Phone |  | keadaan: Sedang memuat · Gagal memuat · Bukukan tidak terjadi |
| Web · Memuat, gagal memuat, Bukukan tidak terjadi | `WebMemuat.dc.html` | Laptop |  | keadaan: Sedang memuat · Gagal memuat · Bukukan tidak terjadi |
| 45 · Akun dan keluar | `Keluar.dc.html` | Phone |  |  |
| Web · Akun dan keluar | `WebKeluar.dc.html` | Laptop |  |  |
| 102 · Alur · Pengembalian | `AlurPengembalian.dc.html` | Phone | Flow with typed input |  |
| Web · Alur · Pengembalian | `WebAlurPengembalian.dc.html` | Laptop | Flow with typed input |  |

### A4 · Laporan resmi

Printed official report pages. 5 boards.

| Board | File | Form | Flow | States |
| --- | --- | --- | --- | --- |
| A4 · F01 Laporan Perbendaharaan Bulanan | `A4F01.dc.html` | A4 page |  |  |
| A4 · F02 Buku Kas Umum, halaman 1 dari 3 | `A4F02a.dc.html` | A4 page |  |  |
| A4 · F02 Buku Kas Umum, halaman 2 dari 3 | `A4F02b.dc.html` | A4 page |  |  |
| A4 · F02 Buku Kas Umum, halaman 3 dari 3 | `A4F02c.dc.html` | A4 page |  |  |
| A4 · F14 Lampiran, halaman 2 dari 3 | `A4F14.dc.html` | A4 page |  |  |

### A4 · Laporan sementara

Printed provisional report page. 1 boards.

| Board | File | Form | Flow | States |
| --- | --- | --- | --- | --- |
| A4 · F01 Laporan sementara | `A4Sementara.dc.html` | A4 page |  |  |

### A4 · Salinan TERBATAS

Printed restricted copy. 1 boards.

| Board | File | Form | Flow | States |
| --- | --- | --- | --- | --- |
| A4 · Salinan TERBATAS, peruntukan Diakonia | `A4Terbatas.dc.html` | A4 page |  |  |

### Putaran 2 · Kerangka platform

Platform frame: combined home, modules, posts, vacancy cover, delegation, notifications, sign-in, account, recovery, general states. 26 boards.

| Board | File | Form | Flow | States |
| --- | --- | --- | --- | --- |
| 46 · Beranda | `BerandaJabatan.dc.html` | Phone |  | keadaan: Beberapa jabatan · Bendahara Jemaat · Sekretaris Jemaat · Operator · Anggota jemaat · Jabatan dipilih otomatis · Dua jabatan dapat bertindak |
| Web · Beranda | `WebBerandaJabatan.dc.html` | Laptop |  | keadaan: Beberapa jabatan · Bendahara Jemaat · Sekretaris Jemaat · Operator · Anggota jemaat · Jabatan dipilih otomatis · Dua jabatan dapat bertindak |
| 47 · Modul | `Modul.dc.html` | Phone |  | keadaan: Daftar modul · Mengaktifkan Data jemaat · Menonaktifkan Warta Jemaat · Dilihat jabatan lain |
| 48 · Penugasan jabatan | `Penugasan.dc.html` | Phone |  | keadaan: Daftar jabatan · Catat penugasan · Menugaskan diri sendiri · Menunggu verifikasi wewenang |
| Web · Penugasan jabatan | `WebPenugasan.dc.html` | Laptop |  | keadaan: Daftar jabatan · Catat penugasan · Menugaskan diri sendiri · Menunggu verifikasi wewenang |
| 49 · Menjalankan jabatan kosong | `JabatanKosong.dc.html` | Phone |  | keadaan: Pita di setiap layar · Konfirmasi tutup buku · Tercatat di Riwayat · Wajib pemeriksa kedua · Jabatan sudah terisi |
| Web · Menjalankan jabatan kosong | `WebJabatanKosong.dc.html` | Laptop |  | keadaan: Pita di setiap layar · Konfirmasi tutup buku · Tercatat di Riwayat · Wajib pemeriksa kedua · Jabatan sudah terisi |
| 50 · Pelimpahan tugas | `Pelimpahan.dc.html` | Phone |  | keadaan: Daftar pelimpahan · Buat pelimpahan · Berakhir sendiri |
| 51 · Pemberitahuan | `KotakMasuk.dc.html` | Phone |  | keadaan: Ada pemberitahuan · Semua sudah selesai · Hanya modul Keuangan |
| Web · Pemberitahuan | `WebKotakMasuk.dc.html` | Laptop |  | keadaan: Ada pemberitahuan · Semua sudah selesai · Hanya modul Keuangan |
| 52 · Cari orang | `CariOrang.dc.html` | Phone |  | keadaan: Dilihat Operator · Dilihat Penatua Kolom 7 · Tidak ada hasil |
| Web · Cari orang | `WebCariOrang.dc.html` | Laptop |  | keadaan: Dilihat Operator · Dilihat Penatua Kolom 7 · Tidak ada hasil |
| 53 · Alur · Penugasan jabatan | `AlurPenugasan.dc.html` | Phone | Flow with typed input |  |
| 54 · Alur · Menjalankan jabatan kosong | `AlurJabatanKosong.dc.html` | Phone | Flow with typed input |  |
| Web · Alur · Menjalankan jabatan kosong | `WebAlurJabatanKosong.dc.html` | Laptop | Flow with typed input |  |
| 55 · Alur · Pelimpahan tugas | `AlurPelimpahan.dc.html` | Phone | Flow with typed input |  |
| 56 · Alur · Beranda gabungan | `AlurBeranda.dc.html` | Phone | Flow with typed input |  |
| 57 · Alur · Modul | `AlurModul.dc.html` | Phone | Flow with typed input |  |
| 58 · Alur · Masuk dan menghubungkan akun | `AlurMasuk.dc.html` | Phone | Flow with typed input |  |
| Web · Alur · Masuk dan menghubungkan akun | `WebAlurMasuk.dc.html` | Laptop | Flow with typed input |  |
| 59 · Alur · Akun saya | `AkunSaya.dc.html` | Phone | Flow with typed input |  |
| Web · Alur · Akun saya | `WebAkunSaya.dc.html` | Laptop | Flow with typed input |  |
| 60 · Alur · Memulihkan akun anggota | `AlurPulihkan.dc.html` | Phone | Flow with typed input |  |
| Web · Alur · Memulihkan akun anggota | `WebAlurPulihkan.dc.html` | Laptop | Flow with typed input |  |
| 61 · Keadaan umum | `KeadaanUmum.dc.html` | Phone |  | keadaan: Memuat · Gagal memuat · Tanpa sambungan · Tidak berwenang · Modul tidak aktif · Sesi berakhir |
| Web · Keadaan umum | `WebKeadaanUmum.dc.html` | Laptop |  | keadaan: Memuat · Gagal memuat · Tanpa sambungan · Tidak berwenang · Modul tidak aktif · Sesi berakhir |

### Putaran 3 · Sekretariat

Secretariat: church documents, letters, announcements, Warta Jemaat. 21 boards.

| Board | File | Form | Flow | States |
| --- | --- | --- | --- | --- |
| 62 · Dokumen gereja | `DokumenGereja.dc.html` | Phone |  | keadaan: Daftar dokumen · Dokumen dengan revisi · Belum ada dokumen · Dilihat anggota jemaat |
| Web · Dokumen gereja | `WebDokumenGereja.dc.html` | Laptop |  | keadaan: Daftar dokumen · Dokumen dengan revisi · Belum ada dokumen · Dilihat anggota jemaat |
| 63 · Terbitkan dokumen | `TerbitDokumen.dc.html` | Phone |  | keadaan: Mengisi · Sedang diunggah · Gagal diunggah · Diterbitkan · Ralat sebagai revisi |
| Web · Terbitkan dokumen | `WebTerbitDokumen.dc.html` | Laptop |  | keadaan: Mengisi · Sedang diunggah · Gagal diunggah · Diterbitkan · Ralat sebagai revisi |
| 64 · Permohonan surat | `PermohonanSurat.dc.html` | Phone |  | keadaan: Diajukan · Menerbitkan surat · Data jemaat tidak aktif · Diterbitkan · Tidak diterbitkan |
| Web · Permohonan surat | `WebPermohonanSurat.dc.html` | Laptop |  | keadaan: Diajukan · Menerbitkan surat · Data jemaat tidak aktif · Diterbitkan · Tidak diterbitkan |
| 65 · Pengumuman | `Pengumuman.dc.html` | Phone |  | keadaan: Daftar · Draf · Diterbitkan · Diarsipkan sendiri · Ralat sebagai revisi |
| Web · Pengumuman | `WebPengumuman.dc.html` | Laptop |  | keadaan: Daftar · Draf · Diterbitkan · Diarsipkan sendiri · Ralat sebagai revisi |
| 66 · Warta Jemaat · edisi 22/11/2026 | `WartaEditor.dc.html` | Phone |  | keadaan: Draf · Sudah diperiksa · Disetujui · Diterbitkan · Hanya Pengumuman yang aktif |
| Web · Warta Jemaat · edisi 22/11/2026 | `WebWartaEditor.dc.html` | Laptop |  | keadaan: Draf · Sudah diperiksa · Disetujui · Diterbitkan · Hanya Pengumuman yang aktif |
| 67 · Tampilkan nama (pengecualian) | `BukaNama.dc.html` | Phone |  | keadaan: Mengisi alasan · Alasan belum diisi · Tercatat · Bukan Sekretaris Jemaat |
| Web · Tampilkan nama (pengecualian) | `WebBukaNama.dc.html` | Laptop |  | keadaan: Mengisi alasan · Alasan belum diisi · Tercatat · Bukan Sekretaris Jemaat |
| 68 · Warta Jemaat | `WartaArsip.dc.html` | Phone |  | keadaan: Arsip edisi · Edisi dengan ralat · Dibaca anggota jemaat · Belum ada edisi |
| Web · Warta Jemaat | `WebWartaArsip.dc.html` | Laptop |  | keadaan: Arsip edisi · Edisi dengan ralat · Dibaca anggota jemaat · Belum ada edisi |
| 69 · Alur · Menerbitkan dokumen | `AlurDokumen.dc.html` | Phone | Flow with typed input |  |
| Web · Alur · Menerbitkan dokumen | `WebAlurDokumen.dc.html` | Laptop | Flow with typed input |  |
| 70 · Alur · Permohonan surat | `AlurSurat.dc.html` | Phone | Flow with typed input |  |
| Web · Alur · Permohonan surat | `WebAlurSurat.dc.html` | Laptop | Flow with typed input |  |
| 71 · Alur · Warta mingguan | `AlurWarta.dc.html` | Phone | Flow with typed input |  |
| Web · Alur · Warta mingguan | `WebAlurWarta.dc.html` | Laptop | Flow with typed input |  |
| A4 · Warta Jemaat edisi 22/11/2026 | `A4Warta.dc.html` | A4 page |  |  |

### Putaran 4 · Data jemaat

Member data: membership, paper-book import, family confirmation, verification, life events, display name, consent. 18 boards.

| Board | File | Form | Flow | States |
| --- | --- | --- | --- | --- |
| 72 · Permohonan menjadi anggota | `PermohonanAnggota.dc.html` | Phone |  | keadaan: Mengisi · Izin belum diberikan · Untuk anak · Diajukan · Dikembalikan · Diverifikasi · Tidak diterima |
| 73 · Impor buku anggota | `ImporBuku.dc.html` | Phone |  | keadaan: Ditampung · Lolos pengecekan · Sudah diimpor |
| Web · Impor buku anggota | `WebImporBuku.dc.html` | Laptop |  | keadaan: Ditampung · Lolos pengecekan · Sudah diimpor |
| 74 · Konfirmasi keluarga | `KonfirmasiKeluarga.dc.html` | Phone |  | keadaan: Belum dikonfirmasi · Dikonfirmasi di aplikasi · Formulir kertas diunggah · Aktif |
| 75 · Verifikasi data | `AntreanVerifikasi.dc.html` | Phone |  | keadaan: Antrean · Kembalikan dengan alasan · Milik keluarga sendiri · Jabatan kosong · Tidak ada yang menunggu |
| 76 · Data anggota dan keluarga | `DataAnggota.dc.html` | Phone |  | keadaan: Dilihat Penatua Kolom 7 · Dilihat Sekretaris Jemaat · Belum dikonfirmasi · Meninggal dunia · Penatua Kolom lain |
| Web · Data anggota dan keluarga | `WebDataAnggota.dc.html` | Laptop |  | keadaan: Dilihat Penatua Kolom 7 · Dilihat Sekretaris Jemaat · Belum dikonfirmasi · Meninggal dunia · Penatua Kolom lain |
| 77 · Peristiwa | `Peristiwa.dc.html` | Phone |  | keadaan: Mengajukan · Diajukan · Diverifikasi · Dikembalikan · Kematian · Pindah Kolom |
| 78 · Tampilan nama saya di publikasi | `TampilanNama.dc.html` | Phone |  | keadaan: Pilihan pribadi · Mengikuti bawaan keluarga · Masih mudah dikenali |
| 79 · Cabut izin dan hapus data saya | `CabutIzin.dc.html` | Phone |  | keadaan: Penjelasan · Konfirmasi · Permintaan lewat kertas · Sudah dihapus |
| 80 · Kemungkinan data ganda | `DataGanda.dc.html` | Phone |  | keadaan: Bandingkan · Gabungkan · Bukan orang yang sama |
| Web · Kemungkinan data ganda | `WebDataGanda.dc.html` | Laptop |  | keadaan: Bandingkan · Gabungkan · Bukan orang yang sama |
| 81 · Persembahan saya | `PersembahanSaya.dc.html` | Phone |  | keadaan: Ada persembahan bernama · Rincian · Belum ada · Bukan persembahan saya |
| 82 · Alur · Menjadi anggota | `AlurAnggota.dc.html` | Phone | Flow with typed input |  |
| 83 · Alur · Peristiwa | `AlurPeristiwa.dc.html` | Phone | Flow with typed input |  |
| 84 · Alur · Buku anggota | `AlurKeluarga.dc.html` | Phone | Flow with typed input |  |
| Web · Alur · Buku anggota | `WebAlurKeluarga.dc.html` | Laptop | Flow with typed input |  |
| 85 · Alur · Data saya | `AlurNama.dc.html` | Phone | Flow with typed input |  |

### Putaran 5 · Kolaborasi

Collaboration: unit finance, fund requests, committees, worship and attendance, cross-unit reports, named offerings. 22 boards.

| Board | File | Form | Flow | States |
| --- | --- | --- | --- | --- |
| 86 · Keuangan Kolom 7 | `KeuanganUnit.dc.html` | Phone |  | keadaan: Beranda unit · Dibukukan · Kas/Bank dikelola Bendahara Jemaat · Peruntukan lain · Pernyataan kesiapan · Tutup buku bukan wewenang unit |
| 87 · Hambatan dari unit | `SelesaikanUnit.dc.html` | Phone |  | keadaan: Hambatan · Mengisi alasan · Alasan belum diisi · Diselesaikan · Ada selisih |
| Web · Hambatan dari unit | `WebSelesaikanUnit.dc.html` | Laptop |  | keadaan: Hambatan · Mengisi alasan · Alasan belum diisi · Diselesaikan · Ada selisih |
| 88 · Permintaan dana | `PermintaanDana.dc.html` | Phone |  | keadaan: Menunggu persetujuan · Disetujui · Tidak disetujui · Kembali menunggu · Menyetujui permintaan sendiri · Di bawah batas · Persetujuan di luar aplikasi |
| 89 · Panitia Natal 2026 | `Panitia.dc.html` | Phone |  | keadaan: Perencanaan · Aktif · Penutupan keuangan · Sisa uang · Ditutup · Diarsipkan |
| 90 · Ibadah dan kegiatan | `Ibadah.dc.html` | Phone |  | keadaan: Draf · Dijadwalkan · Sedang berlangsung · Selesai · Ditutup · Ibadah seluruh Jemaat |
| 91 · Jumlah kehadiran | `Kehadiran.dc.html` | Phone |  | keadaan: Sedang dihitung · Sudah diperiksa · Ditetapkan · Koreksi · Petugas penghitung |
| 92 · Laporan | `LaporanLintas.dc.html` | Phone |  | keadaan: Seluruh Jemaat · Kolom 7 · Panitia Natal 2026 · Modul tidak aktif |
| Web · Laporan | `WebLaporanLintas.dc.html` | Laptop |  | keadaan: Seluruh Jemaat · Kolom 7 · Panitia Natal 2026 · Modul tidak aktif |
| 93 · Persembahan bernama | `PersembahanBernama.dc.html` | Phone |  | keadaan: Tanpa nama · Pilih pemberi · Tercatat atas nama anggota · Belum dikonfirmasi · Dilihat jabatan lain |
| Web · Persembahan bernama | `WebPersembahanBernama.dc.html` | Laptop |  | keadaan: Tanpa nama · Pilih pemberi · Tercatat atas nama anggota · Belum dikonfirmasi · Dilihat jabatan lain |
| 94 · Alur · Keuangan unit | `AlurUnit.dc.html` | Phone | Flow with typed input |  |
| Web · Alur · Keuangan unit | `WebAlurUnit.dc.html` | Laptop | Flow with typed input |  |
| 95 · Alur · Permintaan dana | `AlurDana.dc.html` | Phone | Flow with typed input |  |
| 96 · Alur · Ibadah dan kehadiran | `AlurIbadah.dc.html` | Phone | Flow with typed input |  |
| 97 · Alur · Panitia | `AlurPanitia.dc.html` | Phone | Flow with typed input |  |
| 98 · Alur · Pemberi persetujuan | `PemberiPersetujuan.dc.html` | Phone | Flow with typed input |  |
| 99 · Alur · Kas/Bank unit | `KasUnit.dc.html` | Phone | Flow with typed input |  |
| Web · Alur · Kas/Bank unit | `WebKasUnit.dc.html` | Laptop | Flow with typed input |  |
| 100 · Alur · Membentuk Panitia | `AlurPanitiaBaru.dc.html` | Phone | Flow with typed input |  |
| 101 · Pernyataan kesiapan per peruntukan | `Kesiapan.dc.html` | Phone |  | masukSebagai: Bendahara · Bendahara Komisi Diakonia |
| Web · Pernyataan kesiapan per peruntukan | `WebKesiapan.dc.html` | Laptop |  | masukSebagai: Bendahara · Bendahara Komisi Diakonia |
