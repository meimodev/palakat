import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../actor.dart';
import '../clock.dart';
import '../core_repositories.dart';
import '../jemaat/jemaat.dart';
import '../repositories_jemaat.dart';
import '../repositories_keuangan.dart';
import '../revision.dart';

/// J1, Party to Person (PMP 6.1): a named envelope is a part of an income
/// transaction whose Party links to a Person. PersembahanBernama records the
/// giver; PersembahanSaya lists the giver's own booked gifts. Only the giver
/// and the Bendahara Jemaat see the name (P06).

/// One envelope: the transaction, its envelope part and what the cards show.
class Sampul {
  const Sampul(
    this.t,
    this.a, {
    required this.judul,
    required this.diterima,
    required this.peruntukan,
    required this.pemberi,
  });

  final Transaction t;

  /// The envelope part: the first part of an envelope transaction, or the
  /// part given in the person's name on PersembahanSaya.
  final Allocation a;

  /// 'Sampul syukur': the Uraian up to its first comma.
  final String judul;

  /// 'Ibadah Minggu Pagi': the rest of the Uraian, or null.
  final String? diterima;

  /// The part's Fund ('Umum Jemaat').
  final String peruntukan;

  /// The Person the part's Party links to, or null (Tanpa nama).
  final Person? pemberi;

  /// dd/mm/yyyy of the transaction date.
  String get tanggal => tgl(t.effectiveDate.awal);
}

Sampul _sampul(Ref ref, Transaction t, Allocation a) {
  final orang = ref.watch(peopleRepositoryProvider);
  final [judul, ...tempat] = t.description.split(', ');
  final pihak = orang.parties().where((p) => p.id == a.partyId).firstOrNull;
  return Sampul(
    t,
    a,
    judul: judul,
    diterima: tempat.isEmpty ? null : tempat.join(', '),
    peruntukan:
        ref.watch(fundRepositoryProvider).fund(a.fundId ?? '')?.name ?? '—',
    pemberi: pihak?.personId == null ? null : orang.person(pihak!.personId!),
  );
}

/// PersembahanBernama's envelope: the newest transaction whose Uraian starts
/// with "Sampul", not cancelled and not a reversal; null when none.
// ponytail: picked by Uraian, as the boards name it; a Persembahan sampul
// part or an `id` route param would need its own picker.
final sampulProvider = Provider<Sampul?>((ref) {
  ref.watch(revisionProvider);
  final t = ref
      .watch(transactionRepositoryProvider)
      .list(null)
      .where(
        (t) =>
            t.description.startsWith('Sampul') &&
            t.status != TransactionStatus.cancelled &&
            t.reversalOf == null &&
            t.allocations.isNotEmpty,
      )
      .lastOrNull;
  return t == null ? null : _sampul(ref, t, t.allocations.first);
});

/// Whether the signed-in actor may see a giver's name: the Bendahara Jemaat
/// (or whoever acts in the post), not other officers (P06).
final bolehLihatPemberiProvider = Provider<bool>((ref) {
  final a = ref.watch(actorProvider);
  return a != null &&
      ref
          .watch(canProvider)
          .can(
            a,
            Capability.financeFinalize,
            ScopeRef.jemaat,
            at: ref.watch(hariIniProvider),
          );
});

/// The giver whose PersembahanSaya the Bendahara opens from
/// PersembahanBernama ("Lihat yang dilihat anggota"); null for one's own.
final pemberiDilihatProvider = NotifierProvider<Pilihan, String?>(Pilihan.new);

/// PersembahanSaya: the booked gifts recorded in the person's name, newest
/// first. The person is the signed-in member, or for the Bendahara the
/// giver picked on PersembahanBernama.
final persembahanSayaProvider = Provider<List<Sampul>>((ref) {
  ref.watch(revisionProvider);
  final a = ref.watch(actorProvider);
  if (a == null) return const [];
  final lain = ref.watch(pemberiDilihatProvider);
  final id = lain != null && ref.watch(bolehLihatPemberiProvider)
      ? lain
      : a.personId;
  final pihak = {
    for (final p in ref.watch(peopleRepositoryProvider).parties())
      if (p.personId == id) p.id,
  };
  return [
    for (final t
        in ref.watch(transactionRepositoryProvider).list(null).reversed)
      if (t.isPosted && t.reversalOf == null && !t.isReversed)
        for (final x in t.allocations)
          if (t.typeOf(x) == TransactionType.income &&
              pihak.contains(x.partyId))
            _sampul(ref, t, x),
  ];
});

/// How [personId]'s name prints in the Warta (TampilanNama, DP23).
final tampilanNamaProvider = Provider.family<String, String>((ref, personId) {
  ref.watch(revisionProvider);
  return ref.watch(maskingRepositoryProvider).preference(personId).label;
});

/// "Simpan" and "Lepas nama" on PersembahanBernama, while the envelope is a
/// draft: [nama] is looked up in Data jemaat, the person's Party is linked
/// when it is not yet (refused while Belum dikonfirmasi), and the envelope
/// part takes that Party; a null [nama] releases it. The refusal, or null.
// ponytail: a person with no Party at all is refused; creating Parties
// needs a PeopleRepository command no board draws.
Future<Refusal?> catatPemberi(WidgetRef ref, Sampul s, String? nama) async {
  final a = ref.read(actorProvider);
  if (a == null) return null;
  String kunci() => kunciBaru(a.personId, ref.read(clockProvider));
  final orang = ref.read(peopleRepositoryProvider);
  String? pihakId;
  if (nama != null) {
    const aksi = 'Catat nama pemberi';
    final n = nama.trim().toLowerCase();
    final o = orang
        .search(n)
        .where((p) => p.name.toLowerCase() == n)
        .firstOrNull;
    if (o == null) {
      return const Refusal(
        action: aksi,
        because: 'nama ini tidak ada di Data jemaat.',
      );
    }
    var p = orang.parties().where((x) => x.personId == o.id).firstOrNull;
    if (p == null) {
      p = orang
          .parties()
          .where((x) => x.personId == null && x.displayName == o.name)
          .firstOrNull;
      if (p == null) {
        return Refusal(
          action: aksi,
          because: '${o.name} belum tercatat sebagai pihak di Keuangan.',
        );
      }
      final r = await orang.linkPartyToPerson(
        a,
        p.id,
        o.id,
        expectedRevision: p.revision,
        idempotencyKey: kunci(),
      );
      if (r.refusal != null) return r.refusal;
    }
    pihakId = p.id;
  }
  final t = s.t;
  final r = await ref
      .read(transactionRepositoryProvider)
      .editDraft(
        a,
        t.id,
        TransactionPatch(
          allocations: [
            for (final x in t.allocations)
              identical(x, s.a)
                  ? Allocation(
                      amount: x.amount,
                      type: x.type,
                      accountId: x.accountId,
                      fundId: x.fundId,
                      toFundId: x.toFundId,
                      scopeId: x.scopeId,
                      partyId: pihakId,
                      masterCode: x.masterCode,
                      masterVersionId: x.masterVersionId,
                      caseId: x.caseId,
                      label: x.label,
                    )
                  : x,
          ],
        ),
        expectedRevision: t.revision,
        idempotencyKey: kunci(),
      );
  return r.refusal;
}
