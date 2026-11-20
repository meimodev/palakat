// F5 Advances, deposits, claims (README 8.3): a settlement of um1 lowers its
// remainder; KasusBaru lists a new case with its due date; spending above an
// advance is refused and offered as Penggantian biaya; the home row "N uang
// muka…" follows the count; um2 shows overdue at both dates.

import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/format.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';

import 'harness.dart';

const _pj = 'Pertanggungjawaban uang muka · Panitia Natal';
const _baru = 'Konsumsi rapat Wilayah';

void main() {
  group('F5 kewajiban', () {
    for (final (tata, saat) in [
      (Tata.ponsel, jangkarA),
      (Tata.web, jangkarA),
      (Tata.ponsel, jangkarB),
      (Tata.web, jangkarB),
    ]) {
      testWidgets('${tata.name} $saat', (tester) async {
        final w = await bukaAplikasi(tester, tata: tata, saat: saat);
        final web = tata == Tata.web;
        final kasus = w.read(caseRepositoryProvider);
        Future<void> buka(String lokasi) async {
          w.read(routerProvider).go(lokasi);
          await tester.pumpAndSettle();
        }

        Future<void> ketik(int i, String teks) async {
          final f = find.byType(EditableText).at(i);
          await tester.ensureVisible(f);
          await tester.enterText(f, teks);
          await tester.pumpAndSettle();
        }

        int sisaUangMuka() => kasus
            .advances()
            .where((c) => c.outstanding > 0)
            .fold(0, (s, c) => s + c.outstanding);
        int jumlahUangMuka() =>
            kasus.advances().where((c) => c.outstanding > 0).length;

        await masukSebagai(tester, Persona.meiske);

        // Computed month labels on the finance home (README 8.1).
        final (berjalan, berikut) = bulanDiJangkar[saat]!;
        await buka(Layar.keuangan.lokasi());
        expect(find.textContaining(berjalan), findsWidgets);
        expect(find.textContaining('$berikut belum ditutup'), findsWidgets);

        // The list: computed remainders; um2 is overdue at both dates, on
        // its own page too.
        await buka(Layar.kewajiban.lokasi(anak: 'kasus/um2'));
        expect(find.textContaining('Lewat jatuh tempo'), findsWidgets);
        await buka(Layar.kewajiban.lokasi());
        expect(kasus.caseById('um2')!.overdue, isTrue);
        expect(kasus.caseById('um1')!.outstanding, 650000);
        expect(
          find.text('Sisa belum dipertanggungjawabkan · 2 kasus'),
          findsOneWidget,
        );
        expect(find.text(rp(sisaUangMuka())), findsWidgets);
        expect(find.textContaining('Lewat jatuh tempo'), findsWidgets);

        // um1: above the remainder is refused and offered as a claim.
        await buka(Layar.kewajiban.lokasi(anak: 'kasus/um1'));
        await tekan(tester, 'Catat pertanggungjawaban');
        final isian = web ? find.byType(EditableText).last : null;
        Future<void> jumlah(String n) async {
          final f = isian ?? find.byType(EditableText).last;
          await tester.enterText(f, n);
          await tester.pumpAndSettle();
        }

        await jumlah('700000');
        expect(
          find.textContaining(
            'melebihi sisa Rp650.000. Kelebihan belanja dicatat sebagai '
            'Penggantian biaya.',
          ),
          findsOneWidget,
        );
        final sebelum = w.read(transactionRepositoryProvider).drafts().length;
        await tekan(tester, 'Bukukan pertanggungjawaban');
        expect(w.read(transactionRepositoryProvider).drafts().length, sebelum);

        // A valid settlement waits for the second checker, then books.
        await jumlah('200000');
        await tekan(tester, 'Bukukan pertanggungjawaban');
        expect(find.textContaining('Wajib pemeriksa kedua'), findsOneWidget);
        expect(kasus.caseById('um1')!.outstanding, 650000);

        // KasusBaru: a new advance with its due date.
        final hari = w.read(transactionRepositoryProvider);
        final akhir = DateTime.utc(saat.year, saat.month + 1, 0);
        await buka(Layar.kasusBaru.lokasi());
        await ketik(0, 'Pnt. Jefry Wowor');
        await ketik(1, '300000');
        await tekan(tester, 'Kas');
        await tekan(tester, 'Umum Jemaat');
        await tekan(tester, 'Jemaat');
        await ketik(2, _baru);
        await tekan(tester, tglPanjang(akhir));
        await tekan(tester, 'Periksa dan bukukan');
        expect(find.text('Dicatat sebagai draf'), findsOneWidget);
        expect(hari.drafts().any((t) => t.description.endsWith(_baru)), isTrue);

        await buka(Layar.kewajiban.lokasi());
        expect(find.text(_baru), findsOneWidget);
        expect(find.textContaining(tgl(akhir)), findsWidgets);

        // Jefry checks both drafts; Meiske books them from the cases.
        await periksaOlehJefry(tester, _pj);
        await periksaOlehJefry(tester, 'Uang Muka diberikan · $_baru');
        final hitung = jumlahUangMuka();
        final tx = w.read(transactionRepositoryProvider);
        final dPj = tx.drafts().singleWhere((t) => t.description == _pj);
        final dBaru = tx.drafts().singleWhere(
          (t) => t.description.endsWith(_baru),
        );
        final tahun = w.read(hariIniProvider).tahun;
        final nomor =
            tx
                .voucherSeries(VoucherSeries.bku, tahun)
                .fold(0, (m, e) => max(m, e.number)) +
            1;
        await buka(Layar.kewajiban.lokasi(anak: 'kasus/um1'));
        await tekan(
          tester,
          web
              ? 'Periksa dan bukukan · Pertanggungjawaban uang muka'
              : 'Periksa dan bukukan',
        );
        expect(kasus.caseById('um1')!.outstanding, 450000);
        expect(find.text('Rp450.000'), findsWidgets);

        final baru = kasus.advances().firstWhere((c) => c.kase.title == _baru);
        await buka(Layar.kewajiban.lokasi(anak: 'kasus/${baru.kase.id}'));
        await tekan(
          tester,
          web
              ? 'Periksa dan bukukan · Uang Muka diberikan'
              : 'Periksa dan bukukan',
        );
        expect(kasus.caseById(baru.kase.id)!.outstanding, 300000);
        expect(jumlahUangMuka(), hitung + 1);
        // The next free numbers of today's year (a restart at date B).
        expect(
          (tx.get(dPj.id)!.voucher, tx.get(dBaru.id)!.voucher),
          (
            voucherCode(VoucherSeries.bku, tahun, nomor),
            voucherCode(VoucherSeries.bku, tahun, nomor + 1),
          ),
        );

        // The home row follows the count.
        await buka(Layar.keuangan.lokasi());
        expect(
          find.textContaining(
            '${jumlahUangMuka()} uang muka dengan sisa belum '
            'dipertanggungjawabkan',
          ),
          findsOneWidget,
        );
        expect(kasus.caseById('um2')!.overdue, isTrue);
        tidakAdaTanggalNanti(tester, w.read(hariIniProvider), 'Beranda');

        // "Cek klaim" records the check; no balance changes.
        await buka(Layar.kewajiban.lokasi(anak: 'kasus/pb1'));
        await tekan(tester, 'Cek klaim · tidak mengubah saldo');
        expect(kasus.caseById('pb1')!.kase.checkedBy, 'meiske');
        expect(find.textContaining('klaim sudah dicek'), findsWidgets);
        // README 8.1: the audit actor of the commands run here.
        expect(jejakTerakhir(w, 'finance.case.claim.check').personId, 'meiske');
        expect(jejakTerakhir(w, 'finance.txn.finalize').personId, 'meiske');
        expect(jejakTerakhir(w, 'finance.txn.review').personId, 'jefry');
      });
    }
  });
}
