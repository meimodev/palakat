import 'package:flutter_test/flutter_test.dart';
import 'package:palakat/features/authentication/data/models/country_code.dart';

void main() {
  group('CountryCode', () {
    test('creates CountryCode with all required fields', () {
      const countryCode = CountryCode(
        code: '+62',
        name: 'Indonesia',
        flag: '🇮🇩',
        dialCode: '62',
      );

      expect(countryCode.code, '+62');
      expect(countryCode.name, 'Indonesia');
      expect(countryCode.flag, '🇮🇩');
      expect(countryCode.dialCode, '62');
    });

    test('toString returns formatted string', () {
      const countryCode = CountryCode(
        code: '+62',
        name: 'Indonesia',
        flag: '🇮🇩',
        dialCode: '62',
      );

      expect(countryCode.toString(), '🇮🇩 Indonesia (+62)');
    });

    test('equality works correctly for same values', () {
      const countryCode1 = CountryCode(
        code: '+62',
        name: 'Indonesia',
        flag: '🇮🇩',
        dialCode: '62',
      );

      const countryCode2 = CountryCode(
        code: '+62',
        name: 'Indonesia',
        flag: '🇮🇩',
        dialCode: '62',
      );

      expect(countryCode1, equals(countryCode2));
    });

    test('equality works correctly for different values', () {
      const countryCode1 = CountryCode(
        code: '+62',
        name: 'Indonesia',
        flag: '🇮🇩',
        dialCode: '62',
      );

      const countryCode2 = CountryCode(
        code: '+60',
        name: 'Malaysia',
        flag: '🇲🇾',
        dialCode: '60',
      );

      expect(countryCode1, isNot(equals(countryCode2)));
    });

    test('hashCode is consistent', () {
      const countryCode = CountryCode(
        code: '+62',
        name: 'Indonesia',
        flag: '🇮🇩',
        dialCode: '62',
      );

      expect(countryCode.hashCode, equals(countryCode.hashCode));
    });
  });

  group('supportedCountryCodes', () {
    test('contains exactly 4 countries', () {
      expect(supportedCountryCodes.length, 4);
    });

    test('contains Indonesia', () {
      final indonesia = supportedCountryCodes.firstWhere(
        (c) => c.code == '+62',
      );

      expect(indonesia.name, 'Indonesia');
      expect(indonesia.flag, '🇮🇩');
      expect(indonesia.dialCode, '62');
    });

    test('contains Malaysia', () {
      final malaysia = supportedCountryCodes.firstWhere((c) => c.code == '+60');

      expect(malaysia.name, 'Malaysia');
      expect(malaysia.flag, '🇲🇾');
      expect(malaysia.dialCode, '60');
    });

    test('contains Singapore', () {
      final singapore = supportedCountryCodes.firstWhere(
        (c) => c.code == '+65',
      );

      expect(singapore.name, 'Singapore');
      expect(singapore.flag, '🇸🇬');
      expect(singapore.dialCode, '65');
    });

    test('contains Philippines', () {
      final philippines = supportedCountryCodes.firstWhere(
        (c) => c.code == '+63',
      );

      expect(philippines.name, 'Philippines');
      expect(philippines.flag, '🇵🇭');
      expect(philippines.dialCode, '63');
    });

    test('all country codes start with +', () {
      for (final country in supportedCountryCodes) {
        expect(country.code.startsWith('+'), isTrue);
      }
    });

    test('all dial codes are numeric', () {
      for (final country in supportedCountryCodes) {
        expect(int.tryParse(country.dialCode), isNotNull);
      }
    });

    test('code and dialCode are consistent', () {
      for (final country in supportedCountryCodes) {
        expect(country.code, '+${country.dialCode}');
      }
    });
  });
}
