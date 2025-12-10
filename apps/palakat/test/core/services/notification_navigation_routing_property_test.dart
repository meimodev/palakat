import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/services/notification_navigation_service.dart';

/// **Feature: push-notification-ux-improvements, Property 2: Notification Navigation Routing**
///
/// Property: For any notification with valid deep link data (type and activityId),
/// when tapped, the app should navigate to the screen corresponding to the
/// notification type and activityId.
///
/// **Validates: Requirements 1.3, 2.3**
void main() {
  KiriCheck.verbosity = Verbosity.verbose;

  group('Property 2: Notification Navigation Routing', () {
    late GoRouter mockRouter;
    late NotificationNavigationService service;
    late List<String> navigationLog;

    setUp(() {
      navigationLog = [];

      // Create a mock router that logs navigation calls
      mockRouter = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            name: AppRoute.home,
            builder: (context, state) => const Placeholder(),
          ),
          GoRoute(
            path: '/dashboard',
            name: AppRoute.dashboard,
            builder: (context, state) => const Placeholder(),
            routes: [
              GoRoute(
                path: 'activity-detail/:activityId',
                name: AppRoute.activityDetail,
                builder: (context, state) {
                  navigationLog.add(
                    'activityDetail:${state.pathParameters['activityId']}',
                  );
                  return const Placeholder();
                },
              ),
            ],
          ),
          GoRoute(
            path: '/approvals',
            name: AppRoute.approvals,
            builder: (context, state) => const Placeholder(),
            routes: [
              GoRoute(
                path: 'detail',
                name: AppRoute.approvalDetail,
                builder: (context, state) {
                  final extra = state.extra as RouteParam?;
                  final activityId = extra?.params['activityId'];
                  navigationLog.add('approvalDetail:$activityId');
                  return const Placeholder();
                },
              ),
            ],
          ),
        ],
      );

      service = NotificationNavigationService(mockRouter);
    });

    tearDown(() {
      mockRouter.dispose();
    });

    // Generator for valid activity IDs (positive integers)
    final activityIdArb = integer(min: 1, max: 999999);

    property('ACTIVITY_CREATED notifications navigate to activity detail', () {
      forAll(activityIdArb, (activityId) {
        navigationLog.clear();

        final data = {'type': 'ACTIVITY_CREATED', 'activityId': activityId};

        service.handleNotificationTap(data);

        // Should navigate to activity detail with the correct ID
        expect(
          navigationLog,
          contains('activityDetail:$activityId'),
          reason: 'ACTIVITY_CREATED should navigate to activity detail',
        );
      });
    });

    property('APPROVAL_REQUIRED notifications navigate to approval detail', () {
      forAll(activityIdArb, (activityId) {
        navigationLog.clear();

        final data = {'type': 'APPROVAL_REQUIRED', 'activityId': activityId};

        service.handleNotificationTap(data);

        // Should navigate to approval detail with the correct ID
        expect(
          navigationLog,
          contains('approvalDetail:$activityId'),
          reason: 'APPROVAL_REQUIRED should navigate to approval detail',
        );
      });
    });

    property(
      'APPROVAL_CONFIRMED notifications navigate to activity detail',
      () {
        forAll(activityIdArb, (activityId) {
          navigationLog.clear();

          final data = {'type': 'APPROVAL_CONFIRMED', 'activityId': activityId};

          service.handleNotificationTap(data);

          // Should navigate to activity detail with the correct ID
          expect(
            navigationLog,
            contains('activityDetail:$activityId'),
            reason: 'APPROVAL_CONFIRMED should navigate to activity detail',
          );
        });
      },
    );

    property('APPROVAL_REJECTED notifications navigate to activity detail', () {
      forAll(activityIdArb, (activityId) {
        navigationLog.clear();

        final data = {'type': 'APPROVAL_REJECTED', 'activityId': activityId};

        service.handleNotificationTap(data);

        // Should navigate to activity detail with the correct ID
        expect(
          navigationLog,
          contains('activityDetail:$activityId'),
          reason: 'APPROVAL_REJECTED should navigate to activity detail',
        );
      });
    });

    property('notifications with string activityId are parsed correctly', () {
      final notificationTypes = [
        'ACTIVITY_CREATED',
        'APPROVAL_REQUIRED',
        'APPROVAL_CONFIRMED',
        'APPROVAL_REJECTED',
      ];

      forAll(activityIdArb, (activityId) {
        for (final type in notificationTypes) {
          navigationLog.clear();

          final data = {
            'type': type,
            'activityId': activityId.toString(), // String format
          };

          service.handleNotificationTap(data);

          // Should still navigate correctly
          expect(
            navigationLog.isNotEmpty,
            isTrue,
            reason: 'String activityId should be parsed and navigation occur',
          );
        }
      });
    });

    property('notifications without activityId navigate to home', () {
      final notificationTypes = [
        'ACTIVITY_CREATED',
        'APPROVAL_REQUIRED',
        'APPROVAL_CONFIRMED',
        'APPROVAL_REJECTED',
      ];

      forAll(constant(null), (_) {
        for (final type in notificationTypes) {
          navigationLog.clear();

          final data = {
            'type': type,
            // No activityId
          };

          service.handleNotificationTap(data);

          // Should navigate to home (fallback)
          expect(
            mockRouter.routeInformationProvider.value.uri.path,
            equals('/home'),
            reason: 'Missing activityId should navigate to home',
          );
        }
      });
    });

    property('notifications with invalid type navigate to home', () {
      forAll(activityIdArb, (activityId) {
        navigationLog.clear();

        final data = {'type': 'INVALID_TYPE', 'activityId': activityId};

        service.handleNotificationTap(data);

        // Should navigate to home (fallback)
        expect(
          mockRouter.routeInformationProvider.value.uri.path,
          equals('/home'),
          reason: 'Invalid type should navigate to home',
        );
      });
    });
  });
}
