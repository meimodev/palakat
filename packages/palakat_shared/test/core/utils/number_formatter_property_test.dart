import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:palakat_shared/core/utils/locale_serializer.dart';
import 'package:palakat_shared/core/utils/number_formatter.dart';

/// **Feature: multi-language-support, Property 5: Number Formatting Locale Awareness**
///
/// *For any* numeric value and any supported locale, formatting the number
/// SHALL produce output consistent with that locale's conventions.
///
/// **Validates: Requirements 3.5**
void main() {
  KiriCheck.verbosity = Verbosity.verbose;

  group('Property 5: Number Formatting Locale Awareness', () {
    // Generator for supported locale indices
    final supportedLocaleIndexArb = integer(
      min: 0,
      max: supportedLocales.length - 1,
    );

    // Generator for reasonable positive numbers
    final positiveNumberArb = integer(min: 0, max: 999999999);

    // Generator for decimal numbers (using integers divided by 100)
    final decimalNumberArb = integer(
      min: 0,
      max: 99999999,
    ).map((value) => value / 100.0);

    // Generator for percentage values (0.0 to 1.0)
    final percentageArb = integer(
      min: 0,
      max: 100,
    ).map((value) => value / 100.0);

    property(
      'formatNumber produces different grouping separators for different locales',
      () {
        // Use a large number that will have grouping separators
        forAll(integer(min: 1000, max: 999999999), (value) {
          final indonesianLocale = const Locale('id');
          final englishLocale = const Locale('en');

          final indonesianResult = NumberFormatter.formatNumber(
            value,
            indonesianLocale,
          );
          final englishResult = NumberFormatter.formatNumber(
            value,
            englishLocale,
          );

          // Both should produce non-empty strings
          expect(indonesianResult.isNotEmpty, isTrue);
          expect(englishResult.isNotEmpty, isTrue);

          // Indonesian uses '.' as grouping separator, English uses ','
          // For numbers >= 1000, there should be separators
          if (value >= 1000) {
            // Indonesian format should contain '.'
            expect(indonesianResult.contains('.'), isTrue);
            // English format should contain ','
            expect(englishResult.contains(','), isTrue);
          }
        });
      },
    );

    property('formatDecimal produces locale-specific decimal separators', () {
      forAll(decimalNumberArb, (value) {
        final indonesianLocale = const Locale('id');
        final englishLocale = const Locale('en');

        final indonesianResult = NumberFormatter.formatDecimal(
          value,
          indonesianLocale,
        );
        final englishResult = NumberFormatter.formatDecimal(
          value,
          englishLocale,
        );

        // Both should produce non-empty strings
        expect(indonesianResult.isNotEmpty, isTrue);
        expect(englishResult.isNotEmpty, isTrue);

        // Indonesian uses ',' as decimal separator
        // English uses '.' as decimal separator
        expect(indonesianResult.contains(','), isTrue);
        expect(englishResult.contains('.'), isTrue);
      });
    });

    property('formatRupiah always produces Indonesian currency format', () {
      forAll(positiveNumberArb, (value) {
        final result = NumberFormatter.formatRupiah(value);

        // Should start with Rp
        expect(result.startsWith('Rp'), isTrue);

        // Should not have decimal places (Indonesian Rupiah convention)
        // The result should be non-empty
        expect(result.isNotEmpty, isTrue);
      });
    });

    property('formatCurrency produces locale-specific currency symbols', () {
      forAll(positiveNumberArb, (value) {
        final indonesianLocale = const Locale('id');
        final englishLocale = const Locale('en');

        final indonesianResult = NumberFormatter.formatCurrency(
          value,
          indonesianLocale,
        );
        final englishResult = NumberFormatter.formatCurrency(
          value,
          englishLocale,
        );

        // Indonesian should use Rp
        expect(indonesianResult.contains('Rp'), isTrue);

        // English should use $
        expect(englishResult.contains(r'$'), isTrue);
      });
    });

    property('formatPercent produces valid percentage output', () {
      forAll(combine2(percentageArb, supportedLocaleIndexArb), (pair) {
        final value = pair.$1;
        final locale = supportedLocales[pair.$2];

        final result = NumberFormatter.formatPercent(value, locale);

        // Should contain % symbol
        expect(result.contains('%'), isTrue);

        // Should be non-empty
        expect(result.isNotEmpty, isTrue);
      });
    });

    property(
      'formatCompact produces shorter output than formatNumber for large values',
      () {
        // Use large numbers where compact format makes a difference
        forAll(
          combine2(
            integer(min: 10000, max: 999999999),
            supportedLocaleIndexArb,
          ),
          (pair) {
            final value = pair.$1;
            final locale = supportedLocales[pair.$2];

            final compactResult = NumberFormatter.formatCompact(value, locale);
            final fullResult = NumberFormatter.formatNumber(value, locale);

            // Compact format should generally be shorter or equal
            expect(compactResult.length <= fullResult.length, isTrue);

            // Both should be non-empty
            expect(compactResult.isNotEmpty, isTrue);
            expect(fullResult.isNotEmpty, isTrue);
          },
        );
      },
    );

    property(
      'all format methods produce non-empty output for any supported locale',
      () {
        forAll(combine2(positiveNumberArb, supportedLocaleIndexArb), (pair) {
          final value = pair.$1;
          final locale = supportedLocales[pair.$2];

          expect(
            NumberFormatter.formatNumber(value, locale).isNotEmpty,
            isTrue,
          );
          expect(
            NumberFormatter.formatDecimal(value, locale).isNotEmpty,
            isTrue,
          );
          expect(
            NumberFormatter.formatPercent(value / 100, locale).isNotEmpty,
            isTrue,
          );
          expect(
            NumberFormatter.formatCurrency(value, locale).isNotEmpty,
            isTrue,
          );
          expect(
            NumberFormatter.formatCompact(value, locale).isNotEmpty,
            isTrue,
          );
        });
      },
    );

    property('unsupported locale falls back to default locale formatting', () {
      forAll(positiveNumberArb, (value) {
        final unsupportedLocale = const Locale('fr');

        final unsupportedResult = NumberFormatter.formatNumber(
          value,
          unsupportedLocale,
        );
        final defaultResult = NumberFormatter.formatNumber(
          value,
          defaultLocale,
        );

        // Should fall back to default locale
        expect(unsupportedResult, equals(defaultResult));
      });
    });
  });
}
