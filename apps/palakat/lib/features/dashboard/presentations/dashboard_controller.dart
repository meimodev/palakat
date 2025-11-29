import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/constants.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/models.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:palakat_shared/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_controller.g.dart';

@riverpod
class DashboardController extends _$DashboardController {
  @override
  DashboardState build() {
    // Initialize and fetch data
    Future.microtask(() => _initializeAndFetchData());
    return const DashboardState();
  }

  ActivityRepository get _activityRepo => ref.read(activityRepositoryProvider);

  AuthRepository get _authRepo => ref.read(authRepositoryProvider);

  ChurchRequestRepository get _churchRequestRepo =>
      ref.read(churchRequestRepositoryProvider);

  MembershipRepository get _membershipRepo =>
      ref.read(membershipRepositoryProvider);

  LocalStorageService get _localStorage =>
      ref.read(localStorageServiceProvider);

  /// Initialize dashboard: check auth and refresh membership data if signed in
  Future<void> _initializeAndFetchData() async {
    final isAuthenticated = _localStorage.isAuthenticated;
    final hasValidToken =
        _localStorage.accessToken != null &&
        _localStorage.accessToken!.isNotEmpty;

    if (isAuthenticated && hasValidToken) {
      // Refresh membership data from backend
      await _refreshMembershipData();
    }

    // Fetch dashboard data
    await fetchData();
  }

  /// Refreshes membership data from backend to ensure local cache is in sync
  Future<void> _refreshMembershipData() async {
    try {
      // Get membership ID from cached auth or cached membership
      final membershipId =
          _localStorage.currentMembership?.id ??
          _localStorage.currentAuth?.account.membership?.id;

      if (membershipId == null) {
        // No membership to refresh
        return;
      }

      final result = await _membershipRepo.getMembership(membershipId);

      result.when(
        onSuccess: (membership) async {
          // Update local storage with fresh membership data
          await _localStorage.saveMembership(membership);
        },
        onFailure: (failure) {
          // If membership not found (404), clear the stale cached membership
          if (failure.code == 404) {
            _localStorage.clearMembership();
          }
          // For other errors, keep the cached data and continue
        },
      );
    } catch (e) {
      // Silently fail - we'll use cached data if refresh fails
    }
  }

  Future<void> fetchData() async {
    try {
      final result = await _authRepo.getSignedInAccount();
      result.when(
        onSuccess: (account) {
          if (account != null) {
            state = state.copyWith(account: account, membershipLoading: false);
            fetchThisWeekActivities();
            fetchChurchRequest();
          } else {
            state = state.copyWith(
              account: null,
              membershipLoading: false,
              thisWeekAnnouncementsLoading: false,
              thisWeekActivitiesLoading: false,
              churchRequestLoading: false,
            );
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
    } catch (e) {
      state = state.copyWith(
        account: null,
        membershipLoading: false,
        errorMessage: 'Failed to fetch account: $e',
      );
    }
  }

  Future<void> fetchChurchRequest() async {
    state = state.copyWith(churchRequestLoading: true);

    try {
      final result = await _churchRequestRepo.getMyChurchRequest();

      result.when(
        onSuccess: (churchRequest) {
          state = state.copyWith(
            churchRequest: churchRequest,
            churchRequestLoading: false,
          );
        },
        onFailure: (failure) {
          state = state.copyWith(
            churchRequest: null,
            churchRequestLoading: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(churchRequest: null, churchRequestLoading: false);
    }
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
