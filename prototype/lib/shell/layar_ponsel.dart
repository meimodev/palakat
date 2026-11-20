import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/palakat_tema.dart';
import '../widgets/pita_jabatan_kosong.dart';
import '../providers/session.dart';

/// Root of every phone board (components.md 4.1): fills the frame (or the
/// screen), `kertas`, body text 16 / 1.4, clipped.
///
/// ```
/// Column
/// ├─ PitaJabatanKosong.ponsel   (a finance screen, while the actor covers the vacant Bendahara post)
/// └─ Expanded → Stack           (the board's `position: relative; flex: 1`)
///      ├─ child                 (inset 0)
///      └─ ...overlay            (PonselTabBar, Toast, LembarBawah)
/// ```
class LayarPonsel extends ConsumerWidget {
  const LayarPonsel({
    super.key,
    required this.child,
    this.layarKeuangan = false,
    this.overlay = const [],
  });

  final Widget child;

  /// A finance screen: the strip shows on it while [vacancyCoverProvider] is
  /// true (D18).
  final bool layarKeuangan;
  final List<Widget> overlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final pita = layarKeuangan && ref.watch(vacancyCoverProvider);
    return SizedBox.expand(
      // The Material ancestor TextFields need, outside the board text style
      // so it does not reset it to the theme's bodyMedium.
      child: Material(
        type: MaterialType.transparency,
        child: ColoredBox(
          color: c.kertas,
          child: DefaultTextStyle(
            style: PalakatText.isi.copyWith(
              color: c.tinta,
              height: 1.4,
              // CSS splits line-height leading evenly above and below the glyphs.
              leadingDistribution: TextLeadingDistribution.even,
            ),
            child: ClipRect(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (pita) const PitaJabatanKosong.ponsel(),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(child: child),
                        ...overlay,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
