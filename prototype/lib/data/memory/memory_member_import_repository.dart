import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';
import '../repositories/member_import_repository.dart';
import 'memory_jemaat.dart';

class MemoryMemberImportRepository implements MemberImportRepository {
  MemoryMemberImportRepository(this.j);
  final MemoryJemaat j;

  @override
  List<ImportBatch> batches() => List.unmodifiable(j.t.batches);

  @override
  List<DuplicateCase> duplicates() => List.unmodifiable(j.t.duplicates);

  ImportBatch? _batch(String id) =>
      j.t.batches.where((b) => b.id == id).firstOrNull;

  Grant? _grant(Actor actor) =>
      j.ctx.grant(actor, Capability.membershipImport, ScopeRef.jemaat);

  Refused<T> _tolak<T>(Actor actor) =>
      j.ctx.refuse(actor, Capability.membershipImport, ScopeRef.jemaat);

  @override
  Future<Result<ImportBatch>> stage(
    Actor actor,
    SampleBook book, {
    required String idempotencyKey,
  }) => j.ctx.command(idempotencyKey, () {
    final g = _grant(actor);
    if (g == null) return _tolak(actor);
    final b = ImportBatch(
      id: j.ctx.store.newId('buku'),
      source: book.source,
      kolomId: book.kolomId,
      rows: book.rows,
    );
    j.t.batches.add(b);
    j.ctx.audit(
      g,
      action: 'membership.import.stage',
      summary: '${b.source} ditampung · ${b.rows.length} baris',
      module: Module.membership,
      ref: RecordRef('member_import', b.id),
    );
    return Ok(b);
  });

