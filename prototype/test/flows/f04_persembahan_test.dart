// F4 Offering with parts (README 8.3, the parts only): Persembahan makes one
// income draft whose parts land on different Kas/Bank (Tunai on Kas, QRIS on
// a picked Kas/Bank) and whose Titipan part is a transit collection on this
// month's Titipan case (tt1, 2.1.01.02.00, Sinode, BNI); after
// periksaOlehJefry it is booked with one voucher and tt1 rises by the part.

import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/format.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/keuangan/persembahan.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';

import 'harness.dart';

void main() {
  group('F4 persembahan (bagian)', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final w = await bukaAplikasi(tester, tata: tata);
        final tx = w.read(transactionRepositoryProvider);
        final kasus = w.read(caseRepositoryProvider);
        await masukSebagai(tester, Persona.meiske);
        final p = w.read(pilihanPersembahanProvider);
        expect(p.titipan?.id, 'tt1');
        final tt1 = kasus.caseById('tt1')!.outstanding;
        final qris = p.kasBank.firstWhere(
          (a) => a.id != p.kas && a.id != p.titipan!.akun,
        );

        w.read(routerProvider).go(Layar.persembahan.lokasi());
        await tester.pumpAndSettle();
        // QRIS has no Kas/Bank yet: refused.
        final sebelum = tx.drafts().length;
        await tekan(tester, 'Periksa dan bukukan');
        expect(tx.drafts().length, sebelum);
        expect(
          find.textContaining('Kas/Bank untuk bagian QRIS belum dipilih'),
          findsWidgets,
        );

        final chip = find.text(qris.nama).at(1);
        await tester.ensureVisible(chip);
        await tester.pumpAndSettle();
        await tester.tap(chip);
        await tester.pumpAndSettle();
        await tekan(tester, 'Periksa dan bukukan');
        expect(find.textContaining('Wajib pemeriksa kedua'), findsOneWidget);

        final d = tx.drafts().singleWhere((t) => t.description == p.uraian);
        expect(d.type, TransactionType.income);
        expect(d.allocations, hasLength(3));
        final titip = d.allocations.singleWhere((a) => a.caseId != null);
        expect(d.typeOf(titip), TransactionType.transitCollection);
        expect(titip.caseId, 'tt1');
        expect(titip.amount, 450000);
        expect(titip.masterCode, maTitipanSinode);
        expect(titip.partyId, 'party-sinode');
        expect(d.accountOf(titip), 'bni');
        expect(d.accountOf(d.allocations[0]), p.kas);
        expect(d.accountOf(d.allocations[1]), qris.id);
        // The default Petugas penghitung is stored with the offering.
        expect(d.countedBy, [p.petugasId.first]);
        // The counting sheet is uploaded with the draft (mock-data 2.13).
        expect(
          w
              .read(evidenceRepositoryProvider)
              .forTransaction(d.id)
              .single
              .file
              ?.name,
          p.lembar,
        );

        await periksaOlehJefry(tester, p.uraian);
        final tahun = d.effectiveDate.tahun;
        final nomor =
            tx
                .voucherSeries(VoucherSeries.bku, tahun)
                .fold(0, (m, e) => max(m, e.number)) +
            1;
        w.read(routerProvider).go(Layar.draf.lokasi(param: {'id': d.id}));
        await tester.pumpAndSettle();
        await tekan(tester, 'Periksa dan bukukan');
        final t = tx.get(d.id)!;
        expect(t.isPosted, isTrue);
        // One voucher for all parts: the next free number, on screen.
        expect(t.voucher, voucherCode(VoucherSeries.bku, tahun, nomor));
        expect(
          find.byWidgetPredicate(
            (x) =>
                x is RichText &&
                x.text
                    .toPlainText()
                    .replaceAll(RegExp('[\u200B\u2060]'), '')
                    .contains(t.voucher!),
          ),
          findsWidgets,
        );
        final naik = kasus.caseById('tt1')!.outstanding;
        expect(naik, tt1 + 450000);

        w.read(routerProvider).go(Layar.kewajiban.lokasi(anak: 'kasus/tt1'));
        await tester.pumpAndSettle();
        expect(find.text(rp(naik)), findsWidgets);
        // The booked part is one more collection on the Sinode case.
        final masuk = tx
            .list(null)
            .where(
              (x) =>
                  x.isPosted &&
                  x.allocations.any(
                    (a) =>
                        a.caseId == 'tt1' &&
                        x.typeOf(a) == TransactionType.transitCollection,
                  ),
            );
        expect(masuk, contains(t));
        expect(
          find.textContaining(
            'Dari ${masuk.length} persembahan',
            findRichText: true,
          ),
          findsWidgets,
        );
        // README 8.1: the audit actor of the commands run here.
        expect(jejakTerakhir(w, 'finance.txn.finalize').personId, 'meiske');
      });
    }
  });
}
