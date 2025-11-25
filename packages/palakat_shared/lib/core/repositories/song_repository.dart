import 'package:dio/dio.dart';
import 'package:palakat_shared/core/models/request/request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/endpoint.dart';
import '../models/response/response.dart';
import '../models/result.dart';
import '../models/song.dart';
import '../services/http_service.dart';
import '../utils/error_mapper.dart';

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
      final http = _ref.read(httpServiceProvider);

      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.songs,
        queryParameters: query,
      );

      final data = response.data ?? {};
      // Use SongMapper to transform backend response to Flutter Song model
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => (e as Map<String, dynamic>).toSong(),
      );
      return Result.success(result);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch songs');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch songs', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
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
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.song(songId),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid song response payload'));
      }
      // Use SongMapper to transform backend response to Flutter Song model
      return Result.success(json.toSong());
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch song');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch song', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }
}
