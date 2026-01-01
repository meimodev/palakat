import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/dashboard/presentations/dashboard_controller.dart';
import 'package:palakat/features/home/presentation/home_controller.dart';
import 'package:palakat/features/notification/presentations/widgets/notification_permission_banner.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat_shared/core/extension/build_context_extension.dart';
import 'package:palakat_shared/core/extension/date_time_extension.dart';

import 'widgets/widgets.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Activity? _nextUp(List<Activity> activities) {
    final now = DateTime.now();
    final upcoming = activities
        .where((a) => a.date.isAfter(now) || a.date.isAtSameMomentAs(now))
        .toList(growable: false);
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.date.compareTo(b.date));
    return upcoming.first;
  }

  Future<void> _navigateToHomeTabOrRoute(
    BuildContext context,
    WidgetRef ref, {
    required int tabIndex,
    required String fallbackRouteName,
  }) async {
    final home = ref.read(homeControllerProvider);
    if (home.pageController.hasClients) {
      ref.read(homeControllerProvider.notifier).navigateTo(tabIndex);
      return;
    }

    await context.pushNamed(fallbackRouteName);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(dashboardControllerProvider.notifier);
    final state = ref.watch(dashboardControllerProvider);

    final next = _nextUp(state.thisWeekActivities);

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
              Gap.h48,
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
              _ActionCenter(
                next: next,
                onTapNext: next?.id == null
                    ? null
                    : () {
                        context.pushNamed(
                          AppRoute.activityDetail,
                          pathParameters: {'activityId': next!.id.toString()},
                        );
                      },
                onTapSongs: () => _navigateToHomeTabOrRoute(
                  context,
                  ref,
                  tabIndex: 1,
                  fallbackRouteName: AppRoute.songBook,
                ),
                onTapOperations: () => _navigateToHomeTabOrRoute(
                  context,
                  ref,
                  tabIndex: 2,
                  fallbackRouteName: AppRoute.operations,
                ),
                onTapApprovals: () => _navigateToHomeTabOrRoute(
                  context,
                  ref,
                  tabIndex: 3,
                  fallbackRouteName: AppRoute.approvals,
                ),
                onTapArticles: () => _navigateToHomeTabOrRoute(
                  context,
                  ref,
                  tabIndex: 4,
                  fallbackRouteName: AppRoute.articles,
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
                      onPressedViewAll: () async {
                        await context.pushNamed(
                          AppRoute.viewAll,
                          extra: const RouteParam(params: <String, dynamic>{}),
                        );
                      },
                      activities: state.thisWeekActivities,
                      cardsHeight: BaseSize.customWidth(92),
                      onPressedCardDatePreview: (DateTime dateTime) async {
                        final thisDayActivities = state.thisWeekActivities
                            .where(
                              (element) => element.date.isSameDay(dateTime),
                            )
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
                        await context.pushNamed(
                          AppRoute.viewAll,
                          extra: const RouteParam(
                            params: {
                              RouteParamKey.activityType:
                                  ActivityType.announcement,
                            },
                          ),
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

class _ActionCenter extends StatelessWidget {
  const _ActionCenter({
    required this.next,
    required this.onTapNext,
    required this.onTapSongs,
    required this.onTapOperations,
    required this.onTapApprovals,
    required this.onTapArticles,
  });

  final Activity? next;
  final VoidCallback? onTapNext;
  final VoidCallback onTapSongs;
  final VoidCallback onTapOperations;
  final VoidCallback onTapApprovals;
  final VoidCallback onTapArticles;

  @override
  Widget build(BuildContext context) {
    final nextTitle =
        '${context.l10n.pagination_next} ${context.l10n.lbl_activity}';
    final nextValue = next;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(BaseSize.w12),
          decoration: BoxDecoration(
            color: BaseColor.blue[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BaseColor.blue[200]!, width: 1),
          ),
          child: InkWell(
            onTap: onTapNext,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Container(
                  width: BaseSize.w40,
                  height: BaseSize.w40,
                  decoration: BoxDecoration(
                    color: BaseColor.blue[100],
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    AppIcons.calendar,
                    size: BaseSize.w18,
                    color: BaseColor.blue[700],
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nextTitle,
                        style: BaseTypography.labelMedium.copyWith(
                          color: BaseColor.blue[700],
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Gap.h4,
                      Text(
                        nextValue == null
                            ? context.l10n.noData_activities
                            : nextValue.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: BaseTypography.bodyMedium.copyWith(
                          color: BaseColor.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (nextValue != null) ...[
                        Gap.h4,
                        Text(
                          '${nextValue.date.EEEEddMMMyyyyShort} • ${nextValue.date.HHmm}',
                          style: BaseTypography.bodySmall.copyWith(
                            color: BaseColor.secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onTapNext != null) ...[
                  Gap.w8,
                  FaIcon(
                    AppIcons.openExternal,
                    size: BaseSize.w16,
                    color: BaseColor.blue[700],
                  ),
                ],
              ],
            ),
          ),
        ),
        Gap.h12,
        Row(
          children: [
            Expanded(
              child: _QuickActionTile(
                icon: AppIcons.music,
                label: context.l10n.songBook_title,
                onTap: onTapSongs,
                bg: BaseColor.teal[50]!,
                fg: BaseColor.teal[700]!,
              ),
            ),
            Gap.w12,
            Expanded(
              child: _QuickActionTile(
                icon: AppIcons.grid,
                label: context.l10n.operations_title,
                onTap: onTapOperations,
                bg: BaseColor.primary[50]!,
                fg: BaseColor.primary[700]!,
              ),
            ),
          ],
        ),
        Gap.h12,
        Row(
          children: [
            Expanded(
              child: _QuickActionTile(
                icon: AppIcons.approval,
                label: context.l10n.approval_title,
                onTap: onTapApprovals,
                bg: BaseColor.yellow[50]!,
                fg: BaseColor.yellow[700]!,
              ),
            ),
            Gap.w12,
            Expanded(
              child: _QuickActionTile(
                icon: AppIcons.reader,
                label: context.l10n.articles_title,
                onTap: onTapArticles,
                bg: BaseColor.blue[50]!,
                fg: BaseColor.blue[700]!,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.bg,
    required this.fg,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: BaseSize.w12,
            vertical: BaseSize.h12,
          ),
          child: Row(
            children: [
              Container(
                width: BaseSize.w32,
                height: BaseSize.w32,
                decoration: BoxDecoration(
                  color: fg.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: FaIcon(icon, size: BaseSize.w16, color: fg),
              ),
              Gap.w12,
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BaseTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
