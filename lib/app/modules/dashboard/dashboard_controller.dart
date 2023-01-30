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

    final phone = userRepo.auth.currentUser?.phoneNumber ?? "";

    user = await userRepo.readUser(phone);
    eventsThisWeek =
    await eventRepo.readEventsThisWeek(user!.membership!.churchId);

    isLoading.value = false;
  }

  void onUpdateUserInfo(UserApp user) async {
    isLoading.value = true;
    this.user = await userRepo.readUser(user.id!);
    isLoading.value = false;
  }

  void onTapAccountCard() {
    Get.toNamed(Routes.account, arguments: user);
  }

  void onPressedSignOutButton() {
    userRepo.signOut();
    Future.delayed(Duration.zero).then((value) =>
        Get.offAndToNamed(Routes.signing)
    );
  }
}
