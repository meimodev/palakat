import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';

/// AI help (README 4.2, 4.6 point 6): no network, ever. A proposal is kept
/// PENDING and becomes READY with the board's fixed proposal after the
/// board's delay, on a repository-owned timer that runs even if the screen
/// is left; the revision is bumped then. "Budget used up" is reached when
/// spend + cost > cap.
abstract interface class AiRepository {
  /// This month's spend against the cap.
  AiBudget budget();

  /// Completes with the READY proposal after the board's delay.
  Future<Result<AiProposal>> propose(
    Actor actor,
    AiKind kind,
    AiInput input, {
    required String idempotencyKey,
  });

  /// "Pakai", "Ubah" or "Abaikan"; no reason needed.
  Future<Result<AiProposal>> dispose(
    Actor actor,
    String proposalId,
    AiDisposition disposition, {
    required int expectedRevision,
    required String idempotencyKey,
  });
}
