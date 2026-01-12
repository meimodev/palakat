import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/services/in_app_notification_service.dart';
import 'package:palakat/core/services/notification_display_service_provider.dart';
import 'package:palakat/core/services/pusher_beams_mobile_service.dart';
import 'package:palakat/core/widgets/in_app_notification/in_app_notification_banner.dart';
import 'package:palakat_shared/core/extension/account_extension.dart';
import 'package:palakat_shared/core/models/account.dart';
import 'package:palakat_shared/core/models/membership.dart';
import 'package:palakat_shared/core/utils/interest_builder.dart';
import 'package:palakat_shared/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pusher_beams_controller.g.dart';

/// Controller for managing Pusher Beams push notification subscriptions.
///
/// This controller handles:
/// - Registering device interests based on user membership data
/// - Unregistering all interests on logout
/// - Logging each interest registration/unregistration
///
/// Using keepAlive to ensure the controller persists across the app lifecycle
/// and doesn't get disposed between sign-out and sign-in.
///
/// **Validates: Requirements 3.2, 3.3, 3.4**
@Riverpod(keepAlive: true)
class PusherBeamsController extends _$PusherBeamsController {
  static const String _tag = 'PusherBeamsController';

  PusherBeamsMobileService? _service;

  InAppNotificationService? _inAppNotificationService;

  /// Flag to track if interests have been registered for the current session
  bool _hasRegisteredInterests = false;

  /// The membership ID for which interests were registered
  int? _registeredMembershipId;

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
  /// [membership] - The membership to register interests for
  /// [account] - Optional account object. If not provided, will try to get from
  ///             membership.account. This is useful when the membership doesn't
  ///             have the account back-reference populated.
  ///
  /// Each interest registration is logged for debugging.
  ///
  /// **Validates: Requirements 3.2, 3.3**
  Future<void> registerInterests(
    Membership membership, {
    Account? account,
  }) async {
    final membershipId = membership.id;

    // Check if already registered for this membership
    if (_hasRegisteredInterests && _registeredMembershipId == membershipId) {
      _log(
        'Already registered interests for membership $membershipId, skipping',
      );
      return;
    }

    _log('registerInterests called for membership $membershipId');

    // Recreate service if it was cleared during sign-out
    if (_service == null) {
      _inAppNotificationService = InAppNotificationService(
        navigatorKey: navigatorKey,
      );
      final notificationDisplay = ref.read(
        notificationDisplayServiceSyncProvider,
      );
      _service = PusherBeamsMobileService(
        notificationDisplay: notificationDisplay,
        inAppNotificationService: _inAppNotificationService,
      );
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
    final churchId = membership.church?.id;
    // Use provided account or fall back to membership.account
    final effectiveAccount = account ?? membership.account;

    // Validate required fields
    if (membershipId == null) {
      _log('Cannot register interests: membership ID is null');
      return;
    }

    if (churchId == null) {
      _log('Cannot register interests: church ID is null');
      return;
    }

    if (effectiveAccount == null) {
      _log('Cannot register interests: account is null');
      return;
    }

    if (effectiveAccount.id == null) {
      _log('Cannot register interests: account ID is null');
      return;
    }

    // Get BIPRA from account using the calculateBipra extension
    final bipra = effectiveAccount.calculateBipra.abv;

    final columnId = membership.column?.id;

    _log(
      'Registering interests for membership $membershipId, church $churchId, BIPRA $bipra',
    );

    // Build all applicable interests using InterestBuilder
    final interests = InterestBuilder.buildUserInterests(
      membershipId: membershipId,
      churchId: churchId,
      bipra: bipra,
      accountId: effectiveAccount.id!,
      columnId: columnId,
    );

    try {
      final settings = await ref
          .read(localStorageServiceProvider)
          .loadNotificationSettings();
      if (settings.birthdayNotificationsEnabled) {
        interests.add(InterestBuilder.membershipBirthday(membershipId));
      } else {
        await _service!.unsubscribeFromInterests([
          InterestBuilder.membershipBirthday(membershipId),
        ]);
      }
    } catch (_) {}

    _log('Built ${interests.length} interests: ${interests.join(", ")}');

    // Subscribe to all interests
    _log('Subscribing to interests...');
    await _service!.subscribeToInterests(interests);

    // Verify interests were registered
    final registeredInterests = await _service!.getSubscribedInterests();
    _log(
      'Verified registered interests (${registeredInterests.length}): ${registeredInterests.join(", ")}',
    );

    // Check if interests match what we expected
    if (registeredInterests.length != interests.length) {
      _log(
        'WARNING: Expected ${interests.length} interests but got ${registeredInterests.length}',
      );
    }

    // Set up foreground notification handler to show in-app banners
    _setupForegroundNotificationHandler(membershipId);

    // Set up background/system notification tap handler
    _setupNotificationTapHandler(membershipId);

    // Mark as registered
    _hasRegisteredInterests = true;
    _registeredMembershipId = membershipId;

    _log(
      '✅ Successfully registered all interests and handlers for membership $membershipId',
    );
  }

  Future<void> setBirthdayNotificationsEnabled(bool enabled) async {
    final localStorage = ref.read(localStorageServiceProvider);
    final membershipId =
        _registeredMembershipId ??
        localStorage.currentMembership?.id ??
        localStorage.currentAuth?.account.membership?.id;

    if (membershipId == null) {
      return;
    }

    if (_service == null) {
      _inAppNotificationService = InAppNotificationService(
        navigatorKey: navigatorKey,
      );
      final notificationDisplay = ref.read(
        notificationDisplayServiceSyncProvider,
      );
      _service = PusherBeamsMobileService(
        notificationDisplay: notificationDisplay,
        inAppNotificationService: _inAppNotificationService,
      );
    }

    if (!_service!.isInitialized) {
      await _service!.initialize();
      if (!_service!.isInitialized) {
        return;
      }
    }

    final interest = InterestBuilder.membershipBirthday(membershipId);

    if (enabled) {
      await _service!.subscribeToInterests([interest]);
    } else {
      await _service!.unsubscribeFromInterests([interest]);
    }
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
        _handleInAppNotificationTap(notification, currentMembershipId);
      },
    );
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

