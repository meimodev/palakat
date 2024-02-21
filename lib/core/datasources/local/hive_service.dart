import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/data.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  final userSource = Hive.box<String>(HiveKey.userBox);
  final authSource = Hive.box<String>(HiveKey.authBox);
  final accountSettingSource = Hive.box<String>(HiveKey.accountSettingBox);
  final featureSetSource = Hive.box<String>(HiveKey.featureSetBox);
  final tutorialSetSource = Hive.box<bool>(HiveKey.tutorialSetBox);

  UserData? getUser() {
    final user = userSource.get(HiveKey.user);

    if (user == null) return null;

    return UserData.fromJson(
      json.decode(user),
    );
  }

  Future saveUser(UserData value) async {
    await userSource.put(
      HiveKey.user,
      json.encode(
        value.toJson(),
      ),
    );
  }

  Future deleteUser() async {
    await userSource.delete(
      HiveKey.user,
    );
  }

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

  AccountSettingData? getAccountSetting() {
    final accountSetting = accountSettingSource.get(HiveKey.accountSetting);

    if (accountSetting == null) return null;

    return AccountSettingData.fromJson(json.decode(accountSetting));
  }

  Future setAccountSetting(AccountSettingData value) async {
    await accountSettingSource.put(
      HiveKey.accountSetting,
      json.encode(
        value.toJson(),
      ),
    );
  }

  Future deleteAccountSetting() async {
    await accountSettingSource.delete(HiveKey.accountSetting);
  }

  // List<FeatureSetData> getFeatureSet() {
  //   final featureSet = featureSetSource.get(HiveKey.featureSet);
  //
  //   if (featureSet == null) return [];
  //
  //   return List.from(
  //     (json.decode(featureSet) as List).map(
  //       (e) => FeatureSetData.fromJson(e),
  //     ),
  //   );
  // }
  //
  // Future saveFeatureSet(List<FeatureSetData> value) async {
  //   await featureSetSource.put(
  //     HiveKey.featureSet,
  //     json.encode(
  //       value.map((e) => e.toJson()).toList(),
  //     ),
  //   );
  // }

  bool getTutorialStatus() {
    final tutorialSet = tutorialSetSource.get(HiveKey.tutorialSet);
    return tutorialSet ?? false;
  }

  Future<void> saveTutorialStatus(bool value) async {
    await tutorialSetSource.put(HiveKey.tutorialSet, value);
  }
}

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});
