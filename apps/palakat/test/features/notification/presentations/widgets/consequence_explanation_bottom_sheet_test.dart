import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat/features/notification/presentations/widgets/consequence_explanation_bottom_sheet.dart';

/// Unit tests for ConsequenceExplanationBottomSheet
/// **Feature: push-notification-ux-improvements**
/// **Validates: Requirements 5.1, 5.2, 5.3, 5.4, 5.5**
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConsequenceExplanationBottomSheet Tests', () {
    /// Test that bottom sheet displays title "You'll Miss Out On"
    /// **Validates: Requirements 5.2**
    testWidgets('Bottom sheet displays title "You\'ll Miss Out On"', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapWithMaterialApp());
      await tester.pumpAndSettle();

      // Tap button to show bottom sheet
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(
        find.text('You\'ll Miss Out On'),
        findsOneWidget,
        reason: 'Bottom sheet should display "You\'ll Miss Out On" title',
      );
    });

    /// Test that bottom sheet displays all three consequences
    /// **Validates: Requirements 5.2**
    testWidgets('Bottom sheet displays all consequences', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp());
      await tester.pumpAndSettle();

      // Tap button to show bottom sheet
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Check for all three consequences
      expect(
        find.text('Activity notifications and event updates'),
        findsOneWidget,
        reason: 'Should display activity notifications consequence',
      );
      expect(
        find.text('Approval requests that need your action'),
        findsOneWidget,
        reason: 'Should display approval requests consequence',
      );
      expect(
        find.text('Important church announcements and updates'),
        findsOneWidget,
        reason: 'Should display announcements consequence',
      );
    });

    /// Test that "Enable in Settings" button is present
    /// **Validates: Requirements 5.3, 5.4**
    testWidgets('"Enable in Settings" button is present', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp());
      await tester.pumpAndSettle();

      // Tap button to show bottom sheet
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(
        find.text('Enable in Settings'),
        findsOneWidget,
        reason: 'Should display "Enable in Settings" button',
      );

      // Verify it's an ElevatedButton (primary button)
      final enableButtonFinder = find.ancestor(
        of: find.text('Enable in Settings'),
        matching: find.byType(ElevatedButton),
      );
      expect(
        enableButtonFinder,
        findsOneWidget,
        reason: 'Enable button should be an ElevatedButton (primary)',
      );
    });

    /// Test that "Continue Without Notifications" button is present
    /// **Validates: Requirements 5.3, 5.5**
    testWidgets('"Continue Without Notifications" button is present', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapWithMaterialApp());
      await tester.pumpAndSettle();

      // Tap button to show bottom sheet
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(
        find.text('Continue Without Notifications'),
        findsOneWidget,
        reason: 'Should display "Continue Without Notifications" button',
      );

      // Verify it's a TextButton (text button)
      final continueButtonFinder = find.ancestor(
        of: find.text('Continue Without Notifications'),
        matching: find.byType(TextButton),
      );
      expect(
        continueButtonFinder,
        findsOneWidget,
        reason: 'Continue button should be a TextButton',
      );
    });

    /// Test that onEnableInSettings callback fires when "Enable in Settings" is tapped
    /// **Validates: Requirements 5.4**
    testWidgets('onEnableInSettings callback fires when "Enable" tapped', (
      tester,
    ) async {
      bool? result;

      await tester.pumpWidget(
        _wrapWithMaterialApp(onResult: (value) => result = value),
      );
      await tester.pumpAndSettle();

      // Tap button to show bottom sheet
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Scroll to make the button visible
      await tester.ensureVisible(find.text('Enable in Settings'));
      await tester.pumpAndSettle();

      // Tap "Enable in Settings" button
      final enableButtonFinder = find.ancestor(
        of: find.text('Enable in Settings'),
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(enableButtonFinder);
      await tester.pumpAndSettle();

      expect(
        result,
        isTrue,
        reason: 'Should return true when "Enable in Settings" is tapped',
      );
    });

    /// Test that onContinueWithout callback fires when "Continue Without Notifications" is tapped
    /// **Validates: Requirements 5.5**
    testWidgets('onContinueWithout callback fires when "Continue" tapped', (
      tester,
    ) async {
      bool? result;

      await tester.pumpWidget(
        _wrapWithMaterialApp(onResult: (value) => result = value),
      );
      await tester.pumpAndSettle();

      // Tap button to show bottom sheet
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Scroll to make the button visible
      await tester.ensureVisible(find.text('Continue Without Notifications'));
      await tester.pumpAndSettle();

      // Tap "Continue Without Notifications" button
      final continueButtonFinder = find.ancestor(
        of: find.text('Continue Without Notifications'),
        matching: find.byType(TextButton),
      );
      await tester.tap(continueButtonFinder);
      await tester.pumpAndSettle();

      expect(
        result,
        isFalse,
        reason:
            'Should return false when "Continue Without Notifications" is tapped',
      );
    });

    /// Test that bottom sheet has proper styling (rounded corners, padding)
    testWidgets('Bottom sheet has proper styling', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp());
      await tester.pumpAndSettle();

      // Tap button to show bottom sheet
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Find the main container of the bottom sheet
      final containerFinder = find.byType(Container).first;
      final container = tester.widget<Container>(containerFinder);

      // Verify decoration
      expect(
        container.decoration,
        isA<BoxDecoration>(),
        reason: 'Bottom sheet should have BoxDecoration',
      );

      final decoration = container.decoration as BoxDecoration;
      expect(
        decoration.borderRadius,
        isNotNull,
        reason: 'Bottom sheet should have rounded corners',
      );
    });

    /// Test that bottom sheet displays warning/info icon
    /// **Validates: Requirements 5.1, 5.2**
    testWidgets('Bottom sheet displays warning icon', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp());
      await tester.pumpAndSettle();

      // Tap button to show bottom sheet
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify icon container exists with circular shape
      final iconContainerFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );

      expect(
        iconContainerFinder,
        findsWidgets,
        reason: 'Should display circular icon containers',
      );
    });
  });
}

// ============================================================================
// Helper functions
// ============================================================================

/// Wraps the test with MaterialApp and a button to trigger the bottom sheet.
Widget _wrapWithMaterialApp({void Function(bool?)? onResult}) {
  return MaterialApp(
    home: ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              final result = await showConsequenceExplanationBottomSheet(
                context: context,
              );
              onResult?.call(result);
            },
            child: const Text('Show Bottom Sheet'),
          ),
        ),
      ),
    ),
  );
}
