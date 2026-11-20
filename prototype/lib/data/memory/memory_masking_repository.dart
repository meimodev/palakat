import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';
import '../repositories/masking_repository.dart';
import 'memory_jemaat.dart';

class MemoryMaskingRepository implements MaskingRepository {
  MemoryMaskingRepository(this.j);
  final MemoryJemaat j;

  @override
  NameForm preference(String personId) =>
      j.t.masking[personId]?.form ??
      j.t.householdOf(personId)?.defaultNameForm ??
      NameForm.fullName;

  @override
  MaskingPreference? ownChoice(String personId) => j.t.masking[personId];

  @override
  String nameWith(String personId, NameForm form) {
    final orang = j.ctx.inti.person(personId);
    final p = j.t.profiles[personId];
    final h = j.t.householdOf(personId);
    final kolom = p == null ? '' : j.scopeName(p.kolomAt(j.today));
    final keluarga = h == null ? (orang?.name ?? '') : 'Kel. ${h.name}';
    final bipra =
        p?.bipraOverride ??
        computeBipra(
          birthDate: orang?.birthDate,
          sex: orang?.sex,
          marital: p?.marital,
          at: j.today,
        );
    return switch (form) {
      NameForm.fullName => orang?.name ?? '',
      NameForm.familyName => keluarga,
      NameForm.familyKolom => '$keluarga — $kolom',
      NameForm.kolom => kolom,
      NameForm.bipra => bipra?.label ?? kolom,
      NameForm.bipraKolom => '${bipra?.label ?? 'Anggota'} — $kolom',
      NameForm.none => 'Tanpa nama',
    };
  }

  @override
  String printedName(String personId, PrintContext context) {
    final orang = j.ctx.inti.person(personId);
    if (context == PrintContext.letter) return orang?.name ?? '';
    // Nothing about an unconfirmed or deleted person is published (DL8, DL13).
    if (orang?.status == PersonStatus.unconfirmed ||
        !j.t.profiles.containsKey(personId)) {
      return 'Tanpa nama';
    }
    return nameWith(personId, preference(personId));
  }

  @override
  Future<Result<void>> set(
    Actor actor,
    String personId,
    NameForm preference, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => j.ctx.command(idempotencyKey, () {
    const aksi = 'Simpan pilihan';
    final g = j.submitGrant(actor);
    if (g == null || actor.personId != personId) {
      return j.ctx.no(
        aksi,
        'hanya anggota sendiri yang memilih tampilan namanya.',
      );
    }
    if (!j.t.profiles.containsKey(personId)) {
      return j.ctx.no(aksi, 'Anda belum tercatat di Data jemaat.');
    }
    final lama = j.t.masking[personId];
    final basi = j.ctx.stale<void>(lama?.revision ?? 0, expectedRevision, aksi);
    if (basi != null) return basi;
    if (lama?.form == preference) {
      return j.ctx.no(aksi, 'pilihan ini sudah tersimpan.');
    }
    j.t.masking[personId] = MaskingPreference(
      personId: personId,
      form: preference,
      revision: (lama?.revision ?? 0) + 1,
    );
    j.ctx.audit(
      g,
      action: 'membership.masking.set',
      summary: 'Tampilan nama diubah menjadi ${preference.label}',
      module: Module.membership,
      ref: RecordRef('person', personId),
      before: lama?.form.label,
      after: preference.label,
    );
    return const Ok(null);
  });
}
