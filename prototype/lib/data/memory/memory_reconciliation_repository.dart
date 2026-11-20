import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../repositories/reconciliation_repository.dart';
import 'memory_finance.dart';
import 'memory_master_repository.dart';
import 'memory_settings_repository.dart';
import 'memory_transaction_repository.dart';

/// Reconciliation sessions, statement lines and cash counts (README 4.2,
/// DM 5.5, 6.3, 4.6 point 5): matching is on amounts, confirmed by a person;
/// a posting on the account finalized after the confirmation makes it stale
/// (`PeriodRepository.blockers`). Any change to the matching or the
/// observation drops a confirmation.
class MemoryReconciliationRepository implements ReconciliationRepository {
  MemoryReconciliationRepository(this.f);
  final MemoryFinance f;

  static const _ref = 'recon';

  @override
  ReconSession? session(String accountId, String periodId) => f.k.reconSessions
      .where((s) => s.accountId == accountId && s.periodId == periodId)
      .lastOrNull;

  @override
  List<StatementLine> statementLines(String sessionId) => [
    for (final l in f.k.statementLines)
      if (l.sessionId == sessionId) l,
  ];

  @override
  List<CashCount> cashCounts(String accountId) =>
      f.k.cashCounts.where((c) => c.accountId == accountId).toList()
        ..sort((a, b) => b.countedAt.compareTo(a.countedAt));

  // ---------- Shared figures ----------

  /// [t]'s net movement on [accountId].
  static int diAkun(Transaction t, String accountId) {
    var n = 0;
    for (final e in effectsOf(t)) {
      for (final l in e.legs) {
        if (l.accountId == accountId) n += l.amount;
      }
    }
    return n;
  }

  /// The period a cash count observes: the oldest OPEN period that has
  /// ended, else the one holding today (a count at month end closes that
  /// month's books).
  static Period? periodeHitung(MemoryFinance f) =>
      f.k.periods.where((p) => !p.isClosed && p.end < f.today).firstOrNull ??
      f.k.periodOf(f.today);

  /// Why [s] cannot be confirmed yet; null when it can: an observation, a
  /// difference of Rp0, and every statement line matched in full to posted
  /// transactions.
  static String? belumBisa(MemoryFinance f, ReconSession s) {
    final p = f.k.periodById(s.periodId)!;
    final tunai = f.k.account(s.accountId)?.type == AccountType.cash;
    final hitung =
        (f.k.cashCounts
                .where((c) => c.accountId == s.accountId && c.periodId == p.id)
                .toList()
              ..sort((a, b) => a.countedAt.compareTo(b.countedAt)))
            .lastOrNull;
    final amati = tunai ? hitung?.total : s.statementClosing;
    if (amati == null) {
      return tunai
          ? 'Kas belum dihitung.'
          : 'Saldo rekening koran belum diisi.';
    }
    var jalan = 0;
    for (final id in s.timingItems.keys) {
      final t = f.k.transaction(id);
      if (t != null && t.isPosted) jalan += diAkun(t, s.accountId);
    }
    final selisih =
        f.k.accountBalance(s.accountId, at: p.end) - (amati + jalan);
    if (selisih != 0) return 'Selisih belum dijelaskan ${rp(selisih)}.';
    var belum = 0;
    for (final l in f.k.statementLines) {
      if (l.sessionId != s.id) continue;
      var n = 0;
      for (final id in l.matchedTransactionIds) {
        final t = f.k.transaction(id);
        if (t != null && t.isPosted) n += diAkun(t, s.accountId);
      }
      if (n != l.amount) belum++;
    }
    if (belum > 0) {
      return 'Masih ada $belum mutasi bank yang belum cocok seluruhnya.';
    }
    return null;
  }

  /// Confirms [s] for the church Bendahara clearing a unit's blocker (DL33):
  /// the checks of [confirm], with the reason kept. Returns why not.
  static String? konfirmasiUnit(
    MemoryFinance f,
    ReconSession s,
    String personId,
    String reason,
  ) {
    final belum = belumBisa(f, s);
    if (belum != null) return belum;
    s
      ..status = ReconStatus.confirmed
      ..confirmedBy = personId
      ..confirmedAt = f.now
      ..confirmReason = reason
      ..revision += 1;
    return null;
  }

  Grant? _grant(Actor actor, String accountId) {
    final unit = f.k.account(accountId)?.operatedByScopeId;
    return f.ctx.grant(actor, Capability.financeReconcile, ScopeRef.jemaat) ??
        (unit == null
            ? null
            : f.ctx.grant(actor, Capability.unitFinanceRecord, ScopeRef(unit)));
  }

