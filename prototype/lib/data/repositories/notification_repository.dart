import '../../domain/core/core.dart';

/// The one inbox (README 4.1). Repositories write the rows.
abstract interface class NotificationRepository {
  /// Newest first; types the person switched off are left out.
  List<AppNotification> inbox(String personId);
  int unreadCount(String personId);
  NotificationPreferences preferences(String personId);

  Future<Result<void>> markRead(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// [type] is a [NotificationType] value. [expectedRevision] is the
  /// preferences'.
  Future<Result<void>> setPreference(
    Actor actor,
    String type,
    bool on, {
    required int expectedRevision,
    required String idempotencyKey,
  });
}
