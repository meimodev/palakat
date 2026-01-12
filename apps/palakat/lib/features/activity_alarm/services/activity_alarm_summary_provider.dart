import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/features/activity_alarm/services/activity_alarm_scheduler_provider.dart';
import 'package:palakat_shared/services.dart';

class ActivityAlarmSummary {
  const ActivityAlarmSummary({
    required this.membershipId,
    required this.enabled,
    required this.scheduledCount,
  });

  final int membershipId;
  final bool enabled;
  final int scheduledCount;
}

final activityAlarmSummaryProvider = FutureProvider<ActivityAlarmSummary?>((
  ref,
) async {
  final localStorage = ref.watch(localStorageServiceProvider);
  final membershipId =
      localStorage.currentMembership?.id ??
      localStorage.currentAuth?.account.membership?.id;

  if (membershipId == null) {
    return null;
  }

  final scheduler = await ref.watch(
    activityAlarmSchedulerServiceProvider.future,
  );

  final enabled = await scheduler.isEnabled(membershipId);
  final scheduledCount = enabled
      ? await scheduler.loadScheduledCount(membershipId)
      : 0;

  return ActivityAlarmSummary(
    membershipId: membershipId,
    enabled: enabled,
    scheduledCount: scheduledCount,
  );
});
