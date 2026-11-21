// P3 Picker (replaces sign-in), README 8.3. The picker lists the 11
// personas; each lands on its role home (Hendrik first chooses "Sebagai …");
// a change made by one persona shows for the next. Also the layout chooser,
// a launch with no overrides, and the seed over 366 launch days. On the
// phone (owner change 21/11, README 7.3) each lands on the one home `/` with
// its bottom bar: the exact items, each item's screen, the Lainnya hub.

import 'dart:ui' show AppLifecycleState;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/app.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/app/tata.dart' show pilihTata;
import 'package:palakat_prototype/core/tanggal.dart';
import 'package:palakat_prototype/data/seed/build_seed.dart';
import 'package:palakat_prototype/domain/core/core.dart';
import 'package:palakat_prototype/providers/actor.dart';
import 'package:palakat_prototype/providers/bilah_ponsel.dart';
import 'package:palakat_prototype/providers/core_repositories.dart';
import 'package:palakat_prototype/providers/session.dart';
import 'package:palakat_prototype/screens/p2/beranda_ponsel.dart';
import 'package:palakat_prototype/screens/p2/lainnya_ponsel.dart';
import 'package:palakat_prototype/screens/p2/web_beranda_jabatan.dart';
import 'package:palakat_prototype/shell/ponsel_tab_bar.dart';
import 'package:palakat_prototype/widgets/ikon.dart';
import 'package:palakat_prototype/widgets/bertindak_sebagai.dart';
import 'package:palakat_prototype/widgets/kecil.dart';

import 'harness.dart';

/// [teks] on the person card of the home.
Finder _diKartu(String teks) =>
    find.descendant(of: find.byType(DaftarJabatan), matching: find.text(teks));

const _koverYanti = 'Menjalankan jabatan kosong: Penatua Kolom 2';

/// The phone bar's items in order; the raised circle as '+{its label}'.
List<String> _bilah(WidgetTester tester) => [
  for (final i in tester.widget<BilahPonsel>(find.byType(BilahPonsel)).item)
    i.lingkaran ? '+${i.teks}' : i.teks,
];

/// The owner's bar per persona at launch (README 7.3).
const _bilahPersona = {
  Persona.meiske: [
    'Beranda',
    'Transaksi',
    '+Catat transaksi',
    'Bulan',
    'Lainnya',
  ],
  Persona.olvie: ['Beranda', 'Dokumen', '+Terbitkan', 'Kotak masuk', 'Lainnya'],
  Persona.yanti: ['Beranda', 'Data jemaat', '+Impor', 'Kotak masuk', 'Lainnya'],
  Persona.lidya: ['Beranda', 'Penugasan', '+Setujui', 'Kotak masuk', 'Lainnya'],
  Persona.jefry: ['Beranda', 'Periksa', '+Cari', 'Kotak masuk', 'Lainnya'],
  Persona.hendrik: [
    'Beranda',
    'Verifikasi',
    '+Ibadah',
    'Kotak masuk',
    'Lainnya',
  ],
  Persona.greis: ['Beranda', 'Verifikasi', '+Ibadah', 'Kotak masuk', 'Lainnya'],
  Persona.deasy: [
    'Beranda',
    'Keuangan unit',
    '+Kesiapan',
    'Kotak masuk',
    'Lainnya',
  ],
  Persona.olga: ['Beranda', 'Terbatas', '+Kesiapan', 'Kotak masuk', 'Lainnya'],
  Persona.rivo: ['Beranda', 'Panitia', '+Dana', 'Kotak masuk', 'Lainnya'],
  Persona.novita: [
    'Beranda',
    'Persembahan',
    '+Surat',
    'Kotak masuk',
    'Lainnya',
  ],
};

