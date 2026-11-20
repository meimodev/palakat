// F2 Record and book (README 8.3): a Belanja recorded through Catat (Tanggal,
// Mata Anggaran) is refused at Bukukan until checked; after periksaOlehJefry
// it books with the next free BKU number of its year; "Saldo buku" and
// "Belanja bulan ini" move by the amount; the row shows in Transaksi and
// Cari; "Simpan sebagai draf" instead adds to the draft pill's count and sum.
// Runs on phone, web and tablet at jangkarA, jangkarB and jangkarC.

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/format.dart';
import 'package:palakat_prototype/core/tanggal.dart';
import 'package:palakat_prototype/domain/core/core.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/keuangan/beranda.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';
import 'package:palakat_prototype/providers/seed.dart';

import 'harness.dart';

const _uraian = 'Lakban arsip warta';
const _kueri = 'lakban';
const _jumlah = 150000;
const _jumlahDraf = 50000;

/// Text containing [s] once zero-width breaks (U+200B, U+2060) are removed:
/// the web stamp may break a voucher after its hyphens.
Finder _teksBersih(String s) => find.byWidgetPredicate(
  (w) =>
      w is RichText &&
      w.text.toPlainText().replaceAll(RegExp('[\u200B\u2060]'), '').contains(s),
);

/// The next free BKU number of [tahun], counted from the records, not from
/// the counter: posted rows plus the DP7 numbers given but never finished.
/// Asserts they run from 0001 with no number skipped or used twice and that
/// each posted row carries its own date's year (DP38, DM 8 F12): at jangkarB
/// this is the year-boundary restart.
int _berikutnya(ProviderContainer c, int tahun) {
  final k = c.read(seedProvider).keuangan;
  for (final t in k.transactions) {
    if (t.isPosted) expect(t.voucherYear, t.effectiveDate.tahun);
  }
  final nomor = [
    for (final t in k.transactions)
      if (t.isPosted && t.series == VoucherSeries.bku && t.voucherYear == tahun)
        t.voucherNumber!,
    for (final u in k.unfinishedVouchers)
      if (u.series == VoucherSeries.bku && u.year == tahun) u.number!,
  ]..sort();
  expect(nomor, [for (var i = 1; i <= nomor.length; i++) i]);
  return nomor.length + 1;
}

