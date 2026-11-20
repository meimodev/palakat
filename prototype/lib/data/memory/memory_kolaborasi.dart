import '../../domain/collaboration/collaboration.dart';
import '../../domain/core/core.dart';
import '../seed/tabel_kolaborasi.dart';
import 'memory_context.dart';

/// What the in-memory Collaboration repositories share.
extension KolaborasiKonteks on MemoryContext {
  TabelKolaborasi get kol => store.kolaborasi;

  /// The grants of [personId] that give [c] in exactly [scopeId], not by an
  /// ancestor scope: DL11 has a Kolom's own Penatua or Syamas approve its
  /// service, not the Ketua Jemaat; DL29 the same for requests.
  List<Grant> exactGrants(String personId, Capability c, String scopeId) => [
    for (final g in can.grantsFor(personId, c, ScopeRef(scopeId), at: today))
      if (g.scopeId == scopeId && g.kind != GrantKind.member) g,
  ];

  /// The actor's grant for [c] in exactly [scopeId] (their acting one
  /// first), or null; the module must allow it.
  Grant? exactGrant(Actor actor, Capability c, String scopeId) {
    if (grant(actor, c, ScopeRef(scopeId)) == null) return null;
    final g = exactGrants(actor.personId, c, scopeId);
    if (g.isEmpty) return null;
    return g.firstWhere(
      (x) => x.assignmentId == actor.assignmentId && x.via == actor.via,
      orElse: () => g.first,
    );
  }

  /// Everyone who holds [c] in exactly [scopeId] today.
  List<String> exactHolders(Capability c, String scopeId) => [
    for (final p in inti.people)
      if (!p.isSystem && exactGrants(p.id, c, scopeId).isNotEmpty) p.id,
  ];

  /// The gate's refusal when [exactGrant] is null.
  Refused<T> refuseExact<T>(Actor actor, Capability c, String scopeId) {
    final r = can.whyNot(actor, c, ScopeRef(scopeId), at: today);
    if (r != null && r.because.startsWith('Modul')) return Refused<T>(r);
    final siapa = exactHolders(c, scopeId).map(personName).join(', ');
    return Refused<T>(
      Refusal(
        action: c.label,
        because: 'Jabatan Anda tidak berwenang untuk ini.',
        whoCanAct: siapa.isEmpty ? null : siapa,
      ),
    );
  }

  /// DL11: a Jemaat-wide service or a Panitia event is approved by the Ketua
  /// Jemaat, in the Jemaat scope; any other by its audience's own posts.
  String approverScopeOf(Service s) {
    final t = inti.scope(s.scopeId)?.type;
    return s.kind == ServiceKind.panitia ||
            t == ScopeType.panitia ||
            t == ScopeType.jemaat
        ? ScopeRef.jemaatId
        : s.scopeId;
  }
}
