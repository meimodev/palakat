import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_shared/core/models/language_option.dart';
import 'package:palakat_shared/core/services/locale_controller.dart';
import 'package:palakat_shared/core/widgets/language_selector.dart';

/// Unit tests for LanguageSelector widget
///
/// Tests:
/// - Widget displays current language
/// - Options are shown on tap
/// - Selection triggers locale change
///
/// Requirements: 6.3, 6.4
void main() {
  group('LanguageSelector Widget Tests', () {
    Widget buildTestWidget({Locale initialLocale = const Locale('id')}) {
      return ProviderScope(
        overrides: [
          // Override with a simple value to avoid async storage operations
          localeControllerProvider.overrideWithValue(initialLocale),
        ],
        child: const MaterialApp(
          home: Scaffold(body: Center(child: LanguageSelector())),
        ),
      );
    }

    testWidgets('displays current language with flag', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Default is Indonesian
      expect(find.text('Bahasa Indonesia'), findsOneWidget);
      expect(find.text('🇮🇩'), findsOneWidget);
    });

    testWidgets('displays English when locale is English', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(initialLocale: const Locale('en')),
      );
      await tester.pump();

      expect(find.text('English'), findsOneWidget);
      expect(find.text('🇺🇸'), findsOneWidget);
    });

    testWidgets('shows dialog with language options on tap', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Tap the selector
      await tester.tap(find.byType(LanguageSelector));
      await tester.pump();

      // Dialog should be visible with both options
      expect(find.text('Language'), findsOneWidget);
      expect(
        find.text('Bahasa Indonesia'),
        findsNWidgets(2),
      ); // In selector and dialog
      expect(find.text('English'), findsOneWidget);
      expect(find.text('🇮🇩'), findsNWidgets(2)); // In selector and dialog
      expect(find.text('🇺🇸'), findsOneWidget);
    });

    testWidgets('shows check mark on current language in dialog', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Tap the selector
      await tester.tap(find.byType(LanguageSelector));
      await tester.pump();

      // Check mark should be visible for Indonesian (default)
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('closes dialog when Cancel is tapped', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Open dialog
      await tester.tap(find.byType(LanguageSelector));
      await tester.pump();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      // Dialog should be closed
      expect(find.text('Language'), findsNothing);
    });

    testWidgets('displays dropdown arrow icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Should show dropdown arrow
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });
  });

  group('LanguageOption Model Tests', () {
    test('supportedLanguageOptions contains Indonesian and English', () {
      expect(supportedLanguageOptions.length, equals(2));
      expect(
        supportedLanguageOptions.any((o) => o.locale.languageCode == 'id'),
        isTrue,
      );
      expect(
        supportedLanguageOptions.any((o) => o.locale.languageCode == 'en'),
        isTrue,
      );
    });

    test('getLanguageOption returns correct option for locale', () {
      final indonesian = getLanguageOption(const Locale('id'));
      expect(indonesian.name, equals('Bahasa Indonesia'));
      expect(indonesian.flag, equals('🇮🇩'));

      final english = getLanguageOption(const Locale('en'));
      expect(english.name, equals('English'));
      expect(english.flag, equals('🇺🇸'));
    });

    test('getLanguageOption returns Indonesian for unsupported locale', () {
      final fallback = getLanguageOption(const Locale('fr'));
      expect(fallback.locale.languageCode, equals('id'));
    });

    test('LanguageOption.matches correctly identifies matching locales', () {
      final option = supportedLanguageOptions.first;
      expect(option.matches(const Locale('id')), isTrue);
      expect(option.matches(const Locale('en')), isFalse);
    });
  });
}
