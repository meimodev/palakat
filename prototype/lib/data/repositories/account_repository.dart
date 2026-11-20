import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';

/// Kas/Bank (README 4.2): active dates; a used account is never deleted.
abstract interface class AccountRepository {
  /// Every account active today; with [includeInactive], deactivated ones
  /// too (shown dashed, "tetap tampil di laporan lama").
  List<Account> accounts({bool includeInactive = false});

  /// The book balance at the end of [at] (today when null), from posted
  /// transactions only.
  int balance(String accountId, {Tanggal? at});

  /// The balance split by Fund id, non-zero parts only.
  Map<String, int> balanceByFund(String accountId, {Tanggal? at});

  Future<Result<Account>> add(
    Actor actor,
    AccountDraft draft,
    Tanggal effectiveFrom, {
    required String idempotencyKey,
  });

  /// Out of use from [effectiveFrom]; its ledger stays.
  Future<Result<Account>> deactivate(
    Actor actor,
    String id,
    Tanggal effectiveFrom, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// KasUnit: the unit [scopeId] operates it from [effectiveFrom] (DL32).
  Future<Result<Account>> assignToUnit(
    Actor actor,
    String id,
    String scopeId,
    Tanggal effectiveFrom, {
    required int expectedRevision,
    required String idempotencyKey,
  });
}
