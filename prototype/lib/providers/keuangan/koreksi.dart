import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../actor.dart';
import '../core_repositories.dart';
import '../clock.dart';
import '../repositories_keuangan.dart';
import '../revision.dart';
import 'beranda.dart';
import 'dokumen.dart';
import 'rinci_transaksi.dart';
import 'transaksi.dart';

/// The read model of Koreksi and WebKoreksi (M3): a posted transaction, its
/// reversal and correction (drafts or posted), its month's state and the
/// incidents recorded on it.
class DataKoreksi {
  const DataKoreksi({
    required this.asal,
    required this.rincian,
    required this.tutup,
    required this.bulan,
    required this.pembalikan,
    required this.pengganti,
    required this.keterangan,
    required this.maAsal,
    required this.pilihanMa,
    required this.dokumen,
    required this.kejadian,
  });

  final Transaction asal;
  final RincianTransaksi rincian;

  /// The month of [asal] is closed.
  final bool tutup;

  /// '{Bulan yyyy}' of [asal].
  final String bulan;

  /// Not cancelled; draft or posted.
  final Transaction? pembalikan, pengganti;

  /// 'Kas · diambil dari peruntukan Umum Jemaat · {d Bulan yyyy}'.
  final String keterangan;

  /// 'Belanja 5.02.01.00 Alat tulis dan fotokopi', '' without one.
  final String maAsal;

  /// (code, name) of the Mata Anggaran a correction may take; [asal]'s first.
  final List<(String, String)> pilihanMa;
  final BarisDokumen? dokumen;
  final List<CloseIncident> kejadian;

  bool get dibalik => asal.isReversed;

  /// A reversal or correction drafted, not yet posted.
  bool get menunggu =>
      !dibalik &&
      ((pembalikan?.isDraft ?? false) || (pengganti?.isDraft ?? false));

  String get kasBank => rincian.baris.kasBank;

  /// The change on the Kas/Bank book balance of the posted chain: Rp0 when
  /// the correction has the same amount.
  int get pengaruh => [pembalikan, pengganti]
      .whereType<Transaction>()
      .where((t) => t.isPosted)
      .fold(0, (s, t) => s + signedAmount(t));
}

String _bagian(Transaction t) =>
    t.allocations.map((a) => a.masterCode).whereType<String>().firstOrNull ??
    '';

/// Transaction [id] (the original, its reversal or its correction) as
/// Koreksi shows it; null when it is not there or not posted.
final koreksiProvider = Provider.family<DataKoreksi?, String>((ref, id) {
  ref.watch(revisionProvider);
  final tx = ref.watch(transactionRepositoryProvider);
  var t = tx.get(id);
  if (t == null) return null;
  final akar = t.reversalOf ?? t.correctionOf;
  if (akar != null) t = tx.get(akar) ?? t;
  final asal = t;
  if (!asal.isPosted) return null;
  final r = ref.watch(rincianTransaksiProvider(asal.id));
  if (r == null) return null;
  final master = ref.watch(masterRepositoryProvider);
  final dana = ref.watch(fundRepositoryProvider);
  final periode = ref
      .watch(periodRepositoryProvider)
      .periods()
      .where((p) => p.contains(asal.effectiveDate))
      .firstOrNull;
  final semua = tx
      .list(null)
      .where((x) => x.status != TransactionStatus.cancelled);
  final kode = _bagian(asal);
  final jenis = kode.startsWith('1') || kode.startsWith('2')
      ? MasterKind.pendapatan
      : MasterKind.belanja;
  final baris = [
    for (final x in master.pickerRows(jenis, ref.watch(hariIniProvider)))
      if (x.postable) (x.code, x.name),
  ];
  final a = asal.allocations.first;
  return DataKoreksi(
    asal: asal,
    rincian: r,
    tutup: periode?.isClosed ?? false,
    bulan: periode == null ? '' : namaBulan(periode),
    pembalikan: semua.where((x) => x.reversalOf == asal.id).firstOrNull,
    pengganti: semua.where((x) => x.correctionOf == asal.id).firstOrNull,
    keterangan: [
      r.baris.kasBank,
      if (a.fundId != null)
        'diambil dari peruntukan ${dana.fund(a.fundId!)?.name ?? a.fundId}',
      tglPanjang(asal.effectiveDate.awal),
    ].join(' · '),
    maAsal: kode.isEmpty
        ? ''
        : labelMataAnggaran(master, kode, asal.effectiveDate),
    pilihanMa: [
      ...baris.where((b) => b.$1 == kode),
      ...baris.where((b) => b.$1 != kode),
    ],
    dokumen: ref.watch(dokumenDenganIdProvider(asal.id)),
    kejadian: [
      for (final k in ref.watch(periodRepositoryProvider).incidents())
        if (k.explanation.transactionIds.contains(asal.id)) k,
    ],
  );
});

