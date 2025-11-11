import 'package:intl/intl.dart';

// Extensions for thousand-separated formatting on Number and String
// Usage:
//   12345.toThousands();           // "12,345"
//   12345.67.toThousands();        // "12,345.67"
//   "9876543.2".toThousands();    // "9,876,543.2"
//   "not a number".toThousands(); // returns original string

extension ThousandSeparatedNum on num {
  /// Formats the number into a thousand-separated string.
  /// - Uses comma as thousands separator and dot as decimal separator.
  /// - Trims trailing zeros in the fractional part by default.
  /// - Configure [maxFractionDigits] to control how many decimals can appear.
  String toThousands({int maxFractionDigits = 12}) {
    final formatter = NumberFormat(_patternWithMaxFrac(maxFractionDigits));
    return formatter.format(this).replaceAll(",", ".");
  }
  String get toCurrency => "Rp. ${toThousands()}";

}

extension ThousandSeparatedString on String {
  /// Parses the string as a number and formats it with thousands separators.
  /// Returns the original string if parsing fails or if it's empty/whitespace.
  String toThousands({int maxFractionDigits = 12}) {
    final trimmed = trim();
    if (trimmed.isEmpty) return this;

    // Remove commas before parsing to support already-formatted inputs
    final normalized = trimmed.replaceAll(',', '');
    final value = num.tryParse(normalized);
    if (value == null) return this;

    final formatter = NumberFormat(_patternWithMaxFrac(maxFractionDigits));
    return formatter.format(value).replaceAll(",", ".");
  }

  String get toCurrency => "Rp. ${toThousands()}";
}

String _patternWithMaxFrac(int maxFractionDigits) {
  if (maxFractionDigits <= 0) return '#,##0';
  return '#,##0.${'#' * maxFractionDigits}';
}
