import '../../domain/core/core.dart';

/// Sessions and devices (README 4.1). A session ends on sign-out, or when the
/// assignment it acts in ends (README 3.6).
abstract interface class SessionRepository {
  /// The picker's people, in picker order (README 5.2, D17).
  List<Person> personas();

  /// The session on this device, ended or not; null after sign-out.
  SessionRecord? current();

  /// The person's other devices that are still signed in.
  List<Device> devices(String personId);

  /// Signs [personaId] in on this device. The acting post is picked when one
  /// post can act; with two, `choices` waits for [actAs] (Q31).
  Future<Result<SessionRecord>> signIn(String personaId);

  Future<Result<void>> signOut();

  /// Records the post the person chose ("Sebagai …"): [actor] carries it.
  Future<Result<SessionRecord>> actAs(
    Actor actor, {
    required String idempotencyKey,
  });

  /// AkunSaya "Keluarkan": ends the session on another device.
  Future<Result<void>> endDevice(
    Actor actor,
    String deviceId, {
    required int expectedRevision,
    required String idempotencyKey,
  });
}
