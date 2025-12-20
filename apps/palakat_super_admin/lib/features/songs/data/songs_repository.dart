import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/core/models/response/pagination_response_wrapper.dart';

import '../../auth/application/super_admin_auth_controller.dart';
import 'admin_song_model.dart';
import 'admin_song_part_model.dart';

final songsRepositoryProvider = Provider<SongsRepository>((ref) {
  final dio = ref.watch(superAdminAuthedDioProvider);
  return SongsRepository(dio: dio);
});

class SongsRepository {
  SongsRepository({required this.dio});

  final Dio dio;

  Future<PaginationResponseWrapper<AdminSongModel>> fetchSongs({
    required int page,
    required int pageSize,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (sortBy != null && sortBy.trim().isNotEmpty) 'sortBy': sortBy.trim(),
      if (sortOrder != null && sortOrder.trim().isNotEmpty)
        'sortOrder': sortOrder.trim(),
    };

    final res = await dio.get<Map<String, dynamic>>(
      'admin/songs',
      queryParameters: query,
    );

    final data = res.data ?? const {};
    return PaginationResponseWrapper.fromJson(
      data,
      (e) => AdminSongModel.fromJson(e as Map<String, dynamic>),
    );
  }

  Future<AdminSongModel> fetchSong(int id) async {
    final res = await dio.get<Map<String, dynamic>>('admin/songs/$id');
    final body = res.data ?? const {};
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('Invalid response');
    }
    return AdminSongModel.fromJson(data);
  }

  Future<AdminSongModel> createSong({
    required String title,
    required int index,
    required String book,
    required String link,
  }) async {
    final payload = <String, dynamic>{
      'title': title,
      'index': index,
      'book': book,
      'link': link,
    };

    final res = await dio.post<Map<String, dynamic>>(
      'admin/songs',
      data: payload,
    );
    final body = res.data ?? const {};
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) throw StateError('Invalid response');
    return AdminSongModel.fromJson(data);
  }

  Future<AdminSongModel> updateSong({
    required int id,
    String? title,
    int? index,
    String? book,
    String? link,
  }) async {
    final payload = <String, dynamic>{
      if (title != null) 'title': title,
      if (index != null) 'index': index,
      if (book != null) 'book': book,
      if (link != null) 'link': link,
    };

    final res = await dio.patch<Map<String, dynamic>>(
      'admin/songs/$id',
      data: payload,
    );
    final body = res.data ?? const {};
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) throw StateError('Invalid response');
    return AdminSongModel.fromJson(data);
  }

  Future<void> deleteSong(int id) async {
    await dio.delete('admin/songs/$id');
  }

  Future<AdminSongPartModel> createSongPart({
    required int songId,
    required int index,
    required String name,
    required String content,
  }) async {
    final payload = <String, dynamic>{
      'index': index,
      'name': name,
      'content': content,
      'song': {
        'connect': {'id': songId},
      },
    };

    final res = await dio.post<Map<String, dynamic>>(
      'admin/song-parts',
      data: payload,
    );

    final body = res.data ?? const {};
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) throw StateError('Invalid response');
    return AdminSongPartModel.fromJson(data);
  }

  Future<AdminSongPartModel> updateSongPart({
    required int id,
    int? index,
    String? name,
    String? content,
  }) async {
    final payload = <String, dynamic>{
      if (index != null) 'index': index,
      if (name != null) 'name': name,
      if (content != null) 'content': content,
    };

    final res = await dio.patch<Map<String, dynamic>>(
      'admin/song-parts/$id',
      data: payload,
    );

    final body = res.data ?? const {};
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) throw StateError('Invalid response');
    return AdminSongPartModel.fromJson(data);
  }

  Future<void> deleteSongPart(int id) async {
    await dio.delete('admin/song-parts/$id');
  }
}
