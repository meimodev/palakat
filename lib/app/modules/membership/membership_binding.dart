import 'package:get/get.dart';

import 'membership_controller.dart';

class MembershipBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MembershipController>(MembershipController());
  }
}
