import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:developer' as dev;

import 'local.dart';

part 'hive_service.g.dart';


@riverpod
class HiveService extends _$HiveService{
  @override
  HiveService build() {
    return HiveService();
  }

   // Box<String> get _userSource => Hive.box<String>(HiveKey.userBox);
   Box<String> get _authSource => Hive.box<String>(HiveKey.authBox);

  AuthData? getAuth() {
    final auth = _authSource.get(HiveKey.auth);

    if (auth == null) {
      dev.log("[HIVE SERVICE] access token not saved");
      return null;
    }

    return AuthData.fromJson(json.decode(auth));
  }

  Future saveAuth(AuthData value) async {
    await _authSource.put(HiveKey.auth, json.encode(value.toJson()));
  }

  Future deleteAuth() async {
    await _authSource.delete(HiveKey.auth);
  }
}

Future<void> hiveInit() async {
  await Hive.initFlutter('cache');
  await Hive.openBox<String>(HiveKey.authBox);
  await Hive.openBox<String>(HiveKey.userBox);
}

Future<void> hiveClose() async {
  await Hive.close();
}

class HiveKey {
  static const String userBox = 'userBox';
  static const String user = 'user';

  static const String authBox = 'authBox';
  static const String auth = 'auth';

}


//
// final hiveServiceProvider = Provider<HiveService>((ref) {
//   return HiveService();
// });
//
