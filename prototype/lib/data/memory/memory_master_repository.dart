import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../repositories/master_repository.dart';
import 'memory_finance.dart';

/// Mata Anggaran versions and rows (DM 5.5); commands need finance.settings.
class MemoryMasterRepository implements MasterRepository {
  MemoryMasterRepository(this.f);
  final MemoryFinance f;

  @override
  List<MasterVersion> versions(MasterKind kind) => [
    for (final v in f.k.masterVersions)
      if (v.kind == kind) v,
  ];

  @override
  List<MasterRow> rows(String versionId) =>
      f.k.masterRows.where((r) => r.versionId == versionId).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

  @override
  List<MasterRow> pickerRows(MasterKind kind, Tanggal date) {
    final berlaku =
        f.k.masterVersions
            .where(
              (v) =>
                  v.kind == kind &&
                  v.status == MasterVersionStatus.published &&
                  v.effectiveFrom != null &&
                  v.effectiveFrom! <= date,
            )
            .toList()
          ..sort((a, b) => a.effectiveFrom!.compareTo(b.effectiveFrom!));
    final v = berlaku.lastOrNull;
    return v == null ? const [] : rows(v.id);
  }

  Grant? _g(Actor actor) =>
      f.ctx.grant(actor, Capability.financeSettings, ScopeRef.jemaat);

  Refused<T> _tolak<T>(Actor actor) =>
      f.ctx.refuse(actor, Capability.financeSettings, ScopeRef.jemaat);

  MasterVersion? _versi(String id) =>
      f.k.masterVersions.where((v) => v.id == id).firstOrNull;

  /// The 1st of M+1.
  Tanggal get _bulanDepan {
    final t = f.today;
    return t.bulan == 12
        ? Tanggal(t.tahun + 1, 1, 1)
        : Tanggal(t.tahun, t.bulan + 1, 1);
  }

  String _bulan(Tanggal d) => bulanTahun(d.tahun, d.bulan);

  /// The published version of [kind] effective last; null when none.
  MasterVersion? _terbitTerakhir(MasterKind kind) =>
      (versions(kind)
            .where((v) => v.status == MasterVersionStatus.published)
            .toList()
          ..sort((a, b) => a.effectiveFrom!.compareTo(b.effectiveFrom!)))
          .lastOrNull;

  /// The first month a new version of [kind] may take effect: M+1, or the
  /// month after the last published one when that is later (no two
  /// versions of one kind from the same month, DM §3 MasterVersion).
  Tanggal _bulanBoleh(MasterKind kind) {
    final t = _terbitTerakhir(kind)?.effectiveFrom;
    if (t == null || t < _bulanDepan) return _bulanDepan;
    final x = t.tambahHari(31);
    return Tanggal(x.tahun, x.bulan, 1);
  }

  /// A row change returns a reviewed version to DRAFT (DM 5.5).
  Result<MasterRow>? _bolehUbah(MasterVersion? v, int rev, String aksi) {
    if (v == null) return f.ctx.no(aksi, 'Versi tidak ditemukan.');
    if (v.status == MasterVersionStatus.published) {
      return f.ctx.no(
        aksi,
        'Versi ${v.code} sudah diterbitkan dan tidak dapat diubah.',
      );
    }
    return f.ctx.stale<MasterRow>(v.revision, rev, aksi);
  }

  void _keDraf(MasterVersion v) {
    v
      ..status = MasterVersionStatus.draft
      ..reviewedBy = null
      ..reviewedAt = null
      ..revision += 1;
  }

  @override
  Future<Result<MasterVersion>> createDraftVersion(
    Actor actor,
    MasterKind kind, {
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Buat versi baru';
    final g = _g(actor);
    if (g == null) return _tolak(actor);
    final semua = versions(kind);
    if (semua.any((v) => v.status != MasterVersionStatus.published)) {
      return f.ctx.no(aksi, 'Masih ada versi yang belum diterbitkan.');
    }
    final dasar = semua.lastOrNull;
    final mulai = _bulanBoleh(kind);
    final (th, no) = dasar == null
        ? (mulai.tahun, 0)
        : (
            int.parse(dasar.code.split('.').first),
            int.parse(dasar.code.split('.').last),
          );
    final kode = th == mulai.tahun ? '$th.${no + 1}' : '${mulai.tahun}.1';
    final v = MasterVersion(
      id: '${kind.name}-$kode',
      kind: kind,
      code: kode,
      status: MasterVersionStatus.draft,
      effectiveFrom: mulai,
      createdBy: actor.personId,
      createdAt: f.now,
    );
    f.k.masterVersions.add(v);
    if (dasar != null) {
      for (final r in rows(dasar.id)) {
        f.k.masterRows.add(
          MasterRow(
            versionId: v.id,
            code: r.code,
            name: r.name,
            order: r.order,
            parentCode: r.parentCode,
            level: r.level,
            postable: r.postable,
            allowedEffect: r.allowedEffect,
            active: r.active,
          ),
        );
      }
    }
    f.audit(
      g,
      action: 'finance.master.draft',
      summary:
          'Membuat versi Mata Anggaran $kode · usulan berlaku mulai ${_bulan(mulai)}',
      ref: RecordRef('master', v.id),
    );
    return Ok(v);
  });

