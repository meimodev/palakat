import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart';
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
        final params = (state.extra as RouteParam?)?.params;
        final songMap = params?[RouteParamKey.song] as Map<String, dynamic>?;

        assert(
          songMap != null,
          'RouteParamKey.song cannot be null',
        );

        return SongDetailScreen(
          song: Song.fromJson(songMap!),
        );
      },
    ),
  ],
);
