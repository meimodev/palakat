import '../../domain/core/core.dart';

/// People and parties (README 4.1).
abstract interface class PeopleRepository {
  Person? person(String id);

  /// Name contains [query], case-insensitive; system actors excluded.
  List<Person> search(String query);
  List<Party> parties();

  Future<Result<void>> linkPartyToPerson(
    Actor actor,
    String partyId,
    String personId, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// Removes the link and keeps the recorded name (DL13).
  Future<Result<void>> unlinkParty(
    Actor actor,
    String partyId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// AkunSaya: the sign-in number and the backup email of the actor's own
  /// account (not in README 4.1; added for P2). A null field is unchanged;
  /// an empty email removes it. A new phone number ends the person's other
  /// devices in the same command.
  Future<Result<Person>> setContact(
    Actor actor, {
    String? phone,
    String? backupEmail,
    required int expectedRevision,
    required String idempotencyKey,
  });
}
