import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:palakat/core/constants/app_icons.dart';
import 'package:palakat/core/widgets/app_icon_widget.dart';
import 'package:palakat_shared/theme.dart';

/// Property-based tests for AppIconWidget class.
/// **Feature: icon-consolidation**
void main() {
  group('AppIconWidget Property Tests', () {
    /// **Feature: icon-consolidation, Property 2: Icon helper sizing consistency**
    /// **Validates: Requirements 2.1**
    ///
    /// *For any* size parameter passed to AppIconWidget, the resulting FaIcon
    /// widget SHALL have that exact size value.
    testWidgets('Property 2: Icon helper sizing consistency', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(home: SizedBox()),
        ),
      );

      // Test factory constructors produce correct sizes
      final smallWidget = AppIconWidget.small(AppIcons.back);
      final mediumWidget = AppIconWidget.medium(AppIcons.back);
      final largeWidget = AppIconWidget.large(AppIcons.back);
      final xlWidget = AppIconWidget.xl(AppIcons.back);

      // Verify sizes match expected BaseSize values
      expect(
        smallWidget.size,
        equals(BaseSize.w16),
        reason: 'Small icon should have size BaseSize.w16',
      );
      expect(
        mediumWidget.size,
        equals(BaseSize.w20),
        reason: 'Medium icon should have size BaseSize.w20',
      );
      expect(
        largeWidget.size,
        equals(BaseSize.w24),
        reason: 'Large icon should have size BaseSize.w24',
      );
      expect(
        xlWidget.size,
        equals(BaseSize.w32),
        reason: 'XL icon should have size BaseSize.w32',
      );
    });

    /// Property test: Custom size is preserved
    property('Custom size parameter is preserved', () {
      forAll(integer(min: 8, max: 64).map((i) => i.toDouble()), (customSize) {
        final widget = AppIconWidget(AppIcons.search, size: customSize);
        expect(
          widget.size,
          equals(customSize),
          reason: 'Custom size $customSize should be preserved',
        );
      });
    });

    /// **Feature: icon-consolidation, Property 3: Icon helper color application**
    /// **Validates: Requirements 2.2**
    ///
    /// *For any* color parameter passed to AppIconWidget, the resulting FaIcon
    /// widget SHALL have that exact color value applied.
    property('Property 3: Icon helper color application', () {
      forAll(_colorArbitrary(), (color) {
        final widget = AppIconWidget(AppIcons.approve, color: color);
        expect(
          widget.color,
          equals(color),
          reason: 'Color should be preserved in widget',
        );
      });
    });

    /// Test factory constructors with color
    property('Factory constructors preserve color', () {
      forAll(_colorArbitrary(), (color) {
        final smallWidget = AppIconWidget.small(AppIcons.back, color: color);
        final mediumWidget = AppIconWidget.medium(AppIcons.back, color: color);
        final largeWidget = AppIconWidget.large(AppIcons.back, color: color);
        final xlWidget = AppIconWidget.xl(AppIcons.back, color: color);

        expect(
          smallWidget.color,
          equals(color),
          reason: 'Small factory should preserve color',
        );
        expect(
          mediumWidget.color,
          equals(color),
          reason: 'Medium factory should preserve color',
        );
        expect(
          largeWidget.color,
          equals(color),
          reason: 'Large factory should preserve color',
        );
        expect(
          xlWidget.color,
          equals(color),
          reason: 'XL factory should preserve color',
        );
      });
    });

    /// Test that null color is handled correctly (uses default)
    test('Null color uses default', () {
      final widget = AppIconWidget(AppIcons.search);
      expect(
        widget.color,
        isNull,
        reason: 'Null color should be preserved (uses theme default)',
      );
    });

    /// Test that the widget builds correctly with FaIcon
    testWidgets('Widget builds FaIcon correctly', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: AppIconWidget.medium(AppIcons.search, color: Colors.blue),
            ),
          ),
        ),
      );

      // Find the FaIcon widget
      final faIconFinder = find.byType(FaIcon);
      expect(
        faIconFinder,
        findsOneWidget,
        reason: 'AppIconWidget should render a FaIcon',
      );

      // Verify the FaIcon has correct properties
      final faIcon = tester.widget<FaIcon>(faIconFinder);
      expect(
        faIcon.icon,
        equals(AppIcons.search),
        reason: 'FaIcon should have the correct icon',
      );
      expect(
        faIcon.color,
        equals(Colors.blue),
        reason: 'FaIcon should have the correct color',
      );
    });
  });
}

// ============================================================================
// Arbitrary generators
// ============================================================================

/// Generates a random Color value.
Arbitrary<Color> _colorArbitrary() {
  return integer(min: 0, max: 255).flatMap((r) {
    return integer(min: 0, max: 255).flatMap((g) {
      return integer(min: 0, max: 255).map((b) {
        return Color.fromARGB(255, r, g, b);
      });
    });
  });
}
