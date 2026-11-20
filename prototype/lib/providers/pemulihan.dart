import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/memory/memory_recovery_repository.dart';
import '../data/repositories/recovery_repository.dart';
import 'core_repositories.dart';

/// Account recovery (P4). Not in README 4.1; M6 adds it in its own files
/// until the merge folds it into the core repositories (request R1).
final recoveryRepositoryProvider = Provider<RecoveryRepository>(
  (ref) => MemoryRecoveryRepository(ref.watch(memoryContextProvider)),
);
