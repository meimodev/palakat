import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/models.dart';

import '../../domain/cash_mutation.dart';

class CashMutationsState {
  final AsyncValue<PaginationResponseWrapper<CashMutation>> mutations;
  final String searchQuery;
  final int pageSize;
  final int currentPage;

  final int? accountId;
  final CashMutationType? typeFilter;

  final DateRangePreset dateRangePreset;
  final DateTimeRange? customDateRange;

  const CashMutationsState({
    this.mutations = const AsyncValue.loading(),
    this.searchQuery = '',
    this.pageSize = 10,
    this.currentPage = 1,
    this.accountId,
    this.typeFilter,
    this.dateRangePreset = DateRangePreset.allTime,
    this.customDateRange,
  });

  CashMutationsState copyWith({
    AsyncValue<PaginationResponseWrapper<CashMutation>>? mutations,
    String? searchQuery,
    int? pageSize,
    int? currentPage,
    int? accountId,
    bool clearAccountId = false,
    CashMutationType? typeFilter,
    bool clearTypeFilter = false,
    DateRangePreset? dateRangePreset,
    DateTimeRange? customDateRange,
  }) {
    return CashMutationsState(
      mutations: mutations ?? this.mutations,
      searchQuery: searchQuery ?? this.searchQuery,
      pageSize: pageSize ?? this.pageSize,
      currentPage: currentPage ?? this.currentPage,
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
      dateRangePreset: dateRangePreset ?? this.dateRangePreset,
      customDateRange: customDateRange ?? this.customDateRange,
    );
  }
}
