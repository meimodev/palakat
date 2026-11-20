import 'dart:async';

import 'package:flutter/widgets.dart';

import '../core/format.dart' show rp;
import 'gerak.dart';

/// A counting figure (motion.md, "Counting figures"): the boards' 30 ms ticks
/// with 1 − (1 − t)³. Main: `Hitung(dari: saldoLama, nilai: saldoBaru,
/// lama: 780 ms, tunda: 750 ms)` keyed on `posted`. TutupBuku, WebRekonsiliasi,
/// Kewajiban, WebKasus: `Hitung(nilai: target)` (660 ms); a new [nilai] counts on
/// from the figure on screen. Under reduce motion the final figure shows at once.
class Hitung extends StatefulWidget {
  const Hitung({
    super.key,
    required this.nilai,
    this.dari,
    this.lama = const Duration(milliseconds: 660),
    this.tunda = Duration.zero,
    required this.builder,
  });

  /// Target figure.
  final int nilai;

  /// Start figure on first mount; null shows [nilai] at once.
  final int? dari;
  final Duration lama, tunda;
  final Widget Function(BuildContext context, int tampil) builder;
  @override
  State<Hitung> createState() => _HitungState();
}

class _HitungState extends State<Hitung> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.lama,
  );
  late double _awal = (widget.dari ?? widget.nilai).toDouble();
  late double _akhir = widget.nilai.toDouble();
  Timer? _tunda;
  bool _mulai = false;

  int get _tampil =>
      antara(_awal, _akhir, const KubikKeluar().transform(_c.value)).round();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (gerakMati(context)) {
      _tunda?.cancel();
      _c.value = 1;
      _mulai =
          true; // switching reduce motion off later must not replay the count
      return;
    }
    if (_mulai) return;
    _mulai = true;
    if (_awal == _akhir) {
      _c.value = 1;
    } else if (widget.tunda == Duration.zero) {
      _c.forward(from: 0);
    } else {
      _tunda = Timer(widget.tunda, () {
        if (mounted) _c.forward(from: 0);
      });
    }
  }

  @override
  void didUpdateWidget(Hitung oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nilai == oldWidget.nilai) return;
    _tunda?.cancel();
    _awal = _tampil.toDouble(); // continue from the figure on screen
    _akhir = widget.nilai.toDouble();
    if (gerakMati(context)) {
      _c.value = 1;
    } else {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _tunda?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    value: rp(widget.nilai), // assistive tech hears only the final figure
    child: ExcludeSemantics(
      child: gerakMati(context)
          ? widget.builder(context, widget.nilai)
          : AnimatedBuilder(
              animation: _c,
              builder: (ctx, _) => widget.builder(ctx, _tampil),
            ),
    ),
  );
}
