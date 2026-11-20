import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/boards.dart';
import 'package:palakat_prototype/main.dart';
import 'package:palakat_prototype/mock/format.dart';
import 'package:palakat_prototype/motion/hitung.dart';
import 'package:palakat_prototype/router.dart';
import 'package:palakat_prototype/shell/panel_keadaan.dart';
import 'package:palakat_prototype/shell/panel_samping.dart';
import 'package:palakat_prototype/shell/prototipe_state.dart';
import 'package:palakat_prototype/theme/palakat_tokens.dart';
import 'package:palakat_prototype/widgets/chip_pilihan.dart';
import 'package:palakat_prototype/widgets/isian_jumlah.dart';
import 'package:palakat_prototype/widgets/lembar_bawah.dart';
import 'package:palakat_prototype/widgets/pita_jabatan_kosong.dart';
import 'package:palakat_prototype/widgets/tekan.dart';
import 'package:palakat_prototype/widgets/tombol.dart';
import 'package:palakat_prototype/widgets/tombol_bersyarat.dart';

/// Widget sweeps W1–W7 and X09 of docs/build/rules-checklist.md.
///
/// W1, W2, W3, W4, W7: every board at its frame size, default tweaks and then
/// each other tweak option in turn (the loop of routes_test.dart). W5, W6 and
/// X09 are route checks. Every failure of a test is collected and reported at
/// its end. The Keadaan panel (PanelKeadaan) is left out of every sweep.
///
/// Run one board: fvm flutter test test/rules_test.dart --plain-name '/Main '
void main() {
  for (final p in semuaPapan) {
    _sapu('/${p.stem} default', p, null);
    for (final t in p.tweaks) {
      final pilihan = t.editor == 'boolean'
          ? <Object>[true, false]
          : t.pilihan!.cast<Object>();
      for (final v in pilihan.where((v) => v != t.bawaan)) {
        _sapu('/${p.stem} @tweak ${t.nama}=$v', p, (t.nama, v));
      }
    }
  }

  for (final (stem, rute) in _ruteW5) {
    _w5('/$stem W5 $rute', rute);
  }

  for (final panel in [false, true]) {
    final cara = panel ? 'panel reduce motion' : 'disableAnimations';
    _w6Bukukan('/Main W6 $cara', panel);
    _w6Memuat('/Memuat W6 $cara', panel);
  }

  testWidgets('/Memuat X09 Rangka is announced "Memuat"', (tester) async {
    final keadaan = await _buka(tester, '/Memuat', const Size(390, 844));
    // Rangka's own label comes first; its keterangan text merges in after it
    // ("Memuat\nMemuat saldo dan transaksi…").
    final ada = find
        .bySemanticsLabel(RegExp(r'^Memuat(\n|$)'))
        .evaluate()
        .isNotEmpty;
    await _tutup(tester, keadaan);
    expect(
      ada,
      isTrue,
      reason: 'X09: /Memuat (Sedang memuat) has no Semantics label "Memuat"',
    );
  });
}

// ---------------------------------------------------------------- helpers

/// Opens [rute] in a fresh app at [ukuran]; bounded pumps, not pumpAndSettle:
/// loops (Ulang, titik, denyut, putar) never settle.
Future<PrototypeState> _buka(
  WidgetTester tester,
  String rute,
  Size ukuran, {
  void Function(PrototypeState)? siapkan,
  int pompa = 30,
}) async {
  tester.view.physicalSize = ukuran;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final keadaan = PrototypeState();
  siapkan?.call(keadaan);
  final router = buatRouter();
  await tester.pumpWidget(PalakatPrototipe(router: router, keadaan: keadaan));
  router.go(rute);
  await _pompa(tester, pompa);
  return keadaan;
}

Future<void> _pompa(WidgetTester tester, [int n = 30]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _tutup(WidgetTester tester, PrototypeState keadaan) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 10));
  keadaan.dispose();
}

typedef _Simpul = ({Element e, Element? permukaan, bool layar});

