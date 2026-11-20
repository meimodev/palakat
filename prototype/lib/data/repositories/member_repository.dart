import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';

/// Members and households (README 4.4). BIPRA is computed from birth date,
/// sex and marital status (DL28); the Penatua Kolom may override one case.
abstract interface class MemberRepository {
  /// Members with a profile (active and unconfirmed), optionally of one
  /// Kolom today. Deceased members are kept.
  List<Member> members({String? kolom});
  Member? member(String personId);
  List<Household> households();
  Household? household(String id);
  Bipra? bipra(String personId);

  /// Active members, unconfirmed members and active households, optionally
  /// of one Kolom (not in README 4.4; LaporanLintas and the home rows).
  ({int active, int unconfirmed, int households}) counts({String? kolom});

  /// Verified life events of [personId], oldest first.
  List<VerificationItem> events(String personId);

  Future<Result<void>> overrideBipra(
    Actor actor,
    String personId,
    Bipra group, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });
}
