// P17 Cross-module report (README 8.3): each viewer sees only the figures
// they may see: Lidya the whole church, Hendrik Kolom 7, Rivo Panitia
// Natal (advance um1, its settlements and its remainder; the Panitia Natal
// fund itself is Rp0, DP27). Every figure is computed.

import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/format.dart';
import 'package:palakat_prototype/providers/core_repositories.dart';
import 'package:palakat_prototype/providers/repositories_jemaat.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';
import 'package:palakat_prototype/providers/repositories_kolaborasi.dart';

import 'harness.dart';

const _semuaKas = 'Saldo buku semua Kas/⁠Bank';

void main() {
  group('P17 laporan lintas', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final c = await bukaAplikasi(tester, tata: tata);
        final anggota = c.read(memberRepositoryProvider);
        final dana = c.read(fundRepositoryProvider);
        final panitia = c.read(panitiaRepositoryProvider);
        Future<void> buka() async {
          c.read(routerProvider).go(Layar.laporanLintas.lokasi());
          await tester.pumpAndSettle();
          expect(find.text('Laporan'), findsWidgets);
        }

        // Lidya: the whole church.
        await masukSebagai(tester, Persona.lidya);
        await buka();
        final semua = anggota.counts();
        final kolom = c
            .read(orgRepositoryProvider)
            .scopes()
            .where((s) => s.id.startsWith('kolom-'))
            .length;
        expect(find.text(titik('${semua.active}')), findsOneWidget);
        expect(find.text('di $kolom Kolom'), findsOneWidget);
        expect(find.text(titik('${semua.households}')), findsOneWidget);
        expect(find.text('231'), findsOneWidget);
        expect(find.text('hanya yang Ditetapkan'), findsOneWidget);
        // All Kas/Bank: the sum of the account balances.
        final akun = c.read(accountRepositoryProvider);
        final kas = akun
            .accounts(includeInactive: true)
            .fold(0, (n, a) => n + akun.balance(a.id));
        expect(dana.ownedBalance(null), kas);
        expect(find.text(_semuaKas), findsOneWidget);
        expect(find.text(rp(kas)), findsOneWidget);
        expect(find.textContaining('Uang Muka ·'), findsNothing);
        await keluar(tester);

        // Hendrik as Penatua Kolom 7: Kolom 7 only.
        await masukSebagai(tester, Persona.hendrik);
        await tekan(tester, 'Sebagai Penatua Kolom 7');
        await buka();
        final k7 = anggota.counts(kolom: 'kolom-7');
        expect(find.text('Kolom 7 saja'), findsOneWidget);
        expect(find.text(titik('${k7.active}')), findsOneWidget);
        expect(find.text(titik('${k7.households}')), findsOneWidget);
        expect(find.text('Saldo buku peruntukan Kolom 7'), findsOneWidget);
        expect(find.text(rp(dana.ownedBalance('kolom-7'))), findsOneWidget);
        expect(find.text(_semuaKas), findsNothing);
        expect(find.text(titik('${semua.active}')), findsNothing);
        expect(find.textContaining('Diakonia'), findsNothing);
        await keluar(tester);

        // Rivo: Panitia Natal's money, the advance um1 (DP27).
        await masukSebagai(tester, Persona.rivo);
        final sebagai = find.text('Sebagai Bendahara Panitia Natal 2026');
        if (sebagai.evaluate().isNotEmpty) {
          await tekan(tester, 'Sebagai Bendahara Panitia Natal 2026');
        }
        await buka();
        final m = panitia.money('panitia-natal');
        expect(m.fundBalance, 0);
        expect(m.advanced, 1500000);
        expect(m.settled, 850000);
        expect(m.outstanding, 650000);
        final natal = panitia.get('panitia-natal')!.name;
        expect(find.text('Saldo buku peruntukan $natal'), findsOneWidget);
        expect(find.text('Panitia · tahap Aktif'), findsOneWidget);
        expect(find.text('Uang Muka · Panitia Natal'), findsOneWidget);
        for (final n in [m.advanced, m.settled, m.outstanding]) {
          expect(find.text(rp(n)), findsOneWidget);
        }
        expect(find.text(_semuaKas), findsNothing);
        expect(find.text('Anggota aktif'), findsNothing);
        expect(find.text('Saldo buku peruntukan Kolom 7'), findsNothing);
      });
    }
  });
}
