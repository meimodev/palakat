import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/models.dart';

part 'expense_screen_state.freezed.dart';

@freezed
abstract class ExpenseScreenState with _$ExpenseScreenState {
  const factory ExpenseScreenState({
    @Default(AsyncValue.loading()) AsyncValue<PaginationResponseWrapper<Expense>> expenses,
    @Default('') String searchQuery,
    @Default(DateRangePreset.allTime) DateRangePreset dateRangePreset,
    DateTimeRange? customDateRange,
    PaymentMethod? paymentMethodFilter,
    @Default(10) int pageSize,
    @Default(1) int currentPage,
  }) = _ExpenseScreenState;
}
