import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/dashboard/presentations/dashboard_controller.dart';
import 'package:palakat_shared/core/extension/date_time_extension.dart';

import 'widgets/widgets.dart';

void _showSignOutConfirmation(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<bool>(
    context: context,
    backgroundColor: BaseColor.transparent,
    builder: (dialogContext) => Container(
      decoration: BoxDecoration(
        color: BaseColor.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(BaseSize.radiusLg),
          topRight: Radius.circular(BaseSize.radiusLg),
        ),
      ),
      padding: EdgeInsets.all(BaseSize.w24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: BaseSize.w40,
              height: BaseSize.h4,
              decoration: BoxDecoration(
                color: BaseColor.neutral30,
                borderRadius: BorderRadius.circular(BaseSize.radiusSm),
              ),
            ),
          ),
          Gap.h16,
          Container(
            width: BaseSize.w56,
            height: BaseSize.w56,
            decoration: BoxDecoration(
              color: BaseColor.red[50],
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.logout,
              size: BaseSize.w32,
              color: BaseColor.red[700],
            ),
          ),
          Gap.h16,
          Text(
            "Sign Out?",
            style: BaseTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: BaseColor.black,
            ),
            textAlign: TextAlign.center,
          ),
          Gap.h12,
          Text(
            "Are you sure you want to sign out? You will need to sign in again to access your account.",
            style: BaseTypography.bodyMedium.toSecondary,
            textAlign: TextAlign.center,
          ),
          Gap.h24,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
                    side: BorderSide(color: BaseColor.neutral40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                    ),
                  ),
                  child: Text(
                    "Cancel",
                    style: BaseTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: BaseColor.secondaryText,
                    ),
                  ),
                ),
              ),
              Gap.w12,
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await ref
                        .read(dashboardControllerProvider.notifier)
                        .signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BaseColor.red[600],
                    foregroundColor: BaseColor.white,
                    padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                    ),
                  ),
                  child: Text(
                    "Sign Out",
                    style: BaseTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: BaseColor.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Gap.h8,
        ],
      ),
    ),
  );
}

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Dashboard",
                style: BaseTypography.headlineLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: BaseColor.black,
                  letterSpacing: -0.5,
                ),
              ),
              if (state.account != null)
                IconButton(
                  onPressed: () => _showSignOutConfirmation(context, ref),
                  icon: Icon(
                    Icons.logout,
                    size: BaseSize.w24,
                    color: BaseColor.red[600],
                  ),
                  tooltip: 'Sign Out',
                  style: IconButton.styleFrom(
                    backgroundColor: BaseColor.red[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
          if (state.account != null && state.churchRequest != null)
            LoadingWrapper(
              loading: state.churchRequestLoading,
              hasError: false,
              onRetry: () => controller.fetchChurchRequest(),
              shimmerPlaceholder: PalakatShimmerPlaceholders.membershipCard(),
              child: Column(
                children: [
                  ChurchRequestStatusCardWidget(
                    churchRequest: state.churchRequest!,
                  ),
                  Gap.h16,
                ],
              ),
            ),
          Gap.h16,
          LoadingWrapper(
            loading: state.membershipLoading,
            hasError:
                state.errorMessage != null && state.membershipLoading == false,
            errorMessage: state.errorMessage,
            onRetry: () => controller.fetchData(),
            shimmerPlaceholder: PalakatShimmerPlaceholders.membershipCard(),
            child: MembershipCardWidget(
              account: state.account,
              onPressedCard: () async {
                // If user is signed in, navigate to account screen with account ID
                if (state.account != null && state.account!.id != null) {
                  await context.pushNamed(
                    AppRoute.account,
                    extra: RouteParam(params: {'accountId': state.account!.id}),
                  );
                } else {
                  // If not signed in, start authentication flow
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
                loading: state.thisWeekActivitiesLoading,
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
                  onPressedViewAll: () async =>
                      await context.pushNamed(AppRoute.viewAll),
                  activities: state.thisWeekActivities,
                  cardsHeight: BaseSize.customWidth(92),
                  onPressedCardDatePreview: (DateTime dateTime) async {
                    final thisDayActivities = state.thisWeekActivities
                        .where((element) => element.date.isSameDay(dateTime))
                        .toList();

                    await showDialogPreviewDayActivitiesWidget(
                      title: dateTime.ddMmmm,
                      context: context,
                      data: thisDayActivities,
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
              LoadingWrapper(
                loading: state.thisWeekAnnouncementsLoading,
                hasError:
                    state.errorMessage != null &&
                    state.thisWeekAnnouncementsLoading == false,
                errorMessage: state.errorMessage,
                onRetry: () => controller.fetchThisWeekActivities(),
                shimmerPlaceholder: Column(
                  children: [
                    PalakatShimmerPlaceholders.announcementCard(),
                    Gap.h12,
                    PalakatShimmerPlaceholders.announcementCard(),
                  ],
                ),
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
