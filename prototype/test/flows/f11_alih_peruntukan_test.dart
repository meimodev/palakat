// F11 Fund transfer (README 8.3): AlihPeruntukan moves money between two
// peruntukan inside one Kas/Bank as a fundTransfer draft; the same source and
// target, and an amount above the source's balance there, are refused; after
// periksaOlehJefry it is booked and both peruntukan balances change while
// the Kas/Bank balance does not.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/keuangan/kasus.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';

import 'harness.dart';

const _dasar = 'keputusan rapat BPMJ';

void main() {
  group('F11 alih peruntukan', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final w = await bukaAplikasi(tester, tata: tata);
        final tx = w.read(transactionRepositoryProvider);
        final akun = w.read(accountRepositoryProvider);
        await masukSebagai(tester, Persona.meiske);
        final p = w.read(pilihanKasusBaruProvider);
        final bank = p.kasBank.firstWhere((k) => k.id == 'bni');
        final dari = p.peruntukan.firstWhere((x) => x.id == 'umum');
        final ke = p.peruntukan.firstWhere((x) => x.id == 'diak');
        final awal = akun.balanceByFund(bank.id);
        final total = akun.balance(bank.id);

        w.read(routerProvider).go(Layar.alihPeruntukan.lokasi());
        await tester.pumpAndSettle();
        Future<void> ketuk(Finder f) async {
          await tester.ensureVisible(f);
          await tester.pumpAndSettle();
          await tester.tap(f);
          await tester.pumpAndSettle();
        }

        Future<void> ketik(int i, String teks) async {
          final f = find.byType(EditableText).at(i);
          await tester.ensureVisible(f);
          await tester.enterText(f, teks);
          await tester.pumpAndSettle();
        }

        await tekan(tester, bank.nama);
        await ketuk(find.text(dari.nama).at(0));
        await ketuk(find.text(dari.nama).at(1));
        await ketik(0, '500000');
        await ketik(1, _dasar);
        expect(
          find.textContaining('peruntukan asal dan tujuan harus berbeda'),
          findsOneWidget,
        );
        await ketuk(find.text(ke.nama).at(1));
        await ketik(0, '${awal[dari.id]! + 1}');
        expect(
          find.textContaining('melebihi saldo peruntukan ${dari.nama}'),
          findsOneWidget,
        );
        final sebelum = tx.drafts().length;
        await tekan(tester, 'Periksa dan bukukan');
        expect(tx.drafts().length, sebelum);

        await ketik(0, '500000');
        expect(find.textContaining('Tidak dapat dibukukan'), findsNothing);
        await tekan(tester, 'Periksa dan bukukan');
        expect(find.textContaining('Wajib pemeriksa kedua'), findsOneWidget);
        final d = tx.drafts().singleWhere(
          (t) => t.type == TransactionType.fundTransfer,
        );
        expect(akun.balanceByFund(bank.id)[dari.id], awal[dari.id]);

        await periksaOlehJefry(tester, d.description);
        w.read(routerProvider).go(Layar.draf.lokasi(param: {'id': d.id}));
        await tester.pumpAndSettle();
        await tekan(tester, 'Periksa dan bukukan');
        expect(tx.get(d.id)!.isPosted, isTrue);
        final akhir = akun.balanceByFund(bank.id);
        expect(akhir[dari.id], awal[dari.id]! - 500000);
        expect(akhir[ke.id], (awal[ke.id] ?? 0) + 500000);
        expect(akun.balance(bank.id), total);
      });
    }
  });
}
