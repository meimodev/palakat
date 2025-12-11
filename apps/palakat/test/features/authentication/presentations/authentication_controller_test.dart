import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:palakat/features/authentication/data/firebase_auth_repository.dart';
import 'package:palakat/features/authentication/presentations/authentication_controller.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

class MockFirebaseAuthRepository extends Mock
    implements FirebaseAuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockFirebaseAuthRepository mockFirebaseAuthRepo;
  late ProviderContainer container;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockFirebaseAuthRepo = MockFirebaseAuthRepository();

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepo),
        firebaseAuthRepositoryProvider.overrideWithValue(mockFirebaseAuthRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthenticationController - Phone Number Validation', () {
    test('initial state has default values', () {
      final controller = container.read(authenticationControllerProvider);

      expect(controller.phoneNumber, '');
      expect(controller.fullPhoneNumber, '');
      expect(controller.errorMessage, null);
    });

    test('onPhoneNumberChanged updates phone number and clears error', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.onPhoneNumberChanged('081234567890');

      final state = container.read(authenticationControllerProvider);
      expect(state.phoneNumber, '081234567890');
      expect(state.fullPhoneNumber, '+6281234567890');
      expect(state.errorMessage, null);
    });

    test('validatePhoneNumber returns false for empty phone', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      final isValid = controller.validatePhoneNumber();

      expect(isValid, false);
      final state = container.read(authenticationControllerProvider);
      expect(state.errorMessage, 'Please enter phone number');
    });

    test(
      'validatePhoneNumber returns false for too short Indonesian phone',
      () {
        final controller = container.read(
          authenticationControllerProvider.notifier,
        );

        controller.onPhoneNumberChanged('812345');

        final isValid = controller.validatePhoneNumber();

        expect(isValid, false);
        final state = container.read(authenticationControllerProvider);
        expect(state.errorMessage, contains('too short'));
      },
    );

    test('validatePhoneNumber returns false for too long Indonesian phone', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.onPhoneNumberChanged('81234567890123456');

      final isValid = controller.validatePhoneNumber();

      expect(isValid, false);
      final state = container.read(authenticationControllerProvider);
      expect(state.errorMessage, contains('too long'));
    });

    test('validatePhoneNumber returns false for all zeros', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.onPhoneNumberChanged('000000000');

      final isValid = controller.validatePhoneNumber();

      expect(isValid, false);
      final state = container.read(authenticationControllerProvider);
      expect(state.errorMessage, contains('valid phone number'));
    });

    test('validatePhoneNumber returns false for repeating digits', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.onPhoneNumberChanged('111111111');

      final isValid = controller.validatePhoneNumber();

      expect(isValid, false);
      final state = container.read(authenticationControllerProvider);
      expect(state.errorMessage, 'Please enter a valid phone number');
    });

    test('validatePhoneNumber returns true for valid Indonesian phone', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.onPhoneNumberChanged('81234567890');

      final isValid = controller.validatePhoneNumber();

      expect(isValid, true);
      final state = container.read(authenticationControllerProvider);
      expect(state.errorMessage, null);
    });

    test('validatePhoneNumber handles phone with leading zero', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.onPhoneNumberChanged('081234567890');

      final isValid = controller.validatePhoneNumber();

      expect(isValid, true);
    });

    test('validatePhoneNumber rejects phone not starting with 0', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.onPhoneNumberChanged('812345678901');

      final isValid = controller.validatePhoneNumber();

      expect(isValid, false);
      final state = container.read(authenticationControllerProvider);
      expect(state.errorMessage, 'Phone number must start with 0');
    });

    test('validatePhoneNumber rejects phone shorter than 12 digits', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.onPhoneNumberChanged('08123456789');

      final isValid = controller.validatePhoneNumber();

      expect(isValid, false);
      final state = container.read(authenticationControllerProvider);
      expect(state.errorMessage, 'Phone number must be at least 12 digits');
    });

    test('validatePhoneNumber rejects phone longer than 13 digits', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.onPhoneNumberChanged('08123456789012');

      final isValid = controller.validatePhoneNumber();

      expect(isValid, false);
      final state = container.read(authenticationControllerProvider);
      expect(state.errorMessage, 'Phone number must be at most 13 digits');
    });

    test('validatePhoneNumber accepts valid 12-digit phone', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.onPhoneNumberChanged('081234567890');

      final isValid = controller.validatePhoneNumber();

      expect(isValid, true);
    });

    test('validatePhoneNumber accepts valid 13-digit phone', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.onPhoneNumberChanged('0812345678901');

      final isValid = controller.validatePhoneNumber();

      expect(isValid, true);
    });
  });

  group('AuthenticationController - OTP Validation', () {
    test('validateOtp returns false for empty OTP', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      final isValid = controller.validateOtp();

      expect(isValid, false);
      final state = container.read(authenticationControllerProvider);
      expect(state.errorMessage, 'Please enter verification code');
    });

    test('validateOtp returns false for incomplete OTP', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.onOtpChanged('123');

      final isValid = controller.validateOtp();

      expect(isValid, false);
      final state = container.read(authenticationControllerProvider);
      expect(state.errorMessage, contains('complete'));
    });

    test('validateOtp returns false for too long OTP', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.onOtpChanged('1234567');

      final isValid = controller.validateOtp();

      expect(isValid, false);
      final state = container.read(authenticationControllerProvider);
      expect(state.errorMessage, contains('must be'));
    });

    test('validateOtp returns false for non-numeric OTP', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.onOtpChanged('12a456');

      final isValid = controller.validateOtp();

      expect(isValid, false);
      final state = container.read(authenticationControllerProvider);
      // The validation treats non-numeric as incomplete since it strips non-digits
      expect(state.errorMessage, isNotNull);
    });

    test('validateOtp returns true for valid 6-digit OTP', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.onOtpChanged('123456');

      final isValid = controller.validateOtp();

      expect(isValid, true);
      final state = container.read(authenticationControllerProvider);
      expect(state.errorMessage, null);
    });

    test('onOtpChanged updates OTP and clears error', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.onOtpChanged('123456');

      final state = container.read(authenticationControllerProvider);
      expect(state.otp, '123456');
      expect(state.errorMessage, null);
    });
  });

  group('AuthenticationController - Timer Functionality', () {
    test('startTimer sets initial countdown to 120 seconds', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.startTimer();

      final state = container.read(authenticationControllerProvider);
      expect(state.remainingSeconds, 120);
      expect(state.canResendOtp, false);
    });

    test('timer counts down correctly', () async {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.startTimer();

      // Wait for a few ticks (need to wait longer for timer to actually tick)
      await Future.delayed(const Duration(milliseconds: 1500));

      final state = container.read(authenticationControllerProvider);
      expect(state.remainingSeconds, lessThanOrEqualTo(120));
      expect(state.remainingSeconds, greaterThanOrEqualTo(118));
    });

    test('stopTimer sets canResendOtp to false', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.startTimer();
      controller.stopTimer();

      // Timer should be stopped and canResendOtp should be false
      final state = container.read(authenticationControllerProvider);
      expect(state.canResendOtp, false);
    });

    test('formatTime formats seconds correctly', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      expect(controller.formatTime(120), '02:00');
      expect(controller.formatTime(90), '01:30');
      expect(controller.formatTime(59), '00:59');
      expect(controller.formatTime(0), '00:00');
      expect(controller.formatTime(5), '00:05');
    });
  });

  group('AuthenticationController - State Transitions', () {
    test('showOtpScreen sets showOtpScreen to true', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.showOtpScreen();

      final state = container.read(authenticationControllerProvider);
      expect(state.showOtpScreen, true);
    });

    test('goBackToPhoneInput resets OTP state but preserves phone', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      // Set up state
      controller.onPhoneNumberChanged('81234567890');
      controller.onOtpChanged('123456');
      controller.showOtpScreen();
      controller.startTimer();

      // Go back
      controller.goBackToPhoneInput();

      final state = container.read(authenticationControllerProvider);
      expect(state.showOtpScreen, false);
      expect(state.otp, '');
      expect(state.phoneNumber, '81234567890'); // Phone preserved
      expect(state.errorMessage, null);
    });

    test('clearError clears error message', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      // Set an error
      controller.validatePhoneNumber(); // Will set error for empty phone

      var state = container.read(authenticationControllerProvider);
      expect(state.errorMessage, isNotNull);

      // Clear error
      controller.clearError();

      state = container.read(authenticationControllerProvider);
      expect(state.errorMessage, null);
    });

    test('reset clears all state', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      // Set up state
      controller.onPhoneNumberChanged('81234567890');
      controller.onOtpChanged('123456');
      controller.showOtpScreen();

      // Reset
      controller.reset();

      final state = container.read(authenticationControllerProvider);
      expect(state.phoneNumber, '');
      expect(state.otp, '');
      expect(state.showOtpScreen, false);
      expect(state.errorMessage, null);
    });
  });

  group('AuthenticationController - Error Handling', () {
    test('phone validation error is set correctly', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.validatePhoneNumber();

      final state = container.read(authenticationControllerProvider);
      expect(state.errorMessage, isNotNull);
      expect(state.errorMessage, contains('phone'));
    });

    test('OTP validation error is set correctly', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.validateOtp();

      final state = container.read(authenticationControllerProvider);
      expect(state.errorMessage, isNotNull);
      expect(state.errorMessage, contains('verification code'));
    });

    test('error is cleared when phone number changes', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      // Set error
      controller.validatePhoneNumber();
      var state = container.read(authenticationControllerProvider);
      expect(state.errorMessage, isNotNull);

      // Change phone number
      controller.onPhoneNumberChanged('812');

      state = container.read(authenticationControllerProvider);
      expect(state.errorMessage, null);
    });

    test('error is cleared when OTP changes', () {
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      // Set error
      controller.validateOtp();
      var state = container.read(authenticationControllerProvider);
      expect(state.errorMessage, isNotNull);

      // Change OTP
      controller.onOtpChanged('123');

      state = container.read(authenticationControllerProvider);
      expect(state.errorMessage, null);
    });
  });

  group('AuthenticationController - Loading States', () {
    test('initial loading states are false', () {
      final state = container.read(authenticationControllerProvider);

      expect(state.isSendingOtp, false);
      expect(state.isVerifyingOtp, false);
      expect(state.isValidatingAccount, false);
    });
  });
}
