import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../repositories/evidence_repository.dart';
import 'memory_finance.dart';

/// Supporting documents (README 4.2, DM 5.3): append-only decision lines;
/// uploaded is not verified; no self-verification (README 3.5); an
/// exception needs a reason. Failed and quarantined uploads are not
/// reachable (D9).
class MemoryEvidenceRepository implements EvidenceRepository {
  MemoryEvidenceRepository(this.f);
  final MemoryFinance f;

  static const _ref = 'transaction';

  @override
  List<EvidenceItem> forTransaction(String id) => [
    for (final e in f.k.evidence)
      if (e.transactionId == id) e,
  ];

  @override
  List<({Transaction transaction, EvidenceStatus status})> list(
    String periodId,
    EvidenceStatus? status,
  ) {
    final p = f.k.periodById(periodId);
    if (p == null) return const [];
    final boleh = f.visibleFundIds();
    return [
      for (final t in f.k.transactions)
        if (p.contains(t.effectiveDate) &&
            t.status != TransactionStatus.cancelled)
          if ((f.visible(t, boleh), f.k.evidenceStatus(t))
              case (final v?, final s) when status == null || s == status)
            (transaction: v, status: s),
    ];
  }

  /// Who may verify, reject or release: the Bendahara or the second
  /// checker.
  Grant? _decider(Actor actor) =>
      f.ctx.grant(actor, Capability.financeFinalize, ScopeRef.jemaat) ??
      f.ctx.grant(actor, Capability.financeReview, ScopeRef.jemaat);

  String? _deciders(String bukan) {
    final names = <String>{
      for (final c in [Capability.financeFinalize, Capability.financeReview])
        for (final p in f.ctx.can.whoCan(c, ScopeRef.jemaat, at: f.today))
          if (p.id != bukan) p.name,
    };
    return names.isEmpty ? null : names.join(', ');
  }

  EvidenceItem? _item(String id) =>
      f.k.evidence.where((e) => e.id == id).firstOrNull;

