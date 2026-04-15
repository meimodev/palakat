import 'package:flutter/material.dart';
import 'package:palakat_admin/constants.dart';
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

    ref.listen(realtimeEventProvider, (_, next) {
      final event = next.asData?.value;
      if (event == null) {
        return;
      }

      if (!_shouldRefreshForRealtimeEvent(event)) {
        return;
      }

      Future.microtask(_fetchEntries);
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

  Map<String, dynamic>? _extractEventData(RealtimeEvent event) {
    final data = event.payload['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  bool _shouldRefreshForRealtimeEvent(RealtimeEvent event) {
    if (event.name != 'finance.created' &&
        event.name != 'finance.updated' &&
        event.name != 'finance.deleted') {
      return false;
    }

    final churchId = _currentChurchId;
    if (churchId == null) {
      return false;
    }

    final eventData = _extractEventData(event);
    final eventChurchId = eventData?['churchId'];
    final normalizedChurchId = eventChurchId is int
        ? eventChurchId
        : int.tryParse('$eventChurchId');

    return normalizedChurchId == churchId;
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
