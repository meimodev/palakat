// mock-data.md 2.8 (October report SNP-2026-10-01), 2.11 (month-end
// reconciliation of Bank BNI ··4821), 2.12 (hitung kas), close checklist.
//
// Report tables are strings exactly as this file's source lists them; the
// screens print them, never recompute them (mock-data.md 0). The per-board
// verbatim tables (Laporan's F01–F14, WebExcel's F/LAP) belong in
// laporan_oktober.dart and excel.dart, owned by those screens' specs.
import 'model.dart';
import 'transaksi.dart';

// ---------- 2.8 October report ----------

/// F01 Laporan Perbendaharaan Bulanan (A4F01, A4Sementara, WebLaporan,
/// Laporan). Section 3 row 1: the saldo akhir Rp38.465.000 is 31/10, while
/// the November boards show Rp38.415.000.
const f01Oktober = [
  ['Saldo awal Kas/Bank', 'Rp36.250.000'],
  ['Pendapatan ekonomi', 'Rp14.820.000'],
  ['Belanja ekonomi', '−Rp11.455.000'],
  ['Dana Transit masuk · titipan masuk', 'Rp2.400.000'],
  ['Dana Transit keluar · titipan disalurkan', '−Rp2.400.000'],
  ['Uang Muka diberikan', '−Rp1.500.000'],
  ['Pengembalian sisa uang muka', 'Rp350.000'],
  ['Saldo akhir Kas/Bank', 'Rp38.465.000'],
];

/// F01 reconciliation block / F10 Posisi Kas & Bank "Per 31 Oktober 2026":
/// Kas/Bank · Saldo buku · Pembanding · Selisih. Section 3 row 2: BNI
/// Rp24.600.000 is after the October fee. Row 20: Kejadian says the Kas
/// count was Rp85.000 over; F10 keeps Rp0.
const f10Oktober = [
  ['Kas', 'Rp8.750.000', 'Hitung kas Rp8.750.000', 'Rp0'],
  [
    'Bank BNI ··4821',
    'Rp24.600.000',
    'Rekening koran Rp24.100.000 + setoran dalam perjalanan Rp500.000',
    'Rp0',
  ],
  ['Bank SulutGo ··1107', 'Rp5.115.000', 'Rekening koran Rp5.115.000', 'Rp0'],
  ['Jumlah', 'Rp38.465.000', '', 'Rp0'],
];

/// F03 Buku Kas Pembantu · Kas: 22 rows (rows as in WebPaketLaporan
/// `LAP.F03`, not repeated here).
const f03SaldoAwalKas = 'Rp4.070.000';
const f03SaldoAkhirKas = 'Saldo akhir Kas Rp8.750.000';
const f03JumlahBaris = 22;

/// F03 TERBATAS (peruntukan Diakonia): saldo awal Rp3.050.000 → 0098
/// Rp950.000 → Rp4.000.000 → 0122 Rp300.000 → Rp3.700.000.
/// Section 3 row 4: Terbatas, WebTerbatas, AlihPeruntukan show Rp4.200.000
/// for November; not derivable from these rows.
const f03Terbatas = [
  ['Saldo awal', 'Rp3.050.000'],
  ['BKU-2026-0098', 'Rp950.000', 'Rp4.000.000'],
  ['BKU-2026-0122', 'Rp300.000', 'Rp3.700.000'],
];

/// F05 Pendapatan (headings first in their group).
const f05Oktober = [
  ['PERSEMBAHAN', 'Rp13.620.000'],
  ['Persembahan Ibadah Minggu', 'Rp10.950.000'],
  ['Persembahan syukur', 'Rp1.720.000'],
  ['Persembahan Diakonia', 'Rp950.000'],
  ['SUMBANGAN', 'Rp1.200.000'],
  ['Sumbangan donatur', 'Rp1.200.000'],
  ['Sumbangan natura', 'Rp0'],
  ['Jumlah Pendapatan', 'Rp14.820.000'],
];

/// F07 Belanja.
const f07Oktober = [
  ['BELANJA OPERASIONAL', 'Rp11.155.000'],
  ['Listrik, air dan telepon', 'Rp1.000.000'],
  ['Alat tulis dan fotokopi', 'Rp250.000'],
  ['Biaya administrasi bank', 'Rp15.000'],
  ['Konsumsi rapat', 'Rp750.000'],
  ['Sewa peralatan', 'Rp0'],
  ['Honorarium pelayan', 'Rp3.640.000'],
  ['Pemeliharaan gedung', 'Rp5.500.000'],
  ['BELANJA PELAYANAN', 'Rp300.000'],
  ['Diakonia sakit', 'Rp300.000'],
  ['Jumlah Belanja', 'Rp11.455.000'],
];

