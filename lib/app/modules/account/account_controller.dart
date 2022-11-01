import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palakat/data/models/user.dart';

class AccountController extends GetxController {

  var textEditingControllerName = TextEditingController();
  var textEditingControllerDob = TextEditingController();
  var textEditingControllerPhone = TextEditingController();
  var textEditingControllerColumn = TextEditingController();
  var textEditingControllerChurchName = TextEditingController();
  var textEditingControllerChurchLocation = TextEditingController();

  User? user;

  @override
  void dispose() {
    textEditingControllerName.dispose();
    textEditingControllerDob.dispose();
    textEditingControllerPhone.dispose();
    textEditingControllerColumn.dispose();
    textEditingControllerChurchName.dispose();
    textEditingControllerChurchLocation.dispose();
    super.dispose();
  }

  @override
  void onInit() {
    super.onInit();
    if (user != null) {
      textEditingControllerName.text = user!.name;
      textEditingControllerDob.text = user!.dob;
      textEditingControllerPhone.text = user!.phone;
      textEditingControllerColumn.text = user!.column;
      textEditingControllerChurchName.text = user!.church.name;
      textEditingControllerChurchLocation.text = user!.church.location;
    }
  }

}