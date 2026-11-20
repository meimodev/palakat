import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../repositories/settings_repository.dart';
import 'memory_finance.dart';

/// Rule values and the Lingkup list (D24: changes from the 1st of M+1).
class MemorySettingsRepository implements SettingsRepository {
  MemorySettingsRepository(this.f);
  final MemoryFinance f;

  /// The latest value of [rule] with effectiveFrom <= [at].
  RuleValue? _inForce(FinanceRule rule, Tanggal at) {
    final v =
        f.k.ruleValues
            .where((v) => v.rule == rule && v.effectiveFrom <= at)
            .toList()
          ..sort((a, b) {
            final d = a.effectiveFrom.compareTo(b.effectiveFrom);
            return d != 0 ? d : a.setAt.compareTo(b.setAt);
          });
    return v.lastOrNull;
  }

  @override
  RuleValue? valueInForce(FinanceRule rule, {required Tanggal at}) =>
      _inForce(rule, at);

  @override
  RulesInForce rulesInForce({required Tanggal at}) => RulesInForce({
    for (final r in FinanceRule.values) r: _inForce(r, at)?.on ?? false,
  });

  @override
  List<RuleValue> scheduled() =>
      f.k.ruleValues.where((v) => v.effectiveFrom > f.today).toList()
        ..sort((a, b) => a.effectiveFrom.compareTo(b.effectiveFrom));

  @override
  List<LingkupLink> lingkup({Tanggal? at}) => [
    for (final l in f.k.lingkup)
      if (l.activeFrom <= (at ?? f.today)) l,
  ];

  /// The 1st of M+1, the month every change takes effect from (D24).
  Tanggal get bulanDepan {
    final t = f.today;
    return t.bulan == 12
        ? Tanggal(t.tahun + 1, 1, 1)
        : Tanggal(t.tahun, t.bulan + 1, 1);
  }

  @override
  Future<Result<RuleValue>> setRule(
    Actor actor,
    FinanceRule rule,
    bool on,
    Tanggal effectiveFrom, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Ubah aturan';
    final g = f.ctx.grant(actor, Capability.financeSettings, ScopeRef.jemaat);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeSettings, ScopeRef.jemaat);
    }
    final kini = _inForce(rule, f.today);
    final basi = f.ctx.stale<RuleValue>(
      kini?.revision ?? 0,
      expectedRevision,
      aksi,
    );
    if (basi != null) return basi;
    // D24: never the running month; the 1st of a later month.
    if (effectiveFrom.hari != 1 || effectiveFrom < bulanDepan) {
      return f.ctx.no(
        aksi,
        'Perubahan aturan berlaku mulai bulan berikutnya, '
        '${bulanTahun(bulanDepan.tahun, bulanDepan.bulan)}.',
      );
    }
    // A later change replaces the one already scheduled from that month on.
    f.k.ruleValues.removeWhere(
      (v) => v.rule == rule && v.effectiveFrom >= effectiveFrom,
    );
    final v = RuleValue(
      id: f.ctx.store.newId('aturan'),
      rule: rule,
      on: on,
      effectiveFrom: effectiveFrom,
      setBy: actor.personId,
      setAt: f.now,
      reason: reason.trim().isEmpty ? null : reason.trim(),
    );
    f.k.ruleValues.add(v);
    f.audit(
      g,
      action: 'finance.rule.set',
      summary:
          'Wajib pemeriksa kedua ${on ? 'hidup' : 'mati'} mulai '
          '${bulanTahun(effectiveFrom.tahun, effectiveFrom.bulan)}',
      ref: RecordRef('rule', rule.name),
      before: '${kini?.on ?? false}',
      after: '$on',
      reason: v.reason,
    );
    return Ok(v);
  });

  @override
  Future<Result<LingkupLink>> addLingkup(
    Actor actor,
    String scopeId,
    Tanggal effectiveFrom, {
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Tambah Lingkup';
    final g = f.ctx.grant(actor, Capability.financeSettings, ScopeRef.jemaat);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeSettings, ScopeRef.jemaat);
    }
    final s = f.ctx.inti.scope(scopeId);
    if (s == null) return f.ctx.no(aksi, 'Lingkup belum dipilih.');
    if (f.k.lingkup.any((l) => l.scopeId == scopeId)) {
      return f.ctx.no(aksi, '${s.name} sudah menjadi Lingkup.');
    }
    // D24: the 1st of a month not yet running and not closed.
    final salah = effectiveFrom.hari != 1 || effectiveFrom <= f.today
        ? 'Hanya bulan yang belum ditutup dan belum berjalan.'
        : f.closedReason(effectiveFrom);
    if (salah != null) return f.ctx.no(aksi, salah);
    final l = LingkupLink(
      id: f.ctx.store.newId('lingkup'),
      scopeId: scopeId,
      activeFrom: effectiveFrom,
    );
    f.k.lingkup.add(l);
    f.audit(
      g,
      action: 'finance.lingkup.add',
      summary:
          'Menambah Lingkup ${s.name} · berlaku mulai '
          '${bulanTahun(effectiveFrom.tahun, effectiveFrom.bulan)}',
      ref: RecordRef('scope', scopeId),
    );
    return Ok(l);
  });
}
