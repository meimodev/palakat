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
        final code = exception.code;
        dev.log("[FIREBASE AUTH EXCEPTION] [verifyPhoneNumber()] "
            "code = $code message = ${exception.message}");

        onFailed(code);
      },
      codeAutoRetrievalTimeout: (String verificationID) {
        dev.log(
            "[FIREBASE AUTH] [success] OTP Sent Auto Retrieval timed out, manual verification");
        onManualCodeVerification(verificationID);
      },
      forceResendingToken: resendToken,
    );
  }

  Future<void> signInWithCredentialFromPhone({
    required String verificationId,
    required String smsCode,
    required void Function(String firebaseAuthExceptionCode) onFailed,
  }) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    try {
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      final code = e.code;
      dev.log("[FIREBASE AUTH EXCEPTION] [signInWithCredentialFromPhone()] "
          "code = $code message = ${e.message}");
      onFailed(code);
    }
  }
}
