// F21 Finance notifications (README 8.3): opening an item lowers the unread
// count; switching a type off hides it while the home blockers stay.

import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/domain/core/core.dart';
import 'package:palakat_prototype/providers/core_repositories.dart';
import 'package:palakat_prototype/providers/keuangan/beranda.dart';
import 'package:palakat_prototype/widgets/sakelar.dart';

import 'harness.dart';

void main() {
  group('F21 pemberitahuan keuangan', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final c = await bukaAplikasi(tester, tata: tata);
        await masukSebagai(tester, Persona.meiske);
        final repo = c.read(notificationRepositoryProvider);
        List<AppNotification> keuangan() => [
          for (final n in repo.inbox('meiske'))
            if (n.module == Module.finance) n,
        ];
        int belum() => keuangan().where((n) => !n.read).length;

        c.read(routerProvider).go(Layar.pemberitahuan.lokasi());
        await tester.pumpAndSettle();
        final awal = belum();
        expect(awal, greaterThan(1));
        expect(find.text('Belum dibaca · $awal'), findsOneWidget);
        final semuaAwal = repo.unreadCount('meiske');
        // AI is off by default: its row is hidden.
        expect(find.textContaining('Biaya AI bulan ini'), findsNothing);

        // Opening an item marks it read.
        const dokumen = '1 dokumen pendukung wajib, belum ada';
        await tekan(tester, dokumen);
        expect(find.text('Belum dibaca · ${awal - 1}'), findsOneWidget);
        expect(repo.unreadCount('meiske'), semuaAwal - 1);
        expect(keuangan().singleWhere((n) => n.title == dokumen).read, isTrue);

        // Switching "Jatuh tempo" off hides the overdue advance.
        const tempo = 'Uang muka lewat jatuh tempo';
        expect(find.text(tempo), findsOneWidget);
        final hambatan = c.read(berandaKeuanganProvider).hambatan.length;
        final perlu = c.read(berandaKeuanganProvider).perluTindakan.length;
        final sakelar = find.byWidgetPredicate(
          (w) => w is Sakelar && w.label == 'Pemberitahuan Jatuh tempo',
        );
        await tester.ensureVisible(sakelar);
        await tester.pumpAndSettle();
        await tester.tap(sakelar);
        await tester.pumpAndSettle();
        expect(
          repo.preferences('meiske').allows(NotificationType.due),
          isFalse,
        );
        expect(find.text(tempo), findsNothing);
        expect(find.text('Belum dibaca · ${awal - 2}'), findsOneWidget);

        // The home still lists every blocker.
        c.read(routerProvider).go(Layar.keuangan.lokasi());
        await tester.pumpAndSettle();
        final beranda = c.read(berandaKeuanganProvider);
        expect(beranda.hambatan.length, hambatan);
        expect(beranda.perluTindakan.length, perlu);
        expect(beranda.hambatan, isNotEmpty);
        expect(
          find.textContaining(beranda.perluTindakan.first.judul),
          findsWidgets,
        );
      });
    }
  });
}
