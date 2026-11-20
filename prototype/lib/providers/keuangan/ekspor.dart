import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../actor.dart';
import '../clock.dart';
import '../core_repositories.dart';
import '../repositories_keuangan.dart';
import '../revision.dart';
import 'beranda.dart';

/// The read model of Ekspor and WebEkspor (M3): what the church export
/// holds, and the posted transactions whose required document is missing
/// (the export is "belum lengkap" without them).
class DataEkspor {
  const DataEkspor({
    required this.mulai,
    required this.transaksi,
    required this.versi,
    required this.dokumen,
    required this.laporan,
    required this.tanpaDokumen,
  });

  /// 'd Bulan yyyy' of the first month in the book.
  final String mulai;

  /// The contents' descriptions.
  final String transaksi, versi, dokumen, laporan;

  final List<Transaction> tanpaDokumen;

  /// The five contents: name and description.
  List<(String, String)> get isi => [
    ('Buku', transaksi),
    ('Versi', versi),
    ('Dokumen pendukung', dokumen),
    ('Laporan', laporan),
    ('Daftar isi', 'Apa yang ada di ekspor ini, dan apa yang tidak'),
  ];
}

final eksporProvider = Provider<DataEkspor>((ref) {
  ref.watch(revisionProvider);
  final tx = ref.watch(transactionRepositoryProvider);
  final ev = ref.watch(evidenceRepositoryProvider);
  final periode = ref.watch(periodRepositoryProvider).periods();
  final semua = tx.list(null);
  final tanpa = <Transaction>[];
  var file = 0;
  for (final p in periode) {
    for (final x in ev.list(p.id, null)) {
      file += ev
          .forTransaction(x.transaction.id)
          .where((e) => e.file != null)
          .length;
      if (x.transaction.isPosted &&
          x.status == EvidenceStatus.requiredMissing) {
        tanpa.add(x.transaction);
      }
    }
  }
  final tutup = [
    for (final p in periode)
      if (p.isClosed) namaBulan(p),
  ];
  return DataEkspor(
    mulai: periode.isEmpty ? '' : tglPanjang(periode.first.start.awal),
    transaksi:
        '${semua.length} transaksi, termasuk yang dibalik dan dibatalkan',
    versi: 'Mata Anggaran, pengaturan dan aturan per bulan',
    dokumen: '$file file, masing-masing dengan checksum',
    laporan: tutup.isEmpty
        ? 'Belum ada laporan resmi'
        : 'Laporan resmi ${tutup.join(', ')}',
    tanpaDokumen: tanpa,
  );
});

/// "Buat ekspor": the manifest (its file name) or the refusal.
Future<({ExportManifest? manifest, Refusal? pesan})> buatEkspor(
  WidgetRef ref,
) async {
  final a = ref.read(actorProvider);
  if (a == null) return (manifest: null, pesan: null);
  final r = await ref
      .read(exportRepositoryProvider)
      .build(a, idempotencyKey: kunciBaru(a.personId, ref.read(clockProvider)));
  return (manifest: r.isOk ? r.value : null, pesan: r.refusal);
}
