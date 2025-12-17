import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseBootstrap {
  static bool get isConfigured {
    final apiKey = dotenv.env['FIREBASE_API_KEY'];
    final authDomain = dotenv.env['FIREBASE_AUTH_DOMAIN'];
    final projectId = dotenv.env['FIREBASE_PROJECT_ID'];
    final storageBucket = dotenv.env['FIREBASE_STORAGE_BUCKET'];
    final messagingSenderId = dotenv.env['FIREBASE_MESSAGING_SENDER_ID'];
    final appId = dotenv.env['FIREBASE_APP_ID'];

    return [
      apiKey,
      authDomain,
      projectId,
      storageBucket,
      messagingSenderId,
      appId,
    ].every((v) => v != null && v.trim().isNotEmpty);
  }

  static Future<void> initIfConfigured() async {
    if (!isConfigured) {
      return;
    }

    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY']!,
        authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN']!,
        projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
        appId: dotenv.env['FIREBASE_APP_ID']!,
      ),
    );

    if (kDebugMode) {
      debugPrint('Firebase initialized for Super Admin');
    }
  }
}
