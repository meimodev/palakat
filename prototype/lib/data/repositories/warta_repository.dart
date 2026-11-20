import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/secretariat/secretariat.dart';

/// The weekly Warta Jemaat (README 4.3): DRAFT → REVIEW → APPROVED →
/// PUBLISHED → ARCHIVED; the Sekretaris performs every step and each step is
/// recorded (rulebook 14.7). After review the content is locked (P18).
abstract interface class WartaRepository {
  /// Newest Sunday first.
  List<WartaEdition> editions();
  WartaEdition? edition(String id);

  /// What the edition prints: picked announcements and names as each member
  /// chose, with recorded exceptions.
  WartaPreview? preview(String id);

  Future<Result<WartaEdition>> draft(
    Actor actor,
    Tanggal sunday, {
    required String idempotencyKey,
  });

  /// Picks [announcementId] into the edition ([include]) or out of it; only
  /// while Draf, and only a published announcement (P17, AlurWarta).
  Future<Result<void>> pickAnnouncement(
    Actor actor,
    String id,
    String announcementId,
    bool include, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// "Tandai sudah diperiksa": Draf → Sudah diperiksa.
  Future<Result<void>> submit(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// "Setujui untuk diterbitkan".
  Future<Result<void>> approve(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// "Kembali ke Draf" from Sudah diperiksa or Disetujui (WartaEditor).
  Future<Result<void>> returnToDraft(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  Future<Result<void>> publish(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// A linked correction of a published edition; the edition is unchanged.
  Future<Result<void>> ralat(
    Actor actor,
    String id, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// Prints the name of [personId], who chose "Tanpa nama", in this edition
  /// only; Sekretaris Jemaat only, with a reason.
  Future<Result<void>> revealIdentity(
    Actor actor,
    String editionId,
    String personId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });
}
