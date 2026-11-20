// F12 Supporting documents (README 8.3): "Terverifikasi (oleh Meiske L.)"
// after Verifikasi; "Dikecualikan" with a reason; the missing document of
// the drawn 0143 is captured through Kamera (P) or WebUnggah (W): its
// attention item leaves the finance home and Dokumen, and once checked
// PeriodRepository.blockers(M0) no longer lists it; a Belanja booked in the
// test after periksaOlehJefry gets its document through the same capture.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';
import 'package:palakat_prototype/providers/seed.dart';
import 'package:palakat_prototype/widgets/tekan.dart';

import 'harness.dart';

void main() {
  group('F12 dokumen', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final w = await bukaAplikasi(tester, tata: tata);
        final web = tata == Tata.web;
        final k = w.read(seedProvider).keuangan;
        final ev = w.read(evidenceRepositoryProvider);
        final tx = w.read(transactionRepositoryProvider);
        EvidenceStatus status(Transaction t) => k.evidenceStatus(t);
        Future<void> buka(String lokasi) async {
          w.read(routerProvider).go(lokasi);
          await tester.pumpAndSettle();
        }

        Future<void> pilih(String uraian) async {
          await buka(Layar.dokumen.lokasi());
          await tekan(tester, uraian);
        }

        /// Kamera (phone) or WebUnggah (web), from the chosen row.
        Future<void> tangkap() async {
          await tekan(tester, 'Lampirkan dokumen pendukung');
          if (web) {
            await tekan(tester, 'Pilih file');
          } else {
            await tester.tap(find.bySemanticsLabel('Ambil foto').first);
            await tester.pumpAndSettle();
            await tekan(tester, 'Pakai foto ini');
          }
          await tungguTiruan(tester, const Duration(milliseconds: 1600));
        }

        final b145 = k.bySeedKey('0145')!;
        final b140 = k.bySeedKey('0140')!;
        final b143 = k.bySeedKey('0143')!;
        final m0 = k.periodOf(k.bySeedKey('0146')!.effectiveDate)!.id;
        bool menghalangi(Transaction t) => w
            .read(periodRepositoryProvider)
            .blockers(m0)
            .any(
              (b) =>
                  b.kind == BlockerKind.evidenceMissing &&
                  b.transactionId == t.id,
            );

        await masukSebagai(tester, Persona.meiske);
        await buka(Layar.keuangan.lokasi());
        expect(
          find.textContaining('1 dokumen pendukung wajib, belum ada'),
          findsOneWidget,
        );

        // Verifikasi a receipt Yanti uploaded.
        await pilih('Konsumsi rapat majelis');
        await tekan(tester, 'Verifikasi');
        expect(status(b145), EvidenceStatus.verified);
        expect(find.text('Terverifikasi (oleh Meiske L.)'), findsWidgets);

        // Dikecualikan with a reason (none: nothing happens).
        await pilih('Bensin operasional');
        await tekan(tester, 'Catat pengecualian');
        await tekan(tester, 'Simpan pengecualian');
        expect(status(b140), EvidenceStatus.uploaded);
        await tester.enterText(
          find.byType(EditableText).last,
          'kuitansi menyusul',
        );
        await tester.pumpAndSettle();
        await tekan(tester, 'Simpan pengecualian');
        expect(status(b140), EvidenceStatus.exceptionAccepted);
        expect(
          find.textContaining('Dikecualikan (alasan: kuitansi menyusul)'),
          findsWidgets,
        );

        // The missing document of 0143, captured.
        expect(menghalangi(b143), isTrue);
        // Its Dokumen row reads 'Wajib, belum ada' (drafts may too).
        Finder hilang() => find.descendant(
          of: find
              .ancestor(
                of: find.text('Sewa sound system'),
                matching: find.byType(Tekan),
              )
              .first,
          matching: find.text('Wajib, belum ada'),
        );
        await buka(Layar.dokumen.lokasi());
        expect(hilang(), findsOneWidget);
        await pilih('Sewa sound system');
        await tangkap();
        expect(status(b143), EvidenceStatus.uploaded);
        expect(
          find.textContaining('Diunggah, belum diverifikasi'),
          findsWidgets,
        );
        await buka(Layar.keuangan.lokasi());
        expect(
          find.textContaining('dokumen pendukung wajib, belum ada'),
          findsNothing,
        );
        await buka(Layar.dokumen.lokasi());
        expect(find.text('Sewa sound system'), findsWidgets);
        expect(hilang(), findsNothing);

        // Meiske cannot verify her own upload; Jefry verifies it.
        await pilih('Sewa sound system');
        await tekan(tester, 'Verifikasi');
        expect(status(b143), EvidenceStatus.uploaded);
        expect(find.textContaining('Anda yang mengunggah'), findsOneWidget);
        await keluar(tester);
        await masukSebagai(tester, Persona.jefry);
        await pilih('Sewa sound system');
        await tekan(tester, 'Verifikasi');
        expect(status(b143), EvidenceStatus.verified);
        expect(menghalangi(b143), isFalse);
        expect(ev.forTransaction(b143.id).last.decidedBy, 'jefry');
        await keluar(tester);
        await masukSebagai(tester, Persona.meiske);

        // A Belanja booked in the test gets its document the same way.
        const uraian = 'Fotokopi warta jemaat';
        await periksaOlehJefry(tester, uraian);
        final d = tx.drafts().firstWhere((t) => t.description == uraian);
        await buka(Layar.draf.lokasi(param: {'id': d.id}));
        await tekan(tester, 'Periksa dan bukukan');
        final t = tx.get(d.id)!;
        expect(t.isPosted, isTrue);
        expect(status(t), EvidenceStatus.requiredMissing);
        await pilih(uraian);
        await tangkap();
        expect(status(t), EvidenceStatus.uploaded);
        expect(ev.forTransaction(t.id).single.by, 'meiske');
      });
    }
  });
}
