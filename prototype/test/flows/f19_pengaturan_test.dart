// F19 Settings (README 8.3): the second-checker rule shows on; switching it
// off says it stops from M+1 and Meiske's own unchecked draft is still
// refused at Bukukan in M0; adding a Kas/Bank, peruntukan or Lingkup states
// "berlaku mulai {M+1}" and adds a Riwayat line; a deactivated account shows
// dashed; the Mata Anggaran draft is reviewed and published from M+1;
// KasUnit gives a unit its own Kas/Bank.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/format.dart';
import 'package:palakat_prototype/core/tanggal.dart';
import 'package:palakat_prototype/domain/core/core.dart';
import 'package:palakat_prototype/domain/finance/finance.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/clock.dart';
import 'package:palakat_prototype/providers/keuangan/pengaturan.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';
import 'package:palakat_prototype/widgets/garis_status.dart';
import 'package:palakat_prototype/widgets/kecil.dart';
import 'package:palakat_prototype/widgets/sakelar.dart';

import 'harness.dart';

void main() {
  group('F19 pengaturan', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final c = await bukaAplikasi(tester, tata: tata);
        await masukSebagai(tester, Persona.meiske);
        final ponsel = tata == Tata.ponsel;
        final hari = c.read(hariIniProvider);
        final depan = awalBulanKe(hari, 1);
        final bulanDepan = bulanDari(depan);
        final setel = c.read(settingsRepositoryProvider);
        Future<void> ke(Layar l, {String? anak}) async {
          c.read(routerProvider).go(l.lokasi(anak: anak));
          await tester.pumpAndSettle();
        }

        String riwayatTeratas() =>
            c.read(pengaturanProvider).riwayat.first.summary;
        Finder berisi(String t) => find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains(t),
        );

        // ---- The second checker: on; switched off from M+1 ----
        await ke(Layar.pengaturan);
        if (ponsel) {
          expect(find.text('Wajib pemeriksa kedua: hidup'), findsOneWidget);
          await tekan(tester, 'Aturan persetujuan dan dokumen pendukung');
        }
        expect(berisi('Hidup · Bukukan memerlukan'), findsOneWidget);
        final sakelar = find.byWidgetPredicate(
          (w) => w is Sakelar && w.label == 'Wajib pemeriksa kedua',
        );
        await tester.ensureVisible(sakelar);
        await tester.pumpAndSettle();
        await tester.tap(sakelar);
        await tester.pumpAndSettle();
        expect(find.text('Mati mulai $bulanDepan'), findsOneWidget);
        expect(berisi('Berlaku mulai $bulanDepan.'), findsOneWidget);
        expect(setel.rulesInForce(at: hari).secondChecker, isTrue);
        expect(setel.rulesInForce(at: depan).secondChecker, isFalse);
        expect(setel.scheduled(), hasLength(1));
        expect(
          riwayatTeratas(),
          'Wajib pemeriksa kedua mati mulai $bulanDepan',
        );

        // Meiske's own unchecked draft is still refused at Bukukan in M0.
        final tx = c.read(transactionRepositoryProvider);
        const fotokopi = 'Fotokopi warta jemaat';
        final draf = tx.drafts().firstWhere(
          (t) =>
              t.createdBy == 'meiske' &&
              t.status == TransactionStatus.draft &&
              t.description == fotokopi,
        );
        await ke(Layar.transaksi);
        await tekan(tester, fotokopi);
        await tekan(tester, 'Periksa dan bukukan');
        if (ponsel) await tekan(tester, 'Bukukan');
        expect(find.textContaining('Wajib pemeriksa kedua'), findsOneWidget);
        expect(tx.get(draf.id)!.status, TransactionStatus.draft);
        expect(tx.get(draf.id)!.voucher, isNull);
        if (ponsel) {
          await ke(Layar.pengaturan, anak: 'riwayat');
          expect(
            find.text(
              'Meiske Lumentut · Wajib pemeriksa kedua mati mulai $bulanDepan',
            ),
            findsOneWidget,
          );
        }

        // ---- Tambah: a Kas/Bank, a peruntukan and a Lingkup from M+1 ----
        await ke(Layar.ubahPengaturan);
        await isi(tester, 'Nama bank', 'Mandiri');
        await tester.enterText(find.byType(EditableText).at(1), '7788');
        await tester.pumpAndSettle();
        await tekan(tester, 'Simpan sebagai versi baru');
        const bank = 'Bank Mandiri ··7788';
        expect(berisi('$bank · berlaku mulai $bulanDepan'), findsOneWidget);
        expect(
          riwayatTeratas(),
          'Menambah Kas/Bank $bank · berlaku mulai $bulanDepan',
        );
        final mandiri = c
            .read(accountRepositoryProvider)
            .accounts(includeInactive: true)
            .singleWhere((a) => a.name == bank);
        expect(mandiri.activeFrom, depan);

        await tekan(tester, 'Tambah peruntukan');
        await isi(tester, 'Nama peruntukan', 'Beasiswa');
        await tekan(tester, 'Jemaat');
        await tekan(tester, 'Simpan sebagai versi baru');
        expect(
          berisi('Peruntukan Beasiswa · berlaku mulai $bulanDepan'),
          findsOneWidget,
        );
        expect(
          riwayatTeratas(),
          'Menambah peruntukan Beasiswa · berlaku mulai $bulanDepan',
        );

        await tekan(tester, 'Tambah Lingkup');
        await tekan(tester, 'Kolom 4');
        await tekan(tester, 'Simpan sebagai versi baru');
        expect(
          berisi('Lingkup Kolom 4 · berlaku mulai $bulanDepan'),
          findsOneWidget,
        );
        expect(
          riwayatTeratas(),
          'Menambah Lingkup Kolom 4 · berlaku mulai $bulanDepan',
        );
        expect(
          setel.lingkup(at: depan).any((l) => l.scopeId == 'kolom-4'),
          isTrue,
        );
        expect(
          setel.lingkup(at: hari).any((l) => l.scopeId == 'kolom-4'),
          isFalse,
        );

        // ---- Nonaktifkan: Bank SulutGo from M+1, shown dashed ----
        final sulut = c
            .read(accountRepositoryProvider)
            .accounts()
            .firstWhere((a) => a.id == 'bsg');
        final akanMati =
            'Aktif sampai akhir ${bulanDari(hari)} · nonaktif mulai $bulanDepan';
        if (ponsel) {
          await ke(Layar.pengaturan, anak: 'kas');
          final kartu = find.ancestor(
            of: find.text(sulut.name),
            matching: find.byType(Kartu),
          );
          await tester.tap(
            find.descendant(
              of: kartu.first,
              matching: find.text('Nonaktifkan'),
            ),
          );
          await tester.pumpAndSettle();
          await tekan(tester, 'Nonaktifkan mulai $bulanDepan');
          expect(find.text(akanMati), findsOneWidget);
          final garis = tester.widget<Kartu>(
            find
                .ancestor(
                  of: find.text(sulut.name),
                  matching: find.byType(Kartu),
                )
                .first,
          );
          expect(garis.status, GarisStatus.draf);
        } else {
          await ke(Layar.pengaturan);
          final baris = find.ancestor(
            of: find.text(sulut.name),
            matching: find.byType(Row),
          );
          final tombol = find.descendant(
            of: baris.first,
            matching: find.text('Nonaktifkan'),
          );
          await tester.ensureVisible(tombol);
          await tester.pumpAndSettle();
          await tester.tap(tombol);
          await tester.pumpAndSettle();
          expect(find.text(akanMati), findsOneWidget);
        }
        expect(
          c
              .read(accountRepositoryProvider)
              .accounts()
              .firstWhere((a) => a.id == 'bsg')
              .activeTo,
          depan.tambahHari(-1),
        );
        expect(
          riwayatTeratas(),
          'Menonaktifkan ${sulut.name} · berlaku mulai $bulanDepan',
        );

        // ---- Mata Anggaran: Boleh untuk, diperiksa, terbitkan from M+1 ----
        final usulan = c.read(versiMataAnggaranProvider).usulan!;
        expect(usulan.berlaku, depan);
        await ke(Layar.mataAnggaran);
        if (ponsel) await tekan(tester, 'Versi ${usulan.kode}');
        final kode = find.textContaining('5.06.01.00');
        await tester.ensureVisible(kode);
        await tester.pumpAndSettle();
        final pilihan = find
            .ancestor(of: kode, matching: find.byType(Container))
            .evaluate()
            .map(
              (e) => find.descendant(
                of: find.byWidget(e.widget),
                matching: find.text('Milik sendiri'),
              ),
            )
            .firstWhere((f) => f.evaluate().isNotEmpty);
        await tester.tap(pilihan.first);
        await tester.pumpAndSettle();
        final master = c.read(masterRepositoryProvider);
        expect(
          master
              .rows(usulan.versi[MasterKind.belanja]!.id)
              .singleWhere((r) => r.code == '5.06.01.00')
              .allowedEffect,
          AllowedEffect.owned,
        );
        await tekan(tester, 'Tandai sudah diperiksa');
        expect(
          c.read(versiMataAnggaranProvider).usulan!.status,
          MasterVersionStatus.reviewed,
        );
        await tekan(tester, 'Terbitkan');
        await tekan(tester, 'Terbitkan, berlaku mulai $bulanDepan');
        for (final k in MasterKind.values) {
          final v = master
              .versions(k)
              .singleWhere((v) => v.code == usulan.kode);
          expect(v.status, MasterVersionStatus.published);
          expect(v.effectiveFrom, depan);
        }
        expect(
          master
              .pickerRows(MasterKind.belanja, hari)
              .any((r) => r.code == '5.06.01.00'),
          isFalse,
        );
        expect(
          master
              .pickerRows(MasterKind.belanja, depan)
              .any((r) => r.code == '5.06.01.00'),
          isTrue,
        );
        expect(
          berisi('Berlaku mulai $bulanDepan · diterbitkan oleh'),
          findsWidgets,
        );

        // ---- KasUnit: Panitia Natal gets its own Kas from M+1 ----
        await ke(Layar.kasUnit);
        await tekan(tester, 'Tambah Kas/Bank unit');
        await tester.enterText(
          find.byType(EditableText).first,
          'Kas Panitia Natal',
        );
        await tester.pumpAndSettle();
        await tekan(tester, 'Panitia Natal 2026');
        await tekan(tester, 'Simpan');
        expect(
          find.text(
            'Kas Panitia Natal dikelola oleh Panitia Natal 2026, berlaku mulai '
            '$bulanDepan.',
          ),
          findsOneWidget,
        );
        final kasNatal = c
            .read(accountRepositoryProvider)
            .accounts(includeInactive: true)
            .singleWhere((a) => a.name == 'Kas Panitia Natal');
        expect(kasNatal.operatedByScopeId, 'panitia-natal');
        expect(kasNatal.activeFrom, depan);
        final kartuNatal = find.ancestor(
          of: find.text('Kas Panitia Natal'),
          matching: find.byType(Kartu),
        );
        for (final t in [
          'Berlaku mulai $bulanDepan',
          'Dikelola oleh Panitia Natal 2026',
        ]) {
          expect(
            find.descendant(of: kartuNatal, matching: find.text(t)),
            findsOneWidget,
          );
        }
        expect(
          berisi(
            '${tgl(c.read(clockProvider).now())} · Kas Panitia Natal dikelola '
            'oleh Panitia Natal 2026, berlaku mulai $bulanDepan. Oleh Meiske '
            'Lumentut, Bendahara Jemaat.',
          ),
          findsOneWidget,
        );
        expect(Tanggal.dari(c.read(clockProvider).now()), hari);

        // ---- assignToUnit: dated from M+1, only to a unit with a treasurer ----
        final akun = c.read(accountRepositoryProvider);
        final saya = c.read(actorProvider)!;
        Future<Result<Account>> serahkan(String unit, Tanggal mulai) {
          final kas = akun.accounts().firstWhere((a) => a.id == 'kas');
          return akun.assignToUnit(
            saya,
            'kas',
            unit,
            mulai,
            expectedRevision: kas.revision,
            idempotencyKey: kunciBaru('meiske', c.read(clockProvider)),
          );
        }

        expect(await serahkan('kolom-7', hari), isA<Refused<Account>>());
        final tanpa = await serahkan('kolom-4', depan);
        expect(
          (tanpa as Refused<Account>).refusal.because,
          'Kolom 4 belum punya bendahara unit.',
        );
        expect(await serahkan('kolom-7', depan), isA<Ok<Account>>());
        Account kas() => akun.accounts().firstWhere((a) => a.id == 'kas');
        expect(kas().operatedByScopeId, isNull, reason: 'belum berlaku');
        await majukanJam(tester, depan.awal.difference(hari.awal));
        expect(kas().operatedByScopeId, 'kolom-7');
        expect(akun.accounts().any((a) => a.id == 'bsg'), isFalse);
        expect(akun.accounts().any((a) => a.name == bank), isTrue);
      });
    }
  });
}
