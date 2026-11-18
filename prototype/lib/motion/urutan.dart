import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/palakat_tema.dart';
import 'kerangka.dart';

/// Reusable pieces of the money-status sequences (motion.md, "Money-status
/// sequences"). Every other step of a sequence is a plain `Gerak` at its call site.

/// `lingkar`: a stroke drawn clockwise from 12 o'clock, butt ends; optional fill.
/// [p] is the eased progress 0..1.
class Cincin extends CustomPainter {
  Cincin(
    this.p, {
    required this.r,
    required this.tebal,
    required this.garis,
    this.isi,
  });
  final double p, r, tebal;
  final Color garis;
  final Color? isi;

  @override
  void paint(Canvas canvas, Size size) {
    final pusat = size.center(Offset.zero);
    if (isi != null) canvas.drawCircle(pusat, r, Paint()..color = isi!);
    canvas.drawArc(
      Rect.fromCircle(center: pusat, radius: r),
      -math.pi / 2,
      2 * math.pi * p,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = tebal
        ..strokeCap = StrokeCap.butt
        ..color = garis,
    );
  }

  @override
  bool shouldRepaint(Cincin o) =>
      o.p != p ||
      o.r != r ||
      o.tebal != tebal ||
      o.garis != garis ||
      o.isi != isi;
}

/// The success disc (Awal "Wewenang Bendahara aktif", HitungKas "Hitung kas
/// tersimpan"): 88 viewBox, r 38, `laut` fill at once, stroke 3 `laut` traced
/// `lingkar .7s ease-out`, then the check `M29 45l10 10 20-21` (stroke 5 `diLaut`,
/// round) `pudar .3s .5s both`. Drawn at [ukuran] (Awal 88, HitungKas 56).
/// Key it on the state that mounts it.
class LingkarSelesai extends StatelessWidget {
  const LingkarSelesai({super.key, this.ukuran = 88});
  final double ukuran;

  @override
  Widget build(BuildContext context) {
    final w = context.warna;
    return SizedBox.square(
      dimension: ukuran,
      child: FittedBox(
        child: SizedBox.square(
          dimension: 88,
          child: Stack(
            children: [
              Positioned.fill(
                child: GerakBuilder(
                  lama: const Duration(milliseconds: 700),
                  builder: (c, t) => CustomPaint(
                    painter: Cincin(
                      Curves.easeOut.transform(t),
                      r: 38,
                      tebal: 3,
                      garis: w.laut,
                      isi: w.laut,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Gerak(
                  Kerangka.pudar,
                  lama: const Duration(milliseconds: 300),
                  tunda: const Duration(milliseconds: 500),
                  child: CustomPaint(painter: _Centang(w.diLaut)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Centang extends CustomPainter {
  _Centang(this.warna);
  final Color warna;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(29, 45)
        ..relativeLineTo(10, 10)
        ..relativeLineTo(20, -21),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = warna,
    );
  }

  @override
  bool shouldRepaint(_Centang o) => o.warna != warna;
}

/// The seal of Tutup buku (`segel`), TutupBuku and WebTutupBuku Ditutup: 104 box,
/// ring r 46 stroke 3 `permukaan` `lingkar .9s .3s ease-out both`, then the lock
/// (body 34 × 26 radius 5, shackle stroke 4 round, `permukaan`) `cap` C
/// `.5s 1.1s keluar both`, origin the box centre. The `gelap` background and the
/// text are the screen's. Key it on the state that mounts it.
class SegelGembok extends StatelessWidget {
  const SegelGembok({super.key, this.ukuran = 104});
  final double ukuran;

  @override
  Widget build(BuildContext context) {
    final w = context.warna;
    // The board's svg: role="img" aria-label="Buku sudah ditutup".
    return Semantics(
      image: true,
      label: 'Buku sudah ditutup',
      child: SizedBox.square(
        dimension: ukuran,
        child: FittedBox(
          child: SizedBox.square(
            dimension: 104,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GerakBuilder(
                    lama: PalakatMotion.segel,
                    tunda: const Duration(milliseconds: 300),
                    builder: (c, t) => CustomPaint(
                      painter: Cincin(
                        Curves.easeOut.transform(t),
                        r: 46,
                        tebal: 3,
                        garis: w.permukaan,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Gerak(
                    Kerangka.capSegel,
                    lama: const Duration(milliseconds: 500),
                    tunda: const Duration(milliseconds: 1100),
                    kurva: PalakatMotion.keluar,
                    child: CustomPaint(painter: _Gembok(w.permukaan)),
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

class _Gembok extends CustomPainter {
  _Gembok(this.warna);
  final Color warna;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(35, 48, 34, 26),
        const Radius.circular(5),
      ),
      Paint()..color = warna,
    );
    // M41 48v-8a11 11 0 0 1 22 0v8
    canvas.drawPath(
      Path()
        ..moveTo(41, 48)
        ..lineTo(41, 40)
        ..arcToPoint(const Offset(63, 40), radius: const Radius.circular(11))
        ..lineTo(63, 48),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = warna,
    );
  }

  @override
  bool shouldRepaint(_Gembok o) => o.warna != warna;
}

/// The ink sweep of Bukukan (`sapu .7s ease-out both`, `tinta`): a `laut`
/// overlay over the whole card. Put it last in a Stack that is clipped with the
/// card's radius. Key it on the booked state.
class SapuTinta extends StatelessWidget {
  const SapuTinta({super.key});

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: IgnorePointer(
      child: Gerak(
        Kerangka.sapu,
        lama: PalakatMotion.tinta,
        kurva: Curves.easeOut,
        child: ColoredBox(color: context.warna.laut),
      ),
    ),
  );
}

/// A progress bar (`isi`, linear both): a `laut` fill grows over [lama] inside
/// a `garis` track [tinggi] high (4 or 6), radius tinggi / 2. Full is not
/// success: the screen's timer decides when the state flips.
class BatangIsi extends StatelessWidget {
  const BatangIsi({super.key, required this.lama, this.tinggi = 6});
  final Duration lama;
  final double tinggi;

  @override
  Widget build(BuildContext context) {
    final w = context.warna;
    return ClipRRect(
      borderRadius: BorderRadius.circular(tinggi / 2),
      child: SizedBox(
        width: double.infinity,
        height: tinggi,
        child: ColoredBox(
          color: w.garis,
          child: Gerak(
            Kerangka.isi,
            lama: lama,
            kurva: Curves.linear,
            child: ColoredBox(color: w.laut),
          ),
        ),
      ),
    );
  }
}
