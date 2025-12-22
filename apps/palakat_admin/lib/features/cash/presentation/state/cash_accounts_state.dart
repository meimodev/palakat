import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/models.dart';

import '../../domain/cash_account.dart';

class CashAccountsState {
  final AsyncValue<PaginationResponseWrapper<CashAccount>> accounts;
  final String searchQuery;
  final int pageSize;
  final int currentPage;

  const CashAccountsState({
    this.accounts = const AsyncValue.loading(),
    this.searchQuery = '',
    this.pageSize = 10,
    this.currentPage = 1,
  });

  CashAccountsState copyWith({
    AsyncValue<PaginationResponseWrapper<CashAccount>>? accounts,
    String? searchQuery,
    int? pageSize,
    int? currentPage,
  }) {
    return CashAccountsState(
      accounts: accounts ?? this.accounts,
      searchQuery: searchQuery ?? this.searchQuery,
      pageSize: pageSize ?? this.pageSize,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
