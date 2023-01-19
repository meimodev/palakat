import 'package:get/get.dart';
import 'package:palakat/data/models/event.dart';
import 'package:palakat/data/models/user_app.dart';
import 'package:palakat/data/repos/event_repo.dart';
import 'package:palakat/data/repos/user_repo.dart';
import 'package:palakat/shared/shared.dart';

class DashboardController extends GetxController {
  UserApp? user;

  final userRepo = Get.find<UserRepo>();
  final eventRepo = Get.find<EventRepo>();

  var isLoading = true.obs;
  var eventsThisWeek = <Event>[];

  @override
  void onInit() async {
    super.onInit();
    user = await userRepo.readUser("99XfAvEkRoobnrC4foJ2");
    eventsThisWeek =
        await eventRepo.readEventsThisWeek(user!.membership!.churchId);

    isLoading.value = false;
  }

  void onUpdateUserInfo(UserApp user){
    isLoading.value = true;
    this.user = user;
    isLoading.value = false;
  }

  void onTapAccountCard() {
    Get.toNamed(Routes.account, arguments: user);
  }
}
