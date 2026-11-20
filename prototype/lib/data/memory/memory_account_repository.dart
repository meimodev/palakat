import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../repositories/account_repository.dart';
import 'memory_finance.dart';

/// Kas/Bank and their balances; settings commands need finance.settings.
class MemoryAccountRepository implements AccountRepository {
  MemoryAccountRepository(this.f);
  final MemoryFinance f;

  @override
  List<Account> accounts({bool includeInactive = false}) => [
    for (final a in f.k.accounts)
      if (includeInactive || a.activeAt(f.today)) a,
  ];

  @override
  int balance(String accountId, {Tanggal? at}) =>
      f.k.accountBalance(accountId, at: at ?? f.today);

  @override
  Map<String, int> balanceByFund(String accountId, {Tanggal? at}) =>
      f.k.balanceByFund(accountId, at: at ?? f.today);

  /// The settings gate every command shares (finance.settings at Jemaat).
  Grant? _g(Actor actor) =>
      f.ctx.grant(actor, Capability.financeSettings, ScopeRef.jemaat);

  /// "berlaku mulai {bulan}" must be the 1st of a month not yet running.
  String? _bulanSalah(Tanggal d) => d.hari != 1 || d <= f.today
      ? 'Hanya bulan yang belum ditutup dan belum berjalan.'
      : f.closedReason(d);

  String _bulan(Tanggal d) => bulanTahun(d.tahun, d.bulan);

  /// P14: only a unit with a Bendahara unit in office gets a Kas/Bank.
  String? _unitSalah(String scopeId) {
    final unit = f.ctx.inti.scope(scopeId);
    if (unit == null || scopeId == ScopeRef.jemaatId) {
      return 'Unit belum dipilih.';
    }
    final ada = f.ctx.inti.posts.any(
      (p) =>
          p.scopeId == scopeId &&
          p.role == Role.bendaharaUnit &&
          f.ctx.inti.assignments.any(
            (a) =>
                a.postId == p.id &&
                a.status != AssignmentStatus.pending &&
                a.inForce(f.today),
          ),
    );
    return ada ? null : '${unit.name} belum punya bendahara unit.';
  }

  /// KasUnit's Riwayat line: '{nama} dikelola oleh {unit}, berlaku mulai …'.
  String _dikelola(String nama, String scopeId, Tanggal mulai) =>
      '$nama dikelola oleh ${f.ctx.inti.scope(scopeId)?.name ?? scopeId}, '
      'berlaku mulai ${_bulan(mulai)}';

  @override
  Future<Result<Account>> add(
    Actor actor,
    AccountDraft draft,
    Tanggal effectiveFrom, {
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Tambah Kas/Bank';
    final g = _g(actor);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeSettings, ScopeRef.jemaat);
    }
    final nama = draft.name.trim();
    if (nama.isEmpty) return f.ctx.no(aksi, 'Nama Kas/Bank belum diisi.');
    if (f.k.accounts.any((a) => a.name.toLowerCase() == nama.toLowerCase())) {
      return f.ctx.no(aksi, 'Nama Kas/Bank sudah dipakai.');
    }
    final unit = draft.operatedByScopeId;
    if (unit != null) {
      final salah = _unitSalah(unit);
      if (salah != null) return f.ctx.no(aksi, salah);
    }
    final salah = _bulanSalah(effectiveFrom);
    if (salah != null) return f.ctx.no(aksi, salah);
    final a = Account(
      id: f.ctx.store.newId('akun'),
      name: nama,
      shortName: draft.shortName.trim().isEmpty ? nama : draft.shortName,
      type: draft.type,
      institution: draft.institution,
      activeFrom: effectiveFrom,
      operatedByScopeId: unit,
    );
    f.k.accounts.add(a);
    f.audit(
      g,
      action: 'finance.account.add',
      summary: unit == null
          ? 'Menambah Kas/Bank $nama · berlaku mulai ${_bulan(effectiveFrom)}'
          : _dikelola(nama, unit, effectiveFrom),
      ref: RecordRef('account', a.id),
      after: unit,
    );
    return Ok(a);
  });

  @override
  Future<Result<Account>> deactivate(
    Actor actor,
    String id,
    Tanggal effectiveFrom, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Nonaktifkan Kas/Bank';
    final g = _g(actor);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeSettings, ScopeRef.jemaat);
    }
    final a = f.k.accounts.where((x) => x.id == id).firstOrNull;
    if (a == null) return f.ctx.no(aksi, 'Kas/Bank tidak ditemukan.');
    final basi = f.ctx.stale<Account>(a.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (a.activeTo != null) {
      return f.ctx.no(aksi, '${a.name} sudah dinonaktifkan.');
    }
    if (reason.trim().isEmpty) return f.ctx.no(aksi, 'Alasan belum diisi.');
    final salah = _bulanSalah(effectiveFrom);
    if (salah != null) return f.ctx.no(aksi, salah);
    a
      ..activeTo = effectiveFrom.tambahHari(-1)
      ..deactivationReason = reason.trim()
      ..revision += 1;
    f.audit(
      g,
      action: 'finance.account.deactivate',
      summary:
          'Menonaktifkan ${a.name} · berlaku mulai ${_bulan(effectiveFrom)}',
      ref: RecordRef('account', a.id),
      reason: reason.trim(),
    );
    return Ok(a);
  });

  /// The unit takes the account over from the 1st of a month not yet
  /// running (D24); until then its current operator keeps it.
  @override
  Future<Result<Account>> assignToUnit(
    Actor actor,
    String id,
    String scopeId,
    Tanggal effectiveFrom, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Serahkan ke unit';
    final g = _g(actor);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeSettings, ScopeRef.jemaat);
    }
    final a = f.k.accounts.where((x) => x.id == id).firstOrNull;
    if (a == null) return f.ctx.no(aksi, 'Kas/Bank tidak ditemukan.');
    final basi = f.ctx.stale<Account>(a.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    final unitSalah = _unitSalah(scopeId);
    if (unitSalah != null) return f.ctx.no(aksi, unitSalah);
    final salah = _bulanSalah(effectiveFrom);
    if (salah != null) return f.ctx.no(aksi, salah);
    if (a.activeTo != null && a.activeTo! < effectiveFrom) {
      return f.ctx.no(aksi, '${a.name} sudah nonaktif.');
    }
    if (a.operatorAt(effectiveFrom) == scopeId) {
      return f.ctx.no(
        aksi,
        '${a.name} sudah dikelola ${f.ctx.inti.scope(scopeId)!.name}.',
      );
    }
    // A takeover already in force today becomes the operator before this one.
    a
      ..operatedByScopeId = a.operatorAt(f.today)
      ..nextOperatorScopeId = scopeId
      ..nextOperatorFrom = effectiveFrom
      ..revision += 1;
    f.audit(
      g,
      action: 'finance.account.assign_unit',
      summary: _dikelola(a.name, scopeId, effectiveFrom),
      ref: RecordRef('account', a.id),
      before: a.operatedByScopeId ?? ScopeRef.jemaatId,
      after: scopeId,
    );
    return Ok(a);
  });
}
