import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_prototype/theme/palakat_tema.dart';
import 'package:palakat_prototype/widgets/butir_perhatian.dart';
import 'package:palakat_prototype/widgets/chip_pilihan.dart';
import 'package:palakat_prototype/widgets/garis.dart';
import 'package:palakat_prototype/widgets/isian_alasan.dart';
import 'package:palakat_prototype/widgets/isian_jumlah.dart';
import 'package:palakat_prototype/widgets/kartu_kasus.dart';
import 'package:palakat_prototype/widgets/kartu_persetujuan.dart';
import 'package:palakat_prototype/widgets/kartu_usulan_ai.dart';
import 'package:palakat_prototype/widgets/panel_dokumen.dart';
import 'package:palakat_prototype/widgets/pemilih_mata_anggaran.dart';
import 'package:palakat_prototype/widgets/penghitung_pecahan.dart';
import 'package:palakat_prototype/widgets/rangkaian_koreksi.dart';
import 'package:palakat_prototype/widgets/sakelar.dart';
import 'package:palakat_prototype/widgets/tombol.dart';

const c = PalakatWarna.terang;

/// Phone root: 16 px, line height 1.4, `tinta` (components.md 1.3), inside a
/// router whose `/:stem` pages show "papan …" so links can be followed.
Widget _app(Widget anak, {bool gulir = true, bool kurangiGerak = false}) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (ctx, _) => Scaffold(
          body: MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: kurangiGerak),
            child: DefaultTextStyle(
              style: PalakatText.isi.copyWith(
                height: 1.4,
                leadingDistribution: TextLeadingDistribution.even,
                color: c.tinta,
              ),
              child: gulir ? SingleChildScrollView(child: anak) : anak,
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/:stem',
        builder: (_, s) => Text('papan ${s.pathParameters['stem']}'),
      ),
    ],
  );
  return MaterialApp.router(
    theme: palakatTema(Brightness.light),
    routerConfig: router,
  );
}

TextStyle _gaya(WidgetTester t, String teks) =>
    t.widget<Text>(find.text(teks)).style!;

GarisBorder _garisDi(WidgetTester t, Finder f) {
  final d = t.widget<Container>(f).decoration as ShapeDecoration;
  return d.shape as GarisBorder;
}

