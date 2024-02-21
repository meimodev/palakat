// import 'package:firebase_messaging/firebase_messaging.dart';
//
// class FCM {
//   static final _messaging = FirebaseMessaging.instance;
//
//   static Future init() async {
//     await requestFcmPermission();
//     // await _messaging.getInitialMessage();
//
//     // FirebaseMessaging.onBackgroundMessage(FCM.handleBackgroundMessage);
//   }
//
//   static Future<String> getToken() async {
//     return await _messaging.getToken() ?? '';
//   }
//
//   static Future<void> requestFcmPermission() async {
//     await _messaging.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );
//
//     await _messaging.setForegroundNotificationPresentationOptions(
//       alert: true, // Required to display a heads up notification
//       badge: true,
//       sound: true,
//     );
//
//     // We can use $settings.authorizationStatus to handle the authorization status
//     // There are 4 status from FCM :
//     // authorized, denied, notDetermined, and provisional
//   }
//
//   static Future<void> handleBackgroundMessage(RemoteMessage message) async {
//     print('Got a message whilst in the background!');
//     print('Message data: ${message.data}');
//
//     if (message.notification != null) {
//       print('Message also contained a notification: ${message.notification}');
//     }
//   }
// }
