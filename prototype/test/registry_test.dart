import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/boards.dart';

void main() {
  final canvas = jsonDecode(
    File('../docs/design/handoff/canvas/canvas.json').readAsStringSync(),
  ) as Map;
  final manifest =
      (jsonDecode(File('../docs/build/board-manifest.json').readAsStringSync())
              as Map)['boards']
          as Map;
  final order = (canvas['order'] as List).cast<String>();

  test('199 boards in canvas order', () {
    expect(semuaPapan.length, 199);
    expect(semuaPapan.map((p) => '${p.stem}.dc.html').toList(), order);
  });

  test('titles, pages, frames and forms match canvas.json', () {
    for (final p in semuaPapan) {
      final b = (canvas['boards'] as Map)['${p.stem}.dc.html'] as Map;
      expect(p.judul, b['title'], reason: p.stem);
      expect(p.halaman, b['page'], reason: p.stem);
      expect(p.lebar, (b['w'] as num).toDouble(), reason: p.stem);
      expect(p.tinggi, (b['h'] as num).toDouble(), reason: p.stem);
      final w = b['w'], h = b['h'];
      final bentuk = (w == 390 && h == 844)
          ? Bentuk.ponsel
          : b['expand'] == 'fill'
          ? (w == 1440 ? Bentuk.laptop : Bentuk.tablet)
          : ({w, h}.containsAll([794, 1123]) ? Bentuk.a4 : Bentuk.lembar);
      expect(p.bentuk, bentuk, reason: p.stem);
    }
  });

  test('tweaks match the manifest: names, editors, options, defaults', () {
    for (final p in semuaPapan) {
      final t = (manifest['${p.stem}.dc.html'] as Map)['tweaks'] as Map;
      expect(
        p.tweaks.map((x) => x.nama).toList(),
        t.keys.toList(),
        reason: p.stem,
      );
      for (final x in p.tweaks) {
        final m = t[x.nama] as Map;
        expect(x.editor, m['editor'], reason: '${p.stem}.${x.nama}');
        expect(
          x.pilihan,
          m['options'] == null
              ? isNull
              : (m['options'] as List).map((o) => '$o').toList(),
        );
        expect(x.bawaan, m['default'], reason: '${p.stem}.${x.nama}');
      }
    }
  });

  test('1282 links, every target a board, inbound is the reverse', () {
    expect(semuaPapan.fold<int>(0, (n, p) => n + p.keluar.length), 1282);
    for (final p in semuaPapan) {
      for (final t in p.keluar) {
        expect(
          papanMenurutStem.containsKey(t),
          isTrue,
          reason: '${p.stem} → $t',
        );
        expect(papanMenurutStem[t]!.masuk, contains(p.stem));
      }
    }
  });
}
