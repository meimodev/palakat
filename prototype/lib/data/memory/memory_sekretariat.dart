import '../../domain/core/core.dart';
import '../../domain/secretariat/secretariat.dart';
import '../seed/tabel_sekretariat.dart';
import 'memory_context.dart';

extension SekretariatKonteks on MemoryContext {
  TabelSekretariat get sek => store.sekretariat;

  /// Whether [personId] is among the addressees of [a] today (Q25, Q30):
  /// every member; the servants (anyone holding a post, a cover or a
  /// delegation); a Kolom's members and servants; one member and their
  /// family.
  bool sees(Audience a, String personId) {
    switch (a.kind) {
      case AudienceKind.all:
        return true;
      case AudienceKind.servants:
        return can
            .grantsOf(personId, at: today)
            .any((g) => g.kind != GrantKind.member);
      case AudienceKind.scope:
        return sek.memberScopes[personId] == a.scopeId ||
            can
                .grantsOf(personId, at: today)
                .any(
                  (g) => g.kind != GrantKind.member && g.scopeId == a.scopeId,
                );
      case AudienceKind.person:
        final rumah = sek.households[personId];
        final kolom = sek.memberScopes[a.personId];
        return a.personId == personId ||
            (rumah != null && sek.households[a.personId] == rumah) ||
            // The servants whose post covers that member (PMP 6.1).
            (kolom != null &&
                can
                    .grantsOf(personId, at: today)
                    .any(
                      (g) => g.kind != GrantKind.member && g.scopeId == kolom,
                    ));
    }
  }

  /// Notifies everyone [a] addresses today except [kecuali] (README 3.4).
  void notifyAudience(
    Audience a,
    String kecuali, {
    required String title,
    required String body,
    required Module module,
    required RecordRef ref,
  }) {
    for (final p in inti.people) {
      if (!p.isSystem && p.id != kecuali && sees(a, p.id)) {
        notify(p.id, title: title, body: body, module: module, ref: ref);
      }
    }
  }

  /// Notifies [personId] when they are a person (a household-level request
  /// such as Keluarga Lasut has no one to notify yet).
  void notifyPerson(
    String personId, {
    required String title,
    required String body,
    required Module module,
    required RecordRef ref,
  }) {
    if (inti.person(personId) == null) return;
    notify(personId, title: title, body: body, module: module, ref: ref);
  }

  /// Everyone who may [c] in the Jemaat today: the recipients of a request
  /// waiting for that post (README 3.4).
  Iterable<String> holders(Capability c) => [
    for (final p in inti.people)
      if (!p.isSystem &&
          can.grantsFor(p.id, c, ScopeRef.jemaat, at: today).isNotEmpty)
        p.id,
  ];

  /// Notifies every holder of [c] except [kecuali].
  void notifyHolders(
    Capability c,
    String kecuali, {
    required String title,
    required String body,
    required Module module,
    required RecordRef ref,
  }) {
    for (final id in holders(c)) {
      if (id != kecuali) {
        notify(
          id,
          title: title,
          body: body,
          type: NotificationType.action,
          module: module,
          ref: ref,
        );
      }
    }
  }

  /// The secretariat module's gate in the Jemaat scope: the grant, or null.
  Grant? gate(Actor actor, Capability c) => grant(actor, c, ScopeRef.jemaat);
}
