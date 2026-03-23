import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
    final l10n = context.l10n;

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
              l10n.dashboard_smokeTest_scheduledSnack(
                '${scheduledAt.HHmm}:$secondText',
              ),
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
          SnackBar(
            content: Text(l10n.dashboard_smokeTest_failedSnack(e.toString())),
          ),
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
    final l10n = context.l10n;
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
    var smokeTestActivityTitle = l10n.dashboard_smokeTest_title;

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
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DashboardReveal(
                duration: const Duration(milliseconds: 300),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final headerActions = Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.end,
                      children: [
                        if (state.account != null)
                          Badge.count(
                            count: alarmScheduledCount,
                            isLabelVisible: alarmScheduledCount > 0,
                            backgroundColor: AppColors.error,
                            textColor: AppColors.surfaceContainerLowest,
                            offset: const Offset(-2, 2),
                            child: IconButton(
                              onPressed: () =>
                                  context.pushNamed(AppRoute.alarmSettings),
                              icon: FaIcon(
                                AppIcons.notificationActive,
                                size: 22.0,
                                color: AppColors.onPrimary,
                              ),
                              tooltip: l10n.dashboard_alarmSettings_tooltip,
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.warning,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                        if (state.account != null)
                          IconButton(
                            onPressed: () =>
                                context.pushNamed(AppRoute.settings),
                            icon: FaIcon(
                              AppIcons.settings,
                              size: 24.0,
                              color: AppColors.onPrimary,
                            ),
                            tooltip: context.l10n.settings_title,
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                      ],
                    );

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            l10n.dashboard_title,
                            style: Theme.of(context).textTheme.headlineLarge!
                                .copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                  letterSpacing: -0.5,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (state.account != null) ...[Gap.w8, headerActions],
                      ],
                    );
                  },
                ),
              ),
              Gap.h16,
              if (state.account != null)
                DashboardReveal(
                  delay: const Duration(milliseconds: 60),
                  child: Column(
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
                              extra: const RouteParam(
                                params: <String, dynamic>{},
                              ),
                            );
                          },
                          activities: state.thisWeekActivities,
                          announcements: state.thisWeekAnnouncements,
                          birthdays: thisWeekBirthdays,
                          cardsHeight: 92,
                          onPressedCardDatePreview: (DateTime dateTime) async {
                            final thisDayActivities = state.thisWeekActivities
                                .where(
                                  (element) => element.date.isSameDay(dateTime),
                                )
                                .toList();

                            final thisDayAnnouncements = state
                                .thisWeekAnnouncements
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
                                  pathParameters: {
                                    'membershipId': id.toString(),
                                  },
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
                ),
              Gap.h16,
              DashboardReveal(
                delay: const Duration(milliseconds: 120),
                child: LoadingWrapper(
                  loading: state.membershipLoading,
                  hasError:
                      state.errorMessage != null &&
                      state.membershipLoading == false &&
                      !isDisconnectedError,
                  errorMessage: isDisconnectedError ? null : state.errorMessage,
                  onRetry: () => controller.fetchData(),
                  shimmerPlaceholder:
                      PalakatShimmerPlaceholders.membershipCard(),
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
              ),
              if (state.account != null && alarmScheduledCount > 0)
                DashboardReveal(
                  delay: const Duration(milliseconds: 160),
                  child: Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: const ActivityAlarmInfoCardWidget(),
                  ),
                ),
              if (state.account != null && state.churchRequest != null)
                DashboardReveal(
                  delay: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: LoadingWrapper(
                      loading: state.churchRequestLoading,
                      hasError: false,
                      onRetry: () => controller.fetchChurchRequest(),
                      shimmerPlaceholder:
                          PalakatShimmerPlaceholders.membershipCard(),
                      child: ChurchRequestStatusCardWidget(
                        churchRequest: state.churchRequest!,
                      ),
                    ),
                  ),
                ),
              if (state.pendingMembershipInvitation != null)
                DashboardReveal(
                  delay: const Duration(milliseconds: 240),
                  child: Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: MembershipInvitationConfirmationCardWidget(
                      invitation: state.pendingMembershipInvitation!,
                      onResolved: () async {
                        await controller.fetchData();
                      },
                    ),
                  ),
                ),
              Gap.h16,
              const DashboardReveal(
                delay: Duration(milliseconds: 280),
                child: NotificationPermissionBanner(),
              ),
              if (kDebugMode && state.account != null) ...[
                DashboardReveal(
                  delay: const Duration(milliseconds: 320),
                  child: Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: DashboardNoticeCardWidget(
                      icon: AppIcons.notificationActive,
                      title: l10n.dashboard_smokeTest_title,
                      message: smokeTestActivityId == null
                          ? l10n.dashboard_smokeTest_emptyMessage
                          : l10n.dashboard_smokeTest_readyMessage,
                      actionLabel: _isSchedulingSmokeTest
                          ? l10n.dashboard_smokeTest_loadingAction
                          : l10n.dashboard_smokeTest_action,
                      onPressedAction:
                          smokeTestActivityId == null || _isSchedulingSmokeTest
                          ? null
                          : () => _scheduleSmokeTestAlarm(
                              activityId: smokeTestActivityId!,
                              title: smokeTestActivityTitle,
                            ),
                      tone: DashboardNoticeTone.primary,
                    ),
                  ),
                ),
              ],
              if (state.account != null)
                canExactAsync.when(
                  data: (canExact) {
                    return DashboardAnimatedPresence(
                      visible: !canExact,
                      child: Padding(
                        padding: EdgeInsets.only(top: 12.0),
                        child: DashboardNoticeCardWidget(
                          icon: AppIcons.warning,
                          title: l10n.dashboard_alarmPermission_exact_title,
                          message: l10n.dashboard_alarmPermission_exact_message,
                          actionLabel:
                              l10n.notificationPermission_btn_enableInSettings,
                          onPressedAction: () async {
                            final service = ref.read(
                              exactAlarmPermissionServiceProvider,
                            );
                            await service.requestExactAlarmPermission();
                            ref.invalidate(canScheduleExactAlarmsProvider);
                          },
                          tone: DashboardNoticeTone.warning,
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
                    return DashboardAnimatedPresence(
                      visible: !canUseFullScreenIntent,
                      child: Padding(
                        padding: EdgeInsets.only(top: 12.0),
                        child: DashboardNoticeCardWidget(
                          icon: AppIcons.warning,
                          title:
                              l10n.dashboard_alarmPermission_fullScreen_title,
                          message:
                              l10n.dashboard_alarmPermission_fullScreen_message,
                          actionLabel:
                              l10n.notificationPermission_btn_enableInSettings,
                          onPressedAction: () async {
                            final service = ref.read(
                              exactAlarmPermissionServiceProvider,
                            );
                            await service.requestFullScreenIntentPermission();
                            ref.invalidate(canUseFullScreenIntentProvider);
                          },
                          tone: DashboardNoticeTone.warning,
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (error, stackTrace) => const SizedBox.shrink(),
                ),
              Gap.h64,
            ],
          ),
        ),
      ),
    );
  }
}
