import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'song_search_repository_base.dart';
import 'song_search_repository_web.dart'
    if (dart.library.io) 'song_search_repository_io.dart';

export 'song_search_repository_base.dart';

final songSearchRepositoryProvider = Provider<SongSearchRepository>((ref) {
  return createSongSearchRepository();
});
