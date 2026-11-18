import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// One item of a [BarisLentur]: CSS `flex: <tumbuh> 1 <dasar>px; max-width: <maks>`.
class Lentur {
  const Lentur({
    required this.dasar,
    this.tumbuh = 1,
    this.maks,
    required this.child,
  });

  /// flex-basis px.
  final double dasar;

  /// flex-grow (999 for "main", 1 or 1.3 for "aside").
  final double tumbuh;

  /// max-width.
  final double? maks;
  final Widget child;
}

/// CSS `display: flex; flex-wrap: wrap; gap; align-items: flex-start`.
/// Never put it inside an IntrinsicHeight (it measures with a LayoutBuilder).
class BarisLentur extends StatelessWidget {
  const BarisLentur({
    super.key,
    required this.anak,
    this.jarak = 24,
    this.jarakBaris,
    this.rata = CrossAxisAlignment.start,
  });

  final List<Lentur> anak;

  /// Column gap.
  final double jarak;

  /// Row gap, defaults to [jarak] (`gap: 20px 28px` = jarakBaris 20, jarak 28).
  final double? jarakBaris;
  final CrossAxisAlignment rata;

  /// The width of each item, line by line, for a content width [w]: CSS
  /// hypothetical sizes (basis clamped to max-width and to [w]) decide the
  /// lines; free space goes by flex-grow, an item that hits its max-width is
  /// frozen there and the rest is shared again.
  static List<List<double>> lebar(List<Lentur> anak, double jarak, double w) {
    double awal(Lentur a) =>
        math.min(math.min(a.dasar, a.maks ?? double.infinity), w);
    final baris = <List<Lentur>>[];
    var jumlah = 0.0;
    for (final a in anak) {
      if (baris.isNotEmpty && jumlah + jarak + awal(a) <= w) {
        baris.last.add(a);
        jumlah += jarak + awal(a);
      } else {
        baris.add([a]);
        jumlah = awal(a);
      }
    }
    return [
      for (final b in baris)
        () {
          final ukuran = [for (final a in b) awal(a)];
          final beku = [
            for (final a in b)
              a.tumbuh <= 0 || (a.maks != null && a.dasar >= a.maks!),
          ];
          while (true) {
            final sisa =
                w - jarak * (b.length - 1) - ukuran.fold(0.0, (s, u) => s + u);
            var tumbuh = 0.0;
            for (var i = 0; i < b.length; i++) {
              if (!beku[i]) tumbuh += b[i].tumbuh;
            }
            if (sisa <= 1e-9 || tumbuh == 0) break;
            var dijepit = false;
            for (var i = 0; i < b.length; i++) {
              if (beku[i]) continue;
              ukuran[i] += sisa * b[i].tumbuh / tumbuh;
              final maks = b[i].maks;
              if (maks != null && ukuran[i] >= maks) {
                ukuran[i] = maks;
                beku[i] = true;
                dijepit = true;
              }
            }
            if (!dijepit) break;
          }
          return ukuran;
        }(),
    ];
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final semua = lebar(anak, jarak, c.maxWidth);
      var i = 0;
      final baris = <Widget>[];
      for (final b in semua) {
        if (baris.isNotEmpty) baris.add(SizedBox(height: jarakBaris ?? jarak));
        final isi = <Widget>[];
        for (final w in b) {
          if (isi.isNotEmpty) isi.add(SizedBox(width: jarak));
          isi.add(SizedBox(width: w, child: anak[i++].child));
        }
        baris.add(Row(crossAxisAlignment: rata, children: isi));
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: baris,
      );
    },
  );
}

/// CSS `grid-template-columns: repeat(auto-fit, minmax(min(X, 100%), 1fr)); gap`,
/// `align-items: start`.
class KisiOtomatis extends StatelessWidget {
  const KisiOtomatis({
    super.key,
    required this.minLebar,
    required this.anak,
    this.jarak = 12,
    this.jarakBaris,
  });

  final double minLebar;
  final List<Widget> anak;
  final double jarak;

  /// Row gap, defaults to [jarak].
  final double? jarakBaris;

  /// Column count for a content width [w].
  static int kolom(double w, double minLebar, double jarak, int jumlah) =>
      math.max(1, math.min(((w + jarak) / (minLebar + jarak)).floor(), jumlah));

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      if (anak.isEmpty) return const SizedBox.shrink();
      final w = c.maxWidth;
      final n = kolom(w, minLebar, jarak, anak.length);
      final lebar = (w - jarak * (n - 1)) / n;
      final baris = <Widget>[];
      for (var i = 0; i < anak.length; i += n) {
        if (baris.isNotEmpty) baris.add(SizedBox(height: jarakBaris ?? jarak));
        final isi = <Widget>[];
        for (var j = i; j < math.min(i + n, anak.length); j++) {
          if (isi.isNotEmpty) isi.add(SizedBox(width: jarak));
          isi.add(SizedBox(width: lebar, child: anak[j]));
        }
        baris.add(
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: isi),
        );
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: baris,
      );
    },
  );
}

/// CSS negative vertical margin: the box is [atas] + [bawah] shorter than its
/// child and the child is drawn [atas] higher. The child stays hittable.
class MarginNegatif extends SingleChildRenderObjectWidget {
  const MarginNegatif({super.key, this.atas = 0, this.bawah = 0, super.child});

  final double atas;
  final double bawah;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMarginNegatif(atas, bawah);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) => (renderObject as _RenderMarginNegatif)
    ..atas = atas
    ..bawah = bawah;
}

class _RenderMarginNegatif extends RenderShiftedBox {
  _RenderMarginNegatif(this._atas, this._bawah) : super(null);

  double _atas, _bawah;
  set atas(double v) {
    if (v == _atas) return;
    _atas = v;
    markNeedsLayout();
  }

  set bawah(double v) {
    if (v == _bawah) return;
    _bawah = v;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final c = child;
    if (c == null) {
      size = constraints.smallest;
      return;
    }
    c.layout(
      BoxConstraints(
        minWidth: constraints.minWidth,
        maxWidth: constraints.maxWidth,
      ),
      parentUsesSize: true,
    );
    size = constraints.constrain(
      Size(c.size.width, math.max(0, c.size.height - _atas - _bawah)),
    );
    (c.parentData! as BoxParentData).offset = Offset(0, -_atas);
  }

  // Hit the whole child, also the part drawn outside this box.
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!hitTestChildren(result, position: position)) return false;
    result.add(BoxHitTestEntry(this, position));
    return true;
  }
}
