import 'package:halo_hermina/features/domain.dart';

class LoginState {
  final bool isLoading;
  final LoginType selectedLoginMode;
  final bool isPasswordObscure;
  final OtpProvider otpProvider;
  final Map<String, dynamic> errors;
  final bool redirectBack;

  const LoginState({
    this.isLoading = false,
    this.selectedLoginMode = LoginType.email,
    this.isPasswordObscure = true,
    this.otpProvider = OtpProvider.sms,
    this.errors = const {},
    this.redirectBack = false,
  });

  LoginState copyWith({
    bool? isLoading,
    LoginType? selectedLoginMode,
    bool? isPasswordObscure,
    OtpProvider? otpProvider,
    Map<String, dynamic>? errors,
    bool? redirectBack,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      selectedLoginMode: selectedLoginMode ?? this.selectedLoginMode,
      isPasswordObscure: isPasswordObscure ?? this.isPasswordObscure,
      otpProvider: otpProvider ?? this.otpProvider,
      redirectBack: redirectBack ?? this.redirectBack,
      errors: errors ?? this.errors,
    );
  }
}
