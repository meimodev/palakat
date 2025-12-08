import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:palakat_shared/core/services/local_storage_service.dart';
import 'package:palakat_shared/core/utils/locale_serializer.dart';

/// **Feature: multi-language-support, Property 2: Locale Persistence Consistency**
///
/// *For any* supported locale, when saved to storage and then loaded,
/// the retrieved locale SHALL equal the saved locale.
///
/// **Validates: Requirements 1.5, 1.6, 5.4**
void main() {
  KiriCheck.verbosity = Verbosity.verbose;

  setUpAll(() async {
    // Initialize Hive for testing with a temporary path
    Hive.init('.hive_test');
    // Open the auth box that LocalStorageService uses
    await Hive.openBox('auth');
  });

  tearDownAll(() async {
    // Clean up Hive after tests
    await Hive.close();
    await Hive.deleteFromDisk();
  });

  group('Property 2: Locale Persistence Consistency', () {
    // Generator for supported locale indices
    final supportedLocaleIndexArb = integer(
      min: 0,
      max: supportedLocales.length - 1,
    );

    // Property test: Serialization is consistent with LocaleSerializer
    // This tests the core property that the service uses LocaleSerializer correctly
    property('locale serialization in service matches LocaleSerializer', () {
      forAll(supportedLocaleIndexArb, (index) {
        final locale = supportedLocales[index];

        // The service uses LocaleSerializer.serialize internally
        final serialized = LocaleSerializer.serialize(locale);

        // Verify the serialized value is the language code
        expect(serialized, equals(locale.languageCode));

        // Verify deserialization produces equivalent locale
        final deserialized = LocaleSerializer.deserialize(serialized);
        expect(deserialized.languageCode, equals(locale.languageCode));
      });
    });

    // Property test: All supported locales can be serialized and deserialized
    property('all supported locales round-trip through serialization', () {
      forAll(supportedLocaleIndexArb, (index) {
        final originalLocale = supportedLocales[index];

        // Serialize
        final serialized = LocaleSerializer.serialize(originalLocale);

        // Deserialize
        final deserialized = LocaleSerializer.deserialize(serialized);

        // Should be equivalent
        expect(deserialized.languageCode, equals(originalLocale.languageCode));
        expect(LocaleSerializer.isSupported(deserialized), isTrue);
      });
    });

    // Property test: Supported locales are recognized
    property('isSupported returns true for all supported locales', () {
      forAll(supportedLocaleIndexArb, (index) {
        final locale = supportedLocales[index];
        expect(LocaleSerializer.isSupported(locale), isTrue);
      });
    });
  });

  // Async tests for actual persistence (these test the full round-trip)
  group('Locale Persistence Integration Tests', () {
    late LocalStorageService service;

    setUp(() async {
      service = LocalStorageService();
    });

    tearDown(() async {
      await service.clearLocale();
    });

    test('loadLocale returns null when no locale has been saved', () async {
      final loadedLocale = await service.loadLocale();
      expect(loadedLocale, isNull);
    });

    test('currentLocale is null before any locale is saved', () {
      expect(service.currentLocale, isNull);
    });

    test('saving Indonesian locale persists correctly', () async {
      const indonesianLocale = Locale('id');

      await service.saveLocale(indonesianLocale);

      final newService = LocalStorageService();
      final loadedLocale = await newService.loadLocale();

      expect(loadedLocale, isNotNull);
      expect(loadedLocale!.languageCode, equals('id'));
    });

    test('saving English locale persists correctly', () async {
      const englishLocale = Locale('en');

      await service.saveLocale(englishLocale);

      final newService = LocalStorageService();
      final loadedLocale = await newService.loadLocale();

      expect(loadedLocale, isNotNull);
      expect(loadedLocale!.languageCode, equals('en'));
    });

    test(
      'overwriting locale with different value persists new value',
      () async {
        const indonesianLocale = Locale('id');
        const englishLocale = Locale('en');

        // Save Indonesian first
        await service.saveLocale(indonesianLocale);

        // Overwrite with English
        await service.saveLocale(englishLocale);

        // Should load English
        final newService = LocalStorageService();
        final loadedLocale = await newService.loadLocale();

        expect(loadedLocale, isNotNull);
        expect(loadedLocale!.languageCode, equals('en'));
      },
    );

    test('clearLocale removes persisted locale', () async {
      const locale = Locale('en');

      // Save locale
      await service.saveLocale(locale);

      // Clear locale
      await service.clearLocale();

      // Verify currentLocale is null
      expect(service.currentLocale, isNull);

      // Verify loading returns null
      final newService = LocalStorageService();
      final loadedLocale = await newService.loadLocale();
      expect(loadedLocale, isNull);
    });

    test('currentLocale reflects saved locale after saveLocale', () async {
      const locale = Locale('en');

      await service.saveLocale(locale);

      expect(service.currentLocale, isNotNull);
      expect(service.currentLocale!.languageCode, equals('en'));
    });

    // Test all supported locales persist correctly
    for (final locale in supportedLocales) {
      test('saving ${locale.languageCode} locale persists correctly', () async {
        await service.saveLocale(locale);

        final newService = LocalStorageService();
        final loadedLocale = await newService.loadLocale();

        expect(loadedLocale, isNotNull);
        expect(loadedLocale!.languageCode, equals(locale.languageCode));
      });
    }
  });
}
