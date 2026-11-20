import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/memory/memory_audit_repository.dart';
import '../data/memory/memory_context.dart';
import '../data/memory/memory_export_repository.dart';
import '../data/memory/memory_file_repository.dart';
import '../data/memory/memory_notification_repository.dart';
import '../data/memory/memory_org_repository.dart';
import '../data/memory/memory_people_repository.dart';
import '../data/memory/memory_role_repository.dart';
import '../data/memory/memory_session_repository.dart';
import '../data/memory/memory_workspace_repository.dart';
import '../data/repositories/audit_repository.dart';
import '../data/repositories/export_repository.dart';
import '../data/repositories/file_repository.dart';
import '../data/repositories/notification_repository.dart';
import '../data/repositories/org_repository.dart';
import '../data/repositories/people_repository.dart';
import '../data/repositories/role_repository.dart';
import '../data/repositories/session_repository.dart';
import '../data/repositories/workspace_repository.dart';
import 'clock.dart';
import 'revision.dart';
import 'seed.dart';

/// The shared base of every in-memory repository: the store, the clock and
/// the revision bump. Later milestones build their repositories on it.
final memoryContextProvider = Provider<MemoryContext>(
  (ref) => MemoryContext(
    ref.watch(seedProvider),
    ref.watch(clockProvider),
    () => ref.read(revisionProvider.notifier).bump(),
  ),
);

// The core repositories (README 4.1). Overriding one with a Supabase
// implementation later is the seam (D1).

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => MemorySessionRepository(ref.watch(memoryContextProvider)),
);

final workspaceRepositoryProvider = Provider<WorkspaceRepository>(
  (ref) => MemoryWorkspaceRepository(ref.watch(memoryContextProvider)),
);

final peopleRepositoryProvider = Provider<PeopleRepository>(
  (ref) => MemoryPeopleRepository(ref.watch(memoryContextProvider)),
);

final orgRepositoryProvider = Provider<OrgRepository>(
  (ref) => MemoryOrgRepository(ref.watch(memoryContextProvider)),
);

final roleRepositoryProvider = Provider<RoleRepository>((ref) {
  final r = MemoryRoleRepository(ref.watch(memoryContextProvider));
  ref.onDispose(r.dispose);
  return r;
});

final auditRepositoryProvider = Provider<AuditRepository>(
  (ref) => MemoryAuditRepository(ref.watch(memoryContextProvider)),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => MemoryNotificationRepository(ref.watch(memoryContextProvider)),
);

final fileRepositoryProvider = Provider<FileRepository>(
  (ref) => MemoryFileRepository(ref.watch(memoryContextProvider)),
);

final exportRepositoryProvider = Provider<ExportRepository>(
  (ref) => MemoryExportRepository(ref.watch(memoryContextProvider)),
);
