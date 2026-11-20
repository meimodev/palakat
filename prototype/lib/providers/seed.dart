import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/seed/build_seed.dart';
import '../data/seed/seed_store.dart';
import 'launch.dart';

/// The in-memory state, built once per ProviderScope, which is once per
/// launch (README 3.3, D6).
final seedProvider = Provider<SeedStore>((ref) {
  final l = ref.watch(launchProvider);
  return buildSeed(anchor: l.anchor, now: l.now);
});
