import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/finance/finance.dart';
import '../repositories_keuangan.dart';
import '../revision.dart';
import '../seed.dart';
import 'beranda.dart';
import 'transaksi.dart';

/// The read model of Dokumen, WebDokumen, Kamera, WebUnggah, LihatDokumen
/// and Ekspor (M3): each transaction's supporting-document state from
/// EvidenceRepository, worded as the boards word it.

/// The transaction Dokumen chose for Kamera, WebUnggah and LihatDokumen
/// (their routes carry no id). Null: [dokumenTerpilihProvider] falls back.
class PilihanDokumen extends Notifier<String?> {
  @override
  String? build() => null;

  void pilih(String? id) => state = id;
}

final pilihanDokumenProvider = NotifierProvider<PilihanDokumen, String?>(
  PilihanDokumen.new,
);

/// One transaction as Dokumen lists it.
class BarisDokumen {
  const BarisDokumen({
    required this.transaksi,
    required this.status,
    required this.label,
    required this.bulan,
    required this.tutup,
    required this.riwayat,
    required this.menunggu,
  });

  final Transaction transaksi;
  final EvidenceStatus status;

  /// 'Wajib, belum ada', 'Terverifikasi (oleh Meiske L.)', …
  final String label;

  /// '{Bulan yyyy} · Belum ditutup'.
  final String bulan;
  final bool tutup;

  /// Newest first: '{dd/mm/yyyy hh.mm} · {what} oleh {name}'.
  final List<String> riwayat;

  /// The uploaded file waiting for verification, if any.
  final EvidenceItem? menunggu;

  String get id => transaksi.id;

  /// The voucher, or 'Draf' before Bukukan.
  String get no => transaksi.voucher ?? 'Draf';
  String get jumlah => rp(signedAmount(transaksi));

  /// Verified, excepted or not required: no close blocker.
  bool get beres =>
      status != EvidenceStatus.requiredMissing &&
      status != EvidenceStatus.uploaded;
}

/// [t] with its document state.
BarisDokumen barisDokumen(Ref ref, Transaction t) {
  final ev = ref.watch(evidenceRepositoryProvider);
  String nama(String? id) =>
      id == null ? '' : ref.watch(namaPendekProvider(id));
  final items = ev.forTransaction(t.id);
  final s = _status(t, items);
  final verif = items
      .where((e) => e.state == EvidenceItemState.verified)
      .lastOrNull;
  final kecuali = items
      .where((e) => e.state == EvidenceItemState.exception)
      .lastOrNull;
  final label = switch (s) {
    EvidenceStatus.requiredMissing => 'Wajib, belum ada',
    EvidenceStatus.uploaded => 'Diunggah, belum diverifikasi',
    EvidenceStatus.verified => 'Terverifikasi (oleh ${nama(verif?.decidedBy)})',
    EvidenceStatus.exceptionAccepted =>
      'Dikecualikan (alasan: ${kecuali?.reason})',
    EvidenceStatus.notRequired => 'Tidak diperlukan',
  };
  final riwayat = <(DateTime, String)>[];
  for (final e in items) {
    final f = e.file?.name ?? 'File';
    switch (e.state) {
      case EvidenceItemState.exception:
        riwayat.add((
          e.at,
          'Dikecualikan · alasan: ${e.reason} · dicatat ${nama(e.by)}',
        ));
      default:
        riwayat.add((e.at, '$f diunggah oleh ${nama(e.by)}'));
    }
    final d = e.decidedAt;
    if (d == null) continue;
    switch (e.state) {
      case EvidenceItemState.verified:
        riwayat.add((d, 'Terverifikasi oleh ${nama(e.decidedBy)}'));
      case EvidenceItemState.rejected:
        riwayat.add((
          d,
          'File ditolak · alasan: ${e.reason} · oleh ${nama(e.decidedBy)}',
        ));
      case EvidenceItemState.released:
        riwayat.add((
          d,
          'File dilepas oleh ${nama(e.decidedBy)} · tetap di Riwayat',
        ));
      default:
    }
  }
  riwayat.sort((a, b) => b.$1.compareTo(a.$1));
  final p = ref
      .watch(periodRepositoryProvider)
      .periods()
      .where((x) => x.contains(t.effectiveDate))
      .firstOrNull;
  final tutup = p?.isClosed ?? false;
  return BarisDokumen(
    transaksi: t,
    status: s,
    label: label,
    bulan: p == null
        ? ''
        : '${namaBulan(p)} · ${tutup ? 'Sudah ditutup' : 'Belum ditutup'}',
    tutup: tutup,
    riwayat: [for (final (w, x) in riwayat) '${tglJam(w)} · $x'],
    menunggu: items
        .where((e) => e.state == EvidenceItemState.uploaded)
        .lastOrNull,
  );
}

