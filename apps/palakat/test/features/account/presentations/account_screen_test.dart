import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:palakat/features/account/presentations/account/account_screen.dart';
import 'package:palakat_shared/core/widgets/language_selector.dart';

/// Widget tests for AccountScreen
/// **Feature: settings-screen**
/// **Validates: Requirements 4.4**
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize Hive for testing with a temporary path
    Hive.init('.hive_test');
    // Open the boxes that LocalStorageService uses
    await Hive.openBox('auth');
    await Hive.openBox('permission_state');
    await Hive.openBox('notification_settings');
  });

  tearDownAll(() async {
    // Clean up Hive after tests
    await Hive.close();
  });

  group('AccountScreen Widget Tests', () {
    /// Test that LanguageSelector is not present in AccountScreen widget tree
    /// **Validates: Requirements 4.4**
    testWidgets('LanguageSelector is not present in AccountScreen widget tree', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapWithProviderScope(const AccountScreen()));

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify that LanguageSelector is not in the widget tree
      final languageSelectorFinder = find.byType(LanguageSelector);
      expect(
        languageSelectorFinder,
        findsNothing,
        reason:
            'LanguageSelector should not be present in AccountScreen as it was moved to SettingsScreen',
      );
    });

    /// Test that AccountScreen renders without LanguageSelector widget
    /// **Validates: Requirements 4.4**
    testWidgets('AccountScreen renders successfully without LanguageSelector', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapWithProviderScope(const AccountScreen()));

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify that AccountScreen itself is rendered
      final accountScreenFinder = find.byType(AccountScreen);
      expect(
        accountScreenFinder,
        findsOneWidget,
        reason: 'AccountScreen should render successfully',
      );

      // Verify that no LanguageSelector is found anywhere in the widget tree
      final languageSelectorFinder = find.byType(LanguageSelector);
      expect(
        languageSelectorFinder,
        findsNothing,
        reason:
            'No LanguageSelector should be found in AccountScreen widget tree',
      );
    });
  });
}

/// Helper function to wrap widget with ProviderScope and MaterialApp
Widget _wrapWithProviderScope(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, _) => ProviderScope(child: MaterialApp(home: child)),
  );
}
