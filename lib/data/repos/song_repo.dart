import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:jiffy/jiffy.dart';
import 'package:palakat/data/models/helper_song_db_version.dart';
import 'package:palakat/data/models/song.dart';
import 'dart:developer' as dev;

import 'package:palakat/shared/shared.dart';

class SongRepo {
  Isar? isar;
  static Map<String, dynamic>? decodedStringFromAsset;

  Future<void> initSongs() async {
    isar ??= await Isar.open([SongSchema, HelperSongDbVersionSchema]);

    final isSongsAlreadyCached = await isar!.songs.getSize() > 0;
    if (isSongsAlreadyCached) {
      dev.log("[SongRepo] songs already cached");

      final cachedSongsVersion =
          (await isar!.helperSongDbVersions.where().findAll()).first;

      final cachedSongsVersionDate =
          Jiffy(cachedSongsVersion.dateRaw, Values.rawDBSongsVersionFormat);

      final localSongsData = await _readDataFromLocalFile();

      final localSongsDate = Jiffy(
          localSongsData["version_time_stamp"], Values.rawDBSongsVersionFormat);

      final isLocalSongsVersionIsSameOrOlder =
          localSongsDate.isSameOrBefore(cachedSongsVersionDate, Units.DAY);

      if (isLocalSongsVersionIsSameOrOlder) {
        dev.log("[SongRepo] cached songs version is same or newer, skip caching");
        return;
      }
      dev.log("[SongRepo] cached songs is older, starting caching");

    }

    clearSongs();
    final localSongsData = await _readDataFromLocalFile();
    dev.log(
        "[SongRepo] caching songs, to version ${localSongsData["version_time_stamp"]} ");

    await isar!.writeTxn(() async {
      await isar!.helperSongDbVersions.put(
          HelperSongDbVersion(dateRaw: localSongsData["version_time_stamp"]));

      for (Map<String, dynamic> d in localSongsData["data"]) {
        await isar!.songs.put(
          Song(
            id: d["id"],
            title: d["title"],
            book: d["book"],
            entry: d["entry"],
            songParts: (d["parts"] as List)
                .map<SongPart>(
                    (e) => SongPart.fromMap(e as Map<String, dynamic>))
                .toList(),
            composition: List<String>.from(d["composition"]),
          ),
        );
      }
    });
  }

   Future<Map<String, dynamic>> _readDataFromLocalFile() async {
    if (decodedStringFromAsset != null) {
      return decodedStringFromAsset!;
    }

    final String loadedStringFromAsset =
        await rootBundle.loadString('assets/songs/songs.json');
     decodedStringFromAsset = await json.decode(loadedStringFromAsset);
    return decodedStringFromAsset!;
  }

  Future<List<Song>> getSongs() async {
    return await isar!.songs.where().findAll();
  }

  Future<void> setSongs() async {
    // await isar!.writeTxn(() async{
    //   await isar!.songs.put();
    // });
  }

  Future<List<Song>> searchSong(String text) async {
    return await isar!.songs
        .filter()
        .contentWordsElementContains(text, caseSensitive: false)
        .findAll();
  }

  Future<void> clearSongs() async {
    await isar!.writeTxn(() async {
      await isar!.songs.clear();
      await isar!.helperSongDbVersions.clear();
    });
  }
}
