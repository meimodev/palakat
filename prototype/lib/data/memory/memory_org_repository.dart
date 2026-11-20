import '../../domain/core/core.dart';
import '../repositories/org_repository.dart';
import 'memory_context.dart';

class MemoryOrgRepository implements OrgRepository {
  MemoryOrgRepository(this.ctx);
  final MemoryContext ctx;

  @override
  List<Scope> scopes({ScopeType? type}) => [
    for (final s in ctx.inti.scopes)
      if (type == null || s.type == type) s,
  ];

  @override
  Scope? scope(String id) => ctx.inti.scope(id);

  @override
  List<Scope> ancestors(String id) {
    final hasil = <Scope>[];
    var s = ctx.inti.scope(id);
    while (s?.parentId != null) {
      s = ctx.inti.scope(s!.parentId!);
      if (s == null || hasil.contains(s)) break;
      hasil.add(s);
    }
    return hasil;
  }

  @override
  Future<Result<Scope>> createScope(
    Actor actor,
    ScopeDraft draft, {
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    final c = draft.type == ScopeType.panitia
        ? Capability.panitiaCreate
        : Capability.assignPost;
    final g = ctx.grant(actor, c, ScopeRef(draft.parentId));
    if (g == null) return ctx.refuse(actor, c, ScopeRef(draft.parentId));
    if (draft.name.trim().isEmpty) {
      return ctx.no(c.label, 'Nama belum diisi.');
    }
    if (ctx.inti.scope(draft.parentId) == null) {
      return ctx.no(c.label, 'Unit induk tidak ditemukan.');
    }
    final s = Scope(
      id: ctx.store.newId('lingkup'),
      type: draft.type,
      name: draft.name.trim(),
      parentId: draft.parentId,
      start: draft.start ?? ctx.today,
    );
    ctx.inti.scopes.add(s);
    ctx.audit(
      g,
      action: 'scope.create',
      summary: 'Membuat ${s.name}',
      module: draft.type == ScopeType.panitia ? Module.panitia : null,
      ref: RecordRef('scope', s.id),
    );
    return Ok(s);
  });
}
