import '../../core/clock.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../seed/seed_store.dart';
import '../seed/tabel_inti.dart';

/// What every in-memory repository shares (README 3.4): the store, the clock,
/// the revision bump, the idempotency log, the gate, audit and notifications.
/// Later milestones build their repositories on it too.
class MemoryContext {
  MemoryContext(this.store, this.clock, this.changed);

  final SeedStore store;
  final Clock clock;

  /// Bumps `revisionProvider`; called after every successful command and
  /// every repository timer that changes state.
  final void Function() changed;

  TabelInti get inti => store.inti;
  DateTime get now => clock.now();
  Tanggal get today => Tanggal.dari(now);
  Can get can => Can(store.inti);

  /// Runs [body] once per [idempotencyKey]: a repeated key returns the first
  /// result and changes nothing (README 3.4, B45–B50). A successful result
  /// bumps the revision.
  Future<Result<T>> command<T>(
    String idempotencyKey,
    Result<T> Function() body,
  ) async {
    final lama = store.idempotencyLog[idempotencyKey];
    if (lama != null) return lama as Result<T>;
    final r = body();
    store.idempotencyLog[idempotencyKey] = r;
    if (r is Ok<T>) changed();
    return r;
  }

  /// The grant [actor] uses for [c] in [scope] today (or at [at]), or null.
  Grant? grant(Actor actor, Capability c, ScopeRef scope, {Tanggal? at}) =>
      can.grantFor(actor, c, scope, at: at ?? today);

  /// The gate's refusal for [c].
  Refused<T> refuse<T>(
    Actor actor,
    Capability c,
    ScopeRef scope, {
    Tanggal? at,
  }) => Refused<T>(
    can.whyNot(actor, c, scope, at: at ?? today) ??
        Refusal(action: c.label, because: 'Tidak berwenang.'),
  );

  /// A refusal with the board's copy.
  Refused<T> no<T>(String action, String because, {String? whoCanAct}) =>
      Refused<T>(
        Refusal(action: action, because: because, whoCanAct: whoCanAct),
      );

  /// The Draf board's "Sudah diubah sejak Anda membukanya" when [actual] is
  /// not [expected]; null when they match.
  Refused<T>? stale<T>(int actual, int expected, String action) =>
      actual == expected
      ? null
      : no<T>(action, 'Sudah diubah sejak Anda membukanya.');

  /// The actor's own acting grant, for audit lines of commands that need no
  /// capability (their own account, inbox and devices).
  Grant own(Actor actor) {
    final g = can.grantsOf(actor.personId, at: today);
    return g.where((x) => x.toActor() == actor).firstOrNull ??
        g.firstOrNull ??
        Grant(
          kind: GrantKind.member,
          personId: actor.personId,
          scopeId: actor.scopeId,
          title: 'Anggota jemaat',
          capabilities: const {},
        );
  }

  String personName(String id) => inti.person(id)?.name ?? id;

  /// The post title the actor acts in, for the audit line: the Operator's
  /// own post for a cover, the person's first post for a delegation.
  String _actingRole(Grant g) {
    switch (g.kind) {
      case GrantKind.assignment:
        return g.title;
      case GrantKind.member:
        return 'Anggota jemaat';
      case GrantKind.cover:
        final a = inti.assignment(g.assignmentId ?? '');
        return inti.post(a?.postId ?? '')?.title ?? 'Operator';
      case GrantKind.delegation:
        final own = can
            .grantsOf(g.personId, at: today)
            .where((x) => x.kind == GrantKind.assignment)
            .firstOrNull;
        return own?.title ?? 'Anggota jemaat';
    }
  }

  /// Appends the audit line of a command done through [g] (README 3.4).
  void audit(
    Grant g, {
    required String action,
    required String summary,
    Module? module,
    RecordRef? ref,
    String? before,
    String? after,
    String? reason,
  }) => inti.audit.add(
    AuditRecord(
      id: store.newId('aud'),
      at: now,
      personId: g.personId,
      personName: personName(g.personId),
      actingRole: _actingRole(g),
      assignmentId: g.assignmentId,
      scopeId: g.scopeId,
      via: g.via,
      viaLabel: g.viaLabel,
      module: module,
      action: action,
      summary: summary,
      before: before,
      after: after,
      reason: reason,
      ref: ref,
    ),
  );

  /// Appends an audit line for a system actor (the Petugas verifikasi).
  void auditSystem(
    String personId,
    String role, {
    required String action,
    required String summary,
    RecordRef? ref,
    String? reason,
  }) => inti.audit.add(
    AuditRecord(
      id: store.newId('aud'),
      at: now,
      personId: personId,
      personName: personName(personId),
      actingRole: role,
      scopeId: ScopeRef.jemaatId,
      action: action,
      summary: summary,
      reason: reason,
      ref: ref,
    ),
  );

  /// Writes a notification row for [recipientId] (README 3.4).
  void notify(
    String recipientId, {
    required String title,
    required String body,
    String type = NotificationType.role,
    Module? module,
    RecordRef? ref,
  }) => inti.notifications.add(
    AppNotification(
      id: store.newId('kabar'),
      recipientId: recipientId,
      type: type,
      module: module,
      title: title,
      body: body,
      createdAt: now,
      ref: ref,
    ),
  );

  /// Ends every open session acting in [assignmentId] (README 3.6): the
  /// router then shows `/sesi-berakhir`.
  void endSessionsActingIn(String assignmentId) {
    for (final s in inti.sessions) {
      if (!s.ended && s.acting?.assignmentId == assignmentId) {
        s
          ..endedAt = now
          ..endReason = SessionEnd.authorityEnded
          ..revision += 1;
      }
    }
  }
}
