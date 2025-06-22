import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/data.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  final userSource = Hive.box<String>(HiveKey.userBox);
  final authSource = Hive.box<String>(HiveKey.authBox);


  AuthData? getAuth() {
    final auth = authSource.get(HiveKey.auth);

    if (auth == null) return null;

    return AuthData.fromJson(
      json.decode(auth),
    );
  }

  Future saveAuth(AuthData value) async {
    await authSource.put(
      HiveKey.auth,
      json.encode(
        value.toJson(),
      ),
    );
  }

  Future deleteAuth() async {
    await userSource.delete(
      HiveKey.auth,
    );
  }




}

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});
