import '../app/layar.dart';

/// One side-nav item: label, target screen and, for a child route, its path
/// under the screen (navigation.md 1.3).
typedef ItemNav = ({String teks, Layar ke, String? anak});

/// The side-nav item lists of the web screens (navigation.md 1.3,
/// "Variants"). A screen passes one by name: `NavSamping(item: navKeuangan, …)`.
const List<ItemNav> navKeuangan = [
  (teks: 'Beranda', ke: Layar.keuangan, anak: null),
  (teks: 'Transaksi', ke: Layar.transaksi, anak: null),
  (teks: 'Uang Muka dan Titipan', ke: Layar.kewajiban, anak: null),
  (teks: 'Rekonsiliasi', ke: Layar.tutupBuku, anak: 'rekonsiliasi'),
  (teks: 'Bulan dan tutup buku', ke: Layar.tutupBuku, anak: null),
  (teks: 'Laporan', ke: Layar.paketLaporan, anak: null),
  (teks: 'Pengaturan', ke: Layar.pengaturan, anak: null),
];

/// WebTerbatas: all three items point at the screen itself (kind self).
const List<ItemNav> navTerbatas = [
  (teks: 'Beranda', ke: Layar.terbatas, anak: null),
  (teks: 'Transaksi', ke: Layar.terbatas, anak: null),
  (teks: 'Laporan', ke: Layar.terbatas, anak: null),
];

/// Rounds 2 to 5. The boards' "Ibadah dan kegiatan" and "Panitia" items open
/// phone-only screens and are left out on the web (README 7.1 rule 4).
const List<ItemNav> navPlatform = [
  (teks: 'Beranda', ke: Layar.beranda, anak: null),
  (teks: 'Keuangan', ke: Layar.keuangan, anak: null),
  (teks: 'Dokumen gereja', ke: Layar.dokumenGereja, anak: null),
  (teks: 'Pengumuman', ke: Layar.pengumuman, anak: null),
  (teks: 'Warta Jemaat', ke: Layar.warta, anak: null),
  (teks: 'Data jemaat', ke: Layar.dataAnggota, anak: null),
  (teks: 'Pemberitahuan', ke: Layar.kotakMasuk, anak: null),
  (teks: 'Pengaturan', ke: Layar.penugasan, anak: null),
];
