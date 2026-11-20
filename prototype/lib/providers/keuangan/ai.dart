import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/finance/finance.dart';
import '../actor.dart';
import '../repositories_keuangan.dart';
import '../revision.dart';
import 'rinci_transaksi.dart';
import 'transaksi.dart';

/// This month's AI spend against the cap (BantuanAI, AIFoto,
/// AIMataAnggaran): used up when spend + cost > cap (README 4.2).
final anggaranAiProvider = Provider<AiBudget>((ref) {
  ref.watch(revisionProvider);
  return ref.watch(aiRepositoryProvider).budget();
});

/// "Bantuan AI berhenti sampai {Bulan Tahun}": the month after today.
final bulanAiLanjutProvider = Provider<String>((ref) {
  final t = ref.watch(hariIniProvider);
  final n = t.tahun * 12 + t.bulan;
  return bulanTahun(n ~/ 12, n % 12 + 1);
});

/// The day the fixed receipt and sentence proposals carry (the repository's
/// "day 6 of last month"), for the sample sentence.
final hariNotaProvider = Provider<Tanggal>((ref) {
  final t = ref.watch(hariIniProvider);
  final n = t.tahun * 12 + t.bulan - 2;
  return Tanggal(n ~/ 12, n % 12 + 1, 6);
});

/// A draft an AI board filled, as its field card prints it. An empty string
/// is "Belum diisi" (D01: Kas/Bank, peruntukan and Lingkup stay empty until
/// the person picks them).
class IsianDrafAi {
  const IsianDrafAi({
    required this.transaksi,
    required this.kasBank,
    required this.peruntukan,
    required this.lingkup,
    required this.mataAnggaran,
  });

  final Transaction transaksi;
  final String kasBank, peruntukan, lingkup;

  /// One label per part ('Belanja 5.01.02.00 Listrik, air dan telepon');
  /// empty while none is chosen.
  final List<String> mataAnggaran;

  int get jumlah => transaksi.total;
  String get pihak => transaksi.payee ?? '';
  Tanggal get tanggal => transaksi.effectiveDate;
}

final isianDrafAiProvider = Provider.family<IsianDrafAi?, String>((ref, id) {
  final r = ref.watch(rincianTransaksiProvider(id));
  final t = ref.watch(transactionRepositoryProvider).get(id);
  if (r == null || t == null) return null;
  String fakta(String kunci) {
    final f = r.fakta.where((x) => x.$1 == kunci).firstOrNull;
    return f == null || f.$3 ? '' : f.$2;
  }

  final master = ref.watch(masterRepositoryProvider);
  return IsianDrafAi(
    transaksi: t,
    kasBank: t.allocations.any((a) => t.accountOf(a) != null)
        ? r.baris.kasBank
        : '',
    peruntukan: fakta('Diambil dari peruntukan'),
    lingkup: fakta('Lingkup'),
    mataAnggaran: [
      for (final a in t.allocations)
        if (a.masterCode != null)
          labelMataAnggaran(master, a.masterCode!, t.effectiveDate),
    ],
  );
});
