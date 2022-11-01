import 'package:get/get.dart';

import 'account_controller.dart';

class AccountBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<AccountController>(AccountController());
  }
}
