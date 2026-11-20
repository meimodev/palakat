import '../../domain/core/core.dart';

/// The church-owned export (README 4.1, F18): a manifest, no file.
abstract interface class ExportRepository {
  Future<Result<ExportManifest>> build(
    Actor actor, {
    required String idempotencyKey,
  });
}
