import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/boards.dart';
import 'package:palakat_prototype/main.dart';
import 'package:palakat_prototype/router.dart';
import 'package:palakat_prototype/shell/prototipe_state.dart';

/// Every board route builds without exceptions or overflow (README M0, M9 item 2):
/// at its frame size with default tweaks, with each tweak option changed from the
/// default one at a time, and laptop pages also at 1280, 860 and 390 wide.
///
/// Run one board: fvm flutter test test/routes_test.dart --plain-name '/Main '
void main() {
  for (final p in semuaPapan) {
    final ukuran = <Size>[
      Size(p.lebar, p.tinggi),
      if (p.bentuk == Bentuk.laptop || p.bentuk == Bentuk.tablet) ...[
        Size(1280, p.tinggi),
        Size(860, p.tinggi),
        const Size(390, 844),
      ],
    ];
    for (final u in ukuran) {
      _uji('/${p.stem} @${u.width.toInt()}×${u.height.toInt()}', p.stem, u, null);
    }
    for (final t in p.tweaks) {
      final pilihan = t.editor == 'boolean' ? <Object>[true, false] : t.pilihan!.cast<Object>();
      for (final v in pilihan.where((v) => v != t.bawaan)) {
        _uji('/${p.stem} @tweak ${t.nama}=$v', p.stem, Size(p.lebar, p.tinggi), (t.nama, v));
      }
    }
  }
}

void _uji(String nama, String stem, Size u, (String, Object)? tweak) {
  testWidgets(nama, (tester) async {
    tester.view.physicalSize = u;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final keadaan = PrototypeState();
    if (tweak != null) keadaan.setTweak(stem, tweak.$1, tweak.$2);
    final router = buatRouter();
    await tester.pumpWidget(PalakatPrototipe(router: router, keadaan: keadaan));
    router.go('/$stem');
    // Bounded pumps, not pumpAndSettle: loops (Ulang, titik, denyut, putar) never settle.
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
    keadaan.dispose();
  });
}
