import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:palakat/core/models/account.dart';
import 'package:palakat/core/models/membership.dart';
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

  Box<String> get _membershipSource => Hive.box<String>(HiveKey.membershipBox);

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
    dev.log("[HIVE SERVICE] get saved account $account");
    return account == null ? null : Account.fromJson(json.decode(account));
  }

  Future<void> saveAccount(Account account) async {
    await _accountSource.put(HiveKey.account, json.encode(account.toJson()));
    dev.log("[HIVE SERVICE] account saved $account");
  }

  Future<void> deleteAccount() async {
    await _accountSource.delete(HiveKey.account);
  }

  Membership? getMembership() {
    final membership = _membershipSource.get(HiveKey.membership);
    dev.log("[HIVE SERVICE] get saved membership $membership");
    return membership == null
        ? null
        : Membership.fromJson(json.decode(membership));
  }

  Future<void> saveMembership(Membership membership) async {
    await _membershipSource.put(
      HiveKey.membership,
      json.encode(membership.toJson()),
    );
    dev.log("[HIVE SERVICE] membership saved $membership");
  }

  Future<void> deleteMembership() async {
    await _membershipSource.delete(HiveKey.membership);
  }
}

Future<void> hiveInit() async {
  await Hive.initFlutter('cache');
  await Hive.openBox<String>(HiveKey.authBox);
  await Hive.openBox<String>(HiveKey.accountBox);
  await Hive.openBox<String>(HiveKey.membershipBox);
}

Future<void> hiveClose() async {
  await Hive.close();
}

class HiveKey {
  static const String accountBox = 'accountBox';
  static const String account = 'account';

  static const String authBox = 'authBox';
  static const String auth = 'auth';

  static const String membershipBox = 'membershipBox';
  static const String membership = 'membership';
}
