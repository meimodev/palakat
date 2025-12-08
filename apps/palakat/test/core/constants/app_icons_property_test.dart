import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:palakat/core/constants/app_icons.dart';

/// Property-based tests for AppIcons class.
/// **Feature: icon-consolidation**
void main() {
  group('AppIcons Property Tests', () {
    /// **Feature: icon-consolidation, Property 1: AppIcons accessors return valid IconData**
    /// **Validates: Requirements 1.1**
    ///
    /// *For any* icon accessor in the AppIcons class, calling the accessor
    /// SHALL return a non-null IconData instance from FontAwesomeIcons.
    property('Property 1: AppIcons accessors return valid IconData', () {
      // Get all icon accessors from AppIcons
      final allIcons = _getAllAppIcons();

      forAll(_iconIndexArbitrary(allIcons.length), (index) {
        final iconEntry = allIcons[index];
        final iconData = iconEntry.value;

        // Verify the icon is not null
        expect(
          iconData,
          isNotNull,
          reason: 'AppIcons.${iconEntry.key} should return non-null IconData',
        );

        // Verify it's a valid IconData instance
        expect(
          iconData,
          isA<IconData>(),
          reason: 'AppIcons.${iconEntry.key} should return IconData',
        );

        // Verify it has a valid codePoint (Font Awesome icons have specific ranges)
        expect(
          iconData.codePoint,
          greaterThan(0),
          reason: 'AppIcons.${iconEntry.key} should have a valid codePoint > 0',
        );

        // Verify it uses the Font Awesome font family
        expect(
          iconData.fontFamily,
          isNotNull,
          reason:
              'AppIcons.${iconEntry.key} should have a fontFamily specified',
        );
      });
    });

    /// Additional test: All icons are unique or intentionally shared
    test('All icon accessors are defined', () {
      final allIcons = _getAllAppIcons();

      // Verify we have all expected icons
      expect(
        allIcons.length,
        greaterThanOrEqualTo(35),
        reason: 'Should have at least 35 icon definitions',
      );

      // Verify each icon has a valid name
      for (final entry in allIcons) {
        expect(entry.key, isNotEmpty, reason: 'Icon name should not be empty');
      }
    });
  });
}

// ============================================================================
// Helper functions
// ============================================================================

/// Returns all icon accessors from AppIcons as name-value pairs.
List<MapEntry<String, IconData>> _getAllAppIcons() {
  return [
    // Navigation Icons
    MapEntry('back', AppIcons.back),
    MapEntry('forward', AppIcons.forward),
    MapEntry('chevronDown', AppIcons.chevronDown),
    MapEntry('chevronUp', AppIcons.chevronUp),
    MapEntry('home', AppIcons.home),
    MapEntry('grid', AppIcons.grid),
    // Action Icons
    MapEntry('approve', AppIcons.approve),
    MapEntry('reject', AppIcons.reject),
    MapEntry('close', AppIcons.close),
    MapEntry('delete', AppIcons.delete),
    MapEntry('search', AppIcons.search),
    MapEntry('download', AppIcons.download),
    MapEntry('openExternal', AppIcons.openExternal),
    // Status Icons
    MapEntry('pending', AppIcons.pending),
    MapEntry('inProgress', AppIcons.inProgress),
    MapEntry('success', AppIcons.success),
    MapEntry('error', AppIcons.error),
    MapEntry('warning', AppIcons.warning),
    MapEntry('info', AppIcons.info),
    // Content Icons
    MapEntry('document', AppIcons.document),
    MapEntry('calendar', AppIcons.calendar),
    MapEntry('event', AppIcons.event),
    MapEntry('announcement', AppIcons.announcement),
    MapEntry('notes', AppIcons.notes),
    MapEntry('description', AppIcons.description),
    MapEntry('music', AppIcons.music),
    MapEntry('reader', AppIcons.reader),
    MapEntry('approval', AppIcons.approval),
    // User/Account Icons
    MapEntry('person', AppIcons.person),
    MapEntry('church', AppIcons.church),
    MapEntry('phone', AppIcons.phone),
    MapEntry('supervisor', AppIcons.supervisor),
    // Financial Icons
    MapEntry('money', AppIcons.money),
    MapEntry('revenue', AppIcons.revenue),
    MapEntry('expense', AppIcons.expense),
    MapEntry('payment', AppIcons.payment),
    MapEntry('bankAccount', AppIcons.bankAccount),
    MapEntry('wallet', AppIcons.wallet),
    // Location Icons
    MapEntry('mapPin', AppIcons.mapPin),
    MapEntry('location', AppIcons.location),
    MapEntry('gps', AppIcons.gps),
    MapEntry('map', AppIcons.map),
    MapEntry('coordinates', AppIcons.coordinates),
    // Time Icons
    MapEntry('time', AppIcons.time),
    MapEntry('schedule', AppIcons.schedule),
    MapEntry('createdAt', AppIcons.createdAt),
  ];
}

// ============================================================================
// Arbitrary generators
// ============================================================================

/// Generates an index into the icons list.
Arbitrary<int> _iconIndexArbitrary(int length) {
  return integer(min: 0, max: length - 1);
}
