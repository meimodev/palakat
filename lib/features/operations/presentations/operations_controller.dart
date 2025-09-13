import 'package:palakat/features/account/data/account_repository.dart';
import 'package:palakat/features/account/data/membership_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/features/operations/domain/entities/report.dart';
import 'package:palakat/features/operations/presentations/operations_state.dart';

part 'operations_controller.g.dart';

@riverpod
class OperationsController extends _$OperationsController {
  late MembershipRepository _membershipRepository;
  late AccountRepository _accountRepository;

  @override
  OperationsState build() {
    _membershipRepository = ref.read(membershipRepositoryProvider);
    _accountRepository = ref.read(accountRepositoryProvider);
    fetchData();

    return const OperationsState();
  }

  void fetchData() async {
    await fetchMembership();
  }

  Future<void> fetchMembership() async {
    final resAccount = await _accountRepository.getSignedInAccount();
    resAccount.when(
      onSuccess: (account) async {
        if (account == null) {
          state = state.copyWith(membership: null, loadingScreen: false);
          return;
        }

        final resMembership = await _membershipRepository.getMembership(
          account.id,
        );
        resMembership.when(
          onSuccess: (membership) {
            state = state.copyWith(
              membership: membership,
              loadingScreen: false,
            );
          },
          onFailure: (failure) {},
        );
      },
    );
  }
}
