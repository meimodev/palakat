import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/boards.dart';
import 'package:palakat_prototype/main.dart';
import 'package:palakat_prototype/router.dart';

/// Every board route builds without exceptions at its frame size.
void main() {
  for (final p in semuaPapan) {
    testWidgets('/${p.stem} at ${p.lebar.toInt()}×${p.tinggi.toInt()}', (tester) async {
      tester.view.physicalSize = Size(p.lebar, p.tinggi);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final router = buatRouter();
      await tester.pumpWidget(PalakatPrototipe(router: router));
      router.go('/${p.stem}');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    });
  }
}
