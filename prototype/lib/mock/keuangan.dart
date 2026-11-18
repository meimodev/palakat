// mock-data.md 2.4 (Kas/Bank, peruntukan, Lingkup), 2.5 (Mata Anggaran),
// 2.6 (months).
import 'model.dart';

// ---------- 2.4 Kas/Bank ----------

const kasBankKas = KasBank(
  id: 'kas',
  nama: 'Kas',
  namaPendek: 'Kas',
  jenis: JenisKasBank.kas,
  dikelolaOleh: 'Dikelola Jemaat',
  aktif: true,
  keterangan: 'Aktif · dipakai sejak September 2026',
);
const kasBankBni = KasBank(
  id: 'bni',
  nama: 'Bank BNI ··4821',
  namaPendek: 'Bank BNI',
  jenis: JenisKasBank.bank,
  dikelolaOleh: 'Dikelola Jemaat',
  aktif: true,
  keterangan: 'Aktif · dipakai sejak September 2026',
);
const kasBankBsg = KasBank(
  id: 'bsg',
  nama: 'Bank SulutGo ··1107',
  namaPendek: 'Bank SulutGo',
  jenis: JenisKasBank.bank,
  dikelolaOleh: 'Dikelola Jemaat',
  aktif: true,
  keterangan: 'Aktif · dipakai sejak September 2026',
);

/// Deactivated 28/10/2026 16.44.
const kasBankHut = KasBank(
  id: 'hut',
  nama: 'Kas Panitia HUT',
  namaPendek: 'Kas Panitia HUT',
  jenis: JenisKasBank.kas,
  dikelolaOleh: '—',
  aktif: false,
  keterangan: 'Nonaktif sejak November 2026 · tetap tampil di laporan lama',
);
const kasBankKolom7 = KasBank(
  id: 'kol7',
  nama: 'Kas Kolom 7',
  namaPendek: 'Kas Kolom 7',
  jenis: JenisKasBank.kas,
  dikelolaOleh: 'Dikelola oleh Kolom 7 · Bendahara: Deasy Tumbelaka',
  aktif: true,
);

/// Panitia board text only ("Kas Panitia Natal yang dikelolanya").
/// Section 3 row 39: KasUnit and Lainnya do not list it.
const kasPanitiaNatal = 'Kas Panitia Natal';

/// The three Jemaat Kas/Bank, in board order.
const kasBankJemaat = [kasBankKas, kasBankBni, kasBankBsg];

/// Saldo per Kas/Bank id at four moments. Section 3 rows 1–3: November
/// (16/11) and 31 October are different moments; each screen shows its own
/// board's moment.
///
/// Opening 15/09/2026 (OPN-2026-0001).
const saldoPembukaan = {'kas': 3200000, 'bni': 24000000, 'bsg': 5100000};
const totalSaldoPembukaan = 32300000;

/// 1 October 2026. Kas from F03; BNI and SulutGo are **derived** (no board
/// draws them).
const saldo1Oktober = {'kas': 4070000, 'bni': 28565000, 'bsg': 3615000};
const totalSaldo1Oktober = 36250000;

/// 31 October 2026 saldo buku (F10, A4F01, WebLaporan).
const saldo31Oktober = {'kas': 8750000, 'bni': 24600000, 'bsg': 5115000};
const totalSaldo31Oktober = 38465000;

/// November saldo buku on 16/11/2026 (Main, WebBeranda, TabBeranda,
/// KasusBaru, Memuat, …).
const saldoNovember = {'kas': 8420000, 'bni': 24615000, 'bsg': 5380000};
const totalSaldoNovember = 38415000;

/// Kas Kolom 7 (not in the Jemaat totals): October rekon Rp920.000,
/// November Rp1.240.000.
const saldoKasKolom7Oktober = 920000;
const saldoKasKolom7November = 1240000;

const sumberSaldoPembukaan = {
  'kas': 'Sumber: berita acara hitung kas 14/09/2026',
  'bni': 'Rekening koran 14/09/2026', // WebAwal
};

/// Kas split at opening (Awal). Pembangunan is empty: "Belum diisi. Kosong
/// bukan Rp0." (Rp500.000 balances it).
const kasPembukaanPerPeruntukan = {'umum': 2000000, 'diak': 700000};
const kasPembukaanPembangunanPenyeimbang = 500000;
const teksPembukaanBni = 'Rp24.000.000 · sudah dibagi';
const teksPembukaanBsg = 'Rp5.100.000 · sudah dibagi';
const teksPembukaanKasusBerjalan =
    'Uang muka dan titipan yang masih berjalan: tidak ada';

