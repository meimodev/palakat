import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:palakat_shared/core/utils/locale_serializer.dart';

/// **Feature: multi-language-support, Property 1: Locale Round-Trip Consistency**
///
/// *For any* supported locale, serializing it to a string and then deserializing
/// back SHALL produce a locale equal to the original.
///
/// **Validates: Requirements 7.1, 7.2, 7.3**
void main() {
  KiriCheck.verbosity = Verbosity.verbose;

  group('Property 1: Locale Round-Trip Consistency', () {
    // Generator for supported locale indices
    final supportedLocaleIndexArb = integer(
      min: 0,
      max: supportedLocales.length - 1,
    );

    property(
      'serializing then deserializing a supported locale returns the original locale',
      () {
        forAll(supportedLocaleIndexArb, (index) {
          final originalLocale = supportedLocales[index];

          // Serialize to string
          final serialized = LocaleSerializer.serialize(originalLocale);

          // Deserialize back to Locale
          final deserialized = LocaleSerializer.deserialize(serialized);

          // Should equal the original
          expect(
            deserialized.languageCode,
            equals(originalLocale.languageCode),
          );
        });
      },
    );

    property('serialize produces the language code string', () {
      forAll(supportedLocaleIndexArb, (index) {
        final locale = supportedLocales[index];

        final serialized = LocaleSerializer.serialize(locale);

        expect(serialized, equals(locale.languageCode));
      });
    });

    property('deserialize with valid code produces correct locale', () {
      forAll(supportedLocaleIndexArb, (index) {
        final expectedLocale = supportedLocales[index];
        final code = expectedLocale.languageCode;

        final result = LocaleSerializer.deserialize(code);

        expect(result.languageCode, equals(expectedLocale.languageCode));
      });
    });

    property('isSupported returns true for all supported locales', () {
      forAll(supportedLocaleIndexArb, (index) {
        final locale = supportedLocales[index];

        expect(LocaleSerializer.isSupported(locale), isTrue);
      });
    });

    property('fromLanguageCode is equivalent to deserialize', () {
      forAll(supportedLocaleIndexArb, (index) {
        final locale = supportedLocales[index];
        final code = locale.languageCode;

        final fromDeserialize = LocaleSerializer.deserialize(code);
        final fromLanguageCode = LocaleSerializer.fromLanguageCode(code);

        expect(
          fromLanguageCode.languageCode,
          equals(fromDeserialize.languageCode),
        );
      });
    });
  });

  group('Edge cases', () {
    test('deserialize with unsupported code returns default locale', () {
      final result = LocaleSerializer.deserialize('fr');

      expect(result.languageCode, equals(defaultLocale.languageCode));
    });

    test('deserialize with empty string returns default locale', () {
      final result = LocaleSerializer.deserialize('');

      expect(result.languageCode, equals(defaultLocale.languageCode));
    });

    test('isSupported returns false for unsupported locale', () {
      final unsupportedLocale = const Locale('fr');

      expect(LocaleSerializer.isSupported(unsupportedLocale), isFalse);
    });

    test('supportedLocales contains Indonesian and English', () {
      expect(supportedLocales.any((l) => l.languageCode == 'id'), isTrue);
      expect(supportedLocales.any((l) => l.languageCode == 'en'), isTrue);
    });

    test('defaultLocale is Indonesian', () {
      expect(defaultLocale.languageCode, equals('id'));
    });
  });
}
