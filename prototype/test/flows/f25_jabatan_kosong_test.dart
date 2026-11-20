// F25 Vacant Bendahara post, README 8.3: Lidya ends Meiske's term in
// Penugasan; the post reads vacant; Yanti takes cover with a reason and the
// acknowledgement; phone finance screens show PitaJabatanKosong and web ones
// the vacancy band and footer; Yanti records and, after Jefry's check, books,
// and the detail and Riwayat read "oleh Yanti Sumual, Operator …"; Yanti is
// refused as checker; Lidya assigns Yohanis Tumbelaka, active after the
// board timer; the cover ends and the strip is gone.

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/data/repositories/role_repository.dart';
import 'package:palakat_prototype/domain/core/core.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/core_repositories.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';
import 'package:palakat_prototype/shell/nav_samping.dart';
import 'package:palakat_prototype/widgets/pita_jabatan_kosong.dart';

import 'harness.dart';

const _uraian = 'Lakban arsip Kolom';
const _oleh =
    'Yanti Sumual, Operator · menjalankan jabatan kosong Bendahara Jemaat';

PostView _bendahara(ProviderContainer c) => c
    .read(roleRepositoryProvider)
    .posts()
    .firstWhere((p) => p.post.id == 'bendahara-jemaat');

Finder _memuat(String s) => find.textContaining(s, findRichText: true);

/// The web vacancy footer (NavSamping's PenggunaSesi).
final _footer = find.descendant(
  of: find.byType(PenggunaSesi),
  matching: _memuat(
    'Yanti Sumual · Operator\nMenjalankan jabatan kosong Bendahara Jemaat',
  ),
);

