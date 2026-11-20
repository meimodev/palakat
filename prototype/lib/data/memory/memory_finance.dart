import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../seed/tabel_keuangan.dart';
import 'memory_context.dart';

/// What every in-memory finance repository shares: the core context, the
/// finance tables, the signed-in viewer for Fund-only filtering (README
/// 3.5) and period checks.
class MemoryFinance {
  MemoryFinance(this.ctx, this.viewer);

  final MemoryContext ctx;

  /// The signed-in actor, read when a query runs; null in tests that read
  /// repositories directly (no filtering then).
  final Actor? Function() viewer;

  TabelKeuangan get k => ctx.store.keuangan;
  Tanggal get today => ctx.today;
  DateTime get now => ctx.now;

  /// The Fund ids the viewer may see; null when they see every Fund
  /// (`finance.view`) or nobody is signed in. A Fund-only viewer sees the
  /// Funds owned by the scopes of their `finance.view_fund` grants, and the
  /// Funds they prepare.
  Set<String>? visibleFundIds() {
    final a = viewer();
    if (a == null) return null;
    final can = ctx.can;
    if (can.grantFor(a, Capability.financeView, ScopeRef.anywhere, at: today) !=
        null) {
      return null;
    }
    final grants = can.grantsFor(
      a.personId,
      Capability.financeViewFund,
      ScopeRef.anywhere,
      at: today,
    );
    // A scoped preparer also sees the Fund they attest (DP37: Rivo, Pembangunan).
    return {
      for (final f in k.funds)
        if (f.preparerPersonId == a.personId ||
            grants.any((g) => can.covers(g.scopeId, ScopeRef(f.ownerScopeId))))
          f.id,
    };
  }

  /// [t] as [funds] may see it: whole, sliced to their parts, or null.
  /// A viewer always sees what they made.
  Transaction? visible(Transaction t, Set<String>? funds) {
    final saya = viewer()?.personId;
    if (funds == null || t.createdBy == saya) return t;
    // A giver also sees the gifts recorded in their name (P06, J1).
    final pihak = {
      for (final p in ctx.inti.parties)
        if (p.personId == saya) p.id,
    };
    final s = t.slice(
      (a) =>
          funds.contains(a.fundId) ||
          funds.contains(a.toFundId) ||
          (t.typeOf(a) == TransactionType.income && pihak.contains(a.partyId)),
    );
    return s.allocations.isEmpty ? null : s;
  }

  /// "{bulan} sudah ditutup." for a date in a CLOSED period, or "before the
  /// recording started"; null when [d] may be booked.
  String? closedReason(Tanggal d) {
    final c = k.cutover;
    if (c != null && d < c) {
      return 'Tanggal ini sebelum pencatatan dimulai pada $c.';
    }
    final p = k.periodOf(d);
    if (p == null || !p.isClosed) return null;
    return '${bulanTahun(p.year, p.month)} sudah ditutup.';
  }

  /// The finance audit line.
  void audit(
    Grant g, {
    required String action,
    required String summary,
    RecordRef? ref,
    String? before,
    String? after,
    String? reason,
  }) => ctx.audit(
    g,
    action: action,
    summary: summary,
    module: Module.finance,
    ref: ref,
    before: before,
    after: after,
    reason: reason,
  );

  /// A finance notification ('tindak' by default).
  void notify(
    String recipientId, {
    required String title,
    required String body,
    String type = NotificationType.action,
    RecordRef? ref,
  }) => ctx.notify(
    recipientId,
    title: title,
    body: body,
    type: type,
    module: Module.finance,
    ref: ref,
  );
}
