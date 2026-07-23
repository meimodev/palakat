import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_shared/core/config/endpoint.dart';
import 'package:palakat_shared/core/services/http_service.dart';

/// Phase 5 §9.5 — the palakat_admin poll transport that replaces its socket
/// (decision #72). `palakat_admin` is Flutter web and needs in-app live
/// refresh, not background push. Instead of holding a socket open it polls a
/// cheap per-church change-version endpoint; a version change marks data stale
/// (§9.4). It never refetches on its own — the read happens when the admin
/// acknowledges the update.

/// A nullable version holder. Riverpod 3 dropped `StateProvider` from the main
/// surface, so this is the idiomatic tiny mutable provider.
class ChangeVersionNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  // ignore: use_setters_to_change_properties
  void set(int? value) => state = value;
}

/// The latest version seen from the backend; null until the first poll.
final latestChangeVersionProvider =
    NotifierProvider<ChangeVersionNotifier, int?>(ChangeVersionNotifier.new);

/// The version the admin has acknowledged. When [latestChangeVersionProvider]
/// moves past this, church data is stale and the shell shows a refresh
/// affordance. Advancing this (the admin taps refresh) is what drives the data
/// controllers to re-read — a change signal invalidates, it never refetches on
/// its own (§9.4 — the eager refetch is the fan-out amplifier the cost model
/// forbids).
final seenChangeVersionProvider =
    NotifierProvider<ChangeVersionNotifier, int?>(ChangeVersionNotifier.new);

/// True when the backend holds data newer than what the admin has acknowledged.
final hasStaleDataProvider = Provider<bool>((ref) {
  final latest = ref.watch(latestChangeVersionProvider);
  final seen = ref.watch(seenChangeVersionProvider);
  return latest != null && latest != seen;
});

const _pollInterval = Duration(seconds: 30);

/// Mounts near the app root. Polls the change-version endpoint every 30s while
/// the tab is visible and stops when it is hidden — ~2 req/min per working
/// admin, 0 at night, so the backend instance still scales to zero (§9.5).
class ChurchChangeVersionPoller extends ConsumerStatefulWidget {
  const ChurchChangeVersionPoller({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ChurchChangeVersionPoller> createState() =>
      _ChurchChangeVersionPollerState();
}

class _ChurchChangeVersionPollerState
    extends ConsumerState<ChurchChangeVersionPoller>
    with WidgetsBindingObserver {
  Timer? _timer;
  int? _churchId;
  bool _inFlight = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // On web, a hidden tab reports `hidden`/`paused`; a focused one, `resumed`.
    if (state == AppLifecycleState.resumed) {
      _start();
    } else {
      _stop();
    }
  }

  void _start() {
    _timer ??= Timer.periodic(_pollInterval, (_) => unawaited(_poll()));
    unawaited(_poll()); // poll immediately on (re)gaining focus
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  int? _currentChurchId() =>
      ref.read(authControllerProvider).value?.account.membership?.church?.id;

  Future<void> _poll() async {
    if (_inFlight) return;
    final churchId = _currentChurchId();
    if (churchId == null) return;

    // Church switch / first auth: drop the baseline so a fresh church does not
    // inherit the previous one's version as already-seen.
    if (churchId != _churchId) {
      _churchId = churchId;
      ref.read(latestChangeVersionProvider.notifier).set(null);
      ref.read(seenChangeVersionProvider.notifier).set(null);
    }

    _inFlight = true;
    try {
      final dio = ref.read(dioInstanceProvider);
      final res = await dio.get<Map<String, dynamic>>(
        Endpoints.churchChangeVersion(churchId: churchId),
      );
      final raw = res.data?['version'];
      final version = raw is num ? raw.toInt() : int.tryParse('$raw');
      if (version == null || !mounted) return;

      // The first reading for a church is the baseline — no stale banner for it.
      if (ref.read(seenChangeVersionProvider) == null) {
        ref.read(seenChangeVersionProvider.notifier).set(version);
      }
      ref.read(latestChangeVersionProvider.notifier).set(version);
    } on DioException {
      // Best-effort: a failed poll just means no update this tick.
    } finally {
      _inFlight = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
