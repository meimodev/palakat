import 'dart:developer' as dev show log;
import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat_shared/core/services/local_storage_service.dart';
import 'package:palakat_shared/core/services/local_storage_service_provider.dart';
import 'package:palakat_shared/core/utils/locale_serializer.dart';

part 'locale_controller.g.dart';

/// Controller for managing the application locale state.
///
/// This controller handles:
/// - Loading persisted locale from storage on initialization
/// - Updating the current locale and persisting changes
/// - Notifying listeners when locale changes
///
/// Requirements: 5.1, 5.2, 5.3, 5.4
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  /// Build the initial state with default Indonesian locale.
  ///
  /// Loads any persisted locale from storage asynchronously.
  /// Requirements: 5.2, 5.3
  @override
  Locale build() {
    // Load persisted locale asynchronously
    _loadPersistedLocale();
    // Return default locale immediately
    return defaultLocale;
  }

  /// Get the LocalStorageService instance
  LocalStorageService get _storage => ref.read(localStorageServiceProvider);

  /// Set the application locale and persist it to storage.
  ///
  /// Only updates if the locale is supported and different from current.
  /// Requirements: 1.4, 5.1, 5.4
  Future<void> setLocale(Locale locale) async {
    // Validate locale is supported
    if (!LocaleSerializer.isSupported(locale)) {
      dev.log(
        'LocaleController.setLocale: unsupported locale "${locale.languageCode}", ignoring',
        name: 'LocaleController',
      );
      return;
    }

    // Skip if same as current
    if (state.languageCode == locale.languageCode) {
      dev.log(
        'LocaleController.setLocale: locale already set to "${locale.languageCode}"',
        name: 'LocaleController',
      );
      return;
    }

    // Update state (notifies listeners)
    state = locale;

    // Persist to storage
    await _storage.saveLocale(locale);

    dev.log(
      'LocaleController.setLocale: locale changed to "${locale.languageCode}"',
      name: 'LocaleController',
    );
  }

  /// Load persisted locale from storage.
  ///
  /// Called during initialization to restore user's language preference.
  /// Requirements: 1.6, 5.2
  Future<void> _loadPersistedLocale() async {
    try {
      final persistedLocale = await _storage.loadLocale();
      if (persistedLocale != null &&
          LocaleSerializer.isSupported(persistedLocale)) {
        // Only update if different from current state
        if (state.languageCode != persistedLocale.languageCode) {
          state = persistedLocale;
          dev.log(
            'LocaleController._loadPersistedLocale: restored locale "${persistedLocale.languageCode}"',
            name: 'LocaleController',
          );
        }
      }
    } catch (e) {
      dev.log(
        'LocaleController._loadPersistedLocale: failed to load locale: $e',
        name: 'LocaleController',
      );
      // Keep default locale on error
    }
  }
}
