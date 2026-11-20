import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/tanggal.dart';
import '../../data/repositories/master_repository.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../core_repositories.dart';
import '../repositories_keuangan.dart';
import '../revision.dart';

/// A chip of the Catat form: the record id and its label.
typedef PilihanChip = ({String id, String nama});

/// What the Catat form offers on a date (D01: nothing is pre-selected):
/// the Kas/Bank, peruntukan and Lingkup in force, and the Mata Anggaran rows
/// of the published versions in force, headings included.
class PilihanCatat {
  const PilihanCatat({
    required this.kasBank,
    required this.peruntukan,
    required this.lingkup,
    required this.belanja,
    required this.pendapatan,
    required this.umum,
  });

  final List<PilihanChip> kasBank;
  final List<PilihanChip> peruntukan;
  final List<PilihanChip> lingkup;
  final List<MasterRow> belanja;
  final List<MasterRow> pendapatan;

  /// The Jemaat's own Fund ('Umum Jemaat'): a Pindah antar Kas/Bank moves
  /// its share, as the seed's transfers do.
  final String? umum;

  /// The name of Kas/Bank [id], or '' when unknown.
  String namaKasBank(String? id) =>
      kasBank.where((x) => x.id == id).firstOrNull?.nama ?? '';
  String namaPeruntukan(String? id) =>
      peruntukan.where((x) => x.id == id).firstOrNull?.nama ?? '';
  String namaLingkup(String? id) =>
      lingkup.where((x) => x.id == id).firstOrNull?.nama ?? '';
}

final pilihanCatatProvider = Provider.family<PilihanCatat, Tanggal>((ref, d) {
  ref.watch(revisionProvider);
  final org = ref.watch(orgRepositoryProvider);
  final master = ref.watch(masterRepositoryProvider);
  final dana = [
    for (final f in ref.watch(fundRepositoryProvider).funds())
      if (f.activeAt(d)) f,
  ];
  List<MasterRow> ma(MasterKind k) => [
    for (final r in master.pickerRows(k, d))
      if (r.active && (!r.postable || r.allowedEffect.allowsOwned)) r,
  ];
  return PilihanCatat(
    kasBank: [
      for (final a in ref.watch(accountRepositoryProvider).accounts())
        if (a.activeAt(d)) (id: a.id, nama: a.name),
    ],
    peruntukan: [for (final f in dana) (id: f.id, nama: f.name)],
    lingkup: [
      for (final l in ref.watch(settingsRepositoryProvider).lingkup(at: d))
        (
          id: l.scopeId,
          nama: l.scopeId == ScopeRef.jemaatId
              ? 'Jemaat'
              : org.scope(l.scopeId)?.name ?? l.scopeId,
        ),
    ],
    belanja: ma(MasterKind.belanja),
    pendapatan: ma(MasterKind.pendapatan),
    umum: dana
        .where((f) => f.ownerScopeId == ScopeRef.jemaatId)
        .firstOrNull
        ?.id,
  );
});

/// The version code ('{tahun}.1') of Mata Anggaran [code] in force at [at].
String? versiMataAnggaran(MasterRepository master, String code, Tanggal at) {
  for (final k in MasterKind.values) {
    final row = master.pickerRows(k, at).where((r) => r.code == code);
    if (row.isEmpty) continue;
    return master
        .versions(k)
        .where((v) => v.id == row.first.versionId)
        .firstOrNull
        ?.code;
  }
  return null;
}
