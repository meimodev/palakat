import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Centralized date formatting extensions for DateTime
extension DateTimeFormatExtension on DateTime {
  /// Format date as YYYY-MM-DD (used in activities table and search)
  String toStandardDateString() {
    return DateFormat('y-MM-dd').format(this);
  }

  /// Format date as MMM dd, yyyy (used in member DOB and display)
  String toDisplayDateString() {
    return DateFormat('MMM dd, yyyy').format(this);
  }

  /// Format date and time as EEEE, dd MMMM yyyy - HH:mm (used in activity details)
  String toDateTimeString() {
    return DateFormat('EEEE, dd MMMM yyyy - HH:mm').format(this);
  }

  /// Format date as MM/dd/yyyy (alternative short format)
  String toShortDateString() {
    return DateFormat('MM/dd/yyyy').format(this);
  }

  /// Format date with custom pattern
  String toCustomFormat(String pattern) {
    return DateFormat(pattern).format(this);
  }

  /// Get relative time description (e.g., "2 hours ago", "in 3 days")
  String toRelativeTime() {
    final now = DateTime.now();
    final diff = difference(now);
    
    if (diff.isNegative) {
      // Past dates
      final absDiff = diff.abs();
      if (absDiff.inDays > 0) {
        return '${absDiff.inDays} day${absDiff.inDays == 1 ? '' : 's'} ago';
      } else if (absDiff.inHours > 0) {
        return '${absDiff.inHours} hour${absDiff.inHours == 1 ? '' : 's'} ago';
      } else if (absDiff.inMinutes > 0) {
        return '${absDiff.inMinutes} minute${absDiff.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } else {
      // Future dates
      if (diff.inDays > 0) {
        return 'in ${diff.inDays} day${diff.inDays == 1 ? '' : 's'}';
      } else if (diff.inHours > 0) {
        return 'in ${diff.inHours} hour${diff.inHours == 1 ? '' : 's'}';
      } else if (diff.inMinutes > 0) {
        return 'in ${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'}';
      } else {
        return 'Now';
      }
    }
  }

  /// Check if date is in range (used for date filtering)
  bool isInRange(DateTimeRange? range) {
    if (range == null) return true;
    
    final dateOnly = DateUtils.dateOnly(this);
    final startOnly = DateUtils.dateOnly(range.start);
    final endOnly = DateUtils.dateOnly(range.end);
    
    final afterStart = dateOnly.isAtSameMomentAs(startOnly) || dateOnly.isAfter(startOnly);
    final beforeEnd = dateOnly.isAtSameMomentAs(endOnly) || dateOnly.isBefore(endOnly);
    
    return afterStart && beforeEnd;
  }

  /// Get start of day for this date
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Get end of day for this date
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }
}

/// Extension for parsing date strings
extension DateTimeParseExtension on String {
  /// Parse date string safely with fallback
  DateTime? toDateTimeSafely() {
    try {
      return DateTime.parse(this);
    } catch (e) {
      return null;
    }
  }
}
