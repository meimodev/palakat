import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../repositories/period_repository.dart';
import 'memory_finance.dart';

/// Periods, the computed close blockers (DM 6.4), readiness and incidents.
/// Commands: M4.
class MemoryPeriodRepository implements PeriodRepository {
  MemoryPeriodRepository(this.f);
  final MemoryFinance f;

  @override
  List<Period> periods() => List.of(f.k.periods);

  @override
  Period? period(String id) => f.k.periodById(id);

  /// An Account counts for [p] with a balance at its end or a movement in it
  /// (DM 6.4 step 2: inactive accounts with balances stay). One never used
  /// (Kas Panitia HUT) does not.
  bool _relevant(Account a, Period p) =>
      f.k.accountBalance(a.id, at: p.end) != 0 ||
      _postedIn(p).any(
        (t) =>
            t.toAccountId == a.id ||
            t.allocations.any((x) => t.accountOf(x) == a.id),
      );

  Iterable<Transaction> _postedIn(Period p) =>
      f.k.posted.where((t) => p.contains(t.effectiveDate));

  /// A posting on [a] dated up to the period's end, finalized after the
  /// confirmation, makes it stale (DM 5.5).
  bool _stale(ReconSession s, Account a, Period p) =>
      s.confirmedAt != null &&
      f.k.transactions.any(
        (t) =>
            t.isPosted &&
            t.effectiveDate <= p.end &&
            t.finalizedAt != null &&
            t.finalizedAt!.isAfter(s.confirmedAt!) &&
            (t.toAccountId == a.id ||
                t.allocations.any((x) => t.accountOf(x) == a.id)),
      );

  @override
  List<Blocker> blockers(String periodId) {
    final p = f.k.periodById(periodId);
    if (p == null || p.isClosed) return const [];
    final b = <Blocker>[];

    // 1. Every earlier period is CLOSED (RD01).
    for (final q in f.k.periods) {
      if (q.end < p.start && !q.isClosed) {
        b.add(Blocker(kind: BlockerKind.earlierPeriodOpen, periodId: q.id));
      }
    }

    // 2. Every relevant Account reconciled and confirmed at the cutoff.
    for (final a in f.k.accounts) {
      if (!_relevant(a, p)) continue;
      final unit = a.operatedByScopeId;
      final s = f.k.reconSessions
          .where((x) => x.accountId == a.id && x.periodId == p.id)
          .lastOrNull;
      if (a.type == AccountType.bank &&
          (s == null || s.statementClosing == null)) {
        b.add(
          Blocker(
            kind: BlockerKind.statementMissing,
            accountId: a.id,
            unitScopeId: unit,
          ),
        );
        continue;
      }
      if (a.type == AccountType.cash &&
          !f.k.cashCounts.any(
            (c) => c.accountId == a.id && c.periodId == p.id,
          )) {
        b.add(
          Blocker(
            kind: BlockerKind.cashCountMissing,
            accountId: a.id,
            unitScopeId: unit,
          ),
        );
        continue;
      }
      if (s == null || s.status != ReconStatus.confirmed || _stale(s, a, p)) {
        b.add(
          Blocker(
            kind: BlockerKind.notReconciled,
            accountId: a.id,
            unitScopeId: unit,
          ),
        );
      }
    }

    // 3. Classification; drafts and staged rows dated in the period (RD09).
    for (final t in _postedIn(p)) {
      if (t.type == TransactionType.reversal) continue;
      final kurang = t.allocations.any((a) {
        final s = postingSigns[t.typeOf(a)] ?? const PostingSign();
        final perlu =
            s.income != 0 ||
            s.expense != 0 ||
            s.transitIn != 0 ||
            s.transitOut != 0;
        return perlu && a.masterCode == null;
      });
      if (kurang) {
        b.add(
          Blocker(
            kind: BlockerKind.missingClassification,
            transactionId: t.id,
            unitScopeId: t.unitScopeId,
          ),
        );
      }
    }
    for (final t in f.k.transactions) {
      if (t.isDraft && p.contains(t.effectiveDate)) {
        b.add(
          Blocker(
            kind: BlockerKind.openDraft,
            transactionId: t.id,
            unitScopeId: t.unitScopeId,
            amount: t.total,
          ),
        );
      }
    }
    for (final r in f.k.stagedRows) {
      if (r.date != null &&
          p.contains(r.date!) &&
          r.committedTransactionId == null &&
          r.disposition != RowDisposition.refused &&
          r.disposition != RowDisposition.deselected) {
        b.add(Blocker(kind: BlockerKind.stagedImportRow, importRowId: r.id));
      }
    }

    // 4. No negative case position at the period's end.
    for (final c in f.k.cases) {
      if (f.k.caseView(c, f.today, asOf: p.end).outstanding < 0) {
        b.add(Blocker(kind: BlockerKind.negativeCase, caseId: c.id));
      }
    }

    // 5. Required approval and evidence; readiness per Fund (RD12).
    for (final t in _postedIn(p)) {
      if (f.k.approvalMissing(t)) {
        b.add(
          Blocker(
            kind: BlockerKind.approvalMissing,
            transactionId: t.id,
            unitScopeId: t.unitScopeId,
          ),
        );
      }
      if (f.k.evidenceOpen(t)) {
        b.add(
          Blocker(
            kind: BlockerKind.evidenceMissing,
            transactionId: t.id,
            unitScopeId: t.unitScopeId,
            amount: t.total,
          ),
        );
      }
    }
    for (final r in attestations(periodId)) {
      final kind = switch (r.state) {
        ReadinessState.missing => BlockerKind.readinessMissing,
        ReadinessState.invalidated => BlockerKind.readinessInvalidated,
        _ => null,
      };
      if (kind == null) continue;
      final owner = f.k.fund(r.fundId)?.ownerScopeId;
      b.add(
        Blocker(
          kind: kind,
          fundId: r.fundId,
          unitScopeId: owner == ScopeRef.jemaatId ? null : owner,
        ),
      );
    }

    // 6. The report template is accepted (RD03).
    if (!f.k.templates.any((t) => t.accepted)) {
      b.add(const Blocker(kind: BlockerKind.templateNotAccepted));
    }
    return b;
  }

  @override
  List<ReadinessView> attestations(String periodId) {
    final p = f.k.periodById(periodId);
    if (p == null) return const [];
    return [
      for (final x in f.k.funds)
        if (f.k.needsAttestation(x, p)) f.k.readiness(x, p),
    ];
  }

  @override
  List<CloseIncident> incidents() => List.of(f.k.incidents);

  @override
  Future<Result<ReadinessAttestation>> attest(
    Actor actor,
    String fundId,
    String periodId, {
    required String idempotencyKey,
  }) => f.notYet('Nyatakan siap');

  @override
  Future<Result<ReadinessAttestation>> waive(
    Actor actor,
    String fundId,
    String periodId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Kecualikan pernyataan kesiapan');

  @override
  Future<Result<void>> clearUnitBlocker(
    Actor actor,
    BlockerKind kind,
    String targetId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Selesaikan hambatan unit');

  @override
  Future<Result<ReportSnapshot>> close(
    Actor actor,
    String periodId,
    String confirmation, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Tutup buku');

  @override
  Future<Result<CloseIncident>> recordIncident(
    Actor actor,
    String periodId,
    IncidentExplanation explanation,
    TransactionDraft? settlementDraft, {
    required String idempotencyKey,
  }) => f.notYet('Catat kejadian');
}
