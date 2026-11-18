// mock-data.md 2.7 (October transactions, F02), September rows, 2.9
// (November), 2.13 (multi-part offering), 2.14 (supporting documents) and
// 2.15 (corrections, persetujuan, events, refunds).
import 'model.dart';

const _bl = JenisTransaksi.belanja;
const _pd = JenisTransaksi.pendapatan;
const _pi = JenisTransaksi.pindah;
const _tm = JenisTransaksi.titipanMasuk;
const _um = JenisTransaksi.uangMukaDiberikan;
const _pj = JenisTransaksi.pertanggungjawaban;
const _bni = 'Bank BNI ··4821';

// ---------- 2.7 October 2026, F02 Buku Kas Umum (31 rows) ----------

/// Rows reused by other tables (rekonsiliasi, F12, F14, Dokumen).
const trx0105 = Transaksi(
  noBukti: 'BKU-2026-0105',
  tanggal: '09/10/2026',
  kodeMA: '5.02.01.00',
  uraian: 'Konsumsi rapat majelis',
  jenis: _bl,
  status: StatusTransaksi.dibalik,
  kasBank: 'Kas',
  keluar: 750000,
  tandaRantai: 'Dibalik oleh BKU-2026-0109',
);
const trx0109 = Transaksi(
  noBukti: 'BKU-2026-0109',
  tanggal: '12/10/2026',
  kodeMA: '5.02.01.00',
  uraian: 'Pembalikan BKU-2026-0105',
  jenis: JenisTransaksi.pembalikan,
  kasBank: 'Kas',
  keluar: -750000,
  tandaRantai: 'Pembalikan',
  catatan: 'Mata Anggaran keliru',
);
const trx0110 = Transaksi(
  noBukti: 'BKU-2026-0110',
  tanggal: '12/10/2026',
  kodeMA: '5.04.01.00',
  uraian: 'Konsumsi rapat majelis',
  jenis: JenisTransaksi.koreksi,
  kasBank: 'Kas',
  keluar: 750000,
  tandaRantai: 'Koreksi dari BKU-2026-0105',
);
const trx0116 = Transaksi(
  noBukti: 'BKU-2026-0116',
  tanggal: '22/10/2026',
  kodeMA: '5.08.02.00',
  uraian: 'Pemeliharaan atap gedung',
  jenis: _bl,
  kasBank: _bni,
  keluar: 5500000,
  persetujuan: 'Sudah dicatat · Ketua BPMJ',
  dokumen: StatusDokumenPendukung.dikecualikan,
  catatan: 'Dikecualikan · kuitansi menyusul', // recorded 22/10/2026
);
const trx0118 = Transaksi(
  noBukti: 'BKU-2026-0118',
  tanggal: '27/10/2026',
  kodeMA: '1.3.53.09.00',
  uraian: 'Persembahan syukur',
  jenis: _pd,
  kasBank: _bni,
  masuk: 500000,
);
const trx0121 = Transaksi(
  noBukti: 'BKU-2026-0121',
  tanggal: '28/10/2026',
  kodeMA: '1.4.10.02.00',
  uraian: 'Sumbangan donatur',
  jenis: _pd,
  kasBank: _bni,
  masuk: 500000,
);
const trx0122 = Transaksi(
  noBukti: 'BKU-2026-0122',
  tanggal: '27/10/2026',
  kodeMA: '4.03.04.00',
  uraian: 'Diakonia sakit',
  jenis: _bl,
  kasBank: 'Kas',
  keluar: 300000,
  peruntukan: 'Diakonia',
);
const trx0127 = Transaksi(
  noBukti: 'BKU-2026-0127',
  tanggal: '30/10/2026',
  uraian: 'Pindah antar Kas/Bank: Bank BNI ke Kas',
  jenis: _pi,
  kasBank: 'Bank BNI ke Kas',
  masuk: 2000000,
  keluar: 2000000,
);

/// In transit at month end ("dibawa ke November 2026", 2.11).
const trx0131 = Transaksi(
  noBukti: 'BKU-2026-0131',
  tanggal: '31/10/2026',
  uraian: 'Setoran ke bank: ke Bank BNI ··4821',
  jenis: _pi,
  kasBank: 'Kas ke Bank BNI',
  masuk: 500000,
  keluar: 500000,
);

/// Created from the "BIAYA ADM" bank mutation.
const trx0133 = Transaksi(
  noBukti: 'BKU-2026-0133',
  tanggal: '31/10/2026',
  kodeMA: '5.03.03.00',
  uraian: 'Biaya administrasi bank',
  jenis: _bl,
  kasBank: _bni,
  keluar: 15000,
);

