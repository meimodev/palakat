import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../motion/halaman.dart';
import '../motion/kerangka.dart';
import '../domain/core/modules.dart';
import '../providers/actor.dart';
import '../providers/layout.dart';
import '../providers/session.dart';
import '../screens/a4/a4_f01.dart';
import '../screens/a4/a4_f02a.dart';
import '../screens/a4/a4_f14.dart';
import '../screens/a4s/a4_sementara.dart';
import '../screens/a4t/a4_terbatas.dart';
import '../screens/lanjut/bantuan_ai.dart';
import '../screens/lanjut/bukti.dart';
import '../screens/lanjut/ekspor.dart';
import '../screens/lanjut/impor.dart';
import '../screens/lanjut/kewajiban.dart';
import '../screens/lanjut/laporan.dart';
import '../screens/lanjut/pemeriksa.dart';
import '../screens/lanjut/persembahan.dart';
import '../screens/lanjut/terbatas.dart';
import '../screens/lanjut/web_ai.dart';
import '../screens/lanjut/web_bukti.dart';
import '../screens/lanjut/web_ekspor.dart';
import '../screens/lanjut/web_excel.dart';
import '../screens/lanjut/web_impor.dart';
import '../screens/lanjut/web_kewajiban.dart';
import '../screens/lanjut/web_paket_laporan.dart';
import '../screens/lanjut/web_pemeriksa.dart';
import '../screens/lanjut/web_persembahan.dart';
import '../screens/lanjut/web_terbatas.dart';
import '../screens/lengkap/ai_bulan.dart';
import '../screens/lengkap/ai_foto.dart';
import '../screens/lengkap/ai_mata_anggaran.dart';
import '../screens/lengkap/alih_peruntukan.dart';
import '../screens/lengkap/awal_isian.dart';
import '../screens/lengkap/cari.dart';
import '../screens/lengkap/dokumen.dart';
import '../screens/lengkap/draf.dart';
import '../screens/lengkap/format_laporan.dart';
import '../screens/lengkap/kamera.dart';
import '../screens/lengkap/kasus_baru.dart';
import '../screens/lengkap/kejadian.dart';
import '../screens/lengkap/keluar.dart';
import '../screens/lengkap/lihat_dokumen.dart';
import '../screens/lengkap/lihat_transaksi.dart';
import '../screens/lengkap/pemberitahuan.dart';
import '../screens/lengkap/pengembalian.dart';
import '../screens/lengkap/persetujuan.dart';
import '../screens/lengkap/pilih_bulan.dart';
import '../screens/lengkap/rekon_isi.dart';
import '../screens/lengkap/sambungan.dart';
import '../screens/lengkap/tanggal.dart';
import '../screens/lengkap/ubah_pengaturan.dart';
import '../screens/lengkap/web_ai_foto.dart';
import '../screens/lengkap/web_ai_mata_anggaran.dart';
import '../screens/lengkap/web_alih_peruntukan.dart';
import '../screens/lengkap/web_awal_isian.dart';
import '../screens/lengkap/web_bagi.dart';
import '../screens/lengkap/web_bantuan_ai.dart';
import '../screens/lengkap/web_cari.dart';
import '../screens/lengkap/web_catat.dart';
import '../screens/lengkap/web_dokumen.dart';
import '../screens/lengkap/web_draf.dart';
import '../screens/lengkap/web_excel_terbatas.dart';
import '../screens/lengkap/web_format_laporan.dart';
import '../screens/lengkap/web_kasus.dart';
import '../screens/lengkap/web_kasus_baru.dart';
import '../screens/lengkap/web_kejadian.dart';
import '../screens/lengkap/web_keluar.dart';
import '../screens/lengkap/web_koreksi.dart';
import '../screens/lengkap/web_lihat_dokumen.dart';
import '../screens/lengkap/web_lihat_transaksi.dart';
import '../screens/lengkap/web_pemberitahuan.dart';
import '../screens/lengkap/web_pengembalian.dart';
import '../screens/lengkap/web_persetujuan.dart';
import '../screens/lengkap/web_pilih_bulan.dart';
import '../screens/lengkap/web_rekon_isi.dart';
import '../screens/lengkap/web_sambungan.dart';
import '../screens/lengkap/web_serah_terima.dart';
import '../screens/lengkap/web_tanggal.dart';
import '../screens/lengkap/web_ubah_pengaturan.dart';
import '../screens/lengkap/web_unggah.dart';
import '../screens/p2/akun_saya.dart';
import '../screens/p2/beranda_jabatan.dart';
import '../screens/p2/cari_orang.dart';
import '../screens/p2/jabatan_kosong.dart';
import '../screens/p2/keadaan_umum.dart';
import '../screens/p2/kotak_masuk.dart';
import '../screens/p2/modul.dart';
import '../screens/p2/pelimpahan.dart';
import '../screens/p2/penugasan.dart';
import '../screens/p2/web_akun_saya.dart';
import '../screens/p2/web_beranda_jabatan.dart';
import '../screens/p2/web_cari_orang.dart';
import '../screens/p2/web_jabatan_kosong.dart';
import '../screens/p2/web_keadaan_umum.dart';
import '../screens/p2/web_kotak_masuk.dart';
import '../screens/p2/web_penugasan.dart';
import '../screens/p3/a4_warta.dart';
import '../screens/p3/alur_dokumen.dart';
import '../screens/p3/buka_nama.dart';
import '../screens/p3/dokumen_gereja.dart';
import '../screens/p3/pengumuman.dart';
import '../screens/p3/permohonan_surat.dart';
import '../screens/p3/warta_arsip.dart';
import '../screens/p3/warta_editor.dart';
import '../screens/p3/web_buka_nama.dart';
import '../screens/p3/web_dokumen_gereja.dart';
import '../screens/p3/web_pengumuman.dart';
import '../screens/p3/web_permohonan_surat.dart';
import '../screens/p3/web_terbit_dokumen.dart';
import '../screens/p3/web_warta_arsip.dart';
import '../screens/p3/web_warta_editor.dart';
import '../screens/p4/antrean_verifikasi.dart';
import '../screens/p4/cabut_izin.dart';
import '../screens/p4/data_anggota.dart';
import '../screens/p4/data_ganda.dart';
import '../screens/p4/impor_buku.dart';
import '../screens/p4/konfirmasi_keluarga.dart';
import '../screens/p4/peristiwa.dart';
import '../screens/p4/permohonan_anggota.dart';
import '../screens/p4/persembahan_saya.dart';
import '../screens/p4/tampilan_nama.dart';
import '../screens/p4/web_data_anggota.dart';
import '../screens/p4/web_data_ganda.dart';
import '../screens/p4/web_impor_buku.dart';
import '../screens/p5/ibadah.dart';
import '../screens/p5/kas_unit.dart';
import '../screens/p5/kehadiran.dart';
import '../screens/p5/kesiapan.dart';
import '../screens/p5/keuangan_unit.dart';
import '../screens/p5/laporan_lintas.dart';
import '../screens/p5/panitia.dart';
import '../screens/p5/pemberi_persetujuan.dart';
import '../screens/p5/permintaan_dana.dart';
import '../screens/p5/persembahan_bernama.dart';
import '../screens/p5/selesaikan_unit.dart';
import '../screens/p5/web_alur_unit.dart';
import '../screens/p5/web_kas_unit.dart';
import '../screens/p5/web_kesiapan.dart';
import '../screens/p5/web_laporan_lintas.dart';
import '../screens/p5/web_persembahan_bernama.dart';
import '../screens/p5/web_selesaikan_unit.dart';
import '../screens/pemilih/pemilih_persona.dart';
import '../screens/ponsel/awal.dart';
import '../screens/ponsel/bagi.dart';
import '../screens/ponsel/bendahara.dart';
import '../screens/ponsel/hitung_kas.dart';
import '../screens/ponsel/koreksi.dart';
import '../screens/ponsel/lainnya.dart';
import '../screens/ponsel/main.dart';
import '../screens/ponsel/mata_anggaran.dart';
import '../screens/ponsel/tutup_buku.dart';
import '../screens/web/tab_beranda.dart';
import '../screens/web/tab_catat.dart';
import '../screens/web/tab_transaksi.dart';
import '../screens/web/web_awal.dart';
import '../screens/web/web_beranda.dart';
import '../screens/web/web_hitung_kas.dart';
import '../screens/web/web_laporan.dart';
import '../screens/web/web_mata_anggaran.dart';
import '../screens/web/web_pengaturan.dart';
import '../screens/web/web_rekonsiliasi.dart';
import '../screens/web/web_transaksi.dart';
import '../screens/web/web_tutup_buku.dart';
import '../shell/tidak_ditemukan.dart';
import '../theme/palakat_tokens.dart';
import 'layar.dart';
import 'tata.dart';

