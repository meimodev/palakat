import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/layar.dart';
import '../domain/core/core.dart';
import '../widgets/ikon_data.dart';
import 'actor.dart';
import 'home_rows.dart';
import 'keuangan/beranda.dart';

/// The phone home and its bottom bar (owner change 21/11, README 7.3): one
/// home at `/` for every persona, with a bar for every persona.

/// True when the actor's phone home is the finance home (Main's Beranda):
/// they can act as the church's Bendahara (they hold the Bendahara Jemaat
/// post, or an Operator covers it while vacant) and the finance home opens
/// for them.
final berandaKeuanganPonselProvider = Provider<bool>((ref) {
  final a = ref.watch(actorProvider);
  if (a == null) return false;
  final can = ref.watch(canProvider);
  final bendahara = can
      .grantsOf(a.personId, at: ref.watch(hariIniProvider))
      .any(
        (g) =>
            (g.kind == GrantKind.assignment || g.kind == GrantKind.cover) &&
            can.facts.post(g.postId!)?.role == Role.bendaharaJemaat,
      );
  return bendahara && ref.watch(penjagaProvider(Layar.keuangan)) == null;
});

/// One bar item of a non-finance home: label, the screen it opens with
/// `Cara.ganti` (and its child route), and its icon.
typedef ItemBilahPonsel = ({
  String teks,
  Layar ke,
  String? anak,
  IkonData ikon,
});

/// A post or delegation the actor acts in, as the bar table reads it.
typedef _Pos = ({Role? peran, ScopeType? jenis, bool pelimpahan});

ItemBilahPonsel _i(String teks, Layar ke, IkonData ikon, {String? anak}) =>
    (teks: teks, ke: ke, anak: anak, ikon: ikon);

/// The owner's bar table (21/11), in priority order: the first row that
/// matches a post the actor holds gives the module tab and the raised
/// action. Held posts and delegations count; a vacancy cover counts only for
/// the Bendahara post, which gives the finance home instead (so Yanti, who
/// covers Penatua Kolom 2, is the Operator row). The last row, Anggota
/// jemaat, is for anyone no row above matches.
final List<
  ({bool Function(_Pos) cocok, ItemBilahPonsel tab, ItemBilahPonsel aksi})
>
tabelBilahPonsel = [
  (
    cocok: (p) => p.peran == Role.sekretarisJemaat,
    tab: _i('Dokumen', Layar.dokumenGereja, Ikon.dokumen),
    aksi: _i('Terbitkan', Layar.dokumenGereja, Ikon.terbitkan, anak: 'terbit'),
  ),
  (
    cocok: (p) => p.peran == Role.ketuaJemaat || p.peran == Role.pimpinanJemaat,
    tab: _i('Penugasan', Layar.penugasan, Ikon.penugasan),
    aksi: _i('Setujui', Layar.permintaanDana, Ikon.centang),
  ),
  (
    cocok: (p) => p.peran == Role.pemeriksaKedua,
    tab: _i('Periksa', Layar.pemeriksa, Ikon.periksa),
    aksi: _i('Cari', Layar.cari, Ikon.cari),
  ),
  (
    cocok: (p) => p.peran == Role.penatuaKolom,
    tab: _i('Verifikasi', Layar.verifikasi, Ikon.verifikasi),
    aksi: _i('Ibadah', Layar.ibadah, Ikon.ibadah),
  ),
  (
    cocok: (p) => p.peran == Role.operator,
    tab: _i('Data jemaat', Layar.dataAnggota, Ikon.dataJemaat),
    aksi: _i('Impor', Layar.imporBuku, Ikon.impor),
  ),
  (
    cocok: (p) => p.peran == Role.syamasKolom || p.pelimpahan,
    tab: _i('Verifikasi', Layar.verifikasi, Ikon.verifikasi),
    aksi: _i('Ibadah', Layar.ibadah, Ikon.ibadah),
  ),
  (
    cocok: (p) => p.peran == Role.bendaharaUnit && p.jenis == ScopeType.kolom,
    tab: _i('Keuangan unit', Layar.keuanganUnit, Ikon.keuanganUnit),
    aksi: _i('Kesiapan', Layar.kesiapan, Ikon.periksa),
  ),
  (
    cocok: (p) =>
        p.peran == Role.aksesTerbatas ||
        (p.peran == Role.bendaharaUnit && p.jenis == ScopeType.komisi),
    tab: _i('Terbatas', Layar.terbatas, Ikon.terbatas),
    aksi: _i('Kesiapan', Layar.kesiapan, Ikon.periksa),
  ),
  (
    cocok: (p) => p.peran == Role.bendaharaUnit && p.jenis == ScopeType.panitia,
    tab: _i('Panitia', Layar.panitia, Ikon.panitia),
    aksi: _i('Dana', Layar.permintaanDana, Ikon.dana),
  ),
  (
    cocok: (_) => false,
    tab: _i('Persembahan', Layar.persembahanSaya, Ikon.persembahan),
    aksi: _i('Surat', Layar.surat, Ikon.surat),
  ),
];