/// F02 in print order. All Dibukukan unless the status says otherwise.
/// Print each amount with rp(); the reversal prints '−Rp750.000'.
const f02Oktober = [
  Transaksi(
    noBukti: 'BKU-2026-0098',
    tanggal: '04/10/2026',
    kodeMA: '1.3.53.07.00; 1.3.55.01.00',
    uraian: 'Persembahan Ibadah Minggu dan Diakonia',
    jenis: _pd,
    kasBank: 'Kas; Bank BNI ··4821',
    masuk: 4150000,
    bagian: [
      BagianTransaksi(
        kodeMA: '1.3.53.07.00',
        jumlah: 3200000,
        kasBankId: 'kas',
      ),
      BagianTransaksi(
        kodeMA: '1.3.55.01.00',
        jumlah: 950000,
        kasBankId: 'bni',
        peruntukanId: 'diak',
      ),
    ],
  ),
  Transaksi(
    noBukti: 'BKU-2026-0099',
    tanggal: '04/10/2026',
    kodeMA: '2.1.01.02.00',
    uraian: 'Titipan untuk: Sinode · Sentralisasi',
    jenis: _tm,
    kasBank: 'Kas',
    masuk: 600000,
  ),
  Transaksi(
    noBukti: 'BKU-2026-0100',
    tanggal: '05/10/2026',
    kodeMA: '5.07.01.00',
    uraian: 'Honorarium pelayan',
    jenis: _bl,
    kasBank: _bni,
    keluar: 1820000,
  ),
  Transaksi(
    noBukti: 'BKU-2026-0101',
    tanggal: '06/10/2026',
    kodeMA: '5.01.02.00; 5.02.01.00',
    uraian: 'Toko Sinar: listrik dan alat tulis, satu pembayaran',
    jenis: _bl,
    kasBank: _bni,
    keluar: 1250000,
    bagian: [
      BagianTransaksi(kodeMA: '5.01.02.00', jumlah: 1000000),
      BagianTransaksi(kodeMA: '5.02.01.00', jumlah: 250000),
    ],
  ),
  Transaksi(
    noBukti: 'BKU-2026-0102',
    tanggal: '06/10/2026',
    uraian: 'Setoran ke bank: ke Bank BNI ··4821',
    jenis: _pi,
    kasBank: 'Kas ke Bank BNI',
    masuk: 5000000,
    keluar: 5000000,
  ),
  Transaksi(
    noBukti: 'BKU-2026-0103',
    tanggal: '07/10/2026',
    uraian: 'Uang Muka diberikan · Pnt. Jefry Wowor',
    jenis: _um,
    kasBank: 'Kas',
    keluar: 400000,
  ),
  Transaksi(
    noBukti: 'BKU-2026-0104',
    tanggal: '08/10/2026',
    uraian: 'Setoran ke bank: ke Bank SulutGo ··1107',
    jenis: _pi,
    kasBank: 'Kas ke Bank SulutGo',
    masuk: 1500000,
    keluar: 1500000,
  ),
  trx0105,
  Transaksi(
    noBukti: 'BKU-2026-0106',
    tanggal: '10/10/2026',
    uraian: 'Pengembalian sisa uang muka · Panitia HUT Jemaat',
    jenis: JenisTransaksi.pengembalianSisaUangMuka,
    kasBank: 'Kas',
    masuk: 350000,
  ),
  Transaksi(
    noBukti: 'BKU-2026-0107',
    tanggal: '11/10/2026',
    kodeMA: '1.3.53.07.00',
    uraian: 'Persembahan Ibadah Minggu',
    jenis: _pd,
    kasBank: 'Kas',
    masuk: 2650000,
  ),
  Transaksi(
    noBukti: 'BKU-2026-0108',
    tanggal: '11/10/2026',
    kodeMA: '2.1.01.02.00',
    uraian: 'Titipan untuk: Sinode · Sentralisasi',
    jenis: _tm,
    kasBank: 'Kas',
    masuk: 600000,
  ),
  trx0109,
  trx0110,
  Transaksi(
    noBukti: 'BKU-2026-0114',
    tanggal: '18/10/2026',
    kodeMA: '1.3.53.07.00',
    uraian: 'Persembahan Ibadah Minggu',
    jenis: _pd,
    kasBank: 'Kas',
    masuk: 2400000,
  ),
  Transaksi(
    noBukti: 'BKU-2026-0115',
    tanggal: '18/10/2026',
    kodeMA: '1.4.10.02.00',
    uraian: 'Sumbangan donatur',
    jenis: _pd,
    kasBank: _bni,
    masuk: 700000,
  ),
  Transaksi(
    noBukti: 'BKU-2026-0117',
    tanggal: '18/10/2026',
    kodeMA: '2.1.01.02.00',
    uraian: 'Titipan untuk: Sinode · Sentralisasi',
    jenis: _tm,
    kasBank: 'Kas',
    masuk: 600000,
  ),
  Transaksi(
    noBukti: 'BKU-2026-0112',
    tanggal: '20/10/2026',
    uraian: 'Uang Muka diberikan · Sdri. Natalia Rumengan',
    jenis: _um,
    kasBank: 'Kas',
    keluar: 800000,
  ),
  Transaksi(
    noBukti: 'BKU-2026-0113',
    tanggal: '20/10/2026',
    kodeMA: '1.3.53.09.00',
    uraian: 'Persembahan syukur',
    jenis: _pd,
    kasBank: 'Kas',
    masuk: 1220000,
  ),
  trx0116,
  Transaksi(
    noBukti: 'BKU-2026-0119',
    tanggal: '25/10/2026',
    uraian: 'Uang Muka diberikan · Ibu Selvie Kalalo',
    jenis: _um,
    kasBank: 'Kas',
    keluar: 300000,
  ),
  Transaksi(
    noBukti: 'BKU-2026-0123',
    tanggal: '25/10/2026',
    kodeMA: '1.3.53.07.00',
    uraian: 'Persembahan Ibadah Minggu',
    jenis: _pd,
    kasBank: 'Kas',
    masuk: 2700000,
  ),
  Transaksi(
    noBukti: 'BKU-2026-0125',
    tanggal: '25/10/2026',
    kodeMA: '2.1.01.02.00',
    uraian: 'Titipan untuk: Sinode · Sentralisasi',
    jenis: _tm,
    kasBank: 'Kas',
    masuk: 600000,
  ),
  Transaksi(
    noBukti: 'BKU-2026-0120',
    tanggal: '26/10/2026',
    kodeMA: '5.07.01.00',
    uraian: 'Honorarium pelayan',
    jenis: _bl,
    kasBank: _bni,
    keluar: 1820000,
  ),
  Transaksi(
    noBukti: 'BKU-2026-0130',
    tanggal: '26/10/2026',
    uraian: 'Setoran ke bank: ke Bank BNI ··4821',
    jenis: _pi,
    kasBank: 'Kas ke Bank BNI',
    masuk: 2690000,
    keluar: 2690000,
  ),
  trx0118,
  trx0122,
  trx0121,
  trx0127,
  Transaksi(
    noBukti: 'BKU-2026-0128',
    tanggal: '30/10/2026',
    kodeMA: '2.1.01.02.00',
    uraian: 'Penyaluran · Titipan untuk: Sinode',
    jenis: JenisTransaksi.titipanDisalurkan,
    kasBank: _bni,
    keluar: 2400000,
  ),
  trx0131,
  trx0133,
];