/// Every onstage element (what `find` sees), PanelKeadaan subtrees left out,
/// with its nearest surface (a LembarBawah or a PanelSamping, null = the page)
/// and whether it sits under the board's `<Stem>Screen`.
List<_Simpul> _jelajah(WidgetTester tester, String stem) {
  final hasil = <_Simpul>[];
  final layar = '${stem}Screen';
  void kunjungi(Element e, Element? permukaan, bool diLayar) {
    final w = e.widget;
    if (w is PanelKeadaan) return;
    if (w is LembarBawah || w is PanelSamping) permukaan = e;
    if (w.runtimeType.toString() == layar) diLayar = true;
    hasil.add((e: e, permukaan: permukaan, layar: diLayar));
    e.debugVisitOnstageChildren((c) => kunjungi(c, permukaan, diLayar));
  }

  tester.binding.rootElement!.debugVisitOnstageChildren(
    (c) => kunjungi(c, null, false),
  );
  return hasil;
}

RenderParagraph? _paragraf(Element e) {
  if (e is! RenderObjectElement) return null;
  final r = e.renderObject;
  return r is RenderParagraph ? r : null;
}

String _teks(RenderParagraph p) =>
    p.text.toPlainText(includePlaceholders: false).replaceAll('\u2060', '');

/// Texts of every paragraph in [e]'s subtree.
List<String> _teksDi(Element e) {
  final out = <String>[];
  void k(Element c) {
    final p = _paragraf(c);
    if (p != null) out.add(_teks(p));
    c.debugVisitOnstageChildren(k);
  }

  k(e);
  return out;
}

/// Calls [f] for every text-bearing span of [s] with its effective style.
void _rentang(
  InlineSpan s,
  TextStyle gaya,
  void Function(String, TextStyle) f,
) {
  final g = s.style == null ? gaya : gaya.merge(s.style);
  if (s is! TextSpan) return;
  if ((s.text ?? '').trim().isNotEmpty) f(s.text!, g);
  for (final c in s.children ?? const <InlineSpan>[]) {
    _rentang(c, g, f);
  }
}

/// Opacity 0 above it (a Gerak not yet started) or no area.
bool _tersembunyi(RenderObject r) {
  if (r is RenderBox && (!r.hasSize || r.size.isEmpty)) return true;
  for (RenderObject? a = r; a != null; a = a.parent) {
    if (a is RenderOpacity && a.opacity == 0) return true;
    if (a is RenderAnimatedOpacity && a.opacity.value == 0) return true;
  }
  return false;
}

/// On screen: some of it inside the view and not hidden.
bool _tampak(Element e, Size layar) {
  final r = e.renderObject;
  if (r is! RenderBox || !r.attached || !r.hasSize) return false;
  final kotak = MatrixUtils.transformRect(
    r.getTransformTo(null),
    Offset.zero & r.size,
  );
  final irisan = (Offset.zero & layar).intersect(kotak);
  return irisan.width > 0 && irisan.height > 0 && !_tersembunyi(r);
}

/// Every class declared in lib/ (tests run from the package root).
final _kelasLib = {
  for (final f in Directory('lib').listSync(recursive: true))
    if (f is File && f.path.endsWith('.dart'))
      for (final m in RegExp(
        r'^class (\w+)',
        multiLine: true,
      ).allMatches(f.readAsStringSync()))
        m[1]!,
};

/// The nearest widgets above [e] declared in lib/, to find a failure there.
String _asal(Element e) {
  final nama = <String>[];
  e.visitAncestorElements((a) {
    final t = a.widget.runtimeType.toString().split('<').first;
    if (_kelasLib.contains(t) && !nama.contains(t)) nama.add(t);
    return nama.length < 3;
  });
  return nama.isEmpty ? '' : ' in ${nama.join(' < ')}';
}

String _pendek(String s) {
  final t = s.replaceAll('\n', ' ').trim();
  return t.length > 70 ? '"${t.substring(0, 70)}…"' : '"$t"';
}

// ---------------------------------------------------------------- W1–W4, W7

final _barisLarangan = {
  PalakatColors.putus.toARGB32(): 'putus',
  PalakatColors.garis.toARGB32(): 'garis',
  PalakatColors.garisTegas.toARGB32(): 'garisTegas',
};
final _kosong = RegExp(r'\bnull\b|\bundefined\b|\bNaN\b|Instance of');
final _kode = [
  RegExp(r'^[−+]?Rp[0-9.]+$'),
  RegExp(r'^[A-Z]{3}-\d{4}-\d{4}$'),
  RegExp(r'^\d+(\.\d{2})+$'),
  RegExp(r'^SNP-'),
];

