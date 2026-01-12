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
      Future.microtask(_refreshExactAlarmPermissionAndResync);
    }
  }

  Future<void> _refreshExactAlarmPermissionAndResync() async {
    try {
      ref.invalidate(canScheduleExactAlarmsProvider);

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
    return ScaffoldWidget(
      loading: _loading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenTitleWidget.primary(
            title: 'Activity Alarms',
            leadIcon: AppIcons.back,
            leadIconColor: BaseColor.black,
            onPressedLeadIcon: () => context.pop(),
          ),
          Gap.h16,
          if (_membershipId == null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
              child: Text(
                'No membership found.',
                style: BaseTypography.bodyMedium.toSecondary,
                textAlign: TextAlign.center,
              ),
            )
          else ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
              child: Container(
                padding: EdgeInsets.all(BaseSize.w12),
                decoration: BoxDecoration(
                  color: BaseColor.primary[50],
                  borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                  border: Border.all(color: BaseColor.primary[200]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enable activity alarms',
                            style: BaseTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: BaseColor.black,
                            ),
                          ),
                          Gap.h4,
                          Text(
                            'Schedule reminders for this week on your phone.',
                            style: BaseTypography.bodySmall.toSecondary,
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
            if (_error != null) ...[
              Gap.h12,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
                child: Text(
                  _error!,
                  style: BaseTypography.bodySmall.copyWith(
                    color: BaseColor.red[700],
                  ),
                ),
              ),
            ],
            Gap.h16,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
              child: Text(
                'This week',
                style: BaseTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: BaseColor.black,
                ),
              ),
            ),
            Gap.h8,
            if (_activities.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
                child: Text(
                  'No activities with reminders found.',
                  style: BaseTypography.bodyMedium.toSecondary,
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activities.length,
                separatorBuilder: (context, index) => Gap.h8,
                padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
                itemBuilder: (context, index) {
                  final activity = _activities[index];
                  final id = activity.id;
                  if (id == null) return const SizedBox.shrink();

                  final reminder = activity.reminder;
                  final reminderText = reminder?.name;
                  final dateLocal = activity.date.toLocal();

                  final isEnabled =
                      _enabled && !_disabledActivities.contains(id);

                  return Material(
                    color: BaseColor.cardBackground1,
                    elevation: 1,
                    shadowColor: BaseColor.black.withValues(alpha: 0.05),
                    surfaceTintColor: BaseColor.primary[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                      onTap: () {
                        context.pushNamed(
                          AppRoute.activityDetail,
                          pathParameters: {'activityId': id.toString()},
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(BaseSize.w12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity.title,
                                    style: BaseTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: BaseColor.black,
                                    ),
                                  ),
                                  Gap.h4,
                                  Text(
                                    '${dateLocal.ddMmmmYyyy} ${dateLocal.HHmm}',
                                    style: BaseTypography.bodySmall.toSecondary,
                                  ),
                                  if (reminderText != null) ...[
                                    Gap.h4,
                                    Text(
                                      reminderText,
                                      style: BaseTypography.bodySmall.copyWith(
                                        color: BaseColor.neutral[700],
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
