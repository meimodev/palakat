// P1 Home and inbox, membership part (README 8.3): each persona's
// membership rows come from real open items (the verification queue routed
// to them, unconfirmed members, the paper book, their family's returned
// event); finishing the item removes the row; no web home row links a
// phone-only screen.

import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/format.dart';
import 'package:palakat_prototype/domain/core/core.dart';
import 'package:palakat_prototype/domain/membership/membership.dart';
import 'package:palakat_prototype/providers/core_repositories.dart';
import 'package:palakat_prototype/providers/home_rows.dart';
import 'package:palakat_prototype/providers/repositories_jemaat.dart';

import 'harness.dart';

/// A Data jemaat row; the queue row of a covered Penatua post opens
/// JabatanKosong instead.
bool _jemaat(HomeRow r) =>
    r.ke.modulLayar == ModulLayar.dataJemaat ||
    r.judul.endsWith('menunggu verifikasi');

const _buku = 'Buku anggota Kolom 7 · 2019–2026';

void main() {
  group('P1 beranda jemaat', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final ponsel = tata == Tata.ponsel;
        final c = await bukaAplikasi(tester, tata: tata);

        Future<void> keBeranda() async {
          c.read(routerProvider).go(Layar.beranda.lokasi());
          await tester.pumpAndSettle();
        }

        // Each persona's rows, as the layout allows.
        final harap = <Persona, List<String>>{
          Persona.yanti: [
            '3 data Kolom 2 menunggu verifikasi',
            '$_buku belum diimpor',
            'Buku anggota: 318 baris sudah diimpor',
          ],
          Persona.hendrik: [
            if (ponsel) '1 data menunggu verifikasi',
            if (ponsel) '12 anggota Kolom 7 belum dikonfirmasi',
          ],
          Persona.greis: [if (ponsel) '2 data menunggu verifikasi'],
          Persona.novita: [if (ponsel) 'Baptisan · Gabriel Wenas dikembalikan'],
        };
        for (final p in Persona.values) {
          await masukSebagai(tester, p);
          if (p == Persona.hendrik) {
            await tekan(tester, 'Sebagai Penatua Kolom 7');
          }
          final baris = c.read(homeRowsProvider);
          for (final r in baris) {
            expect(r.ke.adaUntuk(tata), isTrue, reason: '${p.name} ${r.judul}');
          }
          expect(
            [for (final r in baris.where(_jemaat)) r.judul],
            harap[p] ?? const <String>[],
            reason: p.name,
          );
          for (final r in baris.where(_jemaat)) {
            expect(find.text(r.judul), findsOneWidget, reason: r.judul);
          }
          await keluar(tester);
        }

        if (ponsel) {
          // Greis verifies Hendrik's family's change as Syamas Kolom 7 (not
          // through his delegation): her row counts one fewer.
          await masukSebagai(tester, Persona.greis);
          await tekan(tester, '2 data menunggu verifikasi');
          await tekan(tester, 'Perubahan data · Keluarga Rumagit');
          // The button, not the page title of the same words.
          await tester.ensureVisible(find.text('Verifikasi data').last);
          await tester.tap(find.text('Verifikasi data').last);
          await tester.pumpAndSettle();
          expect(
            find.text('Perubahan data · Keluarga Rumagit diverifikasi.'),
            findsOneWidget,
          );
          final j = jejakTerakhir(c, 'membership.verify');
          expect(j.personName, 'Sym. Greis Mamahit');
          expect(j.via, Via.direct);
          await keBeranda();
          expect(find.text('1 data menunggu verifikasi'), findsOneWidget);

          // The Lasut move needs both Kolom: Greis verifies Kolom 7's part
          // through the delegation in Peristiwa; it waits for the Penatua of
          // Kolom 4, and leaves Greis's home.
          await tekan(tester, '1 data menunggu verifikasi');
          await tester.tap(find.textContaining('Keluarga Lasut').first);
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text('Verifikasi data').last);
          await tester.tap(find.text('Verifikasi data').last);
          await tester.pumpAndSettle();
          expect(
            jejakTerakhir(c, 'membership.verify').via,
            const ViaDelegation('pelimpahan-hendrik-greis'),
          );
          final verif = c.read(verificationRepositoryProvider);
          final pindah = verif.item('peristiwa-pindah-lasut')!;
          expect(pindah.open, isTrue);
          expect(verif.verifiers(pindah.id), ['penatua-kolom-4-orang']);
          await keBeranda();
          expect(find.text('1 data menunggu verifikasi'), findsNothing);
          await keluar(tester);
          return;
        }

        // Web: the Operator's book rows follow the import, done in
        // WebImporBuku and WebDataGanda.
        await masukSebagai(tester, Persona.yanti);
        final impor = c.read(memberImportRepositoryProvider);
        ImportBatch buku() =>
            impor.batches().firstWhere((b) => b.source == _buku);
        final lahir = c
            .read(peopleRepositoryProvider)
            .person('agustina')!
            .birthDate!;
        await tekan(tester, '$_buku belum diimpor');
        await tekan(tester, 'Jalankan pengecekan');
        await keBeranda();
        await tekan(tester, '1 kemungkinan data ganda');
        await tekan(tester, 'Bukan orang yang sama');
        await keBeranda();
        expect(find.text('1 kemungkinan data ganda'), findsNothing);
        await tekan(tester, '$_buku belum diimpor');
        await isi(tester, 'Tanggal lahir', tgl(lahir.awal));
        await tekan(tester, 'Impor 27 baris');
        expect(buku().status, ImportStatus.imported);
        await keBeranda();
        expect(find.text('$_buku belum diimpor'), findsNothing);
        expect(
          find.text('Buku anggota: ${318 + 28} baris sudah diimpor'),
          findsOneWidget,
        );
        await keluar(tester);
      });
    }
  });
}
