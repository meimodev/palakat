import '../../domain/collaboration/collaboration.dart';
import '../../domain/core/core.dart';
import '../repositories/attendance_repository.dart';
import 'memory_context.dart';
import 'memory_kolaborasi.dart';

/// DL30: the service's approver assigns counters, reviews and finalizes;
/// counters only count.
class MemoryAttendanceRepository implements AttendanceRepository {
  MemoryAttendanceRepository(this.ctx);
  final MemoryContext ctx;

  static const _ref = 'attendance';

  @override
  AttendanceCount? count(String serviceId) => ctx.kol.attendance[serviceId];

  /// The service and its count, or the refusal.
  (Service, AttendanceCount)? _of(String serviceId) {
    final s = ctx.kol.service(serviceId);
    final c = ctx.kol.attendance[serviceId];
    return s == null || c == null ? null : (s, c);
  }

  /// The approver's grant for [c] on [s]. DL30: whoever approved the
  /// service; another holder of its approving posts (DL11) only once that
  /// person no longer holds one.
  Grant? _approver(Actor actor, Capability c, Service s) {
    final lingkup = ctx.approverScopeOf(s);
    final g = ctx.exactGrant(actor, c, lingkup);
    final oleh = s.approvedBy;
    if (g == null || oleh == null || oleh == actor.personId) return g;
    return ctx.exactGrants(oleh, c, lingkup).isEmpty ? g : null;
  }

  void _audit(
    Grant g,
    Service s,
    String action,
    String summary, {
    String? reason,
    String? before,
    String? after,
  }) => ctx.audit(
    g,
    action: action,
    summary: summary,
    module: Module.attendance,
    ref: RecordRef(_ref, s.id),
    reason: reason,
    before: before,
    after: after,
  );

  @override
  Future<Result<AttendanceCount>> assignCounter(
    Actor actor,
    String serviceId,
    String personId,
    String post, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Tugaskan penghitung';
    final x = _of(serviceId);
    if (x == null) return ctx.no(aksi, 'ibadah ini belum disetujui.');
    final (s, c) = x;
    final g = _approver(actor, Capability.attendanceAssignCounter, s);
    if (g == null) {
      return ctx.refuseExact(
        actor,
        Capability.attendanceAssignCounter,
        ctx.approverScopeOf(s),
      );
    }
    final basi = ctx.stale<AttendanceCount>(c.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (c.status == AttendanceStatus.finalized) {
      return ctx.no(aksi, 'jumlah kehadiran sudah Ditetapkan.');
    }
    if (post.trim().isEmpty) return ctx.no(aksi, 'pos belum diisi.');
    if (ctx.inti.person(personId) == null) {
      return ctx.no(aksi, 'petugas belum dipilih.');
    }
    final p = c.postOf(post.trim());
    if (p == null) {
      c.posts.add(CounterPost(post: post.trim(), personId: personId));
    } else {
      p.personId = personId;
    }
    c.revision += 1;
    _audit(
      g,
      s,
      'attendance.assign_counter',
      '${ctx.personName(personId)} ditugaskan menghitung ${post.trim()} · '
          '${s.title}',
    );
    if (personId != actor.personId) {
      ctx.notify(
        personId,
        title: 'Petugas penghitung kehadiran · ${s.title}',
        body: '${post.trim()} · ${s.date}',
        type: NotificationType.action,
        module: Module.attendance,
        ref: RecordRef(_ref, s.id),
      );
    }
    return Ok(c);
  });

  @override
  Future<Result<AttendanceCount>> increment(
    Actor actor,
    String serviceId,
    String post,
    int n, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    final aksi = n < 0 ? 'Kurangi satu' : 'Tambah satu';
    final x = _of(serviceId);
    if (x == null) return ctx.no(aksi, 'ibadah ini belum disetujui.');
    final (s, c) = x;
    if (!ctx.can.moduleActive(Module.attendance)) {
      return ctx.refuse(actor, Capability.attendanceCount, ScopeRef.jemaat);
    }
    final p = c.postOf(post);
    if (p == null || p.personId != actor.personId) {
      return ctx.no(
        aksi,
        'Anda bukan petugas penghitung $post untuk ibadah ini.',
      );
    }
    final basi = ctx.stale<AttendanceCount>(c.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    // Only attendance that happened is counted (LaporanLintas reports it).
    if (s.date > ctx.today) return ctx.no(aksi, 'ibadah belum berlangsung.');
    if (c.status != AttendanceStatus.live) {
      return ctx.no(aksi, 'jumlah kehadiran ${c.status.label}.');
    }
    final lama = p.count;
    p.count = p.count + n < 0 ? 0 : p.count + n;
    c.revision += 1;
    _audit(
      ctx.own(actor),
      s,
      'attendance.count',
      'Jumlah kehadiran ${p.post}: ${p.count} · ${s.title}',
      before: '$lama',
      after: '${p.count}',
    );
    return Ok(c);
  });

