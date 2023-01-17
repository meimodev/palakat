import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palakat/app/widgets/custom_simple_dialog.dart';
import 'package:palakat/data/models/church.dart';
import 'package:palakat/data/models/user_app.dart';
import 'package:palakat/shared/routes.dart';

class MembershipController extends GetxController {
  final textEditingControllerChurch = TextEditingController();
  final textEditingControllerColumn = TextEditingController();

  UserApp? user;
  String baptizeStatus = "";
  String sidiStatus = "";
  Church? selectedChurch;

  @override
  void dispose() {
    textEditingControllerChurch.dispose();
    textEditingControllerColumn.dispose();
    super.dispose();
  }

  @override
  void onInit() {
    super.onInit();
    //TODO get user data through local storage & assign to user

    baptizeStatus = "Belum Baptis";
    sidiStatus = "Belum Sidi";

    if (user != null) {
      selectedChurch = user!.membership!.church;
      textEditingControllerColumn.text = user!.membership!.column;
      if(user!.membership!.baptize){
        baptizeStatus = "Baptis";
      }
      if(user!.membership!.sidi){
        baptizeStatus = "Sidi";
      }
    }
  }

  void onPressedNextButton() {
    // validate inputs
    if (selectedChurch == null) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Warning",
          description: "Church is not selected yet",
        ),
      );
    }

    final column = textEditingControllerColumn.text;

    if (column.isEmpty) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Warning",
          description: "Column cannot be empty",
        ),
      );
      return;
    }
    if (!column.isNumericOnly) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Warning",
          description: "Column consist of number 0 - 9",
        ),
      );
      return;
    }

    if (column.startsWith("0")) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Warning",
          description: "Column number consist only 1 - 99",
        ),
      );
      return;
    }

    if (column.length > 2) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Warning",
          description: "Column number consist only 1 - 99",
        ),
      );
      return;
    }

    Get.offNamedUntil(Routes.home, (route) => route.settings.name == Routes.home);
  }

  void onSelectChurch(Church church) {
    selectedChurch = church;
    textEditingControllerChurch.text = "${selectedChurch!.name}, ${selectedChurch!.location}";
    print(church.toString());
  }
}
