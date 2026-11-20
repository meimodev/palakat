import '../../domain/core/core.dart';
import '../../domain/secretariat/secretariat.dart';

/// Announcements (README 4.3): DRAFT → PUBLISHED → ARCHIVED, archived by
/// itself after its end date (DL14). The Operator drafts; only the
/// Sekretaris Jemaat publishes.
abstract interface class AnnouncementRepository {
  /// Newest first. With [audienceOf], only published or archived ones
  /// addressed to that person (members never see drafts).
  List<Announcement> list({String? audienceOf});

  /// The name of the Kolom whose announcements [personId] receives as a
  /// member ('Kolom 7'), or null. Beyond README 4.3, for the member's home
  /// row; MemberRepository answers it once M10 joins Data jemaat.
  String? kolomOf(String personId);

  Future<Result<Announcement>> draft(
    Actor actor,
    AnnouncementDraft announcementDraft, {
    required String idempotencyKey,
  });

  Future<Result<void>> publish(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// A ralat of a published announcement: [body] becomes revision n + 1 and
  /// revision n stays readable as "Digantikan" (DL14, rule 723). Beyond
  /// README 4.3: both Pengumuman boards draw it.
  Future<Result<Announcement>> revise(
    Actor actor,
    String id,
    String body, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  Future<Result<void>> archive(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  });
}
