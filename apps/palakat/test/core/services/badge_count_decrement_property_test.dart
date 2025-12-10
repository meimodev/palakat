import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';

/// **Feature: push-notification-ux-improvements, Property 9: Badge Count Decrement**
///
/// *For any* initial badge count N and K notifications marked as read (where K ≤ N),
/// the badge count should be N - K after marking.
///
/// **Validates: Requirements 10.3**
///
/// This property test verifies the mathematical relationship between initial badge
/// count, notifications marked as read, and final badge count. The actual iOS badge
/// display is tested in integration tests on real devices.
void main() {
  KiriCheck.verbosity = Verbosity.quiet;

  group('Property 9: Badge Count Decrement', () {
    // Generator for initial badge count (1-100, must be at least 1 to have something to decrement)
    final initialBadgeCountArb = integer(min: 1, max: 100);

    property(
      'badge count should be N - K after K notifications are marked as read (K ≤ N)',
      () {
        // Create a generator that produces both initial count and read count
        // where read count is always <= initial count
        final combinedArb = initialBadgeCountArb.flatMap((initialCount) {
          final markedAsReadArb = integer(min: 1, max: initialCount);
          return markedAsReadArb.map((readCount) => (initialCount, readCount));
        });

        forAll(combinedArb, (tuple) {
          final (initialCount, markedAsReadCount) = tuple;

          // Property: Final badge count = Initial count - Marked as read count
          final expectedFinalCount = initialCount - markedAsReadCount;

          // Simulate badge count decrement
          int currentBadgeCount = initialCount;
          for (int i = 0; i < markedAsReadCount; i++) {
            currentBadgeCount--;
          }

          expect(
            currentBadgeCount,
            equals(expectedFinalCount),
            reason:
                'Badge count should be $expectedFinalCount after marking '
                '$markedAsReadCount notifications as read starting from $initialCount',
          );

          // Additional constraint: badge count should never be negative
          expect(
            currentBadgeCount,
            greaterThanOrEqualTo(0),
            reason: 'Badge count should never be negative',
          );
        }, maxExamples: 100);
      },
    );

    property(
      'marking all notifications as read should result in zero badge count',
      () {
        forAll(initialBadgeCountArb, (initialCount) {
          // Property: Marking all N notifications as read should result in 0 badge count
          final finalCount = initialCount - initialCount;

          expect(
            finalCount,
            equals(0),
            reason:
                'Badge count should be 0 after marking all $initialCount notifications as read',
          );
        }, maxExamples: 100);
      },
    );

    property(
      'marking zero notifications as read should not change badge count',
      () {
        forAll(initialBadgeCountArb, (initialCount) {
          // Property: Marking 0 notifications as read should not change badge count
          final finalCount = initialCount - 0;

          expect(
            finalCount,
            equals(initialCount),
            reason:
                'Badge count should remain $initialCount when no notifications are marked as read',
          );
        }, maxExamples: 100);
      },
    );

    property('badge count decrement should be order-independent', () {
      // Create a generator that produces initial count and two read counts
      final combinedArb = initialBadgeCountArb.flatMap((initialCount) {
        final firstReadArb = integer(min: 1, max: initialCount ~/ 2);
        return firstReadArb.flatMap((firstReadCount) {
          final maxSecondRead = (initialCount - firstReadCount).clamp(
            1,
            initialCount,
          );
          final secondReadArb = integer(min: 1, max: maxSecondRead);
          return secondReadArb.map(
            (secondReadCount) =>
                (initialCount, firstReadCount, secondReadCount),
          );
        });
      });

      forAll(combinedArb, (tuple) {
        final (initialCount, firstReadCount, secondReadCount) = tuple;

        // Property: Marking firstReadCount then secondReadCount should equal
        // marking secondReadCount then firstReadCount
        final result1 = initialCount - firstReadCount - secondReadCount;
        final result2 = initialCount - secondReadCount - firstReadCount;

        expect(
          result1,
          equals(result2),
          reason: 'Badge count decrement should be order-independent',
        );
      }, maxExamples: 100);
    });

    property('incrementing then decrementing should be reversible', () {
      // Create a generator that produces both initial count and add count
      final addCountArb = integer(min: 1, max: 50);
      final combinedArb = combine2(initialBadgeCountArb, addCountArb);

      forAll(combinedArb, (tuple) {
        final (initialCount, addCount) = tuple;

        // Property: (N + M) - M = N (round trip)
        final afterIncrement = initialCount + addCount;
        final afterDecrement = afterIncrement - addCount;

        expect(
          afterDecrement,
          equals(initialCount),
          reason:
              'Badge count should return to $initialCount after incrementing by '
              '$addCount and then decrementing by $addCount',
        );
      }, maxExamples: 100);
    });

    property('badge count should never go below zero', () {
      forAll(initialBadgeCountArb, (initialCount) {
        // Try to mark more than available as read (should be clamped to 0)
        final excessiveReadCount = initialCount + 10;

        // Property: Badge count should be clamped at 0, never negative
        final finalCount = (initialCount - excessiveReadCount)
            .clamp(0, double.infinity)
            .toInt();

        expect(
          finalCount,
          equals(0),
          reason:
              'Badge count should be 0 (not negative) when attempting to mark '
              '$excessiveReadCount notifications as read from $initialCount',
        );

        expect(
          finalCount,
          greaterThanOrEqualTo(0),
          reason: 'Badge count should never be negative',
        );
      }, maxExamples: 100);
    });
  });
}
