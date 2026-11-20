import 'dart:math' as math;

import 'package:flutter/rendering.dart' show OverflowBoxFit;
import 'package:flutter/widgets.dart';

import '../../domain/core/core.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';

/// A command's refusal as the boards draw it: "Tidak dapat dilakukan:
/// {action}." then the reason and who can act.
Widget penolakanDari(Refusal r) => Penolakan(
  tindakan: r.action,
  sebab: r.whoCanAct == null
      ? r.because
      : '${r.because} Yang perlu bertindak: ${r.whoCanAct}.',
  jalan: const [],
  ukuranTeks: 14,
);

/// Fact card: `Kartu` (dibukukan), content in a column with gap 6.
class KartuFakta extends StatelessWidget {
  const KartuFakta({super.key, required this.anak});

  final List<Widget> anak;

  @override
  Widget build(BuildContext context) => Kartu(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: anak,
    ),
  );
}

/// Card head row with a badge. When the badge and the title's longest word do
/// not fit side by side, the board wins over spec 22 "Chip overflow": the
/// badge stays beside a one-word-wide title and overflows the card.
class KepalaLencana extends StatelessWidget {
  const KepalaLencana(
    this.judul,
    this.label, {
    super.key,
    required this.bentuk,
  });

  final String judul;
  final String label;
  final BentukLencana bentuk;

  @override
  Widget build(BuildContext context) {
    final lencana = LencanaStatus(label, bentuk: bentuk);
    final gaya = DefaultTextStyle.of(context).style
        .copyWith(fontWeight: FontWeight.w700);
    double lebar(String t, TextStyle s) => _lebar(context, t, s);

    return LayoutBuilder(
      builder: (context, ruang) {
        final kata = judul
            .split(' ')
            .map((w) => lebar(w, gaya))
            .reduce(math.max);
        // Badge: 13/700 text, padding 9 and a 1.5 line on each side.
        final chip = lebar(label, gaya.copyWith(fontSize: 13)) + 21;
        if (kata + 16 + chip <= ruang.maxWidth) {
          return KepalaKartu(judul: judul, ujung: lencana);
        }
        // As the board's flex row: the title shrinks to its longest word and
        // the `flex: none` badge keeps its width, running past the card edge.
        return Row(
          children: [
            SizedBox(
              width: kata.ceilToDouble(),
              child: Text(judul, style: gaya),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OverflowBox(
                alignment: AlignmentDirectional.centerStart,
                maxWidth: double.infinity,
                fit: OverflowBoxFit.deferToChild,
                child: lencana,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Caption 13 `tinta3`.
class Keterangan extends StatelessWidget {
  const Keterangan(this.teks, {super.key});
  final String teks;

  @override
  Widget build(BuildContext context) =>
      Text(teks, style: TextStyle(fontSize: 13, color: context.warna.tinta3));
}

/// Plain line 14 `tinta2`.
class BarisPolos extends StatelessWidget {
  const BarisPolos(this.teks, {super.key});
  final String teks;

  @override
  Widget build(BuildContext context) =>
      Text(teks, style: TextStyle(fontSize: 14, color: context.warna.tinta2));
}

/// Dashed note (draf, padding 12 14) or terpilih note (radius 12): one 14 px
/// paragraph, a bold `tinta` lead, a space, then [sisa] (`tinta2` when [redup]).
class Catatan extends StatelessWidget {
  const Catatan({
    super.key,
    required this.status,
    required this.tebal,
    required this.sisa,
    this.redup = false,
  });

  final GarisStatus status;
  final String tebal, sisa;
  final bool redup;

  @override
  Widget build(BuildContext context) => Kartu(
    status: status,
    radius: status == GarisStatus.terpilih ? 12 : 14,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: tebal,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: ' $sisa',
            style: TextStyle(color: redup ? context.warna.tinta2 : null),
          ),
        ],
      ),
      style: TextStyle(fontSize: 14, color: context.warna.tinta),
    ),
  );
}

/// Single-line width of [t] in [s].
double _lebar(BuildContext context, String t, TextStyle s) {
  final p = TextPainter(
    text: TextSpan(text: t, style: s),
    textDirection: TextDirection.ltr,
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();
  final w = p.width;
  p.dispose();
  return w;
}

/// Fact row as the board's flex row: label 14 `tinta2`, gap 16, value
/// right-aligned [berat] `tinta` ([mono] money). Unlike `BarisInfo`, the label
/// shrinks too: when both do not fit on one line each gives up width in
/// proportion to its own (CSS `flex-shrink: 1`), so a long label wraps.
class BarisFakta extends StatelessWidget {
  const BarisFakta(
    this.label,
    this.nilai, {
    super.key,
    this.mono = false,
    this.berat = FontWeight.w600,
  });

  final String label, nilai;
  final bool mono;
  final FontWeight berat;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final dasar = DefaultTextStyle.of(context).style.copyWith(fontSize: 14);
    final gayaLabel = dasar.copyWith(color: c.tinta2);
    final gayaNilai = dasar.copyWith(
      color: c.tinta,
      fontWeight: berat,
      fontFamily: mono ? PalakatText.mono : null,
    );
    return LayoutBuilder(
      builder: (context, ruang) {
        final wl = _lebar(context, label, gayaLabel);
        final wn = _lebar(context, nilai, gayaNilai);
        final ada = ruang.maxWidth - 16;
        final lebih = math.max(0.0, wl + wn - ada);
        // Neither shrinks below its longest word (CSS `min-width: auto`).
        double kata(String t, TextStyle s) =>
            t.split(' ').map((w) => _lebar(context, w, s)).reduce(math.max);
        final l0 = wl - lebih * wl / (wl + wn);
        final l = math.min(
          ada,
          math.max(
            kata(label, gayaLabel),
            math.min(l0, ada - kata(nilai, gayaNilai)),
          ),
        );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: l,
              child: Text(label, style: gayaLabel),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(nilai, textAlign: TextAlign.right, style: gayaNilai),
            ),
          ],
        );
      },
    );
  }
}
