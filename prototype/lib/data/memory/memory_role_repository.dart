import 'dart:async';

import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../repositories/role_repository.dart';
import 'memory_context.dart';

/// Posts, terms, cover, delegation and authority grants. Owns the timer that
/// stands for the Petugas verifikasi (README 3.7); [dispose] cancels it.
class MemoryRoleRepository implements RoleRepository {
  MemoryRoleRepository(this.ctx);
  final MemoryContext ctx;
  final _timers = <Timer>[];

  /// The system actor that verifies authority (mock-data 2.2).
  static const petugasId = 'petugas';

  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }

  // ---------- Queries ----------

  bool _authorized(Assignment a) => ctx.inti.authorityGrants.any(
    (g) => g.assignmentId == a.id && g.status == GrantStatus.active,
  );

  /// The holder in force at [at]: for the Bendahara and Sekretaris only with
  /// an active authority grant.
  Assignment? _holder(Post p, Tanggal at) => ctx.inti.assignments
      .where(
        (a) =>
            a.postId == p.id &&
            a.inForce(at) &&
            (!p.role.needsAuthority || _authorized(a)),
      )
      .firstOrNull;

  VacancyCover? _cover(String postId, Tanggal at) => ctx.inti.covers
      .where((c) => c.postId == postId && c.inForce(at))
      .firstOrNull;

  @override
  List<PostView> posts({String? scopeId}) {
    final t = ctx.today;
    return [
      for (final p in ctx.inti.posts)
        if (scopeId == null || p.scopeId == scopeId) _view(p, t),
    ];
  }

  PostView _view(Post p, Tanggal t) {
    final milik = ctx.inti.assignments.where((a) => a.postId == p.id);
    final tunggu = milik
        .where((a) => a.status == AssignmentStatus.pending)
        .lastOrNull;
    final lalu = milik.where((a) => a.endedBy(t)).toList()
      ..sort((a, b) => (b.end ?? b.start).compareTo(a.end ?? a.start));
    return PostView(
      post: p,
      holder: _holder(p, t),
      pending: tunggu,
      pendingGrant: tunggu == null
          ? null
          : ctx.inti.authorityGrants
                .where(
                  (g) =>
                      g.assignmentId == tunggu.id &&
                      g.status == GrantStatus.pending,
                )
                .firstOrNull,
      cover: _cover(p.id, t),
      handover: ctx.inti.handovers
          .where((h) => h.postId == p.id && h.status == HandoverStatus.proposed)
          .lastOrNull,
      lastHolder: lalu.firstOrNull,
    );
  }

  @override
  List<Assignment> assignmentsOf(String personId) => [
    for (final a in ctx.inti.assignments)
      if (a.personId == personId) a,
  ];

  @override
  List<Delegation> delegations({String? personId}) => [
    for (final d in ctx.inti.delegations)
      if (personId == null ||
          d.fromPersonId == personId ||
          d.toPersonId == personId)
        d,
  ];

  @override
  List<AuthorityGrant> grants({String? personId}) => [
    for (final g in ctx.inti.authorityGrants)
      if (personId == null || g.personId == personId) g,
  ];

  // ---------- Helpers ----------

  /// Ends a term so that it is out of force from [from] on: now, when [from]
  /// is today or earlier; otherwise on the day before [from].
  void _endTerm(Term x, Tanggal from) {
    final t = ctx.today;
    if (from <= t) {
      switch (x) {
        case Assignment a:
          a
            ..end = t
            ..endedAt = ctx.now
            ..status = AssignmentStatus.ended
            ..revision += 1;
        case VacancyCover c:
          c
            ..end = t
            ..endedAt = ctx.now
            ..revision += 1;
      }
    } else {
      switch (x) {
        case Assignment a:
          a
            ..end = from.tambahHari(-1)
            ..revision += 1;
        case VacancyCover c:
          c
            ..end = from.tambahHari(-1)
            ..revision += 1;
      }
    }
  }

  void _revokeGrantsOf(String assignmentId, String by, String reason) {
    for (final g in ctx.inti.authorityGrants) {
      if (g.assignmentId == assignmentId && g.status != GrantStatus.revoked) {
        g
          ..status = GrantStatus.revoked
          ..revokedBy = by
          ..revokedAt = ctx.now
          ..reason = reason
          ..revision += 1;
      }
    }
  }

  /// [baru] takes the post from [baru.start]: the previous holder's term and
  /// any cover end, and sessions acting in the old assignment end.
  void _takeOver(Post post, Assignment baru, {required String by}) {
    final t = ctx.today;
    final lama = _holder(post, t);
    if (lama != null && lama.id != baru.id) {
      _endTerm(lama, baru.start);
      lama.endReason = 'Digantikan ${ctx.personName(baru.personId)}';
      if (!lama.inForce(t)) {
        _revokeGrantsOf(lama.id, by, lama.endReason!);
        ctx.endSessionsActingIn(lama.id);
      }
      ctx.notify(
        lama.personId,
        title: 'Masa jabatan ${post.title} berakhir',
        body: 'Digantikan ${ctx.personName(baru.personId)}',
        ref: RecordRef('assignment', lama.id),
      );
    }
    final c = _cover(post.id, t);
    if (c != null) {
      _endTerm(c, baru.start);
      ctx.notify(
        c.personId,
        title: 'Jabatan ${post.title} sudah terisi',
        body:
            '${ctx.personName(baru.personId)} memegang jabatan ini; Anda '
            'tidak lagi menjalankannya.',
        ref: RecordRef('post', post.id),
      );
    }
    for (final h in ctx.inti.handovers) {
      if (h.postId == post.id &&
          h.toPersonId == baru.personId &&
          h.status == HandoverStatus.proposed) {
        h
          ..status = HandoverStatus.recorded
          ..assignmentId = baru.id
          ..revision += 1;
      }
    }
    post.revision += 1;
  }

  /// The Petugas verifikasi activates a pending grant (the board timer).
  void _activate(String grantId) {
    final g = ctx.inti.authorityGrants
        .where((g) => g.id == grantId && g.status == GrantStatus.pending)
        .firstOrNull;
    final a = g == null ? null : ctx.inti.assignment(g.assignmentId);
    final post = a == null ? null : ctx.inti.post(a.postId);
    if (g == null || a == null || post == null) return;
    g
      ..status = GrantStatus.active
      ..verifiedBy = petugasId
      ..verifiedAt = ctx.now
      ..revision += 1;
    a
      ..status = AssignmentStatus.active
      ..revision += 1;
    _takeOver(post, a, by: petugasId);
    ctx.auditSystem(
      petugasId,
      Role.petugasVerifikasi.label,
      action: 'role.grant_activate',
      summary:
          'Mengaktifkan wewenang ${g.role.label} untuk '
          '${ctx.personName(a.personId)}',
      ref: RecordRef('assignment', a.id),
    );
    ctx.notify(
      a.personId,
      title: 'Wewenang ${post.title} aktif',
      body: 'Diverifikasi Petugas verifikasi',
      ref: RecordRef('assignment', a.id),
    );
    ctx.changed();
  }

  // ---------- Commands ----------

  @override
  Future<Result<HandoverProposal>> proposeHandover(
    Actor actor,
    String postId,
    String toPersonId,
    String documentRef, {
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Serah terima';
    final post = ctx.inti.post(postId);
    if (post == null) return ctx.no(aksi, 'Jabatan tidak ditemukan.');
    final pegang = _holder(post, ctx.today);
    if (pegang == null || pegang.personId != actor.personId) {
      return ctx.no(
        aksi,
        'Hanya pemegang jabatan ini yang dapat menyiapkan serah terima.',
      );
    }
    final ke = ctx.inti.person(toPersonId);
    if (ke == null || ke.isSystem) {
      return ctx.no(aksi, 'Penerus belum dipilih.');
    }
    if (toPersonId == actor.personId) {
      return ctx.no(aksi, 'Penerus harus orang lain.');
    }
    if (documentRef.trim().isEmpty) {
      return ctx.no(aksi, 'Dokumen gereja belum dilampirkan.');
    }
    final h = HandoverProposal(
      id: ctx.store.newId('serah'),
      postId: postId,
      fromPersonId: actor.personId,
      toPersonId: toPersonId,
      documentRef: documentRef.trim(),
      createdAt: ctx.now,
    );
    ctx.inti.handovers.add(h);
    final g = ctx.own(
      Actor(
        personId: actor.personId,
        assignmentId: pegang.id,
        scopeId: post.scopeId,
      ),
    );
    ctx.audit(
      g,
      action: 'role.handover',
      summary: 'Menyiapkan serah terima ${post.title} kepada ${ke.name}',
      module: post.role == Role.bendaharaJemaat ? Module.finance : null,
      ref: RecordRef('handover', h.id),
    );
    for (final p in ctx.can.whoCan(
      Capability.assignPost,
      ScopeRef(post.scopeId),
      at: ctx.today,
    )) {
      ctx.notify(
        p.id,
        title: 'Serah terima ${post.title} menunggu dicatat',
        body: 'Dari ${ctx.personName(actor.personId)} kepada ${ke.name}',
        type: NotificationType.action,
        ref: RecordRef('handover', h.id),
      );
    }
    return Ok(h);
  });

  @override
  Future<Result<Assignment>> assign(
    Actor actor,
    String postId,
    String personId,
    Tanggal start, {
    String? documentRef,
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Catat penugasan';
    final post = ctx.inti.post(postId);
    if (post == null) return ctx.no(aksi, 'Jabatan tidak ditemukan.');
    final lingkup = ScopeRef(post.scopeId);
    final g = ctx.grant(actor, Capability.assignPost, lingkup);
    if (g == null) return ctx.refuse(actor, Capability.assignPost, lingkup);
    if (personId == actor.personId) {
      return ctx.no(
        aksi,
        'Anda tidak dapat menugaskan jabatan kepada diri sendiri.',
      );
    }
    final basi = ctx.stale<Assignment>(post.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    final orang = ctx.inti.person(personId);
    if (orang == null || orang.isSystem) {
      return ctx.no(aksi, 'Orang belum dipilih.');
    }
    if (_holder(post, ctx.today)?.personId == personId) {
      return ctx.no(aksi, '${orang.name} sudah memegang jabatan ini.');
    }
    final tunggu = ctx.inti.assignments.any(
      (a) => a.postId == postId && a.status == AssignmentStatus.pending,
    );
    if (tunggu) {
      return ctx.no(
        aksi,
        'Penugasan sebelumnya masih menunggu verifikasi wewenang.',
      );
    }
    final butuh = post.role.needsAuthority;
    final a = Assignment(
      id: ctx.store.newId('tugas'),
      postId: postId,
      personId: personId,
      start: start,
      status: butuh ? AssignmentStatus.pending : AssignmentStatus.active,
      documentRef: documentRef,
      recordedBy: actor.personId,
      recordedAt: ctx.now,
    );
    ctx.inti.assignments.add(a);
    if (butuh) {
      final w = AuthorityGrant(
        id: ctx.store.newId('wewenang'),
        personId: personId,
        assignmentId: a.id,
        role: post.role,
        documentRef: documentRef,
        recordedBy: actor.personId,
        recordedAt: ctx.now,
      );
      ctx.inti.authorityGrants.add(w);
      post.revision += 1;
      _timers.add(Timer(waktuVerifikasiWewenang, () => _activate(w.id)));
      ctx.notify(
        personId,
        title: 'Penugasan ${post.title} dicatat',
        body: 'Menunggu verifikasi wewenang',
        ref: RecordRef('assignment', a.id),
      );
    } else {
      _takeOver(post, a, by: actor.personId);
      ctx.notify(
        personId,
        title: 'Anda ditugaskan sebagai ${post.title}',
        body: 'Dicatat oleh ${ctx.personName(actor.personId)}',
        ref: RecordRef('assignment', a.id),
      );
    }
    ctx.audit(
      g,
      action: 'role.assign',
      summary:
          'Menugaskan ${orang.name} sebagai ${post.title}'
          '${butuh ? ' · menunggu verifikasi wewenang' : ''}',
      ref: RecordRef('assignment', a.id),
    );
    return Ok(a);
  });

  @override
  Future<Result<Assignment>> endTerm(
    Actor actor,
    String assignmentId,
    Tanggal end, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Catat berakhir';
    final a = ctx.inti.assignment(assignmentId);
    final post = a == null ? null : ctx.inti.post(a.postId);
    if (a == null || post == null) {
      return ctx.no(aksi, 'Penugasan tidak ditemukan.');
    }
    final lingkup = ScopeRef(post.scopeId);
    final g = ctx.grant(actor, Capability.assignPost, lingkup);
    if (g == null) return ctx.refuse(actor, Capability.assignPost, lingkup);
    final basi = ctx.stale<Assignment>(a.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (a.status == AssignmentStatus.ended) {
      return ctx.no(aksi, 'Masa jabatan ini sudah berakhir.');
    }
    if (reason.trim().isEmpty) return ctx.no(aksi, 'Alasan belum diisi.');
    if (end < a.start) {
      return ctx.no(aksi, 'Tanggal berakhir sebelum tanggal mulai.');
    }
    final t = ctx.today;
    if (end <= t) {
      a
        ..end = end
        ..endedAt = ctx.now
        ..status = AssignmentStatus.ended;
      _revokeGrantsOf(a.id, actor.personId, reason.trim());
      ctx.endSessionsActingIn(a.id);
    } else {
      a.end = end;
    }
    a
      ..endReason = reason.trim()
      ..revision += 1;
    post.revision += 1;
    ctx.audit(
      g,
      action: 'role.end_term',
      summary:
          'Mengakhiri masa jabatan ${ctx.personName(a.personId)} sebagai '
          '${post.title}',
      reason: reason.trim(),
      ref: RecordRef('assignment', a.id),
    );
    ctx.notify(
      a.personId,
      title: 'Masa jabatan ${post.title} berakhir',
      body: reason.trim(),
      ref: RecordRef('assignment', a.id),
    );
    if (_holder(post, t) == null && _cover(post.id, t) == null) {
      for (final p in ctx.can.whoCan(
        Capability.coverVacancy,
        ScopeRef.jemaat,
        at: t,
      )) {
        ctx.notify(
          p.id,
          title: 'Jabatan ${post.title} kosong',
          body: 'Operator dapat menjalankan jabatan kosong',
          type: NotificationType.action,
          ref: RecordRef('post', post.id),
        );
      }
    }
    return Ok(a);
  });

  @override
  Future<Result<VacancyCover>> coverVacancy(
    Actor actor,
    String postId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    final aksi = Capability.coverVacancy.label;
    final g = ctx.grant(actor, Capability.coverVacancy, ScopeRef.jemaat);
    if (g == null) {
      return ctx.refuse(actor, Capability.coverVacancy, ScopeRef.jemaat);
    }
    final post = ctx.inti.post(postId);
    if (post == null) return ctx.no(aksi, 'Jabatan tidak ditemukan.');
    final basi = ctx.stale<VacancyCover>(post.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    final t = ctx.today;
    if (_holder(post, t) != null) {
      return ctx.no(aksi, '${post.title} tidak kosong.');
    }
    final ada = _cover(postId, t);
    if (ada != null) {
      return ctx.no(
        aksi,
        'Jabatan ini sudah dijalankan ${ctx.personName(ada.personId)}.',
      );
    }
    if (reason.trim().isEmpty) return ctx.no(aksi, 'Alasan belum diisi.');
    final c = VacancyCover(
      id: ctx.store.newId('cover'),
      postId: postId,
      personId: actor.personId,
      operatorAssignmentId: g.assignmentId,
      start: t,
      startedAt: ctx.now,
      reason: reason.trim(),
    );
    ctx.inti.covers.add(c);
    post.revision += 1;
    ctx.audit(
      g,
      action: 'role.cover',
      summary: 'Menjalankan jabatan kosong ${post.title}',
      module: post.role == Role.bendaharaJemaat ? Module.finance : null,
      reason: c.reason,
      ref: RecordRef('post', post.id),
    );
    for (final p in ctx.can.whoCan(
      Capability.assignPost,
      ScopeRef(post.scopeId),
      at: t,
    )) {
      ctx.notify(
        p.id,
        title: 'Jabatan kosong ${post.title} dijalankan Operator',
        body: '${ctx.personName(actor.personId)}, Operator',
        ref: RecordRef('post', post.id),
      );
    }
    return Ok(c);
  });

  @override
  Future<Result<Delegation>> delegate(
    Actor actor,
    DelegatedTask task,
    String toPersonId,
    Tanggal start,
    Tanggal end, {
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    final aksi = Capability.delegate.label;
    final g = ctx.grant(actor, Capability.delegate, ScopeRef.anywhere);
    if (g == null) {
      return ctx.refuse(actor, Capability.delegate, ScopeRef.anywhere);
    }
    final lingkup = ScopeRef(task.scopeId);
    // Only what one holds through one's own post can be delegated.
    final sumber = ctx.can
        .grantsFor(actor.personId, task.capability, lingkup, at: ctx.today)
        .where((x) => x.kind == GrantKind.assignment)
        .firstOrNull;
    if (sumber == null) {
      return ctx.no(aksi, 'Tugas ini bukan wewenang jabatan Anda.');
    }
    if (toPersonId == actor.personId) {
      return ctx.no(
        aksi,
        'Anda tidak dapat melimpahkan tugas kepada diri sendiri.',
      );
    }
    final ke = ctx.inti.person(toPersonId);
    if (ke == null || ke.isSystem) {
      return ctx.no(aksi, 'Penerima belum dipilih.');
    }
    if (end < start) {
      return ctx.no(aksi, 'Tanggal berakhir sebelum tanggal mulai.');
    }
    final d = Delegation(
      id: ctx.store.newId('pelimpahan'),
      fromPersonId: actor.personId,
      fromAssignmentId: sumber.assignmentId,
      toPersonId: toPersonId,
      task: task,
      start: start,
      end: end,
      createdAt: ctx.now,
    );
    ctx.inti.delegations.add(d);
    ctx.audit(
      sumber,
      action: 'role.delegate',
      summary: 'Melimpahkan "${task.label}" kepada ${ke.name}',
      ref: RecordRef('delegation', d.id),
    );
    ctx.notify(
      toPersonId,
      title: 'Pelimpahan baru: ${task.label}',
      body: 'Dari ${ctx.personName(actor.personId)}, ${sumber.title}',
      ref: RecordRef('delegation', d.id),
    );
    return Ok(d);
  });

  @override
  Future<Result<AuthorityGrant>> revokeGrant(
    Actor actor,
    String grantId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Cabut wewenang';
    final g =
        ctx.grant(actor, Capability.verifyAuthority, ScopeRef.jemaat) ??
        ctx.grant(actor, Capability.assignPost, ScopeRef.jemaat);
    if (g == null) {
      return ctx.refuse(actor, Capability.assignPost, ScopeRef.jemaat);
    }
    final w = ctx.inti.authorityGrants
        .where((x) => x.id == grantId)
        .firstOrNull;
    if (w == null) return ctx.no(aksi, 'Wewenang tidak ditemukan.');
    final basi = ctx.stale<AuthorityGrant>(w.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (w.status == GrantStatus.revoked) {
      return ctx.no(aksi, 'Wewenang ini sudah dicabut.');
    }
    if (reason.trim().isEmpty) return ctx.no(aksi, 'Alasan belum diisi.');
    _revokeGrantsOf(w.assignmentId, actor.personId, reason.trim());
    ctx.endSessionsActingIn(w.assignmentId);
    final a = ctx.inti.assignment(w.assignmentId);
    if (a != null) ctx.inti.post(a.postId)?.revision += 1;
    ctx.audit(
      g,
      action: 'role.revoke',
      summary:
          'Mencabut wewenang ${w.role.label} ${ctx.personName(w.personId)}'
          ' · semua sesi diakhiri',
      reason: reason.trim(),
      ref: RecordRef('assignment', w.assignmentId),
    );
    ctx.notify(
      w.personId,
      title: 'Wewenang ${w.role.label} dicabut',
      body: reason.trim(),
      ref: RecordRef('assignment', w.assignmentId),
    );
    return Ok(w);
  });
}
