import '../../core/format.dart';
import '../../domain/collaboration/collaboration.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../repositories/case_repository.dart';
import '../repositories/fund_request_repository.dart';
import 'memory_context.dart';
import 'memory_kolaborasi.dart';

/// Fund requests with IN_APP approval (DL29, DM 5.2). The approver follows
/// the Fund's owner and the approver table; the requester never approves,
/// so a request from the unit's own head goes to the Ketua Jemaat.
class MemoryFundRequestRepository implements FundRequestRepository {
  MemoryFundRequestRepository(this.ctx, this._cases);

  final MemoryContext ctx;

  /// The payment is drafted through its issueAdvance (README 4.5).
  final CaseRepository _cases;

  static const _ref = 'fund_request';

  FundRequestView _view(FundRequest r) {
    final t = ctx.store.keuangan.transaction(r.paymentTransactionId);
    final state = t != null && t.isPosted
        ? FundRequestState.paid
        : t != null && t.isDraft
        ? FundRequestState.paymentRecorded
        : switch (r.approval) {
            RequestApproval.notRequired => FundRequestState.noApprovalNeeded,
            RequestApproval.pending => FundRequestState.waiting,
            RequestApproval.approved => FundRequestState.approved,
            RequestApproval.rejected => FundRequestState.refused,
          };
    return FundRequestView(request: r, state: state);
  }

  @override
  List<FundRequestView> list({String? personId}) => [
    for (final r in ctx.kol.fundRequests.reversed)
      if (personId == null || r.requestedBy == personId) _view(r),
  ];

  @override
  FundRequestView? get(String id) {
    final r = ctx.kol.fundRequest(id);
    return r == null ? null : _view(r);
  }

  @override
  List<Fund> requestableFunds(String personId) {
    final unit = {
      for (final g in ctx.can.grantsOf(personId, at: ctx.today))
        if (g.kind != GrantKind.member &&
            g.capabilities.contains(Capability.requestsSubmit))
          g.scopeId,
    };
    final aktif = [
      for (final f in ctx.store.keuangan.funds)
        if (f.activeAt(ctx.today)) f,
    ];
    return [
      for (final f in aktif)
        if (unit.contains(f.ownerScopeId)) f,
      for (final f in aktif)
        if (f.ownerScopeId == ScopeRef.jemaatId) f,
    ];
  }

  /// DL29: who decides a request on [fundId] by [requesterId]: the scope of
  /// the deciding post and its title.
  (String, String) _approverOf(String fundId, String requesterId) {
    final owner =
        ctx.store.keuangan.fund(fundId)?.ownerScopeId ?? ScopeRef.jemaatId;
    final type = ctx.inti.scope(owner)?.type ?? ScopeType.jemaat;
    final choice = ctx.kol.approverTable.choiceFor(type);
    var lingkup = choice == ApproverChoice.ketuaJemaat
        ? ScopeRef.jemaatId
        : owner;
    // The requester heads that unit: no self-approval, so the Ketua Jemaat.
    if (lingkup != ScopeRef.jemaatId &&
        ctx
            .exactGrants(requesterId, Capability.requestsApprove, lingkup)
            .isNotEmpty) {
      lingkup = ScopeRef.jemaatId;
    }
    if (lingkup == ScopeRef.jemaatId) return (lingkup, 'Ketua Jemaat');
    final post = ctx.inti.posts
        .where(
          (p) =>
              p.scopeId == lingkup &&
              roleCapabilities[p.role]!.contains(Capability.requestsApprove),
        )
        .firstOrNull;
    return (lingkup, post?.title ?? choice.labelFor(type));
  }

  RequestApproval _needs(int amount) => amount < ctx.kol.approverTable.threshold
      ? RequestApproval.notRequired
      : RequestApproval.pending;

  void _notifyApprovers(FundRequest r, String title) {
    for (final id in ctx.exactHolders(
      Capability.requestsApprove,
      r.approverScopeId,
    )) {
      if (id == r.requestedBy) continue;
      ctx.notify(
        id,
        title: title,
        body:
            '${rp(r.amount)} · ${r.purpose} · ${ctx.personName(r.requestedBy)}, '
            '${r.requesterTitle}',
        type: NotificationType.action,
        module: Module.inAppApprovals,
        ref: RecordRef(_ref, r.id),
      );
    }
  }

  /// The Bendahara Jemaat is told a request may be paid.
  void _notifyPayer(FundRequest r) {
    for (final p in ctx.inti.people) {
      if (p.isSystem || p.id == r.requestedBy) continue;
      if (ctx.can
          .grantsFor(
            p.id,
            Capability.financeFinalize,
            ScopeRef.jemaat,
            at: ctx.today,
          )
          .isNotEmpty) {
        ctx.notify(
          p.id,
          title: 'Permintaan dana siap dibayar · ${r.purpose}',
          body: '${rp(r.amount)} · dibukukan sebagai Uang Muka diberikan',
          type: NotificationType.action,
          module: Module.inAppApprovals,
          ref: RecordRef(_ref, r.id),
        );
      }
    }
  }