/// Where a bar item opens (screen, child route); the finance bar's Lainnya
/// is the finance Lainnya.
(Layar, String?) _tujuan(String item, {required bool keuangan}) =>
    switch (item) {
      'Transaksi' => (Layar.transaksi, null),
      'Bulan' => (Layar.tutupBuku, null),
      'Lainnya' => (keuangan ? Layar.pengaturan : Layar.lainnya, null),
      'Kotak masuk' => (Layar.kotakMasuk, null),
      'Dokumen' => (Layar.dokumenGereja, null),
      'Terbitkan' => (Layar.dokumenGereja, 'terbit'),
      'Penugasan' => (Layar.penugasan, null),
      'Setujui' || 'Dana' => (Layar.permintaanDana, null),
      'Periksa' => (Layar.pemeriksa, null),
      'Cari' => (Layar.cari, null),
      'Verifikasi' => (Layar.verifikasi, null),
      'Ibadah' => (Layar.ibadah, null),
      'Data jemaat' => (Layar.dataAnggota, null),
      'Impor' => (Layar.imporBuku, null),
      'Keuangan unit' => (Layar.keuanganUnit, null),
      'Kesiapan' => (Layar.kesiapan, null),
      'Terbatas' => (Layar.terbatas, null),
      'Panitia' => (Layar.panitia, null),
      'Persembahan' => (Layar.persembahanSaya, null),
      'Surat' => (Layar.surat, null),
      _ => throw StateError(item),
    };

/// The top page's location, pushed pages included.
String _atas(ProviderContainer c) =>
    c.read(routerProvider).state.uri.toString();

/// The hub row [judul] (not a group heading or a bar label).
Finder _barisHub(String judul) =>
    find.descendant(of: find.byType(BarisDaftar), matching: find.text(judul));

