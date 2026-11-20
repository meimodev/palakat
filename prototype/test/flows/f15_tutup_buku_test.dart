// F15 Month end and close (README 8.3): every computed blocker of M−1 is
// cleared on the screens the boards draw (BNI: 0131 in transit, the fee from
// "BIAYA ADM", match, confirm; the SulutGo statement; the Kas count; Kas
// Kolom 7, the Kolom 7 draft and the missing Kolom 7 readiness through
// SelesaikanUnit with a reason; Diakonia readiness by Olga; Pembangunan by
// Rivo). Holding the button closes M−1: "Sudah ditutup", snapshot
// SNP-{y}-{mm}-01, M0 next to close; booking or correcting into M−1 is then
// refused. `tutupBulanLalu` is the helper F16, F17 and F25 use.

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/app.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/clock.dart';
import 'package:palakat_prototype/providers/keuangan/akhir_bulan.dart';
import 'package:palakat_prototype/providers/keuangan/beranda.dart';
import 'package:palakat_prototype/providers/layout.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';
import 'package:palakat_prototype/providers/seed.dart';
import 'package:palakat_prototype/providers/session.dart';

import 'harness.dart';

ProviderContainer _c(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(PalakatApp)));

Future<void> _ke(WidgetTester tester, Layar l, {String? anak}) async {
  _c(tester).read(routerProvider).go(l.lokasi(anak: anak));
  await tester.pumpAndSettle();
}

/// Types [teks] into the [i]th text field on screen.
Future<void> _ketik(WidgetTester tester, String teks, {int i = 0}) async {
  final f = find.byType(EditableText).at(i);
  await tester.ensureVisible(f);
  await tester.enterText(f, teks);
  await tester.pumpAndSettle();
}

/// Pnt. Jefry Wowor opens the bank's reconciliation from his home row and
/// marks it "Sudah diperiksa" (D24); then the earlier persona signs in again.
Future<void> periksaRekonOlehJefry(WidgetTester tester, String akunId) async {
  final c = _c(tester);
  final sebelum = c.read(sessionProvider)?.persona;
  await keluar(tester);
  await masukSebagai(tester, Persona.jefry);
  // His home row opens the session waiting for his check (no direct go).
  final akun = c.read(rekonAkunProvider(akunId))!.akun.name;
  await tekan(tester, 'Rekonsiliasi $akun menunggu pemeriksaan');
  expect(find.text('Unggah mutasi dari file CSV'), findsNothing);
  await tekan(tester, 'Tandai sudah diperiksa');
  final s = c.read(rekonAkunProvider(akunId))!.sesi!;
  expect((s.status, s.reviewedBy), (ReconStatus.reviewed, 'jefry'));
  await keluar(tester);
  if (sebelum != null) await masukSebagai(tester, sebelum);
}