  @override
  Future<Result<AttendanceCount>> submitForReview(
    Actor actor,
    String serviceId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Tandai sudah diperiksa';
    final x = _of(serviceId);
    if (x == null) return ctx.no(aksi, 'ibadah ini belum disetujui.');
    final (s, c) = x;
    final g =
        _approver(actor, Capability.attendanceFinalize, s) ??
        (c.isCounter(actor.personId) && ctx.can.moduleActive(Module.attendance)
            ? ctx.own(actor)
            : null);
    if (g == null) {
      return ctx.refuseExact(
        actor,
        Capability.attendanceFinalize,
        ctx.approverScopeOf(s),
      );
    }
    final basi = ctx.stale<AttendanceCount>(c.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (c.status != AttendanceStatus.live) {
      return ctx.no(aksi, 'jumlah kehadiran ${c.status.label}.');
    }
    if (c.counted <= 0) return ctx.no(aksi, 'jumlah kehadiran masih nol.');
    c
      ..status = AttendanceStatus.review
      ..reviewedBy = actor.personId
      ..reviewedAt = ctx.now
      ..revision += 1;
    if (s.status == ServiceStatus.scheduled) {
      s
        ..status = ServiceStatus.done
        ..revision += 1;
    }
    _audit(
      g,
      s,
      'attendance.review',
      'Jumlah kehadiran ${c.counted} orang ditandai Sudah diperiksa · '
          '${s.title}',
    );
    if (s.approvedBy case final a? when a != actor.personId) {
      ctx.notify(
        a,
        title: 'Jumlah kehadiran ${s.title} menunggu Ditetapkan',
        body: '${c.counted} orang · dikirim ${ctx.personName(actor.personId)}',
        type: NotificationType.action,
        module: Module.attendance,
        ref: RecordRef(_ref, s.id),
      );
    }
    return Ok(c);
  });

  @override
  Future<Result<AttendanceCount>> returnToCounter(
    Actor actor,
    String serviceId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Kembalikan ke penghitung';
    final x = _of(serviceId);
    if (x == null) return ctx.no(aksi, 'ibadah ini belum disetujui.');
    final (s, c) = x;
    final g = _approver(actor, Capability.attendanceFinalize, s);
    if (g == null) {
      return ctx.refuseExact(
        actor,
        Capability.attendanceFinalize,
        ctx.approverScopeOf(s),
      );
    }
    final basi = ctx.stale<AttendanceCount>(c.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (c.status != AttendanceStatus.review) {
      return ctx.no(aksi, 'jumlah kehadiran ${c.status.label}.');
    }
    c
      ..status = AttendanceStatus.live
      ..reviewedBy = null
      ..reviewedAt = null
      ..revision += 1;
    if (s.status == ServiceStatus.done) {
      s
        ..status = ServiceStatus.scheduled
        ..revision += 1;
    }
    _audit(
      g,
      s,
      'attendance.return',
      'Jumlah kehadiran dikembalikan ke penghitung · ${s.title}',
      reason: reason.trim().isEmpty ? null : reason.trim(),
    );
    for (final p in c.posts) {
      if (p.personId == actor.personId) continue;
      ctx.notify(
        p.personId,
        title: 'Jumlah kehadiran ${s.title} dikembalikan',
        body: reason.trim().isEmpty ? p.post : 'Alasan: ${reason.trim()}',
        type: NotificationType.action,
        module: Module.attendance,
        ref: RecordRef(_ref, s.id),
      );
    }
    return Ok(c);
  });

  @override
  Future<Result<AttendanceCount>> finalize(
    Actor actor,
    String serviceId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Tetapkan';
    final x = _of(serviceId);
    if (x == null) return ctx.no(aksi, 'ibadah ini belum disetujui.');
    final (s, c) = x;
    final g = _approver(actor, Capability.attendanceFinalize, s);
    if (g == null) {
      // Kehadiran, "Petugas penghitung" (DP35).
      if (c.isCounter(actor.personId)) {
        return ctx.no(aksi, 'penghitung tidak menetapkan jumlah.');
      }
      return ctx.refuseExact(
        actor,
        Capability.attendanceFinalize,
        ctx.approverScopeOf(s),
      );
    }
    final basi = ctx.stale<AttendanceCount>(c.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (c.status == AttendanceStatus.finalized) {
      return ctx.no(aksi, 'jumlah kehadiran sudah Ditetapkan.');
    }
    if (c.counted <= 0) return ctx.no(aksi, 'jumlah kehadiran masih nol.');
    c
      ..status = AttendanceStatus.finalized
      ..reviewedBy ??= actor.personId
      ..reviewedAt ??= ctx.now
      ..finalizedBy = actor.personId
      ..finalizedAt = ctx.now
      ..revision += 1;
    s
      ..status = ServiceStatus.closed
      ..closedAt = ctx.now
      ..revision += 1;
    _audit(
      g,
      s,
      'attendance.finalize',
      'Jumlah kehadiran Ditetapkan: ${c.total} orang · ${s.title}',
    );
    return Ok(c);
  });

  @override
  Future<Result<AttendanceCount>> correct(
    Actor actor,
    String serviceId,
    int value, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Catat koreksi';
    final x = _of(serviceId);
    if (x == null) return ctx.no(aksi, 'ibadah ini belum disetujui.');
    final (s, c) = x;
    final g = _approver(actor, Capability.attendanceCorrect, s);
    if (g == null) {
      return ctx.refuseExact(
        actor,
        Capability.attendanceCorrect,
        ctx.approverScopeOf(s),
      );
    }
    final basi = ctx.stale<AttendanceCount>(c.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (c.status != AttendanceStatus.finalized) {
      return ctx.no(aksi, 'hanya jumlah yang sudah Ditetapkan yang dikoreksi.');
    }
    if (value <= 0) return ctx.no(aksi, 'jumlah yang benar belum diisi.');
    final alasan = reason.trim();
    if (alasan.isEmpty) return ctx.no(aksi, 'alasan belum diisi.');
    final lama = c.total;
    c.corrections.add(
      AttendanceCorrection(
        from: lama,
        to: value,
        reason: alasan,
        by: actor.personId,
        at: ctx.now,
      ),
    );
    c.revision += 1;
    _audit(
      g,
      s,
      'attendance.correct',
      'Koreksi jumlah kehadiran: $lama menjadi $value orang · ${s.title}',
      reason: alasan,
      before: '$lama',
      after: '$value',
    );
    return Ok(c);
  });
}
