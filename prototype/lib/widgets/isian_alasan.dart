import 'package:flutter/material.dart';

import '../theme/palakat_tema.dart';
import 'kecil.dart';

/// The required reason: "Alasan" 14 `tinta2` + " · wajib" 700 `tinta`,
/// margin-bottom 6, then a two-row textarea (padding 12 14, radius 12, 1 px
/// `garisTegas`, `permukaan`, font inherited, hint `tinta3`).
/// [baris] 3 is the "Penjelasan" variant of Koreksi. Tapping the label
/// focuses the field (the board's `<label for>`).
class IsianAlasan extends StatefulWidget {
  const IsianAlasan({
    super.key,
    required this.controller,
    required this.onChanged,
    this.contoh,
    this.label = 'Alasan',
    this.baris = 2,
    this.focusNode,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  /// Hint, e.g. 'Contoh: Mata Anggaran keliru'.
  final String? contoh;
  final String label;
  final int baris;
  final FocusNode? focusNode;

  /// Blank is refused; there is no minimum length.
  static bool terisi(String t) => t.trim().isNotEmpty;

  @override
  State<IsianAlasan> createState() => _IsianAlasanState();
}

class _IsianAlasanState extends State<IsianAlasan> {
  FocusNode? _fokusSendiri;
  FocusNode get _fokus => widget.focusNode ?? (_fokusSendiri ??= FocusNode());

  @override
  void dispose() {
    _fokusSendiri?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final w = widget;
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _fokus.requestFocus,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${w.label} '),
                  TextSpan(
                    text: '· wajib',
                    style: TextStyle(
                      color: c.tinta,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ),
          const SizedBox(height: 6),
          IsianTeks(
            controller: w.controller,
            onChanged: w.onChanged,
            focusNode: _fokus,
            petunjuk: w.contoh,
            baris: w.baris,
            // rows="2": the height is the rows, not IsianTeks' 96 minimum.
            minTinggi: 0,
          ),
        ],
      ),
    );
  }
}
