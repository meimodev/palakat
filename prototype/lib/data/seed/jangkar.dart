import '../../core/tanggal.dart';

/// The story's own today: the boards are drawn on day [_hariCerita] of
/// [_bulanCerita] [_tahunCerita], a Monday, at 12.05 (README 5.3). Seed
/// files never hold a literal date; they write story dates through these
/// anchors, which move them relative to the launch date T.
const _tahunCerita = 2026, _bulanCerita = 11, _hariCerita = 16;

/// The latest seeded time on the story's today: 12.05.
const _menitCeritaTerakhir = 12 * 60 + 5;

/// A date in M0 that remembers the story day it was drawn on, so [Jangkar.jam]
/// can keep story order when several story days land on today (README 5.3).
class TanggalCerita extends Tanggal {
  const TanggalCerita(super.tahun, super.bulan, super.hari, this.cerita);

  TanggalCerita.dari(Tanggal t, this.cerita) : super(t.tahun, t.bulan, t.hari);

  /// The drawn day of the story month (1–16 for past days).
  final int cerita;
}

/// The date anchors of README 5.3 and the clamps of 5.4, for one launch:
/// [hariIni] is T (WITA) and [sekarang] the launch time.
class Jangkar {
  Jangkar({required this.hariIni, required this.sekarang})
    : assert(Tanggal.dari(sekarang) == hariIni);

  /// T, the launch date.
  final Tanggal hariIni;

  /// Now at launch, WITA.
  final DateTime sekarang;

  /// The month M+[m] as (year, month).
  (int, int) bulan(int m) {
    final n = hariIni.tahun * 12 + (hariIni.bulan - 1) + m;
    return (n ~/ 12, n % 12 + 1);
  }

  static int _panjang(int tahun, int bulan) =>
      DateTime.utc(tahun, bulan + 1, 0).day;

  /// Day [d] of month M+[m], clamped to the month's length. In M0 the date
  /// remembers [d] as its story day.
  Tanggal bln(int m, int d) {
    final (y, b) = bulan(m);
    final hari = d.clamp(1, _panjang(y, b));
    return m == 0 ? TanggalCerita(y, b, hari, d) : Tanggal(y, b, hari);
  }

  /// The last day of month M+[m].
  Tanggal akhirBln(int m) {
    final (y, b) = bulan(m);
    return Tanggal(y, b, _panjang(y, b));
  }

  /// A history fact that only prints (member since, Baptism): unchanged.
  Tanggal sejarah(int y, int m, int d) => Tanggal(y, m, d);

  /// A drawn story date that drives a computed age or a term in force (birth
  /// dates, terms since the 1st of January): moved by the same months as M,
  /// clamped to the month, so ages and terms stay as drawn.
  Tanggal geser(int y, int m, int d) =>
      bln((y * 12 + m) - (_tahunCerita * 12 + _bulanCerita), d);

  /// The [n]th Sunday of month M+[m].
  Tanggal minggu(int m, int n) {
    final (y, b) = bulan(m);
    final satu = DateTime.utc(y, b, 1);
    final pertama = 1 + (DateTime.sunday - satu.weekday) % 7;
    final t = Tanggal(y, b, pertama + 7 * (n - 1));
    assert(t.bulan == b, 'minggu($m, $n) keluar dari bulannya');
    return t;
  }

  /// The [k]th Sunday on or before T, clamped to day 1 of M0 or later, so
  /// nothing slips into M−1 (README 5.4).
  Tanggal mingguLalu(int k) {
    final mundur = hariIni.awal.weekday % 7; // days since the last Sunday
    final t = hariIni.tambahHari(-mundur - 7 * (k - 1));
    final awal = bln(0, 1);
    return t < awal ? awal : t;
  }

  /// Today anchor for ledger rows (README 5.3): story day [d] ≤ 16 is
  /// T − (16 − d) days, clamped to day 1 of M0 or later; d > 16 is the first
  /// date on or after T + (d − 16) days on the drawn weekday.
  Tanggal hariCerita(int d) {
    if (d <= _hariCerita) {
      final t = hariIni.tambahHari(d - _hariCerita);
      final awal = bln(0, 1);
      return TanggalCerita.dari(t < awal ? awal : t, d);
    }
    final hariGambar = DateTime.utc(_tahunCerita, _bulanCerita, d).weekday;
    var t = hariIni.tambahHari(d - _hariCerita);
    while (t.awal.weekday != hariGambar) {
      t = t.tambahHari(1);
    }
    return t;
  }

  /// Today anchor for records outside the ledger (README 5.3): story day
  /// [d] ≤ 16 is T − (16 − d) days, with no clamp.
  Tanggal hariLalu(int d) {
    assert(d <= _hariCerita, 'hariLalu($d): only past story days');
    return TanggalCerita.dari(hariIni.tambahHari(d - _hariCerita), d);
  }

  /// [t] or, when it is earlier, [batas] (README 5.4: the overdue advance is
  /// never due before its issue date).
  Tanggal tidakSebelum(Tanggal t, Tanggal batas) => t < batas ? batas : t;

  /// The time [h].[m] on [t] (README 5.3). A time on today keeps its story
  /// order and is never later than now: when the story's latest time (12.05)
  /// is still to come, or story days clamp onto today (T on day 1), today's
  /// times map linearly, in story order, onto 00.00 to now.
  DateTime jam(Tanggal t, int h, int m) {
    final polos = DateTime.utc(t.tahun, t.bulan, t.hari, h, m);
    if (t != hariIni) return polos;
    final menitSekarang = sekarang.hour * 60 + sekarang.minute;
    final cerita = t is TanggalCerita ? t.cerita : _hariCerita;
    final hariAwal = hariIni.hari == 1 ? 1 : _hariCerita;
    if (hariAwal == _hariCerita && menitSekarang >= _menitCeritaTerakhir) {
      // ponytail: a stray time after now (not a story time) is pulled to now.
      return polos.isAfter(sekarang) ? sekarang : polos;
    }
    final lo = hariAwal * 1440;
    final hi = _hariCerita * 1440 + _menitCeritaTerakhir;
    final s = (cerita.clamp(hariAwal, _hariCerita) * 1440 + h * 60 + m).clamp(
      lo,
      hi,
    );
    final menit = (s - lo) * menitSekarang ~/ (hi - lo);
    return t.awal.add(Duration(minutes: menit));
  }
}
