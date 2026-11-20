import 'package:flutter/material.dart';

import '../../domain/finance/finance.dart';
import '../../providers/keuangan/akhir_bulan.dart';
import '../../providers/keuangan/laporan.dart';
import '../../shell/halaman_a4.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/tekan.dart';

/// The report document views (README 7.1 rule 5): the header lines every
/// A4 page of a month's report prints, and a paginated page frame.

/// 'F01 · LAPORAN RESMI', or the provisional label before the close.
String kodeA4(LaporanBulan l, String form) =>
    '$form · ${l.resmi ? 'LAPORAN RESMI' : 'LAPORAN SEMENTARA · BUKAN LAPORAN RESMI'}';

/// 'Jemaat Karunia · Periode laporan {rentang}' plus [ekor].
String subjudulA4(LaporanBulan l, [String? ekor]) =>
    'Jemaat Karunia · Periode laporan ${rentangPeriode(l.periode)}'
    '${ekor == null ? '' : ' · $ekor'}';

/// The mono lines at the right of the header.
List<String> kananA4(LaporanBulan l) => [
  if (l.resmi) ...[
    'ID ${l.snapshot!.id}',
    'Dibekukan ${dibekukan(l.snapshot!)}',
  ] else
    'Belum punya ID laporan resmi',
  'Versi Mata Anggaran ${l.data(ReportForm.f05).totals['versionCode'] ?? ''}',
];

/// One block of a page and the rows it takes.
typedef BlokA4 = ({int berat, Widget isi});

/// Splits [blok] into pages of at most [muat] rows (a block never splits).
List<List<Widget>> bagiHalaman(List<BlokA4> blok, int muat) {
  final hal = <List<Widget>>[[]];
  var isi = 0;
  for (final b in blok) {
    if (isi > 0 && isi + b.berat > muat) {
      hal.add([]);
      isi = 0;
    }
    hal.last.add(b.isi);
    isi += b.berat;
  }
  return hal;
}

/// A document of several A4 pages, one shown at a time with a page bar
/// above it ("Halaman sebelumnya", "Halaman berikutnya").
class HalamanA4Bertingkat extends StatefulWidget {
  const HalamanA4Bertingkat({
    super.key,
    required this.ukuran,
    required this.form,
    required this.kode,
    required this.judul,
    required this.subjudul,
    required this.kanan,
    required this.halaman,
  });

  final Size ukuran;

  /// 'F02', for the footer 'F02 · halaman 1 dari 3'.
  final String form;
  final String kode, judul, subjudul;
  final List<String> kanan;
  final List<List<Widget>> halaman;

  @override
  State<HalamanA4Bertingkat> createState() => _HalamanA4BertingkatState();
}

class _HalamanA4BertingkatState extends State<HalamanA4Bertingkat> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final n = widget.halaman.length;
    final i = _i.clamp(0, n - 1);
    final halaman = HalamanA4(
      key: ValueKey(i),
      ukuran: widget.ukuran,
      kode: widget.kode,
      judul: widget.judul,
      subjudul: widget.subjudul,
      kanan: widget.kanan,
      kakiKanan: '${widget.form} · halaman ${i + 1} dari $n',
      isi: widget.halaman[i],
    );
    if (n == 1) return halaman;
    final c = context.warna;
    Widget tombol(String t, int ke) => Tekan(
      onTap: ke < 0 || ke >= n ? null : () => setState(() => _i = ke),
      radius: 10,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        child: Text(
          t,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ke < 0 || ke >= n ? c.tinta3 : c.laut,
          ),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ColoredBox(
          color: c.permukaan,
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              tombol('Halaman sebelumnya', i - 1),
              Text(
                'Halaman ${i + 1} dari $n',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
              tombol('Halaman berikutnya', i + 1),
            ],
          ),
        ),
        Expanded(child: halaman),
      ],
    );
  }
}
