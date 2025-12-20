import 'admin_song_part_model.dart';

class AdminSongModel {
  AdminSongModel({
    required this.id,
    required this.title,
    required this.index,
    required this.book,
    required this.link,
    this.parts = const [],
  });

  final int id;
  final String title;
  final int index;
  final String book;
  final String link;
  final List<AdminSongPartModel> parts;

  factory AdminSongModel.fromJson(Map<String, dynamic> json) {
    final partsJson = json['parts'] as List<dynamic>?;
    final parts = (partsJson ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(AdminSongPartModel.fromJson)
        .toList();

    parts.sort((a, b) => a.index.compareTo(b.index));

    return AdminSongModel(
      id: (json['id'] as num).toInt(),
      title: json['title']?.toString() ?? '',
      index: (json['index'] as num?)?.toInt() ?? 0,
      book: json['book']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
      parts: parts,
    );
  }
}
