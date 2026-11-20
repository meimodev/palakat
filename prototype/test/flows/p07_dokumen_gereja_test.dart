// P7 Church documents (README 8.3): "Diterbitkan" only with a signed copy; a
// Ralat makes "Revisi 2" and the old version still opens; Novita sees only
// documents addressed to her.

import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/format.dart';
import 'package:palakat_prototype/core/tanggal.dart';
import 'package:palakat_prototype/domain/core/core.dart';
import 'package:palakat_prototype/domain/secretariat/secretariat.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/core_repositories.dart';
import 'package:palakat_prototype/providers/repositories_sekretariat.dart';

import 'harness.dart';

void main() {
  group('P7 dokumen gereja', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final c = await bukaAplikasi(tester, tata: tata);
        final repo = c.read(documentRepositoryProvider);
        final hari = Tanggal.dari(jangkarA);
        Future<void> keDokumen() async {
          c.read(routerProvider).go(Layar.dokumenGereja.lokasi());
          await tester.pumpAndSettle();
        }

        await masukSebagai(tester, Persona.olvie);
        await keDokumen();
        expect(
          find.text('Surat edaran jadwal ibadah Natal 2026'),
          findsOneWidget,
        );

        // A new document: refused until the signed copy is attached.
        final judul = 'SK BPMJ No. 14/${hari.tahun} · Penugasan Syamas Kolom 3';
        await tekan(tester, 'Terbitkan dokumen');
        await tekan(tester, 'Keputusan dan surat edaran');
        await isi(tester, 'Judul', judul);
        await isi(tester, 'Tanggal dokumen', tgl(hari.awal));
        await tekan(tester, 'Pelayan dan pengurus');
        if (tata == Tata.web) {
          // WebTerbitDokumen's aside shows what the addressees will see.
          expect(find.text('Yang dilihat penerima'), findsOneWidget);
          expect(find.text('Belum diterbitkan'), findsOneWidget);
        }
        await tekan(tester, 'Terbitkan');
        expect(
          find.textContaining('salinan bertanda tangan belum terlampir.'),
          findsOneWidget,
        );
        expect(repo.list().where((d) => d.title == judul), isEmpty);
        // The repository refuses it too.
        final tanpa = await repo.publish(
          c.read(actorProvider)!,
          DocumentDraft(kind: DocumentKind.decision, title: judul),
          null,
          Audience.servants,
          idempotencyKey: 'p7-tanpa-salinan',
        );
        expect(tanpa, isA<Refused<ChurchDocument>>());

        await tekan(tester, 'Pilih file');
        await tekan(tester, 'Terbitkan');
        // TerbitDokumen's confirmation; the addressees are notified.
        expect(
          find.textContaining('Anggota yang dituju menerima pemberitahuan.'),
          findsOneWidget,
        );
        final kabar = c.read(notificationRepositoryProvider);
        bool dapat(String id) =>
            kabar.inbox(id).any((n) => n.title == '$judul diterbitkan');
        expect(dapat('hendrik'), isTrue);
        expect(dapat('novita'), isFalse);
        expect(dapat('olvie'), isFalse);
        await tekan(tester, 'Lihat di Dokumen gereja');
        expect(
          find.text('$judul diterbitkan untuk Pelayan dan pengurus.'),
          findsOneWidget,
        );
        final d = repo.list().firstWhere((x) => x.title == judul);
        expect(d.statusLabel, 'Diterbitkan');
        expect(jejakTerakhir(c, 'document.publish').personId, 'olvie');
        // The Riwayat of AlurDokumen, from the audit.
        expect(
          find.textContaining(
            '$judul diterbitkan untuk Pelayan dan pengurus. · '
            'Olvie Pangemanan',
          ),
          findsOneWidget,
        );

        // A Ralat makes Revisi 2; Revisi 1 still opens.
        await tekan(tester, judul);
        await tekan(tester, 'Terbitkan revisi baru');
        await isi(tester, 'Yang diralat · wajib', 'Nomor SK 14, bukan 13.');
        await tekan(tester, 'Pilih file');
        await tekan(tester, 'Terbitkan revisi');
        expect(
          find.text(
            '$judul: revisi 2 diterbitkan. Yang diralat: Nomor SK 14, bukan '
            '13.',
          ),
          findsOneWidget,
        );
        expect(repo.get(d.id)!.statusLabel, 'Revisi 2');
        expect(repo.get(d.id)!.revisions, hasLength(2));
        expect(find.text('Revisi 2'), findsOneWidget);
        expect(find.text('Digantikan oleh revisi 2'), findsOneWidget);
        await tekan(tester, 'Buka salinan bertanda tangan');
        await tester.tap(find.text('Buka salinan bertanda tangan').last);
        await tester.pumpAndSettle();
        expect(
          find.textContaining(
            'salinan-bertanda-tangan.pdf · 1 halaman · '
            'revisi 1',
          ),
          findsOneWidget,
        );
        expect(jejakTerakhir(c, 'document.revise').personId, 'olvie');
        expect(
          kabar
              .inbox('hendrik')
              .any((n) => n.title.startsWith('$judul: revisi 2')),
          isTrue,
        );
        await tekan(tester, 'Semua dokumen');
        expect(
          find.textContaining('revisi 1 tetap dapat dibuka'),
          findsNWidgets(2),
        );
        await keluar(tester);

        // The Operator sees the whole archive (DL25).
        await masukSebagai(tester, Persona.yanti);
        await keDokumen();
        expect(find.text(judul), findsOneWidget);
        expect(find.textContaining('Notulen rapat BPMJ'), findsOneWidget);
        expect(find.text('Terbitkan dokumen'), findsNothing);
        await keluar(tester);

        // Novita sees only the documents addressed to her.
        await masukSebagai(tester, Persona.novita);
        await keDokumen();
        expect(find.text(judul), findsNothing);
        expect(find.textContaining('Notulen rapat BPMJ'), findsNothing);
        expect(
          find.text('Surat edaran jadwal ibadah Natal 2026'),
          findsOneWidget,
        );
        expect(find.text('Tata ibadah Minggu Adven I'), findsOneWidget);
        expect(find.text('Terbitkan dokumen'), findsNothing);
        for (final x in repo.list(audienceOf: 'novita')) {
          expect(
            x.audience == Audience.all || x.audience.personId == 'novita',
            isTrue,
            reason: x.title,
          );
        }
      });
    }
  });
}