  @override
  Future<Result<MasterRow>> editRow(
    Actor actor,
    String versionId,
    MasterRow row, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Ubah baris';
    final g = _g(actor);
    if (g == null) return _tolak(actor);
    final v = _versi(versionId);
    final no = _bolehUbah(v, expectedRevision, aksi);
    if (no != null) return no;
    if (row.code.trim().isEmpty || row.name.trim().isEmpty) {
      return f.ctx.no(aksi, 'Kode dan nama baris belum diisi.');
    }
    final ada = rows(versionId).where((r) => r.code == row.code).firstOrNull;
    final MasterRow baru;
    if (ada != null) {
      ada
        ..name = row.name.trim()
        ..postable = row.postable
        ..allowedEffect = row.allowedEffect
        ..active = row.active
        ..revision += 1;
      baru = ada;
    } else {
      baru = MasterRow(
        versionId: versionId,
        code: row.code.trim(),
        name: row.name.trim(),
        order: rows(versionId).length + 1,
        parentCode: row.parentCode,
        level: row.level,
        postable: row.postable,
        allowedEffect: row.allowedEffect,
        active: row.active,
      );
      f.k.masterRows.add(baru);
    }
    _keDraf(v!);
    f.audit(
      g,
      action: 'finance.master.row',
      summary: 'Mengubah baris ${baru.code} ${baru.name} di versi ${v.code}',
      ref: RecordRef('master', v.id),
    );
    return Ok(baru);
  });

  @override
  Future<Result<MasterRow>> setAllowedEffect(
    Actor actor,
    String versionId,
    String code,
    AllowedEffect effects, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Ubah boleh untuk';
    final g = _g(actor);
    if (g == null) return _tolak(actor);
    final v = _versi(versionId);
    final no = _bolehUbah(v, expectedRevision, aksi);
    if (no != null) return no;
    final r = rows(versionId).where((r) => r.code == code).firstOrNull;
    if (r == null || !r.postable) {
      return f.ctx.no(aksi, 'Judul kelompok tidak dapat dibukukan.');
    }
    final sebelum = r.allowedEffect;
    r
      ..allowedEffect = effects
      ..revision += 1;
    _keDraf(v!);
    f.audit(
      g,
      action: 'finance.master.allowed_effect',
      summary: 'Boleh untuk ${r.code} ${r.name} di versi ${v.code}',
      ref: RecordRef('master', v.id),
      before: sebelum.name,
      after: effects.name,
    );
    return Ok(r);
  });

  @override
  Future<Result<MasterVersion>> review(
    Actor actor,
    String versionId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Tandai sudah diperiksa';
    final g = _g(actor);
    if (g == null) return _tolak(actor);
    final v = _versi(versionId);
    if (v == null) return f.ctx.no(aksi, 'Versi tidak ditemukan.');
    final basi = f.ctx.stale<MasterVersion>(v.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (v.status != MasterVersionStatus.draft) {
      return f.ctx.no(aksi, 'Versi ${v.code} bukan draf.');
    }
    v
      ..status = MasterVersionStatus.reviewed
      ..reviewedBy = actor.personId
      ..reviewedAt = f.now
      ..revision += 1;
    f.audit(
      g,
      action: 'finance.master.review',
      summary:
          'Menandai versi Mata Anggaran ${v.code} (${v.kind.name}) sudah diperiksa',
      ref: RecordRef('master', v.id),
    );
    return Ok(v);
  });

  @override
  Future<Result<MasterVersion>> publish(
    Actor actor,
    String versionId,
    Tanggal effectiveFrom, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Terbitkan';
    final g = _g(actor);
    if (g == null) return _tolak(actor);
    final v = _versi(versionId);
    if (v == null) return f.ctx.no(aksi, 'Versi tidak ditemukan.');
    final basi = f.ctx.stale<MasterVersion>(v.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (v.status != MasterVersionStatus.reviewed) {
      return f.ctx.no(aksi, 'Versi ${v.code} belum ditandai sudah diperiksa.');
    }
    final boleh = _bulanBoleh(v.kind);
    if (effectiveFrom.hari != 1 || effectiveFrom < boleh) {
      return f.ctx.no(
        aksi,
        boleh == _bulanDepan
            ? 'Versi baru berlaku mulai bulan berikutnya, ${_bulan(boleh)}.'
            : 'Versi baru berlaku paling cepat mulai ${_bulan(boleh)}.',
      );
    }
    v
      ..status = MasterVersionStatus.published
      ..effectiveFrom = effectiveFrom
      ..publishedBy = actor.personId
      ..publishedAt = f.now
      ..revision += 1;
    f.audit(
      g,
      action: 'finance.master.publish',
      summary:
          'Menerbitkan versi Mata Anggaran ${v.code} (${v.kind.name}) · '
          'berlaku mulai ${_bulan(effectiveFrom)}',
      ref: RecordRef('master', v.id),
    );
    return Ok(v);
  });
}