  @override
  Future<Result<ImportBatch>> check(
    Actor actor,
    String batchId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => j.ctx.command(idempotencyKey, () {
    const aksi = 'Jalankan pengecekan';
    final g = _grant(actor);
    if (g == null) return _tolak(actor);
    final b = _batch(batchId);
    if (b == null) return j.ctx.no(aksi, 'Buku tidak ditemukan.');
    if (b.status != ImportStatus.staged) {
      return j.ctx.no(aksi, 'buku ini sudah diperiksa.');
    }
    final basi = j.ctx.stale<ImportBatch>(b.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    for (final r in b.rows) {
      if (r.yearMissing) {
        r.status = RowStatus.incomplete;
      } else if (r.birthDate == null) {
        r
          ..status = RowStatus.refused
          ..note =
              'Tidak diimpor: tanggal lahir wajib. Dicatat dengan '
              'alasannya.';
      } else if (r.personId == null) {
        final sama = _samaDengan(r);
        if (sama != null) {
          r
            ..status = RowStatus.duplicate
            ..note =
                'Kemungkinan data ganda: sudah ada ${sama.name}, '
                '${_status(sama)}';
          j.t.duplicates.add(
            DuplicateCase(
              id: j.ctx.store.newId('ganda'),
              batchId: b.id,
              rowId: r.id,
              existingPersonId: sama.id,
            ),
          );
        }
      }
    }
    b
      ..status = ImportStatus.checked
      ..revision += 1;
    j.ctx.audit(
      g,
      action: 'membership.import.check',
      summary: '${b.source} lolos pengecekan',
      module: Module.membership,
      ref: RecordRef('member_import', b.id),
    );
    return Ok(b);
  });

  String _status(Person p) => switch (p.status) {
    PersonStatus.active => 'Aktif',
    PersonStatus.unconfirmed => 'Belum dikonfirmasi',
    PersonStatus.deceased => 'Meninggal dunia',
  };

  /// A member already in Data jemaat with the same name and birth date.
  Person? _samaDengan(ImportRow r) {
    for (final p in j.t.profiles.keys) {
      final o = j.ctx.inti.person(p);
      if (o != null &&
          o.name.toLowerCase() == r.name.toLowerCase() &&
          o.birthDate == r.birthDate) {
        return o;
      }
    }
    return null;
  }

  @override
  Future<Result<void>> completeRow(
    Actor actor,
    String batchId,
    String rowId,
    Tanggal birthDate, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => j.ctx.command(idempotencyKey, () {
    const aksi = 'Impor';
    final g = _grant(actor);
    if (g == null) return _tolak(actor);
    final b = _batch(batchId);
    final r = b?.rows.where((x) => x.id == rowId).firstOrNull;
    if (b == null || r == null) return j.ctx.no(aksi, 'Baris tidak ditemukan.');
    if (!(birthDate < j.today)) {
      return j.ctx.no(aksi, 'tanggal lahir harus sebelum hari ini.');
    }
    final basi = j.ctx.stale<void>(b.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    r
      ..birthDate = birthDate
      ..yearMissing = false
      ..status = RowStatus.ok;
    b.revision += 1;
    j.ctx.audit(
      g,
      action: 'membership.import.complete',
      summary: 'Tanggal lahir ${r.name} dilengkapi',
      module: Module.membership,
      ref: RecordRef('member_import', b.id),
    );
    return const Ok(null);
  });

  @override
  Future<Result<void>> resolveDuplicate(
    Actor actor,
    String caseId,
    DuplicateDecision decision, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => j.ctx.command(idempotencyKey, () {
    final aksi = decision == DuplicateDecision.merge
        ? 'Gabungkan'
        : 'Bukan orang yang sama';
    final g = _grant(actor);
    if (g == null) return _tolak(actor);
    final c = j.t.duplicates.where((d) => d.id == caseId).firstOrNull;
    if (c == null) return j.ctx.no(aksi, 'Data tidak ditemukan.');
    if (c.status != DuplicateStatus.open) {
      return j.ctx.no(aksi, 'sudah diputuskan.');
    }
    if (reason.trim().isEmpty) return j.ctx.no(aksi, 'alasan belum diisi.');
    final basi = j.ctx.stale<void>(c.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    final b = _batch(c.batchId)!;
    final r = b.rows.firstWhere((x) => x.id == c.rowId);
    if (decision == DuplicateDecision.merge) {
      r
        ..personId = c.existingPersonId
        ..status = RowStatus.merged
        ..note = 'Digabung dengan data yang sudah ada.';
      c.status = DuplicateStatus.merged;
    } else {
      r
        ..status = RowStatus.ok
        ..note = null;
      c.status = DuplicateStatus.notSame;
      if (b.status == ImportStatus.imported) _impor(b, r);
    }
    c
      ..decidedBy = actor.personId
      ..decidedAt = j.ctx.now
      ..reason = reason.trim()
      ..revision += 1;
    b.revision += 1;
    j.ctx.audit(
      g,
      action: 'membership.duplicate.resolve',
      summary: '${r.name}: $aksi',
      module: Module.membership,
      ref: RecordRef('duplicate', c.id),
      reason: reason.trim(),
    );
    return const Ok(null);
  });

  @override
  Future<Result<ImportBatch>> commit(
    Actor actor,
    String batchId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => j.ctx.command(idempotencyKey, () {
    const aksi = 'Impor';
    final g = _grant(actor);
    if (g == null) return _tolak(actor);
    final b = _batch(batchId);
    if (b == null) return j.ctx.no(aksi, 'Buku tidak ditemukan.');
    if (b.status != ImportStatus.checked) {
      return j.ctx.no(
        aksi,
        b.status == ImportStatus.staged
            ? 'pengecekan belum dijalankan.'
            : 'buku ini sudah diimpor.',
      );
    }
    final kurang = b.rows
        .where((r) => r.status == RowStatus.incomplete)
        .firstOrNull;
    if (kurang != null) {
      return j.ctx.no(aksi, 'tanggal lahir ${kurang.name} belum lengkap.');
    }
    if (b.rows.any((r) => r.status == RowStatus.duplicate)) {
      return j.ctx.no(aksi, 'kemungkinan data ganda belum diputuskan.');
    }
    final basi = j.ctx.stale<ImportBatch>(b.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    for (final r in b.rows) {
      if (r.status == RowStatus.ok || r.status == RowStatus.merged) {
        _impor(b, r);
      }
    }
    b
      ..status = ImportStatus.imported
      ..importedAt = j.ctx.now
      ..importedBy = actor.personId
      ..revision += 1;
    final n = b.rows.where((r) => r.status == RowStatus.imported).length;
    j.ctx.audit(
      g,
      action: 'membership.import.commit',
      summary: '${b.source} diimpor: $n orang',
      module: Module.membership,
      ref: RecordRef('member_import', b.id),
    );
    return Ok(b);
  });

  /// One row into Data jemaat: its person (new, UNCONFIRMED, unless the row
  /// is a known person), its profile, its family.
  void _impor(ImportBatch b, ImportRow r) {
    final inti = j.ctx.inti;
    final gabung = r.status == RowStatus.merged;
    var id = r.personId;
    if (id == null) {
      id = j.ctx.store.newId('anggota-impor');
      inti.addPerson(
        Person(
          id: id,
          name: r.name,
          status: PersonStatus.unconfirmed,
          birthDate: r.birthDate,
          sex: r.sex,
        ),
      );
      r.personId = id;
    }
    final o = inti.person(id)!;
    if (o.birthDate == null && r.birthDate != null) o.birthDate = r.birthDate;
    j.t.profiles.putIfAbsent(
      id,
      () => MemberProfile(
        personId: id!,
        kolom: [KolomStint(kolomId: r.kolomId, start: j.today)],
        marital: r.marital,
        importBatchId: b.id,
        importLine: r.line,
        importedAt: j.ctx.now,
      ),
    );
    final kunci = r.householdKey;
    if (kunci != null && !gabung) {
      final h = j.t.households.putIfAbsent(
        kunci,
        () => Household(
          id: kunci,
          name: r.name.split(' ').last,
          kolomId: r.kolomId,
          memberIds: [],
          representativeId: id,
          status: HouseholdStatus.unconfirmed,
          importedAt: j.ctx.now,
        ),
      );
      j.join(h, id);
      if (o.status == PersonStatus.unconfirmed &&
          h.status != HouseholdStatus.unconfirmed) {
        h
          ..status = HouseholdStatus.unconfirmed
          ..importedAt = j.ctx.now
          ..revision += 1;
      }
    }
    if (!gabung) r.status = RowStatus.imported;
  }
}