// Section 4 of rules-checklist.md: board breaches built as drawn (4.2) or
// checked and allowed (4.3), allowlisted per rule and per board, exactly.

/// W1 (F06): a code or amount drawn in sans on the board.
const _w1Sans = {
  'Kejadian': {'BKU-2026-0031'},
  'WebKejadian': {'BKU-2026-0031'},
  'AlurUnit': {'Rp0'},
  'WebAlurUnit': {'Rp0'},
  'AlurDana': {'Rp0'},
};

/// W3 (A01): the boards draw these primary buttons together on one surface.
const _w3Utama = {
  'WebBeranda': {'+ Pendapatan', '− Belanja', '+ Persembahan'},
  'TabBeranda': {'+ Pendapatan', '− Belanja', '+ Persembahan'},
  'WebTransaksi': {'+ Catat transaksi', 'Periksa dan bukukan'},
};

/// W4 (P04): the vacant post is the subject of these boards; the strip follows
/// their keadaan, not the switch. Never more than one.
const _w4Pokok = {'JabatanKosong', 'WebJabatanKosong'};

const _awalanLarangan = [
  'Dilihat sebagai',
  'Di prototipe ini',
  'Ulangi contoh',
];

void _sapu(String nama, Papan p, (String, Object)? tweak) {
  testWidgets(nama, (tester) async {
    final adaJk = p.tweaks.any((t) => t.nama == 'jabatanKosong');
    final ukuran = Size(p.lebar, p.tinggi);
    final keadaan = await _buka(
      tester,
      '/${p.stem}',
      ukuran,
      siapkan: (k) {
        if (tweak != null) k.setTweak(p.stem, tweak.$1, tweak.$2);
        // W4: a board without the tweak never shows the strip, even with the
        // global switch on.
        if (!adaJk && tweak == null) k.jabatanKosong = true;
      },
    );
    final gagal = <String>{};
    final galat = tester.takeException();
    if (galat != null) gagal.add('build: $galat');

    final semua = _jelajah(tester, p.stem);

    // W1: text sweep over every RenderParagraph.
    for (final s in semua) {
      final par = _paragraf(s.e);
      if (par == null) continue;
      final isi = _teks(par).trim();
      if (isi.isEmpty) continue;
      if (_kosong.hasMatch(isi)) {
        gagal.add('W1 reads ${_pendek(isi)}${_asal(s.e)}');
      }
      final kode = _kode.any((r) => r.hasMatch(isi));
      _rentang(par.text, const TextStyle(), (t, g) {
        final besar = g.fontSize ?? 14;
        if (besar < 13) gagal.add('W1 ${besar}px: ${_pendek(t)}${_asal(s.e)}');
        final warna = _barisLarangan[g.color?.toARGB32()];
        if (warna != null) {
          gagal.add('W1 colour $warna: ${_pendek(t)}${_asal(s.e)}');
        }
        if (kode &&
            g.fontFamily != PalakatText.mono &&
            !(_w1Sans[p.stem]?.contains(isi) ?? false)) {
          gagal.add(
            'W1 not mono (${g.fontFamily}): ${_pendek(isi)}${_asal(s.e)}',
          );
        }
      });
    }

    // W2: every pressable target at least 44 × 44.
    final w2 = await iOSTapTargetGuideline.evaluate(tester);
    if (!w2.passed) gagal.addAll(_w2Rinci(tester, semua, w2.reason ?? ''));

    // W3: at most one primary Tombol or TombolBersyarat visible per surface;
    // with a bottom sheet open only the sheet is the topmost surface.
    final utama = <Element?, List<String>>{};
    for (final s in semua) {
      final w = s.e.widget;
      final label = switch (w) {
        Tombol(jenis: JenisTombol.utama) => w.label,
        TombolBersyarat() => w.label,
        _ => null,
      };
      if (label != null && _tampak(s.e, ukuran)) {
        (utama[s.permukaan] ??= []).add(label);
      }
    }
    final lembar = utama.keys.where((k) => k?.widget is LembarBawah).toList();
    for (final k in lembar.isNotEmpty ? lembar : utama.keys) {
      final l = utama[k]!;
      final boleh = _w3Utama[p.stem];
      if (l.length > 1 &&
          !(boleh != null && l.toSet().difference(boleh).isEmpty)) {
        final di = k == null ? 'page' : k.widget.runtimeType.toString();
        gagal.add('W3 ${l.length} primary buttons on the $di: $l');
      }
    }

    // W4: PitaJabatanKosong follows the switch on boards with the tweak.
    final pita = semua.where((s) => s.e.widget is PitaJabatanKosong).length;
    final harus = adaJk && keadaan.jabatanKosong ? 1 : 0;
    if (_w4Pokok.contains(p.stem) ? pita > 1 : pita != harus) {
      gagal.add(
        'W4 $pita PitaJabatanKosong, expected $harus '
        '(tweak ${adaJk ? 'present' : 'absent'}, '
        'switch ${keadaan.jabatanKosong ? 'on' : 'off'})',
      );
    }

    // W7: no prototype device inside <Stem>Screen.
    if (!semua.any((s) => s.layar)) gagal.add('W7 no ${p.stem}Screen onstage');
    for (final s in semua.where((s) => s.layar)) {
      final par = _paragraf(s.e);
      if (par != null) {
        final isi = _teks(par).trim();
        for (final a in _awalanLarangan) {
          if (isi.startsWith(a)) gagal.add('W7 text ${_pendek(isi)}');
        }
      }
      final w = s.e.widget;
      final label = switch (w) {
        Tekan() => w.label,
        Tombol() => w.label,
        TombolBersyarat() => w.label,
        _ => null,
      };
      if (w is Tekan || w is Tombol || w is TekanAria || w is TombolBersyarat) {
        for (final t in [?label, ..._teksDi(s.e)]) {
          if (t.trim().startsWith('Contoh:')) {
            gagal.add('W7 ${w.runtimeType} labelled ${_pendek(t)}');
          }
        }
      }
    }

    await _tutup(tester, keadaan);
    if (gagal.isNotEmpty) fail(gagal.join('\n'));
  });
}

