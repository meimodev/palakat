import '../../domain/core/core.dart';

/// Account recovery (core.recover_account, core.confirm_recovery; not in
/// README 4.1, added by M6 for P4).
abstract interface class RecoveryRepository {
  /// Every recovery, newest first.
  List<AccountRecovery> recoveries();

  /// The Kolom whose Penatua confirms a recovery of [personId], or null.
  String? confirmingScope(String personId);

  /// The Operator asks; the Penatua Kolom is notified. The Operator never
  /// recovers their own account.
  Future<Result<AccountRecovery>> request(
    Actor actor,
    String personId,
    String newPhone, {
    required String idempotencyKey,
  });

  /// The Penatua Kolom confirms the identity: the new number is set and the
  /// person's other devices are signed out.
  Future<Result<AccountRecovery>> confirm(
    Actor actor,
    String recoveryId, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// "Bukan orangnya": nothing changes.
  Future<Result<AccountRecovery>> decline(
    Actor actor,
    String recoveryId, {
    required int expectedRevision,
    required String idempotencyKey,
  });
}
