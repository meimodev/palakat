import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../repositories/approval_repository.dart';
import 'memory_finance.dart';

/// External approvals (README 4.2, DM 5.2): the Bendahara records what was
/// decided outside the app; "Ganti" supersedes; a material change of the
/// transaction voids it (in `TransactionRepository`).
class MemoryApprovalRepository implements ApprovalRepository {
  MemoryApprovalRepository(this.f);
  final MemoryFinance f;

  static const _ref = 'transaction';

  @override
  List<ApprovalRecord> forTransaction(String id) => [
    for (final a in f.k.approvals)
      if (a.transactionId == id) a,
  ];

  Refused<ApprovalRecord>? _cek(String aksi, ApprovalDeclaration d) {
    if (d.approverName.trim().isEmpty) {
      return f.ctx.no(aksi, 'Pemberi persetujuan belum diisi.');
    }
    if (d.method.trim().isEmpty) {
      return f.ctx.no(aksi, 'Cara persetujuan belum diisi.');
    }
    if (d.date > f.today) {
      return f.ctx.no(aksi, 'Tanggal persetujuan setelah hari ini.');
    }
    return null;
  }

  @override
  Future<Result<ApprovalRecord>> recordExternal(
    Actor actor,
    String txnId,
    ApprovalDeclaration declaration, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Catat persetujuan';
    final g = f.ctx.grant(actor, Capability.financeRecord, ScopeRef.jemaat);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeRecord, ScopeRef.jemaat);
    }
    final t = f.k.transaction(txnId);
    if (t == null) return f.ctx.no(aksi, 'Transaksi tidak ditemukan.');
    if (t.status == TransactionStatus.cancelled) {
      return f.ctx.no(aksi, 'Transaksi ini sudah dibatalkan.');
    }
    if (t.approvalMode != ApprovalMode.external) {
      return f.ctx.no(aksi, 'Transaksi ini tidak memerlukan persetujuan.');
    }
    if (f.k.approvalOf(t) != null) {
      return f.ctx.no(aksi, 'Persetujuan sudah dicatat. Pakai Ganti.');
    }
    final basi = f.ctx.stale<ApprovalRecord>(
      t.revision,
      expectedRevision,
      aksi,
    );
    if (basi != null) return basi;
    final salah = _cek(aksi, declaration);
    if (salah != null) return salah;
    final a = ApprovalRecord(
      id: f.ctx.store.newId('setuju'),
      transactionId: t.id,
      declaration: declaration,
      recordedBy: actor.personId,
      recordedAt: f.now,
      transactionRevision: t.revision,
    );
    f.k.approvals.add(a);
    f.audit(
      g,
      action: 'finance.approval.record',
      summary:
          'Persetujuan dicatat: ${declaration.approverName} · '
          '${t.description}',
      ref: RecordRef(_ref, t.id),
    );
    return Ok(a);
  });

  @override
  Future<Result<ApprovalRecord>> supersede(
    Actor actor,
    String approvalId,
    ApprovalDeclaration declaration, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Ganti persetujuan';
    final g = f.ctx.grant(actor, Capability.financeRecord, ScopeRef.jemaat);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeRecord, ScopeRef.jemaat);
    }
    final lama = f.k.approvals.where((a) => a.id == approvalId).firstOrNull;
    if (lama == null || lama.status != ApprovalStatus.recorded) {
      return f.ctx.no(aksi, 'Tidak ada persetujuan yang berlaku.');
    }
    final basi = f.ctx.stale<ApprovalRecord>(
      lama.revision,
      expectedRevision,
      aksi,
    );
    if (basi != null) return basi;
    if (reason.trim().isEmpty) return f.ctx.no(aksi, 'Alasan belum diisi.');
    final salah = _cek(aksi, declaration);
    if (salah != null) return salah;
    final t = f.k.transaction(lama.transactionId)!;
    final baru = ApprovalRecord(
      id: f.ctx.store.newId('setuju'),
      transactionId: t.id,
      declaration: declaration,
      recordedBy: actor.personId,
      recordedAt: f.now,
      transactionRevision: t.revision,
    );
    lama
      ..status = ApprovalStatus.superseded
      ..supersededBy = baru.id
      ..endedAt = f.now
      ..reason = reason.trim()
      ..revision += 1;
    f.k.approvals.add(baru);
    f.audit(
      g,
      action: 'finance.approval.supersede',
      summary: 'Persetujuan diganti: ${declaration.approverName}',
      reason: reason.trim(),
      ref: RecordRef(_ref, t.id),
    );
    return Ok(baru);
  });
}
