import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/core/services/church_change_version_poller.dart';
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

    // Phase 5 §9.5 / §9.4: a change signal invalidates, it does not refetch.
    // The admin's refresh tap advances the seen version; only then re-read.
    ref.listen(seenChangeVersionProvider, (previous, next) {
      if (previous != null && next != previous) {
        unawaited(refresh());
      }
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
