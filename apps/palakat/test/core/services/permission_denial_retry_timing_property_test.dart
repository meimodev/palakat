import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:palakat/core/services/permission_manager_service.dart';
import 'package:palakat_shared/core/services/local_storage_service.dart';

/// **Feature: push-notification-ux-improvements, Property 5: Permission Denial Retry Timing**
///
/// *For any* denial timestamp, if the current time is at least 7 days after
/// the denial timestamp, shouldRetryAfterDenial SHALL return true; otherwise false.
///
/// **Validates: Requirements 6.1**
void main() {
  KiriCheck.verbosity = Verbosity.verbose;

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
    await Hive.deleteFromDisk();
  });

  group('Property 5: Permission Denial Retry Timing', () {
    late PermissionManagerService service;

    setUp(() {
      final storage = LocalStorageService();
      service = PermissionManagerServiceImpl(storage);
    });

    // Generator for days offset (can be negative for past, positive for future)
    final daysOffsetArb = integer(min: -30, max: 30);

    // Property test: Retry allowed after 7 days
    property('retry allowed after 7 days or more', () {
      forAll(daysOffsetArb, (daysOffset) {
        final now = DateTime.now();
        final deniedAt = now.subtract(Duration(days: daysOffset.abs()));

        final shouldRetry = service.shouldRetryAfterDenial(deniedAt);

        // If denied at least 7 days ago, should retry
        if (daysOffset.abs() >= 7) {
          expect(
            shouldRetry,
            isTrue,
            reason: 'Should retry after $daysOffset days',
          );
        } else {
          expect(
            shouldRetry,
            isFalse,
            reason: 'Should not retry after only $daysOffset days',
          );
        }
      });
    });

    // Property test: Null deniedAt always allows retry
    property('null deniedAt always allows retry', () {
      forAll(constant(null), (DateTime? deniedAt) {
        final shouldRetry = service.shouldRetryAfterDenial(deniedAt);
        expect(shouldRetry, isTrue);
      });
    });

    // Property test: Exact 7-day boundary
    property('exactly 7 days allows retry', () {
      forAll(constant(7), (days) {
        final now = DateTime.now();
        final deniedAt = now.subtract(Duration(days: days));

        final shouldRetry = service.shouldRetryAfterDenial(deniedAt);

        expect(
          shouldRetry,
          isTrue,
          reason: 'Should retry after exactly 7 days',
        );
      });
    });

    // Property test: Just under 7 days denies retry
    property('just under 7 days denies retry', () {
      forAll(integer(min: 0, max: 6), (days) {
        final now = DateTime.now();
        final deniedAt = now.subtract(Duration(days: days));

        final shouldRetry = service.shouldRetryAfterDenial(deniedAt);

        expect(
          shouldRetry,
          isFalse,
          reason: 'Should not retry after only $days days',
        );
      });
    });

    // Property test: More than 7 days allows retry
    property('more than 7 days allows retry', () {
      forAll(integer(min: 8, max: 365), (days) {
        final now = DateTime.now();
        final deniedAt = now.subtract(Duration(days: days));

        final shouldRetry = service.shouldRetryAfterDenial(deniedAt);

        expect(shouldRetry, isTrue, reason: 'Should retry after $days days');
      });
    });

    // Property test: Hours precision (6 days 23 hours should not retry)
    property('6 days 23 hours should not allow retry', () {
      forAll(constant(null), (_) {
        final now = DateTime.now();
        final deniedAt = now.subtract(const Duration(days: 6, hours: 23));

        final shouldRetry = service.shouldRetryAfterDenial(deniedAt);

        expect(
          shouldRetry,
          isFalse,
          reason: 'Should not retry after 6 days 23 hours',
        );
      });
    });

    // Property test: 7 days 1 hour should allow retry
    property('7 days 1 hour should allow retry', () {
      forAll(constant(null), (_) {
        final now = DateTime.now();
        final deniedAt = now.subtract(const Duration(days: 7, hours: 1));

        final shouldRetry = service.shouldRetryAfterDenial(deniedAt);

        expect(shouldRetry, isTrue, reason: 'Should retry after 7 days 1 hour');
      });
    });
  });

  // Unit tests for edge cases
  group('Permission Denial Retry Timing Unit Tests', () {
    late PermissionManagerService service;

    setUp(() {
      final storage = LocalStorageService();
      service = PermissionManagerServiceImpl(storage);
    });

    test('null deniedAt returns true', () {
      expect(service.shouldRetryAfterDenial(null), isTrue);
    });

    test('exactly 7 days ago returns true', () {
      final deniedAt = DateTime.now().subtract(const Duration(days: 7));
      expect(service.shouldRetryAfterDenial(deniedAt), isTrue);
    });

    test('6 days 23 hours 59 minutes ago returns false', () {
      final deniedAt = DateTime.now().subtract(
        const Duration(days: 6, hours: 23, minutes: 59),
      );
      expect(service.shouldRetryAfterDenial(deniedAt), isFalse);
    });

    test('7 days 1 second ago returns true', () {
      final deniedAt = DateTime.now().subtract(
        const Duration(days: 7, seconds: 1),
      );
      expect(service.shouldRetryAfterDenial(deniedAt), isTrue);
    });

    test('1 day ago returns false', () {
      final deniedAt = DateTime.now().subtract(const Duration(days: 1));
      expect(service.shouldRetryAfterDenial(deniedAt), isFalse);
    });

    test('30 days ago returns true', () {
      final deniedAt = DateTime.now().subtract(const Duration(days: 30));
      expect(service.shouldRetryAfterDenial(deniedAt), isTrue);
    });

    test('1 hour ago returns false', () {
      final deniedAt = DateTime.now().subtract(const Duration(hours: 1));
      expect(service.shouldRetryAfterDenial(deniedAt), isFalse);
    });

    test('168 hours (7 days) ago returns true', () {
      final deniedAt = DateTime.now().subtract(const Duration(hours: 168));
      expect(service.shouldRetryAfterDenial(deniedAt), isTrue);
    });

    test('167 hours ago returns false', () {
      final deniedAt = DateTime.now().subtract(const Duration(hours: 167));
      expect(service.shouldRetryAfterDenial(deniedAt), isFalse);
    });

    test('169 hours ago returns true', () {
      final deniedAt = DateTime.now().subtract(const Duration(hours: 169));
      expect(service.shouldRetryAfterDenial(deniedAt), isTrue);
    });
  });
}
