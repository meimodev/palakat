import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_prototype/boards.dart';
import 'package:palakat_prototype/router.dart';
import 'package:palakat_prototype/shell/prototipe_state.dart';
import 'package:palakat_prototype/theme/palakat_tema.dart';

/// Screenshot of one screen for the visual-parity harness (tool/SHOTS.md).
/// Skipped unless SHOT is defined; run it through tool/app_shot.sh:
///   fvm flutter test test/shot_test.dart --dart-define=SHOT=Main
///     [--dart-define=TWEAKS=gagalSimpan=true&bulan=sepi]  (query string, values URL-encoded)
///     [--dart-define=ROUTE=/Main/child] [--dart-define=KLIK=a|b] (each URL-encoded)
///     [--dart-define=W=390 --dart-define=H=844] [--dart-define=MS=2500] [--dart-define=OUT=/abs/x.png]
const _stem = String.fromEnvironment('SHOT');
const _tweaks = String.fromEnvironment('TWEAKS');
const _route = String.fromEnvironment('ROUTE');
const _klik = String.fromEnvironment('KLIK');
const _out = String.fromEnvironment('OUT');
const _w = int.fromEnvironment('W');
const _h = int.fromEnvironment('H');
const _ms = int.fromEnvironment('MS', defaultValue: 2500);

const _fonts = {
  'PlusJakartaSans': ['Regular', 'Medium', 'SemiBold', 'Bold'],
  'IBMPlexMono': ['Regular', 'Medium', 'SemiBold'],
};

void main() {
  setUpAll(() async {
    if (_stem.isEmpty) return;
    // The real TTFs, so text is not drawn in the test font.
    for (final MapEntry(key: family, value: styles) in _fonts.entries) {
      final loader = FontLoader(family);
      for (final s in styles) {
        final bytes = File('assets/fonts/$family-$s.ttf').readAsBytesSync();
        loader.addFont(Future.value(ByteData.sublistView(bytes)));
      }
      await loader.load();
    }
  });

  testWidgets('shot $_stem', skip: _stem.isEmpty, (tester) async {
    final papan = papanMenurutStem[_stem];
    if (papan == null) throw ArgumentError.value(_stem, 'SHOT', 'not a board');
    tester.view.physicalSize = Size(
      _w > 0 ? _w.toDouble() : papan.lebar,
      _h > 0 ? _h.toDouble() : papan.tinggi,
    );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Reduced motion, like the board side: end states, loops at rest.
    final keadaan = PrototypeState()..kurangiGerak = true;
    if (_tweaks.isNotEmpty) {
      for (final MapEntry(key: nama, value: v) in Uri.splitQueryString(
        _tweaks,
      ).entries) {
        final t = papan.tweaks.where((t) => t.nama == nama).firstOrNull;
        if (t == null) {
          throw ArgumentError(
            'unknown tweak "$nama" on $_stem (have: ${papan.tweaks.map((t) => t.nama).join(', ')})',
          );
        }
        if (t.editor == 'boolean' && v != 'true' && v != 'false') {
          throw ArgumentError('tweak $nama must be true or false');
        }
        if (t.pilihan != null && !t.pilihan!.contains(v)) {
          throw ArgumentError(
            'tweak $nama=$v is not one of: ${t.pilihan!.join(' / ')}',
          );
        }
        keadaan.setTweak(_stem, nama, t.editor == 'boolean' ? v == 'true' : v);
      }
    }

    final router = buatRouter();
    final kunci = GlobalKey();
    // The app as in main.dart minus BingkaiPerangkat: only the screen, no
    // device frame and no Keadaan panel handle over it.
    await tester.pumpWidget(
      RepaintBoundary(
        key: kunci,
        child: PrototipeLingkup(
          keadaan: keadaan,
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: palakatTema(Brightness.light),
            darkTheme: palakatTema(Brightness.dark),
            themeMode: keadaan.tema,
            themeAnimationDuration: Duration.zero,
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: InheritedGoRouter(goRouter: router, child: child!),
            ),
          ),
        ),
      ),
    );
    router.go(_route.isEmpty ? '/$_stem' : _route);
    Future<void> tunggu(int ms) async {
      // Bounded pumps, not pumpAndSettle: loops never settle.
      for (var t = 0; t < ms; t += 100) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await tunggu(_ms);
    String? klikGagal;
    for (final k in _klik.split('|').where((k) => k.isNotEmpty)) {
      final teks = Uri.decodeComponent(k);
      final kena = find.textContaining(teks).hitTestable();
      final semua = find.textContaining(teks);
      if (semua.evaluate().isEmpty) {
        klikGagal =
            'KLIK: no text "$teks" (the shot shows the state before it)';
        break;
      }
      await tester.tap(
        kena.evaluate().isNotEmpty ? kena.first : semua.first,
        warnIfMissed: false,
      );
      await tunggu(1000);
    }

    final galat = tester.takeException();
    final out = _out.isNotEmpty
        ? _out
        : '${Directory.current.path}/build/shots/app/$_stem.png';
    final ro =
        kunci.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final img = await ro.toImage(pixelRatio: 1);
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      File(out)
        ..parent.createSync(recursive: true)
        ..writeAsBytesSync(data!.buffer.asUint8List());
      img.dispose();
    });
    // ignore: avoid_print
    print('SHOT $out');

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
    keadaan.dispose();
    expect(galat, isNull, reason: 'the screen threw while building');
    expect(klikGagal, isNull);
  });
}
