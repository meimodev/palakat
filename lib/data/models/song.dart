import 'song_part.dart';

class Song {
  final String id;
  final String title;
  final String book;
  final List<SongPart> songParts;

  Song({
    required this.id,
    required this.title,
    required this.book,
    required this.songParts,
  });
}
