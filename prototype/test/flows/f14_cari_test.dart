// F14 Search (README 8.3): the answer total equals the sum of the posted
// records it lists; a transaction booked earlier in the test is found.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/format.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';

import 'harness.dart';

const _fotokopi = 'draf-fotokopi-warta';
const _kueri = 'fotokopi warta';

void main() {
  group('F14 cari', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final c = await bukaAplikasi(tester, tata: tata);
        final tx = c.read(transactionRepositoryProvider);

        Future<void> bukaCari() async {
          c.read(routerProvider).go(Layar.cari.lokasi());
          await tester.pumpAndSettle();
        }

        Future<void> cari(String kueri) async {
          await tester.enterText(find.byType(EditableText).first, kueri);
          await tester.pumpAndSettle();
        }

        /// The listed records are posted, and the answer is their sum.
        void jumlahSamaDenganBaris(Iterable<Transaction> diharapkan, int n) {
          expect(diharapkan, hasLength(n));
          for (final t in diharapkan) {
            expect(t.isPosted, isTrue, reason: t.id);
            expect(find.text(t.description), findsWidgets, reason: t.id);
            expect(find.textContaining(t.voucher!), findsWidgets);
          }
          expect(
            find.textContaining(
              'Jumlah dari $n transaksi yang sudah dibukukan',
            ),
            findsOneWidget,
          );
        }

        await masukSebagai(tester, Persona.meiske);
        await bukaCari();

        // The opening question reads as a Mata Anggaran: only the matching
        // parts of the four Sunday-morning offerings count (0098's Kas part).
        const kode = '1.3.53.07.00';
        final minggu = [
          for (final k in ['0098', '0107', '0114', '0123'])
            tx.list(null).singleWhere((t) => t.seedKey == k),
        ];
        final bagian = minggu.fold(
          0,
          (n, t) =>
              n +
              effectsOf(t)
                  .where((e) => e.allocation.masterCode == kode)
                  .fold(0, (m, e) => m + e.income),
        );
        expect(bagian, 10950000);
        expect(find.text(rp(bagian)), findsOneWidget);
        jumlahSamaDenganBaris(minggu, 4);

        // Before the booking the draft is not found.
        await cari(_kueri);
        List<Transaction> diBuku() => [
          for (final t in tx.list(null))
            if (t.isPosted &&
                t.description.toLowerCase().contains('fotokopi warta'))
              t,
        ];
        final sebelum = diBuku();
        expect(sebelum.any((t) => t.id == _fotokopi), isFalse);

        // Jefry checks the seeded draft and Meiske books it from Draf.
        await periksaOlehJefry(tester, 'Fotokopi warta jemaat');
        c.read(routerProvider).go(Layar.draf.lokasi(param: {'id': _fotokopi}));
        await tester.pumpAndSettle();
        await tekan(tester, 'Periksa dan bukukan');
        final buku = tx.get(_fotokopi)!;
        expect(buku.isPosted, isTrue);
        expect(
          jejakTransaksi(c, _fotokopi, 'finance.txn.review').personId,
          'jefry',
        );
        expect(
          jejakTransaksi(c, _fotokopi, 'finance.txn.finalize').personId,
          'meiske',
        );

        // Found by Meiske, then by Jefry; the total is the listed rows' sum.
        for (final p in [Persona.meiske, Persona.jefry]) {
          if (p == Persona.jefry) {
            await keluar(tester);
            await masukSebagai(tester, p);
          }
          await bukaCari();
          await cari(_kueri);
          final baris = diBuku();
          expect(baris, hasLength(sebelum.length + 1), reason: p.name);
          jumlahSamaDenganBaris(baris, baris.length);
          expect(find.textContaining(buku.voucher!), findsOneWidget);
          expect(
            find.text(rp(baris.fold(0, (n, t) => n + signedAmount(t)))),
            findsWidgets,
            reason: p.name,
          );
        }
      });
    }
  });
}
