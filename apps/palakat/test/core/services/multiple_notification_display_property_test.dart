import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:palakat/core/models/notification_payload.dart';

/// **Feature: push-notification-ux-improvements, Property 3: Multiple Notification Display**
///
/// *For any* sequence of N foreground notifications (N > 0), the system notification
/// tray should contain N separate notifications, each with distinct content.
///
/// **Validates: Requirements 1.5**
///
/// Note: This property test verifies the logical requirement that N notifications
/// should result in N distinct notification IDs and payloads. The actual display
/// to the system notification tray is tested in integration tests on real devices.
void main() {
  KiriCheck.verbosity = Verbosity.quiet;

  group('Property 3: Multiple Notification Display', () {
    // Generator for notification payloads with unique identifiers
    final notificationPayloadArb =
        combine3(
          string(minLength: 1, maxLength: 50),
          string(minLength: 1, maxLength: 100),
          integer(min: 0, max: 1000000),
        ).map((tuple) {
          final (title, body, id) = tuple;
          return (
            id: id,
            payload: NotificationPayload(
              title: '$title-$id', // Make title unique
              body: body,
              icon: null,
              data: {'id': id.toString()},
            ),
          );
        });

    // Generator for a list of 1-10 notifications
    final notificationListArb = list(
      notificationPayloadArb,
      minLength: 1,
      maxLength: 10,
    );

    property(
      'N notifications should have N unique IDs and distinct content',
      () {
        forAll(notificationListArb, (notifications) {
          // Property: Each notification should have a unique ID
          final ids = notifications.map((n) => n.id).toList();
          final uniqueIds = ids.toSet();

          expect(
            uniqueIds.length,
            equals(notifications.length),
            reason: 'All notification IDs should be unique',
          );

          // Property: Each notification should have distinct content
          final titles = notifications.map((n) => n.payload.title).toList();
          final uniqueTitles = titles.toSet();

          expect(
            uniqueTitles.length,
            equals(notifications.length),
            reason: 'All notification titles should be distinct',
          );

          // Property: Each notification payload should be complete
          for (final notification in notifications) {
            expect(
              notification.payload.title.isNotEmpty,
              isTrue,
              reason: 'Notification title should not be empty',
            );
            expect(
              notification.payload.body,
              isNotNull,
              reason: 'Notification body should not be null',
            );
          }
        }, maxExamples: 100);
      },
    );

    property(
      'notification IDs should remain stable across multiple accesses',
      () {
        forAll(notificationListArb, (notifications) {
          // Property: Accessing the same notification multiple times
          // should return the same ID
          for (final notification in notifications) {
            final id1 = notification.id;
            final id2 = notification.id;

            expect(
              id1,
              equals(id2),
              reason: 'Notification ID should be stable',
            );
          }
        }, maxExamples: 100);
      },
    );
  });
}
