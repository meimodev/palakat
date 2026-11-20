import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/memory/memory_account_repository.dart';
import '../data/memory/memory_ai_repository.dart';
import '../data/memory/memory_approval_repository.dart';
import '../data/memory/memory_case_repository.dart';
import '../data/memory/memory_evidence_repository.dart';
import '../data/memory/memory_finance.dart';
import '../data/memory/memory_fund_repository.dart';
import '../data/memory/memory_import_repository.dart';
import '../data/memory/memory_master_repository.dart';
import '../data/memory/memory_opening_repository.dart';
import '../data/memory/memory_period_repository.dart';
import '../data/memory/memory_reconciliation_repository.dart';
import '../data/memory/memory_report_repository.dart';
import '../data/memory/memory_settings_repository.dart';
import '../data/memory/memory_transaction_repository.dart';
import '../data/repositories/account_repository.dart';
import '../data/repositories/ai_repository.dart';
import '../data/repositories/approval_repository.dart';
import '../data/repositories/case_repository.dart';
import '../data/repositories/evidence_repository.dart';
import '../data/repositories/fund_repository.dart';
import '../data/repositories/import_repository.dart';
import '../data/repositories/master_repository.dart';
import '../data/repositories/opening_repository.dart';
import '../data/repositories/period_repository.dart';
import '../data/repositories/reconciliation_repository.dart';
import '../data/repositories/report_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/transaction_repository.dart';
import 'actor.dart';
import 'core_repositories.dart';

/// The shared base of the finance repositories: the core context plus the
/// signed-in actor, read when a query runs, for Fund-only filtering (README
/// 3.5). Reading it never changes provider state.
final memoryFinanceProvider = Provider<MemoryFinance>(
  (ref) => MemoryFinance(
    ref.watch(memoryContextProvider),
    () => ref.read(actorProvider),
  ),
);

// The finance repositories (README 4.2). Overriding one with a Supabase
// implementation later is the seam (D1).

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => MemorySettingsRepository(ref.watch(memoryFinanceProvider)),
);

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => MemoryAccountRepository(ref.watch(memoryFinanceProvider)),
);

final fundRepositoryProvider = Provider<FundRepository>(
  (ref) => MemoryFundRepository(ref.watch(memoryFinanceProvider)),
);

final masterRepositoryProvider = Provider<MasterRepository>(
  (ref) => MemoryMasterRepository(ref.watch(memoryFinanceProvider)),
);

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => MemoryTransactionRepository(
    ref.watch(memoryFinanceProvider),
    ref.watch(settingsRepositoryProvider),
    ref.watch(masterRepositoryProvider),
  ),
);

final approvalRepositoryProvider = Provider<ApprovalRepository>(
  (ref) => MemoryApprovalRepository(ref.watch(memoryFinanceProvider)),
);

final evidenceRepositoryProvider = Provider<EvidenceRepository>(
  (ref) => MemoryEvidenceRepository(ref.watch(memoryFinanceProvider)),
);

final caseRepositoryProvider = Provider<CaseRepository>(
  (ref) => MemoryCaseRepository(
    ref.watch(memoryFinanceProvider),
    ref.watch(transactionRepositoryProvider),
  ),
);

final importRepositoryProvider = Provider<ImportRepository>(
  (ref) => MemoryImportRepository(
    ref.watch(memoryFinanceProvider),
    ref.watch(transactionRepositoryProvider),
  ),
);

final reconciliationRepositoryProvider = Provider<ReconciliationRepository>(
  (ref) => MemoryReconciliationRepository(ref.watch(memoryFinanceProvider)),
);

final periodRepositoryProvider = Provider<PeriodRepository>(
  (ref) => MemoryPeriodRepository(ref.watch(memoryFinanceProvider)),
);

final openingRepositoryProvider = Provider<OpeningRepository>(
  (ref) => MemoryOpeningRepository(ref.watch(memoryFinanceProvider)),
);

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => MemoryReportRepository(
    ref.watch(memoryFinanceProvider),
    ref.watch(periodRepositoryProvider),
  ),
);

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  final r = MemoryAiRepository(ref.watch(memoryFinanceProvider));
  ref.onDispose(r.cancelTimers);
  return r;
});
