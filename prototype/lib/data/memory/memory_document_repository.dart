import '../../domain/core/core.dart';
import '../../domain/secretariat/secretariat.dart';
import '../repositories/document_repository.dart';
import 'memory_context.dart';
import 'memory_sekretariat.dart';

class MemoryDocumentRepository implements DocumentRepository {
  MemoryDocumentRepository(this.ctx);
  final MemoryContext ctx;

  @override
  List<ChurchDocument> list({String? audienceOf}) => [
    for (final d in ctx.sek.documents.reversed)
      if (audienceOf == null || ctx.sees(d.audience, audienceOf)) d,
  ];

  @override
  ChurchDocument? get(String id) =>
      ctx.sek.documents.where((d) => d.id == id).firstOrNull;

  @override
  Future<Result<ChurchDocument>> publish(
    Actor actor,
    DocumentDraft draft,
    SampleFile? signedCopy,
    Audience audience, {
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Terbitkan';
    final g = ctx.gate(actor, Capability.documentsPublish);
    if (g == null) {
      return ctx.refuse(actor, Capability.documentsPublish, ScopeRef.jemaat);
    }
    final judul = draft.title.trim();
    if (judul.isEmpty) return ctx.no(aksi, 'judul belum diisi.');
    final t = draft.documentDate;
    if (t != null && t > ctx.today) {
      return ctx.no(aksi, 'tanggal dokumen belum tiba.');
    }
    if (signedCopy == null) {
      return ctx.no(aksi, 'salinan bertanda tangan belum terlampir.');
    }
    final d = ChurchDocument(
      id: ctx.store.newId('dokumen'),
      kind: draft.kind,
      title: judul,
      documentDate: t,
      audience: audience,
      revisions: [
        DocumentRevision(
          number: 1,
          signedCopy: signedCopy,
          publishedAt: ctx.now,
          publishedBy: actor.personId,
        ),
      ],
    );
    ctx.sek.documents.add(d);
    ctx.audit(
      g,
      action: 'document.publish',
      summary: '$judul diterbitkan untuk ${audience.label}.',
      module: Module.churchDocuments,
      ref: RecordRef('document', d.id),
    );
    ctx.notifyAudience(
      audience,
      actor.personId,
      title: '$judul diterbitkan',
      body: '${draft.kind.label} · ditujukan untuk ${audience.label}',
      module: Module.churchDocuments,
      ref: RecordRef('document', d.id),
    );
    return Ok(d);
  });

  @override
  Future<Result<ChurchDocument>> revise(
    Actor actor,
    String id,
    String ralat,
    SampleFile? signedCopy, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Terbitkan revisi';
    final g = ctx.gate(actor, Capability.documentsPublish);
    if (g == null) {
      return ctx.refuse(actor, Capability.documentsPublish, ScopeRef.jemaat);
    }
    final d = get(id);
    if (d == null) return ctx.no(aksi, 'dokumen tidak ditemukan.');
    final basi = ctx.stale<ChurchDocument>(d.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    final r = ralat.trim();
    if (r.isEmpty) return ctx.no(aksi, 'yang diralat belum diisi.');
    if (signedCopy == null) {
      return ctx.no(aksi, 'salinan bertanda tangan revisi belum terlampir.');
    }
    final n = d.current.number + 1;
    d.revisions.add(
      DocumentRevision(
        number: n,
        signedCopy: signedCopy,
        publishedAt: ctx.now,
        publishedBy: actor.personId,
        ralat: r,
      ),
    );
    d.revision += 1;
    ctx.audit(
      g,
      action: 'document.revise',
      summary: '${d.title}: revisi $n diterbitkan. Yang diralat: $r',
      module: Module.churchDocuments,
      ref: RecordRef('document', d.id),
      reason: r,
    );
    ctx.notifyAudience(
      d.audience,
      actor.personId,
      title: '${d.title}: revisi $n diterbitkan',
      body: 'Yang diralat: $r',
      module: Module.churchDocuments,
      ref: RecordRef('document', d.id),
    );
    return Ok(d);
  });
}
