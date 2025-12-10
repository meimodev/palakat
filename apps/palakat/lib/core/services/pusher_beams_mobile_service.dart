import 'dart:developer' as developer;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:palakat_shared/core/models/permission_state.dart';
import 'package:pusher_beams/pusher_beams.dart';

import '../constants/notification_channels.dart';
import '../models/notification_payload.dart';
import '../widgets/in_app_notification/in_app_notification_banner.dart';
import 'in_app_notification_service.dart';
import 'notification_display_service.dart';
import 'permission_manager_service.dart';

/// Service for managing Pusher Beams push notifications on mobile devices.
///
/// This service handles:
/// - SDK initialization with instance ID from environment
/// - Permission flow integration
/// - Foreground notification display
/// - Subscribing to device interests for targeted notifications
/// - Unsubscribing from all interests on logout
///
/// **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5, 3.1, 3.3, 3.4, 4.1, 4.4, 4.5**
class PusherBeamsMobileService {
  static const String _tag = 'PusherBeamsMobileService';

  final PermissionManagerService? _permissionManager;
  final NotificationDisplayService? _notificationDisplay;
  final InAppNotificationService? _inAppNotificationService;

  bool _isInitialized = false;

  /// Constructor with optional dependencies for permission and notification display
  PusherBeamsMobileService({
    PermissionManagerService? permissionManager,
    NotificationDisplayService? notificationDisplay,
    InAppNotificationService? inAppNotificationService,
  }) : _permissionManager = permissionManager,
       _notificationDisplay = notificationDisplay,
       _inAppNotificationService = inAppNotificationService;

  /// Returns whether the service has been initialized
  bool get isInitialized => _isInitialized;

  /// Initialize with permission flow integration
  /// Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 4.1, 4.4, 4.5
  Future<void> initializeWithPermissions(BuildContext context) async {
    _log('initializeWithPermissions() called');

    if (_permissionManager == null) {
      _log(
        'No permission manager provided, falling back to direct initialization',
      );
      await initialize();
      return;
    }

    // Check current permission state
    final permissionState = await _permissionManager.getPermissionState();
    _log('Current permission status: ${permissionState.status}');

    if (permissionState.status == PermissionStatus.granted) {
      // Permission already granted, initialize directly
      _log('Permission already granted, initializing...');
      await initialize();
      return;
    }

    // Check if we should show rationale
    final shouldShow = await _permissionManager.shouldShowRationale();
    _log('Should show rationale: $shouldShow');

    if (shouldShow) {
      // Request permissions with rationale flow
      final status = await _permissionManager.requestPermissionsWithRationale(
        context,
      );
      _log('Permission request result: $status');

      if (status == PermissionStatus.granted) {
        // Permission granted, initialize
        await initialize();
      } else {
        _log('Permission not granted, skipping initialization');
      }
    } else {
      _log('Should not show rationale, skipping initialization');
    }
  }

  /// Set up foreground notification handler to show in-app banner
  /// Requirements: 1.1, 1.2, 1.3, 1.4, 1.5
  ///
  /// When a notification is received in the foreground, this shows an in-app
  /// banner instead of a system notification. The banner auto-dismisses and
  /// can be tapped to navigate to the related content.
  void setupForegroundNotificationHandler({
    void Function(InAppNotificationData notification)? onNotificationTapped,
  }) {
    if (_inAppNotificationService == null) {
      _log(
        'No in-app notification service provided, falling back to system notification',
      );
      _setupSystemNotificationFallback();
      return;
    }

    // Set up tap handler for in-app notifications
    if (onNotificationTapped != null) {
      _inAppNotificationService.setOnNotificationTapped(onNotificationTapped);
    }

    setOnMessageReceivedInTheForeground((notification) {
      _log('Foreground notification received: $notification');

      // Show in-app notification banner
      _inAppNotificationService.showFromMap(notification);

      // Also show system notification (like when app is in background)
      _showSystemNotification(notification);
    });

    _log(
      'Foreground notification handler set up with in-app banner and system notification',
    );
  }

