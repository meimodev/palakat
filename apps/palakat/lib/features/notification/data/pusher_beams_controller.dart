import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/services/in_app_notification_service.dart';
import 'package:palakat/core/services/notification_display_service_provider.dart';
import 'package:palakat/core/services/pusher_beams_mobile_service.dart';
import 'package:palakat/core/widgets/in_app_notification/in_app_notification_banner.dart';
import 'package:palakat_shared/core/extension/account_extension.dart';
import 'package:palakat_shared/core/models/membership.dart';
import 'package:palakat_shared/core/utils/interest_builder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pusher_beams_controller.g.dart';

/// Controller for managing Pusher Beams push notification subscriptions.
///
/// This controller handles:
/// - Registering device interests based on user membership data
/// - Unregistering all interests on logout
/// - Logging each interest registration/unregistration
///
/// **Validates: Requirements 3.2, 3.3, 3.4**
@riverpod
class PusherBeamsController extends _$PusherBeamsController {
  static const String _tag = 'PusherBeamsController';

  PusherBeamsMobileService? _service;

  InAppNotificationService? _inAppNotificationService;

  @override
  void build() {
    // Initialize the in-app notification service with navigator key
    _inAppNotificationService = InAppNotificationService(
      navigatorKey: navigatorKey,
    );

    // Get the shared notification display service (initialized in main.dart)
    final notificationDisplay = ref.read(
      notificationDisplayServiceSyncProvider,
    );

    // Initialize the service with proper dependencies
    _service = PusherBeamsMobileService(
      notificationDisplay: notificationDisplay,
      inAppNotificationService: _inAppNotificationService,
    );
  }

  /// Registers device interests for the given membership.
  ///
  /// Subscribes to the following interests:
  /// - Global interest (palakat)
  /// - Church interest (church.{churchId})
  /// - BIPRA interest (church.{churchId}_bipra.{BIPRA})
  /// - Column interest (church.{churchId}_column.{columnId}) if applicable
  /// - Column BIPRA interest if applicable
  /// - Membership interest (membership.{membershipId})
  ///
  /// Each interest registration is logged for debugging.
  ///
  /// **Validates: Requirements 3.2, 3.3**
  Future<void> registerInterests(Membership membership) async {
    if (_service == null) {
      _log('Service not initialized');
      return;
    }

    // Ensure service is initialized
    if (!_service!.isInitialized) {
      _log('Initializing Pusher Beams service...');
      await _service!.initialize();

      // Check if initialization was successful
      if (!_service!.isInitialized) {
        _log(
          'Failed to initialize service. Check PUSHER_BEAMS_INSTANCE_ID in .env',
        );
        return;
      }
    }

    // Extract required data from membership
    final membershipId = membership.id;
    final churchId = membership.church?.id;
    final account = membership.account;

    // Validate required fields
    if (membershipId == null) {
      _log('Cannot register interests: membership ID is null');
      return;
    }

    if (churchId == null) {
      _log('Cannot register interests: church ID is null');
      return;
    }

    if (account == null) {
      _log('Cannot register interests: account is null');
      return;
    }

    // Get BIPRA from account using the calculateBipra extension
    final bipra = account.calculateBipra.abv;

    final columnId = membership.column?.id;

    _log(
      'Registering interests for membership $membershipId, church $churchId, BIPRA $bipra',
    );

    // Build all applicable interests using InterestBuilder
    final interests = InterestBuilder.buildUserInterests(
      membershipId: membershipId,
      churchId: churchId,
      bipra: bipra,
      columnId: columnId,
    );

    _log('Built ${interests.length} interests: ${interests.join(", ")}');

    // Subscribe to all interests
    await _service!.subscribeToInterests(interests);

    // Set up foreground notification handler to show in-app banners
    _setupForegroundNotificationHandler(membershipId);

    // Set up background/system notification tap handler
    _setupNotificationTapHandler(membershipId);

    _log('Successfully registered all interests');
  }

  /// Sets up foreground notification handler to show in-app banners.
  ///
  /// When the app is in foreground and receives a notification,
  /// this displays an in-app banner at the top of the screen.
  void _setupForegroundNotificationHandler(int currentMembershipId) {
    if (_service == null || !_service!.isInitialized) {
      _log('Service not ready for foreground notification handler');
      return;
    }

    _service!.setupForegroundNotificationHandler(
      onNotificationTapped: (notification) {
        _log('In-app notification tapped: ${notification.title}');
        _handleInAppNotificationTap(notification, currentMembershipId);
      },
    );

    _log('Foreground notification handler set up');
  }

