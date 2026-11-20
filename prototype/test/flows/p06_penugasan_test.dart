// P6 Posts and delegation, README 8.3 (M6 part): Lidya assigns Penatua Kolom 2
// to Altje and Yanti's cover ends; Lidya cannot assign herself; Hendrik's
// delegation to Greis shows in force in Pelimpahan and reads ended 15 days
// later.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/data/seed/keputusan_penugasan.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/core_repositories.dart';

import 'harness.dart';

Future<void> buka(WidgetTester tester, ProviderContainer c, Layar l) async {
  c.read(routerProvider).go(l.lokasi());
  await tester.pumpAndSettle();
}

/// Lidya, in Penugasan: refused for herself, then assigns Altje.
Future<void> tugaskanAltje(WidgetTester tester, ProviderContainer c) async {
  await masukSebagai(tester, Persona.lidya);
  await buka(tester, c, Layar.penugasan);
  final hari = c.read(hariIniProvider);
  // The first vacant post is Penatua Kolom 2.
  await tekan(tester, 'Tugaskan');
  expect(find.text('Penatua Kolom 2'), findsWidgets);
  await isi(tester, 'Orang', 'Lidya');
  await tekan(tester, 'Pdt. Lidya Rondonuwu');
  expect(
    find.textContaining(
      'Anda tidak dapat menugaskan jabatan kepada diri sendiri.',
      findRichText: true,
    ),
    findsOneWidget,
  );
  await isi(tester, 'Orang', 'Altje');
  await tekan(tester, 'Pnt. Altje Rompas');
  await tekan(tester, 'Belum ada dokumen');
  expect(
    find.textContaining(
      'penugasan memerlukan keputusan tertulis gereja di Dokumen gereja.',
      findRichText: true,
    ),
    findsOneWidget,
  );
  final sk = keputusanPenugasan(hari);
  await tekan(tester, sk);
  await tekan(tester, 'Catat penugasan');
  expect(
    find.text(
      'Penatua Kolom 2 dipegang Pnt. Altje Rompas sejak $hari. '
      'Keputusan: $sk.',
    ),
    findsOneWidget,
  );
  final p = c
      .read(roleRepositoryProvider)
      .posts()
      .firstWhere((x) => x.post.id == 'penatua-kolom-2');
  expect(p.holder?.personId, 'altje');
  expect(p.cover, isNull);
  expect(jejakTerakhir(c, 'role.assign').personName, 'Pdt. Lidya Rondonuwu');
  await keluar(tester);
}

void main() {
  group('P6 penugasan dan pelimpahan', () {
    testWidgets('ponsel', (tester) async {
      final c = await bukaAplikasi(tester);
      await tugaskanAltje(tester, c);

      // Yanti's cover of Penatua Kolom 2 has ended.
      await masukSebagai(tester, Persona.yanti);
      expect(
        find.text('Menjalankan jabatan kosong: Penatua Kolom 2'),
        findsNothing,
      );
      await buka(tester, c, Layar.jabatanKosong);
      expect(
        find.textContaining(
          'Penatua Kolom 2 sudah terisi:',
          findRichText: true,
        ),
        findsOneWidget,
      );
      await keluar(tester);

      // Hendrik's delegation to Greis: in force, then ended by itself.
      await masukSebagai(tester, Persona.hendrik);
      await buka(tester, c, Layar.pelimpahan);
      expect(find.text('Penatua Kolom 7 → Sym. Greis Mamahit'), findsOneWidget);
      expect(find.text('Aktif'), findsOneWidget);
      expect(find.text('Berakhir'), findsNothing);
      await majukanJam(tester, const Duration(days: 15));
      expect(find.text('Aktif'), findsNothing);
      expect(find.text('Berakhir'), findsOneWidget);
      expect(find.text('Berakhir sendiri pada tanggalnya.'), findsOneWidget);
    });

    testWidgets('web (Penugasan)', (tester) async {
      final c = await bukaAplikasi(tester, tata: Tata.web);
      await tugaskanAltje(tester, c);
    });
  });
}
