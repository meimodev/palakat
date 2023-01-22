import 'package:get/get.dart';

import 'signing_controller.dart';

class SigningBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<SigningController>(SigningController());
  }
}
