import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/core/config/app_config.dart';
import 'package:palakat_shared/core/models/models.dart';
import 'package:palakat_shared/core/services/socket_service.dart';

import '../../auth/application/super_admin_auth_controller.dart';

final songsRepositoryProvider = Provider<SongsRepository>((ref) {
  final socket = ref.watch(superAdminSocketServiceProvider);
  final config = ref.watch(appConfigProvider);
  return SongsRepository(socket: socket, songDbFileId: config.songDbFileId);
});

class SongsRepository {
  SongsRepository({required this.socket, required this.songDbFileId});

  final SocketService socket;

  /// Falls back to 999 if SONG_DB_FILE_ID is not set.
  final int? songDbFileId;

  int get _effectiveSongDbFileId => songDbFileId ?? 999;

  SongDbFile _parseSongDbJson(String rawJson) {
    final decoded = jsonDecode(rawJson.trimLeft());
    if (decoded is! Map) {
      throw Failure('Invalid song DB JSON');
    }

    final map = decoded.cast<String, dynamic>();

    final booksList = map['books'];
    final books = (booksList is List)
        ? booksList
              .whereType<Map>()
              .map((e) => e.cast<String, dynamic>())
              .map(SongBook.fromJson)
              .toList()
        : <SongBook>[];

    final bookNameById = {
      for (final b in books)
        if (b.id.trim().isNotEmpty) b.id.trim(): b.name,
    };

    final songsList = map['songs'];
    if (songsList is! List) {
      throw Failure('Invalid song DB JSON');
    }

    final songs = songsList
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .map((json) {
          final song = Song.fromJson(json);
          if (song.bookId.trim().isNotEmpty && song.bookName.trim().isEmpty) {
            final name = bookNameById[song.bookId.trim()];
            if (name != null && name.trim().isNotEmpty) {
              return song.copyWith(bookName: name);
            }
          }
          return song;
        })
        .toList();

    final version = map['version']?.toString();
    final updatedAt = DateTime.tryParse(map['updatedAt']?.toString() ?? '');

    int? asInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim());
      return null;
    }

    final booksCount = asInt(map['books_count']) ?? books.length;
    final songsCount = asInt(map['songs_count']) ?? songs.length;

    return SongDbFile(
      version: (version != null && version.trim().isNotEmpty)
          ? version.trim()
          : null,
      updatedAt: updatedAt,
      booksCount: booksCount,
      songsCount: songsCount,
      books: books,
      songs: songs,
    );
  }

  Future<SongDbFile> downloadSongDb() async {
    final fileId = _effectiveSongDbFileId;
    final dl = await socket.downloadFileBytes(fileId: fileId);
    final rawJson = utf8.decode(dl.bytes);
    return _parseSongDbJson(rawJson);
  }

  Future<Map<String, dynamic>> uploadSongDb({
    required String rawJson,
    void Function(int sentBytes, int totalBytes)? onProgress,
  }) async {
    final bytes = Uint8List.fromList(utf8.encode(rawJson));
    final init = await socket.rpc('admin.songDb.upload.init', {
      'fileId': _effectiveSongDbFileId,
      'sizeBytes': bytes.length,
      'contentType': 'application/json',
      'originalName': 'songs.json',
    });

    final initData = init['data'];
    if (initData is! Map) {
      throw Failure('Invalid upload init response');
    }
    final uploadId = initData['uploadId'];
    final chunkSize = initData['chunkSize'];
    if (uploadId is! String || uploadId.isEmpty) {
      throw Failure('Invalid uploadId');
    }

    final cs = chunkSize is int ? chunkSize : (256 * 1024);
    int sent = 0;
    try {
      while (sent < bytes.length) {
        final end = (sent + cs) > bytes.length ? bytes.length : (sent + cs);
        final chunk = bytes.sublist(sent, end);
        await socket.rpc('admin.songDb.upload.chunk', {
          'uploadId': uploadId,
          'dataBase64': base64Encode(chunk),
        });
        sent = end;
        onProgress?.call(sent, bytes.length);
      }

      final done = await socket.rpc('admin.songDb.upload.complete', {
        'uploadId': uploadId,
      });
      final data = done['data'];
      if (data is Map) {
        return data.cast<String, dynamic>();
      }
      return const <String, dynamic>{};
    } catch (e) {
      try {
        await socket.rpc('admin.songDb.upload.abort', {'uploadId': uploadId});
      } catch (_) {}
      rethrow;
    }
  }
}

class SongDbFile {
  const SongDbFile({
    required this.version,
    required this.updatedAt,
    required this.booksCount,
    required this.songsCount,
    required this.books,
    required this.songs,
  });

  final String? version;
  final DateTime? updatedAt;
  final int booksCount;
  final int songsCount;
  final List<SongBook> books;
  final List<Song> songs;

  SongDbFile copyWith({
    String? version,
    DateTime? updatedAt,
    int? booksCount,
    int? songsCount,
    List<SongBook>? books,
    List<Song>? songs,
  }) {
    return SongDbFile(
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      booksCount: booksCount ?? this.booksCount,
      songsCount: songsCount ?? this.songsCount,
      books: books ?? this.books,
      songs: songs ?? this.songs,
    );
  }
}
