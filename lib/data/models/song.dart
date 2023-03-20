import 'package:isar/isar.dart';
import 'package:palakat/shared/shared.dart';

part 'song.g.dart';

@collection
class Song {
  Id isarId = Isar.autoIncrement;

  final String id;
  final String title;
  final String book;
  final String entry;
  final List<SongPart> songParts;
  final List<String> composition;

  Song({
    required this.id,
    required this.title,
    required this.book,
    required this.entry,
    required this.songParts,
    required this.composition,
  });

  @Index()
  List<String> get titleWords => Isar.splitWords(title);

  // @Index(type: IndexType.value, caseSensitive: false)
  // List<String> get contentWords {
  //   String res = '';
  //   for (SongPart songPart in songParts) {
  //     res += songPart.content!.reduce((value, element) => " $value $element ");
  //   }
  //   return Isar.splitWords(res);
  // }

  @Index()
  String get rawTitle {
    String res = '';
    res = "$book ${book.toInitials} $entry $id $title".toLowerCase();
    res = res.replaceAll(RegExp('[^A-Za-z0-9 ]'), '');
    res = res.replaceAll('  ', ' ');
    return res;
  }

  @Index()
  String get rawLyrics {
    String res = '';
    for (SongPart songPart in songParts) {
      res += songPart.content!.reduce((value, element) => "$value $element ");
    }

    res = res.replaceAll(RegExp('[^A-Za-z0-9 ]'), '');
    res = res.replaceAll('  ', ' ');
    return res;
  }

  @override
  String toString() {
    return 'Song{isarId: $isarId, '
        'id: $id, title: $title, '
        'book: $book, entry: $entry, '
        'songParts: $songParts, composition: $composition}';
  }
}

@embedded
class SongPart {
  String? type;
  List<String>? content;

  SongPart({this.type, this.content});

  factory SongPart.fromMap(Map<String, dynamic> map) => SongPart(
        content: List<String>.from(map["content"]),
        type: map["type"],
      );

  @override
  String toString() {
    return 'SongPart{type: $type, content: $content}';
  }
}
