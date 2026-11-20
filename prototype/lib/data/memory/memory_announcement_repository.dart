import '../../domain/core/core.dart';
import '../../domain/secretariat/secretariat.dart';
import '../repositories/announcement_repository.dart';
import 'memory_context.dart';
import 'memory_sekretariat.dart';

class MemoryAnnouncementRepository implements AnnouncementRepository {
  MemoryAnnouncementRepository(this.ctx);
  final MemoryContext ctx;

  @override
  List<Announcement> list({String? audienceOf}) => [
    for (final a in ctx.sek.announcements.reversed)
      if (audienceOf == null ||
          (a.status != AnnouncementStatus.draft &&
              ctx.sees(a.audience, audienceOf)))
        a,
  ];

  @override
  String? kolomOf(String personId) {
    final id = ctx.sek.memberScopes[personId];
    return id == null ? null : ctx.inti.scope(id)?.name;
  }

  Announcement? _get(String id) =>
      ctx.sek.announcements.where((a) => a.id == id).firstOrNull;

  @override
  Future<Result<Announcement>> draft(
    Actor actor,
    AnnouncementDraft announcementDraft, {
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Simpan draf';
    final g = ctx.gate(actor, Capability.announcementsDraft);
    if (g == null) {
      return ctx.refuse(actor, Capability.announcementsDraft, ScopeRef.jemaat);
    }
    final d = announcementDraft;
    if (d.title.trim().isEmpty) return ctx.no(aksi, 'judul belum diisi.');
    if (d.body.trim().isEmpty) return ctx.no(aksi, 'isi belum diisi.');
    if (d.endsOn != null && !(d.endsOn! > ctx.today)) {
      return ctx.no(aksi, 'tanggal berakhir harus setelah hari ini.');
    }
    final a = Announcement(
      id: ctx.store.newId('pengumuman'),
      title: d.title.trim(),
      body: d.body.trim(),
      audience: d.audience,
      endsOn: d.endsOn,
      draftedBy: actor.personId,
      draftedAt: ctx.now,
    );
    ctx.sek.announcements.add(a);
    ctx.audit(
      g,
      action: 'announcement.draft',
      summary: 'Pengumuman “${a.title}” disimpan sebagai Draf.',
      module: Module.announcements,
      ref: RecordRef('announcement', a.id),
    );
    ctx.notifyHolders(
      Capability.announcementsPublish,
      actor.personId,
      title: 'Pengumuman “${a.title}” menunggu diterbitkan',
      body: 'Draf oleh ${ctx.personName(actor.personId)}',
      module: Module.announcements,
      ref: RecordRef('announcement', a.id),
    );
    return Ok(a);
  });

  @override
  Future<Result<void>> publish(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Terbitkan';
    final g = ctx.gate(actor, Capability.announcementsPublish);
    if (g == null) {
      return ctx.refuse(
        actor,
        Capability.announcementsPublish,
        ScopeRef.jemaat,
      );
    }
    final a = _get(id);
    if (a == null) return ctx.no(aksi, 'pengumuman tidak ditemukan.');
    final basi = ctx.stale<void>(a.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (a.status != AnnouncementStatus.draft) {
      return ctx.no(aksi, 'pengumuman ini sudah diterbitkan.');
    }
    a
      ..status = AnnouncementStatus.published
      ..publishedBy = actor.personId
      ..publishedAt = ctx.now
      ..revision += 1;
    // For all members it goes into the Warta editions still being drafted
    // (AlurWarta: "dipilih masuk ke Warta edisi …").
    if (a.audience == Audience.all) {
      for (final e in ctx.sek.editions) {
        if (e.status == WartaStatus.draft && !(e.sunday < ctx.today)) {
          e
            ..announcementIds.add(a.id)
            ..revision += 1;
        }
      }
    }
    ctx.audit(
      g,
      action: 'announcement.publish',
      summary: 'Pengumuman “${a.title}” diterbitkan untuk ${a.audience.label}.',
      module: Module.announcements,
      ref: RecordRef('announcement', a.id),
    );
    if (a.draftedBy != actor.personId) {
      ctx.notify(
        a.draftedBy,
        title: 'Pengumuman “${a.title}” diterbitkan',
        body: 'Untuk ${a.audience.label}',
        module: Module.announcements,
        ref: RecordRef('announcement', a.id),
      );
    }
    return const Ok(null);
  });

  @override
  Future<Result<Announcement>> revise(
    Actor actor,
    String id,
    String body, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    final a = _get(id);
    final aksi = 'Terbitkan revisi ${(a?.revisionNumber ?? 1) + 1}';
    final g = ctx.gate(actor, Capability.announcementsPublish);
    if (g == null) {
      return ctx.refuse(
        actor,
        Capability.announcementsPublish,
        ScopeRef.jemaat,
      );
    }
    if (a == null) return ctx.no(aksi, 'pengumuman tidak ditemukan.');
    final basi = ctx.stale<Announcement>(a.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (a.statusAt(ctx.today) != AnnouncementStatus.published) {
      return ctx.no(aksi, 'hanya pengumuman yang sedang diterbitkan.');
    }
    final isi = body.trim();
    if (isi.isEmpty) return ctx.no(aksi, 'isi belum diisi.');
    if (isi == a.body) return ctx.no(aksi, 'isi belum diubah.');
    final lama = a.body;
    a
      ..superseded.add(
        AnnouncementRevision(
          number: a.revisionNumber,
          body: lama,
          publishedAt: a.publishedAt!,
          publishedBy: a.publishedBy!,
        ),
      )
      ..body = isi
      ..publishedAt = ctx.now
      ..publishedBy = actor.personId
      ..revision += 1;
    ctx.audit(
      g,
      action: 'announcement.revise',
      summary:
          'Pengumuman “${a.title}”: revisi ${a.revisionNumber} diterbitkan.',
      module: Module.announcements,
      ref: RecordRef('announcement', a.id),
      before: lama,
      after: isi,
    );
    return Ok(a);
  });

  @override
  Future<Result<void>> archive(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Arsipkan';
    final g = ctx.gate(actor, Capability.announcementsPublish);
    if (g == null) {
      return ctx.refuse(
        actor,
        Capability.announcementsPublish,
        ScopeRef.jemaat,
      );
    }
    final a = _get(id);
    if (a == null) return ctx.no(aksi, 'pengumuman tidak ditemukan.');
    final basi = ctx.stale<void>(a.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (a.status != AnnouncementStatus.published) {
      return ctx.no(aksi, 'hanya pengumuman yang diterbitkan.');
    }
    a
      ..status = AnnouncementStatus.archived
      ..revision += 1;
    ctx.audit(
      g,
      action: 'announcement.archive',
      summary: 'Pengumuman “${a.title}” diarsipkan.',
      module: Module.announcements,
      ref: RecordRef('announcement', a.id),
    );
    return const Ok(null);
  });
}
