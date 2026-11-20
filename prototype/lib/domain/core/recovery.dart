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
