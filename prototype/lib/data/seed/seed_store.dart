import '../../core/tanggal.dart';
import '../../domain/core/result.dart';
import 'tabel_inti.dart';
import 'tabel_jemaat.dart';
import 'tabel_keuangan.dart';
import 'tabel_kolaborasi.dart';
import 'tabel_sekretariat.dart';

/// The mutable in-memory state of one launch (README 3.1, 5.7): one tables
/// object per module, the id and voucher counters and the idempotency log.
/// Only the in-memory repositories change it.
class SeedStore {
  SeedStore({required this.anchor, required this.launchedAt});

  /// T, the launch date (WITA), and the launch time.
  final Tanggal anchor;
  final DateTime launchedAt;

  final inti = TabelInti();
  final keuangan = TabelKeuangan();
  final sekretariat = TabelSekretariat();
  final jemaat = TabelJemaat();
  final kolaborasi = TabelKolaborasi();

  /// Each idempotency key's first result (README 3.4): a repeated key returns
  /// it and changes nothing.
  final Map<String, Result<Object?>> idempotencyLog = {};

  final Map<String, int> _ids = {};

  /// A fresh id: 'aud-1', 'aud-2', …
  String newId(String prefix) =>
      '$prefix-${_ids.update(prefix, (n) => n + 1, ifAbsent: () => 1)}';

  /// The last number given per voucher series per year ('BKU-2027' → 3).
  final Map<String, int> voucherCounters = {};

  /// The next number of [series] in [year] (DM D08, RD13: one counter per
  /// series per year; numbers are never reused).
  int nextVoucher(String series, int year) =>
      voucherCounters.update('$series-$year', (n) => n + 1, ifAbsent: () => 1);
}
