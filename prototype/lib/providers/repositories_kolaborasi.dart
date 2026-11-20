import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/memory/memory_approver_table_repository.dart';
import '../data/memory/memory_attendance_repository.dart';
import '../data/memory/memory_fund_request_repository.dart';
import '../data/memory/memory_panitia_repository.dart';
import '../data/memory/memory_service_repository.dart';
import '../data/repositories/approver_table_repository.dart';
import '../data/repositories/attendance_repository.dart';
import '../data/repositories/fund_request_repository.dart';
import '../data/repositories/panitia_repository.dart';
import '../data/repositories/service_repository.dart';
import 'core_repositories.dart';
import 'repositories_keuangan.dart';
import 'repositories_sekretariat.dart';

// The Collaboration repositories (README 4.5). Overriding one with a
// Supabase implementation later is the seam (D1).

final panitiaRepositoryProvider = Provider<PanitiaRepository>(
  (ref) => MemoryPanitiaRepository(
    ref.watch(memoryContextProvider),
    ref.watch(orgRepositoryProvider),
    ref.watch(documentRepositoryProvider),
  ),
);

final serviceRepositoryProvider = Provider<ServiceRepository>(
  (ref) => MemoryServiceRepository(ref.watch(memoryContextProvider)),
);

final attendanceRepositoryProvider = Provider<AttendanceRepository>(
  (ref) => MemoryAttendanceRepository(ref.watch(memoryContextProvider)),
);

final fundRequestRepositoryProvider = Provider<FundRequestRepository>(
  (ref) => MemoryFundRequestRepository(
    ref.watch(memoryContextProvider),
    ref.watch(caseRepositoryProvider),
  ),
);

final approverTableRepositoryProvider = Provider<ApproverTableRepository>(
  (ref) => MemoryApproverTableRepository(ref.watch(memoryContextProvider)),
);
