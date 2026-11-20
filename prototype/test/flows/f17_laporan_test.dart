// F17 Reports (README 8.3): a Belanja booked in the test after
// `periksaOlehJefry` shows in Bukti and in the provisional report; before the
// close the provisional ribbon, after it the official ribbon, and the F01,
// F02, F14 and Excel document views render; every report figure equals the
// sum of the rows LihatTransaksi lists for it; Bukti's gap view lists the
// allocated unfinished numbers: 6 at date A, and at date B 4 in M−1's year
// and 2 in M0's (DP7).

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/app.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/keuangan/beranda.dart';
import 'package:palakat_prototype/providers/keuangan/laporan.dart';
import 'package:palakat_prototype/providers/layout.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';
import 'package:palakat_prototype/providers/seed.dart';

import 'f15_tutup_buku_test.dart' show tutupBulanLalu;
import 'harness.dart';

ProviderContainer _c(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(PalakatApp)));

Future<void> _ke(
  WidgetTester tester,
  Layar l, {
  Map<String, String> p = const {},
  String? anak,
}) async {
  _c(tester).read(routerProvider).go(l.lokasi(param: p, anak: anak));
  await tester.pumpAndSettle();
}

const _uraian = 'Fotokopi laporan akhir bulan';

/// Every F05/F07 figure equals the sum of the parts LihatTransaksi lists.
void _angkaSama(ProviderContainer c) {
  final angka = c.read(angkaLaporanProvider);
  expect(angka, isNotEmpty);
  for (final a in angka) {
    expect(a.rows.fold(0, (n, r) => n + r.jm), a.total, reason: a.n);
  }
}

