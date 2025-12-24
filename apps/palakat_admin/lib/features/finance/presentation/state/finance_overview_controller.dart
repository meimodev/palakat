import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/repositories.dart';

import 'finance_overview_state.dart';

final financeOverviewControllerProvider =
    NotifierProvider<FinanceOverviewController, FinanceOverviewState>(
      FinanceOverviewController.new,
    );

class FinanceOverviewController extends Notifier<FinanceOverviewState> {
  @override
  FinanceOverviewState build() {
    final initial = const FinanceOverviewState();
    Future.microtask(_fetch);
    return initial;
  }

  Future<void> _fetch() async {
    state = state.copyWith(overview: const AsyncLoading());

    final repo = ref.read(financeRepositoryProvider);
    final result = await repo.fetchOverview();

    result.when(
      onSuccess: (overview) {
        state = state.copyWith(overview: AsyncData(overview));
      },
      onFailure: (failure) {
        state = state.copyWith(
          overview: AsyncError(
            AppError.serverError(failure.message, statusCode: failure.code),
            StackTrace.current,
          ),
        );
      },
    );
  }

  Future<void> refresh() async {
    await _fetch();
  }
}
