import 'package:get/get.dart';
import 'package:palakat/data/repos/church_repo.dart';

import 'membership_controller.dart';

class MembershipBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ChurchRepo>(ChurchRepo());
    Get.put<MembershipController>(MembershipController());
  }
}
