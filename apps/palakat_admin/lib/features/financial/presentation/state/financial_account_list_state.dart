import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/models.dart';

part 'financial_account_list_state.freezed.dart';

@freezed
abstract class FinancialAccountListState with _$FinancialAccountListState {
  const factory FinancialAccountListState({
    @Default(AsyncValue.loading())
    AsyncValue<PaginationResponseWrapper<FinancialAccountNumber>> accounts,
    @Default('') String searchQuery,
    @Default(10) int pageSize,
    @Default(1) int currentPage,
    FinanceType? typeFilter,
  }) = _FinancialAccountListState;
}
