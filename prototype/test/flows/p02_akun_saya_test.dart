// P2 My account, README 8.3: "Email cadangan disimpan."; a removed device is
// gone; sign-out returns to the picker, and the change is kept.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/core_repositories.dart';
import 'package:palakat_prototype/providers/tema.dart';
import 'package:palakat_prototype/widgets/sakelar.dart';

import 'harness.dart';

void main() {
  group('P2 akun saya', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final wadah = await bukaAplikasi(tester, tata: tata);
        await masukSebagai(tester, Persona.meiske);

        Future<void> bukaAkun() async {
          wadah.read(routerProvider).go(Layar.akun.lokasi());
          await tester.pumpAndSettle();
        }

        await bukaAkun();
        expect(find.text('Meiske Lumentut'), findsOneWidget);
        expect(find.textContaining('Chrome di laptop'), findsOneWidget);

        // A removed device is gone, in the repository too.
        final sesi = wadah.read(sessionRepositoryProvider);
        expect(sesi.devices('meiske'), hasLength(2));
        await tekan(tester, 'Keluarkan');
        expect(
          find.text(
            'Perangkat itu dikeluarkan. Ia harus masuk lagi dengan kode baru.',
          ),
          findsOneWidget,
        );
        expect(find.textContaining('Chrome di laptop'), findsNothing);
        expect(sesi.devices('meiske'), hasLength(1));

        // The backup email, through the code view.
        await tekan(tester, 'Ganti email cadangan');
        await isi(tester, 'Email cadangan', 'meiske.l@contoh.id');
        await tekan(tester, 'Kirim kode ke email');
        await isi(tester, 'Kode 6 angka', '482913');
        await tekan(tester, 'Simpan email cadangan');
        expect(find.text('Email cadangan disimpan.'), findsOneWidget);
        expect(find.text('m···@contoh.id'), findsOneWidget);
        expect(
          wadah.read(peopleRepositoryProvider).person('meiske')!.backupEmail,
          'meiske.l@contoh.id',
        );

        // Sign-out returns to the picker; signing in again keeps the change.
        await keluar(tester);
        expect(lokasiSekarang(tester), '/pilih');
        await masukSebagai(tester, Persona.meiske);
        await bukaAkun();
        expect(find.textContaining('Chrome di laptop'), findsNothing);
        expect(find.textContaining('Ponsel Android'), findsOneWidget);

        // A new sign-in number signs the other devices out in one command.
        final orang = wadah.read(peopleRepositoryProvider);
        final r = await orang.setContact(
          wadah.read(actorProvider)!,
          phone: '0812 3456 7890',
          expectedRevision: orang.person('meiske')!.revision,
          idempotencyKey: 'p2-hp-${tata.name}',
        );
        expect(r.isOk, isTrue);
        expect(sesi.devices('meiske'), isEmpty);
      });
    }

    // Owner request: light by default, also when the system is dark; the
    // "Tema gelap" switch in AkunSaya turns dark on for the rest of the run.
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets('tema terang bawaan, gelap dari Akun ${tata.name}', (
        tester,
      ) async {
        tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        final wadah = await bukaAplikasi(tester, tata: tata);
        Brightness terang() =>
            Theme.of(tester.element(find.text('Masuk sebagai'))).brightness;
        expect(terang(), Brightness.light);

        await masukSebagai(tester, Persona.meiske);
        wadah.read(routerProvider).go(Layar.akun.lokasi());
        await tester.pumpAndSettle();
        final sakelar = find.byType(Sakelar);
        await tester.ensureVisible(sakelar);
        await tester.tap(sakelar);
        await tester.pumpAndSettle();
        expect(wadah.read(temaProvider), ThemeMode.dark);

        // Kept across sign-out, like the rest of the in-memory state.
        await keluar(tester);
        expect(terang(), Brightness.dark);
      });
    }
  });
}
