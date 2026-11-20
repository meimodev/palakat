import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';

/// What members and households submit for verification (README 4.4).
abstract interface class ApplicationRepository {
  VerificationItem? application(String id);

  /// Items [personId] or their household submitted, newest first.
  List<VerificationItem> submittedBy(String personId);

  /// A new member's application with their consent (membership.apply).
  Future<Result<VerificationItem>> apply(
    Actor actor,
    ApplicationForm form,
    bool consent, {
    required String idempotencyKey,
  });

  /// A life event; the letter or certificate is required.
  Future<Result<VerificationItem>> submitLifeEvent(
    Actor actor,
    LifeEventDraft event,
    String? attachment, {
    required String idempotencyKey,
  });

  Future<Result<VerificationItem>> submitDataChange(
    Actor actor,
    String personId,
    String change, {
    required String idempotencyKey,
  });

  /// The household confirms its imported data and consents, in the app
  /// (its representative) or on a signed [paperForm] an officer enters.
  Future<Result<VerificationItem>> confirmHousehold(
    Actor actor,
    String householdId, {
    String? paperForm,
    required int expectedRevision,
    required String idempotencyKey,
  });
}
