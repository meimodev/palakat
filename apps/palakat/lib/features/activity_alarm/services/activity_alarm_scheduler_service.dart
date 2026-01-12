import 'dart:io';

import 'package:palakat/core/constants/notification_channels.dart';
import 'package:palakat/core/models/notification_payload.dart';
import 'package:palakat/core/services/notification_display_service.dart';
import 'package:palakat/core/services/timezone_service.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/models.dart';

import '../models/activity_alarm_record.dart';
import 'activity_alarm_repository.dart';

class ActivityAlarmSyncResult {
  const ActivityAlarmSyncResult({
    required this.scheduledCount,
    required this.cancelledCount,
    required this.totalDesiredCount,
  });

  final int scheduledCount;
  final int cancelledCount;
  final int totalDesiredCount;
}

class ActivityAlarmSchedulerService {
  ActivityAlarmSchedulerService({
    required NotificationDisplayService display,
    ActivityAlarmRepository? repository,
  }) : _display = display,
       _repo = repository ?? ActivityAlarmRepository();

  final NotificationDisplayService _display;
  final ActivityAlarmRepository _repo;

  Future<bool> isEnabled(int membershipId) => _repo.isEnabled(membershipId);

  Future<int> loadScheduledCount(int membershipId) async {
    final nowUtc = DateTime.now().toUtc();
    final scheduled = await _repo.loadScheduled(membershipId);

    var changed = false;
    var count = 0;

    for (final entry in scheduled.entries) {
      final alarmAtUtc = DateTime.tryParse(entry.value.alarmAtUtcIso)?.toUtc();
      if (alarmAtUtc == null) {
        changed = true;
        continue;
      }

      if (alarmAtUtc.isAfter(nowUtc)) {
        count++;
      } else {
        changed = true;
      }
    }

    if (changed) {
      final next = <String, ActivityAlarmRecord>{};
      for (final entry in scheduled.entries) {
        final alarmAtUtc = DateTime.tryParse(
          entry.value.alarmAtUtcIso,
        )?.toUtc();
        if (alarmAtUtc != null && alarmAtUtc.isAfter(nowUtc)) {
          next[entry.key] = entry.value;
        }
      }
      await _repo.saveScheduled(membershipId, next);
    }

    return count;
  }

  Future<void> setEnabled(int membershipId, bool enabled) async {
    await _repo.setEnabled(membershipId, enabled);
    if (!enabled) {
      await cancelAllForMembership(membershipId);
    }
  }

  Future<Set<int>> loadDisabledActivities(int membershipId) {
    return _repo.loadDisabledActivities(membershipId);
  }

  Future<void> setActivityEnabled(
    int membershipId,
    int activityId,
    bool enabled,
  ) async {
    final disabled = await _repo.loadDisabledActivities(membershipId);
    if (enabled) {
      disabled.remove(activityId);
    } else {
      disabled.add(activityId);
    }
    await _repo.saveDisabledActivities(membershipId, disabled);

    final scheduled = await _repo.loadScheduled(membershipId);
    final toRemove = <String>[];
    for (final entry in scheduled.entries) {
      if (entry.value.activityId == activityId) {
        await _display.cancelNotification(entry.value.notificationId);
        toRemove.add(entry.key);
      }
    }
    for (final key in toRemove) {
      scheduled.remove(key);
    }
    await _repo.saveScheduled(membershipId, scheduled);
  }

