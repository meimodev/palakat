import 'tata.dart';

/// The modules of PMP §6 that switch screens on and off (D21). [inti] is the
/// platform core, always on.
enum ModulLayar {
  inti,
  keuangan,
  keuanganUnit,
  persetujuan,
  dokumenGereja,
  pengumuman,
  warta,
  dataJemaat,
  ibadah,
  kehadiran,
  panitia,
  laporan,
}

/// One value per app screen, not per board (README 3.6, 7.2). The comment
/// above each value names the boards it replaces. [jalur] is the route path
/// (path parameters as `:name`); [ponsel] and [web] say which route tree has a
/// screen for it (the tablet uses the web tree, README 3.2).
///
/// The board accounting check of README 11 item 7 reads this file.
enum Layar {
  // ── Core (M0–M1) ──

  /// PemilihPersona (new): the persona picker, the only way in (D7, D17).
  /// The sign-in boards Masuk, WebMasuk, AlurMasuk and WebAlurMasuk are
  /// dropped (D19); their "Masuk" links open this picker.
  pemilih('/pilih', ModulLayar.inti),

  /// BerandaJabatan + AlurBeranda (phone), WebBerandaJabatan (web): the role
  /// home, the bottom page of every stack.
  beranda('/', ModulLayar.inti),

  /// KotakMasuk, WebKotakMasuk.
  kotakMasuk('/kotak-masuk', ModulLayar.inti),

  /// AkunSaya, WebAkunSaya.
  akun('/akun', ModulLayar.inti),

  /// Keluar (child route `keluar`), WebKeluar.
  keluar('/keluar', ModulLayar.inti),

  /// Sambungan, WebSambungan: the session-ended view only (DP34).
  sesiBerakhir('/sesi-berakhir', ModulLayar.inti),

  // Guard views KeadaanUmum and WebKeadaanUmum have no Layar: the router
  // renders them in place of a screen whose module is off or whose
  // capability the actor lacks (M1).

  // ── Finance (M2–M5) ──

  /// Main (phone, a ShellRoute with child routes transaksi, catat,
  /// mata-anggaran, periksa, detail/:id); WebBeranda on web, TabBeranda on the
  /// tablet.
  keuangan('/keuangan', ModulLayar.keuangan),

  /// Main `transaksi`; WebTransaksi (tablet: TabTransaksi).
  transaksi('/keuangan/transaksi', ModulLayar.keuangan),

  /// Main `detail`; WebTransaksi with the row selected.
  transaksiRinci('/keuangan/detail/:id', ModulLayar.keuangan),

  /// Main `catat` (with `mata-anggaran` and `periksa`); WebCatat (tablet:
  /// TabCatat).
  catat('/keuangan/catat', ModulLayar.keuangan),

  /// Tanggal, WebTanggal.
  tanggal('/tanggal', ModulLayar.keuangan),

  /// Bagi, WebBagi.
  bagi('/bagi', ModulLayar.keuangan),

  /// BantuanAI, WebBantuanAI.
  bantuanAi('/bantuan-ai', ModulLayar.keuangan),

  /// AIFoto, WebAIFoto.
  aiFoto('/ai-foto', ModulLayar.keuangan),

  /// AIMataAnggaran, WebAIMataAnggaran.
  aiMataAnggaran('/ai-mata-anggaran', ModulLayar.keuangan),

  /// PilihBulan, WebPilihBulan.
  pilihBulan('/pilih-bulan', ModulLayar.keuangan),

  /// Draf, WebDraf.
  draf('/draf/:id', ModulLayar.keuangan),

  /// Pemeriksa, WebPemeriksa.
  pemeriksa('/pemeriksa', ModulLayar.keuangan),

  /// Cari, WebCari.
  cari('/cari', ModulLayar.keuangan),

  /// Persembahan (child route `hasil`), WebPersembahan.
  persembahan('/persembahan', ModulLayar.keuangan),

  /// Kewajiban (child route `kasus/:id`), WebKewajiban; `kasus/:id` is
  /// WebKasus on web.
  kewajiban('/kewajiban', ModulLayar.keuangan),

