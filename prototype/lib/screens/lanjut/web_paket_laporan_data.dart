part of 'web_paket_laporan.dart';

// The board's `F`, `LAP` and `LAPT` tables, verbatim (mock-data.md 0: report
// strings are printed as drawn, never recomputed).

/// Report list: code, name, "Format bawaan aplikasi. …" description.
/// F02's description changes with the TERBATAS copy (see [_isiF02Terbatas]).
const _daftarLaporan = [
  (
    'F01',
    'Laporan Perbendaharaan Bulanan',
    'Saldo awal dan akhir Kas/Bank, Pendapatan dan Belanja, Dana Transit masuk dan keluar, uang muka, kesimpulan rekonsiliasi.',
  ),
  (
    'F02',
    'Buku Kas Umum',
    'Semua Kas/Bank dalam satu buku, dengan label Kas/Bank per baris.',
  ),
  (
    'F03',
    'Buku Kas Pembantu',
    'Per Kas/Bank, per peruntukan, per Lingkup, per Uang Muka, per Titipan untuk.',
  ),
  (
    'F04',
    'Mata Anggaran Pendapatan',
    'Semua baris versi yang diterbitkan, sesuai urutan sumber.',
  ),
  (
    'F05',
    'Realisasi Pendapatan Menurut Mata Anggaran',
    'Pendapatan per baris, termasuk baris bernilai Rp0. Tanpa kolom anggaran.',
  ),
  (
    'F06',
    'Mata Anggaran Belanja',
    'Semua baris versi yang diterbitkan, sesuai urutan sumber.',
  ),
  (
    'F07',
    'Realisasi Belanja Menurut Mata Anggaran',
    'Belanja per baris. Tanpa kolom anggaran.',
  ),
  (
    'F08',
    'Rekap Penerimaan',
    'Penerimaan buku, tiap ukuran di kolomnya sendiri.',
  ),
  (
    'F09',
    'Rekap Pengeluaran',
    'Pengeluaran buku, termasuk belanja dari uang muka.',
  ),
  (
    'F10',
    'Posisi Kas & Bank',
    'Saldo buku, hasil hitung kas dan saldo rekening koran di kolom terpisah.',
  ),
  (
    'F11',
    'Rekonsiliasi',
    'Per Kas/Bank: item dalam perjalanan, saldo pembanding, yang cocok dan belum cocok.',
  ),
  (
    'F12',
    'Daftar Bukti Kas',
    'Daftar No. Bukti dengan persetujuan, dokumen pendukung dan pengecualian.',
  ),
  (
    'F13',
    'Sentralisasi / Penyaluran',
    'Titipan per pihak: terkumpul, disalurkan, sisa. Sentralisasi dari uang milik sendiri terpisah.',
  ),
  (
    'F14',
    'Lampiran Laporan Bulanan',
    'Delapan lampiran. Lampiran tanpa isi dicetak sebagai Nihil.',
  ),
];

const _isiF02Terbatas = 'Hanya bagian peruntukan Diakonia.';

/// F02 TERBATAS rows: date, No. Bukti, No. MA, Uraian, receipt, payment.
const _bkuTerbatas = [
  (
    '04/10/2026',
    'BKU-2026-0098',
    '1.3.55.01.00',
    'Bagian peruntukan Diakonia',
    950000,
    0,
  ),
  (
    '27/10/2026',
    'BKU-2026-0122',
    '4.03.04.00',
    'Bagian peruntukan Diakonia',
    0,
    300000,
  ),
];

/// One row of a generic report table; [tebal] = 700 with a `tinta` line.
class _Baris {
  const _Baris(this.sel, [this.tebal = false]);
  final List<String> sel;
  final bool tebal;
}

/// A generic report table. [kolom]: px widths, null = `minmax(0, 1fr)`.
class _Lap {
  const _Lap({
    required this.sub,
    required this.kolom,
    required this.judul,
    required this.kanan,
    required this.mono,
    required this.baris,
    required this.kaki,
  });
  final String sub;
  final List<double?> kolom;
  final List<String> judul;
  final List<int> kanan, mono;
  final List<_Baris> baris;
  final String kaki;

