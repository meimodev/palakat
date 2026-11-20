import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';
import '../repositories/consent_repository.dart';
import 'memory_jemaat.dart';

class MemoryConsentRepository implements ConsentRepository {
  MemoryConsentRepository(this.j);
  final MemoryJemaat j;

  @override
  List<Consent> consents(String personId) => [
    for (final c in j.t.consents)
      if (c.personId == personId) c,
  ];

  @override
  ({String version, Tanggal? date}) text() =>
      (version: consentVersion, date: j.t.consentTextDate);

  @override
  List<DeletionRequest> deletionRequests() =>
      List.unmodifiable(j.t.deletions.reversed);

  /// The member themself, or an officer recording a paper request in the
  /// person's Kolom.
  Grant? _grant(Actor actor, String personId) => actor.personId == personId
      ? j.submitGrant(actor)
      : j.ctx.grant(
          actor,
          Capability.membershipRecordPaper,
          ScopeRef(j.kolomOf(personId) ?? ScopeRef.jemaatId),
        );

  @override
  Future<Result<Consent>> record(
    Actor actor,
    String personId,
    ConsentChannel channel, {
    required String idempotencyKey,
  }) => j.ctx.command(idempotencyKey, () {
    final g = _grant(actor, personId);
    if (g == null) {
      return j.ctx.refuse(actor, Capability.membershipSubmit, ScopeRef.jemaat);
    }
    final c = Consent(
      id: j.ctx.store.newId('izin'),
      personId: personId,
      version: consentVersion,
      at: j.ctx.now,
      channel: channel,
      givenBy: actor.personId,
    );
    j.t.consents.add(c);
    j.ctx.audit(
      g,
      action: 'membership.consent.record',
      summary: 'Izin penggunaan data pribadi ${j.name(personId)}',
      module: Module.membership,
      ref: RecordRef('person', personId),
    );
    return Ok(c);
  });

