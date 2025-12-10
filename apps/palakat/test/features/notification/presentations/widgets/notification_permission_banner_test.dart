import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat/core/services/permission_manager_service_provider.dart';
import 'package:palakat/features/notification/presentations/widgets/notification_permission_banner.dart';
import 'package:palakat_shared/core/models/permission_state.dart';
import 'package:riverpod/src/framework.dart' show Override;

/// Mock PermissionState notifier for testing
class _MockPermissionState extends PermissionState {
  final PermissionStateModel _state;

  _MockPermissionState(this._state);

  @override
  Future<PermissionStateModel> build() async {
    return _state;
  }
}

/// Wraps a widget with MaterialApp and ScreenUtilInit for testing.
Widget _wrapWithMaterialApp(Widget child, List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp(home: Scaffold(body: child)),
    ),
  );
}

/// Widget tests for NotificationPermissionBanner
///
/// Requirements: 6.2, 6.3
void main() {
  group('NotificationPermissionBanner Widget Tests', () {
    testWidgets('banner hidden when permission granted', (
      WidgetTester tester,
    ) async {
      // Arrange
      final grantedState = PermissionStateModel(
        status: PermissionStatus.granted,
        lastCheckedAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        _wrapWithMaterialApp(const NotificationPermissionBanner(), [
          permissionStateProvider.overrideWith(
            () => _MockPermissionState(grantedState),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Enable Notifications'), findsNothing);
      expect(
        find.text('Stay updated with activities and approvals'),
        findsNothing,
      );
      expect(find.text('Enable'), findsNothing);
    });

    testWidgets('banner visible when permission denied', (
      WidgetTester tester,
    ) async {
      // Arrange
      final deniedState = PermissionStateModel(
        status: PermissionStatus.denied,
        deniedAt: DateTime.now(),
        lastCheckedAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        _wrapWithMaterialApp(const NotificationPermissionBanner(), [
          permissionStateProvider.overrideWith(
            () => _MockPermissionState(deniedState),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Enable Notifications'), findsOneWidget);
      expect(
        find.text('Stay updated with activities and approvals'),
        findsOneWidget,
      );
      expect(find.text('Enable'), findsOneWidget);
    });

    testWidgets('banner visible when permission not determined', (
      WidgetTester tester,
    ) async {
      // Arrange
      final notDeterminedState = PermissionStateModel(
        status: PermissionStatus.notDetermined,
        lastCheckedAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        _wrapWithMaterialApp(const NotificationPermissionBanner(), [
          permissionStateProvider.overrideWith(
            () => _MockPermissionState(notDeterminedState),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Enable Notifications'), findsOneWidget);
      expect(find.text('Enable'), findsOneWidget);
    });

    testWidgets('banner visible when permission permanently denied', (
      WidgetTester tester,
    ) async {
      // Arrange
      final permanentlyDeniedState = PermissionStateModel(
        status: PermissionStatus.permanentlyDenied,
        deniedAt: DateTime.now(),
        lastCheckedAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        _wrapWithMaterialApp(const NotificationPermissionBanner(), [
          permissionStateProvider.overrideWith(
            () => _MockPermissionState(permanentlyDeniedState),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Enable Notifications'), findsOneWidget);
      expect(find.text('Enable'), findsOneWidget);
    });

    testWidgets('"Enable Notifications" button present when visible', (
      WidgetTester tester,
    ) async {
      // Arrange
      final deniedState = PermissionStateModel(
        status: PermissionStatus.denied,
        deniedAt: DateTime.now(),
        lastCheckedAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        _wrapWithMaterialApp(const NotificationPermissionBanner(), [
          permissionStateProvider.overrideWith(
            () => _MockPermissionState(deniedState),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      // Assert
      final enableButton = find.widgetWithText(ElevatedButton, 'Enable');
      expect(enableButton, findsOneWidget);

      // Verify button is tappable
      await tester.tap(enableButton);
      await tester.pumpAndSettle();
    });

    testWidgets('dismiss button present when visible', (
      WidgetTester tester,
    ) async {
      // Arrange
      final deniedState = PermissionStateModel(
        status: PermissionStatus.denied,
        deniedAt: DateTime.now(),
        lastCheckedAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        _wrapWithMaterialApp(const NotificationPermissionBanner(), [
          permissionStateProvider.overrideWith(
            () => _MockPermissionState(deniedState),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      // Assert
      final dismissButton = find.byType(IconButton);
      expect(dismissButton, findsOneWidget);
    });

    testWidgets('banner dismisses when dismiss button tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      final deniedState = PermissionStateModel(
        status: PermissionStatus.denied,
        deniedAt: DateTime.now(),
        lastCheckedAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        _wrapWithMaterialApp(const NotificationPermissionBanner(), [
          permissionStateProvider.overrideWith(
            () => _MockPermissionState(deniedState),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      // Assert: Banner visible initially
      expect(find.text('Enable Notifications'), findsOneWidget);

      // Act: Tap dismiss button
      final dismissButton = find.byType(IconButton);
      await tester.tap(dismissButton);
      await tester.pumpAndSettle();

      // Assert: Banner hidden after dismissal
      expect(find.text('Enable Notifications'), findsNothing);
      expect(find.text('Enable'), findsNothing);
    });

    testWidgets('enable button shows permission rationale', (
      WidgetTester tester,
    ) async {
      // Arrange
      final deniedState = PermissionStateModel(
        status: PermissionStatus.denied,
        deniedAt: DateTime.now(),
        lastCheckedAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        _wrapWithMaterialApp(const NotificationPermissionBanner(), [
          permissionStateProvider.overrideWith(
            () => _MockPermissionState(deniedState),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      // Act: Tap enable button
      final enableButton = find.widgetWithText(ElevatedButton, 'Enable');
      await tester.tap(enableButton);
      await tester.pumpAndSettle();

      // Assert: Permission rationale bottom sheet shown
      expect(find.text('Stay Updated'), findsOneWidget);
      expect(find.text('Allow Notifications'), findsOneWidget);
      expect(find.text('Not Now'), findsOneWidget);
    });
  });
}