/// "Saldo semua Kas/Bank" printed after each F02 row, same order.
const f02SaldoSetelah = [
  40400000, 41000000, 39180000, 37930000, 37930000, 37530000, 37530000, //
  36780000, 37130000, 39780000, 40380000, 41130000, 40380000, 42780000,
  43480000, 44080000, 43280000, 44500000, 39000000, 38700000, 41400000,
  42000000, 40180000, 40180000, 40680000, 40380000, 40880000, 40880000,
  38480000, 38480000, 38465000,
];
const f02SaldoAwal = 36250000; // "Saldo awal Kas/Bank Rp36.250.000"

/// Page subtotals (after BKU-2026-0108 and BKU-2026-0125) and the final
/// "Jumlah dan saldo akhir Kas/Bank" row.
const f02Halaman1 = (masuk: 14850000, keluar: 10720000);
const f02Halaman2 = (masuk: 23070000, keluar: 17320000);
const f02Jumlah = (masuk: 29260000, keluar: 27045000, saldo: 38465000);

const f02Catatan =
    '31 baris. … Nomor di antara BKU-2026-0098 dan BKU-2026-0133 yang tidak tampil di sini bukan arus kas/bank Oktober 2026; semuanya terdaftar di F12 Daftar Bukti Kas.';

/// Numbers in the F02 range that are not October cash rows.
const nomorBukanArusOktober = [
  (
    noBukti: 'BKU-2026-0111',
    teks: 'diberikan 14/10/2026 10.20, pembukuannya tidak selesai. Nomor ini tidak dipakai ulang.',
  ),
  (noBukti: 'BKU-2026-0124', teks: 'diberikan 29/10/2026 16.05, …'),
  (noBukti: 'BKU-2026-0126', teks: 'diberikan 30/10/2026 09.12, …'),
  (
    noBukti: 'BKU-2026-0129',
    teks: 'Uang Muka diberikan, Panitia Natal, 01/11/2026',
  ),
  (noBukti: 'BKU-2026-0132', teks: 'Sampul syukur Novita Wenas, 01/11/2026'),
];

/// R03 (section 3 row 13): the settlements of the October advances
/// (Rp400.000 and Rp300.000, together Rp700.000) are dated November, so the
/// October pack prints Rp0 for them and attachment 2 reads "Nihil". Do not
/// add them to October.
const penyelesaianUangMukaOktoberDiNovember = [400000, 300000];

// ---------- September 2026 rows (PilihBulan, Kejadian, Draf) ----------

const transaksiSeptember = [
  Transaksi(
    noBukti: 'OPN-2026-0001',
    tanggal: '15/09/2026',
    uraian: 'Saldo awal pencatatan',
    jenis: JenisTransaksi.saldoAwal,
    masuk: 32300000,
  ),
  Transaksi(
    noBukti: 'BKU-2026-0019',
    tanggal: '18/09/2026',
    uraian: 'Persembahan Ibadah Minggu',
    jenis: _pd,
    masuk: 2900000,
  ),
  Transaksi(
    noBukti: 'BKU-2026-0031',
    tanggal: '22/09/2026',
    uraian: 'Alat tulis Toko Sinar',
    jenis: _bl,
    keluar: 85000,
  ),
];

/// Draf printed with "28 September 2026"; "Draf dicatat oleh Meiske L."
/// 28/09/2026 16.10. Section 3 row 27: the Honor pemusik draft differs per
/// board (see [drafHonorPemusik]).
const drafHonorPemusikSeptember = Transaksi(
  tanggal: '28/09/2026',
  uraian: 'Honor pemusik',
  jenis: _bl,
  status: StatusTransaksi.draf,
  kasBank: _bni,
  keluar: 650000,
  catatan: 'Draf dicatat oleh Meiske L.',
);

// ---------- 2.9 November 2026 (running month, as of 16/11/2026) ----------

/// Beranda figures (Main, WebBeranda, TabBeranda). Saldo per Kas/Bank is
/// saldoNovember in keuangan.dart.
const berandaNovember = (
  drafJumlah: 800000,
  drafTeks: 'Rp800.000 · 2 draf · belum masuk saldo',
  pendapatan: 7540000, // "tanpa titipan"
  belanja: 7940000,
  surplus: -400000,
);

/// "Perlu tindakan (4)" on Beranda, as (judul, sub). The first sub is bata,
/// bold. Section 3 row 15: Main, WebBeranda, BerandaJabatan say
/// "1 hambatan"; WebTutupBuku (`adaHambatan`) shows 2.
const berandaPerluTindakan = [
  (
    'Oktober 2026 belum ditutup',
    '1 hambatan · bulan berikutnya untuk tutup buku',
  ),
  ('2 draf belum dibukukan', 'Belum masuk saldo · Rp800.000'),
  ('1 dokumen pendukung wajib, belum ada', 'BKU-2026-0143 · Rp600.000'),
  ('1 Mata Anggaran belum dipilih', 'Draf · Honor pemusik'),
];
const berandaUntukDiketahui =
    '2 uang muka dengan sisa belum dipertanggungjawabkan · Rp1.150.000';