/// The guideline names a failing node by its local rect only: name each one
/// by its label and the texts drawn inside it, so it can be found in lib/.
List<String> _w2Rinci(WidgetTester tester, List<_Simpul> semua, String alasan) {
  final ukuran = RegExp(r'found Size\(([\d.]+), ([\d.]+)\)')
      .allMatches(alasan)
      .map((m) => '${m[1]}×${m[2]}')
      .toSet();
  final teks = [
    for (final s in semua)
      if (_paragraf(s.e) case final p? when p.attached && p.hasSize)
        (
          MatrixUtils.transformRect(
            p.getTransformTo(null),
            Offset.zero & p.size,
          ).center,
          _teks(p).trim(),
        ),
  ];
  final hasil = <String>[];
  void kunjungi(SemanticsNode n) {
    final d = n.getSemanticsData();
    var r = n.rect;
    final lokal = r.size;
    for (SemanticsNode? x = n; x != null; x = x.parent) {
      if (x.transform != null) r = MatrixUtils.transformRect(x.transform!, r);
    }
    final kunci =
        '${lokal.width.toStringAsFixed(1)}×${lokal.height.toStringAsFixed(1)}';
    if ((d.hasAction(SemanticsAction.tap) ||
            d.hasAction(SemanticsAction.longPress)) &&
        ukuran.contains(kunci)) {
      final isi = [
        if (d.label.isNotEmpty) 'label "${d.label}"',
        for (final (c, t) in teks)
          if (r.contains(c) && t.isNotEmpty) _pendek(t),
      ];
      hasil.add(
        'W2 $kunci target at (${r.left.round()}, ${r.top.round()}): '
        '${isi.isEmpty ? '(no text)' : isi.join(' ')}',
      );
    }
    n.visitChildren((c) {
      kunjungi(c);
      return true;
    });
  }

  final akar =
      tester.binding.renderViews.first.owner?.semanticsOwner?.rootSemanticsNode;
  if (akar != null) kunjungi(akar);
  return hasil.isEmpty ? ['W2 ${alasan.trim()}'] : hasil;
}

