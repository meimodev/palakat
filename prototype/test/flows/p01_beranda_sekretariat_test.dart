// P1 Home and inbox, Secretariat part (README 8.3): each persona's rows come
// from real open items; finishing the item removes the row; no web home row
// links a phone-only screen.

import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/format.dart';
import 'package:palakat_prototype/core/tanggal.dart';
import 'package:palakat_prototype/domain/secretariat/secretariat.dart';
import 'package:palakat_prototype/providers/home_rows.dart';

import 'harness.dart';

bool _sekretariat(HomeRow r) => const {
  ModulLayar.dokumenGereja,
  ModulLayar.pengumuman,
  ModulLayar.warta,
}.contains(r.ke.modulLayar);

void main() {
  group('P1 beranda sekretariat', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final c = await bukaAplikasi(tester, tata: tata);
        final edisi = tgl(mingguDepan(Tanggal.dari(jangkarA)).awal);
        Future<void> keBeranda() async {
          c.read(routerProvider).go(Layar.beranda.lokasi());
          await tester.pumpAndSettle();
        }

        // Every persona: rows link a screen of this layout; only the
        // Sekretaris, the Operator and the member get Secretariat rows.
        for (final p in Persona.values) {
          await masukSebagai(tester, p);
          if (p == Persona.hendrik) {
            await tekan(tester, 'Sebagai Penatua Kolom 7');
          }
          final baris = c.read(homeRowsProvider);
          for (final r in baris) {
            expect(r.ke.adaUntuk(tata), isTrue, reason: '${p.name} ${r.judul}');
          }
          for (final r in baris.where(_sekretariat)) {
            expect(find.text(r.judul), findsOneWidget, reason: r.judul);
          }
          if (!{Persona.olvie, Persona.yanti, Persona.novita}.contains(p)) {
            expect(baris.where(_sekretariat), isEmpty, reason: p.name);
          }
          await keluar(tester);
        }

        // The Operator's request recorded at the office; the member's own.
        await masukSebagai(tester, Persona.yanti);
        expect(
          find.text('1 permohonan surat dicatat di kantor'),
          findsOneWidget,
        );
        await keluar(tester);
        await masukSebagai(tester, Persona.novita);
        expect(find.text('Permohonan surat keterangan'), findsOneWidget);
        expect(find.textContaining('Warta Jemaat edisi'), findsOneWidget);
        await keluar(tester);

        // The Sekretaris finishes her items; each row leaves.
        await masukSebagai(tester, Persona.olvie);
        expect(find.text('3 permohonan surat'), findsOneWidget);
        expect(find.text('2 pengumuman masih Draf'), findsOneWidget);
        expect(find.text('Warta Jemaat edisi $edisi'), findsOneWidget);
        expect(find.textContaining('pengumuman berakhir pada'), findsOneWidget);

        await tekan(tester, '3 permohonan surat');
        await tekan(tester, 'Buka permohonan');
        await tekan(tester, 'Tidak diterbitkan');
        await isi(
          tester,
          'Alasan · wajib',
          'Surat dari kantor kerja belum ada',
        );
        await tekan(tester, 'Catat tidak diterbitkan');
        await keBeranda();
        expect(find.text('2 permohonan surat'), findsOneWidget);

        await tekan(tester, '2 pengumuman masih Draf');
        await tekan(tester, 'Pendaftaran katekisasi sidi 2027');
        await tekan(tester, 'Terbitkan');
        await tekan(tester, 'Kembali');
        await tekan(tester, 'Rapat pelayan khusus');
        await tekan(tester, 'Terbitkan');
        await keBeranda();
        expect(find.textContaining('pengumuman masih Draf'), findsNothing);

        await tekan(tester, 'Warta Jemaat edisi $edisi');
        await tekan(tester, 'Tandai sudah diperiksa');
        await tekan(tester, 'Setujui untuk diterbitkan');
        await tekan(tester, 'Terbitkan');
        await keBeranda();
        expect(find.text('Warta Jemaat edisi $edisi'), findsNothing);
        await keluar(tester);

        // Novita's refused request leaves her list of open items.
        await masukSebagai(tester, Persona.novita);
        expect(find.text('Permohonan surat keterangan'), findsNothing);
        expect(find.text('Warta Jemaat edisi $edisi'), findsOneWidget);
      });
    }
  });
}
