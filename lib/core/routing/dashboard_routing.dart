import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
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
        final id = params?[RouteParamKey.activityId] as String?;

        assert(
          id?.isEmpty == false,
          'RouteParamKey.id must be set with non empty String',
        );

        return ActivityDetailScreen(
          id: id!,
        );
      },
    ),
    // GoRoute(
    //   path: 'patient-list',
    //   name: AppRoute.patientList,
    //   builder: (context, state) => const PatientListScreen(),
    // ),
    // GoRoute(
    //   path: 'patient-form',
    //   name: AppRoute.patientForm,
    //   builder: (context, state) => const PatientFormScreen(),
    // ),
  ],
);
