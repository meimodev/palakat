import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_prototype/motion/halaman.dart';
import 'package:palakat_prototype/motion/hitung.dart';
import 'package:palakat_prototype/motion/kerangka.dart';
import 'package:palakat_prototype/motion/ulang.dart';
import 'package:palakat_prototype/motion/urutan.dart';
import 'package:palakat_prototype/theme/palakat_tema.dart';

Widget _bungkus(Widget anak, {bool mati = false}) => MediaQuery(
  data: MediaQueryData(disableAnimations: mati),
  child: Theme(
    data: palakatTema(Brightness.light),
    child: Directionality(textDirection: TextDirection.ltr, child: anak),
  ),
);

double _opasitas(WidgetTester tester, Finder f) => tester
    .widget<Opacity>(
      find.descendant(of: f, matching: find.byType(Opacity)).first,
    )
    .opacity;

const _kotak = SizedBox(width: 10, height: 10);

void main() {
  test('1. named motions equal their tokens', () {
    expect(PalakatMotion.sentuh, const Duration(milliseconds: 160));
    expect(PalakatMotion.pindahLayar, const Duration(milliseconds: 280));
    expect(PalakatMotion.kait, const Duration(milliseconds: 450));
    expect(PalakatMotion.tinta, const Duration(milliseconds: 700));
    expect(PalakatMotion.segelTahan, const Duration(milliseconds: 1600));
    expect(PalakatMotion.segel, const Duration(milliseconds: 900));
    expect(PalakatMotion.keluar, const Cubic(0.2, 0.8, 0.2, 1));
  });

  testWidgets(
    '2. Gerak holds the 0 % frame during its delay and the 100 % frame after',
    (tester) async {
      await tester.pumpWidget(
        _bungkus(
          const Gerak(
            Kerangka.muncul,
            lama: Duration(milliseconds: 300),
            tunda: Duration(milliseconds: 500),
            child: _kotak,
          ),
        ),
      );
      final g = find.byType(Gerak);
      expect(_opasitas(tester, g), 0);
      await tester.pump(const Duration(milliseconds: 400));
      expect(_opasitas(tester, g), 0);
      await tester.pump(
        const Duration(milliseconds: 250),
      ); // timer fires, controller starts
      await tester.pump(const Duration(milliseconds: 400));
      expect(_opasitas(tester, g), 1);
    },
  );

  testWidgets('2. cap A ends at −3°, sapu ends transparent, gelap ends tinta', (
    tester,
  ) async {
    late BuildContext c;
    await tester.pumpWidget(
      _bungkus(
        Builder(
          builder: (ctx) {
            c = ctx;
            return const SizedBox();
          },
        ),
      ),
    );
    final cap = Kerangka.cap(c, 1, PalakatMotion.keluar, _kotak) as Opacity;
    final putar = cap.child! as Transform;
    expect(cap.opacity, 1);
    expect(
      math.atan2(putar.transform.storage[1], putar.transform.storage[0]),
      closeTo(-3 * math.pi / 180, 1e-9),
    );
    expect((Kerangka.sapu(c, 1, Curves.easeOut, _kotak) as Opacity).opacity, 0);
    final gelap = Kerangka.gelap((w) => w.kertas)(
      c,
      1,
      Curves.easeOut,
      _kotak,
    ) as ColoredBox;
    expect(gelap.color, PalakatWarna.terang.tinta);
  });

  testWidgets(
    '3. under reduce motion everything is at its end or still on the first frame',
    (tester) async {
      double? tUlang = -1;
      await tester.pumpWidget(
        _bungkus(
          mati: true,
          Column(
            children: [
              Gerak(
                Kerangka.cap,
                key: ValueKey('cap'),
                lama: Duration(milliseconds: 550),
                tunda: Duration(milliseconds: 350),
                kurva: PalakatMotion.keluar,
                child: _kotak,
              ),
              Ulang(
                periode: const Duration(seconds: 1),
                tunda: const Duration(milliseconds: 200),
                builder: (_, t) {
                  tUlang = t;
                  return _kotak;
                },
              ),
              Hitung(
                dari: 100,
                nilai: 500,
                lama: const Duration(milliseconds: 780),
                tunda: const Duration(milliseconds: 750),
                builder: (_, n) => Text('$n'),
              ),
              const TitikAI(),
              const Denyut(child: _kotak),
              const Putar(child: _kotak),
              const SizedBox(width: 104, height: 104, child: SegelGembok()),
              const SizedBox(width: 88, height: 88, child: LingkarSelesai()),
            ],
          ),
        ),
      );
      expect(_opasitas(tester, find.byKey(const ValueKey('cap'))), 1);
      expect(tUlang, isNull);
      expect(find.text('500'), findsOneWidget);
      for (final o in tester.widgetList<Opacity>(
        find.descendant(
          of: find.byType(TitikAI),
          matching: find.byType(Opacity),
        ),
      )) {
        expect(o.opacity, 1);
      }
      expect(_opasitas(tester, find.byType(Denyut)), 1);
      expect(
        tester.binding.transientCallbackCount,
        0,
        reason: 'no ticker runs',
      );
    },
  );

  testWidgets('3. Ulang stops when reduce motion turns on mid-run', (
    tester,
  ) async {
    double? tUlang;
    Widget ulang(bool mati) => _bungkus(
      mati: mati,
      Ulang(
        periode: const Duration(seconds: 1),
        builder: (_, t) {
          tUlang = t;
          return _kotak;
        },
      ),
    );
    await tester.pumpWidget(ulang(false));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tUlang, isNotNull);
    await tester.pumpWidget(ulang(true));
    expect(tUlang, isNull);
    expect(tester.binding.transientCallbackCount, 0);
  });

  test('4. ruas applies the curve per segment: cap A scale at t = .55 is exactly .94', () {
    expect(ruas(.55, 0, .55, PalakatMotion.keluar), 1);
    expect(ruas(.55, .55, 1, PalakatMotion.keluar), 0);
    expect(antara(.94, 1, ruas(.55, .55, 1, PalakatMotion.keluar)), .94);
  });

  testWidgets('4. cap A frame at t = .55', (tester) async {
    late BuildContext c;
    await tester.pumpWidget(
      Builder(
        builder: (ctx) {
          c = ctx;
          return const SizedBox();
        },
      ),
    );
    final cap = Kerangka.cap(c, .55, PalakatMotion.keluar, _kotak) as Opacity;
    final skala = (cap.child! as Transform).child! as Transform;
    expect(skala.transform.storage[0], .94);
  });

  testWidgets(
    '5. Hitung counts 24615000 → 24600000 over 660 ms and continues mid-count',
    (tester) async {
      int? tampil;
      Widget hitung(int nilai) => _bungkus(
        Hitung(
          dari: 24615000,
          nilai: nilai,
          builder: (_, n) {
            tampil = n;
            return Text('$n');
          },
        ),
      );
      await tester.pumpWidget(hitung(24600000));
      expect(tampil, 24615000);
      await tester.pump(const Duration(milliseconds: 330));
      expect(tampil, greaterThan(24600000));
      expect(tampil, lessThan(24615000));
      await tester.pump(const Duration(milliseconds: 330));
      expect(tampil, 24600000);

      await tester.pumpWidget(hitung(24615000));
      await tester.pump(const Duration(milliseconds: 200));
      final tengah = tampil!;
      expect(tengah, greaterThan(24600000));
      await tester.pumpWidget(hitung(24000000));
      expect(
        tampil,
        tengah,
        reason: 'a new target counts on from the figure on screen',
      );
      await tester.pump(const Duration(milliseconds: 660));
      expect(tampil, 24000000);
    },
  );

  testWidgets('5. Hitung waits for its delay showing the old figure', (
    tester,
  ) async {
    int? tampil;
    await tester.pumpWidget(
      _bungkus(
        Hitung(
          dari: 100,
          nilai: 200,
          lama: const Duration(milliseconds: 780),
          tunda: const Duration(milliseconds: 750),
          builder: (_, n) => Text('${tampil = n}'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(tampil, 100);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 800));
    expect(tampil, 200);
  });

  testWidgets('5. Hitung exposes only the final figure to assistive tech', (
    tester,
  ) async {
    final h = tester.ensureSemantics();
    await tester.pumpWidget(
      _bungkus(Hitung(dari: 0, nilai: -15000, builder: (_, n) => Text('$n'))),
    );
    expect(tester.getSemantics(find.byType(Hitung)).value, '−Rp15.000');
    await tester.pump(const Duration(seconds: 1));
    h.dispose();
  });

  testWidgets('3. Gerak jumps to its end when reduce motion turns on mid-run', (
    tester,
  ) async {
    Widget gerak(bool mati) => _bungkus(
      mati: mati,
      const Gerak(
        Kerangka.pudar,
        key: ValueKey('g'),
        lama: Duration(milliseconds: 300),
        tunda: Duration(milliseconds: 500),
        child: _kotak,
      ),
    );
    await tester.pumpWidget(gerak(false));
    await tester.pump(const Duration(milliseconds: 200));
    expect(_opasitas(tester, find.byType(Gerak)), 0);
    await tester.pumpWidget(gerak(true));
    expect(_opasitas(tester, find.byType(Gerak)), 1);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('3. sequence pieces show their end state under reduce motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      _bungkus(
        mati: true,
        const Column(
          children: [
            SizedBox(
              width: 100,
              height: 40,
              child: Stack(children: [_kotak, SapuTinta()]),
            ),
            SegelGembok(),
            SizedBox(width: 200, child: BatangIsi(lama: Duration(seconds: 2))),
          ],
        ),
      ),
    );
    expect(_opasitas(tester, find.byType(SapuTinta)), 0);
    final kunci = tester
        .widgetList<Opacity>(
          find.descendant(
            of: find.byType(SegelGembok),
            matching: find.byType(Opacity),
          ),
        )
        .single;
    expect(kunci.opacity, 1);
    expect(
      tester
          .widget<FractionallySizedBox>(find.byType(FractionallySizedBox))
          .widthFactor,
      1,
    );
    expect(find.bySemanticsLabel('Buku sudah ditutup'), findsOneWidget);
  });

  testWidgets(
    '3. switching reduce motion off does not replay a finished count',
    (tester) async {
      int? tampil;
      Widget hitung(bool mati) => _bungkus(
        mati: mati,
        Hitung(dari: 100, nilai: 200, builder: (_, n) => Text('${tampil = n}')),
      );
      await tester.pumpWidget(hitung(true));
      expect(tampil, 200);
      await tester.pumpWidget(hitung(false));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tampil, 200);
    },
  );

  testWidgets(
    'balik: mid-flip the bottom edge is narrower, as in the browser',
    (tester) async {
      late BuildContext c;
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            c = ctx;
            return const SizedBox();
          },
        ),
      );
      final o = Kerangka.balik(c, .5, Curves.linear, _kotak) as Opacity;
      final m = (o.child! as Transform).transform;
      // Points relative to the hinge (top centre); top corners stay put.
      expect(MatrixUtils.transformPoint(m, const Offset(50, 0)).dx, 50);
      expect(
        MatrixUtils.transformPoint(m, const Offset(50, 60)).dx,
        lessThan(50),
      );
    },
  );

  group('7. halaman', () {
    Future<Page<void>> halamanUntuk(
      WidgetTester tester, {
      Bingkai? kerangka,
      bool mati = false,
    }) async {
      late Page<void> hasil;
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (c, s) =>
                hasil = halaman(c, s, const SizedBox(), kerangka: kerangka),
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: mati),
            child: child!,
          ),
        ),
      );
      return hasil;
    }

    testWidgets('phone board: CustomTransitionPage 280 ms, instant reverse', (
      tester,
    ) async {
      final p = await halamanUntuk(tester, kerangka: Kerangka.masuk);
      expect(p, isA<CustomTransitionPage<void>>());
      p as CustomTransitionPage<void>;
      expect(p.transitionDuration, const Duration(milliseconds: 280));
      expect(p.reverseTransitionDuration, Duration.zero);
    });

    testWidgets('laptop board: NoTransitionPage', (tester) async {
      expect(await halamanUntuk(tester), isA<NoTransitionPage<void>>());
    });

    testWidgets('reduce motion: NoTransitionPage', (tester) async {
      expect(
        await halamanUntuk(tester, kerangka: Kerangka.masuk, mati: true),
        isA<NoTransitionPage<void>>(),
      );
    });
  });
}
