import '../../domain/collaboration/collaboration.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';

/// Fund requests (README 4.5, DL29, DM 5.2): Diajukan → disetujui / tidak
/// disetujui / jumlah diubah → dibayar. No self-approval; below the
/// threshold no approval is needed; a material change resets the approval
/// to PENDING. Approval is not payment: the church Bendahara records it as
/// Uang Muka diberikan.
abstract interface class FundRequestRepository {
  /// Newest first. With [personId], only that person's requests.
  List<FundRequestView> list({String? personId});
  FundRequestView? get(String id);

  /// The Funds [personId] may ask from ("Diambil dari peruntukan"): those
  /// owned by the units of their `requests.submit` posts, then the Jemaat's
  /// own. Not cut by the Fund-only viewer filter (PermintaanDana, M9).
  List<Fund> requestableFunds(String personId);

  Future<Result<FundRequest>> submit(
    Actor actor,
    FundRequestDraft requestDraft, {
    required String idempotencyKey,
  });

  Future<Result<FundRequest>> approve(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// "Tidak disetujui", with a reason.
  Future<Result<FundRequest>> refuse(
    Actor actor,
    String id, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// The requester changes the amount before payment; an approval given
  /// stops counting and the request waits again.
  Future<Result<FundRequest>> changeAmount(
    Actor actor,
    String id,
    int amount, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// Creates the Uang Muka diberikan draft through
  /// `CaseRepository.issueAdvance` (from the Jemaat Kas/Bank holding most of
  /// the request's Fund) and returns its transaction id. "Dibayar" once
  /// that draft is booked.
  Future<Result<String>> recordPayment(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  });
}
