// P12 Life events (README 8.3): Novita resubmits Gabriel's returned
// Baptism; without the letter it is refused, with it it is submitted; Data
// jemaat changes only after Hendrik, Penatua Kolom 7, verifies it.

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/format.dart';
import 'package:palakat_prototype/domain/membership/membership.dart';
import 'package:palakat_prototype/providers/repositories_jemaat.dart';
import 'package:palakat_prototype/shell/tautan.dart';

import 'harness.dart';

String _atas(ProviderContainer c) =>
    tumpukanHalaman(c.read(routerProvider)).last;

void main() {
  testWidgets('P12 peristiwa · ponsel', (tester) async {
    final c = await bukaAplikasi(tester);
    final anggota = c.read(memberRepositoryProvider);
    final verifikasi = c.read(verificationRepositoryProvider);
    bool baptis() => anggota
        .events('gabriel')
        .any((e) => e.event!.kind == LifeEventKind.baptism);
    final lama = verifikasi.item('peristiwa-baptis-gabriel')!;
    expect(lama.status, ItemStatus.returned);
    expect(baptis(), isFalse);

    // Novita: the returned Baptism is on her home.
    await masukSebagai(tester, Persona.novita);
    await tekan(tester, 'Baptisan · Gabriel Wenas dikembalikan');
    expect(_atas(c), Layar.peristiwa.lokasi());
    expect(
      find.text(
        'Dikembalikan Penatua Kolom 7. nama di surat baptis “Gabriel J. '
        'Wenas”; mohon samakan.',
        findRichText: true,
      ),
      findsOneWidget,
    );

    // Without the letter: refused, nothing submitted.
    final sebelum = c.read(applicationRepositoryProvider).submittedBy('novita');
    expect(
      find.text('Tidak dapat dilakukan: Ajukan.', findRichText: true),
      findsNothing,
    );
    expect(
      find.textContaining(
        'surat atau piagam belum terlampir.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    await tekan(tester, 'Ajukan peristiwa');
    expect(
      c.read(applicationRepositoryProvider).submittedBy('novita'),
      hasLength(sebelum.length),
    );

    // With it: submitted, Data jemaat unchanged.
    await tekan(tester, 'Pilih file');
    expect(find.text('Terlampir'), findsOneWidget);
    await tekan(tester, 'Ajukan peristiwa');
    expect(
      find.text('Diajukan. Penatua Kolom 7 diberi tahu lewat Pemberitahuan.'),
      findsOneWidget,
    );
    final baru = c
        .read(applicationRepositoryProvider)
        .submittedBy('novita')
        .firstWhere((i) => i.open && i.kind == ItemKind.lifeEvent);
    expect(baru.attachment, 'surat-baptis.jpg');
    expect(baru.event!.personIds, ['gabriel']);
    expect(verifikasi.item(lama.id)!.replacedBy, baru.id);
    expect(find.text('Baptisan · Gabriel Wenas'), findsOneWidget);
    expect(baptis(), isFalse);
    // Resubmitted: the returned row leaves her home.
    c.read(routerProvider).go(Layar.beranda.lokasi());
    await tester.pumpAndSettle();
    expect(find.text('Baptisan · Gabriel Wenas dikembalikan'), findsNothing);
    await keluar(tester);

    // Hendrik verifies it from his queue.
    await masukSebagai(tester, Persona.hendrik);
    await tekan(tester, 'Sebagai Penatua Kolom 7');
    await tekan(
      tester,
      tester
          .widget<Text>(find.textContaining('data menunggu verifikasi').first)
          .data!,
    );
    expect(_atas(c), Layar.verifikasi.lokasi());
    await tekan(tester, 'Peristiwa: Baptisan · Gabriel Wenas');
    expect(_atas(c), Layar.peristiwa.lokasi());
    expect(find.text('surat-baptis.jpg'), findsOneWidget);
    expect(baptis(), isFalse, reason: 'belum berubah sebelum diverifikasi');
    await tekan(tester, 'Verifikasi data');
    expect(verifikasi.item(baru.id)!.status, ItemStatus.verified);
    expect(baptis(), isTrue);
    final jejak = jejakTerakhir(c, 'membership.verify');
    expect(jejak.personName, 'Pnt. Hendrik Rumagit');
    expect(jejak.actingRole, 'Penatua Kolom 7');

    // DataAnggota shows it now.
    await tekan(tester, 'Buka data Gabriel Wenas');
    expect(_atas(c), Layar.dataAnggota.lokasi());
    expect(find.text('Gabriel Wenas'), findsOneWidget);
    expect(
      find.text('${tgl(baru.event!.date.awal)} · Diverifikasi'),
      findsOneWidget,
    );
    await keluar(tester);
  });
}
