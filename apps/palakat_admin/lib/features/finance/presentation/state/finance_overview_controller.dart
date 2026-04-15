import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/repositories.dart';
import 'package:palakat_shared/services.dart';

import 'finance_overview_state.dart';

final financeOverviewControllerProvider =
    NotifierProvider<FinanceOverviewController, FinanceOverviewState>(
      FinanceOverviewController.new,
    );

class FinanceOverviewController extends Notifier<FinanceOverviewState> {
  @override
  FinanceOverviewState build() {
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

      Future.microtask(_fetch);
    }

    socket.connectionStatusListenable.addListener(onSocketStatusChanged);
    ref.onDispose(() {
      socket.connectionStatusListenable.removeListener(onSocketStatusChanged);
    });

    ref.listen(realtimeEventProvider, (_, next) {
      final event = next.asData?.value;
      if (event == null) {
        return;
      }

      if (!_shouldRefreshForRealtimeEvent(event)) {
        return;
      }

      Future.microtask(_fetch);
    });

    final initial = const FinanceOverviewState();
    Future.microtask(_fetch);
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

  Future<void> _fetch() async {
    state = state.copyWith(overview: const AsyncLoading());

    final repo = ref.read(financeRepositoryProvider);
    final result = await repo.fetchOverview();

    result.when(
      onSuccess: (overview) {
        state = state.copyWith(overview: AsyncData(overview));
      },
      onFailure: (failure) {
        state = state.copyWith(
          overview: AsyncError(
            AppError.serverError(failure.message, statusCode: failure.code),
            StackTrace.current,
          ),
        );
      },
    );
  }

  Future<void> refresh() async {
    await _fetch();
  }
}
