import 'dart:ui';

/// Supported locales for the application
const supportedLocales = [
  Locale('id'), // Indonesian (default)
  Locale('en'), // English
];

/// Default locale for the application
const defaultLocale = Locale('id');

/// Utility class for serializing and deserializing Locale objects.
///
/// This class provides methods to convert Locale objects to strings for
/// storage and back to Locale objects for use in the application.
class LocaleSerializer {
  /// Private constructor to prevent instantiation
  LocaleSerializer._();

  /// Serialize a [Locale] to a storable string representation.
  ///
  /// Returns the language code of the locale (e.g., 'id', 'en').
  static String serialize(Locale locale) => locale.languageCode;

  /// Deserialize a string back to a [Locale] object.
  ///
  /// If the [code] is empty or not a supported locale, returns [defaultLocale].
  static Locale deserialize(String code) {
    if (code.isEmpty) {
      return defaultLocale;
    }
    final locale = Locale(code);
    return isSupported(locale) ? locale : defaultLocale;
  }

  /// Check if a [Locale] is supported by the application.
  ///
  /// Returns true if the locale's language code matches any supported locale.
  static bool isSupported(Locale locale) {
    return supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  /// Get a supported locale from a language code string.
  ///
  /// Returns [defaultLocale] if the code is not supported.
  static Locale fromLanguageCode(String code) {
    return deserialize(code);
  }
}
