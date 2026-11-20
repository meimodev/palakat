// P15 Worship and attendance (README 8.3): Hendrik approves Ibadah Kolom 7
// (the next Thursday) and assigns Greis; Greis counts and is refused
// "Tetapkan"; Hendrik finalizes; the count shows in LaporanLintas; the
// Sunday count was finalized by Lidya (DP25), and her correction keeps both
// values (DP35).

import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/tanggal.dart';
import 'package:palakat_prototype/domain/collaboration/collaboration.dart';
import 'package:palakat_prototype/providers/repositories_kolaborasi.dart';

import 'harness.dart';

const _kolom7 = 'ibadah-kolom-7';
const _minggu = 'ibadah-minggu-pagi';

void main() {
  group('P15 ibadah dan kehadiran', () {
    testWidgets('ponsel', (tester) async {
      final c = await bukaAplikasi(tester);
      final ibadah = c.read(serviceRepositoryProvider);
      final hadir = c.read(attendanceRepositoryProvider);
      Future<void> ke(Layar l, [Map<String, String> p = const {}]) async {
        c.read(routerProvider).go(l.lokasi(param: p));
        await tester.pumpAndSettle();
      }

      final s = ibadah.get(_kolom7)!;
      final hari = Tanggal.dari(jangkarA);
      expect(s.date.awal.weekday, DateTime.thursday);
      expect(s.date > hari && s.date <= hari.tambahHari(7), isTrue);

      // Hendrik approves it from his home row.
      await masukSebagai(tester, Persona.hendrik);
      await tekan(tester, 'Sebagai Penatua Kolom 7');
      await tekan(tester, 'Ibadah Kolom 7, ${s.date}');
      expect(find.text('Kamis, ${s.date} 19.00'), findsOneWidget);
      expect(
        find.text(
          'Disetujui oleh Penatua atau Syamas dari Kolom yang dituju: Pnt. '
          'Hendrik Rumagit atau Sym. Greis Mamahit.',
        ),
        findsOneWidget,
      );
      await tekan(tester, 'Setujui dan jadwalkan');
      expect(ibadah.get(_kolom7)!.status, ServiceStatus.scheduled);
      expect(ibadah.get(_kolom7)!.approvedBy, 'hendrik');
      expect(ibadah.get(_kolom7)!.approverTitle, 'Penatua Kolom 7');
      expect(find.text('Dijadwalkan'), findsWidgets);

      // ... and assigns Greis to the front door.
      await tekan(tester, 'Tugaskan penghitung kehadiran');
      expect(find.text('Jumlah kehadiran'), findsOneWidget);
      await tekan(tester, 'Pintu depan');
      await tekan(tester, 'Sym. Greis Mamahit');
      await tekan(tester, 'Tugaskan');
      expect(hadir.count(_kolom7)!.postOf('Pintu depan')!.personId, 'greis');
      expect(find.text('Pintu depan · Greis M.'), findsOneWidget);
      await keluar(tester);

      // Greis counts from her home row and is refused "Tetapkan".
      await masukSebagai(tester, Persona.greis);
      await tekan(tester, 'Hitung kehadiran · Ibadah Kolom 7');
      expect(
        find.textContaining('Petugas penghitung kehadiran'),
        findsOneWidget,
      );
      // Counting opens on the service's day.
      await tekan(tester, '+');
      expect(find.textContaining('ibadah belum berlangsung.'), findsOneWidget);
      expect(hadir.count(_kolom7)!.counted, 0);
      await majukanJam(tester, s.date.awal.difference(hari.awal));
      for (var i = 0; i < 39; i++) {
        await tester.tap(find.text('+'));
        await tester.pump();
      }
      await tekan(tester, '−');
      expect(hadir.count(_kolom7)!.counted, 38);
      expect(find.text('38'), findsWidgets);
      await tekan(tester, 'Kirim untuk diperiksa');
      expect(hadir.count(_kolom7)!.status, AttendanceStatus.review);
      await tekan(tester, 'Tetapkan');
      expect(
        find.textContaining('penghitung tidak menetapkan jumlah.'),
        findsOneWidget,
      );
      expect(hadir.count(_kolom7)!.status, AttendanceStatus.review);
      await keluar(tester);

      // Hendrik finalizes; the service is Ditutup.
      await masukSebagai(tester, Persona.hendrik);
      await tekan(tester, 'Sebagai Penatua Kolom 7');
      await tekan(tester, 'Jumlah kehadiran Ibadah Kolom 7');
      await tekan(tester, 'Tetapkan');
      final h = hadir.count(_kolom7)!;
      expect(h.status, AttendanceStatus.finalized);
      expect(h.finalizedBy, 'hendrik');
      expect(ibadah.get(_kolom7)!.status, ServiceStatus.closed);
      expect(
        find.textContaining('Ditetapkan oleh Pnt. Hendrik Rumagit'),
        findsOneWidget,
      );
      expect(find.text('Jumlah kehadiran Ibadah Kolom 7'), findsNothing);

      // The finalized count shows in his LaporanLintas (Kolom 7 reach).
      await ke(Layar.laporanLintas);
      expect(
        find.text('Jumlah kehadiran Ibadah Kolom 7 ${s.date}'),
        findsOneWidget,
      );
      expect(find.text('38'), findsOneWidget);
      expect(find.text('Kolom 7 saja'), findsOneWidget);
      await keluar(tester);

      // The last Sunday: Ditetapkan at 231 by Lidya, who approved it (DP25).
      final m = ibadah.get(_minggu)!;
      expect(hadir.count(_minggu)!.finalizedBy, 'lidya');
      await masukSebagai(tester, Persona.lidya);
      await ke(Layar.kehadiran, {'ibadah': _minggu});
      expect(
        find.textContaining('Ditetapkan oleh Pdt. Lidya Rondonuwu'),
        findsOneWidget,
      );
      expect(find.text('231'), findsOneWidget);
      expect(find.text('Pintu depan · Yanti S.'), findsOneWidget);

      // Her correction keeps both values (DP35).
      await tekan(tester, 'Koreksi');
      await isi(tester, 'Jumlah yang benar', '236');
      await isi(
        tester,
        'Alasan · wajib',
        'lembar pos balkon terlambat diserahkan',
      );
      await tekan(tester, 'Catat koreksi');
      final k = hadir.count(_minggu)!;
      expect(k.counted, 231);
      expect(k.total, 236);
      expect(k.corrections.single.from, 231);
      expect(k.corrections.single.by, 'lidya');
      expect(find.text('Koreksi jumlah'), findsOneWidget);
      expect(
        find.text('Alasan: lembar pos balkon terlambat diserahkan'),
        findsOneWidget,
      );
      expect(find.text('236'), findsOneWidget);

      // Reports use the corrected figure.
      await ke(Layar.laporanLintas);
      expect(
        find.text('Jumlah kehadiran ${m.title} ${m.date}'),
        findsOneWidget,
      );
      expect(find.text('236'), findsOneWidget);
    });
  });
}
