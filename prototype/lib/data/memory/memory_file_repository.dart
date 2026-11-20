import '../../domain/core/core.dart';
import '../repositories/file_repository.dart';
import 'memory_context.dart';

class MemoryFileRepository implements FileRepository {
  MemoryFileRepository(this.ctx);
  final MemoryContext ctx;

  @override
  List<FileRecord> files(RecordRef ref) => [
    for (final f in ctx.inti.files)
      if (f.ref == ref) f,
  ];

  /// Who may attach to a record is the owning module's command's rule; here
  /// any signed-in person with a grant may.
  @override
  Future<Result<FileRecord>> attach(
    Actor actor,
    RecordRef ref,
    SampleFile file, {
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    final g = ctx.can.grantsOf(actor.personId, at: ctx.today).firstOrNull;
    if (g == null) return ctx.no('Lampirkan', 'Akun ini tidak aktif.');
    if (file.name.trim().isEmpty) {
      return ctx.no('Lampirkan', 'Nama berkas belum ada.');
    }
    final f = FileRecord(
      id: ctx.store.newId('berkas'),
      ref: ref,
      file: file,
      attachedBy: actor.personId,
      attachedAt: ctx.now,
    );
    ctx.inti.files.add(f);
    ctx.audit(
      g,
      action: 'file.attach',
      summary: 'Melampirkan ${file.name}',
      ref: ref,
    );
    return Ok(f);
  });
}
