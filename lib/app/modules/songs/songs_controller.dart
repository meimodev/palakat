import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palakat/data/models/song.dart';
import 'package:palakat/data/repos/song_repo.dart';
import 'package:palakat/shared/routes.dart';

class SongsController extends GetxController {
  final tecSearch = TextEditingController();

  final List<String> songBooks = [
    "Nanyikanlah Nyanyian Baru Bagi TUHAN",
    "Kidung Jemaat",
    "Nyanyikanlah Kidung Baru",
    "Dua Sahabat Lama",
  ];

  final List<String> searchHints = [
    "KJ 234",
    "Kami Puji Dengan Riang",
    "Kidung Jemaat 301",
    "KJ56",
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
    songsLoading.value = true;
    songs = await songRepo.searchSong(category);
    tecSearch.text = category;
    songsLoading.value = false;

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
