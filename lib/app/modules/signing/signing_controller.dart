import 'package:get/get.dart';
import 'package:palakat/shared/shared.dart';

enum SigningState { enterPhone, enterCode }

class SigningController extends GetxController {
  var loading = true.obs;

  SigningState state = SigningState.enterPhone;

  RxString errorText = "".obs;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void onInit() {
    super.onInit();
    loading.toggle();

    // if (state == SigningState.enterPhone) {
    //   //show enter phone
    //   _showEnterPhone();
    //   //hide enter code
    //   return;
    // }

    // _showEnterCode();
  }

  void onPressedNext() async{

    loading.value = true;
    await Future.delayed(const Duration(seconds: 10));
    state = state == SigningState.enterPhone
        ? SigningState.enterCode
        : SigningState.enterPhone;

    if (state == SigningState.enterPhone) {
      final error = _validatePhone();
      if (error.isNotEmpty) {
        errorText.value = error;
        // request OTP code
        return;
      }
    }
    if (state == SigningState.enterCode) {
      final error = _validateCode();
      if (error.isNotEmpty) {
        errorText.value = error;
        // Verify OTP code
        return;
      }
    }
    loading.value = false;

  }

  String _validatePhone() {
    return "";
  }

  String _validateCode() {
    return "";
  }

  _showEnterPhone() {}

  _showEnterCode() {}
}
