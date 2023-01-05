import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palakat/app/widgets/custom_simple_dialog.dart';
import 'package:palakat/data/models/user.dart';
import 'package:palakat/shared/routes.dart';

class AccountController extends GetxController {
  final textEditingControllerName = TextEditingController();
  final textEditingControllerDob = TextEditingController();
  final textEditingControllerPhone = TextEditingController();

  User? user;

  String maritalStatus = "";

  @override
  void dispose() {
    textEditingControllerName.dispose();
    textEditingControllerDob.dispose();
    textEditingControllerPhone.dispose();
    super.dispose();
  }

  @override
  void onInit() {
    super.onInit();
    //get user data through local storage
    maritalStatus = "Belum Menikah";
    if (user != null) {
      textEditingControllerName.text = user!.name;
      textEditingControllerDob.text = user!.dob;
      textEditingControllerPhone.text = user!.phone;
      maritalStatus = user!.maritalStatus;
    }
  }

  void onPressedNextButton() {
    // validate inputs
    final phone = textEditingControllerPhone.text;
    final name = textEditingControllerName.text;
    final dob = textEditingControllerDob.text;

    if (phone.isEmpty) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Warning",
          description: "Phone cannot be empty",
        ),
      );
      return;
    }
    if (!phone.isNumericOnly) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Warning",
          description: "Phone consist of number 0 - 9",
        ),
      );
      return;

    }
    if (!phone.startsWith("0")) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Warning",
          description: "Phone start with 0",
        ),
      );
      return;
    }
    if (phone.length > 13 || phone.length < 12) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Warning",
          description: "Phone number consist of 12 or 13 number",
        ),
      );
      return;
    }
    if (name.isEmpty) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Warning",
          description: "Name cannot be empty",
        ),
      );
      return;
    }
    if (dob.isEmpty) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Warning",
          description: "Date of birth cannot be empty",
        ),
      );
      return;
    }
    if (maritalStatus.isEmpty) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Warning",
          description: "Select either one of the marital status",
        ),
      );
      return;
    }

    Get.toNamed(Routes.membership);
    // print("phone $phone name $name dob $dob married $maritalStatus");
  }
}
