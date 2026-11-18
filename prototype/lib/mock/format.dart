import 'dart:math' as math;

/// "Not known", never Rp0.
const kosong = '—';

/// The flow boards' `HARI` and `HARI_T`: today in the prototype.
const hari = 20261116, hariTeks = '16/11/2026';

const _bulan = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

/// Thousand dots for a digits string: '1250000' → '1.250.000'.
String titik(String digits) =>
    digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');

/// Board `rp(n)`: '−' (U+2212) for negatives, dot thousands, no decimals.
String rp(int n) => '${n < 0 ? '−' : ''}Rp${titik('${n.abs()}')}';

/// Flow boards' `rpT(d)`: digits string → 'Rp1.500.000'; '' → 'Rp0'.
String rpDigit(String digits) => 'Rp${titik(digits.isEmpty ? '0' : digits)}';

/// Signed with a space: '+ Rp3.150.000', '− Rp500.000'.
String rpBeda(int n) => '${n < 0 ? '−' : '+'} Rp${titik('${n.abs()}')}';

/// Board input filter: non-digits out, leading zeros out (a lone '0' stays
/// with [simpanNol]), cut to [max].
String hanyaAngka(String raw, {int max = 11, bool simpanNol = false}) {
  final d = raw
      .replaceAll(RegExp(r'\D'), '')
      .replaceFirst(RegExp(simpanNol ? r'^0+(?=\d)' : r'^0+'), '');
  return d.length > max ? d.substring(0, max) : d;
}

String _dua(int n) => n.toString().padLeft(2, '0');

/// 06/10/2026
String tgl(DateTime d) => '${_dua(d.day)}/${_dua(d.month)}/${d.year}';

/// 6 Oktober 2026
String tglPanjang(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

/// 11.05 (dot, 24 h)
String jam(DateTime d) => '${_dua(d.hour)}.${_dua(d.minute)}';

/// 16/11/2026 11.05
String tglJam(DateTime d) => '${tgl(d)} ${jam(d)}';

/// Oktober 2026
String bulanTahun(int tahun, int bulan) => '${_bulan[bulan - 1]} $tahun';

/// Flow boards' `tgl(t)`: 'dd/mm/yyyy' → yyyymmdd, null when not that shape
/// or day/month out of range (no calendar check).
int? bacaTgl(String t) {
  final m = RegExp(r'^(\d\d)/(\d\d)/(\d{4})$').firstMatch(t.trim());
  if (m == null) return null;
  final d = int.parse(m[1]!), b = int.parse(m[2]!);
  if (b < 1 || b > 12 || d < 1 || d > 31) return null;
  return int.parse(m[3]!) * 10000 + b * 100 + d;
}

/// Riwayat line of the flow boards: `'16/11/2026 · <teks>'`, newest first.
List<String> catat(List<String> riwayat, String teks) => [
  '$hariTeks · $teks',
  ...riwayat,
];

/// Masked phone: '081298765432' → '0812 ···· 5432'.
String samarHp(String n) =>
    '${n.substring(0, math.min(4, n.length))} ···· ${n.substring(math.max(0, n.length - 4))}';

/// Masked email: 'olvie@contoh.id' → 'o···@contoh.id'; '' → 'Belum diisi'.
String samarEmail(String e) {
  if (e.isEmpty) return 'Belum diisi';
  final at = e.indexOf('@');
  // JS slice(-1) when there is no '@': the last character.
  return '${e[0]}···${at < 0 ? e.substring(e.length - 1) : e.substring(at)}';
}

/// Phone check of AlurMasuk / AkunSaya.
bool hpSah(String n) => RegExp(r'^08\d{8,11}$').hasMatch(n);

/// Email check of AkunSaya.
bool emailSah(String e) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e);

/// Count-up after posting: step [i] of [n] (30 ms apart), eased 1 − (1 − i/n)³.
int hitungNaik(int dari, int ke, int i, int n) {
  final k = 1 - math.pow(1 - i / n, 3);
  return (dari + (ke - dari) * k).round();
}
