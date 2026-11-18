import 'package:flutter/widgets.dart';

import '../theme/palakat_tema.dart';
import 'garis.dart';

enum JenisPita { peran, kunci, belumPasti }

/// The banner that names the user's role ([JenisPita.peran], 1.5 solid
/// `tinta`), a locking state ([JenisPita.kunci], `tinta` field) or something
/// not yet decided ([JenisPita.belumPasti], 1.5 dashed `putus`).
class PitaPeran extends StatelessWidget {
  const PitaPeran({
    super.key,
    required this.jenis,
    required this.judul,
    this.kalimat,
    this.radius,
    this.padding,
    this.ukuranJudul,
    this.jarak = 6,
    this.anak = const [],
    this.sebaris = false,
  });

  final JenisPita jenis;
  final String judul;
  final String? kalimat;

  /// Default: peran 12, kunci 14, belumPasti 14. Bendahara, WebPengaturan: 16.
  final double? radius;

  /// Default: peran 10 14, kunci 12 14, belumPasti 10 14.
  /// Web peran 12 16; Bendahara 18; WebPengaturan, WebSerahTerima 18 20.
  final EdgeInsetsGeometry? padding;

  /// kunci title size: null = inherited 700 (preview); 19 on Bendahara,
  /// WebPengaturan, WebSerahTerima.
  final double? ukuranJudul;

  /// kunci: column gap between title, sentence and [anak] (6; Bendahara 8).
  final double jarak;

  /// kunci: further paragraphs after the sentence (14 `diTinta`), e.g.
  /// "Yang perlu bertindak: …" with a `permukaan` bold run or a link.
  final List<Widget> anak;

  /// peran on web (WebTerbatas): title and sentence on one wrapping row,
  /// gap 4 16.
  final bool sebaris;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    const tebal = TextStyle(fontWeight: FontWeight.w700);
    final Widget isi;
    final ShapeBorder garis;
    final EdgeInsetsGeometry pad;
    Color? latar;

    switch (jenis) {
      case JenisPita.peran:
        final r = radius ?? 12;
        garis = GarisBorder.penuh(c.tinta, radius: r);
        pad =
            padding ??
            (sebaris
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                : const EdgeInsets.symmetric(horizontal: 14, vertical: 10));
        final kepala = Text(judul, style: tebal);
        final sub = kalimat == null
            ? null
            : Text(kalimat!, style: TextStyle(fontSize: 14, color: c.tinta2));
        isi = sub == null
            ? kepala
            : sebaris
            ? Wrap(
                spacing: 16,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [kepala, sub],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [kepala, sub],
              );
      case JenisPita.kunci:
        latar = c.tinta;
        garis = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? 14),
        );
        pad =
            padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 12);
        final bagian = <Widget>[
          Text(
            judul,
            style: tebal.copyWith(fontSize: ukuranJudul, color: c.permukaan),
          ),
          if (kalimat != null) Text(kalimat!),
          ...anak,
        ];
        isi = DefaultTextStyle.merge(
          style: TextStyle(color: c.diTinta),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < bagian.length; i++) ...[
                if (i > 0) SizedBox(height: jarak),
                bagian[i],
              ],
            ],
          ),
        );
      case JenisPita.belumPasti:
        garis = GarisBorder.putus(c.putus, radius: radius ?? 14);
        pad =
            padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 10);
        isi = Text.rich(
          TextSpan(
            children: [
              TextSpan(text: judul, style: tebal),
              if (kalimat != null)
                TextSpan(
                  text: ' $kalimat',
                  style: TextStyle(color: c.tinta2),
                ),
            ],
          ),
        );
    }

    return Semantics(
      container: true,
      child: Container(
        width: double.infinity,
        padding: pad,
        decoration: ShapeDecoration(color: latar, shape: garis),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            // WebTerbatas: the title inherits the body size (15).
            fontSize: sebaris ? null : 14,
            color: jenis == JenisPita.kunci ? c.permukaan : c.tinta,
          ),
          child: isi,
        ),
      ),
    );
  }
}
