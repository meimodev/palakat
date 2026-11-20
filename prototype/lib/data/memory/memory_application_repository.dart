import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';
import '../repositories/application_repository.dart';
import 'memory_jemaat.dart';

class MemoryApplicationRepository implements ApplicationRepository {
  MemoryApplicationRepository(this.j);
  final MemoryJemaat j;

  @override
  VerificationItem? application(String id) => j.t.item(id);

  @override
  List<VerificationItem> submittedBy(String personId) {
    final keluarga = j.t.householdOf(personId)?.memberIds ?? [personId];
    return [
      for (final i in j.t.items.reversed)
        if (keluarga.contains(i.submittedBy) ||
            (i.event?.personIds.any(keluarga.contains) ?? false))
          i,
    ];
  }

  VerificationItem _baru(
    ItemKind kind,
    String scopeId,
    String oleh, {
    String? subject,
    String? household,
    ApplicationForm? form,
    LifeEventDraft? event,
    String? attachment,
    String? change,
    String? paperForm,
  }) {
    final i = VerificationItem(
      id: j.ctx.store.newId('verifikasi'),
      kind: kind,
      scopeId: scopeId,
      submittedBy: oleh,
      submittedAt: j.ctx.now,
      subjectPersonId: subject,
      householdId: household,
      application: form,
      event: event,
      attachment: attachment,
      change: change,
      consentVersion: form != null || kind == ItemKind.household
          ? consentVersion
          : null,
      paperForm: paperForm,
    );
    j.t.items.add(i);
    j.notifyVerifiers(i);
    return i;
  }

  @override
  Future<Result<VerificationItem>> apply(
    Actor actor,
    ApplicationForm form,
    bool consent, {
    required String idempotencyKey,
  }) => j.ctx.command(idempotencyKey, () {
    const aksi = 'Ajukan permohonan';
    final g = j.ctx.grant(actor, Capability.membershipApply, ScopeRef.jemaat);
    if (g == null) {
      return j.ctx.refuse(actor, Capability.membershipApply, ScopeRef.jemaat);
    }
    if (form.name.trim().isEmpty) return j.ctx.no(aksi, 'nama belum diisi.');
    if (!(form.birthDate < j.today)) {
      return j.ctx.no(aksi, 'tanggal lahir harus sebelum hari ini.');
    }
    if (!consent) {
      return j.ctx.no(aksi, 'izin penggunaan data pribadi belum diberikan.');
    }
    final i = _baru(
      ItemKind.application,
      form.kolomId,
      actor.personId,
      subject: actor.personId,
      household: form.householdId,
      form: form,
    );
    j.ctx.audit(
      g,
      action: 'membership.apply',
      summary: j.title(i),
      module: Module.membership,
      ref: RecordRef('membership_item', i.id),
    );
    return Ok(i);
  });

  @override
  Future<Result<VerificationItem>> submitLifeEvent(
    Actor actor,
    LifeEventDraft event,
    String? attachment, {
    required String idempotencyKey,
  }) => j.ctx.command(idempotencyKey, () {
    const aksi = 'Ajukan';
    final g = j.submitGrant(actor);
    if (g == null) {
      return j.ctx.refuse(actor, Capability.membershipSubmit, ScopeRef.jemaat);
    }
    if (event.personIds.isEmpty) {
      return j.ctx.no(aksi, 'orangnya belum dipilih.');
    }
    if (!event.personIds.every((p) => j.ownFamily(actor, p))) {
      return j.ctx.no(aksi, 'peristiwa hanya diajukan untuk keluarga sendiri.');
    }
    if (event.date > j.today) {
      return j.ctx.no(aksi, 'tanggal peristiwa belum tiba.');
    }
    if (event.kind != LifeEventKind.kolomMove &&
        (attachment == null || attachment.isEmpty)) {
      return j.ctx.no(aksi, 'surat atau piagam belum terlampir.');
    }
    final kolom = event.kind == LifeEventKind.kolomMove
        ? event.toKolomId!
        : j.kolomOf(event.personIds.first) ?? ScopeRef.jemaatId;
    final lama = event.replaces == null ? null : j.t.item(event.replaces!);
    final i = _baru(
      ItemKind.lifeEvent,
      kolom,
      actor.personId,
      household: event.householdId,
      event: event,
      attachment: attachment,
    );
    if (lama != null && lama.status == ItemStatus.returned) {
      lama
        ..replacedBy = i.id
        ..revision += 1;
    }
    j.ctx.audit(
      g,
      action: 'membership.life_event.submit',
      summary: j.title(i),
      module: Module.membership,
      ref: RecordRef('membership_item', i.id),
    );
    return Ok(i);
  });

