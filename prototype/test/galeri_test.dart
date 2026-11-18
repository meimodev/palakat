import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/main.dart';
import 'package:palakat_prototype/router.dart';

/// `/_komponen` builds in both themes at laptop and phone width.
void main() {
  for (final lebar in [1440.0, 390.0]) {
    testWidgets('/_komponen at $lebar wide', (t) async {
      t.view.physicalSize = Size(lebar, 1000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final router = buatRouter();
      await t.pumpWidget(PalakatPrototipe(router: router));
      router.go('/_komponen');
      // The wait loops repeat forever, so no pumpAndSettle.
      for (var i = 0; i < 30; i++) {
        await t.pump(const Duration(milliseconds: 100));
      }
      expect(t.takeException(), isNull);
      expect(find.text('Terang'), findsWidgets);
      expect(find.text('Gelap'), findsWidgets);
      expect(find.text('TombolBersyarat'), findsOneWidget);
      final ulang = find.text('Putar ulang').first;
      await t.ensureVisible(ulang);
      await t.pump();
      await t.tap(ulang);
      await t.pump(const Duration(seconds: 3));
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 5));
    });
  }
}
