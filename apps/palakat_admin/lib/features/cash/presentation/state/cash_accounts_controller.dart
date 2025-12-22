import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/utils.dart';

import '../../data/cash_account_repository.dart';
import 'cash_accounts_state.dart';

final cashAccountsControllerProvider =
    NotifierProvider<CashAccountsController, CashAccountsState>(
      CashAccountsController.new,
    );

class CashAccountsController extends Notifier<CashAccountsState> {
  late final Debouncer _searchDebouncer;

  @override
  CashAccountsState build() {
    _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
    ref.onDispose(() => _searchDebouncer.dispose());

    final initial = const CashAccountsState();
    Future.microtask(_fetch);
    return initial;
  }

  Future<void> _fetch() async {
    state = state.copyWith(accounts: const AsyncLoading());
    final repo = ref.read(cashAccountRepositoryProvider);

    final result = await repo.fetchAccounts(
      page: state.currentPage,
      pageSize: state.pageSize,
      search: state.searchQuery.isEmpty ? null : state.searchQuery,
      sortBy: 'createdAt',
      sortOrder: 'desc',
    );

    result.when(
      onSuccess: (accounts) {
        state = state.copyWith(accounts: AsyncData(accounts));
      },
      onFailure: (failure) {
        state = state.copyWith(
          accounts: AsyncError(
            AppError.serverError(failure.message, statusCode: failure.code),
            StackTrace.current,
          ),
        );
      },
    );
  }

  void onChangedSearch(String value) {
    state = state.copyWith(searchQuery: value, currentPage: 1);
    _searchDebouncer(() => _fetch());
  }

  void onChangedPageSize(int pageSize) {
    state = state.copyWith(pageSize: pageSize, currentPage: 1);
    _fetch();
  }

  void onChangedPage(int page) {
    state = state.copyWith(currentPage: page);
    _fetch();
  }

  void onPressedNextPage() {
    state = state.copyWith(currentPage: state.currentPage + 1);
    _fetch();
  }

  void onPressedPrevPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(currentPage: state.currentPage - 1);
      _fetch();
    }
  }

  Future<void> refresh() async {
    await _fetch();
  }

  Future<void> create({
    required String name,
    String? currency,
    int? openingBalance,
  }) async {
    final repo = ref.read(cashAccountRepositoryProvider);
    final result = await repo.create(
      name: name,
      currency: currency,
      openingBalance: openingBalance,
    );

    result.when(
      onSuccess: (_) async {
        await _fetch();
      },
      onFailure: (failure) {
        throw AppError.serverError(failure.message, statusCode: failure.code);
      },
    );
  }

  Future<void> update({
    required int id,
    String? name,
    String? currency,
    int? openingBalance,
  }) async {
    final repo = ref.read(cashAccountRepositoryProvider);
    final result = await repo.update(
      id: id,
      name: name,
      currency: currency,
      openingBalance: openingBalance,
    );

    result.when(
      onSuccess: (_) async {
        await _fetch();
      },
      onFailure: (failure) {
        throw AppError.serverError(failure.message, statusCode: failure.code);
      },
    );
  }

  Future<void> delete(int id) async {
    final repo = ref.read(cashAccountRepositoryProvider);
    final result = await repo.delete(id: id);

    result.when(
      onSuccess: (_) async {
        await _fetch();
      },
      onFailure: (failure) {
        throw AppError.serverError(failure.message, statusCode: failure.code);
      },
    );
  }
}
