import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/secretariat/secretariat.dart';
import '../repositories/letter_repository.dart';
import 'memory_context.dart';
import 'memory_sekretariat.dart';

class MemoryLetterRepository implements LetterRepository {
  MemoryLetterRepository(this.ctx);
  final MemoryContext ctx;

  @override
  List<LetterRequest> requests({String? personId}) => [
    for (final r in ctx.sek.letters)
      if (personId == null ||
          r.forPersonId == personId ||
          r.requestedBy == personId)
        r,
  ];

  LetterRequest? _get(String id) =>
      ctx.sek.letters.where((r) => r.id == id).firstOrNull;

  @override
  String nextNumber({required Tanggal at}) =>
      letterNumber((ctx.sek.letterCounters[at.tahun] ?? 0) + 1, at);

  /// A new request for [forPersonId], or the refusal.
  Result<LetterRequest> _baru(
    Grant g,
    String forPersonId,
    LetterType type,
    String? purpose, {
    required bool atOffice,
  }) {
    const aksi = 'Ajukan permohonan';
    final orang = ctx.inti.person(forPersonId);
    if (orang == null) return ctx.no(aksi, 'anggota tidak ditemukan.');
    final sama = ctx.sek.letters.any(
      (r) =>
          r.forPersonId == forPersonId &&
          r.type == type &&
          r.status == LetterStatus.requested,
    );
    if (sama) {
      return ctx.no(aksi, 'permohonan yang sama masih Diajukan.');
    }
    final keperluan = purpose?.trim();
    final r = LetterRequest(
      id: ctx.store.newId('surat'),
      type: type,
      forPersonId: forPersonId,
      forName: orang.name,
      requestedBy: g.personId,
      requestedAt: ctx.now,
      purpose: keperluan == null || keperluan.isEmpty ? null : keperluan,
      atOffice: atOffice,
      household: ctx.sek.households[forPersonId],
    );
    ctx.sek.letters.add(r);
    final ref = RecordRef('letter', r.id);
    ctx.audit(
      g,
      action: atOffice ? 'letter.record_at_office' : 'letter.request',
      summary: atOffice
          ? 'Permohonan ${r.title} dicatat di kantor.'
          : 'Permohonan ${r.title} diajukan.',
      module: Module.churchDocuments,
      ref: ref,
    );
    ctx.notifyHolders(
      Capability.documentsIssueLetter,
      g.personId,
      title: 'Permohonan ${r.title}',
      body: atOffice
          ? 'Dicatat ${ctx.personName(g.personId)} di kantor'
          : 'Diajukan ${tgl(ctx.now)}',
      module: Module.churchDocuments,
      ref: ref,
    );
    return Ok(r);
  }

  @override
  Future<Result<LetterRequest>> request(
    Actor actor,
    LetterType type, {
    String? purpose,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    final g = ctx.gate(actor, Capability.documentsRequestLetter);
    if (g == null) {
      return ctx.refuse(
        actor,
        Capability.documentsRequestLetter,
        ScopeRef.jemaat,
      );
    }
    return _baru(g, actor.personId, type, purpose, atOffice: false);
  });

  @override
  Future<Result<LetterRequest>> recordAtOffice(
    Actor actor,
    String forPersonId,
    LetterType type, {
    String? purpose,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    final g = ctx.gate(actor, Capability.documentsRecordRequest);
    if (g == null) {
      return ctx.refuse(
        actor,
        Capability.documentsRecordRequest,
        ScopeRef.jemaat,
      );
    }
    return _baru(g, forPersonId, type, purpose, atOffice: true);
  });

