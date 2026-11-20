import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../actor.dart';
import '../clock.dart';
import '../core_repositories.dart';
import '../repositories_keuangan.dart';
import '../revision.dart';
import 'catat.dart';
import 'transaksi.dart';

/// The read model of Persembahan and WebPersembahan, parts only (M3, F4):
/// the Sunday offering as one income draft whose parts may land on different
/// Kas/Bank, and whose Titipan part is a transit collection on this month's
/// open Titipan case.

/// The Mata Anggaran of the Sunday offering and of the Titipan part.
const maPersembahanMinggu = '1.3.53.07.00';
const maTitipanSinode = '2.1.01.02.00';

/// Petugas penghitung of the offering and the Kas count (roles.md: not a
/// post in the seed): the church Bendahara and second checker in force
/// today, then the preparers of the Funds not kept by a Kolom (DP37), so a
/// handover (F20) changes the list.
final penghitungProvider = Provider<List<Person>>((ref) {
  ref.watch(revisionProvider);
  final can = ref.watch(canProvider);
  final hari = ref.watch(hariIniProvider);
  final orang = ref.watch(peopleRepositoryProvider);
  final org = ref.watch(orgRepositoryProvider);
  final ids = <String>{
    for (final c in [Capability.financeFinalize, Capability.financeReview])
      for (final p in can.whoCan(c, ScopeRef.jemaat, at: hari)) p.id,
    for (final f in ref.watch(fundRepositoryProvider).funds())
      if (org.scope(f.ownerScopeId)?.type != ScopeType.kolom)
        ?f.preparerPersonId,
  };
  return [for (final id in ids) ?orang.person(id)];
});

class PilihanPersembahan {
  const PilihanPersembahan({
    required this.minggu,
    required this.kasBank,
    required this.kas,
    required this.umum,
    required this.titipan,
    required this.maSendiri,
    required this.maTitipan,
    required this.petugas,
    required this.petugasId,
  });

  /// Petugas penghitung to pick from (mock-data 2.13); the first is the
  /// default on both twins.
  final List<String> petugas;

  /// The person ids of [petugas], in the same order.
  final List<String> petugasId;

  /// The counting sheet attached to the offering on booking.
  String get lembar =>
      'lembar-penghitungan-${minggu.hari.toString().padLeft(2, '0')}-'
      '${minggu.bulan.toString().padLeft(2, '0')}.jpg';

  /// The last Sunday up to today: the service the offering is from.
  final Tanggal minggu;

  /// The church Kas/Bank.
  final List<({String id, String nama})> kasBank;

  /// The first cash Kas (Tunai lands there).
  final String? kas;

  /// The church's general peruntukan.
  final String? umum;

  /// This month's open Titipan case for the Titipan part.
  final ({
    String id,
    String pihak,
    String fundId,
    String? akun,
    String? partyId,
  })?
  titipan;

  /// 'Pendapatan 1.3.53.07.00 Persembahan Ibadah Minggu'.
  final String maSendiri, maTitipan;

  String get uraian => 'Persembahan Ibadah Minggu · ${tglPanjang(minggu.awal)}';
}

