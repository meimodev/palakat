import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';

class LanguageState {
  final bool isLoading;
  final AsyncValue<bool?> valid;
  final LanguageKey language;

  const LanguageState({
    this.isLoading = true,
    this.valid = const AsyncData(null),
    this.language = defaultLanguage,
  });

  LanguageState copyWith({
    bool? isLoading,
    AsyncValue<bool?>? valid,
    LanguageKey? language,
  }) {
    return LanguageState(
      valid: valid ?? this.valid,
      isLoading: isLoading ?? this.isLoading,
      language: language ?? this.language,
    );
  }
}
