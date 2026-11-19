import 'package:flutter/widgets.dart';

import '../../theme/palakat_tema.dart';
import '../../widgets/lencana_status.dart';

/// KitAlur info row as the board's CSS lays it out: both spans shrink in
/// proportion to their width (`flex: 0 1 auto`), so a long value makes the
/// label wrap too ("Diajukan / oleh"), where `BarisInfo` keeps the label whole.
class BarisInfoDana extends StatelessWidget {
  const BarisInfoDana(this.label, this.nilai, {super.key, this.mono = false});

  final String label, nilai;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final dasar = DefaultTextStyle.of(context).style
        .merge(const TextStyle(fontSize: 14));
    final gl = dasar.copyWith(color: c.tinta2);
    final gn = dasar.copyWith(
      color: c.tinta,
      fontWeight: FontWeight.w600,
      fontFamily: mono ? PalakatText.mono : null,
    );
    return LayoutBuilder(
      builder: (context, ruang) {
        final skala = MediaQuery.textScalerOf(context);
        TextPainter ukur(String t, TextStyle g) => TextPainter(
          text: TextSpan(text: t, style: g),
          textDirection: TextDirection.ltr,
          textScaler: skala,
        )..layout();
        final pl = ukur(label, gl), pn = ukur(nilai, gn);
        final (wl, wn, minL) = (pl.width, pn.width, pl.minIntrinsicWidth);
        pl.dispose();
        pn.dispose();
        final lebih = wl + 16 + wn - ruang.maxWidth;
        final lebarL = lebih <= 0
            ? wl
            : (wl - lebih * wl / (wl + wn)).clamp(minL, wl);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: lebarL.ceilToDouble(),
              child: Text(label, style: gl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(nilai, textAlign: TextAlign.right, style: gn),
            ),
          ],
        );
      },
    );
  }
}

/// Card head row (KitAlur `KepalaKartu`) that drops the badge under the title
/// when the badge and the title's longest word do not fit side by side: the
/// 275 px "Disetujui oleh Pdt. Lidya Rondonuwu" badge overflows the board's
/// 316 px head row (spec 23, AlurDana Notes). Otherwise as `KepalaKartu`.
class KepalaLencanaDana extends StatelessWidget {
  const KepalaLencanaDana({
    super.key,
    required this.judul,
    required this.label,
    required this.bentuk,
  });

  final String judul, label;
  final BentukLencana bentuk;

  double _lebar(TextSpan s, TextScaler skala, {bool kata = false}) {
    final p = TextPainter(
      text: s,
      textDirection: TextDirection.ltr,
      textScaler: skala,
    )..layout();
    final w = kata ? p.minIntrinsicWidth : p.width;
    p.dispose();
    return w;
  }

  @override
  Widget build(BuildContext context) {
    final dasar = DefaultTextStyle.of(context).style;
    final gayaJudul = dasar.merge(const TextStyle(fontWeight: FontWeight.w700));
    final teks = Text(judul, style: gayaJudul);
    final lencana = LencanaStatus(label, bentuk: bentuk);
    return LayoutBuilder(
      builder: (context, ruang) {
        final skala = MediaQuery.textScalerOf(context);
        final kata = _lebar(
          TextSpan(text: judul, style: gayaJudul),
          skala,
          kata: true,
        );
        // LencanaStatus: padding 3 9 inside a 1.5 line.
        final badge =
            _lebar(
              TextSpan(
                text: label,
                style: dasar.merge(
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              skala,
            ) +
            21;
        if (kata + 16 + badge <= ruang.maxWidth) {
          return Row(
            children: [
              Expanded(child: teks),
              const SizedBox(width: 16),
              lencana,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [teks, lencana],
        );
      },
    );
  }
}
