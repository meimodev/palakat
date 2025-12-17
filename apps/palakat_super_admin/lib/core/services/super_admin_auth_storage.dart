import 'package:hive/hive.dart';

class SuperAdminAuthStorage {
  static const String boxName = 'super_admin_auth';
  static const String _kAccessToken = 'access_token';

  static Future<void> ensureBoxOpen() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  Box get _box => Hive.box(boxName);

  String? get accessToken => _box.get(_kAccessToken) as String?;

  bool get isAuthenticated =>
      accessToken != null && (accessToken ?? '').trim().isNotEmpty;

  Future<void> saveAccessToken(String token) async {
    await ensureBoxOpen();
    await _box.put(_kAccessToken, token);
  }

  Future<void> clear() async {
    await ensureBoxOpen();
    await _box.delete(_kAccessToken);
  }
}
