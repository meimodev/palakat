import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/palakat_tema.dart';
import 'gerak.dart';

export 'gerak.dart';

/// One Bingkai per board keyframe and variant (motion.md, "Keyframes").
/// Variants that take a distance or a colour are factories.
abstract final class Kerangka {
  /// `muncul`: opacity 0 → 1, translateY 8 → 0.
  static Widget muncul(BuildContext c, double t, Curve k, Widget w) {
    final p = k.transform(t);
    return Opacity(
      opacity: p,
      child: Transform.translate(offset: Offset(0, 8 * (1 - p)), child: w),
    );
  }

  /// `masuk`: opacity 0 → 1, translateX 24 → 0 (pindahLayar, keluar).
  static Widget masuk(BuildContext c, double t, Curve k, Widget w) {
    final p = k.transform(t);
    return Opacity(
      opacity: p,
      child: Transform.translate(offset: Offset(24 * (1 - p), 0), child: w),
    );
  }

  /// `naik`: translateY 100 % → 0 of the sheet's own height. No fade.
  static Widget naik(BuildContext c, double t, Curve k, Widget w) =>
      FractionalTranslation(
        translation: Offset(0, 1 - k.transform(t)),
        child: w,
      );

  /// `pudar`: opacity 0 → 1.
  static Widget pudar(BuildContext c, double t, Curve k, Widget w) =>
      Opacity(opacity: k.transform(t), child: w);

  static Bingkai _cap(
    double dari,
    double henti,
    double akhir, {
    double putarDari = 0,
    double putar = 0,
  }) => (c, t, k, w) {
    final a = ruas(t, 0, henti, k), b = ruas(t, henti, 1, k);
    final skala = t < henti ? antara(dari, akhir, a) : antara(akhir, 1, b);
    final derajat = t < henti ? antara(putarDari, putar, a) : putar;
    return Opacity(
      opacity: t < henti ? a : 1,
      child: Transform.rotate(
        angle: derajat * math.pi / 180,
        child: Transform.scale(scale: skala, child: w),
      ),
    );
  };

  /// `cap` A, the No. Bukti stamp: 1.7 → .94 (55 %) → 1, −9° → −3°, stays −3°.
  static final Bingkai cap = _cap(1.7, .55, .94, putarDari: -9, putar: -3);

  /// `cap` B, scale only from 1.7 (Koreksi "Dibalik").
  static final Bingkai capTegak = _cap(1.7, .55, .94);

  /// `cap` C, scale only from 1.8 (the lock; the Gerak preview's `segel`).
  static final Bingkai capSegel = _cap(1.8, .60, .92);

  /// `sapu`: scaleX 0 → 1 at 20 % (to 65 %), then fades to 0. Origin left.
  /// Child: ColoredBox(laut), as the last child of a clipped Stack, inside
  /// IgnorePointer + Positioned.fill (see [SapuTinta] in urutan.dart).
  static Widget sapu(BuildContext c, double t, Curve k, Widget w) {
    final lebar = ruas(t, 0, .65, k);
    final opasitas = t < .65 ? .2 : antara(.2, 0, ruas(t, .65, 1, k));
    return Opacity(
      opacity: opasitas,
      child: Transform(
        alignment: Alignment.centerLeft,
        transform: Matrix4.diagonal3Values(lebar, 1, 1),
        child: w,
      ),
    );
  }

  /// `isi`: width 0 → 100 %, always linear (see [BatangIsi] in urutan.dart).
  static Widget isi(BuildContext c, double t, Curve k, Widget w) =>
      FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: k.transform(t),
        child: w,
      );

  /// `gelap`: background [dari] → tinta. Phone: `(w) => w.kertas`;
  /// web: `(w) => w.permukaan` (clip with radius 18).
  static Bingkai gelap(Color Function(PalakatWarna w) dari) =>
      (c, t, k, w) => ColoredBox(
        color: Color.lerp(dari(c.warna), c.warna.tinta, k.transform(t))!,
        child: w,
      );

  /// `kait`: scale 0 → 1.25 (70 %) → 1, opacity 0 → 1 over the first segment.
  static Widget kait(BuildContext c, double t, Curve k, Widget w) {
    final a = ruas(t, 0, .7, k), b = ruas(t, .7, 1, k);
    return Opacity(
      opacity: t < .7 ? a : 1,
      child: Transform.scale(
        scale: t < .7 ? antara(0, 1.25, a) : antara(1.25, 1, b),
        child: w,
      ),
    );
  }

  /// `dariKiri`: from [jarak] px left (TutupBuku 40, WebRekonsiliasi 60).
  static Bingkai dariKiri(double jarak) => (c, t, k, w) {
    final p = k.transform(t);
    return Opacity(
      opacity: p,
      child: Transform.translate(offset: Offset(-jarak * (1 - p), 0), child: w),
    );
  };

  /// `dariKanan`: from [jarak] px right.
  static Bingkai dariKanan(double jarak) => (c, t, k, w) {
    final p = k.transform(t);
    return Opacity(
      opacity: p,
      child: Transform.translate(offset: Offset(jarak * (1 - p), 0), child: w),
    );
  };

  /// `balik`: perspective(700px) rotateX(−90° → 0), hinged on the top edge.
  /// CSS perspective() puts −1/d in m34 (+z toward the viewer); with the same
  /// sign here the projection matches the browser: mid-flip, the bottom edge
  /// is farther away (narrower) than the hinge.
  static Widget balik(BuildContext c, double t, Curve k, Widget w) {
    final p = k.transform(t);
    return Opacity(
      opacity: p,
      child: Transform(
        alignment: Alignment.topCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, -1 / 700)
          ..rotateX(antara(-math.pi / 2, 0, p)),
        child: w,
      ),
    );
  }

  /// `tali`: a 2 px line grows from 0 to [tinggi] (Koreksi 18).
  /// Child: ColoredBox(tinta), inside Padding(left: 28).
  static Bingkai tali(double tinggi) =>
      (c, t, k, w) =>
          SizedBox(width: 2, height: tinggi * k.transform(t), child: w);

  /// `turun`: opacity 0 → 1, translateY −14 → 0 (BantuanAI only).
  static Widget turun(BuildContext c, double t, Curve k, Widget w) {
    final p = k.transform(t);
    return Opacity(
      opacity: p,
      child: Transform.translate(offset: Offset(0, -14 * (1 - p)), child: w),
    );
  }

  /// `kilat`: opacity .9 → 0, ignores the pointer (Kamera; child a permukaan fill).
  static Widget kilat(BuildContext c, double t, Curve k, Widget w) =>
      IgnorePointer(
        child: Opacity(opacity: antara(.9, 0, k.transform(t)), child: w),
      );
}
