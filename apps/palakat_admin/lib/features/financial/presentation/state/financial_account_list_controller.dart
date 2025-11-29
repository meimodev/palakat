import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_admin/features/financial/presentation/state/financial_account_list_state.dart';
import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/repositories.dart';
import 'package:palakat_admin/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'financial_account_list_controller.g.dart';

@riverpod
class FinancialAccountListController extends _$FinancialAccountListController {
  late final Debouncer _searchDebouncer;

  @override
  FinancialAccountListState build() {
    _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
    ref.onDispose(() => _searchDebouncer.dispose());

    final initial = const FinancialAccountListState();
    Future.microtask(() {
      _fetchAccounts();
    });
    return initial;
  }

  Church get church =>
      ref.read(authControllerProvider).value!.account.membership!.church!;

  Future<void> _fetchAccounts() async {
    state = state.copyWith(accounts: const AsyncLoading());
    final repository = ref.read(financialAccountRepositoryProvider);

    final result = await repository.getAll(
      paginationRequest: PaginationRequestWrapper(
        data: GetFinancialAccountsRequest(
          churchId: church.id!,
          search: state.searchQuery.isEmpty ? null : state.searchQuery,
        ),
        page: state.currentPage,
        pageSize: state.pageSize,
      ),
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
    _searchDebouncer(() => _fetchAccounts());
  }

  void onChangedPageSize(int pageSize) {
    state = state.copyWith(pageSize: pageSize, currentPage: 1);
    _fetchAccounts();
  }

  void onChangedPage(int page) {
    state = state.copyWith(currentPage: page);
    _fetchAccounts();
  }

  void onPressedNextPage() {
    state = state.copyWith(currentPage: state.currentPage + 1);
    _fetchAccounts();
  }

  void onPressedPrevPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(currentPage: state.currentPage - 1);
      _fetchAccounts();
    }
  }

  Future<void> refresh() async {
    await _fetchAccounts();
  }

  Future<void> deleteAccount(int accountId) async {
    final repository = ref.read(financialAccountRepositoryProvider);
    final result = await repository.delete(id: accountId);

    result.when(
      onSuccess: (_) async {
        await _fetchAccounts();
      },
      onFailure: (failure) {
        throw AppError.serverError(failure.message, statusCode: failure.code);
      },
    );
  }

  Future<FinancialAccountNumber> createAccount({
    required String accountNumber,
    required FinanceType type,
    String? description,
  }) async {
    final repository = ref.read(financialAccountRepositoryProvider);
    final result = await repository.create(
      data: {
        'accountNumber': accountNumber,
        'type': type.value,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );

    return result.when(
      onSuccess: (account) {
        _fetchAccounts();
        return account;
      },
      onFailure: (failure) {
        throw AppError.serverError(failure.message, statusCode: failure.code);
      },
    )!;
  }

  Future<FinancialAccountNumber> updateAccount({
    required int id,
    required String accountNumber,
    required FinanceType type,
    String? description,
  }) async {
    final repository = ref.read(financialAccountRepositoryProvider);
    final result = await repository.update(
      id: id,
      data: {
        'accountNumber': accountNumber,
        'type': type.value,
        'description': description,
      },
    );

    return result.when(
      onSuccess: (account) {
        _fetchAccounts();
        return account;
      },
      onFailure: (failure) {
        throw AppError.serverError(failure.message, statusCode: failure.code);
      },
    )!;
  }
}

// GetFinancialAccountsRequest is now imported from palakat_shared via palakat_admin/models.dart
