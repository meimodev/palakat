// Dataset reader of WebExcel: one sheet per form of the report pack, built
// from `tabelLaporan` (README 7.1 rule 5).

import '../../domain/finance/finance.dart';
import '../../providers/keuangan/laporan.dart';
import 'laporan_tabel.dart';

/// One sheet of the report-pack workbook. [lebar]: grid widths in px, null
/// for the `minmax(0, 1fr)` column. [sub] and [kaki] are not shown.
typedef LembarExcel = ({
  String kode,
  String nama,
  String sub,
  List<double?> lebar,
  List<String> kolom,
  List<int> kanan,
  List<({List<String> sel, bool tebal})> baris,
  String kaki,
});

/// The sheets of [l]'s report pack, F01 to F14.
List<LembarExcel> lembarExcel(LaporanBulan l) => [
  for (final (kode, nama) in laporanDaftar)
    () {
      final t = tabelLaporan(l, formLaporan(kode));
      return (
        kode: kode,
        nama: nama,
        sub: t.sub,
        lebar: lebarKolom(t),
        kolom: t.cols,
        kanan: t.kanan,
        baris: [
          for (final r in t.rows) (sel: selBaris(r), tebal: r.last is int),
        ],
        kaki: t.kaki,
      );
    }(),
];

/// The workbook's file name: 'Paket-Laporan-GMIM_Jemaat-Karunia_{yyyy-mm}'.
String namaFileExcel(Period p) =>
    'Paket-Laporan-GMIM_Jemaat-Karunia_${p.id}.xlsx';