void main() {
  group('F17 laporan', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      for (final (nama, saat) in [('A', jangkarA), ('B', jangkarB)]) {
        testWidgets('${tata.name} $nama', (tester) async {
          final c = await bukaAplikasi(tester, tata: tata, saat: saat);
          final web = c.read(layoutProvider) != Tata.ponsel;
          final bulan = c.read(bulanBukuProvider).berikutDitutup!;
          final berjalan = c.read(bulanBukuProvider).berjalan!;
          final tx = c.read(transactionRepositoryProvider);
          final hari = c.read(hariIniProvider);
          // Computed labels (README 8.1): "Desember 2026" next to close at B.
          expect((namaBulan(berjalan), namaBulan(bulan)), bulanDiJangkar[saat]);

          // Bukti's gap view (DP7).
          final celah = {
            for (final b in c.read(buktiProvider)) b.tahun: b.celah.length,
          };
          if (nama == 'A') {
            expect(celah.values.fold(0, (n, x) => n + x), 6);
          } else {
            expect(celah[bulan.year], 4);
            expect(celah[berjalan.year], 2);
          }

          // A Belanja into M−1, checked by Jefry and booked by Meiske.
          await masukSebagai(tester, Persona.meiske);
          final draf = await tx.createDraft(
            c.read(actorProvider)!,
            TransactionDraft(
              type: TransactionType.expense,
              effectiveDate: bulan.end,
              description: _uraian,
              accountId: 'kas',
              evidenceRequired: false,
              allocations: const [
                Allocation(
                  amount: 45000,
                  fundId: 'umum',
                  scopeId: 'jemaat',
                  masterCode: '5.02.01.00',
                ),
              ],
            ),
            idempotencyKey: 'f17-${tata.name}-$nama',
          );
          final id = draf.value.id;
          await periksaOlehJefry(tester, _uraian);
          final nomor =
              'BKU-${bulan.year}-'
              '${(c.read(seedProvider).lastVoucher('BKU', bulan.year) + 1).toString().padLeft(4, '0')}';
          await _ke(tester, Layar.draf, p: {'id': id});
          await tekan(tester, 'Periksa dan bukukan');
          final t = tx.get(id)!;
          expect(t.isPosted, isTrue);
          expect(t.voucher, nomor);

          // Bukti lists it; the gap view lists the numbers.
          await _ke(tester, Layar.bukti);
          expect(find.textContaining(_uraian), findsOneWidget);
          await tekan(tester, 'Celah nomor');
          expect(
            find.textContaining('pembukuannya tidak selesai'),
            findsNWidgets(celah.values.fold(0, (n, x) => n + x)),
          );
          // Per BKU year on screen (at B: 4 in M−1's year, 2 in M0's).
          for (final MapEntry(key: tahun, value: n) in celah.entries) {
            expect(
              find.byWidgetPredicate(
                (w) =>
                    w is RichText &&
                    w.text.toPlainText().contains('BKU-$tahun-') &&
                    w.text.toPlainText().contains('pembukuannya tidak selesai'),
              ),
              findsNWidgets(n),
              reason: 'celah $tahun',
            );
          }
          tidakAdaTanggalNanti(tester, hari, 'Bukti');

          // The provisional report holds it.
          await _ke(tester, Layar.laporan);
          expect(find.textContaining('Bukan laporan resmi'), findsWidgets);
          expect(find.textContaining(namaBulan(bulan)), findsWidgets);
          tidakAdaTanggalNanti(tester, hari, 'Laporan');
          if (web) {
            await _ke(tester, Layar.paketLaporan);
          } else {
            await _ke(tester, Layar.laporan, anak: 'rinci/F02');
          }
          expect(find.textContaining(_uraian), findsWidgets);
          final l = c.read(laporanBulanProvider)!;
          expect(l.periode.id, bulan.id);
          expect(l.resmi, isFalse);
          final f07 = l
              .data(ReportForm.f07)
              .rows
              .firstWhere((r) => r['code'] == '5.02.01.00');
          expect(f07['amount'], greaterThanOrEqualTo(45000));
          _angkaSama(c);
          await _ke(tester, Layar.lihatTransaksi);
          expect(
            find.textContaining('sama dengan angka di laporan'),
            findsOneWidget,
          );
          await _ke(
            tester,
            Layar.laporanResmi,
            p: {'periode': bulan.id, 'bentuk': 'sementara'},
          );
          expect(find.textContaining('LAPORAN SEMENTARA'), findsWidgets);

          // The close; then the official ribbon and the document views.
          await keluar(tester);
          final p = await tutupBulanLalu(tester);
          await _ke(tester, Layar.laporan);
          expect(find.textContaining(p.snapshotId!), findsWidgets);
          expect(find.textContaining('Bukan laporan resmi'), findsNothing);
          expect(c.read(laporanBulanProvider)!.resmi, isTrue);
          _angkaSama(c);
          for (final (bentuk, judul) in [
            ('f01', 'LAPORAN PERBENDAHARAAN BULANAN'),
            ('f02', 'BUKU KAS UMUM'),
            ('f14', 'LAMPIRAN LAPORAN BULANAN'),
            ('excel', 'Contoh file Excel'),
          ]) {
            await _ke(
              tester,
              Layar.laporanResmi,
              p: {'periode': p.id, 'bentuk': bentuk},
            );
            expect(find.text(judul), findsOneWidget, reason: bentuk);
            expect(tester.takeException(), isNull, reason: bentuk);
            if (bentuk != 'excel') {
              expect(
                find.textContaining('LAPORAN RESMI'),
                findsWidgets,
                reason: bentuk,
              );
            }
          }
          // F02 pages through every row: the booked Belanja is on one.
          await _ke(
            tester,
            Layar.laporanResmi,
            p: {'periode': p.id, 'bentuk': 'f02'},
          );
          final halaman =
              (c.read(laporanBulanProvider)!.data(ReportForm.f02).rows.length +
                  10) ~/
              11;
          // The M−1 reversal chain (seed 0105 → 0109 → 0110) carries its
          // tags, computed from the transactions.
          final balik = tx
              .list(p.id)
              .firstWhere((t) => t.isPosted && t.reversalOf != null);
          final asal = tx.get(balik.reversalOf!)!;
          final tanda = {
            'Dibalik oleh ${balik.voucher}',
            for (final t in tx.list(p.id))
              if (t.isPosted && t.correctionOf == asal.id)
                'Koreksi dari ${asal.voucher}',
          };
          expect(tanda, hasLength(2));
          final terlihat = <String>{};
          void lihat() {
            if (find.text(_uraian).evaluate().isNotEmpty) terlihat.add(_uraian);
            for (final x in tanda) {
              if (find.text(x).evaluate().isNotEmpty) terlihat.add(x);
            }
          }

          lihat();
          for (var i = 1; i < halaman; i++) {
            await tekan(tester, 'Halaman berikutnya');
            lihat();
          }
          expect(terlihat, {_uraian, ...tanda});
        });
      }
    }
  });
}
