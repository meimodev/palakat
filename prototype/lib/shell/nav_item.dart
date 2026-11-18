/// One side-nav item: label and target board stem (navigation.md 1.3).
typedef ItemNav = ({String teks, String ke});

/// The six side-nav item lists of the web boards (navigation.md 1.3,
/// "Variants"). A screen passes one by name: `NavSamping(item: navKeuangan, …)`;
/// the link test reads these lists.
const List<ItemNav> navKeuangan = [
  (teks: 'Beranda', ke: 'WebBeranda'),
  (teks: 'Transaksi', ke: 'WebTransaksi'),
  (teks: 'Uang Muka dan Titipan', ke: 'WebKewajiban'),
  (teks: 'Rekonsiliasi', ke: 'WebRekonsiliasi'),
  (teks: 'Bulan dan tutup buku', ke: 'WebTutupBuku'),
  (teks: 'Laporan', ke: 'WebPaketLaporan'),
  (teks: 'Pengaturan', ke: 'WebPengaturan'),
];

/// WebTerbatas: all three items point at the board itself (kind self).
const List<ItemNav> navTerbatas = [
  (teks: 'Beranda', ke: 'WebTerbatas'),
  (teks: 'Transaksi', ke: 'WebTerbatas'),
  (teks: 'Laporan', ke: 'WebTerbatas'),
];

const List<ItemNav> navMasuk = [(teks: 'Masuk', ke: 'WebMasuk')];

const List<ItemNav> navVerifikasi = [
  (teks: 'Verifikasi wewenang', ke: 'WebVerifikasi'),
];

/// WebPemulihan marks "Masuk" active (index 0), as the board does.
const List<ItemNav> navPemulihan = [
  (teks: 'Masuk', ke: 'WebMasuk'),
  (teks: 'Pemulihan akun', ke: 'WebPemulihan'),
];

/// Rounds 2 to 5. "Ibadah dan kegiatan" and "Panitia" open phone boards
/// (decision 26).
const List<ItemNav> navPlatform = [
  (teks: 'Beranda', ke: 'WebBerandaJabatan'),
  (teks: 'Keuangan', ke: 'WebBeranda'),
  (teks: 'Dokumen gereja', ke: 'WebDokumenGereja'),
  (teks: 'Pengumuman', ke: 'WebPengumuman'),
  (teks: 'Warta Jemaat', ke: 'WebWartaArsip'),
  (teks: 'Data jemaat', ke: 'WebDataAnggota'),
  (teks: 'Ibadah dan kegiatan', ke: 'Ibadah'),
  (teks: 'Panitia', ke: 'Panitia'),
  (teks: 'Pemberitahuan', ke: 'WebKotakMasuk'),
  (teks: 'Pengaturan', ke: 'WebPenugasan'),
];

/// Every list by its const name (for the link test and the gallery).
const Map<String, List<ItemNav>> semuaNav = {
  'navKeuangan': navKeuangan,
  'navTerbatas': navTerbatas,
  'navMasuk': navMasuk,
  'navVerifikasi': navVerifikasi,
  'navPemulihan': navPemulihan,
  'navPlatform': navPlatform,
};