/// F08 Rekap Penerimaan: Kas/Bank · Pendapatan · Titipan masuk ·
/// Pengembalian sisa uang muka · Pindah masuk · Jumlah.
const f08Oktober = [
  ['Kas', '12.170.000', '2.400.000', '350.000', '2.000.000', '16.920.000'],
  ['Bank BNI ··4821', '2.650.000', '0', '0', '8.190.000', '10.840.000'],
  ['Bank SulutGo ··1107', '0', '0', '0', '1.500.000', '1.500.000'],
  ['Jumlah', '14.820.000', '2.400.000', '350.000', '11.690.000', '29.260.000'],
];

/// F09 Rekap Pengeluaran: Kas/Bank · Belanja · Titipan disalurkan · Uang
/// Muka diberikan · Pindah keluar · Jumlah.
const f09Oktober = [
  ['Kas', '1.050.000', '0', '1.500.000', '9.690.000', '12.240.000'],
  [
    'Bank BNI ··4821',
    '10.405.000',
    '2.400.000',
    '0',
    '2.000.000',
    '14.805.000',
  ],
  ['Bank SulutGo ··1107', '0', '0', '0', '0', '0'],
  [
    'Jumlah',
    '11.455.000',
    '2.400.000',
    '1.500.000',
    '11.690.000',
    '27.045.000',
  ],
];

/// F11 Rekonsiliasi: row label · Kas · BNI · SulutGo.
const f11Oktober = [
  ['Hasil hitung / rekening koran', '8.750.000', '24.100.000', '5.115.000'],
  ['Setoran dalam perjalanan', '0', '500.000', '0'],
  ['Pembayaran dalam perjalanan', '0', '0', '0'],
  ['Saldo pembanding', '8.750.000', '24.600.000', '5.115.000'],
  ['Saldo buku', '8.750.000', '24.600.000', '5.115.000'],
  ['Selisih', '0', '0', '0'],
  ['Mutasi bank cocok / belum cocok', '—', '13 / 0', '1 / 0'],
  ['Status', 'Sudah dipastikan', 'Sudah dipastikan', 'Sudah dipastikan'],
];

/// F12 Daftar Bukti Kas: No. Bukti · Jumlah · Persetujuan · Dokumen.
/// Section 3 row 38: "Contoh 5 dari 33 baris" while F02 has 31 rows.
const f12Judul = 'Contoh 5 dari 33 baris';
const f12Oktober = [
  ['BKU-2026-0098', 'Rp4.150.000', 'Tidak diperlukan', 'Terverifikasi'],
  ['BKU-2026-0101', '−Rp1.250.000', 'Tidak diperlukan', 'Terverifikasi'],
  ['BKU-2026-0105', '−Rp750.000', 'Tidak diperlukan', 'Terverifikasi'],
  ['BKU-2026-0109', 'Rp750.000', 'Tidak diperlukan', 'Tidak diperlukan'],
  [
    'BKU-2026-0116',
    '−Rp5.500.000',
    'Sudah dicatat · Ketua BPMJ',
    'Dikecualikan · kuitansi menyusul',
  ],
];

/// F13 Sentralisasi / Penyaluran: Penerima · four amount columns.
const f13Oktober = [
  ['Sinode', 'Rp0', 'Rp2.400.000', 'Rp2.400.000', 'Rp0'],
  ['Wilayah', 'Rp0', 'Rp0', 'Rp0', 'Rp0'],
  ['Jumlah titipan', 'Rp0', 'Rp2.400.000', 'Rp2.400.000', 'Rp0'],
  ['Sentralisasi dari uang milik sendiri (Belanja, bukan titipan)', 'Rp0'],
];

/// F14 attachments: no · judul · isi.
const f14Oktober = [
  ['1', 'Uang Muka', '3 kasus'],
  ['2', 'Rincian Pertanggungjawaban Uang Muka', 'Nihil'],
  ['3', 'Penghitungan Persembahan', '4 ibadah'],
  ['4', 'Penggantian Biaya', 'Nihil'],
  ['5', 'Pengecualian Dokumen Pendukung', '1 dokumen'],
  ['6', 'Pembalikan dan Koreksi', '1 rangkaian'],
  ['7', 'Saldo Awal Pencatatan', 'Nihil'],
  ['8', 'Hasil Pengecekan Otomatis', '8 syarat terpenuhi'],
];

/// F14 attachment 5 row.
const f14Pengecualian = [
  'BKU-2026-0116',
  'Alasan: kuitansi menyusul · Pemberi pengecualian: Ketua BPMJ · dicatat 22/10/2026',
  '−Rp5.500.000',
];