const berandaPosisiKas = '— Belum dihitung';
const berandaPosisiBank = '— Rekening koran belum diisi';

// Tweak `bulan: sepi`: all November figures Rp0, no drafts, only the
// October action.

const trx0139 = Transaksi(
  noBukti: 'BKU-2026-0139',
  tanggal: '09/11/2026',
  kodeMA: '5.02.01.00',
  uraian: 'Konsumsi rapat majelis',
  jenis: _bl,
  status: StatusTransaksi.dibalik,
  kasBank: 'Kas',
  keluar: 750000,
  tandaRantai: 'Dibalik oleh No. Bukti BKU-2026-0144',
  dokumen: StatusDokumenPendukung.terverifikasi,
  dibukukanPada: '09/11/2026 14.12',
);

/// Section 3 row 7: KeuanganUnit dates the posting 17/11/2026 20.10, AlurUnit
/// dates the transaction 12/11/2026. Pemeriksa uses 0151 for "Sewa kursi
/// ibadah padang" (−Rp900.000) and WebPemeriksa for its first row; Bukti's
/// series runs "sampai 0151". Number reused by independent boards.
const trx0151 = Transaksi(
  noBukti: 'BKU-2026-0151',
  tanggal: '12/11/2026',
  uraian: 'Persembahan Ibadah Kolom',
  jenis: _pd,
  kasBank: 'Kas Kolom 7',
  masuk: 320000,
  peruntukan: 'Kolom 7',
  dibukukanPada: '17/11/2026 20.10',
  catatan:
      'Dibukukan oleh Deasy Tumbelaka, Bendahara Kolom 7 · 17/11/2026 20.10',
);

/// Section 3 rows 5–6: Bukti, WebBukti, Dokumen, LihatDokumen show it posted;
/// Main, PilihBulan, WebPemeriksa still show the draft dated 14/11/2026
/// ([drafFotokopiWarta]); WebTransaksi shows the draft dated 16/11/2026
/// ([drafFotokopiWartaWeb]). The Catat flow on Main, TabCatat, WebCatat also
/// posts as BKU-2026-0147 ([catatPosting]).
const trx0147 = Transaksi(
  noBukti: 'BKU-2026-0147',
  tanggal: '16/11/2026',
  kodeMA: '5.02.01.00',
  uraian: 'Fotokopi warta jemaat',
  jenis: _bl,
  kasBank: 'Kas',
  keluar: 150000,
  peruntukan: 'Umum Jemaat',
  lingkup: 'Jemaat',
  dokumen: StatusDokumenPendukung.diunggah,
  dibukukanPada: '16/11/2026 10.42',
);

/// Section 3 row 10: Persembahan/WebPersembahan post the same service again
/// as BKU-2026-0148 (Rp3.600.000, [persembahanBagian]). Row 11: JabatanKosong
/// prints "Dibukukan pada 16/11/2026 11.42" by Yanti Sumual.
const trx0146 = Transaksi(
  noBukti: 'BKU-2026-0146',
  tanggal: '15/11/2026',
  kodeMA: '1.3.53.07.00',
  uraian: 'Persembahan Ibadah Minggu',
  jenis: _pd,
  kasBank: 'Kas',
  masuk: 3450000,
  peruntukan: 'Umum Jemaat',
  lingkup: 'Jemaat',
  dokumen: StatusDokumenPendukung.terverifikasi,
  dibukukanPada: '15/11/2026 12.20',
);

