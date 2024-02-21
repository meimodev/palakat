import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResetPasswordState {
  final AsyncValue<bool?> valid;
  final Map<String, dynamic> errors;
  final bool isNewPasswordObscure;
  final bool isConfirmationPasswordObscure;
  final String userSerial;
  final String token;

  const ResetPasswordState({
    this.isNewPasswordObscure = true,
    this.isConfirmationPasswordObscure = true,
    this.valid = const AsyncData(null),
    this.errors = const {},
    this.userSerial = "",
    this.token = "",
  });

  ResetPasswordState copyWith({
    AsyncValue<bool?>? valid,
    Map<String, dynamic>? errors,
    bool? isNewPasswordObscure,
    bool? isConfirmationPasswordObscure,
    String? userSerial,
    String? token,
  }) {
    return ResetPasswordState(
      valid: valid ?? this.valid,
      errors: errors ?? this.errors,
      isNewPasswordObscure: isNewPasswordObscure ?? this.isNewPasswordObscure,
      isConfirmationPasswordObscure:
          isConfirmationPasswordObscure ?? this.isConfirmationPasswordObscure,
      userSerial: userSerial ?? this.userSerial,
      token: token ?? this.token,
    );
  }
}
