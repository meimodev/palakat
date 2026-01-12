import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/services/notification_display_service_provider.dart';

import 'activity_alarm_scheduler_service.dart';

final activityAlarmSchedulerServiceProvider =
    FutureProvider<ActivityAlarmSchedulerService>((ref) async {
      final display = await ref.watch(
        notificationDisplayServiceProvider.future,
      );
      return ActivityAlarmSchedulerService(display: display);
    });