      final notificationType = notification.type;

      if (notificationType == 'MEMBER_BIRTHDAY') {
        final birthdayMembershipId =
            _parseIntValue(data['birthdayMembershipId']) ??
            _parseIntValue(data['membershipId']);
        if (birthdayMembershipId == null) {
          return;
        }

        final context = navigatorKey.currentContext;
        if (context == null) {
          return;
        }

        context.pushNamed(
          AppRoute.memberDetail,
          pathParameters: {'membershipId': birthdayMembershipId.toString()},
        );
        return;
      }

      final activityId = _parseIntValue(data['activityId']);

      if (activityId == null) {
        _log('No activityId in notification, skipping navigation');
        return;
      }

      final context = navigatorKey.currentContext;
      if (context == null) {
        _log('No navigator context available');
        return;
      }

      if (notificationType == 'ACTIVITY_ALARM') {
        _log('Navigating to alarm ring for activity $activityId');
        context.pushNamed(
          AppRoute.alarmRing,
          pathParameters: {'activityId': activityId.toString()},
          extra: RouteParam(
            params: {
              'title': data['title'],
              'reminderName': data['reminderName'],
              'reminderValue': data['reminderValue'],
              'alarmKey': data['alarmKey'],
              'notificationId': _parseIntValue(data['notificationId']),
            },
          ),
        );
      } else if (notificationType == 'APPROVAL_REQUIRED' ||
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
        final notificationType = notificationData['type'] as String?;

        if (notificationType == 'MEMBER_BIRTHDAY') {
          final birthdayMembershipId =
              _parseIntValue(notificationData['birthdayMembershipId']) ??
              _parseIntValue(notificationData['membershipId']);
          if (birthdayMembershipId == null) {
            return;
          }

          final context = navigatorKey.currentContext;
          if (context == null) {
            return;
          }

          context.pushNamed(
            AppRoute.memberDetail,
            pathParameters: {'membershipId': birthdayMembershipId.toString()},
          );
          return;
        }

        final activityId = _parseIntValue(notificationData['activityId']);

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

        if (notificationType == 'ACTIVITY_ALARM') {
          _log('Navigating to alarm ring for activity $activityId');
          context.pushNamed(
            AppRoute.alarmRing,
            pathParameters: {'activityId': activityId.toString()},
            extra: RouteParam(
              params: {
                'title': notificationData['title'],
                'reminderName': notificationData['reminderName'],
                'reminderValue': notificationData['reminderValue'],
                'alarmKey': notificationData['alarmKey'],
                'notificationId': _parseIntValue(
                  notificationData['notificationId'],
                ),
              },
            ),
          );
        } else if (notificationType == 'APPROVAL_REQUIRED' ||
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

  /// Unregisters all device interests and clears Pusher Beams state.
  ///
  /// This should be called when the user logs out.
  /// Each interest unregistration is logged for debugging.
  ///
  /// Note: This method does NOT check service initialization because the
  /// Pusher Beams SDK is a singleton and may have been initialized by a
  /// previous controller instance. We always attempt to clear interests
  /// to ensure the device stops receiving notifications after logout.
  ///
  /// **Validates: Requirements 3.4**
  Future<void> unregisterAllInterests() async {
    if (_service == null) {
      _log('Service not initialized, creating temporary service for cleanup');
      // Create a temporary service just for cleanup
      _service = PusherBeamsMobileService();
    }

    _log('Unregistering all interests');

    // Get current interests for logging before clearing
    final currentInterests = await _service!.getSubscribedInterests();
    _log(
      'Current interests before unregistration: ${currentInterests.join(", ")}',
    );

    // Unsubscribe from all interests
    await _service!.unsubscribeFromAllInterests();

    // Clear all Pusher Beams state (this also clears the device token)
    await _service!.clearAllState();

    // Reset the service to ensure a fresh instance is created on next registration
    // This is important because the service's internal state (like _isInitialized)
    // needs to be reset for the next sign-in
    _service = null;
    _inAppNotificationService = null;

    // Reset registration flags
    _hasRegisteredInterests = false;
    _registeredMembershipId = null;

    _log('✅ Successfully unregistered all interests and cleared state');
  }

  void _log(String message) {
    final logMessage = '[$_tag] $message';
    developer.log(logMessage, name: 'PusherBeams');
    debugPrint('🔔 $logMessage'); // Also print to console for visibility
  }
}
