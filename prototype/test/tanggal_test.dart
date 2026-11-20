import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/main.dart';
import 'package:palakat_prototype/router.dart';
import 'package:palakat_prototype/shell/prototipe_state.dart';

/// Tanggal's "Tanggal dokumen" field (`onDok`): keeps digits and "/", then
/// the first 10 characters.
void main() {
  testWidgets('Tanggal dokumen keeps digits and slashes, at most 10', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final keadaan = PrototypeState();
    final router = buatRouter();
    await tester.pumpWidget(PalakatPrototipe(router: router, keadaan: keadaan));
    router.go('/Tanggal');
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.ensureVisible(find.text('Berbeda'));
    await tester.tap(find.text('Berbeda'));
    await tester.pump();

    final isian = find.byType(EditableText).last;
    for (final (masuk, keluar) in [
      ('1a2/11/20269', '12/11/2026'),
      ('ab12/1', '12/1'),
    ]) {
      await tester.enterText(isian, masuk);
      await tester.pump();
      expect(tester.widget<EditableText>(isian).controller.text, keluar);
    }

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
    keadaan.dispose();
  });
}
