import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/palakat_tema.dart';
import 'gerak.dart';

/// Repeating motion. t is the position in the current cycle (0..1), or null
/// before the delay and under reduce motion; null means "draw the plain style".
class Ulang extends StatefulWidget {
  const Ulang({
    super.key,
    required this.periode,
    this.tunda = Duration.zero,
    required this.builder,
  });
  final Duration periode, tunda;
  final Widget Function(BuildContext context, double? t) builder;
  @override
  State<Ulang> createState() => _UlangState();
}

class _UlangState extends State<Ulang> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.periode,
  );
  Timer? _tunda;
  bool _jalan = false;

  void _mulai() {
    _jalan = true;
    _c.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tunda?.cancel();
    if (gerakMati(context)) {
      _c.stop();
      _jalan = false;
      return;
    }
    if (_jalan) return;
    if (widget.tunda == Duration.zero) {
      _mulai(); // no one-frame plain style before a zero delay
    } else {
      _tunda = Timer(widget.tunda, () {
        if (mounted) setState(_mulai);
      });
    }
  }

  @override
  void dispose() {
    _tunda?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (ctx, _) => widget.builder(ctx, _jalan ? _c.value : null),
  );
}

/// Opacity of `titik` (0 %, 100 % .25; 50 % 1; CSS ease) at cycle position t.
double opasitasTitik(double? t) => t == null
    ? 1.0
    : t < .5
    ? antara(.25, 1, ruas(t, 0, .5, Curves.ease))
    : antara(1, .25, ruas(t, .5, 1, Curves.ease));

/// Opacity of `denyut` (0 %, 100 % 1; 50 % .45; ease-in-out) at cycle position t.
double opasitasDenyut(double? t) => t == null
    ? 1.0
    : t < .5
    ? antara(1, .45, ruas(t, 0, .5, Curves.easeInOut))
    : antara(.45, 1, ruas(t, .5, 1, Curves.easeInOut));

/// `titik`: AI is thinking. Three 6 × 6 `laut` dots, 4 apart, `titik 1s`
/// with delays 0, .2s, .4s (no fill mode: a delayed dot is opaque until it starts).
/// The words before it ("Menyusun usulan") belong to the screen.
class TitikAI extends StatelessWidget {
  const TitikAI({super.key});

  @override
  Widget build(BuildContext context) {
    final titik = SizedBox.square(
      dimension: 6,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.warna.laut,
          shape: BoxShape.circle,
        ),
      ),
    );
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Ulang(
              periode: const Duration(seconds: 1),
              tunda: Duration(milliseconds: 200 * i),
              builder: (c, t) =>
                  Opacity(opacity: opasitasTitik(t), child: titik),
            ),
          ],
        ],
      ),
    );
  }
}

/// `denyut 1.4s ease-in-out infinite` on a skeleton block (Memuat, WebMemuat).
/// Blocks mounted together stay in step.
class Denyut extends StatelessWidget {
  const Denyut({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Ulang(
    periode: const Duration(milliseconds: 1400),
    builder: (c, t) => Opacity(opacity: opasitasDenyut(t), child: child),
  );
}

/// `putar`: one clockwise turn per [periode], linear, repeating; still at 0°
/// under reduce motion. TutupBuku spinner 1 s; Awal and Bendahara dashed ring 6 s.
class Putar extends StatelessWidget {
  const Putar({
    super.key,
    this.periode = const Duration(seconds: 1),
    required this.child,
  });
  final Duration periode;
  final Widget child;

  @override
  Widget build(BuildContext context) => Ulang(
    periode: periode,
    builder: (c, t) =>
        Transform.rotate(angle: 2 * math.pi * (t ?? 0), child: child),
  );
}
