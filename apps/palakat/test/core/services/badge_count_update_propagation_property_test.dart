import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:palakat/core/services/notification_display_service.dart';

/// **Feature: push-notification-ux-improvements, Property 10: Badge Count Update Propagation**
///
/// *For any* badge count update operation, the new badge count should be reflected
/// in the system within a reasonable time (< 1 second).
///
/// **Validates: Requirements 10.5**
///
/// This property test verifies that badge count updates complete within acceptable
/// time bounds. The actual iOS badge display on the home screen is tested in
/// integration tests on real devices.
void main() {
  KiriCheck.verbosity = Verbosity.quiet;

  group('Property 10: Badge Count Update Propagation', () {
    late NotificationDisplayService service;

    setUp(() {
      // Create service instance for testing
      service = NotificationDisplayServiceImpl();
    });

    // Generator for badge count values (0-100)
    final badgeCountArb = integer(min: 0, max: 100);

    property('badge count update should complete within 1 second', () {
      forAll(badgeCountArb, (count) async {
        // Skip test on non-iOS platforms since badge count is iOS-only
        if (!Platform.isIOS) {
          return;
        }

        // Property: Badge count update operation should complete in < 1 second
        final stopwatch = Stopwatch()..start();

        await service.updateBadgeCount(count);

        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;

        expect(
          elapsedMs,
          lessThan(1000),
          reason:
              'Badge count update to $count should complete in less than '
              '1000ms, but took ${elapsedMs}ms',
        );
      }, maxExamples: 100);
    });

    property(
      'multiple sequential badge count updates should each complete within 1 second',
      () {
        // Generator for a sequence of badge count updates
        final updateSequenceArb = list(
          badgeCountArb,
          minLength: 2,
          maxLength: 5,
        );

        forAll(updateSequenceArb, (counts) async {
          // Skip test on non-iOS platforms since badge count is iOS-only
          if (!Platform.isIOS) {
            return;
          }

          // Property: Each update in a sequence should complete within 1 second
          for (final count in counts) {
            final stopwatch = Stopwatch()..start();

            await service.updateBadgeCount(count);

            stopwatch.stop();
            final elapsedMs = stopwatch.elapsedMilliseconds;

            expect(
              elapsedMs,
              lessThan(1000),
              reason:
                  'Badge count update to $count should complete in less than '
                  '1000ms, but took ${elapsedMs}ms',
            );
          }
        }, maxExamples: 50);
      },
    );

    property('badge count update to zero should complete within 1 second', () {
      forAll(constant(0), (count) async {
        // Skip test on non-iOS platforms since badge count is iOS-only
        if (!Platform.isIOS) {
          return;
        }

        // Property: Clearing badge count (setting to 0) should be fast
        final stopwatch = Stopwatch()..start();

        await service.updateBadgeCount(count);

        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;

        expect(
          elapsedMs,
          lessThan(1000),
          reason:
              'Badge count update to 0 should complete in less than '
              '1000ms, but took ${elapsedMs}ms',
        );
      }, maxExamples: 100);
    });

    property(
      'rapid badge count updates should all complete within reasonable time',
      () {
        // Generator for rapid update scenario (increment then decrement)
        final rapidUpdateArb = combine2(badgeCountArb, badgeCountArb);

        forAll(rapidUpdateArb, (tuple) async {
          // Skip test on non-iOS platforms since badge count is iOS-only
          if (!Platform.isIOS) {
            return;
          }

          final (count1, count2) = tuple;

          // Property: Two rapid updates should both complete quickly
          final stopwatch = Stopwatch()..start();

          await service.updateBadgeCount(count1);
          await service.updateBadgeCount(count2);

          stopwatch.stop();
          final totalElapsedMs = stopwatch.elapsedMilliseconds;

          // Both updates together should complete in < 2 seconds
          expect(
            totalElapsedMs,
            lessThan(2000),
            reason:
                'Two badge count updates ($count1, $count2) should complete '
                'in less than 2000ms, but took ${totalElapsedMs}ms',
          );

          // Each update should average < 1 second
          final averageMs = totalElapsedMs / 2;
          expect(
            averageMs,
            lessThan(1000),
            reason:
                'Average time per badge count update should be less than '
                '1000ms, but was ${averageMs}ms',
          );
        }, maxExamples: 50);
      },
    );

    property(
      'badge count update timing should be consistent across different values',
      () {
        // Generator for different badge count ranges
        final lowCountArb = integer(min: 0, max: 10);
        final highCountArb = integer(min: 90, max: 100);
        final combinedArb = combine2(lowCountArb, highCountArb);

        forAll(combinedArb, (tuple) async {
          // Skip test on non-iOS platforms since badge count is iOS-only
          if (!Platform.isIOS) {
            return;
          }

          final (lowCount, highCount) = tuple;

          // Property: Update time should not significantly vary based on count value
          final stopwatch1 = Stopwatch()..start();
          await service.updateBadgeCount(lowCount);
          stopwatch1.stop();
          final lowElapsedMs = stopwatch1.elapsedMilliseconds;

          final stopwatch2 = Stopwatch()..start();
          await service.updateBadgeCount(highCount);
          stopwatch2.stop();
          final highElapsedMs = stopwatch2.elapsedMilliseconds;

          // Both should complete within 1 second
          expect(
            lowElapsedMs,
            lessThan(1000),
            reason:
                'Badge count update to $lowCount should complete in less than '
                '1000ms, but took ${lowElapsedMs}ms',
          );

          expect(
            highElapsedMs,
            lessThan(1000),
            reason:
                'Badge count update to $highCount should complete in less than '
                '1000ms, but took ${highElapsedMs}ms',
          );

          // The difference in timing should not be excessive (< 500ms difference)
          final timeDifference = (lowElapsedMs - highElapsedMs).abs();
          expect(
            timeDifference,
            lessThan(500),
            reason:
                'Time difference between updating to $lowCount (${lowElapsedMs}ms) '
                'and $highCount (${highElapsedMs}ms) should be less than 500ms, '
                'but was ${timeDifference}ms',
          );
        }, maxExamples: 50);
      },
    );
  });
}
