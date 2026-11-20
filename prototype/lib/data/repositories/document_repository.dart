import '../../domain/core/core.dart';
import '../../domain/secretariat/secretariat.dart';

/// Church documents (README 4.3): revisions only, with no approval step; a
/// ralat makes a new revision and the old one stays openable (PMP 6.1).
abstract interface class DocumentRepository {
  /// Newest first. With [audienceOf], only those addressed to that person.
  List<ChurchDocument> list({String? audienceOf});
  ChurchDocument? get(String id);

  /// Refused without a signed copy, or with a document date after today.
  Future<Result<ChurchDocument>> publish(
    Actor actor,
    DocumentDraft draft,
    SampleFile? signedCopy,
    Audience audience, {
    required String idempotencyKey,
  });

  /// A new revision correcting [ralat]; refused without a signed copy.
  Future<Result<ChurchDocument>> revise(
    Actor actor,
    String id,
    String ralat,
    SampleFile? signedCopy, {
    required int expectedRevision,
    required String idempotencyKey,
  });
}
