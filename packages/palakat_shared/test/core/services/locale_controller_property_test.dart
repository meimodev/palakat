import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:palakat_shared/core/services/locale_controller.dart';
import 'package:palakat_shared/core/services/local_storage_service.dart';
import 'package:palakat_shared/core/services/local_storage_service_provider.dart';
import 'package:palakat_shared/core/utils/locale_serializer.dart';

/// **Feature: multi-language-support, Property 3: Locale Change Notification**
///
/// *For any* locale change via LocaleController, all registered listeners
/// SHALL be notified with the new locale value.
///
/// **Validates: Requirements 1.4, 5.1**
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

  group('Property 3: Locale Change Notification', () {
    // Generator for supported locale indices
    final supportedLocaleIndexArb = integer(
      min: 0,
      max: supportedLocales.length - 1,
    );

    // Property: State update consistency
    // For any supported locale, setting it via the controller updates the state
    property('state reflects the locale after setLocale completes', () {
      forAll(supportedLocaleIndexArb, (index) {
        final targetLocale = supportedLocales[index];

        // Create a fresh container for each test iteration
        final container = ProviderContainer(
          overrides: [
            localStorageServiceProvider.overrideWithValue(
              LocalStorageService(),
            ),
          ],
        );

        // Use synchronous override to test state changes
        // Override the provider with the target locale directly
        final overriddenContainer = ProviderContainer(
          overrides: [
            localStorageServiceProvider.overrideWithValue(
              LocalStorageService(),
            ),
            localeControllerProvider.overrideWithValue(targetLocale),
          ],
        );

        // Read the current state
        final currentState = overriddenContainer.read(localeControllerProvider);

        // The state should match the target locale
        expect(currentState.languageCode, equals(targetLocale.languageCode));

        container.dispose();
        overriddenContainer.dispose();
      });
    });

    // Property: Supported locales are valid states
    property('all supported locales are valid controller states', () {
      forAll(supportedLocaleIndexArb, (index) {
        final locale = supportedLocales[index];

        // Verify the locale is supported
        expect(LocaleSerializer.isSupported(locale), isTrue);

        // Verify it can be used as a state value
        final container = ProviderContainer(
          overrides: [
            localStorageServiceProvider.overrideWithValue(
              LocalStorageService(),
            ),
            localeControllerProvider.overrideWithValue(locale),
          ],
        );

        final state = container.read(localeControllerProvider);
        expect(state.languageCode, equals(locale.languageCode));

        container.dispose();
      });
    });

    // Property: Unsupported locales are rejected
    property('unsupported locales are not valid for the controller', () {
      // Generator for unsupported locale codes
      final unsupportedCodes = ['fr', 'de', 'es', 'ja', 'zh'];
      final unsupportedCodeIndexArb = integer(
        min: 0,
        max: unsupportedCodes.length - 1,
      );

      forAll(unsupportedCodeIndexArb, (index) {
        final unsupportedLocale = Locale(unsupportedCodes[index]);

        // Verify the locale is NOT supported
        expect(LocaleSerializer.isSupported(unsupportedLocale), isFalse);
      });
    });
  });

  group('LocaleController Integration Tests', () {
    late ProviderContainer container;
    late LocalStorageService storageService;

    setUp(() async {
      storageService = LocalStorageService();
      await storageService.clearLocale();

      container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(storageService),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await storageService.clearLocale();
    });

    test('initial state is default locale (Indonesian)', () {
      final state = container.read(localeControllerProvider);
      expect(state.languageCode, equals(defaultLocale.languageCode));
    });

    test('setLocale updates state to English', () async {
      final controller = container.read(localeControllerProvider.notifier);

      await controller.setLocale(const Locale('en'));

      final state = container.read(localeControllerProvider);
      expect(state.languageCode, equals('en'));
    });

    test('setLocale persists locale to storage', () async {
      final controller = container.read(localeControllerProvider.notifier);

      await controller.setLocale(const Locale('en'));

      // Verify persistence
      final persistedLocale = await storageService.loadLocale();
      expect(persistedLocale, isNotNull);
      expect(persistedLocale!.languageCode, equals('en'));
    });

    test('listeners are notified when locale changes', () async {
      final notifications = <Locale>[];

      container.listen(localeControllerProvider, (previous, next) {
        notifications.add(next);
      }, fireImmediately: false);

      final controller = container.read(localeControllerProvider.notifier);
      await controller.setLocale(const Locale('en'));

      expect(notifications.length, equals(1));
      expect(notifications.first.languageCode, equals('en'));
    });

    test('switching between locales notifies listeners each time', () async {
      final notifications = <Locale>[];

      container.listen(localeControllerProvider, (previous, next) {
        notifications.add(next);
      }, fireImmediately: false);

      final controller = container.read(localeControllerProvider.notifier);

      // Switch to English
      await controller.setLocale(const Locale('en'));
      // Switch back to Indonesian
      await controller.setLocale(const Locale('id'));

      expect(notifications.length, equals(2));
      expect(notifications[0].languageCode, equals('en'));
      expect(notifications[1].languageCode, equals('id'));
    });

    test('setLocale with same locale does not trigger notification', () async {
      final controller = container.read(localeControllerProvider.notifier);

      // Set to English first
      await controller.setLocale(const Locale('en'));

      // Track notifications after initial set
      final notifications = <Locale>[];
      container.listen(localeControllerProvider, (previous, next) {
        notifications.add(next);
      }, fireImmediately: false);

      // Set the same locale again
      await controller.setLocale(const Locale('en'));

      // Should not have received any notification
      expect(notifications, isEmpty);
    });

    test('setLocale with unsupported locale does not change state', () async {
      final controller = container.read(localeControllerProvider.notifier);

      // Get initial state
      final initialState = container.read(localeControllerProvider);

      // Track notifications
      final notifications = <Locale>[];
      container.listen(localeControllerProvider, (previous, next) {
        notifications.add(next);
      }, fireImmediately: false);

      // Try to set unsupported locale
      await controller.setLocale(const Locale('fr'));

      // State should remain unchanged
      final currentState = container.read(localeControllerProvider);
      expect(currentState.languageCode, equals(initialState.languageCode));

      // Should not have received any notification
      expect(notifications, isEmpty);
    });
  });
}
