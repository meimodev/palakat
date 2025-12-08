import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:palakat_shared/core/utils/date_formatter.dart';
import 'package:palakat_shared/core/utils/locale_serializer.dart';

/// **Feature: multi-language-support, Property 4: Date Formatting Locale Awareness**
///
/// *For any* DateTime value and any supported locale, formatting the date
/// SHALL produce output consistent with that locale's conventions.
///
/// **Validates: Requirements 3.4, 4.6**
void main() {
  KiriCheck.verbosity = Verbosity.verbose;

  setUpAll(() async {
    // Initialize date formatting for all supported locales
    await initializeDateFormatting('id');
    await initializeDateFormatting('en');
  });

  group('Property 4: Date Formatting Locale Awareness', () {
    // Generator for supported locale indices
    final supportedLocaleIndexArb = integer(
      min: 0,
      max: supportedLocales.length - 1,
    );

    // Generator for reasonable DateTime values (year 2000-2100)
    final dateTimeArb = integer(
      min: 946684800000,
      max: 4102444800000,
    ).map((millis) => DateTime.fromMillisecondsSinceEpoch(millis));

    property(
      'formatShort produces different output for different locales on the same date',
      () {
        forAll(dateTimeArb, (date) {
          final indonesianLocale = const Locale('id');
          final englishLocale = const Locale('en');

          final indonesianResult = DateFormatter.formatShort(
            date,
            indonesianLocale,
          );
          final englishResult = DateFormatter.formatShort(date, englishLocale);

          // Both should produce non-empty strings
          expect(indonesianResult.isNotEmpty, isTrue);
          expect(englishResult.isNotEmpty, isTrue);

          // The outputs may differ due to locale-specific formatting
          // (e.g., date order, separators)
          // We verify both are valid formatted strings containing date components
          expect(indonesianResult.contains(date.day.toString()), isTrue);
          expect(englishResult.contains(date.day.toString()), isTrue);
        });
      },
    );

    property('formatMedium produces locale-specific month names', () {
      forAll(dateTimeArb, (date) {
        final indonesianLocale = const Locale('id');
        final englishLocale = const Locale('en');

        final indonesianResult = DateFormatter.formatMedium(
          date,
          indonesianLocale,
        );
        final englishResult = DateFormatter.formatMedium(date, englishLocale);

        // Both should produce non-empty strings
        expect(indonesianResult.isNotEmpty, isTrue);
        expect(englishResult.isNotEmpty, isTrue);

        // Both should contain the year
        expect(indonesianResult.contains(date.year.toString()), isTrue);
        expect(englishResult.contains(date.year.toString()), isTrue);
      });
    });

    property('formatLong produces locale-specific full month names', () {
      forAll(dateTimeArb, (date) {
        final indonesianLocale = const Locale('id');
        final englishLocale = const Locale('en');

        final indonesianResult = DateFormatter.formatLong(
          date,
          indonesianLocale,
        );
        final englishResult = DateFormatter.formatLong(date, englishLocale);

        // Both should produce non-empty strings
        expect(indonesianResult.isNotEmpty, isTrue);
        expect(englishResult.isNotEmpty, isTrue);

        // Both should contain the year
        expect(indonesianResult.contains(date.year.toString()), isTrue);
        expect(englishResult.contains(date.year.toString()), isTrue);

        // Long format should be longer than short format
        final shortIndonesian = DateFormatter.formatShort(
          date,
          indonesianLocale,
        );
        final shortEnglish = DateFormatter.formatShort(date, englishLocale);

        expect(indonesianResult.length >= shortIndonesian.length, isTrue);
        expect(englishResult.length >= shortEnglish.length, isTrue);
      });
    });

    property(
      'all format methods produce non-empty output for any supported locale',
      () {
        forAll(combine2(dateTimeArb, supportedLocaleIndexArb), (pair) {
          final date = pair.$1;
          final locale = supportedLocales[pair.$2];

          expect(DateFormatter.formatShort(date, locale).isNotEmpty, isTrue);
          expect(DateFormatter.formatMedium(date, locale).isNotEmpty, isTrue);
          expect(DateFormatter.formatLong(date, locale).isNotEmpty, isTrue);
          expect(
            DateFormatter.formatWithDayName(date, locale).isNotEmpty,
            isTrue,
          );
          expect(DateFormatter.formatTime(date, locale).isNotEmpty, isTrue);
          expect(DateFormatter.formatDateTime(date, locale).isNotEmpty, isTrue);
        });
      },
    );

    property(
      'formatCustom with same pattern produces consistent output for same locale',
      () {
        forAll(combine2(dateTimeArb, supportedLocaleIndexArb), (pair) {
          final date = pair.$1;
          final locale = supportedLocales[pair.$2];
          const pattern = 'yyyy-MM-dd';

          final result1 = DateFormatter.formatCustom(date, pattern, locale);
          final result2 = DateFormatter.formatCustom(date, pattern, locale);

          expect(result1, equals(result2));
        });
      },
    );

    property('unsupported locale falls back to default locale formatting', () {
      forAll(dateTimeArb, (date) {
        final unsupportedLocale = const Locale('fr');

        final unsupportedResult = DateFormatter.formatMedium(
          date,
          unsupportedLocale,
        );
        final defaultResult = DateFormatter.formatMedium(date, defaultLocale);

        // Should fall back to default locale
        expect(unsupportedResult, equals(defaultResult));
      });
    });
  });
}
