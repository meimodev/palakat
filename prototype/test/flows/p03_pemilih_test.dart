// P3 Picker (replaces sign-in), README 8.3. The picker lists the 11
// personas; each lands on its role home (Hendrik first chooses "Sebagai …");
// a change made by one persona shows for the next. Also the layout chooser,
// a launch with no overrides, and the seed over 366 launch days.

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/app.dart';
import 'package:palakat_prototype/app/tata.dart' show pilihTata;
import 'package:palakat_prototype/core/tanggal.dart';
import 'package:palakat_prototype/data/seed/build_seed.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/core_repositories.dart';
import 'package:palakat_prototype/providers/session.dart';
import 'package:palakat_prototype/screens/p2/beranda_jabatan.dart';
import 'package:palakat_prototype/screens/p2/web_beranda_jabatan.dart';
import 'package:palakat_prototype/widgets/bertindak_sebagai.dart';

import 'harness.dart';

/// [teks] on the person card of the home.
Finder _diKartu(String teks) =>
    find.descendant(of: find.byType(DaftarJabatan), matching: find.text(teks));

const _koverYanti = 'Menjalankan jabatan kosong: Penatua Kolom 2';

void main() {
  final tanggal = {'A': jangkarA, 'B': jangkarB, 'D': jangkarD};

  group('P3 pemilih', () {
    for (final MapEntry(key: nama, value: saat) in tanggal.entries) {
      for (final tata in Tata.values) {
        testWidgets('${tata.name} $nama', (tester) async {
          final c = await bukaAplikasi(tester, tata: tata, saat: saat);

          expect(find.text('Masuk sebagai'), findsOneWidget);
          expect(Persona.values, hasLength(11));
          for (final p in Persona.values) {
            expect(find.text(p.nama), findsOneWidget, reason: p.name);
          }

          for (final p in Persona.values) {
            await masukSebagai(tester, p);
            expect(lokasiSekarang(tester), '/', reason: p.name);
            expect(
              find.byType(
                tata == Tata.ponsel
                    ? BerandaJabatanScreen
                    : WebBerandaJabatanScreen,
              ),
              findsOneWidget,
              reason: p.name,
            );
            expect(_diKartu(p.nama), findsOneWidget, reason: p.name);

            switch (p) {
              case Persona.hendrik:
                // Two posts can act: the home asks first (Q31).
                expect(_diKartu('Penatua Kolom 7'), findsOneWidget);
                expect(_diKartu('Ketua Komisi Diakonia'), findsOneWidget);
                expect(c.read(sessionProvider)!.perluMemilih, isTrue);
                await tekan(tester, 'Sebagai Penatua Kolom 7');
                expect(c.read(sessionProvider)!.perluMemilih, isFalse);
                expect(
                  c.read(sessionProvider)!.bertindak!.title,
                  'Penatua Kolom 7',
                );
                expect(find.text('Akun saya'), findsOneWidget);
              case Persona.meiske:
                expect(_diKartu('Bendahara Jemaat'), findsOneWidget);
              case Persona.yanti:
                expect(_diKartu('Operator'), findsOneWidget);
                expect(_diKartu(_koverYanti), findsOneWidget);
              case Persona.novita:
                expect(_diKartu('Anggota jemaat'), findsOneWidget);
              default:
                break;
            }
            expect(find.text('Akun saya'), findsOneWidget, reason: p.name);

            await keluar(tester);
            expect(lokasiSekarang(tester), '/pilih');
          }
        });
      }
    }

    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets('perubahan terlihat persona berikutnya ${tata.name}', (
        tester,
      ) async {
        final c = await bukaAplikasi(tester, tata: tata);
        await masukSebagai(tester, Persona.yanti);
        expect(_diKartu(_koverYanti), findsOneWidget);
        await keluar(tester);

        // Lidya fills the vacant Penatua Kolom 2 post (Penugasan is M6, so
        // through the repository): Yanti's cover ends.
        await masukSebagai(tester, Persona.lidya);
        final role = c.read(roleRepositoryProvider);
        final post = role
            .posts()
            .firstWhere((v) => v.post.id == 'penatua-kolom-2')
            .post;
        final r = await role.assign(
          c.read(actorProvider)!,
          post.id,
          'altje',
          c.read(hariIniProvider),
          expectedRevision: post.revision,
          idempotencyKey: 'p3-altje',
        );
        expect(r.isOk, isTrue, reason: r.refusal?.because);
        await keluar(tester);

        await masukSebagai(tester, Persona.yanti);
        expect(_diKartu('Operator'), findsOneWidget);
        expect(_diKartu(_koverYanti), findsNothing);
      });
    }

    test('pilihTata', () {
      for (final MapEntry(key: tata, value: ukuran) in ukuranTata.entries) {
        expect(
          pilihTata(web: tata == Tata.web, ukuranLogis: ukuran),
          tata,
          reason: tata.name,
        );
      }
      expect(pilihTata(web: true, ukuranLogis: const Size(390, 844)), Tata.web);
    });

    testWidgets('tanpa override: pemilih tampil', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: PalakatApp()));
      await tester.pumpAndSettle();
      expect(find.text('Masuk sebagai'), findsOneWidget);
    });

    test('buildSeed 366 hari, 00.01 dan 23.59', () {
      for (var i = 0; i < 366; i++) {
        final d = jangkarA.add(Duration(days: i));
        for (final (h, m) in [(0, 1), (23, 59)]) {
          final now = DateTime.utc(d.year, d.month, d.day, h, m);
          buildSeed(anchor: Tanggal.dari(now), now: now);
        }
      }
    });
  });
}
