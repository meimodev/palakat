// F6 Second checker, README 8.3: Meiske cannot mark her own draft; Jefry
// marks it "Sudah diperiksa"; "Ubah" returns it to Draf and drops the check;
// checked again, Meiske books it "Dibukukan" with the next free number.

import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';
import 'package:palakat_prototype/providers/seed.dart';

import 'harness.dart';

const _uraian = 'Fotokopi warta jemaat';

void main() {
  group('F6 pemeriksa kedua', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final wadah = await bukaAplikasi(tester, tata: tata);
        final tx = wadah.read(transactionRepositoryProvider);
        Transaction draf() => tx.drafts().firstWhere(
          (t) => t.description == _uraian,
          orElse: () =>
              tx.list(null).lastWhere((t) => t.description == _uraian),
        );
        Future<void> bukaPemeriksa() async {
          wadah.read(routerProvider).go(Layar.pemeriksa.lokasi());
          await tester.pumpAndSettle();
          await tekan(tester, _uraian);
        }

        final web = tata == Tata.web;
        await masukSebagai(tester, Persona.meiske);
        await bukaPemeriksa();

        // Her own draft: the mark is refused and pressing it changes nothing.
        expect(
          find.text(
            web
                ? 'Tidak dapat dilakukan: Anda yang mencatat transaksi ini. '
                      'Pemeriksa kedua: Pnt. Jefry Wowor.'
                : 'Tidak dapat dilakukan: Anda yang mencatat transaksi ini, '
                      'jadi orang lain yang harus menandainya sudah diperiksa. '
                      'Pemeriksa kedua: Pnt. Jefry Wowor.',
          ),
          findsOneWidget,
        );
        await tekan(tester, 'Tandai sudah diperiksa');
        expect(draf().status, TransactionStatus.draft);
        expect(find.text('Belum diperiksa'), findsOneWidget);

        // Jefry marks it; Meiske sees the check.
        await periksaOlehJefry(tester, _uraian);
        await bukaPemeriksa();
        expect(draf().status, TransactionStatus.reviewed);
        expect(draf().reviewedBy, 'jefry');
        expect(
          find.text('Sudah diperiksa · belum masuk saldo'),
          findsOneWidget,
        );
        expect(find.textContaining('Pnt. Jefry Wowor'), findsWidgets);

        // "Ubah" returns it to Draf and drops the check.
        if (web) {
          await tekan(tester, 'Ubah · kembali ke Draf');
        } else {
          await tekan(tester, 'Ubah');
          expect(
            find.text('Ubah transaksi yang sudah diperiksa?'),
            findsOneWidget,
          );
          await tekan(tester, 'Ubah dan kembalikan ke Draf');
        }
        expect(draf().status, TransactionStatus.draft);
        expect(draf().reviewedBy, isNull);
        expect(find.text('Draf · belum masuk saldo'), findsOneWidget);
        expect(find.text('Belum diperiksa'), findsOneWidget);

        // Checked again, then booked with the next free BKU number.
        final tahun = draf().effectiveDate.tahun;
        final nomor =
            wadah
                .read(seedProvider)
                .lastVoucher(VoucherSeries.bku.code, tahun) +
            1;
        await periksaOlehJefry(tester, _uraian);
        await bukaPemeriksa();
        await tekan(tester, 'Bukukan');
        final buku = draf();
        expect(buku.status, TransactionStatus.finalized);
        expect(buku.finalizedBy, 'meiske');
        expect(buku.voucher, voucherCode(VoucherSeries.bku, tahun, nomor));
        // The audit actors (AuditRepository): checked by Jefry, returned to
        // Draf and booked by Meiske.
        expect(
          jejakTransaksi(wadah, buku.id, 'finance.txn.review').personId,
          'jefry',
        );
        expect(
          jejakTransaksi(wadah, buku.id, 'finance.txn.edit').personId,
          'meiske',
        );
        final bukukan = jejakTransaksi(wadah, buku.id, 'finance.txn.finalize');
        expect(bukukan.personId, 'meiske');
        expect(bukukan.actingRole, 'Bendahara Jemaat');
        expect(find.text('Dibukukan'), findsWidgets);
        // The phone stamp may break after the last hyphen (U+200B).
        final cap = web
            ? buku.voucher!
            : buku.voucher!.replaceFirst(RegExp(r'-(?=\d+$)'), '-\u200B');
        expect(find.text('No. Bukti $cap'), findsOneWidget);
      });
    }
  });
}
