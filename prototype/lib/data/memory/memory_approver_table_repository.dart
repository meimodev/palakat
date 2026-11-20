import '../../core/format.dart';
import '../../domain/collaboration/collaboration.dart';
import '../../domain/core/core.dart';
import '../repositories/approver_table_repository.dart';
import 'memory_context.dart';
import 'memory_kolaborasi.dart';

class MemoryApproverTableRepository implements ApproverTableRepository {
  MemoryApproverTableRepository(this.ctx);
  final MemoryContext ctx;

  @override
  ApproverTable table() => ctx.kol.approverTable;

  @override
  Future<Result<ApproverTable>> set(
    Actor actor,
    ScopeType unitType,
    ApproverChoice approverRole,
    int threshold, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Simpan tabel';
    final g = ctx.grant(actor, Capability.requestsSetTable, ScopeRef.jemaat);
    if (g == null) {
      return ctx.refuse(actor, Capability.requestsSetTable, ScopeRef.jemaat);
    }
    final t = ctx.kol.approverTable;
    final basi = ctx.stale<ApproverTable>(t.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (!ApproverTable.unitTypes.contains(unitType)) {
      return ctx.no(aksi, 'jenis unit tidak dikenali.');
    }
    if (threshold < 0) {
      return ctx.no(aksi, 'batas tidak boleh kurang dari nol.');
    }
    final lama = t.rows[unitType];
    t.rows[unitType] = approverRole;
    t
      ..threshold = threshold
      ..savedBy = actor.personId
      ..savedAt = ctx.now
      ..revision += 1;
    ctx.audit(
      g,
      action: 'requests.set_table',
      summary:
          'Tabel pemberi persetujuan: ${_unit(unitType)} → '
          '${approverRole.labelFor(unitType)} · batas ${rp(threshold)}',
      module: Module.inAppApprovals,
      before: lama?.labelFor(unitType),
      after: approverRole.labelFor(unitType),
    );
    return Ok(t);
  });

  static String _unit(ScopeType t) => switch (t) {
    ScopeType.kolom => 'Kolom',
    ScopeType.bipra => 'BIPRA',
    ScopeType.komisi => 'Komisi',
    ScopeType.panitia => 'Panitia',
    _ => 'Jemaat',
  };
}