/// Awal draws the label and the amount ([totalSaldoPembukaan]) on separate
/// lines.
const teksPembukaanDibukukan = 'Saldo awal pencatatan · semua Kas/Bank';
const noBuktiPembukaan = 'OPN-2026-0001';

/// Bank BNI ··4821 by peruntukan on 16/11 (AlihPeruntukan); bar colours
/// tinta, laut, PalakatIlustrasi (#86B5B8). Sum Rp24.615.000.
const bniPerPeruntukanNovember = {
  'umum': 18115000,
  'diak': 4200000,
  'bang': 2300000,
};

// ---------- Peruntukan and Lingkup ----------

const peruntukanUmum = Peruntukan('umum', 'Umum Jemaat');
const peruntukanDiakonia = Peruntukan('diak', 'Diakonia');
const peruntukanPembangunan = Peruntukan('bang', 'Pembangunan');
const semuaPeruntukan = [
  peruntukanUmum,
  peruntukanDiakonia,
  peruntukanPembangunan,
];

/// Unit peruntukan.
const peruntukanUnit = ['Kolom 7', 'Panitia Natal'];

/// Catat forms, KasusBaru, TabCatat. Section 3 row 22: Awal says
/// "3 Kas/Bank · 3 peruntukan · 4 Lingkup"; Lainnya lists five
/// ([lingkupLainnya]).
const semuaLingkup = [
  Lingkup('Jemaat'),
  Lingkup('Kolom 3'),
  Lingkup('BIPRA Pemuda'),
  Lingkup('Panitia Natal'),
];

/// Section 3 row 22: Lainnya adds Komisi Diakonia.
const lingkupLainnya = [
  Lingkup('Jemaat'),
  Lingkup('Kolom 3'),
  Lingkup('BIPRA Pemuda'),
  Lingkup('Komisi Diakonia'),
  Lingkup('Panitia Natal'),
];

// ---------- 2.5 Mata Anggaran, version 2026.1 ----------

const _pd = Pohon.pendapatan, _bl = Pohon.belanja;
const _ms = BolehUntuk.milikSendiri;

/// Every row drawn on any board, version 2026.1.
const mataAnggaran = [
  MataAnggaran(
    kode: '1.3.53.00.00',
    nama: 'PERSEMBAHAN',
    pohon: _pd,
    judulKelompok: true,
  ),
  MataAnggaran(
    kode: '1.3.53.07.00',
    nama: 'Persembahan Ibadah Minggu',
    pohon: _pd,
    bolehUntuk: _ms,
  ),
  MataAnggaran(
    kode: '1.3.53.09.00',
    nama: 'Persembahan syukur',
    pohon: _pd,
    bolehUntuk: _ms,
  ),
  MataAnggaran(
    kode: '1.3.55.01.00',
    nama: 'Persembahan Diakonia',
    pohon: _pd,
    bolehUntuk: _ms,
  ),
  MataAnggaran(
    kode: '1.4.10.00.00',
    nama: 'SUMBANGAN',
    pohon: _pd,
    judulKelompok: true,
  ),
  MataAnggaran(
    kode: '1.4.10.02.00',
    nama: 'Sumbangan donatur',
    pohon: _pd,
    bolehUntuk: BolehUntuk.keduanya,
  ),

  /// F05 only. Section 3 row 25: F05 (2026.1) prints it as Rp0;
  /// WebMataAnggaran tags it "Baru" in 2026.2.
  MataAnggaran(kode: '1.4.10.03.00', nama: 'Sumbangan natura', pohon: _pd),

  /// Section 3 row 24: F02 and Persembahan use it (2026.1); KasusBaru names
  /// it "Sentralisasi Sinode"; 2026.2 marks it "Baru".
  MataAnggaran(
    kode: '2.1.01.02.00',
    nama: 'DANA TRANSIT Sentralisasi Sinode',
    pohon: _pd,
    bolehUntuk: BolehUntuk.titipan,
  ),

  /// Section 3 row 23: KasusBaru's name; WebMataAnggaran 2026.2 names it
  /// "DANA TRANSIT Penyaluran Sentralisasi Sinode" (Belanja tab).
  MataAnggaran(
    kode: '2.2.01.02.00',
    nama: 'Persembahan khusus Wilayah',
    bolehUntuk: BolehUntuk.titipan,
  ),
  MataAnggaran(
    kode: '5.00.00.00',
    nama: 'BELANJA OPERASIONAL',
    pohon: _bl,
    judulKelompok: true,
  ),
  MataAnggaran(
    kode: '5.01.02.00',
    nama: 'Listrik, air dan telepon',
    pohon: _bl,
    bolehUntuk: _ms,
  ),
  MataAnggaran(
    kode: '5.02.01.00',
    nama: 'Alat tulis dan fotokopi',
    pohon: _bl,
    bolehUntuk: _ms,
  ),
  MataAnggaran(
    kode: '5.03.03.00',
    nama: 'Biaya administrasi bank',
    pohon: _bl,
    bolehUntuk: _ms,
  ),
  MataAnggaran(kode: '5.04.01.00', nama: 'Konsumsi rapat', pohon: _bl),
  MataAnggaran(kode: '5.05.02.00', nama: 'Sewa peralatan', pohon: _bl),
  MataAnggaran(kode: '5.07.01.00', nama: 'Honorarium pelayan', pohon: _bl),
  MataAnggaran(kode: '5.08.02.00', nama: 'Pemeliharaan gedung', pohon: _bl),
  MataAnggaran(
    kode: '4.00.00.00',
    nama: 'BELANJA PELAYANAN',
    pohon: _bl,
    judulKelompok: true,
  ),
  MataAnggaran(
    kode: '4.03.03.00',
    nama: 'Diakonia duka',
    pohon: _bl,
    bolehUntuk: _ms,
  ),
  MataAnggaran(kode: '4.03.04.00', nama: 'Diakonia sakit', pohon: _bl),
];

