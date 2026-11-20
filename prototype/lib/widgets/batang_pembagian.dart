import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../core/format.dart';
import '../theme/palakat_tema.dart';
import 'garis.dart';

class BagianBatang {
  const BagianBatang(this.jumlah, this.warna);
  final int jumlah;
  final Color warna;
}

/// The division bar: segments left to right, each `jumlah / max(total, Σ)`
/// of the inner width, animated; the unfilled rest shows the dashed line.
class BatangPembagian extends StatelessWidget {
  const BatangPembagian({
    super.key,
    required this.total,
    required this.bagian,
    this.tinggi = 18,
    this.garisPutus = true,
    this.durasi = const Duration(milliseconds: 450),
  });

  final int total;
  final List<BagianBatang> bagian;

  /// 18 (Awal, Bagi, AlihPeruntukan), 14 (Kewajiban detail), 8 (KartuKasus).
  final double tinggi;

  /// false on AlihPeruntukan: the parts fill the whole bar.
  final bool garisPutus;

  /// 450 ms (Awal, Bagi), 500 ms (AlihPeruntukan, Kewajiban).
  final Duration durasi;

  /// Segment colours in order (Bagi `C`).
  static List<Color> warnaBagian(PalakatWarna c) => [
    c.tinta,
    c.laut,
    PalakatIlustrasi.peruntukanKetiga,
    c.tinta2,
    c.garisTegas,
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final jumlah = bagian.fold(0, (s, b) => s + b.jumlah);
    final bagi = math.max(total, jumlah);
    final r = tinggi / 2;
    final garis = garisPutus ? GarisBorder.putus(c.putus, radius: r) : null;
    final lama = context.gerak(durasi);
    return Container(
      height: tinggi,
      decoration: garis == null ? null : ShapeDecoration(shape: garis),
      child: ClipRRect(
        // overflow: hidden clips to the padding box, inside the line.
        borderRadius: BorderRadius.circular(
          math.max(0, r - (garis?.tebal ?? 0)),
        ),
        child: LayoutBuilder(
          builder: (context, k) => Row(
            children: [
              for (final b in bagian)
                AnimatedContainer(
                  duration: lama,
                  curve: PalakatMotion.keluar,
                  width: bagi <= 0
                      ? 0
                      : k.maxWidth * (b.jumlah / bagi).clamp(0.0, 1.0),
                  color: b.warna,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The line under the bar: label 14/700 and amount mono 18/600, `bata` while
/// a remainder or an excess exists, `laut` when it adds up. Gap 8 above is the screen's.
class SisaPembagian extends StatelessWidget {
  const SisaPembagian({
    super.key,
    required this.label,
    required this.jumlah,
    required this.pas,
  });

  /// Screen copy: 'Sisa belum dibagi', 'Total baris sama dengan Jumlah' …
  final String label;

  /// Shown as `rp(jumlah)`; Bagi passes the absolute remainder.
  final int jumlah;
  final bool pas;

  @override
  Widget build(BuildContext context) {
    final warna = pas ? context.warna.laut : context.warna.bata;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: warna,
            ),
          ),
        ),
        Text(
          rp(jumlah),
          style: TextStyle(
            fontFamily: PalakatText.mono,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: warna,
          ),
        ),
      ],
    );
  }
}
