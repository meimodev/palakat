// F9 Refund (README 8.3, RD04): Pengembalian (the Alur merged in) picks a
// posted Belanja; a refund above the original is refused; a valid one is a
// supplierRefund draft linked by voucher, booked after periksaOlehJefry, and
// it lowers M0 Belanja and raises the Kas/Bank it comes back to.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/format.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/keuangan/beranda.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';
import 'package:palakat_prototype/providers/seed.dart';
import 'package:palakat_prototype/widgets/kecil.dart';

import 'harness.dart';

const _uraian = 'Pemeliharaan atap gedung';

void main() {
  group('F9 pengembalian', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final w = await bukaAplikasi(tester, tata: tata);
        final k = w.read(seedProvider).keuangan;
        final tx = w.read(transactionRepositoryProvider);
        final akun = w.read(accountRepositoryProvider);
        final asal = k.transactions.singleWhere(
          (t) => t.description == _uraian && t.isPosted,
        );
        final m0 = w.read(bulanBukuProvider).berjalan!.id;
        int belanja() => w.read(ringkasanBulanProvider(m0))!.belanja;
        final belanja0 = belanja();
        final bank0 = akun.balance(asal.accountId!);

        await masukSebagai(tester, Persona.meiske);
        w.read(routerProvider).go(Layar.pengembalian.lokasi());
        await tester.pumpAndSettle();

        final tombol = find.descendant(
          of: find.ancestor(
            of: find.text(_uraian),
            matching: find.byType(Kartu),
          ),
          matching: find.text('Catat uang kembali dari pemasok'),
        );
        await tester.ensureVisible(tombol);
        await tester.tap(tombol);
        await tester.pumpAndSettle();
        expect(
          find.textContaining('paling banyak ${rp(asal.total)}'),
          findsWidgets,
        );

        // Above the original: refused on screen and by the repository.
        final jumlah = find.byType(EditableText).first;
        await tester.enterText(jumlah, '${asal.total + 100000}');
        await tester.enterText(
          find.byType(EditableText).last,
          'atap tidak jadi diganti',
        );
        await tester.pumpAndSettle();
        expect(
          find.text('Tidak dapat dilakukan: melebihi jumlah transaksi asal.'),
          findsOneWidget,
        );
        final sebelum = tx.drafts().length;
        await tekan(tester, 'Simpan sebagai draf');
        expect(tx.drafts().length, sebelum);
        final lebih = await w
            .read(caseRepositoryProvider)
            .refund(
              w.read(actorProvider)!,
              asal.id,
              asal.total + 1,
              reason: 'x',
              idempotencyKey: 'f9-lebih-${tata.name}',
            );
        expect(lebih.refusal?.because, contains('melebihi'));
        // A reversed original is refused by the command, not only hidden.
        final dibalik = k.transactions.firstWhere(
          (t) => t.isReversed && t.type == TransactionType.expense,
        );
        final balik = await w
            .read(caseRepositoryProvider)
            .refund(
              w.read(actorProvider)!,
              dibalik.id,
              1000,
              reason: 'x',
              idempotencyKey: 'f9-dibalik-${tata.name}',
            );
        expect(balik.refusal?.because, contains('sudah dibalik'));

        // A valid refund: a draft linked to the original, waiting for Jefry.
        await tester.enterText(jumlah, '1500000');
        await tester.pumpAndSettle();
        await tekan(tester, 'Periksa dan bukukan');
        expect(find.textContaining('Wajib pemeriksa kedua'), findsOneWidget);
        expect(find.text('Draf · belum masuk saldo'), findsOneWidget);
        expect(
          find.textContaining('Terkait dengan No. Bukti ${asal.voucher}'),
          findsOneWidget,
        );
        final d = tx.drafts().singleWhere((t) => t.sourceRef == asal.voucher);
        expect(d.type, TransactionType.supplierRefund);
        expect(d.total, 1500000);
        expect(belanja(), belanja0);

        await periksaOlehJefry(tester, d.description);
        w.read(routerProvider).go(Layar.draf.lokasi(param: {'id': d.id}));
        await tester.pumpAndSettle();
        await tekan(tester, 'Periksa dan bukukan');
        expect(tx.get(d.id)!.isPosted, isTrue);
        expect(belanja(), belanja0 - 1500000);
        expect(akun.balance(asal.accountId!), bank0 + 1500000);

        // What is left to refund.
        w.read(routerProvider).go(Layar.pengembalian.lokasi());
        await tester.pumpAndSettle();
        await tester.ensureVisible(tombol);
        await tester.tap(tombol);
        await tester.pumpAndSettle();
        expect(
          find.textContaining('paling banyak ${rp(asal.total - 1500000)}'),
          findsWidgets,
        );
      });
    }
  });
}
