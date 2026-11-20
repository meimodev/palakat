// F10 Draft in a closed month (README 8.3): the M−2-dated draft (DP17 b) is
// refused at Bukukan; "Pindah tanggal" with a reason moves it to M0, or
// "Batalkan" with a reason gives "Dibatalkan" and no number; the link to
// the closed month's draft then disappears.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/domain/core/core.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/clock.dart';
import 'package:palakat_prototype/providers/keuangan/beranda.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';
import 'package:palakat_prototype/widgets/isian_alasan.dart';

import 'harness.dart';

const _id = 'draf-honor-pemusik-tutup';

void main() {
  group('F10 draf di bulan yang sudah ditutup', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      // The Transaksi link: the phone counts, the web board names it.
      final tautan = tata == Tata.web
          ? 'Draf di bulan yang sudah ditutup'
          : '1 draf di bulan yang sudah ditutup';

      for (final cara in ['pindah', 'batal']) {
        testWidgets('${tata.name} $cara', (tester) async {
          final c = await bukaAplikasi(tester, tata: tata);
          final tx = c.read(transactionRepositoryProvider);
          Transaction draf() => tx.get(_id)!;

          Future<void> bukaTransaksi() async {
            c.read(routerProvider).go(Layar.transaksi.lokasi());
            await tester.pumpAndSettle();
          }

          Future<void> isiAlasan(String teks) async {
            final f = find
                .descendant(
                  of: find.byType(IsianAlasan),
                  matching: find.byType(EditableText),
                )
                .first;
            await tester.enterText(f, teks);
            await tester.pumpAndSettle();
          }

          await masukSebagai(tester, Persona.meiske);

          // The draft lies in M−2, which is closed.
          final bulanDraf = c
              .read(bulanBukuProvider)
              .semua
              .singleWhere((p) => p.contains(draf().effectiveDate));
          expect(bulanDraf.isClosed, isTrue);
          expect(c.read(berandaKeuanganProvider).drafBulanTutup, hasLength(1));

          // Transaksi → the link opens the draft.
          await bukaTransaksi();
          await tekan(tester, tautan);
          expect(find.text('Honor pemusik'), findsOneWidget);

          // Refused at Bukukan: the board's closed-month refusal, no button,
          // and the repository refuses the booking too.
          expect(
            find.textContaining('Tidak dapat dilakukan: Bukukan.'),
            findsOneWidget,
          );
          expect(
            find.textContaining(
              '${namaBulan(bulanDraf)} sudah ditutup, dan draf ini',
            ),
            findsOneWidget,
          );
          expect(find.text('Periksa dan bukukan'), findsNothing);
          final meiske = c.read(actorProvider)!;
          final tolak = await tx.finalize(
            meiske,
            _id,
            expectedRevision: draf().revision,
            idempotencyKey: kunciBaru(meiske.personId, c.read(clockProvider)),
          );
          expect(tolak, isA<Refused<String>>());
          expect(
            (tolak as Refused<String>).refusal.because,
            contains('sudah ditutup'),
          );
          expect(draf().isDraft, isTrue);
          expect(draf().voucher, isNull);

          if (cara == 'pindah') {
            await tekan(tester, 'Pindah tanggal');
            final hari = c.read(hariIniProvider);
            final m0 = c.read(bulanBukuProvider).berjalan!;
            final ke = 'Pindah tanggal ke ${namaBulan(m0)}';
            // No reason, no move.
            await tester.tap(find.text(ke).last);
            await tester.pumpAndSettle();
            expect(draf().effectiveDate, isNot(hari));
            await isiAlasan('Salah tanggal, honor bulan ini');
            await tekan(tester, ke);

            expect(draf().effectiveDate, hari);
            expect(m0.contains(draf().effectiveDate), isTrue);
            expect(draf().status, TransactionStatus.draft);
            expect(draf().voucher, isNull);
            expect(
              find.textContaining('alasan: Salah tanggal, honor bulan ini'),
              findsOneWidget,
            );
            expect(
              find.textContaining('Tidak dapat dilakukan: Bukukan.'),
              findsNothing,
            );
            expect(find.text('Periksa dan bukukan'), findsOneWidget);
            final jejak = jejakTransaksi(c, draf().id, 'finance.txn.redate');
            expect(jejak.personId, 'meiske');
            expect(jejak.reason, 'Salah tanggal, honor bulan ini');
            expect(jejak.after, '$hari');
            // RD09: only into a later month; back into the month waiting to
            // close is refused.
            final mundur = await tx.redate(
              meiske,
              draf().id,
              c.read(bulanBukuProvider).berikutDitutup!.end,
              reason: 'Coba mundur',
              expectedRevision: draf().revision,
              idempotencyKey: kunciBaru(meiske.personId, c.read(clockProvider)),
            );
            expect(mundur, isA<Refused<Transaction>>());
            expect(draf().effectiveDate, hari);
          } else {
            await tekan(tester, 'Batalkan');
            // No reason, no cancel.
            await tester.tap(find.text('Batalkan draf').last);
            await tester.pumpAndSettle();
            expect(draf().isDraft, isTrue);
            await isiAlasan('Dicatat dua kali');
            await tester.tap(find.text('Batalkan draf').last);
            await tester.pumpAndSettle();

            expect(draf().status, TransactionStatus.cancelled);
            expect(draf().voucherNumber, isNull);
            expect(draf().cancelReason, 'Dicatat dua kali');
            expect(find.text('Dibatalkan'), findsOneWidget);
            expect(find.text('Alasan: Dicatat dua kali'), findsOneWidget);
            expect(
              find.textContaining('tidak pernah punya No. Bukti'),
              findsOneWidget,
            );
            expect(find.textContaining('BKU-'), findsNothing);
            final jejak = jejakTransaksi(c, draf().id, 'finance.txn.cancel');
            expect(jejak.personId, 'meiske');
            expect(jejak.reason, 'Dicatat dua kali');
          }

          // The link is gone.
          expect(c.read(berandaKeuanganProvider).drafBulanTutup, isEmpty);
          await bukaTransaksi();
          expect(find.text(tautan), findsNothing);
        });
      }
    }
  });
}
