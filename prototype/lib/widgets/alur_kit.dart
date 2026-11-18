import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/palakat_tema.dart';
import 'chip_pilihan.dart';
import 'kecil.dart';
import 'tata_letak.dart';

/// KitAlur (components.md 2.9): the parts the flow boards draw with the same
/// inline values. Everything else in the kit is an existing widget with fixed
/// arguments (see the table in 2.9).

/// Field and textarea (K6, K6t): label 14 `tinta2`, gap 6, the board's input
/// box; typed text and placeholder 14 (`tinta2` / `tinta3`), hint 13 `tinta3`
/// under the input. [baris] 3 is the textarea (no placeholder, no hint).
class IsianAlur extends StatelessWidget {
  const IsianAlur({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
    this.petunjuk,
    this.keterangan,
    this.baris = 1,
    this.keyboard = TextInputType.text,
    this.formatter = const [],
    this.hanyaBaca = false,
  });

  /// Verbatim: 'Nomor ponsel', 'Alasan · wajib'.
  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  /// Placeholder: '08…', 'hh/bb/tttt'.
  final String? petunjuk;

  /// Hint under the input: 'Contoh: 081234567890'.
  final String? keterangan;

  /// 1 = input, 3 = textarea.
  final int baris;
  final TextInputType keyboard;
  final List<TextInputFormatter> formatter;
  final bool hanyaBaca;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final area = baris > 1;
    final isian = IsianTeks(
      controller: controller,
      label: label,
      jarakLabel: 6,
      petunjuk: area ? null : petunjuk,
      onChanged: onChanged,
      formatters: formatter,
      keyboardType: area ? TextInputType.multiline : keyboard,
      // The board's input{font:inherit;color:inherit} takes the label's style.
      gaya: TextStyle(fontSize: 14, color: c.tinta2),
      baris: baris,
      hanyaBaca: hanyaBaca,
    );
    if (area || keterangan == null) return isian;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        isian,
        const SizedBox(height: 6),
        Text(keterangan!, style: TextStyle(fontSize: 13, color: c.tinta3)),
      ],
    );
  }
}

/// Button row (K9): wrap, gap 8 both ways, each button `flex: 1 1 150px;
/// max-width: 340px`; buttons on one line take the tallest one's height
/// (CSS `align-items: stretch`). Children must not hold a LayoutBuilder.
class BarisTombol extends StatelessWidget {
  const BarisTombol({super.key, required this.anak});

  final List<Widget> anak;

  static const _jarak = 8.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, ruang) {
      final lentur = [
        for (final a in anak) Lentur(dasar: 150, maks: 340, child: a),
      ];
      final semua = BarisLentur.lebar(lentur, _jarak, ruang.maxWidth);
      var i = 0;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (n, b) in semua.indexed) ...[
            if (n > 0) const SizedBox(height: _jarak),
            IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (k, w) in b.indexed) ...[
                    if (k > 0) const SizedBox(width: _jarak),
                    SizedBox(width: w, child: anak[i++]),
                  ],
                ],
              ),
            ),
          ],
        ],
      );
    },
  );
}

/// Card head row: space-between, centred, gap 16; title 700 body size that
/// wraps; [ujung] (a LencanaStatus or a mono amount) never shrinks.
class KepalaKartu extends StatelessWidget {
  const KepalaKartu({super.key, required this.judul, this.ujung});

  final String judul;
  final Widget? ujung;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(judul, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      if (ujung != null) ...[const SizedBox(width: 16), ujung!],
    ],
  );
}

/// Info row (key–value): space-between, gap 16, 14 px; label `tinta2`, value
/// right-aligned [berat] `tinta` ([mono] for money and phone numbers).
class BarisInfo extends StatelessWidget {
  const BarisInfo(
    this.label,
    this.nilai, {
    super.key,
    this.mono = false,
    this.berat = FontWeight.w600,
  });

  final String label;
  final String nilai;
  final bool mono;
  final FontWeight berat;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return DefaultTextStyle.merge(
      style: const TextStyle(fontSize: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: c.tinta2)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              nilai,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: c.tinta,
                fontWeight: berat,
                fontFamily: mono ? PalakatText.mono : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Prototype device: goes in AlatPrototipe.alat (4.9), never on the screen.
/// The label "Dilihat sebagai" and one chip per actor.
class DilihatSebagai extends StatelessWidget {
  const DilihatSebagai({
    super.key,
    required this.pilihan,
    required this.terpilih,
    required this.onPilih,
  });

  /// The board's actors, in board order.
  final List<String> pilihan;

  /// The board's `akt`.
  final String terpilih;

  /// The board's `pick`.
  final ValueChanged<String> onPilih;

  @override
  Widget build(BuildContext context) => ChipPilihan<String>(
    label: 'Dilihat sebagai',
    jarakLabel: 6,
    pilihan: [for (final p in pilihan) (nilai: p, teks: p)],
    terpilih: terpilih,
    onPilih: onPilih,
  );
}
