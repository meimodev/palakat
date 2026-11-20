// F22 Restricted access (README 8.3, D27): Olga sees only Diakonia rows and
// balance; a Diakonia transaction booked in the test appears; the TERBATAS
// PDF and Excel views hold only Diakonia rows; other funds' screens are
// "Tidak berwenang" for her.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/app.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/format.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/keuangan/laporan.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';
import 'package:palakat_prototype/providers/seed.dart';

import 'f15_tutup_buku_test.dart' show penggantiBuktiM3;
import 'harness.dart';

ProviderContainer _c(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(PalakatApp)));

Future<void> _ke(
  WidgetTester tester,
  Layar l, {
  Map<String, String> p = const {},
}) async {
  _c(tester).read(routerProvider).go(l.lokasi(param: p));
  await tester.pumpAndSettle();
}

const _uraian = 'Persembahan Diakonia syukur keluarga';

void main() {
  group('F22 terbatas', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final c = await bukaAplikasi(tester, tata: tata, saat: jangkarA);
        penggantiBuktiM3(c);
        final k = c.read(seedProvider).keuangan;
        final tx = c.read(transactionRepositoryProvider);
        bool diakonia(String id) => k.transactions
            .firstWhere((t) => t.id == id)
            .allocations
            .any((a) => a.fundId == 'diak' || a.toFundId == 'diak');

        // Meiske records a Diakonia offering; Jefry checks; Meiske books it.
        await masukSebagai(tester, Persona.meiske);
        final draf = await tx.createDraft(
          c.read(actorProvider)!,
          TransactionDraft(
            type: TransactionType.income,
            effectiveDate: c.read(hariIniProvider),
            description: _uraian,
            accountId: 'kas',
            evidenceRequired: false,
            allocations: const [
              Allocation(
                amount: 120000,
                fundId: 'diak',
                scopeId: 'jemaat',
                masterCode: '1.3.55.01.00',
              ),
            ],
          ),
          idempotencyKey: 'f22-${tata.name}',
        );
        final id = draf.value.id;
        await periksaOlehJefry(tester, _uraian);
        await _ke(tester, Layar.draf, p: {'id': id});
        await tekan(tester, 'Periksa dan bukukan');
        final no = tx.get(id)!.voucher!;
        await keluar(tester);

        // Olga: only Diakonia.
        await masukSebagai(tester, Persona.olga);
        final t = c.read(terbatasProvider)!;
        expect(t.dana.id, 'diak');
        expect(t.baris.map((r) => r.no), contains(no));
        expect(t.baris.every((r) => diakonia(r.id)), isTrue);
        final semua = {
          for (final x in k.posted)
            if (effectsOf(x).any(
              (e) =>
                  e.legs.any((l) => l.accountId != null && l.fundId == 'diak'),
            ))
              x.id,
        };
        expect(t.baris.map((r) => r.id).toSet(), semua);
        await _ke(tester, Layar.terbatas);
        expect(
          find.textContaining('Akses terbatas: Peruntukan Diakonia'),
          findsWidgets,
        );
        expect(find.text(rp(t.saldo)), findsOneWidget);
        expect(find.textContaining(no), findsWidgets);

        // The TERBATAS copies of the last closed month and of this month
        // (which holds the offering booked above): only Diakonia rows, in
        // the datasets and on the PDF and Excel views.
        final bulanIni = k.periodOf(c.read(hariIniProvider))!;
        for (final p in [t.ditutup!, bulanIni]) {
          final r = c.read(laporanTerbatasProvider(p.id))!;
          for (final f in [ReportForm.f02, ReportForm.f03, ReportForm.f12]) {
            for (final row in r.datasets[f]!.rows) {
              final tid = row['transactionId'] as String?;
              if (tid != null) expect(diakonia(tid), isTrue, reason: '$f');
            }
          }
          Set<String> kode(ReportForm f) => {
            for (final row in r.datasets[f]!.rows)
              if (row['postable'] == true && row['amount'] != 0)
                row['code'] as String,
          };
          final dalam = [
            for (final x in k.posted)
              if (p.contains(x.effectiveDate)) x,
          ];
          final kodeDiak = {...kode(ReportForm.f05), ...kode(ReportForm.f07)};
          final kodeLain = {
            for (final x in dalam)
              for (final a in x.allocations)
                if (a.fundId != 'diak' && a.masterCode != null) a.masterCode!,
          }.difference(kodeDiak);
          final noDiak = {
            for (final x in dalam)
              if (diakonia(x.id)) x.voucher!,
          };
          final noLain = {
            for (final x in dalam)
              if (!diakonia(x.id)) x.voucher!,
          };
          // M−2 moves Diakonia only through the opening balance (no Mata
          // Anggaran); this month has the offering.
          if (p == bulanIni) {
            expect(kodeDiak, contains('1.3.55.01.00'));
            expect(noDiak, contains(no));
          }
          expect(kodeLain, isNotEmpty);
          void hanyaDiakonia(Iterable<String> ada, Iterable<String> tidak) {
            for (final x in ada) {
              expect(find.text(x), findsWidgets, reason: '${p.id} $x');
            }
            for (final x in tidak) {
              expect(find.text(x), findsNothing, reason: '${p.id} $x');
            }
          }

          await _ke(
            tester,
            Layar.laporanTerbatas,
            p: {'periode': p.id, 'bentuk': 'pdf'},
          );
          expect(find.text('REALISASI MENURUT MATA ANGGARAN'), findsOneWidget);
          expect(
            find.textContaining('Akses terbatas: Peruntukan Diakonia'),
            findsWidgets,
          );
          hanyaDiakonia(kodeDiak, kodeLain);
          expect(tester.takeException(), isNull);
          await _ke(
            tester,
            Layar.laporanTerbatas,
            p: {'periode': p.id, 'bentuk': 'excel'},
          );
          expect(find.text('Contoh file Excel TERBATAS'), findsOneWidget);
          hanyaDiakonia(kode(ReportForm.f05), kodeLain);
          await tekan(tester, 'F02');
          hanyaDiakonia(noDiak, noLain);
          expect(tester.takeException(), isNull);
        }

        // Whole-Jemaat screens are refused ("Tidak berwenang").
        for (final l in [Layar.laporan, Layar.bukti, Layar.lihatTransaksi]) {
          expect(
            c.read(penjagaProvider(l)),
            Penjaga.tidakBerwenang,
            reason: l.name,
          );
          await _ke(tester, l);
          expect(
            find.textContaining('tidak melihat data ini'),
            findsWidgets,
            reason: l.name,
          );
        }
      });
    }
  });
}
