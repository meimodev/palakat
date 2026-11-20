// P9 Announcements and Warta (README 8.3): Yanti drafts and Olvie publishes
// an announcement; the edition of the next Sunday goes Draf → diperiksa →
// disetujui → terbitkan and shows "Diterbitkan" in WartaArsip; A4Warta
// renders. M10: names follow TampilanNama; the finance excerpt comes from the
// latest closed snapshot; only finalized attendance shows; a BukaNama
// exception is recorded with its reason.

import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/format.dart';
import 'package:palakat_prototype/core/tanggal.dart';
import 'package:palakat_prototype/domain/collaboration/collaboration.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/domain/membership/membership.dart';
import 'package:palakat_prototype/domain/secretariat/secretariat.dart';
import 'package:palakat_prototype/providers/repositories_jemaat.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';
import 'package:palakat_prototype/providers/repositories_kolaborasi.dart';
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

          // M10 · names follow each member's Tampilan nama (J2).
          final masking = c.read(maskingRepositoryProvider);
          expect(
            find.textContaining(
              'Syukur HUT pernikahan: '
              '${masking.printedName('novita', PrintContext.warta)}',
              findRichText: true,
            ),
            findsWidgets,
          );
          expect(
            find.textContaining(
              'Sampul syukur: Tanpa nama, Kolom 4',
              findRichText: true,
            ),
            findsWidgets,
          );

          // M10 · only Ditetapkan attendance, of the last Sunday (J3).
          final hadir = warta.preview(e.id)!.attendance!;
          final hitung = c.read(attendanceRepositoryProvider);
          final ibadah = c.read(serviceRepositoryProvider);
          for (final s in ibadah.list()) {
            if (hadir.parts.any((x) => x.label == s.title)) {
              expect(hitung.count(s.id)!.status, AttendanceStatus.finalized);
            }
          }
          expect(
            hitung.count('ibadah-adven-1')!.status,
            isNot(AttendanceStatus.finalized),
          );
          expect(
            hadir.parts.map((x) => x.label),
            isNot(contains('Ibadah Minggu Adven I')),
          );
          final pagi = hitung.count('ibadah-minggu-pagi')!.total;
          expect(hadir.parts, [(label: 'Ibadah Minggu pagi', n: pagi)]);
          expect(
            find.text(
              'Minggu ${tgl(hadir.sunday.awal)}: $pagi orang '
              '(Ibadah Minggu pagi $pagi)',
            ),
            findsOneWidget,
          );

          // M10 · the finance summary is the latest closed month's
          // snapshot; the open month is not printed (J3).
          final periode = c.read(periodRepositoryProvider).periods();
          final tutup = periode.where((p) => p.isClosed).last;
          final buka = periode.firstWhere((p) => !p.isClosed);
          final f01 = c
              .read(reportRepositoryProvider)
              .snapshot(tutup.id)!
              .pack
              .datasets[ReportForm.f01]!
              .totals;
          final bulan = bulanTahun(tutup.year, tutup.month);
          expect(find.text('Ringkasan keuangan'), findsOneWidget);
          expect(find.text('Pendapatan $bulan'), findsOneWidget);
          expect(find.text(rp(f01['income'] as int)), findsWidgets);
          expect(find.text('Belanja $bulan'), findsOneWidget);
          expect(find.text(rp(f01['expense'] as int)), findsWidgets);
          expect(
            find.textContaining(
              'Pendapatan ${bulanTahun(buka.year, buka.month)}',
            ),
            findsNothing,
          );

          // M10 · BukaNama: the Sekretaris prints the name by exception,
          // with a reason (TampilanNama rule).
          const alasan = 'Permintaan resmi keluarga untuk ucapan syukur';
          await tekan(tester, 'Tampilkan nama (pengecualian)');
          expect(find.text('Kel. Mamahit — Kolom 4'), findsOneWidget);
          await isi(tester, 'Alasan · wajib', alasan);
          await tekan(tester, 'Catat pengecualian');
          final x = e.exceptionFor('mamahit-1')!;
          expect(x.reason, alasan);
          expect(x.printedAs, 'Kel. Mamahit — Kolom 4');
          final jejak = jejakTerakhir(c, 'warta.reveal_identity');
          expect(jejak.personId, 'olvie');
          expect(jejak.reason, alasan);
          expect(find.text('Alasan: $alasan'), findsOneWidget);
          await tekan(tester, 'Kembali');
          expect(
            find.textContaining(
              'Kel. Mamahit — Kolom 4 (pengecualian tercatat)',
              findRichText: true,
            ),
            findsOneWidget,
          );
          expect(find.text('Tampilkan nama (pengecualian)'), findsNothing);

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
          expect(
            find.text('Sampul syukur: Kel. Mamahit — Kolom 4'),
            findsOneWidget,
          );
          expect(
            find.text('Ringkasan keuangan · $bulan'.toUpperCase()),
            findsOneWidget,
          );

          // WartaArsip lists it as Diterbitkan.
          await ke(Layar.warta);
          expect(find.text('Edisi $edisi'), findsOneWidget);
          expect(find.text('Susun edisi $edisi'), findsNothing);
          // The nearest enclosing row or card of the edition carries the
          // badge, and no other edition's.
          final baris = find
              .ancestor(
                of: find.text('Edisi $edisi'),
                matching: find.byWidgetPredicate((_) => true),
              )
              .evaluate()
              .firstWhere(
                (e) => find
                    .descendant(
                      of: find.byElementPredicate((x) => x == e),
                      matching: find.text('Diterbitkan'),
                    )
                    .evaluate()
                    .isNotEmpty,
              );
          expect(
            find.descendant(
              of: find.byElementPredicate((x) => x == baris),
              matching: find.textContaining('Edisi '),
            ),
            findsOneWidget,
          );
          // Only the coming edition's own Sunday is after today.
          tidakAdaTanggalNanti(
            tester,
            Tanggal.dari(saat),
            'WartaArsip',
            kecuali: {edisi},
          );
        });
      }
    }
  });
}
