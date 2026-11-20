// F16 Incident after close (README 8.3): after `tutupBulanLalu`, the finding
// "Kas … lebih Rp85.000" is recorded on Kejadian with the next K number
// (`K-{y}-02` at date A, DP18). The closed month's figures do not change;
// the settlement is a separate draft in M0, booked after `periksaOlehJefry`;
// M0's blockers stay (D11).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/app.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/providers/keuangan/beranda.dart';
import 'package:palakat_prototype/providers/layout.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';
import 'package:palakat_prototype/providers/seed.dart';

import 'f15_tutup_buku_test.dart' show tutupBulanLalu;
import 'harness.dart';

ProviderContainer _c(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(PalakatApp)));

Future<void> _ke(WidgetTester tester, Layar l, {Map<String, String>? p}) async {
  _c(tester).read(routerProvider).go(l.lokasi(param: p ?? const {}));
  await tester.pumpAndSettle();
}

void main() {
  group('F16 kejadian', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final c = await bukaAplikasi(tester, tata: tata, saat: jangkarA);
        final ditutup = await tutupBulanLalu(tester);
        final k = c.read(seedProvider).keuangan;
        final per = c.read(periodRepositoryProvider);
        final tx = c.read(transactionRepositoryProvider);
        final berjalan = c.read(bulanBukuProvider).berjalan!;
        final kasDitutup = k.accountBalance('kas', at: ditutup.end);
        final barisDitutup = tx.list(ditutup.id).length;
        final tahun = c.read(bulanBukuProvider).berjalan!.year;

        await _ke(tester, Layar.kejadian);
        expect(find.text('K-$tahun-01'), findsWidgets);
        await tekan(tester, 'Catat kejadian baru');
        await isi(tester, 'Judul', 'Kas Jemaat lebih Rp85.000');
        await isi(
          tester,
          'Penjelasan',
          'Hitung ulang kas menemukan uang Rp85.000 lebih dari buku.',
        );
        await isi(tester, 'Dampak pada rekonsiliasi', 'Tidak ada.');
        await isi(tester, 'Penanggung jawab', 'Meiske L., Bendahara');
        await tekan(tester, 'Uang masuk ke Kas');
        await isi(tester, 'Jumlah penyelesaian', '85000');
        await tekan(tester, 'Catat kejadian');

        final baru = per.incidents().last;
        expect(baru.code, 'K-$tahun-02');
        expect(baru.periodId, ditutup.id);
        expect(find.text('K-$tahun-02'), findsWidgets);
        expect(find.text('Kas Jemaat lebih Rp85.000'), findsWidgets);

        // The closed month's figures are unchanged.
        expect(k.accountBalance('kas', at: ditutup.end), kasDitutup);
        expect(tx.list(ditutup.id).length, barisDitutup);
        expect(per.period(ditutup.id)!.isClosed, isTrue);

        // The settlement: a separate draft in M0, booked after the check.
        final draf = tx.get(baru.settlementTransactionId!)!;
        expect(draf.isPosted, isFalse);
        expect(berjalan.contains(draf.effectiveDate), isTrue);
        await periksaOlehJefry(tester, draf.description);
        final nomor =
            'BKU-${berjalan.year}-'
            '${(c.read(seedProvider).lastVoucher('BKU', berjalan.year) + 1).toString().padLeft(4, '0')}';
        await _ke(tester, Layar.draf, p: {'id': draf.id});
        await tekan(tester, 'Periksa dan bukukan');
        expect(tx.get(draf.id)!.voucher, nomor);
        expect(k.accountBalance('kas', at: ditutup.end), kasDitutup);

        // M0's blockers stay.
        expect(per.blockers(berjalan.id), isNotEmpty);
        await _ke(tester, Layar.kejadian);
        if (c.read(layoutProvider) == Tata.ponsel) {
          await tekan(tester, 'Kas Jemaat lebih Rp85.000');
        }
        expect(
          find.text('Hambatan tutup buku ${namaBulan(berjalan)} tetap ada.'),
          findsOneWidget,
        );
        expect(find.textContaining(nomor), findsOneWidget);
      });
    }
  });
}
