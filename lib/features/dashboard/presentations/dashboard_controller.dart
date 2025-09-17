import 'package:palakat/features/account/data/membership_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/features/presentation.dart';

part 'dashboard_controller.g.dart';

@riverpod
class DashboardController extends _$DashboardController {
  @override
  DashboardState build() {
    fetchData();

    return const DashboardState();
  }

  MembershipRepository get _membershipRepo =>
      ref.read(membershipRepositoryProvider);

  void fetchData() async {
    await fetchMembershipData();
  }

  Future<void> fetchMembershipData() async {
    final result = await _membershipRepo.getSignedInMembership();
    result.when(
      onSuccess: (membership) {
        state = state.copyWith(
          membershipLoading: false,
          membership: membership,
          account: membership?.account,
        );
      },
      onFailure: (failure) {
        state = state.copyWith(membershipLoading: false, membership: null);
      },
    );
  }
}
