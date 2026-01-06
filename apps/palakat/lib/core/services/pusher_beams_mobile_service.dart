import 'dart:async';
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
/// - FCM token refresh handling to maintain notification delivery
///
/// **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5, 3.1, 3.3, 3.4, 4.1, 4.4, 4.5**
class PusherBeamsMobileService {
  static const String _tag = 'PusherBeamsMobileService';

  final PermissionManagerService? _permissionManager;
  final NotificationDisplayService? _notificationDisplay;
  final InAppNotificationService? _inAppNotificationService;

  bool _isInitialized = false;

  /// Subscription for FCM token refresh events
  /// This is critical - when FCM token is refreshed, Pusher Beams needs to
  /// re-register the device to continue receiving notifications
  StreamSubscription<String>? _tokenRefreshSubscription;

  /// Stored foreground notification callback
  /// This is needed to re-register the callback after SDK restart (e.g., token refresh)
  void Function(Map<Object?, Object?> notification)? _foregroundCallback;

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
      if (!context.mounted) return;
      final status = await _permissionManager.requestPermissionsWithRationale();
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
    _log('setupForegroundNotificationHandler called');
    _log(
      '  _inAppNotificationService: ${_inAppNotificationService != null ? "exists" : "null"}',
    );
    _log(
      '  _notificationDisplay: ${_notificationDisplay != null ? "exists" : "null"}',
    );
    _log('  _isInitialized: $_isInitialized');

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
      _log('Tap handler set on in-app notification service');
    }

    _log('Setting up Pusher Beams foreground message callback...');
    setOnMessageReceivedInTheForeground((notification) {
      _log('🔔 Foreground notification received: $notification');

      // Show in-app notification banner
      _inAppNotificationService.showFromMap(notification);

      // Also show system notification (like when app is in background)
      _showSystemNotification(notification);
    });

    _log(
      '✅ Foreground notification handler set up with in-app banner and system notification',
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
      String? fcmToken = await messaging.getToken();

      // If token is null, wait a bit and retry (can happen after token deletion)
      if (fcmToken == null) {
        _log('FCM token is null, waiting and retrying...');
        await Future.delayed(const Duration(seconds: 1));
        fcmToken = await messaging.getToken();
      }

      // Try one more time with longer delay
      if (fcmToken == null) {
        _log('FCM token still null, waiting longer and retrying...');
        await Future.delayed(const Duration(seconds: 2));
        fcmToken = await messaging.getToken();
      }

      if (fcmToken == null) {
        _log(
          'Failed to get FCM token after retries. Cannot initialize Pusher Beams.',
        );
        return;
      }

      _log('FCM token obtained: ${fcmToken.substring(0, 20)}...');

      // Step 3: Clear any existing Pusher Beams state to ensure clean initialization
      // This is important for re-initialization after sign-out
      _log('Clearing any existing Pusher Beams state...');
      try {
        await PusherBeams.instance.clearAllState();
        _log('Existing state cleared');
      } catch (e) {
        _log('Clear state failed (may be first initialization): $e');
        // Continue anyway
      }

      // Step 4: Stop Pusher Beams to ensure clean state
      _log('Stopping Pusher Beams to ensure clean state...');
      try {
        await PusherBeams.instance.stop();
        _log('Pusher Beams stopped');
      } catch (e) {
        _log('Stop failed (may not have been started): $e');
        // Continue anyway - stop might fail if SDK wasn't started
      }

      // Small delay to ensure SDK is fully stopped
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 5: Start Pusher Beams fresh
      _log(
        'Starting Pusher Beams with instance ID: ${instanceId.substring(0, 8)}...',
      );
      await PusherBeams.instance.start(instanceId);

      // Add a delay to ensure SDK is fully initialized
      await Future.delayed(const Duration(milliseconds: 2000));

      // Step 6: Set up FCM token refresh listener
      // This is CRITICAL - when FCM token is refreshed (which can happen
      // periodically or after certain events), Pusher Beams needs to be
      // notified to re-register the device. Without this, notifications
      // will stop working after the token refresh.
      _setupTokenRefreshListener(instanceId);

      _isInitialized = true;
      _log('Initialized successfully');
    } catch (e, stackTrace) {
      _log('Failed to initialize: $e');
      _log('Stack trace: $stackTrace');
      // Don't throw - push notifications should not block app operation
    }
  }

  /// Sets up a listener for FCM token refresh events.
  ///
  /// When the FCM token is refreshed by Firebase (which can happen periodically
  /// or after certain events like app reinstall), Pusher Beams needs to be
  /// restarted to re-register the device with the new token.
  ///
  /// Without this, notifications will stop working after the token refresh
  /// because Pusher Beams will still be using the old token.
  void _setupTokenRefreshListener(String instanceId) {
    // Cancel any existing subscription
    _tokenRefreshSubscription?.cancel();

    _log('Setting up FCM token refresh listener...');

    _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
        .listen(
          (newToken) async {
            _log('🔄 FCM token refreshed: ${newToken.substring(0, 20)}...');
            _log('Re-registering device with Pusher Beams...');

            try {
              // Stop and restart Pusher Beams to re-register with new token
              // This is necessary because Pusher Beams caches the FCM token
              // and won't automatically pick up the new one
              await PusherBeams.instance.stop();
              await Future.delayed(const Duration(milliseconds: 500));
              await PusherBeams.instance.start(instanceId);

              // Re-register the foreground callback after SDK restart
              // This is critical - without this, foreground notifications
              // will stop working after token refresh
              _registerForegroundCallback();

              _log(
                '✅ Device re-registered with Pusher Beams after token refresh',
              );
            } catch (e) {
              _log('❌ Failed to re-register after token refresh: $e');
            }
          },
          onError: (error) {
            _log('❌ Error in token refresh listener: $error');
          },
        );

    _log('✅ FCM token refresh listener set up');
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

  /// Ensures the Pusher Beams SDK is started before performing operations.
  ///
  /// This is needed because the SDK throws null check errors if methods are
  /// called before start() has been called.
  Future<bool> _ensureSdkStarted() async {
    final instanceId = dotenv.env['PUSHER_BEAMS_INSTANCE_ID'];
    if (instanceId == null || instanceId.isEmpty) {
      _log('PUSHER_BEAMS_INSTANCE_ID not configured, cannot start SDK');
      return false;
    }

    try {
      // Try to start the SDK - if already started, this should be a no-op
      await PusherBeams.instance.start(instanceId);
      return true;
    } catch (e) {
      _log('Failed to ensure SDK started: $e');
      return false;
    }
  }

  /// Unsubscribes from all device interests.
  ///
  /// This should be called when the user logs out.
  /// This method will attempt to start the SDK if needed before clearing interests.
  ///
  /// **Validates: Requirements 3.4**
  Future<void> unsubscribeFromAllInterests() async {
    try {
      // Ensure SDK is started before calling methods
      final sdkReady = await _ensureSdkStarted();
      if (!sdkReady) {
        _log('SDK not ready, skipping unsubscription');
        return;
      }

      // Get current interests for logging
      final currentInterests = await PusherBeams.instance.getDeviceInterests();

      if (currentInterests.isEmpty) {
        _log('No interests to unsubscribe from');
        return;
      }

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

  /// Clears all Pusher Beams state including device token registration.
  ///
  /// This should be called after unsubscribing from interests on logout.
  /// This method will attempt to start the SDK if needed before clearing state.
  ///
  /// Also deletes the FCM token to ensure a fresh token is obtained on next
  /// sign-in, which is required for Pusher Beams to properly re-register
  /// the device.
  ///
  /// **Validates: Requirements 3.4**
  Future<void> clearAllState() async {
    _log('clearAllState() called');

    // Cancel token refresh subscription first
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _log('Token refresh subscription cancelled');

    // Clear stored foreground callback
    _foregroundCallback = null;

    // Mark as not initialized first
    _isInitialized = false;

    try {
      // Ensure SDK is started before calling methods
      final sdkReady = await _ensureSdkStarted();
      if (!sdkReady) {
        _log('SDK not ready, skipping Pusher Beams state clear');
      } else {
        // Clear all Pusher Beams state (while SDK is running)
        _log('Clearing Pusher Beams state...');
        try {
          await PusherBeams.instance.clearAllState();
          _log('Pusher Beams state cleared');
        } catch (e) {
          _log('Failed to clear Pusher Beams state: $e');
        }

        // Stop the SDK
        try {
          _log('Stopping Pusher Beams...');
          await PusherBeams.instance.stop();
          _log('Pusher Beams stopped');
        } catch (e) {
          _log('Failed to stop Pusher Beams: $e');
        }
      }

      // Delete FCM token to force a fresh token on next sign-in
      // This is done regardless of Pusher Beams state
      _log('Deleting FCM token...');
      try {
        await FirebaseMessaging.instance.deleteToken();
        _log('FCM token deleted');
      } catch (e) {
        _log('Failed to delete FCM token: $e');
      }

      _log('clearAllState() completed');
    } catch (e) {
      _log('Error in clearAllState: $e');
      // Don't throw - continue with logout flow
    }
  }

  /// Gets the list of currently subscribed interests.
  ///
  /// Returns an empty list if the SDK is not ready or if there's an error.
  Future<List<String>> getSubscribedInterests() async {
    try {
      // Ensure SDK is started before calling methods
      final sdkReady = await _ensureSdkStarted();
      if (!sdkReady) {
        _log('SDK not ready, returning empty interests');
        return [];
      }

      final interests = await PusherBeams.instance.getDeviceInterests();
      // Filter out null values and return only non-null strings
      return interests.whereType<String>().toList();
    } catch (e) {
      _log('Failed to get subscribed interests: $e');
      return [];
    }
  }

  /// Sets a callback for when a notification is received while the app is in foreground.
  ///
  /// IMPORTANT: The callback is registered with the Pusher Beams SDK singleton.
  /// This callback persists as long as the SDK is running. If the SDK is stopped
  /// and restarted (e.g., due to FCM token refresh), the callback will be
  /// automatically re-registered.
  void setOnMessageReceivedInTheForeground(
    void Function(Map<Object?, Object?> notification) callback,
  ) {
    _log(
      'setOnMessageReceivedInTheForeground called, _isInitialized=$_isInitialized',
    );

    // Store the callback so it can be re-registered after SDK restart
    _foregroundCallback = callback;

    if (!_isInitialized) {
      _log('❌ Not initialized. Callback stored for later registration.');
      return;
    }

    _registerForegroundCallback();
  }

  /// Internal method to register the foreground callback with the SDK.
  void _registerForegroundCallback() {
    if (_foregroundCallback == null) {
      _log('No foreground callback to register');
      return;
    }

    try {
      // Register the callback with Pusher Beams SDK
      // Note: This is a callback-based API in pusher_beams 1.1.0
      // The callback is stored internally by the SDK
      PusherBeams.instance.onMessageReceivedInTheForeground(
        _foregroundCallback!,
      );
      _log('✅ Foreground message callback set on Pusher Beams SDK');
    } catch (e, stackTrace) {
      _log('❌ Failed to set foreground message callback: $e');
      _log('Stack trace: $stackTrace');
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
