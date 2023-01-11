import 'package:get/get.dart';
import 'package:palakat/data/models/song.dart';

class SongDetailController extends GetxController {

  Song? song ;



  @override
  void onInit() {
    super.onInit();
    song = Get.arguments as Song;

  }

}
