import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../repositories/recovery_repository.dart';
import 'memory_context.dart';

/// Account recovery in memory (P4), on the core table `recoveries`.
class MemoryRecoveryRepository implements RecoveryRepository {
  MemoryRecoveryRepository(this.ctx);
  final MemoryContext ctx;
  List<AccountRecovery> get _rows => ctx.inti.recoveries;

  @override
  List<AccountRecovery> recoveries() => _rows.reversed.toList();

  @override
  String? confirmingScope(String personId) =>
      ctx.store.jemaat.profiles[personId]?.kolomAt(ctx.today);

  @override
  Future<Result<AccountRecovery>> request(
    Actor actor,
    String personId,
    String newPhone, {
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Minta kepastian Penatua Kolom';
    final g = ctx.grant(actor, Capability.recoverAccount, ScopeRef.jemaat);
    if (g == null) {
      return ctx.refuse(actor, Capability.recoverAccount, ScopeRef.jemaat);
    }
    final p = ctx.inti.person(personId);
    if (p == null || p.isSystem) {
      return ctx.no(aksi, 'orangnya belum ditemukan.');
    }
    if (personId == actor.personId) {
      return ctx.no(aksi, 'Operator tidak memulihkan akunnya sendiri.');
    }
    if (!hpSah(newPhone)) {
      return ctx.no(aksi, 'nomor ponsel tidak dikenali.');
    }
    final kolom = confirmingScope(personId);
    if (kolom == null) {
      return ctx.no(aksi, 'Kolom orang ini belum tercatat di Data jemaat.');
    }
    if (_rows.any(
      (r) => r.personId == personId && r.status == RecoveryStatus.waiting,
    )) {
      return ctx.no(aksi, 'pemulihan akun orang ini masih menunggu.');
    }
    final r = AccountRecovery(
      id: ctx.store.newId('pulih'),
      personId: personId,
      newPhone: newPhone,
      scopeId: kolom,
      requestedBy: actor.personId,
      requestedAt: ctx.now,
    );
    _rows.add(r);
    ctx.audit(
      g,
      action: 'core.recovery.request',
      summary:
          'Pemulihan akun ${p.name} diminta · nomor baru ${samarHp(newPhone)}',
      ref: RecordRef('recovery', r.id),
    );
    for (final o in ctx.can.whoCan(
      Capability.confirmRecovery,
      ScopeRef(kolom),
      at: ctx.today,
    )) {
      ctx.notify(
        o.id,
        title: 'Pemulihan akun · ${p.name}',
        body: 'Diminta ${ctx.personName(actor.personId)}, Operator',
        type: NotificationType.action,
        ref: RecordRef('recovery', r.id),
      );
    }
    return Ok(r);
  });

  Result<AccountRecovery> _decide(
    Actor actor,
    String recoveryId,
    int expectedRevision,
    RecoveryStatus status,
  ) {
    const aksi = 'Pastikan identitas';
    final r = _rows.where((x) => x.id == recoveryId).firstOrNull;
    if (r == null) return ctx.no(aksi, 'Pemulihan tidak ditemukan.');
    final lingkup = ScopeRef(r.scopeId);
    final g = ctx.grant(actor, Capability.confirmRecovery, lingkup);
    if (g == null) {
      return ctx.refuse(actor, Capability.confirmRecovery, lingkup);
    }
    final basi = ctx.stale<AccountRecovery>(r.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (r.status != RecoveryStatus.waiting) {
      return ctx.no(aksi, 'Pemulihan ini sudah diputuskan.');
    }
    if (actor.personId == r.requestedBy || actor.personId == r.personId) {
      return ctx.no(aksi, 'Anda tidak dapat memastikan pemulihan ini sendiri.');
    }
    final p = ctx.inti.person(r.personId)!;
    r
      ..status = status
      ..decidedBy = actor.personId
      ..decidedAt = ctx.now
      ..revision += 1;
    final pulih = status == RecoveryStatus.recovered;
    if (pulih) {
      p
        ..phone = r.newPhone
        ..revision += 1;
      for (final d in ctx.inti.devices) {
        if (d.personId == p.id && d.endedAt == null) {
          d
            ..endedAt = ctx.now
            ..revision += 1;
        }
      }
    }
    ctx.audit(
      g,
      action: pulih ? 'core.recovery.confirm' : 'core.recovery.decline',
      summary: pulih
          ? 'Identitas ${p.name} dipastikan · akun dipulihkan'
          : 'Identitas tidak dipastikan · pemulihan akun ${p.name} tidak '
                'dijalankan',
      ref: RecordRef('recovery', r.id),
    );
    ctx.notify(
      r.requestedBy,
      title: pulih
          ? 'Akun ${p.name} dipulihkan'
          : 'Pemulihan akun ${p.name} tidak dijalankan',
      body: 'Oleh ${ctx.personName(actor.personId)}',
      ref: RecordRef('recovery', r.id),
    );
    return Ok(r);
  }

  @override
  Future<Result<AccountRecovery>> confirm(
    Actor actor,
    String recoveryId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(
    idempotencyKey,
    () =>
        _decide(actor, recoveryId, expectedRevision, RecoveryStatus.recovered),
  );

  @override
  Future<Result<AccountRecovery>> decline(
    Actor actor,
    String recoveryId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(
    idempotencyKey,
    () => _decide(
      actor,
      recoveryId,
      expectedRevision,
      RecoveryStatus.notConfirmed,
    ),
  );
}
