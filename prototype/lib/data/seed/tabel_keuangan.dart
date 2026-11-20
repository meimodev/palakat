import '../../core/tanggal.dart';
import '../../domain/finance/finance.dart';

/// The Finance tables (README 5.7), complete in M2: M3–M5 only fill their
/// seed files. Mutable lists the in-memory repositories change; seed files
/// add rows directly. Below them, the derived figures every finance
/// repository shares (balances, case positions, evidence and approval
/// states), always computed from posted transactions (D11).
class TabelKeuangan {
  final List<Account> accounts = [];
  final List<Fund> funds = [];
  final List<LingkupLink> lingkup = [];
  final List<RuleValue> ruleValues = [];
  final List<MasterVersion> masterVersions = [];
  final List<MasterRow> masterRows = [];

  /// Every transaction, in creation order.
  final List<Transaction> transactions = [];

  /// Numbers given but never posted (DP7).
  final List<UnfinishedVoucher> unfinishedVouchers = [];
  final List<ApprovalRecord> approvals = [];
  final List<EvidenceItem> evidence = [];
  final List<FinanceCase> cases = [];
  final List<ImportBatch> importBatches = [];
  final List<StagedRow> stagedRows = [];
  final List<ReconSession> reconSessions = [];
  final List<StatementLine> statementLines = [];
  final List<CashCount> cashCounts = [];

  /// Calendar order. The first starts at the cutover.
  final List<Period> periods = [];
  final List<ReadinessAttestation> attestations = [];
  final List<CloseIncident> incidents = [];
  final List<ReportSnapshot> snapshots = [];
  final List<ReportTemplate> templates = [];
  final List<AiProposal> aiProposals = [];

  /// AI spend per period id ('yyyy-mm'), rupiah.
  final Map<String, int> aiSpend = {};

  /// "Batas biaya AI per bulan" (Bukti, WebAI).
  int aiCap = 150000;

  /// The cost of one AI proposal: from the seeded 75 % spend, five more
  /// proposals reach the cap (F3).
  int aiCost = 7500;

  /// The cutover, seeded complete (D19).
  OpeningBatch? opening;

  // ---------- Lookups ----------

  Account? account(String? id) => accounts.where((a) => a.id == id).firstOrNull;
  Fund? fund(String? id) => funds.where((f) => f.id == id).firstOrNull;
  Transaction? transaction(String? id) =>
      transactions.where((t) => t.id == id).firstOrNull;
  FinanceCase? kase(String? id) => cases.where((c) => c.id == id).firstOrNull;
  MasterVersion? masterVersion(String? id) =>
      masterVersions.where((v) => v.id == id).firstOrNull;
  Period? periodById(String? id) =>
      periods.where((p) => p.id == id).firstOrNull;

  /// The seeded transaction drawn with voucher [key] ('0143').
  Transaction? bySeedKey(String key) =>
      transactions.where((t) => t.seedKey == key).firstOrNull;

  /// The period containing [d]; null before the cutover or after the last.
  Period? periodOf(Tanggal d) =>
      periods.where((p) => p.contains(d)).firstOrNull;

  /// The first day of recording (the first period's start).
  Tanggal? get cutover => periods.firstOrNull?.start;

  /// [d] is in a CLOSED period.
  bool isClosed(Tanggal d) => periodOf(d)?.isClosed ?? false;

  /// The posted transactions, in posting order: effective date, then series
  /// and number.
  Iterable<Transaction> get posted {
    final p = transactions.where((t) => t.isPosted).toList()
      ..sort(postingOrder);
    return p;
  }

  static int postingOrder(Transaction a, Transaction b) {
    final d = a.effectiveDate.compareTo(b.effectiveDate);
    if (d != 0) return d;
    final s = a.series.index.compareTo(b.series.index);
    if (s != 0) return s;
    return (a.voucherNumber ?? 0).compareTo(b.voucherNumber ?? 0);
  }