/// "Bukukan pembalikan dan koreksi" ([ma] given) or "Bukukan pembalikan":
/// drafts the reversal (and the correction carrying [ma]) unless drafted
/// already, then books them. Null when the whole chain is posted.
Future<Refusal?> bukukanKoreksi(
  WidgetRef ref,
  DataKoreksi d, {
  required String alasan,
  String? ma,
}) async {
  final a = ref.read(actorProvider);
  if (a == null) return null;
  final tx = ref.read(transactionRepositoryProvider);
  String kunci() => kunciBaru(a.personId, ref.read(clockProvider));
  if (d.pembalikan == null) {
    final t = d.asal;
    final Result<Object> r = ma == null
        ? await tx.reverse(
            a,
            t.id,
            reason: alasan,
            expectedRevision: t.revision,
            idempotencyKey: kunci(),
          )
        : await tx.correct(
            a,
            t.id,
            TransactionDraft(
              type: t.type,
              effectiveDate: ref.read(hariIniProvider),
              description: t.description,
              accountId: t.accountId,
              toAccountId: t.toAccountId,
              payee: t.payee,
              sourceRef: t.sourceRef,
              allocations: [
                for (final x in t.allocations) x.copyWith(masterCode: ma),
              ],
            ),
            reason: alasan,
            expectedRevision: t.revision,
            idempotencyKey: kunci(),
          );
    if (r.refusal case final p?) return p;
  }
  return bukukanRangkaian(ref, d.asal.id);
}

/// Books the drafted reversal and correction of [asalId] as one pair.
Future<Refusal?> bukukanRangkaian(WidgetRef ref, String asalId) async {
  final a = ref.read(actorProvider);
  if (a == null) return null;
  final tx = ref.read(transactionRepositoryProvider);
  final balik = tx
      .list(null)
      .where((x) => x.reversalOf == asalId && x.isDraft)
      .firstOrNull;
  if (balik == null) return null;
  final r = await tx.finalizeCorrection(
    a,
    asalId,
    expectedRevision: balik.revision,
    idempotencyKey: kunciBaru(a.personId, ref.read(clockProvider)),
  );
  return r.refusal;
}

/// "Catat kejadian" on [d]'s closed month.
Future<Refusal?> catatKejadian(
  WidgetRef ref,
  DataKoreksi d, {
  required String penjelasan,
  String dampak = '',
  String penanggungJawab = '',
}) async {
  final a = ref.read(actorProvider);
  if (a == null) return null;
  final p = ref
      .read(periodRepositoryProvider)
      .periods()
      .where((x) => x.contains(d.asal.effectiveDate))
      .firstOrNull;
  if (p == null) return null;
  final r = await ref
      .read(periodRepositoryProvider)
      .recordIncident(
        a,
        p.id,
        IncidentExplanation(
          title: 'Kejadian ${d.asal.voucher}',
          facts: penjelasan.trim(),
          impact: dampak.trim(),
          responsible: penanggungJawab.trim(),
          transactionIds: [d.asal.id],
        ),
        null,
        idempotencyKey: kunciBaru(a.personId, ref.read(clockProvider)),
      );
  return r.refusal;
}

/// '+Rp750.000', 'Rp0', '−Rp750.000'.
String pengaruhTeks(int n) => n > 0 ? '+${rp(n)}' : rp(n);

/// The reason given for the reversal or correction of [asalId] (its audit
/// line), '' when there is none.
final alasanPembalikanProvider = Provider.family<String, String>((ref, asalId) {
  ref.watch(revisionProvider);
  return ref
          .watch(auditRepositoryProvider)
          .list(AuditFilter(ref: RecordRef('transaction', asalId)))
          .where(
            (x) =>
                x.action == 'finance.txn.reverse' ||
                x.action == 'finance.txn.correct',
          )
          .firstOrNull
          ?.reason ??
      '';
});

/// 'Belanja 5.04.01.00 Konsumsi rapat' of [t]'s first coded part.
String labelKoreksi(WidgetRef ref, Transaction t) {
  final kode = _bagian(t);
  return kode.isEmpty
      ? ''
      : labelMataAnggaran(
          ref.watch(masterRepositoryProvider),
          kode,
          t.effectiveDate,
        );
}