  /// Handles tap on in-app notification banner.
  void _handleInAppNotificationTap(
    InAppNotificationData notification,
    int currentMembershipId,
  ) {
    try {
      final data = notification.data;
      if (data == null) {
        _log('No data in notification, skipping navigation');
        return;
      }

      final activityId = _parseIntValue(data['activityId']);
      final notificationType = notification.type;

      if (activityId == null) {
        _log('No activityId in notification, skipping navigation');
        return;
      }

      final context = navigatorKey.currentContext;
      if (context == null) {
        _log('No navigator context available');
        return;
      }

      if (notificationType == 'APPROVAL_REQUIRED' ||
          notificationType == 'APPROVAL_CONFIRMED' ||
          notificationType == 'APPROVAL_REJECTED') {
        _log('Navigating to approval detail for activity $activityId');
        context.pushNamed(
          AppRoute.approvalDetail,
          extra: RouteParam(
            params: {
              'activityId': activityId,
              'currentMembershipId': currentMembershipId,
            },
          ),
        );
      } else {
        _log('Navigating to activity detail for activity $activityId');
        context.pushNamed(
          AppRoute.activityDetail,
          pathParameters: {'activityId': activityId.toString()},
        );
      }
    } catch (e) {
      _log('Error handling in-app notification tap: $e');
    }
  }

  /// Sets up the notification tap handler to navigate to relevant screens.
  ///
  /// Parses the deep link data from the notification and navigates to:
  /// - Activity detail screen for activity notifications
  /// - Approval detail screen for approval notifications
  ///
  /// **Validates: Requirements 3.5**
  void _setupNotificationTapHandler(int currentMembershipId) {
    if (_service == null || !_service!.isInitialized) {
      return;
    }

    _service!.setOnSystemNotificationTapped((notificationData) {
      _log('Notification tapped, processing navigation...');

      try {
        // Extract deep link information from notification data
        final activityId = _parseIntValue(notificationData['activityId']);
        final notificationType = notificationData['type'] as String?;

        _log(
          'Parsed notification: activityId=$activityId, type=$notificationType',
        );

        if (activityId == null) {
          _log('No activityId in notification, skipping navigation');
          return;
        }

        // Navigate based on notification type
        final context = navigatorKey.currentContext;
        if (context == null) {
          _log('No navigator context available');
          return;
        }

        if (notificationType == 'APPROVAL_REQUIRED' ||
            notificationType == 'APPROVAL_CONFIRMED' ||
            notificationType == 'APPROVAL_REJECTED') {
          // Navigate to approval detail screen
          _log('Navigating to approval detail for activity $activityId');
          context.pushNamed(
            AppRoute.approvalDetail,
            extra: RouteParam(
              params: {
                'activityId': activityId,
                'currentMembershipId': currentMembershipId,
              },
            ),
          );
        } else {
          // Navigate to activity detail screen
          _log('Navigating to activity detail for activity $activityId');
          context.pushNamed(
            AppRoute.activityDetail,
            pathParameters: {'activityId': activityId.toString()},
          );
        }
      } catch (e) {
        _log('Error handling notification tap: $e');
      }
    });
  }

  /// Helper method to parse integer values from notification data
  int? _parseIntValue(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Unregisters all device interests.
  ///
  /// This should be called when the user logs out.
  /// Each interest unregistration is logged for debugging.
  ///
  /// **Validates: Requirements 3.4**
  Future<void> unregisterAllInterests() async {
    if (_service == null) {
      _log('Service not initialized');
      return;
    }

    if (!_service!.isInitialized) {
      _log('Service not initialized, skipping unregistration');
      return;
    }

    _log('Unregistering all interests');

    // Get current interests for logging before clearing
    final currentInterests = await _service!.getSubscribedInterests();
    _log(
      'Current interests before unregistration: ${currentInterests.join(", ")}',
    );

    // Unsubscribe from all interests
    await _service!.unsubscribeFromAllInterests();

    // Clear all Pusher Beams state
    await _service!.clearAllState();

    _log('Successfully unregistered all interests and cleared state');
  }

  void _log(String message) {
    final logMessage = '[$_tag] $message';
    developer.log(logMessage, name: 'PusherBeams');
    debugPrint('🔔 $logMessage'); // Also print to console for visibility
  }
}
