import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/data_sources/data_sources.dart';
import 'package:palakat/core/utils/extensions/date_time_extension.dart';
import 'package:palakat/features/dashboard/data/activity_repository.dart';
import 'package:palakat/features/data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/features/presentation.dart';

part 'dashboard_controller.g.dart';

@riverpod
class DashboardController extends _$DashboardController {
  AccountRepository get accRepo => ref.read(accountRepositoryProvider);

  ActivityRepository get activityRepo => ref.read(activityRepositoryProvider);

  DateTime get startOfWeek => DateTime.now().toStartOfTheWeek;

  DateTime get endOfWeek => DateTime.now().toEndOfTheWeek;

  @override
  DashboardState build() {
    fetchMembershipData();
    fetchThisAnnouncementData();
    fetchThisWeekActivityData();

    return const DashboardState(
      membership: null,
      membershipLoading: true,
      thisWeekActivitiesLoading: true,
      thisWeekActivities: [],
      thisWeekAnnouncementsLoading: true,
      thisWeekAnnouncements: [],
    );
  }

  void fetchThisWeekActivityData() async {
    final activities = await activityRepo.getActivities(
      GetActivitiesRequest(
        churchSerial: "G41zIX6vKFiTNsrlwCCN",
        activityDateRange: DateTimeRange(start: startOfWeek, end: endOfWeek),
      ),
    );

    activities.when(
      success: (data) {
        state = state.copyWith(
          thisWeekActivities: data,
          thisWeekActivitiesLoading: false,
        );
      },
      failure: (error, stackTrace) {
        state = state.copyWith(
          thisWeekActivitiesLoading: false,
        );
      },
    );
  }

  void fetchMembershipData() async {
    final membership = await accRepo.getMembership("DSA9B8UVCBk9dPaCrqfA");
    membership.when(
      success: (data) {
        state = state.copyWith(
          membership: data,
          membershipLoading: false,
        );
      },
      failure: (error, stackTrace) {
        state = state.copyWith(
          membershipLoading: false,
        );
      },
    );
  }

  void fetchThisAnnouncementData() async {
    final activities = await activityRepo.getActivities(
      GetActivitiesRequest(
        churchSerial: "G41zIX6vKFiTNsrlwCCN",
        publishDateRange: DateTimeRange(start: startOfWeek, end: endOfWeek),
      ),
    );

    activities.when(
      success: (data) {
        state = state.copyWith(
          thisWeekAnnouncements: data
              .where(
                (element) => element.type == ActivityType.announcement,
              )
              .toList(),
          thisWeekAnnouncementsLoading: false,
        );
      },
      failure: (error, stackTrace) {
        state = state.copyWith(
          thisWeekAnnouncementsLoading: false,
        );
      },
    );
  }
}