  Future<ActivityAlarmSyncResult> syncWeekAlarms({
    required int membershipId,
    required List<Activity> activities,
  }) async {
    await TimeZoneService.initialize();

    final nowUtc = DateTime.now().toUtc();
    final nowLocal = DateTime.now();
    final enabled = await _repo.isEnabled(membershipId);

    if (!enabled) {
      final cancelled = await cancelAllForMembership(membershipId);
      await _repo.saveLastSyncAt(membershipId, nowUtc);
      return ActivityAlarmSyncResult(
        scheduledCount: 0,
        cancelledCount: cancelled,
        totalDesiredCount: 0,
      );
    }

    final disabledActivities = await _repo.loadDisabledActivities(membershipId);
    final existing = await _repo.loadScheduled(membershipId);

    final desired = <String, ActivityAlarmRecord>{};

    for (final activity in activities) {
      final id = activity.id;
      if (id == null) continue;

      if (activity.activityType != ActivityType.event &&
          activity.activityType != ActivityType.service) {
        continue;
      }

      final reminder = activity.reminder;
      if (reminder == null) continue;

      if (disabledActivities.contains(id)) continue;

      final activityDateLocal = activity.date.toLocal();
      final alarmAtLocal = activityDateLocal.subtract(
        _offsetForReminder(reminder),
      );
      if (!alarmAtLocal.isAfter(nowLocal)) continue;

      final activityDateUtc = activityDateLocal.toUtc();
      final alarmAtUtc = alarmAtLocal.toUtc();

      final alarmKey = _alarmKey(activityId: id, reminderValue: reminder.value);
      final notificationId = _notificationId(alarmKey);

      desired[alarmKey] = ActivityAlarmRecord(
        alarmKey: alarmKey,
        notificationId: notificationId,
        activityId: id,
        reminderValue: reminder.value,
        activityDateUtcIso: activityDateUtc.toIso8601String(),
        alarmAtUtcIso: alarmAtUtc.toIso8601String(),
        scheduledAtUtcIso: nowUtc.toIso8601String(),
        title: activity.title,
      );
    }

    var scheduledCount = 0;
    var cancelledCount = 0;

    for (final existingEntry in existing.entries) {
      if (!desired.containsKey(existingEntry.key)) {
        await _display.cancelNotification(existingEntry.value.notificationId);
        cancelledCount++;
      }
    }

    final nextScheduled = <String, ActivityAlarmRecord>{};

    for (final entry in desired.entries) {
      final existingRecord = existing[entry.key];
      final desiredRecord = entry.value;

      final shouldReschedule =
          existingRecord == null ||
          existingRecord.alarmAtUtcIso != desiredRecord.alarmAtUtcIso ||
          existingRecord.reminderValue != desiredRecord.reminderValue;

      if (shouldReschedule) {
        if (existingRecord != null) {
          await _display.cancelNotification(existingRecord.notificationId);
          cancelledCount++;
        }

        final alarmAtUtc = DateTime.tryParse(
          desiredRecord.alarmAtUtcIso,
        )?.toUtc();
        if (alarmAtUtc != null) {
          final scheduledAt = alarmAtUtc.toLocal();

          await _display.scheduleNotification(
            payload: NotificationPayload(
              title: desiredRecord.title,
              body: desiredRecord.reminderValue,
              data: {
                'type': 'ACTIVITY_ALARM',
                'activityId': desiredRecord.activityId.toString(),
                'alarmKey': desiredRecord.alarmKey,
                'title': desiredRecord.title,
                'reminderName': _reminderNameForValue(
                  desiredRecord.reminderValue,
                ),
                'reminderValue': desiredRecord.reminderValue,
                'notificationId': desiredRecord.notificationId.toString(),
              },
            ),
            channelId: NotificationChannels.activityAlarms.id,
            scheduledAt: scheduledAt,
            id: desiredRecord.notificationId,
            fullScreenIntent: Platform.isAndroid,
          );

          scheduledCount++;
        }
      }

      nextScheduled[entry.key] = desiredRecord;
    }

    await _repo.saveScheduled(membershipId, nextScheduled);
    await _repo.saveLastSyncAt(membershipId, nowUtc);

    return ActivityAlarmSyncResult(
      scheduledCount: scheduledCount,
      cancelledCount: cancelledCount,
      totalDesiredCount: desired.length,
    );
  }

  Future<int> cancelAllForMembership(int membershipId) async {
    final existing = await _repo.loadScheduled(membershipId);
    var cancelledCount = 0;

    for (final entry in existing.entries) {
      await _display.cancelNotification(entry.value.notificationId);
      cancelledCount++;
    }

    await _repo.saveScheduled(membershipId, <String, ActivityAlarmRecord>{});
    return cancelledCount;
  }

  Duration _offsetForReminder(Reminder reminder) {
    switch (reminder) {
      case Reminder.tenMinutes:
        return const Duration(minutes: 10);
      case Reminder.thirtyMinutes:
        return const Duration(minutes: 30);
      case Reminder.oneHour:
        return const Duration(hours: 1);
      case Reminder.twoHour:
        return const Duration(hours: 2);
    }
  }

  String _alarmKey({required int activityId, required String reminderValue}) {
    return 'activity:$activityId:reminder:$reminderValue';
  }

  int _notificationId(String alarmKey) {
    var hash = 0x811c9dc5;
    for (final codeUnit in alarmKey.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }

  String _reminderNameForValue(String reminderValue) {
    for (final r in Reminder.values) {
      if (r.value == reminderValue) return r.name;
    }
    return reminderValue;
  }
}