  @override
  Future<Result<VerificationItem>> submitDataChange(
    Actor actor,
    String personId,
    String change, {
    required String idempotencyKey,
  }) => j.ctx.command(idempotencyKey, () {
    const aksi = 'Ajukan';
    final g = j.submitGrant(actor);
    if (g == null) {
      return j.ctx.refuse(actor, Capability.membershipSubmit, ScopeRef.jemaat);
    }
    if (!j.ownFamily(actor, personId)) {
      return j.ctx.no(aksi, 'perubahan hanya diajukan untuk keluarga sendiri.');
    }
    if (change.trim().isEmpty) {
      return j.ctx.no(aksi, 'perubahannya belum diisi.');
    }
    final i = _baru(
      ItemKind.dataChange,
      j.kolomOf(personId) ?? ScopeRef.jemaatId,
      actor.personId,
      subject: personId,
      household: j.t.profiles[personId]?.householdId,
      change: change.trim(),
    );
    j.ctx.audit(
      g,
      action: 'membership.data_change.submit',
      summary: j.title(i),
      module: Module.membership,
      ref: RecordRef('membership_item', i.id),
    );
    return Ok(i);
  });

  @override
  Future<Result<VerificationItem>> confirmHousehold(
    Actor actor,
    String householdId, {
    String? paperForm,
    required int expectedRevision,
    required String idempotencyKey,
  }) => j.ctx.command(idempotencyKey, () {
    const aksi = 'Kirim untuk diverifikasi';
    final h = j.t.households[householdId];
    if (h == null) return j.ctx.no(aksi, 'Keluarga tidak ditemukan.');
    final lingkup = ScopeRef(j.householdKolom(h));
    final kertas = paperForm != null;
    final g = kertas
        ? j.ctx.grant(actor, Capability.membershipConfirmHousehold, lingkup)
        : (h.representativeId == actor.personId ? j.submitGrant(actor) : null);
    if (g == null) {
      return kertas
          ? j.ctx.refuse(actor, Capability.membershipConfirmHousehold, lingkup)
          : j.ctx.no(
              aksi,
              'hanya wakil keluarga yang mengonfirmasi di aplikasi.',
            );
    }
    if (kertas && paperForm.isEmpty) {
      return j.ctx.no(aksi, 'formulir bertanda tangan belum terlampir.');
    }
    if (h.status != HouseholdStatus.unconfirmed) {
      return j.ctx.no(aksi, 'keluarga ini tidak menunggu konfirmasi.');
    }
    final basi = j.ctx.stale<VerificationItem>(
      h.revision,
      expectedRevision,
      aksi,
    );
    if (basi != null) return basi;
    for (final p in h.memberIds) {
      j.t.consents.add(
        Consent(
          id: j.ctx.store.newId('izin'),
          personId: p,
          version: consentVersion,
          at: j.ctx.now,
          channel: kertas ? ConsentChannel.paper : ConsentChannel.app,
          givenBy: h.representativeId ?? actor.personId,
          paperForm: paperForm,
        ),
      );
    }
    h
      ..status = HouseholdStatus.awaiting
      ..revision += 1;
    final i = _baru(
      ItemKind.household,
      lingkup.scopeId,
      actor.personId,
      household: h.id,
      paperForm: paperForm,
    );
    j.ctx.audit(
      g,
      action: 'membership.household.confirm',
      summary: kertas
          ? 'Formulir konfirmasi Keluarga ${h.name} dimasukkan'
          : 'Keluarga ${h.name} mengonfirmasi datanya',
      module: Module.membership,
      ref: RecordRef('household', h.id),
    );
    return Ok(i);
  });
}
