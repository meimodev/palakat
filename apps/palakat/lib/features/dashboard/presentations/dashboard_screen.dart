import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/activity_alarm/services/activity_alarm_summary_provider.dart';
import 'package:palakat/features/activity_alarm/services/exact_alarm_permission_service_provider.dart';
import 'package:palakat/features/activity_alarm/services/activity_alarm_scheduler_provider.dart';
import 'package:palakat/features/dashboard/presentations/dashboard_controller.dart';
import 'package:palakat/features/notification/presentations/widgets/notification_permission_banner.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';
import 'package:palakat_shared/core/extension/date_time_extension.dart';

import 'widgets/widgets.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {
  bool _isSchedulingSmokeTest = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(canScheduleExactAlarmsProvider);
      ref.invalidate(canUseFullScreenIntentProvider);
    }
  }

  Future<void> _scheduleSmokeTestAlarm({
    required int activityId,
    required String title,
  }) async {
    if (_isSchedulingSmokeTest) {
      return;
    }

    setState(() {
      _isSchedulingSmokeTest = true;
    });

    try {
      final scheduler = await ref.read(
        activityAlarmSchedulerServiceProvider.future,
      );
      final scheduledAt = await scheduler.scheduleSmokeTestAlarm(
        activityId: activityId,
        title: title,
      );

      if (!mounted) {
        return;
      }

      final secondText = scheduledAt.second.toString().padLeft(2, '0');
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Smoke test alarm scheduled for ${scheduledAt.HHmm}:$secondText',
            ),
          ),
        );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Failed to schedule smoke test alarm: $e')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isSchedulingSmokeTest = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(dashboardControllerProvider.notifier);
    final state = ref.watch(dashboardControllerProvider);
    final errorMsg = state.errorMessage?.trim() ?? '';
    final errorLower = errorMsg.toLowerCase();
    final isDisconnectedError =
        errorLower == 'disconnected' || errorLower.contains('disconnect');
    final thisWeekBirthdaysAsync = ref.watch(thisWeekBirthdaysProvider);
    final thisWeekBirthdays =
        thisWeekBirthdaysAsync.value ?? const <BirthdayItem>[];
    final canExactAsync = ref.watch(canScheduleExactAlarmsProvider);
    final canFullScreenAsync = ref.watch(canUseFullScreenIntentProvider);
    final alarmSummaryAsync = ref.watch(activityAlarmSummaryProvider);
    final alarmSummary = alarmSummaryAsync.asData?.value;
    final alarmScheduledCount = alarmSummary?.enabled == true
        ? alarmSummary?.scheduledCount ?? 0
        : 0;
    int? smokeTestActivityId;
    var smokeTestActivityTitle = 'Alarm smoke test';

    for (final activity in state.thisWeekActivities) {
      final id = activity.id;
      if (id == null) {
        continue;
      }
      smokeTestActivityId = id;
      smokeTestActivityTitle = activity.title;
      break;
    }

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      child: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchData();
        },
        color: BaseColor.teal.shade500,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.dashboard_title,
                    style: BaseTypography.headlineLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BaseColor.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      if (state.account != null)
                        Badge.count(
                          count: alarmScheduledCount,
                          isLabelVisible: alarmScheduledCount > 0,
                          backgroundColor: BaseColor.red,
                          textColor: BaseColor.white,
                          offset: const Offset(-2, 2),
                          child: IconButton(
                            onPressed: () =>
                                context.pushNamed(AppRoute.alarmSettings),
                            icon: FaIcon(
                              AppIcons.notificationActive,
                              size: BaseSize.w22,
                              color: BaseColor.yellow[800],
                            ),
                            tooltip: 'Activity alarms',
                            style: IconButton.styleFrom(
                              backgroundColor: BaseColor.yellow[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      if (state.account != null) Gap.w8,
                      if (state.account != null)
                        IconButton(
                          onPressed: () => context.pushNamed(AppRoute.settings),
                          icon: FaIcon(
                            AppIcons.settings,
                            size: BaseSize.w24,
                            color: BaseColor.primary[600],
                          ),
                          tooltip: context.l10n.settings_title,
                          style: IconButton.styleFrom(
                            backgroundColor: BaseColor.primary[50],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Gap.h16,
              const NotificationPermissionBanner(),
              if (state.account != null && state.churchRequest != null)
                LoadingWrapper(
                  loading: state.churchRequestLoading,
                  hasError: false,
                  onRetry: () => controller.fetchChurchRequest(),
                  shimmerPlaceholder:
                      PalakatShimmerPlaceholders.membershipCard(),
                  child: Column(
                    children: [
                      ChurchRequestStatusCardWidget(
                        churchRequest: state.churchRequest!,
                      ),
                      Gap.h16,
                    ],
                  ),
                ),
              if (state.pendingMembershipInvitation != null)
                Column(
                  children: [
                    MembershipInvitationConfirmationCardWidget(
                      invitation: state.pendingMembershipInvitation!,
                      onResolved: () async {
                        await controller.fetchData();
                      },
                    ),
                    Gap.h16,
                  ],
                ),
              LoadingWrapper(
                loading: state.membershipLoading,
                hasError:
                    state.errorMessage != null &&
                    state.membershipLoading == false &&
                    !isDisconnectedError,
                errorMessage: isDisconnectedError ? null : state.errorMessage,
                onRetry: () => controller.fetchData(),
                shimmerPlaceholder: PalakatShimmerPlaceholders.membershipCard(),
                child: MembershipCardWidget(
                  account: state.account,
                  onPressedCard: () async {
                    if (state.account != null && state.account!.id != null) {
                      await context.pushNamed(
                        AppRoute.account,
                        extra: RouteParam(
                          params: {'accountId': state.account!.id},
                        ),
                      );
                    } else {
                      await context.pushNamed(AppRoute.authentication);
                    }
                    controller.fetchData();
                  },
                ),
              ),
              Gap.h12,
              if (kDebugMode && state.account != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    BaseSize.w16,
                    BaseSize.h12,
                    BaseSize.w16,
                    0,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(BaseSize.w12),
                    decoration: BoxDecoration(
                      color: BaseColor.teal[50],
                      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                      border: Border.all(color: BaseColor.teal[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              AppIcons.notificationActive,
                              color: BaseColor.teal[700],
                              size: BaseSize.w18,
                            ),
                            Gap.w8,
                            Expanded(
                              child: Text(
                                'Alarm smoke test',
                                style: BaseTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: BaseColor.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Gap.h8,
                        Text(
                          smokeTestActivityId == null
                              ? 'Load at least one dashboard activity to test the alarm flow.'
                              : 'Schedules an activity alarm to ring in 10 seconds using the current device notification flow.',
                          style: BaseTypography.bodySmall.toSecondary,
                        ),
                        Gap.h12,
                        OutlinedButton(
                          onPressed:
                              smokeTestActivityId == null ||
                                  _isSchedulingSmokeTest
                              ? null
                              : () => _scheduleSmokeTestAlarm(
                                  activityId: smokeTestActivityId!,
                                  title: smokeTestActivityTitle,
                                ),
                          child: Text(
                            _isSchedulingSmokeTest
                                ? 'Scheduling...'
                                : 'Test alarm in 10 seconds',
                            style: BaseTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: BaseColor.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (state.account != null)
                canExactAsync.when(
                  data: (canExact) {
                    if (canExact) return const SizedBox.shrink();

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: BaseSize.w16,
                        vertical: BaseSize.h12,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(BaseSize.w12),
                        decoration: BoxDecoration(
                          color: BaseColor.yellow[50],
                          borderRadius: BorderRadius.circular(
                            BaseSize.radiusMd,
                          ),
                          border: Border.all(color: BaseColor.yellow[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  AppIcons.warning,
                                  color: BaseColor.yellow[800],
                                  size: BaseSize.w18,
                                ),
                                Gap.w8,
                                Expanded(
                                  child: Text(
                                    'Allow exact alarms',
                                    style: BaseTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: BaseColor.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Gap.h8,
                            Text(
                              'To trigger alarms on time, Android may require you to allow exact alarms for Palakat.',
                              style: BaseTypography.bodySmall.toSecondary,
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
                                'Open settings',
                                style: BaseTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: BaseColor.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (error, stackTrace) => const SizedBox.shrink(),
                ),
              if (state.account != null)
                canFullScreenAsync.when(
                  data: (canUseFullScreenIntent) {
                    if (canUseFullScreenIntent) return const SizedBox.shrink();

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: BaseSize.w16,
                        vertical: BaseSize.h12,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(BaseSize.w12),
                        decoration: BoxDecoration(
                          color: BaseColor.yellow[50],
                          borderRadius: BorderRadius.circular(
                            BaseSize.radiusMd,
                          ),
                          border: Border.all(color: BaseColor.yellow[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  AppIcons.warning,
                                  color: BaseColor.yellow[800],
                                  size: BaseSize.w18,
                                ),
                                Gap.w8,
                                Expanded(
                                  child: Text(
                                    'Allow full-screen alarms',
                                    style: BaseTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: BaseColor.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Gap.h8,
                            Text(
                              'To show the alarm screen over the lock screen, Android may require you to allow full-screen intent for Palakat.',
                              style: BaseTypography.bodySmall.toSecondary,
                            ),
                            Gap.h12,
                            OutlinedButton(
                              onPressed: () async {
                                final service = ref.read(
                                  exactAlarmPermissionServiceProvider,
                                );
                                await service
                                    .requestFullScreenIntentPermission();
                                ref.invalidate(canUseFullScreenIntentProvider);
                              },
                              child: Text(
                                'Open settings',
                                style: BaseTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: BaseColor.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (error, stackTrace) => const SizedBox.shrink(),
                ),
              Gap.h16,
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LoadingWrapper(
                    loading:
                        state.thisWeekActivitiesLoading ||
                        state.thisWeekAnnouncementsLoading,
                    hasError:
                        state.errorMessage != null &&
                        state.thisWeekActivitiesLoading == false,
                    errorMessage: state.errorMessage,
                    onRetry: () => controller.fetchThisWeekActivities(),
                    shimmerPlaceholder: Column(
                      children: [
                        PalakatShimmerPlaceholders.activityCard(),
                        Gap.h8,
                        PalakatShimmerPlaceholders.activityCard(),
                        Gap.h8,
                        PalakatShimmerPlaceholders.activityCard(),
                      ],
                    ),
                    child: ActivityWidget(
                      onPressedViewAll: () async {
                        await context.pushNamed(
                          AppRoute.viewAll,
                          extra: const RouteParam(params: <String, dynamic>{}),
                        );
                      },
                      activities: state.thisWeekActivities,
                      announcements: state.thisWeekAnnouncements,
                      birthdays: thisWeekBirthdays,
                      cardsHeight: BaseSize.customWidth(92),
                      onPressedCardDatePreview: (DateTime dateTime) async {
                        final thisDayActivities = state.thisWeekActivities
                            .where(
                              (element) => element.date.isSameDay(dateTime),
                            )
                            .toList();

                        final thisDayAnnouncements = state.thisWeekAnnouncements
                            .where((a) => a.date.isSameDay(dateTime))
                            .toList(growable: false);

                        final thisDayBirthdays = thisWeekBirthdays
                            .where((b) => b.date.isSameDay(dateTime))
                            .toList(growable: false);

                        await showDialogPreviewDayActivitiesWidget(
                          title: dateTime.ddMmmm,
                          context: context,
                          activities: [
                            ...thisDayAnnouncements,
                            ...thisDayActivities,
                          ],
                          birthdays: thisDayBirthdays,
                          onPressedCardBirthday: (birthday) {
                            final id = birthday.membership.id;
                            if (id == null) return;
                            context.pushNamed(
                              AppRoute.memberDetail,
                              pathParameters: {'membershipId': id.toString()},
                            );
                          },
                          onPressedCardActivity: (activity) {
                            context.pushNamed(
                              AppRoute.activityDetail,
                              pathParameters: {
                                'activityId': activity.id.toString(),
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              Gap.h64,
            ],
          ),
        ),
      ),
    );
  }
}