/// Name of a 2026.1 code, or null.
String? namaMA(String kode) {
  for (final m in mataAnggaran) {
    if (m.kode == kode) return m.nama;
  }
  return null;
}

/// KasusBaru names 2.1.01.02.00 this way (section 3 row 24).
const namaSentralisasiKasusBaru = 'Sentralisasi Sinode';

/// Picker lists of the Catat forms (Main, WebCatat, TabCatat), in order.
const pilihanMABelanja = [
  '5.00.00.00',
  '5.01.02.00',
  '5.02.01.00',
  '5.03.03.00',
  '4.00.00.00',
  '4.03.03.00',
];
const pilihanMAPendapatan = [
  '1.3.53.00.00',
  '1.3.53.07.00',
  '1.3.53.09.00',
  '1.4.10.00.00',
  '1.4.10.02.00',
];

/// Bagi's list.
const pilihanMABagi = [
  '5.01.02.00',
  '5.02.01.00',
  '5.03.03.00',
  '5.04.01.00',
  '5.05.02.00',
];

/// Titipan list on KasusBaru (code, name as drawn there).
const pilihanMATitipan = [
  ('2.1.01.02.00', 'Sentralisasi Sinode'),
  ('2.2.01.02.00', 'Persembahan khusus Wilayah'),
];

const versiMASekarang = VersiMataAnggaran(
  kode: '2026.1',
  status: 'Diterbitkan',
  berlaku: 'Berlaku mulai September 2026',
  barisPendapatan: 131,
  barisBelanja: 158,
  contoh: mataAnggaran,
);
const teksBarisVersiSekarang = 'Pendapatan 131 baris · Belanja 158 baris';

// ---------- 2.5 Version 2026.2 (draft) ----------

/// Section 3 row 26: both boards say "2 baris baru · 1 nama berubah" while
/// WebMataAnggaran tags 4 rows "Baru". Keep the text and the tags.
const teksBedaVersiUsulan =
    '2 baris baru · 1 nama berubah · dibanding versi 2026.1';
const berlakuVersiUsulan = 'usulan berlaku mulai Desember 2026';
const teksVersiUsulanDiterbitkan =
    'Berlaku mulai Desember 2026 · diterbitkan oleh Meiske L., 16/11/2026';