/// F14 attachment 6 rows.
const f14Rangkaian = [
  ['BKU-2026-0105', 'Rp750.000', 'Dibalik'],
  ['BKU-2026-0109', '−Rp750.000', 'alasan: Mata Anggaran keliru'],
  ['BKU-2026-0110', 'Rp750.000', 'Transaksi koreksi'],
];

const laporanOktober = LaporanResmi(
  id: 'SNP-2026-10-01',
  periode: 'Periode laporan 1–31 Oktober 2026',
  dibekukan: '16/11/2026 11.05',
  versiMA: '2026.1',
  tabel: {
    'F01': f01Oktober,
    'F05': f05Oktober,
    'F07': f07Oktober,
    'F08': f08Oktober,
    'F09': f09Oktober,
    'F10': f10Oktober,
    'F11': f11Oktober,
    'F12': f12Oktober,
    'F13': f13Oktober,
    'F14': f14Oktober,
  },
);

/// TERBATAS copy (A4Terbatas, WebPaketLaporan with `salinan` ≠ Seluruh
/// Jemaat).
const terbatasF05 = [
  ['1.3.55.01.00', 'Persembahan Diakonia', 'Rp950.000'],
];
const terbatasF07 = [
  ['4.03.03.00', 'Diakonia duka', 'Rp0'],
  ['4.03.04.00', 'Diakonia sakit', 'Rp300.000'],
];
const f03TerbatasSaldoDiakonia = (awal: 'Rp3.050.000', akhir: 'Rp3.700.000');

/// Section 3 row 15: F12 TERBATAS prints 0122 "Terverifikasi" at close.
const terbatasF12 = [
  ['BKU-2026-0098', 'Rp950.000', 'Terverifikasi'],
  ['BKU-2026-0122', '−Rp300.000', 'Terverifikasi'],
];

/// WebExcel file name.
const namaFileExcelOktober = 'Paket-Laporan-GMIM_Jemaat-Karunia_2026-10.xlsx';

/// Warta and Cari reuse (Belanja printed positive on Warta).
const wartaPendapatanOktober = 'Pendapatan Rp14.820.000';
const wartaBelanjaOktober = 'Belanja Rp11.455.000';

/// Cari: "persembahan Minggu pagi bulan Oktober".
const cariPertanyaan = 'persembahan Minggu pagi bulan Oktober';
const cariJawaban = [
  ('BKU-2026-0098', 3200000),
  ('BKU-2026-0107', 2650000),
  ('BKU-2026-0114', 2400000),
  ('BKU-2026-0123', 2700000),
];
const cariJumlah = 10950000;

// ---------- 2.11 Reconciliation of Bank BNI ··4821, October 2026 ----------

const _m1 = MutasiBank(
  id: 'm1',
  nama: 'TRF MASUK IBU RUNTU',
  tanggal: '28/10/2026',
  jumlah: 1000000,
);
const _m2 = MutasiBank(
  id: 'm2',
  nama: 'TARIK TUNAI',
  tanggal: '30/10/2026',
  jumlah: -2000000,
);
const _m3 = MutasiBank(
  id: 'm3',
  nama: 'BIAYA ADM',
  tanggal: '31/10/2026',
  jumlah: -15000,
);

/// m1 matches t1 + t2; m2 matches t3; m3 has no transaction until "Buat
/// transaksi dari mutasi ini" creates BKU-2026-0133.
const mutasiBniOktober = [_m1, _m2, _m3];

/// The two transfers as the reconciliation boards draw them: the BNI side
/// only (`jm` −2.000.000 and +500.000), and t4 named "Kas ke Bank BNI".
/// F02's rows (trx0127, trx0131) fill both columns, so their `jumlah` is 0.
const _rekonT3 = Transaksi(
  noBukti: 'BKU-2026-0127',
  tanggal: '30/10/2026',
  uraian: 'Pindah antar Kas/Bank: Bank BNI ke Kas',
  jenis: JenisTransaksi.pindah,
  kasBank: 'Bank BNI ··4821',
  keluar: 2000000,
);
const _rekonT4 = Transaksi(
  noBukti: 'BKU-2026-0131',
  tanggal: '31/10/2026',
  uraian: 'Setoran ke bank: Kas ke Bank BNI',
  jenis: JenisTransaksi.pindah,
  kasBank: 'Bank BNI ··4821',
  masuk: 500000,
);

