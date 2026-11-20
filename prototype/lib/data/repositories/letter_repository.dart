import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/secretariat/secretariat.dart';

/// Letter requests (README 4.3): requested → issued or refused. An issued
/// letter is also a church document addressed to the member alone.
abstract interface class LetterRepository {
  /// Oldest first. With [personId], only the requests for or by that person.
  List<LetterRequest> requests({String? personId});

  /// The next number of the outgoing-letter book in [at]'s year:
  /// 'NNN/SKet/{Roman month}/{year}'.
  String nextNumber({required Tanggal at});

  /// The member's own request.
  Future<Result<LetterRequest>> request(
    Actor actor,
    LetterType type, {
    String? purpose,
    required String idempotencyKey,
  });

  /// The Operator records a request at the office for a member without a
  /// phone.
  Future<Result<LetterRequest>> recordAtOffice(
    Actor actor,
    String forPersonId,
    LetterType type, {
    String? purpose,
    required String idempotencyKey,
  });

  Future<Result<LetterRequest>> issue(
    Actor actor,
    String id,
    String number,
    SampleFile? signedCopy, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  Future<Result<void>> refuse(
    Actor actor,
    String id, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });
}
