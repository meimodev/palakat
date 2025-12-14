import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';

/// Property-based tests for ARB file key parity.
/// **Feature: admin-localization**
void main() {
  group('ARB Key Parity Property Tests', () {
    late Map<String, dynamic> enArb;
    late Map<String, dynamic> idArb;

    setUpAll(() async {
      // Load ARB files
      final enFile = File('lib/l10n/intl_en.arb');
      final idFile = File('lib/l10n/intl_id.arb');

      expect(enFile.existsSync(), isTrue, reason: 'English ARB file should exist');
      expect(idFile.existsSync(), isTrue, reason: 'Indonesian ARB file should exist');

      final enContent = await enFile.readAsString();
      final idContent = await idFile.readAsString();

      enArb = json.decode(enContent) as Map<String, dynamic>;
      idArb = json.decode(idContent) as Map<String, dynamic>;
    });

    /// **Feature: admin-localization, Property 1: ARB Key Parity**
    /// **Validates: Requirements 19.1**
    ///
    /// *For any* localization key present in `intl_en.arb`, there SHALL exist 
    /// a corresponding key with the same name in `intl_id.arb`
    test('Property 1: ARB Key Parity', () {
      // Get all keys from English ARB (excluding metadata keys that start with @)
      final enKeys = enArb.keys
          .where((key) => !key.startsWith('@') && key != '@@locale')
          .toSet();

      // Get all keys from Indonesian ARB (excluding metadata keys)
      final idKeys = idArb.keys
          .where((key) => !key.startsWith('@') && key != '@@locale')
          .toSet();

      // Check that every English key exists in Indonesian ARB
      final missingInId = enKeys.difference(idKeys);
      expect(
        missingInId,
        isEmpty,
        reason: 'All English keys should exist in Indonesian ARB. Missing keys: $missingInId',
      );

      // Check that every Indonesian key exists in English ARB (reverse check)
      final missingInEn = idKeys.difference(enKeys);
      expect(
        missingInEn,
        isEmpty,
        reason: 'All Indonesian keys should exist in English ARB. Missing keys: $missingInEn',
      );

      // Verify that both files have the same number of translation keys
      expect(
        enKeys.length,
        equals(idKeys.length),
        reason: 'English and Indonesian ARB files should have the same number of keys',
      );
    });

    /// Property test: Key consistency across ARB files
    property('All localization keys have corresponding translations', () {
      forAll(
        _arbKeyArbitrary(enArb),
        (key) {
          // Skip metadata keys
          if (key.startsWith('@') || key == '@@locale') {
            return;
          }

          // Verify key exists in both files
          expect(
            enArb.containsKey(key),
            isTrue,
            reason: 'Key "$key" should exist in English ARB',
          );
          expect(
            idArb.containsKey(key),
            isTrue,
            reason: 'Key "$key" should exist in Indonesian ARB',
          );

          // Verify both values are non-empty strings
          final enValue = enArb[key];
          final idValue = idArb[key];

          expect(
            enValue,
            isA<String>(),
            reason: 'English value for key "$key" should be a string',
          );
          expect(
            idValue,
            isA<String>(),
            reason: 'Indonesian value for key "$key" should be a string',
          );

          expect(
            (enValue as String).isNotEmpty,
            isTrue,
            reason: 'English value for key "$key" should not be empty',
          );
          expect(
            (idValue as String).isNotEmpty,
            isTrue,
            reason: 'Indonesian value for key "$key" should not be empty',
          );
        },
      );
    });

    /// Test specific admin keys that should be present
    test('Admin-specific keys are present in both ARB files', () {
      final adminKeys = [
        'admin_billing_title',
        'admin_approval_title',
        'admin_account_title',
        'admin_activity_title',
        'admin_revenue_title',
        'admin_member_title',
        'admin_financial_title',
      ];

      for (final key in adminKeys) {
        expect(
          enArb.containsKey(key),
          isTrue,
          reason: 'Admin key "$key" should exist in English ARB',
        );
        expect(
          idArb.containsKey(key),
          isTrue,
          reason: 'Admin key "$key" should exist in Indonesian ARB',
        );
      }
    });

    /// Test that locale metadata is correct
    test('ARB files have correct locale metadata', () {
      expect(
        enArb['@@locale'],
        equals('en'),
        reason: 'English ARB should have @@locale set to "en"',
      );
      expect(
        idArb['@@locale'],
        equals('id'),
        reason: 'Indonesian ARB should have @@locale set to "id"',
      );
    });
  });
}

// ============================================================================
// Arbitrary generators
// ============================================================================

/// Generates a random key from the English ARB file.
Arbitrary<String> _arbKeyArbitrary(Map<String, dynamic> arbFile) {
  final keys = arbFile.keys.toList();
  return integer(min: 0, max: keys.length - 1).map((index) => keys[index]);
}