import 'package:jiffy/jiffy.dart';

extension StringExtension on String {
  String get toCamelCase {
    return toLowerCase()
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }

  Jiffy? get toJiffy {
    try {
      return Jiffy.parse(this);
    } catch (e) {
      return null;
    }
  }

  // Returns initials from a full name string, e.g., "John Doe" -> "JD"
  String get initials {
    final parts = trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  // Formats a phone number grouping digits as 4-4-rest when length is 12 or 13.
  // Preserves leading '+' when present. Returns original string if formatting not applicable.
  String get formattedPhone {
    if (isEmpty) return this;
    final trimmed = trim();
    final hasPlus = trimmed.startsWith('+');
    final digits = RegExp(
      r'\d+',
    ).allMatches(trimmed).map((m) => m.group(0)!).join();

    if (digits.length == 12 || digits.length == 13) {
      final p1 = digits.substring(0, 4);
      final p2 = digits.substring(4, 8);
      final p3 = digits.substring(8);
      final grouped = '$p1-$p2-$p3';
      return hasPlus ? '+$grouped' : grouped;
    }

    return this;
  }
}
