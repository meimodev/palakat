import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/activity_alarm/services/activity_alarm_scheduler_provider.dart';
import 'package:palakat/features/activity_alarm/services/activity_alarm_summary_provider.dart';
import 'package:palakat/features/activity_alarm/services/exact_alarm_permission_service_provider.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:palakat_shared/services.dart';

import 'activity_alarm_motion_widget.dart';

class AlarmSettingsScreen extends ConsumerStatefulWidget {
  const AlarmSettingsScreen({super.key});

  @override
  ConsumerState<AlarmSettingsScreen> createState() =>
      _AlarmSettingsScreenState();
}

class _AlarmSettingsScreenState extends ConsumerState<AlarmSettingsScreen>
    with WidgetsBindingObserver {
  bool _loading = true;
  String? _error;

  int? _membershipId;
  bool _enabled = true;
  Set<int> _disabledActivities = <int>{};
  List<Activity> _activities = <Activity>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(_load);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future.microtask(_refreshAlarmPermissionsOnResume);
    }
  }

  Future<void> _refreshAlarmPermissionsOnResume() async {
    try {
      ref.invalidate(canScheduleExactAlarmsProvider);
      ref.invalidate(canUseFullScreenIntentProvider);

      final membershipId = _membershipId;
      if (membershipId == null) return;
      if (!_enabled) return;

      final exactService = ref.read(exactAlarmPermissionServiceProvider);
      final canExact = await exactService.canScheduleExactAlarms();
      if (!canExact) return;

      final scheduler = await ref.read(
        activityAlarmSchedulerServiceProvider.future,
      );
      await scheduler.syncWeekAlarms(
        membershipId: membershipId,
        activities: _activities,
      );
      ref.invalidate(activityAlarmSummaryProvider);
    } catch (_) {}
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final localStorage = ref.read(localStorageServiceProvider);
      final membershipId =
          localStorage.currentMembership?.id ??
          localStorage.currentAuth?.account.membership?.id;

      if (membershipId == null) {
        setState(() {
          _membershipId = null;
          _loading = false;
          _enabled = true;
          _disabledActivities = <int>{};
          _activities = <Activity>[];
        });
        return;
      }

      final scheduler = await ref.read(
        activityAlarmSchedulerServiceProvider.future,
      );

      final enabled = await scheduler.isEnabled(membershipId);
      final disabled = await scheduler.loadDisabledActivities(membershipId);

      final homeRepo = ref.read(homeRepositoryProvider);
      final dashboardResult = await homeRepo.getHomeDashboard();

      var activities = <Activity>[];
      dashboardResult.when(
        onSuccess: (response) {
          final data = response.data;
          final nowLocal = DateTime.now();
          final approved = data.thisWeekActivities
              .where(
                (a) => a.approvers.approvalStatus == ApprovalStatus.approved,
              )
              .where(
                (a) =>
                    (a.activityType == ActivityType.event ||
                        a.activityType == ActivityType.service) &&
                    a.reminder != null,
              )
              .where((a) => a.date.toLocal().isAfter(nowLocal))
              .toList();

          approved.sort((a, b) => a.date.compareTo(b.date));
          activities = approved;
        },
        onFailure: (_) {
          activities = <Activity>[];
        },
      );

      if (!mounted) return;

      setState(() {
        _membershipId = membershipId;
        _enabled = enabled;
        _disabledActivities = disabled;
        _activities = activities;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _setGlobalEnabled(bool enabled) async {
    final membershipId = _membershipId;
    if (membershipId == null) return;

    setState(() {
      _enabled = enabled;
    });

    try {
      final scheduler = await ref.read(
        activityAlarmSchedulerServiceProvider.future,
      );
      await scheduler.setEnabled(membershipId, enabled);

      ref.invalidate(activityAlarmSummaryProvider);

      if (enabled) {
        await scheduler.syncWeekAlarms(
          membershipId: membershipId,
          activities: _activities,
        );
        ref.invalidate(activityAlarmSummaryProvider);
      }
    } catch (_) {}
  }

  Future<void> _setActivityEnabled(int activityId, bool enabled) async {
    final membershipId = _membershipId;
    if (membershipId == null) return;

    setState(() {
      if (enabled) {
        _disabledActivities.remove(activityId);
      } else {
        _disabledActivities.add(activityId);
      }
    });

    try {
      final scheduler = await ref.read(
        activityAlarmSchedulerServiceProvider.future,
      );
      await scheduler.setActivityEnabled(membershipId, activityId, enabled);
      await scheduler.syncWeekAlarms(
        membershipId: membershipId,
        activities: _activities,
      );
      ref.invalidate(activityAlarmSummaryProvider);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canExactAsync = ref.watch(canScheduleExactAlarmsProvider);
    final canFullScreenAsync = ref.watch(canUseFullScreenIntentProvider);

    return ScaffoldWidget(
      loading: _loading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ActivityAlarmReveal(
            child: ScreenTitleWidget.primary(
              title: l10n.dashboard_alarmSettings_tooltip,
              leadIcon: AppIcons.back,
              leadIconColor: AppColors.onSurface,
              onPressedLeadIcon: () => context.pop(),
            ),
          ),
          Gap.h16,
          if (_membershipId == null)
            ActivityAlarmReveal(
              delay: const Duration(milliseconds: 40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.settings_noMembership,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else ...[
            ActivityAlarmReveal(
              delay: const Duration(milliseconds: 40),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: AppColors.primary.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: AppColors.primary.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.activityAlarm_enableTitle,
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary.shade700,
                              ),
                            ),
                            Gap.h4,
                            Text(
                              l10n.activityAlarm_enableSubtitle,
                              style: Theme.of(context).textTheme.bodyMedium!.toSecondary,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _enabled,
                        onChanged: (value) => _setGlobalEnabled(value),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ActivityAlarmAnimatedPresence(
              visible: _error != null,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16.0,
                  12.0,
                  16.0,
                  0,
                ),
                child: Text(
                  _error ?? '',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
            canExactAsync.when(
              data: (canExact) {
                return ActivityAlarmAnimatedPresence(
                  visible: !canExact,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      16.0,
                      12.0,
                      16.0,
                      0,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: AppColors.warning.shade50,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: AppColors.warning.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                AppIcons.warning,
                                color: AppColors.warning.shade700,
                                size: 18.0,
                              ),
                              Gap.w8,
                              Expanded(
                                child: Text(
                                  l10n.dashboard_alarmPermission_exact_title,
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.warning.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Gap.h8,
                          Text(
                            l10n.dashboard_alarmPermission_exact_message,
                            style: Theme.of(context).textTheme.bodyMedium!.toSecondary,
                          ),
                          Gap.h12,
                          OutlinedButton(
                            onPressed: () async {
                              final service = ref.read(
                                exactAlarmPermissionServiceProvider,
                              );
                              await service.requestExactAlarmPermission();
                              ref.invalidate(canScheduleExactAlarmsProvider);
                            },
                            child: Text(
                              l10n.notificationPermission_btn_enableInSettings,
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.warning.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (error, stackTrace) => const SizedBox.shrink(),
            ),
            canFullScreenAsync.when(
              data: (canUseFullScreenIntent) {
                return ActivityAlarmAnimatedPresence(
                  visible: !canUseFullScreenIntent,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      16.0,
                      12.0,
                      16.0,
                      0,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: AppColors.warning.shade50,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: AppColors.warning.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                AppIcons.warning,
                                color: AppColors.warning.shade700,
                                size: 18.0,
                              ),
                              Gap.w8,
                              Expanded(
                                child: Text(
                                  l10n.dashboard_alarmPermission_fullScreen_title,
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.warning.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Gap.h8,
                          Text(
                            l10n.dashboard_alarmPermission_fullScreen_message,
                            style: Theme.of(context).textTheme.bodyMedium!.toSecondary,
                          ),
                          Gap.h12,
                          OutlinedButton(
                            onPressed: () async {
                              final service = ref.read(
                                exactAlarmPermissionServiceProvider,
                              );
                              await service.requestFullScreenIntentPermission();
                              ref.invalidate(canUseFullScreenIntentProvider);
                            },
                            child: Text(
                              l10n.notificationPermission_btn_enableInSettings,
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.warning.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (error, stackTrace) => const SizedBox.shrink(),
            ),
            Gap.h32,
            ActivityAlarmReveal(
              delay: const Duration(milliseconds: 80),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  l10n.dateRangeFilter_thisWeek,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            Gap.h8,
            if (_activities.isEmpty)
              ActivityAlarmReveal(
                delay: const Duration(milliseconds: 120),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    l10n.activityAlarm_noActivitiesWithReminders,
                    style: Theme.of(context).textTheme.bodyMedium!.toSecondary,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activities.length,
                separatorBuilder: (context, index) => Gap.h8,
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                itemBuilder: (context, index) {
                  final activity = _activities[index];
                  final id = activity.id;
                  if (id == null) return const SizedBox.shrink();

                  final reminder = activity.reminder;
                  final reminderText = reminder?.name;
                  final dateLocal = activity.date.toLocal();

                  final isEnabled =
                      _enabled && !_disabledActivities.contains(id);

                  return ActivityAlarmReveal(
                    key: ValueKey('alarm-activity-$id'),
                    delay: Duration(milliseconds: 120 + (index * 40)),
                    child: Material(
                      color: AppColors.surfaceContainerLowest,
                      elevation: 1,
                      shadowColor: AppColors.primary.withValues(alpha: 0.05),
                      surfaceTintColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8.0),
                        onTap: () {
                          context.pushNamed(
                            AppRoute.activityDetail,
                            pathParameters: {'activityId': id.toString()},
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activity.title,
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Gap.h4,
                                    Text(
                                      '${dateLocal.ddMmmmYyyy} ${dateLocal.HHmm}',
                                      style:
                                          Theme.of(context).textTheme.bodyMedium!.toSecondary,
                                    ),
                                    if (reminderText != null) ...[
                                      Gap.h4,
                                      Text(
                                        reminderText,
                                        style: Theme.of(context).textTheme.bodyMedium!
                                            .copyWith(
                                              color: AppColors.neutral,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Switch(
                                value: isEnabled,
                                onChanged: _enabled
                                    ? (value) => _setActivityEnabled(id, value)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
          Gap.h24,
        ],
      ),
    );
  }
}
