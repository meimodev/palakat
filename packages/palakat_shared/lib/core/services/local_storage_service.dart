import 'dart:developer' as dev show log;
import 'dart:ui';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:palakat_shared/core/models/auth_response.dart';
import 'package:palakat_shared/core/models/auth_tokens.dart';
import 'package:palakat_shared/core/models/membership.dart';
import 'package:palakat_shared/core/models/notification_settings.dart';
import 'package:palakat_shared/core/models/permission_state.dart';
import 'package:palakat_shared/core/utils/locale_serializer.dart';

/// Auth persistence service backed by Hive. Stores the full AuthResponse
/// (tokens + account) as JSON, enabling session restore and account caching.
/// Also handles locale preference persistence, permission state, and notification settings.
class LocalStorageService {
  static const _kAuthBox = 'auth';
  static const _kAuthKey = 'auth.response';
  static const _kMembershipKey = 'membership';
  static const _kLocaleKey = 'app.locale';
  static const _kPermissionStateBox = 'permission_state';
  static const _kPermissionStateKey = 'permission_state';
  static const _kNotificationSettingsBox = 'notification_settings';
  static const _kNotificationSettingsKey = 'notification_settings';

  AuthResponse? _auth;
  Membership? _membership;
  Locale? _locale;
  PermissionStateModel? _permissionState;
  NotificationSettingsModel? _notificationSettings;

  // Consider presence of cached AuthResponse as logged-in state
  bool get isAuthenticated => _auth != null;
  String? get accessToken => _auth?.tokens.accessToken;
  String? get refreshToken => _auth?.tokens.refreshToken;
  DateTime? get expiresAt => _auth?.tokens.expiresAt;
  AuthResponse? get currentAuth => _auth;
  Membership? get currentMembership => _membership;
  Locale? get currentLocale => _locale;
  PermissionStateModel? get currentPermissionState => _permissionState;
  NotificationSettingsModel? get currentNotificationSettings =>
      _notificationSettings;

  Future<void> init() async {
    await _ensureBoxOpen();
    dev.log(
      'AuthService.init: loading cached auth from Hive',
      name: 'AuthService',
    );
    _loadFromBox();
    _loadMembershipFromBox();
  }

  /// Synchronously load cached auth when Hive box is already open.
  /// Use this during app startup after Hive.openBox('auth') to avoid races.
  void loadFromCacheSync() {
    if (!Hive.isBoxOpen(_kAuthBox)) return;
    _loadFromBox();
  }

  Future<void> saveAuth(AuthResponse auth) async {
    await _ensureBoxOpen();
    final box = Hive.box(_kAuthBox);
    _auth = auth;
    await box.put(_kAuthKey, auth.toJson());
    dev.log('AuthService.saveAuth: saved auth to Hive', name: 'AuthService');
  }

  Future<void> saveTokens(AuthTokens tokens) async {
    if (_auth == null) return; // Refresh should only occur when authed
    final updated = _auth!.copyWith(tokens: tokens);
    await saveAuth(updated);
  }

  Future<void> clear() async {
    await _ensureBoxOpen();
    final box = Hive.box(_kAuthBox);
    _auth = null;
    _membership = null;
    await box.delete(_kAuthKey);
    await box.delete(_kMembershipKey);
    dev.log(
      'LocalStorageService.clear: cleared all auth data from Hive',
      name: 'LocalStorageService',
    );
  }

  Future<void> saveMembership(Membership membership) async {
    await _ensureBoxOpen();
    final box = Hive.box(_kAuthBox);
    _membership = membership;
    await box.put(_kMembershipKey, membership.toJson());
    dev.log(
      'LocalStorageService.saveMembership: saved membership to Hive',
      name: 'LocalStorageService',
    );
  }

  Future<void> clearMembership() async {
    await _ensureBoxOpen();
    final box = Hive.box(_kAuthBox);
    _membership = null;
    await box.delete(_kMembershipKey);
    dev.log(
      'LocalStorageService.clearMembership: cleared membership from Hive',
      name: 'LocalStorageService',
    );
  }

