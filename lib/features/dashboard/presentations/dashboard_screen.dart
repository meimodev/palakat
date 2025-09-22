import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/utils/extensions/date_time_extension.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/dashboard/presentations/dashboard_controller.dart';

import 'widgets/widgets.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(dashboardControllerProvider.notifier);
    final state = ref.watch(dashboardControllerProvider);

    return ScaffoldWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenTitleWidget.titleOnly(title: "Dashboard"),
          Gap.h16,
          LoadingWrapper(
            paddingTop: BaseSize.h24,
            paddingBottom: BaseSize.h24,
            loading: state.membershipLoading,
            child: MembershipCardWidget(
              membership: state.membership,
              onPressedCard: () async {
                await context.pushNamed(AppRoute.authentication);
                controller.fetchData();
              },
            ),
          ),
          Gap.h24,
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LoadingWrapper(
                paddingTop: BaseSize.h48,
                paddingBottom: BaseSize.h24,
                loading: state.thisWeekActivitiesLoading,
                child: ActivityWidget(
                  onPressedViewAll: () async =>
                      await context.pushNamed(AppRoute.viewAll),
                  activities: state.thisWeekActivities,
                  cardsHeight: BaseSize.customWidth(80),
                  onPressedCardDatePreview: (DateTime dateTime) async {
                    final thisDayActivities = state.thisWeekActivities
                        .where(
                          (element) =>
                              element.date.isSameDay(dateTime),
                        )
                        .toList();

                    await showDialogPreviewDayActivitiesWidget(
                      title: dateTime.ddMmmm,
                      context: context,
                      data: thisDayActivities,
                      onPressedCardActivity: (activity) {
                        context.pushNamed(
                          AppRoute.activityDetail,
                          extra: RouteParam(
                            params: {
                              RouteParamKey.activity: activity.toJson(),
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              Gap.h12,
              LoadingWrapper(
                paddingTop: BaseSize.h24,
                paddingBottom: BaseSize.h24,
                loading: state.thisWeekAnnouncementsLoading,
                child: AnnouncementWidget(
                  announcements: state.thisWeekAnnouncements,
                  onPressedViewAll: () async {
                    await context.pushNamed(AppRoute.viewAll);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
