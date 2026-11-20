import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/memory/memory_import_repository.dart' show importDescription;
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../actor.dart';
import '../clock.dart';
import '../repositories_keuangan.dart';
import '../revision.dart';
import 'transaksi.dart';

/// The read model of Impor and WebImpor (M3): the newest import batch from
/// ImportRepository and its rows, worded as the boards word them.

/// The four steps: 'Ditampung', 'Lolos pengecekan', 'Sudah diperiksa',
/// 'Sudah diimpor'.
const langkahImpor = [
  'Ditampung',
  'Lolos pengecekan',
  'Sudah diperiksa',
  'Sudah diimpor',
];

/// A row's result badge tone; the names are LencanaStatus shapes.
enum NadaImpor { draf, garis, tinta, bata, peran }

class BarisImpor {
  const BarisImpor({
    required this.baris,
    required this.ur,
    required this.baca,
    required this.ma,
  });

  final StagedRow baris;

  /// The description read from the file.
  final String ur;

  /// '{dd/mm/yyyy} · Kas · Rp3.100.000 masuk'.
  final String baca;

  /// 'Pendapatan 1.3.53.07.00 …', '' when none.
  final String ma;

  String get id => baris.id;
  bool get ganda => baris.disposition == RowDisposition.possibleDuplicate;
}

class DataImpor {
  const DataImpor({required this.batch, required this.baris});

  final ImportBatch batch;
  final List<BarisImpor> baris;

  /// 0–3, the batch's step.
  int get langkah => batch.status.index;

  int get diimpor =>
      baris.where((b) => b.baris.committedTransactionId != null).length;
}

/// The newest batch; null when nothing was staged.
final imporProvider = Provider<DataImpor?>((ref) {
  ref.watch(revisionProvider);
  final repo = ref.watch(importRepositoryProvider);
  final b = repo.batches().firstOrNull;
  if (b == null) return null;
  final akun = ref.watch(accountRepositoryProvider);
  final master = ref.watch(masterRepositoryProvider);
  String namaAkun(String? id) =>
      akun
          .accounts(includeInactive: true)
          .where((a) => a.id == id)
          .firstOrNull
          ?.name ??
      'Kas/Bank belum dipilih';
  return DataImpor(
    batch: b,
    baris: [
      for (final r in repo.rows(b.id))
        BarisImpor(
          baris: r,
          ur: importDescription(r.raw),
          baca: [
            r.date == null ? 'tanggal tidak terbaca' : tgl(r.date!.awal),
            namaAkun(r.accountId),
            '${rp(r.amount ?? 0)} '
                '${r.type == TransactionType.income ? 'masuk' : 'keluar'}',
          ].join(' · '),
          ma: r.masterCode == null || r.date == null
              ? (r.masterCode ?? '')
              : labelMataAnggaran(master, r.masterCode!, r.date!),
        ),
    ],
  );
});

/// The badge, its tone, the note under it and whether "Tetap impor" /
/// "Tidak diimpor" are offered, of row [b] at step [langkah]; [tetap] is
/// the choice on a possible duplicate (null: not decided).
({String hasil, NadaImpor nada, String cat, bool pilih}) hasilBaris(
  BarisImpor b,
  int langkah,
  bool? tetap,
) {
  final r = b.baris;
  final alasan = 'Alasan: ${r.reason ?? ''}';
  if (langkah >= 1 && r.disposition == RowDisposition.refused) {
    return (
      hasil: 'Tidak diimpor',
      nada: NadaImpor.bata,
      cat: alasan,
      pilih: false,
    );
  }
  if (r.disposition == RowDisposition.deselected) {
    return (
      hasil: 'Tidak diimpor',
      nada: NadaImpor.garis,
      cat: alasan,
      pilih: false,
    );
  }
  if (langkah == 1 && b.ganda) {
    if (tetap == false) {
      return (
        hasil: 'Tidak diimpor',
        nada: NadaImpor.garis,
        cat:
            'Alasan: ${r.reason?.replaceFirst('Tanggal, Kas/Bank dan jumlah ', '') ?? ''}',
        pilih: false,
      );
    }
    if (tetap == null) {
      return (
        hasil: 'Mungkin ganda',
        nada: NadaImpor.peran,
        cat: r.reason ?? '',
        pilih: true,
      );
    }
  }
  return (
    hasil: langkahImpor[langkah],
    nada: langkah == 3
        ? NadaImpor.tinta
        : langkah == 0
        ? NadaImpor.draf
        : NadaImpor.garis,
    cat: '',
    pilih: false,
  );
}

/// The step's button: "Jalankan pengecekan", "Tandai sudah diperiksa" (the
/// duplicates kept per [tetap]) or "Impor".
Future<Refusal?> majuImpor(
  WidgetRef ref,
  DataImpor d,
  Map<String, bool> tetap,
) async {
  final a = ref.read(actorProvider);
  if (a == null) return null;
  final repo = ref.read(importRepositoryProvider);
  final b = d.batch;
  final kunci = kunciBaru(a.personId, ref.read(clockProvider));
  final r = switch (b.status) {
    ImportBatchStatus.staged => await repo.validate(
      a,
      b.id,
      expectedRevision: b.revision,
      idempotencyKey: kunci,
    ),
    ImportBatchStatus.validated => await repo.reviewRows(
      a,
      b.id,
      {
        for (final x in d.baris)
          if (x.baris.disposition == RowDisposition.ok ||
              (x.ganda && tetap[x.id] == true))
            x.id,
      },
      expectedRevision: b.revision,
      idempotencyKey: kunci,
    ),
    ImportBatchStatus.reviewed => await repo.commit(
      a,
      b.id,
      expectedRevision: b.revision,
      idempotencyKey: kunci,
    ),
    ImportBatchStatus.committed => null,
  };
  return r?.refusal;
}
