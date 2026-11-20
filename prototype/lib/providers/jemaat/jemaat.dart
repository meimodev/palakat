import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';
import '../actor.dart';
import '../clock.dart';
import '../core_repositories.dart';
import '../repositories_jemaat.dart';
import '../revision.dart';

/// Which record a membership screen shows (UI state, set in the tap that
/// opens the screen): null leaves the screen on its default record. It
/// starts over for each signed-in person, so no one inherits another's pick.
class Pilihan extends Notifier<String?> {
  @override
  String? build() {
    ref.watch(actorProvider.select((a) => a?.personId));
    return null;
  }

  void pilih(String? id) => state = id;
}

/// DataAnggota: the person.
final anggotaDipilihProvider = NotifierProvider<Pilihan, String?>(Pilihan.new);

/// KonfirmasiKeluarga: the household.
final keluargaDipilihProvider = NotifierProvider<Pilihan, String?>(Pilihan.new);

/// Peristiwa: the life event item.
final peristiwaDipilihProvider = NotifierProvider<Pilihan, String?>(
  Pilihan.new,
);

/// DataGanda: the duplicate case.
final gandaDipilihProvider = NotifierProvider<Pilihan, String?>(Pilihan.new);

/// The names a membership screen prints, read once per build.
class NamaJemaat {
  NamaJemaat(this.ref);
  final Ref ref;

  String orang(String id) =>
      ref.read(peopleRepositoryProvider).person(id)?.name ?? id;

  String kolom(String id) =>
      ref.read(orgRepositoryProvider).scope(id)?.name ?? id;

  String? keluarga(String id) =>
      ref.read(memberRepositoryProvider).household(id)?.name;

  String judul(VerificationItem i) => itemTitle(i, orang, keluarga);

  String subjek(VerificationItem i) => itemSubject(i, orang, keluarga);

  /// "Pnt. Hendrik Rumagit, Penatua Kolom 7": the name and the post of the
  /// newest audit line of [action] on [itemId], else the name alone.
  String olehSiapa(String personId, String itemId, String action) {
    final r = ref
        .read(auditRepositoryProvider)
        .list(AuditFilter(ref: RecordRef('membership_item', itemId)))
        .where((x) => x.action == action && x.personId == personId)
        .firstOrNull;
    if (r == null) return orang(personId);
    final via = r.viaLabel == null ? '' : ' · ${r.viaLabel}';
    return '${r.personName}, ${r.actingRole}$via';
  }
}

/// Re-reads on every revision.
final namaJemaatProvider = Provider<NamaJemaat>((ref) {
  ref.watch(revisionProvider);
  return NamaJemaat(ref);
});

/// Runs a membership command as the signed-in actor with a fresh key.
Future<Result<T>?> jalankanJemaat<T>(
  WidgetRef ref,
  Future<Result<T>> Function(Actor aktor, String kunci) perintah,
) async {
  final a = ref.read(actorProvider);
  if (a == null) return null;
  return perintah(a, kunciBaru(a.personId, ref.read(clockProvider)));
}

/// Where a membership screen's back arrow goes: Data jemaat for whoever may
/// open it, else the home (a member's own screens).
final kembaliJemaatProvider = Provider<Layar>(
  (ref) => ref.watch(penjagaProvider(Layar.dataAnggota)) == null
      ? Layar.dataAnggota
      : Layar.beranda,
);

/// 'dd/mm/yyyy hh.mm' of [t], or ''.
String saatJemaat(DateTime? t) => t == null ? '' : tglJam(t);
