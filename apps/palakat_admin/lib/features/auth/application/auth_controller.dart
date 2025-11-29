import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/repositories.dart';
import 'package:palakat_admin/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  AsyncValue<AuthResponse?> build() {
    // Initialize from cached auth (Hive) so session is restored on app start
    final cached = ref.read(localStorageServiceProvider).currentAuth;
    return AsyncValue.data(cached);
  }

  Future<void> signIn({
    required String identifier,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signIn(
      AuthCredentials(identifier: identifier, password: password),
    );
    result.when(
      onSuccess: (auth) {
        state = AsyncValue.data(auth);
      },
      onFailure: (failure) {
        state = AsyncValue.error(
          AppError.serverError(failure.message, statusCode: failure.code),
          StackTrace.current,
        );
      },
    );
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signOut();
    result.when(
      onSuccess: (_) {
        state = const AsyncValue.data(null);
      },
      onFailure: (_) {
        // Still clear local state even on network error
        // (Repository already cleared local storage)
        state = const AsyncValue.data(null);
      },
    );
  }

  /// Force sign-out locally without calling the API.
  /// Useful for 401 handling to avoid provider cycles.
  Future<void> forceSignOut() async {
    try {
      await ref.read(localStorageServiceProvider).clear();
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  /// Update the locally cached auth by replacing its Account, then sync provider state.
  /// Safe no-op if there is no current cached auth (e.g., signed out).
  Future<void> updateCachedAccount(Account updatedAccount) async {
    final storage = ref.read(localStorageServiceProvider);
    final current = storage.currentAuth;
    if (current == null) return;

    final newAuth = current.copyWith(account: updatedAccount);
    await storage.saveAuth(newAuth);
    state = AsyncValue.data(newAuth);
  }
}