  @override
  Future<Result<EvidenceItem>> upload(
    Actor actor,
    String txnId,
    SampleFile file, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Unggah dokumen';
    final g =
        f.ctx.grant(actor, Capability.financeRecord, ScopeRef.jemaat) ??
        f.ctx.grant(actor, Capability.unitFinanceRecord, ScopeRef.anywhere);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeRecord, ScopeRef.jemaat);
    }
    final t = f.k.transaction(txnId);
    if (t == null) return f.ctx.no(aksi, 'Transaksi tidak ditemukan.');
    if (t.status == TransactionStatus.cancelled) {
      return f.ctx.no(aksi, 'Transaksi ini sudah dibatalkan.');
    }
    final basi = f.ctx.stale<EvidenceItem>(t.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    final e = EvidenceItem(
      id: f.ctx.store.newId('bukti'),
      transactionId: t.id,
      state: EvidenceItemState.uploaded,
      by: actor.personId,
      at: f.now,
      file: file,
    );
    f.k.evidence.add(e);
    f.audit(
      g,
      action: 'finance.evidence.upload',
      summary: 'Dokumen pendukung diunggah: ${file.name}',
      ref: RecordRef(_ref, t.id),
    );
    return Ok(e);
  });

  @override
  Future<Result<EvidenceItem>> verify(
    Actor actor,
    String evidenceId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Verifikasi';
    final e = _item(evidenceId);
    if (e == null || e.state != EvidenceItemState.uploaded) {
      return f.ctx.no(aksi, 'Tidak ada dokumen yang menunggu verifikasi.');
    }
    final basi = f.ctx.stale<EvidenceItem>(e.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    final g = _decider(actor);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeFinalize, ScopeRef.jemaat);
    }
    if (e.by == actor.personId) {
      return f.ctx.no(
        aksi,
        'Anda yang mengunggah dokumen ini, jadi orang lain yang harus '
        'memverifikasinya.',
        whoCanAct: _deciders(actor.personId),
      );
    }
    e
      ..state = EvidenceItemState.verified
      ..decidedBy = actor.personId
      ..decidedAt = f.now
      ..revision += 1;
    f.audit(
      g,
      action: 'finance.evidence.verify',
      summary: 'Dokumen pendukung diverifikasi: ${e.file?.name ?? ''}',
      ref: RecordRef(_ref, e.transactionId),
    );
    return Ok(e);
  });

  @override
  Future<Result<EvidenceItem>> reject(
    Actor actor,
    String evidenceId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Tolak dokumen';
    final e = _item(evidenceId);
    if (e == null || e.state != EvidenceItemState.uploaded) {
      return f.ctx.no(aksi, 'Tidak ada dokumen yang menunggu verifikasi.');
    }
    final basi = f.ctx.stale<EvidenceItem>(e.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    final g = _decider(actor);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeFinalize, ScopeRef.jemaat);
    }
    if (reason.trim().isEmpty) return f.ctx.no(aksi, 'Alasan belum diisi.');
    e
      ..state = EvidenceItemState.rejected
      ..decidedBy = actor.personId
      ..decidedAt = f.now
      ..reason = reason.trim()
      ..revision += 1;
    f.audit(
      g,
      action: 'finance.evidence.reject',
      summary: 'Dokumen pendukung ditolak: ${e.file?.name ?? ''}',
      reason: reason.trim(),
      ref: RecordRef(_ref, e.transactionId),
    );
    return Ok(e);
  });

  @override
  Future<Result<EvidenceItem>> acceptException(
    Actor actor,
    String txnId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Catat pengecualian';
    // The Ketua Jemaat grants it; the Bendahara records it (Dokumen board).
    final g =
        f.ctx.grant(
          actor,
          Capability.financeAcceptException,
          ScopeRef.jemaat,
        ) ??
        f.ctx.grant(actor, Capability.financeFinalize, ScopeRef.jemaat);
    if (g == null) {
      return f.ctx.refuse(
        actor,
        Capability.financeAcceptException,
        ScopeRef.jemaat,
      );
    }
    final t = f.k.transaction(txnId);
    if (t == null) return f.ctx.no(aksi, 'Transaksi tidak ditemukan.');
    final basi = f.ctx.stale<EvidenceItem>(t.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (reason.trim().isEmpty) return f.ctx.no(aksi, 'Alasan belum diisi.');
    final s = f.k.evidenceStatus(t);
    if (s != EvidenceStatus.requiredMissing && s != EvidenceStatus.uploaded) {
      return f.ctx.no(aksi, 'Dokumen pendukung transaksi ini sudah beres.');
    }
    final e = EvidenceItem(
      id: f.ctx.store.newId('bukti'),
      transactionId: t.id,
      state: EvidenceItemState.exception,
      by: actor.personId,
      at: f.now,
      reason: reason.trim(),
    );
    f.k.evidence.add(e);
    f.audit(
      g,
      action: 'finance.evidence.exception',
      summary: 'Dokumen pendukung dikecualikan: ${t.description}',
      reason: reason.trim(),
      ref: RecordRef(_ref, t.id),
    );
    return Ok(e);
  });

  @override
  Future<Result<EvidenceItem>> release(
    Actor actor,
    String evidenceId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Lepaskan dokumen';
    final e = _item(evidenceId);
    if (e == null ||
        e.state == EvidenceItemState.released ||
        e.state == EvidenceItemState.rejected) {
      return f.ctx.no(aksi, 'Tidak ada dokumen yang dapat dilepaskan.');
    }
    final basi = f.ctx.stale<EvidenceItem>(e.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    final g = _decider(actor);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeFinalize, ScopeRef.jemaat);
    }
    if (reason.trim().isEmpty) return f.ctx.no(aksi, 'Alasan belum diisi.');
    final t = f.k.transaction(e.transactionId);
    if (t != null && f.k.isClosed(t.effectiveDate)) {
      return f.ctx.no(aksi, 'Bulannya sudah ditutup.');
    }
    e
      ..state = EvidenceItemState.released
      ..decidedBy = actor.personId
      ..decidedAt = f.now
      ..reason = reason.trim()
      ..revision += 1;
    f.audit(
      g,
      action: 'finance.evidence.release',
      summary: 'Dokumen pendukung dilepaskan: ${e.file?.name ?? ''}',
      reason: reason.trim(),
      ref: RecordRef(_ref, e.transactionId),
    );
    return Ok(e);
  });
}
