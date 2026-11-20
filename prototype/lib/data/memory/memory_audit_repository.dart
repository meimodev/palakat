import '../../domain/core/core.dart';
import '../repositories/audit_repository.dart';
import 'memory_context.dart';

class MemoryAuditRepository implements AuditRepository {
  MemoryAuditRepository(this.ctx);
  final MemoryContext ctx;

  @override
  List<AuditRecord> list(AuditFilter f) {
    final hasil = [
      for (final r in ctx.inti.audit.reversed)
        if ((f.personId == null || r.personId == f.personId) &&
            (f.module == null || r.module == f.module) &&
            (!f.coreOnly || r.module == null) &&
            (f.ref == null || r.ref == f.ref) &&
            (f.actionPrefix == null || r.action.startsWith(f.actionPrefix!)) &&
            (f.from == null || !r.at.isBefore(f.from!)) &&
            (f.to == null || !r.at.isAfter(f.to!)))
          r,
    ];
    // Newest first; equal times keep the newest-appended first.
    return hasil..sort((a, b) => b.at.compareTo(a.at));
  }
}
