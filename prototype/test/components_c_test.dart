import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/motion/kerangka.dart';
import 'package:palakat_prototype/theme/palakat_tema.dart';
import 'package:palakat_prototype/widgets/alur_kit.dart';
import 'package:palakat_prototype/widgets/bertindak_sebagai.dart';
import 'package:palakat_prototype/widgets/garis.dart';
import 'package:palakat_prototype/widgets/kecil.dart';
import 'package:palakat_prototype/widgets/lembar_bawah.dart';
import 'package:palakat_prototype/widgets/pita_jabatan_kosong.dart';
import 'package:palakat_prototype/widgets/pita_laporan.dart';
import 'package:palakat_prototype/widgets/pita_peran.dart';
import 'package:palakat_prototype/widgets/pratinjau_layar_kunci.dart';
import 'package:palakat_prototype/widgets/riwayat_alur.dart';
import 'package:palakat_prototype/widgets/status_simpan.dart';
import 'package:palakat_prototype/widgets/tampilan_nama.dart';
import 'package:palakat_prototype/widgets/tombol.dart';

const c = PalakatWarna.terang;

Widget _app(Widget anak, {double lebar = 390, bool gerakMati = false}) =>
    MaterialApp(
      theme: palakatTema(Brightness.light),
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(390, 844),
          disableAnimations: gerakMati,
        ),
        child: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: lebar, child: anak),
          ),
        ),
      ),
    );

/// The colour of the span holding [teks] inside any RichText.
Color? _warnaTeks(WidgetTester t, String teks) {
  for (final r in t.widgetList<RichText>(find.byType(RichText))) {
    Color? hasil;
    r.text.visitChildren((s) {
      if (s is TextSpan && s.text == teks) {
        hasil = s.style?.color;
        return false;
      }
      return true;
    });
    if (hasil != null) return hasil;
    if (r.text.toPlainText() == teks) return r.text.style?.color;
  }
  return null;
}

Color? _isi(WidgetTester t, Finder f) {
  final d = t.widget<Container>(f).decoration;
  return d is ShapeDecoration ? d.color : (d as BoxDecoration?)?.color;
}