  Refused<T>? _tutup<T>(String aksi, Period? p) {
    if (p == null) return f.ctx.no(aksi, 'Bulan tidak ditemukan.');
    if (p.isClosed) {
      return f.ctx.no(aksi, '${bulanTahun(p.year, p.month)} sudah ditutup.');
    }
    return null;
  }

  ReconSession? _sesi(String id) =>
      f.k.reconSessions.where((s) => s.id == id).firstOrNull;

  void _buka(ReconSession s) {
    s
      ..status = ReconStatus.open
      ..reviewedBy = null
      ..reviewedAt = null
      ..confirmedBy = null
      ..confirmedAt = null
      ..confirmReason = null
      ..revision += 1;
  }

  // ---------- Commands ----------

  /// Sets the statement closing and appends [statement]'s lines (an empty
  /// file name keeps the session's file).
  @override
  Future<Result<ReconSession>> importStatement(
    Actor actor,
    String accountId,
    String periodId,
    SampleStatement statement, {
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Unggah rekening koran';
    final g = _grant(actor, accountId);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeReconcile, ScopeRef.jemaat);
    }
    final akun = f.k.account(accountId);
    if (akun == null || akun.type != AccountType.bank) {
      return f.ctx.no(aksi, 'Rekening koran hanya untuk rekening bank.');
    }
    final p = f.k.periodById(periodId);
    final tutup = _tutup<ReconSession>(aksi, p);
    if (tutup != null) return tutup;
    var s = session(accountId, periodId);
    if (s == null) {
      s = ReconSession(
        id: f.ctx.store.newId('rekon'),
        accountId: accountId,
        periodId: periodId,
      );
      f.k.reconSessions.add(s);
    } else {
      _buka(s);
    }
    s
      ..statementClosing = statement.closing
      ..statementFile = statement.fileName.isEmpty
          ? s.statementFile
          : statement.fileName;
    for (final l in statement.lines) {
      f.k.statementLines.add(
        StatementLine(
          id: f.ctx.store.newId('mutasi'),
          sessionId: s.id,
          date: l.date,
          amount: l.amount,
          description: l.description,
        ),
      );
    }
    f.audit(
      g,
      action: 'finance.recon.import',
      summary:
          'Rekening koran ${akun.name} · ${bulanTahun(p!.year, p.month)}: '
          '${rp(statement.closing)}, ${statement.lines.length} mutasi',
      ref: RecordRef(_ref, s.id),
    );
    return Ok(s);
  });

  /// Sets the matched transactions of [lineIds]; an empty [txnIds] releases
  /// them ("Lepaskan"). A part may be matched first, never more than the
  /// line.
  @override
  Future<Result<ReconSession>> match(
    Actor actor,
    String sessionId,
    List<String> lineIds,
    List<String> txnIds, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    final aksi = txnIds.isEmpty ? 'Lepaskan' : 'Cocokkan';
    final s = _sesi(sessionId);
    if (s == null) return f.ctx.no(aksi, 'Rekonsiliasi tidak ditemukan.');
    final g = _grant(actor, s.accountId);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeReconcile, ScopeRef.jemaat);
    }
    final tutup = _tutup<ReconSession>(aksi, f.k.periodById(s.periodId));
    if (tutup != null) return tutup;
    final basi = f.ctx.stale<ReconSession>(s.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    final baris = [
      for (final l in f.k.statementLines)
        if (l.sessionId == s.id && lineIds.contains(l.id)) l,
    ];
    if (baris.isEmpty) return f.ctx.no(aksi, 'Mutasi bank tidak ditemukan.');
    final txn = [for (final id in txnIds) ?f.k.transaction(id)];
    if (txn.length != txnIds.length) {
      return f.ctx.no(aksi, 'Transaksi tidak ditemukan.');
    }
    for (final t in txn) {
      if (!t.isPosted) {
        return f.ctx.no(aksi, 'Hanya transaksi yang sudah dibukukan.');
      }
      if (diAkun(t, s.accountId) == 0) {
        return f.ctx.no(aksi, '${t.voucher} tidak bergerak di rekening ini.');
      }
    }
    final mutasi = baris.fold(0, (n, l) => n + l.amount);
    final buku = txn.fold(0, (n, t) => n + diAkun(t, s.accountId));
    if (buku != 0 && (buku.sign != mutasi.sign || buku.abs() > mutasi.abs())) {
      return f.ctx.no(
        aksi,
        'Jumlah transaksi ${rp(buku)} melebihi mutasi bank ${rp(mutasi)}.',
      );
    }
    for (final l in baris) {
      l
        ..matchedTransactionIds = List.of(txnIds)
        ..revision += 1;
    }
    _buka(s);
    f.audit(
      g,
      action: 'finance.recon.match',
      summary: txnIds.isEmpty
          ? 'Pencocokan dilepas: ${baris.map((l) => l.description).join(', ')}'
          : 'Dicocokkan: ${baris.map((l) => l.description).join(', ')} ↔ '
                '${txn.map((t) => t.voucher).join(', ')}',
      ref: RecordRef(_ref, s.id),
    );
    return Ok(s);
  });

  /// Marks [txnId] in transit; marking it again releases it ("Lepaskan").
  @override
  Future<Result<ReconSession>> markTimingItem(
    Actor actor,
    String sessionId,
    String txnId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    final s = _sesi(sessionId);
    final lepas = s?.timingItems.containsKey(txnId) ?? false;
    final aksi = lepas ? 'Lepaskan' : 'Tandai dalam perjalanan';
    if (s == null) return f.ctx.no(aksi, 'Rekonsiliasi tidak ditemukan.');
    final g = _grant(actor, s.accountId);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeReconcile, ScopeRef.jemaat);
    }
    final p = f.k.periodById(s.periodId);
    final tutup = _tutup<ReconSession>(aksi, p);
    if (tutup != null) return tutup;
    final basi = f.ctx.stale<ReconSession>(s.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    final t = f.k.transaction(txnId);
    if (t == null || !t.isPosted || !p!.contains(t.effectiveDate)) {
      return f.ctx.no(aksi, 'Hanya transaksi yang dibukukan di bulan ini.');
    }
    if (diAkun(t, s.accountId) == 0) {
      return f.ctx.no(aksi, '${t.voucher} tidak bergerak di rekening ini.');
    }
    if (reason.trim().isEmpty) return f.ctx.no(aksi, 'Alasan belum diisi.');
    s.timingItems = {
      for (final e in s.timingItems.entries)
        if (e.key != txnId) e.key: e.value,
      if (!lepas) txnId: reason.trim(),
    };
    _buka(s);
    f.audit(
      g,
      action: 'finance.recon.timing',
      summary: lepas
          ? 'Dalam perjalanan dilepas: ${t.voucher}'
          : 'Dalam perjalanan: ${t.voucher}',
      reason: reason.trim(),
      ref: RecordRef(_ref, s.id),
    );
    return Ok(s);
  });

  /// A DRAFT through `TransactionRepository.createDraft`, linked to the
  /// line; it counts as matched once it is booked.
  @override
  Future<Result<Transaction>> createTxnFromLine(
    Actor actor,
    String lineId,
    TransactionDraft draft, {
    required String idempotencyKey,
  }) async {
    const aksi = 'Buat transaksi dari mutasi ini';
    final lama = f.ctx.store.idempotencyLog[idempotencyKey];
    if (lama != null) return lama as Result<Transaction>;
    final l = f.k.statementLines.where((x) => x.id == lineId).firstOrNull;
    final s = l == null ? null : _sesi(l.sessionId);
    if (l == null || s == null) {
      return f.ctx.no(aksi, 'Mutasi bank tidak ditemukan.');
    }
    if (l.matchedTransactionIds.isNotEmpty) {
      return f.ctx.no(aksi, 'Mutasi ini sudah punya transaksi.');
    }
    final r = await MemoryTransactionRepository(
      f,
      MemorySettingsRepository(f),
      MemoryMasterRepository(f),
    ).createDraft(actor, draft, idempotencyKey: '$idempotencyKey/draf');
    if (r is Refused<Transaction>) return r;
    final t = r.value;
    return f.ctx.command(idempotencyKey, () {
      l
        ..matchedTransactionIds = [t.id]
        ..revision += 1;
      _buka(s);
      return Ok(t);
    });
  }

  /// The second-checker rule (D24) for [s]'s month: OPEN → REVIEWED →
  /// CONFIRMED. A cash count with its counters and the Bendahara's clearing
  /// of a unit blocker (DL33) confirm without it.
  bool _wajibPeriksa(ReconSession s) =>
      MemorySettingsRepository(f)
          .rulesInForce(at: f.k.periodById(s.periodId)!.end)
          .secondChecker;

  /// "Tandai sudah diperiksa": by someone who checks and does not confirm
  /// the account's reconciliation, on a session ready to confirm.
  @override
  Future<Result<ReconSession>> review(
    Actor actor,
    String sessionId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Tandai sudah diperiksa';
    final s = _sesi(sessionId);
    if (s == null) return f.ctx.no(aksi, 'Rekonsiliasi tidak ditemukan.');
    final g = f.ctx.grant(actor, Capability.financeReview, ScopeRef.jemaat);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeReview, ScopeRef.jemaat);
    }
    final tutup = _tutup<ReconSession>(aksi, f.k.periodById(s.periodId));
    if (tutup != null) return tutup;
    final basi = f.ctx.stale<ReconSession>(s.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (s.status != ReconStatus.open) {
      return f.ctx.no(aksi, 'Rekonsiliasi ini sudah diperiksa.');
    }
    if (_grant(actor, s.accountId) != null) {
      return f.ctx.no(
        aksi,
        'Pemeriksa kedua adalah orang lain, bukan yang memastikan '
        'rekonsiliasi ini.',
      );
    }
    final belum = belumBisa(f, s);
    if (belum != null) return f.ctx.no(aksi, belum);
    s
      ..status = ReconStatus.reviewed
      ..reviewedBy = actor.personId
      ..reviewedAt = f.now
      ..revision += 1;
    f.audit(
      g,
      action: 'finance.recon.review',
      summary: 'Rekonsiliasi ${f.k.account(s.accountId)?.name} diperiksa',
      ref: RecordRef(_ref, s.id),
    );
    return Ok(s);
  });

  @override
  Future<Result<ReconSession>> confirm(
    Actor actor,
    String sessionId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Pastikan rekonsiliasi';
    final s = _sesi(sessionId);
    if (s == null) return f.ctx.no(aksi, 'Rekonsiliasi tidak ditemukan.');
    final g = _grant(actor, s.accountId);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeReconcile, ScopeRef.jemaat);
    }
    final tutup = _tutup<ReconSession>(aksi, f.k.periodById(s.periodId));
    if (tutup != null) return tutup;
    final basi = f.ctx.stale<ReconSession>(s.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    final belum = belumBisa(f, s);
    if (belum != null) return f.ctx.no(aksi, belum);
    // A confirmed session made stale by a book change is confirmed again
    // as it stands ("Pastikan lagi"); any change to it reopens it (_buka).
    if (_wajibPeriksa(s) && s.status == ReconStatus.open) {
      return f.ctx.no(
        aksi,
        'Wajib pemeriksa kedua: rekonsiliasi ini belum ditandai sudah '
        'diperiksa oleh orang lain.',
      );
    }
    if (s.reviewedBy == actor.personId) {
      return f.ctx.no(
        aksi,
        'Anda yang memeriksa rekonsiliasi ini; orang lain yang memastikan.',
      );
    }
    s
      ..status = ReconStatus.confirmed
      ..confirmedBy = actor.personId
      ..confirmedAt = f.now
      ..revision += 1;
    f.audit(
      g,
      action: 'finance.recon.confirm',
      summary: 'Rekonsiliasi ${f.k.account(s.accountId)?.name} dipastikan',
      ref: RecordRef(_ref, s.id),
    );
    return Ok(s);
  });

  /// The count observes [periodeHitung]. A count equal to the book is the
  /// counter's confirmation of the cash reconciliation; a difference keeps
  /// it open, a close blocker.
  @override
  Future<Result<CashCount>> recordCashCount(
    Actor actor,
    String accountId,
    Map<int, int> denominations,
    List<String> counters, {
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Simpan hitung kas';
    final g = _grant(actor, accountId);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeReconcile, ScopeRef.jemaat);
    }
    final akun = f.k.account(accountId);
    if (akun == null || akun.type != AccountType.cash) {
      return f.ctx.no(aksi, 'Hitung kas hanya untuk Kas.');
    }
    if (counters.isEmpty) {
      return f.ctx.no(aksi, 'Petugas penghitung belum dipilih.');
    }
    if (denominations.values.any((n) => n < 0)) {
      return f.ctx.no(aksi, 'Jumlah lembar tidak boleh kurang dari nol.');
    }
    final p = periodeHitung(f);
    final tutup = _tutup<CashCount>(aksi, p);
    if (tutup != null) return tutup;
    final c = CashCount(
      id: f.ctx.store.newId('hitung'),
      accountId: accountId,
      periodId: p!.id,
      countedAt: f.now,
      denominations: Map.of(denominations),
      counters: List.of(counters),
      recordedBy: actor.personId,
    );
    f.k.cashCounts.add(c);
    var s = session(accountId, p.id);
    if (s == null) {
      s = ReconSession(
        id: f.ctx.store.newId('rekon'),
        accountId: accountId,
        periodId: p.id,
      );
      f.k.reconSessions.add(s);
    } else {
      _buka(s);
    }
    if (belumBisa(f, s) == null) {
      s
        ..status = ReconStatus.confirmed
        ..confirmedBy = actor.personId
        ..confirmedAt = f.now;
    }
    f.audit(
      g,
      action: 'finance.cash.count',
      summary:
          'Hitung kas ${akun.name} · ${bulanTahun(p.year, p.month)}: '
          '${rp(c.total)}',
      ref: RecordRef(_ref, s.id),
    );
    return Ok(c);
  });
}
