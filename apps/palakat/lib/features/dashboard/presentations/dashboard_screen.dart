import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/dashboard/presentations/dashboard_controller.dart';
import 'package:palakat/features/notification/presentations/widgets/notification_permission_banner.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';
import 'package:palakat_shared/core/extension/date_time_extension.dart';

import 'widgets/widgets.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(dashboardControllerProvider.notifier);
    final state = ref.watch(dashboardControllerProvider);
    final thisWeekBirthdaysAsync = ref.watch(thisWeekBirthdaysProvider);
    final thisWeekBirthdays =
        thisWeekBirthdaysAsync.value ?? const <BirthdayItem>[];

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
                    state.membershipLoading == false,
                errorMessage: state.errorMessage,
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
