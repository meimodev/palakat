import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat/features/notification/presentations/widgets/permission_rationale_bottom_sheet.dart';

/// Unit tests for PermissionRationaleBottomSheet
/// **Feature: push-notification-ux-improvements**
/// **Validates: Requirements 4.1, 4.2, 4.3, 4.4, 4.5**
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PermissionRationaleBottomSheet Tests', () {
    /// Test that bottom sheet displays title "Stay Updated"
    /// **Validates: Requirements 4.2**
    testWidgets('Bottom sheet displays title "Stay Updated"', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp());
      await tester.pumpAndSettle();

      // Tap button to show bottom sheet
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(
        find.text('Stay Updated'),
        findsOneWidget,
        reason: 'Bottom sheet should display "Stay Updated" title',
      );
    });

    /// Test that bottom sheet displays all three benefits
    /// **Validates: Requirements 4.2**
    testWidgets('Bottom sheet displays all benefits', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp());
      await tester.pumpAndSettle();

      // Tap button to show bottom sheet
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Check for all three benefits
      expect(
        find.text('Get notified about new activities and events'),
        findsOneWidget,
        reason: 'Should display activity updates benefit',
      );
      expect(
        find.text('Receive approval requests that need your attention'),
        findsOneWidget,
        reason: 'Should display approval requests benefit',
      );
      expect(
        find.text('Don\'t miss important church announcements'),
        findsOneWidget,
        reason: 'Should display announcements benefit',
      );
    });

    /// Test that "Allow Notifications" button is present
    /// **Validates: Requirements 4.3, 4.4**
    testWidgets('"Allow Notifications" button is present', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp());
      await tester.pumpAndSettle();

      // Tap button to show bottom sheet
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(
        find.text('Allow Notifications'),
        findsOneWidget,
        reason: 'Should display "Allow Notifications" button',
      );

      // Verify it's an ElevatedButton (primary button)
      final allowButtonFinder = find.ancestor(
        of: find.text('Allow Notifications'),
        matching: find.byType(ElevatedButton),
      );
      expect(
        allowButtonFinder,
        findsOneWidget,
        reason: 'Allow button should be an ElevatedButton (primary)',
      );
    });

    /// Test that "Not Now" button is present
    /// **Validates: Requirements 4.3, 4.5**
    testWidgets('"Not Now" button is present', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp());
      await tester.pumpAndSettle();

      // Tap button to show bottom sheet
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(
        find.text('Not Now'),
        findsOneWidget,
        reason: 'Should display "Not Now" button',
      );

      // Verify it's a TextButton (text button)
      final notNowButtonFinder = find.ancestor(
        of: find.text('Not Now'),
        matching: find.byType(TextButton),
      );
      expect(
        notNowButtonFinder,
        findsOneWidget,
        reason: 'Not Now button should be a TextButton',
      );
    });

    /// Test that onAllow callback fires when "Allow Notifications" is tapped
    /// **Validates: Requirements 4.4**
    testWidgets('onAllow callback fires when "Allow" tapped', (tester) async {
      bool? result;

      await tester.pumpWidget(
        _wrapWithMaterialApp(onResult: (value) => result = value),
      );
      await tester.pumpAndSettle();

      // Tap button to show bottom sheet
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Scroll to make the button visible
      await tester.ensureVisible(find.text('Allow Notifications'));
      await tester.pumpAndSettle();

      // Tap "Allow Notifications" button
      final allowButtonFinder = find.ancestor(
        of: find.text('Allow Notifications'),
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(allowButtonFinder);
      await tester.pumpAndSettle();

      expect(
        result,
        isTrue,
        reason: 'Should return true when "Allow Notifications" is tapped',
      );
    });

    /// Test that onNotNow callback fires when "Not Now" is tapped
    /// **Validates: Requirements 4.5**
    testWidgets('onNotNow callback fires when "Not Now" tapped', (
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
      await tester.ensureVisible(find.text('Not Now'));
      await tester.pumpAndSettle();

      // Tap "Not Now" button
      final notNowButtonFinder = find.ancestor(
        of: find.text('Not Now'),
        matching: find.byType(TextButton),
      );
      await tester.tap(notNowButtonFinder);
      await tester.pumpAndSettle();

      expect(
        result,
        isFalse,
        reason: 'Should return false when "Not Now" is tapped',
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

    /// Test that bottom sheet displays icon/illustration
    /// **Validates: Requirements 4.2**
    testWidgets('Bottom sheet displays notification icon', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp());
      await tester.pumpAndSettle();

      // Tap button to show bottom sheet
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify icon container exists
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
              final result = await showPermissionRationaleBottomSheet(
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
