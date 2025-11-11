import 'package:palakat_admin/core/repositories/repositories.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/features/operations/presentations/operations_state.dart';

part 'operations_controller.g.dart';

@riverpod
class OperationsController extends _$OperationsController {
  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  @override
  OperationsState build() {
    Future.microtask(() {
      fetchData();
    });
    return const OperationsState();
  }

  void fetchData() async {
    await fetchMembership();
  }

  Future<void> fetchMembership() async {
    final result = await _authRepository.getSignedInAccount();
    result.when(
      onSuccess: (account) {
        state = state.copyWith(
          membership: account!.membership,
          loadingScreen: false,
        );
      },
      onFailure: (failure) {
        state = state.copyWith(
          loadingScreen: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
