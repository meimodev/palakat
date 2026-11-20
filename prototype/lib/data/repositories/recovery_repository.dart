import '../../domain/core/core.dart';

enum RecoveryStatus { waiting, recovered, notConfirmed }

/// A member's account recovery (AlurPulihkan, P4): the Operator asks with the
/// new number the person brought; the Penatua Kolom of the person's Kolom
/// confirms the identity, and only then the number changes.
class AccountRecovery {
  AccountRecovery({
    required this.id,
    required this.personId,
    required this.newPhone,
    required this.scopeId,
    required this.requestedBy,
    required this.requestedAt,
    this.status = RecoveryStatus.waiting,
    this.decidedBy,
    this.decidedAt,
    this.revision = 1,
  });

  final String id;
  final String personId;
  final String newPhone;

  /// The Kolom whose Penatua confirms.
  final String scopeId;
  final String requestedBy;
  final DateTime requestedAt;
  RecoveryStatus status;
  String? decidedBy;
  DateTime? decidedAt;
  int revision;
}

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
