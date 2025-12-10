import 'package:flutter_test/flutter_test.dart';
import 'package:palakat/core/constants/notification_channels.dart';
import 'package:palakat/core/services/pusher_beams_mobile_service.dart';

/// Unit tests for PusherBeamsMobileService
///
/// Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 4.1, 4.4, 4.5
///
/// Note: These tests focus on the logic that can be tested without
/// the actual Pusher Beams SDK or system permissions. Integration tests
/// on real devices will test the full permission flow and notification display.
void main() {
  group('PusherBeamsMobileService', () {
    test('can be instantiated without dependencies', () {
      final service = PusherBeamsMobileService();
      expect(service, isNotNull);
      expect(service.isInitialized, isFalse);
    });

    test('can be instantiated with dependencies', () {
      final service = PusherBeamsMobileService(
        permissionManager: null,
        notificationDisplay: null,
      );
      expect(service, isNotNull);
      expect(service.isInitialized, isFalse);
    });

    test('setupForegroundNotificationHandler does not throw', () {
      final service = PusherBeamsMobileService();
      expect(
        () => service.setupForegroundNotificationHandler(),
        returnsNormally,
      );
    });
  });

  group('foreground notification handler logic', () {
    test('extracts payload correctly from notification data', () {
      // This test verifies the logic of payload extraction
      // that would be used in the foreground handler

      // Arrange
      final notificationData = <Object?, Object?>{
        'title': 'Test Title',
        'body': 'Test Body',
        'icon': 'test_icon',
        'data': <String, dynamic>{
          'type': 'ACTIVITY_CREATED',
          'activityId': '123',
        },
      };

      // Extract data as the handler would
      final title = notificationData['title'] as String? ?? 'Notification';
      final body = notificationData['body'] as String? ?? '';
      final icon = notificationData['icon'] as String?;
      final data = notificationData['data'] as Map<String, dynamic>?;

      // Assert
      expect(title, 'Test Title');
      expect(body, 'Test Body');
      expect(icon, 'test_icon');
      expect(data, isNotNull);
      expect(data!['type'], 'ACTIVITY_CREATED');
      expect(data['activityId'], '123');
    });

    test('assigns correct channel for ACTIVITY_CREATED type', () {
      // Arrange
      const type = 'ACTIVITY_CREATED';

      // Act
      final channelId = NotificationChannels.getChannelForType(type);

      // Assert
      expect(channelId, NotificationChannels.activityUpdates.id);
    });

    test('assigns correct channel for APPROVAL_REQUIRED type', () {
      // Arrange
      const type = 'APPROVAL_REQUIRED';

      // Act
      final channelId = NotificationChannels.getChannelForType(type);

      // Assert
      expect(channelId, NotificationChannels.approvalRequests.id);
    });

    test('assigns correct channel for APPROVAL_CONFIRMED type', () {
      // Arrange
      const type = 'APPROVAL_CONFIRMED';

      // Act
      final channelId = NotificationChannels.getChannelForType(type);

      // Assert
      expect(channelId, NotificationChannels.activityUpdates.id);
    });

    test('assigns correct channel for APPROVAL_REJECTED type', () {
      // Arrange
      const type = 'APPROVAL_REJECTED';

      // Act
      final channelId = NotificationChannels.getChannelForType(type);

      // Assert
      expect(channelId, NotificationChannels.activityUpdates.id);
    });

    test('assigns default channel for unknown type', () {
      // Arrange
      const type = 'UNKNOWN_TYPE';

      // Act
      final channelId = NotificationChannels.getChannelForType(type);

      // Assert
      expect(channelId, NotificationChannels.generalAnnouncements.id);
    });

    test('handles missing title gracefully', () {
      // Arrange
      final notificationData = <Object?, Object?>{'body': 'Test Body'};

      // Extract data as the handler would
      final title = notificationData['title'] as String? ?? 'Notification';

      // Assert
      expect(title, 'Notification');
    });

    test('handles missing body gracefully', () {
      // Arrange
      final notificationData = <Object?, Object?>{'title': 'Test Title'};

      // Extract data as the handler would
      final body = notificationData['body'] as String? ?? '';

      // Assert
      expect(body, '');
    });

    test('handles missing data gracefully', () {
      // Arrange
      final notificationData = <Object?, Object?>{
        'title': 'Test Title',
        'body': 'Test Body',
      };

      // Extract data as the handler would
      final data = notificationData['data'] as Map<String, dynamic>?;

      // Assert
      expect(data, isNull);
    });

    test('handles missing type in data gracefully', () {
      // Arrange
      final notificationData = <Object?, Object?>{
        'title': 'Test Title',
        'body': 'Test Body',
        'data': <String, dynamic>{'activityId': '123'},
      };

      // Extract data as the handler would
      final data = notificationData['data'] as Map<String, dynamic>?;
      final type = data?['type'] as String?;
      final channelId = NotificationChannels.getChannelForType(type ?? '');

      // Assert
      expect(type, isNull);
      expect(channelId, NotificationChannels.generalAnnouncements.id);
    });
  });
}
