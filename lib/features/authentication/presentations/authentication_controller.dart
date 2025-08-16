import 'dart:async';

import 'package:palakat/features/presentation.dart';
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

  void hideOtpVerification() {
    _timer?.cancel();
    state = state.copyWith(
      showOtpVerification: false,
      otp: '',
      remainingTime: 120,
      canResendOtp: false,
      errorMessage: null,
    );
  }

  void startTimer() {
    _timer?.cancel();

    state = state.copyWith(remainingTime: 120, canResendOtp: false);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    if (state.otp.length < 6) {
      state = state.copyWith(errorMessage: "Please enter complete OTP");
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

  Future<bool> verifyOtp() async {
    if (!validateOtp()) return false;

    state = state.copyWith(loading: true, errorMessage: null);

    try {
      await Future.delayed(const Duration(seconds: 1));
      final success = state.otp == "123456";

      if (!success) {
        state = state.copyWith(
          loading: false,
          errorMessage: "Invalid OTP code",
        );
        return false;
      }

      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        loading: false,
        errorMessage: "Verification failed: ${e.toString()}",
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void reset() {
    _timer?.cancel();
    state = const AuthenticationState();
  }
}
