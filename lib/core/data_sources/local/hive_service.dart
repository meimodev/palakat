import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:palakat/core/models/account.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:developer' as dev;

import 'local.dart';

part 'hive_service.g.dart';

@riverpod
class HiveService extends _$HiveService {
  @override
  HiveService build() {
    return HiveService();
  }

  Box<String> get _accountSource => Hive.box<String>(HiveKey.accountBox);
  Box<String> get _authSource => Hive.box<String>(HiveKey.authBox);

  AuthData? getAuth() {
    final auth = _authSource.get(HiveKey.auth);

    if (auth == null) {
      dev.log("[HIVE SERVICE] access token not saved");
      return null;
    }

    return AuthData.fromJson(json.decode(auth));
  }

  Future<void> saveAuth(AuthData value) async {
    await _authSource.put(HiveKey.auth, json.encode(value.toJson()));
  }

  Future<void> deleteAuth() async {
    await _authSource.delete(HiveKey.auth);
  }

  Account? getAccount() {
    final account = _accountSource.get(HiveKey.account);
    return account == null ? null : Account.fromJson(json.decode(account));
  }

  Future<void> saveAccount(Account account) async {
    await _accountSource.put(HiveKey.account, json.encode(account.toJson()));
  }

  Future<void> deleteAccount() async {
    await _accountSource.delete(HiveKey.account);
  }
}

Future<void> hiveInit() async {
  await Hive.initFlutter('cache');
  await Hive.openBox<String>(HiveKey.authBox);
  await Hive.openBox<String>(HiveKey.accountBox);
}

Future<void> hiveClose() async {
  await Hive.close();
}

class HiveKey {
  static const String accountBox = 'accountBox';
  static const String account = 'account';

  static const String authBox = 'authBox';
  static const String auth = 'auth';
}
