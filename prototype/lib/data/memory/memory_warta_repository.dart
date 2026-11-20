import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/collaboration/collaboration.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../domain/membership/membership.dart';
import '../../domain/secretariat/secretariat.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/masking_repository.dart';
import '../repositories/period_repository.dart';
import '../repositories/report_repository.dart';
import '../repositories/service_repository.dart';
import '../repositories/warta_repository.dart';
import 'memory_context.dart';
import 'memory_sekretariat.dart';

/// The Warta reads other modules' data (PMP 6.1 joins J2, J3): names from
/// Tampilan nama, the last Sunday's Ditetapkan counts and the latest closed
/// month's snapshot.
class MemoryWartaRepository implements WartaRepository {
  MemoryWartaRepository(
    this.ctx, {
    required this.masking,
    required this.periods,
    required this.reports,
    required this.services,
    required this.attendance,
  });
  final MemoryContext ctx;
  final MaskingRepository masking;
  final PeriodRepository periods;
  final ReportRepository reports;
  final ServiceRepository services;
  final AttendanceRepository attendance;

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
    if (e.printed case final p?) return p;
    return WartaPreview(
      edition: e,
      announcements: [
        for (final a in ctx.sek.announcements)
          if (e.announcementIds.contains(a.id) &&
              a.status != AnnouncementStatus.draft)
            a,
      ],
      events: [for (final v in e.events) _cetak(e, v)],
      attendance: _hadir(e.sunday),
      finance: _keuangan(e.publishedAt),
    );
  }

  /// The name as the member chose it (TampilanNama). "Tanpa nama" prints
  /// the Kolom only, unless the Sekretaris recorded an exception; nothing
  /// of an unconfirmed or deleted person is named (DL8, DL13).
  PrintedEvent _cetak(WartaEdition e, WartaEvent v) {
    final id = v.personId;
    final x = e.exceptionFor(id);
    final orang = ctx.inti.person(id);
    final dipilih =
        masking.preference(id) == NameForm.none &&
        orang?.status == PersonStatus.active &&
        ctx.store.jemaat.profiles.containsKey(id);
    final nama = masking.printedName(id, PrintContext.warta);
    return (
      event: v,
      printed:
          x?.printedAs ??
          (dipilih
              ? 'Tanpa nama, ${masking.nameWith(id, NameForm.kolom)}'
              : nama),
      reveal: dipilih ? masking.nameWith(id, NameForm.familyKolom) : null,
      exception: x != null,
    );
  }

  /// The Ditetapkan counts of the last Sunday before [minggu] with any:
  /// a count still being counted or checked is never printed (J3, rulebook
  /// 14.9).
  WartaAttendance? _hadir(Tanggal minggu) {
    if (!ctx.can.moduleActive(Module.attendance)) return null;
    final tetap = [
      for (final s in services.list(scopeId: ScopeRef.jemaatId))
        if (s.kind == ServiceKind.minggu && s.date < minggu)
          if (attendance.count(s.id) case final c?
              when c.status == AttendanceStatus.finalized)
            (s: s, c: c),
    ];
    if (tetap.isEmpty) return null;
    final hari = tetap.last.s.date;
    final parts = [
      for (final x in tetap)
        if (x.s.date == hari) (label: x.s.title, n: x.c.total),
    ];
    return (
      sunday: hari,
      parts: parts,
      total: parts.fold(0, (n, x) => n + x.n),
    );
  }

  /// Income and spending of the latest CLOSED month, read from its close
  /// snapshot; an open month is never printed (J3). A published edition
  /// keeps the month closed by its publishing.
  WartaFinance? _keuangan(DateTime? terbit) {
    if (!ctx.can.moduleActive(Module.finance)) return null;
    final p = periods
        .periods()
        .where(
          (p) =>
              p.isClosed &&
              (terbit == null ||
                  (p.closedAt != null && !p.closedAt!.isAfter(terbit))),
        )
        .lastOrNull;
    final s = p == null ? null : reports.snapshot(p.id);
    final t = s?.pack.datasets[ReportForm.f01]?.totals;
    if (p == null || t == null) return null;
    return (
      year: p.year,
      month: p.month,
      income: t['income'] as int? ?? 0,
      expense: t['expense'] as int? ?? 0,
      closedAt: p.closedAt,
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
          ..publishedBy = actor.personId
          ..printed = preview(e.id);
      case WartaStatus.draft || WartaStatus.retired:
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
    final v = preview(e.id)?.events
        .where((x) => x.event.personId == personId && x.reveal != null)
        .firstOrNull;
    if (v == null) {
      return ctx.no(aksi, 'anggota ini tidak memilih “Tanpa nama”.');
    }
    if (e.status != WartaStatus.draft) return ctx.no(aksi, _kunci);
    final alasan = reason.trim();
    if (alasan.isEmpty) return ctx.no(aksi, 'alasan belum diisi.');
    if (v.exception) return ctx.no(aksi, 'pengecualian ini sudah tercatat.');
    e
      ..exceptions.add(
        NameException(
          personId: personId,
          printedAs: v.reveal!,
          reason: alasan,
          at: ctx.now,
          by: actor.personId,
        ),
      )
      ..revision += 1;
    ctx.audit(
      g,
      action: 'warta.reveal_identity',
      summary: 'Pengecualian tampilan nama · ${v.reveal}',
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
