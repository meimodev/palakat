import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_prototype/boards.dart';
import 'package:palakat_prototype/main.dart';
import 'package:palakat_prototype/router.dart';
import 'package:palakat_prototype/shell/belum_dibangun.dart';
import 'package:palakat_prototype/shell/panel_keadaan.dart';
import 'package:palakat_prototype/shell/peluncur.dart';
import 'package:palakat_prototype/shell/perangkat_prototipe.dart';
import 'package:palakat_prototype/shell/perjalanan.dart';
import 'package:palakat_prototype/shell/prototipe_state.dart';
import 'package:palakat_prototype/shell/tidak_ditemukan.dart';
import 'package:palakat_prototype/widgets/chip_pilihan.dart';
import 'package:palakat_prototype/widgets/sakelar.dart';

/// Prototype chrome: launcher, Keadaan panel, PrototypeState, unknown route.
void main() {
  Future<GoRouter> buka(
    WidgetTester tester, {
    Size ukuran = const Size(1440, 1000),
    GoRouter? router,
  }) async {
    tester.view.physicalSize = ukuran;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final r = router ?? buatRouter();
    await tester.pumpWidget(PalakatPrototipe(router: r));
    await tester.pumpAndSettle();
    return r;
  }

  Finder diPanel(Finder f) =>
      find.descendant(of: find.byType(PanelKeadaan), matching: f);
  PrototypeState keadaan(WidgetTester tester) =>
      PrototypeState.of(tester.element(find.byType(MaterialApp)));

  // navigation.md 4.3 says 127, but its own lists name 126 distinct boards.
  test('journeys: 8 roles, every stem is a board, 126 boards', () {
    expect(perjalananJabatan, hasLength(8));
    final stems = {
      for (final j in perjalananJabatan)
        for (final l in j.langkah)
          for (final e in l)
            for (final t in e.ke) t.stem,
    };
    expect(stems.where((s) => !papanMenurutStem.containsKey(s)), isEmpty);
    expect(stems, hasLength(126));
  });

  test('PrototypeState: defaults, global jabatanKosong, notifies', () {
    final k = PrototypeState();
    addTearDown(k.dispose);
    var n = 0;
    k.addListener(() => n++);
    expect(k.tweak('Main', 'bulan'), 'ramai');
    expect(k.tweak('Main', 'gagalSimpan'), false);
    k.setTweak('Main', 'bulan', 'sepi');
    expect(k.nilai('Main', 'bulan'), 'sepi');
    expect(n, 1);
    k.setTweak('Main', 'jabatanKosong', true);
    expect(k.jabatanKosong, isTrue);
    expect(k.tweak('WebBeranda', 'jabatanKosong'), true);
    expect(n, 2);
    k.gelap = true;
    expect(k.tema, ThemeMode.dark);
    expect(n, 3);
    expect(() => k.setTweak('Main', 'tidakAda', 1), throwsArgumentError);
  });

  testWidgets(
    'launcher lists 199 boards by canvas page, Komponen, and 8 roles',
    (tester) async {
      await buka(tester);
      expect(find.byType(Peluncur), findsOneWidget);
      expect(find.text('Palakat · prototipe'), findsOneWidget);
      expect(
        find.text('199 layar · data contoh, tanpa server'),
        findsOneWidget,
      );
      expect(find.text('Komponen'), findsOneWidget);
      for (final p in semuaPapan) {
        expect(find.text(p.stem), findsOneWidget, reason: p.stem);
      }
      for (final (id, nama) in halamanKanvas) {
        final n = semuaPapan.where((p) => p.halaman == id).length;
        expect(find.text('$nama · $n layar'), findsOneWidget);
      }

      await tester.tap(find.text('Perjalanan jabatan'));
      await tester.pumpAndSettle();
      for (final j in perjalananJabatan) {
        expect(find.text(j.peran), findsOneWidget);
      }
      expect(find.text('Ponsel · 9 layar'), findsNothing);
      expect(keadaan(tester).urutPerjalanan, isTrue);
    },
  );

  testWidgets('launcher row opens its board with the launcher below', (
    tester,
  ) async {
    final r = await buka(tester);
    await tester.ensureVisible(find.text('WebBukti'));
    await tester.tap(find.text('WebBukti'));
    await tester.pumpAndSettle();
    expect(r.routerDelegate.currentConfiguration.uri.path, '/WebBukti');
    await r.routerDelegate.popRoute();
    await tester.pumpAndSettle();
    expect(find.byType(Peluncur), findsOneWidget);
  });

  testWidgets(
    'panel beside the phone frame shows the tweaks with defaults; changing one notifies',
    (tester) async {
      final r = await buka(tester);
      r.go('/Main');
      await tester.pumpAndSettle();
      final k = keadaan(tester);

      // Phone board at 1440: framed 390 × 844, panel always open.
      expect(find.byType(PanelKeadaan), findsOneWidget);
      expect(
        diPanel(find.text('1 · Harian: catat sampai bukukan')),
        findsOneWidget,
      );
      expect(diPanel(find.text('Kembali')), findsOneWidget);
      final bulan = tester.widget<ChipPilihan<String>>(
        diPanel(find.byType(ChipPilihan<String>)),
      );
      expect(bulan.label, 'bulan');
      expect(bulan.terpilih, 'ramai');
      expect([for (final p in bulan.pilihan) p.teks], ['ramai', 'sepi']);
      final gagal = tester.widget<Sakelar>(diPanel(find.byType(Sakelar)).first);
      expect(gagal.label, 'gagalSimpan');
      expect(gagal.nilai, isFalse);
      expect(
        diPanel(find.textContaining('Operator Yanti Sumual')),
        findsOneWidget,
      );
      expect(diPanel(find.text('Tautan masuk')), findsOneWidget);

      var n = 0;
      k.addListener(() => n++);
      await tester.tap(diPanel(find.text('sepi')));
      await tester.pumpAndSettle();
      expect(k.tweak('Main', 'bulan'), 'sepi');
      expect(n, 1);
      expect(
        tester
            .widget<ChipPilihan<String>>(
              diPanel(find.byType(ChipPilihan<String>)),
            )
            .terpilih,
        'sepi',
      );

      // Gelap switches the theme; Bingkai ponsel off moves the panel behind a handle.
      await tester.tap(diPanel(find.text('Gelap')));
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.byType(PanelKeadaan))).brightness,
        Brightness.dark,
      );
      k.bingkaiPonsel = false;
      await tester.pumpAndSettle();
      expect(find.byType(PanelKeadaan), findsNothing);
      await tester.tap(find.bySemanticsLabel('Keadaan'));
      await tester.pumpAndSettle();
      expect(find.byType(PanelKeadaan), findsOneWidget);
    },
  );

  testWidgets(
    'phone frame: 700 wide uses the floating button; a short window scales the frame',
    (tester) async {
      final r = await buka(tester, ukuran: const Size(700, 900));
      r.go('/Main');
      await tester.pumpAndSettle();
      expect(find.byType(PanelKeadaan), findsNothing);
      await tester.tap(find.bySemanticsLabel('Keadaan'));
      await tester.pumpAndSettle();
      expect(find.byType(PanelKeadaan), findsOneWidget);

      tester.view.physicalSize = const Size(1440, 600);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final layar = tester.getRect(find.byType(BelumDibangun));
      expect(
        layar.height,
        closeTo(552, 0.5),
      ); // (600 − 48) high: scaled down by FittedBox, still 390 × 844 inside
      expect(
        MediaQuery.sizeOf(tester.element(find.byType(BelumDibangun))),
        const Size(390, 844),
      );
    },
  );

  testWidgets(
    'laptop board: floating button opens the panel; Semua layar returns to the launcher',
    (tester) async {
      final r = await buka(tester);
      r.go('/WebBeranda');
      await tester.pumpAndSettle();
      expect(find.byType(PanelKeadaan), findsNothing);
      await tester.tap(find.bySemanticsLabel('Keadaan'));
      await tester.pumpAndSettle();
      expect(
        diPanel(find.text('jabatanKosong')),
        findsNothing,
      ); // global, shown in Semua layar
      expect(diPanel(find.text('bulan')), findsOneWidget);
      await tester.tap(diPanel(find.text('Semua layar')).first);
      await tester.pumpAndSettle();
      expect(find.byType(Peluncur), findsOneWidget);
    },
  );

  testWidgets(
    'AlatPrototipe devices appear in the panel for the top board only',
    (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const SizedBox(),
            routes: [
              GoRoute(
                path: 'Main',
                builder: (_, _) => const AlatPrototipe(
                  stem: 'Main',
                  alat: [Text('Contoh: 123456')],
                  child: SizedBox(),
                ),
              ),
            ],
          ),
        ],
      );
      await buka(tester, router: router);
      router.go('/Main');
      await tester.pumpAndSettle();
      expect(diPanel(find.text('Alat prototipe')), findsOneWidget);
      expect(diPanel(find.text('Contoh: 123456')), findsOneWidget);
      expect(diPanel(find.text('Hanya di prototipe')), findsOneWidget);
      router.go('/');
      await tester.pumpAndSettle();
      expect(keadaan(tester).perangkat.value, isEmpty);
    },
  );

  testWidgets(
    'AlatPrototipe: a child page of the same board shows its own devices; popping restores the parent\'s',
    (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const SizedBox(),
            routes: [
              GoRoute(
                path: 'Main',
                builder: (_, _) => const AlatPrototipe(
                  stem: 'Main',
                  alat: [Text('Contoh: induk')],
                  child: SizedBox(),
                ),
                routes: [
                  GoRoute(
                    path: 'catat',
                    builder: (_, _) => const AlatPrototipe(
                      stem: 'Main',
                      alat: [Text('Contoh: anak')],
                      child: SizedBox(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      await buka(tester, router: router);
      router.go('/Main');
      await tester.pumpAndSettle();
      router.push('/Main/catat');
      await tester.pumpAndSettle();
      expect(diPanel(find.text('Contoh: anak')), findsOneWidget);
      expect(diPanel(find.text('Contoh: induk')), findsNothing);
      router.pop();
      await tester.pumpAndSettle();
      expect(diPanel(find.text('Contoh: induk')), findsOneWidget);
      expect(diPanel(find.text('Contoh: anak')), findsNothing);
    },
  );

  testWidgets('full-screen phone handle: 24 × 64 drawn, 44 wide to tap', (
    tester,
  ) async {
    final r = await buka(tester, ukuran: const Size(390, 844));
    r.go('/Main');
    await tester.pumpAndSettle();
    final tekan = find.bySemanticsLabel('Keadaan');
    expect(tester.getSize(tekan), const Size(44, 64));
    expect(tester.getTopRight(tekan).dx, 390);
    await tester.tapAt(tester.getTopLeft(tekan) + const Offset(4, 32));
    await tester.pumpAndSettle();
    expect(find.byType(PanelKeadaan), findsOneWidget);
  });

  testWidgets(
    'unknown routes show Layar tidak ditemukan with a working Semua layar',
    (tester) async {
      for (final jalur in ['/Nope', '/main', '/Main.dc.html']) {
        final r = await buka(tester);
        r.go(jalur);
        await tester.pumpAndSettle();
        expect(
          find.text('Layar tidak ditemukan'),
          findsOneWidget,
          reason: jalur,
        );
        expect(find.text(jalur), findsWidgets);
        await tester.tap(
          find.descendant(
            of: find.byType(TidakDitemukanScreen),
            matching: find.text('Semua layar'),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(Peluncur), findsOneWidget);
      }
    },
  );
}
