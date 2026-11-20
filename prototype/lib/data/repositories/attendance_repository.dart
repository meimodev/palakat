import '../../domain/collaboration/collaboration.dart';
import '../../domain/core/core.dart';

/// Attendance counts (README 4.5; rulebook 14.9, DL30): LIVE → REVIEW →
/// FINALIZED. The service's approver assigns counters, reviews and
/// finalizes; counters only count. A correction keeps both values. Every
/// `expectedRevision` is the count's.
abstract interface class AttendanceRepository {
  /// Null until the service is approved.
  AttendanceCount? count(String serviceId);

  /// Adds a post with its counter, or gives the post to [personId].
  Future<Result<AttendanceCount>> assignCounter(
    Actor actor,
    String serviceId,
    String personId,
    String post, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// [n] may be negative ("−"); a post never goes below 0. Only that post's
  /// counter, while LIVE.
  Future<Result<AttendanceCount>> increment(
    Actor actor,
    String serviceId,
    String post,
    int n, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// "Kirim untuk diperiksa" / "Tandai sudah diperiksa": a counter or the
  /// approver; refused while the total is 0.
  Future<Result<AttendanceCount>> submitForReview(
    Actor actor,
    String serviceId, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// "Kembalikan ke penghitung" / "Ubah angka".
  Future<Result<AttendanceCount>> returnToCounter(
    Actor actor,
    String serviceId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// "Tetapkan": the approver only; the service becomes Ditutup.
  Future<Result<AttendanceCount>> finalize(
    Actor actor,
    String serviceId, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// A Ditetapkan figure is never edited, only corrected with a reason.
  Future<Result<AttendanceCount>> correct(
    Actor actor,
    String serviceId,
    int value, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });
}
