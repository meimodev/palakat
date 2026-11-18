// mock-data.md 2.19: secretariat.
import 'model.dart';

/// DokumenGereja. All tinta; all Diterbitkan except the Revisi 2 row. Section 3
/// row 35: 18/11/2026 is after "today"; keep.
const semuaDokumenGereja = [
  DokumenGereja(
    judul: 'SK BPMJ No. 14/2026 · Penugasan Syamas Kolom 3',
    jenisTanggalUntuk:
        'Keputusan dan surat edaran · 18/11/2026 · Pelayan dan pengurus',
    status: 'Diterbitkan',
    gaya: GayaLabel.tinta,
  ),

  /// "Diterbitkan oleh Olvie Pangemanan, 14/11/2026 09.10".
  DokumenGereja(
    judul: 'Surat edaran jadwal ibadah Natal 2026',
    jenisTanggalUntuk:
        'Keputusan dan surat edaran · 12/11/2026 · Semua anggota',
    status: 'Revisi 2',
    gaya: GayaLabel.tinta,
  ),
  DokumenGereja(
    judul: 'Notulen rapat BPMJ 08/11/2026',
    jenisTanggalUntuk: 'Notulen rapat · Pelayan dan pengurus',
    status: 'Diterbitkan',
    gaya: GayaLabel.tinta,
  ),
  DokumenGereja(
    judul: 'Tata ibadah Minggu Adven I',
    jenisTanggalUntuk: 'Tata gereja dan liturgi · Semua anggota',
    status: 'Diterbitkan',
    gaya: GayaLabel.tinta,
  ),
  DokumenGereja(
    judul: 'Surat keterangan · Novita Wenas',
    jenisTanggalUntuk:
        'Surat untuk anggota · 15/11/2026 · hanya anggota dan keluarganya',
    status: 'Diterbitkan',
    gaya: GayaLabel.tinta,
  ),
  DokumenGereja(
    judul: 'Serah terima aset Panitia Paskah 2026',
    jenisTanggalUntuk:
        'Serah terima aset panitia · 30/04/2026 · Pelayan dan pengurus',
    status: 'Diterbitkan',
    gaya: GayaLabel.tinta,
  ),
];

/// `Dilihat anggota jemaat` shows rows 2, 4, 5 (indexes 1, 3, 4).
const dokumenGerejaUntukAnggota = [1, 3, 4];
const dokumenRevisi2Oleh =
    'Diterbitkan oleh Olvie Pangemanan, 14/11/2026 09.10';

/// TerbitDokumen.
const terbitDokumen = (
  ditujukan: 'Ditujukan untuk: Semua anggota · 12/11/2026',
  diterbitkan: 'Diterbitkan oleh Olvie Pangemanan, 12/11/2026 16.40',
  ralat: 'Jam ibadah malam Natal: 19.00, bukan 18.00.',
);

/// Pengumuman. Draft by "Operator Yanti Sumual".
const semuaPengumuman = [
  Pengumuman(
    judul: 'Kerja bakti halaman gereja',
    untuk: 'Semua anggota · berakhir pada 20/11/2026',
    status: 'Diterbitkan',
    gaya: GayaLabel.tinta,
  ),
  Pengumuman(
    judul: 'Pendaftaran katekisasi sidi 2027',
    untuk: 'Semua anggota · tanpa tanggal berakhir',
    status: 'Draf',
    gaya: GayaLabel.draf,
  ),
  Pengumuman(
    judul: 'Rapat pelayan khusus',
    untuk: 'Pelayan dan pengurus · berakhir pada 25/11/2026',
    status: 'Draf',
    gaya: GayaLabel.draf,
  ),
  Pengumuman(
    judul: 'Latihan paduan suara Kolom 7',
    untuk: 'Kolom 7 · berakhir 15/11/2026',
    status: 'Diarsipkan',
    gaya: GayaLabel.abu,
  ),
];
const pengumumanKerjaBaktiIsi =
    'Sabtu, 21 November 2026 pukul 07.00. Membawa alat kebersihan masing-masing.';
const pengumumanKerjaBaktiOleh =
    'Diterbitkan oleh Olvie Pangemanan, 16/11/2026 08.15';
const pengumumanDrafOleh = 'Operator Yanti Sumual';

