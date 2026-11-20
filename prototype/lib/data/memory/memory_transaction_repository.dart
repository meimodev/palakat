import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/collaboration/collaboration.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../repositories/master_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/transaction_repository.dart';
import 'memory_finance.dart';

/// The ledger over `TabelKeuangan.transactions` (README 4.2, DM 5.1). Holds
/// the workflow rules of README 3.5: maker ≠ checker, a covering Operator is
/// not the checker, the second-checker rule from `rulesInForce`, the unit
/// treasurer's own Fund and Accounts (DL26, DL32), and the closed-period
/// refusals (RD09, D07).
class MemoryTransactionRepository implements TransactionRepository {
  MemoryTransactionRepository(this.f, this.settings, this.master);

  final MemoryFinance f;
  final SettingsRepository settings;
  final MasterRepository master;

  static const _ref = 'transaction';

  // ---------- Queries ----------

  @override
  List<Transaction> list(
    String? periodId, [
    TransactionFilter filter = const TransactionFilter(),
  ]) {
    final p = periodId == null ? null : f.k.periodById(periodId);
    if (periodId != null && p == null) return const [];
    final funds = f.visibleFundIds();
    final hasil = <Transaction>[
      for (final t in f.k.transactions)
        if ((p == null || p.contains(t.effectiveDate)) && _matches(t, filter))
          ?f.visible(t, funds),
    ]..sort(_order);
    return hasil;
  }

  static int _order(Transaction a, Transaction b) {
    final d = a.effectiveDate.compareTo(b.effectiveDate);
    if (d != 0) return d;
    if (a.isPosted && b.isPosted) return a.voucherNumber! - b.voucherNumber!;
    if (a.isPosted != b.isPosted) return a.isPosted ? -1 : 1;
    return a.createdAt.compareTo(b.createdAt);
  }

  bool _matches(Transaction t, TransactionFilter q) {
    if (q.types != null &&
        !q.types!.contains(t.type) &&
        !t.allocations.any((a) => q.types!.contains(a.type))) {
      return false;
    }
    if (q.statuses != null && !q.statuses!.contains(t.status)) return false;
    if (q.from != null && t.effectiveDate < q.from!) return false;
    if (q.to != null && t.effectiveDate > q.to!) return false;
    if (q.accountId != null &&
        t.toAccountId != q.accountId &&
        !t.allocations.any((a) => t.accountOf(a) == q.accountId)) {
      return false;
    }
    if (q.fundId != null &&
        !t.allocations.any(
          (a) => a.fundId == q.fundId || a.toFundId == q.fundId,
        )) {
      return false;
    }
    if (q.masterCode != null &&
        !t.allocations.any((a) => a.masterCode == q.masterCode)) {
      return false;
    }
    final teks = q.text?.trim().toLowerCase() ?? '';
    if (teks.isNotEmpty) {
      final isi = [
        t.description,
        ?t.payee,
        ?t.voucher,
        ?t.sourceRef,
        for (final a in t.allocations) ?a.masterCode,
      ].join(' ').toLowerCase();
      if (!teks.split(RegExp(r'\s+')).every(isi.contains)) return false;
    }
    return true;
  }

  @override
  Transaction? get(String id) {
    final t = f.k.transaction(id);
    return t == null ? null : f.visible(t, f.visibleFundIds());
  }

  @override
  List<Transaction> drafts({String? periodId}) => list(
    periodId,
    const TransactionFilter(
      statuses: {TransactionStatus.draft, TransactionStatus.reviewed},
    ),
  );

  @override
  List<VoucherEntry> voucherSeries(VoucherSeries series, int year) {
    final terakhir = f.ctx.store.lastVoucher(series.code, year);
    return [
      for (var n = 1; n <= terakhir; n++)
        VoucherEntry(
          series: series,
          year: year,
          number: n,
          transactionId: f.k.transactions
              .where(
                (t) =>
                    t.isPosted &&
                    t.series == series &&
                    t.voucherYear == year &&
                    t.voucherNumber == n,
              )
              .firstOrNull
              ?.id,
          unfinished: f.k.unfinishedVouchers
              .where(
                (u) => u.series == series && u.year == year && u.number == n,
              )
              .firstOrNull,
        ),
    ];
  }

  @override
  List<VoucherEntry> gaps(VoucherSeries series, int year) => [
    for (final e in voucherSeries(series, year))
      if (e.isGap) e,
  ];

  // ---------- Rules ----------

  /// The grant that records: the church's `finance.record`, else a unit
  /// treasurer's `unit_finance.record` in their unit.
  Grant? _recordGrant(Actor actor) =>
      f.ctx.grant(actor, Capability.financeRecord, ScopeRef.jemaat) ??
      f.ctx.grant(actor, Capability.unitFinanceRecord, ScopeRef.anywhere);

