import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/core/models/models.dart';


part 'authentication_state.freezed.dart';

@freezed
abstract class AuthenticationState with _$AuthenticationState {
  const factory AuthenticationState({
    @Default('') String phone,
    @Default('') String otp,
    String? errorMessage,
    Timer? timer,
    @Default(120) int remainingTime,
    @Default(false) bool showOtpVerification,
    @Default(false) bool loading,
    @Default(false) bool isFormValid,
    @Default(false) bool canResendOtp,
    final Account? user,
  }) = _AuthenticationState;
}