/// The union of the November transactions drawn; each board uses its own
/// fields. See the doc comments of the named rows for disagreements.
const transaksiNovember = [
  Transaksi(
    noBukti: 'BKU-2026-0129',
    tanggal: '01/11/2026',
    uraian: 'Uang Muka diberikan · Panitia Natal',
    jenis: _um,
    keluar: 1500000,
    peruntukan: 'Umum Jemaat',
    catatan: 'Sdr. Rivo Mandagi · dari peruntukan Umum Jemaat',
  ),

  /// Novita Wenas, Ibadah Minggu Pagi (PersembahanSaya). Section 3 row 29:
  /// CariOrang dates it 08/11/2026.
  Transaksi(
    noBukti: 'BKU-2026-0132',
    tanggal: '01/11/2026',
    uraian: 'Sampul syukur',
    jenis: _pd,
    masuk: 100000,
    peruntukan: 'Umum Jemaat',
    catatan: 'Novita Wenas · Ibadah Minggu Pagi',
  ),
  Transaksi(
    noBukti: 'BKU-2026-0134',
    tanggal: '05/11/2026',
    uraian: 'Penggantian biaya dibayar · Bensin antar jemput',
    jenis: JenisTransaksi.penggantianBiaya,
    keluar: 120000,
    catatan: 'Sdr. Rivo Mandagi · Belanja, dicatat satu kali',
  ),
  Transaksi(
    noBukti: 'BKU-2026-0135',
    tanggal: '06/11/2026',
    kodeMA: '1.3.55.01.00',
    uraian: 'Persembahan Diakonia',
    jenis: _pd,
    masuk: 1200000,
    peruntukan: 'Diakonia',
  ),
  Transaksi(
    noBukti: 'BKU-2026-0136',
    tanggal: '07/11/2026',
    uraian: 'Penyaluran · Sentralisasi November',
    jenis: JenisTransaksi.titipanDisalurkan,
    keluar: 1000000,
    catatan: 'Sinode · bukan Belanja',
  ),
  Transaksi(
    noBukti: 'BKU-2026-0137',
    noBuktiAsal: 'KW-0412',
    tanggal: '08/11/2026',
    uraian: 'Renovasi pastori, termin 1',
    jenis: _bl,
    keluar: 4500000,
    persetujuan: 'Sudah dicatat · Pdt. Lidya Rondonuwu, Ketua BPMJ',
    dokumen: StatusDokumenPendukung.dikecualikan,
    catatan: 'Dikecualikan (alasan: kuitansi menyusul, oleh Ketua BPMJ)',
  ),
  Transaksi(
    noBukti: 'BKU-2026-0138',
    tanggal: '08/11/2026',
    uraian: 'Pertanggungjawaban uang muka · Panitia Natal',
    jenis: _pj,
    keluar: 850000,
    catatan: 'menjadi Belanja',
  ),
  trx0139,
  Transaksi(
    noBukti: 'BKU-2026-0140',
    uraian: 'Bensin operasional',
    jenis: _bl,
    keluar: 200000,
  ),
  Transaksi(
    noBukti: 'BKU-2026-0141',
    tanggal: '10/11/2026',
    kodeMA: '4.03.03.00',
    uraian: 'Diakonia duka',
    jenis: _bl,
    keluar: 500000,
    peruntukan: 'Diakonia',
  ),
  Transaksi(
    noBukti: 'BKU-2026-0142',
    uraian: 'Pindah antar Kas/Bank: Kas ke Bank BNI',
    jenis: _pi,
    masuk: 1000000,
  ),

  /// Receipt CV NADA PRIMA ([notaSoundSystem]).
  Transaksi(
    noBukti: 'BKU-2026-0143',
    tanggal: '11/11/2026',
    kodeMA: '5.05.02.00',
    uraian: 'Sewa sound system',
    jenis: _bl,
    kasBank: 'Kas',
    keluar: 600000,
    lingkup: 'Panitia Natal',
    dokumen: StatusDokumenPendukung.wajibBelumAda,
    dibukukanPada: '11/11/2026 16.05',
  ),
  Transaksi(
    noBukti: 'BKU-2026-0144',
    tanggal: '12/11/2026',
    uraian: 'Pembalikan BKU-2026-0139',
    jenis: JenisTransaksi.pembalikan,
    kasBank: 'Kas',
    masuk: 750000,
    tandaRantai: 'Pembalikan',
    dibukukanPada: '12/11/2026 09.31',
    catatan: 'Mata Anggaran keliru',
  ),
  Transaksi(
    noBukti: 'BKU-2026-0145',
    kodeMA: '5.04.01.00',
    uraian: 'Konsumsi rapat majelis',
    jenis: JenisTransaksi.koreksi,
    keluar: 750000,
    catatan: 'koreksi · 5.04.01.00 Konsumsi rapat',
  ),
  trx0146,
  trx0147,
  Transaksi(
    noBukti: 'BKU-2026-0148',
    tanggal: '15/11/2026',
    uraian: 'Persembahan Ibadah Minggu',
    jenis: _pd,
    masuk: 3600000,
    bagian: persembahanBagian,
  ),
  Transaksi(
    noBukti: 'BKU-2026-0149',
    tanggal: '03/11/2026',
    uraian: 'Pertanggungjawaban uang muka · Perjalanan dinas Wilayah',
    jenis: _pj,
    keluar: 400000,
    catatan: 'menjadi Belanja',
  ),

  /// Section 3 row 8: Kewajiban's own next number for new entries is also
  /// BKU-2026-0150 (`nomor: 150`). Keep.
  Transaksi(
    noBukti: 'BKU-2026-0150',
    tanggal: '05/11/2026',
    uraian: 'Pertanggungjawaban uang muka · Retret Pemuda',
    jenis: _pj,
    keluar: 300000,
    catatan: 'menjadi Belanja',
  ),
  trx0151,

  /// Section 3 row 9: WebPemeriksa uses 0152 for its second posted row.
  Transaksi(
    noBukti: 'BKU-2026-0152',
    tanggal: '16/11/2026',
    uraian: 'Alih peruntukan',
    jenis: JenisTransaksi.alihPeruntukan,
    kasBank: _bni,
    dibukukanPada: '16/11/2026 11.55',
  ),
  Transaksi(
    noBukti: 'BKU-2026-0155',
    tanggal: '16/11/2026',
    kodeMA: '5.04.01.00',
    uraian: 'Konsumsi rapat',
    jenis: _bl,
    kasBank: 'Kas',
    keluar: 85000,
    dibukukanPada: '16/11/2026 11.52',
    catatan:
        'satu kali', // Memuat: "Dibukukan pada 16/11/2026 11.52 · satu kali"
  ),
  drafFotokopiWarta,
  drafHonorPemusik,
  dibatalkanBungaAltar,
];

/// Section 3 row 5: Main, PilihBulan, WebPemeriksa date this draft
/// 14/11/2026; WebTransaksi uses [drafFotokopiWartaWeb].
const drafFotokopiWarta = Transaksi(
  tanggal: '14/11/2026',
  uraian: 'Fotokopi warta jemaat',
  jenis: _bl,
  status: StatusTransaksi.draf,
  kasBank: 'Kas',
  keluar: 150000,
  catatan: 'Belum masuk saldo',
);

/// Section 3 row 5: WebTransaksi's copy of the draft (16/11/2026).
const drafFotokopiWartaWeb = Transaksi(
  tanggal: '16/11/2026',
  uraian: 'Fotokopi warta jemaat',
  jenis: _bl,
  status: StatusTransaksi.draf,
  kasBank: 'Kas',
  keluar: 150000,
  catatan: 'Belum masuk saldo',
);

