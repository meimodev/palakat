import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palakat/data/models/song.dart';
import 'package:palakat/data/models/song_part.dart';
import 'package:palakat/shared/routes.dart';

class SongsController extends GetxController {
  final tecSearch = TextEditingController();

  final List<String> songBooks = [
    "Nanyikanlah Nyanyian Baru Bagi TUHAN (NNBT)",
    "Kidung Jemaat (KJ)",
    "Nyanyikanlah Kidung Baru (NKB)",
    "Dua Sahabat Lama (DSL)",
  ];

  final List<String> searchHints = [
    "NKB No 2",
    "Terpujilah Allah",
    "kami puji dengan riang",
    "Hatiku percaya",
  ];

   List<Song> songs = [
    Song(id: '123', title: "Kami Puji Dengan riang", book: "KJ 1", songParts: [
      SongPart(type: "Verse 1", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Verse 2", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Refr", content: "lorem ipsum dolor sit amet"),
    ]),
    Song(id: '123', title: "Suci suci suci", book: "NNBT 2", songParts: [
      SongPart(type: "Verse 1", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Verse 2", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Refr", content: "lorem ipsum dolor sit amet"),
    ]),
    Song(id: '123', title: "Kami Puji Dengan riang", book: "KJ 1", songParts: [
      SongPart(type: "Verse 1", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Verse 2", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Refr", content: "lorem ipsum dolor sit amet"),
    ]),
    Song(id: '123', title: "Suci suci suci", book: "NNBT 2", songParts: [
      SongPart(type: "Verse 1", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Verse 2", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Refr", content: "lorem ipsum dolor sit amet"),
    ]),
    Song(id: '123', title: "Kami Puji Dengan riang", book: "KJ 1", songParts: [
      SongPart(type: "Verse 1", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Verse 2", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Refr", content: "lorem ipsum dolor sit amet"),
    ]),
    Song(id: '123', title: "Suci suci suci", book: "NNBT 2", songParts: [
      SongPart(type: "Verse 1", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Verse 2", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Refr", content: "lorem ipsum dolor sit amet"),
    ]),
    Song(id: '123', title: "Kami Puji Dengan riang", book: "KJ 1", songParts: [
      SongPart(type: "Verse 1", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Verse 2", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Refr", content: "lorem ipsum dolor sit amet"),
    ]),
    Song(id: '123', title: "Suci suci suci", book: "NNBT 2", songParts: [
      SongPart(type: "Verse 1", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Verse 2", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Refr", content: "lorem ipsum dolor sit amet"),
    ]),
    Song(id: '123', title: "Kami Puji Dengan riang", book: "KJ 1", songParts: [
      SongPart(type: "Verse 1", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Verse 2", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Refr", content: "lorem ipsum dolor sit amet"),
    ]),
    Song(id: '123', title: "Suci suci suci", book: "NNBT 2", songParts: [
      SongPart(type: "Verse 1", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Verse 2", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Refr", content: "lorem ipsum dolor sit amet"),
    ]), Song(id: '123', title: "Kami Puji Dengan riang", book: "KJ 1", songParts: [
      SongPart(type: "Verse 1", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Verse 2", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Refr", content: "lorem ipsum dolor sit amet"),
    ]),
    Song(id: '123', title: "Suci suci suci", book: "NNBT 2", songParts: [
      SongPart(type: "Verse 1", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Verse 2", content: "lorem ipsum dolor sit amet"),
      SongPart(type: "Refr", content: "lorem ipsum dolor sit amet"),
    ]),

  ];

  @override
  void dispose() {
    tecSearch.dispose();
    super.dispose();
  }

  void onPressedCategoryCard(String category) {
    tecSearch.text = category;
  }

  void onPressedSongCard(Song song) {
    print(song.title);
    Get.toNamed(Routes.songDetail, arguments: song);
  }

  void onChangeSearchText(String text) {
  }
}
