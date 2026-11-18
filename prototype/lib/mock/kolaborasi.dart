// mock-data.md 2.20: collaboration.
import 'model.dart';

/// Panitia board. Section 3 row 34: saldo Rp4.350.000 (Aktif), sisa
/// Rp650.000 here; AlurPanitia prints its own ([alurPanitia]).
const panitiaNatal = Panitia(
  nama: 'Panitia Natal 2026',
  ketua: 'Sdr. Stevi Lengkong',
  sekretaris: 'Sdri. Natalia Rumengan',
  bendahara: 'Sdr. Rivo Mandagi',
  peruntukan: 'Panitia Natal',
  dasar: 'SK BPMJ No. 11/2026 · Dokumen gereja',
);
const panitiaSaldoAktif = 4350000;

/// Penutupan. Sisa signed off by Meiske Lumentut, "Alih peruntukan ke Umum
/// Jemaat", 05/01/2027 (section 3 row 35: after "today"); asset handover
/// "kepada Komisi Pembangunan".
const panitiaPenutupan = (
  // (label, value) rows as drawn.
  sisa: ('Sisa uang', 'Rp650.000'),
  uangMuka: ('Uang Muka belum dipertanggungjawabkan', 'Rp0'),
  aset: ('Aset tersisa', '2 lampu sorot, 1 pohon Natal'),
  sisaDisetujuiOleh: 'Meiske Lumentut',
  sisaKe: 'Alih peruntukan ke Umum Jemaat',
  sisaPada: '05/01/2027',
  asetKepada: 'kepada Komisi Pembangunan',
);

/// AlurPanitia (section 3 row 34).
const alurPanitia = (
  pengurus: 'Ketua: Stevi Lengkong · Bendahara: Rivo Mandagi',
  uangMuka: 'Diberikan Rp300.000', // Uang Muka Dekorasi Natal
  saldo: ('Saldo peruntukan Panitia Natal 2026', 'Rp350.000'),
);

/// AlurPanitiaBaru choices.
const alurPanitiaBaru = (
  ketua: ['Stevi Lengkong', 'Rivo Mandagi'],
  sekretaris: ['Natalia Rumengan', 'Stevi Lengkong'],
  bendahara: ['Rivo Mandagi', 'Stevi Lengkong'],
  dokumen: 'SK BPMJ No. 15/2026',
);

/// Ibadah. Kolom service: persetujuan by Pnt. Hendrik Rumagit or Sym. Greis
/// Mamahit, given 16/11/2026; Ditutup "38 orang". Adven: persetujuan by
/// Pdt. Lidya Rondonuwu 15/11/2026. [Ibadah.status] is per board state.
const ibadahKolom7 = Ibadah(
  judul: 'Ibadah Kolom 7',
  jenis: 'Ibadah Kolom',
  waktu: 'Kamis, 19/11/2026 19.00',
  untuk: 'Kolom 7',
  tempat: 'Kel. Wenas-Lasut',
  status: '',
);
const ibadahAdven = Ibadah(
  judul: 'Ibadah Minggu Adven I',
  jenis: '',
  waktu: 'Minggu, 29/11/2026 · Subuh, Pagi, Malam',
  untuk: 'Semua anggota',
  tempat: '',
  status: '',
);
const ibadahKolom7Ditutup = '38 orang';

/// Kehadiran. Ditetapkan by Pnt. Hendrik Rumagit 15/11/2026 11.20. Section 3
/// row 32: `Koreksi` changes 231 → 236; the total is not updated elsewhere.
const kehadiranPagi = Kehadiran(
  ibadah: 'Ibadah Minggu pagi · 15/11/2026',
  perPos: {'Pintu depan · Yanti S.': 142, 'Pintu samping · Greis M.': 89},
  status: 'Ditetapkan',
);
const kehadiranJumlah = 231;
const kehadiranPenghitungMulai = 142; // the counter starts at 142
const kehadiranDitetapkan = 'Pnt. Hendrik Rumagit 15/11/2026 11.20';
const kehadiranKoreksi = (
  dari: 231,
  ke: 236,
  alasan: 'Alasan: lembar pos balkon terlambat diserahkan.',
  pada: '16/11/2026 08.05',
);

/// PermintaanDana. Persetujuan by Pdt. Lidya Rondonuwu 17/11/2026 09.15;
/// refused 17/11/2026 09.20 ("rincian konsumsi belum dilampirkan."); amount
/// changed to Rp1.800.000.
const permintaanDanaNatalPemuda = PermintaanDana(
  perlu: 'Konsumsi Natal Pemuda',
  jumlah: 1500000,
  peruntukan: 'Umum Jemaat',
  diajukanOleh: 'Sdr. Rivo Mandagi, Ketua Pemuda',
  status: '', // per board state
);
const permintaanDana = (
  disetujui: '17/11/2026 09.15',
  ditolak: '17/11/2026 09.20',
  alasanTolak: 'rincian konsumsi belum dilampirkan.',
  jumlahBaru: 1800000,
  kecilPerlu: 'Alat tulis',
  kecilJumlah: 85000, // below Rp250.000
  persetujuanLuar:
      'Pdt. Lidya Rondonuwu, Ketua BPMJ · 08/11/2026 · notulen rapat',
);

/// AlurBeranda, AlurDana: waiting for Pdt. Lidya Rondonuwu, Ketua Jemaat;
/// payment booked by Meiske Lumentut as Uang Muka diberikan.
const permintaanDanaDiakonia = PermintaanDana(
  perlu: 'Permintaan dana Komisi Diakonia',
  jumlah: 750000,
  peruntukan: '',
  diajukanOleh: 'Pnt. Hendrik Rumagit, Ketua Komisi Diakonia',
  status: 'Diajukan',
);

