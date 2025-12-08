import 'dart:ui';

import 'package:intl/intl.dart';

import 'locale_serializer.dart';

/// Locale-aware date formatting utility.
///
/// Provides methods to format dates according to the specified locale,
/// supporting Indonesian (id) and English (en) locales.
class DateFormatter {
  /// Private constructor to prevent instantiation
  DateFormatter._();

  /// Format date in short format (e.g., "07/12/2025" for en, "07/12/2025" for id)
  ///
  /// Uses locale-specific date format patterns.
  static String formatShort(DateTime date, Locale locale) {
    final effectiveLocale = _getEffectiveLocale(locale);
    return DateFormat.yMd(effectiveLocale.languageCode).format(date);
  }

  /// Format date in medium format (e.g., "Dec 7, 2025" for en, "7 Des 2025" for id)
  ///
  /// Uses locale-specific date format patterns.
  static String formatMedium(DateTime date, Locale locale) {
    final effectiveLocale = _getEffectiveLocale(locale);
    return DateFormat.yMMMd(effectiveLocale.languageCode).format(date);
  }

  /// Format date in long format (e.g., "December 7, 2025" for en, "7 Desember 2025" for id)
  ///
  /// Uses locale-specific date format patterns.
  static String formatLong(DateTime date, Locale locale) {
    final effectiveLocale = _getEffectiveLocale(locale);
    return DateFormat.yMMMMd(effectiveLocale.languageCode).format(date);
  }

  /// Format date with day name (e.g., "Sunday, December 7, 2025" for en)
  ///
  /// Uses locale-specific date format patterns.
  static String formatWithDayName(DateTime date, Locale locale) {
    final effectiveLocale = _getEffectiveLocale(locale);
    return DateFormat.yMMMMEEEEd(effectiveLocale.languageCode).format(date);
  }

  /// Format time only (e.g., "14:30" or "2:30 PM" depending on locale)
  ///
  /// Uses locale-specific time format patterns.
  static String formatTime(DateTime date, Locale locale) {
    final effectiveLocale = _getEffectiveLocale(locale);
    return DateFormat.Hm(effectiveLocale.languageCode).format(date);
  }

  /// Format date and time (e.g., "Dec 7, 2025, 14:30")
  ///
  /// Uses locale-specific date and time format patterns.
  static String formatDateTime(DateTime date, Locale locale) {
    final effectiveLocale = _getEffectiveLocale(locale);
    return DateFormat.yMMMd(effectiveLocale.languageCode).add_Hm().format(date);
  }

  /// Format with custom pattern while respecting locale
  ///
  /// The [pattern] follows ICU date format patterns.
  static String formatCustom(DateTime date, String pattern, Locale locale) {
    final effectiveLocale = _getEffectiveLocale(locale);
    return DateFormat(pattern, effectiveLocale.languageCode).format(date);
  }

  /// Get the effective locale, falling back to default if not supported
  static Locale _getEffectiveLocale(Locale locale) {
    return LocaleSerializer.isSupported(locale) ? locale : defaultLocale;
  }
}
