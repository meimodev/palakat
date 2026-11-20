import '../../core/format.dart';
import '../../domain/collaboration/collaboration.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../domain/secretariat/secretariat.dart';
import '../repositories/document_repository.dart';
import '../repositories/org_repository.dart';
import '../repositories/panitia_repository.dart';
import 'memory_context.dart';
import 'memory_kolaborasi.dart';

/// Panitia (DL27): the authorized church officer creates and moves it; the
/// church Bendahara approves its leftover's destination. Its money is the
/// ledger's (DP27): its own Fund plus the advances issued to its scope.
class MemoryPanitiaRepository implements PanitiaRepository {
  MemoryPanitiaRepository(this.ctx, this._org, this._documents);

  final MemoryContext ctx;
  final OrgRepository _org;
  final DocumentRepository _documents;

  static const _ref = 'panitia';

  @override
  List<Panitia> list() => List.unmodifiable(ctx.kol.panitia);

  @override
  Panitia? get(String id) => ctx.kol.panitiaById(id);

  @override
  PanitiaMoney money(String id) {
    final p = get(id);
    final k = ctx.store.keuangan;
    var advanced = 0, settled = 0, returned = 0, outstanding = 0;
    final ids = <String>[];
    if (p != null) {
      for (final c in k.cases) {
        if (c.kind != CaseKind.advance || c.scopeId != p.scopeId) continue;
        ids.add(c.id);
        final v = k.caseView(c, ctx.today);
        advanced += v.amount;
        outstanding += v.outstanding;
        for (final t in v.entries) {
          for (final e in effectsOf(t)) {
            if (e.allocation.caseId != c.id) continue;
            if (e.type == TransactionType.advanceReturn) {
              returned -= e.caseDelta;
            } else if (e.type == TransactionType.advanceSpending) {
              settled -= e.caseDelta;
            }
          }
        }
      }
    }
    final fundId = p?.fundId;
    return PanitiaMoney(
      fundBalance: fundId == null ? 0 : k.fundBalance(fundId, at: ctx.today),
      advanceIds: ids,
      advanced: advanced,
      settled: settled,
      returned: returned,
      outstanding: outstanding,
    );
  }

  void _notifyOfficers(Panitia p, String title, String body, String except) {
    final o = p.officers;
    if (o == null) return;
    for (final id in {o.ketuaId, o.sekretarisId, o.bendaharaId}) {
      if (id == except) continue;
      ctx.notify(
        id,
        title: title,
        body: body,
        module: Module.panitia,
        ref: RecordRef(_ref, p.id),
      );
    }
  }

  @override
  Future<Result<Panitia>> create(
    Actor actor,
    String name,
    String skDocumentId,
    PanitiaOfficers officers, {
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Bentuk Panitia';
    final g = ctx.grant(actor, Capability.panitiaCreate, ScopeRef.jemaat);
    if (g == null) {
      return ctx.refuse(actor, Capability.panitiaCreate, ScopeRef.jemaat);
    }
    final nama = name.trim();
    if (nama.isEmpty) return ctx.no(aksi, 'nama Panitia belum diisi.');
    for (final id in [
      officers.ketuaId,
      officers.sekretarisId,
      officers.bendaharaId,
    ]) {
      if (ctx.inti.person(id) == null) {
        return ctx.no(aksi, 'pengurus belum dipilih.');
      }
    }
    if (!officers.distinct) {
      return ctx.no(
        aksi,
        'Ketua, Sekretaris dan Bendahara harus tiga orang yang berbeda.',
      );
    }
    if (officers.ketuaId == actor.personId ||
        officers.sekretarisId == actor.personId ||
        officers.bendaharaId == actor.personId) {
      return ctx.no(
        aksi,
        'Anda tidak dapat menugaskan jabatan kepada diri sendiri.',
      );
    }
    final sk = _documents.get(skDocumentId);
    if (sk == null || sk.kind != DocumentKind.decision) {
      return ctx.no(
        aksi,
        'pembentukan Panitia memerlukan keputusan tertulis gereja di '
        'Dokumen gereja.',
      );
    }
    final key = '$idempotencyKey/lingkup';
    _org.createScope(
      actor,
      ScopeDraft(type: ScopeType.panitia, name: nama),
      idempotencyKey: key,
    );
    // The command body ran at once; its result is in the log.
    final lingkup = ctx.store.idempotencyLog[key]! as Result<Scope>;
    if (lingkup is! Ok<Scope>) return Refused(lingkup.refusal!);
    // DL26/DL29: its officers hold its posts from the decision on (no
    // Panitia post needs an authority grant), so its Ketua approves its
    // requests and its Bendahara books its unit finance.
    for (final (peran, jabatan, orang) in [
      (Role.ketuaPanitia, 'Ketua', officers.ketuaId),
      (Role.sekretarisPanitia, 'Sekretaris', officers.sekretarisId),
      (Role.bendaharaUnit, 'Bendahara', officers.bendaharaId),
    ]) {
      final post = Post(
        id: ctx.store.newId('jabatan'),
        role: peran,
        scopeId: lingkup.value.id,
        title: '$jabatan $nama',
      );
      ctx.inti.posts.add(post);
      ctx.inti.assignments.add(
        Assignment(
          id: ctx.store.newId('tugas'),
          postId: post.id,
          personId: orang,
          start: ctx.today,
          status: AssignmentStatus.active,
          documentRef: sk.title,
          recordedBy: actor.personId,
          recordedAt: ctx.now,
        ),
      );
    }
    final p = Panitia(
      id: ctx.store.newId('panitia'),
      scopeId: lingkup.value.id,
      name: nama,
      stage: PanitiaStage.planning,
      skDocumentId: sk.id,
      officers: officers,
      createdBy: actor.personId,
      createdAt: ctx.now,
      history: [
        PanitiaStageChange(
          stage: PanitiaStage.planning,
          by: actor.personId,
          at: ctx.now,
        ),
      ],
    );
    ctx.kol.panitia.add(p);
    ctx.audit(
      g,
      action: 'panitia.create',
      summary:
          '$nama dibentuk · Ketua ${ctx.personName(officers.ketuaId)}, '
          'Sekretaris ${ctx.personName(officers.sekretarisId)}, Bendahara '
          '${ctx.personName(officers.bendaharaId)} · ${sk.title}',
      module: Module.panitia,
      ref: RecordRef(_ref, p.id),
    );
    return Ok(p);
  });

