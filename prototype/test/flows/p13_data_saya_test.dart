// P13 My name and my data (README 8.3; M10 adds the Warta preview): Novita
// saves a name form; withdrawing consent records the request and, asked
// through her own login, deletes her member data at once (DL13); finance
// records keep the booked name.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/domain/membership/membership.dart';
import 'package:palakat_prototype/providers/core_repositories.dart';
import 'package:palakat_prototype/providers/repositories_jemaat.dart';
import 'package:palakat_prototype/providers/repositories_keuangan.dart';
import 'package:palakat_prototype/shell/tautan.dart';

import 'harness.dart';

String _atas(ProviderContainer c) =>
    tumpukanHalaman(c.read(routerProvider)).last;

/// Taps the last widget showing [teks] (the button, not the page title).
Future<void> _tekanAkhir(WidgetTester tester, String teks) async {
  final f = find.text(teks).last;
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('P13 data saya · ponsel', (tester) async {
    final c = await bukaAplikasi(tester);
    final masking = c.read(maskingRepositoryProvider);
    final izin = c.read(consentRepositoryProvider);
    expect(masking.preference('novita'), NameForm.familyKolom);
    expect(
      masking.printedName('novita', PrintContext.warta),
      'Kel. Wenas-Lasut — Kolom 7',
    );

    await masukSebagai(tester, Persona.novita);
    c.read(routerProvider).push(Layar.tampilanNama.lokasi());
    await tester.pumpAndSettle();
    expect(find.text('Pilihan pribadi'), findsOneWidget);
    expect(find.text('Kel. Wenas-Lasut — Kolom 7'), findsWidgets);

    // The chosen name form is saved.
    await tekan(tester, 'Nama lengkap');
    await tekan(tester, 'Simpan pilihan');
    expect(find.text('Tampilan nama disimpan: Nama lengkap.'), findsOneWidget);
    expect(masking.preference('novita'), NameForm.fullName);
    expect(masking.printedName('novita', PrintContext.warta), 'Novita Wenas');
    expect(
      jejakTerakhir(c, 'membership.masking.set').personName,
      'Novita Wenas',
    );
    expect(
      find.textContaining('Tampilan nama diubah menjadi Nama lengkap'),
      findsOneWidget,
    );

    // Withdrawing consent: the request is recorded and carried out.
    await tekan(tester, 'Cabut izin dan hapus data saya');
    expect(_atas(c), Layar.cabutIzin.lokasi());
    await tekan(tester, 'Lanjutkan');
    await tekan(
      tester,
      'Saya mengerti data saya akan dihapus dan tidak dapat dikembalikan. '
      'Untuk menjadi anggota lagi saya harus mengajukan permohonan baru.',
    );
    await _tekanAkhir(tester, 'Cabut izin dan hapus data saya');
    expect(find.text('Catatan penghapusan'), findsOneWidget);
    expect(find.text('anggota sendiri'), findsOneWidget);

    final permintaan = izin.deletionRequests().first;
    expect(permintaan.done, isTrue);
    expect(permintaan.personId, isNull, reason: 'tanpa data pribadi');
    expect(permintaan.executedBy, 'novita');
    expect(jejakTerakhir(c, 'membership.consent.withdraw').personId, 'novita');
    expect(jejakTerakhir(c, 'membership.deletion.request').personId, 'novita');
    expect(c.read(memberRepositoryProvider).member('novita'), isNull);
    expect(
      c.read(memberRepositoryProvider).household('wenas-lasut')!.memberIds,
      isNot(contains('novita')),
    );
    expect(izin.consents('novita'), isEmpty);

    // Finance keeps the booked name; the link to the person is gone.
    final pihak = c
        .read(peopleRepositoryProvider)
        .parties()
        .firstWhere((p) => p.id == 'party-novita');
    expect(pihak.displayName, 'Novita Wenas');
    expect(pihak.personId, isNull);
    await keluar(tester);
    // Read with no one signed in: a member sees no ledger rows.
    final sampul = c.read(transactionRepositoryProvider).get('bku-0132')!;
    expect(sampul.allocations.first.partyId, 'party-novita');
  });
}
