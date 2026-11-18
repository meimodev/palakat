import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Eased progress (0..1) of one keyframe segment [a, b] at linear time t (0..1).
/// CSS applies the timing function per segment; this reproduces it.
double ruas(double t, double a, double b, Curve kurva) =>
    kurva.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

double antara(double a, double b, double p) => a + (b - a) * p;

/// The boards' counting curve, exactly: 1 − (1 − t)³.
class KubikKeluar extends Curve {
  const KubikKeluar();
  @override
  double transformInternal(double t) => 1 - math.pow(1 - t, 3).toDouble();
}

bool gerakMati(BuildContext context) => MediaQuery.disableAnimationsOf(context);

/// One keyframe: draws [child] at linear time t with the board's timing function.
typedef Bingkai = Widget Function(BuildContext context, double t, Curve kurva, Widget child);

/// Plays once on mount: waits [tunda], then runs t from 0 to 1 over [lama].
/// Before the delay t = 0 (fill-mode both). After the end t stays 1.
/// Under reduce motion t is 1 at once, delay skipped. If reduce motion turns
/// on mid-run, it jumps to 1.
class GerakBuilder extends StatefulWidget {
  const GerakBuilder({super.key, required this.lama, this.tunda = Duration.zero, required this.builder});
  final Duration lama, tunda;
  final Widget Function(BuildContext context, double t) builder;
  @override
  State<GerakBuilder> createState() => _GerakBuilderState();
}

class _GerakBuilderState extends State<GerakBuilder> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.lama);
  Timer? _tunda;
  bool _mulai = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (gerakMati(context)) {
      _tunda?.cancel();
      _c.value = 1;
      return;
    }
    if (_mulai) return;
    _mulai = true;
    if (widget.tunda == Duration.zero) {
      _c.forward();
    } else {
      _tunda = Timer(widget.tunda, () => _c.forward());
    }
  }

  @override
  void dispose() {
    _tunda?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      AnimatedBuilder(animation: _c, builder: (ctx, _) => widget.builder(ctx, _c.value));
}

/// A keyframe played once on mount. Give it a key naming the state that shows it.
class Gerak extends StatelessWidget {
  const Gerak(
    this.kerangka, {
    super.key,
    required this.lama,
    this.tunda = Duration.zero,
    this.kurva = Curves.ease,
    required this.child,
  });
  final Bingkai kerangka;
  final Duration lama, tunda;
  final Curve kurva;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      GerakBuilder(lama: lama, tunda: tunda, builder: (ctx, t) => kerangka(ctx, t, kurva, child));
}
