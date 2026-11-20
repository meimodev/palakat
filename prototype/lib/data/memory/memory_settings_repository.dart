import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../repositories/settings_repository.dart';
import 'memory_finance.dart';

/// Rule values and the Lingkup list. Commands: M5.
class MemorySettingsRepository implements SettingsRepository {
  MemorySettingsRepository(this.f);
  final MemoryFinance f;

  /// The latest value of [rule] with effectiveFrom <= [at].
  RuleValue? _inForce(FinanceRule rule, Tanggal at) {
    final v =
        f.k.ruleValues
            .where((v) => v.rule == rule && v.effectiveFrom <= at)
            .toList()
          ..sort((a, b) {
            final d = a.effectiveFrom.compareTo(b.effectiveFrom);
            return d != 0 ? d : a.setAt.compareTo(b.setAt);
          });
    return v.lastOrNull;
  }

  @override
  RulesInForce rulesInForce({required Tanggal at}) => RulesInForce({
    for (final r in FinanceRule.values) r: _inForce(r, at)?.on ?? false,
  });

  @override
  List<RuleValue> scheduled() =>
      f.k.ruleValues.where((v) => v.effectiveFrom > f.today).toList()
        ..sort((a, b) => a.effectiveFrom.compareTo(b.effectiveFrom));

  @override
  List<LingkupLink> lingkup({Tanggal? at}) => [
    for (final l in f.k.lingkup)
      if (l.activeFrom <= (at ?? f.today)) l,
  ];

  @override
  Future<Result<RuleValue>> setRule(
    Actor actor,
    FinanceRule rule,
    bool on,
    Tanggal effectiveFrom, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Ubah aturan');

  @override
  Future<Result<LingkupLink>> addLingkup(
    Actor actor,
    String scopeId,
    Tanggal effectiveFrom, {
    required String idempotencyKey,
  }) => f.notYet('Tambah Lingkup');
}