  // ---------- Balances (README 4.6 point 1) ----------

  Iterable<Leg> _legs({Tanggal? at, Tanggal? from}) sync* {
    for (final t in transactions) {
      if (!t.isPosted) continue;
      if (at != null && t.effectiveDate > at) continue;
      if (from != null && t.effectiveDate < from) continue;
      for (final e in effectsOf(t)) {
        yield* e.legs;
      }
    }
  }

  /// A Kas/Bank's book balance at the end of [at] (all time when null).
  int accountBalance(String accountId, {Tanggal? at}) =>
      _legs(at: at)
          .where((l) => l.accountId == accountId)
          .fold(0, (s, l) => s + l.amount);

  /// A Fund's liquid balance at the end of [at].
  int fundBalance(String fundId, {Tanggal? at}) =>
      _legs(at: at)
          .where((l) => l.fundId == fundId)
          .fold(0, (s, l) => s + l.amount);

  /// A Kas/Bank's balance split by Fund (AlihPeruntukan), non-zero only.
  Map<String, int> balanceByFund(String accountId, {Tanggal? at}) {
    final m = <String, int>{};
    for (final l in _legs(at: at)) {
      if (l.accountId != accountId || l.fundId == null) continue;
      m[l.fundId!] = (m[l.fundId!] ?? 0) + l.amount;
    }
    m.removeWhere((_, v) => v == 0);
    return m;
  }

  /// README 4.6: every posted leg has both an Account and a Fund, so the
  /// account totals equal the Fund totals. The seed asserts it.
  bool get ledgerBalanced {
    var accountsTotal = 0, fundsTotal = 0;
    for (final l in _legs()) {
      if (l.accountId != null) accountsTotal += l.amount;
      if (l.fundId != null) fundsTotal += l.amount;
    }
    return accountsTotal == fundsTotal;
  }

  // ---------- Cases (DM 5.4) ----------

  /// [c] with its figures from posted linked parts, at [today]; with
  /// [asOf], only postings dated on or before it (a period's end, DM 6.4).
  CaseView caseView(FinanceCase c, Tanggal today, {Tanggal? asOf}) {
    // Issues and collections raise it, the rest lowers it; a reversal part
    // keeps its original's type with the opposite sign.
    var naik = 0, turun = 0;
    final entries = <Transaction>[];
    for (final t in posted) {
      if (asOf != null && t.effectiveDate > asOf) continue;
      var linked = false;
      for (final e in effectsOf(t)) {
        if (e.allocation.caseId != c.id) continue;
        linked = true;
        if (e.type == TransactionType.advanceIssue ||
            e.type == TransactionType.transitCollection) {
          naik += e.caseDelta;
        } else {
          turun -= e.caseDelta;
        }
      }
      if (linked) entries.add(t);
    }
    final amount = c.kind == CaseKind.claim ? (c.claimAmount ?? 0) : naik;
    final reduced = turun;
    final outstanding = amount - reduced;
    return CaseView(
      kase: c,
      amount: amount,
      reduced: reduced,
      outstanding: outstanding,
      state: outstanding <= 0 && amount > 0
          ? CaseState.settled
          : reduced > 0
          ? CaseState.partial
          : CaseState.open,
      overdue: outstanding > 0 && c.dueDate != null && c.dueDate! < today,
      entries: entries,
    );
  }

  // ---------- Approval and evidence (DM 5.2, 5.3) ----------

  /// The external approval in force for [t], or null.
  ApprovalRecord? approvalOf(Transaction t) => approvals
      .where(
        (a) => a.transactionId == t.id && a.status == ApprovalStatus.recorded,
      )
      .lastOrNull;

  /// The required approval is missing.
  bool approvalMissing(Transaction t) =>
      t.approvalMode == ApprovalMode.external && approvalOf(t) == null;

