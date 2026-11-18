import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_prototype/shell/halaman_a4.dart';
import 'package:palakat_prototype/shell/halaman_web.dart';
import 'package:palakat_prototype/shell/kendali.dart';
import 'package:palakat_prototype/shell/kepala_ponsel.dart';
import 'package:palakat_prototype/shell/layar_ponsel.dart';
import 'package:palakat_prototype/shell/nav_samping.dart';
import 'package:palakat_prototype/shell/panel_samping.dart';
import 'package:palakat_prototype/shell/ponsel_tab_bar.dart';
import 'package:palakat_prototype/shell/prototipe_state.dart';
import 'package:palakat_prototype/shell/tautan.dart';
import 'package:palakat_prototype/theme/palakat_tema.dart';

const w = PalakatWarna.terang;

Future<GoRouter> pasang(
  WidgetTester t,
  Size layar,
  List<RouteBase> anak,
  String awal, {
  PrototypeState? keadaan,
}) async {
  t.view.physicalSize = layar;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final r = GoRouter(
    initialLocation: awal,
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SizedBox(), routes: anak),
    ],
  );
  addTearDown(r.dispose);
  await t.pumpWidget(
    PrototipeLingkup(
      keadaan: keadaan ?? PrototypeState(),
      child: MaterialApp.router(
        theme: palakatTema(Brightness.light),
        routerConfig: r,
      ),
    ),
  );
  await t.pumpAndSettle();
  return r;
}

GoRoute web(String stem, int aktif) => GoRoute(
  path: stem,
  builder: (_, _) => HalamanWeb(
    jabatanKosong: true,
    nav: NavSamping(
      item: navKeuangan,
      aktif: aktif,
      pengguna: const PenggunaKeuangan(),
    ),
    isi: [Text('isi $stem')],
  ),
);

final rutesWeb = [web('WebBeranda', 0), web('WebRekonsiliasi', 3)];

Color? isiItem(WidgetTester t, String teks) {
  final kotak = t.widget<Container>(
    find.ancestor(of: find.text(teks), matching: find.byType(Container)).first,
  );
  return (kotak.decoration as BoxDecoration?)?.color;
}

