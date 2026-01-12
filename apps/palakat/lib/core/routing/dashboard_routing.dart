import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/core/constants/enums.dart';

final dashboardRouting = GoRoute(
  path: '/dashboard',
  name: AppRoute.dashboard,
  builder: (context, state) => const DashboardScreen(),
  routes: [
    GoRoute(
      path: 'view-all',
      name: AppRoute.viewAll,
      builder: (context, state) {
        final params = (state.extra as RouteParam?)?.params;
        final type = params?[RouteParamKey.activityType] as ActivityType?;
        return ViewAllScreen(activityType: type);
      },
    ),
    GoRoute(
      path: 'activity-detail/:activityId',
      name: AppRoute.activityDetail,
      builder: (context, state) {
        final activityIdStr = state.pathParameters['activityId'];

        assert(
          activityIdStr != null,
          'activityId path parameter cannot be null',
        );

        final activityId = int.parse(activityIdStr!);

        // Check if navigating from approval context (Req 6.2, 6.3)
        final params = (state.extra as RouteParam?)?.params;
        final isFromApprovalContext =
            params?[RouteParamKey.isFromApprovalContext] as bool? ?? false;

        return ActivityDetailScreen(
          activityId: activityId,
          isFromApprovalContext: isFromApprovalContext,
        );
      },
    ),
    GoRoute(
      path: 'alarm-ring/:activityId',
      name: AppRoute.alarmRing,
      builder: (context, state) {
        final activityIdStr = state.pathParameters['activityId'];
        final activityId = int.tryParse(activityIdStr ?? '');
        final extra = state.extra as RouteParam?;
        final params = extra?.params ?? const <String, dynamic>{};

        if (activityId == null) {
          return const DashboardScreen();
        }

        return AlarmRingScreen(
          activityId: activityId,
          title: params['title'] as String?,
          reminderName: params['reminderName'] as String?,
          reminderValue: params['reminderValue'] as String?,
          alarmKey: params['alarmKey'] as String?,
          notificationId: params['notificationId'] as int?,
        );
      },
    ),
  ],
);
