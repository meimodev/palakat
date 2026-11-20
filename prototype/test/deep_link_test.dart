import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_prototype/boards.dart';
import 'package:palakat_prototype/main.dart';
import 'package:palakat_prototype/mock/kolaborasi.dart';
import 'package:palakat_prototype/router.dart';
import 'package:palakat_prototype/screens/lanjut/laporan_tabel.dart';
import 'package:palakat_prototype/shell/prototipe_state.dart';

/// Every child route opened directly by URL (a web reload or a pasted link) builds
/// without exceptions or overflow at its board's frame size, lands on the child or
/// on a valid view of its board, and survives Back.
///
/// Run one route: fvm flutter test test/deep_link_test.dart --plain-name '/Koreksi/kejadian'
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Path parameters, filled from the mock data each parent lists.
  final isi = <String, String>{
    ':id': 'um1',
    ':no': terbatasBaris.first.$1,
    ':f': laporanDaftar.first.$1,
  };
  // Views that need earlier steps in the initial state: they replace the URL
  // with the board's root (navigation.md 5.4 and the screen specs).
  const keParent = {
    '/Main/detail',
    '/Awal/saldo',
    '/Koreksi/hasil',
    '/Koreksi/kejadian',
    '/HitungKas/banding',
    '/Kamera/unggah',
  };
  final anak = <(String stem, String url)>[];
  void jelajah(List<RouteBase> rute, String? stem) {
    for (final r in rute) {
      if (r is ShellRoute) {
        jelajah(r.routes, stem);
      } else if (r is GoRoute) {
        if (stem != null) {
          anak.add((
            stem,
            '/$stem/${r.path.split('/').map((s) => isi[s] ?? s).join('/')}',
          ));
        } else if (papanMenurutStem.containsKey(r.path)) {
          jelajah(r.routes, r.path);
        } else {
          jelajah(r.routes, null);
        }
      }
    }
  }

  jelajah(buatRouter().configuration.routes, null);
  test('found the child routes', () => expect(anak, hasLength(31)));

  for (final (stem, url) in anak) {
    testWidgets(url, (tester) async {
      final p = papanMenurutStem[stem]!;
      tester.view.physicalSize = Size(p.lebar, p.tinggi);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final keadaan = PrototypeState();
      final router = buatRouter();
      await tester.pumpWidget(
        PalakatPrototipe(router: router, keadaan: keadaan),
      );
      router.go(url);
      Future<void> pompa() async {
        // Bounded pumps, not pumpAndSettle: loops (Ulang, titik, denyut, putar) never settle.
        for (var i = 0; i < 30; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      await pompa();
      expect(tester.takeException(), isNull);
      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        keParent.contains(url) ? '/$stem' : url,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == '${stem}Screen',
        ),
        findsWidgets,
      );

      await tester.binding.handlePopRoute();
      await pompa();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 10));
      keadaan.dispose();
    });
  }
}
