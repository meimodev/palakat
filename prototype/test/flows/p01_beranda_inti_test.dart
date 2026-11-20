// P1 Home and inbox, Inti rows (README 8.3, M6): each row comes from a real
// open item and finishing the item removes it. Lidya: "Serah terima …
// menunggu dicatat" until she records it, then "Penugasan … menunggu
// verifikasi wewenang" until the Petugas verifikasi activates it. Yanti:
// "Jabatan Sekretaris Jemaat kosong" until she runs it. Hendrik: "Pemulihan
// akun · …" until he confirms. No web home row links a phone-only screen.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/data/repositories/role_repository.dart';
import 'package:palakat_prototype/providers/home_rows.dart';
import 'package:palakat_prototype/widgets/kecil.dart';

import 'harness.dart';

const _serah = 'Serah terima Bendahara Jemaat menunggu dicatat';
const _tunggu = 'Penugasan Bendahara Jemaat menunggu verifikasi wewenang';
const _kosong = 'Jabatan Sekretaris Jemaat kosong';
const _pulih = 'Pemulihan akun · Novita Wenas';

/// The rows of the Inti screens (C1).
List<String> _barisInti(ProviderContainer c) => [
  for (final r in c.read(homeRowsProvider))
    if (r.ke.modulLayar == Layar.penugasan.modulLayar) r.judul,
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
  });
}
