// P6 Posts and delegation, README 8.3: Lidya assigns Penatua Kolom 2 to Altje
// and Yanti's cover ends; Lidya cannot assign herself; Hendrik's delegation
// to Greis shows in force in Pelimpahan and reads ended 15 days later.
// After the M6–M8 merge: Yanti verifies from the Kolom 2 queue under her
// cover (her own family goes to the Syamas); once Altje is assigned the queue
// routes to Altje; Greis verifies a Kolom 7 item in AntreanVerifikasi while
// the delegation is in force, and not after Hendrik ends it.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/domain/core/core.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/core_repositories.dart';
import 'package:palakat_prototype/providers/repositories_jemaat.dart';
import 'package:palakat_prototype/widgets/kecil.dart';

import 'harness.dart';

Future<void> buka(WidgetTester tester, ProviderContainer c, Layar l) async {
  c.read(routerProvider).go(l.lokasi());
  await tester.pumpAndSettle();
}

/// Lidya, in Penugasan: refused for herself, then assigns Altje.
Future<void> tugaskanAltje(WidgetTester tester, ProviderContainer c) async {
  await masukSebagai(tester, Persona.lidya);
  await buka(tester, c, Layar.penugasan);
  final hari = c.read(hariIniProvider);
  // The first vacant post is Penatua Kolom 2.
  await tekan(tester, 'Tugaskan');
  expect(find.text('Penatua Kolom 2'), findsWidgets);
  await isi(tester, 'Orang', 'Lidya');
  await tekan(tester, 'Pdt. Lidya Rondonuwu');
  expect(
    find.textContaining(
      'Anda tidak dapat menugaskan jabatan kepada diri sendiri.',
      findRichText: true,
    ),
    findsOneWidget,
  );
  await isi(tester, 'Orang', 'Altje');
  await tekan(tester, 'Pnt. Altje Rompas');
  await tekan(tester, 'Belum ada dokumen');
  expect(
    find.textContaining(
      'penugasan memerlukan keputusan tertulis gereja di Dokumen gereja.',
      findRichText: true,
    ),
    findsOneWidget,
  );
  final sk = skPenugasan(c);
  await tekan(tester, sk);
  await tekan(tester, 'Catat penugasan');
  expect(
    find.text(
      'Penatua Kolom 2 dipegang Pnt. Altje Rompas sejak $hari. '
      'Keputusan: $sk.',
    ),
    findsOneWidget,
  );
  final p = c
      .read(roleRepositoryProvider)
      .posts()
      .firstWhere((x) => x.post.id == 'penatua-kolom-2');
  expect(p.holder?.personId, 'altje');
  expect(p.cover, isNull);
  expect(jejakTerakhir(c, 'role.assign').personName, 'Pdt. Lidya Rondonuwu');
  await keluar(tester);
}

const _sumual = 'Perubahan data · Keluarga Sumual';
const _sidi = 'Peristiwa: Sidi · Gabriela Rompas';
const _rumagit = 'Perubahan data · Keluarga Rumagit';

/// The Kolom 2 items still open, by id.
List<String> _kolom2(ProviderContainer c) => [
  for (final i in c.read(verificationRepositoryProvider).pending('kolom-2'))
    i.id,
];

/// The "Verifikasi data" button on the card titled [judul].
Finder _verifikasi(String judul) => find.descendant(
  of: find.ancestor(of: find.text(judul), matching: find.byType(Kartu)).first,
  matching: find.text('Verifikasi data'),
);

/// Greis opens AntreanVerifikasi and verifies the item whose row contains
/// [judul], from its own screen (Peristiwa) or inline (a data change).
Future<void> _greisVerifikasi(
  WidgetTester tester,
  ProviderContainer c,
  String judul,
) async {
  await masukSebagai(tester, Persona.greis);
  await buka(tester, c, Layar.verifikasi);
  await tester.tap(find.textContaining(judul).first);
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Verifikasi data').last);
  await tester.tap(find.text('Verifikasi data').last);
  await tester.pumpAndSettle();
}

