import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';

/// Peruntukan (README 4.2). A Fund-only viewer sees only their own Funds
/// (README 3.5).
abstract interface class FundRepository {
  /// Every Fund active today that the signed-in actor may see.
  List<Fund> funds();

  /// Null when unknown or hidden from a Fund-only viewer.
  Fund? fund(String id);

  /// The Fund's liquid balance at the end of [at] (today when null).
  int balance(String fundId, {Tanggal? at});

  /// "Berlaku mulai {M+1}" (F19).
  Future<Result<Fund>> add(
    Actor actor,
    FundDraft draft,
    Tanggal effectiveFrom, {
    required String idempotencyKey,
  });
}
