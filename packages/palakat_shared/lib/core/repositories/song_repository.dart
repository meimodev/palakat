import 'package:palakat_shared/core/models/request/request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/response/response.dart';
import '../models/result.dart';
import '../models/song.dart';
import '../services/socket_service.dart';

part 'song_repository.g.dart';

@riverpod
SongRepository songRepository(Ref ref) => SongRepository(ref);

class SongRepository {
  SongRepository(this._ref);

  final Ref _ref;

  /// Get songs with pagination and optional search filter
  /// Supports searching by title or index
  Future<Result<PaginationResponseWrapper<Song>, Failure>> getSongs({
    required PaginationRequestWrapper<GetFetchSongsRequest> paginationRequest,
  }) async {
    try {
      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('songsPublic.list', query);
      // Use SongMapper to transform backend response to Flutter Song model
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => (e as Map<String, dynamic>).toSong(),
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  /// Search songs by title or index
  Future<Result<PaginationResponseWrapper<Song>, Failure>> searchSongs({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    final request = PaginationRequestWrapper(
      page: page,
      pageSize: pageSize,
      data: GetFetchSongsRequest(search: query),
    );
    return getSongs(paginationRequest: request);
  }

  /// Get a single song by ID with all its parts
  Future<Result<Song, Failure>> getSongById({required String songId}) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final id = int.tryParse(songId);
      if (id == null) {
        return Result.failure(Failure('Invalid songId'));
      }
      final body = await socket.rpc('songsPublic.get', {'id': id});

      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid song response payload'));
      }
      // Use SongMapper to transform backend response to Flutter Song model
      return Result.success(json.toSong());
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
