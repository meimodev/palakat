// P11 Become a member (README 8.3, DP36): Yanti, covering the vacant
// Penatua Kolom 2, goes from her home row to JabatanKosong and opens Kevin's
// application from the Kolom 2 queue in AntreanVerifikasi; PermohonanAnggota shows his submitted form read-only;
// "Verifikasi data" verifies it. Kevin is "Aktif" with BIPRA computed;
// Novita is unchanged.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/format.dart';
import 'package:palakat_prototype/domain/core/core.dart';
import 'package:palakat_prototype/domain/membership/membership.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/repositories_jemaat.dart';
import 'package:palakat_prototype/shell/tautan.dart';
import 'package:palakat_prototype/widgets/kecil.dart';

import 'harness.dart';

/// The page on top of the router's stack.
String _atas(ProviderContainer c) =>
    tumpukanHalaman(c.read(routerProvider)).last;

void main() {
  testWidgets('P11 menjadi anggota · ponsel', (tester) async {
    final c = await bukaAplikasi(tester);
    final anggota = c.read(memberRepositoryProvider);
    final novita = anggota.member('novita')!;
    final bipraNovita = novita.bipra;
    expect(anggota.member('kevin'), isNull);

    await masukSebagai(tester, Persona.yanti);
    expect(find.text('3 data Kolom 2 menunggu verifikasi'), findsOneWidget);
    expect(
      find.text(
        'Menjalankan jabatan kosong Penatua Kolom 2 sejak '
        '${tgl(c.read(jalanJabatanProvider('penatua-kolom-2')).sejak!)}',
      ),
      findsOneWidget,
    );
    await tekan(tester, '3 data Kolom 2 menunggu verifikasi');
    expect(_atas(c), Layar.jabatanKosong.lokasi());
    await tekan(tester, 'Menunggu verifikasi · Kolom 2');
    expect(_atas(c), Layar.verifikasi.lokasi());
    expect(find.textContaining('Penatua Kolom 2: jabatan kosong.'), findsOne);
    // Her own family's change is in her scope but not hers to verify.
    expect(find.text('Perubahan data · Keluarga Sumual'), findsOneWidget);
    expect(find.text('Ke Syamas'), findsOneWidget);
    expect(
      find.text('Milik keluarga Anda sendiri · diteruskan ke Syamas Kolom 2'),
      findsOneWidget,
    );

    await tekan(tester, 'Permohonan menjadi anggota · Kevin Rompas');
    expect(
      _atas(c),
      Layar.permohonanAnggota.lokasi(param: {'id': 'permohonan-kevin'}),
    );
    // The submitted form, read-only.
    expect(find.text('Kevin Rompas'), findsOneWidget);
    expect(find.text('Kolom 2'), findsOneWidget);
    expect(find.text('Belum pernah menikah'), findsOneWidget);
    expect(
      find.text('Bersama tanggal lahir menentukan Kategori BIPRA: Pemuda'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Anda memverifikasi hanya data Kolom 2, dan bukan data keluarga '
        'Anda sendiri.',
      ),
      findsOneWidget,
    );

    await tekan(tester, 'Verifikasi data');
    expect(find.text('Diverifikasi'), findsOneWidget);
    expect(find.text('Anggota jemaat · Keluarga Rompas · Kolom 2'), findsOne);
    expect(
      find.textContaining(
        'Diverifikasi oleh Yanti Sumual, Operator · menjalankan jabatan '
        'kosong Penatua Kolom 2,',
      ),
      findsOneWidget,
    );

    // Kevin is a member, Aktif, with BIPRA computed.
    final kevin = anggota.member('kevin')!;
    expect(kevin.person.status, PersonStatus.active);
    expect(kevin.kolomId, 'kolom-2');
    expect(kevin.household?.name, 'Rompas');
    expect(kevin.bipra, Bipra.pemuda);
    expect(kevin.profile.bipraOverride, isNull);
    final jejak = jejakTerakhir(c, 'membership.verify');
    expect(jejak.personName, 'Yanti Sumual');
    expect(jejak.viaLabel, 'menjalankan jabatan kosong Penatua Kolom 2');
    expect(
      c.read(verificationRepositoryProvider).item('permohonan-kevin')!.status,
      ItemStatus.verified,
    );

    // CariOrang shows him as an active member of Keluarga Rompas.
    c.read(routerProvider).go(Layar.cariOrang.lokasi());
    await tester.pumpAndSettle();
    await isi(tester, 'Cari nama, keluarga atau Kolom', 'Kevin');
    final kartuKevin = find
        .ancestor(
          of: find.text('Data jemaat · Keluarga Rompas · Kolom 2'),
          matching: find.byType(Kartu),
        )
        .first;
    expect(
      find.descendant(of: kartuKevin, matching: find.text('Aktif')),
      findsOneWidget,
    );

    // Novita is unchanged.
    final lagi = anggota.member('novita')!;
    expect(lagi.person.status, PersonStatus.active);
    expect(lagi.kolomId, novita.kolomId);
    expect(lagi.bipra, bipraNovita);
    expect(lagi.profile.revision, novita.profile.revision);

    // The home row counts one fewer.
    c.read(routerProvider).go(Layar.beranda.lokasi());
    await tester.pumpAndSettle();
    expect(find.text('2 data Kolom 2 menunggu verifikasi'), findsOneWidget);
    await keluar(tester);
  });
}
