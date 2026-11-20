part of 'web_paket_laporan.dart';

// Dataset reader of WebPaketLaporan: the report list, and each form as a
// table from `tabelLaporan` (README 7.1 rule 5). Nothing is drawn literally.

/// Report list: code, name, "Format bawaan aplikasi. …" description.
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

/// One row of a report table; [tebal] = 700 with a `tinta` line.
class _Baris {
  const _Baris(this.sel, [this.tebal = false]);
  final List<String> sel;
  final bool tebal;
}

/// A report table. [kolom]: px widths, null = `minmax(0, 1fr)`.
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

/// [form] of [l] as a [_Lap].
_Lap _lapDari(LaporanBulan l, ReportForm form) {
  final t = tabelLaporan(l, form);
  return _Lap(
    sub: t.sub,
    kolom: lebarKolom(t),
    judul: t.cols,
    kanan: t.kanan,
    mono: [
      for (var i = 0; i < t.cols.length; i++)
        if (t.kanan.contains(i) || kolomMono.contains(t.cols[i])) i,
    ],
    baris: [for (final r in t.rows) _Baris(selBaris(r), r.last is int)],
    kaki: t.kaki,
  );
}
