import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';

/// Mata Anggaran versions and rows (README 4.2): DRAFT → REVIEWED →
/// PUBLISHED (DM 5.5).
abstract interface class MasterRepository {
  /// Every version of [kind], oldest first.
  List<MasterVersion> versions(MasterKind kind);

  /// The rows of a version in source order.
  List<MasterRow> rows(String versionId);

  /// The rows of the version published and in force at [date], in source
  /// order, headings included (postable false).
  List<MasterRow> pickerRows(MasterKind kind, Tanggal date);

  /// A draft copy of the latest version, numbered next, effective from M+1.
  Future<Result<MasterVersion>> createDraftVersion(
    Actor actor,
    MasterKind kind, {
    required String idempotencyKey,
  });

  /// Adds or replaces a row of a draft (keyed by code).
  Future<Result<MasterRow>> editRow(
    Actor actor,
    String versionId,
    MasterRow row, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// "Boleh untuk" of row [code] (RD10).
  Future<Result<MasterRow>> setAllowedEffect(
    Actor actor,
    String versionId,
    String code,
    AllowedEffect effects, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  Future<Result<MasterVersion>> review(
    Actor actor,
    String versionId, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  Future<Result<MasterVersion>> publish(
    Actor actor,
    String versionId,
    Tanggal effectiveFrom, {
    required int expectedRevision,
    required String idempotencyKey,
  });
}
