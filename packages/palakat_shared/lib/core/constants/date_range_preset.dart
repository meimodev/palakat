import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:palakat_shared/l10n/generated/app_localizations.dart';

AppLocalizations _l10n() {
  final localeName = intl.Intl.getCurrentLocale();
  final languageCode = localeName.split(RegExp('[_-]')).first;
  return lookupAppLocalizations(
    Locale(languageCode.isEmpty ? 'en' : languageCode),
  );
}

/// Preset date range options for filtering
enum DateRangePreset {
  allTime,
  today,
  thisWeek,
  thisMonth,
  lastWeek,
  lastMonth,
  custom;

  String get displayName {
    final l10n = _l10n();
    switch (this) {
      case DateRangePreset.allTime:
        return l10n.dateRangePreset_allTime;
      case DateRangePreset.today:
        return l10n.dateRangePreset_today;
      case DateRangePreset.thisWeek:
        return l10n.dateRangePreset_thisWeek;
      case DateRangePreset.thisMonth:
        return l10n.dateRangePreset_thisMonth;
      case DateRangePreset.lastWeek:
        return l10n.dateRangePreset_lastWeek;
      case DateRangePreset.lastMonth:
        return l10n.dateRangePreset_lastMonth;
      case DateRangePreset.custom:
        return l10n.dateRangePreset_custom;
    }
  }

  /// Calculates the DateTimeRange for this preset
  /// Returns null for allTime and custom presets
  DateTimeRange? getDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (this) {
      case DateRangePreset.allTime:
        return null;

      case DateRangePreset.today:
        return DateTimeRange(
          start: today,
          end: today
              .add(const Duration(days: 1))
              .subtract(const Duration(seconds: 1)),
        );

      case DateRangePreset.thisWeek:
        // Start from Monday of current week
        final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek
            .add(const Duration(days: 7))
            .subtract(const Duration(seconds: 1));
        return DateTimeRange(start: startOfWeek, end: endOfWeek);

      case DateRangePreset.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(
          now.year,
          now.month + 1,
          1,
        ).subtract(const Duration(seconds: 1));
        return DateTimeRange(start: startOfMonth, end: endOfMonth);

      case DateRangePreset.lastWeek:
        // Start from Monday of last week
        final startOfThisWeek = today.subtract(Duration(days: now.weekday - 1));
        final startOfLastWeek = startOfThisWeek.subtract(
          const Duration(days: 7),
        );
        final endOfLastWeek = startOfThisWeek.subtract(
          const Duration(seconds: 1),
        );
        return DateTimeRange(start: startOfLastWeek, end: endOfLastWeek);

      case DateRangePreset.lastMonth:
        final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
        final endOfLastMonth = DateTime(
          now.year,
          now.month,
          1,
        ).subtract(const Duration(seconds: 1));
        return DateTimeRange(start: startOfLastMonth, end: endOfLastMonth);

      case DateRangePreset.custom:
        // Custom range should be handled separately
        return null;
    }
  }
}
