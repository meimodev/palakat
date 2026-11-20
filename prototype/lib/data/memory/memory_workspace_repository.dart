import '../../domain/core/core.dart';
import '../repositories/workspace_repository.dart';
import 'memory_context.dart';

class MemoryWorkspaceRepository implements WorkspaceRepository {
  MemoryWorkspaceRepository(this.ctx);
  final MemoryContext ctx;

  @override
  Workspace workspace() => ctx.inti.workspace;

  @override
  List<ModuleState> modules() => [
    for (final m in Module.values) ?ctx.inti.moduleState(m),
  ];

  @override
  Future<Result<ModuleState>> setModuleStatus(
    Actor actor,
    Module module,
    ModuleStatus status, {
    String? reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    final aksi = status == ModuleStatus.active
        ? 'Aktifkan modul'
        : 'Nonaktifkan modul';
    final g = ctx.grant(actor, Capability.switchModule, ScopeRef.jemaat);
    if (g == null) {
      return ctx.refuse(actor, Capability.switchModule, ScopeRef.jemaat);
    }
    final m = ctx.inti.moduleState(module)!;
    final basi = ctx.stale<ModuleState>(m.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    final alasan = reason?.trim() ?? '';
    if (status == ModuleStatus.active) {
      final perlu = module.needs;
      if (perlu != null && !ctx.can.moduleActive(perlu)) {
        return ctx.no(aksi, 'modul ${perlu.label} harus aktif lebih dulu.');
      }
    } else if (alasan.isEmpty) {
      return ctx.no(aksi, 'Alasan belum diisi.');
    }
    final sebelum = m.status.name;
    m
      ..status = status
      ..changedBy = actor.personId
      ..changedAt = ctx.now
      ..reason = alasan.isEmpty ? null : alasan
      ..revision += 1;
    ctx.audit(
      g,
      action: 'module.switch',
      summary: status == ModuleStatus.active
          ? 'Modul ${module.label} aktif'
          : 'Modul ${module.label} dinonaktifkan',
      before: sebelum,
      after: status.name,
      reason: m.reason,
      ref: RecordRef('module', module.name),
    );
    return Ok(m);
  });
}
