// P3 Picker (replaces sign-in), README 8.3. M0: Meiske signs in, lands on
// her role home and signs out to the picker, at P, W and T. M1 extends it.

import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/screens/p2/beranda_jabatan.dart';
import 'package:palakat_prototype/screens/p2/web_beranda_jabatan.dart';

import 'harness.dart';

void main() {
  group('P3 pemilih', () {
    for (final tata in Tata.values) {
      testWidgets(tata.name, (tester) async {
        await bukaAplikasi(tester, tata: tata);

        expect(find.text('Masuk sebagai'), findsOneWidget);
        for (final p in Persona.values) {
          expect(find.text(p.nama), findsOneWidget, reason: p.name);
        }

        await masukSebagai(tester, Persona.meiske);
        expect(lokasiSekarang(tester), '/');
        expect(
          find.byType(
            tata == Tata.ponsel
                ? BerandaJabatanScreen
                : WebBerandaJabatanScreen,
          ),
          findsOneWidget,
        );

        await keluar(tester);
        expect(lokasiSekarang(tester), '/pilih');
      });
    }
  });
}