/// Taps the bar item [item] ('+…' is the raised circle, by its label).
Future<void> _tekanBilah(WidgetTester tester, String item) async {
  final f = item.startsWith('+')
      ? find.descendant(
          of: find.byType(BilahPonsel),
          matching: find.bySemanticsLabel(item.substring(1)),
        )
      : find.descendant(
          of: find.byType(BilahPonsel),
          matching: find.text(item),
        );
  await tester.tap(f.first);
  await tester.pumpAndSettle();
}

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
                    ? BerandaPonselScreen
                    : WebBerandaJabatanScreen,
              ),
              findsOneWidget,
              reason: p.name,
            );
            // The phone's finance home is Main's Beranda (owner 21/11).
            final keuangan = tata == Tata.ponsel && p == Persona.meiske;
            expect(
              _diKartu(p.nama),
              keuangan ? findsNothing : findsOneWidget,
              reason: p.name,
            );

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
              case Persona.meiske when keuangan:
                expect(find.text('Saldo buku semua Kas/Bank'), findsOneWidget);
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
            expect(
              find.text('Akun saya'),
              keuangan ? findsNothing : findsOneWidget,
              reason: p.name,
            );

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

    // Owner request: Back on the role home signs out to the picker, keeping
    // the state. Android's back gesture on the phone and the tablet.
    for (final tata in [Tata.ponsel, Tata.tablet]) {
      testWidgets('kembali dari Beranda ke pemilih ${tata.name}', (
        tester,
      ) async {
        // Android hands Back to the app only while the framework says it
        // handles it; a home in a nested navigator once lost that.
        Object? menanganiKembali;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (panggilan) async {
            if (panggilan.method == 'SystemNavigator.setFrameworkHandlesBack') {
              menanganiKembali = panggilan.arguments;
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );
        // The framework reports the flag only for a visible app.
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        final wadah = await bukaAplikasi(tester, tata: tata);
        await masukSebagai(tester, Persona.meiske);
        expect(menanganiKembali, isTrue, reason: 'Back reaches the app');
        wadah.read(routerProvider).push(Layar.akun.lokasi());
        await tester.pumpAndSettle();
        expect(find.text('Perangkat yang masuk'), findsOneWidget);

        // Back from a page above the home only pops it.
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Perangkat yang masuk'), findsNothing);
        expect(find.text('Masuk sebagai'), findsNothing);
        expect(wadah.read(sessionProvider), isNotNull);

        // Back on the home signs out and shows the picker.
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(wadah.read(sessionProvider), isNull);
        expect(find.text('Masuk sebagai'), findsOneWidget);

        await masukSebagai(tester, Persona.olvie);
        expect(lokasiSekarang(tester), Layar.beranda.jalur);
      });
    }

    // The browser's Back from the home reaches /pilih: the same sign-out.
    testWidgets('kembali peramban dari Beranda ke pemilih web', (tester) async {
      final wadah = await bukaAplikasi(tester, tata: Tata.web);
      await masukSebagai(tester, Persona.meiske);
      expect(lokasiSekarang(tester), Layar.beranda.jalur);

      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/navigation',
        const JSONMethodCodec().encodeMethodCall(
          MethodCall('pushRouteInformation', {
            'location': Layar.pemilih.jalur,
            'state': null,
          }),
        ),
        (_) {},
      );
      await tester.pumpAndSettle();
      expect(wadah.read(sessionProvider), isNull);
      expect(find.text('Masuk sebagai'), findsOneWidget);

      // Signing in from there still goes home.
      await masukSebagai(tester, Persona.olvie);
      expect(lokasiSekarang(tester), Layar.beranda.jalur);
      expect(wadah.read(sessionProvider), isNotNull);
    });

    // Owner request: nothing is drawn under the status bar or the gesture bar.
    testWidgets('ponsel di bawah bilah status', (tester) async {
      await bukaAplikasi(tester);
      tester.view.padding = const FakeViewPadding(top: 40, bottom: 24);
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('Masuk sebagai')).dy, greaterThan(40));

      await masukSebagai(tester, Persona.meiske);
      expect(tester.getTopLeft(find.text('Beranda').first).dy, greaterThan(40));
      expect(
        tester.getBottomLeft(find.byType(BerandaPonselScreen)).dy,
        lessThanOrEqualTo(ukuranTata[Tata.ponsel]!.height - 24),
      );
    });

    // Owner change 21/11: every persona's phone home and its bar.
    testWidgets('beranda dan bilah ponsel', (tester) async {
      final c = await bukaAplikasi(tester);
      for (final p in Persona.values) {
        await masukSebagai(tester, p);
        if (p == Persona.hendrik) {
          await tekan(tester, 'Sebagai Penatua Kolom 7');
        }
        final keuangan = p == Persona.meiske;
        expect(lokasiSekarang(tester), Layar.beranda.jalur, reason: p.name);
        expect(c.read(berandaKeuanganPonselProvider), keuangan, reason: p.name);
        expect(
          find.text('Saldo buku semua Kas/Bank'),
          keuangan ? findsOneWidget : findsNothing,
          reason: p.name,
        );
        expect(
          find.byType(BerandaJabatanPonsel),
          keuangan ? findsNothing : findsOneWidget,
          reason: p.name,
        );
        if (!keuangan) {
          expect(find.text('Beranda'), findsWidgets);
          expect(
            find.text('Satu Beranda untuk semua jabatan Anda'),
            findsOneWidget,
          );
          expect(find.bySemanticsLabel('Kembali ke Beranda'), findsNothing);
        }
        final bilah = _bilahPersona[p]!;
        expect(_bilah(tester), bilah, reason: p.name);

        // Every item but Beranda opens its screen; back home after each.
        for (final item in bilah.skip(1)) {
          await _tekanBilah(tester, item);
          if (item == '+Catat transaksi') {
            expect(find.text('Catat apa?'), findsOneWidget);
            // Back closes the sheet first, and stays signed in.
            await tester.binding.handlePopRoute();
            await tester.pumpAndSettle();
            expect(find.text('Catat apa?'), findsNothing);
            expect(c.read(sessionProvider), isNotNull);
            continue;
          }
          final (l, anak) = _tujuan(
            item.replaceFirst('+', ''),
            keuangan: keuangan,
          );
          expect(_atas(c), l.lokasi(anak: anak), reason: '${p.name} $item');
          expect(
            find.text('Halaman ini tidak tersedia'),
            findsNothing,
            reason: '${p.name} $item',
          );
          expect(tester.takeException(), isNull, reason: '${p.name} $item');
          if (item == 'Lainnya') break;
          c.read(routerProvider).go(Layar.beranda.jalur);
          await tester.pumpAndSettle();
        }

        if (keuangan) {
          // The finance Lainnya keeps its bar and gains the other modules.
          expect(_bilah(tester), bilah);
          expect(find.text('Jabatan dan modul lain'), findsOneWidget);
          for (final t in [
            'Warta Jemaat',
            'Permohonan surat',
            'Persembahan saya',
            'Kotak masuk',
            'Akun saya',
          ]) {
            expect(_barisHub(t), findsOneWidget, reason: t);
          }
          await keluar(tester);
          continue;
        }

        // The hub: exactly the screens this persona may open on the phone,
        // grouped by module, then Akun saya and Keluar; its Keluar signs out.
        expect(find.byType(LainnyaPonselScreen), findsOneWidget);
        expect(_bilah(tester), bilah);
        final hari = c.read(hariIniProvider);
        final bisa = {
          for (final l in Layar.values)
            if (judulHub(l) != null &&
                l.ponsel &&
                !l.jalur.contains(':') &&
                penjagaUntuk(
                      l,
                      c.read(canProvider),
                      c.read(actorProvider),
                      hari,
                    ) ==
                    null)
              l,
        };
        final hub = c.read(hubLainnyaProvider);
        expect({for (final (_, d) in hub) ...d.map((t) => t.ke)}, bisa);
        for (final (grup, daftar) in hub) {
          expect(find.text(grup), findsWidgets, reason: '${p.name} $grup');
          for (final t in daftar) {
            expect(
              _barisHub(t.judul),
              findsOneWidget,
              reason: '${p.name} ${t.judul}',
            );
          }
        }
        expect(find.text('Akun saya'), findsOneWidget);
        await tekan(tester, 'Keluar');
        expect(c.read(sessionProvider), isNull, reason: p.name);
        expect(find.text('Masuk sebagai'), findsOneWidget, reason: p.name);
      }
    });

    // Every hub link of every non-finance persona opens its screen without a
    // guard view.
    for (final p in Persona.values.where((p) => p != Persona.meiske)) {
      testWidgets('lainnya ponsel ${p.name}', (tester) async {
        final c = await bukaAplikasi(tester);
        await masukSebagai(tester, p);
        final hub = c.read(hubLainnyaProvider);
        expect(hub, isNotEmpty);
        for (final (_, daftar) in hub) {
          for (final t in daftar) {
            c.read(routerProvider).go(Layar.lainnya.jalur);
            await tester.pumpAndSettle();
            await tester.ensureVisible(_barisHub(t.judul));
            await tester.pumpAndSettle();
            await tester.tap(_barisHub(t.judul));
            await tester.pumpAndSettle();
            expect(_atas(c), t.ke.lokasi(), reason: t.judul);
            expect(find.text('Halaman ini tidak tersedia'), findsNothing);
            expect(tester.takeException(), isNull, reason: t.judul);
          }
        }
      });
    }

    // A persona who may see finance but whose home is not the finance home
    // reaches Main's Beranda from the hub, with Main's bar to move about.
    testWidgets('beranda keuangan dari lainnya ponsel', (tester) async {
      final c = await bukaAplikasi(tester);
      await masukSebagai(tester, Persona.jefry);
      await _tekanBilah(tester, 'Lainnya');
      await tester.ensureVisible(_barisHub('Beranda keuangan'));
      await tester.pumpAndSettle();
      await tester.tap(_barisHub('Beranda keuangan'));
      await tester.pumpAndSettle();
      expect(_atas(c), Layar.keuangan.lokasi());
      expect(find.text('Saldo buku semua Kas/Bank'), findsOneWidget);
      expect(find.byType(PonselTabBar), findsOneWidget);

      await _tekanBilah(tester, 'Transaksi');
      expect(_atas(c), Layar.transaksi.lokasi());
      expect(find.byType(PonselTabBar), findsOneWidget);
      await _tekanBilah(tester, 'Beranda');
      expect(_atas(c), Layar.keuangan.lokasi());

      // Back returns to the hub, then home; still signed in.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(LainnyaPonselScreen), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(BerandaJabatanPonsel), findsOneWidget);
      expect(c.read(sessionProvider), isNotNull);
    });

    // A slot whose screen is off falls to the next post the actor holds.
    testWidgets('bilah ponsel: jabatan berikutnya', (tester) async {
      final c = await bukaAplikasi(tester);
      await masukSebagai(tester, Persona.lidya);
      final roles = c.read(roleRepositoryProvider);
      final pos = roles.posts().firstWhere(
        (x) => x.post.id == 'penatua-kolom-2',
      );
      final t = await roles.assign(
        c.read(actorProvider)!,
        'penatua-kolom-2',
        'olvie',
        c.read(hariIniProvider),
        documentRef: 'dokumen-sk-penugasan',
        expectedRevision: pos.post.revision,
        idempotencyKey: 'p3-olvie-penatua',
      );
      expect(t.isOk, isTrue, reason: t.refusal?.because);
      final ws = c.read(workspaceRepositoryProvider);
      final m = ws.modules().firstWhere(
        (x) => x.module == Module.churchDocuments,
      );
      final r = await ws.setModuleStatus(
        c.read(actorProvider)!,
        Module.churchDocuments,
        ModuleStatus.off,
        reason: 'Belum dipakai',
        expectedRevision: m.revision,
        idempotencyKey: 'p3-dokumen-mati-2',
      );
      expect(r.isOk, isTrue, reason: r.refusal?.because);
      await keluar(tester);

      // Olvie's Sekretaris row is off: the Penatua Kolom row gives the slots.
      await masukSebagai(tester, Persona.olvie);
      expect(_bilah(tester), [
        'Beranda',
        'Verifikasi',
        '+Ibadah',
        'Kotak masuk',
        'Lainnya',
      ]);
      await _tekanBilah(tester, 'Verifikasi');
      expect(_atas(c), Layar.verifikasi.lokasi());
      expect(find.text('Halaman ini tidak tersedia'), findsNothing);
    });

    // A module switched off takes its tab, action and hub group with it.
    testWidgets('modul mati: bilah dan lainnya ponsel', (tester) async {
      final c = await bukaAplikasi(tester);
      await masukSebagai(tester, Persona.olvie);
      expect(_bilah(tester), _bilahPersona[Persona.olvie]);
      await keluar(tester);

      await masukSebagai(tester, Persona.lidya);
      final ws = c.read(workspaceRepositoryProvider);
      final m = ws.modules().firstWhere(
        (x) => x.module == Module.churchDocuments,
      );
      final r = await ws.setModuleStatus(
        c.read(actorProvider)!,
        Module.churchDocuments,
        ModuleStatus.off,
        reason: 'Belum dipakai',
        expectedRevision: m.revision,
        idempotencyKey: 'p3-dokumen-mati',
      );
      expect(r.isOk, isTrue, reason: r.refusal?.because);
      await keluar(tester);

      // Olvie: no Dokumen tab, no Terbitkan, no Dokumen gereja group.
      await masukSebagai(tester, Persona.olvie);
      expect(_bilah(tester), ['Beranda', 'Kotak masuk', 'Lainnya']);
      await _tekanBilah(tester, 'Lainnya');
      expect(find.text('Dokumen gereja'), findsNothing);
      expect(find.text('Permohonan surat'), findsNothing);
      expect(find.text('Pengumuman'), findsWidgets);
      await keluar(tester);

      // Novita: Surat falls away; Persembahan stays.
      await masukSebagai(tester, Persona.novita);
      expect(_bilah(tester), [
        'Beranda',
        'Persembahan',
        'Kotak masuk',
        'Lainnya',
      ]);
    });

    // Owner request: the raised button names its action, and Kotak masuk has
    // its own icon.
    testWidgets('bilah ponsel: label tombol tengah', (tester) async {
      await bukaAplikasi(tester);
      Finder diBilah(String teks) => find.descendant(
        of: find.byType(BilahPonsel),
        matching: find.text(teks),
      );
      await masukSebagai(tester, Persona.meiske);
      expect(diBilah('Catat'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      await masukSebagai(tester, Persona.olvie);
      expect(diBilah('Terbitkan'), findsOneWidget);
      final ikon = tester
          .widgetList<PalakatIkon>(
            find.descendant(
              of: find.byType(BilahPonsel),
              matching: find.byType(PalakatIkon),
            ),
          )
          .map((i) => i.ikon);
      expect(ikon, contains(Ikon.kotakMasuk));
      expect(ikon, isNot(contains(Ikon.unggah)));
    });

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
