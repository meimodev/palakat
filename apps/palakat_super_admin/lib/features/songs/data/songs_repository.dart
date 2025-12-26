import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/core/models/response/pagination_response_wrapper.dart';
import 'package:palakat_shared/core/services/socket_service.dart';

import '../../auth/application/super_admin_auth_controller.dart';
import 'admin_song_model.dart';
import 'admin_song_part_model.dart';

final songsRepositoryProvider = Provider<SongsRepository>((ref) {
  final socket = ref.watch(superAdminSocketServiceProvider);
  return SongsRepository(socket: socket);
});

class SongsRepository {
  SongsRepository({required this.socket});

  final SocketService socket;

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

    final data = await socket.rpc('admin.songs.list', query);
    return PaginationResponseWrapper.fromJson(
      data,
      (e) => AdminSongModel.fromJson(e as Map<String, dynamic>),
    );
  }

  Future<AdminSongModel> fetchSong(int id) async {
    final body = await socket.rpc('admin.songs.get', {'id': id});
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

    final body = await socket.rpc('admin.songs.create', payload);
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

    final body = await socket.rpc('admin.songs.update', {
      'id': id,
      'dto': payload,
    });
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) throw StateError('Invalid response');
    return AdminSongModel.fromJson(data);
  }

  Future<void> deleteSong(int id) async {
    await socket.rpc('admin.songs.delete', {'id': id});
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

    final body = await socket.rpc('admin.songParts.create', payload);

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

    final body = await socket.rpc('admin.songParts.update', {
      'id': id,
      'dto': payload,
    });

    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) throw StateError('Invalid response');
    return AdminSongPartModel.fromJson(data);
  }

  Future<void> deleteSongPart(int id) async {
    await socket.rpc('admin.songParts.delete', {'id': id});
  }
}
