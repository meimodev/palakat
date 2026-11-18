import 'package:flutter/widgets.dart';

import '../theme/palakat_tema.dart';

/// Sheet form (CONVENTIONS, navigation.md 1.7): PetaLayar 1760 × 1860,
/// Cakupan 1400 × 1660, Keputusan 1280 × 1320, PetaPlatform 1280 × 2100.
/// A fixed-size `kertas` page, padding 56, 15 / 1.45, column gap [jarak];
/// it scrolls both ways and has no app chrome. Content beyond the page is
/// clipped, as the board's fixed box would cut it.
class HalamanLembar extends StatelessWidget {
  const HalamanLembar({
    super.key,
    required this.ukuran,
    required this.isi,
    this.jarak = 32,
  });

  final Size ukuran;
  final List<Widget> isi;

  /// 32 (PetaLayar, Cakupan, Keputusan), 28 (PetaPlatform).
  final double jarak;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return ColoredBox(
      color: c.kertas,
      child: DefaultTextStyle(
        style: PalakatText.isiWeb.copyWith(color: c.tinta, height: 1.45),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox.fromSize(
              size: ukuran,
              child: SingleChildScrollView(
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(56),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < isi.length; i++) ...[
                      if (i > 0) SizedBox(height: jarak),
                      isi[i],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
