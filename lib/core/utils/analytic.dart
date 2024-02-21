// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:flutter/foundation.dart';
// import 'package:palakat/core/utils/utils.dart';
//
// class Analytic {
//   static final _analytics = FirebaseAnalytics.instance;
//
//   static Future init() async {
//     // Disable analytics for non-production environment
//     if (kDebugMode || F.flavor != Flavor.production) {
//       await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
//     }
//   }
//
//   static Future<void> logLogin({
//     required String loginMethod,
//   }) async {
//     await _analytics.logLogin(loginMethod: loginMethod);
//     await logGaEvent(
//       name: 'login',
//       parameters: {
//         'method': loginMethod,
//       },
//     );
//   }
//
//   static Future<void> logGaEvent({
//     required String name,
//     Map<String, Object?>? parameters,
//   }) async {
//     await _analytics.logEvent(
//       name: name,
//       parameters: parameters,
//     );
//   }
// }
