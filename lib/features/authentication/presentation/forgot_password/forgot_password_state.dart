import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordState {
  final AsyncValue<bool?> valid;
  final Map<String, dynamic> errors;

  const ForgotPasswordState({
    this.valid = const AsyncData(null),
    this.errors = const {},
  });

  ForgotPasswordState copyWith({
    AsyncValue<bool?>? valid,
    Map<String, dynamic>? errors,
  }) {
    return ForgotPasswordState(
      valid: valid ?? this.valid,
      errors: errors ?? this.errors,
    );
  }
}
