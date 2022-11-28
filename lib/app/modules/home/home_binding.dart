import 'package:get/get.dart';
import 'package:palakat/app/modules/calendar/calendar_controller.dart';
import 'package:palakat/app/modules/dashboard/dashboard_controller.dart';
import 'package:palakat/app/modules/songs/songs_controller.dart';
import 'package:palakat/data/repos/user_repo.dart';

// import 'home_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<UserRepo>(UserRepo());
    Get.put<DashboardController>(DashboardController());
    Get.put<CalendarController>(CalendarController());
    Get.put<SongsController>(SongsController());
  }
}
