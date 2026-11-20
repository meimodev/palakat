import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';

/// Report datasets F01–F14 (README 4.2, 4.6 point 3, DM 7–8): PREVIEW
/// computed from state for any month, SNAPSHOT frozen at the close. A
/// Fund-only viewer's perimeter is cut to their Funds (README 3.5).
abstract interface class ReportRepository {
  ReportPack preview(String periodId, Perimeter perimeter);

  /// Null until the period is closed.
  ReportSnapshot? snapshot(String periodId);

  /// One form from [source]: the snapshot when the period is closed and the
  /// perimeter whole, else computed.
  ReportDataset dataset(ReportSource source, ReportForm form);

  /// TERBATAS: F02, F03, F05, F07 and F12 of one Fund (D27).
  RestrictedReport restricted(ReportSource source, String fundId);

  List<ReportTemplate> templates();

  /// RD03: the authorized church officer accepts the default template.
  Future<Result<ReportTemplate>> acceptTemplate(
    Actor actor,
    String templateId, {
    required int expectedRevision,
    required String idempotencyKey,
  });
}