void main() {
  group('P6 penugasan dan pelimpahan', () {
    testWidgets('ponsel', (tester) async {
      final c = await bukaAplikasi(tester);

      // Yanti runs Penatua Kolom 2: its queue under her cover.
      await masukSebagai(tester, Persona.yanti);
      await buka(tester, c, Layar.jabatanKosong);
      expect(find.text('Menunggu verifikasi · Kolom 2'), findsOneWidget);
      expect(
        find.textContaining(
          'Tidak dapat dilakukan: Verifikasi data. ini data keluarga Anda '
          'sendiri. Diteruskan kepada Syamas Kolom 2.',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(_verifikasi(_sumual), findsNothing);
      await tester.ensureVisible(_verifikasi(_sidi));
      await tester.tap(_verifikasi(_sidi));
      await tester.pumpAndSettle();
      expect(find.text('$_sidi diverifikasi.'), findsOneWidget);
      final v = jejakTerakhir(c, 'membership.verify');
      expect(v.personName, 'Yanti Sumual');
      expect(v.via, const ViaVacancyCover('penatua-kolom-2'));
      expect(
        find.textContaining(
          'oleh Yanti Sumual, Operator · menjalankan jabatan kosong '
          'Penatua Kolom 2',
        ),
        findsWidgets,
      );
      expect(
        c.read(verificationRepositoryProvider).verifiers('perubahan-sumual'),
        ['syamas-kolom-2-orang'],
      );
      await keluar(tester);

      await tugaskanAltje(tester, c);

      // The Kolom 2 queue now routes to Altje.
      final altje = c
          .read(roleRepositoryProvider)
          .posts()
          .firstWhere((x) => x.post.id == 'penatua-kolom-2')
          .holder!;
      final antre = c
          .read(verificationRepositoryProvider)
          .queue(
            Actor(
              personId: 'altje',
              assignmentId: altje.id,
              scopeId: 'kolom-2',
            ),
          );
      expect([
        for (final e in antre)
          if (e.blocked == null) e.item.id,
      ], containsAll(_kolom2(c)));
      expect(_kolom2(c), hasLength(3));

      // Yanti's cover of Penatua Kolom 2 has ended.
      await masukSebagai(tester, Persona.yanti);
      expect(
        find.text('Menjalankan jabatan kosong: Penatua Kolom 2'),
        findsNothing,
      );
      await buka(tester, c, Layar.jabatanKosong);
      expect(
        find.textContaining(
          'Penatua Kolom 2 sudah terisi:',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Anda tidak lagi menjalankan jabatan Penatua Kolom 2.',
          findRichText: true,
        ),
        findsNWidgets(3),
      );
      expect(find.text('Verifikasi data'), findsNothing);
      await keluar(tester);

      // Greis verifies a Kolom 7 item through Hendrik's delegation.
      await _greisVerifikasi(tester, c, 'Keluarga Lasut');
      final g = jejakTerakhir(c, 'membership.verify');
      expect(g.personName, 'Sym. Greis Mamahit');
      expect(g.via, const ViaDelegation('pelimpahan-hendrik-greis'));
      expect(
        c
            .read(verificationRepositoryProvider)
            .item('peristiwa-pindah-lasut')!
            .verifiedScopes,
        contains('kolom-7'),
      );
      await keluar(tester);

      // Hendrik's own family is not verified through his delegation: Greis
      // verifies it as Syamas Kolom 7.
      await _greisVerifikasi(tester, c, _rumagit);
      expect(find.text('$_rumagit diverifikasi.'), findsOneWidget);
      final s = jejakTerakhir(c, 'membership.verify');
      expect(s.personName, 'Sym. Greis Mamahit');
      expect(s.via, Via.direct);
      await keluar(tester);

      // Hendrik's delegation to Greis: in force, then ended by itself.
      await masukSebagai(tester, Persona.hendrik);
      await buka(tester, c, Layar.pelimpahan);
      expect(find.text('Penatua Kolom 7 → Sym. Greis Mamahit'), findsOneWidget);
      expect(find.text('Aktif'), findsOneWidget);
      expect(find.text('Berakhir'), findsNothing);
      await majukanJam(tester, const Duration(days: 15));
      expect(find.text('Aktif'), findsNothing);
      expect(find.text('Berakhir'), findsOneWidget);
      expect(find.text('Berakhir sendiri pada tanggalnya.'), findsOneWidget);
    });

    testWidgets('ponsel · akhiri pelimpahan', (tester) async {
      final c = await bukaAplikasi(tester);
      await masukSebagai(tester, Persona.hendrik);
      await buka(tester, c, Layar.pelimpahan);
      await tekan(tester, 'Akhiri sekarang');
      final hari = c.read(hariIniProvider);
      expect(find.text('Berakhir'), findsOneWidget);
      expect(
        find.text('Diakhiri $hari oleh Pnt. Hendrik Rumagit'),
        findsOneWidget,
      );
      expect(find.text('Akhiri sekarang'), findsNothing);
      expect(
        jejakTerakhir(c, 'role.delegate.end').personName,
        'Pnt. Hendrik Rumagit',
      );
      await keluar(tester);

      // Greis no longer acts through the delegation, and is told so.
      expect(
        c
            .read(canProvider)
            .grantsOf('greis', at: hari)
            .where((g) => g.kind == GrantKind.delegation),
        isEmpty,
      );
      expect(
        c
            .read(notificationRepositoryProvider)
            .inbox('greis')
            .where((n) => n.title.startsWith('Pelimpahan berakhir')),
        hasLength(1),
      );
    });

    testWidgets('ponsel · masa jabatan pemberi berakhir', (tester) async {
      final c = await bukaAplikasi(tester);
      // Lidya ends Hendrik's Penatua Kolom 7 term in Penugasan.
      await masukSebagai(tester, Persona.lidya);
      await buka(tester, c, Layar.penugasan);
      final kartu = find
          .ancestor(
            of: find.text('Penatua Kolom 7').first,
            matching: find.byType(Kartu),
          )
          .first;
      final akhiri = find.descendant(
        of: kartu,
        matching: find.text('Catat berakhir'),
      );
      await tester.ensureVisible(akhiri);
      await tester.tap(akhiri);
      await tester.pumpAndSettle();
      await isi(tester, 'Alasan · wajib', 'Pindah tugas');
      await tekan(tester, 'Catat berakhir');
      await keluar(tester);

      // Hendrik's delegation to Greis ended with his post.
      final hari = c.read(hariIniProvider);
      expect(
        c
            .read(canProvider)
            .grantsOf('greis', at: hari)
            .where((g) => g.kind == GrantKind.delegation),
        isEmpty,
      );
      final d = c
          .read(roleRepositoryProvider)
          .delegations()
          .firstWhere((x) => x.id == 'pelimpahan-hendrik-greis');
      expect(d.inForce(hari), isFalse);
      // Greis is told, in her inbox.
      await masukSebagai(tester, Persona.greis);
      await buka(tester, c, Layar.kotakMasuk);
      expect(
        find.textContaining('Pelimpahan berakhir', findRichText: true),
        findsWidgets,
      );
      await keluar(tester);
    });

    testWidgets('web (Penugasan)', (tester) async {
      final c = await bukaAplikasi(tester, tata: Tata.web);
      await tugaskanAltje(tester, c);
    });
  });
}