/// Main, WebTransaksi. Section 3 row 27: WebPemeriksa → 15/11/2026, MA
/// 5.07.01.00; Draf → 28 September 2026 ([drafHonorPemusikSeptember]);
/// Impor → 08/11/2026 Kas Rp650.000. Separate demos.
const drafHonorPemusik = Transaksi(
  tanggal: '08/11/2026',
  uraian: 'Honor pemusik',
  jenis: _bl,
  status: StatusTransaksi.draf,
  kasBank: _bni,
  keluar: 650000,
  persetujuan: 'Persetujuan belum dicatat',
  dokumen: StatusDokumenPendukung.wajibBelumAda,
  catatan: 'Mata Anggaran belum dipilih',
);

/// WebTransaksi: "Tercatat dua kali"; "Dibatalkan oleh Meiske L."
/// 06/11/2026 08.02.
const dibatalkanBungaAltar = Transaksi(
  tanggal: '05/11/2026',
  uraian: 'Pembelian bunga altar',
  jenis: _bl,
  status: StatusTransaksi.dibatalkan,
  kasBank: 'Kas',
  keluar: 200000,
  catatan: 'Tercatat dua kali',
);
const dibatalkanBungaAltarOleh = 'Dibatalkan oleh Meiske L.';
const dibatalkanBungaAltarPada = '06/11/2026 08.02';

/// The Catat flow on Main, TabCatat and WebCatat always posts this way.
const catatPosting = (
  noBukti: 'BKU-2026-0147',
  dibukukanPada: 'Dibukukan pada 16/11/2026 10.42',
  dicatatPada: 'Dicatat pada 16/11/2026 10.39',
  file: 'nota-16-11.jpg',
  tanggalPanjang: '16 November 2026',
);

/// Riwayat lines of the Catat flow; the name ends each line ("oleh …",
/// Meiske L. or plk).
const catatRiwayat = [
  '10.42 · Dibukukan oleh',
  '10.41 · Dokumen pendukung diunggah',
  '10.39 · Draf dicatat oleh',
];

/// Bukti (phone) and WebBukti. Phone prints "Contoh 5 dari 51".
const buktiJudul = 'Daftar Bukti Kas · November 2026 · Belum ditutup';
const buktiSeriBiasa = 'Seri Biasa · BKU-2026-0001 sampai 0151';
const buktiContohWeb = 'Contoh 6 dari 51 baris';
const buktiContohPonsel = 'Contoh 5 dari 51';
const buktiNomorTanpaTransaksi = '3 nomor tanpa transaksi'; // 0111, 0124, 0126
const buktiSeriOpn = 'Seri OPN … Tidak ada celah';
const buktiSeriAdj = 'Seri ADJ Penyesuaian · Belum pernah dipakai';

/// Import rows (Impor, WebImpor). `hasil` is a code, not display text:
/// 'ok', 'ganda' (possible duplicate), 'ditolak' (refused). Statuses "Ditampung · Lolos pengecekan ·
/// Sudah diperiksa · Sudah diimpor".
const imporStatus = [
  'Ditampung',
  'Lolos pengecekan',
  'Sudah diperiksa',
  'Sudah diimpor',
];
const imporBaris = [
  (
    sumber: '02/11/26 · Persembahan Mgg · 3.100.000',
    dibaca: '02/11/2026 · Kas · Rp3.100.000 masuk',
    mataAnggaran: 'Pendapatan 1.3.53.07.00',
    hasil: 'ok',
  ),
  (
    sumber: '04/11/26 · Bayar PLN · -1250000',
    dibaca: '04/11/2026 · Bank BNI ··4821 · Rp1.250.000 keluar',
    mataAnggaran: 'Belanja 5.01.02.00',
    hasil: 'ok',
  ),
  (
    sumber: '4 Nop · PLN nov · 1.250.000,-',
    dibaca: '04/11/2026 · Bank BNI ··4821 · Rp1.250.000 keluar',
    mataAnggaran: 'Belanja 5.01.02.00',
    hasil: 'ganda',
  ),
  (
    sumber: '08/11/26 · Honor pemusik · 650rb',
    dibaca: '08/11/2026 · Kas · Rp650.000 keluar',
    mataAnggaran: '—',
    hasil: 'ok',
  ),
  (
    sumber: '31/11/26 · ATK · 85.000',
    dibaca: 'tanggal tidak terbaca · Kas · Rp85.000 keluar',
    mataAnggaran: 'Belanja 5.02.01.00',
    hasil: 'ditolak',
  ),
];

/// Export (Ekspor) parts, as (judul, keterangan).
const eksporBagian = [
  ('Buku', ''),
  ('Versi', ''),
  ('Dokumen pendukung', '214 file, masing-masing dengan checksum'),
  ('Laporan', 'Laporan resmi September dan Oktober 2026'),
  ('Daftar isi', ''),
];
const eksporWebDitahan =
    '2 file Ditahan (alasan keamanan) · BKU-2026-0117, BKU-2026-0130';
const eksporWebGagal = '1 file gagal dibaca · BKU-2026-0102';

// ---------- 2.13 Persembahan with several parts ----------

const persembahanJudul = 'Ibadah Minggu · 15 November 2026';

/// Tunai to Kas; QRIS with no Kas/Bank yet; Transfer bank as titipan to
/// Bank BNI. Posts as BKU-2026-0148. The boards name no peruntukan.
const persembahanBagian = [
  BagianTransaksi(kodeMA: '1.3.53.07.00', jumlah: 2350000, kasBankId: 'kas'),
  BagianTransaksi(kodeMA: '1.3.53.07.00', jumlah: 800000),
  BagianTransaksi(kodeMA: '2.1.01.02.00', jumlah: 450000, kasBankId: 'bni'),
];
const persembahanBagianNama = ['Tunai', 'QRIS', 'Transfer bank'];
const persembahanBagianJenis = [
  'Milik sendiri',
  'Milik sendiri',
  'Titipan untuk: Sinode',
];
const persembahanMilikSendiri = 3150000;
const persembahanTitipan = 450000;
const persembahanJumlah = 3600000;
const persembahanMAMilik = 'Pendapatan 1.3.53.07.00 Persembahan Ibadah Minggu';
const persembahanMATitipan =
    'Pendapatan 2.1.01.02.00 DANA TRANSIT Sentralisasi Sinode';