  /// The evidence projection of [t] (DM 5.3).
  EvidenceStatus evidenceStatus(Transaction t) {
    final items = evidence.where((e) => e.transactionId == t.id).toList();
    if (items.any((e) => e.state == EvidenceItemState.exception)) {
      return EvidenceStatus.exceptionAccepted;
    }
    if (items.any((e) => e.state == EvidenceItemState.verified)) {
      return EvidenceStatus.verified;
    }
    if (items.any((e) => e.state == EvidenceItemState.uploaded)) {
      return EvidenceStatus.uploaded;
    }
    return t.evidenceRequired
        ? EvidenceStatus.requiredMissing
        : EvidenceStatus.notRequired;
  }

  /// Required evidence is not yet verified or excepted (a close blocker).
  bool evidenceOpen(Transaction t) => switch (evidenceStatus(t)) {
    EvidenceStatus.requiredMissing || EvidenceStatus.uploaded => true,
    _ => false,
  };

  // ---------- Readiness (RD12, DP37) ----------

  /// A Fund needs an attestation for [p] when it has a scoped preparer and
  /// activity or a balance in the period.
  bool needsAttestation(Fund f, Period p) {
    if (f.preparerPersonId == null) return false;
    if (fundBalance(f.id, at: p.end) != 0) return true;
    return posted.any(
      (t) =>
          p.contains(t.effectiveDate) &&
          t.allocations.any((a) => a.fundId == f.id || a.toFundId == f.id),
    );
  }

  /// The state of [f]'s attestation for [p]: a posting in the Fund dated in
  /// the period and finalized after the attestation invalidates it.
  ReadinessView readiness(Fund f, Period p) {
    final a = attestations
        .where((x) => x.fundId == f.id && x.periodId == p.id)
        .lastOrNull;
    if (a == null) {
      return ReadinessView(fundId: f.id, state: ReadinessState.missing);
    }
    if (a.waivedBy != null) {
      return ReadinessView(
        fundId: f.id,
        state: ReadinessState.waived,
        attestation: a,
      );
    }
    if (a.attestedAt == null) {
      return ReadinessView(
        fundId: f.id,
        state: ReadinessState.missing,
        attestation: a,
      );
    }
    final later = transactions.any(
      (t) =>
          t.isPosted &&
          p.contains(t.effectiveDate) &&
          t.finalizedAt != null &&
          t.finalizedAt!.isAfter(a.attestedAt!) &&
          t.allocations.any((x) => x.fundId == f.id || x.toFundId == f.id),
    );
    return ReadinessView(
      fundId: f.id,
      state: later ? ReadinessState.invalidated : ReadinessState.current,
      attestation: a,
    );
  }

  // ---------- Vouchers (README 5.5, DP38) ----------

  /// Numbers every seeded voucher through [next] (`SeedStore.nextVoucher`)
  /// in the boards' posting order: the drawn numbers ascending, posted rows
  /// and DP7 unfinished numbers together; each takes the next number of its
  /// own year's series. Call once, after the seed rows are added.
  void numberSeedVouchers(int Function(String series, int year) next) {
    final items = <(String, Object)>[
      for (final t in transactions)
        if (t.isPosted && t.seedKey != null && t.voucherNumber == null)
          (t.seedKey!, t),
      for (final u in unfinishedVouchers)
        if (u.seedKey != null && u.number == null) (u.seedKey!, u),
    ]..sort((a, b) => _drawnOrder(a.$1, b.$1));
    for (final (_, x) in items) {
      switch (x) {
        case Transaction t:
          t
            ..voucherYear = t.effectiveDate.tahun
            ..voucherNumber = next(t.series.code, t.effectiveDate.tahun);
        case UnfinishedVoucher u:
          u
            ..year = u.allocatedAt.year
            ..number = next(u.series.code, u.allocatedAt.year);
      }
    }
  }

  static int _drawnOrder(String a, String b) {
    final x = int.tryParse(a), y = int.tryParse(b);
    if (x != null && y != null) return x.compareTo(y);
    return a.compareTo(b);
  }
}
