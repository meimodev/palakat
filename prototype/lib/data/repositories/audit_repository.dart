import '../../domain/core/core.dart';

/// The audit trail (README 4.1): appended by the other repositories inside
/// their commands; read by every Riwayat list.
abstract interface class AuditRepository {
  /// Newest first.
  List<AuditRecord> list(AuditFilter filter);
}
