import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../repositories/account_repository.dart';
import 'memory_finance.dart';

/// Kas/Bank and their balances. Commands: M5.
class MemoryAccountRepository implements AccountRepository {
  MemoryAccountRepository(this.f);
  final MemoryFinance f;

  @override
  List<Account> accounts({bool includeInactive = false}) => [
    for (final a in f.k.accounts)
      if (includeInactive || a.activeTo == null || a.activeTo! >= f.today) a,
  ];

  @override
  int balance(String accountId, {Tanggal? at}) =>
      f.k.accountBalance(accountId, at: at ?? f.today);

  @override
  Map<String, int> balanceByFund(String accountId, {Tanggal? at}) =>
      f.k.balanceByFund(accountId, at: at ?? f.today);

  @override
  Future<Result<Account>> add(
    Actor actor,
    AccountDraft draft,
    Tanggal effectiveFrom, {
    required String idempotencyKey,
  }) => f.notYet('Tambah Kas/Bank');

  @override
  Future<Result<Account>> deactivate(
    Actor actor,
    String id,
    Tanggal effectiveFrom, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Nonaktifkan Kas/Bank');

  @override
  Future<Result<Account>> assignToUnit(
    Actor actor,
    String id,
    String scopeId,
    Tanggal effectiveFrom, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Serahkan ke unit');
}