/// The app's router (README 3.6): one route tree for [Tata.ponsel] and one for
/// the web and the tablet, registering the same paths. Without a session every
/// location shows the picker; with one, the picker redirects home.
final routerProvider = Provider<GoRouter>((ref) {
  final tata = ref.watch(layoutProvider);
  // Follows the session (sign-in, sign-out, the session ending) and module
  // status (README 3.6).
  final segar = ValueNotifier(0);
  ref.listen(sessionProvider, (_, _) => segar.value++);
  ref.listen(
    canProvider.select(
      (c) => [for (final m in Module.values) c.moduleActive(m)].join(),
    ),
    (_, _) => segar.value++,
  );
  final router = GoRouter(
    initialLocation: Layar.beranda.jalur,
    refreshListenable: segar,
    redirect: (context, state) {
      final sesi = ref.read(sessionProvider);
      final di = state.matchedLocation;
      final pilih = Layar.pemilih.jalur, akhir = Layar.sesiBerakhir.jalur;
      if (sesi == null) return di == pilih ? null : pilih;
      if (sesi.berakhir) return di == akhir ? null : akhir;
      return di == pilih || di == akhir ? Layar.beranda.jalur : null;
    },
    errorBuilder: (context, state) =>
        TidakDitemukanScreen(lokasi: state.uri.toString()),
    routes: [
      GoRoute(
        path: Layar.pemilih.jalur,
        pageBuilder: (c, s) => halaman(c, s, const PemilihPersonaScreen()),
      ),
      if (tata == Tata.ponsel)
        GoRoute(
          path: Layar.beranda.jalur,
          pageBuilder: (c, s) => _p(c, s, const BerandaJabatanScreen()),
          routes: _ponsel(),
        )
      else
        GoRoute(
          path: Layar.beranda.jalur,
          pageBuilder: (c, s) => halaman(c, s, const WebBerandaJabatanScreen()),
          routes: _web(tablet: tata == Tata.tablet),
        ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    segar.dispose();
  });
  return router;
});

/// Shows [child], or the guard view (KeadaanUmum on the phone, WebKeadaanUmum
/// on web and tablet) when [layar]'s module is not active or the actor lacks
/// its capability (README 3.6).
class _Dijaga extends ConsumerWidget {
  const _Dijaga(this.layar, this.child);

  final Layar layar;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(penjagaProvider(layar));
    if (p == null) return child;
    return ref.watch(layoutProvider) == Tata.ponsel
        ? KeadaanUmumScreen(key: ValueKey(p), penjaga: p)
        : WebKeadaanUmumScreen(key: ValueKey(p), penjaga: p);
  }
}

