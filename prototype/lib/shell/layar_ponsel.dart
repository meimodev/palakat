import 'package:flutter/widgets.dart';

import '../theme/palakat_tema.dart';
import '../widgets/pita_jabatan_kosong.dart';
import 'prototipe_state.dart';

/// Root of every phone board (components.md 4.1): fills the frame (or the
/// screen), `kertas`, body text 16 / 1.4, clipped.
///
/// ```
/// Column
/// ├─ PitaJabatanKosong.ponsel   (board has the tweak and the global switch is on)
/// └─ Expanded → Stack           (the board's `position: relative; flex: 1`)
///      ├─ child                 (inset 0)
///      └─ ...overlay            (PonselTabBar, Toast, LembarBawah)
/// ```
class LayarPonsel extends StatelessWidget {
  const LayarPonsel({
    super.key,
    required this.child,
    this.jabatanKosong = false,
    this.overlay = const [],
  });

  final Widget child;

  /// The board carries the `jabatanKosong` tweak. The strip shows while this
  /// and the global switch of [PrototypeState] are both on.
  final bool jabatanKosong;
  final List<Widget> overlay;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final pita =
        jabatanKosong &&
        (PrototypeState.maybeOf(context)?.jabatanKosong ?? false);
    return SizedBox.expand(
      child: ColoredBox(
        color: c.kertas,
        child: DefaultTextStyle(
          style: PalakatText.isi.copyWith(color: c.tinta, height: 1.4),
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
    );
  }
}
