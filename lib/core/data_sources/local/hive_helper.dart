import 'package:palakat/core/constants/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> hiveInit() async {
  await Hive.initFlutter('cache');
  await Hive.openBox<String>(HiveKey.authBox);
  await Hive.openBox<String>(HiveKey.userBox);
  await Hive.openBox<String>(HiveKey.accountSettingBox);
  await Hive.openBox<String>(HiveKey.featureSetBox);
  await Hive.openBox<bool>(HiveKey.tutorialSetBox);
}

Future<void> hiveClose() async {
  await Hive.close();
}