  /// Save locale preference to Hive storage.
  ///
  /// Serializes the locale to a string representation and persists it.
  /// Requirements: 1.5, 5.4
  Future<void> saveLocale(Locale locale) async {
    await _ensureBoxOpen();
    final box = Hive.box(_kAuthBox);
    _locale = locale;
    final serialized = LocaleSerializer.serialize(locale);
    await box.put(_kLocaleKey, serialized);
    dev.log(
      'LocalStorageService.saveLocale: saved locale "$serialized" to Hive',
      name: 'LocalStorageService',
    );
  }

  /// Load saved locale preference from Hive storage.
  ///
  /// Returns null if no locale has been saved.
  /// Requirements: 1.6, 5.4
  Future<Locale?> loadLocale() async {
    await _ensureBoxOpen();
    _loadLocaleFromBox();
    return _locale;
  }

  /// Clear saved locale preference from Hive storage.
  Future<void> clearLocale() async {
    await _ensureBoxOpen();
    final box = Hive.box(_kAuthBox);
    _locale = null;
    await box.delete(_kLocaleKey);
    dev.log(
      'LocalStorageService.clearLocale: cleared locale from Hive',
      name: 'LocalStorageService',
    );
  }

  /// Save permission state to Hive storage.
  ///
  /// Requirements: 7.1, 7.2, 7.3
  Future<void> savePermissionState(PermissionStateModel state) async {
    await _ensurePermissionStateBoxOpen();
    final box = Hive.box(_kPermissionStateBox);
    _permissionState = state;
    await box.put(_kPermissionStateKey, state.toJson());
    dev.log(
      'LocalStorageService.savePermissionState: saved permission state to Hive',
      name: 'LocalStorageService',
    );
  }

  /// Load permission state from Hive storage.
  ///
  /// Returns null if no permission state has been saved.
  /// Requirements: 7.1, 7.2, 7.3
  Future<PermissionStateModel?> loadPermissionState() async {
    await _ensurePermissionStateBoxOpen();
    _loadPermissionStateFromBox();
    return _permissionState;
  }

  /// Clear permission state from Hive storage.
  Future<void> clearPermissionState() async {
    await _ensurePermissionStateBoxOpen();
    final box = Hive.box(_kPermissionStateBox);
    _permissionState = null;
    await box.delete(_kPermissionStateKey);
    dev.log(
      'LocalStorageService.clearPermissionState: cleared permission state from Hive',
      name: 'LocalStorageService',
    );
  }

  /// Save notification settings to Hive storage.
  Future<void> saveNotificationSettings(
    NotificationSettingsModel settings,
  ) async {
    await _ensureNotificationSettingsBoxOpen();
    final box = Hive.box(_kNotificationSettingsBox);
    _notificationSettings = settings;
    await box.put(_kNotificationSettingsKey, settings.toJson());
    dev.log(
      'LocalStorageService.saveNotificationSettings: saved notification settings to Hive',
      name: 'LocalStorageService',
    );
  }

  /// Load notification settings from Hive storage.
  ///
  /// Returns default settings if none have been saved.
  Future<NotificationSettingsModel> loadNotificationSettings() async {
    await _ensureNotificationSettingsBoxOpen();
    _loadNotificationSettingsFromBox();
    return _notificationSettings ?? const NotificationSettingsModel();
  }

  /// Clear notification settings from Hive storage.
  Future<void> clearNotificationSettings() async {
    await _ensureNotificationSettingsBoxOpen();
    final box = Hive.box(_kNotificationSettingsBox);
    _notificationSettings = null;
    await box.delete(_kNotificationSettingsKey);
    dev.log(
      'LocalStorageService.clearNotificationSettings: cleared notification settings from Hive',
      name: 'LocalStorageService',
    );
  }

