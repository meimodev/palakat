import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as notifications;
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart' as tz;

import '../constants/notification_channels.dart';
import '../models/notification_payload.dart';
import '../routing/app_routing.dart';

/// Abstract interface for displaying system notifications
abstract class NotificationDisplayService {
  /// Initialize notification channels (Android)
  Future<void> initializeChannels();

  /// Display a system notification
  Future<void> displayNotification({
    required NotificationPayload payload,
    required String channelId,
    int? id,
    bool fullScreenIntent = false,
  });

  Future<void> scheduleNotification({
    required NotificationPayload payload,
    required String channelId,
    required DateTime scheduledAt,
    required int id,
    bool fullScreenIntent = false,
  });

  /// Set handler for notification tap events
  void setNotificationTapHandler(
    void Function(Map<String, dynamic> data) handler,
  );

  /// Clear all notifications
  Future<void> clearAllNotifications();

  Future<void> cancelNotification(int id);

  Future<List<notifications.PendingNotificationRequest>>
  pendingNotificationRequests();

  Future<bool> canScheduleExactNotifications();

  /// Update badge count (iOS)
  Future<void> updateBadgeCount(int count);

  /// Clear badge count (iOS) - convenience method for updateBadgeCount(0)
  Future<void> clearBadgeCount();

  /// Dispose and cleanup resources
  void dispose();
}

/// Implementation of NotificationDisplayService using flutter_local_notifications
class NotificationDisplayServiceImpl implements NotificationDisplayService {
  final notifications.FlutterLocalNotificationsPlugin _plugin;
  void Function(Map<String, dynamic> data)? _tapHandler;
  Map<String, dynamic>? _pendingTapData;
  int _notificationIdCounter = 0;
  final Map<int, Timer> _foregroundAlarmTimers = <int, Timer>{};