// ---------------------------------------------------------------- W5

const _ruteW5 = [
  ('Main', '/Main/catat'),
  ('WebCatat', '/WebCatat'),
  ('TabCatat', '/TabCatat'),
  ('KasusBaru', '/KasusBaru'),
  ('WebKasusBaru', '/WebKasusBaru'),
  ('AlihPeruntukan', '/AlihPeruntukan'),
  ('WebAlihPeruntukan', '/WebAlihPeruntukan'),
];

final _bidang = RegExp(r'Kas/Bank|peruntukan|Lingkup', caseSensitive: false);
final _kodeMa = RegExp(r'\d+\.\d{2}');
const _maKosong = 'Mata Anggaran belum dipilih';

/// The four classification fields as they stand: label → selected?
/// Chip groups by label; 'Mata Anggaran' by an inline row (a Tekan with
/// `dipilih` holding a No. MA) or by the "Mata Anggaran belum dipilih" field.
({Map<String, bool> pilih, Map<String, VoidCallback> pilihPertama}) _bidangW5(
  WidgetTester tester,
  String stem,
  bool maKosongAwal,
) {
  final pilih = <String, bool>{};
  final pertama = <String, VoidCallback>{};
  final semua = _jelajah(tester, stem).where((s) => s.layar).toList();
  for (final s in semua) {
    final w = s.e.widget;
    if (w is! ChipPilihan) continue;
    final label = (w.label ?? '').replaceAll('\u2060', '');
    if (!_bidang.hasMatch(label)) continue;
    var kunci = label;
    for (var i = 2; pilih.containsKey(kunci); i++) {
      kunci = '$label #$i';
    }
    pilih[kunci] = (w as dynamic).terpilih != null;
    VoidCallback? tap;
    void cari(Element c) {
      final cw = c.widget;
      if (tap == null && cw is ChipSatu && cw.onTap != null) tap = cw.onTap;
      c.visitChildren(cari);
    }

    cari(s.e);
    if (tap != null) pertama[kunci] = tap!;
  }
  final ma = [
    for (final s in semua)
      if (s.e.widget case Tekan(dipilih: final bool d)
          when _teksDi(s.e).any(_kodeMa.hasMatch))
        (d, (s.e.widget as Tekan).onTap),
  ];
  if (ma.isNotEmpty) {
    pilih['Mata Anggaran'] = ma.any((m) => m.$1);
    final t = ma.firstWhere((m) => m.$2 != null, orElse: () => ma.first).$2;
    if (t != null) pertama['Mata Anggaran'] = t;
  } else if (maKosongAwal) {
    pilih['Mata Anggaran'] = find.text(_maKosong).evaluate().isEmpty;
  }
  return (pilih: pilih, pilihPertama: pertama);
}

void _w5(String nama, String rute) {
  final stem = rute.split('/')[1];
  final p = papanMenurutStem[stem]!;
  testWidgets(nama, (tester) async {
    final ukuran = Size(p.lebar, p.tinggi);
    final gagal = <String>{};

    var keadaan = await _buka(tester, rute, ukuran);
    final maKosong = find.text(_maKosong).evaluate().isNotEmpty;
    final awal = _bidangW5(tester, stem, maKosong);
    if (awal.pilih.isEmpty) {
      gagal.add(
        'W5 no Kas/Bank, peruntukan, Lingkup or Mata Anggaran field on open',
      );
    }
    awal.pilih.forEach((b, v) {
      if (v) gagal.add('W5 "$b" is selected on open');
    });
    await _tutup(tester, keadaan);

    for (final b in awal.pilih.keys) {
      keadaan = await _buka(tester, rute, ukuran);
      final tap = _bidangW5(tester, stem, maKosong).pilihPertama[b];
      if (tap != null) {
        tap();
      } else if (b == 'Mata Anggaran' && maKosong) {
        await _pilihMaLewatPemilih(tester);
      } else {
        gagal.add('W5 "$b" has no option to press on this view');
        await _tutup(tester, keadaan);
        continue;
      }
      await _pompa(tester, 10);
      final sesudah = _bidangW5(tester, stem, maKosong).pilih;
      if (sesudah[b] == false) gagal.add('W5 pressing "$b" did not select it');
      sesudah.forEach((lain, v) {
        if (lain != b && v) gagal.add('W5 selecting "$b" selected "$lain"');
      });
      await _tutup(tester, keadaan);
    }
    if (gagal.isNotEmpty) fail(gagal.join('\n'));
  });
}