  /// KasusBaru, WebKasusBaru.
  kasusBaru('/kasus-baru', ModulLayar.keuangan),

  /// Persetujuan, WebPersetujuan.
  persetujuan('/persetujuan/:id', ModulLayar.keuangan),

  /// Koreksi (child routes pembalikan, hasil, kejadian), WebKoreksi.
  koreksi('/koreksi/:id', ModulLayar.keuangan),

  /// Pengembalian + AlurPengembalian, WebPengembalian + WebAlurPengembalian
  /// (pending RD04, D25).
  pengembalian('/pengembalian', ModulLayar.keuangan),

  /// AlihPeruntukan, WebAlihPeruntukan.
  alihPeruntukan('/alih-peruntukan', ModulLayar.keuangan),

  /// Dokumen (child route `rinci`), WebDokumen.
  dokumen('/dokumen', ModulLayar.keuangan),

  /// Kamera (child routes tinjau, unggah); on web only `unggah`, WebUnggah.
  fotoDokumen('/foto-dokumen', ModulLayar.keuangan),

  /// LihatDokumen, WebLihatDokumen.
  lihatDokumen('/lihat-dokumen/:id', ModulLayar.keuangan),

  /// Impor, WebImpor.
  impor('/impor', ModulLayar.keuangan),

  /// Ekspor, WebEkspor.
  ekspor('/ekspor', ModulLayar.keuangan),

  /// TutupBuku (child routes cek, rekonsiliasi, konfirmasi, ditutup),
  /// WebTutupBuku; `rekonsiliasi` is WebRekonsiliasi on web.
  tutupBuku('/tutup-buku', ModulLayar.keuangan),

  /// RekonIsi, WebRekonIsi.
  rekeningKoran('/rekening-koran', ModulLayar.keuangan),

  /// HitungKas (child route `banding`), WebHitungKas.
  hitungKas('/hitung-kas', ModulLayar.keuangan),

  /// Kesiapan, WebKesiapan.
  kesiapan('/kesiapan', ModulLayar.keuanganUnit),

  /// SelesaikanUnit, WebSelesaikanUnit.
  hambatanUnit('/hambatan-unit', ModulLayar.keuanganUnit),

  /// AIBulan, WebAI.
  aiBulan('/ai-bulan', ModulLayar.keuangan),

  /// Kejadian (child route `rinci`), WebKejadian.
  kejadian('/kejadian', ModulLayar.keuangan),

  /// Laporan (child route `rinci/:f`), WebLaporan.
  laporan('/laporan', ModulLayar.keuangan),

  /// WebPaketLaporan (web only).
  paketLaporan('/paket-laporan', ModulLayar.keuangan, ponsel: false),

  /// LihatTransaksi, WebLihatTransaksi.
  lihatTransaksi('/lihat-transaksi', ModulLayar.keuangan),

  /// Bukti, WebBukti.
  bukti('/bukti', ModulLayar.keuangan),

  /// FormatLaporan, WebFormatLaporan.
  formatLaporan('/format-laporan', ModulLayar.keuangan),

  /// The official and provisional report pages by `bentuk`: A4F01 (`f01`),
  /// A4F02a, A4F02b and A4F02c as one paginated F02 (`f02`), A4F14 (`f14`),
  /// A4Sementara (`sementara`), and WebExcel (`excel`).
  laporanResmi('/laporan-resmi/:periode/:bentuk', ModulLayar.keuangan),

  /// Terbatas (child route `transaksi/:no`), WebTerbatas.
  terbatas('/terbatas', ModulLayar.keuangan),

  /// A4Terbatas (`pdf`), WebExcelTerbatas (`excel`).
  laporanTerbatas('/laporan-terbatas/:periode/:bentuk', ModulLayar.keuangan),

  /// Awal (child routes tunjuk, saldo), WebAwal: read-only (D19).
  awal('/awal', ModulLayar.keuangan),

  /// AwalIsian, WebAwalIsian: read-only.
  awalIsian('/awal-isian', ModulLayar.keuangan),

