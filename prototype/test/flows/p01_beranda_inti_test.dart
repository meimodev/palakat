// P1 Home and inbox, Inti rows (README 8.3, M6): each row comes from a real
// open item and finishing the item removes it. Lidya: "Serah terima …
// menunggu dicatat" until she records it, then "Penugasan … menunggu
// verifikasi wewenang" until the Petugas verifikasi activates it. Yanti:
// "Jabatan Sekretaris Jemaat kosong" until she runs it. Hendrik: "Pemulihan
// akun · …" until he confirms. No web home row links a phone-only screen.
// On the phone (owner change 21/11) Meiske's home is Main's Beranda followed
// by the other modules' rows, with no finance row shown twice.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/data/repositories/role_repository.dart';
import 'package:palakat_prototype/domain/collaboration/collaboration.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/bilah_ponsel.dart';
import 'package:palakat_prototype/providers/home_rows.dart';
import 'package:palakat_prototype/providers/keuangan/beranda.dart';
import 'package:palakat_prototype/providers/repositories_kolaborasi.dart';
import 'package:palakat_prototype/widgets/kecil.dart';

import 'harness.dart';

const _serah = 'Serah terima Bendahara Jemaat menunggu dicatat';
const _tunggu = 'Penugasan Bendahara Jemaat menunggu verifikasi wewenang';
const _kosong = 'Jabatan Sekretaris Jemaat kosong';
const _pulih = 'Pemulihan akun · Novita Wenas';

/// The rows of the Inti screens (C1); a covered Penatua post's Data jemaat
/// queue row also opens JabatanKosong, but belongs to P1 jemaat.
List<String> _barisInti(ProviderContainer c) => [
  for (final r in c.read(homeRowsProvider))
    if (r.ke.modulLayar == Layar.penugasan.modulLayar &&
        !r.judul.endsWith('menunggu verifikasi'))
      r.judul,
];

