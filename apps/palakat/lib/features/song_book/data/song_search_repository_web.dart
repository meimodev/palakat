import 'song_search_repository_base.dart';
import 'song_search_repository_fallback.dart';

SongSearchRepository createSongSearchRepository() {
  return SongSearchRepositoryFallback();
}
