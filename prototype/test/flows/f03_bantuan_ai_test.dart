// F3 AI help, README 8.3: the draft fields are filled; Kas/Bank, peruntukan
// and Lingkup still read "Belum diisi"; status "Tersimpan · Draf"; nothing is
// booked; the AI spend rises by the fixed cost; repeated proposals reach the
// budget-used-up view.

import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';

import 'harness.dart';

void main() {
  group('F3 bantuan AI', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final wadah = await bukaAplikasi(tester, tata: tata);
        final ai = wadah.read(aiRepositoryProvider);
        final tx = wadah.read(transactionRepositoryProvider);
        int dibukukan() => tx
            .list(null)
            .where((t) => t.status == TransactionStatus.finalized)
            .length;
        Future<void> buka(Layar l) async {
          wadah.read(routerProvider).go(l.lokasi());
          await tester.pumpAndSettle();
        }

        await masukSebagai(tester, Persona.meiske);
        final bukuAwal = dibukukan();
        final awal = ai.budget();

        // From a receipt photo.
        await buka(Layar.aiFoto);
        expect(find.text('Rp0'), findsOneWidget);
        expect(find.text('Belum diisi'), findsNWidgets(6));
        await tekan(tester, 'Buat usulan dari foto ini');
        expect(find.text('Membaca foto…'), findsOneWidget);
        await tungguTiruan(tester, const Duration(milliseconds: 1400));
        expect(find.text('Usulan AI · dari foto'), findsOneWidget);
        expect(find.text('AI kurang yakin, mohon dicek'), findsNWidgets(2));
        expect(ai.budget().spent, awal.spent + awal.cost);
        await tekan(tester, 'Pakai');
        expect(
          find.text(
            'Tersimpan sebagai Draf · belum masuk saldo. Semua isian masih '
            'dapat diubah.',
          ),
          findsOneWidget,
        );
        expect(find.text('Rp1.250.000'), findsOneWidget);
        expect(find.text('Toko Sinar'), findsOneWidget);
        expect(
          find.text('Dibagi ke 2 baris · total sama dengan Jumlah'),
          findsOneWidget,
        );
        expect(find.text('Belum diisi'), findsNWidgets(3));
        final foto = tx.drafts().singleWhere((t) => t.payee == 'Toko Sinar');
        expect(foto.aiProposalId, isNotNull);
        expect(foto.total, 1250000);
        expect(foto.allocations.every((a) => a.fundId == null), isTrue);
        expect(foto.accountId, isNull);

        // From a sentence.
        await buka(Layar.bantuanAi);
        expect(find.text('Belum tersimpan'), findsOneWidget);
        expect(
          find.text('Biaya AI bulan ini ${ai.budget().percent}% dari batas'),
          findsOneWidget,
        );
        await tekan(tester, 'Buat usulan dari kalimat ini');
        expect(find.text('dari kalimat Anda'), findsOneWidget);
        expect(ai.budget().spent, awal.spent + 2 * awal.cost);
        await tekan(tester, 'Pakai');
        expect(find.text('Tersimpan · Draf'), findsOneWidget);
        expect(find.text('PLN'), findsOneWidget);
        expect(find.text('Rp1.250.000'), findsOneWidget);
        expect(find.text('Belum diisi'), findsNWidgets(3));
        final kalimat = tx.drafts().singleWhere((t) => t.payee == 'PLN');
        expect(kalimat.status, TransactionStatus.draft);
        expect(kalimat.allocations.single.masterCode, '5.01.02.00');

        // Nothing is booked.
        expect(dibukukan(), bukuAwal);

        // Asking again and again reaches the month's limit.
        for (var i = 0; i < 10 && !ai.budget().usedUp; i++) {
          await tekan(tester, 'Buat usulan dari kalimat ini');
          await tekan(tester, 'Abaikan');
        }
        expect(ai.budget().usedUp, isTrue);
        expect(
          find.textContaining('Batas biaya AI per bulan tercapai.'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Bantuan AI berhenti sampai Desember 2026.'),
          findsOneWidget,
        );
        expect(find.text('Buat usulan dari kalimat ini'), findsNothing);
        expect(find.text('Tersimpan · Draf'), findsOneWidget);
      });
    }
  });
}
