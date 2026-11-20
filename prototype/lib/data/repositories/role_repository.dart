import '../../core/tanggal.dart';
import '../../domain/core/core.dart';

/// How long the Petugas verifikasi takes to activate an authority grant: the
/// Bendahara and WebSerahTerima boards' timer.
const waktuVerifikasiWewenang = Duration(milliseconds: 2800);

/// Posts, assignments, delegations, vacancy cover and authority grants
/// (README 4.1, PMP 5).
abstract interface class RoleRepository {
  /// Posts in post order, with holder, vacancy, cover, a pending assignment
  /// and a proposed handover as of today. [scopeId] narrows to one scope.
  List<PostView> posts({String? scopeId});

  /// Every assignment of the person, pending and ended included.
  List<Assignment> assignmentsOf(String personId);

  /// Delegations from or to [personId]; all when null.
  List<Delegation> delegations({String? personId});

  /// Authority grants of [personId]; all when null.
  List<AuthorityGrant> grants({String? personId});

  /// The outgoing holder prepares the handover with the church document
  /// (SerahTerima, DP39). The authorized church officer then records it.
  Future<Result<HandoverProposal>> proposeHandover(
    Actor actor,
    String postId,
    String toPersonId,
    String documentRef, {
    required String idempotencyKey,
  });

  /// Records an assignment (DL21). For the Bendahara and Sekretaris it waits
  /// as "Menunggu verifikasi wewenang" until the Petugas verifikasi activates
  /// it after [waktuVerifikasiWewenang]; then the previous holder's term
  /// ends, any cover ends and sessions acting in the old assignment end.
  /// Other posts take effect at once and end the cover. No self-assignment.
  /// [expectedRevision] is the post's.
  Future<Result<Assignment>> assign(
    Actor actor,
    String postId,
    String personId,
    Tanggal start, {
    String? documentRef,
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// [end] is the last day in force; today or earlier ends it now.
  Future<Result<Assignment>> endTerm(
    Actor actor,
    String assignmentId,
    Tanggal end, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// An Operator takes over a vacant post (DL12). [expectedRevision] is the
  /// post's.
  Future<Result<VacancyCover>> coverVacancy(
    Actor actor,
    String postId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// [end] is the last day in force; it expires by itself.
  Future<Result<Delegation>> delegate(
    Actor actor,
    DelegatedTask task,
    String toPersonId,
    Tanggal start,
    Tanggal end, {
    required String idempotencyKey,
  });

  /// The delegator ends a delegation in force today ("Akhiri sekarang").
  Future<Result<Delegation>> endDelegation(
    Actor actor,
    String delegationId, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// Revokes an authority grant; sessions acting in its assignment end.
  Future<Result<AuthorityGrant>> revokeGrant(
    Actor actor,
    String grantId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });
}