/// KeuanganUnit. Section 3 row 7 (BKU-2026-0151, see trx0151) and row 14
/// (Kolom 7 drafts differ per board).
const keuanganUnit = (
  kas: ('Kas Kolom 7', 1240000),
  perluTindakan: ('Perlu tindakan', 2), // label, then a count badge
  drafBank: (
    uraian: 'Konsumsi ibadah Kolom',
    jumlah: -150000,
  ), // on Bank BNI ··4821, refused
  drafDiakonia: (
    uraian: 'Bantuan duka',
    jumlah: -200000,
  ), // from Diakonia, refused
  rekonOktober: (saldoBuku: 920000, hitung: 920000, selisih: 0),
);

/// AlurUnit. Section 3 row 14: draft Rp185.000, "terhalang 1 hal".
const alurUnit = (
  noBukti: 'BKU-2026-0151',
  tanggal: '12/11/2026',
  jumlah: 320000,
  drafTanggal: '28/10/2026',
  drafJumlah: 185000,
  drafPindahKe: '02/11/2026',
);

/// SelesaikanUnit. Section 3 row 14: "28/10/2026 · −Rp150.000",
/// "terhalang 2 hal".
const selesaikanUnit = (
  terhalang: 'terhalang 2 hal dari Kolom 7',
  draf: ('Kolom 7 · bertanggal 28/10/2026 · ', -150000), // amount in mono
  rekonKas: 920000,
  alasan: 'Bendahara Kolom 7 sedang di luar kota; nota baru diterima November.',
  diselesaikanOleh: 'Meiske Lumentut',
  diselesaikanPada: ['16/11/2026 10.40', '16/11/2026 10.42'],
);

/// KasUnit: (Kas/Bank, dikelola). Unit choices include Kolom 4.
const kasUnit = [
  ('Kas', 'Dikelola Jemaat'),
  ('Bank BNI ··4821', 'Dikelola Jemaat'),
  ('Bank SulutGo ··1107', 'Dikelola Jemaat'),
  ('Kas Kolom 7', 'Dikelola oleh Kolom 7 · Bendahara: Deasy Tumbelaka'),
];

/// Kesiapan, WebKesiapan (board `F` and the initial `f` state):
/// (id, peruntukan, oleh, status). The board builds the line under each
/// row: 'Oleh ' + oleh when ready; [kesiapanPerluLagi] for Diakonia;
/// 'Bendahara unit: ' + oleh for Pembangunan.
/// `masukSebagai: Bendahara Komisi Diakonia` → "Dkn. Olga Tamba, Bendahara
/// Komisi Diakonia".
const kesiapan = [
  (
    'umum',
    'Umum Jemaat',
    'Pnt. Jefry Wowor · 02/11/2026',
    'Sudah dinyatakan siap',
  ),
  ('diak', 'Diakonia', 'Dkn. Olga Tamba', 'Perlu dinyatakan lagi'),
  ('bang', 'Pembangunan', 'Sdr. Rivo Mandagi', 'Pernyataan kesiapan belum ada'),
];
const kesiapanPerluLagi =
    'Dinyatakan 01/11/2026, lalu ada transaksi Oktober yang berubah. Pernyataan lama tidak berlaku lagi.';
const kesiapanSebagaiDiakonia = 'Dkn. Olga Tamba, Bendahara Komisi Diakonia';

/// Terbatas, WebTerbatas: (noBukti, tanggal, uraian, jumlah). Section 3
/// row 4: saldo Rp4.200.000 is drawn; the rows do not derive it.
const terbatasSaldoDiakoniaNovember = (
  'Saldo buku peruntukan Diakonia',
  4200000,
);
const terbatasBaris = [
  ('BKU-2026-0141', '10/11/2026', 'Diakonia duka', -500000),
  ('BKU-2026-0135', '06/11/2026', 'Persembahan Diakonia', 1200000),
  ('BKU-2026-0122', '27/10/2026', 'Diakonia sakit', -300000),
  ('BKU-2026-0098', '04/10/2026', 'Persembahan Diakonia', 950000),
];

/// LaporanLintas money card (board `U`): (judul, nilai, keterangan) for
/// `keadaan` 0–3: Seluruh Jemaat, Kolom 7, Panitia Natal 2026, Modul tidak
/// aktif (same as Seluruh Jemaat). Section 3 row 1.
const lintasUang = [
  (
    'Saldo buku semua Kas/Bank',
    'Rp38.415.000',
    'Keuangan · hanya yang sudah dibukukan',
  ),
  (
    'Saldo buku peruntukan Kolom 7',
    'Rp1.240.000',
    'Keuangan unit · Kas Kolom 7',
  ),
  (
    'Saldo buku peruntukan Panitia Natal',
    'Rp4.350.000',
    'Panitia · tahap Aktif',
  ),
  (
    'Saldo buku semua Kas/Bank',
    'Rp38.415.000',
    'Keuangan · hanya yang sudah dibukukan',
  ),
];

/// PersembahanBernama: refused for Ferry Wenas (Belum dikonfirmasi).
const persembahanBernama = (
  judul: 'Sampul syukur',
  jumlah: 100000,
  tanggal: '01/11/2026',
  pemberi: 'Novita Wenas',
  ditolakUntuk: 'Ferry Wenas',
);
