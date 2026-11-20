import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';
import '../repositories/member_repository.dart';
import 'memory_jemaat.dart';

class MemoryMemberRepository implements MemberRepository {
  MemoryMemberRepository(this.j);
  final MemoryJemaat j;

  Member? _member(MemberProfile p) {
    final orang = j.ctx.inti.person(p.personId);
    if (orang == null) return null;
    final hitung = computeBipra(
      birthDate: orang.birthDate,
      sex: orang.sex,
      marital: p.marital,
      at: j.today,
    );
    return Member(
      person: orang,
      profile: p,
      household: p.householdId == null ? null : j.t.households[p.householdId],
      kolomId: p.kolomAt(j.today),
      bipra: p.bipraOverride ?? hitung,
      bipraComputed: hitung,
    );
  }

  @override
  List<Member> members({String? kolom}) => [
    for (final p in j.t.profiles.values)
      if (kolom == null || p.kolomAt(j.today) == kolom) ?_member(p),
  ];

  @override
  Member? member(String personId) {
    final p = j.t.profiles[personId];
    return p == null ? null : _member(p);
  }

  @override
  List<Household> households() => List.unmodifiable(j.t.households.values);

  @override
  Household? household(String id) => j.t.households[id];

  @override
  Bipra? bipra(String personId) => member(personId)?.bipra;

  @override
  ({int active, int unconfirmed, int households}) counts({String? kolom}) {
    var aktif = 0, belum = 0;
    for (final p in j.t.profiles.values) {
      if (kolom != null && p.kolomAt(j.today) != kolom) continue;
      switch (j.ctx.inti.person(p.personId)?.status) {
        case PersonStatus.active:
          aktif++;
        case PersonStatus.unconfirmed:
          belum++;
        default:
      }
    }
    final keluarga = j.t.households.values
        .where(
          (h) =>
              h.status == HouseholdStatus.active &&
              h.memberIds.isNotEmpty &&
              (kolom == null || j.householdKolom(h) == kolom),
        )
        .length;
    return (active: aktif, unconfirmed: belum, households: keluarga);
  }

  @override
  List<VerificationItem> events(String personId) => [
    for (final i in j.t.items)
      if (i.kind == ItemKind.lifeEvent &&
          i.status == ItemStatus.verified &&
          (i.event!.personIds.contains(personId) ||
              (i.householdId != null &&
                  j.t.households[i.householdId]?.memberIds.contains(personId) ==
                      true)))
        i,
  ];

  @override
  Future<Result<void>> overrideBipra(
    Actor actor,
    String personId,
    Bipra group, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => j.ctx.command(idempotencyKey, () {
    const aksi = 'Ubah BIPRA';
    final p = j.t.profiles[personId];
    if (p == null) return j.ctx.no(aksi, 'Data anggota tidak ditemukan.');
    final lingkup = ScopeRef(p.kolomAt(j.today));
    final g = j.ctx.grant(actor, Capability.membershipOverrideBipra, lingkup);
    if (g == null) {
      return j.ctx.refuse(actor, Capability.membershipOverrideBipra, lingkup);
    }
    if (reason.trim().isEmpty) return j.ctx.no(aksi, 'alasan belum diisi.');
    final basi = j.ctx.stale<void>(p.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    final lama = bipra(personId);
    p
      ..bipraOverride = group
      ..bipraOverrideReason = reason.trim()
      ..revision += 1;
    j.ctx.audit(
      g,
      action: 'membership.bipra.override',
      summary: 'Kategori BIPRA ${j.name(personId)} dikoreksi',
      module: Module.membership,
      ref: RecordRef('person', personId),
      before: lama?.label,
      after: group.label,
      reason: reason.trim(),
    );
    return const Ok(null);
  });
}
