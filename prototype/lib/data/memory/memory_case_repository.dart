import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../repositories/case_repository.dart';
import 'memory_finance.dart';
import 'memory_master_repository.dart';
import 'memory_settings_repository.dart';
import 'memory_transaction_repository.dart';

/// Advances, transit and claims with derived figures (README 4.2, DM 5.4).
/// Every command but [recordClaim] drafts its linked transaction through
/// `TransactionRepository.createDraft`; outstanding amounts count FINALIZED
/// parts only, and the draft uses the case's Fund (EC06).
class MemoryCaseRepository implements CaseRepository {
  MemoryCaseRepository(this.f)
    : _tx = MemoryTransactionRepository(
        f,
        MemorySettingsRepository(f),
        MemoryMasterRepository(f),
      );

  final MemoryFinance f;

  // ponytail: its own ledger instance over the same store, because the shared
  // provider file gives this repository only MemoryFinance (README 10.1).
  final MemoryTransactionRepository _tx;

  static const _ref = 'case';

  List<CaseView> _of(CaseKind kind) => [
    for (final c in f.k.cases)
      if (c.kind == kind) f.k.caseView(c, f.today),
  ];

  @override
  List<CaseView> advances() => _of(CaseKind.advance);

  @override
  List<CaseView> transits() => _of(CaseKind.transit);

  @override
  List<CaseView> claims() => _of(CaseKind.claim);

  @override
  CaseView? caseById(String id) {
    final c = f.k.kase(id);
    return c == null ? null : f.k.caseView(c, f.today);
  }

  // ---------- Helpers ----------

  /// The draft through the ledger's own command. Its body runs at once (a
  /// command has no await before it), so the result is in the log already.
  Result<Transaction> _draft(Actor actor, TransactionDraft d, String key) {
    final k = '$key/draf';
    _tx.createDraft(actor, d, idempotencyKey: k);
    return f.ctx.store.idempotencyLog[k]! as Result<Transaction>;
  }

  /// Open drafts that move [c] down (settle, return, remit, pay).
  int _pendingDown(FinanceCase c) {
    var n = 0;
    for (final t in f.k.transactions) {
      if (!t.isDraft) continue;
      for (final a in t.allocations) {
        if (a.caseId != c.id) continue;
        final s = postingSigns[t.typeOf(a)];
        if (s != null && s.kase < 0) n += a.amount;
      }
    }
    return n;
  }

  /// The Mata Anggaran last used on [c] for [type], as the default of the
  /// next entry (the board's sheet asks only for the amount).
  String? _lastCode(FinanceCase c, TransactionType type) {
    String? code;
    for (final t in f.k.transactions) {
      for (final a in t.allocations) {
        if (a.caseId == c.id && t.typeOf(a) == type && a.masterCode != null) {
          code = a.masterCode;
        }
      }
    }
    return code;
  }

  String _who(FinanceCase c) =>
      f.ctx.inti.parties
          .where((p) => p.id == c.partyId)
          .firstOrNull
          ?.displayName ??
      c.partyId ??
      c.title;

