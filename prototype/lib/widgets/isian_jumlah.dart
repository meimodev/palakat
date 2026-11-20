import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/palakat_tema.dart';
import 'input_format.dart';
import 'tekan.dart';

/// The five board sizes of the rupiah field (components.md 3.4).
enum UkuranJumlah { besar, lebar, standar, sedang, baris }

/// Rupiah amount field: label 14 `tinta2` above, then a baseline row on a
/// 2 px `tinta` underline: "Rp" `tinta3` and the mono 500 figure with dot
/// thousands. Empty shows the grey [petunjuk], never a value.
/// [UkuranJumlah.baris] is the row form of Bagi, Awal and Persembahan: no
/// visible label (read by screen readers), 1.5 underline, width 160, right
/// aligned, hint "—".
class IsianJumlah extends StatefulWidget {
  const IsianJumlah({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.ukuran = UkuranJumlah.standar,
    this.petunjuk = '0',
    this.sisakanNol = false,
    this.hanyaBaca = false,
    this.lebarMaks,
    this.warnaAngka,
    this.ukuranRp,
    this.ukuranAngka,
    this.focusNode,
    this.maks = 11,
  });

  /// 'Jumlah (Rp)'.
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final UkuranJumlah ukuran;

  /// '0' or '—' (grey hint, never a value).
  final String petunjuk;

  /// Keep a typed leading zero ("Kas kosong: catat Rp0").
  final bool sisakanNol;
  final bool hanyaBaca;

  /// 280, 300, 420 on web boards (max-width of the underlined row); 150
  /// narrows the [UkuranJumlah.baris] row to Awal's width.
  final double? lebarMaks;

  /// Figure colour; default inherited (`tinta`).
  final Color? warnaAngka;

  /// Board overrides: "Rp" 16 on WebPersembahan, figure 18 on Persembahan.
  final double? ukuranRp, ukuranAngka;
  final FocusNode? focusNode;

  /// Most digits kept: 12 where the board slices to 12 (Main, Catat).
  final int maks;

  @override
  State<IsianJumlah> createState() => _IsianJumlahState();
}

class _IsianJumlahState extends State<IsianJumlah> {
  FocusNode? _fokusSendiri;
  FocusNode get _fokus => widget.focusNode ?? (_fokusSendiri ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _fokus.addListener(_ubah);
  }

  @override
  void didUpdateWidget(IsianJumlah old) {
    super.didUpdateWidget(old);
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _fokusSendiri)?.removeListener(_ubah);
      _fokus.addListener(_ubah);
    }
  }

  void _ubah() => setState(() {});

  @override
  void dispose() {
    _fokus.removeListener(_ubah);
    _fokusSendiri?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final w = widget;
    // (Rp, figure, letter spacing, gap) per size.
    final (rp, angka, jarakHuruf, jarak) = switch (w.ukuran) {
      UkuranJumlah.besar => (22.0, 38.0, -1.0, 6.0),
      UkuranJumlah.lebar => (24.0, 40.0, -1.0, 8.0),
      UkuranJumlah.standar => (20.0, 30.0, 0.0, 6.0),
      UkuranJumlah.sedang => (18.0, 26.0, 0.0, 6.0),
      UkuranJumlah.baris => (14.0, 17.0, 0.0, 4.0),
    };
    final baris = w.ukuran == UkuranJumlah.baris;
    final dasar = DefaultTextStyle.of(context).style;
    final gayaAngka = dasar.copyWith(
      fontFamily: PalakatText.mono,
      fontFeatures: const [FontFeature.tabularFigures()],
      fontSize: w.ukuranAngka ?? angka,
      fontWeight: FontWeight.w500,
      letterSpacing: jarakHuruf,
      color: w.warnaAngka,
    );
    // The board's input is 44 high with its line centred. The TextField
    // itself is the 44 (its tap and semantics node); a collapsed decorator
    // keeps its line at the top of a taller box, so padding centres it.
    final garis = TextPainter(
      text: TextSpan(text: '0', style: gayaAngka),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    );
    final sela = math.max(0.0, (44 - garis.preferredLineHeight) / 2);
    garis.dispose();
    final field = CincinFokus(
      tampil: _fokus.hasFocus,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _fokus.requestFocus,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Material(
            type: MaterialType.transparency,
            child: TextField(
              controller: w.controller,
              focusNode: _fokus,
              onChanged: w.onChanged,
              readOnly: w.hanyaBaca,
              keyboardType: TextInputType.number,
              inputFormatters: [
                RupiahInputFormatter(sisakanNol: w.sisakanNol, maks: w.maks),
              ],
              textAlign: baris ? TextAlign.right : TextAlign.start,
              textAlignVertical: TextAlignVertical.center,
              style: gayaAngka,
              cursorColor: c.laut,
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(vertical: sela),
                border: InputBorder.none,
                hintText: w.petunjuk,
                hintStyle: gayaAngka.copyWith(color: c.tinta3),
              ),
            ),
          ),
        ),
      ),
    );
    Widget barisRp = Container(
      width: baris ? 160 : null,
      padding: EdgeInsets.only(bottom: baris ? 0 : 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: c.tinta, width: baris ? 1.5 : 2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          ExcludeSemantics(
            child: Text(
              'Rp',
              style: TextStyle(
                fontFamily: PalakatText.mono,
                fontSize: w.ukuranRp ?? rp,
                color: c.tinta3,
              ),
            ),
          ),
          SizedBox(width: jarak),
          Expanded(
            child: Semantics(label: w.label, child: field),
          ),
        ],
      ),
    );
    if (w.lebarMaks != null) {
      barisRp = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: w.lebarMaks!),
        child: barisRp,
      );
    }
    if (baris) return barisRp;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // The field carries the label for screen readers.
        ExcludeSemantics(
          child: GestureDetector(
            onTap: _fokus.requestFocus,
            // An inline <label> sits on the parent's line box (strut).
            child: Text(
              w.label,
              strutStyle: StrutStyle.fromTextStyle(dasar),
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ),
        ),
        barisRp,
      ],
    );
  }
}
