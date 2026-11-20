import '../domain/core/capabilities.dart';
import '../domain/core/modules.dart';
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
  laporan;

  /// The switchable module behind it; null for core and reports, which are
  /// always on.
  Module? get modul => switch (this) {
    inti || laporan => null,
    keuangan => Module.finance,
    keuanganUnit => Module.unitFinance,
    persetujuan => Module.inAppApprovals,
    dokumenGereja => Module.churchDocuments,
    pengumuman => Module.announcements,
    warta => Module.warta,
    dataJemaat => Module.membership,
    ibadah => Module.services,
    kehadiran => Module.attendance,
    panitia => Module.panitia,
  };
}

/// Why the router shows the guard view in place of a screen (README 3.6):
/// [keadaan] is the KeadaanUmum / WebKeadaanUmum view it opens on.
enum Penjaga {
  modulTidakAktif('Modul tidak aktif'),
  tidakBerwenang('Tidak berwenang');

  const Penjaga(this.keadaan);

  final String keadaan;
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
  keuangan('/keuangan', ModulLayar.keuangan, kemampuan: Capability.financeView),

  /// Main `transaksi`; WebTransaksi (tablet: TabTransaksi).
  transaksi(
    '/keuangan/transaksi',
    ModulLayar.keuangan,
    kemampuan: Capability.financeView,
  ),

  /// Main `detail`; WebTransaksi with the row selected.
  transaksiRinci(
    '/keuangan/detail/:id',
    ModulLayar.keuangan,
    kemampuan: Capability.financeView,
  ),

  /// Main `catat` (with `mata-anggaran` and `periksa`); WebCatat (tablet:
  /// TabCatat).
  catat(
    '/keuangan/catat',
    ModulLayar.keuangan,
    kemampuan: Capability.financeRecord,
  ),

  /// Tanggal, WebTanggal.
  tanggal('/tanggal', ModulLayar.keuangan, kemampuan: Capability.financeRecord),

  /// Bagi, WebBagi.
  bagi('/bagi', ModulLayar.keuangan, kemampuan: Capability.financeRecord),

  /// BantuanAI, WebBantuanAI.
  bantuanAi(
    '/bantuan-ai',
    ModulLayar.keuangan,
    kemampuan: Capability.financeRecord,
  ),

  /// AIFoto, WebAIFoto.
  aiFoto('/ai-foto', ModulLayar.keuangan, kemampuan: Capability.financeRecord),

  /// AIMataAnggaran, WebAIMataAnggaran.
  aiMataAnggaran(
    '/ai-mata-anggaran',
    ModulLayar.keuangan,
    kemampuan: Capability.financeRecord,
  ),

  /// PilihBulan, WebPilihBulan.
  pilihBulan(
    '/pilih-bulan',
    ModulLayar.keuangan,
    kemampuan: Capability.financeView,
  ),

  /// Draf, WebDraf.
  draf('/draf/:id', ModulLayar.keuangan, kemampuan: Capability.financeRecord),

  /// Pemeriksa, WebPemeriksa.
  pemeriksa(
    '/pemeriksa',
    ModulLayar.keuangan,
    kemampuan: Capability.financeReview,
  ),

  /// Cari, WebCari.
  cari('/cari', ModulLayar.keuangan, kemampuan: Capability.financeView),

  /// Persembahan (child route `hasil`), WebPersembahan.
  persembahan(
    '/persembahan',
    ModulLayar.keuangan,
    kemampuan: Capability.financeRecord,
  ),

  /// Kewajiban (child route `kasus/:id`), WebKewajiban; `kasus/:id` is
  /// WebKasus on web.
  kewajiban(
    '/kewajiban',
    ModulLayar.keuangan,
    kemampuan: Capability.financeView,
  ),

  /// KasusBaru, WebKasusBaru.
  kasusBaru(
    '/kasus-baru',
    ModulLayar.keuangan,
    kemampuan: Capability.financeRecord,
  ),

  /// Persetujuan, WebPersetujuan.
  persetujuan(
    '/persetujuan/:id',
    ModulLayar.keuangan,
    kemampuan: Capability.financeRecord,
  ),

  /// Koreksi (child routes pembalikan, hasil, kejadian), WebKoreksi.
  koreksi(
    '/koreksi/:id',
    ModulLayar.keuangan,
    kemampuan: Capability.financeRecord,
  ),

