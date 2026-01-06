import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:palakat_shared/core/config/app_config.dart';
import 'package:palakat_shared/core/models/request/request.dart';
import 'package:palakat_shared/core/repositories/file_manager_repository.dart';
import 'package:palakat_shared/core/services/socket_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/response/response.dart';
import '../models/result.dart';
import '../models/song_book.dart';
import '../models/song.dart';

part 'song_repository.g.dart';

@riverpod
SongRepository songRepository(Ref ref) => SongRepository(ref);

class SongRepository {
  SongRepository(this._ref);

  final Ref _ref;

  static const _kSongDbBox = 'song_db';
  static const _kSongDbJsonKey = 'songs.json';
  static const _kSongDbCachedAtKey = 'songs.cachedAt';
  static const _kSongDbVersionKey = 'songs.version';
  static const _kSongDbUpdatedAtKey = 'songs.updatedAt';
  static const _kSongDbSongsCountKey = 'songs.songsCount';
  static const _kSongDbBooksCountKey = 'songs.booksCount';

  List<Song>? _songsCache;
  List<SongBook>? _booksCache;
  ({String? version, DateTime? updatedAt, int songsCount, int booksCount})?
  _metaCache;

  ({DateTime? updatedAt, double? sizeInKB})? _remoteMetaCache;

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value.trim());
    return null;
  }

  void _setMetaCache({
    required String? version,
    required DateTime? updatedAt,
    required int songsCount,
    required int booksCount,
  }) {
    _metaCache = (
      version: (version != null && version.trim().isNotEmpty)
          ? version.trim()
          : null,
      updatedAt: updatedAt,
      songsCount: songsCount,
      booksCount: booksCount,
    );
  }

  Future<Box<dynamic>> _ensureSongDbBoxOpen() async {
    if (!Hive.isBoxOpen(_kSongDbBox)) {
      await Hive.openBox(_kSongDbBox);
    }
    return Hive.box(_kSongDbBox);
  }

  Future<DateTime?> getSongDbCachedAt() async {
    final box = await _ensureSongDbBoxOpen();
    final cachedAt = box.get(_kSongDbCachedAtKey);
    return _asDateTime(cachedAt);
  }

  ({List<SongBook> books, List<Song> songs}) _parseSongDbJson(String rawJson) {
    final normalized = rawJson.trimLeft();
    final decoded = jsonDecode(normalized);

    if (decoded is List) {
      final songs = decoded
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .map(Song.fromJson)
          .toList();
      _setMetaCache(
        version: null,
        updatedAt: null,
        songsCount: songs.length,
        booksCount: 0,
      );
      return (books: const <SongBook>[], songs: songs);
    }

    if (decoded is! Map<String, dynamic>) {
      throw Failure('Invalid song DB JSON format');
    }

    final booksList = decoded['books'];
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

    final songsList = decoded['songs'];
    if (songsList is! List) {
      throw Failure('Invalid song DB JSON format');
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

    final version = decoded['version']?.toString();
    final updatedAt = _asDateTime(decoded['updatedAt']);
    final songsCount = _asInt(decoded['songs_count']) ?? songs.length;
    final booksCount = _asInt(decoded['books_count']) ?? books.length;
    _setMetaCache(
      version: version,
      updatedAt: updatedAt,
      songsCount: songsCount,
      booksCount: booksCount,
    );

    return (books: books, songs: songs);
  }

  List<SongBook> _parseBooksJson(String rawJson) {
    return _parseSongDbJson(rawJson).books;
  }

  Future<List<SongBook>> getSongBooks({bool forceRefresh = false}) async {
    if (!forceRefresh && _booksCache != null) {
      return _booksCache!;
    }

    final box = await _ensureSongDbBoxOpen();
    final cached = box.get(_kSongDbJsonKey);
    if (cached is String && cached.trim().isNotEmpty) {
      final books = _parseBooksJson(cached);
      _booksCache = books;
      return books;
    }
    throw Failure('Song DB not downloaded');
  }

  Future<({DateTime? updatedAt, double? sizeInKB})> getRemoteSongDbMetadata({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _remoteMetaCache != null) {
      return _remoteMetaCache!;
    }

    final config = _ref.read(appConfigProvider);
    final fileId = config.songDbFileId;
    if (fileId == null) {
      throw Failure('Missing SONG_DB_FILE_ID');
    }

    final socket = _ref.read(socketServiceProvider);
    final body = await socket.rpc('public.songDb.meta', {'fileId': fileId});
    final Map<String, dynamic> data =
        (body['data'] as Map?)?.cast<String, dynamic>() ?? {};

    final updatedAt = _asDateTime(data['updatedAt']);

    final rawSize = data['sizeInKB'];
    double? sizeInKB;
    if (rawSize is num) {
      sizeInKB = rawSize.toDouble();
    } else if (rawSize is String) {
      sizeInKB = double.tryParse(rawSize.trim());
    }

    _remoteMetaCache = (updatedAt: updatedAt, sizeInKB: sizeInKB);
    return _remoteMetaCache!;
  }

  Future<bool> hasCachedSongDb() async {
    final box = await _ensureSongDbBoxOpen();
    final cached = box.get(_kSongDbJsonKey);
    return cached is String && cached.trim().isNotEmpty;
  }

  Future<Result<bool, Failure>> downloadSongDb() async {
    try {
      final config = _ref.read(appConfigProvider);
      final fileId = config.songDbFileId;
      if (fileId == null) {
        return Result.failure(Failure('Missing SONG_DB_FILE_ID'));
      }

      final fm = _ref.read(fileManagerRepositoryProvider);
      final dl = await fm.fetchFileBytes(fileId: fileId, showProgress: false);

      Failure? downloadFailure;
      final bytes = dl.when(
        onSuccess: (bytes) => bytes,
        onFailure: (failure) {
          downloadFailure = failure;
        },
      );

      if (bytes == null) {
        return Result.failure(
          downloadFailure ?? Failure('Failed to download song DB'),
        );
      }

      final raw = utf8.decode(bytes);
      final parsed = _parseSongDbJson(raw);

      final box = await _ensureSongDbBoxOpen();
      await box.put(_kSongDbJsonKey, raw);
      await box.put(_kSongDbCachedAtKey, DateTime.now().toIso8601String());
      await box.put(_kSongDbVersionKey, _metaCache?.version);
      await box.put(
        _kSongDbUpdatedAtKey,
        _metaCache?.updatedAt?.toIso8601String(),
      );
      await box.put(_kSongDbSongsCountKey, _metaCache?.songsCount);
      await box.put(_kSongDbBooksCountKey, _metaCache?.booksCount);
      _songsCache = null;
      _booksCache = parsed.books;

      return Result.success(true);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<
    ({String? version, DateTime? updatedAt, int songsCount, int booksCount})
  >
  getSongDbMetadata({bool forceRefresh = false}) async {
    if (!forceRefresh && _metaCache != null) {
      return _metaCache!;
    }

    final box = await _ensureSongDbBoxOpen();

    final version = box.get(_kSongDbVersionKey);
    final updatedAt = box.get(_kSongDbUpdatedAtKey);
    final songsCount = box.get(_kSongDbSongsCountKey);
    final booksCount = box.get(_kSongDbBooksCountKey);

    final cachedSongsCount = _asInt(songsCount);
    final cachedBooksCount = _asInt(booksCount);
    if (cachedSongsCount != null && cachedBooksCount != null) {
      _setMetaCache(
        version: version?.toString(),
        updatedAt: _asDateTime(updatedAt),
        songsCount: cachedSongsCount,
        booksCount: cachedBooksCount,
      );
      return _metaCache!;
    }

    final cached = box.get(_kSongDbJsonKey);
    if (cached is String && cached.trim().isNotEmpty) {
      _parseSongDbJson(cached);
      await box.put(_kSongDbVersionKey, _metaCache?.version);
      await box.put(
        _kSongDbUpdatedAtKey,
        _metaCache?.updatedAt?.toIso8601String(),
      );
      await box.put(_kSongDbSongsCountKey, _metaCache?.songsCount);
      await box.put(_kSongDbBooksCountKey, _metaCache?.booksCount);
      return _metaCache!;
    }

    throw Failure('Song DB not downloaded');
  }

  Future<List<Song>> _loadSongs({required bool forceRefresh}) async {
    if (!forceRefresh && _songsCache != null) {
      return _songsCache!;
    }

    final box = await _ensureSongDbBoxOpen();

    final cached = box.get(_kSongDbJsonKey);
    if (cached is String && cached.trim().isNotEmpty) {
      final parsed = _parseSongDbJson(cached);
      final songs = parsed.songs;
      _songsCache = songs;
      _booksCache = parsed.books;
      return songs;
    }

    throw Failure('Song DB not downloaded');
  }

  String _normalizeSearch(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }

  String _normalizeSongTitle(String value) {
    final lowered = value.toLowerCase();
    final withoutNo = lowered.replaceAll(
      RegExp(r'\bno\.?\s*', caseSensitive: false),
      '',
    );
    return withoutNo.replaceAll(RegExp(r'\s+'), '');
  }

  /// Get songs with pagination and optional search filter
  /// Supports searching by title or index
  Future<Result<PaginationResponseWrapper<Song>, Failure>> getSongs({
    required PaginationRequestWrapper<GetFetchSongsRequest> paginationRequest,
    bool forceRefresh = false,
  }) async {
    try {
      final allSongs = await _loadSongs(forceRefresh: forceRefresh);
      final query = paginationRequest.data.search?.trim() ?? '';
      final filtered = query.isEmpty
          ? allSongs
          : allSongs.where((s) {
              final q = _normalizeSearch(query);
              bool matchesField(String value) =>
                  _normalizeSearch(value).contains(q);

              final titleMatch =
                  _normalizeSongTitle(s.title).contains(q) ||
                  _normalizeSearch(s.title).contains(q);

              final lyricsMatch = s.definition.any(
                (p) => _normalizeSearch(p.content).contains(q),
              );

              return titleMatch ||
                  matchesField(s.subTitle) ||
                  matchesField(s.bookId) ||
                  matchesField(s.bookName) ||
                  matchesField(s.author) ||
                  matchesField(s.publisher) ||
                  lyricsMatch;
            }).toList();

      final page = paginationRequest.page;
      final pageSize = paginationRequest.pageSize;
      final total = filtered.length;
      final totalPages = total == 0 ? 1 : ((total + pageSize - 1) ~/ pageSize);
      final start = (page - 1) * pageSize;
      final end = (start + pageSize).clamp(0, total);
      final pageItems = start >= total
          ? <Song>[]
          : filtered.sublist(start, end);

      return Result.success(
        PaginationResponseWrapper<Song>(
          message: 'Success',
          pagination: PaginationResponseWrapperResponse(
            page: page,
            pageSize: pageSize,
            total: total,
            totalPages: totalPages,
            hasNext: page < totalPages,
            hasPrev: page > 1,
          ),
          data: pageItems,
        ),
      );
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  /// Search songs by title or index
  Future<Result<PaginationResponseWrapper<Song>, Failure>> searchSongs({
    required String query,
    int page = 1,
    int pageSize = 10000,
    bool forceRefresh = false,
  }) async {
    final request = PaginationRequestWrapper(
      page: page,
      pageSize: pageSize,
      data: GetFetchSongsRequest(search: query),
    );
    return getSongs(paginationRequest: request, forceRefresh: forceRefresh);
  }

  /// Get a single song by ID with all its parts
  Future<Result<Song, Failure>> getSongById({
    required String songId,
    bool forceRefresh = false,
  }) async {
    try {
      final songs = await _loadSongs(forceRefresh: forceRefresh);
      final song = songs.cast<Song?>().firstWhere(
        (s) => s?.id == songId,
        orElse: () => null,
      );
      if (song == null) {
        return Result.failure(Failure('Song not found'));
      }
      return Result.success(song);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
