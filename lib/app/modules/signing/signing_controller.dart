import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:palakat/data/models/user_app.dart';
import 'package:palakat/data/repos/user_repo.dart';
import 'package:palakat/data/services/phone_auth_service.dart';
import 'package:palakat/shared/shared.dart';
import 'package:rive/rive.dart';
import 'dart:developer' as dev;

enum SigningState { enterPhone, enterCode }

class SigningController extends GetxController {
  final UserRepo userRepo = Get.find<UserRepo>();

  var loading = true.obs;

  SigningState state = SigningState.enterPhone;

  RxString errorText = "".obs;

  final TextEditingController tecPhone = TextEditingController();
  final TextEditingController tecCode = TextEditingController();

  ///tight coupling implementation, fix this later!
  SMITrigger? showBall;
  SMIBool? loadingBall;

  ///tight coupling implementation, fix this later!
  final phoneAuthService = PhoneAuthService();

  @override
  void onReady() {
    super.onReady();

    //check whether the user already signed in then proceed straight to home
    final currentUser = userRepo.auth.currentUser;
    if (currentUser != null) {
      Get.offAndToNamed(Routes.home);
      return;
    }
    dev.log("[NO USER SIGNED IN]");

    loading.toggle();
  }

  void _startLoading() {
    //loading true
    loading.value = true;
    loadingBall?.value = true;

    //trigger show
    showBall?.fire();
  }

  void _endLoading() {
    loadingBall?.value = false;
    loading.value = false;
  }

  void onPressedNext() async {
    errorText.value = "";

    if (state == SigningState.enterPhone) {
      print("$state phone ${tecPhone.text}");
      final error = _validatePhone(tecPhone.text);
      if (error.isNotEmpty) {
        print(error);
        errorText.value = error;
        _endLoading();
        return;
      }
      _startLoading();
      await Future.delayed(const Duration(seconds: 3));
      _phoneVerification();
    }
    if (state == SigningState.enterCode) {
      final error = _validateCode(tecCode.text);
      if (error.isNotEmpty) {
        errorText.value = error;
        return;
      }
      // Verify OTP code
      _startLoading();
      await Future.delayed(const Duration(seconds: 3));
      _phoneAuthWithOtp();
    }
  }

  String _validatePhone(String phone) {
    phone.cleanPhone(withCountryCode: true);

    if (phone.isEmpty) {
      return "Phone cannot be empty";
    }

    if (!phone.startsWith("0")) {
      return "Phone start with 0";
    }
    if (phone.length < 12 || phone.length > 13) {
      return "Phone consist of 12 - 13 number";
    }

    return "";
  }

  String _validateCode(String code) {
    if (code.isEmpty) {
      return "OTP Code cannot be empty";
    }

    if (!code.isNumericOnly) {
      return "Code only contain number";
    }
    if (code.length != 6) {
      return "Phone consist of 6 digit number";
    }

    return "";
  }

  void onInitLoading(SMIBool loading, SMITrigger show) {
    showBall = show;
    loadingBall = loading;
  }

  void _phoneAuthWithOtp() async {
    final code = tecCode.text;
    await userRepo.signInWithCredential(code);
  }

  void _phoneVerification() async {
    final phoneNumber = tecPhone.text;
    await userRepo.verifyPhoneNumber(
      phoneNumber: phoneNumber.cleanPhone(withCountryCode: true),
      onProceed: _onProceed,
      onRegister: _onRegister,
      onManualCodeVerification: () async {
        state = SigningState.enterCode;
        _endLoading();
      },
      onFailed: _onFailed,
    );
  }

  _onProceed(UserApp user) {
    Get.offAndToNamed(Routes.home);
  }

  _onRegister(String phone, String userId) {
    final user = UserApp(
      id: userId,
      dob: DateTime.now(),
      phone: phone,
      name: "",
      maritalStatus: "Belum Menikah",
    );
    Get.offAndToNamed(Routes.account, arguments: user);
  }

  _onFailed(String firebaseAuthExceptionCode) {
    errorText.value = firebaseAuthExceptionCode;
    _endLoading();
  }
}
