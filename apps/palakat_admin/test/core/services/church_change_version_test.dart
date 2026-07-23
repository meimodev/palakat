import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_admin/core/services/church_change_version_poller.dart';

/// Phase 5 §9.5 — the staleness signal that drives the shell's refresh banner
/// and, on acknowledgement, the data controllers. A change invalidates; it
/// never refetches on its own (§9.4).
void main() {
  test('hasStaleData tracks latest vs acknowledged version', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    ChangeVersionNotifier latest() =>
        container.read(latestChangeVersionProvider.notifier);
    ChangeVersionNotifier seen() =>
        container.read(seenChangeVersionProvider.notifier);
    bool stale() => container.read(hasStaleDataProvider);

    // Nothing polled yet — not stale.
    expect(stale(), isFalse);

    // First poll establishes the baseline (poller sets seen == latest): no banner.
    latest().set(5);
    seen().set(5);
    expect(stale(), isFalse);

    // A later poll finds newer data — stale, banner shows.
    latest().set(6);
    expect(stale(), isTrue);

    // Admin taps refresh (seen advances to latest) — no longer stale.
    seen().set(6);
    expect(stale(), isFalse);
  });
}
