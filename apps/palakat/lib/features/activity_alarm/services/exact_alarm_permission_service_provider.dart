import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/features/activity_alarm/services/exact_alarm_permission_service.dart';

final exactAlarmPermissionServiceProvider =
    Provider<ExactAlarmPermissionService>((ref) {
      return ExactAlarmPermissionService();
    });

final canScheduleExactAlarmsProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(exactAlarmPermissionServiceProvider);
  return service.canScheduleExactAlarms();
});

final canUseFullScreenIntentProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(exactAlarmPermissionServiceProvider);
  return service.canUseFullScreenIntent();
});