/// Clears every blocker of the next month to close through the screens and
/// closes it, at the layout the app runs in. Starts on the picker and ends
/// signed in as Meiske. Returns the closed period.
Future<Period> tutupBulanLalu(WidgetTester tester) async {
  final c = _c(tester);
  final web = c.read(layoutProvider) != Tata.ponsel;
  final per = c.read(periodRepositoryProvider);
  final bulan = c.read(bulanBukuProvider).berikutDitutup!;
  final nama = namaBulan(bulan);

  // Olga and Rivo state readiness for their Funds (DP37).
  for (final (orang, dana) in [
    (Persona.olga, 'Diakonia'),
    (Persona.rivo, 'Pembangunan'),
  ]) {
    await masukSebagai(tester, orang);
    await _ke(tester, Layar.kesiapan);
    expect(find.text('Peruntukan $dana'), findsOneWidget);
    await tekan(tester, 'Nyatakan siap');
    expect(find.text('Sudah dinyatakan siap'), findsOneWidget);
    await keluar(tester);
  }

  await masukSebagai(tester, Persona.meiske);
  await _ke(tester, Layar.tutupBuku);
  if (!web) await tekan(tester, 'Periksa kesiapan tutup buku');
  expect(find.text('Bank BNI ··4821 belum direkonsiliasi'), findsOneWidget);

  // BNI: match the two lines, 0131 in transit, the fee from "BIAYA ADM".
  await tekan(tester, 'Buka rekonsiliasi');
  await tekan(tester, 'Cocokkan');
  await tekan(tester, 'Cocokkan');
  await tekan(tester, 'Tandai dalam perjalanan');
  expect(
    c.read(rekonAkunProvider('bni'))!.dalamPerjalanan.map((t) => t.seedKey),
    ['0131'],
  );
  await tekan(tester, 'Buat transaksi dari mutasi ini');
  final biaya = c
      .read(transactionRepositoryProvider)
      .drafts()
      .singleWhere((t) => t.description == 'Biaya administrasi bank');
  await periksaOlehJefry(tester, 'Biaya administrasi bank');
  final nomor =
      'BKU-${bulan.year}-'
      '${(c.read(seedProvider).lastVoucher('BKU', bulan.year) + 1).toString().padLeft(4, '0')}';
  c.read(routerProvider).go(Layar.draf.lokasi(param: {'id': biaya.id}));
  await tester.pumpAndSettle();
  await tekan(tester, 'Periksa dan bukukan');
  expect(c.read(transactionRepositoryProvider).get(biaya.id)!.voucher, nomor);
  await _ke(tester, Layar.tutupBuku, anak: 'rekonsiliasi');
  expect(find.text('Rp0'), findsWidgets);
  // The second checker (D24): Meiske cannot mark it herself; Jefry does.
  await tekan(tester, 'Tandai sudah diperiksa');
  expect(
    find.textContaining('Pemeriksa kedua adalah orang lain'),
    findsWidgets,
  );
  expect(c.read(rekonAkunProvider('bni'))!.sesi!.status, ReconStatus.open);
  await periksaRekonOlehJefry(tester, 'bni');
  await _ke(tester, Layar.tutupBuku, anak: 'rekonsiliasi');
  expect(find.text('Sudah diperiksa'), findsWidgets);
  expect(
    find.text('Sudah diperiksa oleh Pnt. Jefry Wowor. Bendahara memastikan.'),
    findsOneWidget,
  );
  await tekan(tester, 'Pastikan rekonsiliasi');
  expect(find.text('Sudah dipastikan'), findsWidgets);
  final bni = c.read(rekonAkunProvider('bni'))!.sesi!;
  expect(bni.status, ReconStatus.confirmed);
  expect((bni.reviewedBy, bni.confirmedBy), ('jefry', 'meiske'));

  // SulutGo: the statement through RekonIsi.
  final bsg = c.read(rekonAkunProvider('bsg'))!;
  await _ke(tester, Layar.rekeningKoran);
  await _ketik(tester, '${bsg.buku}');
  await tekan(tester, 'Unggah mutasi dari file CSV');
  while (find.text('Cocokkan ·').evaluate().isNotEmpty) {
    await tekan(tester, 'Cocokkan ·');
  }
  expect(find.text('2 · Sudah diperiksa'), findsOneWidget); // three chips
  await periksaRekonOlehJefry(tester, 'bsg');
  await _ke(tester, Layar.rekeningKoran);
  expect(
    find.text('Sudah diperiksa oleh Pnt. Jefry Wowor. Bendahara memastikan.'),
    findsOneWidget,
  );
  await tekan(tester, 'Pastikan rekonsiliasi');
  expect(c.read(rekonAkunProvider('bsg'))!.dipastikan, isTrue);

  // The Kas count, equal to the book (selisih Rp0).
  final kas = c.read(hitungKasProvider)!;
  await _ke(tester, Layar.hitungKas);
  var sisa = kas.buku;
  final pecahan = [100000, 50000, 20000, 10000, 5000, 2000, 1000];
  for (var i = 0; i < pecahan.length; i++) {
    final p = pecahan[i];
    if (web) {
      // Web: one count field per denomination.
      if (sisa ~/ p > 0) await _ketik(tester, '${sisa ~/ p}', i: i);
    } else {
      for (var n = sisa ~/ p; n > 0; n--) {
        await tester.tap(find.bySemanticsLabel('Tambah satu lembar ${_rp(p)}'));
        await tester.pump();
      }
    }
    sisa %= p;
  }
  await tester.pumpAndSettle();
  await tekan(tester, 'Meiske L.');
  // The phone compares on its child route; the web board compares live.
  if (!web) await tekan(tester, 'Bandingkan dengan Saldo buku');
  expect(find.text('Hasil hitung kas sama dengan Saldo buku.'), findsOneWidget);
  await tekan(tester, 'Simpan hitung kas');
  expect(find.text('Hitung kas tersimpan'), findsOneWidget);
  expect(c.read(hitungKasProvider)!.dipastikan, isTrue);

  // Kolom 7 through SelesaikanUnit, each with a reason (DL33, DP37).
  await _ke(tester, Layar.hambatanUnit);
  for (final (aksi, tombol) in [
    ('Pindah tanggal', 'Pindah tanggal'),
    ('Pastikan dari hitung kas unit', 'Pastikan dari hitung kas unit'),
    ('Bebaskan', 'Bebaskan'),
  ]) {
    await tekan(tester, aksi);
    expect(
      find.text('Tidak dapat dilakukan: alasan belum diisi.'),
      findsOneWidget,
    );
    await _ketik(tester, 'Bendahara Kolom 7 sedang di luar kota.');
    await tekan(tester, tombol);
    expect(find.text('Diselesaikan'), findsWidgets);
  }
  expect(
    per.blockers(bulan.id),
    isEmpty,
    reason: '${per.blockers(bulan.id).map((b) => b.kind)}',
  );

  // The close: tick the statement, hold the button.
  await _ke(tester, Layar.tutupBuku);
  if (!web) {
    await tekan(tester, 'Periksa kesiapan tutup buku');
    expect(
      find.text('Tidak ada hambatan. $nama siap ditutup.'),
      findsOneWidget,
    );
    await tekan(tester, 'Lanjut ke konfirmasi tutup buku');
  }
  await tekan(tester, pernyataanTutup(bulan));
  await tahan(tester, 'Tutup buku $nama');
  await tungguTiruan(tester, const Duration(milliseconds: 1600));
  expect(find.text('Buku bulan $nama sudah ditutup.'), findsOneWidget);
  return per.period(bulan.id)!;
}