/// The module tab and the raised action of the actor's non-finance bar, by
/// [tabelBilahPonsel]: each from the first matching row whose screen opens
/// on the phone (module active, guard allows); null leaves the slot out.
final bilahPonselProvider =
    Provider<({ItemBilahPonsel? tab, ItemBilahPonsel? aksi})>((ref) {
      final a = ref.watch(actorProvider);
      if (a == null) return (tab: null, aksi: null);
      final can = ref.watch(canProvider);
      final hari = ref.watch(hariIniProvider);
      final pos = <_Pos>[
        for (final g in can.grantsOf(a.personId, at: hari))
          if (g.kind == GrantKind.assignment || g.kind == GrantKind.delegation)
            (
              peran: g.postId == null ? null : can.facts.post(g.postId!)?.role,
              jenis: can.facts.scope(g.scopeId)?.type,
              pelimpahan: g.kind == GrantKind.delegation,
            ),
      ];
      var cocok = [
        for (final b in tabelBilahPonsel)
          if (pos.any(b.cocok)) b,
      ];
      if (cocok.isEmpty) cocok = [tabelBilahPonsel.last];
      bool buka(ItemBilahPonsel i) =>
          i.ke.ponsel && penjagaUntuk(i.ke, can, a, hari) == null;
      return (
        tab: cocok.map((b) => b.tab).where(buka).firstOrNull,
        aksi: cocok.map((b) => b.aksi).where(buka).firstOrNull,
      );
    });

/// The finance home's role-home rows (owner 21/11): every home row except
/// those whose content Main's summary already shows (the "Keuangan: N hal"
/// row and the finance rows with a summary row of the same title).
final barisBerandaKeuanganProvider = Provider<List<HomeRow>>((ref) {
  final b = ref.watch(berandaKeuanganProvider);
  final ringkas = {
    for (final x in [...b.perluTindakan, ...b.untukDiketahui]) x.judul,
  };
  return [
    for (final r in ref.watch(homeRowsProvider))
      if (r.ke != Layar.keuangan && !ringkas.contains(r.judul)) r,
  ];
});

/// One link of the Lainnya hub.
typedef TautanHub = ({String judul, Layar ke});

