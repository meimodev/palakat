import 'package:get/get.dart';
import 'package:palakat/data/repos/user_repo.dart';

import 'signing_controller.dart';

class SigningBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<UserRepo>(UserRepo());
    Get.put<SigningController>(SigningController());
  }
}
