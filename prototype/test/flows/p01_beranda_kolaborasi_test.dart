// P1 Home and inbox, Collaboration part (README 8.3): each persona's
// "Perlu tindakan" rows come from real open items (services, counts, fund
// requests, Panitia); finishing the item removes the row; no web home row
// links a phone-only screen.

import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/domain/collaboration/collaboration.dart';
import 'package:palakat_prototype/providers/home_rows.dart';
import 'package:palakat_prototype/providers/repositories_kolaborasi.dart';
import 'package:palakat_prototype/providers/repositories_sekretariat.dart';
import 'package:palakat_prototype/widgets/chip_pilihan.dart';

import 'harness.dart';

bool _kolaborasi(HomeRow r) => const {
  ModulLayar.persetujuan,
  ModulLayar.ibadah,
  ModulLayar.kehadiran,
  ModulLayar.panitia,
}.contains(r.ke.modulLayar);

/// Taps chip [teks] of the ChipPilihan labelled [label].
Future<void> _pilih(WidgetTester tester, String label, String teks) async {
  final grup = find.ancestor(
    of: find.text(label),
    matching: find.byType(ChipPilihan<String>),
  );
  final f = find.descendant(of: grup.first, matching: find.text(teks)).first;
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  group('P1 beranda kolaborasi', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final c = await bukaAplikasi(tester, tata: tata);
        Future<void> keBeranda() async {
          c.read(routerProvider).go(Layar.beranda.lokasi());
          await tester.pumpAndSettle();
        }

        // Every persona: rows link a screen of this layout; Collaboration
        // screens are phone only, so the web home has none of their rows.
        final adaBaris = <Persona>{};
        for (final p in Persona.values) {
          await masukSebagai(tester, p);
          if (p == Persona.hendrik) {
            await tekan(tester, 'Sebagai Penatua Kolom 7');
          }
          final baris = c.read(homeRowsProvider);
          for (final r in baris) {
            expect(r.ke.adaUntuk(tata), isTrue, reason: '${p.name} ${r.judul}');
          }
          if (baris.any(_kolaborasi)) adaBaris.add(p);
          await keluar(tester);
        }
        if (tata == Tata.web) {
          expect(adaBaris, isEmpty);
          return;
        }
        expect(
          adaBaris,
          containsAll([
            Persona.lidya,
            Persona.hendrik,
            Persona.greis,
            Persona.jefry,
            Persona.olga,
            Persona.rivo,
          ]),
        );

        // Hendrik approves the Kolom 7 service; the Draf row gives way to
        // "Tugaskan penghitung", which leaves once a counter is assigned.
        final s = c.read(serviceRepositoryProvider).get('ibadah-kolom-7')!;
        await masukSebagai(tester, Persona.hendrik);
        await tekan(tester, 'Sebagai Penatua Kolom 7');
        expect(find.text('Ibadah Kolom 7, ${s.date}'), findsOneWidget);
        await tekan(tester, 'Ibadah Kolom 7, ${s.date}');
        await tekan(tester, 'Setujui dan jadwalkan');
        await keBeranda();
        expect(find.text('Ibadah Kolom 7, ${s.date}'), findsNothing);
        await tekan(tester, 'Tugaskan penghitung · Ibadah Kolom 7');
        await tekan(tester, 'Tugaskan penghitung kehadiran');
        await tekan(tester, 'Pintu depan');
        await tekan(tester, 'Deasy Tumbelaka');
        await tekan(tester, 'Tugaskan');
        await keBeranda();
        expect(find.text('Tugaskan penghitung · Ibadah Kolom 7'), findsNothing);
        await keluar(tester);

        // Greis no longer has the Draf row: Hendrik approved it.
        await masukSebagai(tester, Persona.greis);
        expect(find.text('Ibadah Kolom 7, ${s.date}'), findsNothing);
        await keluar(tester);

        // Lidya decides a fund request; the Bendahara is then asked to pay.
        await masukSebagai(tester, Persona.lidya);
        expect(find.text('Permintaan dana Komisi Diakonia'), findsOneWidget);
        await tekan(tester, 'Permintaan dana Komisi Diakonia');
        await tekan(tester, 'Setujui');
        await keBeranda();
        expect(find.text('Permintaan dana Komisi Diakonia'), findsNothing);
        expect(find.text('Permintaan dana BIPRA Pemuda'), findsOneWidget);

        // A new Panitia waits in Perencanaan until she activates it.
        c.read(routerProvider).go(Layar.panitia.lokasi());
        await tester.pumpAndSettle();
        await tekan(tester, 'Membentuk Panitia baru');
        await isi(tester, 'Nama Panitia', 'Panitia Retret Pemuda');
        await _pilih(tester, 'Ketua', 'Sdr. Stevi Lengkong');
        await _pilih(tester, 'Sekretaris', 'Sdri. Natalia Rumengan');
        await _pilih(tester, 'Bendahara', 'Sdr. Rivo Mandagi');
        final sk = c
            .read(panitiaRepositoryProvider)
            .get('panitia-natal')!
            .skDocumentId!;
        final judulSk = c.read(documentRepositoryProvider).get(sk)!.title;
        await _pilih(tester, 'Keputusan gereja', judulSk);
        await tekan(tester, 'Bentuk Panitia');
        await keBeranda();
        expect(
          find.text('Panitia Retret Pemuda masih Perencanaan'),
          findsOneWidget,
        );
        await tekan(tester, 'Panitia Retret Pemuda masih Perencanaan');
        await tekan(tester, 'Aktifkan Panitia');
        expect(
          c
              .read(panitiaRepositoryProvider)
              .list()
              .singleWhere((p) => p.name == 'Panitia Retret Pemuda')
              .stage,
          PanitiaStage.active,
        );
        await keBeranda();
        expect(
          find.text('Panitia Retret Pemuda masih Perencanaan'),
          findsNothing,
        );
        await keluar(tester);

        await masukSebagai(tester, Persona.meiske);
        expect(find.text('1 permintaan dana siap dibayar'), findsOneWidget);
        await keluar(tester);

        // A counter's row is there to know before the service day.
        await masukSebagai(tester, Persona.jefry);
        expect(
          find.text('Hitung kehadiran · Ibadah Minggu Adven I'),
          findsOneWidget,
        );
      });
    }
  });
}
