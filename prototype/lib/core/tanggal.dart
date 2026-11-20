/// A church-local calendar date (WITA), without a time.
class Tanggal implements Comparable<Tanggal> {
  const Tanggal(this.tahun, this.bulan, this.hari);

  /// The date of a WITA wall-clock time from a [Clock].
  factory Tanggal.dari(DateTime saat) =>
      Tanggal(saat.year, saat.month, saat.day);

  final int tahun, bulan, hari;

  /// Midnight of this date as a WITA wall-clock time.
  DateTime get awal => DateTime.utc(tahun, bulan, hari);

  /// The date [n] days later (earlier when negative); month and year roll over.
  Tanggal tambahHari(int n) => Tanggal.dari(awal.add(Duration(days: n)));

  @override
  int compareTo(Tanggal other) => awal.compareTo(other.awal);

  bool operator <(Tanggal other) => compareTo(other) < 0;
  bool operator <=(Tanggal other) => compareTo(other) <= 0;
  bool operator >(Tanggal other) => compareTo(other) > 0;
  bool operator >=(Tanggal other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is Tanggal &&
      other.tahun == tahun &&
      other.bulan == bulan &&
      other.hari == hari;

  @override
  int get hashCode => Object.hash(tahun, bulan, hari);

  /// dd/mm/yyyy, as the screens write dates.
  @override
  String toString() =>
      '${hari.toString().padLeft(2, '0')}/${bulan.toString().padLeft(2, '0')}/$tahun';
}
