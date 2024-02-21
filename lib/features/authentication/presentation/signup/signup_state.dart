import 'package:halo_hermina/core/constants/constants.dart';

class SignUpState {
  final bool isLoading;
  final SignUpType selectedSignUpMode;
  final Map<String, dynamic> errors;

  const SignUpState({
    this.isLoading = false,
    this.selectedSignUpMode = SignUpType.email,
    this.errors = const {},
  });

  SignUpState copyWith({
    bool? isLoading,
    SignUpType? selectedSignUpMode,
    Map<String, dynamic>? errors,
  }) {
    return SignUpState(
      isLoading: isLoading ?? this.isLoading,
      selectedSignUpMode: selectedSignUpMode ?? this.selectedSignUpMode,
      errors: errors ?? this.errors,
    );
  }
}
