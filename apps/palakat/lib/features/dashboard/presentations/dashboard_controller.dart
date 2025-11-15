import 'package:palakat_shared/core/models/models.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/features/presentation.dart';

part 'dashboard_controller.g.dart';

@riverpod
class DashboardController extends _$DashboardController {
  @override
  DashboardState build() {
    Future.microtask(() {
      fetchData();
    });
    return const DashboardState();
  }

  ActivityRepository get _activityRepo => ref.read(activityRepositoryProvider);

  AuthRepository get _authRepo => ref.read(authRepositoryProvider);

  Future<void> fetchData() async {
    final result = await _authRepo.getSignedInAccount();
    result.when(
      onSuccess: (account) {
        if (account != null) {
          state = state.copyWith(account: account, membershipLoading: false);

          fetchThisWeekActivities();
        }
      },
      onFailure: (failure) {
        state = state.copyWith(
          account: null,
          membershipLoading: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  Future<void> fetchThisWeekActivities() async {
    final membership = state.account!.membership;
    final churchId = membership?.church?.id;

    if (churchId == null) {
      state = state.copyWith(
        thisWeekActivitiesLoading: false,
        thisWeekActivities: [],
        thisWeekAnnouncementsLoading: false,
        thisWeekAnnouncements: [],
      );
      return;
    }

    final now = DateTime.now();
    final startOfWeek = now.toStartOfTheWeek;
    final endOfWeek = now.toEndOfTheWeek;

    final result = await _activityRepo.fetchActivities(
      paginationRequest: PaginationRequestWrapper(
        data: GetFetchActivitiesRequest(
          churchId: churchId,
          startDate: startOfWeek,
          endDate: endOfWeek,
        ),
      ),
    );

    result.when(
      onSuccess: (response) {
        final approved = response.data.where(
          (activity) =>
              activity.approvers.approvalStatus == ApprovalStatus.approved,
        );

        final eventsAndServices = approved
            .where(
              (activity) =>
                  activity.activityType == ActivityType.event ||
                  activity.activityType == ActivityType.service,
            )
            .toList();

        final announcements = approved
            .where(
              (activity) => activity.activityType == ActivityType.announcement,
            )
            .toList();

        state = state.copyWith(
          thisWeekActivitiesLoading: false,
          thisWeekActivities: eventsAndServices,
          thisWeekAnnouncementsLoading: false,
          thisWeekAnnouncements: announcements,
        );
      },
      onFailure: (failure) {
        state = state.copyWith(
          thisWeekActivitiesLoading: false,
          thisWeekActivities: [],
          thisWeekAnnouncementsLoading: false,
          thisWeekAnnouncements: [],
          errorMessage: failure.message,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