/// Warta 22/11/2026 (WartaEditor, A4Warta). Section 3 row 32: attendance
/// 231 (Pagi) / 412 here; Kehadiran `Koreksi` shows 236. Row 35: the
/// review dates are after "today"; keep.
const warta22November = (
  ibadah: 'Subuh 05.00 · Pagi 09.00 · Malam 18.00',
  pengumuman: 'Kerja bakti halaman gereja · Pendaftaran katekisasi sidi 2027',
  kehadiran: '412 orang (Subuh 96 · Pagi 231 · Malam 85)',
  kehadiranJudul: 'Kehadiran Minggu 15/11/2026',
  peristiwa: [
    'Syukur HUT pernikahan: Keluarga Wenas-Lasut — Kolom 7',
    'Sampul syukur: Tanpa nama, Kolom 4',
  ],
  pengecualianNama: 'Kel. Mamahit — Kolom 4',
  pendapatan: 'Pendapatan Rp14.820.000',
  belanja: 'Belanja Rp11.455.000',
  diperiksa: 'Olvie Pangemanan, 20/11/2026 14.05',
  disetujui: '20/11/2026 14.20',
  diterbitkan: '21/11/2026 17.00',
  diterbitkanA4: 'Diterbitkan 21/11/2026 oleh Sekretaris Jemaat',
);

/// AlurWarta adds this.
const alurWartaTambahan = 'Rabu, 25/11/2026 pukul 19.00';

/// BukaNama.
const bukaNamaAlasan =
    'Persembahan khusus pembangunan diumumkan atas keputusan Sidang Majelis Jemaat 08/11/2026.';
const bukaNamaOleh =
    'Oleh Olvie Pangemanan, Sekretaris Jemaat · 20/11/2026 13.50';

/// WartaArsip.
const wartaArsip = [
  EdisiWarta(
    edisi: 'Edisi 15/11/2026',
    terbit: 'Diterbitkan 14/11/2026 17.00',
    status: 'Diterbitkan',
    gaya: GayaLabel.tinta,
  ),
  EdisiWarta(
    edisi: 'Edisi 08/11/2026',
    terbit: 'Diterbitkan 07/11/2026 · 1 ralat',
    status: 'Diterbitkan',
    gaya: GayaLabel.tinta,
  ),
  EdisiWarta(
    edisi: 'Edisi 01/11/2026',
    terbit: 'Diterbitkan 31/10/2026',
    status: 'Diarsipkan',
    gaya: GayaLabel.abu,
  ),
  EdisiWarta(
    edisi: 'Edisi 25/10/2026',
    terbit: 'Diterbitkan 24/10/2026',
    status: 'Diarsipkan',
    gaya: GayaLabel.abu,
  ),
];
const wartaArsipRalat = (
  teks: 'Jadwal ibadah Kolom 5 dipindah ke Kamis 12/11/2026.',
  pada: '09/11/2026 08.30',
);

/// PermohonanSurat. Issued: "No. 027/SKet/XI/2026 · 15/11/2026". Refused
/// Atestasi recorded 16/11/2026.
const semuaPermohonanSurat = [
  PermohonanSurat(
    judul: 'Surat keterangan · Novita Wenas',
    sub: 'Diajukan anggota 14/11/2026 · untuk melamar pekerjaan',
    status: 'Diajukan',
    gaya: GayaLabel.garis,
  ),
  PermohonanSurat(
    judul: 'Atestasi · Keluarga Lasut',
    sub: 'Dicatat Operator Yanti Sumual 15/11/2026',
    status: 'Diajukan',
    gaya: GayaLabel.garis,
  ),
  PermohonanSurat(
    judul: 'Atestasi · Ferry Wenas',
    sub: 'Diajukan 13/11/2026',
    status: 'Diajukan',
    gaya: GayaLabel.garis,
  ),
];
const suratDiterbitkanNomor = 'No. 027/SKet/XI/2026 · 15/11/2026';
const atestasiDitolakPada = '16/11/2026';

/// AlurSurat (board `P`): (jenis, nama, sub, status, keluarga · kolom).
const alurSurat = [
  (
    'Surat keterangan',
    'Novita Wenas',
    'Diajukan 14/11/2026 · untuk melamar pekerjaan',
    'Diajukan',
    'Wenas-Lasut · Kolom 7',
  ),
  (
    'Atestasi keluar',
    'Keluarga Lasut',
    'Diajukan 15/11/2026 · pindah ke Jemaat lain',
    'Diajukan',
    'Lasut · Kolom 4',
  ),
  (
    'Surat keterangan',
    'Agustina Lasut',
    'Dicatat Operator di kantor, 16/11/2026',
    'Diajukan',
    'Wenas-Lasut · Kolom 7',
  ),
];
