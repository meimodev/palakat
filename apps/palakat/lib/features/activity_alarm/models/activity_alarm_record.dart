class ActivityAlarmRecord {
  const ActivityAlarmRecord({
    required this.alarmKey,
    required this.notificationId,
    required this.activityId,
    required this.reminderValue,
    required this.activityDateUtcIso,
    required this.alarmAtUtcIso,
    required this.scheduledAtUtcIso,
    required this.title,
  });

  final String alarmKey;
  final int notificationId;
  final int activityId;
  final String reminderValue;
  final String activityDateUtcIso;
  final String alarmAtUtcIso;
  final String scheduledAtUtcIso;
  final String title;

  DateTime? get alarmAtUtc => DateTime.tryParse(alarmAtUtcIso)?.toUtc();

  Map<String, dynamic> toJson() {
    return {
      'alarmKey': alarmKey,
      'notificationId': notificationId,
      'activityId': activityId,
      'reminderValue': reminderValue,
      'activityDateUtcIso': activityDateUtcIso,
      'alarmAtUtcIso': alarmAtUtcIso,
      'scheduledAtUtcIso': scheduledAtUtcIso,
      'title': title,
    };
  }

  static ActivityAlarmRecord? fromJson(Map<String, dynamic> json) {
    final alarmKey = json['alarmKey']?.toString();
    final notificationIdRaw = json['notificationId'];
    final activityIdRaw = json['activityId'];
    final reminderValue = json['reminderValue']?.toString();
    final activityDateUtcIso = json['activityDateUtcIso']?.toString();
    final alarmAtUtcIso = json['alarmAtUtcIso']?.toString();
    final scheduledAtUtcIso = json['scheduledAtUtcIso']?.toString();
    final title = json['title']?.toString() ?? 'Activity';

    final notificationId = notificationIdRaw is int
        ? notificationIdRaw
        : int.tryParse(notificationIdRaw?.toString() ?? '');
    final activityId = activityIdRaw is int
        ? activityIdRaw
        : int.tryParse(activityIdRaw?.toString() ?? '');

    if (alarmKey == null ||
        alarmKey.isEmpty ||
        notificationId == null ||
        activityId == null ||
        reminderValue == null ||
        reminderValue.isEmpty ||
        activityDateUtcIso == null ||
        activityDateUtcIso.isEmpty ||
        alarmAtUtcIso == null ||
        alarmAtUtcIso.isEmpty ||
        scheduledAtUtcIso == null ||
        scheduledAtUtcIso.isEmpty) {
      return null;
    }

    return ActivityAlarmRecord(
      alarmKey: alarmKey,
      notificationId: notificationId,
      activityId: activityId,
      reminderValue: reminderValue,
      activityDateUtcIso: activityDateUtcIso,
      alarmAtUtcIso: alarmAtUtcIso,
      scheduledAtUtcIso: scheduledAtUtcIso,
      title: title,
    );
  }
}
