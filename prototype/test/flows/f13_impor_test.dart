// F13 Import (README 8.3): the staged sample file is checked (the impossible
// date is refused, the same date/Kas/Bank/amount is flagged as a possible
// duplicate), the duplicate is kept, the batch is marked checked and
// imported: "4 baris sudah diimpor · 1 tidak diimpor", and the four drafts
// show in Transaksi.

import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';

import 'harness.dart';

void main() {
  group('F13 impor', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final w = await bukaAplikasi(tester, tata: tata);
        final repo = w.read(importRepositoryProvider);
        final tx = w.read(transactionRepositoryProvider);
        final batch = repo.batches().first;
        final rows = repo.rows(batch.id);
        await masukSebagai(tester, Persona.meiske);
        w.read(routerProvider).go(Layar.impor.lokasi());
        await tester.pumpAndSettle();
        expect(find.textContaining(batch.fileName), findsWidgets);

        await tekan(tester, 'Jalankan pengecekan');
        expect(batch.status, ImportBatchStatus.validated);
        final tolak = rows.singleWhere(
          (r) => r.disposition == RowDisposition.refused,
        );
        expect(tolak.date, isNull);
        expect(find.textContaining('${tolak.reason}'), findsOneWidget);
        expect(tolak.reason, endsWith('tidak ada.'));
        expect(find.text('Mungkin ganda'), findsOneWidget);
        expect(
          rows.where((r) => r.disposition == RowDisposition.possibleDuplicate),
          hasLength(1),
        );

        // Undecided: "Tandai sudah diperiksa" waits.
        await tekan(tester, 'Tandai sudah diperiksa');
        expect(batch.status, ImportBatchStatus.validated);
        await tekan(tester, 'Tetap impor');
        await tekan(tester, 'Tandai sudah diperiksa');
        expect(batch.status, ImportBatchStatus.reviewed);

        final f = find.text('Impor').last;
        await tester.ensureVisible(f);
        await tester.tap(f);
        await tester.pumpAndSettle();
        expect(batch.status, ImportBatchStatus.committed);
        expect(
          find.textContaining('4 baris sudah diimpor · 1 tidak diimpor'),
          findsOneWidget,
        );
        final draf = tx.drafts().where((t) => t.importRowId != null).toList();
        expect(draf, hasLength(4));

        w.read(routerProvider).go(Layar.transaksi.lokasi());
        await tester.pumpAndSettle();
        expect(find.textContaining('Honor pemusik'), findsWidgets);
      });
    }
  });
}