/// Default first.
const persembahanPetugas = ['Dkn. Olga Tamba', 'Pnt. Jefry Wowor', 'Meiske L.'];

/// Named envelopes added in this order.
const persembahanAmplop = [
  ('Novita Wenas', 100000),
  ('Agustina Lasut', 250000),
];
const persembahanFile = 'lembar-penghitungan-15-11.jpg';

// ---------- 2.14 Supporting documents (Dokumen, WebDokumen) ----------

const _nov = 'November 2026 · Belum ditutup';

/// Rows d, e, f: initial status per board ([DokumenPendukung.status] null).
const dokumenPendukung = [
  DokumenPendukung(
    id: 'a',
    noBukti: 'BKU-2026-0147',
    uraian: 'Fotokopi warta jemaat',
    jumlah: -150000,
    bulan: _nov,
    status: StatusDokumenPendukung.diunggah,
    file: 'nota-16-11.jpg',
    riwayat: ['16/11/2026 10.41 · nota-16-11.jpg diunggah oleh Meiske L.'],
  ),
  DokumenPendukung(
    id: 'b',
    noBukti: 'BKU-2026-0143',
    uraian: 'Sewa sound system',
    jumlah: -600000,
    bulan: _nov,
    status: StatusDokumenPendukung.wajibBelumAda,
  ),

  /// History from 22/10 (per board).
  DokumenPendukung(
    id: 'c',
    noBukti: 'BKU-2026-0116',
    uraian: 'Pemeliharaan atap gedung',
    jumlah: -5500000,
    bulan: 'Oktober 2026 · Sudah ditutup',
    status: StatusDokumenPendukung.dikecualikan,
  ),
  DokumenPendukung(
    id: 'd',
    noBukti: 'BKU-2026-0145',
    uraian: 'Konsumsi rapat majelis',
    jumlah: -750000,
    bulan: _nov,
  ),
  DokumenPendukung(
    id: 'e',
    noBukti: 'BKU-2026-0140',
    uraian: 'Bensin operasional',
    jumlah: -200000,
    bulan: _nov,
  ),
  DokumenPendukung(
    id: 'f',
    noBukti: 'BKU-2026-0142',
    uraian: 'Pindah antar Kas/Bank: Kas ke Bank BNI',
    jumlah: 1000000,
    bulan: _nov,
  ),
];

/// Receipt paper colour is PalakatIlustrasi (#FBFAF6).
const notaFotokopi = Nota(
  toko: 'TOKO SINAR',
  alamat: 'Jl. Pierre Tendean 7',
  total: 'Rp150.000',
  tanggal: '16/11/2026',
  kaki: 'Terima kasih',
  baris: [('Fotokopi warta', ''), ('300 lbr x 500', '150.000')],
);
const notaSoundSystem = Nota(
  toko: 'CV NADA PRIMA',
  alamat: 'Jl. Sam Ratulangi 14',
  total: 'Rp600.000',
  tanggal: '11/11/2026',
  kaki: 'LUNAS',
  baris: [('Sewa sound system', ''), ('1 hari', '600.000')],
);

// ---------- 2.15 Corrections, persetujuan, events, refunds ----------

/// Koreksi, WebKoreksi. Result 0144 (pembalikan) + 0145 (koreksi); effect
/// "Rp0" (koreksi) or "+Rp750.000" (pembalikan only). `bulanTransaksi:
/// Sudah ditutup` shows date 09/10/2026.
const koreksi = (
  asal: trx0139,
  maAsal:
      'Belanja 5.02.01.00 Alat tulis dan fotokopi · Versi Mata Anggaran 2026.1',
  // (kode, nama, catatan) as the board's list: 'asal' is a tag, not part
  // of the name.
  pilihanMA: [
    ('5.02.01.00', 'Alat tulis dan fotokopi', 'asal'),
    ('5.04.01.00', 'Konsumsi rapat', ''),
  ],
  persetujuan:
      'Pdt. Lidya Rondonuwu, Ketua BPMJ · 08/11/2026 · cara: notulen rapat',
  dicatatPada: '16/11/2026 11.20',
  tanggalBulanDitutup: '09/10/2026',
);

/// Persetujuan, WebPersetujuan.
const persetujuan = (
  jumlah: -2500000,
  kasBank: _bni,
  ma: 'Belanja 5.08.02.00 Pemeliharaan gedung · 16 November 2026',
  oleh: 'Pdt. Lidya Rondonuwu, Ketua BPMJ',
  tanggal: '08/11/2026',
  cara: 'notulen rapat',
  dicatatPada: '16/11/2026 11.20',
  digantiPada: '16/11/2026 11.45',
  jumlahBaru: -2750000,
  jumlahBaruPada: '16/11/2026 11.50',
);

/// Pemeriksa (phone). Section 3 row 7: posts as BKU-2026-0151. Row 37:
/// Pemeriksa and WebPemeriksa have "Wajib pemeriksa kedua: hidup", while
/// Lainnya has the rule off ("Hidup mulai Desember 2026" when switched).
const pemeriksa = (
  uraian: 'Sewa kursi ibadah padang',
  jumlah: -900000,
  kasBank: 'Kas',
  peruntukan: 'Umum Jemaat',
  lingkup: 'Jemaat',
  ma: 'Belanja 5.05.02.00 Sewa peralatan · 16 November 2026',
  dicatat: 'Meiske L. · 16/11/2026 09.40',
  diperiksa: 'Pnt. Jefry Wowor · 16/11/2026 10.05',
  noBukti: 'BKU-2026-0151',
);

