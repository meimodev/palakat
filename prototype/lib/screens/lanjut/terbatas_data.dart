import '../../providers/keuangan/laporan.dart';

export '../../providers/keuangan/laporan.dart' show BarisTerbatas, Terbatas;

/// Board `rows` filter over the viewer's Fund rows (`terbatasProvider`):
/// trimmed, lower-cased [cari] found in [kunci] of a row.
List<BarisTerbatas> saringTerbatas(
  List<BarisTerbatas> baris,
  String cari,
  String Function(BarisTerbatas) kunci,
) {
  final q = cari.trim().toLowerCase();
  return [
    for (final r in baris)
      if (q.isEmpty || kunci(r).toLowerCase().contains(q)) r,
  ];
}

const tidakTerbatas = [
  'Jumlah seluruh transaksi pada No. Bukti ini',
  'Bagian peruntukan lain',
  'Uraian dan catatan',
  'Nama pencatat dan pemberi persetujuan',
  'Dokumen pendukung asli',
];
