// F8 Correction (README 8.3): a posted M0 Belanja is reversed and corrected
// onto another Mata Anggaran; after periksaOlehJefry both drafts take the next
// free numbers, the original reads "Dibalik oleh No. Bukti …" and the net
// effect on Kas is Rp0. A transaction of M−2 (closed) cannot be corrected:
// the refusal offers "Catat kejadian".

import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';
import 'package:palakat_prototype/providers/seed.dart';

import 'harness.dart';

void main() {
  group('F8 koreksi', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final w = await bukaAplikasi(tester, tata: tata);
        final web = tata == Tata.web;
        final k = w.read(seedProvider).keuangan;
        final tx = w.read(transactionRepositoryProvider);
        final akun = w.read(accountRepositoryProvider);
        Future<void> buka(String id) async {
          w.read(routerProvider).go(Layar.koreksi.lokasi(param: {'id': id}));
          await tester.pumpAndSettle();
        }

        await masukSebagai(tester, Persona.meiske);
        // An M0 Belanja nobody reversed yet (0139 is the seeded example).
        final asal = k.transactions.lastWhere(
          (t) =>
              t.isPosted &&
              t.type == TransactionType.expense &&
              !t.isReversed &&
              t.correctionOf == null &&
              t.approvalMode == ApprovalMode.notRequired &&
              t.allocations.length == 1 &&
              t.allocations.single.caseId == null &&
              !(k.periodOf(t.effectiveDate)?.isClosed ?? true),
        );
        final maAsal = asal.allocations.single.masterCode;
        final no = asal.voucher!;
        final kas = akun.balance('kas');

        await buka(asal.id);
        expect(find.text(no), findsWidgets);
        await tekan(tester, 'Koreksi dengan pembalikan');
        await tester.enterText(
          find.byType(EditableText).first,
          'Mata Anggaran keliru',
        );
        await tester.pumpAndSettle();
        await tekan(tester, 'Bukukan pembalikan dan koreksi');

        // The second checker has not looked yet: both stay drafts.
        expect(find.textContaining('Wajib pemeriksa kedua'), findsOneWidget);
        final balik = tx.list(null).singleWhere((t) => t.reversalOf == asal.id);
        final ganti = tx
            .list(null)
            .singleWhere((t) => t.correctionOf == asal.id);
        expect(balik.isDraft && ganti.isDraft, isTrue);
        expect(ganti.allocations.single.masterCode, isNot(maAsal));
        expect(ganti.allocations.single.masterCode, isNotNull);

        await periksaOlehJefry(tester, balik.description);
        await periksaOlehJefry(tester, ganti.description);

        // The next free numbers, in order.
        final tahun = w.read(hariIniProvider).tahun;
        final berikut =
            tx
                .voucherSeries(VoucherSeries.bku, tahun)
                .fold(0, (m, e) => max(m, e.number)) +
            1;
        await buka(asal.id);
        await tekan(tester, 'Periksa dan bukukan');
        expect(
          tx.get(balik.id)!.voucher,
          voucherCode(VoucherSeries.bku, tahun, berikut),
        );
        expect(
          tx.get(ganti.id)!.voucher,
          voucherCode(VoucherSeries.bku, tahun, berikut + 1),
        );
        expect(tx.get(asal.id)!.isReversed, isTrue);
        expect(find.text('Koreksi dibukukan'), findsOneWidget);
        expect(find.text('Rp0'), findsOneWidget);
        expect(
          find.textContaining('Alasan: Mata Anggaran keliru'),
          findsOneWidget,
        );
        expect(akun.balance('kas'), kas);

        await buka(asal.id);
        expect(
          find.textContaining(
            'Dibalik oleh No. Bukti ${web ? '' : tx.get(balik.id)!.voucher}',
          ),
          findsOneWidget,
        );

        // M−2 is closed: refused, with "Catat kejadian".
        final m2 = k.transactions.firstWhere(
          (t) =>
              t.isPosted &&
              !t.isReversed &&
              t.type == TransactionType.expense &&
              (k.periodOf(t.effectiveDate)?.isClosed ?? false),
        );
        final r = await tx.correct(
          w.read(actorProvider)!,
          m2.id,
          TransactionDraft(
            type: m2.type,
            effectiveDate: w.read(hariIniProvider),
            description: m2.description,
            allocations: m2.allocations,
          ),
          reason: 'keliru',
          expectedRevision: m2.revision,
          idempotencyKey: 'f8-m2-${tata.name}',
        );
        expect(r.refusal?.because, contains('catat kejadian'));
        await buka(m2.id);
        expect(
          find.textContaining(
            'Tidak dapat dilakukan: koreksi dengan pembalikan',
          ),
          findsOneWidget,
        );
        expect(find.text('Catat kejadian'), findsOneWidget);
        expect(find.text('Koreksi dengan pembalikan'), findsNothing);
      });
    }
  });
}
