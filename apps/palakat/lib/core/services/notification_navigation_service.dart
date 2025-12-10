import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/app_routing.dart';

/// Service for handling navigation from notification taps.
///
/// This service provides centralized logic for routing users to the appropriate
/// screen based on notification data (type and activityId).
///
/// **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5**
class NotificationNavigationService {
  final GoRouter router;

  NotificationNavigationService(this.router);

  /// Navigate based on notification data.
  ///
  /// Routes to different screens based on notification type:
  /// - ACTIVITY_CREATED → activity detail screen (Req 3.1)
  /// - APPROVAL_REQUIRED → approval detail screen (Req 3.2)
  /// - APPROVAL_CONFIRMED → activity detail screen (Req 3.3)
  /// - APPROVAL_REJECTED → activity detail screen (Req 3.4)
  /// - Missing activityId or invalid data → home screen (Req 3.5)
  ///
  /// **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5**
  void handleNotificationTap(Map<String, dynamic> data) {
    debugPrint('🔔 [NotificationNavigationService] Handling notification tap');
    debugPrint('🔔 [NotificationNavigationService] Data: $data');

    final type = data['type'] as String?;
    final activityId = data['activityId'];

    // Parse activityId - it could be String or int
    final int? parsedActivityId = _parseActivityId(activityId);

    debugPrint('🔔 [NotificationNavigationService] Type: $type');
    debugPrint(
      '🔔 [NotificationNavigationService] ActivityId: $parsedActivityId',
    );

    // Fallback to home if activityId is missing (Req 3.5)
    if (parsedActivityId == null) {
      debugPrint(
        '🔔 [NotificationNavigationService] No activityId, navigating to home',
      );
      router.go('/home');
      return;
    }

    // Route based on notification type
    switch (type) {
      case 'ACTIVITY_CREATED': // Req 3.1
        debugPrint(
          '🔔 [NotificationNavigationService] Navigating to activity detail',
        );
        router.pushNamed(
          AppRoute.activityDetail,
          pathParameters: {'activityId': parsedActivityId.toString()},
        );
        break;

      case 'APPROVAL_REQUIRED': // Req 3.2
        debugPrint(
          '🔔 [NotificationNavigationService] Navigating to approval detail',
        );
        router.pushNamed(
          AppRoute.approvalDetail,
          extra: RouteParam(params: {'activityId': parsedActivityId}),
        );
        break;

      case 'APPROVAL_CONFIRMED': // Req 3.3
      case 'APPROVAL_REJECTED': // Req 3.4
        debugPrint(
          '🔔 [NotificationNavigationService] Navigating to activity detail',
        );
        router.pushNamed(
          AppRoute.activityDetail,
          pathParameters: {'activityId': parsedActivityId.toString()},
        );
        break;

      default: // Req 3.5 - invalid/unknown type
        debugPrint(
          '🔔 [NotificationNavigationService] Unknown type, navigating to home',
        );
        router.go('/home');
    }
  }

  /// Parse activityId from various formats (String, int, or null).
  int? _parseActivityId(dynamic activityId) {
    if (activityId == null) {
      return null;
    }

    if (activityId is int) {
      return activityId;
    }

    if (activityId is String) {
      return int.tryParse(activityId);
    }

    return null;
  }
}
