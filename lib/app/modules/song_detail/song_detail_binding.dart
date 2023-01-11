import 'package:get/get.dart';

import 'song_detail_controller.dart';

class SongDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<SongDetailController>(SongDetailController());
  }
}
