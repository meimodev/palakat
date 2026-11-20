import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../actor.dart';
import '../clock.dart';
import '../repositories_keuangan.dart';
import '../revision.dart';
import 'rinci_transaksi.dart';
import 'transaksi.dart';

/// The read model of Persetujuan and WebPersetujuan (M3): one transaction's
/// external approval records from ApprovalRepository, worded as the boards
/// word them.

/// One approval record as the boards print it.
class CatatanPersetujuan {
  const CatatanPersetujuan({
    required this.rekam,
    required this.nama,
    required this.jabatan,
    required this.tanggal,
    required this.cara,
    required this.oleh,
    required this.pada,
    required this.cat,
  });

  final ApprovalRecord rekam;
  final String nama, jabatan, cara;

  /// 'dd/mm/yyyy' of the declaration.
  final String tanggal;

  /// 'Meiske L.'; 'dd/mm/yyyy hh.mm'.
  final String oleh, pada;

  /// '' while recorded; 'Digantikan … · alasan: …' or 'Tidak berlaku lagi
  /// sejak … · …'.
  final String cat;
}

class DataPersetujuan {
  const DataPersetujuan({
    required this.rincian,
    required this.berlaku,
    required this.lama,
    required this.keterangan,
  });

  final RincianTransaksi rincian;
  final CatatanPersetujuan? berlaku;

  /// Superseded and voided, newest first.
  final List<CatatanPersetujuan> lama;

  /// '{Kas/Bank} · {Mata Anggaran} · {d Bulan yyyy}'.
  final String keterangan;

  Transaction get transaksi => rincian.transaksi;
  int get jumlah => transaksi.total;
}

/// Transaction [id] with its approval records; null when it is not there.
final persetujuanProvider = Provider.family<DataPersetujuan?, String>((
  ref,
  id,
) {
  ref.watch(revisionProvider);
  final r = ref.watch(rincianTransaksiProvider(id));
  if (r == null) return null;
  final t = r.transaksi;
  final master = ref.watch(masterRepositoryProvider);
  String nama(String personId) => ref.watch(namaPendekProvider(personId));
  CatatanPersetujuan baca(ApprovalRecord a) {
    final akhir = a.endedAt == null ? '' : tglJam(a.endedAt!);
    return CatatanPersetujuan(
      rekam: a,
      nama: a.declaration.approverName,
      jabatan: a.declaration.approverRole,
      tanggal: tgl(a.declaration.date.awal),
      cara: a.declaration.method,
      oleh: nama(a.recordedBy),
      pada: tglJam(a.recordedAt),
      cat: switch (a.status) {
        ApprovalStatus.recorded => '',
        ApprovalStatus.superseded => 'Digantikan $akhir · alasan: ${a.reason}',
        ApprovalStatus.voided =>
          'Tidak berlaku lagi sejak $akhir · ${a.reason}',
      },
    );
  }

  final semua = ref.watch(approvalRepositoryProvider).forTransaction(id);
  final ma = {
    for (final a in t.allocations)
      if (a.masterCode != null)
        labelMataAnggaran(master, a.masterCode!, t.effectiveDate),
  };
  return DataPersetujuan(
    rincian: r,
    berlaku: semua
        .where((a) => a.status == ApprovalStatus.recorded)
        .map(baca)
        .firstOrNull,
    lama: [
      for (final a in semua.reversed)
        if (a.status != ApprovalStatus.recorded) baca(a),
    ],
    keterangan: [
      r.baris.kasBank,
      ...ma,
      tglPanjang(t.effectiveDate.awal),
    ].join(' · '),
  );
});

/// "Catat persetujuan" (no record yet) or "Ganti catatan persetujuan"
/// ([alasan] given): the giver declared outside the app, dated today, by
/// notulen rapat.
Future<Refusal?> simpanPersetujuan(
  WidgetRef ref,
  DataPersetujuan d, {
  required String nama,
  required String jabatan,
  String? alasan,
}) async {
  final a = ref.read(actorProvider);
  if (a == null) return null;
  final repo = ref.read(approvalRepositoryProvider);
  final kunci = kunciBaru(a.personId, ref.read(clockProvider));
  final decl = ApprovalDeclaration(
    approverName: nama.trim(),
    approverRole: jabatan.trim(),
    date: ref.read(hariIniProvider),
    method: 'notulen rapat',
  );
  final lama = d.berlaku?.rekam;
  final r = lama == null || alasan == null
      ? await repo.recordExternal(
          a,
          d.transaksi.id,
          decl,
          expectedRevision: d.transaksi.revision,
          idempotencyKey: kunci,
        )
      : await repo.supersede(
          a,
          lama.id,
          decl,
          reason: alasan,
          expectedRevision: lama.revision,
          idempotencyKey: kunci,
        );
  return r.refusal;
}

/// The board's example of a material change: the amount up by a tenth,
/// rounded to the thousand.
int jumlahUbahan(int jumlah) => (jumlah * 11 ~/ 10) ~/ 1000 * 1000;

/// "Ubah menjadi …": the draft's single allocation gets [baru]; the
/// repository voids the recorded approval (a material change).
Future<Refusal?> ubahJumlahDraf(WidgetRef ref, Transaction t, int baru) async {
  final a = ref.read(actorProvider);
  if (a == null) return null;
  final pertama = t.allocations.first;
  final r = await ref
      .read(transactionRepositoryProvider)
      .editDraft(
        a,
        t.id,
        TransactionPatch(
          allocations: [
            pertama.copyWith(amount: baru - t.total + pertama.amount),
            ...t.allocations.skip(1),
          ],
        ),
        expectedRevision: t.revision,
        idempotencyKey: kunciBaru(a.personId, ref.read(clockProvider)),
      );
  return r.refusal;
}
