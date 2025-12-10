import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../widgets/in_app_notification/in_app_notification_banner.dart';

/// Service for displaying in-app notification banners as overlays.
///
/// This service manages showing notification banners when the app is in foreground.
/// It uses Flutter's Overlay system to display banners at the top of the screen.
///
/// Key features:
/// - Shows animated banner at top of screen
/// - Auto-dismisses after configured duration
/// - Replaces current notification if a new one arrives
/// - Handles tap to navigate to related content
class InAppNotificationService {
  static const String _tag = 'InAppNotificationService';

  OverlayEntry? _currentOverlay;
  final GlobalKey<NavigatorState> _navigatorKey;
  void Function(InAppNotificationData notification)? _onNotificationTapped;

  InAppNotificationService({required GlobalKey<NavigatorState> navigatorKey})
    : _navigatorKey = navigatorKey;

  /// Sets the callback to be invoked when a notification banner is tapped.
  void setOnNotificationTapped(
    void Function(InAppNotificationData notification) callback,
  ) {
    _onNotificationTapped = callback;
  }

  /// Shows an in-app notification banner.
  ///
  /// If a notification is already showing, it will be replaced with the new one.
  ///
  /// [notification] - The notification data to display
  /// [displayDuration] - How long to show the banner (default: 5 seconds)
  void show({
    required InAppNotificationData notification,
    Duration displayDuration = const Duration(seconds: 8),
  }) {
    _log('Showing notification: ${notification.title}');

    // Remove any existing notification first
    _removeCurrentOverlay();

    final overlayState = _navigatorKey.currentState?.overlay;
    if (overlayState == null) {
      _log('No overlay state available, cannot show notification');
      return;
    }

    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: InAppNotificationBanner(
          notification: notification,
          displayDuration: displayDuration,
          onTap: () {
            _log('Notification tapped: ${notification.title}');
            _onNotificationTapped?.call(notification);
            _removeCurrentOverlay();
          },
          onDismiss: () {
            _log('Notification dismissed');
            _removeCurrentOverlay();
          },
        ),
      ),
    );

    overlayState.insert(_currentOverlay!);
    _log('Notification overlay inserted');
  }

  /// Shows a notification from raw notification data (Map format).
  ///
  /// This is a convenience method that parses the notification data
  /// and calls [show].
  void showFromMap(Map<Object?, Object?> notificationData) {
    try {
      final title = notificationData['title'] as String? ?? 'Notification';
      final body = notificationData['body'] as String? ?? '';
      final data = notificationData['data'] as Map<Object?, Object?>?;

      // Extract type and convert data map
      String? type;
      Map<String, dynamic>? parsedData;

      if (data != null) {
        type = data['type'] as String?;
        parsedData = _convertToStringDynamicMap(data);
      }

      final notification = InAppNotificationData(
        title: title,
        body: body,
        type: type,
        data: parsedData,
      );

      show(notification: notification);
    } catch (e) {
      _log('Error parsing notification data: $e');
    }
  }

  /// Converts a Map<Object?, Object?> to Map<String, dynamic>
  Map<String, dynamic> _convertToStringDynamicMap(Map<Object?, Object?> map) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      if (key != null) {
        result[key.toString()] = value;
      }
    });
    return result;
  }

  /// Removes the current overlay if one exists.
  void _removeCurrentOverlay() {
    if (_currentOverlay != null) {
      try {
        _currentOverlay!.remove();
      } catch (e) {
        // Overlay might already be removed
        _log('Error removing overlay: $e');
      }
      _currentOverlay = null;
    }
  }

  /// Disposes of the service and cleans up resources.
  void dispose() {
    _removeCurrentOverlay();
    _onNotificationTapped = null;
  }

  void _log(String message) {
    final logMessage = '[$_tag] $message';
    developer.log(logMessage, name: 'InAppNotification');
    debugPrint('📬 $logMessage');
  }
}
