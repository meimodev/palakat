import 'package:hive_flutter/hive_flutter.dart';

import '../models/activity_alarm_record.dart';

class ActivityAlarmRepository {
  static const String _boxName = 'activity_alarm';

  Future<Box> _box() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    }
    return Hive.openBox(_boxName);
  }

  String _enabledKey(int membershipId) => 'alarms.enabled.$membershipId';
  String _disabledActivitiesKey(int membershipId) =>
      'alarms.disabledActivities.$membershipId';
  String _scheduledKey(int membershipId) => 'alarms.scheduled.$membershipId';
  String _lastSyncKey(int membershipId) => 'alarms.lastSyncAt.$membershipId';

  Future<bool> isEnabled(int membershipId) async {
    final box = await _box();
    final value = box.get(_enabledKey(membershipId));
    if (value is bool) return value;
    return true;
  }

  Future<void> setEnabled(int membershipId, bool enabled) async {
    final box = await _box();
    await box.put(_enabledKey(membershipId), enabled);
  }

  Future<Set<int>> loadDisabledActivities(int membershipId) async {
    final box = await _box();
    final value = box.get(_disabledActivitiesKey(membershipId));
    if (value is List) {
      return value
          .map((e) => e is int ? e : int.tryParse(e.toString()))
          .whereType<int>()
          .toSet();
    }
    return <int>{};
  }

  Future<void> saveDisabledActivities(int membershipId, Set<int> ids) async {
    final box = await _box();
    await box.put(_disabledActivitiesKey(membershipId), ids.toList());
  }

  Future<Map<String, ActivityAlarmRecord>> loadScheduled(
    int membershipId,
  ) async {
    final box = await _box();
    final raw = box.get(_scheduledKey(membershipId));

    if (raw is! Map) return <String, ActivityAlarmRecord>{};

    final result = <String, ActivityAlarmRecord>{};
    raw.forEach((key, value) {
      if (key == null) return;
      final alarmKey = key.toString();
      if (value is Map) {
        final record = ActivityAlarmRecord.fromJson(
          Map<String, dynamic>.from(value),
        );
        if (record != null) {
          result[alarmKey] = record;
        }
      }
    });

    return result;
  }

  Future<void> saveScheduled(
    int membershipId,
    Map<String, ActivityAlarmRecord> scheduled,
  ) async {
    final box = await _box();
    final raw = <String, dynamic>{};
    for (final entry in scheduled.entries) {
      raw[entry.key] = entry.value.toJson();
    }
    await box.put(_scheduledKey(membershipId), raw);
  }

  Future<DateTime?> loadLastSyncAt(int membershipId) async {
    final box = await _box();
    final raw = box.get(_lastSyncKey(membershipId));
    if (raw is String && raw.trim().isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  Future<void> saveLastSyncAt(int membershipId, DateTime timeUtc) async {
    final box = await _box();
    await box.put(
      _lastSyncKey(membershipId),
      timeUtc.toUtc().toIso8601String(),
    );
  }
}
