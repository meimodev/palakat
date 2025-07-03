import 'dart:developer';
import 'package:palakat/core/data_sources/data_sources.dart';
import 'package:palakat/features/account/data/membership_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/features/presentation.dart';

part 'dashboard_controller.g.dart';

@riverpod
class DashboardController extends _$DashboardController {
  // AccountRepository get accRepo => ref.read(accountRepositoryProvider);

  // ActivityRepository get activityRepo => ref.read(activityRepositoryProvider);

  // DateTime get startOfWeek => DateTime.now().toStartOfTheWeek;

  // DateTime get endOfWeek => DateTime.now().toEndOfTheWeek;

  @override
  DashboardState build() {
    fetchMembershipData();
    fetchThisAnnouncementData();
    fetchThisWeekActivityData();

    return const DashboardState(
      membership: null,
      membershipLoading: false,
      thisWeekActivitiesLoading: true,
      thisWeekActivities: [],
      thisWeekAnnouncementsLoading: true,
      thisWeekAnnouncements: [],
    );
  }

  // void test() async {
  //   MembershipRepository repo = ref.read(membershipRepositoryProvider );
  //   HiveService hiveService = ref.read(hiveServiceProvider);
  //
  //   await hiveService.saveAuth(
  //     AuthData(
  //       accessToken:
  //           "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjbGllbnRJZCI6InNlY3JldC1mcm9udGVuZC11c2VybmFtZSIsInNvdXJjZSI6ImNsaWVudC1zdHJhdGVneSIsImlhdCI6MTc0OTU1NjAwMX0.LWs9yiwgFAnUx5jmIPHvZh8_dwrHmLWt2jaLqI2eq6E",
  //       refreshToken: 'refreshToken',
  //     ),
  //   );
  //   final res = await repo.getMembership(1);
  //
  //   log("test fetch");
  //   log(res.toString());
  // }

  void fetchThisWeekActivityData() async {
    // final activities = await activityRepo.getActivities(
    //   GetActivitiesRequest(
    //     churchSerial: "G41zIX6vKFiTNsrlwCCN",
    //     activityDateRange: DateTimeRange(start: startOfWeek, end: endOfWeek),
    //   ),
    // );

    // activities.when(
    //   success: (data) {
    //     state = state.copyWith(
    //       thisWeekActivities: data,
    //       thisWeekActivitiesLoading: false,
    //     );
    //   },
    //   failure: (error, stackTrace) {
    //     state = state.copyWith(
    //       thisWeekActivitiesLoading: false,
    //     );
    //   },
    // );
  }

  void fetchMembershipData() async {
    // final membership = await accRepo.getMembership("DSA9B8UVCBk9dPaCrqfA");
    // membership.when(
    //   success: (data) {
    //     state = state.copyWith(
    //       membership: data,
    //       membershipLoading: false,
    //     );
    //   },
    //   failure: (error, stackTrace) {
    //     state = state.copyWith(
    //       membershipLoading: false,
    //     );
    //   },
    // );
  }

  void fetchThisAnnouncementData() async {
    // final activities = await activityRepo.getActivities(
    //   GetActivitiesRequest(
    //     churchSerial: "G41zIX6vKFiTNsrlwCCN",
    //     publishDateRange: DateTimeRange(start: startOfWeek, end: endOfWeek),
    //   ),
    // );
    //
    // activities.when(
    //   success: (data) {
    //     state = state.copyWith(
    //       thisWeekAnnouncements: data
    //           .where(
    //             (element) => element.type == ActivityType.announcement,
    //           )
    //           .toList(),
    //       thisWeekAnnouncementsLoading: false,
    //     );
    //   },
    //   failure: (error, stackTrace) {
    //     state = state.copyWith(
    //       thisWeekAnnouncementsLoading: false,
    //     );
    //   },
    // );
  }
}