/// The Lainnya hub's label of [l] (its board title, shortened where the
/// board names a person or a year); null leaves it out: the homes, the
/// picker, the session views, the hub itself, Akun and Keluar (the hub lists
/// them last), and the steps that open only inside another screen's flow
/// (Main's Transaksi and Catat, reached from its bar; the pickers, AI helps
/// and sub-forms of Catat, Kewajiban, Dokumen and TutupBuku).
String? judulHub(Layar l) => switch (l) {
  Layar.pemilih ||
  Layar.beranda ||
  Layar.akun ||
  Layar.keluar ||
  Layar.sesiBerakhir ||
  Layar.lainnya ||
  Layar.transaksi ||
  Layar.catat ||
  Layar.tanggal ||
  Layar.bagi ||
  Layar.bantuanAi ||
  Layar.aiFoto ||
  Layar.aiMataAnggaran ||
  Layar.pilihBulan ||
  Layar.kasusBaru ||
  Layar.fotoDokumen ||
  Layar.rekeningKoran => null,
  // Main's Beranda, for a persona whose home is not the finance home.
  Layar.keuangan => 'Beranda keuangan',
  Layar.kotakMasuk => 'Kotak masuk',
  Layar.transaksiRinci => 'Rincian transaksi',
  Layar.draf => 'Draf',
  Layar.pemeriksa => 'Wajib pemeriksa kedua',
  Layar.cari => 'Cari dan tanya',
  Layar.persembahan => 'Persembahan dengan beberapa bagian',
  Layar.kewajiban => 'Uang Muka dan Titipan',
  Layar.persetujuan => 'Persetujuan',
  Layar.koreksi => 'Koreksi',
  Layar.pengembalian => 'Pengembalian',
  Layar.alihPeruntukan => 'Alih peruntukan',
  Layar.dokumen => 'Dokumen pendukung',
  Layar.lihatDokumen => 'Lihat dokumen',
  Layar.impor => 'Impor transaksi',
  Layar.ekspor => 'Ekspor data Jemaat',
  Layar.tutupBuku => 'Akhir bulan dan tutup buku',
  Layar.hitungKas => 'Hitung kas',
  Layar.kesiapan => 'Pernyataan kesiapan',
  Layar.hambatanUnit => 'Hambatan dari unit',
  Layar.aiBulan => 'Bantuan AI akhir bulan',
  Layar.kejadian => 'Kejadian setelah tutup buku',
  Layar.laporan => 'Laporan keuangan',
  Layar.paketLaporan => 'Paket laporan',
  Layar.lihatTransaksi => 'Lihat transaksi di balik angka laporan',
  Layar.bukti => 'Daftar Bukti Kas',
  Layar.formatLaporan => 'Persetujuan format laporan',
  Layar.laporanResmi => 'Laporan resmi',
  Layar.terbatas => 'Akses terbatas per peruntukan',
  Layar.laporanTerbatas => 'Laporan terbatas',
  Layar.awal => 'Pengaturan awal dan saldo awal',
  Layar.awalIsian => 'Pengaturan awal: identitas dan daftar',
  Layar.pengaturan => 'Pengaturan keuangan',
  Layar.ubahPengaturan => 'Tambah dan ubah pengaturan',
  Layar.mataAnggaran => 'Mata Anggaran',
  Layar.kasUnit => 'Kas/Bank unit',
  Layar.bendahara => 'Bendahara dan sesi',
  Layar.pemberitahuan => 'Pemberitahuan keuangan',
  Layar.penugasan => 'Penugasan jabatan',
  Layar.jabatanKosong => 'Menjalankan jabatan kosong',
  Layar.pelimpahan => 'Pelimpahan tugas',
  Layar.modul => 'Modul',
  Layar.cariOrang => 'Cari orang',
  Layar.dokumenGereja => 'Dokumen gereja',
  Layar.surat => 'Permohonan surat',
  Layar.pengumuman => 'Pengumuman',
  Layar.warta => 'Warta Jemaat',
  Layar.wartaEdisi => 'Edisi Warta Jemaat',
  Layar.bukaNama => 'Tampilkan nama',
  Layar.wartaPdf => 'Warta Jemaat (PDF)',
  Layar.dataAnggota => 'Data anggota dan keluarga',
  Layar.permohonanAnggota => 'Permohonan anggota',
  Layar.imporBuku => 'Impor buku anggota',
  Layar.konfirmasiKeluarga => 'Konfirmasi keluarga',
  Layar.verifikasi => 'Verifikasi data',
  Layar.peristiwa => 'Peristiwa',
  Layar.dataGanda => 'Kemungkinan data ganda',
  Layar.tampilanNama => 'Tampilan nama saya di publikasi',
  Layar.cabutIzin => 'Cabut izin dan hapus data saya',
  Layar.keuanganUnit => 'Keuangan unit',
  Layar.permintaanDana => 'Permintaan dana',
  Layar.pemberiPersetujuan => 'Pemberi persetujuan',
  Layar.panitia => 'Panitia',
  Layar.ibadah => 'Ibadah dan kegiatan',
  Layar.kehadiran => 'Jumlah kehadiran',
  Layar.laporanLintas => 'Laporan lintas modul',
  Layar.persembahanBernama => 'Persembahan bernama',
  Layar.persembahanSaya => 'Persembahan saya',
};

/// The module name a hub group shows: the Modul board's names; core screens
/// are "Umum" and the cross-module report "Laporan".
String namaGrupHub(ModulLayar m) =>
    m.modul?.label ?? (m == ModulLayar.laporan ? 'Laporan' : 'Umum');

/// The Lainnya hub (owner 21/11): every screen the actor may open on the
/// phone (module active, guard allows, a phone screen, no path parameter),
/// grouped by module in [Layar] order.
final hubLainnyaProvider = Provider<List<(String, List<TautanHub>)>>((ref) {
  final a = ref.watch(actorProvider);
  if (a == null) return const [];
  final can = ref.watch(canProvider);
  final hari = ref.watch(hariIniProvider);
  final grup = <String, List<TautanHub>>{};
  for (final l in Layar.values) {
    final judul = judulHub(l);
    if (judul == null || !l.ponsel || l.jalur.contains(':')) continue;
    if (penjagaUntuk(l, can, a, hari) != null) continue;
    grup.putIfAbsent(namaGrupHub(l.modulLayar), () => []).add((
      judul: judul,
      ke: l,
    ));
  }
  return [for (final e in grup.entries) (e.key, e.value)];
});

/// The finance Lainnya's "Jabatan dan modul lain" group: the hub's links
/// that are not finance-board screens (a finance or unit-finance screen that
/// needs a capability), so a Bendahara still reaches Warta, Surat and
/// Persembahan saya.
final hubJabatanLainProvider = Provider<List<TautanHub>>(
  (ref) => [
    for (final (_, daftar) in ref.watch(hubLainnyaProvider))
      for (final t in daftar)
        if (!(t.ke.kemampuan != null &&
            (t.ke.modulLayar == ModulLayar.keuangan ||
                t.ke.modulLayar == ModulLayar.keuanganUnit)))
          t,
  ],
);
