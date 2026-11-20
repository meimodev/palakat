// The flow-test harness (README 8.1). Every flow test starts the real app
// with bukaAplikasi, signs in through the picker and drives the UI.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/app.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/app/tata.dart';
import 'package:palakat_prototype/core/clock.dart';
import 'package:palakat_prototype/providers/clock.dart';
import 'package:palakat_prototype/providers/layout.dart';
import 'package:palakat_prototype/providers/session.dart';
import 'package:palakat_prototype/widgets/kecil.dart';

export 'package:palakat_prototype/app/tata.dart' show Tata;
export 'package:palakat_prototype/providers/session.dart' show Persona;

/// The story date: 16/11/2026 12.05 WITA, where board and seed dates agree.
final jangkarA = DateTime.utc(2026, 11, 16, 12, 5);

/// Year boundary: 05/01/2027 10.00 WITA.
final jangkarB = DateTime.utc(2027, 1, 5, 10);

/// Short month before: 03/03/2027 09.00 WITA.
final jangkarC = DateTime.utc(2027, 3, 3, 9);

/// Day 1 of a month: 01/06/2027 08.00 WITA.
final jangkarD = DateTime.utc(2027, 6, 1, 8);

/// The test view size of each layout (README 3.2).
const ukuranTata = {
  Tata.ponsel: Size(390, 844),
  Tata.tablet: Size(834, 1112),
  Tata.web: Size(1440, 1000),
};

/// Pumps the app with a fixed clock at [saat] (default [jangkarA]) and the
/// layout [tata] at its view size, and returns the app's container so the test
/// can read end states. The picker shows.
Future<ProviderContainer> bukaAplikasi(
  WidgetTester tester, {
  Tata tata = Tata.ponsel,
  DateTime? saat,
}) async {
  tester.view.physicalSize = ukuranTata[tata]!;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(FixedClock(saat ?? jangkarA)),
        layoutProvider.overrideWithValue(tata),
      ],
      child: const PalakatApp(),
    ),
  );
  await tester.pumpAndSettle();
  return _wadah(tester);
}

ProviderContainer _wadah(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(PalakatApp)));

/// Taps [p] on the picker; the role home opens.
Future<void> masukSebagai(WidgetTester tester, Persona p) async {
  expect(find.text('Masuk sebagai'), findsOneWidget, reason: 'picker');
  await tekan(tester, p.nama);
}

/// Signs out the way a person does: Akun, "Keluar", then "Keluar" again to
/// confirm. Back on the picker; every other state is kept.
Future<void> keluar(WidgetTester tester) async {
  _wadah(tester).read(routerProvider).go(Layar.akun.lokasi());
  await tester.pumpAndSettle();
  await tekan(tester, 'Keluar');
  expect(find.text('Keluar dari perangkat ini?'), findsOneWidget);
  await tekan(tester, 'Keluar');
  expect(find.text('Masuk sebagai'), findsOneWidget, reason: 'picker');
}

/// Taps the first widget showing [teks], scrolling it into view first.
Future<void> tekan(WidgetTester tester, String teks) async {
  final f = find.text(teks).first;
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Types [nilai] into the field labelled [label].
Future<void> isi(WidgetTester tester, String label, String nilai) async {
  final kotak = find.ancestor(
    of: find.text(label),
    matching: find.byType(IsianTeks),
  );
  final f = find
      .descendant(of: kotak.first, matching: find.byType(EditableText))
      .first;
  await tester.ensureVisible(f);
  await tester.enterText(f, nilai);
  await tester.pumpAndSettle();
}

/// Holds a hold-to-confirm button ([teks]) until it fills (`segelTahan`
/// 1600 ms, plus a margin).
Future<void> tahan(WidgetTester tester, String teks) async {
  final f = find.text(teks).first;
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  final g = await tester.startGesture(tester.getCenter(f));
  await tester.pump(const Duration(milliseconds: 1700));
  await g.up();
  await tester.pumpAndSettle();
}

/// Pumps past a board timer that fakes outside work (`// tiruan:`).
Future<void> tungguTiruan(WidgetTester tester, Duration d) async {
  await tester.pump(d);
  await tester.pumpAndSettle();
}

/// The location the router shows now.
String lokasiSekarang(WidgetTester tester) =>
    _wadah(tester)
        .read(routerProvider)
        .routerDelegate
        .currentConfiguration
        .uri
        .toString();
