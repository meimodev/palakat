import 'dart:async';
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:palakat_shared/core/models/models.dart';
import '../data/songs_repository.dart';

final songsControllerProvider = NotifierProvider<SongsController, SongsState>(
  SongsController.new,
);

class SongsState {
  const SongsState({
    this.search = '',
    this.bookIdFilter = '',
    this.page = 1,
    this.pageSize = 50,
    this.songDb = const AsyncValue.loading(),
    this.hasDraft = false,
  });

  final String search;
  final String bookIdFilter;
  final int page;
  final int pageSize;
  final AsyncValue<SongDbFile> songDb;
  final bool hasDraft;

  SongsState copyWith({
    String? search,
    String? bookIdFilter,
    int? page,
    int? pageSize,
    AsyncValue<SongDbFile>? songDb,
    bool? hasDraft,
  }) {
    return SongsState(
      search: search ?? this.search,
      bookIdFilter: bookIdFilter ?? this.bookIdFilter,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      songDb: songDb ?? this.songDb,
      hasDraft: hasDraft ?? this.hasDraft,
    );
  }
}

class SongsController extends Notifier<SongsState> {
  late final SongsRepository _repository;

  static const _kDraftBox = 'super_admin_song_db_draft';
  static const _kDraftJsonKey = 'songs.json.draft';

  final Map<String, String> _headerIndexById = <String, String>{};
  final Map<String, String> _lyricsIndexById = <String, String>{};

  List<Song>? _cachedFiltered;
  String? _cachedQuery;
  String? _cachedBookIdFilter;
  List<Song>? _cachedSongsRef;

  @override
  SongsState build() {
    _repository = ref.read(songsRepositoryProvider);
    Future(() => refresh());
    return const SongsState();
  }

  Future<Box<dynamic>> _ensureDraftBoxOpen() async {
    if (!Hive.isBoxOpen(_kDraftBox)) {
      await Hive.openBox(_kDraftBox);
    }
    return Hive.box(_kDraftBox);
  }

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

  String _encodeSongDbJson(SongDbFile db) {
    final encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert({
      'version': db.version,
      'updatedAt': db.updatedAt?.toUtc().toIso8601String(),
      'books_count': db.books.length,
      'songs_count': db.songs.length,
      'books': db.books.map((b) => b.toJson()).toList(),
      'songs': db.songs.map((s) => s.toJson()).toList(),
    });
  }

