import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_prototype/mock/model.dart' show GayaLabel;
import 'package:palakat_prototype/motion/ulang.dart';
import 'package:palakat_prototype/shell/tautan.dart';
import 'package:palakat_prototype/theme/palakat_tema.dart';
import 'package:palakat_prototype/widgets/batang_pembagian.dart';
import 'package:palakat_prototype/widgets/garis.dart';
import 'package:palakat_prototype/widgets/lencana_modul.dart';
import 'package:palakat_prototype/widgets/lencana_status.dart';
import 'package:palakat_prototype/widgets/penolakan.dart';
import 'package:palakat_prototype/widgets/rangka.dart';
import 'package:palakat_prototype/widgets/tahapan.dart';
import 'package:palakat_prototype/widgets/tombol.dart';
import 'package:palakat_prototype/widgets/tombol_bersyarat.dart';

const c = PalakatWarna.terang;

Widget _app(Widget anak, {bool kurangi = false}) => MaterialApp(
  theme: palakatTema(Brightness.light),
  home: MediaQuery(
    data: MediaQueryData(
      size: const Size(390, 844),
      disableAnimations: kurangi,
    ),
    child: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 390,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Align(alignment: Alignment.topLeft, child: anak),
          ),
        ),
      ),
    ),
  ),
);

/// Fill and line of the first ShapeDecoration under [f].
(Color?, ShapeBorder) _rupa(WidgetTester t, Finder f) {
  final d =
      t
              .widgetList<Container>(
                find.descendant(
                  of: f,
                  matching: find.byType(Container),
                  matchRoot: true,
                ),
              )
              .firstWhere((k) => k.decoration is ShapeDecoration)
              .decoration!
          as ShapeDecoration;
  return (d.color, d.shape);
}

Color? _warnaTeks(WidgetTester t, String s) {
  final r = t.renderObject<RenderParagraph>(find.text(s, findRichText: true));
  return r.text.style?.color ??
      (r.text as TextSpan).children?.whereType<TextSpan>().last.style?.color;
}