  /// Lainnya (child routes kas, aturan, riwayat), WebPengaturan.
  pengaturan('/pengaturan', ModulLayar.keuangan),

  /// UbahPengaturan, WebUbahPengaturan.
  ubahPengaturan('/ubah-pengaturan', ModulLayar.keuangan),

  /// MataAnggaran (child route `rinci`), WebMataAnggaran.
  mataAnggaran('/mata-anggaran', ModulLayar.keuangan),

  /// KasUnit, WebKasUnit.
  kasUnit('/kas-unit', ModulLayar.keuanganUnit),

  /// Bendahara (child route `serah`); on web only `serah`, WebSerahTerima.
  bendahara('/bendahara', ModulLayar.keuangan),

  /// Pemberitahuan, WebPemberitahuan.
  pemberitahuan('/pemberitahuan', ModulLayar.keuangan),

  // ── C1 Operator and delegation (M6) ──

  /// Penugasan + AlurPenugasan, WebPenugasan.
  penugasan('/penugasan', ModulLayar.inti),

  /// JabatanKosong + AlurJabatanKosong, WebJabatanKosong +
  /// WebAlurJabatanKosong.
  jabatanKosong('/jabatan-kosong', ModulLayar.inti),

  /// Pelimpahan + AlurPelimpahan (phone only).
  pelimpahan('/pelimpahan', ModulLayar.inti, web: false),

  /// Modul + AlurModul (phone only).
  modul('/modul', ModulLayar.inti, web: false),

  /// CariOrang + AlurPulihkan, WebCariOrang + WebAlurPulihkan.
  cariOrang('/cari-orang', ModulLayar.inti),

  // ── Secretariat (M7) ──

  /// DokumenGereja + TerbitDokumen + AlurDokumen (phone: AlurDokumen's
  /// ShellRoute, child routes terbit and ralat), WebDokumenGereja +
  /// WebTerbitDokumen + WebAlurDokumen.
  dokumenGereja('/dokumen-gereja', ModulLayar.dokumenGereja),

  /// PermohonanSurat + AlurSurat, WebPermohonanSurat + WebAlurSurat.
  surat('/surat', ModulLayar.dokumenGereja),

  /// Pengumuman, WebPengumuman.
  pengumuman('/pengumuman', ModulLayar.pengumuman),

  /// WartaArsip, WebWartaArsip.
  warta('/warta', ModulLayar.warta),

  /// WartaEditor + AlurWarta, WebWartaEditor + WebAlurWarta.
  wartaEdisi('/warta/:edisi', ModulLayar.warta),

  /// BukaNama, WebBukaNama.
  bukaNama('/warta/:edisi/buka-nama', ModulLayar.warta),

  /// A4Warta.
  wartaPdf('/warta/:edisi/pdf', ModulLayar.warta),

  // ── Membership (M8) ──

  /// DataAnggota, WebDataAnggota.
  dataAnggota('/data-anggota', ModulLayar.dataJemaat),

  /// PermohonanAnggota + AlurAnggota (phone only): a submitted application
  /// with the verifier side reachable (DP36); the applicant side stays in the
  /// code, unreachable (O6).
  permohonanAnggota(
    '/permohonan-anggota/:id',
    ModulLayar.dataJemaat,
    web: false,
  ),

  /// ImporBuku + AlurKeluarga, WebImporBuku + WebAlurKeluarga.
  imporBuku('/impor-buku', ModulLayar.dataJemaat),

  /// KonfirmasiKeluarga (phone only).
  konfirmasiKeluarga('/konfirmasi-keluarga', ModulLayar.dataJemaat, web: false),

  /// AntreanVerifikasi (phone only).
  verifikasi('/verifikasi', ModulLayar.dataJemaat, web: false),

  /// Peristiwa + AlurPeristiwa (phone only).
  peristiwa('/peristiwa', ModulLayar.dataJemaat, web: false),

  /// DataGanda, WebDataGanda.
  dataGanda('/data-ganda', ModulLayar.dataJemaat),