  NotificationDisplayServiceImpl({
    notifications.FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? notifications.FlutterLocalNotificationsPlugin();

  /// Initialize the notification plugin
  Future<void> initialize() async {
    const androidSettings = notifications.AndroidInitializationSettings(
      '@drawable/ic_notification',
    );
    const iosSettings = notifications.DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = notifications.InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    try {
      final launchDetails = await _plugin.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        final response = launchDetails?.notificationResponse;
        if (response != null) {
          _onNotificationTapped(response);
        }
      }
    } catch (_) {}
  }

  void _onNotificationTapped(notifications.NotificationResponse response) {
    Map<String, dynamic> data = <String, dynamic>{};

    if (response.payload != null && response.payload!.isNotEmpty) {
      // Try to decode the payload
      try {
        data = _decodePayloadData(response.payload!);
      } catch (_) {
        // If decoding fails, pass empty data
        data = <String, dynamic>{};
      }
    }

    if (_tapHandler != null) {
      _tapHandler!(data);
      return;
    }

    _pendingTapData = data;
    if (kDebugMode) {
      debugPrint(
        '[NotificationDisplayService] Notification tap received before handler was set; buffering. data=$data',
      );
    }
  }

  @override
  Future<void> initializeChannels() async {
    if (!Platform.isAndroid) return;

    try {
      // Create Android notification channels
      for (final channel in NotificationChannels.all) {
        try {
          final androidChannel = notifications.AndroidNotificationChannel(
            channel.id,
            channel.name,
            description: channel.description,
            importance: channel.importance,
            enableVibration: channel.enableVibration,
            playSound: channel.playSound,
          );

          await _plugin
              .resolvePlatformSpecificImplementation<
                notifications.AndroidFlutterLocalNotificationsPlugin
              >()
              ?.createNotificationChannel(androidChannel);
        } catch (e) {
          // Continue with other channels if one fails
        }
      }
    } catch (e) {
      // App should continue to work even if channel init fails
    }
  }

  @override
  Future<void> displayNotification({
    required NotificationPayload payload,
    required String channelId,
    int? id,
    bool fullScreenIntent = false,
  }) async {
    try {
      // Validate payload before processing
      final validationError = payload.validate();
      if (validationError != null) {
        throw ArgumentError('Invalid notification payload: $validationError');
      }

      final notificationId = id ?? _notificationIdCounter++;

      // Find the channel configuration
      final channel = NotificationChannels.all.firstWhere(
        (c) => c.id == channelId,
        orElse: () => NotificationChannels.generalAnnouncements,
      );

      // Create platform-specific notification details
      final androidDetails = notifications.AndroidNotificationDetails(
        channelId,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: _importanceToPriority(channel.importance),
        enableVibration: channel.enableVibration,
        playSound: channel.playSound,
        icon: payload.icon ?? '@drawable/ic_notification',
        category: fullScreenIntent
            ? notifications.AndroidNotificationCategory.alarm
            : null,
        fullScreenIntent: fullScreenIntent,
        audioAttributesUsage: fullScreenIntent
            ? notifications.AudioAttributesUsage.alarm
            : notifications.AudioAttributesUsage.notification,
        visibility: fullScreenIntent
            ? notifications.NotificationVisibility.public
            : null,
        autoCancel: !fullScreenIntent,
        ongoing: fullScreenIntent,
        additionalFlags: fullScreenIntent ? Int32List.fromList(<int>[4]) : null,
      );

      const iosDetails = notifications.DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = notifications.NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Convert data to payload string for tap handling
      String? payloadString;
      if (payload.data != null) {
        try {
          payloadString = _encodePayloadData(payload.data!);
        } catch (e) {
          // If encoding fails, use string representation
          payloadString = payload.data.toString();
        }
      }

      // Display the notification
      await _plugin.show(
        notificationId,
        payload.title,
        payload.body,
        notificationDetails,
        payload: payloadString,
      );

      if (fullScreenIntent) {
        _scheduleForegroundAlarmNavigationFallback(
          id: notificationId,
          scheduledAt: DateTime.now(),
          data: payload.data,
        );
      }
    } catch (e) {
      // Notification display failures should not crash the app
      if (kDebugMode) {
        debugPrint(
          '[NotificationDisplayService] Failed to display notification (id=$id, channel=$channelId): $e',
        );
      }
    }
  }

  @override
  Future<void> scheduleNotification({
    required NotificationPayload payload,
    required String channelId,
    required DateTime scheduledAt,
    required int id,
    bool fullScreenIntent = false,
  }) async {
    try {
      _foregroundAlarmTimers.remove(id)?.cancel();

      final validationError = payload.validate();
      if (validationError != null) {
        throw ArgumentError('Invalid notification payload: $validationError');
      }

      final channel = NotificationChannels.all.firstWhere(
        (c) => c.id == channelId,
        orElse: () => NotificationChannels.generalAnnouncements,
      );

      String? payloadString;
      if (payload.data != null) {
        try {
          payloadString = _encodePayloadData(payload.data!);
        } catch (e) {
          payloadString = payload.data.toString();
        }
      }

      final androidDetails = notifications.AndroidNotificationDetails(
        channelId,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: _importanceToPriority(channel.importance),
        enableVibration: channel.enableVibration,
        playSound: channel.playSound,
        icon: payload.icon ?? '@drawable/ic_notification',
        category: notifications.AndroidNotificationCategory.alarm,
        fullScreenIntent: fullScreenIntent,
        audioAttributesUsage: fullScreenIntent
            ? notifications.AudioAttributesUsage.alarm
            : notifications.AudioAttributesUsage.notification,
        visibility: fullScreenIntent
            ? notifications.NotificationVisibility.public
            : null,
        autoCancel: !fullScreenIntent,
        ongoing: fullScreenIntent,
        additionalFlags: fullScreenIntent ? Int32List.fromList(<int>[4]) : null,
      );

      const iosDetails = notifications.DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = notifications.NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final tzDateTime = tz.TZDateTime.from(scheduledAt, tz.local);

      notifications.AndroidScheduleMode androidScheduleMode =
          notifications.AndroidScheduleMode.exactAllowWhileIdle;
      if (Platform.isAndroid) {
        final androidImpl = _plugin
            .resolvePlatformSpecificImplementation<
              notifications.AndroidFlutterLocalNotificationsPlugin
            >();
        final canExact =
            await androidImpl?.canScheduleExactNotifications() ?? true;
        if (!canExact) {
          androidScheduleMode =
              notifications.AndroidScheduleMode.inexactAllowWhileIdle;
        } else if (fullScreenIntent) {
          androidScheduleMode = notifications.AndroidScheduleMode.alarmClock;
        }
      }

      if (kDebugMode) {
        debugPrint(
          '[NotificationDisplayService] Scheduling notification (id=$id, channel=$channelId, at=$scheduledAt, tzAt=$tzDateTime, mode=$androidScheduleMode, fullScreen=$fullScreenIntent)',
        );
      }

      await _plugin.zonedSchedule(
        id,
        payload.title,
        payload.body,
        tzDateTime,
        notificationDetails,
        payload: payloadString,
        androidScheduleMode: androidScheduleMode,
        uiLocalNotificationDateInterpretation:
            notifications.UILocalNotificationDateInterpretation.absoluteTime,
      );

      if (fullScreenIntent) {
        _scheduleForegroundAlarmNavigationFallback(
          id: id,
          scheduledAt: scheduledAt,
          data: payload.data,
        );
      }

      if (kDebugMode) {
        final pending = await pendingNotificationRequests();
        debugPrint(
          '[NotificationDisplayService] Scheduled OK (id=$id). Pending scheduled count=${pending.length}',
        );
      }
    } catch (e) {
      // Scheduling failures should not crash the app
      if (kDebugMode) {
        debugPrint(
          '[NotificationDisplayService] Failed to schedule notification (id=$id, channel=$channelId, at=$scheduledAt): $e',
        );
      }
    }
  }

  @override
  Future<List<notifications.PendingNotificationRequest>>
  pendingNotificationRequests() async {
    try {
      return await _plugin.pendingNotificationRequests();
    } catch (_) {
      return <notifications.PendingNotificationRequest>[];
    }
  }

  @override
  Future<bool> canScheduleExactNotifications() async {
    if (!Platform.isAndroid) return true;

    try {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            notifications.AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidImpl?.canScheduleExactNotifications() ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Encode payload data as a simple string format
  /// Format: key1=value1;key2=value2
  String _encodePayloadData(Map<String, dynamic> data) {
    try {
      final parts = <String>[];
      data.forEach((key, value) {
        // Sanitize key and value to avoid issues with delimiters
        final sanitizedKey = key.toString().replaceAll(RegExp(r'[=;]'), '_');
        final sanitizedValue = value.toString().replaceAll(
          RegExp(r'[=;]'),
          '_',
        );
        parts.add('$sanitizedKey=$sanitizedValue');
      });
      return parts.join(';');
    } catch (e) {
      rethrow;
    }
  }

  /// Decode payload data from string format
  Map<String, dynamic> _decodePayloadData(String payload) {
    try {
      final data = <String, dynamic>{};
      if (payload.isEmpty) return data;

      final parts = payload.split(';');
      for (final part in parts) {
        if (part.isEmpty) continue;

        final keyValue = part.split('=');
        if (keyValue.length >= 2) {
          final key = keyValue[0];
          // Handle values that might contain '=' by joining the rest
          final value = keyValue.sublist(1).join('=');
          data[key] = value;
        }
      }
      return data;
    } catch (e) {
      return <String, dynamic>{};
    }
  }

  notifications.Priority _importanceToPriority(
    notifications.Importance importance,
  ) {
    switch (importance) {
      case notifications.Importance.high:
        return notifications.Priority.high;
      case notifications.Importance.max:
        return notifications.Priority.max;
      case notifications.Importance.low:
      case notifications.Importance.min:
        return notifications.Priority.low;
      default:
        return notifications.Priority.defaultPriority;
    }
  }

  @override
  void setNotificationTapHandler(
    void Function(Map<String, dynamic> data) handler,
  ) {
    _tapHandler = handler;

    final pending = _pendingTapData;
    if (pending != null) {
      _pendingTapData = null;
      try {
        handler(pending);
      } catch (_) {}
    }
  }

  @override
  Future<void> clearAllNotifications() async {
    try {
      for (final timer in _foregroundAlarmTimers.values) {
        timer.cancel();
      }
      _foregroundAlarmTimers.clear();
      await _plugin.cancelAll();
    } catch (e) {
      // Clearing notifications is not critical
    }
  }

  @override
  Future<void> cancelNotification(int id) async {
    try {
      _foregroundAlarmTimers.remove(id)?.cancel();
      await _plugin.cancel(id);
    } catch (_) {
      // Cancelling notifications is not critical
    }
  }

  @override
  Future<void> updateBadgeCount(int count) async {
    if (!Platform.isIOS) return;

    try {
      // Validate badge count
      if (count < 0) {
        count = 0;
      }

      // Get iOS-specific plugin implementation
      final iosPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            notifications.IOSFlutterLocalNotificationsPlugin
          >();

      if (iosPlugin != null) {
        // Request badge permission if not already granted
        await iosPlugin.requestPermissions(badge: true);

        // Update badge count using a notification with badge count
        // This is the recommended approach for flutter_local_notifications
        final iosDetails = notifications.DarwinNotificationDetails(
          presentAlert: false,
          presentBadge: true,
          presentSound: false,
          badgeNumber: count,
        );

        // Create notification details with the specific badge count
        final notificationDetails = notifications.NotificationDetails(
          iOS: iosDetails,
        );

        // Show a silent notification that only updates the badge
        // Use a unique ID that we can cancel immediately
        const badgeUpdateId = 999999;

        await _plugin.show(
          badgeUpdateId,
          null, // No title
          null, // No body
          notificationDetails,
        );

        // Immediately cancel the notification so it doesn't appear in notification center
        // but the badge count remains
        await _plugin.cancel(badgeUpdateId);
      }
    } catch (e) {
      // Badge count updates are not critical
    }
  }

  @override
  Future<void> clearBadgeCount() async {
    // Clear badge count by setting it to 0
    await updateBadgeCount(0);
  }

  @override
  void dispose() {
    // Clear any handlers
    _tapHandler = null;

    for (final timer in _foregroundAlarmTimers.values) {
      timer.cancel();
    }
    _foregroundAlarmTimers.clear();

    // Reset notification ID counter
    _notificationIdCounter = 0;
  }

  void _scheduleForegroundAlarmNavigationFallback({
    required int id,
    required DateTime scheduledAt,
    required Map<String, dynamic>? data,
  }) {
    if (!Platform.isAndroid) return;
    if (data == null) return;

    final type = data['type']?.toString();
    if (type != 'ACTIVITY_ALARM') return;

    final activityId = int.tryParse(data['activityId']?.toString() ?? '');
    if (activityId == null) return;

    final now = DateTime.now();
    var delay = scheduledAt.difference(now);
    if (delay.isNegative) return;

    _foregroundAlarmTimers.remove(id)?.cancel();
    _foregroundAlarmTimers[id] = Timer(delay, () {
      _foregroundAlarmTimers.remove(id);

      final lifecycleState = SchedulerBinding.instance.lifecycleState;
      if (lifecycleState != AppLifecycleState.resumed) {
        return;
      }

      final context = navigatorKey.currentContext;
      if (context == null) {
        return;
      }

      try {
        GoRouter.of(context).pushNamed(
          AppRoute.alarmRing,
          pathParameters: {'activityId': activityId.toString()},
          extra: RouteParam(
            params: {
              'title': data['title'],
              'reminderName': data['reminderName'],
              'reminderValue': data['reminderValue'],
              'alarmKey': data['alarmKey'],
              'notificationId': int.tryParse(
                data['notificationId']?.toString() ?? '',
              ),
            },
          ),
        );
      } catch (_) {
        // Ignore navigation errors
      }
    });
  }
}