// ---------- Helpers ----------

/// A phone page: the boards' `masuk` entrance.
Page<void> _p(BuildContext c, GoRouterState s, Widget w) =>
    halaman(c, s, w, kerangka: Kerangka.masuk);

/// A route for [l], its path relative to [induk] (default: the home `/`).
/// [web] pages and A4 pages have no entrance; phone pages use [_p].
GoRoute _r(
  Layar l,
  Widget Function(GoRouterState s) w, {
  bool ponsel = false,
  Layar induk = Layar.beranda,
  List<RouteBase> routes = const [],
}) => GoRoute(
  path: _relatif(l.jalur, induk.jalur),
  pageBuilder: (c, s) =>
      ponsel ? _p(c, s, _Dijaga(l, w(s))) : halaman(c, s, _Dijaga(l, w(s))),
  routes: routes,
);

String _relatif(String jalur, String induk) =>
    jalur.substring(induk == '/' ? 1 : induk.length + 1);

/// A child route of a phone board with a `<Stem>Kendali` (navigation.md 2.2,
/// "Child routes"): entrance [kerangka], [ms] and [kurva] from the block.
GoRoute _anak(
  String jalur,
  Widget Function(GoRouterState s) w, {
  Bingkai? kerangka,
  int ms = 280,
  Curve kurva = PalakatMotion.keluar,
  bool tanpaGerak = false,
}) => GoRoute(
  path: jalur,
  pageBuilder: (c, s) => halaman(
    c,
    s,
    w(s),
    kerangka: tanpaGerak ? null : (kerangka ?? Kerangka.masuk),
    lama: Duration(milliseconds: ms),
    kurva: kurva,
  ),
);

