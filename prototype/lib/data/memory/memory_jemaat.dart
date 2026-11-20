import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';
import '../seed/tabel_jemaat.dart';
import 'memory_context.dart';

/// What the in-memory membership repositories share (README 4.4): the core
/// context, the membership tables, the routing of verification items and the
/// no-self-verification rule (PMP 6.1).
class MemoryJemaat {
  MemoryJemaat(this.ctx);
  final MemoryContext ctx;

  TabelJemaat get t => ctx.store.jemaat;
  Tanggal get today => ctx.today;

  String name(String personId) => ctx.personName(personId);
  String? family(String householdId) => t.households[householdId]?.name;

  String title(VerificationItem i) => itemTitle(i, name, family);

  /// The Kolom of [personId] today, or null without a profile.
  String? kolomOf(String personId) => t.profiles[personId]?.kolomAt(today);

  /// A household's Kolom today: its members' Kolom, else the recorded one.
  String householdKolom(Household h) {
    for (final m in [?h.representativeId, ...h.memberIds]) {
      final k = kolomOf(m);
      if (k != null) return k;
    }
    return h.kolomId;
  }

  String scopeName(String id) => ctx.inti.scope(id)?.name ?? id;

  /// Everyone whose family [i] is about: its household, the households of
  /// its people, the subject.
  Set<String> familyOf(VerificationItem i) {
    final ids = <String>{?i.subjectPersonId, ...?i.event?.personIds};
    final keluarga = <String>{
      ?i.householdId,
      for (final p in ids) ?t.profiles[p]?.householdId,
    };
    return {...ids, for (final k in keluarga) ...?t.households[k]?.memberIds};
  }

  /// Whether [personId] would verify their own data: they submitted or
  /// entered it, or it is their family's.
  bool selfFor(String personId, VerificationItem i) =>
      i.submittedBy == personId || familyOf(i).contains(personId);

  /// The Kolom whose verification [i] needs: a Kolom move needs its Kolom
  /// of origin and of destination (Peristiwa k5).
  List<String> scopesOf(VerificationItem i) {
    final e = i.event;
    if (e?.kind == LifeEventKind.kolomMove &&
        e!.fromKolomId != null &&
        e.toKolomId != null &&
        e.fromKolomId != e.toKolomId) {
      return [e.fromKolomId!, e.toKolomId!];
    }
    return [i.scopeId];
  }

  /// The Kolom of [i] still to verify.
  List<String> pendingScopes(VerificationItem i) => [
    for (final s in scopesOf(i))
      if (!i.verifiedScopes.contains(s)) s,
  ];

  /// A Syamas or Operator post verifies only what nobody else may (PMP 6.1),
  /// so its grant does not make its holder a first-line verifier.
  bool _fallback(Grant g) =>
      g.kind == GrantKind.assignment &&
      const {
        Role.syamasKolom,
        Role.operator,
      }.contains(ctx.inti.post(g.postId ?? '')?.role);

  List<Grant> _verifyGrants(String personId, String scopeId) =>
      ctx.can.grantsFor(
        personId,
        Capability.membershipVerify,
        ScopeRef(scopeId),
        at: today,
      );

  bool _verifyGrant(String personId, String scopeId) =>
      _verifyGrants(personId, scopeId).any((g) => !_fallback(g));

  /// The Syamas post holders of [scopeId] in force today.
  List<String> _syamas(String scopeId) => [
    for (final a in ctx.inti.assignments)
      if (a.inForce(today) &&
          ctx.inti.post(a.postId)?.role == Role.syamasKolom &&
          ctx.inti.post(a.postId)?.scopeId == scopeId)
        a.personId,
  ];

  /// The Operator post holders in force today.
  List<String> _operator() => [
    for (final a in ctx.inti.assignments)
      if (a.inForce(today) && ctx.inti.post(a.postId)?.role == Role.operator)
        a.personId,
  ];

  /// Everyone holding a post, a cover or a delegation today.
  Set<String> _calon() => {
    for (final a in ctx.inti.assignments)
      if (a.inForce(today)) a.personId,
    for (final c in ctx.inti.covers)
      if (c.inForce(today)) c.personId,
    for (final d in ctx.inti.delegations)
      if (d.inForce(today)) d.toPersonId,
  };

