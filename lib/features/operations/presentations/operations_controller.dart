import 'package:palakat_admin/core/repositories/repositories.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/features/operations/presentations/operations_state.dart';

part 'operations_controller.g.dart';

@riverpod
class OperationsController extends _$OperationsController {
  MembershipRepository get _membershipRepository =>
      ref.read(membershipRepositoryProvider);

  @override
  OperationsState build() {
    fetchData();
    return const OperationsState();
  }

  void fetchData() async {
    await fetchMembership();
  }

  Future<void> fetchMembership() async {
    final result = await _membershipRepository.getSignedInMembership();
    result.when(
      onSuccess: (data) {
        state = state.copyWith(membership: data, loadingScreen: false);
      },
    );
  }
}
