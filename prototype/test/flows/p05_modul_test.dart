// P5 Modules, README 8.3: switching a module off needs a reason; its menu
// items and home rows disappear for everyone and its paths show "Modul tidak
// aktif"; switching on follows the dependency order; switching back restores.
// Keuangan, the first card, has no switch (AlurModul), so P5 switches off
// Keuangan unit: Meiske's "hambatan dari unit" row, Lainnya's "Pernyataan
// kesiapan" and Modul's "Kas/Bank yang dikelola unit" are its traces.

import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/domain/core/core.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/core_repositories.dart';
import 'package:palakat_prototype/providers/home_rows.dart';
import 'package:palakat_prototype/widgets/kecil.dart';

import 'harness.dart';

void main() {
  testWidgets('P5 modul ponsel', (tester) async {
    final c = await bukaAplikasi(tester);
    final ws = c.read(workspaceRepositoryProvider);
    final hari = c.read(hariIniProvider);
    ModuleStatus status(Module m) =>
        ws.modules().firstWhere((x) => x.module == m).status;
    Future<void> buka(Layar l) async {
      c.read(routerProvider).go(l.lokasi());
      await tester.pumpAndSettle();
    }

    Future<void> ketuk(String teks) async {
      await tester.ensureVisible(find.text(teks).last);
      await tester.tap(find.text(teks).last);
      await tester.pumpAndSettle();
    }

    /// The button [tombol] on the Modul card of [modul].
    Finder diKartu(String modul, String tombol) => find.descendant(
      of: find.ancestor(of: find.text(modul), matching: find.byType(Kartu)),
      matching: find.text(tombol),
    );
    Future<void> tekanKartu(String modul, String tombol) async {
      final f = diKartu(modul, tombol);
      await tester.ensureVisible(f);
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    Future<void> matikan(String modul, String alasan) async {
      await tekanKartu(modul, 'Nonaktifkan modul');
      expect(find.text('Nonaktifkan modul: $modul'), findsOneWidget);
      await isi(tester, 'Alasan · wajib', alasan);
      await ketuk('Nonaktifkan modul');
      expect(
        find.text(
          'Modul $modul dinonaktifkan dan menjadi Hanya baca · alasan: '
          '$alasan.',
        ),
        findsOneWidget,
      );
    }

    Future<void> aktifkan(String modul) async {
      await tekanKartu(modul, 'Aktifkan modul');
      expect(find.text('Aktifkan modul: $modul'), findsOneWidget);
      await ketuk('Aktifkan modul');
      expect(find.text('Modul $modul aktif sejak $hari.'), findsOneWidget);
    }

    /// Meiske's traces of Keuangan unit: a home row and a Lainnya item.
    Future<void> jejakUnitMeiske({required bool ada}) async {
      final n = ada ? findsOneWidget : findsNothing;
      await masukSebagai(tester, Persona.meiske);
      expect(find.textContaining('hambatan dari unit'), n);
      await buka(Layar.pengaturan);
      expect(find.text('Pernyataan kesiapan'), n);
      expect(find.text('Laporan'), findsOneWidget); // Keuangan stays
      await buka(Layar.hambatanUnit);
      expect(
        find.text('Halaman ini tidak tersedia'),
        ada ? findsNothing : findsOneWidget,
      );
      expect(
        c.read(penjagaProvider(Layar.hambatanUnit)),
        ada ? isNull : Penjaga.modulTidakAktif,
      );
      await keluar(tester);
    }

    // Before: Meiske's row and menu item.
    await jejakUnitMeiske(ada: true);

    // Lidya: Keuangan has no switch; Keuangan unit off needs a reason.
    await masukSebagai(tester, Persona.lidya);
    await buka(Layar.modul);
    expect(diKartu('Keuangan', 'Nonaktifkan modul'), findsNothing);
    expect(diKartu('Keuangan', 'Aktifkan modul'), findsNothing);
    expect(find.text('Kas/Bank yang dikelola unit'), findsOneWidget);
    await tekanKartu('Keuangan unit', 'Nonaktifkan modul');
    await ketuk('Nonaktifkan modul');
    expect(status(Module.unitFinance), ModuleStatus.active);
    await tekan(tester, 'Kembali');
    await matikan('Keuangan unit', 'Bendahara unit belum siap');
    expect(status(Module.unitFinance), ModuleStatus.readOnly);
    expect(
      jejakTerakhir(c, 'module.switch').reason,
      'Bendahara unit belum siap',
    );
    // Modul's own link into the module is gone too.
    expect(find.text('Kas/Bank yang dikelola unit'), findsNothing);
    await keluar(tester);

    // Everyone: rows and menu items gone, paths show "Modul tidak aktif".
    await jejakUnitMeiske(ada: false);
    await masukSebagai(tester, Persona.hendrik);
    expect(
      c
          .read(homeRowsProvider)
          .where((r) => r.ke.modulLayar == ModulLayar.keuanganUnit),
      isEmpty,
    );
    await buka(Layar.keuanganUnit);
    expect(find.text('Halaman ini tidak tersedia'), findsOneWidget);
    expect(
      c.read(penjagaProvider(Layar.keuanganUnit)),
      Penjaga.modulTidakAktif,
    );
    await keluar(tester);

    // Dependency order: Warta Jemaat needs Pengumuman; nothing cascades.
    await masukSebagai(tester, Persona.lidya);
    await buka(Layar.modul);
    await matikan('Pengumuman', 'Diganti Warta Jemaat');
    expect(status(Module.announcements), ModuleStatus.readOnly);
    expect(status(Module.warta), ModuleStatus.active);
    await matikan('Warta Jemaat', 'Belum ada penyusun');
    await tekanKartu('Warta Jemaat', 'Aktifkan modul');
    expect(
      find.textContaining(
        'modul Pengumuman harus aktif lebih dulu.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    await ketuk('Aktifkan modul');
    expect(status(Module.warta), ModuleStatus.readOnly);
    await tekan(tester, 'Kembali');
    await aktifkan('Pengumuman');
    await aktifkan('Warta Jemaat');
    expect(status(Module.warta), ModuleStatus.active);

    // Switching back restores.
    await aktifkan('Keuangan unit');
    expect(status(Module.unitFinance), ModuleStatus.active);
    expect(find.text('Kas/Bank yang dikelola unit'), findsOneWidget);
    await keluar(tester);
    await jejakUnitMeiske(ada: true);
  });
}