  @override
  Future<Result<FundRequest>> submit(
    Actor actor,
    FundRequestDraft requestDraft, {
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Ajukan';
    final d = requestDraft;
    final lingkup = d.scopeId == null
        ? ScopeRef.anywhere
        : ScopeRef(d.scopeId!);
    final g = ctx.grant(actor, Capability.requestsSubmit, lingkup);
    if (g == null) {
      return ctx.refuse(actor, Capability.requestsSubmit, lingkup);
    }
    if (d.purpose.trim().isEmpty) return ctx.no(aksi, 'keperluan belum diisi.');
    if (d.amount <= 0) return ctx.no(aksi, 'jumlah belum diisi.');
    final fund = ctx.store.keuangan.fund(d.fundId);
    if (fund == null || !fund.activeAt(ctx.today)) {
      return ctx.no(aksi, 'peruntukan belum dipilih.');
    }
    final (scope, title) = _approverOf(d.fundId, actor.personId);
    final r = FundRequest(
      id: ctx.store.newId('permintaan-dana'),
      purpose: d.purpose.trim(),
      amount: d.amount,
      fundId: d.fundId,
      scopeId: d.scopeId ?? g.scopeId,
      requestedBy: actor.personId,
      requesterTitle: g.title,
      requestedAt: ctx.now,
      approval: _needs(d.amount),
      approverScopeId: scope,
      approverTitle: title,
    );
    ctx.kol.fundRequests.add(r);
    ctx.audit(
      g,
      action: 'request.submit',
      summary: 'Permintaan dana ${rp(r.amount)} · ${r.purpose} diajukan',
      module: Module.inAppApprovals,
      ref: RecordRef(_ref, r.id),
    );
    if (r.approval == RequestApproval.pending) {
      _notifyApprovers(r, 'Permintaan dana menunggu persetujuan');
    } else {
      _notifyPayer(r);
    }
    return Ok(r);
  });

