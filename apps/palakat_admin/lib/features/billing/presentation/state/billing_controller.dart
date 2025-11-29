import 'package:flutter/material.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/repositories.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'billing_screen_state.dart';

part 'billing_controller.g.dart';

@riverpod
class BillingController extends _$BillingController {
  BillingRepository get billingRepo => ref.read(billingRepositoryProvider);

  @override
  BillingScreenState build() {
    // Fetch data on initialization
    Future.microtask(() {
      fetchBillingItems();
      fetchPaymentHistory();
    });

    return const BillingScreenState();
  }

  Future<void> fetchBillingItems() async {
    try {
      state = state.copyWith(billingItems: const AsyncValue.loading());

      final result = await billingRepo.getBillingItemsAsync();

      result.when(
        onSuccess: (data) =>
            state = state.copyWith(billingItems: AsyncValue.data(data)),
        onFailure: (failure) => state = state.copyWith(
          billingItems: AsyncValue.error(failure.message, StackTrace.current),
        ),
      );
    } catch (e, st) {
      state = state.copyWith(billingItems: AsyncValue.error(e, st));
    }
  }

  Future<void> fetchPaymentHistory() async {
    try {
      state = state.copyWith(paymentHistory: const AsyncValue.loading());

      final result = await billingRepo.getPaymentHistoryAsync();

      result.when(
        onSuccess: (data) =>
            state = state.copyWith(paymentHistory: AsyncValue.data(data)),
        onFailure: (failure) => state = state.copyWith(
          paymentHistory: AsyncValue.error(failure.message, StackTrace.current),
        ),
      );
    } catch (e, st) {
      state = state.copyWith(paymentHistory: AsyncValue.error(e, st));
    }
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, page: 0);
  }

  void updateStatusFilter(BillingStatus? status) {
    state = state.copyWith(statusFilter: status, page: 0);
  }

  void updateDateRange(DateTimeRange? dateRange) {
    state = state.copyWith(dateRange: dateRange, page: 0);
  }

  void updatePage(int page) {
    state = state.copyWith(page: page);
  }

  void updateRowsPerPage(int rowsPerPage) {
    state = state.copyWith(rowsPerPage: rowsPerPage, page: 0);
  }

  Future<void> recordPayment({
    required String billingItemId,
    required PaymentMethod paymentMethod,
    String? transactionId,
    String? notes,
  }) async {
    try {
      final result = await billingRepo.recordPaymentAsync(
        billingItemId: billingItemId,
        paymentMethod: paymentMethod,
        transactionId: transactionId,
        notes: notes,
      );

      result.when(
        onSuccess: (_) async {
          // Refresh both lists after successful payment
          await fetchBillingItems();
          await fetchPaymentHistory();
        },
        onFailure: (failure) => throw Exception(failure.message),
      );
    } catch (e) {
      rethrow;
    }
  }

  List<BillingItem> getFilteredBillingItems() {
    final items = state.billingItems.value ?? [];
    return billingRepo.filterBillingItems(
      items,
      state.searchQuery,
      state.statusFilter,
      state.dateRange,
    );
  }

  List<BillingItem> getPaginatedBillingItems() {
    final filteredItems = getFilteredBillingItems();
    return billingRepo.getPaginatedBillingItems(
      filteredItems,
      state.page,
      state.rowsPerPage,
    );
  }

  List<BillingItem> getOverdueItems() {
    final items = state.billingItems.value ?? [];
    return items
        .where((item) => item.status == BillingStatus.overdue || item.isOverdue)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }
}
