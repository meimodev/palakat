import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';

/// Paper member books (README 4.4): Staged → checked → imported. Imported
/// people are UNCONFIRMED until their household confirms (DL8).
abstract interface class MemberImportRepository {
  List<ImportBatch> batches();
  List<DuplicateCase> duplicates();

  Future<Result<ImportBatch>> stage(
    Actor actor,
    SampleBook book, {
    required String idempotencyKey,
  });

  /// "Jalankan pengecekan": refuses rows without a readable birth date and
  /// flags possible duplicates (not in README 4.4).
  Future<Result<ImportBatch>> check(
    Actor actor,
    String batchId, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// Completes a birth date the book left incomplete (not in README 4.4;
  /// AlurKeluarga).
  Future<Result<void>> completeRow(
    Actor actor,
    String batchId,
    String rowId,
    Tanggal birthDate, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  Future<Result<void>> resolveDuplicate(
    Actor actor,
    String caseId,
    DuplicateDecision decision, {
    required String reason,
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