/// TutupBuku (rekon screen), WebRekonsiliasi, AIBulan, WebAI: t1…t4, each
/// `jumlah` the board's `jm`. Section 3 row 2: saldo buku Rp24.615.000
/// before the fee equals the November figure by chance; Rp24.600.000 after.
const rekonBniOktober = Rekonsiliasi(
  kasBankId: 'bni',
  bulan: 'Oktober 2026',
  saldoBuku: 24615000,
  saldoRekeningKoran: 24100000,
  dalamPerjalanan: 500000,
  cocokLain: 12,
  mutasi: mutasiBniOktober,
  belumCocok: [trx0118, trx0121, _rekonT3, _rekonT4],
);
const rekonSaldoBukuSetelahBiaya = 24600000;
const rekonSelisihAwal = 515000; // 24.615.000 − 24.100.000
const rekonCocokLainTeks =
    '12 mutasi bank lain sudah cocok dengan transaksinya.'; // 13 after the fee
const rekonFile =
    'mutasi-bni-okt.csv · 3 mutasi dibaca. Belum ada yang dicocokkan.';

/// Facts of the deposit in transit (mock-data.md 2.11), not a drawn line:
/// each rekon board composes its own sentence.
const rekonDalamPerjalananTeks =
    'BKU-2026-0131 · 31/10/2026 · Rp500.000, dibawa ke November 2026';

/// RekonIsi, WebRekonIsi differ: t4 is BKU-2026-0133 "Biaya administrasi
/// bank" −Rp15.000, and "BIAYA ADM" starts already matched to it; the
/// mutations appear only after the CSV is "uploaded". The statement balance
/// is typed by the user ("Saldo rekening koran per 31/10/2026").
const rekonIsiBni = Rekonsiliasi(
  kasBankId: 'bni',
  bulan: 'Oktober 2026',
  saldoBuku: 24615000,
  saldoRekeningKoran: 24100000,
  dalamPerjalanan: 500000,
  cocokLain: 12,
  mutasi: mutasiBniOktober,
  belumCocok: [trx0118, trx0121, _rekonT3, trx0133],
);
const rekonIsiPemeriksa =
    'Sudah diperiksa oleh Pnt. Jefry Wowor. Bendahara memastikan.';
const rekonIsiBukuBerubah =
    'BKU-2026-0127 dibalik setelah rekonsiliasi dipastikan.';

/// Kas and Bank SulutGo ··1107 on the October close.
const rekonLainOktober = 'Sudah dipastikan';

/// Kas Kolom 7 October: saldo buku = hasil hitung Rp920.000. SelesaikanUnit
/// state "Ada selisih": hitung Rp870.000, selisih Rp50.000.
const rekonKolom7Oktober = (saldoBuku: 920000, hitung: 920000);
const rekonKolom7AdaSelisih = (hitung: 870000, selisih: 50000);

/// Close checklist (TutupBuku, WebTutupBuku), in order.
const syaratTutupBuku = [
  'bulan sebelumnya sudah ditutup',
  'semua 3 kas/bank sudah direkonsiliasi',
  'Mata Anggaran sudah dipilih untuk semua transaksi',
  'persetujuan yang wajib sudah dicatat',
  'dokumen pendukung wajib sudah terverifikasi atau dikecualikan',
  'tidak ada transaksi Draf atau Sudah diperiksa',
  'tidak ada baris impor yang tertunda',
  'persetujuan format laporan sudah dicatat',
];

/// Late draft on `gagalDiCekTerakhir`.
const tutupBukuDrafTerlambat = 'Fotokopi liturgi · Rp85.000';

/// Section 3 row 19: A4F01 "Disiapkan oleh Meiske Lumentut"; with the
/// vacancy on, TutupBuku says "Ditutup oleh Yanti Sumual, Operator".
const tutupBukuPada = '16/11/2026 11.05';

/// PDF ready after 3600 ms; Excel "File gagal dibuat".
const tutupBukuPdfMs = 3600;
const tutupBukuExcelGagal = 'File gagal dibuat';

// ---------- 2.12 Hitung kas (HitungKas, WebHitungKas) ----------

const hitungKasJudul = 'Kas · 16 November 2026 · 11.30';
const hitungKasSaldoBuku = 8420000;
const hitungKasPetugas = ['Meiske L.', 'Pnt. Jefry Wowor', 'Dkn. Olga Tamba'];

/// `contohTerisi` on (default): Rp8.370.000, selisih Rp50.000.
const hitungKasTerisi = HitungKas(
  lembar: [80, 5, 5, 1, 2, 0, 0],
  petugas: hitungKasPetugas,
);
const hitungKasSelisihTeks = 'Uang di kas kurang Rp50.000 dari buku.';

/// `contohTerisi` off.
const hitungKasKosong = HitungKas(
  lembar: [0, 0, 0, 0, 0, 0, 0],
  petugas: hitungKasPetugas,
);
const hitungKasKosongTeks = 'Belum dihitung. Kosong bukan Rp0.';
const hitungKasFile = 'lembar-hitung-16-11.jpg';