  /// The grant that may cancel or redate [t]: the church Bendahara for any
  /// draft (DL33), its maker for their own.
  Grant? _draftGrant(Actor actor, Transaction t) =>
      f.ctx.grant(actor, Capability.financeFinalize, ScopeRef.jemaat) ??
      (t.createdBy == actor.personId ? _recordGrant(actor) : null);

  /// Who may mark [t] checked: not its maker (README 3.5).
  String? _checkers(Transaction t) {
    final names = [
      for (final p in f.ctx.can.whoCan(
        Capability.financeReview,
        ScopeRef.jemaat,
        at: f.today,
      ))
        if (p.id != t.createdBy) p.name,
    ];
    return names.isEmpty ? null : names.join(', ');
  }

  /// Why [t] cannot be checked or booked yet, as one board sentence; null
  /// when it is complete. A reversal copies its original and is not checked
  /// against today's Mata Anggaran (DM 4.1 invariant 4).
  String? _incomplete(Transaction t) {
    final kurang = <String>[];
    void tambah(String s) {
      if (!kurang.contains(s)) kurang.add(s);
    }

    if (t.allocations.isEmpty || t.total <= 0) tambah('jumlah belum diisi');
    for (final a in t.allocations) {
      final type = t.typeOf(a);
      final s = postingSigns[type] ?? const PostingSign();
      if (a.amount <= 0) tambah('jumlah belum diisi');
      if ((s.account != 0 || s.fund != 0) && t.accountOf(a) == null) {
        tambah('Kas/Bank belum dipilih');
      }
      if (s.toAccount != 0) {
        if (t.toAccountId == null) tambah('Kas/Bank tujuan belum dipilih');
        if (t.toAccountId == t.accountOf(a)) {
          tambah('Kas/Bank asal dan tujuan sama');
        }
      }
      if ((s.account != 0 || s.fund != 0 || s.toAccount != 0) &&
          a.fundId == null) {
        tambah('peruntukan belum dipilih');
      }
      if (s.toFund != 0) {
        if (a.toFundId == null) tambah('peruntukan tujuan belum dipilih');
        if (a.toFundId == a.fundId) tambah('peruntukan asal dan tujuan sama');
      }
      if (t.type == TransactionType.reversal) continue;
      final perluMa =
          s.income != 0 ||
          s.expense != 0 ||
          s.transitIn != 0 ||
          s.transitOut != 0;
      if (!perluMa) continue;
      if (a.masterCode == null) {
        tambah('Mata Anggaran belum dipilih');
        continue;
      }
      // DM 4.1 invariant 4: the master of the part's kind. A remittance
      // takes a Belanja titipan row, or 2.1.01.02.00 while the version in
      // force has none (DP13: F02 draws 0128 on it).
      final kind = s.income != 0 || s.transitIn != 0
          ? MasterKind.pendapatan
          : MasterKind.belanja;
      final row =
          _row(a.masterCode!, t.effectiveDate, kind) ??
          (s.transitOut != 0 &&
                  !master
                      .pickerRows(MasterKind.belanja, t.effectiveDate)
                      .any((r) => r.allowedEffect.allowsCustody)
              ? _row(a.masterCode!, t.effectiveDate, MasterKind.pendapatan)
              : null);
      final titipan = s.transitIn != 0 || s.transitOut != 0;
      if (row == null) {
        tambah(
          'Mata Anggaran ${a.masterCode} tidak ada di daftar '
          '${kind == MasterKind.pendapatan ? 'Pendapatan' : 'Belanja'} '
          'versi yang berlaku',
        );
      } else if (!row.postable) {
        tambah('${row.code} judul kelompok, tidak dapat dibukukan');
      } else if (titipan && !row.allowedEffect.allowsCustody) {
        tambah('${row.code} tidak dapat menerima titipan');
      } else if (!titipan && !row.allowedEffect.allowsOwned) {
        tambah('${row.code} hanya untuk titipan');
      }
    }
    if (f.k.approvalMissing(t)) tambah('persetujuan belum dicatat');
    if (kurang.isEmpty) return null;
    final s = '${kurang.join(' dan ')}.';
    return s[0].toUpperCase() + s.substring(1);
  }

  /// The row [code] of [kind] in the version published and in force at [at].
  MasterRow? _row(String code, Tanggal at, MasterKind kind) =>
      master.pickerRows(kind, at).where((r) => r.code == code).firstOrNull;

