import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../repositories/import_repository.dart';
import 'memory_finance.dart';

/// Ledger import batches and staged rows. Commands: M3.
class MemoryImportRepository implements ImportRepository {
  MemoryImportRepository(this.f);
  final MemoryFinance f;

  @override
  List<ImportBatch> batches() => f.k.importBatches.reversed.toList();

  @override
  List<StagedRow> rows(String batchId) =>
      f.k.stagedRows.where((r) => r.batchId == batchId).toList()
        ..sort((a, b) => a.ordinal.compareTo(b.ordinal));

  @override
  Future<Result<ImportBatch>> stage(
    Actor actor,
    SampleImport file, {
    required String idempotencyKey,
  }) => f.notYet('Tampung');

  @override
  Future<Result<ImportBatch>> validate(
    Actor actor,
    String batchId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Cek');

  @override
  Future<Result<ImportBatch>> reviewRows(
    Actor actor,
    String batchId,
    Set<String> selection, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Tandai sudah diperiksa');

  @override
  Future<Result<ImportBatch>> commit(
    Actor actor,
    String batchId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Impor');
}
