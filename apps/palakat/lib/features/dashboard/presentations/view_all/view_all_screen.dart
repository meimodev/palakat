import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat_shared/core/repositories/repositories.dart';

final viewAllActivitiesProvider = FutureProvider.autoDispose
    .family<List<Activity>, ActivityType?>((ref, activityType) async {
      final repo = ref.read(activityRepositoryProvider);

      final now = DateTime.now();
      final startOfWeek = now.toStartOfTheWeek;
      final endOfWeek = now.toEndOfTheWeek;

      final result = await repo.fetchActivities(
        paginationRequest: PaginationRequestWrapper(
          sortBy: 'date',
          sortOrder: 'asc',
          data: GetFetchActivitiesRequest(
            startDate: startOfWeek,
            endDate: endOfWeek,
            activityType: activityType,
          ),
        ),
      );

      return result.when(
        onSuccess: (response) {
          final approved = response.data.where(
            (activity) =>
                activity.approvers.approvalStatus == ApprovalStatus.approved,
          );
          return approved.toList(growable: false);
        },
        onFailure: (failure) {
          throw failure;
        },
      )!;
    });

class ViewAllScreen extends ConsumerWidget {
  const ViewAllScreen({super.key, this.activityType});

  final ActivityType? activityType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(viewAllActivitiesProvider(activityType));

    final titlePrefix = activityType == ActivityType.announcement
        ? context.l10n.activityType_announcement
        : context.l10n.lbl_activity;

    final failure = async.error is Failure ? (async.error as Failure) : null;
    final errorMessage = failure?.message;

    return ScaffoldWidget(
      child: Column(
        children: [
          ScreenTitleWidget.primary(
            title: '$titlePrefix - ${context.l10n.dateRangeFilter_thisWeek}',
            leadIcon: AppIcons.back,
            leadIconColor: Colors.black,
            onPressedLeadIcon: context.pop,
          ),
          Gap.h16,
          LoadingWrapper(
            loading: async.isLoading,
            hasError: async.hasError && (errorMessage != null),
            errorMessage: errorMessage,
            onRetry: () =>
                ref.invalidate(viewAllActivitiesProvider(activityType)),
            shimmerPlaceholder: Column(
              children: [
                PalakatShimmerPlaceholders.activityCard(),
                Gap.h8,
                PalakatShimmerPlaceholders.activityCard(),
                Gap.h8,
                PalakatShimmerPlaceholders.activityCard(),
              ],
            ),
            child: Builder(
              builder: (_) {
                final activities = async.value ?? const <Activity>[];
                final filtered = activityType == null
                    ? activities
                          .where(
                            (a) => a.activityType != ActivityType.announcement,
                          )
                          .toList(growable: false)
                    : activities;

                return Column(
                  children: [
                    ...DateTime.now().generateThisWeekDates.map(
                      (date) => Padding(
                        padding: EdgeInsets.only(bottom: BaseSize.h16),
                        child: CardActivitySectionWidget(
                          title: date.EEEEddMMM,
                          today: date.isSameDay(DateTime.now()),
                          activities: filtered
                              .where(
                                (activity) => activity.date.isSameDay(date),
                              )
                              .toList(),
                          onPressedCard: (Activity activity) {
                            context.pushNamed(
                              AppRoute.activityDetail,
                              pathParameters: {
                                'activityId': activity.id.toString(),
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