  @override
  Future<Result<FundRequest>> approve(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(
    idempotencyKey,
    () => _decide(actor, id, null, expectedRevision),
  );

  @override
  Future<Result<FundRequest>> refuse(
    Actor actor,
    String id, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(
    idempotencyKey,
    () => _decide(actor, id, reason, expectedRevision),
  );

  /// Approves, or with [reason] refuses.
  Result<FundRequest> _decide(
    Actor actor,
    String id,
    String? reason,
    int expectedRevision,
  ) {
    final aksi = reason == null ? 'Setujui' : 'Tidak disetujui';
    final r = ctx.kol.fundRequest(id);
    if (r == null) return ctx.no(aksi, 'permintaan tidak ditemukan.');
    // PermintaanDana k4, AlurDana: another post never opens the way.
    if (r.requestedBy == actor.personId) {
      return ctx.no(
        aksi,
        'permintaan ini Anda ajukan sendiri sebagai ${r.requesterTitle}.',
        whoCanAct: _approverNames(r),
      );
    }
    final g = ctx.exactGrant(
      actor,
      Capability.requestsApprove,
      r.approverScopeId,
    );
    if (g == null) {
      return ctx.refuseExact(
        actor,
        Capability.requestsApprove,
        r.approverScopeId,
      );
    }
    final basi = ctx.stale<FundRequest>(r.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (r.approval != RequestApproval.pending) {
      return ctx.no(aksi, 'permintaan ini tidak menunggu persetujuan.');
    }
    final alasan = reason?.trim();
    if (alasan != null && alasan.isEmpty) {
      return ctx.no(aksi, 'alasan belum diisi.');
    }
    final hasil = alasan == null
        ? RequestApproval.approved
        : RequestApproval.rejected;
    r
      ..approval = hasil
      ..decisions.add(
        RequestDecision(
          approval: hasil,
          by: actor.personId,
          byTitle: g.title,
          at: ctx.now,
          amount: r.amount,
          reason: alasan,
        ),
      )
      ..revision += 1;
    final nama = ctx.personName(actor.personId);
    ctx.audit(
      g,
      action: alasan == null ? 'request.approve' : 'request.refuse',
      summary: alasan == null
          ? 'Permintaan dana Disetujui oleh $nama, ${g.title}'
          : 'Permintaan dana tidak disetujui · alasan: $alasan',
      module: Module.inAppApprovals,
      ref: RecordRef(_ref, r.id),
      reason: alasan,
    );
    ctx.notify(
      r.requestedBy,
      title: alasan == null
          ? 'Permintaan dana Disetujui oleh $nama'
          : 'Permintaan dana tidak disetujui',
      body: alasan == null
          ? '${rp(r.amount)} · ${r.purpose}'
          : 'Alasan: $alasan',
      module: Module.inAppApprovals,
      ref: RecordRef(_ref, r.id),
    );
    if (alasan == null) _notifyPayer(r);
    return Ok(r);
  }

  String? _approverNames(FundRequest r) {
    final s = ctx
        .exactHolders(Capability.requestsApprove, r.approverScopeId)
        .where((id) => id != r.requestedBy)
        .map(ctx.personName)
        .join(', ');
    return s.isEmpty ? null : s;
  }

  @override
  Future<Result<FundRequest>> changeAmount(
    Actor actor,
    String id,
    int amount, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Ubah jumlah';
    final r = ctx.kol.fundRequest(id);
    if (r == null) return ctx.no(aksi, 'permintaan tidak ditemukan.');
    if (r.requestedBy != actor.personId) {
      return ctx.no(aksi, 'hanya yang mengajukan yang mengubah jumlahnya.');
    }
    final g = ctx.grant(actor, Capability.requestsSubmit, ScopeRef(r.scopeId));
    if (g == null) {
      return ctx.refuse(actor, Capability.requestsSubmit, ScopeRef(r.scopeId));
    }
    final basi = ctx.stale<FundRequest>(r.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (_view(r).state
        case FundRequestState.paid || FundRequestState.paymentRecorded) {
      return ctx.no(aksi, 'pembayarannya sudah dicatat.');
    }
    if (amount <= 0) return ctx.no(aksi, 'jumlah belum diisi.');
    if (amount == r.amount) return ctx.no(aksi, 'jumlah belum diubah.');
    final alasan = reason.trim();
    if (alasan.isEmpty) return ctx.no(aksi, 'alasan belum diisi.');
    final lama = r.amount;
    // DM 5.2: a material change voids the decision; it stays in Riwayat.
    for (var i = 0; i < r.decisions.length; i++) {
      if (!r.decisions[i].superseded) {
        r.decisions[i] = r.decisions[i].supersede();
      }
    }
    r
      ..amount = amount
      ..approval = _needs(amount)
      ..revision += 1;
    ctx.audit(
      g,
      action: 'request.change_amount',
      summary:
          'Jumlah diubah dari ${rp(lama)} menjadi ${rp(amount)} · ${r.purpose}',
      module: Module.inAppApprovals,
      ref: RecordRef(_ref, r.id),
      reason: alasan,
      before: rp(lama),
      after: rp(amount),
    );
    if (r.approval == RequestApproval.pending) {
      _notifyApprovers(r, 'Permintaan dana menunggu persetujuan lagi');
    }
    return Ok(r);
  });

  @override
  Future<Result<String>> recordPayment(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Catat pembayaran';
    final r = ctx.kol.fundRequest(id);
    if (r == null) return ctx.no(aksi, 'permintaan tidak ditemukan.');
    final g = ctx.grant(actor, Capability.financeRecord, ScopeRef.jemaat);
    if (g == null) {
      return ctx.refuse(actor, Capability.financeRecord, ScopeRef.jemaat);
    }
    final basi = ctx.stale<String>(r.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    final v = _view(r);
    if (v.state == FundRequestState.paid ||
        v.state == FundRequestState.paymentRecorded) {
      return ctx.no(aksi, 'pembayarannya sudah dicatat.');
    }
    if (!v.payable) return ctx.no(aksi, 'permintaan ini belum disetujui.');
    final k = ctx.store.keuangan;
    // The Jemaat-operated Kas/Bank holding most of the request's Fund.
    final akun = [
      for (final a in k.accounts)
        if (a.activeAt(ctx.today) && a.operatorAt(ctx.today) == null) a,
    ];
    int saldo(String accountId) =>
        k.balanceByFund(accountId, at: ctx.today)[r.fundId] ?? 0;
    akun.sort((a, b) => saldo(b.id).compareTo(saldo(a.id)));
    final pihak = ctx.inti.parties
        .where((p) => p.personId == r.requestedBy)
        .firstOrNull;
    final key = '$idempotencyKey/uang-muka';
    _cases.issueAdvance(
      actor,
      CaseDraft(
        kind: CaseKind.advance,
        title: r.purpose,
        fundId: r.fundId,
        amount: r.amount,
        partyId: pihak?.id,
        payeeName: pihak == null ? ctx.personName(r.requestedBy) : null,
        scopeId: r.scopeId,
        accountId: akun.firstOrNull?.id,
        note: 'Permintaan dana ${r.requesterTitle}',
      ),
      idempotencyKey: key,
    );
    // The command body ran at once; its result is in the log.
    final hasil = ctx.store.idempotencyLog[key]! as Result<String>;
    if (hasil is! Ok<String>) return hasil;
    final t = k.transaction(hasil.value);
    r
      ..paymentTransactionId = hasil.value
      ..caseId = t?.allocations.firstOrNull?.caseId
      ..revision += 1;
    ctx.audit(
      g,
      action: 'request.record_payment',
      summary: 'Uang Muka diberikan ${rp(r.amount)} dicatat · ${r.purpose}',
      module: Module.inAppApprovals,
      ref: RecordRef(_ref, r.id),
    );
    ctx.notify(
      r.requestedBy,
      title: 'Pembayaran permintaan dana dicatat',
      body: '${rp(r.amount)} · ${r.purpose} · dibukukan setelah diperiksa',
      module: Module.inAppApprovals,
      ref: RecordRef(_ref, r.id),
    );
    return Ok(hasil.value);
  });
}
