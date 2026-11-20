import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/secretariat/secretariat.dart';
import '../repositories/warta_repository.dart';
import 'memory_context.dart';
import 'memory_sekretariat.dart';

class MemoryWartaRepository implements WartaRepository {
  MemoryWartaRepository(this.ctx);
  final MemoryContext ctx;

  static String idFor(Tanggal t) =>
      'warta-${t.tahun}-${t.bulan.toString().padLeft(2, '0')}-'
      '${t.hari.toString().padLeft(2, '0')}';

  @override
  List<WartaEdition> editions() =>
      [...ctx.sek.editions]..sort((a, b) => b.sunday.compareTo(a.sunday));

  @override
  WartaEdition? edition(String id) =>
      ctx.sek.editions.where((e) => e.id == id).firstOrNull;

  @override
  WartaPreview? preview(String id) {
    final e = edition(id);
    if (e == null) return null;
    return WartaPreview(
      edition: e,
      announcements: [
        for (final a in ctx.sek.announcements)
          if (e.announcementIds.contains(a.id) &&
              a.status != AnnouncementStatus.draft)
            a,
      ],
      events: [
        for (final v in e.events)
          (
            event: v,
            printed:
                v.anonymousAs == null ||
                    (v.personId != null && e.exceptionFor(v.personId!) != null)
                ? v.name
                : v.anonymousAs!,
          ),
      ],
    );
  }

  /// The gate and the edition, or the refusal.
  (Grant, WartaEdition)? _buka(
    Actor actor,
    String id,
    Capability c,
    int expected,
    String aksi,
    void Function(Refused<void>) tolak,
  ) {
    final g = ctx.gate(actor, c);
    if (g == null) {
      tolak(ctx.refuse(actor, c, ScopeRef.jemaat));
      return null;
    }
    final e = edition(id);
    if (e == null) {
      tolak(ctx.no(aksi, 'edisi tidak ditemukan.'));
      return null;
    }
    final basi = ctx.stale<void>(e.revision, expected, aksi);
    if (basi != null) {
      tolak(basi);
      return null;
    }
    return (g, e);
  }

  /// One status step: from one of [dari] to [ke], recorded with [teks].
  Future<Result<void>> _langkah(
    Actor actor,
    String id,
    int expected,
    String key, {
    required String aksi,
    required Capability c,
    required Set<WartaStatus> dari,
    required WartaStatus ke,
    required String Function(String edisi) teks,
  }) => ctx.command(key, () {
    Refused<void>? r;
    final b = _buka(actor, id, c, expected, aksi, (x) => r = x);
    if (b == null) return r!;
    final (g, e) = b;
    if (!dari.contains(e.status)) {
      return ctx.no(aksi, 'edisi ini sedang ${e.status.label}.');
    }
    e
      ..status = ke
      ..revision += 1;
    switch (ke) {
      case WartaStatus.review:
        e
          ..reviewedAt = ctx.now
          ..reviewedBy = actor.personId;
      case WartaStatus.approved:
        e
          ..approvedAt = ctx.now
          ..approvedBy = actor.personId;
      case WartaStatus.published:
        e
          ..publishedAt = ctx.now
          ..publishedBy = actor.personId;
      case WartaStatus.draft || WartaStatus.archived:
        break;
    }
    ctx.audit(
      g,
      action: 'warta.${ke.name}',
      summary: teks('Edisi ${tgl(e.sunday.awal)}'),
      module: Module.warta,
      ref: RecordRef('warta', e.id),
    );
    return const Ok(null);
  });

  @override
  Future<Result<WartaEdition>> draft(
    Actor actor,
    Tanggal sunday, {
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Susun edisi';
    final g = ctx.gate(actor, Capability.wartaEdit);
    if (g == null) {
      return ctx.refuse(actor, Capability.wartaEdit, ScopeRef.jemaat);
    }
    if (sunday.awal.weekday != DateTime.sunday) {
      return ctx.no(aksi, 'edisi Warta disusun untuk hari Minggu.');
    }
    if (edition(idFor(sunday)) != null) {
      return ctx.no(aksi, 'edisi ${tgl(sunday.awal)} sudah ada.');
    }
    final e = WartaEdition(
      id: idFor(sunday),
      sunday: sunday,
      announcementIds: {
        for (final a in ctx.sek.announcements)
          if (a.audience == Audience.all &&
              a.statusAt(ctx.today) == AnnouncementStatus.published)
            a.id,
      },
    );
    ctx.sek.editions.add(e);
    ctx.audit(
      g,
      action: 'warta.draft',
      summary: 'Edisi ${tgl(sunday.awal)} disusun sebagai Draf',
      module: Module.warta,
      ref: RecordRef('warta', e.id),
    );
    return Ok(e);
  });

