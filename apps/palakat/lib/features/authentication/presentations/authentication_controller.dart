import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/authentication/data/firebase_auth_repository.dart';
import 'package:palakat/features/authentication/data/utils/phone_number_formatter.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/core/models/models.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:palakat_shared/l10n/generated/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'authentication_controller.g.dart';

AppLocalizations _l10n() {
  final localeName = intl.Intl.getCurrentLocale();
  final languageCode = localeName.split(RegExp('[_-]')).first;
  return lookupAppLocalizations(
    Locale(languageCode.isEmpty ? 'en' : languageCode),
  );
}

@riverpod
class AuthenticationController extends _$AuthenticationController {
  Timer? _timer;

  @override
  AuthenticationState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });

    return const AuthenticationState();
  }

  AuthRepository get _authRepo => ref.read(authRepositoryProvider);
  FirebaseAuthRepository get _firebaseAuthRepo =>
      ref.read(firebaseAuthRepositoryProvider);

  // ========== Phone Input Methods ==========

  /// Updates the phone number and formats it for display
  void onPhoneNumberChanged(String value) {
    // Clear error when user starts typing
    state = state.copyWith(phoneNumber: value, errorMessage: null);

    // Update full phone number with formatting
    if (value.isNotEmpty) {
      final fullPhone = PhoneNumberFormatter.toE164(value);
      state = state.copyWith(fullPhoneNumber: fullPhone);
    } else {
      state = state.copyWith(fullPhoneNumber: '');
    }
  }

  /// Validates the phone number format
  /// Phone must start with 0 and be 12-13 digits total
  bool validatePhoneNumber() {
    final l10n = _l10n();
    if (state.phoneNumber.isEmpty) {
      state = state.copyWith(errorMessage: l10n.validation_phoneRequired);
      return false;
    }

    // Remove all non-digit characters for validation
    final cleanPhone = state.phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Check if phone contains only digits
    if (cleanPhone.isEmpty) {
      state = state.copyWith(errorMessage: l10n.validation_invalidPhone);
      return false;
    }

    // Must start with 0
    if (!cleanPhone.startsWith('0')) {
      state = state.copyWith(
        errorMessage: l10n.churchRequest_validation_phoneMustStartWithZero,
      );
      return false;
    }

    // Check length: 12-13 digits
    if (cleanPhone.length < 12) {
      state = state.copyWith(
        errorMessage: l10n.churchRequest_validation_phoneMinDigits(12),
      );
      return false;
    }

    if (cleanPhone.length > 13) {
      state = state.copyWith(
        errorMessage: l10n.churchRequest_validation_phoneMaxDigits(13),
      );
      return false;
    }

    // Additional validation: check for invalid patterns
    // (e.g., all zeros, all same digit)
    if (RegExp(r'^0+$').hasMatch(cleanPhone)) {
      state = state.copyWith(errorMessage: l10n.validation_invalidPhone);
      return false;
    }

    // Check for repeating digits (e.g., 000000000000)
    if (cleanPhone.length >= 8) {
      final firstDigit = cleanPhone[0];
      if (cleanPhone.split('').every((d) => d == firstDigit)) {
        state = state.copyWith(errorMessage: l10n.validation_invalidPhone);
        return false;
      }
    }

    return true;
  }

  /// Sends OTP via Firebase Phone Authentication
  Future<bool> sendOtp() async {
    if (!validatePhoneNumber()) return false;

    state = state.copyWith(isSendingOtp: true, errorMessage: null);

    try {
      // Convert phone to E.164 format for Firebase
      final e164Phone = PhoneNumberFormatter.toE164(state.phoneNumber);

      // Add timeout wrapper for the entire operation
      await Future.any([
        _firebaseAuthRepo.verifyPhoneNumber(
          phoneNumber: e164Phone,
          timeout: const Duration(seconds: 60),
          onCodeSent: (verificationId, resendToken) {
            // Update state with verification ID and resend token
            state = state.copyWith(
              verificationId: verificationId,
              resendToken: resendToken,
              isSendingOtp: false,
              showOtpScreen: true,
            );
            // Start the countdown timer
            startTimer();
          },
          onVerificationCompleted: (credential) {
            // Auto-verification completed (Android only)
            // This happens when SMS is automatically retrieved
            state = state.copyWith(isSendingOtp: false, showOtpScreen: true);
          },
          onVerificationFailed: (failure) {
            // Handle verification failure with specific error messages
            String errorMessage = failure.message;
            final l10n = _l10n();

            // Provide more context for specific error types
            if (failure.code == 429) {
              errorMessage = l10n.msg_tryAgainLater;
            } else if (failure.code == 503 || failure.code == 408) {
              errorMessage = failure.code == 408
                  ? l10n.error_timeout
                  : l10n.err_networkError;
            } else if (failure.code == 400) {
              errorMessage = l10n.err_invalidPhone;
            }

            state = state.copyWith(
              isSendingOtp: false,
              errorMessage: errorMessage,
            );
          },
        ),
        Future.delayed(const Duration(seconds: 90)).then((_) {
          // Timeout after 90 seconds (30 seconds more than Firebase timeout)
          if (state.isSendingOtp) {
            final l10n = _l10n();
            state = state.copyWith(
              isSendingOtp: false,
              errorMessage: l10n.error_timeout,
            );
          }
        }),
      ]);

      // Success is handled in onCodeSent callback
      return true;
    } catch (e) {
      // Handle unexpected errors
      final l10n = _l10n();
      String errorMessage = l10n.err_somethingWentWrong;

      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage = l10n.err_networkError;
      } else if (e.toString().contains('timeout')) {
        errorMessage = l10n.error_timeout;
      }

      state = state.copyWith(isSendingOtp: false, errorMessage: errorMessage);
      return false;
    }
  }

  /// Clears the error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // ========== Navigation Methods ==========

  /// Shows the OTP verification screen
  void showOtpScreen() {
    state = state.copyWith(
      showOtpScreen: true,
      showOtpVerification: true, // Legacy field
    );
  }

  /// Navigates back to phone input screen from OTP screen
  void goBackToPhoneInput() {
    // Cancel timer and Firebase verification session
    stopTimer();

    // Reset OTP-related state but preserve phone number
    state = state.copyWith(
      showOtpScreen: false,
      showOtpVerification: false, // Legacy field
      otp: '',
      verificationId: null,
      errorMessage: null,
      isVerifyingOtp: false,
      isValidatingAccount: false,
    );
  }

  // ========== Legacy Methods (Updated for new state fields) ==========

  void onChangedTextPhone(String value) {
    // Delegate to new method
    onPhoneNumberChanged(value);
    // Keep legacy field for backward compatibility
    state = state.copyWith(phone: value, isFormValid: value.isNotEmpty);
  }

  // ========== OTP Verification Methods ==========

  /// Updates the OTP value as user types
  void onOtpChanged(String value) {
    state = state.copyWith(otp: value, errorMessage: null);
  }

  /// Legacy method for backward compatibility
  void onChangedOtp(String value) {
    onOtpChanged(value);
  }

  void showOtpVerification() {
    final l10n = _l10n();
    if (state.phoneNumber.isEmpty) {
      state = state.copyWith(errorMessage: l10n.validation_phoneRequired);
      return;
    }

    state = state.copyWith(
      showOtpScreen: true,
      showOtpVerification: true, // Legacy field
    );
    startTimer();
  }

  // ========== Timer Methods ==========

  /// Starts the countdown timer for OTP resend
  void startTimer() {
    _timer?.cancel();

    state = state.copyWith(
      remainingSeconds: AppConstants.otpTimerDurationInSeconds,
      remainingTime: AppConstants.otpTimerDurationInSeconds, // Legacy field
      canResendOtp: false,
    );

    _timer = Timer.periodic(AppConstants.timerInterval, (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(
          remainingSeconds: state.remainingSeconds - 1,
          remainingTime: state.remainingSeconds - 1, // Legacy field
        );
      } else {
        timer.cancel();
        state = state.copyWith(canResendOtp: true);
      }
    });
  }

  /// Stops the countdown timer
  void stopTimer() {
    _timer?.cancel();
    state = state.copyWith(canResendOtp: false);
  }

  /// Resends OTP using Firebase with resend token
  Future<void> resendOtp() async {
    if (!state.canResendOtp) {
      return;
    }

    state = state.copyWith(isSendingOtp: true, errorMessage: null);

    try {
      // Convert phone to E.164 format for Firebase
      final e164Phone = PhoneNumberFormatter.toE164(state.phoneNumber);

      // Add timeout wrapper for the resend operation
      await Future.any([
        _firebaseAuthRepo.resendOtp(
          phoneNumber: e164Phone,
          resendToken: state.resendToken,
          timeout: const Duration(seconds: 60),
          onCodeSent: (verificationId, resendToken) {
            // Update state with new verification ID and resend token
            state = state.copyWith(
              verificationId: verificationId,
              resendToken: resendToken,
              isSendingOtp: false,
              otp: '', // Clear previous OTP
            );
            // Restart the countdown timer
            startTimer();
          },
          onVerificationCompleted: (credential) {
            // Auto-verification completed (Android only)
            state = state.copyWith(isSendingOtp: false);
          },
          onVerificationFailed: (failure) {
            // Handle resend failure with specific error messages
            String errorMessage = failure.message;
            final l10n = _l10n();

            // Provide more context for specific error types
            if (failure.code == 429) {
              errorMessage = l10n.msg_tryAgainLater;
            } else if (failure.code == 503 || failure.code == 408) {
              errorMessage = failure.code == 408
                  ? l10n.error_timeout
                  : l10n.err_networkError;
            }

            state = state.copyWith(
              isSendingOtp: false,
              errorMessage: errorMessage,
            );
          },
        ),
        Future.delayed(const Duration(seconds: 90)).then((_) {
          // Timeout after 90 seconds
          if (state.isSendingOtp) {
            final l10n = _l10n();
            state = state.copyWith(
              isSendingOtp: false,
              errorMessage: l10n.error_timeout,
            );
          }
        }),
      ]);
    } catch (e) {
      // Handle unexpected errors
      final l10n = _l10n();
      String errorMessage = l10n.err_somethingWentWrong;

      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage = l10n.err_networkError;
      } else if (e.toString().contains('timeout')) {
        errorMessage = l10n.error_timeout;
      }

      state = state.copyWith(isSendingOtp: false, errorMessage: errorMessage);
    }
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  bool validatePhone() {
    // Delegate to new method
    return validatePhoneNumber();
  }

  /// Validates that OTP is 6 digits
  bool validateOtp() {
    final l10n = _l10n();
    if (state.otp.isEmpty) {
      state = state.copyWith(errorMessage: l10n.validation_requiredField);
      return false;
    }

    // Remove any non-digit characters
    final cleanOtp = state.otp.replaceAll(RegExp(r'\D'), '');

    if (cleanOtp.length < AppConstants.otpLength) {
      state = state.copyWith(errorMessage: l10n.validation_invalidFormat);
      return false;
    }

    if (cleanOtp.length > AppConstants.otpLength) {
      state = state.copyWith(errorMessage: l10n.validation_invalidFormat);
      return false;
    }

    // Check if OTP contains only digits
    if (!RegExp(r'^\d+$').hasMatch(cleanOtp)) {
      state = state.copyWith(errorMessage: l10n.validation_invalidFormat);
      return false;
    }

    return true;
  }

  /// Verifies OTP with Firebase and validates account with backend
  Future<void> verifyOtp({
    required void Function(Account account) onAlreadyRegistered,
    required VoidCallback onNotRegistered,
  }) async {
    if (!validateOtp()) {
      return;
    }

    // Check if we have a verification ID from Firebase
    if (state.verificationId == null) {
      final l10n = _l10n();
      state = state.copyWith(errorMessage: l10n.err_somethingWentWrong);
      return;
    }

    state = state.copyWith(
      isVerifyingOtp: true,
      loading: true, // Legacy field
      errorMessage: null,
    );

    try {
      // Add timeout wrapper for OTP verification
      await Future.any([
        _verifyOtpWithTimeout(
          onAlreadyRegistered: onAlreadyRegistered,
          onNotRegistered: onNotRegistered,
        ),
        Future.delayed(const Duration(seconds: 30)).then((_) {
          // Timeout after 30 seconds
          if (state.isVerifyingOtp) {
            final l10n = _l10n();
            state = state.copyWith(
              isVerifyingOtp: false,
              loading: false,
              errorMessage: l10n.error_timeout,
            );
          }
        }),
      ]);
    } catch (e) {
      // Handle unexpected errors
      final l10n = _l10n();
      String errorMessage = l10n.err_somethingWentWrong;

      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage = l10n.err_networkError;
      }

      state = state.copyWith(
        isVerifyingOtp: false,
        loading: false,
        errorMessage: errorMessage,
      );
    }
  }

  /// Internal method to verify OTP with Firebase
  Future<void> _verifyOtpWithTimeout({
    required void Function(Account account) onAlreadyRegistered,
    required VoidCallback onNotRegistered,
  }) async {
    // Step 1: Verify OTP with Firebase
    final firebaseResult = await _firebaseAuthRepo.verifyOtp(
      verificationId: state.verificationId!,
      smsCode: state.otp,
    );

    // Handle Firebase verification failure
    await firebaseResult.when(
      onSuccess: (userCredential) async {
        // Firebase verification successful, now validate with backend
        await _validateWithBackend(
          onAlreadyRegistered: onAlreadyRegistered,
          onNotRegistered: onNotRegistered,
        );
      },
      onFailure: (failure) {
        // Firebase verification failed with specific error handling
        String errorMessage = failure.message;
        final l10n = _l10n();

        // Provide more context for specific error types
        if (failure.code == 401) {
          errorMessage = l10n.validation_invalidFormat;
        } else if (failure.code == 408) {
          errorMessage = l10n.error_timeout;
        } else if (failure.code == 429) {
          errorMessage = l10n.msg_tryAgainLater;
        } else if (failure.code == 503) {
          errorMessage = l10n.err_networkError;
        }

        state = state.copyWith(
          isVerifyingOtp: false,
          loading: false, // Legacy field
          errorMessage: errorMessage,
        );
      },
    );
  }

  /// Internal method to validate account with backend after Firebase success
  Future<void> _validateWithBackend({
    required void Function(Account account) onAlreadyRegistered,
    required VoidCallback onNotRegistered,
  }) async {
    // Cancel timer when Firebase verification is successful
    _timer?.cancel();

    // Update state to show backend validation is in progress
    state = state.copyWith(isValidatingAccount: true);

    // Use fullPhoneNumber (E.164 format) for backend validation
    final phoneToValidate = state.fullPhoneNumber.isNotEmpty
        ? state.fullPhoneNumber
        : state.phoneNumber;

    try {
      // Add timeout wrapper for backend validation
      await Future.any([
        _performBackendValidation(
          phoneToValidate: phoneToValidate,
          onAlreadyRegistered: onAlreadyRegistered,
          onNotRegistered: onNotRegistered,
        ),
        Future.delayed(const Duration(seconds: 30)).then((_) {
          // Timeout after 30 seconds
          if (state.isValidatingAccount) {
            final l10n = _l10n();
            state = state.copyWith(
              isVerifyingOtp: false,
              isValidatingAccount: false,
              loading: false,
              errorMessage: l10n.error_timeout,
            );
          }
        }),
      ]);
    } catch (e) {
      // Handle unexpected errors during backend validation
      final l10n = _l10n();
      String errorMessage = l10n.err_somethingWentWrong;

      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage = l10n.err_networkError;
      }

      state = state.copyWith(
        isVerifyingOtp: false,
        isValidatingAccount: false,
        loading: false,
        errorMessage: errorMessage,
      );
    }
  }

  /// Performs the actual backend validation
  Future<void> _performBackendValidation({
    required String phoneToValidate,
    required void Function(Account account) onAlreadyRegistered,
    required VoidCallback onNotRegistered,
  }) async {
    // Step 2: Validate account with backend
    final validateAccountByPhoneResult = await _authRepo.validateAccountByPhone(
      phoneToValidate,
    );

    validateAccountByPhoneResult.when(
      onSuccess: (auth) async {
        // Account exists - store tokens and account data
        state = state.copyWith(
          isVerifyingOtp: false,
          isValidatingAccount: false,
          loading: false, // Legacy field
          account: auth.account,
          user: auth.account, // Legacy field
          tokens: auth.tokens,
          errorMessage: null,
          showSuccessFeedback: true,
        );

        // Update local storage with auth data
        if (auth.account.membership != null) {
          await updateLocallySavedAuth(auth);
        }

        // Show success feedback briefly before navigation
        await Future.delayed(const Duration(milliseconds: 800));

        // Reset success feedback
        state = state.copyWith(showSuccessFeedback: false);

        // Navigate to home screen
        onAlreadyRegistered(auth.account);
      },
      onFailure: (failure) async {
        // Handle different failure scenarios with specific error messages
        if (failure.code == 404 || failure.message.contains('not found')) {
          // Account not found - new user, navigate to registration
          state = state.copyWith(
            isVerifyingOtp: false,
            isValidatingAccount: false,
            loading: false, // Legacy field
            errorMessage: null,
            showSuccessFeedback: true,
          );

          // Show success feedback briefly before navigation
          await Future.delayed(const Duration(milliseconds: 800));

          // Reset success feedback
          state = state.copyWith(showSuccessFeedback: false);

          onNotRegistered();
          return;
        }

        // Handle specific backend error codes
        String errorMessage = failure.message;
        final l10n = _l10n();

        if (failure.code == 500) {
          errorMessage = l10n.err_serverError;
        } else if (failure.code == 503) {
          errorMessage = l10n.err_serverError;
        } else if (failure.code == 408 || failure.code == 504) {
          errorMessage = l10n.error_timeout;
        } else if (failure.message.contains('network') ||
            failure.message.contains('connection')) {
          errorMessage = l10n.error_connectionFailed;
        }

        // Other backend errors - show error message with retry option
        state = state.copyWith(
          isVerifyingOtp: false,
          isValidatingAccount: false,
          loading: false,
          errorMessage: errorMessage,
          account: null,
          user: null, // Legacy field
        );
      },
    );
  }

  void reset() {
    _timer?.cancel();
    state = const AuthenticationState();
  }

  Future<void> updateLocallySavedAuth(AuthResponse auth) async {
    await _authRepo.updateLocallySavedAuth(auth);
  }
}