  /// The checks every entry on an existing case shares; null when fine.
  Refused<String>? _entryChecks(
    String aksi,
    FinanceCase? c,
    CaseKind kind,
    CaseEntryDraft d,
    int expectedRevision, {
    required bool down,
    String lebih = '',
  }) {
    if (c == null) return f.ctx.no(aksi, 'Kasus tidak ditemukan.');
    if (c.kind != kind) {
      return f.ctx.no(aksi, 'Bukan kasus untuk tindakan ini.');
    }
    final basi = f.ctx.stale<String>(c.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (d.amount <= 0) return f.ctx.no(aksi, 'Jumlah belum diisi.');
    if (!down) return null;
    final sisa = f.k.caseView(c, f.today).outstanding - _pendingDown(c);
    if (d.amount > sisa) {
      return f.ctx.no(aksi, 'melebihi sisa ${rp(sisa < 0 ? 0 : sisa)}.$lebih');
    }
    return null;
  }

  Result<String> _entry(
    Actor actor,
    FinanceCase c,
    TransactionType type,
    String description,
    CaseEntryDraft d,
    String key, {
    String? accountId,
    String? masterCode,
  }) {
    final r = _draft(
      actor,
      TransactionDraft(
        type: type,
        effectiveDate: d.effectiveDate ?? f.today,
        description: d.description ?? description,
        accountId: accountId,
        allocations: [
          Allocation(
            amount: d.amount,
            fundId: c.fundId,
            scopeId: d.scopeId ?? c.scopeId,
            partyId: c.partyId,
            masterCode: masterCode,
            caseId: c.id,
          ),
        ],
      ),
      key,
    );
    if (r case Refused(:final refusal)) return Refused(refusal);
    final t = (r as Ok<Transaction>).value;
    c.revision += 1;
    return Ok(t.id);
  }

  // ---------- Commands ----------

  /// Opens an advance, or a transit case (`CaseDraft.kind`), with its first
  /// draft.
  @override
  Future<Result<String>> issueAdvance(
    Actor actor,
    CaseDraft caseDraft, {
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    final d = caseDraft;
    final transit = d.kind == CaseKind.transit;
    final aksi = transit ? 'Catat titipan' : 'Beri uang muka';
    if (d.kind == CaseKind.claim) {
      return f.ctx.no(aksi, 'Klaim dicatat dengan Simpan klaim.');
    }
    if (d.title.trim().isEmpty) return f.ctx.no(aksi, 'Uraian belum diisi.');
    if (d.amount <= 0) return f.ctx.no(aksi, 'Jumlah belum diisi.');
    if (d.accountId == null) return f.ctx.no(aksi, 'Kas/Bank belum dipilih.');
    if (!transit) {
      final saldo =
          f.k.balanceByFund(
            d.accountId!,
            at: d.effectiveDate ?? f.today,
          )[d.fundId] ??
          0;
      if (d.amount > saldo) {
        final akun = f.k.account(d.accountId)?.name ?? d.accountId;
        return f.ctx.no(
          aksi,
          'melebihi saldo peruntukan ${f.k.fund(d.fundId)?.name} di $akun '
          '(${rp(saldo)}).',
        );
      }
    }
    final c = FinanceCase(
      id: f.ctx.store.newId('kasus'),
      kind: d.kind,
      title: d.title.trim(),
      fundId: d.fundId,
      openedOn: d.effectiveDate ?? f.today,
      createdBy: actor.personId,
      createdAt: f.now,
      partyId: d.partyId,
      scopeId: d.scopeId,
      accountId: d.accountId,
      dueDate: d.dueDate,
      note: d.note,
    );
    f.k.cases.add(c);
    final r = _draft(
      actor,
      TransactionDraft(
        type: transit
            ? TransactionType.transitCollection
            : TransactionType.advanceIssue,
        effectiveDate: c.openedOn,
        description: transit
            ? 'Titipan untuk: ${_who(c)} · ${c.title}'
            : 'Uang Muka diberikan · ${c.title}',
        accountId: d.accountId,
        allocations: [
          Allocation(
            amount: d.amount,
            fundId: d.fundId,
            scopeId: d.scopeId,
            partyId: d.partyId,
            masterCode: d.masterCode,
            caseId: c.id,
          ),
        ],
      ),
      idempotencyKey,
    );
    if (r case Refused(:final refusal)) {
      f.k.cases.remove(c);
      return Refused(refusal);
    }
    f.audit(
      f.ctx.grant(actor, Capability.financeRecord, ScopeRef.jemaat) ??
          f.ctx.own(actor),
      action: transit ? 'finance.case.transit' : 'finance.case.advance',
      summary: '${transit ? 'Titipan' : 'Uang muka'} dibuka: ${c.title}',
      ref: RecordRef(_ref, c.id),
    );
    return Ok((r as Ok<Transaction>).value.id);
  });

  @override
  Future<Result<String>> settle(
    Actor actor,
    String caseId,
    CaseEntryDraft draft, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Catat pertanggungjawaban';
    final c = f.k.kase(caseId);
    final tolak = _entryChecks(
      aksi,
      c,
      CaseKind.advance,
      draft,
      expectedRevision,
      down: true,
      lebih: ' Kelebihan belanja dicatat sebagai Penggantian biaya.',
    );
    if (tolak != null) return tolak;
    return _entry(
      actor,
      c!,
      TransactionType.advanceSpending,
      'Pertanggungjawaban uang muka · ${c.title}',
      draft,
      idempotencyKey,
      masterCode:
          draft.masterCode ?? _lastCode(c, TransactionType.advanceSpending),
    );
  });

