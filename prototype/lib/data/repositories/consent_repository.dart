import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';

/// Consent and deletion (README 4.4, DL13: the keep and delete lists run in
/// memory).
abstract interface class ConsentRepository {
  List<Consent> consents(String personId);

  /// The consent text in use: its version and date (not in README 4.4).
  ({String version, Tanggal? date}) text();

  /// Every deletion request, newest first (not in README 4.4; CabutIzin).
  List<DeletionRequest> deletionRequests();

  Future<Result<Consent>> record(
    Actor actor,
    String personId,
    ConsentChannel channel, {
    required String idempotencyKey,
  });

  Future<Result<void>> withdraw(
    Actor actor,
    String personId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });

  Future<Result<DeletionRequest>> requestDeletion(
    Actor actor,
    String personId, {
    required String reason,
    required String idempotencyKey,
  });

  Future<Result<DeletionRequest>> executeDeletion(
    Actor actor,
    String requestId, {
    required int expectedRevision,
    required String idempotencyKey,
  });
}
