import 'package:isar/isar.dart';

part 'helper_song_db_version.g.dart';

@collection
class HelperSongDbVersion {

  Id id = Isar.autoIncrement;

  final String dateRaw;

  HelperSongDbVersion({
    required this.dateRaw
  });

  @override
  String toString() {
    return 'HelperSongDbVersion{id: $id, dateRaw: $dateRaw}';
  }
}


