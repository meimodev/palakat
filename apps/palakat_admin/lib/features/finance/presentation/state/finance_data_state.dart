import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/models.dart';

class FinanceDataState {
  final AsyncValue<PaginationResponseWrapper<FinanceEntry>> entries;
  final String searchQuery;
  final DateRangePreset dateRangePreset;
  final DateTimeRange? customDateRange;
  final PaymentMethod? paymentMethodFilter;
  final FinanceEntryType? typeFilter;
  final int currentPage;
  final int pageSize;

  const FinanceDataState({
    this.entries = const AsyncLoading(),
    this.searchQuery = '',
    this.dateRangePreset = DateRangePreset.allTime,
    this.customDateRange,
    this.paymentMethodFilter,
    this.typeFilter,
    this.currentPage = 1,
    this.pageSize = 10,
  });

  FinanceDataState copyWith({
    AsyncValue<PaginationResponseWrapper<FinanceEntry>>? entries,
    String? searchQuery,
    DateRangePreset? dateRangePreset,
    DateTimeRange? customDateRange,
    PaymentMethod? paymentMethodFilter,
    FinanceEntryType? typeFilter,
    int? currentPage,
    int? pageSize,
  }) {
    return FinanceDataState(
      entries: entries ?? this.entries,
      searchQuery: searchQuery ?? this.searchQuery,
      dateRangePreset: dateRangePreset ?? this.dateRangePreset,
      customDateRange: customDateRange ?? this.customDateRange,
      paymentMethodFilter: paymentMethodFilter ?? this.paymentMethodFilter,
      typeFilter: typeFilter ?? this.typeFilter,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  FinanceDataState clearPaymentMethodFilter() {
    return FinanceDataState(
      entries: entries,
      searchQuery: searchQuery,
      dateRangePreset: dateRangePreset,
      customDateRange: customDateRange,
      paymentMethodFilter: null,
      typeFilter: typeFilter,
      currentPage: currentPage,
      pageSize: pageSize,
    );
  }

  FinanceDataState clearTypeFilter() {
    return FinanceDataState(
      entries: entries,
      searchQuery: searchQuery,
      dateRangePreset: dateRangePreset,
      customDateRange: customDateRange,
      paymentMethodFilter: paymentMethodFilter,
      typeFilter: null,
      currentPage: currentPage,
      pageSize: pageSize,
    );
  }
}
