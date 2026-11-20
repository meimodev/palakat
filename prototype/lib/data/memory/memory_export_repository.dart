import '../../domain/core/core.dart';
import '../repositories/export_repository.dart';
import 'memory_context.dart';

class MemoryExportRepository implements ExportRepository {
  MemoryExportRepository(this.ctx);
  final MemoryContext ctx;

  @override
  Future<Result<ExportManifest>> build(
    Actor actor, {
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    final g = ctx.grant(actor, Capability.export, ScopeRef.jemaat);
    if (g == null) return ctx.refuse(actor, Capability.export, ScopeRef.jemaat);
    final t = ctx.today;
    String dua(int n) => n.toString().padLeft(2, '0');
    final i = ctx.inti;
    final m = ExportManifest(
      fileName:
          'ekspor-jemaat-karunia-${t.tahun}-${dua(t.bulan)}-${dua(t.hari)}.zip',
      createdAt: ctx.now,
      // ponytail: core tables only; later milestones add their own counts.
      counts: {
        'orang': i.people.where((p) => !p.isSystem).length,
        'pihak': i.parties.length,
        'lingkup': i.scopes.length,
        'jabatan': i.posts.length,
        'penugasan': i.assignments.length,
        'pelimpahan': i.delegations.length,
        'riwayat': i.audit.length,
        'berkas': i.files.length,
      },
    );
    ctx.audit(
      g,
      action: 'export.build',
      summary: 'Membuat ekspor ${m.fileName}',
    );
    return Ok(m);
  });
}
