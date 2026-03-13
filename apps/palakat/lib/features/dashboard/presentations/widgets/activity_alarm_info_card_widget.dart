import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/activity_alarm/services/activity_alarm_summary_provider.dart';
import 'package:palakat_shared/core/extension/extension.dart';

import 'dashboard_notice_card_widget.dart';

class ActivityAlarmInfoCardWidget extends ConsumerWidget {
  const ActivityAlarmInfoCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final summaryAsync = ref.watch(activityAlarmSummaryProvider);

    return summaryAsync.when(
      data: (summary) {
        if (summary == null) return const SizedBox.shrink();
        if (!summary.enabled) return const SizedBox.shrink();
        if (summary.scheduledCount <= 0) return const SizedBox.shrink();

        return DashboardNoticeCardWidget(
          icon: AppIcons.notificationActive,
          title: l10n.dashboard_alarmSummary_title,
          message: l10n.dashboard_alarmSummary_message(summary.scheduledCount),
          actionLabel: l10n.dashboard_alarmSummary_action,
          onPressedAction: () {
            context.pushNamed(AppRoute.alarmSettings);
          },
          tone: DashboardNoticeTone.warning,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
