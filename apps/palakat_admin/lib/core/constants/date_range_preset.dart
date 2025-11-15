import 'package:flutter/material.dart';

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
    switch (this) {
      case DateRangePreset.allTime:
        return 'All Time';
      case DateRangePreset.today:
        return 'Today';
      case DateRangePreset.thisWeek:
        return 'This Week';
      case DateRangePreset.thisMonth:
        return 'This Month';
      case DateRangePreset.lastWeek:
        return 'Last Week';
      case DateRangePreset.lastMonth:
        return 'Last Month';
      case DateRangePreset.custom:
        return 'Custom Range';
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
          end: today.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
        );

      case DateRangePreset.thisWeek:
        // Start from Monday of current week
        final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7)).subtract(const Duration(seconds: 1));
        return DateTimeRange(start: startOfWeek, end: endOfWeek);

      case DateRangePreset.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
        return DateTimeRange(start: startOfMonth, end: endOfMonth);

      case DateRangePreset.lastWeek:
        // Start from Monday of last week
        final startOfThisWeek = today.subtract(Duration(days: now.weekday - 1));
        final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
        final endOfLastWeek = startOfThisWeek.subtract(const Duration(seconds: 1));
        return DateTimeRange(start: startOfLastWeek, end: endOfLastWeek);

      case DateRangePreset.lastMonth:
        final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
        final endOfLastMonth = DateTime(now.year, now.month, 1).subtract(const Duration(seconds: 1));
        return DateTimeRange(start: startOfLastMonth, end: endOfLastMonth);

      case DateRangePreset.custom:
        // Custom range should be handled separately
        return null;
    }
  }
}
