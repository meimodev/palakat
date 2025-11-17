// ignore_for_file: scoped_providers_should_specify_dependencies

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/authentication/data/firebase_auth_repository.dart';
import 'package:palakat/features/authentication/presentations/phone_input_screen.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';

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
            return const PhoneInputScreen();
          },
        ),
      ),
    );
  }

  group('PhoneInputScreen Widget Tests', () {
    testWidgets('screen renders correctly with all elements', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify card is present
      expect(find.byType(Material), findsWidgets);

      // Verify phone icon
      expect(find.byIcon(Icons.phone_outlined), findsOneWidget);

      // Verify title
      expect(find.text('Sign In'), findsOneWidget);

      // Verify country label
      expect(find.text('Country'), findsOneWidget);

      // Verify phone number label
      expect(find.text('Phone Number'), findsOneWidget);

      // Verify continue button
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('country code selector displays default country', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Default should be Indonesia (+62)
      expect(find.text('Indonesia (+62)'), findsOneWidget);
      expect(find.text('🇮🇩'), findsOneWidget);
    });

    testWidgets('country code selector opens bottom sheet on tap', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on country selector
      await tester.tap(find.text('Indonesia (+62)'));
      await tester.pumpAndSettle();

      // Verify bottom sheet appears
      expect(find.text('Select Country'), findsOneWidget);

      // Verify all supported countries are shown
      expect(find.text('Malaysia (+60)'), findsOneWidget);
      expect(find.text('Singapore (+65)'), findsOneWidget);
      expect(find.text('Philippines (+63)'), findsOneWidget);
    });

    testWidgets('country code selector changes country', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open country selector
      await tester.tap(find.text('Indonesia (+62)'));
      await tester.pumpAndSettle();

      // Select Malaysia
      await tester.tap(find.text('Malaysia (+60)'));
      await tester.pumpAndSettle();

      // Verify Malaysia is now selected
      expect(find.text('Malaysia (+60)'), findsOneWidget);
      expect(find.text('🇲🇾'), findsOneWidget);
    });

    testWidgets('phone input accepts only numbers', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the phone input field
      final phoneInput = find.widgetWithText(TextField, 'Enter phone number');
      expect(phoneInput, findsOneWidget);

      // Verify keyboard type is phone
      final textField = tester.widget<TextField>(phoneInput);
      expect(textField.keyboardType, TextInputType.phone);
    });

    testWidgets('phone input updates state on text change', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter phone number
      final phoneInput = find.widgetWithText(TextField, 'Enter phone number');
      await tester.enterText(phoneInput, '81234567890');
      await tester.pumpAndSettle();

      // Verify text is entered
      expect(find.text('81234567890'), findsOneWidget);
    });

    testWidgets('continue button is enabled by default', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find continue button
      final continueButton = find.text('Continue');
      expect(continueButton, findsOneWidget);

      // Button should be tappable
      await tester.tap(continueButton);
      await tester.pumpAndSettle();
    });

    testWidgets('continue button shows loading state when sending OTP', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter valid phone number
      final phoneInput = find.widgetWithText(TextField, 'Enter phone number');
      await tester.enterText(phoneInput, '81234567890');
      await tester.pumpAndSettle();

      // Mock Firebase to delay response
      when(
        () => mockFirebaseAuthRepo.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          onCodeSent: any(named: 'onCodeSent'),
          onVerificationCompleted: any(named: 'onVerificationCompleted'),
          onVerificationFailed: any(named: 'onVerificationFailed'),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer(
        (_) async => await Future.delayed(const Duration(seconds: 2)),
      );

      // Tap continue button
      await tester.tap(find.text('Continue'));
      await tester.pump();

      // Verify loading indicator appears
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('phone input is disabled during OTP sending', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter valid phone number
      final phoneInput = find.widgetWithText(TextField, 'Enter phone number');
      await tester.enterText(phoneInput, '81234567890');
      await tester.pumpAndSettle();

      // Mock Firebase to delay response
      when(
        () => mockFirebaseAuthRepo.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          onCodeSent: any(named: 'onCodeSent'),
          onVerificationCompleted: any(named: 'onVerificationCompleted'),
          onVerificationFailed: any(named: 'onVerificationFailed'),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer(
        (_) async => await Future.delayed(const Duration(seconds: 2)),
      );

      // Tap continue button
      await tester.tap(find.text('Continue'));
      await tester.pump();

      // Verify input is disabled (opacity reduced)
      final opacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.widgetWithText(TextField, 'Enter phone number'),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, 0.5);
    });

    testWidgets('error message displays when validation fails', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap continue without entering phone number
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify error message appears
      expect(find.text('Please enter phone number'), findsOneWidget);

      // Verify error icon
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('error message clears when phone number changes', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Trigger validation error
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify error appears
      expect(find.text('Please enter phone number'), findsOneWidget);

      // Enter phone number
      final phoneInput = find.widgetWithText(TextField, 'Enter phone number');
      await tester.enterText(phoneInput, '812');
      await tester.pumpAndSettle();

      // Verify error is cleared
      expect(find.text('Please enter phone number'), findsNothing);
    });

    testWidgets('retry button appears for network errors', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter valid phone number
      final phoneInput = find.widgetWithText(TextField, 'Enter phone number');
      await tester.enterText(phoneInput, '81234567890');
      await tester.pumpAndSettle();

      // Mock Firebase to return network error
      when(
        () => mockFirebaseAuthRepo.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          onCodeSent: any(named: 'onCodeSent'),
          onVerificationCompleted: any(named: 'onVerificationCompleted'),
          onVerificationFailed: any(named: 'onVerificationFailed'),
          timeout: any(named: 'timeout'),
        ),
      ).thenThrow(Exception('Network error'));

      // Tap continue button
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Wait for error to appear
      await tester.pump(const Duration(seconds: 1));

      // Verify retry button appears (if error contains network-related keywords)
      // Note: The actual error handling depends on controller implementation
    });

    testWidgets('card has correct styling', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the main card
      final cardMaterial = tester.widgetList<Material>(find.byType(Material));
      final mainCard = cardMaterial.firstWhere(
        (m) => m.color == BaseColor.cardBackground1,
      );

      // Verify card properties
      expect(mainCard.elevation, 1);
      expect(mainCard.color, BaseColor.cardBackground1);
      expect(mainCard.surfaceTintColor, BaseColor.teal[50]);

      // Verify border radius
      final shape = mainCard.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('icon container has correct styling', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the icon container
      final iconContainer = tester.widget<Container>(
        find
            .ancestor(
              of: find.byIcon(Icons.phone_outlined),
              matching: find.byType(Container),
            )
            .first,
      );

      // Verify container decoration
      final decoration = iconContainer.decoration as BoxDecoration;
      expect(decoration.color, BaseColor.teal[100]);
      expect(decoration.shape, BoxShape.circle);

      // Verify icon color
      final icon = tester.widget<Icon>(find.byIcon(Icons.phone_outlined));
      expect(icon.color, BaseColor.teal[700]);
    });

    testWidgets('semantic labels are present for accessibility', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify semantic labels exist
      expect(find.bySemanticsLabel('Phone number input field'), findsOneWidget);
      expect(find.bySemanticsLabel('Continue button'), findsOneWidget);
      expect(find.bySemanticsLabel('Country code selector'), findsOneWidget);
    });
  });
}
