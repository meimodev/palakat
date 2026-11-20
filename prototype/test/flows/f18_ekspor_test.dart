// F18 Export (README 8.3): "Buat ekspor" builds the manifest through
// ExportRepository; "Belum lengkap" lists the posted transactions whose
// required document is missing; the download reads
// "Diunduh · ekspor-jemaat-karunia-{today}.zip".

import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/keuangan/ekspor.dart';
import 'package:palakat_prototype/providers/seed.dart';

import 'harness.dart';

void main() {
  group('F18 ekspor', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final w = await bukaAplikasi(tester, tata: tata);
        await masukSebagai(tester, Persona.meiske);
        final k = w.read(seedProvider).keuangan;
        final kurang = w.read(eksporProvider).tanpaDokumen;
        expect(kurang.map((t) => t.id), contains(k.bySeedKey('0143')!.id));

        w.read(routerProvider).go(Layar.ekspor.lokasi());
        await tester.pumpAndSettle();
        await tester.tap(find.text('Buat ekspor'));
        await tester.pump();
        await tester.pump();
        expect(find.text('Sedang disiapkan…'), findsWidgets);
        await tungguTiruan(tester, const Duration(milliseconds: 2800));

        expect(find.text('Ekspor belum lengkap'), findsOneWidget);
        expect(
          find.textContaining(
            '${kurang.length} transaksi tanpa dokumen pendukung wajib',
          ),
          findsOneWidget,
        );
        for (final t in kurang) {
          expect(find.text('${t.voucher} · ${t.description}'), findsOneWidget);
        }

        await tekan(tester, 'Unduh ekspor (belum lengkap)');
        final h = w.read(hariIniProvider);
        String dua(int n) => n.toString().padLeft(2, '0');
        expect(
          find.text(
            'Diunduh · ekspor-jemaat-karunia-'
            '${h.tahun}-${dua(h.bulan)}-${dua(h.hari)}.zip',
          ),
          findsOneWidget,
        );
      });
    }
  });
}