  /// The board's min width: px columns + 10 each, + 170 with a `fr` column.
  double get minLebar =>
      kolom.fold<double>(0, (t, w) => w == null ? t : t + w + 10) +
      (kolom.contains(null) ? 170 : 0);
}

const _m = '−';

const _lap = <String, _Lap>{
  'F03': _Lap(
    sub: 'Buku per Kas/Bank · Kas',
    kolom: [84, 118, null, 112, 112, 120],
    judul: [
      'Tanggal',
      'No. Bukti',
      'Uraian',
      'Penerimaan',
      'Pengeluaran',
      'Saldo Kas',
    ],
    kanan: [3, 4, 5],
    mono: [1, 3, 4, 5],
    baris: [
      _Baris(['', '', 'Saldo awal Kas', '', '', 'Rp4.070.000'], true),
      _Baris([
        '04/10/2026',
        'BKU-2026-0098',
        'Persembahan Ibadah Minggu dan Diakonia',
        'Rp3.200.000',
        '',
        'Rp7.270.000',
      ]),
      _Baris([
        '04/10/2026',
        'BKU-2026-0099',
        'Titipan untuk: Sinode · Sentralisasi',
        'Rp600.000',
        '',
        'Rp7.870.000',
      ]),
      _Baris([
        '06/10/2026',
        'BKU-2026-0102',
        'Setoran ke bank: ke Bank BNI ··4821',
        '',
        'Rp5.000.000',
        'Rp2.870.000',
      ]),
      _Baris([
        '07/10/2026',
        'BKU-2026-0103',
        'Uang Muka diberikan · Pnt. Jefry Wowor',
        '',
        'Rp400.000',
        'Rp2.470.000',
      ]),
      _Baris([
        '08/10/2026',
        'BKU-2026-0104',
        'Setoran ke bank: ke Bank SulutGo ··1107',
        '',
        'Rp1.500.000',
        'Rp970.000',
      ]),
      _Baris([
        '09/10/2026',
        'BKU-2026-0105',
        'Konsumsi rapat majelis · Dibalik oleh BKU-2026-0109',
        '',
        'Rp750.000',
        'Rp220.000',
      ]),
      _Baris([
        '10/10/2026',
        'BKU-2026-0106',
        'Pengembalian sisa uang muka · Panitia HUT Jemaat',
        'Rp350.000',
        '',
        'Rp570.000',
      ]),
      _Baris([
        '11/10/2026',
        'BKU-2026-0107',
        'Persembahan Ibadah Minggu',
        'Rp2.650.000',
        '',
        'Rp3.220.000',
      ]),
      _Baris([
        '11/10/2026',
        'BKU-2026-0108',
        'Titipan untuk: Sinode · Sentralisasi',
        'Rp600.000',
        '',
        'Rp3.820.000',
      ]),
      _Baris([
        '12/10/2026',
        'BKU-2026-0109',
        'Pembalikan BKU-2026-0105',
        '',
        '${_m}Rp750.000',
        'Rp4.570.000',
      ]),
      _Baris([
        '12/10/2026',
        'BKU-2026-0110',
        'Konsumsi rapat majelis · Koreksi dari BKU-2026-0105',
        '',
        'Rp750.000',
        'Rp3.820.000',
      ]),
      _Baris([
        '18/10/2026',
        'BKU-2026-0114',
        'Persembahan Ibadah Minggu',
        'Rp2.400.000',
        '',
        'Rp6.220.000',
      ]),
      _Baris([
        '18/10/2026',
        'BKU-2026-0117',
        'Titipan untuk: Sinode · Sentralisasi',
        'Rp600.000',
        '',
        'Rp6.820.000',
      ]),
      _Baris([
        '20/10/2026',
        'BKU-2026-0112',
        'Uang Muka diberikan · Sdri. Natalia Rumengan',
        '',
        'Rp800.000',
        'Rp6.020.000',
      ]),
      _Baris([
        '20/10/2026',
        'BKU-2026-0113',
        'Persembahan syukur',
        'Rp1.220.000',
        '',
        'Rp7.240.000',
      ]),
      _Baris([
        '25/10/2026',
        'BKU-2026-0119',
        'Uang Muka diberikan · Ibu Selvie Kalalo',
        '',
        'Rp300.000',
        'Rp6.940.000',
      ]),
      _Baris([
        '25/10/2026',
        'BKU-2026-0123',
        'Persembahan Ibadah Minggu',
        'Rp2.700.000',
        '',
        'Rp9.640.000',
      ]),
      _Baris([
        '25/10/2026',
        'BKU-2026-0125',
        'Titipan untuk: Sinode · Sentralisasi',
        'Rp600.000',
        '',
        'Rp10.240.000',
      ]),
      _Baris([
        '26/10/2026',
        'BKU-2026-0130',
        'Setoran ke bank: ke Bank BNI ··4821',
        '',
        'Rp2.690.000',
        'Rp7.550.000',
      ]),
      _Baris([
        '27/10/2026',
        'BKU-2026-0122',
        'Diakonia sakit',
        '',
        'Rp300.000',
        'Rp7.250.000',
      ]),
      _Baris([
        '30/10/2026',
        'BKU-2026-0127',
        'Pindah antar Kas/Bank: Bank BNI ke Kas',
        'Rp2.000.000',
        '',
        'Rp9.250.000',
      ]),
      _Baris([
        '31/10/2026',
        'BKU-2026-0131',
        'Setoran ke bank: ke Bank BNI ··4821',
        '',
        'Rp500.000',
        'Rp8.750.000',
      ]),
    ],
    kaki: '22 baris Kas · Saldo akhir Kas Rp8.750.000. Buku pembantu juga dibuat per peruntukan, per Lingkup, per Uang Muka dan per Titipan untuk.',
  ),
  'F04': _Lap(
    sub: 'Versi Mata Anggaran 2026.1',
    kolom: [150, null, 250, 130],
    judul: ['No. MA', 'Nama Mata Anggaran', 'Jenis baris', 'Boleh untuk'],
    kanan: [],
    mono: [0],
    baris: [
      _Baris([
        '1.3.53.00.00',
        'PERSEMBAHAN',
        'Judul kelompok, tidak dapat dibukukan',
        '',
      ], true),
      _Baris([
        '1.3.53.07.00',
        'Persembahan Ibadah Minggu',
        'Dapat dibukukan',
        'Milik sendiri',
      ]),
      _Baris([
        '1.3.53.09.00',
        'Persembahan syukur',
        'Dapat dibukukan',
        'Milik sendiri',
      ]),
      _Baris([
        '1.3.55.01.00',
        'Persembahan Diakonia',
        'Dapat dibukukan',
        'Milik sendiri',
      ]),
      _Baris([
        '1.4.10.00.00',
        'SUMBANGAN',
        'Judul kelompok, tidak dapat dibukukan',
        '',
      ], true),
      _Baris([
        '1.4.10.02.00',
        'Sumbangan donatur',
        'Dapat dibukukan',
        'Keduanya',
      ]),
    ],
    kaki: 'Contoh 6 dari 131 baris, sesuai urutan sumber. Nomor dan nama dicetak persis seperti tersimpan.',
  ),
  'F05': _Lap(
    sub: 'Pendapatan menurut Mata Anggaran',
    kolom: [150, null, 170],
    judul: ['No. MA', 'Nama Mata Anggaran', 'Oktober 2026'],
    kanan: [2],
    mono: [0, 2],
    baris: [
      _Baris(['1.3.53.00.00', 'PERSEMBAHAN', 'Rp13.620.000'], true),
      _Baris(['1.3.53.07.00', 'Persembahan Ibadah Minggu', 'Rp10.950.000']),
      _Baris(['1.3.53.09.00', 'Persembahan syukur', 'Rp1.720.000']),
      _Baris(['1.3.55.01.00', 'Persembahan Diakonia', 'Rp950.000']),
      _Baris(['1.4.10.00.00', 'SUMBANGAN', 'Rp1.200.000'], true),
      _Baris(['1.4.10.02.00', 'Sumbangan donatur', 'Rp1.200.000']),
      _Baris(['1.4.10.03.00', 'Sumbangan natura', 'Rp0']),
      _Baris(['', 'Jumlah Pendapatan', 'Rp14.820.000'], true),
    ],
    kaki: 'Contoh 7 dari 131 baris. Baris tanpa transaksi tetap dicetak sebagai Rp0. Tidak ada kolom anggaran, selisih atau persentase.',
  ),
  'F06': _Lap(
    sub: 'Versi Mata Anggaran 2026.1',
    kolom: [150, null, 250, 130],
    judul: ['No. MA', 'Nama Mata Anggaran', 'Jenis baris', 'Boleh untuk'],
    kanan: [],
    mono: [0],
    baris: [
      _Baris([
        '5.00.00.00',
        'BELANJA OPERASIONAL',
        'Judul kelompok, tidak dapat dibukukan',
        '',
      ], true),
      _Baris([
        '5.01.02.00',
        'Listrik, air dan telepon',
        'Dapat dibukukan',
        'Milik sendiri',
      ]),
      _Baris([
        '5.02.01.00',
        'Alat tulis dan fotokopi',
        'Dapat dibukukan',
        'Milik sendiri',
      ]),
      _Baris([
        '5.03.03.00',
        'Biaya administrasi bank',
        'Dapat dibukukan',
        'Milik sendiri',
      ]),
      _Baris([
        '4.00.00.00',
        'BELANJA PELAYANAN',
        'Judul kelompok, tidak dapat dibukukan',
        '',
      ], true),
      _Baris([
        '4.03.03.00',
        'Diakonia duka',
        'Dapat dibukukan',
        'Milik sendiri',
      ]),
    ],
    kaki: 'Contoh 6 dari 158 baris, sesuai urutan sumber.',
  ),
  'F07': _Lap(
    sub: 'Belanja menurut Mata Anggaran',
    kolom: [150, null, 170],
    judul: ['No. MA', 'Nama Mata Anggaran', 'Oktober 2026'],
    kanan: [2],
    mono: [0, 2],
    baris: [
      _Baris(['5.00.00.00', 'BELANJA OPERASIONAL', 'Rp11.155.000'], true),
      _Baris(['5.01.02.00', 'Listrik, air dan telepon', 'Rp1.000.000']),
      _Baris(['5.02.01.00', 'Alat tulis dan fotokopi', 'Rp250.000']),
      _Baris(['5.03.03.00', 'Biaya administrasi bank', 'Rp15.000']),
      _Baris(['5.04.01.00', 'Konsumsi rapat', 'Rp750.000']),
      _Baris(['5.05.02.00', 'Sewa peralatan', 'Rp0']),
      _Baris(['5.07.01.00', 'Honorarium pelayan', 'Rp3.640.000']),
      _Baris(['5.08.02.00', 'Pemeliharaan gedung', 'Rp5.500.000']),
      _Baris(['4.00.00.00', 'BELANJA PELAYANAN', 'Rp300.000'], true),
      _Baris(['4.03.04.00', 'Diakonia sakit', 'Rp300.000']),
      _Baris(['', 'Jumlah Belanja', 'Rp11.455.000'], true),
    ],
    kaki: 'Contoh 9 dari 158 baris. Alat tulis dan fotokopi sudah memuat pembalikan BKU-2026-0109; koreksinya masuk ke Konsumsi rapat. Tidak ada kolom anggaran.',
  ),
  'F08': _Lap(
    sub: 'Penerimaan buku per Kas/Bank',
    kolom: [null, 112, 112, 140, 112, 124],
    judul: [
      'Kas/Bank',
      'Pendapatan',
      'Titipan masuk',
      'Pengembalian sisa uang muka',
      'Pindah masuk',
      'Jumlah penerimaan',
    ],
    kanan: [1, 2, 3, 4, 5],
    mono: [1, 2, 3, 4, 5],
    baris: [
      _Baris([
        'Kas',
        'Rp12.170.000',
        'Rp2.400.000',
        'Rp350.000',
        'Rp2.000.000',
        'Rp16.920.000',
      ]),
      _Baris([
        'Bank BNI ··4821',
        'Rp2.650.000',
        'Rp0',
        'Rp0',
        'Rp8.190.000',
        'Rp10.840.000',
      ]),
      _Baris([
        'Bank SulutGo ··1107',
        'Rp0',
        'Rp0',
        'Rp0',
        'Rp1.500.000',
        'Rp1.500.000',
      ]),
      _Baris([
        'Jumlah',
        'Rp14.820.000',
        'Rp2.400.000',
        'Rp350.000',
        'Rp11.690.000',
        'Rp29.260.000',
      ], true),
    ],
    kaki: 'Penerimaan bukan Pendapatan: kolom Pindah masuk, Titipan masuk dan Pengembalian sisa uang muka tidak pernah dijumlahkan ke Pendapatan.',
  ),
  'F09': _Lap(
    sub: 'Pengeluaran buku per Kas/Bank',
    kolom: [null, 112, 124, 124, 112, 124],
    judul: [
      'Kas/Bank',
      'Belanja',
      'Titipan disalurkan',
      'Uang Muka diberikan',
      'Pindah keluar',
      'Jumlah pengeluaran',
    ],
    kanan: [1, 2, 3, 4, 5],
    mono: [1, 2, 3, 4, 5],
    baris: [
      _Baris([
        'Kas',
        'Rp1.050.000',
        'Rp0',
        'Rp1.500.000',
        'Rp9.690.000',
        'Rp12.240.000',
      ]),
      _Baris([
        'Bank BNI ··4821',
        'Rp10.405.000',
        'Rp2.400.000',
        'Rp0',
        'Rp2.000.000',
        'Rp14.805.000',
      ]),
      _Baris(['Bank SulutGo ··1107', 'Rp0', 'Rp0', 'Rp0', 'Rp0', 'Rp0']),
      _Baris([
        'Jumlah',
        'Rp11.455.000',
        'Rp2.400.000',
        'Rp1.500.000',
        'Rp11.690.000',
        'Rp27.045.000',
      ], true),
    ],
    kaki: 'Belanja dari pertanggungjawaban uang muka dicetak di baris tersendiri dan tidak mengurangi Kas/Bank lagi: Rp0 pada Oktober 2026.',
  ),
  'F10': _Lap(
    sub: 'Per 31 Oktober 2026',
    kolom: [null, 140, 140, 160, 170],
    judul: [
      'Kas/Bank',
      'Saldo buku',
      'Hasil hitung kas',
      'Saldo rekening koran',
      'Selisih belum dijelaskan',
    ],
    kanan: [1, 2, 3, 4],
    mono: [1, 2, 3, 4],
    baris: [
      _Baris(['Kas', 'Rp8.750.000', 'Rp8.750.000', '', 'Rp0']),
      _Baris(['Bank BNI ··4821', 'Rp24.600.000', '', 'Rp24.100.000', 'Rp0']),
      _Baris(['Bank SulutGo ··1107', 'Rp5.115.000', '', 'Rp5.115.000', 'Rp0']),
    ],
    kaki: 'Hasil hitung kas dan saldo rekening koran berada di kolom terpisah dan tidak dijumlahkan. Bank BNI: setoran dalam perjalanan Rp500.000 dijelaskan di F11.',
  ),
  'F11': _Lap(
    sub: 'Per Kas/Bank',
    kolom: [null, 140, 150, 160],
    judul: ['Baris', 'Kas', 'Bank BNI ··4821', 'Bank SulutGo ··1107'],
    kanan: [1, 2, 3],
    mono: [1, 2, 3],
    baris: [
      _Baris([
        'Hasil hitung kas / Saldo rekening koran',
        'Rp8.750.000',
        'Rp24.100.000',
        'Rp5.115.000',
      ]),
      _Baris(['Setoran dalam perjalanan', 'Rp0', 'Rp500.000', 'Rp0']),
      _Baris(['Pembayaran dalam perjalanan', 'Rp0', 'Rp0', 'Rp0']),
      _Baris([
        'Saldo pembanding',
        'Rp8.750.000',
        'Rp24.600.000',
        'Rp5.115.000',
      ], true),
      _Baris([
        'Saldo buku',
        'Rp8.750.000',
        'Rp24.600.000',
        'Rp5.115.000',
      ], true),
      _Baris(['Selisih belum dijelaskan', 'Rp0', 'Rp0', 'Rp0'], true),
      _Baris(['Mutasi bank cocok / belum cocok', '', '13 / 0', '1 / 0']),
      _Baris([
        'Status',
        'Sudah dipastikan',
        'Sudah dipastikan',
        'Sudah dipastikan',
      ]),
    ],
    kaki: 'Item dalam perjalanan dibawa ke November 2026 dan dicetak lagi di laporan bulan itu sampai cocok.',
  ),
  'F12': _Lap(
    sub: 'No. Bukti Oktober 2026',
    kolom: [104, 78, null, 104, 150, 160],
    judul: [
      'No. Bukti',
      'Tanggal',
      'Uraian',
      'Jumlah (Rp)',
      'Persetujuan',
      'Dokumen pendukung saat tutup buku',
    ],
    kanan: [3],
    mono: [0, 3],
    baris: [
      _Baris([
        'BKU-2026-0098',
        '04/10/2026',
        'Persembahan Ibadah Minggu dan Diakonia',
        'Rp4.150.000',
        'Tidak diperlukan',
        'Terverifikasi',
      ]),
      _Baris([
        'BKU-2026-0101',
        '06/10/2026',
        'Toko Sinar: listrik dan alat tulis',
        '${_m}Rp1.250.000',
        'Tidak diperlukan',
        'Terverifikasi',
      ]),
      _Baris([
        'BKU-2026-0105',
        '09/10/2026',
        'Konsumsi rapat majelis · Dibalik oleh BKU-2026-0109',
        '${_m}Rp750.000',
        'Tidak diperlukan',
        'Terverifikasi',
      ]),
      _Baris([
        'BKU-2026-0109',
        '12/10/2026',
        'Pembalikan BKU-2026-0105',
        'Rp750.000',
        'Tidak diperlukan',
        'Tidak diperlukan',
      ]),
      _Baris([
        'BKU-2026-0116',
        '22/10/2026',
        'Pemeliharaan atap gedung',
        '${_m}Rp5.500.000',
        'Sudah dicatat · Ketua BPMJ',
        'Dikecualikan · kuitansi menyusul',
      ]),
    ],
    kaki: 'Contoh 5 dari 33 baris. Kolom dokumen pendukung mencetak status saat tutup buku; dokumen susulan tidak mengubah halaman ini.',
  ),
  'F13': _Lap(
    sub: 'Titipan per pihak, lalu Sentralisasi dari uang milik sendiri',
    kolom: [null, 130, 130, 130, 170],
    judul: [
      'Titipan untuk',
      'Sisa awal',
      'Terkumpul',
      'Disalurkan',
      'Sisa belum disalurkan',
    ],
    kanan: [1, 2, 3, 4],
    mono: [1, 2, 3, 4],
    baris: [
      _Baris(['Sinode', 'Rp0', 'Rp2.400.000', 'Rp2.400.000', 'Rp0']),
      _Baris(['Wilayah', 'Rp0', 'Rp0', 'Rp0', 'Rp0']),
      _Baris([
        'Jumlah titipan',
        'Rp0',
        'Rp2.400.000',
        'Rp2.400.000',
        'Rp0',
      ], true),
      _Baris([
        'Sentralisasi dari uang milik sendiri (Belanja, bukan titipan)',
        '',
        '',
        'Rp0',
        '',
      ]),
    ],
    kaki: 'Judul “Sentralisasi / Penyaluran” menggantikan judul sumber “Sentralisasi / Settlement”.',
  ),
  'F14': _Lap(
    sub: 'Delapan lampiran',
    kolom: [40, null, 260],
    judul: ['', 'Lampiran', 'Isi pada Oktober 2026'],
    kanan: [],
    mono: [0],
    baris: [
      _Baris(['1', 'Uang Muka', '3 kasus']),
      _Baris(['2', 'Rincian Pertanggungjawaban Uang Muka', 'Nihil']),
      _Baris(['3', 'Penghitungan Persembahan', '4 ibadah']),
      _Baris(['4', 'Penggantian Biaya', 'Nihil']),
      _Baris(['5', 'Pengecualian Dokumen Pendukung', '1 dokumen']),
      _Baris(['6', 'Pembalikan dan Koreksi', '1 rangkaian']),
      _Baris(['7', 'Saldo Awal Pencatatan', 'Nihil']),
      _Baris(['8', 'Hasil Pengecekan Otomatis', '8 syarat terpenuhi']),
    ],
    kaki: 'Lampiran tanpa isi dicetak sebagai “Nihil”, bukan halaman kosong.',
  ),
};