void main() {
  group('F2 catat dan bukukan', () {
    for (final saat in [jangkarA, jangkarB, jangkarC]) {
      for (final tata in [Tata.ponsel, Tata.web, Tata.tablet]) {
        testWidgets('${tata.name} ${saat.toIso8601String()}', (tester) async {
          final c = await bukaAplikasi(tester, tata: tata, saat: saat);
          final ponsel = tata == Tata.ponsel;
          final tx = c.read(transactionRepositoryProvider);
          final hari = c.read(hariIniProvider);
          BerandaKeuangan beranda() => c.read(berandaKeuanganProvider);
          void pergi(Layar l) => c.read(routerProvider).go(l.lokasi());

          Future<void> keBeranda() async {
            pergi(Layar.keuangan);
            await tester.pumpAndSettle();
          }

          await masukSebagai(tester, Persona.meiske);
          await keBeranda();

          // Computed labels: the running month and the next one to close.
          final (berjalan, berikut) = bulanDiJangkar[saat]!;
          final b0 = beranda();
          expect(namaBulan(b0.bulan.berjalan!), berjalan);
          expect(namaBulan(b0.bulan.berikutDitutup!), berikut);
          expect(find.textContaining(berjalan), findsWidgets);
          expect(find.textContaining('$berikut belum ditutup'), findsWidgets);
          tidakAdaTanggalNanti(tester, hari, 'Beranda');

          final saldo0 = b0.saldoBuku, belanja0 = b0.bulanIni!.belanja;
          expect(find.text(rp(saldo0)), findsWidgets);
          expect(find.text(rp(belanja0)), findsWidgets);

          // Record a Belanja: Kas, Diakonia, Jemaat, a Mata Anggaran, and
          // day 1 of the running month picked in Tanggal.
          if (ponsel) {
            await tester.tap(find.bySemanticsLabel('Catat transaksi'));
            await tester.pumpAndSettle();
            await tester.tap(find.text('Belanja').last);
            await tester.pumpAndSettle();
          } else {
            pergi(Layar.catat);
            await tester.pumpAndSettle();
          }
          await tester.enterText(find.byType(EditableText).first, '$_jumlah');
          await tester.pumpAndSettle();
          await tekan(tester, 'Kas');
          await tekan(tester, 'Diakonia');
          await tekan(tester, 'Jemaat');
          if (ponsel) await tekan(tester, 'Mata Anggaran belum dipilih');
          await tekan(tester, 'Alat tulis dan fotokopi');
          await isi(tester, 'Uraian', _uraian);

          final tgl = Tanggal(hari.tahun, hari.bulan, 1);
          final tglTeks = tglPanjang(tgl.awal);
          await tekan(tester, ponsel ? 'Ubah' : 'Tanggal transaksi');
          expect(find.text('Pakai ${tglPanjang(hari.awal)}'), findsOneWidget);
          await tekan(tester, '1');
          await tekan(tester, 'Pakai $tglTeks');
          expect(find.textContaining(tglTeks), findsWidgets, reason: 'form');

          // Bukukan is refused until a second person checks it.
          await tekan(tester, 'Periksa dan bukukan');
          if (ponsel) await tekan(tester, 'Bukukan');
          expect(find.textContaining('Wajib pemeriksa kedua'), findsOneWidget);
          final d = tx.drafts().singleWhere((t) => t.description == _uraian);
          expect(d.status, TransactionStatus.draft);
          expect(d.effectiveDate, tgl);
          expect(d.allocations.single.masterCode, '5.02.01.00');
          expect(d.allocations.single.fundId, 'diak');
          expect(d.voucher, isNull);

          await periksaOlehJefry(tester, _uraian);
          expect(tx.get(d.id)!.status, TransactionStatus.reviewed);

          // Booked from Transaksi with the next free number of its year.
          final nomor = _berikutnya(c, tgl.tahun);
          await keBeranda();
          if (ponsel) {
            await tekan(tester, 'Transaksi');
            await tekan(tester, _uraian);
            await tekan(tester, 'Periksa dan bukukan');
            await tekan(tester, 'Bukukan');
            await tester.pump(const Duration(seconds: 2));
            await tester.pumpAndSettle();
          } else {
            pergi(Layar.transaksi);
            await tester.pumpAndSettle();
            await tekan(tester, _uraian);
            await tekan(tester, 'Periksa dan bukukan');
          }
          final t = tx.get(d.id)!;
          expect(t.status, TransactionStatus.finalized);
          expect(t.finalizedBy, 'meiske');
          expect(t.reviewedBy, 'jefry');
          expect(t.voucher, voucherCode(VoucherSeries.bku, tgl.tahun, nomor));
          expect(_berikutnya(c, tgl.tahun), nomor + 1);
          // The audit actors, from AuditRepository.
          expect(
            jejakTransaksi(c, d.id, 'finance.txn.draft').personId,
            'meiske',
          );
          expect(
            jejakTransaksi(c, d.id, 'finance.txn.review').personId,
            'jefry',
          );
          final buku = jejakTransaksi(c, d.id, 'finance.txn.finalize');
          expect(buku.personId, 'meiske');
          expect(buku.via, Via.direct);
          expect(buku.actingRole, 'Bendahara Jemaat');
          expect(_teksBersih(t.voucher!), findsWidgets);

          // The finance home moved by the amount.
          await keBeranda();
          final b1 = beranda();
          expect(b1.saldoBuku, saldo0 - _jumlah);
          expect(b1.bulanIni!.belanja, belanja0 + _jumlah);
          expect(find.text(rp(saldo0 - _jumlah)), findsWidgets);
          expect(find.text(rp(belanja0 + _jumlah)), findsWidgets);

          // The row shows in Transaksi...
          if (ponsel) {
            await tekan(tester, 'Transaksi');
          } else {
            pergi(Layar.transaksi);
            await tester.pumpAndSettle();
          }
          expect(find.text(_uraian), findsWidgets);
          expect(_teksBersih(t.voucher!), findsWidgets);
          tidakAdaTanggalNanti(tester, hari, 'Transaksi');

          // ...and in Cari.
          pergi(Layar.cari);
          await tester.pumpAndSettle();
          await tester.enterText(find.byType(EditableText).first, _kueri);
          await tester.pumpAndSettle();
          expect(find.text(_uraian), findsWidgets);
          expect(_teksBersih(t.voucher!), findsWidgets);

          // "Simpan sebagai draf" adds to the pill's count and sum instead.
          await keBeranda();
          final n0 = beranda().drafJumlah, rp0 = beranda().drafRp;
          expect(
            find.textContaining('${rp(rp0)} · $n0 draf · belum masuk saldo'),
            findsOneWidget,
          );
          if (ponsel) {
            await tester.tap(find.bySemanticsLabel('Catat transaksi'));
            await tester.pumpAndSettle();
            await tester.tap(find.text('Belanja').last);
            await tester.pumpAndSettle();
          } else {
            pergi(Layar.catat);
            await tester.pumpAndSettle();
          }
          await tester.enterText(
            find.byType(EditableText).first,
            '$_jumlahDraf',
          );
          await tester.pumpAndSettle();
          await tekan(tester, 'Simpan sebagai draf');
          if (ponsel) {
            await tungguTiruan(tester, const Duration(milliseconds: 2600));
          }
          await keBeranda();
          final b2 = beranda();
          expect(b2.drafJumlah, n0 + 1);
          expect(b2.drafRp, rp0 + _jumlahDraf);
          expect(
            find.textContaining(
              '${rp(rp0 + _jumlahDraf)} · ${n0 + 1} draf · belum masuk saldo',
            ),
            findsOneWidget,
          );
          expect(b2.saldoBuku, b1.saldoBuku, reason: 'a draft moves nothing');
          tidakAdaTanggalNanti(tester, hari, 'Beranda');
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
