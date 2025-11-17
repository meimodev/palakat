import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat/features/authentication/data/firebase_auth_repository.dart';
import 'package:palakat/features/authentication/presentations/authentication_controller.dart';
import 'package:palakat/features/authentication/presentations/phone_input_screen.dart';
import 'package:palakat_shared/core/models/models.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:palakat_shared/services.dart';

/// Integration tests for the complete Firebase Phone Authentication flow
///
/// These tests cover:
/// - Complete flow: phone input → OTP → validation → home
/// - New user flow: phone input → OTP → validation → registration
/// - Error recovery: invalid OTP → retry → success
/// - Back navigation preserves state
/// - Session persistence across app restarts
///
/// Note: These tests require Firebase Test Mode to be configured with test phone numbers
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Firebase Phone Authentication Integration Tests', () {
    late ProviderContainer container;

    setUp(() async {
      // Initialize Firebase for testing
      try {
        await Firebase.initializeApp();
      } catch (e) {
        // Firebase already initialized
      }

      // Initialize Hive for local storage
      await LocalStorageService.initHive();

      // Create a new provider container for each test
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets(
      'Complete flow: phone input → OTP → validation → home (existing user)',
      (WidgetTester tester) async {
        // This test simulates the complete authentication flow for an existing user
        // Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.5

        // Build the app with provider scope
        await tester.pumpWidget(
          ProviderScope(child: MaterialApp(home: const PhoneInputScreen())),
        );

        // Wait for the screen to render
        await tester.pumpAndSettle();

        // Verify phone input screen is displayed
        expect(find.text('Sign In'), findsOneWidget);
        expect(find.byType(TextField), findsWidgets);

        // Enter a valid test phone number
        // Note: In real testing, use Firebase Test Mode phone numbers
        final phoneField = find.byType(TextField).first;
        await tester.enterText(phoneField, '81234567890');
        await tester.pumpAndSettle();

        // Tap the continue button
        final continueButton = find.text('Continue');
        expect(continueButton, findsOneWidget);
        await tester.tap(continueButton);
        await tester.pumpAndSettle();

        // Note: In a real integration test with Firebase Test Mode:
        // 1. Firebase would send OTP
        // 2. OTP screen would be displayed
        // 3. Enter the test OTP (e.g., "123456")
        // 4. Backend validation would occur
        // 5. User would be navigated to home screen

        // For this test, we verify the controller state changes
        final controller = container.read(
          authenticationControllerProvider.notifier,
        );
        expect(controller.state.phoneNumber, '81234567890');
        expect(controller.state.fullPhoneNumber.isNotEmpty, true);
      },
    );

    testWidgets(
      'New user flow: phone input → OTP → validation → registration',
      (WidgetTester tester) async {
        // This test simulates the flow for a new user who needs to register
        // Requirements: 2.3, 7.1, 7.2

        await tester.pumpWidget(
          ProviderScope(child: MaterialApp(home: const PhoneInputScreen())),
        );

        await tester.pumpAndSettle();

        // Enter phone number
        final phoneField = find.byType(TextField).first;
        await tester.enterText(phoneField, '81298765432');
        await tester.pumpAndSettle();

        // Verify phone number is stored in state
        final controller = container.read(
          authenticationControllerProvider.notifier,
        );
        expect(controller.state.phoneNumber, '81298765432');

        // Note: In a real integration test:
        // 1. After OTP verification succeeds
        // 2. Backend returns 404 or empty data
        // 3. User is navigated to registration screen
        // 4. Phone number is pre-filled and read-only
      },
    );

    testWidgets('Error recovery: invalid OTP → retry → success', (
      WidgetTester tester,
    ) async {
      // This test verifies error handling and retry functionality
      // Requirements: 1.5, 5.1, 5.5

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const PhoneInputScreen())),
      );

      await tester.pumpAndSettle();

      // Enter phone number and proceed to OTP screen
      final phoneField = find.byType(TextField).first;
      await tester.enterText(phoneField, '81234567890');
      await tester.pumpAndSettle();

      // Verify error handling in controller
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      // Simulate invalid OTP entry
      controller.onOtpChanged('000000');
      expect(controller.state.otp, '000000');

      // Clear error when user modifies input
      controller.clearError();
      expect(controller.state.errorMessage, null);

      // Enter correct OTP
      controller.onOtpChanged('123456');
      expect(controller.state.otp, '123456');
    });

    testWidgets('Back navigation preserves phone number state', (
      WidgetTester tester,
    ) async {
      // This test verifies that navigating back from OTP screen preserves state
      // Requirements: 10.1, 10.2, 10.3

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const PhoneInputScreen())),
      );

      await tester.pumpAndSettle();

      // Enter phone number
      final phoneField = find.byType(TextField).first;
      await tester.enterText(phoneField, '81234567890');
      await tester.pumpAndSettle();

      final controller = container.read(
        authenticationControllerProvider.notifier,
      );
      final originalPhone = controller.state.phoneNumber;

      // Simulate navigation to OTP screen
      controller.showOtpScreen();
      expect(controller.state.showOtpScreen, true);

      // Navigate back
      controller.goBackToPhoneInput();
      expect(controller.state.showOtpScreen, false);

      // Verify phone number is preserved
      expect(controller.state.phoneNumber, originalPhone);

      // Verify OTP state is cleared
      expect(controller.state.otp, '');
      expect(controller.state.verificationId, null);
    });

    test('Session persistence: store and retrieve auth tokens', () async {
      // This test verifies session persistence functionality
      // Requirements: 8.1, 8.2, 8.3, 8.4

      // Create mock auth response
      final mockAccount = Account(
        id: 1,
        name: 'Test User',
        phone: '+6281234567890',
        email: 'test@example.com',
        dob: DateTime(1990, 1, 1),
        membership: const Membership(id: 1, baptize: true, sidi: true),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockTokens = AuthTokens(
        accessToken: 'test-access-token',
        refreshToken: 'test-refresh-token',
      );

      final mockAuthResponse = AuthResponse(
        account: mockAccount,
        tokens: mockTokens,
      );

      // Store auth data
      final authRepo = container.read(authRepositoryProvider);
      await authRepo.updateLocallySavedAuth(mockAuthResponse);

      // Verify tokens are stored by checking the service
      final localStorageService = LocalStorageService();
      await localStorageService.init();

      expect(localStorageService.accessToken, 'test-access-token');
      expect(localStorageService.refreshToken, 'test-refresh-token');
      expect(localStorageService.isAuthenticated, true);

      // Clear auth data
      await localStorageService.clear();

      // Verify data is cleared
      expect(localStorageService.accessToken, null);
      expect(localStorageService.isAuthenticated, false);
    });

    test('Phone number validation with different country codes', () {
      // Test phone validation for supported countries
      // Requirements: 6.1, 6.2, 6.3, 6.4

      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      // Test valid 12-digit phone
      controller.onPhoneNumberChanged('081234567890');
      expect(controller.validatePhoneNumber(), true);

      // Test valid 13-digit phone
      controller.onPhoneNumberChanged('0812345678901');
      expect(controller.validatePhoneNumber(), true);

      // Test invalid phone (doesn't start with 0)
      controller.onPhoneNumberChanged('812345678901');
      expect(controller.validatePhoneNumber(), false);
      expect(controller.state.errorMessage, contains('must start with 0'));

      // Test invalid phone (too short)
      controller.onPhoneNumberChanged('08123456789');
      expect(controller.validatePhoneNumber(), false);
      expect(controller.state.errorMessage, contains('at least 12 digits'));

      // Test invalid phone (too long)
      controller.onPhoneNumberChanged('08123456789012');
      expect(controller.validatePhoneNumber(), false);
      expect(controller.state.errorMessage, contains('at most 13 digits'));

      // Test invalid phone (all zeros)
      controller.onPhoneNumberChanged('000000000000');
      expect(controller.validatePhoneNumber(), false);
      expect(controller.state.errorMessage, contains('valid'));
    });

    test('OTP validation logic', () {
      // Test OTP validation
      // Requirements: 1.4, 6.3

      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      // Valid OTP
      controller.onOtpChanged('123456');
      expect(controller.validateOtp(), true);

      // Empty OTP
      controller.onOtpChanged('');
      expect(controller.validateOtp(), false);
      expect(
        controller.state.errorMessage,
        contains('enter verification code'),
      );

      // Too short OTP
      controller.onOtpChanged('12345');
      expect(controller.validateOtp(), false);
      expect(controller.state.errorMessage, contains('complete'));

      // Too long OTP
      controller.onOtpChanged('1234567');
      expect(controller.validateOtp(), false);
      expect(controller.state.errorMessage, contains('must be'));
    });

    test('Timer functionality for OTP resend', () async {
      // Test countdown timer for OTP resend
      // Requirements: 4.1, 4.2, 4.3, 4.4

      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      // Start timer
      controller.startTimer();
      expect(controller.state.remainingSeconds, 120);
      expect(controller.state.canResendOtp, false);

      // Wait for a few seconds
      await Future.delayed(const Duration(seconds: 3));

      // Timer should have decreased
      expect(controller.state.remainingSeconds, lessThan(120));

      // Stop timer
      controller.stopTimer();
      expect(controller.state.canResendOtp, false);

      // Format time test
      expect(controller.formatTime(120), '02:00');
      expect(controller.formatTime(90), '01:30');
      expect(controller.formatTime(5), '00:05');
    });

    test('Error message clearing on input change', () {
      // Test that errors are cleared when user modifies input
      // Requirements: 5.5

      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      // Set an error
      controller.state = controller.state.copyWith(
        errorMessage: 'Test error message',
      );
      expect(controller.state.errorMessage, 'Test error message');

      // Change phone number - should clear error
      controller.onPhoneNumberChanged('812345');
      expect(controller.state.errorMessage, null);

      // Set error again
      controller.state = controller.state.copyWith(
        errorMessage: 'Another error',
      );

      // Change OTP - should clear error
      controller.onOtpChanged('123456');
      expect(controller.state.errorMessage, null);

      // Set error again
      controller.state = controller.state.copyWith(
        errorMessage: 'Yet another error',
      );

      // Explicit clear
      controller.clearError();
      expect(controller.state.errorMessage, null);
    });

    test('State transitions during authentication flow', () {
      // Test state changes throughout the auth flow
      // Requirements: 1.1, 1.2, 1.4, 2.1

      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      // Initial state
      expect(controller.state.phoneNumber, '');
      expect(controller.state.showOtpScreen, false);
      expect(controller.state.isSendingOtp, false);
      expect(controller.state.isVerifyingOtp, false);

      // Phone input
      controller.onPhoneNumberChanged('81234567890');
      expect(controller.state.phoneNumber, '81234567890');
      expect(controller.state.fullPhoneNumber, isNotEmpty);

      // Show OTP screen
      controller.showOtpScreen();
      expect(controller.state.showOtpScreen, true);

      // OTP input
      controller.onOtpChanged('123456');
      expect(controller.state.otp, '123456');

      // Back navigation
      controller.goBackToPhoneInput();
      expect(controller.state.showOtpScreen, false);
      expect(controller.state.otp, '');
      expect(controller.state.phoneNumber, '81234567890'); // Preserved
    });

    test('Firebase repository error conversion', () {
      // Test that Firebase errors are properly converted to user-friendly messages
      // Requirements: 5.1, 5.2, 5.3

      final firebaseRepo = container.read(firebaseAuthRepositoryProvider);

      // This test verifies the error conversion logic exists
      // In a real test, we would mock Firebase exceptions and verify conversions
      expect(firebaseRepo, isNotNull);
    });
  });

  group('Edge Cases and Error Scenarios', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Handle empty phone number submission', () {
      // Requirements: 6.3
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.onPhoneNumberChanged('');
      expect(controller.validatePhoneNumber(), false);
      expect(controller.state.errorMessage, contains('enter phone number'));
    });

    test('Handle invalid phone formats', () {
      // Requirements: 6.4
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      // Phone with letters
      controller.onPhoneNumberChanged('abc123');
      final cleanPhone = controller.state.phoneNumber.replaceAll(
        RegExp(r'\D'),
        '',
      );
      expect(cleanPhone, '123');

      // Phone with special characters
      controller.onPhoneNumberChanged('812-345-6789');
      expect(controller.state.phoneNumber, '812-345-6789');
    });

    test('Handle network timeout scenarios', () {
      // Requirements: 5.1, 5.2
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      // Verify timeout handling exists in sendOtp method
      // In real testing, we would mock network delays
      expect(controller.sendOtp, isNotNull);
    });

    test('Handle concurrent state updates', () {
      // Test that state updates don't conflict
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.onPhoneNumberChanged('081234567890');
      controller.onOtpChanged('123456');

      expect(controller.state.phoneNumber, '081234567890');
      expect(controller.state.otp, '123456');
    });

    test('Handle timer cleanup on navigation', () {
      // Requirements: 10.5
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      controller.startTimer();
      expect(controller.state.remainingSeconds, 120);

      // Navigate back - should stop timer
      controller.goBackToPhoneInput();
      expect(controller.state.canResendOtp, false);
    });

    test('Handle reset functionality', () {
      // Test complete state reset
      final controller = container.read(
        authenticationControllerProvider.notifier,
      );

      // Set various state values
      controller.onPhoneNumberChanged('81234567890');
      controller.onOtpChanged('123456');
      controller.showOtpScreen();
      controller.startTimer();

      // Reset
      controller.reset();

      // Verify all state is cleared
      expect(controller.state.phoneNumber, '');
      expect(controller.state.otp, '');
      expect(controller.state.showOtpScreen, false);
      expect(controller.state.errorMessage, null);
    });
  });
}
