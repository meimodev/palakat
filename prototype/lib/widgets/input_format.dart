import 'package:flutter/services.dart';

import '../core/format.dart';

/// The boards' amount filter: digits only, leading zeros out (a lone '0'
/// stays with [sisakanNol]), at most [maks] digits, shown with thousand dots.
class RupiahInputFormatter extends TextInputFormatter {
  const RupiahInputFormatter({this.sisakanNol = false, this.maks = 11});

  /// true = the `/^0+(?=\d)/` variant (Kas kosong, Rp0 rows).
  final bool sisakanNol;

  /// 11 on most fields; 12, 10, 5, 4 on the fields components.md 2.3 lists.
  final int maks;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final teks = titik(
      hanyaAngka(newValue.text, max: maks, simpanNol: sisakanNol),
    );
    return TextEditingValue(
      text: teks,
      selection: TextSelection.collapsed(offset: teks.length),
    );
  }
}

/// '1.250.000' → 1250000; '' → null (not filled is not zero).
int? angkaDari(String teks) {
  final d = teks.replaceAll(RegExp(r'\D'), '');
  return d.isEmpty ? null : int.parse(d);
}

/// Date field `hh/bb/tttt`: keeps digits and '/', at most 10 characters.
/// The person types the slashes; [bacaTgl] checks the result.
class TanggalInputFormatter extends TextInputFormatter {
  const TanggalInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var teks = newValue.text.replaceAll(RegExp(r'[^\d/]'), '');
    if (teks.length > 10) teks = teks.substring(0, 10);
    if (teks == newValue.text) return newValue;
    return TextEditingValue(
      text: teks,
      selection: TextSelection.collapsed(offset: teks.length),
    );
  }
}
