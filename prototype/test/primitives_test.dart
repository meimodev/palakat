import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/theme/palakat_tema.dart';
import 'package:palakat_prototype/widgets/garis.dart';
import 'package:palakat_prototype/widgets/garis_status.dart';
import 'package:palakat_prototype/widgets/input_format.dart';
import 'package:palakat_prototype/widgets/kecil.dart';
import 'package:palakat_prototype/widgets/tata_letak.dart';
import 'package:palakat_prototype/widgets/tekan.dart';

Widget _app(Widget anak) => MaterialApp(
  theme: palakatTema(Brightness.light),
  home: Scaffold(body: anak),
);

List<(double, double)> _ruas(Path p) => [
  for (final m in p.computeMetrics())
    (
      m.getTangentForOffset(0)!.position.dx,
      m.getTangentForOffset(m.length)!.position.dx,
    ),
];

void main() {
  const c = PalakatWarna.terang;

  group('GarisStatus', () {
    test('line style and colours', () {
      final draf = GarisStatus.draf.gaya(c);
      expect(draf.isi, isNull);
      expect(draf.garis!.gaya, GayaGaris.putus);
      expect(draf.garis!.warna, c.putus);
      expect(draf.garis!.tebal, 1.5);
      expect(draf.garis!.radius, BorderRadius.circular(14));

      final buku = GarisStatus.dibukukan.gaya(c, radius: 16);
      expect(buku.garis!.gaya, GayaGaris.penuh);
      expect(buku.garis!.warna, c.garis);
      expect(buku.garis!.tebal, 1);
      expect(buku.garis!.radius, BorderRadius.circular(16));
      expect(buku.isi, c.permukaan);

      final pilih = GarisStatus.terpilih.gaya(c);
      expect(
        (pilih.garis!.gaya, pilih.garis!.warna, pilih.garis!.tebal),
        (GayaGaris.penuh, c.tinta, 1.5),
      );
      expect(pilih.isi, c.permukaan);

      final tutup = GarisStatus.ditutup.gaya(c);
      expect(tutup.garis, isNull);
      expect(tutup.isi, c.tinta);

      final ai = GarisStatus.usulanAI.gaya(c);
      expect(
        (ai.garis!.gaya, ai.garis!.warna, ai.garis!.tebal),
        (GayaGaris.titik, c.laut, 1.5),
      );
      expect(ai.isi, c.permukaan);

      final hambat = GarisStatus.hambatan.gaya(c);
      expect(
        (hambat.garis!.gaya, hambat.garis!.warna),
        (GayaGaris.penuh, c.bata),
      );
      expect(hambat.isi, c.permukaan);

      expect(
        GarisStatus.ditutup.gaya(PalakatWarna.gelap).isi,
        PalakatWarna.gelap.tinta,
      );
    });
  });

  group('Garis', () {
    final garis = Path()
      ..moveTo(0, 0)
      ..lineTo(100, 0);

    test(
      'dashed 1.5 on an open 100 px line: dashes of 4.5, ends on a dash',
      () {
        final r = _ruas(
          GarisPainter.dashPath(garis, GayaGaris.putus, 1.5, tertutup: false),
        );
        expect(r.first.$1, 0);
        expect(r.last.$2, closeTo(100, 1e-4));
        for (final (a, b) in r) {
          expect(b - a, closeTo(4.5, 1e-4));
        }
        expect(r.length, 14);
      },
    );

    test('dotted 1.5: squares of 1.5', () {
      final r = _ruas(
        GarisPainter.dashPath(garis, GayaGaris.titik, 1.5, tertutup: false),
      );
      for (final (a, b) in r) {
        expect(b - a, closeTo(1.5, 1e-4));
      }
      expect(r.last.$2, closeTo(100, 1e-4));
    });

    test('closed path: n dashes, evenly spaced', () {
      final kotak = Path()..addRect(const Rect.fromLTWH(0, 0, 25, 25));
      final p = GarisPainter.dashPath(kotak, GayaGaris.putus, 1);
      // 100 / (3 + 2) = 20 dashes of 3.
      expect(p.computeMetrics().length, greaterThanOrEqualTo(20));
    });

    test('GarisBorder dimensions and named constructors', () {
      expect(GarisBorder.putus(c.putus).dimensions, const EdgeInsets.all(1.5));
      expect(
        GarisBorder.penuh(c.garis, tebal: 1).dimensions,
        const EdgeInsets.all(1),
      );
      expect(
        GarisBorder.titik(c.laut, radius: 8).radius,
        BorderRadius.circular(8),
      );
      final b = GarisBorder.putus(c.putus, radius: 14).copyWith(tebal: 1);
      expect(
        (b.gaya, b.tebal, b.radius),
        (GayaGaris.putus, 1.0, BorderRadius.circular(14)),
      );
      expect(b.scale(2).tebal, 2);
    });

    testWidgets('GarisLurus is full width, height tebal', (t) async {
      await t.pumpWidget(
        _app(GarisLurus(warna: c.garis, gaya: GayaGaris.putus)),
      );
      expect(t.getSize(find.byType(GarisLurus)), const Size(800, 1));
    });
  });

  group('Tekan', () {
    testWidgets('tap, keyboard, 44 minimum, focus ring only from keyboard', (
      t,
    ) async {
      var n = 0;
      await t.pumpWidget(
        _app(
          Center(
            child: Tekan(
              onTap: () => n++,
              label: 'Simpan',
              radius: 12,
              child: const SizedBox(width: 10, height: 10),
            ),
          ),
        ),
      );
      expect(t.getSize(find.byType(Tekan)), const Size(44, 44));
      await t.tap(find.byType(Tekan));
      expect(n, 1);

      CincinFokus ring() => t.widget(find.byType(CincinFokus));
      expect(ring().tampil, isFalse);

      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pump();
      expect(ring().tampil, isTrue);
      expect(ring().radius, 12);

      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.sendKeyEvent(LogicalKeyboardKey.space);
      expect(n, 3);

      expect(
        t.getSemantics(find.byType(Tekan)),
        matchesSemantics(
          label: 'Simpan',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          isFocused: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
    });

    testWidgets('is its own semantics node beside a text', (t) async {
      await t.pumpWidget(
        _app(
          Column(
            children: [
              const Text('Judul'),
              Tekan(onTap: () {}, child: const Text('Simpan')),
            ],
          ),
        ),
      );
      expect(
        t.getSemantics(find.text('Simpan')),
        matchesSemantics(
          label: 'Simpan',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
    });

    testWidgets('null onTap is disabled', (t) async {
      await t.pumpWidget(_app(const Tekan(onTap: null, child: Text('x'))));
      await t.tap(find.text('x'));
      expect(
        t.getSemantics(find.byType(Tekan)).flagsCollection.isEnabled,
        isNot(true),
      );
    });
  });

  group('Tata letak', () {
    test(
      'BarisLentur: main 999/520 + aside 1/360 + gap 24 side by side from 904',
      () {
        const anak = [
          Lentur(dasar: 520, tumbuh: 999, child: SizedBox()),
          Lentur(dasar: 360, child: SizedBox()),
        ];
        final lebar = BarisLentur.lebar(anak, 24, 904);
        expect(lebar.length, 1);
        expect(lebar[0][0] + lebar[0][1] + 24, closeTo(904, 1e-9));
        expect(BarisLentur.lebar(anak, 24, 903).length, 2);
        expect(BarisLentur.lebar(anak, 24, 903)[1][0], 360 + 543);
        expect(BarisLentur.lebar(anak, 24, 300), [
          [300.0],
          [300.0],
        ]);
        // The space an item cannot take past its max-width goes to the others.
        expect(
          BarisLentur.lebar(
            const [
              Lentur(dasar: 200, maks: 300, child: SizedBox()),
              Lentur(dasar: 200, child: SizedBox()),
            ],
            0,
            1000,
          ),
          [
            [300.0, 700.0],
          ],
        );
        // max-width also clamps the size that decides the line break.
        expect(
          BarisLentur.lebar(
            const [
              Lentur(dasar: 600, maks: 400, child: SizedBox()),
              Lentur(dasar: 500, child: SizedBox()),
            ],
            0,
            900,
          ).length,
          1,
        );
        expect(
          BarisLentur.lebar(
            const [Lentur(dasar: 150, maks: 340, child: SizedBox())],
            12,
            1000,
          ),
          [
            [340.0],
          ],
        );
      },
    );

    test('KisiOtomatis columns', () {
      expect(KisiOtomatis.kolom(1000, 150, 12, 4), 4);
      expect(KisiOtomatis.kolom(1000, 150, 12, 10), 6);
      expect(KisiOtomatis.kolom(100, 150, 12, 4), 1);
      expect(KisiOtomatis.kolom(312, 150, 12, 4), 2);
    });

    testWidgets('BarisLentur and KisiOtomatis lay out without overflow', (
      t,
    ) async {
      for (final w in [390.0, 860.0, 1280.0]) {
        await t.binding.setSurfaceSize(Size(w, 900));
        await t.pumpWidget(
          _app(
            SingleChildScrollView(
              child: Column(
                children: [
                  const BarisLentur(
                    anak: [
                      Lentur(
                        dasar: 520,
                        tumbuh: 999,
                        child: SizedBox(height: 40),
                      ),
                      Lentur(dasar: 360, child: SizedBox(height: 60)),
                    ],
                  ),
                  KisiOtomatis(
                    minLebar: 150,
                    anak: [
                      for (var i = 0; i < 5; i++) const SizedBox(height: 30),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        expect(t.takeException(), isNull);
      }
      await t.binding.setSurfaceSize(null);
    });

    testWidgets('MarginNegatif shortens the box', (t) async {
      await t.pumpWidget(
        _app(
          const Align(
            alignment: Alignment.topLeft,
            child: MarginNegatif(
              atas: 8,
              bawah: 8,
              child: SizedBox(width: 100, height: 44),
            ),
          ),
        ),
      );
      expect(t.getSize(find.byType(MarginNegatif)), const Size(100, 28));
    });
  });

  group('Kecil', () {
    testWidgets('Kartu takes the status line; KotakCentang toggles', (t) async {
      var v = false;
      await t.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, set) => Column(
              children: [
                const Kartu(status: GarisStatus.draf, child: Text('draf')),
                const Kartu(status: GarisStatus.ditutup, child: Text('tutup')),
                const Hitungan(3),
                const JudulBagian('Perlu tindakan', hitungan: 2),
                KotakCentang(
                  nilai: v,
                  onUbah: (x) => set(() => v = x),
                  label: const Text('Saya menyatakan'),
                ),
                const PilihanBulat(
                  nilai: true,
                  onPilih: null,
                  label: Text('A'),
                ),
                const Pesan(Text('Tersimpan')),
                const BarisDaftar(
                  judul: 'Kas/Bank',
                  keterangan: 'Kas',
                  pertama: true,
                ),
                DeretTautan(anak: [TautanTeks('Rekonsiliasi')]),
              ],
            ),
          ),
        ),
      );
      final dek = t.widget<Container>(
        find
            .ancestor(of: find.text('draf'), matching: find.byType(Container))
            .first,
      );
      final shape = (dek.decoration! as ShapeDecoration).shape as GarisBorder;
      expect((shape.gaya, shape.warna), (GayaGaris.putus, c.putus));
      expect((dek.decoration! as ShapeDecoration).color, isNull);

      await t.tap(find.text('Saya menyatakan'));
      await t.pump();
      expect(v, isTrue);
      expect(t.takeException(), isNull);
    });

    testWidgets('every Kartu status paints; IsianTeks needs no Scaffold', (
      t,
    ) async {
      await t.pumpWidget(
        MaterialApp(
          theme: palakatTema(Brightness.light),
          home: Column(
            children: [
              for (final s in GarisStatus.values)
                Kartu(status: s, child: Text(s.name)),
              const IsianTeks(labelSemantik: 'Cari', petunjuk: 'Cari nama'),
            ],
          ),
        ),
      );
      expect(t.takeException(), isNull);
      expect(find.bySemanticsLabel(RegExp(r'^Cari\n')), findsOneWidget);
    });

    testWidgets('IsianTeks with RupiahInputFormatter', (t) async {
      String? nilai;
      await t.pumpWidget(
        _app(
          IsianTeks(
            label: 'Jumlah',
            petunjuk: '0',
            formatters: const [RupiahInputFormatter()],
            onChanged: (s) => nilai = s,
          ),
        ),
      );
      expect(t.getSize(find.byType(TextField)).height, lessThanOrEqualTo(48));
      await t.enterText(find.byType(TextField), '001250000');
      expect(nilai, '1.250.000');
      expect(angkaDari(nilai!), 1250000);
      expect(t.widget<CincinFokus>(find.byType(CincinFokus)).tampil, isTrue);
    });
  });
}
