import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/activity_alarm/services/activity_alarm_summary_provider.dart';

class ActivityAlarmInfoCardWidget extends ConsumerWidget {
  const ActivityAlarmInfoCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(activityAlarmSummaryProvider);

    return summaryAsync.when(
      data: (summary) {
        if (summary == null) return const SizedBox.shrink();
        if (!summary.enabled) return const SizedBox.shrink();
        if (summary.scheduledCount <= 0) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
          child: Container(
            padding: EdgeInsets.all(BaseSize.w12),
            decoration: BoxDecoration(
              color: BaseColor.yellow[50],
              borderRadius: BorderRadius.circular(BaseSize.radiusMd),
              border: Border.all(color: BaseColor.yellow[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: BaseSize.w40,
                      height: BaseSize.w40,
                      decoration: BoxDecoration(
                        color: BaseColor.yellow[100],
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        AppIcons.notificationActive,
                        size: BaseSize.w18,
                        color: BaseColor.yellow[800],
                      ),
                    ),
                    Gap.w12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alarms scheduled',
                            style: BaseTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              color: BaseColor.black,
                            ),
                          ),
                          Gap.h4,
                          Text(
                            '${summary.scheduledCount} reminders set on your phone',
                            style: BaseTypography.bodySmall.copyWith(
                              color: BaseColor.neutral[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Gap.h12,
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.pushNamed(AppRoute.alarmSettings);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
                          side: BorderSide(color: BaseColor.yellow[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              BaseSize.radiusMd,
                            ),
                          ),
                        ),
                        child: Text(
                          'Manage',
                          style: BaseTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: BaseColor.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
