import '../../domain/collaboration/collaboration.dart';
import '../../domain/core/core.dart';

/// Services (README 4.5, DL11): Draf → Dijadwalkan → Selesai → Ditutup. The
/// Penatua or Syamas of the audience's Kolom or BIPRA approves; a Jemaat-wide
/// service or Panitia event, the Ketua Jemaat. Approving opens its
/// attendance count (DL30).
abstract interface class ServiceRepository {
  /// By date. With [scopeId], only that audience's.
  List<Service> list({String? scopeId});
  Service? get(String id);

  /// The people who may approve [id] (its audience's posts in force).
  /// Beyond README 4.5: Ibadah's Draf caption names them.
  List<String> approversOf(String id);

  /// Refused for a date before today.
  Future<Result<Service>> draft(
    Actor actor,
    ServiceDraft serviceDraft, {
    required String idempotencyKey,
  });

  Future<Result<Service>> approve(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// Refused while a started count is not Ditetapkan.
  Future<Result<Service>> close(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  });
}