String _rp(int n) =>
    'Rp${n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+$)'), (_) => '.')}';

void main() {
  // The month-end AI panel keeps its proposals in AiRepository: asked once
  // for the month (cost added); "Buka untuk dicocokkan" opens the
  // reconciliation and is still recorded when the panel is opened again.
  group('F15 bantuan AI akhir bulan', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final c = await bukaAplikasi(tester, tata: tata, saat: jangkarA);
        await masukSebagai(tester, Persona.meiske);
        final ai = c.read(aiRepositoryProvider);
        final awal = ai.budget().spent;
        await _ke(tester, Layar.aiBulan);
        final usul = c.read(aiBulanProvider);
        final n = usul.usul.length + (usul.ringkasan == null ? 0 : 1);
        expect(usul.usul.map((u) => u.id), containsAll(['cocok']));
        expect(ai.budget().spent, awal + n * ai.budget().cost);
        final cocok = usul.usul.firstWhere((u) => u.id == 'cocok');
        await tekan(tester, 'Buka untuk dicocokkan');
        expect(find.text('Cocokkan'), findsWidgets);
        await _ke(tester, Layar.aiBulan);
        expect(find.text(cocok.jadi), findsOneWidget);
        expect(find.text('Buka untuk dicocokkan'), findsNothing);
        expect(ai.budget().spent, awal + n * ai.budget().cost);
      });
    }
  });

  group('F15 tutup buku', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      for (final (nama, saat) in [
        ('A', jangkarA),
        ('B', jangkarB),
        ('C', jangkarC),
      ]) {
        testWidgets('${tata.name} $nama', (tester) async {
          final c = await bukaAplikasi(tester, tata: tata, saat: saat);
          final bulan = c.read(bulanBukuProvider).berikutDitutup!;
          final berjalan = c.read(bulanBukuProvider).berjalan!;
          expect(bulan.end < berjalan.start, isTrue);
          // Computed labels (README 8.1): "Desember 2026" at B, a short
          // February at C.
          expect((namaBulan(berjalan), namaBulan(bulan)), bulanDiJangkar[saat]);
          final p = await tutupBulanLalu(tester);

          expect(p.isClosed, isTrue);
          final mm = bulan.month.toString().padLeft(2, '0');
          expect(p.snapshotId, 'SNP-${bulan.year}-$mm-01');
          expect(
            c.read(reportRepositoryProvider).snapshot(p.id)!.id,
            p.snapshotId,
          );
          expect(c.read(bulanBukuProvider).berikutDitutup!.id, berjalan.id);
          expect(c.read(sessionProvider)?.persona, Persona.meiske);
          // README 8.1: the audit actors of the close and the second check.
          expect(jejakTerakhir(c, 'finance.period.close').personId, 'meiske');
          expect(jejakTerakhir(c, 'finance.recon.review').personId, 'jefry');
          expect(jejakTerakhir(c, 'finance.recon.confirm').personId, 'meiske');
          final saya = c.read(actorProvider)!;
          final kunci = 'f15-${tata.name}-$nama';

          // Booking or correcting into the closed month is refused.
          final tx = c.read(transactionRepositoryProvider);
          final baru = await tx.createDraft(
            saya,
            TransactionDraft(
              type: TransactionType.expense,
              effectiveDate: bulan.end,
              description: 'Terlambat',
              accountId: 'kas',
              allocations: const [
                Allocation(amount: 1000, fundId: 'umum', scopeId: 'jemaat'),
              ],
            ),
            idempotencyKey: '$kunci-draf',
          );
          expect(baru.refusal?.because, contains('sudah ditutup'));
          final lama = tx.list(bulan.id).firstWhere((t) => t.isPosted);
          final koreksi = await tx.reverse(
            saya,
            lama.id,
            reason: 'salah',
            expectedRevision: lama.revision,
            idempotencyKey: '$kunci-balik',
          );
          expect(koreksi.refusal?.because, contains('catat kejadian'));
          // The same refusal on Koreksi, with the Kejadian way forward.
          c
              .read(routerProvider)
              .go(Layar.koreksi.lokasi(param: {'id': lama.id}));
          await tester.pumpAndSettle();
          expect(
            find.textContaining(
              'Tidak dapat dilakukan: koreksi dengan pembalikan',
            ),
            findsOneWidget,
          );
          expect(find.text('Catat kejadian'), findsOneWidget);

          // Back on Bulan: the closed card; M0 next to close.
          await _ke(tester, Layar.tutupBuku);
          expect(find.text('Sudah ditutup'), findsWidgets);
          expect(find.text(namaBulan(berjalan)), findsOneWidget);
          expect(
            find.text('Berikutnya untuk tutup buku · bulan berjalan'),
            findsOneWidget,
          );
          expect(c.read(clockProvider).now().isAfter(p.closedAt!), isFalse);
          tidakAdaTanggalNanti(tester, c.read(hariIniProvider), 'Bulan');
          await _ke(tester, Layar.keuangan);
          expect(find.textContaining(namaBulan(berjalan)), findsWidgets);
          tidakAdaTanggalNanti(tester, c.read(hariIniProvider), 'Beranda');
        });
      }
    }
  });
}
