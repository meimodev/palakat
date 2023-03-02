import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palakat/data/models/song.dart';
import 'package:palakat/data/repos/song_repo.dart';
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
  late SongRepo songRepo;

  List<Song> songs = [];

  var songsLoading = true.obs;

  @override
  void onInit() async {
    super.onInit();

    songsLoading.value = true;
    songRepo = SongRepo();
    await songRepo.initSongs();
    songs = await songRepo.getSongs();
    await Future.delayed(1.seconds);
    songsLoading.value = false;
  }

  @override
  void dispose() {
    tecSearch.dispose();
    super.dispose();
  }

  void onPressedCategoryCard(String category) async {
    tecSearch.text = category;
  }

  void onPressedSongCard(Song song) async {
    Get.toNamed(Routes.songDetail, arguments: song);
  }

  void onChangeSearchText(String text) async{
    songsLoading.value = true;
    songs = await songRepo.searchSong(text);
    // await Future.delayed(1.seconds);
    songsLoading.value = false;

  }
}
