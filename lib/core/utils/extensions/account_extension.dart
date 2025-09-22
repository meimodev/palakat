import 'dart:math';
import 'package:palakat/core/models/account.dart';

extension XAccount on Account {
  /// Years component of age based on `dob` and current local date.
  int get ageYears {
    final now = DateTime.now();
    var years = now.year - dob.year;

    // Anniversary this year (handle months with fewer days than dob.day)
    final annivDay = min(dob.day, _daysInMonth(now.year, dob.month));
    final anniversaryThisYear = DateTime(now.year, dob.month, annivDay);
    if (now.isBefore(anniversaryThisYear)) {
      years -= 1;
    }
    return max(0, years);
  }

  /// Months component of age after removing whole years (0-11)
  int get ageMonths {
    final now = DateTime.now();

    // Compute months difference within the current year span
    var months = now.month - dob.month;

    // If birthday day in this month hasn't occurred yet, subtract one month
    final anchorDay = min(dob.day, _daysInMonth(now.year, now.month));
    if (now.day < anchorDay) {
      months -= 1;
    }

    // Normalize into 0..11 after accounting for years already excluded
    months = (months % 12 + 12) % 12;
    return months;
  }

  /// Days component of age after removing whole years and months
  int get ageDays {
    final now = DateTime.now();

    // Day-of-month anchor for this month (cap to month length)
    final anchorDay = min(dob.day, _daysInMonth(now.year, now.month));
    if (now.day >= anchorDay) {
      return now.day - anchorDay;
    }

    // Otherwise, borrow from previous month
    final prevMonthDays = _daysInMonth(
      now.month == 1 ? now.year - 1 : now.year,
      now.month == 1 ? 12 : now.month - 1,
    );
    return prevMonthDays - (anchorDay - now.day);
  }

  /// Convenience: formatted age like "12y 3m 5d"
  String get ageYmdFormatted => "${ageYears}y ${ageMonths}m ${ageDays}d";

  /// Human-friendly long-form age string, e.g. "12 years 3 months 5 days".
  /// Omits zero components; falls back to "0 days" if all are zero (same-day DOB).
  String get ageLongFormatted {
    final parts = <String>[];
    if (ageYears > 0) {
      parts.add("$ageYears ${ageYears == 1 ? 'year' : 'years'}");
    }
    if (ageMonths > 0) {
      parts.add("$ageMonths ${ageMonths == 1 ? 'month' : 'months'}");
    }
    if (ageDays > 0) {
      parts.add("$ageDays ${ageDays == 1 ? 'day' : 'days'}");
    }
    if (parts.isEmpty) return "0 days";
    return parts.join(' ');
  }

  int _daysInMonth(int year, int month) {
    // Dart DateTime: day 0 gives the last day of the previous month
    final lastDay = DateTime(year, month + 1, 0).day;
    return lastDay;
  }
}