  @override
  Future<Result<Panitia>> advanceStage(
    Actor actor,
    String id, {
    String? reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    final p = get(id);
    final ke = p?.stage.next;
    final aksi = switch (ke) {
      PanitiaStage.active => 'Aktifkan Panitia',
      PanitiaStage.financialClosing => 'Mulai penutupan keuangan',
      PanitiaStage.closed => 'Tutup Panitia',
      PanitiaStage.retired => 'Arsipkan',
      _ => 'Ubah tahap',
    };
    final g = ctx.grant(actor, Capability.panitiaStage, ScopeRef.jemaat);
    if (g == null) {
      return ctx.refuse(actor, Capability.panitiaStage, ScopeRef.jemaat);
    }
    if (p == null) return ctx.no(aksi, 'Panitia tidak ditemukan.');
    final basi = ctx.stale<Panitia>(p.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (ke == null) return ctx.no(aksi, 'Panitia ini sudah diarsipkan.');
    final k = ctx.store.keuangan;
    if (ke == PanitiaStage.closed) {
      // AlurPanitia's order of reasons.
      final m = money(p.id);
      if (m.outstanding > 0) {
        return ctx.no(
          aksi,
          'masih ada Uang Muka yang belum dipertanggungjawabkan.',
        );
      }
      if (m.fundBalance != 0 || !p.leftoverApproved) {
        return ctx.no(aksi, 'sisa uang Panitia belum dikembalikan.');
      }
    }
    if (ke == PanitiaStage.active && p.fundId == null) {
      // AlurPanitiaBaru: its peruntukan is created on activation.
      final f = Fund(
        id: ctx.store.newId('peruntukan'),
        name: p.name,
        ownerScopeId: p.scopeId,
        activeFrom: ctx.today,
      );
      k.funds.add(f);
      p.fundId = f.id;
    }
    if (ke == PanitiaStage.closed) {
      // "dinonaktifkan untuk transaksi baru".
      k.fund(p.fundId)?.activeTo = ctx.today;
      ctx.inti.scope(p.scopeId)?.active = false;
    }
    final alasan = reason?.trim();
    p
      ..stage = ke
      ..history.add(
        PanitiaStageChange(
          stage: ke,
          by: actor.personId,
          at: ctx.now,
          reason: alasan == null || alasan.isEmpty ? null : alasan,
        ),
      )
      ..revision += 1;
    ctx.audit(
      g,
      action: 'panitia.stage',
      summary: ke == PanitiaStage.active
          ? '${p.name} Aktif · peruntukan dibuat'
          : '${p.name} ${ke.label}',
      module: Module.panitia,
      ref: RecordRef(_ref, p.id),
      reason: alasan == null || alasan.isEmpty ? null : alasan,
    );
    _notifyOfficers(
      p,
      '${p.name}: ${ke.label}',
      'Tahap diubah oleh ${ctx.personName(actor.personId)}',
      actor.personId,
    );
    return Ok(p);
  });

  @override
  Future<Result<Panitia>> approveLeftover(
    Actor actor,
    String id,
    String destinationFundId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Setujui sisa uang';
    final g = ctx.grant(
      actor,
      Capability.panitiaApproveLeftover,
      ScopeRef.jemaat,
    );
    if (g == null) {
      return ctx.refuse(
        actor,
        Capability.panitiaApproveLeftover,
        ScopeRef.jemaat,
      );
    }
    final p = get(id);
    if (p == null) return ctx.no(aksi, 'Panitia tidak ditemukan.');
    final basi = ctx.stale<Panitia>(p.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (p.stage != PanitiaStage.financialClosing) {
      return ctx.no(aksi, 'hanya pada tahap Penutupan keuangan.');
    }
    if (p.leftoverApproved) {
      return ctx.no(aksi, 'tujuan sisa uang sudah disetujui.');
    }
    final tujuan = ctx.store.keuangan.fund(destinationFundId);
    if (tujuan == null || tujuan.id == p.fundId) {
      return ctx.no(aksi, 'peruntukan tujuan belum dipilih.');
    }
    final m = money(p.id);
    if (m.outstanding > 0) {
      return ctx.no(
        aksi,
        'masih ada Uang Muka yang belum dipertanggungjawabkan.',
      );
    }
    p
      ..leftoverFundId = tujuan.id
      ..leftoverAmount = m.fundBalance + m.returned
      ..leftoverApprovedBy = actor.personId
      ..leftoverApprovedAt = ctx.now
      ..revision += 1;
    ctx.audit(
      g,
      action: 'panitia.approve_leftover',
      summary:
          'Sisa uang ${p.name} ${rp(p.leftoverAmount!)} · Alih peruntukan ke '
          '${tujuan.name}',
      module: Module.panitia,
      ref: RecordRef(_ref, p.id),
    );
    _notifyOfficers(
      p,
      'Tujuan sisa uang ${p.name} disetujui',
      'Alih peruntukan ke ${tujuan.name} · '
          '${ctx.personName(actor.personId)}',
      actor.personId,
    );
    return Ok(p);
  });
}