  static Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox(_kAuthBox);
    await Hive.openBox(_kPermissionStateBox);
    await Hive.openBox(_kNotificationSettingsBox);
    dev.log(
      'LocalStorageService.initHive: Hive initialized and boxes opened',
      name: 'LocalStorageService',
    );
  }

  Future<void> _ensureBoxOpen() async {
    if (!Hive.isBoxOpen(_kAuthBox)) {
      await Hive.openBox(_kAuthBox);
    }
  }

  Future<void> _ensurePermissionStateBoxOpen() async {
    if (!Hive.isBoxOpen(_kPermissionStateBox)) {
      await Hive.openBox(_kPermissionStateBox);
    }
  }

  Future<void> _ensureNotificationSettingsBoxOpen() async {
    if (!Hive.isBoxOpen(_kNotificationSettingsBox)) {
      await Hive.openBox(_kNotificationSettingsBox);
    }
  }

  void _loadFromBox() {
    final box = Hive.box(_kAuthBox);
    final data = box.get(_kAuthKey);
    if (data is Map) {
      try {
        final normalized = _normalizeJson(data) as Map<String, dynamic>;
        _auth = AuthResponse.fromJson(normalized);
        dev.log('AuthService._loadFromBox: $_auth', name: 'AuthService');
      } catch (_) {
        _auth = null;
        dev.log(
          'AuthService._loadFromBox: failed to parse cached auth, ignoring',
          name: 'AuthService',
        );
      }
    }
  }

  void _loadMembershipFromBox() {
    final box = Hive.box(_kAuthBox);
    final data = box.get(_kMembershipKey);
    if (data is Map) {
      try {
        final normalized = _normalizeJson(data) as Map<String, dynamic>;
        _membership = Membership.fromJson(normalized);
        dev.log(
          'LocalStorageService._loadMembershipFromBox: $_membership',
          name: 'LocalStorageService',
        );
      } catch (_) {
        _membership = null;
        dev.log(
          'LocalStorageService._loadMembershipFromBox: failed to parse cached membership, ignoring',
          name: 'LocalStorageService',
        );
      }
    }
  }

  void _loadLocaleFromBox() {
    final box = Hive.box(_kAuthBox);
    final data = box.get(_kLocaleKey);
    if (data is String && data.isNotEmpty) {
      try {
        _locale = LocaleSerializer.deserialize(data);
        dev.log(
          'LocalStorageService._loadLocaleFromBox: loaded locale "${_locale?.languageCode}"',
          name: 'LocalStorageService',
        );
      } catch (_) {
        _locale = null;
        dev.log(
          'LocalStorageService._loadLocaleFromBox: failed to parse cached locale, ignoring',
          name: 'LocalStorageService',
        );
      }
    }
  }

  void _loadPermissionStateFromBox() {
    final box = Hive.box(_kPermissionStateBox);
    final data = box.get(_kPermissionStateKey);
    if (data is Map) {
      try {
        final normalized = _normalizeJson(data) as Map<String, dynamic>;
        _permissionState = PermissionStateModel.fromJson(normalized);
        dev.log(
          'LocalStorageService._loadPermissionStateFromBox: loaded permission state',
          name: 'LocalStorageService',
        );
      } catch (_) {
        _permissionState = null;
        dev.log(
          'LocalStorageService._loadPermissionStateFromBox: failed to parse cached permission state, ignoring',
          name: 'LocalStorageService',
        );
      }
    }
  }

  void _loadNotificationSettingsFromBox() {
    final box = Hive.box(_kNotificationSettingsBox);
    final data = box.get(_kNotificationSettingsKey);
    if (data is Map) {
      try {
        final normalized = _normalizeJson(data) as Map<String, dynamic>;
        _notificationSettings = NotificationSettingsModel.fromJson(normalized);
        dev.log(
          'LocalStorageService._loadNotificationSettingsFromBox: loaded notification settings',
          name: 'LocalStorageService',
        );
      } catch (_) {
        _notificationSettings = null;
        dev.log(
          'LocalStorageService._loadNotificationSettingsFromBox: failed to parse cached notification settings, ignoring',
          name: 'LocalStorageService',
        );
      }
    }
  }

  dynamic _normalizeJson(dynamic value) {
    if (value is Map) {
      final result = <String, dynamic>{};
      value.forEach((k, v) {
        result[k.toString()] = _normalizeJson(v);
      });
      return result;
    } else if (value is List) {
      return value.map(_normalizeJson).toList();
    }
    return value;
  }
}