  /// The gate and the open request, or the refusal.
  (Grant, LetterRequest)? _buka(
    Actor actor,
    String id,
    int expected,
    String aksi,
    void Function(Refusal) tolak,
  ) {
    final g = ctx.gate(actor, Capability.documentsIssueLetter);
    if (g == null) {
      tolak(
        ctx
            .refuse<void>(
              actor,
              Capability.documentsIssueLetter,
              ScopeRef.jemaat,
            )
            .refusal,
      );
      return null;
    }
    final r = _get(id);
    final sebab = r == null
        ? 'permohonan tidak ditemukan.'
        : r.revision != expected
        ? 'Sudah diubah sejak Anda membukanya.'
        : r.status != LetterStatus.requested
        ? 'permohonan ini sudah ${r.status.label}.'
        : null;
    if (sebab != null) {
      tolak(Refusal(action: aksi, because: sebab));
      return null;
    }
    return (g, r!);
  }

  @override
  Future<Result<LetterRequest>> issue(
    Actor actor,
    String id,
    String number,
    SampleFile? signedCopy, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Terbitkan surat';
    Refusal? tolak;
    final b = _buka(actor, id, expectedRevision, aksi, (x) => tolak = x);
    if (b == null) return Refused(tolak!);
    final (g, r) = b;
    final no = number.trim();
    if (no.isEmpty) return ctx.no(aksi, 'nomor surat belum diisi.');
    if (signedCopy == null) {
      return ctx.no(aksi, 'salinan bertanda tangan belum terlampir.');
    }
    if (ctx.sek.letters.any((x) => x.number == no)) {
      return ctx.no(aksi, 'nomor surat $no sudah dipakai.');
    }
    // The outgoing-letter book: a number in this year's series moves it on.
    final seq = letterSeq(no);
    final tahun = ctx.today.tahun;
    if (seq != null &&
        no.endsWith('/$tahun') &&
        seq > (ctx.sek.letterCounters[tahun] ?? 0)) {
      ctx.sek.letterCounters[tahun] = seq;
    }
    final d = ChurchDocument(
      id: ctx.store.newId('dokumen'),
      kind: DocumentKind.memberLetter,
      title: r.title,
      documentDate: ctx.today,
      audience: Audience.person(r.forPersonId),
      revisions: [
        DocumentRevision(
          number: 1,
          signedCopy: signedCopy,
          publishedAt: ctx.now,
          publishedBy: actor.personId,
        ),
      ],
    );
    ctx.sek.documents.add(d);
    r
      ..status = LetterStatus.issued
      ..number = no
      ..signedCopy = signedCopy
      ..decidedBy = actor.personId
      ..decidedAt = ctx.now
      ..documentId = d.id
      ..revision += 1;
    final ref = RecordRef('letter', r.id);
    final teks = '${r.type.label} ${r.forName} diterbitkan';
    ctx.audit(
      g,
      action: 'letter.issue',
      summary: '$teks dengan No. $no.',
      module: Module.churchDocuments,
      ref: ref,
    );
    for (final p in {r.forPersonId, r.requestedBy}) {
      ctx.notifyPerson(
        p,
        title: teks,
        body: 'No. $no · ${tgl(ctx.now)}',
        module: Module.churchDocuments,
        ref: ref,
      );
    }
    return Ok(r);
  });

  @override
  Future<Result<void>> refuse(
    Actor actor,
    String id, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Catat tidak diterbitkan';
    Refusal? tolak;
    final b = _buka(actor, id, expectedRevision, aksi, (x) => tolak = x);
    if (b == null) return Refused(tolak!);
    final (g, r) = b;
    final alasan = reason.trim();
    if (alasan.isEmpty) return ctx.no(aksi, 'alasan belum diisi.');
    r
      ..status = LetterStatus.refused
      ..refusalReason = alasan
      ..decidedBy = actor.personId
      ..decidedAt = ctx.now
      ..revision += 1;
    final ref = RecordRef('letter', r.id);
    final teks = '${r.type.label} ${r.forName} tidak diterbitkan';
    ctx.audit(
      g,
      action: 'letter.refuse',
      summary: '$teks.',
      module: Module.churchDocuments,
      ref: ref,
      reason: alasan,
    );
    for (final p in {r.forPersonId, r.requestedBy}) {
      ctx.notifyPerson(
        p,
        title: teks,
        body: 'Alasan: $alasan',
        module: Module.churchDocuments,
        ref: ref,
      );
    }
    return const Ok(null);
  });
}
