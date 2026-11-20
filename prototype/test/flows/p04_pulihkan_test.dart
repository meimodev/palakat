// P4 Recover a member's account, README 8.3: Yanti (Operator) asks with the
// new number Novita brought; Hendrik (Penatua Kolom 7) confirms the identity
// and then sees "Tidak ada pemulihan akun yang menunggu Anda"; Yanti sees the
// completed status.

import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/format.dart';
import 'package:palakat_prototype/domain/core/core.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/core_repositories.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';
import 'package:palakat_prototype/providers/repositories_sekretariat.dart';

import 'harness.dart';

const _baru = '081298765432';

void main() {
  group('P4 pulihkan akun', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final c = await bukaAplikasi(tester, tata: tata);
        final ponsel = tata == Tata.ponsel;
        final pulih = c.read(recoveryRepositoryProvider);
        final hari = c.read(hariIniProvider);
        Future<void> cariOrang() async {
          c.read(routerProvider).go(Layar.cariOrang.lokasi());
          await tester.pumpAndSettle();
        }

        // Yanti searches Data jemaat: the Operator sees every Kolom.
        await masukSebagai(tester, Persona.yanti);
        await cariOrang();
        await isi(tester, 'Cari nama, keluarga atau Kolom', 'Wenas');
        expect(
          find.text('Data jemaat · Keluarga Wenas-Lasut · Kolom 7'),
          findsNWidgets(3),
        );
        expect(find.text('Data jemaat · 4 orang · Kolom 7'), findsOneWidget);
        await tekan(tester, 'Ferry Wenas');
        expect(
          c.read(routerProvider).state.uri.path,
          (ponsel ? Layar.konfirmasiKeluarga : Layar.dataAnggota).lokasi(),
        );
        await cariOrang();

        // Dokumen gereja and Keuangan rows (M6-R5): Novita's letter request
        // opens PermohonanSurat, her booked envelope opens Keuangan.
        await isi(tester, 'Cari nama, keluarga atau Kolom', 'Wenas');
        final surat = c
            .read(letterRepositoryProvider)
            .requests()
            .firstWhere((r) => r.id == 'surat-novita');
        final dokumen =
            'Dokumen gereja · Surat keterangan ${tgl(surat.requestedAt)}';
        expect(find.text(dokumen), findsOneWidget);
        final sampul = c.read(transactionRepositoryProvider).get('bku-0132')!;
        final buku =
            'Keuangan · Sampul syukur ${tgl(sampul.effectiveDate.awal)}';
        expect(find.text(buku), findsOneWidget);
        await tekan(tester, dokumen);
        expect(c.read(routerProvider).state.uri.path, Layar.surat.lokasi());
        await cariOrang();
        await isi(tester, 'Cari nama, keluarga atau Kolom', 'Wenas');
        await tekan(tester, buku);
        expect(c.read(routerProvider).state.uri.path, Layar.keuangan.lokasi());
        await cariOrang();

        // Yanti asks.
        await tekan(tester, 'Orangnya kehilangan nomor ponsel? Pulihkan akun');
        await isi(tester, 'Nama orangnya', 'Nov');
        expect(
          find.textContaining('orangnya belum ditemukan.', findRichText: true),
          findsOneWidget,
        );
        await isi(tester, 'Nama orangnya', 'Novita');
        // The button, not the screen title of the same words.
        await tester.ensureVisible(find.text('Cari orang').last);
        await tester.tap(find.text('Cari orang').last);
        await tester.pumpAndSettle();
        expect(find.text('Novita Wenas'), findsOneWidget);
        expect(find.text('Kolom 7'), findsOneWidget);
        expect(find.text('0812 ···· 7741'), findsOneWidget);
        await isi(tester, 'Nomor ponsel baru', '0812');
        expect(
          find.textContaining(
            'nomor ponsel tidak dikenali',
            findRichText: true,
          ),
          findsOneWidget,
        );
        await isi(tester, 'Nomor ponsel baru', _baru);
        await tekan(tester, 'Minta kepastian Penatua Kolom');
        expect(
          find.text('Penatua Kolom 7 diberi tahu lewat Pemberitahuan.'),
          findsOneWidget,
        );
        expect(find.text('Menunggu Penatua Kolom 7'), findsOneWidget);
        final r = pulih.recoveries().single;
        expect(r.status, RecoveryStatus.waiting);
        expect(r.personId, 'novita');
        await keluar(tester);

        // Hendrik confirms from his home row.
        await masukSebagai(tester, Persona.hendrik);
        await tekan(tester, 'Sebagai Penatua Kolom 7');
        expect(find.text('Pemulihan akun · Novita Wenas'), findsOneWidget);
        await tekan(tester, 'Pemulihan akun · Novita Wenas');
        expect(find.text('Menunggu Anda'), findsOneWidget);
        expect(find.text('0812 ···· 5432'), findsOneWidget);
        expect(
          find.textContaining(
            'centang dulu bahwa Anda sudah memastikan orangnya.',
            findRichText: true,
          ),
          findsOneWidget,
        );
        await tekan(
          tester,
          'Saya sudah bertemu atau berbicara langsung dengan orang ini, dan '
          'nomor baru itu memang miliknya.',
        );
        await tekan(tester, 'Pastikan identitas');
        expect(
          find.text('Identitas dipastikan. Nomor baru dipasang.'),
          findsOneWidget,
        );
        expect(
          find.text('Tidak ada pemulihan akun yang menunggu Anda'),
          findsOneWidget,
        );
        expect(pulih.recoveries().single.status, RecoveryStatus.recovered);
        expect(c.read(peopleRepositoryProvider).person('novita')!.phone, _baru);
        expect(
          jejakTerakhir(c, 'core.recovery.confirm').personName,
          'Pnt. Hendrik Rumagit',
        );
        // A Penatua Kolom finds only his own Kolom.
        await cariOrang();
        await isi(tester, 'Cari nama, keluarga atau Kolom', 'Rompas');
        expect(find.text('Tidak ada hasil untuk “Rompas”'), findsOneWidget);
        await isi(tester, 'Cari nama, keluarga atau Kolom', 'Wenas');
        expect(find.text('Novita Wenas'), findsOneWidget);
        expect(find.textContaining('Dokumen gereja · '), findsNothing);
        expect(find.textContaining('Keuangan · '), findsNothing);
        await keluar(tester);

        // Yanti sees the completed status.
        await masukSebagai(tester, Persona.yanti);
        await cariOrang();
        await tekan(tester, 'Orangnya kehilangan nomor ponsel? Pulihkan akun');
        expect(find.text('Dipulihkan'), findsOneWidget);
        expect(
          find.text(
            'Nomor baru dipasang $hari. Semua perangkat lama dikeluarkan. '
            'Novita Wenas masuk dengan kode ke nomor barunya.',
          ),
          findsOneWidget,
        );
      });
    }
  });
}
