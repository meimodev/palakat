import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../repositories/period_repository.dart';
import 'memory_finance.dart';
import 'memory_master_repository.dart';
import 'memory_reconciliation_repository.dart';
import 'memory_report_repository.dart';
import 'memory_settings_repository.dart';
import 'memory_transaction_repository.dart';

/// Periods, the computed close blockers (DM 6.4), readiness and incidents.
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
      final unit = a.operatorAt(p.end);
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

  // ---------- Commands ----------

  static const _ref = 'period';

  MemoryTransactionRepository get _tx => MemoryTransactionRepository(
    f,
    MemorySettingsRepository(f),
    MemoryMasterRepository(f),
  );

  Refused<T>? _terbuka<T>(String aksi, Period? p) {
    if (p == null) return f.ctx.no(aksi, 'Bulan tidak ditemukan.');
    if (p.isClosed) {
      return f.ctx.no(aksi, '${bulanTahun(p.year, p.month)} sudah ditutup.');
    }
    return null;
  }

  ReadinessAttestation _baru(String fundId, String periodId) {
    final a = ReadinessAttestation(
      id: f.ctx.store.newId('siap'),
      fundId: fundId,
      periodId: periodId,
    );
    f.k.attestations.add(a);
    return a;
  }

  /// The unit treasurers to tell (DL33): the scoped preparers of the unit's
  /// Funds.
  List<String> _bendaharaUnit(String? scopeId) => [
    for (final x in f.k.funds)
      if (scopeId != null &&
          x.ownerScopeId == scopeId &&
          x.preparerPersonId != null)
        x.preparerPersonId!,
  ];

  /// "Nyatakan siap": only the Fund's scoped preparer, after the Fund's
  /// last posting (a later one invalidates it, RD12).
  @override
  Future<Result<ReadinessAttestation>> attest(
    Actor actor,
    String fundId,
    String periodId, {
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Nyatakan siap';
    final p = f.k.periodById(periodId);
    final tutup = _terbuka<ReadinessAttestation>(aksi, p);
    if (tutup != null) return tutup;
    final dana = f.k.fund(fundId);
    if (dana == null) return f.ctx.no(aksi, 'Peruntukan tidak ditemukan.');
    if (dana.preparerPersonId != actor.personId) {
      final siapa = dana.preparerPersonId == null
          ? null
          : f.ctx.personName(dana.preparerPersonId!);
      return f.ctx.no(
        aksi,
        'Kesiapan peruntukan ${dana.name} dinyatakan oleh penyiapnya.',
        whoCanAct: siapa,
      );
    }
    final g =
        f.ctx.grant(actor, Capability.unitFinanceAttest, ScopeRef.anywhere) ??
        f.ctx.own(actor);
    if (!f.k.needsAttestation(dana, p!)) {
      return f.ctx.no(
        aksi,
        'Peruntukan ${dana.name} tidak memerlukan pernyataan kesiapan '
        '${bulanTahun(p.year, p.month)}.',
      );
    }
    final a = _baru(fundId, periodId)
      ..preparerId = actor.personId
      ..attestedAt = f.now;
    f.audit(
      g,
      action: 'finance.readiness.attest',
      summary:
          'Kesiapan ${dana.name} · ${bulanTahun(p.year, p.month)} dinyatakan',
      ref: RecordRef(_ref, periodId),
    );
    return Ok(a);
  });

  /// The workspace Bendahara waives a missing or outdated attestation with
  /// a reason; the preparer is told (DL33).
  @override
  Future<Result<ReadinessAttestation>> waive(
    Actor actor,
    String fundId,
    String periodId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Kecualikan pernyataan kesiapan';
    final p = f.k.periodById(periodId);
    final tutup = _terbuka<ReadinessAttestation>(aksi, p);
    if (tutup != null) return tutup;
    final g = f.ctx.grant(
      actor,
      Capability.financeClearUnitBlocker,
      ScopeRef.jemaat,
    );
    if (g == null) {
      return f.ctx.refuse(
        actor,
        Capability.financeClearUnitBlocker,
        ScopeRef.jemaat,
      );
    }
    final basi = f.ctx.stale<ReadinessAttestation>(
      p!.revision,
      expectedRevision,
      aksi,
    );
    if (basi != null) return basi;
    if (reason.trim().isEmpty) return f.ctx.no(aksi, 'Alasan belum diisi.');
    final dana = f.k.fund(fundId);
    if (dana == null || !f.k.needsAttestation(dana, p)) {
      return f.ctx.no(aksi, 'Peruntukan ini tidak memerlukan pernyataan.');
    }
    final a = _baru(fundId, periodId)
      ..waivedBy = actor.personId
      ..waivedAt = f.now
      ..waiverReason = reason.trim();
    p.revision += 1;
    final bulan = bulanTahun(p.year, p.month);
    if (dana.preparerPersonId != null) {
      f.notify(
        dana.preparerPersonId!,
        title:
            'Kesiapan ${dana.name} · $bulan dikecualikan oleh Bendahara '
            'Jemaat',
        body: 'Alasan: ${reason.trim()}',
        type: NotificationType.role,
        ref: RecordRef(_ref, periodId),
      );
    }
    f.audit(
      g,
      action: 'finance.readiness.waive',
      summary: 'Kesiapan ${dana.name} · $bulan dikecualikan',
      reason: reason.trim(),
      ref: RecordRef(_ref, periodId),
    );
    return Ok(a);
  });

  /// DL33: the church Bendahara clears a unit's blocker with a reason, and
  /// the unit is told. [kind] notReconciled confirms the unit account's
  /// reconciliation from its own observation (never hiding a difference);
  /// openDraft moves the draft into the next open month; a readiness
  /// blocker is waived.
  @override
  Future<Result<void>> clearUnitBlocker(
    Actor actor,
    BlockerKind kind,
    String targetId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) async {
    const aksi = 'Selesaikan hambatan unit';
    final lama = f.ctx.store.idempotencyLog[idempotencyKey];
    if (lama != null) return lama as Result<void>;
    final g = f.ctx.grant(
      actor,
      Capability.financeClearUnitBlocker,
      ScopeRef.jemaat,
    );
    if (g == null) {
      return f.ctx.refuse(
        actor,
        Capability.financeClearUnitBlocker,
        ScopeRef.jemaat,
      );
    }
    final why = reason.trim();
    if (why.isEmpty) return f.ctx.no(aksi, 'Alasan belum diisi.');
    final p = f.k.periods.where((x) => !x.isClosed).firstOrNull;
    if (p == null) return f.ctx.no(aksi, 'Tidak ada bulan yang terbuka.');
    switch (kind) {
      case BlockerKind.notReconciled ||
          BlockerKind.cashCountMissing ||
          BlockerKind.statementMissing:
        final akun = f.k.account(targetId);
        final unit = akun?.operatorAt(p.end);
        if (akun == null || unit == null) {
          return f.ctx.no(aksi, 'Kas/Bank ini bukan milik unit.');
        }
        return f.ctx.command(idempotencyKey, () {
          var s = f.k.reconSessions
              .where((x) => x.accountId == targetId && x.periodId == p.id)
              .lastOrNull;
          // The target's revision; 0 while the unit has no session yet.
          final basi = f.ctx.stale<void>(
            s?.revision ?? 0,
            expectedRevision,
            aksi,
          );
          if (basi != null) return basi;
          if (s == null) {
            s = ReconSession(
              id: f.ctx.store.newId('rekon'),
              accountId: targetId,
              periodId: p.id,
            );
            f.k.reconSessions.add(s);
          }
          final belum = MemoryReconciliationRepository.konfirmasiUnit(
            f,
            s,
            actor.personId,
            why,
          );
          if (belum != null) return f.ctx.no(aksi, belum);
          final bulan = bulanTahun(p.year, p.month);
          for (final orang in _bendaharaUnit(unit)) {
            f.notify(
              orang,
              title:
                  'Rekonsiliasi ${akun.name} · $bulan dipastikan oleh '
                  'Bendahara Jemaat',
              body: 'Alasan: $why',
              type: NotificationType.role,
              ref: RecordRef('recon', s.id),
            );
          }
          f.audit(
            g,
            action: 'finance.unit.clear',
            summary: 'Rekonsiliasi ${akun.name} · $bulan dipastikan untuk unit',
            reason: why,
            ref: RecordRef('recon', s.id),
          );
          return const Ok(null);
        });
      case BlockerKind.openDraft:
        final t = f.k.transaction(targetId);
        if (t == null || t.unitScopeId == null) {
          return f.ctx.no(aksi, 'Draf ini bukan milik unit.');
        }
        // Into the next open month after the draft's: today when it is the
        // running month, else its first day (RD09; never past today).
        final ke = f.k.periods
            .where((x) => !x.isClosed && x.start > t.effectiveDate)
            .firstOrNull;
        if (ke == null) return f.ctx.no(aksi, 'Tidak ada bulan tujuan.');
        final r = await _tx.redate(
          actor,
          t.id,
          ke.contains(f.today) ? f.today : ke.start,
          reason: why,
          expectedRevision: expectedRevision,
          idempotencyKey: '$idempotencyKey/pindah',
        );
        if (r is Refused<Transaction>) return Refused(r.refusal);
        return f.ctx.command(idempotencyKey, () => const Ok(null));
      case BlockerKind.readinessMissing || BlockerKind.readinessInvalidated:
        final r = await waive(
          actor,
          targetId,
          p.id,
          reason: why,
          expectedRevision: expectedRevision,
          idempotencyKey: '$idempotencyKey/kecuali',
        );
        if (r is Refused<ReadinessAttestation>) return Refused(r.refusal);
        return f.ctx.command(idempotencyKey, () => const Ok(null));
      default:
        return f.ctx.no(aksi, 'Hambatan ini diselesaikan di layarnya sendiri.');
    }
  }

  /// RD01, RD08: in calendar order, only with no blocker, with the closer's
  /// explicit confirmation; freezes the report pack as `SNP-{y}-{mm}-01`.
  @override
  Future<Result<ReportSnapshot>> close(
    Actor actor,
    String periodId,
    String confirmation, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Tutup buku';
    final g = f.ctx.grant(actor, Capability.financeClose, ScopeRef.jemaat);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeClose, ScopeRef.jemaat);
    }
    final p = f.k.periodById(periodId);
    final tutup = _terbuka<ReportSnapshot>(aksi, p);
    if (tutup != null) return tutup;
    final basi = f.ctx.stale<ReportSnapshot>(
      p!.revision,
      expectedRevision,
      aksi,
    );
    if (basi != null) return basi;
    if (p.end >= f.today) {
      return f.ctx.no(aksi, '${bulanTahun(p.year, p.month)} belum berakhir.');
    }
    final hambatan = blockers(periodId);
    if (hambatan.isNotEmpty) {
      return f.ctx.no(
        aksi,
        'Masih ada ${hambatan.length} hambatan tutup buku.',
      );
    }
    if (confirmation.trim().isEmpty) {
      return f.ctx.no(aksi, 'Pernyataan belum dicentang.');
    }
    p
      ..status = PeriodStatus.closed
      ..closedBy = actor.personId
      ..closedAt = f.now
      ..confirmation = confirmation.trim()
      ..snapshotId = 'SNP-${p.year}-${p.month.toString().padLeft(2, '0')}-01'
      ..revision += 1;
    // The report repository freezes every closed month without a pack.
    final snap = MemoryReportRepository(f, this).snapshot(p.id)!;
    f.audit(
      g,
      action: 'finance.period.close',
      summary: 'Menutup buku ${bulanTahun(p.year, p.month)} · ${snap.id}',
      ref: RecordRef(_ref, p.id),
    );
    return Ok(snap);
  });

  /// DM 3 CloseIncident: never changes the closed month; `K-{y}-NN` in
  /// recording order (DP18); a settlement is a DRAFT in an open month.
  @override
  Future<Result<CloseIncident>> recordIncident(
    Actor actor,
    String periodId,
    IncidentExplanation explanation,
    TransactionDraft? settlementDraft, {
    required String idempotencyKey,
  }) async {
    const aksi = 'Catat kejadian';
    final lama = f.ctx.store.idempotencyLog[idempotencyKey];
    if (lama != null) return lama as Result<CloseIncident>;
    final g = f.ctx.grant(actor, Capability.financeClose, ScopeRef.jemaat);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeClose, ScopeRef.jemaat);
    }
    final p = f.k.periodById(periodId);
    if (p == null || !p.isClosed) {
      return f.ctx.no(
        aksi,
        'Kejadian dicatat untuk bulan yang sudah ditutup. Bulan yang belum '
        'ditutup diperbaiki lewat koreksi.',
      );
    }
    final e = explanation;
    if ([
      e.title,
      e.facts,
      e.impact,
      e.responsible,
    ].any((x) => x.trim().isEmpty)) {
      return f.ctx.no(
        aksi,
        'Judul, fakta, dampak dan penanggung jawab wajib diisi.',
      );
    }
    Transaction? draf;
    if (settlementDraft != null) {
      final r = await _tx.createDraft(
        actor,
        settlementDraft,
        idempotencyKey: '$idempotencyKey/penyelesaian',
      );
      if (r is Refused<Transaction>) return Refused(r.refusal);
      draf = r.value;
    }
    return f.ctx.command(idempotencyKey, () {
      final tahun = f.today.tahun;
      final k = CloseIncident(
        id: f.ctx.store.newId('kejadian'),
        year: tahun,
        number: f.k.incidents.where((x) => x.year == tahun).length + 1,
        periodId: periodId,
        explanation: e,
        recordedBy: actor.personId,
        recordedAt: f.now,
        settlementTransactionId: draf?.id,
      );
      f.k.incidents.add(k);
      f.audit(
        g,
        action: 'finance.incident.record',
        summary: '${k.code} · ${e.title}',
        ref: RecordRef('incident', k.id),
      );
      return Ok(k);
    });
  }

  @override
  Future<Result<CloseIncident>> resolveIncident(
    Actor actor,
    String incidentId,
    String narrative, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Catat penyelesaian keuangan';
    final g = f.ctx.grant(actor, Capability.financeClose, ScopeRef.jemaat);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeClose, ScopeRef.jemaat);
    }
    final k = f.k.incidents.where((x) => x.id == incidentId).firstOrNull;
    if (k == null) return f.ctx.no(aksi, 'Kejadian tidak ditemukan.');
    if ((k.narrativeResolution ?? '').isNotEmpty ||
        k.settlementTransactionId != null) {
      return f.ctx.no(aksi, '${k.code} sudah ditindaklanjuti.');
    }
    if (narrative.trim().isEmpty) {
      return f.ctx.no(aksi, 'Penyelesaian keuangan belum diisi.');
    }
    final basi = f.ctx.stale<CloseIncident>(k.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    k
      ..narrativeResolution = narrative.trim()
      ..revision += 1;
    f.audit(
      g,
      action: 'finance.incident.resolve',
      summary: '${k.code} · penyelesaian keuangan dicatat',
      ref: RecordRef('incident', k.id),
    );
    return Ok(k);
  });
}
