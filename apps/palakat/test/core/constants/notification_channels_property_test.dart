import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:palakat/core/constants/notification_channels.dart';

/// Property-based tests for NotificationChannels class.
/// **Feature: push-notification-ux-improvements**
void main() {
  group('NotificationChannels Property Tests', () {
    /// **Feature: push-notification-ux-improvements, Property 7: Notification Channel Assignment**
    /// **Validates: Requirements 8.2, 9.1, 9.2, 9.3**
    ///
    /// *For any* notification type (ACTIVITY_CREATED, APPROVAL_REQUIRED,
    /// APPROVAL_CONFIRMED, APPROVAL_REJECTED, or other), the notification
    /// SHALL be assigned to the correct channel with appropriate sound and
    /// vibration settings.
    property('Property 7: Notification Channel Assignment', () {
      forAll(_notificationTypeArbitrary(), (notificationType) {
        // Get the channel ID for this notification type
        final channelId = NotificationChannels.getChannelForType(
          notificationType,
        );

        // Find the corresponding channel configuration
        final channel = NotificationChannels.all.firstWhere(
          (ch) => ch.id == channelId,
          orElse: () => throw StateError(
            'Channel ID $channelId not found in NotificationChannels.all',
          ),
        );

        // Verify channel assignment based on notification type
        switch (notificationType) {
          case 'APPROVAL_REQUIRED':
            // Approval requests should use high importance channel
            expect(
              channelId,
              equals(NotificationChannels.approvalRequests.id),
              reason:
                  'APPROVAL_REQUIRED should map to approval_requests channel',
            );
            expect(
              channel.importance,
              equals(Importance.high),
              reason: 'Approval requests should have HIGH importance',
            );
            expect(
              channel.enableVibration,
              isTrue,
              reason: 'Approval requests should enable vibration',
            );
            expect(
              channel.playSound,
              isTrue,
              reason: 'Approval requests should play sound',
            );
            break;

          case 'ACTIVITY_CREATED':
          case 'APPROVAL_CONFIRMED':
          case 'APPROVAL_REJECTED':
            // Activity updates should use default importance channel
            expect(
              channelId,
              equals(NotificationChannels.activityUpdates.id),
              reason:
                  '$notificationType should map to activity_updates channel',
            );
            expect(
              channel.importance,
              equals(Importance.defaultImportance),
              reason: 'Activity updates should have DEFAULT importance',
            );
            expect(
              channel.enableVibration,
              isFalse,
              reason: 'Activity updates should NOT enable vibration',
            );
            expect(
              channel.playSound,
              isTrue,
              reason: 'Activity updates should play sound',
            );
            break;

          default:
            // Unknown types should use general announcements channel
            expect(
              channelId,
              equals(NotificationChannels.generalAnnouncements.id),
              reason:
                  'Unknown type $notificationType should map to general_announcements channel',
            );
            expect(
              channel.importance,
              equals(Importance.low),
              reason: 'General announcements should have LOW importance',
            );
            expect(
              channel.enableVibration,
              isFalse,
              reason: 'General announcements should NOT enable vibration',
            );
            expect(
              channel.playSound,
              isFalse,
              reason: 'General announcements should NOT play sound',
            );
        }

        // Verify channel has required properties
        expect(
          channel.id,
          isNotEmpty,
          reason: 'Channel ID should not be empty',
        );
        expect(
          channel.name,
          isNotEmpty,
          reason: 'Channel name should not be empty',
        );
        expect(
          channel.description,
          isNotEmpty,
          reason: 'Channel description should not be empty',
        );
      });
    });

    /// Additional test: All channels are properly configured
    test('All notification channels have valid configuration', () {
      final allChannels = NotificationChannels.all;

      // Verify we have exactly 3 channels
      expect(
        allChannels.length,
        equals(3),
        reason: 'Should have exactly 3 notification channels',
      );

      // Verify each channel has unique ID
      final channelIds = allChannels.map((ch) => ch.id).toSet();
      expect(
        channelIds.length,
        equals(allChannels.length),
        reason: 'All channel IDs should be unique',
      );

      // Verify each channel has required properties
      for (final channel in allChannels) {
        expect(
          channel.id,
          isNotEmpty,
          reason: 'Channel ID should not be empty',
        );
        expect(
          channel.name,
          isNotEmpty,
          reason: 'Channel name should not be empty',
        );
        expect(
          channel.description,
          isNotEmpty,
          reason: 'Channel description should not be empty',
        );
      }
    });

    /// Additional test: Channel constants are accessible
    test('Channel constants are properly defined', () {
      // Verify activity updates channel
      expect(
        NotificationChannels.activityUpdates.id,
        equals('activity_updates'),
      );
      expect(
        NotificationChannels.activityUpdates.importance,
        equals(Importance.defaultImportance),
      );
      expect(NotificationChannels.activityUpdates.enableVibration, isFalse);
      expect(NotificationChannels.activityUpdates.playSound, isTrue);

      // Verify approval requests channel
      expect(
        NotificationChannels.approvalRequests.id,
        equals('approval_requests'),
      );
      expect(
        NotificationChannels.approvalRequests.importance,
        equals(Importance.high),
      );
      expect(NotificationChannels.approvalRequests.enableVibration, isTrue);
      expect(NotificationChannels.approvalRequests.playSound, isTrue);

      // Verify general announcements channel
      expect(
        NotificationChannels.generalAnnouncements.id,
        equals('general_announcements'),
      );
      expect(
        NotificationChannels.generalAnnouncements.importance,
        equals(Importance.low),
      );
      expect(
        NotificationChannels.generalAnnouncements.enableVibration,
        isFalse,
      );
      expect(NotificationChannels.generalAnnouncements.playSound, isFalse);
    });
  });
}

// ============================================================================
// Arbitrary generators
// ============================================================================

/// Generates notification types including known types and random unknown types.
Arbitrary<String> _notificationTypeArbitrary() {
  // All possible notification types to test
  final allTypes = [
    'ACTIVITY_CREATED',
    'APPROVAL_REQUIRED',
    'APPROVAL_CONFIRMED',
    'APPROVAL_REJECTED',
    'UNKNOWN_TYPE',
    'RANDOM_EVENT',
    'TEST_NOTIFICATION',
    'CUSTOM_TYPE',
    '',
  ];

  return integer(
    min: 0,
    max: allTypes.length - 1,
  ).map((index) => allTypes[index]);
}
