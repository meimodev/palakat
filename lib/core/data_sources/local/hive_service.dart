import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:developer' as dev;

import 'local.dart';

class HiveService {
  final userSource = Hive.box<String>(HiveKey.userBox);
  final authSource = Hive.box<String>(HiveKey.authBox);

  static Future<void> openAllBox() async {
    await Hive.initFlutter('cache');
    if (!Hive.isBoxOpen(HiveKey.userBox)) {
      await Hive.openLazyBox(HiveKey.userBox);
    }
    if (!Hive.isBoxOpen(HiveKey.authBox)) {
      await Hive.openLazyBox(HiveKey.authBox);
    }
  }

  static Future<void> hiveClose() async {
    await Hive.close();
  }

  AuthData? getAuth() {
    final auth = authSource.get(HiveKey.auth);

    if (auth == null) {
      dev.log("[HIVE SERVICE] access token not saved");
      return null;
    }

    return AuthData.fromJson(json.decode(auth));
  }

  Future saveAuth(AuthData value) async {
    await authSource.put(HiveKey.auth, json.encode(value.toJson()));
  }

  Future deleteAuth() async {
    await userSource.delete(HiveKey.auth);
  }
}

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});
