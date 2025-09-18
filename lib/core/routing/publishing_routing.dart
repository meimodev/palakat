import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat/core/models/location.dart';

final publishingRouting = GoRoute(
  path: '/publishing',
  name: AppRoute.publishing,
  builder: (context, state) => const PublishingScreen(),
  routes: [
    GoRoute(
      path: 'activity-publish',
      name: AppRoute.activityPublish,
      builder: (context, state) {
        final params = (state.extra as RouteParam?)?.params;
        final type = params?[RouteParamKey.activityType] as ActivityType?;

        assert(
          type != null,
          'RouteParamKey.activityType cannot be null',
        );

        return ActivityPublishScreen(
          type: type!,
        );
      },
    ),
    GoRoute(
      path: 'map',
      name: AppRoute.publishingMap,
      builder: (context, state) {
        final params = (state.extra as RouteParam?)?.params;
        final ot = params?[RouteParamKey.mapOperationType] as MapOperationType?;
        final locJson = params?[RouteParamKey.location] as Map<String, dynamic>?;
        final initialLocation = locJson != null ? Location.fromJson(locJson) : null;

        assert(
          ot != null,
          'RouteParamKey.mapOperationType cannot be null',
        );

        return MapScreen(
          mapOperationType: ot!,
          initialLocation: initialLocation,
        );
      },
    ),
  ],
);
