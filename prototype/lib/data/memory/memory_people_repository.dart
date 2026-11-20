import '../../domain/core/core.dart';
import '../repositories/people_repository.dart';
import 'memory_context.dart';

class MemoryPeopleRepository implements PeopleRepository {
  MemoryPeopleRepository(this.ctx);
  final MemoryContext ctx;

  @override
  Person? person(String id) => ctx.inti.person(id);

  @override
  List<Person> search(String query) {
    final q = query.trim().toLowerCase();
    return [
      for (final p in ctx.inti.people)
        if (!p.isSystem && q.isNotEmpty && p.name.toLowerCase().contains(q)) p,
    ];
  }

  @override
  List<Party> parties() => List.unmodifiable(ctx.inti.parties);

  Party? _party(String id) =>
      ctx.inti.parties.where((p) => p.id == id).firstOrNull;

  /// Linking is the Bendahara's join (PMP 7); unlinking also follows a
  /// member's deletion (DL13).
  Grant? _grant(Actor actor, {bool hapus = false}) =>
      ctx.grant(actor, Capability.financeRecord, ScopeRef.jemaat) ??
      (hapus
          ? ctx.grant(actor, Capability.membershipDelete, ScopeRef.anywhere)
          : null);

  @override
  Future<Result<void>> linkPartyToPerson(
    Actor actor,
    String partyId,
    String personId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    // The one board that draws the link: PersembahanBernama.
    const aksi = 'Catat nama pemberi';
    final g = _grant(actor);
    if (g == null) {
      return ctx.refuse(actor, Capability.financeRecord, ScopeRef.jemaat);
    }
    final p = _party(partyId);
    final o = ctx.inti.person(personId);
    if (p == null || o == null) return ctx.no(aksi, 'Data tidak ditemukan.');
    // Linked only once the person is verified (PersembahanBernama).
    if (o.status == PersonStatus.unconfirmed) {
      return ctx.no(aksi, 'data ${o.name} masih Belum dikonfirmasi.');
    }
    final basi = ctx.stale<void>(p.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    p
      ..personId = personId
      ..revision += 1;
    ctx.audit(
      g,
      action: 'party.link',
      summary: 'Menghubungkan ${p.displayName} dengan ${o.name}',
      module: Module.finance,
      ref: RecordRef('party', p.id),
    );
    return const Ok(null);
  });

  @override
  Future<Result<void>> unlinkParty(
    Actor actor,
    String partyId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Lepaskan hubungan';
    final g = _grant(actor, hapus: true);
    if (g == null) {
      return ctx.refuse(actor, Capability.financeRecord, ScopeRef.jemaat);
    }
    final p = _party(partyId);
    if (p == null) return ctx.no(aksi, 'Data tidak ditemukan.');
    final basi = ctx.stale<void>(p.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (reason.trim().isEmpty) return ctx.no(aksi, 'Alasan belum diisi.');
    final sebelum = p.personId;
    p
      ..personId = null
      ..revision += 1;
    ctx.audit(
      g,
      action: 'party.unlink',
      summary: 'Melepas hubungan ${p.displayName} dengan anggota',
      module: Module.finance,
      before: sebelum,
      reason: reason.trim(),
      ref: RecordRef('party', p.id),
    );
    return const Ok(null);
  });

  @override
  Future<Result<Person>> setContact(
    Actor actor, {
    String? phone,
    String? backupEmail,
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Simpan';
    final p = ctx.inti.person(actor.personId);
    if (p == null) return ctx.no(aksi, 'Akun tidak ditemukan.');
    final basi = ctx.stale<Person>(p.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    final hp = phone?.replaceAll(RegExp(r'\D'), '');
    if (hp != null && hp.length < 10) {
      return ctx.no(aksi, 'Nomor ponsel belum lengkap.');
    }
    final email = backupEmail?.trim();
    if (email != null && email.isNotEmpty && !email.contains('@')) {
      return ctx.no(aksi, 'Alamat email belum benar.');
    }
    if (hp != null) {
      p.phone = hp;
      // A new sign-in number signs the person's other devices out (AkunSaya).
      for (final d in ctx.inti.devices) {
        if (d.personId == p.id && d.endedAt == null) {
          d
            ..endedAt = ctx.now
            ..revision += 1;
        }
      }
    }
    if (email != null) p.backupEmail = email.isEmpty ? null : email;
    p.revision += 1;
    ctx.audit(
      ctx.own(actor),
      action: 'person.contact',
      summary: hp != null
          ? 'Mengganti nomor ponsel · perangkat lain dikeluarkan'
          : 'Mengubah email cadangan',
      ref: RecordRef('person', p.id),
    );
    return Ok(p);
  });
}