  /// Pengembalian (AlurPengembalian merged into it), WebPengembalian
  /// (WebAlurPengembalian merged into it) (pending RD04, D25).
  pengembalian(
    '/pengembalian',
    ModulLayar.keuangan,
    kemampuan: Capability.financeRecord,
  ),

  /// AlihPeruntukan, WebAlihPeruntukan.
  alihPeruntukan(
    '/alih-peruntukan',
    ModulLayar.keuangan,
    kemampuan: Capability.financeRecord,
  ),

  /// Dokumen (child route `rinci`), WebDokumen.
  dokumen('/dokumen', ModulLayar.keuangan, kemampuan: Capability.financeView),

  /// Kamera (child routes tinjau, unggah); on web only `unggah`, WebUnggah.
  fotoDokumen(
    '/foto-dokumen',
    ModulLayar.keuangan,
    kemampuan: Capability.financeRecord,
  ),

  /// LihatDokumen, WebLihatDokumen.
  lihatDokumen(
    '/lihat-dokumen/:id',
    ModulLayar.keuangan,
    kemampuan: Capability.financeView,
  ),

  /// Impor, WebImpor.
  impor('/impor', ModulLayar.keuangan, kemampuan: Capability.financeRecord),

  /// Ekspor, WebEkspor.
  ekspor('/ekspor', ModulLayar.keuangan, kemampuan: Capability.export),

  /// TutupBuku (child routes cek, rekonsiliasi, konfirmasi, ditutup),
  /// WebTutupBuku; `rekonsiliasi` is WebRekonsiliasi on web.
  tutupBuku(
    '/tutup-buku',
    ModulLayar.keuangan,
    kemampuan: Capability.financeClose,
  ),

  /// RekonIsi, WebRekonIsi.
  rekeningKoran(
    '/rekening-koran',
    ModulLayar.keuangan,
    // The Pemeriksa kedua marks a session checked here (D24).
    kemampuan: Capability.financeReview,
  ),

  /// HitungKas (child route `banding`), WebHitungKas.
  hitungKas(
    '/hitung-kas',
    ModulLayar.keuangan,
    kemampuan: Capability.financeReconcile,
  ),

  /// Kesiapan, WebKesiapan.
  kesiapan(
    '/kesiapan',
    ModulLayar.keuanganUnit,
    kemampuan: Capability.unitFinanceAttest,
  ),

  /// SelesaikanUnit, WebSelesaikanUnit.
  hambatanUnit(
    '/hambatan-unit',
    ModulLayar.keuanganUnit,
    kemampuan: Capability.financeClearUnitBlocker,
  ),

  /// AIBulan, WebAI.
  aiBulan('/ai-bulan', ModulLayar.keuangan, kemampuan: Capability.financeClose),

  /// Kejadian (child route `rinci`), WebKejadian.
  kejadian(
    '/kejadian',
    ModulLayar.keuangan,
    kemampuan: Capability.financeClose,
  ),

  /// Laporan (child route `rinci/:f`), WebLaporan.
  laporan('/laporan', ModulLayar.keuangan, kemampuan: Capability.financeView),

  /// WebPaketLaporan (web only).
  paketLaporan(
    '/paket-laporan',
    ModulLayar.keuangan,
    ponsel: false,
    kemampuan: Capability.financeView,
  ),

  /// LihatTransaksi, WebLihatTransaksi.
  lihatTransaksi(
    '/lihat-transaksi',
    ModulLayar.keuangan,
    kemampuan: Capability.financeView,
  ),

  /// Bukti, WebBukti.
  bukti('/bukti', ModulLayar.keuangan, kemampuan: Capability.financeView),

  /// FormatLaporan, WebFormatLaporan.
  formatLaporan(
    '/format-laporan',
    ModulLayar.keuangan,
    kemampuan: Capability.financeView,
  ),

  /// The official and provisional report pages by `bentuk`: A4F01 (`f01`),
  /// A4F02a, A4F02b and A4F02c as one paginated F02 (`f02`), A4F14 (`f14`),
  /// A4Sementara (`sementara`), and WebExcel (`excel`).
  laporanResmi(
    '/laporan-resmi/:periode/:bentuk',
    ModulLayar.keuangan,
    kemampuan: Capability.financeView,
  ),

  /// Terbatas (child route `transaksi/:no`), WebTerbatas.
  terbatas(
    '/terbatas',
    ModulLayar.keuangan,
    kemampuan: Capability.financeViewFund,
  ),