/// Taps [teks] inside the card that shows [judul].
Future<void> _diKartu(WidgetTester tester, String judul, String teks) async {
  final f = find.descendant(
    of: find.ancestor(of: find.text(judul), matching: find.byType(Kartu)).first,
    matching: find.text(teks),
  );
  await tester.ensureVisible(f);
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  group('P1 beranda inti', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final c = await bukaAplikasi(tester, tata: tata);
        final ponsel = tata == Tata.ponsel;
        Future<void> buka(Layar l, {String? anak}) async {
          c.read(routerProvider).go(l.lokasi(anak: anak));
          await tester.pumpAndSettle();
        }

        // At launch no persona has an Inti row, and no web row links a
        // phone-only screen.
        for (final p in Persona.values) {
          await masukSebagai(tester, p);
          expect(_barisInti(c), isEmpty, reason: p.name);
          for (final r in c.read(homeRowsProvider)) {
            expect(r.ke.adaUntuk(tata), isTrue, reason: '${p.name} ${r.ke}');
          }
          await keluar(tester);
        }

        // Meiske prepares the handover: Lidya's row.
        await masukSebagai(tester, Persona.meiske);
        await buka(Layar.bendahara, anak: 'serah');
        await isi(tester, 'Nama yang ditunjuk', 'Yohanis Tumbelaka');
        await tekan(tester, 'Kirim untuk diverifikasi');
        await keluar(tester);
        await masukSebagai(tester, Persona.lidya);
        expect(_barisInti(c), [_serah]);
        await tekan(tester, _serah);
        expect(find.text('Penugasan jabatan'), findsWidgets);
        await tekan(tester, 'Tugaskan');
        await tekan(tester, 'Catat penugasan');
        // Lidya also ends the Sekretaris' term (Yanti's row below).
        await _diKartu(tester, 'Sekretaris Jemaat', 'Catat berakhir');
        await isi(tester, 'Alasan · wajib', 'Pindah tugas');
        await tekan(tester, 'Catat berakhir');
        await buka(Layar.beranda);
        expect(_barisInti(c), [_tunggu]);
        expect(find.text(_tunggu), findsOneWidget);
        await tungguTiruan(tester, waktuVerifikasiWewenang);
        expect(_barisInti(c), isEmpty);
        expect(find.text(_tunggu), findsNothing);
        await keluar(tester);

        // Yanti: the vacant Sekretaris post until she runs it.
        await masukSebagai(tester, Persona.yanti);
        expect(_barisInti(c), [_kosong]);
        await tekan(tester, _kosong);
        expect(find.text('Menjalankan jabatan kosong'), findsWidgets);
        await tekan(tester, 'Jalankan jabatan kosong');
        await isi(tester, 'Alasan · wajib', 'Sekretaris belum ditugaskan');
        await tekan(
          tester,
          'Saya mengerti setiap tindakan saya tercatat sebagai dijalankan '
          'oleh Operator, dan jabatan ini kembali kepada pemegangnya begitu '
          'ditugaskan.',
        );
        await tekan(tester, 'Jalankan jabatan kosong');
        await buka(Layar.beranda);
        expect(_barisInti(c), isEmpty);
        expect(find.text(_kosong), findsNothing);

        // Yanti asks for Novita's recovery: Hendrik's row.
        await buka(Layar.cariOrang);
        await tekan(tester, 'Orangnya kehilangan nomor ponsel? Pulihkan akun');
        await isi(tester, 'Nama orangnya', 'Novita');
        await tester.ensureVisible(find.text('Cari orang').last);
        await tester.tap(find.text('Cari orang').last);
        await tester.pumpAndSettle();
        await isi(tester, 'Nomor ponsel baru', '081298765432');
        await tekan(tester, 'Minta kepastian Penatua Kolom');
        await keluar(tester);
        await masukSebagai(tester, Persona.hendrik);
        await tekan(tester, 'Sebagai Penatua Kolom 7');
        expect(_barisInti(c), [_pulih]);
        await tekan(tester, _pulih);
        await tekan(
          tester,
          'Saya sudah bertemu atau berbicara langsung dengan orang ini, dan '
          'nomor baru itu memang miliknya.',
        );
        await tekan(tester, 'Pastikan identitas');
        await buka(Layar.beranda);
        expect(_barisInti(c), isEmpty);
        expect(find.text(_pulih), findsNothing);
        if (!ponsel) {
          for (final r in c.read(homeRowsProvider)) {
            expect(r.ke.adaUntuk(tata), isTrue);
          }
        }
      });
    }

    testWidgets('beranda keuangan ponsel Meiske', (tester) async {
      final c = await bukaAplikasi(tester);
      // A request below Rp250.000 is payable at once: Meiske's row of the
      // Persetujuan module ("N permintaan dana siap dibayar").
      await masukSebagai(tester, Persona.hendrik);
      await tekan(tester, 'Sebagai Ketua Komisi Diakonia');
      final r0 = await c
          .read(fundRequestRepositoryProvider)
          .submit(
            c.read(actorProvider)!,
            const FundRequestDraft(
              purpose: 'Konsumsi rapat komisi',
              amount: 200000,
              fundId: 'diak',
            ),
            idempotencyKey: 'p1-inti-dana-kecil',
          );
      expect(r0.isOk, isTrue, reason: r0.refusal?.because);
      await keluar(tester);

      await masukSebagai(tester, Persona.meiske);
      expect(lokasiSekarang(tester), Layar.beranda.jalur);
      expect(c.read(berandaKeuanganPonselProvider), isTrue);

      // Main's summary as drawn.
      final b = c.read(berandaKeuanganProvider);
      expect(find.text('Saldo buku semua Kas/Bank'), findsOneWidget);
      for (final x in [...b.perluTindakan, ...b.untukDiketahui]) {
        expect(find.text(x.judul), findsOneWidget, reason: x.judul);
      }

      // Then the role-home rows of the other modules.
      final lain = c.read(barisBerandaKeuanganProvider);
      final modulLain = lain.where(
        (r) =>
            r.ke.modulLayar != ModulLayar.keuangan &&
            r.ke.modulLayar != ModulLayar.keuanganUnit,
      );
      expect(
        modulLain.map((r) => r.judul),
        contains('1 permintaan dana siap dibayar'),
      );
      for (final r in lain) {
        expect(find.text(r.judul), findsOneWidget, reason: r.judul);
      }

      // No finance row twice: the "Keuangan: N hal" row is the summary
      // itself, and every other home row shows exactly once.
      expect(find.textContaining('hal perlu tindakan'), findsNothing);
      for (final r in c.read(homeRowsProvider)) {
        if (r.ke == Layar.keuangan) continue;
        expect(find.text(r.judul), findsOneWidget, reason: r.judul);
      }

      // A row of another module opens its screen; Back returns home.
      final r = modulLain.first;
      await tekan(tester, r.judul);
      expect(
        c.read(routerProvider).state.uri.toString(),
        r.ke.lokasi(param: r.param),
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Saldo buku semua Kas/Bank'), findsOneWidget);
    });
  });
}
