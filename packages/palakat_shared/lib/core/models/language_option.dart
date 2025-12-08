import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'language_option.freezed.dart';

/// Model representing a language option for the language selector.
///
/// Contains the locale, display name, and flag emoji for a supported language.
/// Requirements: 6.3
@freezed
abstract class LanguageOption with _$LanguageOption {
  const factory LanguageOption({
    required Locale locale,
    required String name,
    required String flag,
  }) = _LanguageOption;

  /// Private constructor for adding custom methods
  const LanguageOption._();

  /// Check if this language option matches the given locale
  bool matches(Locale other) => locale.languageCode == other.languageCode;
}

/// Static list of supported language options.
///
/// This list is the single source of truth for available languages
/// in the language selector widget.
/// Requirements: 6.3
const supportedLanguageOptions = [
  LanguageOption(locale: Locale('id'), name: 'Bahasa Indonesia', flag: '🇮🇩'),
  LanguageOption(locale: Locale('en'), name: 'English', flag: '🇺🇸'),
];

/// Get the language option for a given locale.
///
/// Returns the matching language option, or the first option (Indonesian)
/// if no match is found.
LanguageOption getLanguageOption(Locale locale) {
  return supportedLanguageOptions.firstWhere(
    (option) => option.matches(locale),
    orElse: () => supportedLanguageOptions.first,
  );
}
