import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:palakat/app/widgets/custom_simple_dialog.dart';
import 'package:palakat/data/models/user_app.dart';
import 'package:palakat/data/repos/user_repo.dart';
import 'package:palakat/shared/shared.dart';

class AccountController extends GetxController {
  final userRepo = Get.find<UserRepo>();

  final textEditingControllerName = TextEditingController();
  final textEditingControllerDob = TextEditingController();
  final textEditingControllerPhone = TextEditingController();

  UserApp? user;

  String maritalStatus = "";

  var loading = true.obs;


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

    maritalStatus = "Belum Menikah";
    final arguments = Get.arguments;

    if (arguments is String) {
      textEditingControllerPhone.text = arguments.cleanPhone(useCountryCode: true);
      loading.toggle();
      return;
    }
    user = arguments;

    maritalStatus = "Belum Menikah";
    if (user != null) {
    textEditingControllerName.text = user!.name;
      textEditingControllerDob.text = user!.dob.format(Values.dobPickerFormat);
      textEditingControllerPhone.text = user!.phone.cleanPhone(useCountryCode: true);
      maritalStatus = user!.maritalStatus;
    }
    loading.toggle();
  }

  Future<void> onPressedNextButton() async {
    // validate inputs
    final phone = textEditingControllerPhone.text;
    final name = textEditingControllerName.text;
    final dob = textEditingControllerDob.text;

    if (phone.isEmpty) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Heads up",
          description: "Phone cannot be empty",
        ),
      );
      return;
    }
    if (!phone.isNumericOnly) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Heads up",
          description: "Phone consist of number 0 - 9",
        ),
      );
      return;
    }
    if (!phone.startsWith("0")) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Heads up",
          description: "Phone start with 0",
        ),
      );
      return;
    }
    if (phone.length > 13 || phone.length < 12) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Heads up",
          description: "Phone number consist of 12 or 13 number",
        ),
      );
      return;
    }
    if (name.isEmpty) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Heads up",
          description: "Name cannot be empty",
        ),
      );
      return;
    }
    if (dob.isEmpty) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Heads up",
          description: "Date of birth cannot be empty",
        ),
      );
      return;
    }
    if (maritalStatus.isEmpty) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Heads up",
          description: "Select either one of the marital status",
        ),
      );
      return;
    }

    loading.value = true;
    //Edit user
    if (user != null ) {
      await _editUser();
      return;
    }

    //Create user
    await _createUser();
  }

  Future<void> _editUser() async {
    //check if a user data has been modified
    if (user!.phone == textEditingControllerPhone.text &&
        user!.name == textEditingControllerName.text &&
        user!.dob.format(Values.dobPickerFormat) ==
            textEditingControllerDob.text &&
        user!.maritalStatus == maritalStatus) {
      Get.toNamed(Routes.membership, arguments: user);
      return;
    }

    UserApp editedUser = user!.copyWith(
      phone: textEditingControllerPhone.text,
      name: textEditingControllerName.text,
      dob:
          Jiffy(textEditingControllerDob.text, Values.dobPickerFormat).dateTime,
      maritalStatus: maritalStatus,
    );
    await userRepo.updateUser(editedUser);
    user = editedUser;
    Get.toNamed(Routes.membership, arguments: user);
    loading.value = false;

  }

  Future<void> _createUser() async {
    UserApp newUser = await userRepo.createUser(
      dob:
          Jiffy(textEditingControllerDob.text, Values.dobPickerFormat).dateTime,
      phone: textEditingControllerPhone.text,
      name: textEditingControllerName.text,
      maritalStatus: maritalStatus,
    );
    user = newUser;
    Get.toNamed(Routes.membership, arguments: user);

    loading.value = false;
  }
}
