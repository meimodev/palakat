import 'package:palakat_shared/core/models/song.dart';

import 'song_search_repository_base.dart';

class SongSearchRepositoryFallback implements SongSearchRepository {
  String? _fingerprint;
  List<Song> _songs = const <Song>[];

  bool _isLowerAlpha(int codeUnit) {
    return codeUnit >= 97 && codeUnit <= 122;
  }

  bool _isDigit(int codeUnit) {
    return codeUnit >= 48 && codeUnit <= 57;
  }

  bool _isWhitespace(int codeUnit) {
    return codeUnit == 32 || codeUnit == 9 || codeUnit == 10 || codeUnit == 13;
  }

  bool _isLettersOnly(String value) {
    if (value.isEmpty) return false;
    for (final codeUnit in value.codeUnits) {
      if (!_isLowerAlpha(codeUnit)) return false;
    }
    return true;
  }

  bool _isDigitsOnly(String value) {
    if (value.isEmpty) return false;
    for (final codeUnit in value.codeUnits) {
      if (!_isDigit(codeUnit)) return false;
    }
    return true;
  }

  String _removeWhitespace(String value) {
    final buffer = StringBuffer();
    for (final codeUnit in value.toLowerCase().codeUnits) {
      if (!_isWhitespace(codeUnit)) {
        buffer.writeCharCode(codeUnit);
      }
    }
    return buffer.toString();
  }

  List<String> _normalizedTokens(String value) {
    final lower = value.toLowerCase().trim();
    final tokens = <String>[];
    final buffer = StringBuffer();
    var previousKind = 0;

    void flush() {
      if (buffer.isEmpty) return;
      final token = buffer.toString();
      if (token != 'no') {
        tokens.add(token);
      }
      buffer.clear();
    }

    for (final codeUnit in lower.codeUnits) {
      final isAlpha = _isLowerAlpha(codeUnit);
      final isNumeric = _isDigit(codeUnit);
      if (!isAlpha && !isNumeric) {
        flush();
        previousKind = 0;
        continue;
      }

      final kind = isAlpha ? 1 : 2;
      if (buffer.isNotEmpty && previousKind != 0 && previousKind != kind) {
        flush();
      }
      buffer.writeCharCode(codeUnit);
      previousKind = kind;
    }
    flush();
    return tokens;
  }

  @override
  Future<void> ensureIndexed({
    required List<Song> songs,
    required String fingerprint,
    bool forceRebuild = false,
  }) async {
    if (!forceRebuild && _fingerprint == fingerprint) return;
    _fingerprint = fingerprint;
    _songs = songs;
  }

  String _normalizeSearch(String value) {
    return _removeWhitespace(value);
  }

  String _normalizeSongTitle(String value) {
    return _normalizedTokens(value).join();
  }

  int _bookNumberScore(Song s, String q) {
    final parts = _normalizedTokens(q);
    if (parts.length != 2 ||
        !_isLettersOnly(parts[0]) ||
        !_isDigitsOnly(parts[1])) {
      return 0;
    }

    final book = parts[0];
    final num = parts[1];

    final bookId = s.bookId.trim().toLowerCase();
    final titleNorm = _normalizeSongTitle(s.title);

    if (bookId == book && titleNorm == '$book$num') return 400;
    if (bookId == book && titleNorm.endsWith(num)) return 300;
    if (bookId == book) return 200;
    if (titleNorm == '$book$num') return 180;
    if (titleNorm.startsWith(book) && titleNorm.endsWith(num)) return 150;
    return 0;
  }

  int _fieldScore(Song s, String qNorm) {
    int score = 0;

    final bookId = _normalizeSearch(s.bookId);
    final bookName = _normalizeSearch(s.bookName);
    final titleA = _normalizeSongTitle(s.title);
    final titleB = _normalizeSearch(s.title);
    final subTitle = _normalizeSearch(s.subTitle);
    final author = _normalizeSearch(s.author);
    final publisher = _normalizeSearch(s.publisher);

    if (bookId == qNorm) score += 80;
    if (titleA == qNorm || titleB == qNorm) score += 70;

    if (titleA.contains(qNorm) || titleB.contains(qNorm)) score += 50;
    if (subTitle.contains(qNorm)) score += 25;
    if (bookName.contains(qNorm)) score += 18;
    if (author.contains(qNorm)) score += 12;
    if (publisher.contains(qNorm)) score += 8;

    final lyricsMatch = s.definition.any(
      (p) => _normalizeSearch(p.content).contains(qNorm),
    );
    if (lyricsMatch) score += 5;

    return score;
  }

  @override
  Future<List<String>> searchSongIds({
    required String query,
    required List<Song> songs,
    int limit = 2000,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return const <String>[];

    // Use latest in-memory songs (avoid stale if ensureIndexed not called)
    final source = songs.isNotEmpty ? songs : _songs;

    final qNorm = _normalizeSearch(q);
    if (qNorm.isEmpty) return const <String>[];

    final scored = source
        .map((s) {
          final score = _bookNumberScore(s, q) + _fieldScore(s, qNorm);
          return (song: s, score: score);
        })
        .where((e) => e.score > 0)
        .toList();

    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return a.song.title.compareTo(b.song.title);
    });

    final ids = <String>[];
    for (final e in scored) {
      ids.add(e.song.id);
      if (ids.length >= limit) break;
    }

    return ids;
  }
}