  /// PMP 6.1 routing: whoever verifies in a Kolom of [i] still to verify by
  /// an assignment, delegation or vacancy cover in force, except their own
  /// family; when nobody else may (the Penatua's own family), the Syamas of
  /// the same Kolom, else an Operator (DL12), so nothing waits on an empty
  /// post.
  bool canVerify(String personId, VerificationItem i) =>
      pendingScopes(i).any((s) => canVerifyIn(personId, i, s));

  /// [canVerify] for one Kolom [scopeId] of [i].
  bool canVerifyIn(String personId, VerificationItem i, String scopeId) {
    if (!ctx.can.moduleActive(Module.membership)) return false;
    if (selfFor(personId, i)) return false;
    if (_verifyGrant(personId, scopeId)) return true;
    final lain = _calon().where((p) => !selfFor(p, i));
    if (lain.any((p) => _verifyGrant(p, scopeId))) return false;
    final syamas = _syamas(scopeId).where((p) => !selfFor(p, i)).toList();
    if (syamas.isNotEmpty) return syamas.contains(personId);
    return _operator().where((p) => !selfFor(p, i)).contains(personId);
  }

  /// The people [i] is routed to today.
  List<String> verifiersOf(VerificationItem i) => [
    for (final p in _calon())
      if (canVerify(p, i)) p,
  ];

  /// The refusal reason of "Verifikasi data" for [personId], or null.
  String? whyNot(String personId, VerificationItem i) {
    if (!i.open) return 'data ini sudah ${i.status.label}.';
    if (i.kind == ItemKind.household && i.submittedBy == personId) {
      return 'yang memasukkan formulir tidak memverifikasinya sendiri.';
    }
    if (selfFor(personId, i)) return 'ini data keluarga Anda sendiri.';
    if (!canVerify(personId, i)) {
      final sudah = i.verifiedScopes.where(
        (s) => canVerifyIn(personId, i, s) || _verifyGrant(personId, s),
      );
      if (sudah.isNotEmpty) {
        return 'data ${scopeName(sudah.first)} sudah diverifikasi; menunggu '
            'Penatua ${pendingScopes(i).map(scopeName).join(', ')}.';
      }
      return 'Anda tidak memverifikasi data ${scopeName(i.scopeId)}.';
    }
    return null;
  }

  /// The Kolom of [i] that [personId] verifies now.
  List<String> scopesFor(String personId, VerificationItem i) => [
    for (final s in pendingScopes(i))
      if (canVerifyIn(personId, i, s)) s,
  ];

  /// The grant a verifier acts through, for the audit line: their own
  /// post, cover or delegation before a Syamas or Operator fallback.
  Grant grantFor(Actor actor, VerificationItem i) {
    for (final s in scopesFor(actor.personId, i)) {
      final g = ctx.grant(actor, Capability.membershipVerify, ScopeRef(s));
      if (g != null && !_fallback(g)) return g;
      final semua = _verifyGrants(actor.personId, s);
      final utama = semua.where((x) => !_fallback(x)).firstOrNull;
      if (utama != null) return utama;
      if (g != null) return g;
      if (semua.isNotEmpty) return semua.first;
    }
    return ctx.own(actor);
  }

  /// Tells everyone [i] is routed to that it waits for them.
  void notifyVerifiers(VerificationItem i) {
    for (final p in verifiersOf(i)) {
      ctx.notify(
        p,
        title: title(i),
        body: 'Menunggu verifikasi · ${scopeName(i.scopeId)}',
        type: NotificationType.action,
        module: Module.membership,
        ref: RecordRef('membership_item', i.id),
      );
    }
  }

  /// The grant of an own submission: plain membership (membership.submit).
  Grant? submitGrant(Actor actor) =>
      ctx.grant(actor, Capability.membershipSubmit, ScopeRef.jemaat);

  /// [personId] or a member of [actor]'s household.
  bool ownFamily(Actor actor, String personId) {
    if (personId == actor.personId) return true;
    final h = t.householdOf(actor.personId);
    return h != null && h.memberIds.contains(personId);
  }

  /// Adds [personId] to household [h] (no-op when already in it).
  void join(Household h, String personId) {
    if (!h.memberIds.contains(personId)) h.memberIds.add(personId);
    t.profiles[personId]?.householdId = h.id;
  }
}
