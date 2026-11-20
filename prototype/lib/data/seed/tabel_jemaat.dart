import '../../core/tanggal.dart';
import '../../domain/membership/membership.dart';

/// The Membership tables (README 5.7), owned by M8. Mutable lists the
/// in-memory membership repositories change; nothing else writes them.
class TabelJemaat {
  /// By person id.
  final Map<String, MemberProfile> profiles = {};

  /// By id, in seed order.
  final Map<String, Household> households = {};

  /// Applications, life events (verified history included), data changes and
  /// household confirmations, oldest first.
  final List<VerificationItem> items = [];
  final List<Consent> consents = [];
  final List<DeletionRequest> deletions = [];
  final List<ImportBatch> batches = [];
  final List<DuplicateCase> duplicates = [];

  /// By person id: a member's own name-form choice.
  final Map<String, MaskingPreference> masking = {};

  /// The date of the consent text version (Modul: "Naskah bawaan · versi 1").
  Tanggal? consentTextDate;

  Household? householdOf(String personId) {
    final id = profiles[personId]?.householdId;
    return id == null ? null : households[id];
  }

  VerificationItem? item(String id) =>
      items.where((i) => i.id == id).firstOrNull;
}
