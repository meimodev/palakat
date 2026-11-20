import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';

/// Ledger import (README 4.2, DM 5.5): STAGED → VALIDATED → REVIEWED →
/// COMMITTED. Committed rows become DRAFT transactions; refused rows stay
/// with their disposition. A staged row blocks its period's close.
abstract interface class ImportRepository {
  /// Newest first.
  List<ImportBatch> batches();
  List<StagedRow> rows(String batchId);

  Future<Result<ImportBatch>> stage(
    Actor actor,
    SampleImport file, {
    required String idempotencyKey,
  });

  Future<Result<ImportBatch>> validate(
    Actor actor,
    String batchId, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// [selection] is the row ids to import; the rest are deselected.
  Future<Result<ImportBatch>> reviewRows(
    Actor actor,
    String batchId,
    Set<String> selection, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  Future<Result<ImportBatch>> commit(
    Actor actor,
    String batchId, {
    required int expectedRevision,
    required String idempotencyKey,
  });
}
