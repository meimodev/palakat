// mock-data.md 2.1: today and the church.
import 'model.dart';

// Today (16/11/2026; flow boards' HARI / HARI_T) is `hari` / `hariTeks` in
// format.dart (4.1), not repeated here.

const gereja = Gereja(
  nama: 'Jemaat Karunia',
  namaWarta: 'GMIM Jemaat Karunia',
  zonaWaktu: 'WITA',
  tahunBukuMulai: '1 Januari',
  mulaiPencatatan: '15/09/2026',
);

const teksZonaTahunBuku =
    'WITA · tahun buku mulai 1 Januari (tidak dapat diubah)';
const teksMulaiPencatatan = 'Pencatatan dimulai 15 September 2026';

/// Oktober 2026 is being closed; September 2026 is closed; November 2026
/// is the running month.
const bulanDitutupSekarang = 'Oktober 2026';
const bulanBerjalan = 'November 2026';

// Official and provisional October report.
const idLaporanOktober = 'SNP-2026-10-01';
const dibekukanOktober = 'Dibekukan 16/11/2026 11.05';
const versiMAOktober = '2026.1';
const laporanSementaraTanpaId = 'Belum punya ID laporan resmi';
const laporanSementaraDibuat = 'Dibuat 14/11/2026 09.20'; // A4Sementara

/// Report format. Persetujuan of the format: 03/10/2026, Pdt. Lidya Rondonuwu,
/// Ketua BPMJ. Section 3 row 21: FormatLaporan prints "Dicatat oleh
/// Meiske L., 03/10/2026 11.40"; WebPengaturan "sudah dicatat · 01/11/2026";
/// WebLaporan "Dicatat oleh Meiske L., 02/11/2026 09.10". Keep each board's.
const formatLaporan = 'Bawaan Palakat v1';
const persetujuanFormatTanggal = '03/10/2026';

/// Footer of every A4 page.
const kakiA4 =
    'Palakat · format bawaan aplikasi, bukan formulir resmi GMIM · Jemaat Karunia';

const aturanPersetujuan =
    'Wajib untuk Belanja Rp2.000.000 ke atas · berlaku mulai September 2026';
const aturanDokumenPendukung =
    'Wajib untuk semua Belanja · Bendahara boleh memverifikasi unggahannya sendiri';
const pemberiPengecualian = 'Ketua BPMJ';

/// PermintaanDana: below this no persetujuan is needed.
const batasPermintaanDana = 250000;
const teksBatasPermintaanDana =
    'di bawah batas Rp250.000 yang ditetapkan Jemaat';

/// AIBulan, WebAI: "Batas biaya AI per bulan · … dari Rp150.000"; tweak
/// `biayaAI` 40 · 75 · 95 · 100 %.
const batasBiayaAI = 150000;

/// WebPengaturan.
const seriNoBukti =
    'BKU-2026-0001 Biasa · OPN-2026-0001 Saldo awal pencatatan · ADJ-2026-0001 Penyesuaian';

/// Lainnya prints the series this way.
const seriNoBuktiLainnya =
    'BKU-2026-0001 Biasa · OPN Saldo awal pencatatan · ADJ Penyesuaian';

/// 12 Kolom ("di 12 Kolom", "11 dari 12 terisi").
const jumlahKolom = 12;

const unitBernama = [
  Unit(id: 'jemaat', jenis: JenisUnit.jemaat, nama: 'Jemaat'),
  Unit(id: 'kolom2', jenis: JenisUnit.kolom, nama: 'Kolom 2'),
  Unit(id: 'kolom3', jenis: JenisUnit.kolom, nama: 'Kolom 3'),
  Unit(id: 'kolom4', jenis: JenisUnit.kolom, nama: 'Kolom 4'),
  Unit(id: 'kolom5', jenis: JenisUnit.kolom, nama: 'Kolom 5'),
  Unit(id: 'kolom7', jenis: JenisUnit.kolom, nama: 'Kolom 7'),
  Unit(id: 'kolom11', jenis: JenisUnit.kolom, nama: 'Kolom 11'),
  Unit(id: 'bipraPemuda', jenis: JenisUnit.bipra, nama: 'BIPRA Pemuda'),
  Unit(id: 'bipraRemaja', jenis: JenisUnit.bipra, nama: 'BIPRA Remaja'),
  Unit(id: 'komisiDiakonia', jenis: JenisUnit.komisi, nama: 'Komisi Diakonia'),
  Unit(
    id: 'komisiPembangunan',
    jenis: JenisUnit.komisi,
    nama: 'Komisi Pembangunan',
  ),
  Unit(
    id: 'panitiaNatal2026',
    jenis: JenisUnit.panitia,
    nama: 'Panitia Natal 2026',
  ),
  Unit(id: 'panitiaHut', jenis: JenisUnit.panitia, nama: 'Panitia HUT Jemaat'),
  Unit(
    id: 'panitiaPaskah2026',
    jenis: JenisUnit.panitia,
    nama: 'Panitia Paskah 2026',
  ),
];
