// P8 Letter request (README 8.3): the letter is issued with the number
// NNN/SKet/{Roman M0}/{year}; Novita's inbox shows "Surat keterangan …
// diterbitkan"; Yanti can record a request at the office.

import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/tanggal.dart';
import 'package:palakat_prototype/domain/core/core.dart';
import 'package:palakat_prototype/domain/secretariat/secretariat.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/core_repositories.dart';
import 'package:palakat_prototype/providers/repositories_sekretariat.dart';

import 'harness.dart';

const _romawi = [
  'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', //
  'X', 'XI', 'XII',
];

void main() {
  group('P8 surat', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final c = await bukaAplikasi(tester, tata: tata);
        final surat = c.read(letterRepositoryProvider);
        final hari = Tanggal.dari(jangkarA);
        Future<void> keSurat() async {
          c.read(routerProvider).go(Layar.surat.lokasi());
          await tester.pumpAndSettle();
        }

        // Novita's own request is open; the same one is refused again.
        await masukSebagai(tester, Persona.novita);
        await keSurat();
        expect(find.text('Surat keterangan · Novita Wenas'), findsOneWidget);
        await tekan(tester, 'Ajukan permohonan');
        await tekan(tester, 'Ajukan permohonan');
        expect(
          find.textContaining('permohonan yang sama masih Diajukan.'),
          findsOneWidget,
        );
        await keluar(tester);

        // Yanti records a request at the office for Agustina.
        await masukSebagai(tester, Persona.yanti);
        await keSurat();
        await tekan(tester, 'Catat permohonan di kantor');
        await isi(tester, 'Nama anggota', 'Agustina');
        await tekan(tester, 'Agustina Lasut');
        await isi(tester, 'Keperluan', 'untuk keperluan bank');
        await tekan(tester, 'Catat permohonan');
        expect(
          find.text(
            'Permohonan Surat keterangan · Agustina Lasut dicatat di kantor.',
          ),
          findsOneWidget,
        );
        final kantor = surat.requests(personId: 'agustina').last;
        expect(kantor.atOffice, isTrue);
        expect(kantor.requestedBy, 'yanti');
        expect(jejakTerakhir(c, 'letter.record_at_office').personId, 'yanti');
        await keluar(tester);

        // Olvie issues Novita's letter with the next number.
        await masukSebagai(tester, Persona.olvie);
        await keSurat();
        final nomor = surat.nextNumber(at: hari);
        expect(
          RegExp('^\\d{3}/SKet/${_romawi[hari.bulan - 1]}/${hari.tahun}\$')
              .hasMatch(nomor),
          isTrue,
          reason: nomor,
        );
        await tekan(tester, 'Buka permohonan');
        expect(find.text('Wenas-Lasut · Kolom 7'), findsOneWidget);
        await isi(tester, 'Nomor surat', nomor);
        await tekan(tester, 'Terbitkan surat');
        expect(
          find.textContaining('salinan bertanda tangan belum terlampir.'),
          findsOneWidget,
        );
        await tekan(tester, 'Pilih file');
        await tekan(tester, 'Terbitkan surat');
        expect(
          find.text(
            'Surat keterangan Novita Wenas diterbitkan dengan No. $nomor.',
          ),
          findsOneWidget,
        );
        final r = surat.requests(personId: 'novita').first;
        expect(r.status, LetterStatus.issued);
        expect(r.number, nomor);
        expect(jejakTerakhir(c, 'letter.issue').personId, 'olvie');
        expect(surat.nextNumber(at: hari), isNot(nomor));
        // The issued letter: the member, her household and the servants of
        // her Kolom see it; others do not (PMP 6.1).
        final dok = c.read(documentRepositoryProvider);
        bool lihat(String id) =>
            dok.list(audienceOf: id).any((d) => d.id == r.documentId);
        expect(lihat('novita'), isTrue);
        expect(lihat('agustina'), isTrue);
        expect(lihat('hendrik'), isTrue);
        expect(lihat('meiske'), isFalse);
        // Olvie's inbox held the seeded requests (KotakMasuk round 2).
        expect(
          c
              .read(notificationRepositoryProvider)
              .inbox('olvie')
              .where((n) => n.title.startsWith('Permohonan '))
              .length,
          greaterThanOrEqualTo(3),
        );
        await keluar(tester);

        // With Data jemaat off, the Sekretaris types the member's details.
        await masukSebagai(tester, Persona.lidya);
        final ws = c.read(workspaceRepositoryProvider);
        final m = ws.modules().firstWhere((x) => x.module == Module.membership);
        final mati = await ws.setModuleStatus(
          c.read(actorProvider)!,
          Module.membership,
          ModuleStatus.off,
          reason: 'Belum dipakai',
          expectedRevision: m.revision,
          idempotencyKey: 'p8-data-jemaat-mati',
        );
        expect(mati, isA<Ok<ModuleState>>());
        await keluar(tester);
        await masukSebagai(tester, Persona.olvie);
        await keSurat();
        await tekan(tester, 'Buka permohonan');
        expect(
          find.text(
            'Modul Data jemaat belum aktif. Data anggota diketik di sini dan '
            'hanya dipakai untuk surat ini.',
          ),
          findsOneWidget,
        );
        expect(find.text('Lasut · Kolom 4'), findsOneWidget);
        await isi(tester, 'Nama', '');
        await isi(tester, 'Nomor surat', surat.nextNumber(at: hari));
        await tekan(tester, 'Terbitkan surat');
        expect(
          find.textContaining('nama anggota belum diisi.'),
          findsOneWidget,
        );
        await keluar(tester);

        // Novita's inbox and her documents.
        await masukSebagai(tester, Persona.novita);
        expect(
          c
              .read(notificationRepositoryProvider)
              .inbox('novita')
              .any(
                (n) => n.title == 'Surat keterangan Novita Wenas diterbitkan',
              ),
          isTrue,
        );
        c.read(routerProvider).go(Layar.kotakMasuk.lokasi());
        await tester.pumpAndSettle();
        expect(
          find.text('Surat keterangan Novita Wenas diterbitkan'),
          findsOneWidget,
        );
        c.read(routerProvider).go(Layar.dokumenGereja.lokasi());
        await tester.pumpAndSettle();
        expect(find.text('Surat keterangan · Novita Wenas'), findsOneWidget);
      });
    }
  });
}
