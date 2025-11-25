import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/models.dart';

part 'song.freezed.dart';
part 'song.g.dart';

@freezed
abstract class Song with _$Song {
  const factory Song({
    required String id,
    required String title,
    required String subTitle,
    required List<SongPartType> composition,
    @ListSongPartConverter() required List<SongPart> definition,
    @Default("") String urlImage,
    @Default("") String urlVideo,
  }) = _Song;

  factory Song.fromJson(Map<String, dynamic> data) => _$SongFromJson(data);
}

class ListSongPartConverter
    implements JsonConverter<List<SongPart>, List<Map<String, dynamic>>> {
  const ListSongPartConverter();

  @override
  List<SongPart> fromJson(List<Map<String, dynamic>> json) {
    return json.map((e) => SongPart.fromJson(e)).toList();
  }

  @override
  List<Map<String, dynamic>> toJson(List<SongPart> object) =>
      object.map((e) => e.toJson()).toList();
}

/// Extension to transform backend API response to Flutter Song model.
///
/// Backend response format:
/// ```json
/// {
///   "id": 1,
///   "title": "Song Title",
///   "index": 1,
///   "book": "KJ",
///   "link": "...",
///   "parts": [{ "id": 1, "index": 1, "name": "Verse 1", "content": "..." }]
/// }
/// ```
extension SongMapper on Map<String, dynamic> {
  /// Converts a backend song response to a Flutter [Song] model.
  ///
  /// Maps backend fields to Flutter model fields:
  /// - `id` → string representation of backend id
  /// - `title` → "{book} NO.{index}"
  /// - `subTitle` → backend title
  /// - `composition` → list of SongPartType from parts
  /// - `definition` → list of SongPart from parts
  /// - `urlImage` → backend link
  Song toSong() {
    final partsJson = this['parts'] as List<dynamic>? ?? [];

    // Sort parts by index to ensure correct ordering
    final sortedParts =
        List<Map<String, dynamic>>.from(
          partsJson.map((p) => p as Map<String, dynamic>),
        )..sort(
          (a, b) =>
              (a['index'] as int? ?? 0).compareTo(b['index'] as int? ?? 0),
        );

    final parts = sortedParts.map((p) {
      final partName = p['name'] as String? ?? '';
      return SongPart(
        type: _mapPartNameToType(partName),
        content: p['content'] as String? ?? '',
      );
    }).toList();

    final book = this['book'] as String? ?? '';
    final index = this['index'] as int? ?? 0;

    return Song(
      id: this['id'].toString(),
      title: '$book NO.$index',
      subTitle: this['title'] as String? ?? '',
      composition: parts.map((p) => p.type).toList(),
      definition: parts,
      urlImage: this['link'] as String? ?? '',
      urlVideo: '',
    );
  }

  /// Maps a backend part name string to [SongPartType] enum.
  ///
  /// Backend part names can be in various formats:
  /// - "Verse 1", "Verse 2", etc.
  /// - "Chorus", "Chorus 2", etc.
  /// - "Bridge", "Intro", "Outro", etc.
  /// - "Refrain", "Pre-Chorus", "Hook"
  static SongPartType _mapPartNameToType(String partName) {
    final normalized = partName.toLowerCase().trim();

    // Handle numbered verses
    if (normalized.startsWith('verse')) {
      final number = _extractNumber(normalized);
      switch (number) {
        case 1:
          return SongPartType.verse;
        case 2:
          return SongPartType.verse2;
        case 3:
          return SongPartType.verse3;
        case 4:
          return SongPartType.verse4;
        case 5:
          return SongPartType.verse5;
        case 6:
          return SongPartType.verse6;
        case 7:
          return SongPartType.verse7;
        case 8:
          return SongPartType.verse8;
        default:
          return SongPartType.verse;
      }
    }

    // Handle numbered choruses
    if (normalized.startsWith('chorus')) {
      final number = _extractNumber(normalized);
      switch (number) {
        case 1:
          return SongPartType.chorus;
        case 2:
          return SongPartType.chorus2;
        case 3:
          return SongPartType.chorus3;
        case 4:
          return SongPartType.chorus4;
        default:
          return SongPartType.chorus;
      }
    }

    // Handle other part types
    if (normalized.contains('refrain') || normalized.contains('reff')) {
      return SongPartType.refrain;
    }
    if (normalized.contains('pre-chorus') || normalized.contains('prechorus')) {
      return SongPartType.preChorus;
    }
    if (normalized.contains('bridge')) {
      return SongPartType.bridge;
    }
    if (normalized.contains('intro')) {
      return SongPartType.intro;
    }
    if (normalized.contains('outro')) {
      return SongPartType.outro;
    }
    if (normalized.contains('hook')) {
      return SongPartType.hook;
    }

    // Default to verse for unknown types
    return SongPartType.verse;
  }

  /// Extracts a number from a string like "Verse 1" or "Chorus 2".
  /// Returns 1 if no number is found.
  static int _extractNumber(String text) {
    final match = RegExp(r'\d+').firstMatch(text);
    if (match != null) {
      return int.tryParse(match.group(0) ?? '1') ?? 1;
    }
    return 1;
  }
}