  /// Fallback to system notification when in-app service is not available
  void _setupSystemNotificationFallback() {
    if (_notificationDisplay == null) {
      _log(
        'No notification display service provided, skipping foreground handler setup',
      );
      return;
    }

    setOnMessageReceivedInTheForeground((notification) {
      _log('Foreground notification received (fallback): $notification');

      // Extract payload data
      final title = notification['title'] as String? ?? 'Notification';
      final body = notification['body'] as String? ?? '';
      final icon = notification['icon'] as String?;

      // Convert data from Map<Object?, Object?> to Map<String, dynamic>
      Map<String, dynamic>? data;
      final rawData = notification['data'];
      if (rawData is Map) {
        data = <String, dynamic>{};
        rawData.forEach((key, value) {
          if (key != null) {
            data![key.toString()] = value;
          }
        });
      }

      // Create notification payload
      final payload = NotificationPayload(
        title: title,
        body: body,
        icon: icon,
        data: data,
      );

      // Get notification type and determine channel
      final type = data?['type'] as String?;
      final channelId = NotificationChannels.getChannelForType(type ?? '');

      _log(
        'Displaying system notification (fallback): title=$title, channel=$channelId',
      );

      // Display system notification
      _notificationDisplay.displayNotification(
        payload: payload,
        channelId: channelId,
      );
    });

    _log(
      'Foreground notification handler set up with system notification fallback',
    );
  }

  /// Shows a system notification from notification data map.
  ///
  /// This displays a notification in the system tray alongside
  /// the in-app banner when the app is in foreground.
  void _showSystemNotification(Map<Object?, Object?> notification) {
    if (_notificationDisplay == null) {
      _log('No notification display service, skipping system notification');
      return;
    }

    try {
      // Extract payload data
      final title = notification['title'] as String? ?? 'Notification';
      final body = notification['body'] as String? ?? '';
      final icon = notification['icon'] as String?;

      // Convert data from Map<Object?, Object?> to Map<String, dynamic>
      Map<String, dynamic>? data;
      final rawData = notification['data'];
      if (rawData is Map) {
        data = <String, dynamic>{};
        rawData.forEach((key, value) {
          if (key != null) {
            data![key.toString()] = value;
          }
        });
      }

      // Create notification payload
      final payload = NotificationPayload(
        title: title,
        body: body,
        icon: icon,
        data: data,
      );

      // Get notification type and determine channel
      final type = data?['type'] as String?;
      final channelId = NotificationChannels.getChannelForType(type ?? '');

      _log('Displaying system notification: title=$title, channel=$channelId');

      // Display system notification
      _notificationDisplay.displayNotification(
        payload: payload,
        channelId: channelId,
      );
    } catch (e, stackTrace) {
      _log('Error showing system notification: $e');
      _log('Stack trace: $stackTrace');
    }
  }

