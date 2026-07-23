import 'dart:async';

import 'package:flutter/material.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/core/services/church_change_version_poller.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_admin/features/finance/presentation/state/finance_data_state.dart';
import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/repositories.dart';
import 'package:palakat_admin/utils.dart';
import 'package:palakat_shared/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'finance_data_controller.g.dart';

@riverpod
class FinanceDataController extends _$FinanceDataController {
  late final Debouncer _searchDebouncer;
  bool _isDisposed = false;
  int _fetchRequestId = 0;

  @override
  FinanceDataState build() {
    _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));

    final socket = ref.read(socketServiceProvider);
    var previousConnectionStatus = socket.connectionStatus;

    void onSocketStatusChanged() {
      final nextStatus = socket.connectionStatus;
      final didReconnect =
          previousConnectionStatus != SocketConnectionStatus.connected &&
          nextStatus == SocketConnectionStatus.connected;
      previousConnectionStatus = nextStatus;

      if (!didReconnect || _currentChurchId == null) {
        return;
      }

      Future.microtask(_fetchEntries);
    }

    socket.connectionStatusListenable.addListener(onSocketStatusChanged);
    ref.onDispose(() {
      _isDisposed = true;
      socket.connectionStatusListenable.removeListener(onSocketStatusChanged);
      _searchDebouncer.dispose();
    });

    // Phase 5 §9.5 / §9.4: a change signal invalidates, it does not refetch.
    // The poll marks data stale; the admin's refresh tap advances the seen
    // version, and only then do we re-read — never eagerly per event/tick,
    // which was the fan-out amplifier the cost model forbids. Filters are
    // preserved because refresh() re-fetches the current view.
    ref.listen(seenChangeVersionProvider, (previous, next) {
      if (previous != null && next != previous && !_isDisposed) {
        unawaited(refresh());
      }
    });

    final initial = const FinanceDataState();
    Future.microtask(() {
      _fetchEntries();
    });
    return initial;
  }

  int? get _currentChurchId {
    return ref
        .read(authControllerProvider)
        .value
        ?.account
        .membership
        ?.church
        ?.id;
  }

  Future<void> _fetchEntries() async {
    if (_isDisposed) return;
    final requestId = ++_fetchRequestId;
    final snapshot = state;

    state = snapshot.copyWith(entries: const AsyncLoading());
    final repository = ref.read(financeRepositoryProvider);

    // Calculate actual date range from preset
    DateTimeRange? actualDateRange;
    if (snapshot.dateRangePreset == DateRangePreset.custom) {
      actualDateRange = snapshot.customDateRange;
    } else if (snapshot.dateRangePreset != DateRangePreset.allTime) {
      actualDateRange = snapshot.dateRangePreset.getDateRange();
    }

    final result = await repository.fetchFinanceEntries(
      paginationRequest: PaginationRequestWrapper(
        data: GetFetchFinanceEntriesRequest(
          search: snapshot.searchQuery.isEmpty ? null : snapshot.searchQuery,
          startDate: actualDateRange?.start,
          endDate: actualDateRange?.end,
          paymentMethod: snapshot.paymentMethodFilter,
          type: snapshot.typeFilter,
        ),
        page: snapshot.currentPage,
        pageSize: snapshot.pageSize,
        sortBy: 'createdAt',
        sortOrder: 'desc',
      ),
    );

    if (_isDisposed || requestId != _fetchRequestId) return;

    result.when(
      onSuccess: (entries) {
        if (_isDisposed || requestId != _fetchRequestId) return;
        state = state.copyWith(entries: AsyncData(entries));
      },
      onFailure: (failure) {
        if (_isDisposed || requestId != _fetchRequestId) return;
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
