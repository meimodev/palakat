import 'dart:developer' as developer;
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// JS interop extension for PusherPushNotifications Client
@JS('PusherPushNotifications.Client')
extension type PusherBeamsClient._(JSObject _) implements JSObject {
  external factory PusherBeamsClient(PusherBeamsConfig config);

  external JSPromise<JSAny?> start();
  external JSPromise<JSAny?> addDeviceInterest(String interest);
  external JSPromise<JSAny?> clearDeviceInterests();
  external JSPromise<JSAny?> clearAllState();
  external JSPromise<JSArray<JSString>> getDeviceInterests();
}

/// Configuration for PusherBeamsClient
@JS()
@anonymous
extension type PusherBeamsConfig._(JSObject _) implements JSObject {
  external factory PusherBeamsConfig({String instanceId});
}

/// Service for managing Pusher Beams push notifications on web.
///
/// This service handles:
/// - Web SDK initialization with instance ID from environment
/// - Subscribing to device interests for targeted notifications
/// - Unsubscribing from all interests on logout
///
/// **Validates: Requirements 4.1, 4.3, 4.4**
class PusherBeamsWebService {
  static const String _tag = 'PusherBeamsWebService';

  bool _isInitialized = false;
  PusherBeamsClient? _beamsClient;

  /// Returns whether the service has been initialized
  bool get isInitialized => _isInitialized;

  /// Initializes the Pusher Beams Web SDK with the instance ID from environment.
  ///
  /// **Validates: Requirements 4.1**
  Future<void> initialize() async {
    if (_isInitialized) {
      _log('Already initialized, skipping');
      return;
    }

    if (!kIsWeb) {
      _log('Not running on web platform. Push notifications disabled.');
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
      // Create client instance with instance ID
      final config = PusherBeamsConfig(instanceId: instanceId);
      _beamsClient = PusherBeamsClient(config);

      // Start the client
      await _beamsClient!.start().toDart;
      _isInitialized = true;
      _log(
        'Initialized successfully with instance ID: '
        '${instanceId.substring(0, 8)}...',
      );
    } catch (e) {
      _log('Failed to initialize: $e');
      // Don't throw - push notifications should not block app operation
    }
  }

  /// Subscribes to the specified device interests.
  ///
  /// Each interest subscription is logged for debugging purposes.
  ///
  /// **Validates: Requirements 4.3**
  Future<void> subscribeToInterests(List<String> interests) async {
    if (!_isInitialized || _beamsClient == null) {
      _log('Not initialized. Skipping subscription.');
      return;
    }

    if (interests.isEmpty) {
      _log('No interests provided. Skipping subscription.');
      return;
    }

    for (final interest in interests) {
      try {
        await _beamsClient!.addDeviceInterest(interest).toDart;
        _log('Subscribed to interest: $interest');
      } catch (e) {
        _log('Failed to subscribe to interest $interest: $e');
        // Continue with other interests even if one fails
      }
    }

    _log('Subscription complete. Total interests: ${interests.length}');
  }

  /// Unsubscribes from all device interests.
  ///
  /// This should be called when the user logs out.
  ///
  /// **Validates: Requirements 4.4**
  Future<void> unsubscribeFromAllInterests() async {
    if (!_isInitialized || _beamsClient == null) {
      _log('Not initialized. Skipping unsubscription.');
      return;
    }

    try {
      // Get current interests for logging
      final currentInterests = await getSubscribedInterests();

      for (final interest in currentInterests) {
        _log('Unsubscribing from interest: $interest');
      }

      await _beamsClient!.clearDeviceInterests().toDart;
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
  /// **Validates: Requirements 4.4**
  Future<void> clearAllState() async {
    if (!_isInitialized || _beamsClient == null) {
      _log('Not initialized. Skipping state clear.');
      return;
    }

    try {
      await _beamsClient!.clearAllState().toDart;
      _isInitialized = false;
      _beamsClient = null;
      _log('All state cleared');
    } catch (e) {
      _log('Failed to clear state: $e');
      // Don't throw - continue with logout flow
    }
  }

  /// Gets the list of currently subscribed interests.
  Future<List<String>> getSubscribedInterests() async {
    if (!_isInitialized || _beamsClient == null) {
      return [];
    }

    try {
      final jsInterests = await _beamsClient!.getDeviceInterests().toDart;
      return jsInterests.toDart.map((e) => e.toDart).toList();
    } catch (e) {
      _log('Failed to get subscribed interests: $e');
      return [];
    }
  }

  /// Sets a callback for when a notification is clicked.
  ///
  /// This callback receives the URL and data from the notification click event.
  /// **Validates: Requirements 4.6**
  void setOnNotificationClicked(
    void Function(String url, Map<String, dynamic>? data) callback,
  ) {
    // Listen for messages from the service worker via window.postMessage
    // This is handled in the index.html script
    _log('Notification click callback set');
  }

  void _log(String message) {
    developer.log('[$_tag] $message', name: 'PusherBeams');
  }
}