  @override
  Future<Result<String>> returnUnused(
    Actor actor,
    String caseId,
    CaseEntryDraft draft, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Catat pengembalian sisa';
    final c = f.k.kase(caseId);
    final tolak = _entryChecks(
      aksi,
      c,
      CaseKind.advance,
      draft,
      expectedRevision,
      down: true,
    );
    if (tolak != null) return tolak;
    return _entry(
      actor,
      c!,
      TransactionType.advanceReturn,
      'Pengembalian sisa uang muka · ${c.title}',
      draft,
      idempotencyKey,
      accountId: draft.accountId ?? c.accountId,
    );
  });

  @override
  Future<Result<String>> collectTransit(
    Actor actor,
    String caseId,
    CaseEntryDraft draft, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Catat titipan';
    final c = f.k.kase(caseId);
    final tolak = _entryChecks(
      aksi,
      c,
      CaseKind.transit,
      draft,
      expectedRevision,
      down: false,
    );
    if (tolak != null) return tolak;
    return _entry(
      actor,
      c!,
      TransactionType.transitCollection,
      'Titipan untuk: ${_who(c)} · ${c.title}',
      draft,
      idempotencyKey,
      accountId: draft.accountId ?? c.accountId,
      masterCode:
          draft.masterCode ?? _lastCode(c, TransactionType.transitCollection),
    );
  });

  @override
  Future<Result<String>> remit(
    Actor actor,
    String caseId,
    CaseEntryDraft draft, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Salurkan';
    final c = f.k.kase(caseId);
    final tolak = _entryChecks(
      aksi,
      c,
      CaseKind.transit,
      draft,
      expectedRevision,
      down: true,
    );
    if (tolak != null) return tolak;
    return _entry(
      actor,
      c!,
      TransactionType.transitRemittance,
      'Penyaluran · ${c.title} (${_who(c)})',
      draft,
      idempotencyKey,
      accountId: draft.accountId ?? c.accountId,
      masterCode:
          draft.masterCode ??
          _lastCode(c, TransactionType.transitRemittance) ??
          _lastCode(c, TransactionType.transitCollection),
    );
  });

  @override
  Future<Result<String>> recordClaim(
    Actor actor,
    ClaimDraft claimDraft, {
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Simpan klaim';
    final g = f.ctx.grant(actor, Capability.financeRecord, ScopeRef.jemaat);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeRecord, ScopeRef.jemaat);
    }
    final d = claimDraft;
    if (d.title.trim().isEmpty) return f.ctx.no(aksi, 'Uraian belum diisi.');
    if (d.amount <= 0) return f.ctx.no(aksi, 'Jumlah belum diisi.');
    final c = FinanceCase(
      id: f.ctx.store.newId('kasus'),
      kind: CaseKind.claim,
      title: d.title.trim(),
      fundId: d.fundId,
      openedOn: f.today,
      createdBy: actor.personId,
      createdAt: f.now,
      partyId: d.partyId,
      claimAmount: d.amount,
      note: d.note,
    );
    f.k.cases.add(c);
    f.audit(
      g,
      action: 'finance.case.claim',
      summary: 'Klaim dicatat: ${c.title} · ${rp(d.amount)}',
      ref: RecordRef(_ref, c.id),
    );
    return Ok(c.id);
  });

  @override
  Future<Result<String>> payClaim(
    Actor actor,
    String claimId,
    CaseEntryDraft draft, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Bayar penggantian biaya';
    final c = f.k.kase(claimId);
    final tolak = _entryChecks(
      aksi,
      c,
      CaseKind.claim,
      draft,
      expectedRevision,
      down: true,
    );
    if (tolak != null) return tolak;
    return _entry(
      actor,
      c!,
      TransactionType.claimPayment,
      'Penggantian biaya dibayar · ${c.title}',
      draft,
      idempotencyKey,
      accountId: draft.accountId,
      masterCode:
          draft.masterCode ?? _lastCode(c, TransactionType.claimPayment),
    );
  });

  // RD04: menunggu tabel kejadian. Built as drawn (D25): a supplier refund
  // lowers Belanja, a donor return lowers Pendapatan; linked to the original
  // by its voucher in `sourceRef`.
  @override
  Future<Result<String>> refund(
    Actor actor,
    String originalTxnId,
    int amount, {
    required String reason,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Catat pengembalian';
    final o = f.k.transaction(originalTxnId);
    if (o == null || !o.isPosted) {
      return f.ctx.no(aksi, 'Hanya transaksi yang sudah dibukukan.');
    }
    // DM 5.1: a reversed original has no money left to give back.
    if (o.reversedBy != null) {
      return f.ctx.no(aksi, '${o.voucher} sudah dibalik.');
    }
    final pemasok = refundIsSupplier(o);
    if (pemasok == null) {
      return f.ctx.no(
        aksi,
        'Hanya Belanja (dari pemasok) atau Pendapatan (kepada donatur).',
      );
    }
    if (reason.trim().isEmpty) return f.ctx.no(aksi, 'Alasan belum diisi.');
    if (amount <= 0) return f.ctx.no(aksi, 'Jumlah belum diisi.');
    final boleh = o.total - refundedOf(f.k.transactions, o);
    if (amount > boleh) {
      return f.ctx.no(
        aksi,
        'melebihi jumlah transaksi asal ${o.voucher} (${rp(boleh)}).',
      );
    }
    final a0 = o.allocations.first;
    final r = _draft(
      actor,
      TransactionDraft(
        type: pemasok
            ? TransactionType.supplierRefund
            : TransactionType.donorReturn,
        effectiveDate: f.today,
        description: pemasok
            ? 'Pengembalian dari pemasok · ${o.description}'
            : 'Pengembalian kepada donatur · ${o.description}',
        sourceRef: o.voucher,
        payee: o.payee,
        accountId: o.accountOf(a0),
        allocations: [
          Allocation(
            amount: amount,
            fundId: a0.fundId,
            scopeId: a0.scopeId,
            partyId: a0.partyId,
            masterCode: a0.masterCode,
          ),
        ],
      ),
      idempotencyKey,
    );
    if (r case Refused(:final refusal)) return Refused(refusal);
    final t = (r as Ok<Transaction>).value;
    f.audit(
      f.ctx.grant(actor, Capability.financeRecord, ScopeRef.jemaat) ??
          f.ctx.own(actor),
      action: 'finance.txn.refund',
      summary: 'Pengembalian ${rp(amount)} atas ${o.voucher}',
      reason: reason.trim(),
      ref: RecordRef('transaction', t.id),
    );
    return Ok(t.id);
  });
}

/// RD04: true for a supplier refund (the original is a Belanja), false for a
/// donor return (a Pendapatan), null when [o] cannot be refunded.
bool? refundIsSupplier(Transaction o) => switch (o.type) {
  TransactionType.expense ||
  TransactionType.claimPayment ||
  TransactionType.advanceSpending => true,
  TransactionType.income => false,
  _ => null,
};

/// RD04: what is already refunded on [o] (drafts and posted, not cancelled),
/// found by its voucher in `sourceRef`.
int refundedOf(Iterable<Transaction> all, Transaction o) => all
    .where(
      (t) =>
          t.status != TransactionStatus.cancelled &&
          t.sourceRef == o.voucher &&
          (t.type == TransactionType.supplierRefund ||
              t.type == TransactionType.donorReturn),
    )
    .fold(0, (s, t) => s + t.total);
