import 'package:flutter/widgets.dart';

import '../motion/kerangka.dart';
import '../theme/palakat_tema.dart';
import '../widgets/tata_letak.dart';

/// The web form of a phone bottom sheet (components.md 4.6): an `aside` in
/// the content row, not an overlay. Use it as the second item of a
/// [BarisLentur] through [lentur]:
///
/// ```dart
/// BarisLentur(anak: [Lentur(dasar: 520, tumbuh: 999, child: utama), PanelSamping(anak: [...]).lentur])
/// ```
///
/// Plain: a column with gap [jarak], no box. [berbingkai] (WebKeluar):
/// `permukaan`, 1.5 `tinta`, radius 14, padding 20. [kotak] (WebDraf,
/// WebLihatDokumen, WebUnggah): `permukaan`, 1 `garis`, radius 14, padding 20.
/// [ai] (WebAI): `lautLembut`, radius 18, padding 18, no line. Closing is
/// instant (the screen removes it).
class PanelSamping extends StatelessWidget {
  const PanelSamping({
    super.key,
    required this.anak,
    this.berbingkai = false,
    this.dasar = 340,
    this.maks,
    this.jarak = 14,
    this.muncul = false,
    this.kotak = false,
    this.ai = false,
  });

  final List<Widget> anak;
  final bool berbingkai;

  /// `flex-basis` of the outer box (280–400 on the boards). On a content-box
  /// aside add 2 × padding + 2 × line (WebDraf 360 → 402, WebKeluar 320 → 363).
  final double dasar;

  /// `max-width` of the outer box, likewise (WebKeluar 420 → 463).
  final double? maks;
  final double jarak;

  /// Enters with `muncul` 300 ms `ease` (WebDraf, WebKeluar, WebKasus,
  /// WebPilihBulan, WebTransaksi).
  final bool muncul;
  final bool kotak;
  final bool ai;

  /// This panel as a `flex: 1 1 <dasar>px` item.
  Lentur get lentur => Lentur(dasar: dasar, maks: maks, child: this);

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    Widget isi = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < anak.length; i++) ...[
          if (i > 0) SizedBox(height: jarak),
          anak[i],
        ],
      ],
    );
    final kotakPanel = berbingkai
        ? (c.permukaan, Border.all(color: c.tinta, width: 1.5), 14.0, 20.0)
        : kotak
        ? (c.permukaan, Border.all(color: c.garis), 14.0, 20.0)
        : ai
        ? (c.lautLembut, null, 18.0, 18.0)
        : null;
    if (kotakPanel case (final warna, final garis, final radius, final pad)) {
      isi = Container(
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          color: warna,
          border: garis,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: isi,
      );
    }
    if (!muncul) return isi;
    return Gerak(
      Kerangka.muncul,
      lama: const Duration(milliseconds: 300),
      child: isi,
    );
  }
}
