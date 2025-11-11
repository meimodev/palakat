import 'package:go_router/go_router.dart';
import 'package:palakat_admin/core/models/models.dart';
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
      path: 'activity-detail',
      name: AppRoute.activityDetail,
      builder: (context, state) {
        final params = (state.extra as RouteParam?)?.params;
        final activityMap =
            params?[RouteParamKey.activity] as Map<String, dynamic>?;

        assert(
          activityMap != null,
          'RouteParamKey.activity cannot be null',
        );

        return ActivityDetailScreen(
          activity: Activity.fromJson(activityMap!),
        );
      },
    ),

  ],
);