/// A phone board with child routes: `ShellRoute(<Stem>Kendali)` around the
/// board's root route and its children.
ShellRoute _kendali(
  Layar l,
  Widget Function(Widget child) kendali,
  Widget Function(String? anak, Map<String, String> param) layar,
  List<(String, ({Bingkai? kerangka, int ms, Curve kurva, bool tanpaGerak}))>
  anak,
) => ShellRoute(
  builder: (_, _, child) => _Dijaga(l, kendali(child)),
  routes: [
    GoRoute(
      path: _relatif(l.jalur, '/'),
      pageBuilder: (c, s) => _p(c, s, layar(null, s.pathParameters)),
      routes: [
        for (final (jalur, g) in anak)
          _anak(
            jalur,
            (s) => layar(jalur, s.pathParameters),
            kerangka: g.kerangka,
            ms: g.ms,
            kurva: g.kurva,
            tanpaGerak: g.tanpaGerak,
          ),
      ],
    ),
  ],
);

const _biasa = (
  kerangka: null,
  ms: 280,
  kurva: PalakatMotion.keluar,
  tanpaGerak: false,
);
const _diam = (
  kerangka: null,
  ms: 280,
  kurva: PalakatMotion.keluar,
  tanpaGerak: true,
);
final _pudar200 = (
  kerangka: Kerangka.pudar,
  ms: 200,
  kurva: Curves.ease,
  tanpaGerak: false,
);

/// `laporanResmi` by `bentuk` (README 7.2): F02 is the paginated A4F02aScreen.
Widget _laporanResmi(GoRouterState s) => switch (s.pathParameters['bentuk']) {
  'f02' => const A4F02aScreen(),
  'f14' => const A4F14Screen(),
  'sementara' => const A4SementaraScreen(),
  'excel' => const WebExcelScreen(),
  _ => const A4F01Screen(),
};

Widget _laporanTerbatas(GoRouterState s) =>
    s.pathParameters['bentuk'] == 'excel'
    ? const WebExcelTerbatasScreen()
    : const A4TerbatasScreen();

// ---------- Phone tree (Tata.ponsel) ----------

