import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Represents a notification channel configuration for Android
class NotificationChannel {
  final String id;
  final String name;
  final String description;
  final Importance importance;
  final bool enableVibration;
  final bool playSound;

  const NotificationChannel({
    required this.id,
    required this.name,
    required this.description,
    required this.importance,
    this.enableVibration = false,
    this.playSound = true,
  });
}

/// Predefined notification channels for the app
class NotificationChannels {
  NotificationChannels._();

  static const activityUpdates = NotificationChannel(
    id: 'activity_updates',
    name: 'Activity Updates',
    description: 'Notifications about church activities and events',
    importance: Importance.defaultImportance,
    enableVibration: false,
    playSound: true,
  );

  static const approvalRequests = NotificationChannel(
    id: 'approval_requests',
    name: 'Approval Requests',
    description: 'Notifications requiring your approval',
    importance: Importance.high,
    enableVibration: true,
    playSound: true,
  );

  static const generalAnnouncements = NotificationChannel(
    id: 'general_announcements',
    name: 'General Announcements',
    description: 'General church announcements',
    importance: Importance.low,
    enableVibration: false,
    playSound: false,
  );

  /// Get all notification channels
  static List<NotificationChannel> get all => [
    activityUpdates,
    approvalRequests,
    generalAnnouncements,
  ];

  /// Map notification type to appropriate channel ID
  static String getChannelForType(String notificationType) {
    switch (notificationType) {
      case 'APPROVAL_REQUIRED':
        return approvalRequests.id;
      case 'ACTIVITY_CREATED':
      case 'APPROVAL_CONFIRMED':
      case 'APPROVAL_REJECTED':
      case 'CHURCH_REQUEST_APPROVED':
      case 'CHURCH_REQUEST_REJECTED':
        return activityUpdates.id;
      default:
        return generalAnnouncements.id;
    }
  }
}
