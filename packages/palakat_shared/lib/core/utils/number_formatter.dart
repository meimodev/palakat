import 'dart:ui';

import 'package:intl/intl.dart';

import 'locale_serializer.dart';

/// Locale-aware number formatting utility.
///
/// Provides methods to format numbers and currency according to the specified
/// locale, supporting Indonesian (id) and English (en) locales.
class NumberFormatter {
  /// Private constructor to prevent instantiation
  NumberFormatter._();

  /// Format a number with locale-specific grouping separators.
  ///
  /// For example:
  /// - Indonesian: 1.234.567
  /// - English: 1,234,567
  static String formatNumber(num value, Locale locale) {
    final effectiveLocale = _getEffectiveLocale(locale);
    return NumberFormat.decimalPattern(
      effectiveLocale.languageCode,
    ).format(value);
  }

  /// Format a number with specified decimal places.
  ///
  /// For example with 2 decimal places:
  /// - Indonesian: 1.234,56
  /// - English: 1,234.56
  static String formatDecimal(
    num value,
    Locale locale, {
    int decimalDigits = 2,
  }) {
    final effectiveLocale = _getEffectiveLocale(locale);
    return NumberFormat.decimalPatternDigits(
      locale: effectiveLocale.languageCode,
      decimalDigits: decimalDigits,
    ).format(value);
  }

  /// Format a number as percentage.
  ///
  /// For example:
  /// - Indonesian: 75%
  /// - English: 75%
  static String formatPercent(num value, Locale locale) {
    final effectiveLocale = _getEffectiveLocale(locale);
    return NumberFormat.percentPattern(
      effectiveLocale.languageCode,
    ).format(value);
  }

  /// Format a number as Indonesian Rupiah currency.
  ///
  /// Always uses Indonesian locale for Rupiah formatting.
  /// For example: Rp1.234.567
  static String formatRupiah(num value) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(value);
  }

  /// Format a number as currency with locale-specific formatting.
  ///
  /// For Indonesian locale, uses Rupiah (Rp).
  /// For English locale, uses US Dollar ($).
  static String formatCurrency(num value, Locale locale) {
    final effectiveLocale = _getEffectiveLocale(locale);

    if (effectiveLocale.languageCode == 'id') {
      return formatRupiah(value);
    }

    return NumberFormat.currency(
      locale: effectiveLocale.languageCode,
      symbol: r'$',
      decimalDigits: 2,
    ).format(value);
  }

  /// Format a number in compact form (e.g., 1K, 1M, 1B).
  ///
  /// Uses locale-specific compact patterns.
  static String formatCompact(num value, Locale locale) {
    final effectiveLocale = _getEffectiveLocale(locale);
    return NumberFormat.compact(
      locale: effectiveLocale.languageCode,
    ).format(value);
  }

  /// Format a number in compact currency form.
  ///
  /// For example: Rp1,2 jt (Indonesian) or $1.2M (English)
  static String formatCompactCurrency(num value, Locale locale) {
    final effectiveLocale = _getEffectiveLocale(locale);

    if (effectiveLocale.languageCode == 'id') {
      return NumberFormat.compactCurrency(
        locale: 'id',
        symbol: 'Rp',
        decimalDigits: 0,
      ).format(value);
    }

    return NumberFormat.compactCurrency(
      locale: effectiveLocale.languageCode,
      symbol: r'$',
      decimalDigits: 2,
    ).format(value);
  }

  /// Get the effective locale, falling back to default if not supported
  static Locale _getEffectiveLocale(Locale locale) {
    return LocaleSerializer.isSupported(locale) ? locale : defaultLocale;
  }
}
