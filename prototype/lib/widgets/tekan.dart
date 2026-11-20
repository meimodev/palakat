import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/palakat_tema.dart';

/// The boards' focus ring: `outline: 2px solid laut; outline-offset: 2px`.
/// The child's rounded rect inflated by 3, radius + 3, stroke 2, never clipped.
class CincinFokus extends StatelessWidget {
  const CincinFokus({
    super.key,
    required this.tampil,
    required this.child,
    this.radius = 0,
  });

  /// Paint the ring (keyboard focus only, see [Tekan]).
  final bool tampil;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    fit: StackFit.passthrough,
    children: [
      child,
      if (tampil)
        Positioned(
          left: -3,
          top: -3,
          right: -3,
          bottom: -3,
          child: IgnorePointer(
            child: CustomPaint(
              painter: _CincinPainter(context.warna.laut, radius + 3),
            ),
          ),
        ),
    ],
  );
}

class _CincinPainter extends CustomPainter {
  _CincinPainter(this.warna, this.radius);
  final Color warna;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) => canvas.drawRRect(
    RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
    Paint()
      ..color = warna
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2,
  );

  @override
  bool shouldRepaint(_CincinPainter old) =>
      old.warna != warna || old.radius != radius;
}

enum PeranTekan { tombol, tautan, sakelar }

/// Mouse over a link's whole [Tekan] target (CSS `a:hover`), so a
/// [TautanTeks] inside takes the hover colour beyond its glyphs.
class SorotTautan extends InheritedWidget {
  const SorotTautan({super.key, required this.aktif, required super.child});

  final bool aktif;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SorotTautan>()?.aktif ?? false;

  @override
  bool updateShouldNotify(SorotTautan old) => old.aktif != aktif;
}

/// The base of every pressable thing: keyboard (Enter, Space), click cursor,
/// semantics, a 44 × 44 minimum and the keyboard focus ring. No ink.
class Tekan extends StatefulWidget {
  const Tekan({
    super.key,
    required this.onTap,
    required this.child,
    this.label,
    this.radius = 0,
    this.minLebar = 44,
    this.minTinggi = 44,
    this.dipilih,
    this.tercentang,
    this.peran = PeranTekan.tombol,
  });

  /// null = really disabled (rare, see TombolBersyarat).
  final VoidCallback? onTap;
  final Widget child;

  /// Board aria-label; replaces the child's own semantics.
  final String? label;
  final double radius;
  final double minLebar;
  final double minTinggi;

  /// aria-pressed, selected tab.
  final bool? dipilih;

  /// Switch (toggled) or checkbox (checked).
  final bool? tercentang;
  final PeranTekan peran;

  @override
  State<Tekan> createState() => _TekanState();
}

class _TekanState extends State<Tekan> {
  bool _sorot = false, _layang = false;

  static const _pintasan = <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
  };

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final aktif = w.onTap != null;
    final sakelar = w.peran == PeranTekan.sakelar;
    final tautan = w.peran == PeranTekan.tautan;
    return Semantics(
      // Its own node, so a neighbouring label never merges into the button.
      container: true,
      button: w.peran == PeranTekan.tombol,
      link: w.peran == PeranTekan.tautan,
      toggled: sakelar ? w.tercentang : null,
      checked: sakelar ? null : w.tercentang,
      selected: w.dipilih,
      enabled: aktif,
      label: w.label,
      child: FocusableActionDetector(
        enabled: aktif,
        mouseCursor: aktif ? SystemMouseCursors.click : MouseCursor.defer,
        shortcuts: _pintasan,
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => w.onTap?.call(),
          ),
        },
        onShowFocusHighlight: (v) => setState(() => _sorot = v),
        child: MouseRegion(
          // Not onShowHoverHighlight: that stays off in touch highlight mode.
          onEnter: tautan ? (_) => setState(() => _layang = true) : null,
          onExit: tautan ? (_) => setState(() => _layang = false) : null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: w.onTap,
            child: CincinFokus(
              tampil: _sorot && aktif,
              radius: w.radius,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: w.minLebar,
                  minHeight: w.minTinggi,
                ),
                // aria-label replaces the child's own text.
                child: ExcludeSemantics(
                  excluding: w.label != null,
                  child: SorotTautan(aktif: _layang, child: w.child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