  /// DL26, DL32: a unit treasurer books only in their unit's Funds, on
  /// Accounts their unit operates.
  String? _outsideUnit(Transaction t, String scopeId) {
    final unit = f.ctx.inti.scope(scopeId)?.name ?? scopeId;
    for (final a in t.allocations) {
      for (final id in {t.accountOf(a), t.toAccountId}) {
        final acc = f.k.account(id);
        final operator = acc?.operatorAt(t.effectiveDate);
        if (acc != null && operator != scopeId) {
          final oleh = operator == null
              ? 'Bendahara Jemaat'
              : f.ctx.inti.scope(operator)?.name;
          return '${acc.name} dikelola oleh $oleh, bukan oleh $unit.';
        }
      }
    }
    for (final a in t.allocations) {
      for (final id in {a.fundId, a.toFundId}) {
        final fund = f.k.fund(id);
        if (fund != null && fund.ownerScopeId != scopeId) {
          return 'peruntukan ${fund.name} bukan peruntukan $unit.';
        }
      }
    }
    return null;
  }

  /// A case may not go below zero (DM 5.4): spending above an advance is a
  /// Penggantian biaya.
  String? _overCase(Transaction t) {
    final turun = <String, int>{};
    for (final e in effectsOf(t)) {
      final c = e.allocation.caseId;
      if (c != null && e.caseDelta < 0) {
        turun[c] = (turun[c] ?? 0) - e.caseDelta;
      }
    }
    for (final MapEntry(key: id, value: jumlah) in turun.entries) {
      final c = f.k.kase(id);
      if (c == null) return 'Kasus tidak ditemukan.';
      final sisa = f.k.caseView(c, f.today).outstanding;
      if (jumlah > sisa) {
        return c.kind == CaseKind.advance
            ? 'melebihi sisa ${rp(sisa)}. Kelebihan belanja dicatat sebagai '
                  'Penggantian biaya.'
            : 'melebihi sisa ${rp(sisa)}.';
      }
    }
    return null;
  }

  /// A Fund transfer cannot move more than the source Fund holds on the
  /// Account.
  String? _overFund(Transaction t) {
    for (final a in t.allocations) {
      if (t.typeOf(a) != TransactionType.fundTransfer) continue;
      final acc = t.accountOf(a);
      final ada = acc == null
          ? 0
          : f.k.balanceByFund(acc, at: t.effectiveDate)[a.fundId] ?? 0;
      if (a.amount > ada) {
        return 'melebihi saldo peruntukan ${f.k.fund(a.fundId)?.name} '
            '(${rp(ada)}).';
      }
    }
    return null;
  }

  /// F11: a Fund transfer moves between two different Funds.
  static String? _sameFund(TransactionType type, List<Allocation> parts) =>
      parts.any(
        (a) =>
            (a.type ?? type) == TransactionType.fundTransfer &&
            a.fundId != null &&
            a.fundId == a.toFundId,
      )
      ? 'Peruntukan asal dan tujuan harus berbeda.'
      : null;

  /// DM 5.2: a Belanja of Rp2.000.000 or more needs approval outside the
  /// app, whatever the caller passed.
  static bool _needsApproval(TransactionType type, List<Allocation> parts) =>
      type == TransactionType.expense &&
      parts.fold<int>(0, (s, a) => s + a.amount) >= 2000000;
  static const _approvalRule = 'Belanja Rp2.000.000 ke atas';

  void _dropReview(Transaction t, String why) {
    if (t.status == TransactionStatus.reviewed) {
      t
        ..status = TransactionStatus.draft
        ..reviewedBy = null
        ..reviewedAt = null
        ..reviewedRevision = null;
    }
    for (final a in f.k.approvals) {
      if (a.transactionId == t.id && a.status == ApprovalStatus.recorded) {
        a
          ..status = ApprovalStatus.voided
          ..endedAt = f.now
          ..reason = why
          ..revision += 1;
      }
    }
  }

  /// DL33: the church Bendahara changing a unit's draft tells the unit.
  void _tellUnit(Transaction t, Actor actor, String what, String reason) {
    if (t.unitScopeId == null || t.createdBy == actor.personId) return;
    f.notify(
      t.createdBy,
      title: '$what oleh Bendahara Jemaat',
      body: '${t.description} · alasan: $reason',
      ref: RecordRef(_ref, t.id),
    );
  }

  /// A Panitia from Penutupan keuangan on books no ordinary transaction on
  /// its Fund (AlurPanitia); settling advances and moving its leftover out
  /// still book.
  String? _panitiaClosing(TransactionType type, List<Allocation> allocations) {
    final keluar = const {
      TransactionType.advanceSpending,
      TransactionType.advanceReturn,
      TransactionType.fundTransfer,
    }.contains(type);
    for (final p in f.ctx.store.kolaborasi.panitia) {
      if (p.fundId == null ||
          p.stage.index < PanitiaStage.financialClosing.index) {
        continue;
      }
      if (allocations.any(
        (a) => a.toFundId == p.fundId || (a.fundId == p.fundId && !keluar),
      )) {
        return p.stage == PanitiaStage.financialClosing
            ? '${p.name} sedang dalam Penutupan keuangan.'
            : '${p.name} sudah ${p.stage.label.toLowerCase()}.';
      }
    }
    return null;
  }

