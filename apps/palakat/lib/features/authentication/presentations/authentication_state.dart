import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/models/models.dart';

part 'authentication_state.freezed.dart';
part 'authentication_state.g.dart';

@Freezed(toJson: true, fromJson: true)
abstract class AuthenticationState with _$AuthenticationState {
  const factory AuthenticationState({
    // Phone input fields
    @Default('') String phoneNumber,
    @Default('') String fullPhoneNumber,

    // OTP fields
    @Default('') String otp,
    @Default(false) bool showOtpScreen,

    // Firebase verification fields
    String? verificationId,
    int? resendToken,

    // Timer functionality
    @Default(120) int remainingSeconds,
    @Default(false) bool canResendOtp,

    // Loading states
    @Default(false) bool isSendingOtp,
    @Default(false) bool isVerifyingOtp,
    @Default(false) bool isValidatingAccount,

    // Success state
    @Default(false) bool showSuccessFeedback,

    // Error handling
    String? errorMessage,

    // Authentication result
    Account? account,
    AuthTokens? tokens,

    // Legacy fields (for backward compatibility during migration)
    @Deprecated('Use phoneNumber instead') @Default('') String phone,
    @Deprecated('Use showOtpScreen instead')
    @Default(false)
    bool showOtpVerification,
    @Deprecated('Use isSendingOtp or isVerifyingOtp instead')
    @Default(false)
    bool loading,
    @Deprecated('Use remainingSeconds instead') @Default(120) int remainingTime,
    @Default(false) bool isFormValid,
    @Deprecated('Use account instead') Account? user,
    // ignore: invalid_annotation_target
    @JsonKey(includeFromJson: false, includeToJson: false) Timer? timer,
  }) = _AuthenticationState;

  factory AuthenticationState.fromJson(Map<String, dynamic> json) =>
      _$AuthenticationStateFromJson(json);
}