/// The TERBATAS versions (F03, F05, F07, F12); every other report shows the
/// dashed box in the TERBATAS copy.
const _lapTerbatas = <String, _Lap>{
  'F03': _Lap(
    sub: 'Buku per peruntukan · Diakonia · TERBATAS',
    kolom: [84, 118, 130, 120, 120, 130],
    judul: [
      'Tanggal',
      'No. Bukti',
      'No. MA',
      'Penerimaan',
      'Pengeluaran',
      'Saldo Diakonia',
    ],
    kanan: [3, 4, 5],
    mono: [1, 2, 3, 4, 5],
    baris: [
      _Baris(['', '', '', '', '', 'Rp3.050.000'], true),
      _Baris([
        '04/10/2026',
        'BKU-2026-0098',
        '1.3.55.01.00',
        'Rp950.000',
        '',
        'Rp4.000.000',
      ]),
      _Baris([
        '27/10/2026',
        'BKU-2026-0122',
        '4.03.04.00',
        '',
        'Rp300.000',
        'Rp3.700.000',
      ]),
    ],
    kaki: '2 baris. Uraian, pelaku dan bagian peruntukan lain tidak dicetak di salinan ini.',
  ),
  'F05': _Lap(
    sub: 'Pendapatan peruntukan Diakonia · TERBATAS',
    kolom: [150, null, 170],
    judul: ['No. MA', 'Nama Mata Anggaran', 'Oktober 2026'],
    kanan: [2],
    mono: [0, 2],
    baris: [
      _Baris(['1.3.55.01.00', 'Persembahan Diakonia', 'Rp950.000']),
      _Baris(['', 'Jumlah Pendapatan peruntukan Diakonia', 'Rp950.000'], true),
    ],
    kaki: 'Hanya baris yang punya bagian Diakonia. Baris peruntukan lain tidak dicetak, juga tidak sebagai Rp0.',
  ),
  'F07': _Lap(
    sub: 'Belanja peruntukan Diakonia · TERBATAS',
    kolom: [150, null, 170],
    judul: ['No. MA', 'Nama Mata Anggaran', 'Oktober 2026'],
    kanan: [2],
    mono: [0, 2],
    baris: [
      _Baris(['4.03.03.00', 'Diakonia duka', 'Rp0']),
      _Baris(['4.03.04.00', 'Diakonia sakit', 'Rp300.000']),
      _Baris(['', 'Jumlah Belanja peruntukan Diakonia', 'Rp300.000'], true),
    ],
    kaki: 'Hanya baris yang boleh dipakai peruntukan Diakonia.',
  ),
  'F12': _Lap(
    sub: 'No. Bukti dengan bagian Diakonia · TERBATAS',
    kolom: [130, 100, 160, null],
    judul: [
      'No. Bukti',
      'Tanggal',
      'Bagian Diakonia',
      'Dokumen pendukung saat tutup buku',
    ],
    kanan: [2],
    mono: [0, 2],
    baris: [
      _Baris(['BKU-2026-0098', '04/10/2026', 'Rp950.000', 'Terverifikasi']),
      _Baris([
        'BKU-2026-0122',
        '27/10/2026',
        '${_m}Rp300.000',
        'Terverifikasi',
      ]),
    ],
    kaki: 'Status dokumen dicetak; file aslinya, jumlah seluruh transaksi dan nama pemberi persetujuan tidak disertakan.',
  ),
};
