import 'package:palakat_shared/core/models/song.dart';

abstract class SongSearchRepository {
  Future<void> ensureIndexed({
    required List<Song> songs,
    required String fingerprint,
    bool forceRebuild = false,
  });

  Future<List<String>> searchSongIds({
    required String query,
    required List<Song> songs,
    int limit = 2000,
  });
}
