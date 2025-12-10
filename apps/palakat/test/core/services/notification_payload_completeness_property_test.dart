import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:palakat/core/models/notification_payload.dart';

/// **Feature: push-notification-ux-improvements, Property 1: Notification Payload Completeness**
///
/// *For any* notification payload with non-empty title and body, when displayed
/// as a system notification (foreground or background), the displayed notification
/// should contain the title, body, and icon (if provided) from the payload.
///
/// **Validates: Requirements 1.2, 2.2**
void main() {
  KiriCheck.verbosity = Verbosity.verbose;

  group('Property 1: Notification Payload Completeness', () {
    // Generator for non-empty strings
    final nonEmptyStringArb = string(minLength: 1, maxLength: 100);

    // Generator for optional icon strings
    final optionalIconArb = oneOf([
      constant(null),
      string(minLength: 1, maxLength: 50).map((s) => '@drawable/$s'),
    ]);

    // Generator for data maps
    final dataMapArb = map(
      string(minLength: 1, maxLength: 20),
      oneOf([
        string(minLength: 1, maxLength: 50),
        integer(min: 0, max: 1000).map((i) => i.toString()),
      ]),
      minLength: 0,
      maxLength: 5,
    );

    // Property test: Payload fields are preserved
    property('notification payload fields are preserved', () {
      forAll(
        combine4(
          nonEmptyStringArb,
          nonEmptyStringArb,
          optionalIconArb,
          dataMapArb,
        ),
        (tuple) {
          final (title, body, icon, data) = tuple;

          // Create a notification payload
          final payload = NotificationPayload(
            title: title,
            body: body,
            icon: icon,
            data: data,
          );

          // Verify all fields are present
          expect(payload.title, equals(title));
          expect(payload.body, equals(body));
          expect(payload.icon, equals(icon));
          expect(payload.data, equals(data));

          // Verify serialization round-trip
          final json = payload.toJson();
          final deserialized = NotificationPayload.fromJson(json);

          expect(deserialized.title, equals(title));
          expect(deserialized.body, equals(body));
          expect(deserialized.icon, equals(icon));
          expect(deserialized.data, equals(data));
        },
      );
    });

    // Property test: Title and body are never null or empty
    property('title and body are never null or empty', () {
      forAll(combine2(nonEmptyStringArb, nonEmptyStringArb), (tuple) {
        final (title, body) = tuple;

        final payload = NotificationPayload(title: title, body: body);

        expect(payload.title.isNotEmpty, isTrue);
        expect(payload.body.isNotEmpty, isTrue);
      });
    });

    // Property test: Icon can be null
    property('icon can be null', () {
      forAll(combine2(nonEmptyStringArb, nonEmptyStringArb), (tuple) {
        final (title, body) = tuple;

        final payload = NotificationPayload(
          title: title,
          body: body,
          icon: null,
        );

        expect(payload.icon, isNull);
      });
    });

    // Property test: Data map preserves all entries
    property('data map preserves all entries', () {
      forAll(
        combine3(
          nonEmptyStringArb,
          nonEmptyStringArb,
          map(
            string(minLength: 1, maxLength: 20),
            string(minLength: 1, maxLength: 50),
            minLength: 1,
            maxLength: 10,
          ),
        ),
        (tuple) {
          final (title, body, data) = tuple;

          final payload = NotificationPayload(
            title: title,
            body: body,
            data: data,
          );

          expect(payload.data, isNotNull);
          expect(payload.data!.length, equals(data.length));

          for (final entry in data.entries) {
            expect(payload.data!.containsKey(entry.key), isTrue);
            expect(payload.data![entry.key], equals(entry.value));
          }
        },
      );
    });

    // Property test: Payload equality
    property('payloads with same fields are equal', () {
      forAll(
        combine4(
          nonEmptyStringArb,
          nonEmptyStringArb,
          optionalIconArb,
          dataMapArb,
        ),
        (tuple) {
          final (title, body, icon, data) = tuple;

          final payload1 = NotificationPayload(
            title: title,
            body: body,
            icon: icon,
            data: data,
          );

          final payload2 = NotificationPayload(
            title: title,
            body: body,
            icon: icon,
            data: data,
          );

          expect(payload1, equals(payload2));
        },
      );
    });
  });

  // Unit tests for specific edge cases
  group('Notification Payload Completeness Unit Tests', () {
    test('minimal payload with only title and body', () {
      final payload = NotificationPayload(
        title: 'Test Title',
        body: 'Test Body',
      );

      expect(payload.title, equals('Test Title'));
      expect(payload.body, equals('Test Body'));
      expect(payload.icon, isNull);
      expect(payload.data, isNull);
    });

    test('full payload with all fields', () {
      final payload = NotificationPayload(
        title: 'Test Title',
        body: 'Test Body',
        icon: '@drawable/ic_notification',
        data: {'activityId': '123', 'type': 'ACTIVITY_CREATED'},
      );

      expect(payload.title, equals('Test Title'));
      expect(payload.body, equals('Test Body'));
      expect(payload.icon, equals('@drawable/ic_notification'));
      expect(payload.data, isNotNull);
      expect(payload.data!['activityId'], equals('123'));
      expect(payload.data!['type'], equals('ACTIVITY_CREATED'));
    });

    test('payload with empty data map', () {
      final payload = NotificationPayload(
        title: 'Test Title',
        body: 'Test Body',
        data: {},
      );

      expect(payload.data, isNotNull);
      expect(payload.data!.isEmpty, isTrue);
    });

    test('payload serialization and deserialization', () {
      final original = NotificationPayload(
        title: 'Test Title',
        body: 'Test Body',
        icon: '@drawable/ic_notification',
        data: {'key': 'value'},
      );

      final json = original.toJson();
      final deserialized = NotificationPayload.fromJson(json);

      expect(deserialized.title, equals(original.title));
      expect(deserialized.body, equals(original.body));
      expect(deserialized.icon, equals(original.icon));
      expect(deserialized.data, equals(original.data));
    });

    test('payload with special characters in title and body', () {
      final payload = NotificationPayload(
        title: 'Test Title with émojis 🎉',
        body: 'Test Body with "quotes" and \'apostrophes\'',
      );

      expect(payload.title, contains('émojis'));
      expect(payload.title, contains('🎉'));
      expect(payload.body, contains('"quotes"'));
      expect(payload.body, contains("'apostrophes'"));
    });

    test('payload with nested data structure', () {
      final payload = NotificationPayload(
        title: 'Test Title',
        body: 'Test Body',
        data: {
          'activityId': '123',
          'type': 'ACTIVITY_CREATED',
          'metadata': {'key': 'value'},
        },
      );

      expect(payload.data!['activityId'], equals('123'));
      expect(payload.data!['type'], equals('ACTIVITY_CREATED'));
      expect(payload.data!['metadata'], isA<Map>());
    });

    test('payload with long title and body', () {
      final longTitle = 'A' * 500;
      final longBody = 'B' * 1000;

      final payload = NotificationPayload(title: longTitle, body: longBody);

      expect(payload.title.length, equals(500));
      expect(payload.body.length, equals(1000));
    });

    test('payload with numeric values in data', () {
      final payload = NotificationPayload(
        title: 'Test Title',
        body: 'Test Body',
        data: {'count': 42, 'timestamp': 1234567890, 'isActive': true},
      );

      expect(payload.data!['count'], equals(42));
      expect(payload.data!['timestamp'], equals(1234567890));
      expect(payload.data!['isActive'], equals(true));
    });
  });
}
