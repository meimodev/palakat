import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePasswordState {
  final AsyncValue<bool?> valid;
  final bool isOldPasswordObscure;
  final bool isNewPasswordObscure;
  final bool isConfirmationPasswordObscure;
  final Map<String, dynamic> errors;

  const ChangePasswordState({
    this.valid = const AsyncData(null),
    this.isOldPasswordObscure = true,
    this.isNewPasswordObscure = true,
    this.isConfirmationPasswordObscure = true,
    this.errors = const {},
  });

  ChangePasswordState copyWith({
    AsyncValue<bool?>? valid,
    bool? isOldPasswordObscure,
    bool? isNewPasswordObscure,
    bool? isConfirmationPasswordObscure,
    Map<String, dynamic>? errors,
  }) {
    return ChangePasswordState(
      valid: valid ?? this.valid,
      isOldPasswordObscure: isOldPasswordObscure ?? this.isOldPasswordObscure,
      isNewPasswordObscure: isNewPasswordObscure ?? this.isNewPasswordObscure,
      isConfirmationPasswordObscure:
          isConfirmationPasswordObscure ?? this.isConfirmationPasswordObscure,
      errors: errors ?? this.errors,
    );
  }
}