  /// A4Terbatas (`pdf`), WebExcelTerbatas (`excel`).
  laporanTerbatas(
    '/laporan-terbatas/:periode/:bentuk',
    ModulLayar.keuangan,
    kemampuan: Capability.financeViewFund,
  ),

  /// Awal (child routes tunjuk, saldo), WebAwal: read-only (D19).
  awal('/awal', ModulLayar.keuangan, kemampuan: Capability.financeView),

  /// AwalIsian, WebAwalIsian: read-only.
  awalIsian(
    '/awal-isian',
    ModulLayar.keuangan,
    kemampuan: Capability.financeView,
  ),

  /// Lainnya (child routes kas, aturan, riwayat), WebPengaturan.
  pengaturan(
    '/pengaturan',
    ModulLayar.keuangan,
    kemampuan: Capability.financeSettings,
  ),

  /// UbahPengaturan, WebUbahPengaturan.
  ubahPengaturan(
    '/ubah-pengaturan',
    ModulLayar.keuangan,
    kemampuan: Capability.financeSettings,
  ),

  /// MataAnggaran (child route `rinci`), WebMataAnggaran.
  mataAnggaran(
    '/mata-anggaran',
    ModulLayar.keuangan,
    kemampuan: Capability.financeSettings,
  ),

  /// KasUnit, WebKasUnit.
  kasUnit(
    '/kas-unit',
    ModulLayar.keuanganUnit,
    kemampuan: Capability.financeSettings,
  ),

  /// Bendahara (child route `serah`); on web only `serah`, WebSerahTerima.
  bendahara(
    '/bendahara',
    ModulLayar.keuangan,
    kemampuan: Capability.financeHandover,
  ),

  /// Pemberitahuan, WebPemberitahuan.
  pemberitahuan(
    '/pemberitahuan',
    ModulLayar.keuangan,
    kemampuan: Capability.financeView,
  ),

  // ── C1 Operator and delegation (M6) ──

  /// Penugasan + AlurPenugasan, WebPenugasan.
  penugasan('/penugasan', ModulLayar.inti, kemampuan: Capability.assignPost),

  /// JabatanKosong + AlurJabatanKosong, WebJabatanKosong +
  /// WebAlurJabatanKosong.
  jabatanKosong(
    '/jabatan-kosong',
    ModulLayar.inti,
    kemampuan: Capability.coverVacancy,
  ),

  /// Pelimpahan + AlurPelimpahan (phone only).
  pelimpahan(
    '/pelimpahan',
    ModulLayar.inti,
    web: false,
    kemampuan: Capability.delegate,
  ),

  /// Modul + AlurModul (phone only).
  modul(
    '/modul',
    ModulLayar.inti,
    web: false,
    kemampuan: Capability.switchModule,
  ),

  /// CariOrang + AlurPulihkan, WebCariOrang + WebAlurPulihkan.
  cariOrang('/cari-orang', ModulLayar.inti, kemampuan: Capability.viewPeople),

  // ── Secretariat (M7) ──

  /// DokumenGereja + TerbitDokumen + AlurDokumen (phone: AlurDokumen's
  /// ShellRoute, child routes terbit and ralat), WebDokumenGereja +
  /// WebTerbitDokumen + WebAlurDokumen.
  dokumenGereja(
    '/dokumen-gereja',
    ModulLayar.dokumenGereja,
    kemampuan: Capability.documentsView,
  ),

  /// PermohonanSurat + AlurSurat, WebPermohonanSurat + WebAlurSurat.
  surat(
    '/surat',
    ModulLayar.dokumenGereja,
    kemampuan: Capability.documentsRequestLetter,
  ),

  /// Pengumuman, WebPengumuman.
  pengumuman(
    '/pengumuman',
    ModulLayar.pengumuman,
    kemampuan: Capability.announcementsView,
  ),

  /// WartaArsip, WebWartaArsip.
  warta('/warta', ModulLayar.warta, kemampuan: Capability.wartaView),

  /// WartaEditor + AlurWarta, WebWartaEditor + WebAlurWarta.
  wartaEdisi(
    '/warta/:edisi',
    ModulLayar.warta,
    kemampuan: Capability.wartaEdit,
  ),

  /// BukaNama, WebBukaNama.
  bukaNama(
    '/warta/:edisi/buka-nama',
    ModulLayar.warta,
    kemampuan: Capability.wartaRevealIdentity,
  ),

  /// A4Warta.
  wartaPdf(
    '/warta/:edisi/pdf',
    ModulLayar.warta,
    kemampuan: Capability.wartaView,
  ),

