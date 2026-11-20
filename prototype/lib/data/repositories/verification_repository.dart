import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';

/// The verifier's queue (README 4.4): applications, life events, data
/// changes and household confirmations, routed by the assignments,
/// delegations and vacancy covers in force. SUBMITTED → VERIFIED, returned or
/// declined; nobody verifies their own family's item (PMP 6.1): a Penatua's
/// own family goes to the Syamas of the Kolom.
abstract interface class VerificationRepository {
  List<QueueEntry> queue(Actor actor);

  /// One item, any status (not in README 4.4; the item screens).
  VerificationItem? item(String id);

  /// The confirmations of household [householdId], oldest first (not in
  /// README 4.4; KonfirmasiKeluarga).
  List<VerificationItem> forHousehold(String householdId);

  /// The people [itemId] is routed to today (not in README 4.4).
  List<String> verifiers(String itemId);

  /// Why [actor] may not verify [itemId] today, or null when they may.
  String? whyNotVerify(Actor actor, String itemId);

  Future<Result<void>> verify(
    Actor actor,
    String itemId, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  Future<Result<void>> returnForChanges(
    Actor actor,
    String itemId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });

  Future<Result<void>> decline(
    Actor actor,
    String itemId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });
}
