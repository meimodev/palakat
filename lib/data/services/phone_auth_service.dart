import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as dev;

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int? resendToken;

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String sentCode) onSuccessAuth,
    required void Function(String verificationID) onManualCodeVerification,
    required void Function(String firebaseAuthExceptionCode) onFailed,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 5),
      verificationCompleted: (PhoneAuthCredential credential) async {
        ///android only
        dev.log("[FIREBASE AUTH EXCEPTION] [success] OTP auto retrieved");
        await _auth.signInWithCredential(credential);
        onSuccessAuth(credential.smsCode!);
      },
      codeSent: (String verificationId, int? resendToken) async {
        dev.log("[FIREBASE AUTH] [success] OTP Sent");
        this.resendToken = resendToken;
      },
      verificationFailed: (FirebaseAuthException exception) {
        // log the failed code

        final code = exception.code;
        dev.log("[FIREBASE AUTH EXCEPTION] [error] "
            "code = $code message = ${exception.message}");
        //-- phone authentication specified error
        if (code == "invalid-verification-code" &&
            code == "invalid-verification-id") {
          onFailed(code);
          return;
        }
      },
      codeAutoRetrievalTimeout: (String verificationID) {
        dev.log("[FIREBASE AUTH] [success] OTP Sent Auto Retrieval timed out, manual verification");
        onManualCodeVerification(verificationID);
      },
      forceResendingToken: resendToken,
    );
  }

  Future<void> signInWithCredentialFromPhone(
    String verificationId,
    String smsCode,
  ) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    await _auth.signInWithCredential(credential);

  }
}