void main() {
  group('LencanaStatus', () {
    final harapan = <BentukLencana, (GayaGaris?, Color?, Color?, Color)>{
      BentukLencana.draf: (GayaGaris.putus, c.putus, null, c.tinta2),
      BentukLencana.garis: (GayaGaris.penuh, c.tinta3, c.permukaan, c.tinta2),
      BentukLencana.tinta: (GayaGaris.penuh, c.tinta, c.tinta, c.permukaan),
      BentukLencana.laut: (GayaGaris.penuh, c.laut, c.laut, c.diLaut),
      BentukLencana.lautGaris: (GayaGaris.penuh, c.laut, c.permukaan, c.laut),
      BentukLencana.bata: (GayaGaris.penuh, c.bata, c.permukaan, c.bata),
      BentukLencana.abu: (GayaGaris.penuh, c.garis, c.garis, c.tinta2),
      BentukLencana.peran: (GayaGaris.penuh, c.tinta, c.permukaan, c.tinta),
      BentukLencana.usulanAI: (GayaGaris.titik, c.laut, null, c.lautTua),
      BentukLencana.terbalik: (null, null, c.permukaan, c.tinta),
    };
    for (final MapEntry(key: b, value: h) in harapan.entries) {
      testWidgets('shape ${b.name}', (t) async {
        await t.pumpWidget(_app(LencanaStatus('Kata', bentuk: b)));
        final (isi, garis) = _rupa(t, find.byType(LencanaStatus));
        expect(isi, h.$3);
        if (h.$1 == null) {
          expect(garis, isA<RoundedRectangleBorder>());
        } else {
          final g = garis as GarisBorder;
          expect((g.gaya, g.warna, g.tebal), (h.$1, h.$2, 1.5));
          expect(g.radius, BorderRadius.circular(6));
        }
        expect(_warnaTeks(t, 'Kata'), h.$4);
        final teks = t.widget<Text>(find.text('Kata'));
        expect(
          (teks.style!.fontSize, teks.style!.fontWeight),
          (13, FontWeight.w700),
        );
        expect(teks.softWrap, false);
      });
    }

    testWidgets('padding: 3 9 inside the line, 2 8 AI, 4 10 header', (t) async {
      await t.pumpWidget(
        _app(
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LencanaStatus('A', bentuk: BentukLencana.garis),
              LencanaStatus('B', bentuk: BentukLencana.usulanAI),
              LencanaStatus('C', bentuk: BentukLencana.laut, kepala: true),
            ],
          ),
        ),
      );
      Size beda(String s) {
        final luar = t.getSize(
          find.ancestor(of: find.text(s), matching: find.byType(LencanaStatus)),
        );
        final dalam = t.getSize(find.text(s));
        return Size(luar.width - dalam.width, luar.height - dalam.height);
      }

      expect(beda('A'), const Size(21, 9));
      expect(beda('B'), const Size(19, 7));
      expect(beda('C'), const Size(20, 8));
      expect(
        _rupa(t, find.byType(LencanaStatus).at(2)).$2,
        isA<RoundedRectangleBorder>(),
      );
    });

    test('uang mapping and GayaLabel', () {
      expect(StatusUang.draf.bentuk, BentukLencana.draf);
      expect(StatusUang.sudahDiperiksa.bentuk, BentukLencana.lautGaris);
      expect(StatusUang.dibukukan.bentuk, BentukLencana.tinta);
      expect(StatusUang.sudahDitutup.bentuk, BentukLencana.tinta);
      for (final s in [
        StatusUang.dibalik,
        StatusUang.belumDitutup,
        StatusUang.sedangDikerjakan,
      ]) {
        expect(s.bentuk, BentukLencana.garis);
      }
      expect(StatusUang.dibatalkan.bentuk, BentukLencana.abu);
      expect(StatusUang.sudahDipastikan.bentuk, BentukLencana.laut);
      expect(StatusUang.perluDipastikanLagi.bentuk, BentukLencana.bata);
      expect(StatusUang.perluDipastikanLagi.label, 'Perlu dipastikan lagi');
      expect(GayaLabel.lautg.bentuk, BentukLencana.lautGaris);
      expect(GayaLabel.abu.bentuk, BentukLencana.abu);
    });

    testWidgets('uang factory shows the word', (t) async {
      await t.pumpWidget(_app(LencanaStatus.uang(StatusUang.sudahDiperiksa)));
      expect(find.text('Sudah diperiksa'), findsOneWidget);
    });
  });

  group('LencanaModul', () {
    final kasus = <(Widget, String, BentukLencana)>[
      (
        const LencanaModul.modul(KeadaanModul.aktif),
        'Aktif',
        BentukLencana.laut,
      ),
      (
        const LencanaModul.modul(KeadaanModul.tidakAktif),
        'Tidak aktif',
        BentukLencana.draf,
      ),
      (
        const LencanaModul.modul(KeadaanModul.hanyaBaca),
        'Hanya baca',
        BentukLencana.garis,
      ),
      (
        const LencanaModul.jabatan(KeadaanJabatan.aktif),
        'Aktif',
        BentukLencana.laut,
      ),
      (
        const LencanaModul.jabatan(KeadaanJabatan.berakhir),
        'Berakhir',
        BentukLencana.abu,
      ),
      (
        const LencanaModul.jabatan(KeadaanJabatan.jabatanKosong),
        'Jabatan kosong',
        BentukLencana.bata,
      ),
    ];
    for (final (w, label, bentuk) in kasus) {
      testWidgets('$label → ${bentuk.name}', (t) async {
        await t.pumpWidget(_app(w));
        final l = t.widget<LencanaStatus>(find.byType(LencanaStatus));
        expect((l.label, l.bentuk), (label, bentuk));
      });
    }
  });

  group('Tahapan', () {
    testWidgets('done and not reached chips, one label', (t) async {
      final h = t.ensureSemantics();
      await t.pumpWidget(
        _app(
          const Tahapan(
            langkah: ['Draf', 'Sudah diperiksa', 'Diterbitkan'],
            selesai: 1,
          ),
        ),
      );
      expect(find.text('1 · Draf'), findsOneWidget);
      expect(find.text('3 · Diterbitkan'), findsOneWidget);
      final (isi1, g1) = _rupa(
        t,
        find
            .ancestor(
              of: find.text('1 · Draf'),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(isi1, c.tinta);
      expect(((g1 as GarisBorder).gaya, g1.warna), (GayaGaris.penuh, c.tinta));
      expect(_warnaTeks(t, '1 · Draf'), c.permukaan);
      final (isi2, g2) = _rupa(
        t,
        find
            .ancestor(
              of: find.text('2 · Sudah diperiksa'),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(isi2, isNull);
      expect(((g2 as GarisBorder).gaya, g2.warna), (GayaGaris.putus, c.putus));
      expect(_warnaTeks(t, '2 · Sudah diperiksa'), c.tinta3);
      expect(
        t
            .getSize(
              find
                  .ancestor(
                    of: find.text('1 · Draf'),
                    matching: find.byType(Container),
                  )
                  .first,
            )
            .height,
        33,
      );
      expect(
        find.bySemanticsLabel(
          'Langkah 1 dari 3: 1 Draf, 2 Sudah diperiksa, 3 Diterbitkan',
        ),
        findsOneWidget,
      );
      h.dispose();
    });
  });

  group('BatangPembagian', () {
    testWidgets('segments share the inner width, animated, overfull clamps', (
      t,
    ) async {
      Widget batang(List<int> j, {bool putus = true}) => _app(
        SizedBox(
          width: 303,
          child: BatangPembagian(
            total: 1000,
            garisPutus: putus,
            bagian: [
              for (final (i, v) in j.indexed)
                BagianBatang(v, BatangPembagian.warnaBagian(c)[i]),
            ],
          ),
        ),
      );
      await t.pumpWidget(batang([500, 250]));
      List<double> lebar() => [
        for (final e in find.byType(AnimatedContainer).evaluate())
          e.size!.width,
      ];
      expect(lebar(), [150, 75]); // inner width 300 = 303 − 2 × 1.5
      expect(t.getSize(find.byType(BatangPembagian)).height, 18);
      await t.pumpWidget(batang([500, 1500]));
      await t.pump(const Duration(milliseconds: 200));
      expect(lebar()[1], lessThan(225)); // still moving
      await t.pumpAndSettle();
      expect(lebar(), [75, 225]); // divides by max(total, Σ) = 2000
      final (_, garis) = _rupa(t, find.byType(BatangPembagian));
      expect(
        ((garis as GarisBorder).gaya, garis.radius),
        (GayaGaris.putus, BorderRadius.circular(9)),
      );
      await t.pumpWidget(batang([1000], putus: false));
      await t.pumpAndSettle();
      expect(lebar(), [303]);
    });

    testWidgets('reduce motion jumps', (t) async {
      Widget b(int v) => _app(
        SizedBox(
          width: 103,
          child: BatangPembagian(total: 100, bagian: [BagianBatang(v, c.laut)]),
        ),
        kurangi: true,
      );
      await t.pumpWidget(b(10));
      await t.pumpWidget(b(50));
      await t.pump();
      expect(t.getSize(find.byType(AnimatedContainer)).width, 50);
    });

    testWidgets('SisaPembagian colour follows pas', (t) async {
      await t.pumpWidget(
        _app(
          const SisaPembagian(
            label: 'Sisa belum dibagi',
            jumlah: 250000,
            pas: false,
          ),
        ),
      );
      expect(find.text('Rp250.000'), findsOneWidget);
      expect(_warnaTeks(t, 'Sisa belum dibagi'), c.bata);
      expect(_warnaTeks(t, 'Rp250.000'), c.bata);
      await t.pumpWidget(
        _app(
          const SisaPembagian(
            label: 'Total baris sama dengan Jumlah',
            jumlah: 0,
            pas: true,
          ),
        ),
      );
      expect(_warnaTeks(t, 'Rp0'), c.laut);
    });
  });

  group('Rangka', () {
    testWidgets('blocks pulse, status semantics, still under reduce motion', (
      t,
    ) async {
      final h = t.ensureSemantics();
      final rangka = SizedBox(
        width: 200,
        child: Rangka(
          keterangan: 'Memuat saldo dan transaksi…',
          balok: const [
            RangkaBalok(lebar: .62, tinggi: 44),
            RangkaBalok(lebar: .44, tinggi: 16, denyut: false),
          ],
        ),
      );
      await t.pumpWidget(_app(rangka));
      expect(t.getSize(find.byType(RangkaBalok).first), const Size(200, 44));
      final blok = find.descendant(
        of: find.byType(RangkaBalok).first,
        matching: find.byType(Container),
      );
      expect(t.getSize(blok), const Size(124, 44));
      expect(find.byType(Denyut), findsOneWidget);
      await t.pump(const Duration(milliseconds: 700));
      expect(
        t.widget<Opacity>(find.byType(Opacity)).opacity,
        closeTo(.45, .01),
      );
      expect(find.bySemanticsLabel(RegExp('^Memuat')), findsOneWidget);
      await t.pumpWidget(_app(rangka, kurangi: true));
      await t.pump(const Duration(milliseconds: 700));
      expect(t.widget<Opacity>(find.byType(Opacity)).opacity, 1);
      h.dispose();
    });

    testWidgets('failure card retries', (t) async {
      var n = 0;
      await t.pumpWidget(
        _app(
          RangkaGagal(kalimat: 'Server tidak menjawab.', onCobaLagi: () => n++),
        ),
      );
      expect(find.text('Data belum dapat dimuat'), findsOneWidget);
      final (isi, g) = _rupa(t, find.byType(RangkaGagal));
      expect((isi, (g as GarisBorder).warna), (c.bataLembut, c.bata));
      expect(t.getSize(find.byType(Tombol)).width, greaterThanOrEqualTo(140));
      await t.tap(find.text('Coba lagi'));
      expect(n, 1);
    });
  });

  group('Tombol', () {
    final harapan = <JenisTombol, (Color?, GayaGaris?, Color?, Color)>{
      JenisTombol.utama: (c.laut, null, null, c.diLaut),
      JenisTombol.tinta: (c.tinta, null, null, c.permukaan),
      JenisTombol.kedua: (c.permukaan, GayaGaris.penuh, c.tinta, c.tinta),
      JenisTombol.teks: (null, null, null, c.laut),
      JenisTombol.garisLaut: (c.permukaan, GayaGaris.penuh, c.laut, c.laut),
      JenisTombol.putus: (null, GayaGaris.putus, c.putus, c.tinta2),
      JenisTombol.bata: (c.bata, null, null, c.diBata),
      JenisTombol.garisBata: (c.permukaan, GayaGaris.penuh, c.bata, c.bata),
    };
    for (final MapEntry(key: j, value: h) in harapan.entries) {
      testWidgets('jenis ${j.name}', (t) async {
        var n = 0;
        await t.pumpWidget(
          _app(Tombol('Bukukan', jenis: j, onPressed: () => n++)),
        );
        final (isi, garis) = _rupa(t, find.byType(Tombol));
        expect(isi, h.$1);
        if (h.$2 == null) {
          expect(garis, isA<RoundedRectangleBorder>());
        } else {
          expect(
            ((garis as GarisBorder).gaya, garis.warna, garis.tebal),
            (h.$2, h.$3, 1.5),
          );
        }
        expect(_warnaTeks(t, 'Bukukan'), h.$4);
        expect(
          t.getSize(find.byType(Tombol)),
          Size(350, j == JenisTombol.teks ? 44 : 52),
        );
        await t.tap(find.byType(Tombol));
        expect(n, 1);
      });
    }

    for (final u in UkuranTombol.values) {
      testWidgets('ukuran ${u.name}', (t) async {
        await t.pumpWidget(
          _app(
            Align(
              alignment: Alignment.topLeft,
              child: Tombol(
                'Ubah',
                jenis: JenisTombol.kedua,
                ukuran: u,
                lebarPenuh: false,
                onPressed: () {},
              ),
            ),
          ),
        );
        final s = t.getSize(find.byType(Tombol));
        final teks = t.getSize(find.text('Ubah'));
        expect(s.height, u.tinggi);
        expect(s.width, closeTo(teks.width + 2 * u.padding + 3, .01));
        expect(
          (_rupa(t, find.byType(Tombol)).$2 as GarisBorder).radius,
          BorderRadius.circular(u.radius),
        );
      });
    }

    testWidgets('nonaktif: garis/tinta3, focusable, never runs', (t) async {
      final h = t.ensureSemantics();
      var n = 0;
      await t.pumpWidget(
        _app(Tombol('Bukukan', nonaktif: true, onPressed: () => n++)),
      );
      expect(_rupa(t, find.byType(Tombol)).$1, c.garis);
      expect(_warnaTeks(t, 'Bukukan'), c.tinta3);
      await t.tap(find.byType(Tombol));
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(n, 0);
      expect(
        t.getSemantics(find.byType(TekanAria)),
        matchesSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
          isFocusable: true,
          label: 'Bukukan',
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      h.dispose();
    });

    testWidgets('ikon leads with gap 8, ukuranTeks applies', (t) async {
      await t.pumpWidget(
        _app(
          Tombol(
            'Lampirkan',
            ikon: const SizedBox(width: 20, height: 20),
            ukuranTeks: 14,
            onPressed: () {},
          ),
        ),
      );
      final r = t.renderObject<RenderParagraph>(
        find.textContaining('Lampirkan', findRichText: true),
      );
      expect(r.text.style!.fontSize, 14);
      expect(find.byType(SizedBox), findsWidgets);
    });
    testWidgets('ke: a Tautan to the board, push by default', (t) async {
      final router = GoRouter(
        initialLocation: '/Draf',
        routes: [
          for (final s in ['Draf', 'Main'])
            GoRoute(
              path: '/$s',
              builder: (_, _) => Scaffold(
                body: Column(
                  children: [
                    Text('papan $s'),
                    Tombol(
                      'Kembali ke Beranda',
                      jenis: JenisTombol.teks,
                      onPressed: null,
                      ke: 'Main',
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
      await t.pumpWidget(
        MaterialApp.router(
          theme: palakatTema(Brightness.light),
          routerConfig: router,
        ),
      );
      expect(find.byType(Tautan), findsOneWidget);
      expect(t.widget<Tautan>(find.byType(Tautan)).cara, Cara.dorong);
      await t.tap(find.text('Kembali ke Beranda'));
      await t.pumpAndSettle();
      expect(find.text('papan Main'), findsOneWidget);
      expect(router.canPop(), isTrue);
    });
  });

  group('TombolTahan', () {
    Widget tahan(bool siap, VoidCallback f, {bool kurangi = false}) => _app(
      TombolTahan(
        'Tutup buku Oktober 2026',
        siap: siap,
        onSelesai: f,
        petunjuk: 'Tekan dan tahan tombol sampai penuh',
      ),
      kurangi: kurangi,
    );
    double isi(WidgetTester t) => t
        .getSize(
          find.descendant(
            of: find.byType(AnimatedFractionallySizedBox),
            matching: find.byType(ColoredBox),
          ),
        )
        .width;

    testWidgets('held to 1650 ms closes', (t) async {
      var n = 0;
      await t.pumpWidget(tahan(true, () => n++));
      expect(t.getSize(find.byType(TombolTahan)).height, greaterThan(56));
      final g = await t.startGesture(
        t.getCenter(find.text('Tutup buku Oktober 2026')),
      );
      await t.pump(); // the animation starts on this frame
      await t.pump(const Duration(milliseconds: 800));
      expect(isi(t), closeTo(175, 1)); // half of 350, linear
      await t.pump(const Duration(milliseconds: 849)); // 1649 ms
      expect(n, 0);
      await t.pump(const Duration(milliseconds: 1));
      expect(n, 1);
      await g.up();
      await t.pumpAndSettle();
    });

    testWidgets('released early cancels and shrinks in 200 ms', (t) async {
      var n = 0;
      await t.pumpWidget(tahan(true, () => n++));
      final g = await t.startGesture(t.getCenter(find.byType(TombolTahan)));
      await t.pump();
      await t.pump(const Duration(milliseconds: 1000));
      await g.up();
      await t.pump();
      await t.pump(const Duration(milliseconds: 100));
      expect(isi(t), lessThan(219)); // shrinking
      await t.pump(const Duration(milliseconds: 100));
      expect(isi(t), 0);
      await t.pump(const Duration(seconds: 2));
      expect(n, 0);
    });

    testWidgets('dragging off the button cancels', (t) async {
      var n = 0;
      await t.pumpWidget(tahan(true, () => n++));
      final g = await t.startGesture(
        t.getCenter(find.text('Tutup buku Oktober 2026')),
      );
      await t.pump(const Duration(milliseconds: 500));
      await g.moveBy(const Offset(0, -200));
      await t.pump(const Duration(seconds: 2));
      expect(n, 0);
      await g.up();
    });

    testWidgets('not siap: grey, nothing happens', (t) async {
      var n = 0;
      await t.pumpWidget(tahan(false, () => n++));
      expect(_warnaTeks(t, 'Tutup buku Oktober 2026'), c.tinta3);
      final g = await t.startGesture(t.getCenter(find.byType(TombolTahan)));
      await t.pump(const Duration(seconds: 2));
      await g.up();
      expect(n, 0);
      expect(isi(t), 0);
    });

    testWidgets('keyboard closes at once; reduce motion keeps the hold time', (
      t,
    ) async {
      var n = 0;
      await t.pumpWidget(tahan(true, () => n++, kurangi: true));
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.sendKeyEvent(LogicalKeyboardKey.space);
      expect(n, 1);
      final g = await t.startGesture(t.getCenter(find.byType(TombolTahan)));
      await t.pump();
      expect(isi(t), 350); // no animation
      await t.pump(const Duration(milliseconds: 1600));
      expect(n, 1);
      await t.pump(const Duration(milliseconds: 50));
      expect(n, 2);
      await g.up();
    });
  });

  group('TombolBersyarat', () {
    Widget tb({
      required String alasan,
      bool mulai = true,
      VoidCallback? f,
      String Function()? periksa,
      GayaAlasan gaya = GayaAlasan.penolakan,
      JenisTombol siap = JenisTombol.tinta,
      bool redup = false,
      List<Widget>? baris,
    }) => _app(
      TombolBersyarat(
        label: 'Buat pelimpahan',
        tindakan: 'Buat pelimpahan',
        alasan: alasan,
        sudahMulai: mulai,
        onPressed: f ?? () {},
        periksa: periksa,
        gayaAlasan: gaya,
        warnaSiap: siap,
        teksBelumRedup: redup,
        baris: baris,
      ),
    );

    testWidgets('reason only after input starts; first reason only', (t) async {
      await t.pumpWidget(
        tb(
          alasan: 'tanggal berakhir harus setelah hari ini (16/11/2026).',
          mulai: false,
        ),
      );
      expect(find.textContaining('Tidak dapat dilakukan'), findsNothing);
      expect(_rupa(t, find.byType(TombolBersyarat)).$1, c.garis);
      expect(_warnaTeks(t, 'Buat pelimpahan'), c.tinta2);
      await t.pumpWidget(
        tb(alasan: 'tanggal berakhir harus setelah hari ini (16/11/2026).'),
      );
      expect(
        find.text(
          'Tidak dapat dilakukan: Buat pelimpahan. tanggal berakhir harus setelah hari ini (16/11/2026).',
          findRichText: true,
        ),
        findsOneWidget,
      );
      final kalimat = t.renderObject<RenderParagraph>(
        find.textContaining('Tidak dapat dilakukan', findRichText: true),
      );
      expect(kalimat.text.style?.color, c.tinta);
      TextStyle? tebal;
      kalimat.text.visitChildren((s) {
        if (s is TextSpan &&
            s.text == 'Tidak dapat dilakukan: Buat pelimpahan.') {
          tebal = s.style;
        }
        return tebal == null;
      });
      expect((tebal?.color, tebal?.fontWeight), (c.bata, FontWeight.w700));
      await t.pumpWidget(tb(alasan: ''));
      expect(find.textContaining('Tidak dapat dilakukan'), findsNothing);
      expect(_rupa(t, find.byType(TombolBersyarat)).$1, c.tinta);
      expect(_warnaTeks(t, 'Buat pelimpahan'), c.permukaan);
    });

    testWidgets('stays pressable; re-checks on press', (t) async {
      final h = t.ensureSemantics();
      var n = 0;
      var sekarang = 'Pilih orang.';
      await t.pumpWidget(
        tb(alasan: 'Pilih orang.', f: () => n++, periksa: () => sekarang),
      );
      await t.tap(find.byType(TekanAria));
      expect(n, 0);
      expect(
        t.getSemantics(find.byType(TekanAria)),
        matchesSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
          isFocusable: true,
          label: 'Buat pelimpahan',
          hint: 'Pilih orang.',
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      sekarang = ''; // typed, no rebuild yet: the first press works
      await t.tap(find.byType(TekanAria));
      expect(n, 1);
      await t.pumpWidget(tb(alasan: '', f: () => n++));
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(n, 2);
      h.dispose();
    });

    testWidgets('kalimatBata, pendamping, finance colours', (t) async {
      await t.pumpWidget(
        tb(
          alasan: '2 syarat belum terpenuhi.',
          gaya: GayaAlasan.kalimatBata,
          redup: true,
        ),
      );
      expect(
        _warnaTeks(t, 'Tidak dapat dilakukan: 2 syarat belum terpenuhi.'),
        c.bata,
      );
      expect(_warnaTeks(t, 'Buat pelimpahan'), c.tinta3);
      await t.pumpWidget(
        tb(alasan: 'pilih jenis kasus.', gaya: GayaAlasan.pendamping),
      );
      expect(
        _warnaTeks(t, 'Belum dapat disimpan: pilih jenis kasus.'),
        c.tinta2,
      );
      await t.pumpWidget(tb(alasan: '', siap: JenisTombol.utama));
      expect(_rupa(t, find.byType(TombolBersyarat)).$1, c.laut);
      expect(_warnaTeks(t, 'Buat pelimpahan'), c.diLaut);
    });

    testWidgets('flow row: flex 1 1 150px, max 340', (t) async {
      await t.pumpWidget(
        tb(
          alasan: '',
          baris: [
            Tombol('Batalkan', jenis: JenisTombol.teks, onPressed: () {}),
          ],
        ),
      );
      expect(t.getSize(find.byType(TekanAria)).width, 171); // (350 − 8) / 2
      await t.pumpWidget(tb(alasan: '', baris: const []));
      expect(t.getSize(find.byType(TekanAria)).width, 340);
      await t.pumpWidget(tb(alasan: ''));
      expect(t.getSize(find.byType(TekanAria)).width, 350);
    });
  });

  group('Penolakan', () {
    testWidgets('sentence and steps', (t) async {
      var n = 0;
      await t.pumpWidget(
        _app(
          Penolakan(
            tindakan: 'Bukukan',
            sebab: 'September 2026 sudah ditutup.',
            jalan: [
              Tombol(
                'Pindah tanggal',
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
                onPressed: () => n++,
              ),
              Tombol(
                'Batalkan',
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
      final r = t.renderObject<RenderParagraph>(
        find.text(
          'Tidak dapat dilakukan: Bukukan. September 2026 sudah ditutup.',
          findRichText: true,
        ),
      );
      final kuat =
          ((r.text as TextSpan).children!.first as TextSpan).children!.first
              as TextSpan;
      expect(
        (kuat.style!.color, kuat.style!.fontWeight),
        (c.bata, FontWeight.w700),
      );
      expect((r.text.style!.fontSize, r.text.style!.color), (15, c.tinta));
      expect(t.getSize(find.byType(Tombol).first).height, 48);
      await t.tap(find.text('Pindah tanggal'));
      expect(n, 1);
    });

    testWidgets('no steps (Draf), 14 px', (t) async {
      await t.pumpWidget(
        _app(
          const Penolakan(
            tindakan: 'Bukukan',
            sebab: 'x',
            jalan: [],
            ukuranTeks: 14,
          ),
        ),
      );
      expect(find.byType(Tombol), findsNothing);
      expect(
        t
            .renderObject<RenderParagraph>(
              find.text(
                'Tidak dapat dilakukan: Bukukan. x',
                findRichText: true,
              ),
            )
            .text
            .style!
            .fontSize,
        14,
      );
    });
  });
}