  @override
  Future<Result<void>> withdraw(
    Actor actor,
    String personId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => j.ctx.command(idempotencyKey, () {
    const aksi = 'Cabut izin';
    final g = _grant(actor, personId);
    if (g == null) {
      return j.ctx.refuse(actor, Capability.membershipSubmit, ScopeRef.jemaat);
    }
    final c = consents(personId).where((c) => c.inForce).lastOrNull;
    if (c == null) return j.ctx.no(aksi, 'tidak ada izin yang berlaku.');
    final basi = j.ctx.stale<void>(c.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    c
      ..withdrawnAt = j.ctx.now
      ..revision += 1;
    j.ctx.audit(
      g,
      action: 'membership.consent.withdraw',
      summary: 'Izin penggunaan data pribadi dicabut',
      module: Module.membership,
      ref: RecordRef('person', personId),
      reason: reason,
    );
    return const Ok(null);
  });

  @override
  Future<Result<DeletionRequest>> requestDeletion(
    Actor actor,
    String personId, {
    required String reason,
    required String idempotencyKey,
  }) => j.ctx.command(idempotencyKey, () {
    const aksi = 'Cabut izin dan hapus data saya';
    final g = _grant(actor, personId);
    if (g == null) {
      return j.ctx.refuse(actor, Capability.membershipSubmit, ScopeRef.jemaat);
    }
    if (j.ctx.inti.person(personId)?.status == PersonStatus.deceased) {
      return j.ctx.no(aksi, 'anggota yang meninggal dunia tidak dihapus.');
    }
    final sendiri = actor.personId == personId;
    final r = DeletionRequest(
      id: j.ctx.store.newId('hapus'),
      personId: personId,
      channel: sendiri ? ConsentChannel.app : ConsentChannel.paper,
      recordedBy: actor.personId,
      at: j.ctx.now,
      reason: reason,
    );
    j.t.deletions.add(r);
    j.ctx.audit(
      g,
      action: 'membership.deletion.request',
      summary: 'Permintaan hapus data dicatat',
      module: Module.membership,
      ref: RecordRef('deletion', r.id),
      reason: reason,
    );
    if (!sendiri) {
      // A paper request is confirmed by the Penatua Kolom first (DL13).
      for (final p in j.ctx.can.whoCan(
        Capability.membershipDelete,
        ScopeRef(j.kolomOf(personId) ?? ScopeRef.jemaatId),
        at: j.today,
      )) {
        j.ctx.notify(
          p.id,
          title: 'Permintaan hapus · ${j.name(personId)}',
          body: 'Dicatat ${j.name(actor.personId)}',
          type: NotificationType.action,
          module: Module.membership,
          ref: RecordRef('deletion', r.id),
        );
      }
    }
    return Ok(r);
  });

  @override
  Future<Result<DeletionRequest>> executeDeletion(
    Actor actor,
    String requestId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => j.ctx.command(idempotencyKey, () {
    const aksi = 'Hapus data';
    final r = j.t.deletions.where((d) => d.id == requestId).firstOrNull;
    if (r == null || r.done) return j.ctx.no(aksi, 'Permintaan tidak ada.');
    final id = r.personId!;
    // Own request: acted on directly; a paper one: the Penatua Kolom.
    final g = r.channel == ConsentChannel.app && actor.personId == id
        ? j.submitGrant(actor)
        : j.ctx.grant(
            actor,
            Capability.membershipDelete,
            ScopeRef(j.kolomOf(id) ?? ScopeRef.jemaatId),
          );
    if (g == null) {
      return j.ctx.refuse(
        actor,
        Capability.membershipDelete,
        ScopeRef(j.kolomOf(id) ?? ScopeRef.jemaatId),
      );
    }
    final basi = j.ctx.stale<DeletionRequest>(
      r.revision,
      expectedRevision,
      aksi,
    );
    if (basi != null) return basi;
    _hapus(id, g);
    r
      ..personId = null
      ..executedBy = actor.personId
      ..executedAt = j.ctx.now
      ..revision += 1;
    j.ctx.audit(
      g,
      action: 'membership.deletion.execute',
      summary: 'Data anggota dihapus atas permintaannya',
      module: Module.membership,
      ref: RecordRef('deletion', r.id),
    );
    return Ok(r);
  });

  /// DL13's delete list; the keep list (finance names, published Warta and
  /// documents, audit lines, this record) is left as it is.
  void _hapus(String id, Grant g) {
    final t = j.t;
    final inti = j.ctx.inti;
    final h = t.householdOf(id);
    if (h != null) {
      h.memberIds.remove(id);
      if (h.representativeId == id) h.representativeId = null;
    }
    t.profiles.remove(id);
    t.masking.remove(id);
    t.consents.removeWhere((c) => c.personId == id);
    t.items.removeWhere(
      (i) =>
          i.subjectPersonId == id || (i.event?.personIds.contains(id) ?? false),
    );
    // Finance keeps the name as recorded; the link to the person goes.
    for (final p in inti.parties) {
      if (p.personId == id) {
        p
          ..personId = null
          ..revision += 1;
      }
    }
    // Posts the member held become vacant (DL12), as RoleRepository.endTerm
    // ends a term: authority, sessions acting in it and delegations made
    // from it end; the Operators are told the post is vacant.
    const sebab = 'Data anggota dihapus atas permintaannya';
    final hari = j.today;
    for (final a in inti.assignments.where((a) => a.personId == id).toList()) {
      if (!a.inForce(hari)) continue;
      a
        ..end = hari
        ..endedAt = j.ctx.now
        ..status = AssignmentStatus.ended
        ..endReason = sebab
        ..revision += 1;
      j.ctx
        ..revokeGrantsOf(a.id, g.personId, sebab)
        ..endSessionsActingIn(a.id)
        ..endDelegationsFrom(a.id);
      final post = inti.post(a.postId);
      if (post == null) continue;
      post.revision += 1;
      j.ctx.audit(
        g,
        action: 'role.end_term',
        summary:
            'Mengakhiri masa jabatan ${j.ctx.personName(id)} sebagai '
            '${post.title}',
        reason: sebab,
        ref: RecordRef('assignment', a.id),
      );
      final terisi =
          inti.assignments.any((x) => x.postId == post.id && x.inForce(hari)) ||
          inti.covers.any((c) => c.postId == post.id && c.inForce(hari));
      if (terisi) continue;
      for (final p in j.ctx.can.whoCan(
        Capability.coverVacancy,
        ScopeRef.jemaat,
        at: hari,
      )) {
        j.ctx.notify(
          p.id,
          title: 'Jabatan ${post.title} kosong',
          body: 'Operator dapat menjalankan jabatan kosong',
          type: NotificationType.action,
          ref: RecordRef('post', post.id),
        );
      }
    }
    inti.person(id)
      ?..birthDate = null
      ..phone = null
      ..backupEmail = null
      ..revision += 1;
  }
}
