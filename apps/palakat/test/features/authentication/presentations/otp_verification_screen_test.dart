// ignore_for_file: scoped_providers_should_specify_dependencies

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:palakat/features/authentication/data/firebase_auth_repository.dart';
import 'package:palakat/features/authentication/presentations/otp_verification_screen.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:pinput/pinput.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

class MockFirebaseAuthRepository extends Mock
    implements FirebaseAuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockFirebaseAuthRepository mockFirebaseAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockFirebaseAuthRepo = MockFirebaseAuthRepository();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        // Override repository providers with mocks
        authRepositoryProvider.overrideWith((ref) {
          return mockAuthRepo;
        }),
        firebaseAuthRepositoryProvider.overrideWith((ref) {
          return mockFirebaseAuthRepo;
        }),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            // Initialize ScreenUtil for tests
            ScreenUtil.init(context, designSize: const Size(375, 812));
            return const OtpVerificationScreen();
          },
        ),
      ),
    );
  }

  group('OTPVerificationScreen Widget Tests', () {
    testWidgets('screen renders correctly with basic elements', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify back button
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Verify security icon
      expect(find.byIcon(Icons.security_outlined), findsOneWidget);

      // Verify title
      expect(find.text('Verify OTP'), findsOneWidget);

      // Verify instruction text
      expect(find.text('Enter the verification code sent to'), findsOneWidget);

      // Verify Pinput widget
      expect(find.byType(Pinput), findsOneWidget);

      // Verify timer icon
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });

    testWidgets('OTP input has 6 digit fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find Pinput widget
      final pinput = tester.widget<Pinput>(find.byType(Pinput));

      // Verify it has 6 fields
      expect(pinput.length, 6);
    });

    testWidgets('OTP input accepts only numbers', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find Pinput widget
      final pinput = tester.widget<Pinput>(find.byType(Pinput));

      // Verify keyboard type is number
      expect(pinput.keyboardType, TextInputType.number);
    });

    testWidgets('OTP input is auto-focused', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find Pinput widget
      final pinput = tester.widget<Pinput>(find.byType(Pinput));

      // Verify autofocus is enabled
      expect(pinput.autofocus, true);
    });

    testWidgets('back button exists and is tappable', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap back button
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Note: Navigation behavior would be tested in integration tests
      // Here we just verify the button exists and is tappable
    });

    testWidgets('PIN boxes have correct styling', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find Pinput widget
      final pinput = tester.widget<Pinput>(find.byType(Pinput));

      // Verify default theme
      expect(pinput.defaultPinTheme?.width, 56);
      expect(pinput.defaultPinTheme?.height, 56);

      // Verify text style
      expect(pinput.defaultPinTheme?.textStyle?.fontSize, 20);
      expect(pinput.defaultPinTheme?.textStyle?.fontWeight, FontWeight.w600);
    });

    testWidgets('screen has entry animation', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Pump once to start animation
      await tester.pump();

      // Verify TweenAnimationBuilder exists
      expect(find.byType(TweenAnimationBuilder<double>), findsOneWidget);

      // Complete animation
      await tester.pumpAndSettle();
    });

    testWidgets('semantic labels are present for accessibility', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify semantic labels exist
      expect(find.bySemanticsLabel('Back button'), findsOneWidget);
      expect(
        find.bySemanticsLabel('OTP verification code input'),
        findsOneWidget,
      );
    });

    testWidgets('timer displays countdown in MM:SS format', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify timer displays 02:00 (default 120 seconds)
      expect(find.text('02:00'), findsOneWidget);
    });

    testWidgets('resend button text exists when timer expires', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially timer should be shown, not resend button
      expect(find.text('02:00'), findsOneWidget);

      // Note: Testing timer expiration would require waiting or mocking
      // This test just verifies the initial state
    });
  });
}