// ---------------------------------------------------------------- W6

Future<PrototypeState> _bukaTanpaGerak(
  WidgetTester tester,
  String rute,
  bool panel,
) async {
  if (!panel) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }
  return _buka(
    tester,
    rute,
    const Size(390, 844),
    siapkan: (k) => k.kurangiGerak = panel,
    pompa: 5,
  );
}

Tekan _tekanBerisi(WidgetTester tester, Finder teks) => tester.widget<Tekan>(
  find.ancestor(of: teks.first, matching: find.byType(Tekan)).first,
);

/// Main's Mata Anggaran field opens /Main/mata-anggaran; its first postable
/// row chooses and returns to the form.
Future<void> _pilihMaLewatPemilih(WidgetTester tester) async {
  _tekanBerisi(tester, find.text(_maKosong)).onTap!();
  await _pompa(tester, 5);
  _tekanBerisi(
    tester,
    find.textContaining(RegExp(r'^(Belanja|Pendapatan) \d')),
  ).onTap!();
}

void _w6Bukukan(String nama, bool panel) {
  testWidgets(nama, (tester) async {
    final keadaan = await _bukaTanpaGerak(tester, '/Main/catat', panel);
    final gagal = <String>[];

    await tester.enterText(
      find.descendant(
        of: find.byType(IsianJumlah),
        matching: find.byType(EditableText),
      ),
      '150000',
    );
    await _pompa(tester, 3);
    for (final b in ['Kas/Bank', 'peruntukan', 'Lingkup']) {
      final tap = _bidangW5(
        tester,
        'Main',
        true,
      ).pilihPertama.entries.where((e) => e.key.contains(b)).firstOrNull;
      tap?.value();
      await _pompa(tester, 3);
    }
    await _pilihMaLewatPemilih(tester);
    await _pompa(tester, 5);
    tester
        .widget<Tombol>(find.widgetWithText(Tombol, 'Periksa dan bukukan'))
        .onPressed!();
    await _pompa(tester, 5);

    final bukukan = find.widgetWithText(Tombol, 'Bukukan');
    if (bukukan.evaluate().isEmpty) {
      gagal.add('W6 no Bukukan on /Main/periksa after filling /Main/catat');
    } else {
      tester.widget<Tombol>(bukukan).onPressed!();
      await tester.pump();
      const layar = Size(390, 844);
      final hitung = find.byType(Hitung).evaluate().toList();
      if (hitung.isEmpty) gagal.add('W6 no balance (Hitung) after one pump');
      for (final h in hitung) {
        final akhir = rp((h.widget as Hitung).nilai);
        final ada = find
            .descendant(of: find.byWidget(h.widget), matching: find.text(akhir))
            .evaluate()
            .any((e) => _tampak(e, layar));
        if (!ada) gagal.add('W6 final balance $akhir not shown after one pump');
      }
      final noBukti = find
          .textContaining(RegExp(r'No\. Bukti [A-Z]{3}-\d{4}-\d{4}'))
          .evaluate()
          .any((e) => _tampak(e, layar));
      if (!noBukti) gagal.add('W6 No. Bukti not shown after one pump');
    }
    final galat = tester.takeException();
    if (galat != null) gagal.add('build: $galat');
    await _tutup(tester, keadaan);
    if (gagal.isNotEmpty) fail(gagal.join('\n'));
  });
}

void _w6Memuat(String nama, bool panel) {
  testWidgets(nama, (tester) async {
    final keadaan = await _bukaTanpaGerak(tester, '/Memuat', panel);
    final berjalan = tester.hasRunningAnimations;
    await _tutup(tester, keadaan);
    expect(
      berjalan,
      isFalse,
      reason: 'W6: /Memuat (Sedang memuat) runs animations under reduce motion',
    );
  });
}
