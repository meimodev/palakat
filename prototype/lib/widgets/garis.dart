import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';

enum GayaGaris { penuh, putus, titik }

/// The one border of the prototype: solid, dashed (CSS `dashed`) or dotted
/// (CSS `dotted`), drawn as Chrome draws them. CSS border-box: the line sits
/// inside the box and padding inside the line.
class GarisBorder extends OutlinedBorder {
  const GarisBorder({
    required this.warna,
    this.tebal = 1.5,
    this.gaya = GayaGaris.penuh,
    BorderRadius this._radius = BorderRadius.zero, // named `radius:`
    super.side = BorderSide.none,
  }) : _sudut = 0;

  const GarisBorder.penuh(this.warna, {this.tebal = 1.5, double radius = 0})
    : gaya = GayaGaris.penuh,
      _radius = null,
      _sudut = radius;

  const GarisBorder.putus(this.warna, {this.tebal = 1.5, double radius = 0})
    : gaya = GayaGaris.putus,
      _radius = null,
      _sudut = radius;

  const GarisBorder.titik(this.warna, {this.tebal = 1.5, double radius = 0})
    : gaya = GayaGaris.titik,
      _radius = null,
      _sudut = radius;

  final Color warna;
  final double tebal;
  final GayaGaris gaya;
  // A const constructor cannot build BorderRadius.circular(radius), so the
  // named constructors keep the double and [radius] resolves it.
  final BorderRadius? _radius;
  final double _sudut;

  BorderRadius get radius => _radius ?? BorderRadius.circular(_sudut);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(tebal);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(radius.toRRect(rect).deflate(tebal));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(radius.toRRect(rect));

  @override
  bool get preferPaintInterior => true;

  @override
  void paintInterior(
    Canvas canvas,
    Rect rect,
    Paint paint, {
    TextDirection? textDirection,
  }) => canvas.drawRRect(radius.toRRect(rect), paint);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (tebal <= 0) return;
    final pena = Paint()
      ..color = warna
      ..style = PaintingStyle.stroke
      ..strokeWidth = tebal;
    final rr = radius.toRRect(rect).deflate(tebal / 2);
    if (gaya == GayaGaris.penuh) {
      canvas.drawRRect(rr, pena);
    } else {
      canvas.drawPath(
        GarisPainter.dashPath(Path()..addRRect(rr), gaya, tebal),
        pena,
      );
    }
  }

  @override
  GarisBorder scale(double t) => GarisBorder(
    warna: warna,
    tebal: tebal * t,
    gaya: gaya,
    radius: radius * t,
    side: side.scale(t),
  );

  @override
  GarisBorder copyWith({
    BorderSide? side,
    Color? warna,
    double? tebal,
    GayaGaris? gaya,
    BorderRadius? radius,
  }) => GarisBorder(
    warna: warna ?? this.warna,
    tebal: tebal ?? this.tebal,
    gaya: gaya ?? this.gaya,
    radius: radius ?? this.radius,
    side: side ?? this.side,
  );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) =>
      a is GarisBorder ? _lerp(a, this, t) : super.lerpFrom(a, t);

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) =>
      b is GarisBorder ? _lerp(this, b, t) : super.lerpTo(b, t);

  static GarisBorder _lerp(GarisBorder a, GarisBorder b, double t) =>
      GarisBorder(
        warna: Color.lerp(a.warna, b.warna, t)!,
        tebal: lerpDouble(a.tebal, b.tebal, t)!,
        gaya: t < 0.5 ? a.gaya : b.gaya,
        radius: BorderRadius.lerp(a.radius, b.radius, t)!,
      );

  @override
  bool operator ==(Object other) =>
      other is GarisBorder &&
      other.warna == warna &&
      other.tebal == tebal &&
      other.gaya == gaya &&
      other.radius == radius &&
      other.side == side;

  @override
  int get hashCode => Object.hash(warna, tebal, gaya, radius, side);
}

abstract final class GarisPainter {
  /// Chrome's patterns: dashed = dash 3w gap 2w, dotted = dot 1w gap 1w.
  static (double, double) pola(GayaGaris gaya, double tebal) =>
      gaya == GayaGaris.titik ? (tebal, tebal) : (tebal * 3, tebal * 2);

  /// Dashes [sumber] with the pattern of [gaya]/[tebal], gaps stretched so the
  /// pattern fits each contour evenly. An open line starts and ends on a dash.
  static Path dashPath(
    Path sumber,
    GayaGaris gaya,
    double tebal, {
    bool tertutup = true,
  }) {
    if (gaya == GayaGaris.penuh) return sumber;
    final (dash, gap) = pola(gaya, tebal);
    final hasil = Path();
    for (final m in sumber.computeMetrics()) {
      final p = m.length;
      if (p <= dash) {
        hasil.addPath(m.extractPath(0, p), Offset.zero);
        continue;
      }
      final double langkah;
      final int n;
      if (tertutup) {
        n = math.max(1, (p / (dash + gap)).round());
        langkah = p / n;
      } else {
        n = math.max(1, ((p + gap) / (dash + gap)).round());
        langkah = n == 1 ? p : (p - dash) / (n - 1);
      }
      for (var i = 0; i < n; i++) {
        final a = i * langkah;
        hasil.addPath(m.extractPath(a, math.min(a + dash, p)), Offset.zero);
      }
    }
    return hasil;
  }
}

/// A one-sided rule: CSS border-top / border-bottom. Full width, height = tebal.
class GarisLurus extends StatelessWidget {
  const GarisLurus({
    super.key,
    required this.warna,
    this.tebal = 1,
    this.gaya = GayaGaris.penuh,
  });

  final Color warna;
  final double tebal;
  final GayaGaris gaya;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: tebal,
    child: CustomPaint(painter: _LurusPainter(warna, tebal, gaya)),
  );
}

class _LurusPainter extends CustomPainter {
  _LurusPainter(this.warna, this.tebal, this.gaya);
  final Color warna;
  final double tebal;
  final GayaGaris gaya;

  @override
  void paint(Canvas canvas, Size size) {
    final m = canvas.getTransform();
    // Chrome snaps borders to device pixels; at a fractional offset the dots
    // or dashes would blur into a pale solid line. Not when rotated (Kamera).
    // ponytail: snaps within the current layer only.
    if (gaya != GayaGaris.penuh && m[1] == 0 && m[4] == 0) {
      canvas.translate(
        (m[12].roundToDouble() - m[12]) / m[0],
        (m[13].roundToDouble() - m[13]) / m[5],
      );
    }
    final y = size.height / 2;
    final garis = Path()
      ..moveTo(0, y)
      ..lineTo(size.width, y);
    canvas.drawPath(
      GarisPainter.dashPath(garis, gaya, tebal, tertutup: false),
      Paint()
        ..color = warna
        ..style = PaintingStyle.stroke
        ..strokeWidth = tebal,
    );
  }

  @override
  bool shouldRepaint(_LurusPainter old) =>
      old.warna != warna || old.tebal != tebal || old.gaya != gaya;
}
