// F20 Sessions and handover, README 8.3 (DP39): "Akhiri sesi" removes the
// other device; Meiske prepares the handover to Yohanis Tumbelaka in
// Bendahara `serah` or WebSerahTerima; Lidya records it in Penugasan, which
// shows "Menunggu verifikasi wewenang"; Meiske signs in again; after the
// board timer Yohanis is "aktif sejak {today}", Meiske's term has ended, and
// her session ends on Sambungan or WebSambungan; "Masuk lagi" opens the
// picker; picking Meiske again lands on a member home with no finance rows.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/data/repositories/role_repository.dart';
import 'package:palakat_prototype/domain/core/core.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/core_repositories.dart';
import 'package:palakat_prototype/providers/home_rows.dart';
import 'package:palakat_prototype/providers/session.dart';

import 'harness.dart';

PostView _bendahara(ProviderContainer c) => c
    .read(roleRepositoryProvider)
    .posts()
    .firstWhere((p) => p.post.id == 'bendahara-jemaat');

void main() {
  group('F20 serah terima', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final c = await bukaAplikasi(tester, tata: tata);
        final ponsel = tata == Tata.ponsel;
        Future<void> buka(Layar l, {String? anak}) async {
          c.read(routerProvider).go(l.lokasi(anak: anak));
          await tester.pumpAndSettle();
        }

        final sesi = c.read(sessionRepositoryProvider);
        final hari = c.read(hariIniProvider);

        // "Akhiri sesi" removes the other device.
        await masukSebagai(tester, Persona.meiske);
        await buka(Layar.bendahara, anak: ponsel ? null : 'serah');
        final sebelum = sesi.devices('meiske');
        final n = sebelum.length;
        expect(n, greaterThan(0));
        await tekan(tester, 'Akhiri sesi');
        expect(sesi.devices('meiske'), hasLength(n - 1));
        final ids = {for (final d in sesi.devices('meiske')) d.id};
        final hilang = sebelum.firstWhere((d) => !ids.contains(d.id));
        expect(find.textContaining(hilang.name), findsNothing);

        // Meiske prepares the handover.
        if (ponsel) await buka(Layar.bendahara, anak: 'serah');
        await isi(tester, 'Nama yang ditunjuk', 'Yohanis Tumbelaka');
        await tekan(tester, 'Kirim untuk diverifikasi');
        final h = _bendahara(c).handover;
        expect(h?.toPersonId, 'yohanisT');
        expect(h?.fromPersonId, 'meiske');
        await keluar(tester);

        // Lidya records it in Penugasan: "Menunggu verifikasi wewenang".
        await masukSebagai(tester, Persona.lidya);
        expect(
          find.text('Serah terima Bendahara Jemaat menunggu dicatat'),
          findsOneWidget,
        );
        await buka(Layar.penugasan);
        expect(
          find.textContaining('Serah terima kepada Yohanis Tumbelaka'),
          findsOneWidget,
        );
        await tekan(tester, 'Tugaskan');
        expect(find.text('Yohanis Tumbelaka'), findsWidgets);
        await tekan(tester, 'Catat penugasan');
        expect(find.text('Menunggu verifikasi wewenang'), findsOneWidget);
        expect(_bendahara(c).pending?.personId, 'yohanisT');
        expect(_bendahara(c).holder?.personId, 'meiske');
        await keluar(tester);

        // Meiske signs in again while the Petugas verifikasi checks.
        await masukSebagai(tester, Persona.meiske);
        expect(_bendahara(c).pending, isNotNull, reason: 'timer too early');
        await tungguTiruan(tester, waktuVerifikasiWewenang);
        final p = _bendahara(c);
        expect(p.holder?.personId, 'yohanisT');
        expect(p.holder?.start, hari);
        expect(p.lastHolder?.personId, 'meiske');
        expect(p.lastHolder?.status, AssignmentStatus.ended);

        // Her session ends on Sambungan / WebSambungan.
        expect(lokasiSekarang(tester), Layar.sesiBerakhir.lokasi());
        expect(find.textContaining('berpindah pada'), findsOneWidget);
        await tekan(tester, 'Masuk lagi');
        expect(find.text('Masuk sebagai'), findsOneWidget);

        // Meiske again: a member home with no finance rows.
        await masukSebagai(tester, Persona.meiske);
        expect(c.read(actorProvider)!.assignmentId, isNull);
        expect(
          c
              .read(homeRowsProvider)
              .where(
                (r) => const [
                  Module.finance,
                  Module.unitFinance,
                  Module.inAppApprovals,
                ].contains(r.ke.modulLayar.modul),
              ),
          isEmpty,
        );
        expect(find.textContaining('belum dibukukan'), findsNothing);
        expect(c.read(penjagaProvider(Layar.keuangan)), Penjaga.tidakBerwenang);
        expect(c.read(sessionProvider)!.berakhir, isFalse);
        if (!ponsel) {
          // The web footer follows her role: a member now.
          expect(find.text('Wewenang Bendahara aktif'), findsNothing);
          expect(
            find.textContaining(' · Anggota jemaat', findRichText: true),
            findsWidgets,
          );
        }
        await keluar(tester);

        // Lidya sees Yohanis "aktif sejak {today}" and Meiske's ended term.
        await masukSebagai(tester, Persona.lidya);
        await buka(Layar.penugasan);
        expect(
          find.text('Aktif sejak $hari · wewenang sudah diverifikasi'),
          findsOneWidget,
        );
        expect(find.text('Meiske Lumentut'), findsOneWidget);
        expect(
          jejakTerakhir(c, 'role.grant_activate').personName,
          'Petugas verifikasi',
        );
      });
    }
  });
}
