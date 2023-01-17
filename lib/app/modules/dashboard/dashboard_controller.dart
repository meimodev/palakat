import 'package:get/get.dart';
import 'package:palakat/data/models/model_mock.dart';
import 'package:palakat/data/models/user_app.dart';
import 'package:palakat/data/repos/user_repo.dart';

class DashboardController extends GetxController {
  UserApp? user;
  
  final userRepo = Get.find<UserRepo>();
  
  var isLoading = true.obs;
  var eventsThisWeek = ModelMock.events;

  @override
  void onInit() async {
    super.onInit();
    user = await userRepo.readUser("99XfAvEkRoobnrC4foJ2");
    isLoading.value = false;
  }
}
