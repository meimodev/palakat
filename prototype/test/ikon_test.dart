import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/theme/palakat_tema.dart';
import 'package:palakat_prototype/widgets/ikon.dart';
import 'package:palakat_prototype/widgets/logo.dart';

void main() {
  for (final b in Brightness.values) {
    testWidgets('every icon builds at its size ($b)', (t) async {
      await t.pumpWidget(
        MaterialApp(
          theme: palakatTema(b),
          home: Wrap(
            children: [
              for (final e in Ikon.semua.entries)
                PalakatIkon(e.value.$1, ukuran: e.value.$2, label: e.key),
              const TandaPalakat(),
              const KataPalakat(),
            ],
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      for (final e in Ikon.semua.entries) {
        expect(
          t.getSize(find.bySemanticsLabel(e.key)),
          Size.square(e.value.$2),
        );
      }
      // SvgPicture parses off the test clock, so parse each resolved string here.
      for (final el in find.byType(PalakatIkon).evaluate()) {
        final svg = (el.widget as PalakatIkon).svg(el);
        await t.runAsync(() => SvgStringLoader(svg).loadBytes(null));
      }
    });
  }

  testWidgets('colours come from the tint and the theme', (t) async {
    final svgs = <Brightness, String>{};
    late String tinted; // built last under the light theme
    for (final b in Brightness.values) {
      await t.pumpWidget(
        MaterialApp(
          theme: palakatTema(b),
          home: Builder(
            builder: (c) {
              svgs[b] = const PalakatIkon(Ikon.tanda).svg(c);
              tinted = PalakatIkon(
                Ikon.kembali,
                warna: c.warna.bata,
                tebal: 3.4,
              ).svg(c);
              return const SizedBox();
            },
          ),
        ),
      );
      await t.pumpAndSettle(); // let MaterialApp's theme lerp finish
    }
    String hex(Color c) =>
        '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    expect(svgs[Brightness.light], contains(hex(PalakatWarna.terang.laut)));
    expect(svgs[Brightness.dark], contains(hex(PalakatWarna.gelap.laut)));
    expect(tinted, contains('stroke="${hex(PalakatWarna.terang.bata)}"'));
    expect(tinted, contains('stroke-width="3.4"'));
    expect(tinted, isNot(contains('{')));
  });

  test('no placeholder is left unresolved', () {
    const tokens = {
      'warna',
      'tebal',
      'laut',
      'diLaut',
      'bata',
      'diBata',
      'tinta',
      'tinta2',
      'tinta3',
      'putus',
      'garis',
      'permukaan',
    };
    expect(Ikon.semua, hasLength(25));
    for (final e in Ikon.semua.values) {
      for (final m in RegExp(r'\{(\w+)\}').allMatches(e.$1.akar + e.$1.isi)) {
        expect(tokens, contains(m[1]));
      }
    }
  });
}