  Future<SongDbFile?> _loadDraftOrNull() async {
    final box = await _ensureDraftBoxOpen();
    final raw = box.get(_kDraftJsonKey);
    if (raw is! String || raw.trim().isEmpty) return null;
    try {
      return _parseSongDbJson(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveDraft(SongDbFile db) async {
    final box = await _ensureDraftBoxOpen();
    await box.put(_kDraftJsonKey, _encodeSongDbJson(db));
  }

  Future<void> clearDraft() async {
    final box = await _ensureDraftBoxOpen();
    await box.delete(_kDraftJsonKey);
  }

  Future<void> refresh({bool discardDraft = false}) async {
    state = state.copyWith(songDb: const AsyncValue.loading());
    try {
      await Future<void>.delayed(Duration.zero);

      if (discardDraft) {
        await clearDraft();
      } else {
        final draft = await _loadDraftOrNull();
        if (draft != null) {
          _clearAllCaches();
          state = state.copyWith(
            songDb: AsyncValue.data(draft),
            hasDraft: true,
          );
          return;
        }
      }

      final res = await _repository.downloadSongDb();
      _clearAllCaches();
      state = state.copyWith(songDb: AsyncValue.data(res), hasDraft: false);
    } catch (e, st) {
      state = state.copyWith(songDb: AsyncValue.error(e, st));
    }
  }

  void onChangedSearch(String value) {
    _clearFilteredCache();
    state = state.copyWith(search: value, page: 1);
  }

  void onChangedBookFilter(String? value) {
    _clearFilteredCache();
    state = state.copyWith(bookIdFilter: (value ?? ''), page: 1);
  }

  void onChangedPageSize(int value) {
    state = state.copyWith(pageSize: value, page: 1);
  }

  void onChangedPage(int value) {
    state = state.copyWith(page: value);
  }

  void onPrev() {
    if (state.page > 1) {
      state = state.copyWith(page: state.page - 1);
    }
  }

  void onNext() {
    if (state.page < _pageCount()) {
      state = state.copyWith(page: state.page + 1);
    }
  }

  bool get hasPrev => state.page > 1;

  bool get hasNext => state.page < _pageCount();

  int totalFilteredCount() => _filteredSongs().length;

  List<Song> pagedSongs() {
    final filtered = _filteredSongs();
    if (filtered.isEmpty) return const <Song>[];

    final pageSize = state.pageSize;
    final page = state.page.clamp(1, _pageCount(total: filtered.length));

    final start = (page - 1) * pageSize;
    if (start >= filtered.length) return const <Song>[];
    final end = (start + pageSize) > filtered.length
        ? filtered.length
        : (start + pageSize);
    return filtered.sublist(start, end);
  }

  Song? findSongById(String id) {
    final songs = state.songDb.asData?.value.songs;
    if (songs == null) return null;
    for (final s in songs) {
      if (s.id == id) return s;
    }
    return null;
  }

  Future<void> upsertSong(Song song) async {
    final current = state.songDb.asData?.value;
    if (current == null) {
      throw StateError('Song DB is not loaded');
    }

    _clearFilteredCache();
    _headerIndexById.remove(song.id);
    _lyricsIndexById.remove(song.id);

    final idx = current.songs.indexWhere((s) => s.id == song.id);
    final now = DateTime.now();
    final normalized = song.copyWith(lastUpdate: now);

    final nextSongs = [...current.songs];
    if (idx >= 0) {
      nextSongs[idx] = normalized;
    } else {
      nextSongs.add(normalized);
    }

    final updatedDb = current.copyWith(
      updatedAt: now,
      songsCount: nextSongs.length,
      songs: nextSongs,
    );

    state = state.copyWith(songDb: AsyncValue.data(updatedDb), hasDraft: true);
    await _saveDraft(updatedDb);
  }

  Future<void> deleteSong(String id) async {
    final current = state.songDb.asData?.value;
    if (current == null) {
      throw StateError('Song DB is not loaded');
    }

    _clearFilteredCache();
    _headerIndexById.remove(id);
    _lyricsIndexById.remove(id);

    final nextSongs = current.songs.where((s) => s.id != id).toList();
    final now = DateTime.now();
    final updatedDb = current.copyWith(
      updatedAt: now,
      songsCount: nextSongs.length,
      songs: nextSongs,
    );

    state = state.copyWith(songDb: AsyncValue.data(updatedDb), hasDraft: true);
    await _saveDraft(updatedDb);
  }

  String _bumpVersion(String? current) {
    final raw = (current ?? '').trim();
    if (raw.isEmpty) return '1.0.0';
    final m = RegExp(r'^(\d+)\.(\d+)\.(\d+)$').firstMatch(raw);
    if (m == null) return '1.0.0';
    final major = int.tryParse(m.group(1) ?? '') ?? 1;
    final minor = int.tryParse(m.group(2) ?? '') ?? 0;
    final patch = int.tryParse(m.group(3) ?? '') ?? 0;
    return '$major.$minor.${patch + 1}';
  }

  Future<Map<String, dynamic>> saveSongDb() async {
    final current = state.songDb.asData?.value;
    if (current == null) {
      throw StateError('Song DB is not loaded');
    }

    final now = DateTime.now().toUtc();
    final next = current.copyWith(
      version: _bumpVersion(current.version),
      updatedAt: now,
      booksCount: current.books.length,
      songsCount: current.songs.length,
    );

    final rawJson = _encodeSongDbJson(next);
    final res = await _repository.uploadSongDb(rawJson: rawJson);
    await clearDraft();
    state = state.copyWith(songDb: AsyncValue.data(next), hasDraft: false);
    return res;
  }

  void _clearFilteredCache() {
    _cachedFiltered = null;
    _cachedQuery = null;
    _cachedBookIdFilter = null;
    _cachedSongsRef = null;
  }

  void _clearAllCaches() {
    _clearFilteredCache();
    _headerIndexById.clear();
    _lyricsIndexById.clear();
  }

  List<Song> _filteredSongs() {
    final songs = state.songDb.asData?.value.songs ?? const <Song>[];
    final q = state.search;
    final bookIdFilter = state.bookIdFilter;

    if (_cachedFiltered != null &&
        _cachedQuery == q &&
        _cachedBookIdFilter == bookIdFilter &&
        identical(_cachedSongsRef, songs)) {
      return _cachedFiltered!;
    }

    final bookFiltered = bookIdFilter.trim().isEmpty
        ? songs
        : songs.where((s) => s.bookId.trim() == bookIdFilter.trim()).toList();

    final tokens = _tokenize(q);
    if (tokens.isEmpty) {
      _cachedSongsRef = songs;
      _cachedQuery = q;
      _cachedBookIdFilter = bookIdFilter;
      _cachedFiltered = bookFiltered;
      return bookFiltered;
    }

    final res = bookFiltered
        .where((s) => _matchesTokens(song: s, tokens: tokens))
        .toList();

    final qId = _normalizeId(q);
    if (qId.isNotEmpty) {
      final exactIdx = res.indexWhere((s) => _normalizeId(s.id) == qId);
      if (exactIdx > 0) {
        final exact = res.removeAt(exactIdx);
        res.insert(0, exact);
      }
    }

    _cachedSongsRef = songs;
    _cachedQuery = q;
    _cachedBookIdFilter = bookIdFilter;
    _cachedFiltered = res;
    return res;
  }

  bool _matchesTokens({required Song song, required List<String> tokens}) {
    final header = _headerHaystack(song);
    String? lyrics;
    for (final t in tokens) {
      if (_containsTokenPrefix(haystack: header, token: t)) continue;
      lyrics ??= _lyricsHaystack(song);
      if (!_containsTokenPrefix(haystack: lyrics, token: t)) return false;
    }
    return true;
  }

  bool _containsTokenPrefix({required String haystack, required String token}) {
    if (token.isEmpty) return true;
    if (token.length >= 3) return haystack.contains(token);
    if (haystack == token) return true;
    if (haystack.startsWith(token)) return true;
    return haystack.contains(' $token');
  }

  int _pageCount({int? total}) {
    final t = total ?? totalFilteredCount();
    return _pageCountFor(total: t, pageSize: state.pageSize);
  }

  int _pageCountFor({required int total, required int pageSize}) {
    if (total <= 0) return 1;
    return (total / pageSize).ceil();
  }

  List<String> _tokenize(String raw) {
    final norm = _normalize(raw);
    if (norm.isEmpty) return const <String>[];
    return norm.split(' ').where((t) => t.trim().isNotEmpty).toList();
  }

  String _normalize(String raw) {
    final lower = raw.toLowerCase();
    final spaced = lower.replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
    return spaced.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _normalizeId(String raw) {
    return _normalize(raw).replaceAll(' ', '');
  }

  String _headerHaystack(Song s) {
    final cached = _headerIndexById[s.id];
    if (cached != null) return cached;
    final combined =
        '${s.id} ${s.title} ${s.subTitle} ${s.bookId} ${s.bookName} ${s.author} ${s.publisher}';
    final norm = _normalize(combined);
    _headerIndexById[s.id] = norm;
    return norm;
  }

  String _lyricsHaystack(Song s) {
    final cached = _lyricsIndexById[s.id];
    if (cached != null) return cached;
    final combined = s.definition.map((p) => p.content).join(' ');
    final norm = _normalize(combined);
    _lyricsIndexById[s.id] = norm;
    return norm;
  }
}
