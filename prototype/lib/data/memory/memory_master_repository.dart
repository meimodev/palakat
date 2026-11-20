import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../repositories/master_repository.dart';
import 'memory_finance.dart';

/// Mata Anggaran versions and rows. Commands: M5.
class MemoryMasterRepository implements MasterRepository {
  MemoryMasterRepository(this.f);
  final MemoryFinance f;

  @override
  List<MasterVersion> versions(MasterKind kind) => [
    for (final v in f.k.masterVersions)
      if (v.kind == kind) v,
  ];

  @override
  List<MasterRow> rows(String versionId) =>
      f.k.masterRows.where((r) => r.versionId == versionId).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

  @override
  List<MasterRow> pickerRows(MasterKind kind, Tanggal date) {
    final berlaku =
        f.k.masterVersions
            .where(
              (v) =>
                  v.kind == kind &&
                  v.status == MasterVersionStatus.published &&
                  v.effectiveFrom != null &&
                  v.effectiveFrom! <= date,
            )
            .toList()
          ..sort((a, b) => a.effectiveFrom!.compareTo(b.effectiveFrom!));
    final v = berlaku.lastOrNull;
    return v == null ? const [] : rows(v.id);
  }

  @override
  Future<Result<MasterVersion>> createDraftVersion(
    Actor actor,
    MasterKind kind, {
    required String idempotencyKey,
  }) => f.notYet('Buat versi baru');

  @override
  Future<Result<MasterRow>> editRow(
    Actor actor,
    String versionId,
    MasterRow row, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Ubah baris');

  @override
  Future<Result<MasterRow>> setAllowedEffect(
    Actor actor,
    String versionId,
    String code,
    AllowedEffect effects, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Ubah boleh untuk');

  @override
  Future<Result<MasterVersion>> review(
    Actor actor,
    String versionId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Tandai sudah diperiksa');

  @override
  Future<Result<MasterVersion>> publish(
    Actor actor,
    String versionId,
    Tanggal effectiveFrom, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Terbitkan');
}
