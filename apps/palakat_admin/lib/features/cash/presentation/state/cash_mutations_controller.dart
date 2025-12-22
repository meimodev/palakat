import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/utils.dart';

import '../../data/cash_mutation_repository.dart';
import '../../domain/cash_mutation.dart';
import 'cash_mutations_state.dart';

final cashMutationsControllerProvider =
    NotifierProvider<CashMutationsController, CashMutationsState>(
      CashMutationsController.new,
    );

class CashMutationsController extends Notifier<CashMutationsState> {
  late final Debouncer _searchDebouncer;

  @override
  CashMutationsState build() {
    _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
    ref.onDispose(() => _searchDebouncer.dispose());

    final initial = const CashMutationsState();
    Future.microtask(_fetch);
    return initial;
  }

  Future<void> _fetch() async {
    state = state.copyWith(mutations: const AsyncLoading());
    final repo = ref.read(cashMutationRepositoryProvider);

    DateTimeRange? actualRange;
    if (state.dateRangePreset == DateRangePreset.custom) {
      actualRange = state.customDateRange;
    } else if (state.dateRangePreset != DateRangePreset.allTime) {
      actualRange = state.dateRangePreset.getDateRange();
    }

    final result = await repo.fetchMutations(
      page: state.currentPage,
      pageSize: state.pageSize,
      accountId: state.accountId,
      type: state.typeFilter,
      startDate: actualRange?.start,
      endDate: actualRange?.end,
      search: state.searchQuery.isEmpty ? null : state.searchQuery,
      sortBy: 'happenedAt',
      sortOrder: 'desc',
    );

    result.when(
      onSuccess: (mutations) {
        state = state.copyWith(mutations: AsyncData(mutations));
      },
      onFailure: (failure) {
        state = state.copyWith(
          mutations: AsyncError(
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

  void onChangedTypeFilter(CashMutationType? type) {
    if (type == null) {
      state = state.copyWith(clearTypeFilter: true, currentPage: 1);
    } else {
      state = state.copyWith(typeFilter: type, currentPage: 1);
    }
    _fetch();
  }

  void onChangedDateRangePreset(DateRangePreset preset) {
    state = state.copyWith(dateRangePreset: preset, currentPage: 1);
    _fetch();
  }

  void onCustomDateRangeSelected(DateTimeRange? dateRange) {
    state = state.copyWith(customDateRange: dateRange, currentPage: 1);
    _fetch();
  }

  Future<void> refresh() async {
    await _fetch();
  }

  Future<void> transfer({
    required int fromAccountId,
    required int toAccountId,
    required int amount,
    required DateTime happenedAt,
    String? note,
  }) async {
    final repo = ref.read(cashMutationRepositoryProvider);
    final result = await repo.transfer(
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      amount: amount,
      happenedAt: happenedAt,
      note: note,
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
    final repo = ref.read(cashMutationRepositoryProvider);
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
