import 'dart:async';

import 'package:flutter/material.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/models/models.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'authentication_controller.g.dart';

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

  void onChangedTextPhone(String value) {
    state = state.copyWith(
      phone: value,
      isFormValid: value.isNotEmpty,
      errorMessage: null,
    );
  }

  void onChangedOtp(String value) {
    state = state.copyWith(otp: value, errorMessage: null);
  }

  void showOtpVerification() {
    if (state.phone.isEmpty) {
      state = state.copyWith(errorMessage: "Please fill phone number");
      return;
    }

    state = state.copyWith(showOtpVerification: true);
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();

    state = state.copyWith(
      remainingTime: AppConstants.otpTimerDurationInSeconds,
      canResendOtp: false,
    );

    _timer = Timer.periodic(AppConstants.timerInterval, (timer) {
      if (state.remainingTime > 0) {
        state = state.copyWith(remainingTime: state.remainingTime - 1);
      } else {
        timer.cancel();
        state = state.copyWith(canResendOtp: true);
      }
    });
  }

  void resendOtp() {
    if (state.canResendOtp) {
      startTimer();
      state = state.copyWith(errorMessage: "OTP code resent!");
    }
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  bool validatePhone() {
    if (state.phone.isEmpty) {
      state = state.copyWith(errorMessage: "Please fill phone number");
      return false;
    }
    return true;
  }

  bool validateOtp() {
    if (state.otp.length < AppConstants.otpLength) {
      state = state.copyWith(
        loading: false,
        errorMessage: "Please enter complete OTP",
      );
      return false;
    }
    return true;
  }

  Future<bool> sendOtp() async {
    if (!validatePhone()) return false;

    state = state.copyWith(loading: true, errorMessage: null);

    try {
      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(loading: false);
      showOtpVerification();
      return true;
    } catch (e) {
      state = state.copyWith(
        loading: false,
        errorMessage: "Failed to send OTP: ${e.toString()}",
      );
      return false;
    }
  }

  void verifyOtp({
    required void Function(Account account) onAlreadyRegistered,
    required VoidCallback onNotRegistered,
  }) async {
    if (!validateOtp()) {
      return;
    }

    state = state.copyWith(loading: true, errorMessage: null);

    //Dummy OTP verification using demo code - TODO: Replace with real OTP service
    await Future.delayed(const Duration(milliseconds: 500));
    final otpVerified = state.otp == AppConstants.demoOtpCode;

    if (!otpVerified) {
      state = state.copyWith(loading: false, errorMessage: "Invalid OTP code");
      return;
    }

    // Cancel timer when verification is successful
    _timer?.cancel();

    final validateAccountByPhoneResult = await _authRepo
        .validateAccountByPhone(state.phone);
    validateAccountByPhoneResult.when(
      onSuccess: (auth) async {
        state = state.copyWith(
          loading: false,
          user: auth.account,
          errorMessage: null,
        );
        if (auth.account.membership != null) {
          updateLocallySavedAuth(auth);
        }
        onAlreadyRegistered(auth.account);
      },
      onFailure: (failure) {
        if (failure.code == 404) {
          onNotRegistered();
          return;
        }

        state = state.copyWith(
          loading: false,
          errorMessage: failure.message,
          user: null,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void reset() {
    _timer?.cancel();
    state = const AuthenticationState();
  }

  void updateLocallySavedAuth(AuthResponse auth)async {
     await _authRepo.updateLocallySavedAuth(auth);
  }

 
}