/// WebPemeriksa rows a, b, c. Section 3 rows 7, 9, 27: posted numbers
/// BKU-2026-0151/0152/0153 reuse numbers other boards use.
const pemeriksaWeb = [
  (
    id: 'a',
    uraian: 'Sewa kursi ibadah padang',
    tanggal: '16/11/2026',
    jumlah: -900000,
    sub: 'Kas · Belanja 5.05.02.00 Sewa peralatan',
    noBukti: 'BKU-2026-0151',
  ),
  (
    id: 'b',
    uraian: 'Honor pemusik',
    tanggal: '15/11/2026',
    jumlah: -650000,
    sub: 'Bank BNI ··4821 · Belanja 5.07.01.00 Honorarium pelayan',
    noBukti: 'BKU-2026-0152',
  ),
  (
    id: 'c',
    uraian: 'Fotokopi warta jemaat',
    tanggal: '14/11/2026',
    jumlah: -150000,
    sub: 'Kas · Belanja 5.02.01.00 Alat tulis dan fotokopi',
    noBukti: 'BKU-2026-0153',
  ),
];

/// Kejadian, WebKejadian. Section 3 row 20: K-2026-01's "lebih Rp85.000"
/// disagrees with F10/F11 (selisih Rp0); Kejadian demo, keep.
const kejadian = [
  Kejadian(
    no: 'K-2026-01',
    judul: 'Nota tercatat dua kali',
    periode: 'September 2026',
    transaksi: 'BKU-2026-0031',
    penjelasan: 'Nota Toko Sinar Rp85.000 tercatat dua kali pada 22/09/2026. Ditemukan saat hitung kas 31/10/2026.',
    dampak:
        'Kas Oktober 2026: hasil hitung kas lebih Rp85.000 dari Saldo buku.',
    penanggungJawab: 'Pdt. Lidya Rondonuwu, Ketua BPMJ',
    eskalasi: 'Dibahas di rapat BPMJ 09/11/2026. Belum ada keputusan.',
  ),
  Kejadian(
    no: 'K-2026-02',
    judul: 'Dokumen pendukung menyusul',
    periode: 'September 2026',
    transaksi: 'BKU-2026-0019',
    penjelasan: 'Kuitansi asli diterima 12/10/2026, setelah September ditutup.',
    dampak: 'Tidak ada.',
    penanggungJawab: 'Meiske L., Bendahara',
  ),
];

/// Pengembalian, WebPengembalian: donatur and pemasok sources.
const pengembalianDonatur = (
  noBukti: 'BKU-2026-0121',
  uraian: 'Sumbangan donatur',
  jumlah: 500000,
  ma: 'Pendapatan 1.4.10.02.00',
  kasBank: _bni,
);
const pengembalianPemasok = (
  noBukti: 'BKU-2026-0116',
  uraian: 'Pemeliharaan atap gedung',
  jumlah: 5500000,
  ma: 'Belanja 5.08.02.00',
  kasBank: _bni,
);

/// AlurPengembalian: three sources; date 16/11/2026.
const alurPengembalianSumber = [
  (
    tanggal: '22/10/2026',
    jumlah: 5500000,
    ma: 'Belanja 5.08.02.00 Pemeliharaan gedung',
  ),
  (
    tanggal: '11/11/2026',
    jumlah: 600000,
    ma: 'Belanja 5.05.02.00 Sewa peralatan',
  ),
  (
    tanggal: '28/10/2026',
    jumlah: 500000,
    ma: 'Pendapatan 1.4.10.02.00 Sumbangan donatur',
  ),
];

/// Draf, WebDraf: Honor pemusik (see [drafHonorPemusikSeptember]).
const drafKonflikPada = '16/11/2026 10.58'; // "oleh …, 16/11/2026 10.58"
const drafDibatalkanPada = '16/11/2026 11.20';
const drafKosongDibuat = '16/11/2026 11.02';

/// Bagi, WebBagi: payment Rp1.250.000, two lines, Rp50.000 still to split.
const bagiPembayaran = 1250000;
const bagiBaris = [('5.01.02.00', 1000000), ('5.02.01.00', 200000)];
const bagiSisa = 50000;

/// AIFoto, BantuanAI.
const aiPembagian = [('5.01.02.00', 1000000), ('5.02.01.00', 250000)];
const aiKalimat = 'Bayar PLN Rp1.250.000 dari BNI tanggal 6 Oktober';

/// AIMataAnggaran.
const aiMataAnggaranJumlah = -480000;
const aiMataAnggaranPecah = 'Kertas HVS Rp300.000 dan token listrik Rp180.000';

/// AIBulan, WebAI.
const aiBulanSelisih = 'Selisih Rp515.000 di Bank BNI …';
const aiBulanTarikTunai = (
  mutasi: 'TARIK TUNAI',
  jumlah: -2000000,
  tanggal: '30/10/2026',
  noBukti: 'BKU-2026-0127',
);
const aiBulanKemungkinanGanda = (
  noBukti: 'BKU-2026-0101',
  draf: 'Toko Sinar okt',
  jumlah: 1250000,
  tanggal: '06/10/2026',
);

/// Tanggal, WebTanggal.
const tanggalContoh = '16/11/2026 11.40';

/// Memuat: saldo from saldoNovember (keuangan.dart) and this posting.
const memuatNoBukti = 'BKU-2026-0155';
const memuatJumlah = -85000;