void main() {
  group('F25 jabatan kosong', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final c = await bukaAplikasi(tester, tata: tata);
        final ponsel = tata == Tata.ponsel;
        final tx = c.read(transactionRepositoryProvider);
        Future<void> buka(Layar l, {String? anak}) async {
          c.read(routerProvider).go(l.lokasi(anak: anak));
          await tester.pumpAndSettle();
        }

        // Lidya ends Meiske's term: the post reads vacant.
        await masukSebagai(tester, Persona.lidya);
        await buka(Layar.penugasan);
        await tekan(tester, 'Catat berakhir');
        expect(find.text('Meiske Lumentut'), findsWidgets);
        await isi(tester, 'Alasan · wajib', 'Mengundurkan diri');
        await tekan(tester, 'Catat berakhir');
        final hari = c.read(hariIniProvider);
        expect(
          find.text(
            'Bendahara Jemaat: penugasan Meiske Lumentut berakhir $hari. '
            'Jabatan ini menjadi Jabatan kosong.',
          ),
          findsOneWidget,
        );
        expect(_bendahara(c).vacant, isTrue);
        expect(find.text('Jabatan kosong'), findsWidgets);
        await keluar(tester);

        // Yanti takes cover with a reason and the acknowledgement.
        await masukSebagai(tester, Persona.yanti);
        expect(find.text('Jabatan Bendahara Jemaat kosong'), findsOneWidget);
        await buka(Layar.jabatanKosong);
        // Ended live today: vacant from today (DP19).
        expect(_memuat('Kosong sejak $hari'), findsOneWidget);
        await tekan(tester, 'Jalankan jabatan kosong');
        expect(find.text('Bendahara Jemaat'), findsWidgets);
        await isi(tester, 'Alasan · wajib', 'Bendahara belum ditugaskan');
        expect(_memuat('pernyataan belum dicentang.'), findsOneWidget);
        await tekan(
          tester,
          'Saya mengerti setiap tindakan saya tercatat sebagai dijalankan '
          'oleh Operator, dan jabatan ini kembali kepada pemegangnya begitu '
          'ditugaskan.',
        );
        await tekan(tester, 'Jalankan jabatan kosong');
        expect(
          find.text(
            'Anda menjalankan jabatan kosong Bendahara Jemaat sejak '
            '$hari.',
          ),
          findsOneWidget,
        );
        expect(_bendahara(c).cover?.personId, 'yanti');
        expect(c.read(vacancyCoverProvider), isTrue);
        expect(
          jejakTerakhir(c, 'role.cover').reason,
          'Bendahara belum ditugaskan',
        );

        // The strip (phone) or the band and footer (web) on finance screens.
        await buka(Layar.keuangan);
        if (ponsel) {
          expect(find.byType(PitaJabatanKosong), findsOneWidget);
          expect(_memuat('Menjalankan jabatan kosong'), findsWidgets);
        } else {
          expect(find.byType(PitaJabatanKosong), findsOneWidget);
          expect(
            _memuat('Anda menjalankan jabatan kosong Bendahara Jemaat sejak'),
            findsOneWidget,
          );
          expect(_footer, findsOneWidget);
        }

        // Yanti records a Belanja; Bukukan waits for the second check.
        if (ponsel) {
          await tester.tap(find.bySemanticsLabel('Catat transaksi'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Belanja').last);
          await tester.pumpAndSettle();
          expect(find.byType(PitaJabatanKosong), findsOneWidget);
        } else {
          await buka(Layar.catat);
        }
        await tester.enterText(find.byType(EditableText).first, '75000');
        await tester.pumpAndSettle();
        await tekan(tester, 'Kas');
        await tekan(tester, 'Diakonia');
        await tekan(tester, 'Jemaat');
        if (ponsel) await tekan(tester, 'Mata Anggaran belum dipilih');
        await tekan(tester, 'Alat tulis dan fotokopi');
        await isi(tester, 'Uraian', _uraian);
        await tekan(tester, 'Periksa dan bukukan');
        if (ponsel) await tekan(tester, 'Bukukan');
        expect(find.textContaining('Wajib pemeriksa kedua'), findsOneWidget);
        final d = tx.drafts().singleWhere((t) => t.description == _uraian);

        // Yanti is refused as checker.
        await buka(Layar.pemeriksa);
        final lain = tx
            .drafts()
            .firstWhere(
              (t) => t.status == TransactionStatus.draft && t.id != d.id,
            )
            .description;
        await tekan(tester, lain);
        expect(
          _memuat(
            'Operator yang menjalankan jabatan kosong tidak dapat menjadi '
            'pemeriksa.',
          ),
          findsWidgets,
        );

        // After Jefry's check, Yanti books it.
        await periksaOlehJefry(tester, _uraian);
        if (ponsel) {
          await buka(Layar.keuangan);
          await tekan(tester, 'Transaksi');
          expect(find.byType(PitaJabatanKosong), findsOneWidget);
          await tekan(tester, _uraian);
          expect(find.byType(PitaJabatanKosong), findsOneWidget);
          await tekan(tester, 'Periksa dan bukukan');
          await tekan(tester, 'Bukukan');
          await tester.pump(const Duration(seconds: 2));
          await tester.pumpAndSettle();
        } else {
          await buka(Layar.transaksi);
          await tekan(tester, _uraian);
          await tekan(tester, 'Periksa dan bukukan');
        }
        final t = tx.get(d.id)!;
        expect(t.status, TransactionStatus.finalized);
        expect(t.finalizedBy, 'yanti');
        final buku = jejakTransaksi(c, d.id, 'finance.txn.finalize');
        expect(buku.actorLine, _oleh);
        expect(buku.via, const ViaVacancyCover('bendahara-jemaat'));

        // The detail and Riwayat name the Operator.
        c
            .read(routerProvider)
            .go(Layar.transaksiRinci.lokasi(param: {'id': d.id}));
        await tester.pumpAndSettle();
        expect(_memuat(_oleh), findsWidgets, reason: 'detail');
        if (!ponsel) {
          expect(_memuat('Dibukukan oleh $_oleh'), findsWidgets);
        }
        await buka(Layar.pengaturan, anak: ponsel ? 'riwayat' : null);
        expect(_memuat(_oleh), findsWidgets, reason: 'Riwayat');
        await keluar(tester);

        // Lidya assigns Yohanis Tumbelaka; after the board timer he is
        // active, the cover ends and the strip is gone.
        await masukSebagai(tester, Persona.lidya);
        await buka(Layar.penugasan);
        await tekan(tester, 'Tugaskan');
        await isi(tester, 'Orang', 'Yohanis T');
        await tekan(tester, 'Yohanis Tumbelaka');
        await tekan(tester, skPenugasan(c));
        await tekan(tester, 'Catat penugasan');
        expect(find.text('Menunggu verifikasi wewenang'), findsOneWidget);
        expect(_bendahara(c).pending?.personId, 'yohanisT');
        await tungguTiruan(tester, waktuVerifikasiWewenang);
        final p = _bendahara(c);
        expect(p.holder?.personId, 'yohanisT');
        expect(p.cover, isNull);
        expect(
          find.text('Aktif sejak $hari · wewenang sudah diverifikasi'),
          findsOneWidget,
        );
        await keluar(tester);

        await masukSebagai(tester, Persona.yanti);
        expect(c.read(vacancyCoverProvider), isFalse);
        await buka(Layar.jabatanKosong);
        expect(_memuat('Bendahara Jemaat sudah terisi:'), findsOneWidget);
        expect(
          _memuat('Anda menjalankan jabatan kosong Bendahara Jemaat'),
          findsNothing,
        );
        await buka(Layar.keuangan);
        expect(find.byType(PitaJabatanKosong), findsNothing);
        if (!ponsel) {
          expect(find.byType(PenggunaSesi), findsOneWidget);
          expect(_footer, findsNothing);
        }
      });
    }
  });
}