  // ── Membership (M8) ──

  /// DataAnggota, WebDataAnggota.
  dataAnggota(
    '/data-anggota',
    ModulLayar.dataJemaat,
    kemampuan: Capability.membershipView,
  ),

  /// PermohonanAnggota + AlurAnggota (phone only): a submitted application
  /// with the verifier side reachable (DP36); the applicant side stays in the
  /// code, unreachable (O6).
  permohonanAnggota(
    '/permohonan-anggota/:id',
    ModulLayar.dataJemaat,
    web: false,
    kemampuan: Capability.membershipVerify,
  ),

  /// ImporBuku + AlurKeluarga, WebImporBuku + WebAlurKeluarga.
  imporBuku(
    '/impor-buku',
    ModulLayar.dataJemaat,
    kemampuan: Capability.membershipImport,
  ),

  /// KonfirmasiKeluarga (phone only).
  konfirmasiKeluarga(
    '/konfirmasi-keluarga',
    ModulLayar.dataJemaat,
    web: false,
    kemampuan: Capability.membershipConfirmHousehold,
  ),

  /// AntreanVerifikasi (phone only).
  verifikasi(
    '/verifikasi',
    ModulLayar.dataJemaat,
    web: false,
    kemampuan: Capability.membershipVerify,
  ),

  /// Peristiwa + AlurPeristiwa (phone only).
  peristiwa(
    '/peristiwa',
    ModulLayar.dataJemaat,
    web: false,
    kemampuan: Capability.membershipSubmit,
  ),

  /// DataGanda, WebDataGanda.
  dataGanda(
    '/data-ganda',
    ModulLayar.dataJemaat,
    kemampuan: Capability.membershipImport,
  ),

  /// TampilanNama + the name-form steps of AlurNama (phone only).
  tampilanNama(
    '/tampilan-nama',
    ModulLayar.dataJemaat,
    web: false,
    kemampuan: Capability.membershipSubmit,
  ),

  /// CabutIzin + the consent-withdrawal steps of AlurNama ("Cabut izin dan
  /// hapus data saya") (phone only).
  cabutIzin(
    '/cabut-izin',
    ModulLayar.dataJemaat,
    web: false,
    kemampuan: Capability.membershipSubmit,
  ),

  // ── Collaboration (M9) and Joins (M10) ──

  /// KeuanganUnit + AlurUnit, WebAlurUnit.
  keuanganUnit(
    '/keuangan-unit',
    ModulLayar.keuanganUnit,
    kemampuan: Capability.unitFinanceRecord,
  ),

  /// PermintaanDana + AlurDana (phone only).
  permintaanDana('/permintaan-dana', ModulLayar.persetujuan, web: false),

  /// PemberiPersetujuan (phone only).
  pemberiPersetujuan(
    '/pemberi-persetujuan',
    ModulLayar.persetujuan,
    web: false,
    kemampuan: Capability.requestsSetTable,
  ),

  /// Panitia + AlurPanitia + AlurPanitiaBaru (phone only).
  panitia('/panitia', ModulLayar.panitia, web: false),

  /// Ibadah + AlurIbadah (phone only).
  ibadah(
    '/ibadah',
    ModulLayar.ibadah,
    web: false,
    kemampuan: Capability.servicesView,
  ),

  /// Kehadiran (phone only).
  kehadiran('/kehadiran/:ibadah', ModulLayar.kehadiran, web: false),

  /// LaporanLintas, WebLaporanLintas.
  laporanLintas(
    '/laporan-lintas',
    ModulLayar.laporan,
    kemampuan: Capability.reportsCross,
  ),

  /// PersembahanBernama, WebPersembahanBernama.
  persembahanBernama(
    '/persembahan-bernama',
    ModulLayar.keuangan,
    kemampuan: Capability.financeRecord,
  ),

  /// PersembahanSaya (phone only).
  persembahanSaya('/persembahan-saya', ModulLayar.keuangan, web: false);

  const Layar(
    this.jalur,
    this.modulLayar, {
    this.ponsel = true,
    this.web = true,
    this.kemampuan,
  });

  final String jalur;

  /// The module the screen belongs to; M1 hides it while the module is off.
  final ModulLayar modulLayar;
  final bool ponsel;
  final bool web;

  /// The capability needed to open the screen, asked in any scope (README
  /// 3.6); null when every signed-in person may open it.
  final Capability? kemampuan;

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
