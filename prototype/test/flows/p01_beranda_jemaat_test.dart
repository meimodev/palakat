// P1 Home and inbox, membership part (README 8.3): each persona's
// membership rows come from real open items (the verification queue routed
// to them, unconfirmed members, the paper book, their family's returned
// event); finishing the item removes the row; no web home row links a
// phone-only screen.

import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/tanggal.dart';
import 'package:palakat_prototype/domain/core/core.dart';
import 'package:palakat_prototype/domain/membership/membership.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/home_rows.dart';
import 'package:palakat_prototype/providers/repositories_jemaat.dart';

import 'harness.dart';

bool _jemaat(HomeRow r) => r.ke.modulLayar == ModulLayar.dataJemaat;

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
            if (ponsel) '3 data Kolom 2 menunggu verifikasi',
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
          // Greis verifies the Rumagit change through Hendrik's delegation:
          // her row counts one fewer.
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
          expect(j.via, const ViaDelegation('pelimpahan-hendrik-greis'));
          await keBeranda();
          expect(find.text('1 data menunggu verifikasi'), findsOneWidget);

          // The Lasut move needs both Kolom: Kolom 7's verification leaves it
          // waiting for the Penatua of Kolom 4, and off Greis's home.
          final verif = c.read(verificationRepositoryProvider);
          final pindah = verif.item('peristiwa-pindah-lasut')!;
          final r = await verif.verify(
            c.read(actorProvider)!,
            pindah.id,
            expectedRevision: pindah.revision,
            idempotencyKey: 'p1-pindah-7',
          );
          expect(r.isOk, isTrue, reason: '${r.refusal}');
          expect(pindah.open, isTrue);
          expect(verif.verifiers(pindah.id), ['penatua-kolom-4-orang']);
          await keBeranda();
          expect(find.text('1 data menunggu verifikasi'), findsNothing);
          await keluar(tester);
          return;
        }

        // Web: the Operator's book rows follow the import.
        await masukSebagai(tester, Persona.yanti);
        final a = c.read(actorProvider)!;
        final impor = c.read(memberImportRepositoryProvider);
        ImportBatch buku() =>
            impor.batches().firstWhere((b) => b.source == _buku);
        var k = 0;
        String kunci() => 'p1-jemaat-${k++}';
        expect(
          (await impor.check(
            a,
            buku().id,
            expectedRevision: buku().revision,
            idempotencyKey: kunci(),
          )).isOk,
          isTrue,
        );
        await keBeranda();
        expect(find.text('1 kemungkinan data ganda'), findsOneWidget);
        final ganda = impor.duplicates().single;
        await impor.resolveDuplicate(
          a,
          ganda.id,
          DuplicateDecision.merge,
          reason: 'Gabungkan',
          expectedRevision: ganda.revision,
          idempotencyKey: kunci(),
        );
        final agustina = buku().rows.firstWhere((r) => r.yearMissing);
        await impor.completeRow(
          a,
          buku().id,
          agustina.id,
          const Tanggal(1974, 12, 12),
          expectedRevision: buku().revision,
          idempotencyKey: kunci(),
        );
        final hasil = await impor.commit(
          a,
          buku().id,
          expectedRevision: buku().revision,
          idempotencyKey: kunci(),
        );
        expect(hasil.isOk, isTrue, reason: '${hasil.refusal}');
        await keBeranda();
        expect(find.text('$_buku belum diimpor'), findsNothing);
        expect(find.text('1 kemungkinan data ganda'), findsNothing);
        expect(
          find.text('Buku anggota: ${318 + 28} baris sudah diimpor'),
          findsOneWidget,
        );
        await keluar(tester);
      });
    }
  });
}
