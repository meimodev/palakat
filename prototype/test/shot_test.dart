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
import 'package:palakat_prototype/widgets/tekan.dart';

/// Screenshot of one screen for the visual-parity harness (tool/SHOTS.md).
/// Skipped unless SHOT_STEM (or --dart-define=SHOT) is set; run it through
/// tool/app_shot.sh, which sets these environment variables:
///   SHOT_STEM=Main  SHOT_TWEAKS=gagalSimpan=true&bulan=sepi (query string, values URL-encoded)
///   SHOT_ROUTE=/Main/child  SHOT_KLIK=a|b (each URL-encoded; steps `ketik:TEXT`, `tunggu:MS`)
///   SHOT_W=390 SHOT_H=844  SHOT_MS=2500  SHOT_OUT=/abs/x.png
/// The same names without the SHOT_ prefix (SHOT for the stem) work as
/// --dart-define, at the cost of a fresh compile per value set.
String _arg(String k, String bawaan) {
  final v = Platform.environment['SHOT_$k'];
  return v == null || v.isEmpty ? bawaan : v;
}

final _stem = _arg('STEM', const String.fromEnvironment('SHOT'));
final _tweaks = _arg('TWEAKS', const String.fromEnvironment('TWEAKS'));
final _route = _arg('ROUTE', const String.fromEnvironment('ROUTE'));
final _klik = _arg('KLIK', const String.fromEnvironment('KLIK'));
final _out = _arg('OUT', const String.fromEnvironment('OUT'));
final _w = int.tryParse(_arg('W', '')) ?? const int.fromEnvironment('W');
final _h = int.tryParse(_arg('H', '')) ?? const int.fromEnvironment('H');
final _gelap = _arg('GELAP', '') == '1';
final _ms =
    int.tryParse(_arg('MS', '')) ??
    const int.fromEnvironment('MS', defaultValue: 2500);

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
    // Blurred BoxShadows as in the app; flutter_test draws hard bands by
    // default. Restored before the test ends (the binding checks it).
    debugDisableShadows = false;
    final papan = papanMenurutStem[_stem];
    if (papan == null) throw ArgumentError.value(_stem, 'SHOT', 'not a board');
    tester.view.physicalSize = Size(
      _w > 0 ? _w.toDouble() : papan.lebar,
      _h > 0 ? _h.toDouble() : papan.tinggi,
    );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Reduced motion, like the board side: end states, loops at rest.
    final keadaan = PrototypeState()
      ..kurangiGerak = true
      ..tema = _gelap ? ThemeMode.dark : ThemeMode.light;
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
    final kunciAlat = GlobalKey();
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
              child: InheritedGoRouter(
                goRouter: router,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    child!,
                    // The Keadaan panel's prototype devices ("Contoh: …"),
                    // built but never painted, so a click can reach them.
                    Offstage(
                      child: Material(
                        key: kunciAlat,
                        type: MaterialType.transparency,
                        child: ValueListenableBuilder(
                          valueListenable: keadaan.perangkat,
                          builder: (_, m, _) => SingleChildScrollView(
                            child: Column(
                              children: [for (final l in m.values) ...l],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
      final langkah = Uri.decodeComponent(k);
      final jeda = RegExp(r'^tunggu:(\d+)$').firstMatch(langkah);
      if (jeda != null) {
        await tunggu(int.parse(jeda[1]!));
        continue;
      }
      if (langkah.startsWith('ketik:')) {
        final isian = find.byType(EditableText);
        final fokus = isian.evaluate().where(
          (e) => (e.widget as EditableText).focusNode.hasFocus,
        );
        if (isian.evaluate().isEmpty) {
          klikGagal ??= 'KLIK: no text field for "$langkah"';
        } else {
          await tester.enterText(
            fokus.isEmpty ? isian.first : _elemen(fokus.first),
            langkah.substring(6),
          );
          await tunggu(1000);
        }
        continue;
      }
      final e = _sasaran(langkah);
      if (e != null) {
        if (!e.$2) {
          // Off screen or under a footer: scroll it to the top first.
          await tester.ensureVisible(_elemen(e.$1));
          await tester.pump();
        }
        await tester.tap(_elemen(e.$1), warnIfMissed: false);
      } else if (_alat(kunciAlat, langkah) case final tekan?) {
        tekan();
      } else {
        // Keep going, like the board side: later steps still run.
        klikGagal ??=
            'KLIK: no text "$langkah" (the shot shows the state without it)';
        continue;
      }
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
    debugDisableShadows = true;

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
    keadaan.dispose();
    expect(galat, isNull, reason: 'the screen threw while building');
    expect(klikGagal, isNull);
  });
}

Finder _elemen(Element e) => find.byElementPredicate((x) => x == e);

/// The element a --click on [teks] taps, and whether it is hit-testable now.
/// Like support.js klik(): pressable before plain text, exact text before
/// containing, on screen before scrolled away, tree order last; then a
/// Semantics label (the board's aria-label) the same way.
(Element, bool)? _sasaran(String teks) {
  String? isi(Widget w) => switch (w) {
    Text(:final data?) => data,
    Text(:final textSpan?) => textSpan.toPlainText(),
    EditableText(:final controller) => controller.text,
    Semantics(:final properties) => properties.label,
    _ => null,
  };
  bool tekan(Element e) {
    var ya = false;
    e.visitAncestorElements((a) {
      final w = a.widget;
      ya =
          w is Tekan ||
          (w is GestureDetector && w.onTap != null) ||
          (w is Semantics &&
              (w.properties.button == true || w.properties.link == true));
      return !ya;
    });
    return ya;
  }

  for (final f in [
    find.textContaining(teks),
    find.byWidgetPredicate(
      (w) => w is Semantics && (w.properties.label ?? '').contains(teks),
    ),
  ]) {
    final semua = f.evaluate().toList();
    if (semua.isEmpty) continue;
    final kena = f.hitTestable().evaluate().toSet();
    int nilai(Element e) =>
        (tekan(e) ? 0 : 4) +
        (isi(e.widget)?.trim() == teks ? 0 : 2) +
        (kena.contains(e) ? 0 : 1);
    final e = semua.reduce((a, b) => nilai(b) < nilai(a) ? b : a);
    return (e, kena.contains(e));
  }
  return null;
}

/// The onTap of a Keadaan-panel device whose text contains [teks].
VoidCallback? _alat(GlobalKey kunci, String teks) {
  for (final e
      in find
          .descendant(
            of: find.byKey(kunci, skipOffstage: false),
            matching: find.textContaining(teks, skipOffstage: false),
            skipOffstage: false,
          )
          .evaluate()) {
    VoidCallback? tap;
    e.visitAncestorElements((a) {
      final w = a.widget;
      tap = w is Tekan ? w.onTap : (w is GestureDetector ? w.onTap : null);
      return tap == null && w.key != kunci;
    });
    if (tap != null) return tap;
  }
  return null;
}