  Refused<T>? _missing<T>(String aksi, Transaction? t) =>
      t == null ? f.ctx.no<T>(aksi, 'Transaksi tidak ditemukan.') : null;

  String _closedForCorrection(Transaction t) {
    final p = f.k.periodOf(t.effectiveDate);
    final bulan = p == null ? 'bulan itu' : bulanTahun(p.year, p.month);
    return 'Transaksi $bulan tidak dapat diubah, dibalik, atau dikoreksi, '
        'bahkan dari bulan-bulan sesudahnya. Yang masih dapat Anda lakukan: '
        'catat kejadian setelah tutup buku.';
  }

  // ---------- Commands ----------

  @override
  Future<Result<Transaction>> createDraft(
    Actor actor,
    TransactionDraft draft, {
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Simpan draf';
    final g = _recordGrant(actor);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeRecord, ScopeRef.jemaat);
    }
    if (draft.allocations.any((a) => a.amount < 0)) {
      return f.ctx.no(aksi, 'Jumlah tidak boleh kurang dari nol.');
    }
    final samaDana = _sameFund(draft.type, draft.allocations);
    if (samaDana != null) return f.ctx.no(aksi, samaDana);
    // The opening is seeded read-only (D19); a reversal or correction comes
    // only from reverse() and correct(), which hold their checks (DM 4.3).
    if (draft.type == TransactionType.opening ||
        draft.type == TransactionType.reversal ||
        draft.reversalOf != null ||
        draft.correctionOf != null) {
      return f.ctx.no(
        aksi,
        'Saldo awal, pembalikan dan koreksi tidak dicatat sebagai draf baru.',
      );
    }
    final tutup = f.closedReason(draft.effectiveDate);
    if (tutup != null) {
      return f.ctx.no(
        aksi,
        '$tutup Pilih tanggal di bulan yang belum ditutup.',
      );
    }
    final panitia = _panitiaClosing(draft.type, draft.allocations);
    if (panitia != null) return f.ctx.no(aksi, panitia);
    final t = Transaction(
      id: f.ctx.store.newId('txn'),
      type: draft.type,
      status: TransactionStatus.draft,
      effectiveDate: draft.effectiveDate,
      description: draft.description,
      allocations: List.of(draft.allocations),
      createdBy: actor.personId,
      createdAt: f.now,
      accountId: draft.accountId,
      toAccountId: draft.toAccountId,
      payee: draft.payee,
      sourceRef: draft.sourceRef,
      approvalMode: _needsApproval(draft.type, draft.allocations)
          ? ApprovalMode.external
          : draft.approvalMode,
      approvalRule: _needsApproval(draft.type, draft.allocations)
          ? _approvalRule
          : draft.approvalRule,
      evidenceRequired: draft.evidenceRequired,
      unitScopeId: g.capabilities.contains(Capability.financeRecord)
          ? null
          : g.scopeId,
      importRowId: draft.importRowId,
      aiProposalId: draft.aiProposalId,
      refundOf: draft.refundOf,
      countedBy: List.of(draft.countedBy),
      serviceId: draft.serviceId,
    );
    f.k.transactions.add(t);
    f.audit(
      g,
      action: 'finance.txn.draft',
      summary: 'Draf dicatat: ${t.description}',
      ref: RecordRef(_ref, t.id),
    );
    return Ok(t);
  });

  @override
  Future<Result<Transaction>> editDraft(
    Actor actor,
    String id,
    TransactionPatch patch, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Ubah';
    final t = f.k.transaction(id);
    final hilang = _missing<Transaction>(aksi, t);
    if (hilang != null) return hilang;
    if (!t!.isDraft) {
      return f.ctx.no(
        aksi,
        t.isPosted
            ? 'Sudah masuk saldo dan tidak dapat diubah lagi.'
            : 'Transaksi ini sudah dibatalkan.',
      );
    }
    // DM 5.1: a reversal copies its original in full; it is not edited.
    if (t.reversalOf != null) {
      return f.ctx.no(aksi, 'Pembalikan tidak dapat diubah atau dibalik.');
    }
    final basi = f.ctx.stale<Transaction>(t.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    // DM 5.1: the maker, the church Bendahara (DL33) or the church's second
    // checker (a material edit after review); not another unit treasurer.
    final g =
        _draftGrant(actor, t) ??
        (t.unitScopeId == null
            ? f.ctx.grant(actor, Capability.financeReview, ScopeRef.jemaat)
            : null);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeRecord, ScopeRef.jemaat);
    }
    if (patch.allocations?.any((a) => a.amount < 0) ?? false) {
      return f.ctx.no(aksi, 'Jumlah tidak boleh kurang dari nol.');
    }
    final samaDana = _sameFund(
      patch.type ?? t.type,
      patch.allocations ?? t.allocations,
    );
    if (samaDana != null) return f.ctx.no(aksi, samaDana);
    if (patch.effectiveDate != null) {
      final tutup = f.closedReason(patch.effectiveDate!);
      if (tutup != null) {
        return f.ctx.no(
          aksi,
          '$tutup Pilih tanggal di bulan yang belum ditutup.',
        );
      }
    }
    t
      ..type = patch.type ?? t.type
      ..effectiveDate = patch.effectiveDate ?? t.effectiveDate
      ..description = patch.description ?? t.description
      ..allocations = patch.allocations ?? t.allocations
      ..accountId = patch.accountId ?? t.accountId
      ..toAccountId = patch.toAccountId ?? t.toAccountId
      ..payee = patch.payee ?? t.payee
      ..sourceRef = patch.sourceRef ?? t.sourceRef
      ..revision += 1;
    if (_needsApproval(t.type, t.allocations)) {
      t
        ..approvalMode = ApprovalMode.external
        ..approvalRule = _approvalRule;
    }
    if (patch.isMaterial) _dropReview(t, 'Transaksi diubah');
    f.audit(
      g,
      action: 'finance.txn.edit',
      summary: 'Draf diubah: ${t.description}',
      ref: RecordRef(_ref, t.id),
    );
    return Ok(t);
  });

  @override
  Future<Result<Transaction>> review(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Tandai sudah diperiksa';
    final t = f.k.transaction(id);
    final hilang = _missing<Transaction>(aksi, t);
    if (hilang != null) return hilang;
    switch (t!.status) {
      case TransactionStatus.reviewed:
        return f.ctx.no(aksi, 'Transaksi ini sudah diperiksa.');
      case TransactionStatus.finalized:
        return f.ctx.no(aksi, 'Sudah masuk saldo.');
      case TransactionStatus.cancelled:
        return f.ctx.no(aksi, 'Transaksi ini sudah dibatalkan.');
      case TransactionStatus.draft:
    }
    final basi = f.ctx.stale<Transaction>(t.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    final g = f.ctx.grant(actor, Capability.financeReview, ScopeRef.jemaat);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeReview, ScopeRef.jemaat);
    }
    if (g.kind == GrantKind.cover) {
      return f.ctx.no(
        aksi,
        'Operator yang menjalankan jabatan kosong tidak dapat menjadi '
        'pemeriksa.',
        whoCanAct: _checkers(t),
      );
    }
    if (t.createdBy == actor.personId) {
      return f.ctx.no(
        aksi,
        'Anda yang mencatat transaksi ini, jadi orang lain yang harus '
        'menandainya sudah diperiksa.',
        whoCanAct: _checkers(t),
      );
    }
    final kurang = _incomplete(t);
    if (kurang != null) return f.ctx.no(aksi, kurang);
    t
      ..status = TransactionStatus.reviewed
      ..reviewedBy = actor.personId
      ..reviewedAt = f.now
      ..revision += 1;
    t.reviewedRevision = t.revision;
    f.audit(
      g,
      action: 'finance.txn.review',
      summary: 'Ditandai sudah diperiksa: ${t.description}',
      ref: RecordRef(_ref, t.id),
    );
    f.notify(
      t.createdBy,
      title: 'Sudah diperiksa: ${t.description}',
      body:
          'Diperiksa oleh ${f.ctx.personName(actor.personId)} · siap dibukukan',
      ref: RecordRef(_ref, t.id),
    );
    return Ok(t);
  });

  @override
  Future<Result<String>> finalize(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Bukukan';
    final t = f.k.transaction(id);
    final hilang = _missing<String>(aksi, t);
    if (hilang != null) return hilang;
    final basi = t!.isDraft
        ? f.ctx.stale<String>(t.revision, expectedRevision, aksi)
        : null;
    if (basi != null) return basi;
    // DM 4.3: a correction's reversal and replacement post together, so
    // neither books alone from Pemeriksa, Transaksi, Main or Draf.
    final asal = t.isDraft ? (t.reversalOf ?? t.correctionOf) : null;
    if (asal != null &&
        f.k.transactions.any((x) => x.correctionOf == asal && x.isDraft)) {
      return switch (_postPair(aksi, actor, asal)) {
        Ok(:final value) => Ok(value[t.correctionOf == null ? 0 : 1]),
        Refused(:final refusal) => Refused(refusal),
      };
    }
    final (g, tolak) = _canFinalize(aksi, actor, t);
    if (tolak != null) return tolak;
    return Ok(_post(actor, t, g!));
  });

  @override
  Future<Result<List<String>>> finalizeCorrection(
    Actor actor,
    String originalId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Bukukan';
    final balik = f.k.transactions
        .where((x) => x.reversalOf == originalId && x.isDraft)
        .firstOrNull;
    final basi = balik == null
        ? null
        : f.ctx.stale<List<String>>(balik.revision, expectedRevision, aksi);
    return basi ?? _postPair(aksi, actor, originalId);
  });

  /// Posts the reversal DRAFT of [originalId] and its replacement DRAFT, if
  /// any, both or neither (DM 4.3).
  Result<List<String>> _postPair(String aksi, Actor actor, String originalId) {
    final balik = f.k.transactions
        .where((x) => x.reversalOf == originalId && x.isDraft)
        .firstOrNull;
    final ganti = f.k.transactions
        .where((x) => x.correctionOf == originalId && x.isDraft)
        .firstOrNull;
    if (balik == null) {
      return f.ctx.no<List<String>>(aksi, 'Belum ada draf pembalikan.');
    }
    final (g, tolak) = _canFinalize(aksi, actor, balik);
    if (tolak != null) return Refused(tolak.refusal);
    if (ganti != null) {
      // The replacement is checked as if the reversal were posted (a case
      // or Fund freed by the reversal counts), then the pair posts together.
      final semula = balik.status;
      balik.status = TransactionStatus.finalized;
      final (_, tolakGanti) = _canFinalize(aksi, actor, ganti);
      balik.status = semula;
      if (tolakGanti != null) return Refused(tolakGanti.refusal);
    }
    return Ok([
      _post(actor, balik, g!),
      if (ganti != null) _post(actor, ganti, g),
    ]);
  }

  /// The grant that books [t], or why it cannot be booked now.
  (Grant?, Refused<String>?) _canFinalize(
    String aksi,
    Actor actor,
    Transaction t,
  ) {
    if (t.status == TransactionStatus.cancelled) {
      return (null, f.ctx.no(aksi, 'Transaksi ini sudah dibatalkan.'));
    }
    if (t.isPosted) {
      return (null, f.ctx.no(aksi, 'Sudah dibukukan sebagai ${t.voucher}.'));
    }
    final gereja = f.ctx.grant(
      actor,
      Capability.financeFinalize,
      ScopeRef.jemaat,
    );
    final g =
        gereja ??
        f.ctx.grant(actor, Capability.unitFinanceFinalize, ScopeRef.anywhere);
    if (g == null) {
      return (
        null,
        f.ctx.refuse(actor, Capability.financeFinalize, ScopeRef.jemaat),
      );
    }
    final tutup = f.closedReason(t.effectiveDate);
    if (tutup != null) {
      return (
        null,
        f.ctx.no(
          aksi,
          '$tutup Yang masih dapat Anda lakukan: pindah tanggal ke bulan yang '
          'belum ditutup, atau batalkan.',
        ),
      );
    }
    final panitia = t.reversalOf == null && t.correctionOf == null
        ? _panitiaClosing(t.type, t.allocations)
        : null;
    if (panitia != null) return (null, f.ctx.no(aksi, panitia));
    for (final asal in {t.reversalOf, t.correctionOf}) {
      final o = f.k.transaction(asal);
      if (o != null && f.closedReason(o.effectiveDate) != null) {
        return (null, f.ctx.no(aksi, _closedForCorrection(o)));
      }
    }
    if (gereja == null) {
      final luar = _outsideUnit(t, g.scopeId);
      if (luar != null) return (null, f.ctx.no(aksi, luar));
    }
    final aturan = settings.rulesInForce(at: t.effectiveDate);
    if (aturan.secondChecker && t.status != TransactionStatus.reviewed) {
      final siapa = _checkers(t);
      return (
        null,
        f.ctx.no(
          aksi,
          siapa == null
              ? 'Wajib pemeriksa kedua, dan belum ada pemeriksa kedua yang '
                    'ditunjuk.'
              : 'Wajib pemeriksa kedua: transaksi ini belum ditandai sudah '
                    'diperiksa oleh orang lain.',
          whoCanAct: siapa,
        ),
      );
    }
    final kurang = _incomplete(t) ?? _overCase(t) ?? _overFund(t);
    if (kurang != null) return (null, f.ctx.no(aksi, kurang));
    return (g, null);
  }

  /// Gives [t] the next voucher of its year and posts it.
  String _post(Actor actor, Transaction t, Grant g) {
    t
      ..series = t.type == TransactionType.opening
          ? VoucherSeries.opn
          : VoucherSeries.bku
      ..voucherYear = t.effectiveDate.tahun;
    t
      ..voucherNumber = f.ctx.store.nextVoucher(t.series.code, t.voucherYear!)
      ..status = TransactionStatus.finalized
      ..finalizedBy = actor.personId
      ..finalizedAt = f.now
      ..revision += 1;
    // Solo use (the rule off): the one action records both checks (DM 5.1).
    t
      ..reviewedBy ??= actor.personId
      ..reviewedAt ??= f.now;
    final asal = f.k.transaction(t.reversalOf);
    if (asal != null) {
      asal
        ..reversedBy = t.id
        ..revision += 1;
    }
    final diganti = f.k.transaction(t.correctionOf);
    if (diganti != null) {
      diganti
        ..correctedBy = t.id
        ..revision += 1;
    }
    f.audit(
      g,
      action: 'finance.txn.finalize',
      summary: 'Dibukukan ${t.voucher} · ${t.description}',
      ref: RecordRef(_ref, t.id),
    );
    return t.voucher!;
  }

  @override
  Future<Result<Transaction>> cancel(
    Actor actor,
    String id, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Batalkan';
    final t = f.k.transaction(id);
    final hilang = _missing<Transaction>(aksi, t);
    if (hilang != null) return hilang;
    if (!t!.isDraft) {
      return f.ctx.no(
        aksi,
        t.isPosted
            ? 'Sudah masuk saldo; pakai koreksi dengan pembalikan.'
            : 'Transaksi ini sudah dibatalkan.',
      );
    }
    if (reason.trim().isEmpty) return f.ctx.no(aksi, 'Alasan belum diisi.');
    final basi = f.ctx.stale<Transaction>(t.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    final g = _draftGrant(actor, t);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeFinalize, ScopeRef.jemaat);
    }
    t
      ..status = TransactionStatus.cancelled
      ..cancelledBy = actor.personId
      ..cancelledAt = f.now
      ..cancelReason = reason.trim()
      ..revision += 1;
    _tellUnit(t, actor, 'Draf dibatalkan', reason.trim());
    f.audit(
      g,
      action: 'finance.txn.cancel',
      summary: 'Dibatalkan: ${t.description}',
      reason: reason.trim(),
      ref: RecordRef(_ref, t.id),
    );
    return Ok(t);
  });

  @override
  Future<Result<Transaction>> redate(
    Actor actor,
    String id,
    Tanggal newDate, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Pindah tanggal';
    final t = f.k.transaction(id);
    final hilang = _missing<Transaction>(aksi, t);
    if (hilang != null) return hilang;
    if (!t!.isDraft) {
      return f.ctx.no(
        aksi,
        t.isPosted
            ? 'Sudah masuk saldo dan tidak dapat diubah lagi.'
            : 'Transaksi ini sudah dibatalkan.',
      );
    }
    if (reason.trim().isEmpty) return f.ctx.no(aksi, 'Alasan belum diisi.');
    final basi = f.ctx.stale<Transaction>(t.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    final g = _draftGrant(actor, t);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeFinalize, ScopeRef.jemaat);
    }
    final tutup = f.closedReason(newDate);
    if (tutup != null) {
      return f.ctx.no(aksi, '$tutup Hanya bulan yang belum ditutup.');
    }
    // RD09: into a later OPEN month, not past today.
    final asal = f.k.periodOf(t.effectiveDate);
    final tujuan = f.k.periodOf(newDate);
    if (asal != null && (tujuan == null || tujuan.start <= asal.start)) {
      return f.ctx.no(
        aksi,
        'Hanya ke bulan sesudah ${bulanTahun(asal.year, asal.month)} yang '
        'belum ditutup.',
      );
    }
    if (newDate > f.today) {
      return f.ctx.no(aksi, 'Tanggal setelah hari ini, ${f.today}.');
    }
    final lama = t.effectiveDate;
    t
      ..effectiveDate = newDate
      ..revision += 1;
    _dropReview(t, 'Tanggal dipindah');
    _tellUnit(t, actor, 'Tanggal draf dipindah', reason.trim());
    f.audit(
      g,
      action: 'finance.txn.redate',
      summary: 'Tanggal dipindah: ${t.description}',
      before: '$lama',
      after: '$newDate',
      reason: reason.trim(),
      ref: RecordRef(_ref, t.id),
    );
    return Ok(t);
  });

  /// The checks of reverse and correct; null when [t] may be reversed.
  Refused<T>? _checkReversible<T>(
    String aksi,
    Actor actor,
    Transaction? t,
    String reason,
    int expectedRevision,
  ) {
    final hilang = _missing<T>(aksi, t);
    if (hilang != null) return hilang;
    if (!t!.isPosted) {
      return f.ctx.no(
        aksi,
        'Hanya transaksi yang sudah dibukukan yang dapat dibalik.',
      );
    }
    if (t.type == TransactionType.reversal) {
      return f.ctx.no(aksi, 'Pembalikan tidak dapat diubah atau dibalik.');
    }
    final sudah = f.k.transactions.any(
      (x) => x.reversalOf == t.id && x.status != TransactionStatus.cancelled,
    );
    if (sudah) return f.ctx.no(aksi, 'Transaksi ini sudah dibalik.');
    // DM 5.1 dependency check: a refund linked by refundOf would leave
    // Belanja or Pendapatan short by its amount.
    final kembali = f.k.transactions
        .where(
          (x) => x.refundOf == t.id && x.status != TransactionStatus.cancelled,
        )
        .firstOrNull;
    if (kembali != null) {
      return f.ctx.no(
        aksi,
        'Sudah ada pengembalian ${kembali.voucher ?? kembali.description}. '
        'Balik atau batalkan pengembalian itu lebih dulu.',
      );
    }
    if (reason.trim().isEmpty) return f.ctx.no(aksi, 'Alasan belum diisi.');
    final basi = f.ctx.stale<T>(t.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (f.closedReason(t.effectiveDate) != null) {
      return f.ctx.no(aksi, _closedForCorrection(t));
    }
    final hariIni = f.closedReason(f.today);
    if (hariIni != null) return f.ctx.no(aksi, hariIni);
    return null;
  }

  /// The reversal DRAFT of [t], dated today: its parts and types copied.
  Transaction _reversal(Actor actor, Transaction t, Grant g) => Transaction(
    id: f.ctx.store.newId('txn'),
    type: TransactionType.reversal,
    status: TransactionStatus.draft,
    effectiveDate: f.today,
    description: 'Pembalikan ${t.voucher}',
    allocations: [
      for (final a in t.allocations)
        Allocation(
          amount: a.amount,
          type: t.typeOf(a),
          accountId: t.accountOf(a),
          fundId: a.fundId,
          toFundId: a.toFundId,
          scopeId: a.scopeId,
          partyId: a.partyId,
          masterCode: a.masterCode,
          masterVersionId: a.masterVersionId,
          caseId: a.caseId,
          label: a.label,
        ),
    ],
    createdBy: actor.personId,
    createdAt: f.now,
    accountId: t.accountId,
    toAccountId: t.toAccountId,
    evidenceRequired: false,
    unitScopeId: g.capabilities.contains(Capability.financeRecord)
        ? null
        : g.scopeId,
    reversalOf: t.id,
  );

  @override
  Future<Result<Transaction>> reverse(
    Actor actor,
    String id, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Pembalikan';
    final t = f.k.transaction(id);
    final tolak = _checkReversible<Transaction>(
      aksi,
      actor,
      t,
      reason,
      expectedRevision,
    );
    if (tolak != null) return tolak;
    final g = f.ctx.grant(actor, Capability.financeFinalize, ScopeRef.jemaat);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeFinalize, ScopeRef.jemaat);
    }
    final r = _reversal(actor, t!, g);
    f.k.transactions.add(r);
    f.audit(
      g,
      action: 'finance.txn.reverse',
      summary: 'Pembalikan ${t.voucher} dicatat sebagai draf',
      reason: reason.trim(),
      ref: RecordRef(_ref, t.id),
    );
    return Ok(r);
  });

  @override
  Future<Result<Correction>> correct(
    Actor actor,
    String id,
    TransactionDraft replacement, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Koreksi';
    final t = f.k.transaction(id);
    final tolak = _checkReversible<Correction>(
      aksi,
      actor,
      t,
      reason,
      expectedRevision,
    );
    if (tolak != null) return tolak;
    final g = f.ctx.grant(actor, Capability.financeFinalize, ScopeRef.jemaat);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeFinalize, ScopeRef.jemaat);
    }
    final tutup = f.closedReason(replacement.effectiveDate);
    if (tutup != null) {
      return f.ctx.no(
        aksi,
        '$tutup Pilih tanggal di bulan yang belum ditutup.',
      );
    }
    final r = _reversal(actor, t!, g);
    final baru = Transaction(
      id: f.ctx.store.newId('txn'),
      type: replacement.type,
      status: TransactionStatus.draft,
      effectiveDate: replacement.effectiveDate,
      description: replacement.description,
      allocations: List.of(replacement.allocations),
      createdBy: actor.personId,
      createdAt: f.now,
      accountId: replacement.accountId,
      toAccountId: replacement.toAccountId,
      payee: replacement.payee,
      sourceRef: replacement.sourceRef,
      approvalMode: _needsApproval(replacement.type, replacement.allocations)
          ? ApprovalMode.external
          : replacement.approvalMode,
      approvalRule: _needsApproval(replacement.type, replacement.allocations)
          ? _approvalRule
          : replacement.approvalRule,
      evidenceRequired: replacement.evidenceRequired,
      correctionOf: t.id,
    );
    f.k.transactions.addAll([r, baru]);
    f.audit(
      g,
      action: 'finance.txn.correct',
      summary:
          'Koreksi ${t.voucher}: pembalikan dan pengganti dicatat '
          'sebagai draf',
      reason: reason.trim(),
      ref: RecordRef(_ref, t.id),
    );
    return Ok(Correction(reversal: r, replacement: baru));
  });
}