List<RouteBase> _ponsel() => [
  _r(Layar.kotakMasuk, (_) => const KotakMasukScreen(), ponsel: true),
  _r(Layar.akun, (_) => const AkunSayaScreen(), ponsel: true),
  _kendali(
    Layar.keluar,
    (c) => KeluarKendali(child: c),
    (a, p) => KeluarScreen(anak: a, param: p),
    [
      (
        'keluar',
        (
          kerangka: Kerangka.pudar,
          ms: 250,
          kurva: Curves.ease,
          tanpaGerak: false,
        ),
      ),
    ],
  ),
  _r(Layar.sesiBerakhir, (_) => const SambunganScreen(), ponsel: true),
  // Finance
  _kendali(
    Layar.keuangan,
    (c) => MainKendali(child: c),
    (a, p) => MainScreen(anak: a, param: p),
    [
      ('transaksi', _pudar200),
      ('catat', _biasa),
      (
        'mata-anggaran',
        (
          kerangka: Kerangka.naik,
          ms: 280,
          kurva: PalakatMotion.keluar,
          tanpaGerak: false,
        ),
      ),
      ('periksa', _biasa),
      ('detail/:id', _biasa),
    ],
  ),
  _r(Layar.tanggal, (_) => const TanggalScreen(), ponsel: true),
  _r(Layar.bagi, (_) => const BagiScreen(), ponsel: true),
  _r(Layar.bantuanAi, (_) => const BantuanAIScreen(), ponsel: true),
  _r(Layar.aiFoto, (_) => const AIFotoScreen(), ponsel: true),
  _r(Layar.aiMataAnggaran, (_) => const AIMataAnggaranScreen(), ponsel: true),
  _r(Layar.pilihBulan, (_) => const PilihBulanScreen(), ponsel: true),
  _r(Layar.draf, (_) => const DrafScreen(), ponsel: true),
  _r(Layar.pemeriksa, (_) => const PemeriksaScreen(), ponsel: true),
  _r(Layar.cari, (_) => const CariScreen(), ponsel: true),
  _kendali(
    Layar.persembahan,
    (c) => PersembahanKendali(child: c),
    (a, p) => PersembahanScreen(anak: a, param: p),
    [('hasil', _biasa)],
  ),
  _kendali(
    Layar.kewajiban,
    (c) => KewajibanKendali(child: c),
    (a, p) => KewajibanScreen(anak: a, param: p),
    [('kasus/:id', _biasa)],
  ),
  _r(Layar.kasusBaru, (_) => const KasusBaruScreen(), ponsel: true),
  _r(Layar.persetujuan, (_) => const PersetujuanScreen(), ponsel: true),
  _kendali(
    Layar.koreksi,
    (c) => KoreksiKendali(child: c),
    (a, p) => KoreksiScreen(anak: a, param: p),
    [('pembalikan', _biasa), ('hasil', _pudar200), ('kejadian', _biasa)],
  ),
  _r(Layar.pengembalian, (_) => const PengembalianScreen(), ponsel: true),
  _r(Layar.alihPeruntukan, (_) => const AlihPeruntukanScreen(), ponsel: true),
  _kendali(
    Layar.dokumen,
    (c) => DokumenKendali(child: c),
    (a, p) => DokumenScreen(anak: a, param: p),
    [('rinci', _biasa)],
  ),
  _kendali(
    Layar.fotoDokumen,
    (c) => KameraKendali(child: c),
    (a, p) => KameraScreen(anak: a, param: p),
    [('tinjau', _diam), ('unggah', _diam)],
  ),
  _r(Layar.lihatDokumen, (_) => const LihatDokumenScreen(), ponsel: true),
  _r(Layar.impor, (_) => const ImporScreen(), ponsel: true),
  _r(Layar.ekspor, (_) => const EksporScreen(), ponsel: true),
  _kendali(
    Layar.tutupBuku,
    (c) => TutupBukuKendali(child: c),
    (a, p) => TutupBukuScreen(anak: a, param: p),
    [
      ('cek', _biasa),
      ('rekonsiliasi', _biasa),
      ('konfirmasi', _biasa),
      ('ditutup', _diam),
    ],
  ),
  _r(Layar.rekeningKoran, (_) => const RekonIsiScreen(), ponsel: true),
  _kendali(
    Layar.hitungKas,
    (c) => HitungKasKendali(child: c),
    (a, p) => HitungKasScreen(anak: a, param: p),
    [('banding', _biasa)],
  ),
  _r(Layar.kesiapan, (_) => const KesiapanScreen(), ponsel: true),
  _r(Layar.hambatanUnit, (_) => const SelesaikanUnitScreen(), ponsel: true),
  _r(Layar.aiBulan, (_) => const AIBulanScreen(), ponsel: true),
  _kendali(
    Layar.kejadian,
    (c) => KejadianKendali(child: c),
    (a, p) => KejadianScreen(anak: a, param: p),
    [('rinci', _biasa)],
  ),
  _kendali(
    Layar.laporan,
    (c) => LaporanKendali(child: c),
    (a, p) => LaporanScreen(anak: a, param: p),
    [('rinci/:f', _biasa)],
  ),
  _r(Layar.lihatTransaksi, (_) => const LihatTransaksiScreen(), ponsel: true),
  _r(Layar.bukti, (_) => const BuktiScreen(), ponsel: true),
  _r(Layar.formatLaporan, (_) => const FormatLaporanScreen(), ponsel: true),
  _r(Layar.laporanResmi, _laporanResmi),
  _kendali(
    Layar.terbatas,
    (c) => TerbatasKendali(child: c),
    (a, p) => TerbatasScreen(anak: a, param: p),
    [('transaksi/:no', _biasa)],
  ),
  _r(Layar.laporanTerbatas, _laporanTerbatas),
  _kendali(
    Layar.awal,
    (c) => AwalKendali(child: c),
    (a, p) => AwalScreen(anak: a, param: p),
    [('tunjuk', _biasa), ('saldo', _biasa)],
  ),
  _r(Layar.awalIsian, (_) => const AwalIsianScreen(), ponsel: true),
  _kendali(
    Layar.pengaturan,
    (c) => LainnyaKendali(child: c),
    (a, p) => LainnyaScreen(anak: a, param: p),
    [('kas', _biasa), ('aturan', _biasa), ('riwayat', _biasa)],
  ),
  _r(Layar.ubahPengaturan, (_) => const UbahPengaturanScreen(), ponsel: true),
  _kendali(
    Layar.mataAnggaran,
    (c) => MataAnggaranKendali(child: c),
    (a, p) => MataAnggaranScreen(anak: a, param: p),
    [('rinci', _biasa)],
  ),
  _r(Layar.kasUnit, (_) => const KasUnitScreen(), ponsel: true),
  _kendali(
    Layar.bendahara,
    (c) => BendaharaKendali(child: c),
    (a, p) => BendaharaScreen(anak: a, param: p),
    [('serah', _biasa)],
  ),
  _r(Layar.pemberitahuan, (_) => const PemberitahuanScreen(), ponsel: true),
  // C1
  _r(Layar.penugasan, (_) => const PenugasanScreen(), ponsel: true),
  _r(Layar.jabatanKosong, (_) => const JabatanKosongScreen(), ponsel: true),
  _r(Layar.pelimpahan, (_) => const PelimpahanScreen(), ponsel: true),
  _r(Layar.modul, (_) => const ModulScreen(), ponsel: true),
  _r(Layar.cariOrang, (_) => const CariOrangScreen(), ponsel: true),
  // Secretariat: DokumenGereja is the root page inside AlurDokumen's shell,
  // whose `terbit` and `ralat` views are the child routes (merged in M7).
  _kendali(
    Layar.dokumenGereja,
    (c) => AlurDokumenKendali(child: c),
    (a, p) => a == null
        ? const DokumenGerejaScreen()
        : AlurDokumenScreen(anak: a, param: p),
    [('terbit', _diam), ('ralat', _diam)],
  ),
  _r(Layar.surat, (_) => const PermohonanSuratScreen(), ponsel: true),
  _r(Layar.pengumuman, (_) => const PengumumanScreen(), ponsel: true),
  _r(
    Layar.warta,
    (_) => const WartaArsipScreen(),
    ponsel: true,
    routes: [
      _r(
        Layar.wartaEdisi,
        (_) => const WartaEditorScreen(),
        ponsel: true,
        induk: Layar.warta,
        routes: [
          _r(
            Layar.bukaNama,
            (_) => const BukaNamaScreen(),
            ponsel: true,
            induk: Layar.wartaEdisi,
          ),
          _r(
            Layar.wartaPdf,
            (_) => const A4WartaScreen(),
            induk: Layar.wartaEdisi,
          ),
        ],
      ),
    ],
  ),
  // Membership
  _r(Layar.dataAnggota, (_) => const DataAnggotaScreen(), ponsel: true),
  _r(
    Layar.permohonanAnggota,
    (_) => const PermohonanAnggotaScreen(),
    ponsel: true,
  ),
  _r(Layar.imporBuku, (_) => const ImporBukuScreen(), ponsel: true),
  _r(
    Layar.konfirmasiKeluarga,
    (_) => const KonfirmasiKeluargaScreen(),
    ponsel: true,
  ),
  _r(Layar.verifikasi, (_) => const AntreanVerifikasiScreen(), ponsel: true),
  _r(Layar.peristiwa, (_) => const PeristiwaScreen(), ponsel: true),
  _r(Layar.dataGanda, (_) => const DataGandaScreen(), ponsel: true),
  _r(Layar.tampilanNama, (_) => const TampilanNamaScreen(), ponsel: true),
  _r(Layar.cabutIzin, (_) => const CabutIzinScreen(), ponsel: true),
  // Collaboration and joins
  _r(Layar.keuanganUnit, (_) => const KeuanganUnitScreen(), ponsel: true),
  _r(Layar.permintaanDana, (_) => const PermintaanDanaScreen(), ponsel: true),
  _r(
    Layar.pemberiPersetujuan,
    (_) => const PemberiPersetujuanScreen(),
    ponsel: true,
  ),
  _r(Layar.panitia, (_) => const PanitiaScreen(), ponsel: true),
  _r(Layar.ibadah, (_) => const IbadahScreen(), ponsel: true),
  _r(Layar.kehadiran, (_) => const KehadiranScreen(), ponsel: true),
  _r(Layar.laporanLintas, (_) => const LaporanLintasScreen(), ponsel: true),
  _r(
    Layar.persembahanBernama,
    (_) => const PersembahanBernamaScreen(),
    ponsel: true,
  ),
  _r(Layar.persembahanSaya, (_) => const PersembahanSayaScreen(), ponsel: true),
];