/// MataAnggaran (phone), Belanja tab, with the default "Boleh untuk".
const maUsulanBelanja = [
  MataAnggaran(
    kode: '5.00.00.00',
    nama: 'BELANJA OPERASIONAL',
    pohon: _bl,
    judulKelompok: true,
  ),
  MataAnggaran(
    kode: '5.01.02.00',
    nama: 'Listrik, air dan telepon',
    pohon: _bl,
    bolehUntuk: _ms,
  ),
  MataAnggaran(
    kode: '5.03.03.00',
    nama: 'Biaya administrasi bank',
    pohon: _bl,
    bolehUntuk: _ms,
  ),
  MataAnggaran(
    kode: '5.06.01.00',
    nama: 'Internet dan langganan aplikasi',
    pohon: _bl,
    tanda: 'Baru',
  ),
  MataAnggaran(
    kode: '4.03.03.00',
    nama: 'Diakonia duka dan sakit',
    pohon: _bl,
    bolehUntuk: _ms,
    tanda: 'Nama berubah',
  ),
];

/// MataAnggaran (phone), Pendapatan tab.
const maUsulanPendapatan = [
  MataAnggaran(
    kode: '1.3.53.00.00',
    nama: 'PERSEMBAHAN',
    pohon: _pd,
    judulKelompok: true,
  ),
  MataAnggaran(
    kode: '1.3.53.07.00',
    nama: 'Persembahan Ibadah Minggu',
    pohon: _pd,
    bolehUntuk: _ms,
  ),
  MataAnggaran(
    kode: '1.3.53.09.00',
    nama: 'Persembahan syukur',
    pohon: _pd,
    bolehUntuk: _ms,
  ),
  MataAnggaran(
    kode: '2.1.01.02.00',
    nama: 'DANA TRANSIT Sentralisasi Sinode',
    pohon: _pd,
    bolehUntuk: BolehUntuk.titipan,
    tanda: 'Baru',
  ),
  MataAnggaran(
    kode: '1.4.10.02.00',
    nama: 'Sumbangan donatur',
    pohon: _pd,
    bolehUntuk: BolehUntuk.keduanya,
  ),
];

/// WebMataAnggaran adds this row to the Belanja tab (section 3 row 23).
const maUsulanBelanjaWebTambahan = MataAnggaran(
  kode: '2.2.01.02.00',
  nama: 'DANA TRANSIT Penyaluran Sentralisasi Sinode',
  pohon: _bl,
  bolehUntuk: BolehUntuk.titipan,
  tanda: 'Baru',
);

/// WebMataAnggaran adds this row to the Pendapatan tab (section 3 row 25).
const maUsulanPendapatanWebTambahan = MataAnggaran(
  kode: '1.4.10.03.00',
  nama: 'Sumbangan natura',
  pohon: _pd,
  tanda: 'Baru',
);

const versiMAUsulan = VersiMataAnggaran(
  kode: '2026.2',
  status: 'Draf',
  berlaku: berlakuVersiUsulan,
  contoh: [...maUsulanBelanja, ...maUsulanPendapatan],
);

// ---------- 2.6 Months ----------

const semuaBulan = [
  Bulan(
    tahun: 2026,
    bulan: 12,
    status: StatusBulan.belumDitutup,
    keterangan: 'Belum ada transaksi',
  ),

  /// TutupBuku prints "Bulan berjalan · menunggu Oktober ditutup".
  Bulan(
    tahun: 2026,
    bulan: 11,
    status: StatusBulan.belumDitutup,
    keterangan: 'Bulan berjalan · 12 transaksi',
  ),

  /// Becomes Sudah ditutup 16/11/2026 11.05 ([keteranganOktoberDitutup]).
  /// Section 3 row 38: "33 transaksi" while F02 has 31 rows.
  Bulan(
    tahun: 2026,
    bulan: 10,
    status: StatusBulan.belumDitutup,
    keterangan: 'Berikutnya untuk tutup buku · 33 transaksi',
  ),

  /// Closed 05/10/2026 19.02 by Meiske L.
  Bulan(
    tahun: 2026,
    bulan: 9,
    status: StatusBulan.sudahDitutup,
    keterangan: 'Periode laporan 15–30 September 2026 · 21 transaksi',
  ),
];
const keteranganNovemberTutupBuku = 'Bulan berjalan · menunggu Oktober ditutup';
const keteranganOktoberDitutup = 'Periode laporan 1–31 Oktober 2026';
const oktoberDitutupPada = '16/11/2026 11.05';
const septemberDitutupPada = '05/10/2026 19.02';
