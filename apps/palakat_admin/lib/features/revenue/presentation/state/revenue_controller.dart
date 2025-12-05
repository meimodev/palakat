import 'package:flutter/material.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/repositories.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_admin/features/revenue/presentation/state/revenue_screen_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'revenue_controller.g.dart';

@riverpod
class RevenueController extends _$RevenueController {
  late final Debouncer _searchDebouncer;

  @override
  RevenueScreenState build() {
    _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
    ref.onDispose(() => _searchDebouncer.dispose());

    final initial = const RevenueScreenState();
    Future.microtask(() {
      _fetchRevenues();
    });
    return initial;
  }

  Church get church =>
      ref.read(authControllerProvider).value!.account.membership!.church!;

  Future<void> _fetchRevenues() async {
    state = state.copyWith(revenues: const AsyncLoading());
    final repository = ref.read(revenueRepositoryProvider);

    // Calculate actual date range from preset
    DateTimeRange? actualDateRange;
    if (state.dateRangePreset == DateRangePreset.custom) {
      actualDateRange = state.customDateRange;
    } else if (state.dateRangePreset != DateRangePreset.allTime) {
      actualDateRange = state.dateRangePreset.getDateRange();
    }

    final result = await repository.fetchRevenues(
      paginationRequest: PaginationRequestWrapper(
        data: GetFetchRevenuesRequest(
          churchId: church.id!,
          search: state.searchQuery.isEmpty ? null : state.searchQuery,
          startDate: actualDateRange?.start,
          endDate: actualDateRange?.end,
          paymentMethod: state.paymentMethodFilter,
        ),
        page: state.currentPage,
        pageSize: state.pageSize,
        sortBy: 'id',
        sortOrder: 'desc',
      ),
    );

    result.when(
      onSuccess: (revenues) {
        state = state.copyWith(revenues: AsyncData(revenues));
      },
      onFailure: (failure) {
        state = state.copyWith(
          revenues: AsyncError(
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
    _searchDebouncer(() => _fetchRevenues());
  }

  void onChangedDateRangePreset(DateRangePreset preset) {
    state = state.copyWith(
      dateRangePreset: preset,
      currentPage: 1, // Reset to first page on filter change
    );
    _fetchRevenues();
  }

  void onCustomDateRangeSelected(DateTimeRange? dateRange) {
    state = state.copyWith(
      customDateRange: dateRange,
      currentPage: 1, // Reset to first page on filter change
    );
    _fetchRevenues();
  }

  void onChangedPaymentMethod(PaymentMethod? paymentMethod) {
    state = state.copyWith(
      paymentMethodFilter: paymentMethod,
      currentPage: 1, // Reset to first page on filter change
    );
    _fetchRevenues();
  }

  void onChangedPageSize(int pageSize) {
    state = state.copyWith(
      pageSize: pageSize,
      currentPage: 1, // Reset to first page on page size change
    );
    _fetchRevenues();
  }

  void onChangedPage(int page) {
    state = state.copyWith(currentPage: page);
    _fetchRevenues();
  }

  void onPressedNextPage() {
    state = state.copyWith(currentPage: state.currentPage + 1);
    _fetchRevenues();
  }

  void onPressedPrevPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(currentPage: state.currentPage - 1);
      _fetchRevenues();
    }
  }

  Future<void> refresh() async {
    await _fetchRevenues();
  }

  // Fetch single revenue detail (doesn't mutate state)
  Future<Revenue> fetchRevenue(int revenueId) async {
    final repository = ref.read(revenueRepositoryProvider);
    final result = await repository.fetchRevenue(revenueId: revenueId);

    final revenue = result.when<Revenue>(
      onSuccess: (revenue) => revenue,
      onFailure: (failure) {
        throw AppError.serverError(failure.message, statusCode: failure.code);
      },
    );

    // If we reach here, revenue must be non-null because failure would have thrown
    return revenue!;
  }

  // Save revenue (create or update)
  Future<void> saveRevenue(Revenue revenue) async {
    final repository = ref.read(revenueRepositoryProvider);

    Result<Revenue, Failure> result;

    if (revenue.id != null) {
      final payload = revenue.toJson();
      result = await repository.updateRevenue(
        revenueId: revenue.id!,
        update: payload,
      );
    } else {
      // Create new revenue using CreateRevenueRequest
      final request = CreateRevenueRequest(
        accountNumber: revenue.accountNumber,
        amount: revenue.amount,
        churchId: revenue.churchId,
        activityId: revenue.activityId,
        paymentMethod: revenue.paymentMethod,
      );
      result = await repository.createRevenue(request: request);
    }

    result.when(
      onSuccess: (_) async {
        await _fetchRevenues();
      },
      onFailure: (failure) {
        throw AppError.serverError(failure.message, statusCode: failure.code);
      },
    );
  }

  // Delete revenue
  Future<void> deleteRevenue(int revenueId) async {
    final repository = ref.read(revenueRepositoryProvider);
    final result = await repository.deleteRevenue(revenueId: revenueId);

    result.when(
      onSuccess: (_) async {
        // Refresh the list after delete
        await _fetchRevenues();
      },
      onFailure: (failure) {
        throw AppError.serverError(failure.message, statusCode: failure.code);
      },
    );
  }
}

/// Request model for fetching revenues
class GetFetchRevenuesRequest {
  final int churchId;
  final String? search;
  final DateTime? startDate;
  final DateTime? endDate;
  final PaymentMethod? paymentMethod;

  GetFetchRevenuesRequest({
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
      if (paymentMethod != null)
        'paymentMethod': paymentMethod!.name.toUpperCase(),
    };
  }
}
