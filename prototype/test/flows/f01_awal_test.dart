// F1 Opening, read-only (README 8.3, D19): Awal reads "6 dari 6 langkah";
// the opening batch OPN-{cutover year}-0001 with the computed total per
// account; no input is editable; "Mulai mencatat" opens the finance home.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/format.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/core_repositories.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';

import 'harness.dart';

void main() {
  group('F1 pengaturan awal', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final c = await bukaAplikasi(tester, tata: tata);
        await masukSebagai(tester, Persona.meiske);
        final buka = c.read(openingRepositoryProvider).opening()!;
        final opn = c
            .read(transactionRepositoryProvider)
            .get(buka.transactionId)!;
        final kode = voucherCode(VoucherSeries.opn, buka.cutoverDate.tahun, 1);
        expect(opn.voucher, kode);
        expect(opn.status, TransactionStatus.finalized);
        final perAkun = <String, int>{};
        for (final a in opn.allocations) {
          perAkun[a.accountId!] = (perAkun[a.accountId!] ?? 0) + a.amount;
        }
        final akun = c.read(accountRepositoryProvider);
        String nama(String id) => akun
            .accounts(includeInactive: true)
            .firstWhere((a) => a.id == id)
            .name;
        void tidakAdaIsian() => expect(
          tester
              .widgetList<EditableText>(find.byType(EditableText))
              .every((e) => e.readOnly),
          isTrue,
          reason: 'tidak ada isian yang dapat diubah',
        );
        String polos(String t) => t.replaceAll('​', '');
        Finder berisi(String t) => find.byWidgetPredicate(
          (w) => w is RichText && polos(w.text.toPlainText()).contains(t),
        );

        c.read(routerProvider).go(Layar.awal.lokasi());
        await tester.pumpAndSettle();
        final jemaat = c.read(workspaceRepositoryProvider).workspace().name;
        expect(find.text('$jemaat · 6 dari 6 langkah selesai'), findsOneWidget);
        expect(berisi('Dibukukan · $kode'), findsWidgets);
        // DP16: the four Kas/Bank of the opening, not Kas Panitia HUT.
        expect(perAkun, hasLength(4));
        expect(berisi('${perAkun.length} Kas/Bank ·'), findsWidgets);
        tidakAdaIsian();

        if (tata == Tata.ponsel) {
          await tekan(tester, 'Saldo awal pencatatan');
        }
        expect(berisi('No. Bukti $kode'), findsOneWidget);
        expect(
          berisi(rp(perAkun.values.fold(0, (s, x) => s + x))),
          findsWidgets,
        );
        for (final e in perAkun.entries) {
          expect(berisi(nama(e.key)), findsWidgets);
          expect(find.text(rp(e.value)), findsWidgets, reason: nama(e.key));
        }
        tidakAdaIsian();

        // Identity and lists: read-only, the cutover's.
        c.read(routerProvider).go(Layar.awalIsian.lokasi());
        await tester.pumpAndSettle();
        expect(find.text('Pengaturan awal diterbitkan'), findsOneWidget);
        expect(find.text('Tambah'), findsNothing);
        expect(berisi(nama('hut')), findsNothing);
        tidakAdaIsian();

        // "Mulai mencatat" opens the finance home: on the phone, the home
        // `/` itself (owner change 21/11).
        c.read(routerProvider).go(Layar.awal.lokasi());
        await tester.pumpAndSettle();
        await tekan(tester, 'Mulai mencatat');
        expect(
          lokasiSekarang(tester),
          tata == Tata.ponsel ? Layar.beranda.jalur : Layar.keuangan.lokasi(),
        );
        expect(find.text('Saldo buku semua Kas/Bank'), findsWidgets);
      });
    }
  });
}
