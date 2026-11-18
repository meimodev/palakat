import 'package:flutter/material.dart';

import '../theme/palakat_tema.dart';
import 'kecil.dart';

/// The required reason: "Alasan" 14 `tinta2` + " · wajib" 700 `tinta`,
/// margin-bottom 6, then a two-row textarea (padding 12 14, radius 12, 1 px
/// `garisTegas`, `permukaan`, font inherited, hint `tinta3`).
/// [baris] 3 is the "Penjelasan" variant of Koreksi.
class IsianAlasan extends StatelessWidget {
  const IsianAlasan({
    super.key,
    required this.controller,
    required this.onChanged,
    this.contoh,
    this.label = 'Alasan',
    this.baris = 2,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  /// Hint, e.g. 'Contoh: Mata Anggaran keliru'.
  final String? contoh;
  final String label;
  final int baris;

  /// Blank is refused; there is no minimum length.
  static bool terisi(String t) => t.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '$label '),
                TextSpan(
                  text: '· wajib',
                  style: TextStyle(color: c.tinta, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
          const SizedBox(height: 6),
          IsianTeks(
            controller: controller,
            onChanged: onChanged,
            petunjuk: contoh,
            baris: baris,
            // rows="2": the height is the rows, not IsianTeks' 96 minimum.
            minTinggi: 0,
          ),
        ],
      ),
    );
  }
}
