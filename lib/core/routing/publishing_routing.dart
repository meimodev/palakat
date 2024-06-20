import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/presentation.dart';

final publishingRouting = GoRoute(
  path: '/publishing',
  name: AppRoute.publishing,
  builder: (context, state) => const PublishingScreen(),
  routes: [
    GoRoute(
      path: 'activity-publish',
      name: AppRoute.activityPublish,
      builder: (context, state) {
        // final params = (state.extra as RouteParam?)?.params;
        // final id = params?[RouteParamKey.activityId] as String?;
        //
        // assert(
        //   id?.isEmpty == false,
        //   'RouteParamKey.id must be set with non empty String',
        // );
        //

        return const ActivityPublishScreen(
          id: "",
        );
      },
    ),
    GoRoute(
      path: 'map',
      name: AppRoute.publishingMap,
      builder: (context, state) {
        final params = (state.extra as RouteParam?)?.params;
        final ot = params?[RouteParamKey.mapOperationType] as MapOperationType?;

        assert(
          ot != null,
          'RouteParamKey.mapOperationType cannot be null',
        );

        return MapScreen(mapOperationType: ot!);
      },
    ),
  ],
);
