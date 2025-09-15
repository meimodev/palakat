import 'package:palakat/features/account/data/account_repository.dart';
import 'package:palakat/features/account/data/membership_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/features/presentation.dart';

part 'dashboard_controller.g.dart';

@riverpod
class DashboardController extends _$DashboardController {
  late AccountRepository _accountRepo;
  late MembershipRepository _membershipRepo;

  // ActivityRepository get activityRepo => ref.read(activityRepositoryProvider);

  // DateTime get startOfWeek => DateTime.now().toStartOfTheWeek;

  // DateTime get endOfWeek => DateTime.now().toEndOfTheWeek;

  @override
  DashboardState build() {
    _accountRepo = ref.read(accountRepositoryProvider);
    _membershipRepo = ref.read(membershipRepositoryProvider);

    fetchData();

    return const DashboardState(
      account: null,
      membership: null,
      membershipLoading: true,
      thisWeekActivitiesLoading: true,
      thisWeekActivities: [],
      thisWeekAnnouncementsLoading: true,
      thisWeekAnnouncements: [],
    );
  }

  void fetchData() async {
    await fetchAccountData();
    await fetchMembershipData();
    await fetchThisAnnouncementData();
    await fetchThisWeekActivityData();
  }

  Future<void> fetchAccountData() async {
    final result = await _accountRepo.getSignedInAccount();
    result.when(
      onSuccess: (account) {
        if (account == null) {
          state = state.copyWith(
            account: null,
            membership: null,
            membershipLoading: false,
            thisWeekActivitiesLoading: false,
            thisWeekAnnouncementsLoading: false,
          );
        }
        state = state.copyWith(account: account);
      },
      onFailure: (failure) {
        state = state.copyWith(
          account: null,
          membership: null,
          membershipLoading: false,
          thisWeekActivitiesLoading: false,
          thisWeekAnnouncementsLoading: false,
        );
      },
    );
  }

  Future<void> fetchMembershipData() async {
    final account = state.account;
    if (account == null) {
      state = state.copyWith(
        account: null,
        membership: null,
        membershipLoading: false,
        thisWeekActivitiesLoading: false,
        thisWeekAnnouncementsLoading: false,
      );
      return;
    }
    if (account.membershipId == null) {
      state = state.copyWith(
        account: null,
        membership: null,
        membershipLoading: false,
        thisWeekActivitiesLoading: false,
        thisWeekAnnouncementsLoading: false,
      );
      return;
    }

    final result = await _membershipRepo.getMembership(
      state.account!.membershipId!,
    );
    result.when(
      onSuccess: (data) {
        state = state.copyWith(membershipLoading: false, membership: data);
      },
      onFailure: (failure) {
        state = state.copyWith(membershipLoading: false, membership: null);
      },
    );
  }

  Future<void> fetchThisWeekActivityData() async {}

  Future<void> fetchThisAnnouncementData() async {}
}