  /// Initializes the Pusher Beams SDK with the instance ID from environment.
  ///
  /// **Validates: Requirements 3.1**
  Future<void> initialize() async {
    _log('initialize() called, _isInitialized=$_isInitialized');
    if (_isInitialized) {
      _log('Already initialized, skipping');
      return;
    }

    final instanceId = dotenv.env['PUSHER_BEAMS_INSTANCE_ID'];

    if (instanceId == null || instanceId.isEmpty) {
      _log(
        'PUSHER_BEAMS_INSTANCE_ID not configured. Push notifications disabled.',
      );
      return;
    }

    try {
      // Step 1: Request notification permissions
      _log('Requesting notification permissions...');
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        _log('Notification permissions denied by user');
        return;
      }

      _log('Notification permissions granted: ${settings.authorizationStatus}');

      // Step 2: Ensure FCM token is available before starting Pusher Beams
      // Pusher Beams requires FCM token to register the device
      _log('Requesting FCM token...');
      final fcmToken = await messaging.getToken();

      if (fcmToken == null) {
        _log('Failed to get FCM token. Cannot initialize Pusher Beams.');
        return;
      }

      _log('FCM token obtained: ${fcmToken.substring(0, 20)}...');

      // Step 3: Start Pusher Beams (now that FCM is ready)
      _log(
        'Starting Pusher Beams with instance ID: ${instanceId.substring(0, 8)}...',
      );
      await PusherBeams.instance.start(instanceId);

      // Add a delay to ensure SDK is fully initialized
      await Future.delayed(const Duration(milliseconds: 1500));

      _isInitialized = true;
      _log('Initialized successfully');
    } catch (e, stackTrace) {
      _log('Failed to initialize: $e');
      _log('Stack trace: $stackTrace');
      // Don't throw - push notifications should not block app operation
    }
  }

  /// Subscribes to the specified device interests.
  ///
  /// Each interest subscription is logged for debugging purposes.
  ///
  /// **Validates: Requirements 3.3**
  Future<void> subscribeToInterests(List<String> interests) async {
    if (!_isInitialized) {
      _log('Not initialized. Skipping subscription.');
      return;
    }

    if (interests.isEmpty) {
      _log('No interests provided. Skipping subscription.');
      return;
    }

    int successCount = 0;
    int failureCount = 0;

    for (final interest in interests) {
      try {
        await PusherBeams.instance.addDeviceInterest(interest);
        _log('✓ Subscribed to interest: $interest');
        successCount++;
      } catch (e, stackTrace) {
        _log('✗ Failed to subscribe to interest $interest: $e');
        _log('Stack trace: $stackTrace');
        failureCount++;
        // Continue with other interests even if one fails
      }
    }

    _log(
      'Subscription complete. Success: $successCount, Failed: $failureCount',
    );
  }

  /// Unsubscribes from all device interests.
  ///
  /// This should be called when the user logs out.
  ///
  /// **Validates: Requirements 3.4**
  Future<void> unsubscribeFromAllInterests() async {
    if (!_isInitialized) {
      _log('Not initialized. Skipping unsubscription.');
      return;
    }

    try {
      // Get current interests for logging
      final currentInterests = await PusherBeams.instance.getDeviceInterests();

      for (final interest in currentInterests) {
        _log('Unsubscribing from interest: $interest');
      }

      await PusherBeams.instance.clearDeviceInterests();
      _log('Unsubscribed from all interests');
    } catch (e) {
      _log('Failed to unsubscribe from interests: $e');
      // Don't throw - continue with logout flow
    }
  }

  /// Clears all Pusher Beams state.
  ///
  /// This should be called after unsubscribing from interests on logout.
  ///
  /// **Validates: Requirements 3.4**
  Future<void> clearAllState() async {
    if (!_isInitialized) {
      _log('Not initialized. Skipping state clear.');
      return;
    }

    try {
      await PusherBeams.instance.clearAllState();
      _isInitialized = false;
      _log('All state cleared');
    } catch (e) {
      _log('Failed to clear state: $e');
      // Don't throw - continue with logout flow
    }
  }

  /// Gets the list of currently subscribed interests.
  Future<List<String>> getSubscribedInterests() async {
    if (!_isInitialized) {
      return [];
    }

    try {
      final interests = await PusherBeams.instance.getDeviceInterests();
      // Filter out null values and return only non-null strings
      return interests.whereType<String>().toList();
    } catch (e) {
      _log('Failed to get subscribed interests: $e');
      return [];
    }
  }

  /// Sets a callback for when a notification is received while the app is in foreground.
  void setOnMessageReceivedInTheForeground(
    void Function(Map<Object?, Object?> notification) callback,
  ) {
    if (!_isInitialized) {
      _log('Not initialized. Cannot set message callback.');
      return;
    }

    try {
      PusherBeams.instance.onMessageReceivedInTheForeground(callback);
      _log('Foreground message callback set');
    } catch (e) {
      _log('Failed to set foreground message callback: $e');
    }
  }

  /// Sets a callback for when a system notification is tapped (background/terminated).
  ///
  /// Note: For foreground notifications, the tap handler is set via
  /// setupForegroundNotificationHandler's onNotificationTapped parameter.
  ///
  /// This method is primarily for handling taps on system notifications that
  /// were shown when the app was in background or terminated state.
  ///
  /// **Validates: Requirements 3.5**
  void setOnSystemNotificationTapped(
    void Function(Map<String, dynamic> data) callback,
  ) {
    // System notification taps are handled by NotificationDisplayService
    // through flutter_local_notifications
    if (_notificationDisplay != null) {
      _notificationDisplay.setNotificationTapHandler(callback);
      _log('System notification tap callback set');
    } else {
      _log('No notification display service, cannot set tap callback');
    }
  }

  void _log(String message) {
    final logMessage = '[$_tag] $message';
    developer.log(logMessage, name: 'PusherBeams');
    debugPrint('🔔 $logMessage'); // Also print to console for visibility
  }
}
