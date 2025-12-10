import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/services/notification_navigation_service.dart';

void main() {
  group('NotificationNavigationService', () {
    late GoRouter router;
    late NotificationNavigationService service;
    late List<String> navigationLog;

    setUp(() {
      navigationLog = [];

      // Create a test router that logs navigation
      router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            name: AppRoute.home,
            builder: (context, state) {
              navigationLog.add('home');
              return const Placeholder();
            },
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
                  final id = state.pathParameters['activityId'];
                  navigationLog.add('activityDetail:$id');
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
                  final id = extra?.params['activityId'];
                  navigationLog.add('approvalDetail:$id');
                  return const Placeholder();
                },
              ),
            ],
          ),
        ],
      );

      service = NotificationNavigationService(router);
    });

    tearDown(() {
      router.dispose();
    });

    group('ACTIVITY_CREATED notifications', () {
      test('navigates to activity detail with integer activityId', () {
        // Req 3.1
        final data = {'type': 'ACTIVITY_CREATED', 'activityId': 123};

        service.handleNotificationTap(data);

        // Verify the router's location changed
        expect(
          router.routeInformationProvider.value.uri.path,
          contains('activity-detail/123'),
        );
      });

      test('navigates to activity detail with string activityId', () {
        // Req 3.1
        final data = {'type': 'ACTIVITY_CREATED', 'activityId': '456'};

        service.handleNotificationTap(data);

        expect(
          router.routeInformationProvider.value.uri.path,
          contains('activity-detail/456'),
        );
      });
    });

    group('APPROVAL_REQUIRED notifications', () {
      test('navigates to approval detail with integer activityId', () {
        // Req 3.2
        final data = {'type': 'APPROVAL_REQUIRED', 'activityId': 789};

        service.handleNotificationTap(data);

        expect(
          router.routeInformationProvider.value.uri.path,
          contains('approvals/detail'),
        );
      });

      test('navigates to approval detail with string activityId', () {
        // Req 3.2
        final data = {'type': 'APPROVAL_REQUIRED', 'activityId': '321'};

        service.handleNotificationTap(data);

        expect(
          router.routeInformationProvider.value.uri.path,
          contains('approvals/detail'),
        );
      });
    });

    group('APPROVAL_CONFIRMED notifications', () {
      test('navigates to activity detail', () {
        // Req 3.3
        final data = {'type': 'APPROVAL_CONFIRMED', 'activityId': 555};

        service.handleNotificationTap(data);

        expect(
          router.routeInformationProvider.value.uri.path,
          contains('activity-detail/555'),
        );
      });
    });

    group('APPROVAL_REJECTED notifications', () {
      test('navigates to activity detail', () {
        // Req 3.4
        final data = {'type': 'APPROVAL_REJECTED', 'activityId': 666};

        service.handleNotificationTap(data);

        expect(
          router.routeInformationProvider.value.uri.path,
          contains('activity-detail/666'),
        );
      });
    });

    group('missing activityId', () {
      test('navigates to home when activityId is null', () {
        // Req 3.5
        final data = {
          'type': 'ACTIVITY_CREATED',
          // No activityId
        };

        service.handleNotificationTap(data);

        expect(router.routeInformationProvider.value.uri.path, equals('/home'));
      });

      test('navigates to home when activityId is empty string', () {
        // Req 3.5
        final data = {'type': 'ACTIVITY_CREATED', 'activityId': ''};

        service.handleNotificationTap(data);

        expect(router.routeInformationProvider.value.uri.path, equals('/home'));
      });

      test('navigates to home when activityId is invalid string', () {
        // Req 3.5
        final data = {'type': 'ACTIVITY_CREATED', 'activityId': 'not-a-number'};

        service.handleNotificationTap(data);

        expect(router.routeInformationProvider.value.uri.path, equals('/home'));
      });
    });

    group('invalid data', () {
      test('navigates to home when type is invalid', () {
        // Req 3.5
        final data = {'type': 'INVALID_TYPE', 'activityId': 123};

        service.handleNotificationTap(data);

        expect(router.routeInformationProvider.value.uri.path, equals('/home'));
      });

      test('navigates to home when type is null', () {
        // Req 3.5
        final data = {
          'activityId': 123,
          // No type
        };

        service.handleNotificationTap(data);

        expect(router.routeInformationProvider.value.uri.path, equals('/home'));
      });

      test('navigates to home when data is empty', () {
        // Req 3.5
        final data = <String, dynamic>{};

        service.handleNotificationTap(data);

        expect(router.routeInformationProvider.value.uri.path, equals('/home'));
      });
    });

    group('edge cases', () {
      test('handles very large activityId', () {
        final data = {'type': 'ACTIVITY_CREATED', 'activityId': 999999999};

        service.handleNotificationTap(data);

        expect(
          router.routeInformationProvider.value.uri.path,
          contains('activity-detail/999999999'),
        );
      });

      test('handles activityId of 0', () {
        final data = {'type': 'ACTIVITY_CREATED', 'activityId': 0};

        service.handleNotificationTap(data);

        expect(
          router.routeInformationProvider.value.uri.path,
          contains('activity-detail/0'),
        );
      });

      test('handles negative activityId', () {
        final data = {'type': 'ACTIVITY_CREATED', 'activityId': -1};

        service.handleNotificationTap(data);

        expect(
          router.routeInformationProvider.value.uri.path,
          contains('activity-detail/-1'),
        );
      });

      test('handles mixed case notification type', () {
        // Should not match (case-sensitive)
        final data = {'type': 'activity_created', 'activityId': 123};

        service.handleNotificationTap(data);

        expect(router.routeInformationProvider.value.uri.path, equals('/home'));
      });

      test('all notification types route correctly', () {
        final testCases = [
          {
            'data': {'type': 'ACTIVITY_CREATED', 'activityId': 1},
            'expectedPath': 'activity-detail/1',
          },
          {
            'data': {'type': 'APPROVAL_REQUIRED', 'activityId': 2},
            'expectedPath': 'approvals/detail',
          },
          {
            'data': {'type': 'APPROVAL_CONFIRMED', 'activityId': 3},
            'expectedPath': 'activity-detail/3',
          },
          {
            'data': {'type': 'APPROVAL_REJECTED', 'activityId': 4},
            'expectedPath': 'activity-detail/4',
          },
        ];

        for (final testCase in testCases) {
          // Reset router to home
          router.go('/home');

          service.handleNotificationTap(
            testCase['data']! as Map<String, dynamic>,
          );

          expect(
            router.routeInformationProvider.value.uri.path,
            contains(testCase['expectedPath'] as String),
            reason: 'Failed for ${testCase['data']}',
          );
        }
      });
    });
  });
}