final pilihanPersembahanProvider = Provider<PilihanPersembahan>((ref) {
  ref.watch(revisionProvider);
  final hari = ref.watch(hariIniProvider);
  final minggu = hari.tambahHari(-(hari.awal.weekday % 7));
  final p = ref.watch(pilihanCatatProvider(hari));
  final akun = ref.watch(accountRepositoryProvider).accounts();
  final gereja = [
    for (final a in akun)
      if (a.operatorAt(hari) == null) a,
  ];
  final orang = ref.watch(peopleRepositoryProvider);
  final kasus = ref.watch(caseRepositoryProvider).transits();
  final tt = kasus
      .map((v) => v.kase)
      .where(
        (c) =>
            c.openedOn.tahun == hari.tahun &&
            c.openedOn.bulan == hari.bulan &&
            c.partyId != null,
      )
      .firstOrNull;
  final master = ref.watch(masterRepositoryProvider);
  final penghitung = ref.watch(penghitungProvider);
  return PilihanPersembahan(
    minggu: minggu,
    kasBank: [for (final a in gereja) (id: a.id, nama: a.name)],
    kas: gereja.where((a) => a.type == AccountType.cash).firstOrNull?.id,
    umum: p.umum,
    titipan: tt == null
        ? null
        : (
            id: tt.id,
            pihak:
                orang
                    .parties()
                    .where((x) => x.id == tt.partyId)
                    .firstOrNull
                    ?.displayName ??
                tt.title,
            fundId: tt.fundId,
            akun: tt.accountId,
            partyId: tt.partyId,
          ),
    maSendiri: labelMataAnggaran(master, maPersembahanMinggu, minggu),
    maTitipan: labelMataAnggaran(master, maTitipanSinode, minggu),
    petugas: [for (final o in penghitung) o.short],
    petugasId: [for (final o in penghitung) o.id],
  );
});

/// One part as the form holds it.
typedef BagianPersembahan = ({
  String nama,
  int jumlah,
  bool titipan,
  String akun,
});

/// "Periksa dan bukukan": one income draft with a part per non-empty
/// [bagian] (the Titipan ones as transit collections on [p]'s case), then
/// Bukukan. [penghitung] are names of [PilihanPersembahan.petugas]. Returns
/// the draft id, the voucher once booked, and the refusal.
Future<({String? id, String? no, Refusal? pesan})> bukukanPersembahan(
  WidgetRef ref,
  PilihanPersembahan p,
  List<BagianPersembahan> bagian, {
  required List<String> penghitung,
  String? drafId,
}) async {
  final a = ref.read(actorProvider);
  if (a == null) return (id: null, no: null, pesan: null);
  final tx = ref.read(transactionRepositoryProvider);
  String kunci() => kunciBaru(a.personId, ref.read(clockProvider));
  var t = drafId == null ? null : tx.get(drafId);
  if (t == null || !t.isDraft) {
    final tt = p.titipan;
    final r = await tx.createDraft(
      a,
      TransactionDraft(
        type: TransactionType.income,
        effectiveDate: p.minggu,
        description: p.uraian,
        countedBy: [
          for (final n in penghitung)
            if (p.petugas.indexOf(n) case final i when i >= 0) p.petugasId[i],
        ],
        allocations: [
          for (final b in bagian)
            if (b.jumlah > 0)
              b.titipan && tt != null
                  ? Allocation(
                      amount: b.jumlah,
                      type: TransactionType.transitCollection,
                      accountId: b.akun,
                      fundId: tt.fundId,
                      scopeId: ScopeRef.jemaatId,
                      partyId: tt.partyId,
                      masterCode: maTitipanSinode,
                      caseId: tt.id,
                      label: b.nama,
                    )
                  : Allocation(
                      amount: b.jumlah,
                      accountId: b.akun,
                      fundId: p.umum,
                      scopeId: ScopeRef.jemaatId,
                      masterCode: maPersembahanMinggu,
                      label: b.nama,
                    ),
        ],
      ),
      idempotencyKey: kunci(),
    );
    if (r.refusal case final x?) return (id: null, no: null, pesan: x);
    t = r.value;
    // The counting sheet is the offering's supporting document.
    final u = await ref
        .read(evidenceRepositoryProvider)
        .upload(
          a,
          t.id,
          SampleFile(p.lembar),
          expectedRevision: t.revision,
          idempotencyKey: kunci(),
        );
    if (u.refusal case final x?) return (id: t.id, no: null, pesan: x);
  }
  final f = await tx.finalize(
    a,
    t.id,
    expectedRevision: t.revision,
    idempotencyKey: kunci(),
  );
  return (id: t.id, no: f.isOk ? f.value : null, pesan: f.refusal);
}