  @override
  Future<Result<void>> pickAnnouncement(
    Actor actor,
    String id,
    String announcementId,
    bool include, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Pilih pengumuman';
    Refused<void>? r;
    final b = _buka(
      actor,
      id,
      Capability.wartaEdit,
      expectedRevision,
      aksi,
      (x) => r = x,
    );
    if (b == null) return r!;
    final (g, e) = b;
    if (e.status != WartaStatus.draft) return ctx.no(aksi, _kunci);
    final a = ctx.sek.announcements
        .where((x) => x.id == announcementId)
        .firstOrNull;
    if (a == null || a.status == AnnouncementStatus.draft) {
      return ctx.no(aksi, 'hanya pengumuman yang sudah diterbitkan.');
    }
    if (include) {
      e.announcementIds.add(a.id);
    } else {
      e.announcementIds.remove(a.id);
    }
    e.revision += 1;
    ctx.audit(
      g,
      action: 'warta.pick',
      summary:
          'Pengumuman “${a.title}” ${include ? 'dipilih masuk ke' : 'dikeluarkan dari'} edisi ${tgl(e.sunday.awal)}',
      module: Module.warta,
      ref: RecordRef('warta', e.id),
    );
    return const Ok(null);
  });

  static const _kunci =
      'untuk mengubah isinya, kembalikan edisi ke Draf lebih dulu.';

  @override
  Future<Result<void>> submit(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => _langkah(
    actor,
    id,
    expectedRevision,
    idempotencyKey,
    aksi: 'Tandai sudah diperiksa',
    c: Capability.wartaEdit,
    dari: {WartaStatus.draft},
    ke: WartaStatus.review,
    teks: (e) => '$e ditandai Sudah diperiksa',
  );

  @override
  Future<Result<void>> approve(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => _langkah(
    actor,
    id,
    expectedRevision,
    idempotencyKey,
    aksi: 'Setujui untuk diterbitkan',
    c: Capability.wartaEdit,
    dari: {WartaStatus.review},
    ke: WartaStatus.approved,
    teks: (e) => '$e Disetujui untuk diterbitkan',
  );

  @override
  Future<Result<void>> returnToDraft(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => _langkah(
    actor,
    id,
    expectedRevision,
    idempotencyKey,
    aksi: 'Kembali ke Draf',
    c: Capability.wartaEdit,
    dari: {WartaStatus.review, WartaStatus.approved},
    ke: WartaStatus.draft,
    teks: (e) => '$e dikembalikan ke Draf',
  );

  @override
  Future<Result<void>> publish(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => _langkah(
    actor,
    id,
    expectedRevision,
    idempotencyKey,
    aksi: 'Terbitkan',
    c: Capability.wartaPublish,
    dari: {WartaStatus.approved},
    ke: WartaStatus.published,
    teks: (e) => '$e Diterbitkan untuk semua anggota',
  );

  @override
  Future<Result<void>> ralat(
    Actor actor,
    String id, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Terbitkan ralat';
    Refused<void>? r;
    final b = _buka(
      actor,
      id,
      Capability.wartaPublish,
      expectedRevision,
      aksi,
      (x) => r = x,
    );
    if (b == null) return r!;
    final (g, e) = b;
    if (e.status != WartaStatus.published) {
      return ctx.no(aksi, 'hanya edisi yang sudah diterbitkan.');
    }
    final teks = reason.trim();
    if (teks.isEmpty) return ctx.no(aksi, 'yang diralat belum diisi.');
    e
      ..ralats.add(WartaRalat(text: teks, at: ctx.now, by: actor.personId))
      ..revision += 1;
    ctx.audit(
      g,
      action: 'warta.ralat',
      summary:
          'Ralat edisi ${tgl(e.sunday.awal)} diterbitkan sebagai revisi: $teks',
      module: Module.warta,
      ref: RecordRef('warta', e.id),
      reason: teks,
    );
    return const Ok(null);
  });

  @override
  Future<Result<void>> revealIdentity(
    Actor actor,
    String editionId,
    String personId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Tampilkan nama';
    final g = ctx.gate(actor, Capability.wartaRevealIdentity);
    if (g == null) {
      return ctx.no(
        aksi,
        'hanya Sekretaris Jemaat yang dapat mencatat pengecualian tampilan nama.',
      );
    }
    Refused<void>? r;
    final b = _buka(
      actor,
      editionId,
      Capability.wartaRevealIdentity,
      expectedRevision,
      aksi,
      (x) => r = x,
    );
    if (b == null) return r!;
    final (_, e) = b;
    final v = e.events
        .where((x) => x.personId == personId && x.anonymousAs != null)
        .firstOrNull;
    if (v == null) {
      return ctx.no(aksi, 'anggota ini tidak memilih “Tanpa nama”.');
    }
    if (e.status != WartaStatus.draft) return ctx.no(aksi, _kunci);
    final alasan = reason.trim();
    if (alasan.isEmpty) return ctx.no(aksi, 'alasan belum diisi.');
    if (e.exceptionFor(personId) != null) {
      return ctx.no(aksi, 'pengecualian ini sudah tercatat.');
    }
    e
      ..exceptions.add(
        NameException(
          personId: personId,
          printedAs: v.name,
          reason: alasan,
          at: ctx.now,
          by: actor.personId,
        ),
      )
      ..revision += 1;
    ctx.audit(
      g,
      action: 'warta.reveal_identity',
      summary: 'Pengecualian tampilan nama · ${v.name}',
      module: Module.warta,
      ref: RecordRef('warta', e.id),
      reason: alasan,
    );
    // DL5 keeps rule 638: the member is told.
    ctx.notifyPerson(
      personId,
      title: 'Nama Anda tampil di Warta edisi ${tgl(e.sunday.awal)}',
      body: 'Pengecualian oleh Sekretaris Jemaat · alasan: $alasan',
      module: Module.warta,
      ref: RecordRef('warta', e.id),
    );
    return const Ok(null);
  });
}
