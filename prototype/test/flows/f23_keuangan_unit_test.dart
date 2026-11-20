// F23 Unit finance (README 8.3): Deasy books on Kas Kolom 7 in the Kolom 7
// fund after the second check; the BNI draft and the Diakonia draft are
// refused (DL26, DL32); she declares readiness for M−1 after that booking;
// Meiske clears the Kolom 7 blockers with a reason and Deasy gets a notice
// (DL33); TutupBuku /cek no longer shows the unit blockers. The Bendahara
// side runs on the phone and on the web (WebAlurUnit).

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/app.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/core_repositories.dart';
import 'package:palakat_prototype/providers/keuangan/akhir_bulan.dart';
import 'package:palakat_prototype/providers/keuangan/beranda.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';
import 'package:palakat_prototype/widgets/kecil.dart';

import 'harness.dart';

const _uraian = 'Persembahan syukur Kolom 7';
const _alasan = 'Bendahara Kolom 7 sedang di luar kota.';

ProviderContainer _c(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(PalakatApp)));

Future<void> _ke(WidgetTester tester, Layar l, {String? anak}) async {
  _c(tester).read(routerProvider).go(l.lokasi(anak: anak));
  await tester.pumpAndSettle();
}

/// Taps "Bukukan" on the draft card "Draf · [uraian]".
Future<void> _bukukanDraf(WidgetTester tester, String uraian) async {
  final f = find
      .descendant(
        of: find.ancestor(
          of: find.text('Draf · $uraian'),
          matching: find.byType(Kartu),
        ),
        matching: find.text('Bukukan'),
      )
      .first;
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// The Kolom 7 blockers of the month to close.
List<ButirHambatan> _unit(ProviderContainer c) => [
  for (final h in c.read(tutupBukuProvider).hambatan)
    if (h.dariUnit) h,
];

/// Meiske, on KeuanganUnit (phone) or WebAlurUnit (web), clears every
/// Kolom 7 blocker with a reason; then TutupBuku shows none.
Future<void> _bendaharaMenyelesaikan(WidgetTester tester, bool web) async {
  final c = _c(tester);
  final bulan = c.read(bulanBukuProvider).berikutDitutup!;
  await masukSebagai(tester, Persona.meiske);
  expect(find.textContaining('hambatan dari unit'), findsOneWidget);
  await _ke(tester, Layar.tutupBuku, anak: web ? null : 'cek');
  expect(find.text('Selesaikan untuk unit'), findsWidgets);

  await _ke(tester, Layar.keuanganUnit);
  expect(find.text('Keuangan unit'), findsWidgets);
  // Every unit blocker, each with a reason (the Diakonia readiness too).
  const aksi = ['Pindah tanggal', 'Pastikan dari hitung kas unit', 'Bebaskan'];
  for (var n = 0; n < 6; n++) {
    final t = aksi.where((x) => find.text(x).evaluate().isNotEmpty).firstOrNull;
    if (t == null) break;
    await tekan(tester, t);
    expect(
      find.text('Tidak dapat dilakukan: alasan belum diisi.'),
      findsOneWidget,
    );
    final f = find.byType(EditableText).first;
    await tester.ensureVisible(f);
    await tester.enterText(f, _alasan);
    await tester.pumpAndSettle();
    await tekan(tester, t);
    expect(find.text('Diselesaikan'), findsWidgets);
  }
  expect(_unit(c), isEmpty);
  expect(
    find.text(
      'Tidak ada hambatan dari unit untuk tutup buku ${namaBulan(bulan)}.',
    ),
    findsOneWidget,
  );
  expect(jejakTerakhir(c, 'finance.unit.clear').personId, 'meiske');

  await _ke(tester, Layar.tutupBuku, anak: web ? null : 'cek');
  expect(find.text('Selesaikan untuk unit'), findsNothing);
  await _ke(tester, Layar.beranda);
  expect(find.textContaining('hambatan dari unit'), findsNothing);

  // Deasy is told (DL33).
  final kabar = c.read(notificationRepositoryProvider).inbox('deasy');
  expect(
    kabar.where((n) => n.body.contains(_alasan)),
    isNotEmpty,
    reason: kabar.map((n) => n.title).join('; '),
  );
}

void main() {
  group('F23 keuangan unit', () {
    testWidgets('ponsel', (tester) async {
      final c = await bukaAplikasi(tester);
      final tx = c.read(transactionRepositoryProvider);
      final akun = c.read(accountRepositoryProvider);
      final bulan = c.read(bulanBukuProvider).berikutDitutup!;
      final saldo0 = akun.balance('kol7');

      await masukSebagai(tester, Persona.deasy);
      await tekan(tester, '2 draf Kolom 7 belum dibukukan');
      expect(find.text('Keuangan Kolom 7'), findsOneWidget);
      expect(find.text('Kas Kolom 7'), findsWidgets);

      // A Pendapatan on Kas Kolom 7 in the Kolom 7 fund.
      await tekan(tester, 'Pendapatan');
      expect(
        find.text(
          'Tidak dapat dilakukan: Bukukan. Mata Anggaran belum dipilih.',
        ),
        findsOneWidget,
      );
      await tekan(tester, 'Persembahan syukur');
      await isi(tester, 'Jumlah (Rp)', '250000');
      await tekan(tester, 'Bank BNI ··4821');
      expect(
        find.text(
          'Tidak dapat dilakukan: Bukukan. Kas/Bank ini tidak dikelola Kolom 7.',
        ),
        findsOneWidget,
      );
      await tekan(tester, 'Kas Kolom 7');
      await isi(tester, 'Uraian', _uraian);
      await tekan(tester, 'Bukukan');
      // Saved as a draft; the second checker has not looked yet (D24).
      expect(find.text('Draf · $_uraian'), findsOneWidget);
      expect(find.textContaining('Wajib pemeriksa kedua'), findsOneWidget);
      final draf = tx.drafts().singleWhere((t) => t.description == _uraian);
      expect(draf.unitScopeId, 'kolom-7');

      await periksaOlehJefry(tester, _uraian);
      await _ke(tester, Layar.keuanganUnit);
      await _bukukanDraf(tester, _uraian);
      expect(find.text('Dibukukan di peruntukan Kolom 7.'), findsOneWidget);
      final buku = tx.get(draf.id)!;
      expect(buku.isPosted, isTrue);
      expect(
        find.text('${buku.voucher} · ${buku.effectiveDate} · Dibukukan'),
        findsOneWidget,
      );
      expect(akun.balance('kol7'), saldo0 + 250000);
      final jejak = jejakTransaksi(c, draf.id, 'finance.txn.finalize');
      expect((jejak.personId, jejak.scopeId), ('deasy', 'kolom-7'));

      // DL32: not on a church account, not from another unit's fund.
      await _bukukanDraf(tester, 'Konsumsi ibadah Kolom');
      expect(
        find.textContaining(
          'dikelola oleh Bendahara Jemaat, bukan oleh Kolom 7.',
        ),
        findsOneWidget,
      );
      await _bukukanDraf(tester, 'Bantuan duka');
      expect(
        find.textContaining('peruntukan Diakonia bukan peruntukan Kolom 7.'),
        findsOneWidget,
      );
      expect(tx.get('draf-kolom7-konsumsi')!.isDraft, isTrue);
      expect(tx.get('draf-kolom7-duka')!.isDraft, isTrue);

      // Readiness for M−1 after that booking.
      await tekan(tester, 'Nyatakan siap');
      expect(find.text('Sudah dinyatakan siap'), findsOneWidget);
      final siap = c
          .read(periodRepositoryProvider)
          .attestations(bulan.id)
          .singleWhere((v) => v.fundId == 'kol7');
      expect(siap.state, ReadinessState.current);
      expect(jejakTerakhir(c, 'finance.readiness.attest').personId, 'deasy');
      expect(
        _unit(c).map((h) => h.blocker.kind),
        isNot(contains(BlockerKind.readinessMissing)),
      );
      await keluar(tester);

      await _bendaharaMenyelesaikan(tester, false);
      expect(
        bulan.contains(tx.get('draf-kolom7-konsumsi')!.effectiveDate),
        isFalse,
      );
      await keluar(tester);

      // Deasy sees the moved draft in the running month.
      await masukSebagai(tester, Persona.deasy);
      await _ke(tester, Layar.keuanganUnit);
      expect(find.text('Draf · Konsumsi ibadah Kolom'), findsOneWidget);
      expect(c.read(actorProvider)?.personId, 'deasy');
    });

    testWidgets('web · Bendahara Jemaat', (tester) async {
      await bukaAplikasi(tester, tata: Tata.web);
      await _bendaharaMenyelesaikan(tester, true);
    });
  });
}
