import '../../core/format.dart';
import '../../domain/collaboration/collaboration.dart';
import '../../domain/core/core.dart';
import '../repositories/service_repository.dart';
import 'memory_context.dart';
import 'memory_kolaborasi.dart';

class MemoryServiceRepository implements ServiceRepository {
  MemoryServiceRepository(this.ctx);
  final MemoryContext ctx;

  static const _ref = 'service';

  @override
  List<Service> list({String? scopeId}) => [
    for (final s in ctx.kol.services)
      if (scopeId == null || s.scopeId == scopeId) s,
  ]..sort((a, b) => a.date.compareTo(b.date));

  @override
  Service? get(String id) => ctx.kol.service(id);

  @override
  List<String> approversOf(String id) {
    final s = get(id);
    if (s == null) return const [];
    return ctx.exactHolders(Capability.servicesApprove, ctx.approverScopeOf(s));
  }

  @override
  Future<Result<Service>> draft(
    Actor actor,
    ServiceDraft serviceDraft, {
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Simpan draf ibadah';
    final d = serviceDraft;
    final g = ctx.grant(actor, Capability.servicesDraft, ScopeRef(d.scopeId));
    if (g == null) {
      return ctx.refuse(actor, Capability.servicesDraft, ScopeRef(d.scopeId));
    }
    if (d.title.trim().isEmpty) return ctx.no(aksi, 'ibadah belum dipilih.');
    if (ctx.inti.scope(d.scopeId) == null) {
      return ctx.no(aksi, 'tujuan ibadah tidak dikenali.');
    }
    if (d.date < ctx.today) return ctx.no(aksi, 'tanggal sudah lewat.');
    if (d.place != null && d.place!.trim().isEmpty) {
      return ctx.no(aksi, 'tempat belum diisi.');
    }
    final s = Service(
      id: ctx.store.newId('ibadah'),
      title: d.title.trim(),
      kind: d.kind,
      scopeId: d.scopeId,
      date: d.date,
      time: d.time,
      sessions: d.sessions,
      place: d.place?.trim(),
      draftedBy: actor.personId,
      createdAt: ctx.now,
    );
    ctx.kol.services.add(s);
    ctx.audit(
      g,
      action: 'service.draft',
      summary: '${s.title} ${s.date} disimpan sebagai Draf',
      module: Module.services,
      ref: RecordRef(_ref, s.id),
    );
    for (final id in approversOf(s.id)) {
      if (id == actor.personId) continue;
      ctx.notify(
        id,
        title: 'Setujui jadwal · ${s.title}',
        body: '${tgl(s.date.awal)}${s.time == null ? '' : ' ${s.time}'}',
        type: NotificationType.action,
        module: Module.services,
        ref: RecordRef(_ref, s.id),
      );
    }
    return Ok(s);
  });

  @override
  Future<Result<Service>> approve(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Setujui jadwal';
    final s = get(id);
    if (s == null) return ctx.no(aksi, 'ibadah tidak ditemukan.');
    final lingkup = ctx.approverScopeOf(s);
    final g = ctx.exactGrant(actor, Capability.servicesApprove, lingkup);
    if (g == null) {
      if (lingkup == ScopeRef.jemaatId) {
        // AlurIbadah's copy for a Jemaat-wide service.
        final siapa = approversOf(id).map(ctx.personName).join(', ');
        return ctx.no(
          aksi,
          'ibadah seluruh Jemaat dijadwalkan Sekretaris Jemaat dan disetujui '
          'Ketua Jemaat.',
          whoCanAct: siapa.isEmpty ? null : siapa,
        );
      }
      return ctx.refuseExact(actor, Capability.servicesApprove, lingkup);
    }
    final basi = ctx.stale<Service>(s.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (s.status != ServiceStatus.draft) {
      return ctx.no(aksi, 'ibadah ini sudah disetujui.');
    }
    if (s.date < ctx.today) return ctx.no(aksi, 'tanggal sudah lewat.');
    s
      ..status = ServiceStatus.scheduled
      ..approvedBy = actor.personId
      ..approverTitle = g.title
      ..approvedAt = ctx.now
      ..revision += 1;
    // DL30: the approver now assigns its counters.
    ctx.kol.attendance[s.id] ??= AttendanceCount(serviceId: s.id);
    ctx.audit(
      g,
      action: 'service.approve',
      summary:
          '${s.title} ${s.date} dijadwalkan · Disetujui oleh '
          '${ctx.personName(actor.personId)}',
      module: Module.services,
      ref: RecordRef(_ref, s.id),
    );
    if (s.draftedBy != actor.personId) {
      ctx.notify(
        s.draftedBy,
        title: '${s.title} dijadwalkan',
        body: 'Disetujui oleh ${ctx.personName(actor.personId)}, ${g.title}',
        module: Module.services,
        ref: RecordRef(_ref, s.id),
      );
    }
    return Ok(s);
  });

  @override
  Future<Result<Service>> close(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Tutup ibadah';
    final s = get(id);
    if (s == null) return ctx.no(aksi, 'ibadah tidak ditemukan.');
    final lingkup = ctx.approverScopeOf(s);
    final g = ctx.exactGrant(actor, Capability.servicesApprove, lingkup);
    if (g == null) {
      return ctx.refuseExact(actor, Capability.servicesApprove, lingkup);
    }
    final basi = ctx.stale<Service>(s.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (s.status == ServiceStatus.draft) {
      return ctx.no(aksi, 'ibadah ini belum disetujui.');
    }
    if (s.status == ServiceStatus.closed) {
      return ctx.no(aksi, 'ibadah ini sudah ditutup.');
    }
    final c = ctx.kol.attendance[s.id];
    if (c != null && c.counted > 0 && c.status != AttendanceStatus.finalized) {
      return ctx.no(aksi, 'jumlah kehadiran belum Ditetapkan.');
    }
    s
      ..status = ServiceStatus.closed
      ..closedAt = ctx.now
      ..revision += 1;
    ctx.audit(
      g,
      action: 'service.close',
      summary: '${s.title} ${s.date} ditutup',
      module: Module.services,
      ref: RecordRef(_ref, s.id),
    );
    return Ok(s);
  });
}