void main() {
  group('PitaLaporan', () {
    testWidgets('sementara: dashed putus, sentence 13 tinta2', (t) async {
      await t.pumpWidget(
        _app(const PitaLaporan.sementara(kalimat: 'Bukan laporan resmi.')),
      );
      expect(find.text('Laporan sementara'), findsOneWidget);
      final box = find.descendant(
        of: find.byType(PitaLaporan),
        matching: find.byType(Container),
      );
      final g =
          (t.widget<Container>(box).decoration! as ShapeDecoration).shape
              as GarisBorder;
      expect((g.gaya, g.warna), (GayaGaris.putus, c.putus));
      final s = t.widget<Text>(find.text('Bukan laporan resmi.')).style!;
      expect((s.fontSize, s.color), (13, c.tinta2));
    });

    testWidgets('resmi: tinta field, diTinta2 line, mono ID, web version', (
      t,
    ) async {
      await t.pumpWidget(
        _app(
          const PitaLaporan.resmi(
            dibekukan: '16/11/2026 11.05',
            idSalinan: 'SNP-2026-10-01',
            versi: '2026.1',
            sebaris: true,
          ),
        ),
      );
      final box = find.descendant(
        of: find.byType(PitaLaporan),
        matching: find.byType(Container),
      );
      expect(_isi(t, box), c.tinta);
      expect(
        find.textContaining(
          'Dibekukan saat tutup buku 16/11/2026 11.05 · ID SNP-2026-10-01 · '
          'Versi Mata Anggaran 2026.1',
          findRichText: true,
        ),
        findsOneWidget,
      );
      final r = t
          .widgetList<RichText>(find.byType(RichText))
          .firstWhere((r) => r.text.toPlainText().contains('SNP'));
      String? keluarga;
      r.text.visitChildren((s) {
        if (s is TextSpan && s.text == 'SNP-2026-10-01') {
          keluarga = s.style?.fontFamily;
        }
        return true;
      });
      expect(keluarga, PalakatText.mono);
      expect(r.text.style!.color, c.diTinta2);
      expect(r.text.style!.fontSize, 14);
    });

    testWidgets('A4 forms', (t) async {
      await t.pumpWidget(
        _app(
          const Column(
            children: [
              PitaLaporan.a4Sementara(kalimat: 'Bukan laporan resmi.'),
              PitaLaporan.terbatas(kalimat: 'File ini dibuat khusus.'),
            ],
          ),
        ),
      );
      expect(
        find.text(
          'Laporan sementara. Bukan laporan resmi.',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'TERBATAS · Akses terbatas: Peruntukan Diakonia. '
          'File ini dibuat khusus.',
          findRichText: true,
        ),
        findsOneWidget,
      );
    });
  });

  testWidgets('PitaPeran: peran line, kunci field, belumPasti dashed', (
    t,
  ) async {
    await t.pumpWidget(
      _app(
        const Column(
          children: [
            PitaPeran(
              jenis: JenisPita.peran,
              judul: 'Akses terbatas: Peruntukan Diakonia',
              kalimat: 'Anda hanya melihat bagian Diakonia.',
            ),
            PitaPeran(
              jenis: JenisPita.kunci,
              judul: 'Belum ada Bendahara aktif',
              kalimat: 'Semua data hanya dapat dilihat.',
              ukuranJudul: 19,
            ),
            PitaPeran(
              jenis: JenisPita.belumPasti,
              judul: 'Sementara.',
              kalimat: 'Aturannya belum diputuskan.',
            ),
          ],
        ),
      ),
    );
    expect(
      t
          .widget<Text>(find.text('Anda hanya melihat bagian Diakonia.'))
          .style!
          .color,
      c.tinta2,
    );
    final kunci = t.widget<Text>(find.text('Belum ada Bendahara aktif')).style!;
    expect((kunci.fontSize, kunci.color), (19, c.permukaan));
    expect(
      DefaultTextStyle.of(
        t.element(find.text('Semua data hanya dapat dilihat.')),
      ).style.color,
      c.diTinta,
    );
    expect(
      find.text('Sementara. Aturannya belum diputuskan.', findRichText: true),
      findsOneWidget,
    );
  });

  group('PitaJabatanKosong', () {
    testWidgets('phone one-liner', (t) async {
      final h = t.ensureSemantics();
      await t.pumpWidget(_app(const PitaJabatanKosong.ponsel()));
      expect(
        find.text(
          'Menjalankan jabatan kosong · Bendahara Jemaat',
          findRichText: true,
        ),
        findsOneWidget,
      );
      final box = find.descendant(
        of: find.byType(PitaJabatanKosong),
        matching: find.byType(Container),
      );
      expect(_isi(t, box), c.tinta);
      expect(t.getSize(box).width, 390);
      expect(
        t.getSemantics(box),
        matchesSemantics(
          isLiveRegion: true,
          label: 'Menjalankan jabatan kosong · Bendahara Jemaat',
        ),
      );
      h.dispose();
    });

    testWidgets('web banner and the Penatua Kolom 2 form', (t) async {
      await t.pumpWidget(
        _app(
          const Column(
            children: [
              PitaJabatanKosong.web(),
              PitaJabatanKosong.web(jabatan: 'Penatua Kolom 2', sejak: null),
            ],
          ),
        ),
      );
      expect(
        find.text(
          'Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 '
          '08.15. Setiap tindakan dicatat sebagai dijalankan oleh Operator '
          'Yanti Sumual.',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Anda menjalankan jabatan kosong Penatua Kolom 2. Setiap',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(
        _warnaTeks(
          t,
          ' Setiap tindakan dicatat sebagai dijalankan oleh Operator Yanti '
          'Sumual.',
        ),
        c.diTinta2,
      );
    });
  });

  group('StatusSimpan', () {
    testWidgets('header text colours', (t) async {
      await t.pumpWidget(
        _app(
          const Column(
            children: [
              StatusSimpan(KeadaanSimpan.belum),
              StatusSimpan(KeadaanSimpan.tersimpan),
              StatusSimpan(KeadaanSimpan.mencoba),
              StatusSimpan(KeadaanSimpan.gagal),
            ],
          ),
        ),
      );
      Color? w(String s) => t.widget<Text>(find.text(s)).style!.color;
      expect(w('Belum tersimpan'), c.tinta3);
      expect(w('Tersimpan'), c.laut);
      expect(w('Mencoba menyimpan lagi…'), c.tinta3);
      expect(w('Gagal disimpan'), c.bata);
      expect(t.widget<Text>(find.text('Tersimpan')).style!.fontSize, 13);
    });

    testWidgets('failure banner: Coba lagi', (t) async {
      var n = 0;
      await t.pumpWidget(_app(PitaGagalSimpan(onCobaLagi: () => n++)));
      await t.pumpAndSettle();
      expect(
        find.text(
          'Gagal disimpan. Isian Anda masih ada di layar ini.',
          findRichText: true,
        ),
        findsOneWidget,
      );
      await t.tap(find.text('Coba lagi'));
      expect(n, 1);
      expect(t.getSize(find.text('Coba lagi')).height, lessThan(44));
    });

    testWidgets('changed by someone else', (t) async {
      var n = 0;
      await t.pumpWidget(
        _app(
          PitaDiubahOrangLain(
            oleh: 'Meiske L.',
            jam: '16/11/2026 10.58',
            onMuat: () => n++,
          ),
        ),
      );
      expect(
        find.text(
          'Sudah diubah sejak Anda membukanya (oleh Meiske L., 16/11/2026 '
          '10.58, dari perangkat lain).',
          findRichText: true,
        ),
        findsOneWidget,
      );
      // align-self: flex-start: the button is as wide as its label.
      expect(t.getSize(find.text('Muat versi terbaru')).width, lessThan(300));
      await t.tap(find.text('Muat versi terbaru'));
      expect(n, 1);
    });
  });

  group('LembarBawah', () {
    Widget lembar(VoidCallback tutup, {bool mati = false}) => _app(
      SizedBox(
        height: 700,
        child: Stack(
          children: [
            LembarBawah(
              judul: 'Catat apa?',
              labelTirai: 'Kembali ke Beranda',
              onTutup: tutup,
              jarak: 0,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              isi: const [Text('Pendapatan')],
            ),
          ],
        ),
      ),
      gerakMati: mati,
    );

    testWidgets('rises in 280 ms, scrim and Escape close it', (t) async {
      var n = 0;
      await t.pumpWidget(lembar(() => n++));
      final awal = t.getTopLeft(find.text('Catat apa?')).dy;
      await t.pump(const Duration(milliseconds: 280));
      final akhir = t.getTopLeft(find.text('Catat apa?')).dy;
      expect(awal, greaterThan(akhir));
      final judul = t.widget<Text>(find.text('Catat apa?')).style!;
      expect((judul.fontSize, judul.fontWeight), (18, FontWeight.w700));
      await t.pumpAndSettle();
      await t.tapAt(const Offset(200, 20));
      expect(n, 1);
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      expect(n, 2);
    });

    testWidgets('handle margin 4 adds to the 14 gap; 14 with gap 0', (t) async {
      Future<double> jarakPegangan(double jarak) async {
        await t.pumpWidget(
          _app(
            SizedBox(
              height: 700,
              child: Stack(
                children: [
                  LembarBawah(
                    judul: 'Judul',
                    onTutup: () {},
                    jarak: jarak,
                    isi: const [Text('Isi')],
                  ),
                ],
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        final pegangan = find.byWidgetPredicate(
          (w) => w is Container && w.constraints?.maxWidth == 40,
        );
        return t.getTopLeft(find.text('Judul')).dy -
            t.getBottomLeft(pegangan).dy;
      }

      expect(await jarakPegangan(14), 4 + 14);
      expect(await jarakPegangan(0), 14);
    });

    testWidgets('no motion under reduced motion', (t) async {
      await t.pumpWidget(lembar(() {}, mati: true));
      final y = t.getTopLeft(find.text('Catat apa?')).dy;
      await t.pumpAndSettle();
      expect(t.getTopLeft(find.text('Catat apa?')).dy, y);
    });

    testWidgets('tampilkanLembarBawah completes with the closing value', (
      t,
    ) async {
      String? hasil;
      await t.pumpWidget(
        _app(
          Builder(
            builder: (ctx) => TextButton(
              onPressed: () async {
                hasil = await tampilkanLembarBawah<String>(
                  ctx,
                  judul: 'Pilih bulan',
                  pegangan: false,
                  masuk: Kerangka.muncul,
                  isi: (ctx) => TextButton(
                    onPressed: () => LembarBawah.tutup(ctx, 'Oktober'),
                    child: const Text('Oktober 2026'),
                  ),
                );
              },
              child: const Text('buka'),
            ),
          ),
        ),
      );
      await t.tap(find.text('buka'));
      await t.pumpAndSettle();
      expect(find.text('Pilih bulan'), findsOneWidget);
      await t.tap(find.text('Oktober 2026'));
      await t.pumpAndSettle();
      expect(hasil, 'Oktober');
      expect(find.text('Pilih bulan'), findsNothing);

      // System Back closes the sheet and leaves the screen in place.
      hasil = 'x';
      await t.tap(find.text('buka'));
      await t.pumpAndSettle();
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(hasil, isNull);
      expect(find.text('Pilih bulan'), findsNothing);
      expect(find.text('buka'), findsOneWidget);
    });
  });

  group('KitAlur', () {
    Widget kotak(double h) => ConstrainedBox(
      constraints: BoxConstraints(minHeight: h),
      child: const ColoredBox(color: Colors.black),
    );

    testWidgets('BarisTombol at 350: 340; 171 + 171; third wraps at 340', (
      t,
    ) async {
      Future<List<Size>> ukur(int n) async {
        await t.pumpWidget(
          _app(
            BarisTombol(
              anak: [
                for (var i = 0; i < n; i++)
                  KeyedSubtree(key: ValueKey(i), child: kotak(52)),
              ],
            ),
            lebar: 350,
          ),
        );
        return [for (var i = 0; i < n; i++) t.getSize(find.byKey(ValueKey(i)))];
      }

      expect((await ukur(1)).single.width, 340);
      expect([for (final s in await ukur(2)) s.width], [171, 171]);
      final tiga = await ukur(3);
      expect(tiga[2].width, 340);
      expect(
        t.getTopLeft(find.byKey(const ValueKey(2))).dy -
            t.getTopLeft(find.byKey(const ValueKey(0))).dy,
        52 + 8,
      );
    });

    testWidgets('a 44 text button beside a 52 button is 52 tall', (t) async {
      await t.pumpWidget(
        _app(
          BarisTombol(
            anak: [
              Tombol('Simpan', onPressed: () {}, jenis: JenisTombol.tinta),
              Tombol(
                'Kembali',
                key: const ValueKey('teks'),
                onPressed: () {},
                jenis: JenisTombol.teks,
                ukuran: UkuranTombol.kecil,
              ),
            ],
          ),
          lebar: 350,
        ),
      );
      expect(t.getSize(find.byKey(const ValueKey('teks'))).height, 52);
      expect(t.getSize(find.byKey(const ValueKey('teks'))).width, 171);
    });

    testWidgets('IsianAlur types at 14 tinta2, hint 13 tinta3', (t) async {
      final k = TextEditingController();
      await t.pumpWidget(
        _app(
          IsianAlur(
            label: 'Nomor ponsel',
            controller: k,
            petunjuk: '08…',
            keterangan: 'Contoh: 081234567890',
          ),
        ),
      );
      await t.enterText(find.byType(TextField), '0812');
      expect(k.text, '0812');
      final s = t.widget<TextField>(find.byType(TextField)).style!;
      expect((s.fontSize, s.color), (14, c.tinta2));
      final h = t.widget<Text>(find.text('Contoh: 081234567890')).style!;
      expect((h.fontSize, h.color), (13, c.tinta3));
      final l = t.widget<Text>(find.text('Nomor ponsel')).style!;
      expect((l.fontSize, l.color), (14, c.tinta2));
      expect(
        t.getTopLeft(find.byType(TextField)).dy -
            t.getBottomLeft(find.text('Nomor ponsel')).dy,
        greaterThanOrEqualTo(6),
      );
    });

    testWidgets('KepalaKartu and BarisInfo', (t) async {
      await t.pumpWidget(
        _app(
          const Column(
            children: [
              KepalaKartu(judul: 'Kel. Wenas-Lasut', ujung: Text('Rp1')),
              BarisInfo('Nomor ponsel', '0812 ···· 5432', mono: true),
            ],
          ),
        ),
      );
      expect(
        t.getTopRight(find.text('Rp1')).dx,
        390,
        reason: 'ujung sits at the right edge',
      );
      final v = t.widget<Text>(find.text('0812 ···· 5432'));
      expect(v.textAlign, TextAlign.right);
      expect(v.style!.fontFamily, PalakatText.mono);
      expect(t.widget<Text>(find.text('Nomor ponsel')).style!.color, c.tinta2);
    });

    testWidgets('DilihatSebagai picks an actor', (t) async {
      String? dipilih;
      await t.pumpWidget(
        _app(
          DilihatSebagai(
            pilihan: const ['Anggota', 'Penatua Kolom 7'],
            terpilih: 'Anggota',
            onPilih: (v) => dipilih = v,
          ),
        ),
      );
      expect(find.text('Dilihat sebagai'), findsOneWidget);
      await t.tap(find.text('Penatua Kolom 7'));
      expect(dipilih, 'Penatua Kolom 7');
    });
  });

  group('RiwayatAlur', () {
    testWidgets('nothing when empty', (t) async {
      await t.pumpWidget(_app(const RiwayatAlur(baris: [])));
      expect(find.text('Riwayat'), findsNothing);
    });

    testWidgets('first rule 3 px under the card edge, rows 13 tinta3', (
      t,
    ) async {
      await t.pumpWidget(
        _app(
          const RiwayatAlur(
            baris: ['16/11/2026 · Diajukan · Novita Wenas', '16/11/2026 · B'],
          ),
        ),
      );
      final kartu = t.getTopLeft(find.byType(Kartu));
      final garis = find.byType(GarisLurus);
      expect(garis, findsNWidgets(2));
      // 1 px card line, then 3 px.
      expect(t.getTopLeft(garis.first).dy - kartu.dy, 1 + 3);
      expect(t.getTopLeft(garis.first).dx - kartu.dx, 1 + 16);
      final s = DefaultTextStyle.of(t.element(find.text('16/11/2026 · B')))
          .style;
      expect((s.fontSize, s.color), (13, c.tinta3));
      // Row: rule 1 + 8 + text + 8, overlapping the next rule by 1.
      final teks = t
          .getSize(find.text('16/11/2026 · Diajukan · Novita Wenas'))
          .height;
      expect(
        t.getTopLeft(garis.last).dy - t.getTopLeft(garis.first).dy,
        1 + 8 + teks + 8 - 1,
      );
    });
  });

  testWidgets('TampilanNama: seven rows, radio semantics, sample', (t) async {
    final h = t.ensureSemantics();
    BentukNama? dipilih;
    await t.pumpWidget(
      _app(
        SingleChildScrollView(
          child: TampilanNama(
            pilihan: BentukNama.keluargaKolom,
            contoh: const {
              BentukNama.keluargaKolom: 'Kel. Wenas-Lasut — Kolom 7',
              BentukNama.kolom: 'Kolom 7',
            },
            contohKalimat: 'Syukur HUT pernikahan: ',
            masihDikenali: 'Kolom 11 hanya punya satu anggota Remaja.',
            onPilih: (b) => dipilih = b,
          ),
        ),
      ),
    );
    for (final b in BentukNama.values) {
      expect(find.text(b.label), findsOneWidget);
    }
    expect(
      find.text(
        'Syukur HUT pernikahan: Kel. Wenas-Lasut — Kolom 7',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Masih mudah dikenali. Kolom 11 hanya punya satu anggota Remaja.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(
      t.getSemantics(find.bySemanticsLabel(RegExp('^Keluarga \\+ Kolom'))),
      matchesSemantics(
        label: 'Keluarga + Kolom\nKel. Wenas-Lasut — Kolom 7',
        isButton: true,
        hasCheckedState: true,
        isChecked: true,
        isInMutuallyExclusiveGroup: true,
        isFocusable: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    await t.tap(find.text('Kolom').first);
    expect(dipilih, BentukNama.kolom);
    h.dispose();
  });

  group('BertindakSebagai', () {
    testWidgets('DaftarJabatan and LabelSebagai', (t) async {
      await t.pumpWidget(
        _app(
          const Column(
            children: [
              DaftarJabatan(
                nama: 'Pnt. Hendrik Rumagit',
                jabatan: ['Penatua Kolom 7', 'Ketua Komisi Diakonia'],
              ),
              LabelSebagai(
                jabatan: 'Penatua Kolom 7',
                rincian: '2 permohonan · 2 peristiwa',
              ),
            ],
          ),
        ),
      );
      expect(find.text('Jabatan Anda'), findsOneWidget);
      expect(find.text('Ketua Komisi Diakonia'), findsOneWidget);
      expect(
        find.text('Sebagai Penatua Kolom 7 · 2 permohonan · 2 peristiwa'),
        findsOneWidget,
      );
    });

    testWidgets('satu: lautLembut notice', (t) async {
      await t.pumpWidget(
        _app(const BertindakSebagai.satu(jabatan: 'Penatua Kolom 7')),
      );
      expect(
        find.text(
          'Anda bertindak sebagai Penatua Kolom 7. Hanya jabatan ini yang '
          'berwenang.',
          findRichText: true,
        ),
        findsOneWidget,
      );
      final box = find.descendant(
        of: find.byType(BertindakSebagai),
        matching: find.byType(Container),
      );
      expect(_isi(t, box), c.lautLembut);
    });

    testWidgets('pilih: asks, never guesses', (t) async {
      String? dipilih;
      await t.pumpWidget(
        _app(
          BertindakSebagai.pilih(
            jabatan: const ['Penatua Kolom 7', 'Ketua Komisi Diakonia'],
            onPilih: (j) => dipilih = j,
          ),
          lebar: 350,
        ),
      );
      expect(
        find.text(
          'Dua jabatan Anda dapat menyetujui ini. Pilih salah satu.',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(dipilih, isNull);
      await t.tap(find.text('Sebagai Ketua Komisi Diakonia'));
      expect(dipilih, 'Ketua Komisi Diakonia');
    });
  });

  testWidgets('PratinjauLayarKunci: module and count, no name', (t) async {
    await t.pumpWidget(
      _app(
        const PratinjauLayarKunci(
          modul: 'Data jemaat',
          jumlah: 1,
          jenis: 'data menunggu verifikasi',
        ),
      ),
    );
    expect(find.text('Palakat'), findsOneWidget);
    expect(
      find.text('Data jemaat: 1 data menunggu verifikasi'),
      findsOneWidget,
    );
    expect(
      t.widget<Text>(find.text('Yang tampil di layar kunci')).style!.color,
      c.tinta3,
    );
  });
}
