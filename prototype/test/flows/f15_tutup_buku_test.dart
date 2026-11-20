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

/// ponytail: M3 seeds the evidence and approvals of the posted rows
/// (seed_keuangan_kasus.dart). Until that file is merged, the M−1 rows get
/// verified stand-ins here; once M3's seed is in, this does nothing.
void penggantiBuktiM3(ProviderContainer c) {
  final k = c.read(seedProvider).keuangan;
  if (k.evidence.isNotEmpty || k.approvals.isNotEmpty) return;
  for (final t in k.transactions.where((t) => t.isPosted)) {
    if (t.evidenceRequired) {
      k.evidence.add(
        EvidenceItem(
          id: 'pengganti-${t.id}',
          transactionId: t.id,
          state: EvidenceItemState.verified,
          by: 'meiske',
          at: t.finalizedAt!,
        ),
      );
    }
    if (t.approvalMode == ApprovalMode.external) {
      k.approvals.add(
        ApprovalRecord(
          id: 'pengganti-${t.id}',
          transactionId: t.id,
          declaration: ApprovalDeclaration(
            approverName: 'Pdt. Lidya Rondonuwu',
            approverRole: 'Ketua BPMJ',
            date: t.effectiveDate,
            method: 'notulen rapat',
          ),
          recordedBy: 'meiske',
          recordedAt: t.finalizedAt!,
          transactionRevision: t.revision,
        ),
      );
    }
  }
}

/// ponytail: Pnt. Jefry Wowor has no screen to a reconciliation yet:
/// Layar.tutupBuku and Layar.rekeningKoran need financeClose and
/// financeReconcile, which the Pemeriksa kedua lacks (Request R4). Until the
/// guard admits financeReview he marks it "Sudah diperiksa" through
/// ReconciliationRepository.review as himself; the Bendahara then confirms
/// it on screen.
Future<void> periksaRekonOlehJefry(WidgetTester tester, String akunId) async {
  final c = _c(tester);
  final sebelum = c.read(sessionProvider)?.persona;
  await keluar(tester);
  await masukSebagai(tester, Persona.jefry);
  final s = c.read(rekonAkunProvider(akunId))!.sesi!;
  final h = await c
      .read(reconciliationRepositoryProvider)
      .review(
        c.read(actorProvider)!,
        s.id,
        expectedRevision: s.revision,
        idempotencyKey: 'periksa-rekon-${s.id}-${s.revision}',
      );
  expect(h.isOk, isTrue, reason: h.refusal?.because);
  await tester.pumpAndSettle();
  await keluar(tester);
  if (sebelum != null) await masukSebagai(tester, sebelum);
}

/// Clears every blocker of the next month to close through the screens and
/// closes it, at the layout the app runs in. Starts on the picker and ends
/// signed in as Meiske. Returns the closed period.
Future<Period> tutupBulanLalu(WidgetTester tester) async {
  final c = _c(tester);
  penggantiBuktiM3(c);
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

          // Back on Bulan: the closed card; M0 next to close.
          await _ke(tester, Layar.tutupBuku);
          expect(find.text('Sudah ditutup'), findsWidgets);
          expect(find.text(namaBulan(berjalan)), findsOneWidget);
          expect(
            find.text('Berikutnya untuk tutup buku · bulan berjalan'),
            findsOneWidget,
          );
          expect(c.read(clockProvider).now().isAfter(p.closedAt!), isFalse);
        });
      }
    }
  });
}
