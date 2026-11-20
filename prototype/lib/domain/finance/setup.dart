import '../../core/tanggal.dart';

/// DM 3 PhysicalAccount: `CASH` or `BANK`.
enum AccountType { cash, bank }

/// A Kas/Bank (DM 3 PhysicalAccount). A used account is never deleted; it is
/// deactivated from a date and keeps its ledger.
class Account {
  Account({
    required this.id,
    required this.name,
    required this.shortName,
    required this.type,
    required this.activeFrom,
    this.institution,
    this.activeTo,
    this.deactivationReason,
    this.operatedByScopeId,
    this.revision = 1,
  });

  /// 'kas', 'bni', 'bsg', 'hut', 'kol7'.
  final String id;

  /// As drawn: 'Kas', 'Bank BNI ··4821'.
  String name;

  /// Transfer labels: 'Kas', 'Bank BNI'.
  String shortName;
  final AccountType type;
  String? institution;
  Tanggal activeFrom;

  /// The last day in force; null while active (deactivate from a date).
  Tanggal? activeTo;
  String? deactivationReason;

  /// The unit scope that operates it ('kolom-7'); null = Jemaat (DL32).
  String? operatedByScopeId;
  int revision;

  bool activeAt(Tanggal at) =>
      activeFrom <= at && (activeTo == null || at <= activeTo!);
}

/// What `AccountRepository.add` takes.
class AccountDraft {
  const AccountDraft({
    required this.name,
    required this.shortName,
    required this.type,
    this.institution,
    this.operatedByScopeId,
  });

  final String name;
  final String shortName;
  final AccountType type;
  final String? institution;
  final String? operatedByScopeId;
}

/// A peruntukan (DM 3 Fund): owned by a scope; its owner governs approvals.
class Fund {
  Fund({
    required this.id,
    required this.name,
    required this.ownerScopeId,
    required this.activeFrom,
    this.restriction,
    this.activeTo,
    this.preparerPersonId,
    this.revision = 1,
  });

  /// 'umum', 'diak', 'bang', 'kol7', 'natal'.
  final String id;

  /// 'Umum Jemaat', 'Diakonia', 'Pembangunan', 'Kolom 7', 'Panitia Natal'.
  String name;

  /// 'jemaat', 'komisi-diakonia', 'kolom-7', 'panitia-natal'. A Fund-only
  /// viewer sees the Funds owned by the scopes of their view grants.
  final String ownerScopeId;
  String? restriction;
  Tanggal activeFrom;
  Tanggal? activeTo;

  /// The scoped preparer who attests readiness (RD12, DP37); null = none.
  String? preparerPersonId;
  int revision;

  bool activeAt(Tanggal at) =>
      activeFrom <= at && (activeTo == null || at <= activeTo!);
}

/// What `FundRepository.add` takes.
class FundDraft {
  const FundDraft({
    required this.name,
    required this.ownerScopeId,
    this.restriction,
    this.preparerPersonId,
  });

  final String name;
  final String ownerScopeId;
  final String? restriction;
  final String? preparerPersonId;
}

/// A scope offered as "Lingkup" on the finance forms (DP12): the activity
/// scope of an allocation, from a date.
class LingkupLink {
  LingkupLink({
    required this.id,
    required this.scopeId,
    required this.activeFrom,
    this.revision = 1,
  });

  final String id;
  final String scopeId;
  Tanggal activeFrom;
  int revision;
}

/// The finance rules a church switches (D24).
enum FinanceRule {
  /// "Wajib pemeriksa kedua": a draft is finalized only after a review by
  /// someone other than its maker.
  secondChecker,
}

/// One rule value from a date (D24: a change takes effect from the 1st of
/// M+1). The value in force at a date is the latest with
/// [effectiveFrom] <= date.
class RuleValue {
  RuleValue({
    required this.id,
    required this.rule,
    required this.on,
    required this.effectiveFrom,
    required this.setBy,
    required this.setAt,
    this.reason,
    this.revision = 1,
  });

  final String id;
  final FinanceRule rule;
  final bool on;
  final Tanggal effectiveFrom;
  final String setBy;
  final DateTime setAt;
  final String? reason;
  int revision;
}

/// `SettingsRepository.rulesInForce`: each rule's value at a date (off when
/// no value applies: maker/checker is off by default for solo use, DM 5.2).
class RulesInForce {
  const RulesInForce(this.values);

  final Map<FinanceRule, bool> values;

  bool get secondChecker => values[FinanceRule.secondChecker] ?? false;
}

/// The cutover (DM 6.1, D19): seeded complete, read-only in the app. Its
/// balances are the allocations of the OPN transaction [transactionId].
class OpeningBatch {
  const OpeningBatch({
    required this.cutoverDate,
    required this.transactionId,
    required this.recordedBy,
    required this.recordedAt,
    this.sources = const {},
  });

  final Tanggal cutoverDate;
  final String transactionId;
  final String recordedBy;
  final DateTime recordedAt;

  /// Per account id: 'Sumber: berita acara hitung kas …'.
  final Map<String, String> sources;
}
