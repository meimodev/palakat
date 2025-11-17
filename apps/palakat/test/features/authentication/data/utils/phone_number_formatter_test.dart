import 'package:flutter_test/flutter_test.dart';
import 'package:palakat/features/authentication/data/utils/phone_number_formatter.dart';

void main() {
  group('PhoneNumberFormatter', () {
    group('format()', () {
      test('formats phone number with dashes every 4 digits - 12 digits', () {
        final result = PhoneNumberFormatter.format('081234567890');
        expect(result, '0812-3456-7890');
      });

      test('formats phone number with dashes every 4 digits - 13 digits', () {
        final result = PhoneNumberFormatter.format('0812345678901');
        expect(result, '0812-3456-7890-1');
      });

      test('handles phone number with existing dashes', () {
        final result = PhoneNumberFormatter.format('0812-3456-7890');
        expect(result, '0812-3456-7890');
      });

      test('handles phone number with spaces', () {
        final result = PhoneNumberFormatter.format('0812 3456 7890');
        expect(result, '0812-3456-7890');
      });

      test('handles empty phone number', () {
        final result = PhoneNumberFormatter.format('');
        expect(result, '');
      });

      test('handles short phone number', () {
        final result = PhoneNumberFormatter.format('0812');
        expect(result, '0812');
      });

      test('handles medium length phone number', () {
        final result = PhoneNumberFormatter.format('08123456');
        expect(result, '0812-3456');
      });

      test('converts +62 to 0 when convertPlusToZero is true', () {
        final result = PhoneNumberFormatter.format(
          '+6281234567890',
          convertPlusToZero: true,
        );
        expect(result, '0812-3456-7890');
      });

      test('keeps +62 format when convertPlusToZero is false', () {
        final result = PhoneNumberFormatter.format(
          '+6281234567890',
          convertPlusToZero: false,
        );
        expect(result, '6281-2345-6789-0');
      });

      test('converts +62 with spaces when convertPlusToZero is true', () {
        final result = PhoneNumberFormatter.format(
          '+62 812 3456 7890',
          convertPlusToZero: true,
        );
        expect(result, '0812-3456-7890');
      });

      test('handles +62 with 13 digits when convertPlusToZero is true', () {
        final result = PhoneNumberFormatter.format(
          '+62812345678901',
          convertPlusToZero: true,
        );
        expect(result, '0812-3456-7890-1');
      });

      test(
        'does not affect non-+62 numbers when convertPlusToZero is true',
        () {
          final result = PhoneNumberFormatter.format(
            '081234567890',
            convertPlusToZero: true,
          );
          expect(result, '0812-3456-7890');
        },
      );
    });

    group('toE164()', () {
      test('converts phone to E.164 format with +62', () {
        final result = PhoneNumberFormatter.toE164('081234567890');
        expect(result, '+6281234567890');
      });

      test('removes leading zero when converting to E.164', () {
        final result = PhoneNumberFormatter.toE164('081234567890');
        expect(result, '+6281234567890');
      });

      test('handles phone without leading zero', () {
        final result = PhoneNumberFormatter.toE164('81234567890');
        expect(result, '+6281234567890');
      });

      test('handles phone with spaces', () {
        final result = PhoneNumberFormatter.toE164('0812 3456 7890');
        expect(result, '+6281234567890');
      });

      test('handles phone with dashes', () {
        final result = PhoneNumberFormatter.toE164('0812-3456-7890');
        expect(result, '+6281234567890');
      });

      test('handles phone with mixed formatting', () {
        final result = PhoneNumberFormatter.toE164('(0812) 3456-7890');
        expect(result, '+6281234567890');
      });

      test('handles empty phone number', () {
        final result = PhoneNumberFormatter.toE164('');
        expect(result, '+62');
      });

      test('handles 13-digit phone number', () {
        final result = PhoneNumberFormatter.toE164('0812345678901');
        expect(result, '+62812345678901');
      });
    });

    group('mask()', () {
      test('masks phone number showing first 4 and last 4 digits', () {
        final result = PhoneNumberFormatter.mask('0812-3456-7890');
        expect(result, '0812-****-7890');
      });

      test('masks phone number without dashes', () {
        final result = PhoneNumberFormatter.mask('081234567890');
        expect(result, '0812-****-7890');
      });

      test('masks 13-digit phone number', () {
        final result = PhoneNumberFormatter.mask('0812345678901');
        expect(result, '0812-****-8901');
      });

      test('handles short phone number', () {
        final result = PhoneNumberFormatter.mask('0812');
        expect(result, '0812');
      });

      test('handles medium length phone number', () {
        final result = PhoneNumberFormatter.mask('08123456');
        expect(result, '08**-**56');
      });

      test('handles phone with spaces', () {
        final result = PhoneNumberFormatter.mask('0812 3456 7890');
        expect(result, '0812-****-7890');
      });

      test('converts +62 to 0 when convertPlusToZero is true', () {
        final result = PhoneNumberFormatter.mask(
          '+6281234567890',
          convertPlusToZero: true,
        );
        expect(result, '0812-****-7890');
      });

      test('keeps +62 format when convertPlusToZero is false', () {
        final result = PhoneNumberFormatter.mask(
          '+6281234567890',
          convertPlusToZero: false,
        );
        expect(result, '6281-****-6789-0');
      });

      test('converts +62 with 13 digits when convertPlusToZero is true', () {
        final result = PhoneNumberFormatter.mask(
          '+62812345678901',
          convertPlusToZero: true,
        );
        expect(result, '0812-****-8901');
      });
    });
  });
}