void main() {
  group('NavSamping', () {
    testWidgets('1440: full-height column, active item tinta, go on tap', (
      t,
    ) async {
      final r = await pasang(
        t,
        const Size(1440, 1000),
        rutesWeb,
        '/WebBeranda',
      );
      expect(find.text('Menu'), findsNothing);
      for (final i in navKeuangan) {
        expect(find.text(i.teks), findsOneWidget);
      }
      expect(isiItem(t, 'Beranda'), w.tinta);
      expect(isiItem(t, 'Rekonsiliasi'), isNull);
      final nav = t.getRect(find.byType(NavSamping));
      expect(nav.width, closeTo(220 + 660 / 1000, 1e-9));
      expect(nav.height, 1000);
      expect(t.getTopLeft(find.text('isi WebBeranda')).dx, nav.right + 40);
      expect(find.textContaining('Meiske L.', findRichText: true), findsOne);

      await t.tap(find.text('Rekonsiliasi'));
      await t.pump();
      expect(tumpukanHalaman(r), ['/', '/WebRekonsiliasi']);
      expect(isiItem(t, 'Rekonsiliasi'), w.tinta);
    });

    testWidgets('self item calls diSini and does not navigate', (t) async {
      var kali = 0;
      final r = await pasang(t, const Size(1440, 1000), [
        GoRoute(
          path: 'WebTerbatas',
          builder: (_, _) => HalamanWeb(
            nav: NavSamping(
              item: navTerbatas,
              aktif: 0,
              pengguna: const PenggunaNav(tebal: 'Dkn. Olga Tamba'),
              diSini: () => kali++,
            ),
            isi: const [],
          ),
        ),
      ], '/WebTerbatas');
      await t.tap(find.text('Laporan'));
      await t.pump();
      expect(kali, 1);
      expect(tumpukanHalaman(r), ['/', '/WebTerbatas']);
    });

    testWidgets('jabatanKosong: web banner and Operator footer', (t) async {
      final s = PrototypeState()..jabatanKosong = true;
      await pasang(
        t,
        const Size(1440, 1000),
        rutesWeb,
        '/WebBeranda',
        keadaan: s,
      );
      expect(
        find.textContaining(
          'Anda menjalankan jabatan kosong',
          findRichText: true,
        ),
        findsOne,
      );
      expect(
        find.textContaining('Yanti Sumual · Operator', findRichText: true),
        findsOne,
      );
      s.jabatanKosong = false;
      await t.pump();
      expect(
        find.textContaining(
          'Anda menjalankan jabatan kosong',
          findRichText: true,
        ),
        findsNothing,
      );
    });

    for (final lebar in [860.0, 390.0]) {
      testWidgets('$lebar: top bar, Menu toggles, item navigates closed', (
        t,
      ) async {
        final r = await pasang(t, Size(lebar, 900), rutesWeb, '/WebBeranda');
        expect(find.text('Menu'), findsOneWidget);
        expect(find.text('Uang Muka dan Titipan'), findsNothing);
        expect(t.getSize(find.byType(NavSamping)).width, lebar);
        final semantik = t.ensureSemantics();
        expect(
          t.getSemantics(find.bySemanticsLabel('Menu')),
          isSemantics(isToggled: false, hasToggledState: true),
        );

        await t.tap(find.text('Menu'));
        await t.pump();
        expect(find.text('Tutup menu'), findsOneWidget);
        expect(find.text('Uang Muka dan Titipan'), findsOneWidget);
        expect(find.textContaining('Meiske L.', findRichText: true), findsOne);
        expect(
          t.getSemantics(find.bySemanticsLabel('Menu')),
          isSemantics(isToggled: true, hasToggledState: true),
        );
        semantik.dispose();

        // Back closes the open menu first.
        await t.binding.handlePopRoute();
        await t.pump();
        expect(find.text('Menu'), findsOneWidget);
        expect(tumpukanHalaman(r), ['/', '/WebBeranda']);

        await t.tap(find.text('Menu'));
        await t.pump();
        await t.tap(find.text('Rekonsiliasi'));
        await t.pumpAndSettle();
        expect(tumpukanHalaman(r), ['/', '/WebRekonsiliasi']);
        expect(find.text('Menu'), findsOneWidget);
        expect(find.text('Uang Muka dan Titipan'), findsNothing);
      });
    }
  });

  group('PonselTabBar', () {
    GoRoute ponsel(String stem) => GoRoute(
      path: stem,
      builder: (_, _) => LayarPonsel(
        jabatanKosong: true,
        overlay: [
          if (stem == 'Lainnya')
            PonselTabBar(
              aktif: TabPonsel.lainnya,
              beranda: (isi) =>
                  Tautan(ke: 'Main', cara: Cara.ganti, child: isi),
              transaksi: (isi) =>
                  Tautan(ke: 'Main', cara: Cara.ganti, child: isi),
              catat: (isi) => Tautan(
                ke: 'Main',
                cara: Cara.ganti,
                label: 'Catat transaksi',
                radius: 999,
                child: isi,
              ),
              diameterCatat: 66,
            ),
        ],
        child: Text('layar $stem'),
      ),
    );

    for (final lebar in [390.0, 860.0, 1440.0]) {
      testWidgets('$lebar: Lainnya active, Bulan and Catat link', (t) async {
        final r = await pasang(t, Size(lebar, 844), [
          ponsel('Lainnya'),
          ponsel('Main'),
          ponsel('TutupBuku'),
        ], '/Lainnya');
        Color warna(String s) => t.widget<Text>(find.text(s)).style!.color!;
        expect(warna('Lainnya'), w.laut);
        expect(warna('Bulan'), w.tinta3);
        expect(warna('Beranda'), w.tinta3);

        final bar = t.getRect(
          find
              .descendant(
                of: find.byType(PonselTabBar),
                matching: find.byType(SizedBox),
              )
              .first,
        );
        expect(bar.bottom, 844);
        expect(bar.height, 84 + 13);
        expect(bar.width, lebar);
        final semantik = t.ensureSemantics();
        final catat = find.bySemanticsLabel('Catat transaksi');
        final lingkaran = t.getRect(catat);
        expect(lingkaran.top, bar.top);
        expect(lingkaran.size, const Size(66, 66));
        semantik.dispose();

        await t.tap(find.text('Bulan'));
        await t.pumpAndSettle();
        expect(tumpukanHalaman(r), ['/', '/TutupBuku']);

        r.go('/Lainnya');
        await t.pumpAndSettle();
        await t.tap(find.text('Lainnya')); // the active item is not a link
        await t.pump();
        expect(tumpukanHalaman(r), ['/', '/Lainnya']);

        // The lifted part of the circle, above the 84 px bar, is tappable.
        await t.tapAt(Offset(lingkaran.center.dx, bar.top + 6));
        await t.pumpAndSettle();
        expect(tumpukanHalaman(r), ['/', '/Main']);
      });
    }

    testWidgets('phone jabatanKosong strip follows the global switch', (
      t,
    ) async {
      final s = PrototypeState();
      await pasang(
        t,
        const Size(390, 844),
        [ponsel('Main')],
        '/Main',
        keadaan: s,
      );
      expect(
        find.textContaining('Menjalankan jabatan kosong', findRichText: true),
        findsNothing,
      );
      s.jabatanKosong = true;
      await t.pump();
      expect(
        find.textContaining('Menjalankan jabatan kosong', findRichText: true),
        findsOne,
      );
    });
  });

  group('Tautan', () {
    var diri = 0;
    Widget halaman(String nama) => Column(
      children: [
        Text('di $nama'),
        Tautan(ke: 'B', child: const Text('dorong B')),
        Tautan(ke: 'C', cara: Cara.ganti, child: const Text('ganti C')),
        Tautan(ke: 'A', cara: Cara.naik, child: const Text('naik A')),
        Tautan(ke: nama, diSini: () => diri++, child: const Text('diri')),
      ],
    );
    final rute = <RouteBase>[
      GoRoute(path: 'A', builder: (_, _) => halaman('A')),
      GoRoute(
        path: 'B',
        builder: (_, _) => halaman('B'),
        routes: [GoRoute(path: 'x', builder: (_, _) => halaman('B/x'))],
      ),
      GoRoute(path: 'C', builder: (_, _) => halaman('C')),
    ];
    const layar = Size(390, 844);

    testWidgets('dorong pushes, naik pops to the page below', (t) async {
      final r = await pasang(t, layar, rute, '/A');
      await t.tap(find.text('dorong B'));
      await t.pumpAndSettle();
      expect(tumpukanHalaman(r), ['/', '/A', '/B']);
      await t.tap(find.text('naik A'));
      await t.pumpAndSettle();
      expect(tumpukanHalaman(r), ['/', '/A']);
    });

    testWidgets('naik goes when the page below is not the target', (t) async {
      final r = await pasang(t, layar, rute, '/C');
      await t.tap(find.text('naik A'));
      await t.pumpAndSettle();
      expect(tumpukanHalaman(r), ['/', '/A']);
    });

    testWidgets('kembaliKe pops to a child route of the target', (t) async {
      final r = await pasang(t, layar, rute, '/B/x');
      r.push('/C');
      await t.pumpAndSettle();
      t.element(find.text('di C')).kembaliKe('/B');
      await t.pumpAndSettle();
      expect(tumpukanHalaman(r), ['/', '/B', '/B/x']);
    });

    testWidgets('ganti replaces the stack', (t) async {
      final r = await pasang(t, layar, rute, '/A');
      r.push('/B');
      await t.pumpAndSettle();
      await t.tap(find.text('ganti C').last);
      await t.pumpAndSettle();
      expect(tumpukanHalaman(r), ['/', '/C']);
    });

    testWidgets('self link runs diSini and stays', (t) async {
      final r = await pasang(t, layar, rute, '/A');
      diri = 0;
      await t.tap(find.text('diri'));
      await t.pumpAndSettle();
      expect(diri, 1);
      expect(tumpukanHalaman(r), ['/', '/A']);
    });

    testWidgets('dorong to a board in the stack pops down and resets it', (
      t,
    ) async {
      final r = await pasang(t, layar, rute, '/B/x');
      r.push('/C');
      await t.pumpAndSettle();
      var ulang = 0;
      ulangPapan['B'] = () => ulang++;
      addTearDown(() => ulangPapan.remove('B'));
      await t.tap(find.text('dorong B').last);
      await t.pumpAndSettle();
      expect(tumpukanHalaman(r), ['/', '/B']);
      expect(ulang, 1);
    });
  });

  testWidgets('re-entry pops through a ShellRoute board', (t) async {
    Widget hal(String n) => Column(
      children: [
        Text('di $n'),
        Tautan(ke: 'B', child: const Text('dorong B')),
      ],
    );
    final r = await pasang(t, const Size(390, 844), [
      ShellRoute(
        builder: (_, _, child) => child,
        routes: [
          GoRoute(
            path: 'B',
            builder: (_, _) => hal('B'),
            routes: [GoRoute(path: 'x', builder: (_, _) => hal('B/x'))],
          ),
        ],
      ),
      GoRoute(path: 'C', builder: (_, _) => hal('C')),
    ], '/B/x');
    r.push('/C');
    await t.pumpAndSettle();
    expect(tumpukanHalaman(r), ['/', '/B', '/B/x', '/C']);
    var ulang = 0;
    ulangPapan['B'] = () => ulang++;
    addTearDown(() => ulangPapan.remove('B'));
    await t.tap(find.text('dorong B').last);
    await t.pumpAndSettle();
    expect(tumpukanHalaman(r), ['/', '/B']);
    expect(ulang, 1);
    expect(find.text('di B'), findsOneWidget);
  });

  testWidgets('KepalaPonsel: back is an up link; self back runs diSini', (
    t,
  ) async {
    var diri = 0;
    GoRoute hal(String stem, String ke) => GoRoute(
      path: stem,
      builder: (_, _) => LayarPonsel(
        child: KepalaPonsel(
          judul: 'judul $stem',
          kembaliKe: ke,
          labelKembali: 'Kembali ke $ke',
          diSini: () => diri++,
        ),
      ),
    );
    final r = await pasang(t, const Size(390, 844), [
      hal('Lainnya', 'Lainnya'),
      hal('Laporan', 'Lainnya'),
    ], '/Lainnya');
    r.push('/Laporan');
    await t.pumpAndSettle();
    final semantik = t.ensureSemantics();
    final kembali = find.bySemanticsLabel('Kembali ke Lainnya').last;
    expect(t.getSize(kembali), const Size(44, 44));
    semantik.dispose();
    await t.tap(kembali);
    await t.pumpAndSettle();
    expect(tumpukanHalaman(r), ['/', '/Lainnya']);
    await t.tap(find.bySemanticsLabel('Kembali ke Lainnya'));
    await t.pump();
    expect(diri, 1);
    expect(tumpukanHalaman(r), ['/', '/Lainnya']);
  });

  testWidgets('PanelSamping: framed, boxed and AI boxes', (t) async {
    Future<BoxDecoration> kotak(PanelSamping p) async {
      await t.pumpWidget(
        MaterialApp(theme: palakatTema(Brightness.light), home: p),
      );
      return t.widget<Container>(find.byType(Container)).decoration!
          as BoxDecoration;
    }

    var d = await kotak(
      const PanelSamping(berbingkai: true, anak: [Text('a')]),
    );
    expect(d.border, Border.all(color: w.tinta, width: 1.5));
    d = await kotak(const PanelSamping(kotak: true, anak: [Text('a')]));
    expect(d.border, Border.all(color: w.garis));
    expect(d.color, w.permukaan);
    d = await kotak(const PanelSamping(ai: true, anak: [Text('a')]));
    expect(d.color, w.lautLembut);
    expect(d.border, isNull);
    expect(d.borderRadius, BorderRadius.circular(18));
  });

  testWidgets('HalamanA4: header, footer, light paper', (t) async {
    t.view.physicalSize = const Size(1440, 1300);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        theme: palakatTema(Brightness.dark),
        home: const HalamanA4(
          ukuran: Size(794, 1123),
          kode: 'F01 · LAPORAN RESMI',
          judul: 'LAPORAN PERBENDAHARAAN BULANAN',
          subjudul: 'Jemaat Karunia',
          kanan: ['ID SNP-2026-10-01'],
          kakiKanan: 'F01 · halaman 1 dari 1',
          isi: [Text('isi')],
        ),
      ),
    );
    expect(
      find.text(
        'Palakat · format bawaan aplikasi, bukan formulir resmi GMIM · Jemaat Karunia',
      ),
      findsOne,
    );
    expect(find.text('F01 · halaman 1 dari 1'), findsOne);
    final kertas = t.widget<ColoredBox>(
      find
          .ancestor(of: find.text('isi'), matching: find.byType(ColoredBox))
          .first,
    );
    expect(kertas.color, w.permukaan);
  });
}
