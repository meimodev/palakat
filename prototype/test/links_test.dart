import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/boards.dart';
import 'package:palakat_prototype/shell/nav_item.dart';

/// Link coverage (README M2, navigation.md 3.1): every out-link of every board
/// (`Papan.keluar`) must be wired in that board's screen file.
///
/// A target T is present when the screen file (or a `part` of it) contains
/// `ke: 'T'`, `kembaliKe: 'T'` or `keBagi: 'T'` as a literal, or
/// `item: navX` whose list in `lib/shell/nav_item.dart` holds T, or
/// `PonselTabBar(` (its Bulan and Lainnya tabs: TutupBuku, Lainnya).
///
/// Expected to fail until the screens are built (M3 to M8); it must pass at M9
/// with no exceptions list.
void main() {
  test('every out-link of every board is wired in its screen file', () {
    final hilang = <String, List<String>>{};
    var diharap = 0;
    for (final p in semuaPapan) {
      final ada = tautanDi(berkasLayar(p));
      final kurang = [
        for (final t in p.keluar)
          if (!ada.contains(t)) t,
      ];
      diharap += p.keluar.length;
      if (kurang.isNotEmpty) hilang[p.stem] = kurang;
    }
    final n = hilang.values.fold(0, (a, l) => a + l.length);
    expect(
      n,
      0,
      reason:
          '$n of $diharap expected links missing on ${hilang.length} of '
          '${semuaPapan.length} boards:\n'
          '${[for (final e in hilang.entries) '  ${e.key}: ${e.value.join(', ')}'].join('\n')}',
    );
  });
}

/// `lib/screens/<pageId>/<snake_stem>.dart`, as tool/gen_boards.py names it.
File berkasLayar(Papan p) {
  final ular = p.stem
      .replaceAllMapped(
        RegExp(r'(?<=[a-z0-9])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])'),
        (_) => '_',
      )
      .toLowerCase();
  return File('lib/screens/${p.halaman}/$ular.dart');
}

/// Every board target the source of [f] and its `part` files wire.
Set<String> tautanDi(File f) {
  final teks = StringBuffer();
  void baca(File b) {
    if (!b.existsSync()) return;
    final s = b.readAsStringSync();
    teks.writeln(s);
    for (final m in RegExp(
      r'''^part\s+['"]([^'"]+)['"]''',
      multiLine: true,
    ).allMatches(s)) {
      baca(File('${b.parent.path}/${m[1]}'));
    }
  }

  baca(f);
  final s = teks.toString();
  final ada = <String>{
    for (final m in RegExp(
      r'''\b(?:ke|kembaliKe|keBagi):\s*['"]([^'"]+)['"]''',
    ).allMatches(s))
      m[1]!,
  };
  for (final m in RegExp(r'\bitem:\s*(nav\w+)').allMatches(s)) {
    final daftar = semuaNav[m[1]];
    if (daftar != null) ada.addAll(daftar.map((i) => i.ke));
  }
  if (s.contains('PonselTabBar(')) ada.addAll(const ['TutupBuku', 'Lainnya']);
  return ada;
}
