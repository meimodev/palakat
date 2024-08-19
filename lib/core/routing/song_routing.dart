import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/presentation.dart';

final songRouting = GoRoute(
  path: '/song-book',
  name: AppRoute.songBook,
  builder: (context, state) => const SongBookScreen(),
  routes: [
    GoRoute(
      path: 'detail',
      name: AppRoute.songBookDetail,
      builder: (context, state) {
        // final params = (state.extra as RouteParam?)?.params;
        // final type = params?[RouteParamKey.activityType] as ActivityType?;
        //
        // assert(
        // type != null,
        // 'RouteParamKey.activityType cannot be null',
        // );

        return SongDetailScreen(
          // type: type!,
        );
      },
    ),

  ],
);
