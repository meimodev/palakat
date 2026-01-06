import 'dart:async';

import 'package:palakat_shared/core/models/song.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'song_search_repository_base.dart';
import 'song_search_repository_fallback.dart';

SongSearchRepository createSongSearchRepository() {
  return SongSearchRepositorySqflite();
}

class SongSearchRepositorySqflite implements SongSearchRepository {
  Database? _db;
  final SongSearchRepositoryFallback _fallback = SongSearchRepositoryFallback();

  Future<void>? _indexing;
  String? _fingerprint;

  Future<Database> _openDb() async {
    final existing = _db;
    if (existing != null && existing.isOpen) {
      return existing;
    }

    final dbDir = await getDatabasesPath();
    final dbPath = p.join(dbDir, 'song_search.db');

    final db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
    );

    await _createSchema(db);

    _db = db;
    return db;
  }

  Future<void> _createSchema(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS songs_fts_meta (key TEXT PRIMARY KEY, value TEXT)',
    );

    await db.execute(
      "CREATE VIRTUAL TABLE IF NOT EXISTS songs_fts USING fts5("
      "songId UNINDEXED,"
      "bookId,"
      "title,"
      "subTitle,"
      "bookName,"
      "author,"
      "publisher,"
      "lyrics,"
      "tokenize='unicode61 remove_diacritics 2'"
      ")",
    );
  }

  Future<String?> _readFingerprint(Database db) async {
    final rows = await db.query(
      'songs_fts_meta',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: const ['fingerprint'],
      limit: 1,
    );

    final value = rows.isNotEmpty ? rows.first['value'] : null;
    return value?.toString();
  }

  Future<void> _writeFingerprint(Transaction txn, String fingerprint) async {
    await txn.execute(
      'INSERT OR REPLACE INTO songs_fts_meta(key, value) VALUES(?, ?)',
      ['fingerprint', fingerprint],
    );
  }

  String _normalizeQuery(String query) {
    var q = query.toLowerCase().trim();
    q = q.replaceAll(RegExp(r'\bno\.?\b', caseSensitive: false), ' ');
    q = q.replaceAll(RegExp(r'([a-z])(\d)'), r'$1 $2');
    q = q.replaceAll(RegExp(r'(\d)([a-z])'), r'$1 $2');
    q = q.replaceAll(RegExp(r'[^0-9a-z]+'), ' ');
    q = q.replaceAll(RegExp(r'\s+'), ' ').trim();
    return q;
  }

  String _ftsToken(String token, {required bool allowPrefix}) {
    final cleaned = token.replaceAll(RegExp(r'[^0-9a-z]'), '');
    if (cleaned.isEmpty) return '';
    if (allowPrefix &&
        cleaned.length >= 3 &&
        !RegExp(r'^\d+$').hasMatch(cleaned)) {
      return '$cleaned*';
    }
    return cleaned;
  }

  String _buildFtsQuery(String raw) {
    final normalized = _normalizeQuery(raw);
    if (normalized.isEmpty) return '';

    final parts = normalized
        .split(' ')
        .where((e) => e.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';

    if (parts.length == 2 &&
        RegExp(r'^[a-z]+$').hasMatch(parts[0]) &&
        RegExp(r'^\d+$').hasMatch(parts[1])) {
      final book = _ftsToken(parts[0], allowPrefix: false);
      final num = _ftsToken(parts[1], allowPrefix: false);
      if (book.isEmpty || num.isEmpty) return '';
      return '((bookId:$book OR title:$book) AND title:$num)';
    }

    final tokens = parts
        .map((p) => _ftsToken(p, allowPrefix: true))
        .where((t) => t.isNotEmpty)
        .toList();

    return tokens.join(' ');
  }

  Future<void> _rebuildIndex(
    Database db,
    List<Song> songs,
    String fingerprint,
  ) async {
    await db.transaction((txn) async {
      await txn.execute('DROP TABLE IF EXISTS songs_fts');
      await txn.execute(
        "CREATE VIRTUAL TABLE songs_fts USING fts5("
        "songId UNINDEXED,"
        "bookId,"
        "title,"
        "subTitle,"
        "bookName,"
        "author,"
        "publisher,"
        "lyrics,"
        "tokenize='unicode61 remove_diacritics 2'"
        ")",
      );

      const chunkSize = 80;
      const maxLyricsChars = 12000;
      for (var i = 0; i < songs.length; i += chunkSize) {
        final end = (i + chunkSize > songs.length)
            ? songs.length
            : (i + chunkSize);
        final chunk = songs.sublist(i, end);

        final batch = txn.batch();
        for (final s in chunk) {
          final buffer = StringBuffer();
          for (final part in s.definition) {
            final content = part.content;
            if (content.trim().isEmpty) continue;
            if (buffer.isNotEmpty) buffer.writeln();
            if (buffer.length + content.length > maxLyricsChars) {
              final remaining = maxLyricsChars - buffer.length;
              if (remaining > 0) {
                buffer.write(content.substring(0, remaining));
              }
              break;
            }
            buffer.write(content);
          }
          final lyrics = buffer.toString();

          batch.execute(
            'INSERT INTO songs_fts(songId, bookId, title, subTitle, bookName, author, publisher, lyrics) VALUES(?, ?, ?, ?, ?, ?, ?, ?)',
            [
              s.id,
              s.bookId,
              s.title,
              s.subTitle,
              s.bookName,
              s.author,
              s.publisher,
              lyrics,
            ],
          );
        }
        await batch.commit(noResult: true, continueOnError: true);

        // Yield to the UI thread between chunks to prevent frame drops.
        await Future<void>.delayed(Duration.zero);
      }

      await _writeFingerprint(txn, fingerprint);
    });
  }

  @override
  Future<void> ensureIndexed({
    required List<Song> songs,
    required String fingerprint,
    bool forceRebuild = false,
  }) async {
    await _fallback.ensureIndexed(
      songs: songs,
      fingerprint: fingerprint,
      forceRebuild: forceRebuild,
    );

    if (!forceRebuild && _fingerprint == fingerprint) return;

    final existing = _indexing;
    if (existing != null) {
      await existing;
      return ensureIndexed(
        songs: songs,
        fingerprint: fingerprint,
        forceRebuild: forceRebuild,
      );
    }

    final completer = Completer<void>();
    _indexing = completer.future;

    try {
      final db = await _openDb();
      final dbFingerprint = await _readFingerprint(db);
      if (!forceRebuild && dbFingerprint == fingerprint) {
        _fingerprint = fingerprint;
        completer.complete();
        return;
      }

      await _rebuildIndex(db, songs, fingerprint);
      _fingerprint = fingerprint;
      completer.complete();
    } catch (_) {
      completer.complete();
    } finally {
      _indexing = null;
    }
  }

  @override
  Future<List<String>> searchSongIds({
    required String query,
    required List<Song> songs,
    int limit = 2000,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const <String>[];

    // Never block the UI while indexing. Use fallback until indexing completes.
    if (_indexing != null) {
      return _fallback.searchSongIds(
        query: trimmed,
        songs: songs,
        limit: limit,
      );
    }

    try {
      final db = await _openDb();
      final ftsQuery = _buildFtsQuery(trimmed);
      if (ftsQuery.isEmpty) {
        return _fallback.searchSongIds(
          query: trimmed,
          songs: songs,
          limit: limit,
        );
      }

      final rows = await db.rawQuery(
        'SELECT songId FROM songs_fts WHERE songs_fts MATCH ? ORDER BY bm25(songs_fts, 0.0, 12.0, 10.0, 6.0, 4.0, 2.0, 2.0, 0.5) LIMIT ?',
        [ftsQuery, limit],
      );

      final ids = <String>[];
      for (final row in rows) {
        final id = row['songId']?.toString();
        if (id != null && id.trim().isNotEmpty) {
          ids.add(id);
        }
      }

      if (ids.isEmpty) {
        return _fallback.searchSongIds(
          query: trimmed,
          songs: songs,
          limit: limit,
        );
      }

      return ids;
    } catch (_) {
      return _fallback.searchSongIds(
        query: trimmed,
        songs: songs,
        limit: limit,
      );
    }
  }
}