// ---------- Web tree (Tata.web and Tata.tablet) ----------

List<RouteBase> _web({required bool tablet}) => [
  _r(Layar.kotakMasuk, (_) => const WebKotakMasukScreen()),
  _r(Layar.akun, (_) => const WebAkunSayaScreen()),
  _r(Layar.keluar, (_) => const WebKeluarScreen()),
  _r(Layar.sesiBerakhir, (_) => const WebSambunganScreen()),
  // Finance
  _r(
    Layar.keuangan,
    (_) => tablet ? const TabBerandaScreen() : const WebBerandaScreen(),
    routes: [
      _r(
        Layar.transaksi,
        (_) => tablet ? const TabTransaksiScreen() : const WebTransaksiScreen(),
        induk: Layar.keuangan,
      ),
      _r(
        Layar.transaksiRinci,
        (_) => const WebTransaksiScreen(),
        induk: Layar.keuangan,
      ),
      _r(
        Layar.catat,
        (_) => tablet ? const TabCatatScreen() : const WebCatatScreen(),
        induk: Layar.keuangan,
      ),
    ],
  ),
  _r(Layar.tanggal, (_) => const WebTanggalScreen()),
  _r(Layar.bagi, (_) => const WebBagiScreen()),
  _r(Layar.bantuanAi, (_) => const WebBantuanAIScreen()),
  _r(Layar.aiFoto, (_) => const WebAIFotoScreen()),
  _r(Layar.aiMataAnggaran, (_) => const WebAIMataAnggaranScreen()),
  _r(Layar.pilihBulan, (_) => const WebPilihBulanScreen()),
  _r(Layar.draf, (_) => const WebDrafScreen()),
  _r(Layar.pemeriksa, (_) => const WebPemeriksaScreen()),
  _r(Layar.cari, (_) => const WebCariScreen()),
  _r(Layar.persembahan, (_) => const WebPersembahanScreen()),
  _r(
    Layar.kewajiban,
    (_) => const WebKewajibanScreen(),
    routes: [
      GoRoute(
        path: 'kasus/:id',
        pageBuilder: _halaman(Layar.kewajiban, const WebKasusScreen()),
      ),
    ],
  ),
  _r(Layar.kasusBaru, (_) => const WebKasusBaruScreen()),
  _r(Layar.persetujuan, (_) => const WebPersetujuanScreen()),
  _r(Layar.koreksi, (_) => const WebKoreksiScreen()),
  _r(Layar.pengembalian, (_) => const WebPengembalianScreen()),
  _r(Layar.alihPeruntukan, (_) => const WebAlihPeruntukanScreen()),
  _r(Layar.dokumen, (_) => const WebDokumenScreen()),
  GoRoute(
    path: _relatif(Layar.fotoDokumen.lokasi(anak: 'unggah'), '/'),
    pageBuilder: _halaman(Layar.fotoDokumen, const WebUnggahScreen()),
  ),
  _r(Layar.lihatDokumen, (_) => const WebLihatDokumenScreen()),
  _r(Layar.impor, (_) => const WebImporScreen()),
  _r(Layar.ekspor, (_) => const WebEksporScreen()),
  _r(
    Layar.tutupBuku,
    (_) => const WebTutupBukuScreen(),
    routes: [
      GoRoute(
        path: 'rekonsiliasi',
        pageBuilder: _halaman(Layar.tutupBuku, const WebRekonsiliasiScreen()),
      ),
    ],
  ),
  _r(Layar.rekeningKoran, (_) => const WebRekonIsiScreen()),
  _r(Layar.hitungKas, (_) => const WebHitungKasScreen()),
  _r(Layar.kesiapan, (_) => const WebKesiapanScreen()),
  _r(Layar.hambatanUnit, (_) => const WebSelesaikanUnitScreen()),
  _r(Layar.aiBulan, (_) => const WebAIScreen()),
  _r(Layar.kejadian, (_) => const WebKejadianScreen()),
  _r(Layar.laporan, (_) => const WebLaporanScreen()),
  _r(Layar.paketLaporan, (_) => const WebPaketLaporanScreen()),
  _r(Layar.lihatTransaksi, (_) => const WebLihatTransaksiScreen()),
  _r(Layar.bukti, (_) => const WebBuktiScreen()),
  _r(Layar.formatLaporan, (_) => const WebFormatLaporanScreen()),
  _r(Layar.laporanResmi, _laporanResmi),
  _r(Layar.terbatas, (_) => const WebTerbatasScreen()),
  _r(Layar.laporanTerbatas, _laporanTerbatas),
  _r(Layar.awal, (_) => const WebAwalScreen()),
  _r(Layar.awalIsian, (_) => const WebAwalIsianScreen()),
  _r(Layar.pengaturan, (_) => const WebPengaturanScreen()),
  _r(Layar.ubahPengaturan, (_) => const WebUbahPengaturanScreen()),
  _r(Layar.mataAnggaran, (_) => const WebMataAnggaranScreen()),
  _r(Layar.kasUnit, (_) => const WebKasUnitScreen()),
  GoRoute(
    path: _relatif(Layar.bendahara.lokasi(anak: 'serah'), '/'),
    pageBuilder: _halaman(Layar.bendahara, const WebSerahTerimaScreen()),
  ),
  _r(Layar.pemberitahuan, (_) => const WebPemberitahuanScreen()),
  // C1
  _r(Layar.penugasan, (_) => const WebPenugasanScreen()),
  _r(Layar.jabatanKosong, (_) => const WebJabatanKosongScreen()),
  _r(Layar.cariOrang, (_) => const WebCariOrangScreen()),
  // Secretariat
  _r(
    Layar.dokumenGereja,
    (_) => const WebDokumenGerejaScreen(),
    routes: [
      GoRoute(
        path: 'terbit',
        pageBuilder: _halaman(
          Layar.dokumenGereja,
          const WebTerbitDokumenScreen(),
        ),
      ),
    ],
  ),
  _r(Layar.surat, (_) => const WebPermohonanSuratScreen()),
  _r(Layar.pengumuman, (_) => const WebPengumumanScreen()),
  _r(
    Layar.warta,
    (_) => const WebWartaArsipScreen(),
    routes: [
      _r(
        Layar.wartaEdisi,
        (_) => const WebWartaEditorScreen(),
        induk: Layar.warta,
        routes: [
          _r(
            Layar.bukaNama,
            (_) => const WebBukaNamaScreen(),
            induk: Layar.wartaEdisi,
          ),
          _r(
            Layar.wartaPdf,
            (_) => const A4WartaScreen(),
            induk: Layar.wartaEdisi,
          ),
        ],
      ),
    ],
  ),
  // Membership
  _r(Layar.dataAnggota, (_) => const WebDataAnggotaScreen()),
  _r(Layar.imporBuku, (_) => const WebImporBukuScreen()),
  _r(Layar.dataGanda, (_) => const WebDataGandaScreen()),
  // Collaboration and joins
  _r(Layar.keuanganUnit, (_) => const WebAlurUnitScreen()),
  _r(Layar.laporanLintas, (_) => const WebLaporanLintasScreen()),
  _r(Layar.persembahanBernama, (_) => const WebPersembahanBernamaScreen()),
];

/// A web child page of [l], behind [l]'s guard.
Page<void> Function(BuildContext, GoRouterState) _halaman(Layar l, Widget w) =>
    (c, s) => halaman(c, s, _Dijaga(l, w));
