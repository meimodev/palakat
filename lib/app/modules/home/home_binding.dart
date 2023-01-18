import 'package:get/get.dart';
import 'package:palakat/app/modules/calendar/calendar_controller.dart';
import 'package:palakat/app/modules/dashboard/dashboard_controller.dart';
import 'package:palakat/app/modules/songs/songs_controller.dart';
import 'package:palakat/data/repos/event_repo.dart';
import 'package:palakat/data/repos/user_repo.dart';


class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<UserRepo>(UserRepo());
    Get.put<EventRepo>(EventRepo());
    Get.put<DashboardController>(DashboardController());
    Get.put<CalendarController>(CalendarController());
    Get.put<SongsController>(SongsController());
  }
}
