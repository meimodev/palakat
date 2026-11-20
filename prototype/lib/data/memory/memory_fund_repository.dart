import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../repositories/fund_repository.dart';
import 'memory_finance.dart';

/// Peruntukan, filtered for a Fund-only viewer (README 3.5).
class MemoryFundRepository implements FundRepository {
  MemoryFundRepository(this.f);
  final MemoryFinance f;

  /// Active today or starting later ("berlaku mulai {M+1}"), not ended.
  @override
  List<Fund> funds() {
    final boleh = f.visibleFundIds();
    return [
      for (final x in f.k.funds)
        if ((boleh == null || boleh.contains(x.id)) &&
            (x.activeTo == null || x.activeTo! >= f.today))
          x,
    ];
  }

  @override
  Fund? fund(String id) {
    final boleh = f.visibleFundIds();
    if (boleh != null && !boleh.contains(id)) return null;
    return f.k.fund(id);
  }

  @override
  int balance(String fundId, {Tanggal? at}) {
    final boleh = f.visibleFundIds();
    if (boleh != null && !boleh.contains(fundId)) return 0;
    return f.k.fundBalance(fundId, at: at ?? f.today);
  }

  @override
  int ownedBalance(String? ownerScopeId) => [
    for (final x in f.k.funds)
      if (ownerScopeId == null || x.ownerScopeId == ownerScopeId)
        f.k.fundBalance(x.id, at: f.today),
  ].fold(0, (a, b) => a + b);

  @override
  Future<Result<Fund>> add(
    Actor actor,
    FundDraft draft,
    Tanggal effectiveFrom, {
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Tambah peruntukan';
    final g = f.ctx.grant(actor, Capability.financeSettings, ScopeRef.jemaat);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeSettings, ScopeRef.jemaat);
    }
    final nama = draft.name.trim();
    if (nama.isEmpty) return f.ctx.no(aksi, 'Nama peruntukan belum diisi.');
    if (f.k.funds.any((x) => x.name.toLowerCase() == nama.toLowerCase())) {
      return f.ctx.no(aksi, 'Nama peruntukan sudah dipakai.');
    }
    if (f.ctx.inti.scope(draft.ownerScopeId) == null) {
      return f.ctx.no(aksi, 'Pemilik peruntukan belum dipilih.');
    }
    if (effectiveFrom < f.today) {
      return f.ctx.no(aksi, 'Tanggal berlaku tidak boleh sebelum hari ini.');
    }
    final x = Fund(
      id: f.ctx.store.newId('dana'),
      name: nama,
      ownerScopeId: draft.ownerScopeId,
      activeFrom: effectiveFrom,
      restriction: draft.restriction,
      preparerPersonId: draft.preparerPersonId,
    );
    f.k.funds.add(x);
    f.audit(
      g,
      action: 'finance.fund.add',
      summary:
          'Menambah peruntukan $nama · berlaku mulai '
          '${bulanTahun(effectiveFrom.tahun, effectiveFrom.bulan)}',
      ref: RecordRef('fund', x.id),
    );
    return Ok(x);
  });
}
