// P9 Announcements and Warta (README 8.3, without the M10 parts): Yanti
// drafts and Olvie publishes an announcement; the edition of the next Sunday
// goes Draf → diperiksa → disetujui → terbitkan and shows "Diterbitkan" in
// WartaArsip; A4Warta renders.

import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/format.dart';
import 'package:palakat_prototype/core/tanggal.dart';
import 'package:palakat_prototype/domain/secretariat/secretariat.dart';
import 'package:palakat_prototype/providers/repositories_sekretariat.dart';

import 'harness.dart';

const _judul = 'Ibadah syukur panen Kolom';

void main() {
  group('P9 warta', () {
    for (final saat in [jangkarA, jangkarB]) {
      for (final tata in [Tata.ponsel, Tata.web]) {
        testWidgets('${tata.name} ${tgl(saat)}', (tester) async {
          final c = await bukaAplikasi(tester, tata: tata, saat: saat);
          final umum = c.read(announcementRepositoryProvider);
          final warta = c.read(wartaRepositoryProvider);
          final minggu = mingguDepan(Tanggal.dari(saat));
          final edisi = tgl(minggu.awal);
          Future<void> ke(Layar l) async {
            c.read(routerProvider).go(l.lokasi());
            await tester.pumpAndSettle();
          }

          // Yanti drafts an announcement; she cannot publish it.
          await masukSebagai(tester, Persona.yanti);
          await ke(Layar.pengumuman);
          await tekan(tester, 'Tulis pengumuman');
          expect(find.text('Terbitkan'), findsNothing);
          await isi(tester, 'Judul', _judul);
          await isi(tester, 'Isi', 'Minggu sore di halaman gereja.');
          await tekan(tester, 'Semua anggota');
          await tekan(tester, 'Simpan sebagai draf');
          expect(
            find.text(
              'Pengumuman “$_judul” disimpan sebagai Draf; belum terlihat '
              'anggota.',
            ),
            findsOneWidget,
          );
          final a = umum.list().firstWhere((x) => x.title == _judul);
          expect(a.status, AnnouncementStatus.draft);
          expect(jejakTerakhir(c, 'announcement.draft').personId, 'yanti');
          await keluar(tester);

          // Olvie publishes it; it goes into the coming edition.
          await masukSebagai(tester, Persona.olvie);
          await ke(Layar.pengumuman);
          await tekan(tester, _judul);
          await tekan(tester, 'Terbitkan');
          expect(a.status, AnnouncementStatus.published);
          expect(jejakTerakhir(c, 'announcement.publish').personId, 'olvie');

          // A Ralat is a new revision; revision 1 stays readable (DL14).
          await tekan(tester, 'Ralat');
          expect(find.text('Terbitkan revisi 2'), findsOneWidget);
          await isi(
            tester,
            'Isi',
            'Minggu sore pukul 16.00 di halaman gereja.',
          );
          await tekan(tester, 'Terbitkan revisi 2');
          expect(
            find.text('Pengumuman “$_judul”: revisi 2 diterbitkan.'),
            findsOneWidget,
          );
          expect(a.body, 'Minggu sore pukul 16.00 di halaman gereja.');
          expect(find.text('Revisi 2'), findsOneWidget);
          expect(find.text('Digantikan oleh revisi 2'), findsOneWidget);
          expect(find.text('Minggu sore di halaman gereja.'), findsOneWidget);
          expect(jejakTerakhir(c, 'announcement.revise').personId, 'olvie');

          // The edition of the next Sunday, step by step.
          await ke(Layar.warta);
          await tekan(tester, 'Susun edisi $edisi');
          expect(find.text('Edisi $edisi'), findsOneWidget);
          expect(find.text(_judul), findsOneWidget);
          expect(find.text('Masuk edisi ini'), findsWidgets);
          final e = warta.editions().firstWhere((x) => x.sunday == minggu);
          expect(e.announcementIds, contains(a.id));
          await tekan(tester, 'Tandai sudah diperiksa');
          expect(e.status, WartaStatus.review);
          expect(find.text('Sudah diperiksa'), findsOneWidget);
          await tekan(tester, 'Setujui untuk diterbitkan');
          expect(e.status, WartaStatus.approved);
          expect(find.text('Disetujui'), findsOneWidget);
          await tekan(tester, 'Terbitkan');
          expect(e.status, WartaStatus.published);
          expect(jejakTerakhir(c, 'warta.published').personId, 'olvie');

          // A4Warta renders the edition.
          await tekan(tester, 'Lihat PDF');
          expect(
            find.textContaining('Edisi $edisi · halaman 1 dari 1'),
            findsOneWidget,
          );
          expect(find.textContaining(_judul), findsOneWidget);

          // WartaArsip lists it as Diterbitkan.
          await ke(Layar.warta);
          expect(find.text('Edisi $edisi'), findsOneWidget);
          expect(find.text('Susun edisi $edisi'), findsNothing);
          expect(find.text('Diterbitkan'), findsWidgets);
        });
      }
    }
  });
}
