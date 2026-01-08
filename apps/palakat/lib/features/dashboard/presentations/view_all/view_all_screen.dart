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

    final showBirthdays = activityType == null;
    final birthdaysAsync = showBirthdays
        ? ref.watch(thisWeekBirthdaysProvider)
        : null;

    final titlePrefix = activityType == ActivityType.announcement
        ? context.l10n.activityType_announcement
        : context.l10n.lbl_activity;

    final failure = async.error is Failure ? (async.error as Failure) : null;
    final birthdaysFailure = birthdaysAsync?.error is Failure
        ? (birthdaysAsync!.error as Failure)
        : null;
    final errorMessage = failure?.message ?? birthdaysFailure?.message;

    final loading = async.isLoading || (birthdaysAsync?.isLoading ?? false);
    final hasError =
        (async.hasError || (birthdaysAsync?.hasError ?? false)) &&
        (errorMessage != null);

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
            loading: loading,
            hasError: hasError,
            errorMessage: errorMessage,
            onRetry: () {
              ref.invalidate(viewAllActivitiesProvider(activityType));
              if (showBirthdays) {
                ref.invalidate(thisWeekBirthdaysProvider);
              }
            },
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
                final filtered = activities;

                final birthdays = showBirthdays
                    ? (birthdaysAsync?.value ?? const <BirthdayItem>[])
                    : const <BirthdayItem>[];

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
                          birthdays: birthdays
                              .where((b) => b.date.isSameDay(date))
                              .toList(growable: false),
                          onPressedBirthday: (birthday) {
                            final id = birthday.membership.id;
                            if (id == null) return;
                            context.pushNamed(
                              AppRoute.memberDetail,
                              pathParameters: {'membershipId': id.toString()},
                            );
                          },
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
