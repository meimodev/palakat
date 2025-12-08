import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/presentation.dart';

final dashboardRouting = GoRoute(
  path: '/dashboard',
  name: AppRoute.dashboard,
  builder: (context, state) => const DashboardScreen(),
  routes: [
    GoRoute(
      path: 'view-all',
      name: AppRoute.viewAll,
      builder: (context, state) => const ViewAllScreen(),
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
  ],
);
