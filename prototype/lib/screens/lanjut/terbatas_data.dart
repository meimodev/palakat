import '../../mock/mock.dart';

/// Board `D` of Terbatas and WebTerbatas: the mock rows plus the full Mata
/// Anggaran name the mock does not carry.
typedef BarisTerbatas = ({
  String no,
  String tgl,
  String ma,
  String maPenuh,
  int jm,
});

const _maPenuh = {
  'BKU-2026-0141': 'Belanja 4.03.03.00 Diakonia duka',
  'BKU-2026-0135': 'Pendapatan 1.3.55.01.00 Persembahan Diakonia',
  'BKU-2026-0122': 'Belanja 4.03.04.00 Diakonia sakit',
  'BKU-2026-0098': 'Pendapatan 1.3.55.01.00 Persembahan Diakonia',
};

final List<BarisTerbatas> dataTerbatas = [
  for (final b in terbatasBaris)
    (no: b.$1, tgl: b.$2, ma: b.$3, maPenuh: _maPenuh[b.$1]!, jm: b.$4),
];

/// Board `rows` filter: trimmed, lower-cased [cari] found in [kunci] of a row.
List<BarisTerbatas> saringTerbatas(
  String cari,
  String Function(BarisTerbatas) kunci,
) {
  final q = cari.trim().toLowerCase();
  return [
    for (final r in dataTerbatas)
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
