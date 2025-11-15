import 'package:flutter/material.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/repositories.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_admin/features/expense/presentation/state/expense_screen_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expense_controller.g.dart';

@riverpod
class ExpenseController extends _$ExpenseController {
  late final Debouncer _searchDebouncer;

  @override
  ExpenseScreenState build() {
    _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
    ref.onDispose(() => _searchDebouncer.dispose());

    final initial = const ExpenseScreenState();
    Future.microtask(() {
      _fetchExpenses();
    });
    return initial;
  }

  Church get church =>
      ref.read(authControllerProvider).value!.account.membership!.church!;

  Future<void> _fetchExpenses() async {
    state = state.copyWith(expenses: const AsyncLoading());
    final repository = ref.read(expenseRepositoryProvider);

    // Calculate actual date range from preset
    DateTimeRange? actualDateRange;
    if (state.dateRangePreset == DateRangePreset.custom) {
      actualDateRange = state.customDateRange;
    } else if (state.dateRangePreset != DateRangePreset.allTime) {
      actualDateRange = state.dateRangePreset.getDateRange();
    }

    final result = await repository.fetchExpenses(
      paginationRequest: PaginationRequestWrapper(
        data: GetFetchExpensesRequest(
          churchId: church.id!,
          search: state.searchQuery.isEmpty ? null : state.searchQuery,
          startDate: actualDateRange?.start,
          endDate: actualDateRange?.end,
          paymentMethod: state.paymentMethodFilter,
        ),
        page: state.currentPage,
        pageSize: state.pageSize,
      ),
    );

    result.when(
      onSuccess: (expenses) {
        state = state.copyWith(expenses: AsyncData(expenses));
      },
      onFailure: (failure) {
        state = state.copyWith(
          expenses: AsyncError(
            AppError.serverError(failure.message, statusCode: failure.code),
            StackTrace.current,
          ),
        );
      },
    );
  }

  void onChangedSearch(String value) {
    state = state.copyWith(
      searchQuery: value,
      currentPage: 1, // Reset to first page on search
    );
    _searchDebouncer(() => _fetchExpenses());
  }

  void onChangedDateRangePreset(DateRangePreset preset) {
    state = state.copyWith(
      dateRangePreset: preset,
      currentPage: 1, // Reset to first page on filter change
    );
    _fetchExpenses();
  }

  void onCustomDateRangeSelected(DateTimeRange? dateRange) {
    state = state.copyWith(
      customDateRange: dateRange,
      currentPage: 1, // Reset to first page on filter change
    );
    _fetchExpenses();
  }

  void onChangedPaymentMethod(PaymentMethod? paymentMethod) {
    state = state.copyWith(
      paymentMethodFilter: paymentMethod,
      currentPage: 1, // Reset to first page on filter change
    );
    _fetchExpenses();
  }

  void onChangedPageSize(int pageSize) {
    state = state.copyWith(
      pageSize: pageSize,
      currentPage: 1, // Reset to first page on page size change
    );
    _fetchExpenses();
  }

  void onChangedPage(int page) {
    state = state.copyWith(currentPage: page);
    _fetchExpenses();
  }

  void onPressedNextPage() {
    state = state.copyWith(currentPage: state.currentPage + 1);
    _fetchExpenses();
  }

  void onPressedPrevPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(currentPage: state.currentPage - 1);
      _fetchExpenses();
    }
  }

  Future<void> refresh() async {
    await _fetchExpenses();
  }

  // Fetch single expense detail (doesn't mutate state)
  Future<Expense> fetchExpense(int expenseId) async {
    final repository = ref.read(expenseRepositoryProvider);
    final result = await repository.fetchExpense(expenseId: expenseId);

    final expense = result.when<Expense>(
      onSuccess: (expense) => expense,
      onFailure: (failure) {
        throw AppError.serverError(failure.message, statusCode: failure.code);
      },
    );

    // If we reach here, expense must be non-null because failure would have thrown
    return expense!;
  }

  // Save expense (create or update)
  Future<void> saveExpense(Expense expense) async {
    final repository = ref.read(expenseRepositoryProvider);

    final payload = expense.toJson();
    Result<Expense, Failure> result;

    if (expense.id != null) {
      result = await repository.updateExpense(expenseId: expense.id!, update: payload);
    } else {
      result = await repository.createExpense(data: payload);
    }

    result.when(
      onSuccess: (_) async {
        await _fetchExpenses();
      },
      onFailure: (failure) {
        throw AppError.serverError(failure.message, statusCode: failure.code);
      },
    );
  }

  // Delete expense
  Future<void> deleteExpense(int expenseId) async {
    final repository = ref.read(expenseRepositoryProvider);
    final result = await repository.deleteExpense(expenseId: expenseId);

    result.when(
      onSuccess: (_) async {
        // Refresh the list after delete
        await _fetchExpenses();
      },
      onFailure: (failure) {
        throw AppError.serverError(failure.message, statusCode: failure.code);
      },
    );
  }
}

/// Request model for fetching expenses
class GetFetchExpensesRequest {
  final int churchId;
  final String? search;
  final DateTime? startDate;
  final DateTime? endDate;
  final PaymentMethod? paymentMethod;

  GetFetchExpensesRequest({
    required this.churchId,
    this.search,
    this.startDate,
    this.endDate,
    this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'churchId': churchId,
      if (search != null) 'search': search,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (paymentMethod != null) 'paymentMethod': paymentMethod!.name.toUpperCase(),
    };
  }
}
