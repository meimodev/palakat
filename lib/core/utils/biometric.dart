// import 'dart:developer';
//
// import 'package:flutter/services.dart';
// import 'package:halo_hermina/core/localization/localization.dart';
// import 'package:local_auth/local_auth.dart';
//
// class Biometric {
//   static final LocalAuthentication auth = LocalAuthentication();
//   static final List<BiometricType> restrictedBiometric = [BiometricType.iris];
//
//   static String _getLocalizedReason(List<BiometricType> biometrics) {
//     if (!biometrics.contains(BiometricType.strong)) {
//       if (biometrics.contains(BiometricType.face)) {
//         return LocaleKeys.text_scanYourFaceIdToAuthenticate.tr();
//       } else if (biometrics.contains(BiometricType.fingerprint)) {
//         return LocaleKeys.text_scanYourFingerprintToAuthenticate.tr();
//       }
//     }
//     return LocaleKeys.text_scanYourBiometricToAuthenticate.tr();
//   }
//
//   static Future<List<BiometricType>> getAvailableBiometrics() async {
//     late List<BiometricType> availableBiometrics;
//     try {
//       availableBiometrics = await auth.getAvailableBiometrics();
//     } on PlatformException catch (e) {
//       availableBiometrics = <BiometricType>[];
//       log("Biometric error : $e");
//     }
//
//     return availableBiometrics
//         .where(
//           (element) => !restrictedBiometric.contains(element),
//         )
//         .toList();
//   }
//
//   static Future<bool> checkIfSupport() async {
//     bool deviceSupport = await auth.isDeviceSupported();
//
//     List<BiometricType> availableBiometrics = await getAvailableBiometrics();
//
//     return deviceSupport && availableBiometrics.isNotEmpty;
//   }
//
//   static Future<bool> authenticate() async {
//     List<BiometricType> availableBiometrics = await getAvailableBiometrics();
//
//     try {
//       bool authenticated = await auth.authenticate(
//         localizedReason: _getLocalizedReason(availableBiometrics),
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//         ),
//       );
//
//       return authenticated;
//     } on PlatformException catch (e) {
//       log("Biometric error : $e");
//       return false;
//     }
//   }
//
//   Future<bool> cancelAuthenticate() async {
//     return auth.stopAuthentication();
//   }
// }