void main() {
  group('IsianJumlah', () {
    for (final (u, rp, angka) in [
      (UkuranJumlah.besar, 22.0, 38.0),
      (UkuranJumlah.lebar, 24.0, 40.0),
      (UkuranJumlah.standar, 20.0, 30.0),
      (UkuranJumlah.sedang, 18.0, 26.0),
      (UkuranJumlah.baris, 14.0, 17.0),
    ]) {
      testWidgets('$u: Rp $rp, figure $angka, formats while typing', (t) async {
        final k = TextEditingController();
        addTearDown(k.dispose);
        String? terakhir;
        await t.pumpWidget(
          _app(
            IsianJumlah(
              label: 'Jumlah (Rp)',
              controller: k,
              onChanged: (v) => terakhir = v,
              ukuran: u,
              petunjuk: u == UkuranJumlah.baris ? '—' : '0',
            ),
          ),
        );
        expect(_gaya(t, 'Rp').fontSize, rp);
        expect(_gaya(t, 'Rp').color, c.tinta3);
        final e = t.widget<EditableText>(find.byType(EditableText));
        expect(e.style.fontSize, angka);
        expect(e.style.fontFamily, PalakatText.mono);
        expect(e.style.fontWeight, FontWeight.w500);
        // Empty is a grey hint, not a value.
        expect(k.text, '');
        expect(find.text(u == UkuranJumlah.baris ? '—' : '0'), findsOneWidget);
        await t.enterText(find.byType(TextField), '1250000');
        expect(k.text, '1.250.000');
        expect(terakhir, '1.250.000');
        // Visible label above, except the row form (screen reader only).
        expect(
          find.text('Jumlah (Rp)'),
          u == UkuranJumlah.baris ? findsNothing : findsOneWidget,
        );
        expect(
          t.getSemantics(find.byType(TextField)).label,
          contains('Jumlah (Rp)'),
        );
        // The 44 px target is the field itself (tap and semantics node).
        expect(
          t.getSize(find.byType(TextField)).height,
          greaterThanOrEqualTo(44),
        );
        expect(
          t.getSemantics(find.byType(TextField)).rect.height,
          greaterThanOrEqualTo(44),
        );
        if (u == UkuranJumlah.baris) {
          expect(t.getSize(find.byType(IsianJumlah)).width, 160);
        }
      });
    }

    testWidgets('lebarMaks caps the underlined row', (t) async {
      final k = TextEditingController();
      addTearDown(k.dispose);
      await t.pumpWidget(
        _app(
          IsianJumlah(
            label: 'Wajib untuk Belanja mulai dari',
            controller: k,
            onChanged: (_) {},
            ukuran: UkuranJumlah.sedang,
            lebarMaks: 280,
          ),
        ),
      );
      expect(t.getSize(find.byType(Row).first).width, 280);
    });
  });

  group('IsianAlasan', () {
    testWidgets('label with · wajib, two rows, hint', (t) async {
      final k = TextEditingController();
      addTearDown(k.dispose);
      await t.pumpWidget(
        _app(
          IsianAlasan(
            controller: k,
            onChanged: (_) {},
            contoh: 'Contoh: Mata Anggaran keliru',
          ),
        ),
      );
      expect(find.text('Alasan · wajib', findRichText: true), findsOneWidget);
      expect(find.text('Contoh: Mata Anggaran keliru'), findsOneWidget);
      // rows=2: 2 × 16 × 1.4 + padding 24 + line 2.
      final kotak = find.descendant(
        of: find.byType(IsianAlasan),
        matching: find.byType(Container),
      );
      // The test font rounds each line to whole pixels (22 instead of 22.4).
      expect(t.getSize(kotak.first).height, closeTo(70.8, 1));
      expect(IsianAlasan.terisi('   '), isFalse);
      expect(IsianAlasan.terisi(' nota hilang '), isTrue);
    });

    testWidgets('tapping the label focuses the field', (t) async {
      final k = TextEditingController();
      addTearDown(k.dispose);
      await t.pumpWidget(_app(IsianAlasan(controller: k, onChanged: (_) {})));
      await t.tap(find.text('Alasan · wajib', findRichText: true));
      await t.pump();
      expect(
        t.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
        isTrue,
      );
    });
  });

  group('ChipPilihan', () {
    testWidgets('nothing chosen at first, tap chooses, looks', (t) async {
      String? pilih;
      Widget chip(String? terpilih) => ChipPilihan<String>(
        label: 'Diambil dari peruntukan',
        keterangan: '· uang siapa ini',
        pilihan: const [
          (nilai: 'umum', teks: 'Umum Jemaat'),
          (nilai: 'diakonia', teks: 'Diakonia'),
        ],
        terpilih: terpilih,
        onPilih: (v) => pilih = v,
      );
      await t.pumpWidget(_app(chip(null)));
      expect(
        find.text(
          'Diambil dari peruntukan · uang siapa ini',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(_gaya(t, 'Umum Jemaat').color, c.tinta);
      await t.tap(find.text('Diakonia'));
      expect(pilih, 'diakonia');

      await t.pumpWidget(_app(chip('diakonia')));
      expect(_gaya(t, 'Diakonia').color, c.permukaan);
      expect(_gaya(t, 'Diakonia').fontWeight, FontWeight.w600);
      final chips = find.byType(ChipSatu);
      expect(t.getSize(chips.first).height, 44);
      expect(
        t.getSemantics(find.text('Diakonia')),
        isSemantics(isSelected: true, isButton: true),
      );
      // CSS margin 0 8 8 0: 44 + 8 under the last row.
      expect(t.getSize(find.byType(Wrap)).height, 44);
      expect(
        t.getSize(find.byType(ChipPilihan<String>)).height -
            t.getBottomLeft(find.byType(Wrap)).dy +
            t.getTopLeft(find.byType(ChipPilihan<String>)).dy,
        8,
      );
    });

    testWidgets('filter row: padding 16, no bottom margin', (t) async {
      await t.pumpWidget(
        _app(
          ChipPilihan<int>(
            pilihan: const [(nilai: 1, teks: 'Semua')],
            terpilih: 1,
            onPilih: (_) {},
            padding: 16,
            jarakBaris: 0,
          ),
        ),
      );
      expect(t.getSize(find.byType(ChipPilihan<int>)).height, 44);
    });
  });

  group('PemilihMataAnggaran', () {
    const baris = [
      BarisMataAnggaran('5.01.00.00', 'BELANJA RUTIN', grup: true),
      BarisMataAnggaran('5.01.02.00', 'Listrik, air dan telepon'),
      BarisMataAnggaran('5.02.00.00', 'BELANJA KANTOR', grup: true),
      BarisMataAnggaran('5.02.01.00', 'Alat tulis dan fotokopi'),
    ];

    testWidgets('search keeps groups, pick, tanpa, Bagi link', (t) async {
      BarisMataAnggaran? dipilih;
      var tanpa = 0;
      await t.pumpWidget(
        _app(
          PemilihMataAnggaran(
            pohon: 'Belanja',
            baris: baris,
            onPilih: (r) => dipilih = r,
            onTanpa: () => tanpa++,
            keBagi: 'Bagi',
          ),
          gulir: false,
        ),
      );
      expect(find.text('Pilih Mata Anggaran'), findsOneWidget);
      expect(find.text('Belanja'), findsOneWidget); // tree badge
      expect(find.text('Belanja 5.01.02.00'), findsOneWidget);
      expect(
        find.text('Judul kelompok, tidak dapat dibukukan'),
        findsNWidgets(2),
      );
      final item = find.ancestor(
        of: find.text('Belanja 5.01.02.00'),
        matching: find.byType(Container),
      );
      expect(t.getSize(item.first).height, 60);

      await t.enterText(find.byType(TextField), 'FOTOKOPI');
      await t.pump();
      expect(find.text('Belanja 5.01.02.00'), findsNothing);
      expect(find.text('Belanja 5.02.01.00'), findsOneWidget);
      expect(find.text('BELANJA RUTIN'), findsOneWidget);
      await t.tap(find.text('Alat tulis dan fotokopi'));
      expect(dipilih!.kode, '5.02.01.00');

      await t.tap(find.text('Simpan tanpa Mata Anggaran'));
      expect(tanpa, 1);

      await t.tap(find.text('Bagi ke beberapa Mata Anggaran'));
      await t.pumpAndSettle();
      expect(find.text('papan Bagi'), findsOneWidget);
    });

    testWidgets('keBagi null hides the link', (t) async {
      await t.pumpWidget(
        _app(
          PemilihMataAnggaran(
            pohon: 'Pendapatan',
            baris: const [],
            onPilih: (_) {},
            onTanpa: () {},
            keBagi: null,
          ),
          gulir: false,
        ),
      );
      expect(find.text('Bagi ke beberapa Mata Anggaran'), findsNothing);
    });

    testWidgets('IsianMataAnggaran: not chosen dashed, chosen solid', (
      t,
    ) async {
      await t.pumpWidget(
        _app(IsianMataAnggaran(pohon: 'Belanja', terpilih: null, onTap: () {})),
      );
      expect(
        find.text('Draf boleh disimpan tanpa Mata Anggaran'),
        findsOneWidget,
      );
      expect(find.text('Mata Anggaran belum dipilih'), findsOneWidget);
      final kotak = find.descendant(
        of: find.byType(IsianMataAnggaran),
        matching: find.byType(Container),
      );
      expect(_garisDi(t, kotak).gaya, GayaGaris.putus);
      expect(t.getSize(kotak).height, greaterThanOrEqualTo(56));

      await t.pumpWidget(
        _app(
          IsianMataAnggaran(pohon: 'Belanja', terpilih: baris[1], onTap: () {}),
        ),
      );
      expect(find.text('Belanja 5.01.02.00'), findsOneWidget);
      expect(_garisDi(t, kotak).gaya, GayaGaris.penuh);
      expect(_garisDi(t, kotak).warna, c.garisTegas);
    });
  });

  group('Sakelar', () {
    testWidgets('toggles, thumb moves, switch semantics', (t) async {
      bool? baru;
      Widget s(bool v, {bool nonaktif = false}) => Center(
        child: Sakelar(
          nilai: v,
          onUbah: (x) => baru = x,
          label: 'Wajib pemeriksa kedua',
          nonaktif: nonaktif,
        ),
      );
      await t.pumpWidget(_app(s(false)));
      expect(t.getSize(find.byType(Sakelar)), const Size(56, 44));
      final jempol = find.byType(AnimatedPositioned);
      expect(t.widget<AnimatedPositioned>(jempol).left, 3);
      await t.tap(find.byType(Sakelar));
      expect(baru, isTrue);
      final sem = t.getSemantics(find.byType(Sakelar));
      expect(sem.label, 'Wajib pemeriksa kedua');
      expect(sem, isSemantics(hasToggledState: true, isToggled: false));

      await t.pumpWidget(_app(s(true)));
      await t.pumpAndSettle();
      expect(t.widget<AnimatedPositioned>(jempol).left, 28);

      baru = null;
      await t.pumpWidget(_app(s(true, nonaktif: true)));
      await t.tap(find.byType(Sakelar));
      expect(baru, isNull);
    });
  });

  group('PenghitungPecahan', () {
    testWidgets('counts, never below 0, product', (t) async {
      final hasil = <int>[];
      Widget p(int n) =>
          PenghitungPecahan(pecahan: 100000, lembar: n, onUbah: hasil.add);
      await t.pumpWidget(_app(p(0)));
      expect(find.text('100.000'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
      expect(_gaya(t, '—').color, c.tinta3);
      await t.tap(find.bySemanticsLabel('Kurangi satu lembar Rp100.000'));
      await t.tap(find.bySemanticsLabel('Tambah satu lembar Rp100.000'));
      expect(hasil, [0, 1]);

      await t.pumpWidget(_app(p(3)));
      expect(find.text('Rp300.000'), findsOneWidget);
      expect(_gaya(t, 'Rp300.000').color, c.tinta);
      // Rule (1) + min height 56.
      expect(t.getSize(find.byType(PenghitungPecahan)).height, 57);

      await t.pumpWidget(
        _app(
          PenghitungPecahan(
            pecahan: 1000,
            lembar: 0,
            onUbah: (_) {},
            garisAtas: false,
          ),
        ),
      );
      expect(t.getSize(find.byType(PenghitungPecahan)).height, 56);
    });
  });

  group('ButirPerhatian', () {
    testWidgets('hambatan: bata card, fix button, optional label', (t) async {
      await t.pumpWidget(
        _app(
          ButirPerhatian(
            tingkat: TingkatPerhatian.hambatan,
            judul: 'Bank BNI ··4821 belum direkonsiliasi',
            keterangan: 'Selisih belum dijelaskan Rp515.000',
            labelTingkat: true,
            perbaikan: Tombol(
              'Buka rekonsiliasi',
              onPressed: () {},
              jenis: JenisTombol.tinta,
              ukuran: UkuranTombol.kecil,
            ),
          ),
        ),
      );
      expect(find.text('HAMBATAN'), findsOneWidget);
      expect(_gaya(t, 'HAMBATAN').color, c.bata);
      expect(_gaya(t, 'Bank BNI ··4821 belum direkonsiliasi').fontSize, 15);
      expect(find.text('Buka rekonsiliasi'), findsOneWidget);
      final kartu = find.descendant(
        of: find.byType(ButirPerhatian),
        matching: find.byType(Container),
      );
      expect(_garisDi(t, kartu.first).warna, c.bata);
    });

    testWidgets('perlu tindakan: row, bata first line, link', (t) async {
      await t.pumpWidget(
        _app(
          const Column(
            children: [
              ButirPerhatian(
                tingkat: TingkatPerhatian.perluTindakan,
                judul: 'Oktober 2026 belum ditutup',
                keterangan: '1 hambatan · bulan berikutnya untuk tutup buku',
                warnaKeterangan: PalakatColors.bata,
                pertama: true,
                ke: 'TutupBuku',
              ),
              ButirPerhatian(
                tingkat: TingkatPerhatian.perluTindakan,
                judul: '2 draf belum dibukukan',
                keterangan: 'Perlu tindakan · belum masuk saldo',
              ),
            ],
          ),
        ),
      );
      final pertama = find.byType(ButirPerhatian).first;
      expect(t.getSize(pertama).height, 60);
      expect(t.getSize(find.byType(ButirPerhatian).last).height, 60);
      final ket = _gaya(t, '1 hambatan · bulan berikutnya untuk tutup buku');
      expect((ket.color, ket.fontWeight), (c.bata, FontWeight.w600));
      expect(_gaya(t, 'Perlu tindakan · belum masuk saldo').color, c.tinta3);
      await t.tap(find.text('Oktober 2026 belum ditutup'));
      await t.pumpAndSettle();
      expect(find.text('papan TutupBuku'), findsOneWidget);
    });

    testWidgets('untuk diketahui: heading and plain link', (t) async {
      await t.pumpWidget(
        _app(
          const ButirPerhatian(
            tingkat: TingkatPerhatian.untukDiketahui,
            judul: '2 uang muka dengan sisa belum dipertanggungjawabkan',
            ke: 'Kewajiban',
          ),
        ),
      );
      expect(find.text('Untuk diketahui'), findsOneWidget);
      expect(_gaya(t, 'Untuk diketahui').fontSize, 16);
      await t.tap(
        find.text('2 uang muka dengan sisa belum dipertanggungjawabkan'),
      );
      await t.pumpAndSettle();
      expect(find.text('papan Kewajiban'), findsOneWidget);
    });
  });

  group('PanelDokumen', () {
    testWidgets('every status: thumbnail fill and title colour', (t) async {
      await t.pumpWidget(
        _app(
          PanelDokumen(
            dokumen: [
              for (final s in StatusDokumen.values)
                BarisDokumen(status: s, judul: s.name, keterangan: 'k'),
            ],
          ),
        ),
      );
      for (final s in StatusDokumen.values) {
        expect(
          _gaya(t, s.name).color,
          PanelDokumen.gagal(s) ? c.bata : c.tinta,
          reason: s.name,
        );
      }
      final thumbs = t.widgetList<ThumbDokumen>(find.byType(ThumbDokumen));
      expect(thumbs.length, StatusDokumen.values.length);
      final isi = [
        for (final e in find.byType(ThumbDokumen).evaluate())
          ((t
                      .widget<DecoratedBox>(
                        find.descendant(
                          of: find.byWidget(e.widget),
                          matching: find.byType(DecoratedBox),
                        ),
                      )
                      .decoration)
                  as ShapeDecoration)
              .color,
      ];
      expect(isi, [
        null, // wajib, belum ada
        c.kertas,
        c.bataLembut,
        c.kertas,
        c.lautLembut,
        c.lautLembut,
        c.bataLembut,
        c.bataLembut,
        null, // tidak diperlukan
      ]);
      // Content-box: 34 × 42 inside the 1.5 dashed line, 1 px for the filled.
      expect(t.getSize(find.byType(ThumbDokumen).first), const Size(37, 45));
      expect(t.getSize(find.byType(ThumbDokumen).at(1)), const Size(36, 44));
    });

    testWidgets('Main forms: belum, mengunggah, terlampir', (t) async {
      var lampir = 0;
      await t.pumpWidget(
        _app(LampiranDokumen.belum(onLampirkan: () => lampir++)),
      );
      await t.tap(find.text('Lampirkan dokumen pendukung'));
      expect(lampir, 1);
      expect(t.getSize(find.byType(LampiranDokumen)).height, 56);

      await t.pumpWidget(_app(const LampiranDokumen.mengunggah()));
      expect(find.text('Sedang diunggah…'), findsOneWidget);
      await t.pump(const Duration(milliseconds: 1300));

      await t.pumpWidget(_app(const LampiranDokumen.terlampir()));
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('nota-16-11.jpg · Terlampir'), findsOneWidget);
      expect(find.text('Diunggah, belum diverifikasi'), findsOneWidget);
      expect(t.getSize(find.byType(ThumbDokumen)), const Size(42, 50));
    });
  });

  group('KartuPersetujuan', () {
    testWidgets('belum, sudah, tidak diperlukan', (t) async {
      var catat = 0;
      await t.pumpWidget(_app(KartuPersetujuan.belum(onCatat: () => catat++)));
      expect(find.text('Persetujuan belum dicatat'), findsOneWidget);
      await t.tap(find.text('Catat persetujuan'));
      expect(catat, 1);

      await t.pumpWidget(
        _app(
          const KartuPersetujuan.sudah(
            kepala: 'Persetujuan di luar aplikasi',
            pemberi: 'Pnt. Jefry Wowor',
            jabatan: 'Ketua BPMJ',
            tanggal: '08/11/2026',
            cara: 'notulen rapat',
            dicatatOleh: 'Meiske L.',
            dicatatPada: '16/11/2026 11.20',
          ),
        ),
      );
      expect(find.text('Persetujuan sudah dicatat'), findsOneWidget);
      expect(
        find.text(
          'Pemberi persetujuan: Pnt. Jefry Wowor, Ketua BPMJ',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(find.text('08/11/2026 · cara: notulen rapat'), findsOneWidget);
      expect(
        find.text(
          'Dicatat oleh Meiske L., 16/11/2026 11.20. Pernyataan Bendahara, '
          'bukan persetujuan di dalam aplikasi.',
        ),
        findsOneWidget,
      );
      expect(
        t.widget<GarisLurus>(find.byType(GarisLurus)).gaya,
        GayaGaris.putus,
      );

      await t.pumpWidget(
        _app(const KartuPersetujuan.tidakDiperlukan(aturan: 'transaksi rutin')),
      );
      expect(
        find.text(
          'Tidak diperlukan (aturan: transaksi rutin)',
          findRichText: true,
        ),
        findsOneWidget,
      );
    });
  });

  group('KartuUsulanAI', () {
    testWidgets('mini actions in the card, kurang yakin', (t) async {
      final tekan = <String>[];
      await t.pumpWidget(
        _app(
          KartuUsulanAI(
            label: 'Usulan AI',
            isi: const Text('Belanja 5.01.02.00 Listrik, air dan telepon'),
            kurangYakin: true,
            onPakai: () => tekan.add('pakai'),
            onUbah: () => tekan.add('ubah'),
            onAbaikan: () => tekan.add('abaikan'),
          ),
        ),
      );
      await t.pump(const Duration(milliseconds: 300));
      final saran = t.widget<DefaultTextStyle>(
        find
            .ancestor(
              of: find.text('Belanja 5.01.02.00 Listrik, air dan telepon'),
              matching: find.byType(DefaultTextStyle),
            )
            .first,
      );
      expect(saran.style.fontStyle, FontStyle.italic);
      expect(saran.style.color, c.lautTua);
      expect(find.text('AI kurang yakin, mohon dicek'), findsOneWidget);
      for (final a in ['Pakai', 'Ubah', 'Abaikan']) {
        await t.tap(find.text(a));
        expect(
          t
              .getSize(
                find.ancestor(of: find.text(a), matching: find.byType(Tombol)),
              )
              .height,
          44,
        );
      }
      expect(tekan, ['pakai', 'ubah', 'abaikan']);
    });

    testWidgets('tombolBesar: 46-high equal buttons, no Ubah', (t) async {
      await t.pumpWidget(
        _app(
          KartuUsulanAI(
            label: 'Usulan AI · dari foto',
            isi: const Text('Toko Sinar'),
            onPakai: () {},
            onUbah: null,
            onAbaikan: () {},
            tombolBesar: true,
            bingkai: false,
          ),
        ),
      );
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('Ubah'), findsNothing);
      expect(find.text('AI kurang yakin, mohon dicek'), findsNothing);
      final pakai = find.ancestor(
        of: find.text('Pakai'),
        matching: find.byType(Tombol),
      );
      final abaikan = find.ancestor(
        of: find.text('Abaikan'),
        matching: find.byType(Tombol),
      );
      expect(t.getSize(pakai).height, 46);
      expect(t.getSize(pakai).width, t.getSize(abaikan).width);
    });
  });

  group('KartuKasus', () {
    testWidgets('remainder computed, bold past due, link', (t) async {
      await t.pumpWidget(
        _app(
          const KartuKasus(
            nama: 'Panitia Natal',
            labelPihak: 'Diberikan kepada',
            pihak: 'Sdr. Rivo Mandagi',
            awal: 1500000,
            dipertanggungjawabkan: 850000,
            status: 'Sebagian dipertanggungjawabkan · Lewat jatuh tempo',
            lewatTempo: true,
            ke: 'WebKasus',
          ),
        ),
      );
      expect(find.text('Rp650.000'), findsOneWidget);
      expect(find.text('Diberikan kepada: Sdr. Rivo Mandagi'), findsOneWidget);
      final st = _gaya(t, 'Sebagian dipertanggungjawabkan · Lewat jatuh tempo');
      expect((st.fontWeight, st.color), (FontWeight.w700, c.tinta2));
      await t.tap(find.text('Panitia Natal'));
      await t.pumpAndSettle();
      expect(find.text('papan WebKasus'), findsOneWidget);
    });

    testWidgets('settled: no fill, garis line, not bold', (t) async {
      var buka = 0;
      await t.pumpWidget(
        _app(
          KartuKasus(
            nama: 'Titipan',
            labelPihak: 'Dari',
            pihak: 'Komisi',
            awal: 500000,
            dipertanggungjawabkan: 500000,
            status: 'Selesai',
            lewatTempo: true,
            onTap: () => buka++,
          ),
        ),
      );
      expect(find.text('Rp0'), findsOneWidget);
      expect(_gaya(t, 'Selesai').fontWeight, FontWeight.w400);
      final kotak = find
          .descendant(
            of: find.byType(KartuKasus),
            matching: find.byType(Container),
          )
          .first;
      expect(_garisDi(t, kotak).warna, c.garis);
      expect(
        (t.widget<Container>(kotak).decoration as ShapeDecoration).color,
        isNull,
      );
      await t.tap(find.text('Titipan'));
      expect(buka, 1);
    });
  });

  group('RangkaianKoreksi', () {
    const kartu = [
      KartuRangkaian(
        noBukti: 'BKU-2026-0139',
        lencana: 'Dibalik',
        dibalik: true,
      ),
      KartuRangkaian(
        noBukti: 'BKU-2026-0144 · Pembalikan',
        lencana: 'Dibukukan',
      ),
      KartuRangkaian(
        noBukti: 'BKU-2026-0145 · Transaksi koreksi',
        lencana: 'Dibukukan',
      ),
    ];

    testWidgets('preview chain: three cards, two 2 × 16 links', (t) async {
      await t.pumpWidget(_app(const RangkaianKoreksi(kartu: kartu)));
      expect(find.text('Dibalik'), findsOneWidget);
      expect(find.text('Dibukukan'), findsNWidgets(2));
      final tali = find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == 2 && w.height == 16,
      );
      expect(tali, findsNWidgets(2));
      expect(
        t.getTopLeft(tali.first).dx -
            t.getTopLeft(find.byType(RangkaianKoreksi)).dx,
        28,
      );
    });

    testWidgets('web chain: body lines, 18 links, delayed muncul', (t) async {
      await t.pumpWidget(
        _app(
          const RangkaianKoreksi(
            web: true,
            kartu: [
              KartuRangkaian(
                noBukti: 'BKU-2026-0144',
                lencana: 'Dibukukan',
                judul: 'Pembalikan',
                jumlah: 'Rp750.000',
                keterangan:
                    'Pembalikan dari No. Bukti BKU-2026-0139 · tidak dapat '
                    'diubah atau dibalik',
                tundaMuncul: Duration(milliseconds: 200),
              ),
              KartuRangkaian(
                noBukti: 'BKU-2026-0145',
                lencana: 'Dibukukan',
                judul: 'Transaksi koreksi',
                jumlah: '−Rp750.000',
                tundaMuncul: Duration(milliseconds: 600),
              ),
            ],
          ),
        ),
      );
      double opasitas(String teks) => t
          .widget<Opacity>(
            find.ancestor(of: find.text(teks), matching: find.byType(Opacity)),
          )
          .opacity;
      expect(opasitas('Transaksi koreksi'), 0);
      await t.pump(const Duration(milliseconds: 650));
      await t.pump(const Duration(milliseconds: 400));
      expect(opasitas('Pembalikan'), 1);
      expect(opasitas('Transaksi koreksi'), 1);
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 2 && w.height == 18,
        ),
        findsOneWidget,
      );
      expect(find.text('−Rp750.000'), findsOneWidget);
    });
  });

  testWidgets('reduced motion: entrances end at once', (t) async {
    await t.pumpWidget(
      _app(
        const RangkaianKoreksi(
          kartu: [
            KartuRangkaian(
              noBukti: 'BKU-2026-0145',
              lencana: 'Dibukukan',
              tundaMuncul: Duration(milliseconds: 600),
            ),
          ],
        ),
        kurangiGerak: true,
      ),
    );
    await t.pump();
    expect(
      t
          .widget<Opacity>(
            find.ancestor(
              of: find.text('BKU-2026-0145'),
              matching: find.byType(Opacity),
            ),
          )
          .opacity,
      1,
    );
  });
}
