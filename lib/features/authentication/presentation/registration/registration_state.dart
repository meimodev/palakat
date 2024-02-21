import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';

class RegistrationState {
  final SignUpType selectedSignUpMode;
  final AsyncValue<bool?> valid;
  final bool isPasswordObscure;
  final bool isAgree;
  final DateTime? selectedDate;
  final DateTime? savedDate;
  final String? selectedGender;
  final Map<String, dynamic> errors;

  const RegistrationState({
    this.isPasswordObscure = true,
    this.valid = const AsyncData(null),
    this.isAgree = false,
    this.selectedSignUpMode = SignUpType.email,
    this.selectedDate,
    this.savedDate,
    this.selectedGender,
    this.errors = const {},
  });

  RegistrationState copyWith({
    SignUpType? selectedSignUpMode,
    AsyncValue<bool?>? valid,
    bool? isPasswordObscure,
    bool? isAgree,
    final DateTime? selectedDate,
    final DateTime? savedDate,
    String? selectedGender,
    Map<String, dynamic>? errors,
  }) {
    return RegistrationState(
      selectedSignUpMode: selectedSignUpMode ?? this.selectedSignUpMode,
      valid: valid ?? this.valid,
      isPasswordObscure: isPasswordObscure ?? this.isPasswordObscure,
      isAgree: isAgree ?? this.isAgree,
      selectedDate: selectedDate ?? this.selectedDate,
      savedDate: savedDate ?? this.savedDate,
      selectedGender: selectedGender ?? this.selectedGender,
      errors: errors ?? this.errors,
    );
  }
}
