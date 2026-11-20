import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/layar.dart';
import '../core/clock.dart';
import '../core/tanggal.dart';
import '../domain/core/core.dart';
import 'clock.dart';
import 'core_repositories.dart';
import 'revision.dart';
import 'seed.dart';
import 'session.dart';

/// The capability gate over the live store (README 3.5). A new value on every
/// revision, so `ref.watch(canProvider)` follows module and post changes.
final canProvider = Provider<Can>((ref) {
  ref.watch(revisionProvider);
  return Can(ref.watch(seedProvider).inti);
});

/// Today in WITA from the clock (follows `majukanJam` through the revision).
final hariIniProvider = Provider<Tanggal>((ref) {
  ref.watch(revisionProvider);
  return Tanggal.dari(ref.watch(clockProvider).now());
});

/// The signed-in actor (README 3.3): person, acting assignment, scope and
/// `via`. Null on the picker and once the session has ended. While a person
/// with two posts has not chosen ("Sebagai …"), the actor acts in no post;
/// the gate still answers for the person.
final actorProvider = Provider<Actor?>((ref) {
  final s = ref.watch(sessionProvider);
  if (s == null || s.berakhir) return null;
  return s.bertindak?.toActor() ??
      Actor(personId: s.personId, scopeId: ScopeRef.jemaatId);
});

/// True while the actor covers the vacant Bendahara post (D18): the phone
/// strip, the web band and the web footer read it.
final vacancyCoverProvider = Provider<bool>((ref) {
  final a = ref.watch(actorProvider);
  if (a == null) return false;
  final can = ref.watch(canProvider);
  return can
      .grantsOf(a.personId, at: ref.watch(hariIniProvider))
      .any(
        (g) =>
            g.kind == GrantKind.cover &&
            can.facts.post(g.postId!)?.role == Role.bendaharaJemaat,
      );
});

var _nomorKunci = 0;

/// A fresh idempotency key for one submission (README 3.4):
/// '{personId}-{microseconds}-{counter}'.
String kunciBaru(String personId, Clock clock) =>
    '$personId-${clock.now().microsecondsSinceEpoch}-${_nomorKunci++}';

/// Why [l] cannot open for [actor] at [at], or null when it can (README 3.6):
/// its module is not ACTIVE (a READ_ONLY module counts as not active for
/// screens), or the actor lacks the screen's capability in every scope.
Penjaga? penjagaUntuk(Layar l, Can can, Actor? actor, Tanggal at) {
  if (!can.moduleActive(l.modulLayar.modul)) return Penjaga.modulTidakAktif;
  final k = l.kemampuan;
  if (k == null) return null;
  if (actor == null || !can.can(actor, k, ScopeRef.anywhere, at: at)) {
    return Penjaga.tidakBerwenang;
  }
  return null;
}

/// [penjagaUntuk] for the signed-in actor today; the router's guard reads it.
final penjagaProvider = Provider.family<Penjaga?, Layar>(
  (ref, l) => penjagaUntuk(
    l,
    ref.watch(canProvider),
    ref.watch(actorProvider),
    ref.watch(hariIniProvider),
  ),
);

/// What the vacancy strip, band and footer print (D18) while
/// [vacancyCoverProvider] is true: the covered post's title, when the cover
/// started and the Operator's name. Null otherwise.
final jabatanDijalankanProvider =
    Provider<({String jabatan, DateTime sejak, String operator})?>((ref) {
      ref.watch(revisionProvider);
      if (!ref.watch(vacancyCoverProvider)) return null;
      final a = ref.watch(actorProvider);
      if (a == null) return null;
      final v = ref
          .watch(roleRepositoryProvider)
          .posts()
          .where(
            (p) =>
                p.post.role == Role.bendaharaJemaat &&
                p.cover?.personId == a.personId,
          )
          .firstOrNull;
      final nama = ref.watch(peopleRepositoryProvider).person(a.personId)?.name;
      if (v == null || nama == null) return null;
      return (jabatan: v.post.title, sejak: v.cover!.startedAt, operator: nama);
    });

/// The vacancy band of post [postId] for the screens that show it whoever is
/// signed in (JabatanKosong, WebJabatanKosong, WebAlurJabatanKosong): when
/// its cover started (null while none is in force) and who runs it (the
/// covering person, else the holder of the Operator post).
final jalanJabatanProvider =
    Provider.family<({DateTime? sejak, String operator}), String>((
      ref,
      postId,
    ) {
      ref.watch(revisionProvider);
      final posts = ref.watch(roleRepositoryProvider).posts();
      final cover = posts.where((p) => p.post.id == postId).firstOrNull?.cover;
      final orang =
          cover?.personId ??
          posts
              .where((p) => p.post.role == Role.operator)
              .firstOrNull
              ?.holder
              ?.personId;
      final nama = orang == null
          ? null
          : ref.watch(peopleRepositoryProvider).person(orang)?.name;
      return (sejak: cover?.startedAt, operator: nama ?? '');
    });