EvidenceStatus _status(Transaction t, List<EvidenceItem> items) {
  if (items.any((e) => e.state == EvidenceItemState.exception)) {
    return EvidenceStatus.exceptionAccepted;
  }
  if (items.any((e) => e.state == EvidenceItemState.verified)) {
    return EvidenceStatus.verified;
  }
  if (items.any((e) => e.state == EvidenceItemState.uploaded)) {
    return EvidenceStatus.uploaded;
  }
  return t.evidenceRequired
      ? EvidenceStatus.requiredMissing
      : EvidenceStatus.notRequired;
}

/// Dokumen's list: in the open months, every transaction whose document is
/// missing or waits for verification, or was decided today; and every
/// accepted exception. Waiting ones first.
final daftarDokumenProvider = Provider<List<BarisDokumen>>((ref) {
  ref.watch(revisionProvider);
  final ev = ref.watch(evidenceRepositoryProvider);
  final hari = ref.watch(bulanBukuProvider);
  final mulai = ref.watch(seedProvider).launchedAt;
  final hasil = <BarisDokumen>[];
  for (final p in hari.semua) {
    for (final x in ev.list(p.id, null)) {
      final t = x.transaction;
      final terbuka = !p.isClosed;
      final perlu =
          x.status == EvidenceStatus.requiredMissing ||
          x.status == EvidenceStatus.uploaded;
      // Decided in this run: it stays listed after Verifikasi.
      final baru = ev
          .forTransaction(t.id)
          .any((e) => (e.decidedAt ?? e.at).isAfter(mulai));
      if ((terbuka && (perlu || baru)) ||
          x.status == EvidenceStatus.exceptionAccepted) {
        hasil.add(barisDokumen(ref, t));
      }
    }
  }
  hasil.sort((a, b) {
    final x = a.beres ? 1 : 0, y = b.beres ? 1 : 0;
    if (x != y) return x - y;
    return b.transaksi.effectiveDate.compareTo(a.transaksi.effectiveDate);
  });
  return hasil;
});

/// The transaction Kamera and WebUnggah capture for: Dokumen's choice, else
/// the newest open-month posted transaction still missing its document.
final dokumenTerpilihProvider = Provider<BarisDokumen?>((ref) {
  ref.watch(revisionProvider);
  final id = ref.watch(pilihanDokumenProvider);
  final tx = ref.watch(transactionRepositoryProvider);
  final t = id == null ? null : tx.get(id);
  if (t != null) return barisDokumen(ref, t);
  final daftar = ref.watch(daftarDokumenProvider);
  return daftar
          .where(
            (b) =>
                b.status == EvidenceStatus.requiredMissing &&
                b.transaksi.isPosted,
          )
          .firstOrNull ??
      daftar.firstOrNull;
});

/// The file name of a new capture: 'nota-{dd}-{mm}.jpg' from today.
String namaNota(DateTime today, [int halaman = 1]) {
  String dua(int n) => n.toString().padLeft(2, '0');
  return 'nota-${dua(today.day)}-${dua(today.month)}'
      '${halaman > 1 ? '-$halaman' : ''}.jpg';
}

/// Transaction [id] with its document state (LihatDokumen `/:id`).
final dokumenDenganIdProvider = Provider.family<BarisDokumen?, String>((
  ref,
  id,
) {
  ref.watch(revisionProvider);
  final t = ref.watch(transactionRepositoryProvider).get(id);
  return t == null ? null : barisDokumen(ref, t);
});
