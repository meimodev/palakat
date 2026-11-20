import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';

/// Finance rules and the Lingkup list (README 4.2, D24). A rule value holds
/// from a date; scheduled changes are listed until they take effect.
abstract interface class SettingsRepository {
  /// Each rule's value at [at] (the second checker for a draft dated [at]).
  RulesInForce rulesInForce({required Tanggal at});

  /// Rule values that take effect after today, soonest first.
  List<RuleValue> scheduled();

  /// The scopes offered as Lingkup on the forms at [at] (today when null).
  /// Added beyond README 4.2: no listed query gives the Lingkup list.
  List<LingkupLink> lingkup({Tanggal? at});

  /// A change takes effect from the 1st of M+1 (D24). [expectedRevision] is
  /// the revision of the value in force today (0 when none).
  Future<Result<RuleValue>> setRule(
    Actor actor,
    FinanceRule rule,
    bool on,
    Tanggal effectiveFrom, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// Offers a scope as Lingkup from [effectiveFrom] (F19). Added beyond
  /// README 4.2, with [lingkup].
  Future<Result<LingkupLink>> addLingkup(
    Actor actor,
    String scopeId,
    Tanggal effectiveFrom, {
    required String idempotencyKey,
  });
}
