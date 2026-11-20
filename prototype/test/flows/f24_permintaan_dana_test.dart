// F24 Fund request (README 8.3): Hendrik cannot approve his own request;
// Lidya approves (and in a second test refuses with a reason); Meiske's
// "Catat pembayaran" books Uang Muka diberikan after the check; the request
// reads "Dibayar"; a new advance is in Kewajiban; a request below
// Rp250.000 needs no approval (DL29).

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/app.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/domain/collaboration/collaboration.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';
import 'package:palakat_prototype/providers/repositories_kolaborasi.dart';
import 'package:palakat_prototype/providers/session.dart';

import 'harness.dart';

const _diakonia = 'permintaan-dana-diakonia';
const _kecil = 'Fotokopi daftar kunjungan';

ProviderContainer _c(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(PalakatApp)));

Future<void> _buka(WidgetTester tester) async {
  _c(tester).read(routerProvider).go(Layar.permintaanDana.lokasi());
  await tester.pumpAndSettle();
}

/// Taps [teks] under the request [id]'s card.
Future<void> _tekanDi(WidgetTester tester, String id, String teks) async {
  final f = find
      .descendant(of: find.byKey(ValueKey(id)), matching: find.text(teks))
      .first;
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

FundRequestView _v(WidgetTester tester, String id) =>
    _c(tester).read(fundRequestRepositoryProvider).get(id)!;

/// Hendrik sees his request waiting and is refused "Setujui", in the
/// screen and in the repository.
Future<void> _hendrikTidakMenyetujui(WidgetTester tester) async {
  await masukSebagai(tester, Persona.hendrik);
  await tekan(tester, 'Sebagai Ketua Komisi Diakonia');
  await _buka(tester);
  expect(find.text('Permintaan dana · Kunjungan diakonia'), findsOneWidget);
  expect(find.text('Menunggu persetujuan'), findsWidgets);
  expect(
    find.text(
      'Tidak dapat dilakukan: Setujui. permintaan ini Anda ajukan sendiri '
      'sebagai Ketua Komisi Diakonia.',
    ),
    findsOneWidget,
  );
  expect(
    find.descendant(
      of: find.byKey(const ValueKey(_diakonia)),
      matching: find.text('Setujui'),
    ),
    findsNothing,
  );
  final c = _c(tester);
  final r = await c
      .read(fundRequestRepositoryProvider)
      .approve(
        c.read(actorProvider)!,
        _diakonia,
        expectedRevision: _v(tester, _diakonia).request.revision,
        idempotencyKey: 'f24-hendrik-setujui',
      );
  expect(
    r.refusal?.because,
    'permintaan ini Anda ajukan sendiri sebagai Ketua Komisi Diakonia.',
  );
  expect(_v(tester, _diakonia).state, FundRequestState.waiting);
}

void main() {
  group('F24 permintaan dana', () {
    testWidgets('ponsel · disetujui, dibayar, di bawah batas', (tester) async {
      final c = await bukaAplikasi(tester);
      await _hendrikTidakMenyetujui(tester);

      // Below Rp250.000: no approval, the Bendahara is told.
      await tekan(tester, 'Ajukan permintaan');
      expect(find.text('Permintaan dana · $_kecil'), findsNothing);
      await isi(tester, 'Keperluan', _kecil);
      await isi(tester, 'Jumlah (Rp)', '200000');
      expect(
        find.text('Tidak dapat dilakukan: Ajukan. peruntukan belum dipilih.'),
        findsOneWidget,
      );
      await tekan(tester, 'Diakonia');
      await tekan(tester, 'Ajukan permintaan');
      expect(
        find.text('Bendahara Jemaat diberi tahu lewat Pemberitahuan.'),
        findsOneWidget,
      );
      expect(find.text('Permintaan dana · $_kecil'), findsOneWidget);
      expect(find.text('Tidak diperlukan'), findsOneWidget);
      expect(
        find.text(
          'Tidak diperlukan (aturan: di bawah Rp250.000 tidak perlu '
          'persetujuan).',
        ),
        findsOneWidget,
      );
      final kecil = c
          .read(fundRequestRepositoryProvider)
          .list(personId: 'hendrik')
          .singleWhere((v) => v.request.purpose == _kecil);
      expect(kecil.request.approval, RequestApproval.notRequired);
      expect(kecil.state, FundRequestState.noApprovalNeeded);
      expect(jejakTerakhir(c, 'request.submit').personId, 'hendrik');
      await keluar(tester);

      // Lidya approves from her home row.
      await masukSebagai(tester, Persona.lidya);
      await tekan(tester, 'Permintaan dana Komisi Diakonia');
      expect(find.text('Permintaan dana'), findsOneWidget);
      await _tekanDi(tester, _diakonia, 'Setujui');
      expect(find.text('Disetujui oleh Pdt. Lidya Rondonuwu'), findsOneWidget);
      expect(
        find.textContaining('Disetujui bukan berarti sudah dibayar.'),
        findsOneWidget,
      );
      final setuju = _v(tester, _diakonia);
      expect(setuju.state, FundRequestState.approved);
      expect(setuju.request.decision!.by, 'lidya');
      expect(jejakTerakhir(c, 'request.approve').personId, 'lidya');
      await keluar(tester);

      // Meiske records the payment; booking waits for the second check.
      await masukSebagai(tester, Persona.meiske);
      await tekan(tester, '2 permintaan dana siap dibayar');
      await _tekanDi(tester, _diakonia, 'Catat pembayaran');
      expect(find.text('Pembayaran dicatat'), findsOneWidget);
      final dicatat = _v(tester, _diakonia).request;
      expect(_v(tester, _diakonia).state, FundRequestState.paymentRecorded);
      final tx = c.read(transactionRepositoryProvider);
      final draf = tx.get(dicatat.paymentTransactionId!)!;
      expect(draf.type, TransactionType.advanceIssue);
      expect(draf.description, 'Uang Muka diberikan · Kunjungan diakonia');
      expect(draf.total, 750000);
      await _tekanDi(tester, _diakonia, 'Bukukan sebagai Uang Muka');
      expect(find.textContaining('Wajib pemeriksa kedua'), findsOneWidget);
      expect(tx.get(draf.id)!.isPosted, isFalse);

      await periksaOlehJefry(tester, draf.description);
      await _buka(tester);
      await _tekanDi(tester, _diakonia, 'Bukukan sebagai Uang Muka');
      expect(find.text('Dibayar'), findsOneWidget);
      expect(
        find.textContaining(
          'Dibukukan Bendahara Jemaat sebagai Uang Muka diberikan',
        ),
        findsOneWidget,
      );
      expect(_v(tester, _diakonia).state, FundRequestState.paid);
      final buku = tx.get(draf.id)!;
      expect(buku.isPosted, isTrue);
      expect(buku.voucher, startsWith('BKU-'));
      expect(
        jejakTransaksi(c, draf.id, 'finance.txn.finalize').personId,
        'meiske',
      );

      // The new advance is in Kewajiban.
      final kasus = c
          .read(caseRepositoryProvider)
          .advances()
          .singleWhere((k) => k.kase.id == dicatat.caseId);
      expect(kasus.outstanding, 750000);
      c.read(routerProvider).go(Layar.kewajiban.lokasi());
      await tester.pumpAndSettle();
      expect(find.textContaining('Kunjungan diakonia'), findsWidgets);
      expect(c.read(sessionProvider)?.persona, Persona.meiske);
    });

    testWidgets('ponsel · tidak disetujui dengan alasan', (tester) async {
      final c = await bukaAplikasi(tester);
      await _hendrikTidakMenyetujui(tester);
      await keluar(tester);

      await masukSebagai(tester, Persona.lidya);
      await _buka(tester);
      await _tekanDi(tester, _diakonia, 'Tidak disetujui');
      expect(find.text('Alasan · wajib'), findsOneWidget);
      await isi(tester, 'Alasan · wajib', 'Anggaran Desember sudah penuh');
      await _tekanDi(tester, _diakonia, 'Catat tidak disetujui');
      expect(
        find.text('Alasan: Anggaran Desember sudah penuh'),
        findsOneWidget,
      );
      final v = _v(tester, _diakonia);
      expect(v.state, FundRequestState.refused);
      expect(v.request.decision!.reason, 'Anggaran Desember sudah penuh');
      expect(jejakTerakhir(c, 'request.refuse').personId, 'lidya');
      await keluar(tester);

      // Hendrik is told, and nothing is payable.
      await masukSebagai(tester, Persona.hendrik);
      await tekan(tester, 'Sebagai Ketua Komisi Diakonia');
      expect(
        find.text('Permintaan dana Komisi Diakonia tidak disetujui'),
        findsOneWidget,
      );
      expect(v.payable, isFalse);
    });

    testWidgets('ponsel · jumlah diubah setelah disetujui', (tester) async {
      final c = await bukaAplikasi(tester);
      await masukSebagai(tester, Persona.lidya);
      await _buka(tester);
      await _tekanDi(tester, _diakonia, 'Setujui');
      expect(_v(tester, _diakonia).state, FundRequestState.approved);
      await keluar(tester);

      // DM 5.2: Hendrik changes the amount; the approval no longer holds.
      await masukSebagai(tester, Persona.hendrik);
      await tekan(tester, 'Sebagai Ketua Komisi Diakonia');
      await _buka(tester);
      await _tekanDi(tester, _diakonia, 'Ubah jumlah');
      await isi(tester, 'Jumlah baru (Rp)', '900000');
      await _tekanDi(tester, _diakonia, 'Simpan jumlah');
      expect(
        find.textContaining('Tidak dapat dilakukan: Ubah jumlah. alasan'),
        findsOneWidget,
      );
      await isi(tester, 'Alasan · wajib', 'Tambah dua keluarga');
      await _tekanDi(tester, _diakonia, 'Simpan jumlah');
      final v = _v(tester, _diakonia);
      expect(v.state, FundRequestState.waiting);
      expect(v.request.amount, 900000);
      expect(v.request.decisions.single.superseded, isTrue);
      expect(
        find.text(
          'Jumlah diubah dari Rp750.000 menjadi Rp900.000 setelah disetujui. '
          'Persetujuan lama tidak berlaku lagi dan tetap ada di Riwayat.',
        ),
        findsOneWidget,
      );
      expect(c.read(sessionProvider)?.persona, Persona.hendrik);
    });
  });
}