  /// TampilanNama + the name-form steps of AlurNama (phone only).
  tampilanNama('/tampilan-nama', ModulLayar.dataJemaat, web: false),

  /// CabutIzin + the consent-withdrawal steps of AlurNama ("Cabut izin dan
  /// hapus data saya") (phone only).
  cabutIzin('/cabut-izin', ModulLayar.dataJemaat, web: false),

  // ── Collaboration (M9) and Joins (M10) ──

  /// KeuanganUnit + AlurUnit, WebAlurUnit.
  keuanganUnit('/keuangan-unit', ModulLayar.keuanganUnit),

  /// PermintaanDana + AlurDana (phone only).
  permintaanDana('/permintaan-dana', ModulLayar.persetujuan, web: false),

  /// PemberiPersetujuan (phone only).
  pemberiPersetujuan(
    '/pemberi-persetujuan',
    ModulLayar.persetujuan,
    web: false,
  ),

  /// Panitia + AlurPanitia + AlurPanitiaBaru (phone only).
  panitia('/panitia', ModulLayar.panitia, web: false),

  /// Ibadah + AlurIbadah (phone only).
  ibadah('/ibadah', ModulLayar.ibadah, web: false),

  /// Kehadiran (phone only).
  kehadiran('/kehadiran/:ibadah', ModulLayar.kehadiran, web: false),

  /// LaporanLintas, WebLaporanLintas.
  laporanLintas('/laporan-lintas', ModulLayar.laporan),

  /// PersembahanBernama, WebPersembahanBernama.
  persembahanBernama('/persembahan-bernama', ModulLayar.keuangan),

  /// PersembahanSaya (phone only).
  persembahanSaya('/persembahan-saya', ModulLayar.keuangan, web: false);

  const Layar(
    this.jalur,
    this.modulLayar, {
    this.ponsel = true,
    this.web = true,
  });

  final String jalur;

  /// The module the screen belongs to; M1 hides it while the module is off.
  final ModulLayar modulLayar;
  final bool ponsel;
  final bool web;

  /// Whether the route tree of [tata] has a screen for this value.
  bool adaUntuk(Tata tata) => tata == Tata.ponsel ? ponsel : web;

  /// The location: [jalur] with each `:name` replaced from [param], then the
  /// child route [anak] (`'rinci'`, `'kasus/7'`) if given.
  String lokasi({Map<String, String> param = const {}, String? anak}) {
    final dasar = jalur.replaceAllMapped(RegExp(r':(\w+)'), (m) {
      final v = param[m[1]];
      assert(v != null, 'Layar.$name: parameter ${m[1]} hilang');
      return Uri.encodeComponent(v ?? '');
    });
    if (anak == null) return dasar;
    return dasar == '/' ? '/$anak' : '$dasar/$anak';
  }
}

/// Phone screens whose board keeps its `ShellRoute` + `<Stem>Kendali`
/// (README 3.6, navigation.md 2.1). A push to one already in the stack pops
/// down to it instead (a ShellRoute has one navigator key).
const layarBerKendali = {
  Layar.keuangan,
  Layar.tutupBuku,
  Layar.awal,
  Layar.koreksi,
  Layar.hitungKas,
  Layar.pengaturan,
  Layar.mataAnggaran,
  Layar.bendahara,
  Layar.persembahan,
  Layar.kewajiban,
  Layar.terbatas,
  Layar.laporan,
  Layar.dokumen,
  Layar.kejadian,
  Layar.fotoDokumen,
  Layar.keluar,
  Layar.dokumenGereja,
};

// Papan yang dibuang: (dropped boards, README 7.1 rule 3; D5, D19, DP34)
//
// - Design sheets: PetaLayar, Cakupan, Keputusan, PetaPlatform.
// - Sign-in (the picker replaces them): Masuk, WebMasuk, AlurMasuk,
//   WebAlurMasuk, Pemulihan, WebPemulihan.
// - Internal Palakat page: WebVerifikasi.
// - Fault-only: Memuat, WebMemuat.
