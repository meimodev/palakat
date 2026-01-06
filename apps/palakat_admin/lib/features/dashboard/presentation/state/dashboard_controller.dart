import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/repositories.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dashboard_screen_state.dart';

part 'dashboard_controller.g.dart';

@riverpod
class DashboardController extends _$DashboardController {
  @override
  DashboardScreenState build() {
    final initial = const DashboardScreenState();
    Future.microtask(refresh);
    return initial;
  }

  Church get church =>
      ref.read(authControllerProvider).value!.account.membership!.church!;

  Future<void> refresh() async {
    await fetchHome();
    await Future.wait([fetchPendingApprovals()]);
  }

  Future<void> fetchHome() async {
    state = state.copyWith(home: const AsyncLoading());
    try {
      final repo = ref.read(homeRepositoryProvider);
      final result = await repo.getHomeDashboard(
        request: const GetHomeDashboardRequest(),
      );
      result.when(
        onSuccess: (data) {
          state = state.copyWith(home: AsyncData(data));
        },
        onFailure: (failure) {
          state = state.copyWith(
            home: AsyncError(
              AppError.serverError(failure.message, statusCode: failure.code),
              StackTrace.current,
            ),
          );
        },
      );
    } catch (e, st) {
      state = state.copyWith(home: AsyncError(e, st));
    }
  }

  Future<void> fetchMemberCounts() async {
    state = state.copyWith(memberCounts: const AsyncLoading());
    try {
      final repo = ref.read(membershipRepositoryProvider);
      final result = await repo.fetchCounts(
        GetFetchAccountsRequest(churchId: church.id),
      );

      result.when(
        onSuccess: (data) {
          final counts = MemberScreenStateCounts(
            total: data['total'] ?? 0,
            claimed: data['claimed'] ?? 0,
            baptized: data['baptized'] ?? 0,
            sidi: data['sidi'] ?? 0,
          );
          state = state.copyWith(memberCounts: AsyncData(counts));
        },
        onFailure: (failure) {
          state = state.copyWith(
            memberCounts: AsyncError(
              AppError.serverError(failure.message, statusCode: failure.code),
              StackTrace.current,
            ),
          );
        },
      );
    } catch (e, st) {
      state = state.copyWith(memberCounts: AsyncError(e, st));
    }
  }

  Future<void> fetchFinanceOverview() async {
    state = state.copyWith(financeOverview: const AsyncLoading());
    try {
      final repo = ref.read(financeRepositoryProvider);
      final result = await repo.fetchOverview();
      result.when(
        onSuccess: (overview) {
          state = state.copyWith(financeOverview: AsyncData(overview));
        },
        onFailure: (failure) {
          state = state.copyWith(
            financeOverview: AsyncError(
              AppError.serverError(failure.message, statusCode: failure.code),
              StackTrace.current,
            ),
          );
        },
      );
    } catch (e, st) {
      state = state.copyWith(financeOverview: AsyncError(e, st));
    }
  }

  Future<void> fetchRecentFinanceEntries() async {
    state = state.copyWith(financeEntries: const AsyncLoading());
    try {
      final repo = ref.read(financeRepositoryProvider);
      final result = await repo.fetchFinanceEntries(
        paginationRequest: PaginationRequestWrapper(
          data: const GetFetchFinanceEntriesRequest(),
          page: 1,
          pageSize: 5,
          sortBy: 'createdAt',
          sortOrder: 'desc',
        ),
      );

      result.when(
        onSuccess: (entries) {
          state = state.copyWith(financeEntries: AsyncData(entries));
        },
        onFailure: (failure) {
          state = state.copyWith(
            financeEntries: AsyncError(
              AppError.serverError(failure.message, statusCode: failure.code),
              StackTrace.current,
            ),
          );
        },
      );
    } catch (e, st) {
      state = state.copyWith(financeEntries: AsyncError(e, st));
    }
  }

  Future<void> fetchPendingApprovals() async {
    state = state.copyWith(pendingApprovals: const AsyncLoading());
    try {
      final repo = ref.read(approverRepositoryProvider);
      final result = await repo.fetchApprovers(
        paginationRequest: PaginationRequestWrapper(
          data: {'status': ApprovalStatus.unconfirmed.name.toUpperCase()},
          page: 1,
          pageSize: 50,
          sortBy: 'id',
          sortOrder: 'desc',
        ),
      );

      result.when(
        onSuccess: (approvers) {
          state = state.copyWith(pendingApprovals: AsyncData(approvers));
        },
        onFailure: (failure) {
          state = state.copyWith(
            pendingApprovals: AsyncError(
              AppError.serverError(failure.message, statusCode: failure.code),
              StackTrace.current,
            ),
          );
        },
      );
    } catch (e, st) {
      state = state.copyWith(pendingApprovals: AsyncError(e, st));
    }
  }
}
