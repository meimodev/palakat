import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/notification_channels.dart';
import '../models/notification_payload.dart';

/// Abstract interface for displaying system notifications
abstract class NotificationDisplayService {
  /// Initialize notification channels (Android)
  Future<void> initializeChannels();

  /// Display a system notification
  Future<void> displayNotification({
    required NotificationPayload payload,
    required String channelId,
    int? id,
  });

  /// Set handler for notification tap events
  void setNotificationTapHandler(
    void Function(Map<String, dynamic> data) handler,
  );

  /// Clear all notifications
  Future<void> clearAllNotifications();

  /// Update badge count (iOS)
  Future<void> updateBadgeCount(int count);

  /// Clear badge count (iOS) - convenience method for updateBadgeCount(0)
  Future<void> clearBadgeCount();

  /// Dispose and cleanup resources
  void dispose();
}

/// Implementation of NotificationDisplayService using flutter_local_notifications
class NotificationDisplayServiceImpl implements NotificationDisplayService {
  final FlutterLocalNotificationsPlugin _plugin;
  void Function(Map<String, dynamic> data)? _tapHandler;
  int _notificationIdCounter = 0;

  NotificationDisplayServiceImpl({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  /// Initialize the notification plugin
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (_tapHandler != null) {
      Map<String, dynamic> data = <String, dynamic>{};

      if (response.payload != null && response.payload!.isNotEmpty) {
        // Try to decode the payload
        try {
          data = _decodePayloadData(response.payload!);
        } catch (e) {
          // If decoding fails, pass empty data
          data = <String, dynamic>{};
        }
      }

      // Call the handler with the extracted data
      _tapHandler!(data);
    }
  }

  @override
  Future<void> initializeChannels() async {
    if (!Platform.isAndroid) return;

    try {
      // Create Android notification channels
      for (final channel in NotificationChannels.all) {
        try {
          final androidChannel = AndroidNotificationChannel(
            channel.id,
            channel.name,
            description: channel.description,
            importance: channel.importance,
            enableVibration: channel.enableVibration,
            playSound: channel.playSound,
          );

          await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
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
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: _importanceToPriority(channel.importance),
        enableVibration: channel.enableVibration,
        playSound: channel.playSound,
        icon: payload.icon ?? '@drawable/ic_notification',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
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
    } catch (e) {
      // Notification display failures should not crash the app
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

  Priority _importanceToPriority(Importance importance) {
    switch (importance) {
      case Importance.high:
      case Importance.max:
        return Priority.high;
      case Importance.low:
      case Importance.min:
        return Priority.low;
      default:
        return Priority.defaultPriority;
    }
  }

  @override
  void setNotificationTapHandler(
    void Function(Map<String, dynamic> data) handler,
  ) {
    _tapHandler = handler;
  }

  @override
  Future<void> clearAllNotifications() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      // Clearing notifications is not critical
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
            IOSFlutterLocalNotificationsPlugin
          >();

      if (iosPlugin != null) {
        // Request badge permission if not already granted
        await iosPlugin.requestPermissions(badge: true);

        // Update badge count using a notification with badge count
        // This is the recommended approach for flutter_local_notifications
        final iosDetails = DarwinNotificationDetails(
          presentAlert: false,
          presentBadge: true,
          presentSound: false,
          badgeNumber: count,
        );

        // Create notification details with the specific badge count
        final notificationDetails = NotificationDetails(iOS: iosDetails);

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

    // Reset notification ID counter
    _notificationIdCounter = 0;
  }
}
