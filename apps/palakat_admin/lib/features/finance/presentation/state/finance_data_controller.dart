import 'package:flutter/material.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/features/finance/presentation/state/finance_data_state.dart';
import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/repositories.dart';
import 'package:palakat_admin/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'finance_data_controller.g.dart';

@riverpod
class FinanceDataController extends _$FinanceDataController {
  late final Debouncer _searchDebouncer;

  @override
  FinanceDataState build() {
    _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
    ref.onDispose(() => _searchDebouncer.dispose());

    final initial = const FinanceDataState();
    Future.microtask(() {
      _fetchEntries();
    });
    return initial;
  }

  Future<void> _fetchEntries() async {
    state = state.copyWith(entries: const AsyncLoading());
    final repository = ref.read(financeRepositoryProvider);

    // Calculate actual date range from preset
    DateTimeRange? actualDateRange;
    if (state.dateRangePreset == DateRangePreset.custom) {
      actualDateRange = state.customDateRange;
    } else if (state.dateRangePreset != DateRangePreset.allTime) {
      actualDateRange = state.dateRangePreset.getDateRange();
    }

    final result = await repository.fetchFinanceEntries(
      paginationRequest: PaginationRequestWrapper(
        data: GetFetchFinanceEntriesRequest(
          search: state.searchQuery.isEmpty ? null : state.searchQuery,
          startDate: actualDateRange?.start,
          endDate: actualDateRange?.end,
          paymentMethod: state.paymentMethodFilter,
          type: state.typeFilter,
        ),
        page: state.currentPage,
        pageSize: state.pageSize,
        sortBy: 'createdAt',
        sortOrder: 'desc',
      ),
    );

    result.when(
      onSuccess: (entries) {
        state = state.copyWith(entries: AsyncData(entries));
      },
      onFailure: (failure) {
        state = state.copyWith(
          entries: AsyncError(
            AppError.serverError(failure.message, statusCode: failure.code),
            StackTrace.current,
          ),
        );
      },
    );
  }

  void onChangedSearch(String value) {
    state = state.copyWith(searchQuery: value, currentPage: 1);
    _searchDebouncer(() => _fetchEntries());
  }

  void onChangedDateRangePreset(DateRangePreset preset) {
    state = state.copyWith(dateRangePreset: preset, currentPage: 1);
    _fetchEntries();
  }

  void onCustomDateRangeSelected(DateTimeRange? dateRange) {
    state = state.copyWith(customDateRange: dateRange, currentPage: 1);
    _fetchEntries();
  }

  void onChangedPaymentMethod(PaymentMethod? paymentMethod) {
    if (paymentMethod == null) {
      state = state.clearPaymentMethodFilter().copyWith(currentPage: 1);
    } else {
      state = state.copyWith(
        paymentMethodFilter: paymentMethod,
        currentPage: 1,
      );
    }
    _fetchEntries();
  }

  void onChangedType(FinanceEntryType? type) {
    if (type == null) {
      state = state.clearTypeFilter().copyWith(currentPage: 1);
    } else {
      state = state.copyWith(typeFilter: type, currentPage: 1);
    }
    _fetchEntries();
  }

  void onChangedPageSize(int pageSize) {
    state = state.copyWith(pageSize: pageSize, currentPage: 1);
    _fetchEntries();
  }

  void onChangedPage(int page) {
    state = state.copyWith(currentPage: page);
    _fetchEntries();
  }

  void onPressedNextPage() {
    state = state.copyWith(currentPage: state.currentPage + 1);
    _fetchEntries();
  }

  void onPressedPrevPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(currentPage: state.currentPage - 1);
      _fetchEntries();
    }
  }

  Future<void> refresh() async {
    await _fetchEntries();
  }
}
