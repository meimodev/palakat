import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart' as intl;
import 'package:palakat_shared/l10n/generated/app_localizations.dart';

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

AppLocalizations _l10n() {
  final localeName = intl.Intl.getCurrentLocale();
  final languageCode = localeName.split(RegExp('[_-]')).first;
  return lookupAppLocalizations(
    Locale(languageCode.isEmpty ? 'en' : languageCode),
  );
}

/// Predefined notification channels for the app
class NotificationChannels {
  NotificationChannels._();

  static const activityUpdatesId = 'activity_updates';
  static const approvalRequestsId = 'approval_requests';
  static const generalAnnouncementsId = 'general_announcements';
  static const activityAlarmsId = 'activity_alarms';
  static const birthdayNotificationsId = 'birthday_notifications';

  static NotificationChannel get activityUpdates {
    final l10n = _l10n();
    return NotificationChannel(
      id: activityUpdatesId,
      name: l10n.notificationChannel_activityUpdates_name,
      description: l10n.notificationChannel_activityUpdates_description,
      importance: Importance.defaultImportance,
      enableVibration: false,
      playSound: true,
    );
  }

  static NotificationChannel get approvalRequests {
    final l10n = _l10n();
    return NotificationChannel(
      id: approvalRequestsId,
      name: l10n.notificationChannel_approvalRequests_name,
      description: l10n.notificationChannel_approvalRequests_description,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );
  }

  static NotificationChannel get generalAnnouncements {
    final l10n = _l10n();
    return NotificationChannel(
      id: generalAnnouncementsId,
      name: l10n.notificationChannel_generalAnnouncements_name,
      description: l10n.notificationChannel_generalAnnouncements_description,
      importance: Importance.low,
      enableVibration: false,
      playSound: false,
    );
  }

  static NotificationChannel get activityAlarms {
    final l10n = _l10n();
    return NotificationChannel(
      id: activityAlarmsId,
      name: l10n.notificationChannel_activityAlarms_name,
      description: l10n.notificationChannel_activityAlarms_description,
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );
  }

  static NotificationChannel get birthdayNotifications {
    final l10n = _l10n();
    return NotificationChannel(
      id: birthdayNotificationsId,
      name: l10n.notificationChannel_birthdayNotifications_name,
      description: l10n.notificationChannel_birthdayNotifications_description,
      importance: Importance.defaultImportance,
      enableVibration: false,
      playSound: true,
    );
  }

  /// Get all notification channels
  static List<NotificationChannel> get all => [
    activityUpdates,
    approvalRequests,
    generalAnnouncements,
    activityAlarms,
    birthdayNotifications,
  ];

  /// Map notification type to appropriate channel ID
  static String getChannelForType(String notificationType) {
    switch (notificationType) {
      case 'APPROVAL_REQUIRED':
        return approvalRequestsId;
      case 'ACTIVITY_ALARM':
        return activityAlarmsId;
      case 'MEMBER_BIRTHDAY':
        return birthdayNotificationsId;
      case 'ACTIVITY_CREATED':
      case 'APPROVAL_CONFIRMED':
      case 'APPROVAL_REJECTED':
      case 'CHURCH_REQUEST_APPROVED':
      case 'CHURCH_REQUEST_REJECTED':
        return activityUpdatesId;
      default:
        return generalAnnouncementsId;
    }
  }
}
