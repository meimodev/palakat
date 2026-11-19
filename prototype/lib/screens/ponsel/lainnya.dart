import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../motion/kerangka.dart';
import '../../shell/kendali.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/ponsel_tab_bar.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lembar_bawah.dart';
import '../../widgets/sakelar.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';

// ---------- Board data (Lainnya.dc.html logic class) ----------

typedef _Kas = ({String id, String n, String s, bool mati});

const List<_Kas> _kasDaftar = [
  (id: 'kas', n: 'Kas', s: 'Aktif · dipakai sejak September 2026', mati: false),
  (
    id: 'bni',
    n: 'Bank BNI ··4821',
    s: 'Aktif · dipakai sejak September 2026',
    mati: false,
  ),
  (
    id: 'bsg',
    n: 'Bank SulutGo ··1107',
    s: 'Aktif · dipakai sejak September 2026',
    mati: false,
  ),
  (
    id: 'hut',
    n: 'Kas Panitia HUT',
    s: 'Nonaktif sejak November 2026 · tetap tampil di laporan lama',
    mati: true,
  ),
];

const _bulanPilihan = ['Desember 2026', 'Januari 2027'];

const _riwayat = [
  (
    'Meiske L. membukukan BKU-2026-0146',
    '15/11/2026 12.20 · Persembahan Ibadah Minggu',
  ),
  (
    'Meiske L. membuat pembalikan BKU-2026-0144',
    '12/11/2026 09.31 · Alasan: Mata Anggaran keliru',
  ),
  (
    'Meiske L. menonaktifkan Kas Panitia HUT',
    '28/10/2026 16.44 · berlaku mulai November 2026',
  ),
  (
    'Meiske L. menutup buku September 2026',
    '05/10/2026 19.02 · Periode laporan 15–30 September 2026',
  ),
  (
    'Meiske L. mencatat persetujuan format laporan',
    '03/10/2026 10.15 · Pemberi persetujuan: Pdt. Lidya Rondonuwu, Ketua BPMJ',
  ),
  (
    'Petugas verifikasi mengaktifkan wewenang Bendahara',
    '15/09/2026 10.15 · Meiske Lumentut',
  ),
];

/// Group card C: every row is a push link.
const _tautanC = [
  (
    judul: 'Laporan',
    ket: 'Paket Laporan Bulanan GMIM · F01 sampai F14',
    ke: 'Laporan',
  ),
  (
    judul: 'Daftar Bukti Kas',
    ket: 'Semua No. Bukti dan celah nomor',
    ke: 'Bukti',
  ),
  (
    judul: 'Uang Muka dan Titipan',
    ket: 'Uang yang masih berjalan',
    ke: 'Kewajiban',
  ),
  (judul: 'Impor', ket: 'Dari file Excel atau CSV', ke: 'Impor'),
  (
    judul: 'Ekspor data Jemaat',
    ket: 'Salinan lengkap milik Jemaat',
    ke: 'Ekspor',
  ),
  (
    judul: 'Dokumen pendukung',
    ket: 'Verifikasi, pengecualian, dokumen susulan',
    ke: 'Dokumen',
  ),
  (
    judul: 'Pernyataan kesiapan',
    ket: 'Per peruntukan · setelah ada bendahara unit (Putaran 5)',
    ke: 'Kesiapan',
  ),
  (
    judul: 'Kejadian setelah tutup buku',
    ket: 'Catatan tentang bulan yang sudah ditutup',
    ke: 'Kejadian',
  ),
  (
    judul: 'Persetujuan format laporan',
    ket: 'Sudah dicatat · 03/10/2026',
    ke: 'FormatLaporan',
  ),
  (judul: 'Cari', ket: 'Dengan kata sehari-hari', ke: 'Cari'),
  (judul: 'Pemberitahuan', ket: 'Sementara', ke: 'Pemberitahuan'),
  (
    judul: 'Tambah dan ubah pengaturan',
    ket: 'Kas/Bank, seri No. Bukti, aturan · berlaku mulai bulan tertentu',
    ke: 'UbahPengaturan',
  ),
  (
    judul: 'Wajib pemeriksa kedua',
    ket: 'Aturan pilihan Jemaat',
    ke: 'Pemeriksa',
  ),
  (
    judul: 'Persetujuan di luar aplikasi',
    ket: 'Ganti catatan, dan yang terjadi bila transaksi diubah',
    ke: 'Persetujuan',
  ),
  (
    judul: 'Akun dan keluar',
    ket: 'Meiske Lumentut · perangkat ini',
    ke: 'Keluar',
  ),
];

// ---------- Board state ----------

class _Keadaan extends ChangeNotifier {
  String? sheet;
  String bulan = 'Desember 2026';
  final Map<String, String> non = {};
  bool mc = false;

  void ulang() {
    sheet = null;
    bulan = 'Desember 2026';
    non.clear();
    mc = false;
    notifyListeners();
  }

  void buka(String id) {
    sheet = id;
    bulan = 'Desember 2026';
    notifyListeners();
  }

  void pick(String b) {
    bulan = b;
    notifyListeners();
  }

  void tutupSheet() {
    sheet = null;
    notifyListeners();
  }

  void nonaktifkan() {
    non[sheet!] = bulan;
    sheet = null;
    notifyListeners();
  }

  void toggleMc() {
    mc = !mc;
    notifyListeners();
  }
}

class _Lingkup extends InheritedNotifier<_Keadaan> {
  const _Lingkup({required _Keadaan super.notifier, required super.child});
  static _Keadaan of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Lingkup>()!.notifier!;
  static _Keadaan baca(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_Lingkup>()!.notifier!;
}

/// Owns the board state and the phone root (strip, Nonaktifkan sheet) above
/// the child routes `/Lainnya/kas`, `/aturan`, `/riwayat`.
class LainnyaKendali extends StatefulWidget {
  const LainnyaKendali({super.key, required this.child});
  final Widget child;
  @override
  State<LainnyaKendali> createState() => _LainnyaKendaliState();
}

class _LainnyaKendaliState extends State<LainnyaKendali> {
  final _k = _Keadaan();
  int _generasi = 0;

  @override
  void initState() {
    super.initState();
    ulangPapan['Lainnya'] = _ulang;
  }

  void _ulang() => setState(() {
    _k.ulang();
    _generasi++;
  });

  @override
  void dispose() {
    if (ulangPapan['Lainnya'] == _ulang) ulangPapan.remove('Lainnya');
    _k.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Lingkup(
    notifier: _k,
    child: GenerasiPapan(
      generasi: _generasi,
      child: Material(
        type: MaterialType.transparency,
        child: ListenableBuilder(
          listenable: _k,
          builder: (context, _) => LayarPonsel(
            overlay: [if (_k.sheet != null) _LembarNonaktifkan(k: _k)],
            child: widget.child,
          ),
        ),
      ),
    ),
  );
}

class LainnyaScreen extends StatelessWidget {
  const LainnyaScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.warna.kertas,
    child: switch (anak) {
      'kas' => const _KasBank(),
      'aturan' => const _Aturan(),
      'riwayat' => const _Riwayat(),
      _ => const _Hub(),
    },
  );
}

// ---------- Shared pieces ----------

TextStyle _judulBaris() =>
    const TextStyle(fontWeight: FontWeight.w600, fontSize: 15);

/// `keHub`: pop to `/Lainnya` (closes the sheet too).
void _keHub(BuildContext context) {
  _Lingkup.baca(context).tutupSheet();
  context.kembaliKe('/Lainnya');
}

/// Inner view: header with back, then [isi] filling the rest.
class _Dalam extends StatelessWidget {
  const _Dalam({required this.judul, required this.isi});
  final String judul;
  final Widget isi;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      KepalaPonsel(judul: judul, onKembali: () => _keHub(context)),
      Expanded(child: isi),
    ],
  );
}

/// A static row of a group card: min height 60, centred column, rule above.
class _BarisTetap extends StatelessWidget {
  const _BarisTetap({required this.judul, required this.ket});
  final String judul;
  final InlineSpan ket;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GarisLurus(warna: c.garis),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(judul, style: _judulBaris()),
              Text.rich(ket, style: TextStyle(fontSize: 13, color: c.tinta3)),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _grup(List<Widget> baris) => Kartu(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Column(children: baris),
);

// ---------- Hub ----------

class _Hub extends StatelessWidget {
  const _Hub();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final k = _Lingkup.of(context);
    const mono = TextStyle(fontFamily: PalakatText.mono);
    Tautan ruteMain(Widget isi) =>
        Tautan(ke: 'Main', cara: Cara.ganti, child: isi);

    final isi = <Widget>[
      Semantics(
        header: true,
        child: const Text(
          'Lainnya',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
      Kartu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            const Text(
              'Jemaat Karunia',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
            Text(
              'WITA · tahun buku mulai 1 Januari (tidak dapat diubah)',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            Text(
              'Tanggal mulai pencatatan 15 September 2026',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
      ),
      Text(
        'Pengaturan tidak diubah di tempat. Setiap perubahan berlaku mulai '
        'bulan tertentu dan tidak mengubah transaksi yang sudah dibukukan.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      ),
      _grup([
        BarisDaftar(
          judul: 'Kas/Bank',
          keterangan:
              '${_kasDaftar.where((x) => !x.mati).length} aktif · 1 nonaktif',
          pertama: true,
          onTap: () => context.push('/Lainnya/kas'),
        ),
        const _BarisTetap(
          judul: 'Peruntukan',
          ket: TextSpan(text: 'Umum Jemaat · Diakonia · Pembangunan'),
        ),
        const _BarisTetap(
          judul: 'Lingkup',
          ket: TextSpan(
            text: 'Jemaat · Kolom 3 · BIPRA Pemuda · Komisi Diakonia · Panitia Natal',
          ),
        ),
        const Tautan(
          ke: 'MataAnggaran',
          child: BarisDaftar(
            judul: 'Mata Anggaran',
            keterangan: 'Versi 2026.1 diterbitkan · versi 2026.2 masih draf',
          ),
        ),
        const _BarisTetap(
          judul: 'Seri No. Bukti',
          ket: TextSpan(
            children: [
              TextSpan(text: 'BKU-2026-0001', style: mono),
              TextSpan(text: ' Biasa · '),
              TextSpan(text: 'OPN', style: mono),
              TextSpan(text: ' Saldo awal pencatatan · '),
              TextSpan(text: 'ADJ', style: mono),
              TextSpan(text: ' Penyesuaian'),
            ],
          ),
        ),
      ]),
      _grup([
        BarisDaftar(
          judul: 'Aturan persetujuan dan dokumen pendukung',
          keterangan: k.mc
              ? 'Wajib pemeriksa kedua: hidup mulai Desember 2026'
              : 'Wajib pemeriksa kedua: mati',
          pertama: true,
          onTap: () => context.push('/Lainnya/aturan'),
        ),
        const _BarisTetap(
          judul: 'Format laporan',
          ket: TextSpan(
            text: 'Bawaan Palakat v1 · Persetujuan format: sudah dicatat',
          ),
        ),
        const Tautan(
          ke: 'Bendahara',
          child: BarisDaftar(
            judul: 'Bendahara dan sesi',
            keterangan: 'Meiske Lumentut · Wewenang Bendahara aktif',
          ),
        ),
        BarisDaftar(
          judul: 'Riwayat aktivitas',
          keterangan: 'Siapa melakukan apa, dan kapan',
          onTap: () => context.push('/Lainnya/riwayat'),
        ),
      ]),
      _grup([
        for (final (i, t) in _tautanC.indexed)
          Tautan(
            ke: t.ke,
            child: BarisDaftar(
              judul: t.judul,
              keterangan: t.ket,
              pertama: i == 0,
            ),
          ),
      ]),
    ];

    return Stack(
      children: [
        Positioned.fill(
          bottom: 84,
          child: Gerak(
            Kerangka.pudar,
            lama: const Duration(milliseconds: 200),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 18,
                children: isi,
              ),
            ),
          ),
        ),
        PonselTabBar(
          aktif: TabPonsel.lainnya,
          diameterCatat: 66,
          beranda: ruteMain,
          transaksi: ruteMain,
          catat: (isi) => Tautan(
            ke: 'Main',
            cara: Cara.ganti,
            label: 'Catat transaksi',
            radius: 33,
            child: isi,
          ),
        ),
      ],
    );
  }
}

// ---------- Kas/Bank ----------

class _KasBank extends StatelessWidget {
  const _KasBank();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final k = _Lingkup.of(context);
    // An open sheet takes system Back first (navigation.md 5.1).
    return PopScope(
      canPop: k.sheet == null,
      onPopInvokedWithResult: (sudah, _) {
        if (!sudah) k.tutupSheet();
      },
      child: _Dalam(
        judul: 'Kas/Bank',
        isi: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              for (final x in _kasDaftar) _kartuKas(context, k, x),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Kas/Bank yang sudah dipakai tidak dapat dihilangkan, hanya '
                  'dinonaktifkan. Yang nonaktif tetap tampil di transaksi dan '
                  'laporan lamanya.',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kartuKas(BuildContext context, _Keadaan k, _Kas x) {
    final c = context.warna;
    final akan = k.non[x.id];
    final bisa = !x.mati && akan == null;
    final sub = akan == null
        ? x.s
        : 'Aktif sampai akhir '
              '${akan == 'Desember 2026' ? 'November 2026' : 'Desember 2026'}'
              ' · nonaktif mulai $akan';
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Kartu(
        status: (x.mati || akan != null)
            ? GarisStatus.draf
            : GarisStatus.dibukukan,
        isi: x.mati ? null : c.permukaan,
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    x.n,
                    style: _judulBaris().copyWith(
                      color: x.mati ? c.tinta2 : c.tinta,
                    ),
                  ),
                  Text(sub, style: TextStyle(fontSize: 13, color: c.tinta3)),
                ],
              ),
            ),
            if (bisa)
              Tekan(
                onTap: () => k.buka(x.id),
                radius: 10,
                child: RupaTombol(
                  label: 'Nonaktifkan',
                  isi: c.permukaan,
                  garis: GarisBorder.penuh(c.garisTegas, radius: 10),
                  warnaTeks: c.tinta,
                  radius: 10,
                  tinggi: 44,
                  paddingH: 12,
                  lebarPenuh: false,
                  ukuranTeks: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LembarNonaktifkan extends StatelessWidget {
  const _LembarNonaktifkan({required this.k});
  final _Keadaan k;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final nama = _kasDaftar.firstWhere((x) => x.id == k.sheet).n;
    return LembarBawah(
      judul: 'Nonaktifkan $nama',
      anakJudul: 'Transaksi lama tidak berubah dan tetap tampil di laporannya.',
      labelTirai: 'Kembali ke daftar Kas/Bank',
      onTutup: k.tutupSheet,
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChipPilihan<String>(
              label: 'Berlaku mulai',
              pilihan: [for (final b in _bulanPilihan) (nilai: b, teks: b)],
              terpilih: k.bulan,
              onPilih: k.pick,
              jarakBaris: 0,
            ),
            const SizedBox(height: 8),
            Text(
              'Hanya bulan yang belum ditutup dan belum berjalan.',
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
          ],
        ),
        Tombol(
          'Nonaktifkan mulai ${k.bulan}',
          jenis: JenisTombol.tinta,
          onPressed: k.nonaktifkan,
        ),
        Tombol(
          'Kembali',
          jenis: JenisTombol.teks,
          warnaTeks: c.tinta,
          onPressed: k.tutupSheet,
        ),
      ],
    );
  }
}

// ---------- Aturan ----------

class _Aturan extends StatelessWidget {
  const _Aturan();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final k = _Lingkup.of(context);
    Widget baris(String judul, String teks, {bool pertama = false}) =>
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: pertama
              ? null
              : BoxDecoration(
                  border: Border(top: BorderSide(color: c.garis)),
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(judul, style: _judulBaris()),
              Text(teks, style: TextStyle(fontSize: 14, color: c.tinta2)),
            ],
          ),
        );

    return _Dalam(
      judul: 'Aturan',
      isi: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Kartu(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  baris(
                    'Persetujuan di luar aplikasi',
                    'Wajib untuk Belanja Rp2.000.000 ke atas · berlaku mulai '
                        'September 2026',
                    pertama: true,
                  ),
                  baris(
                    'Dokumen pendukung',
                    'Wajib untuk semua Belanja · Bendahara boleh memverifikasi '
                        'unggahannya sendiri',
                  ),
                  baris('Pemberi pengecualian', 'Ketua BPMJ'),
                ],
              ),
            ),
            Kartu(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 10,
                children: [
                  Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Wajib pemeriksa kedua', style: _judulBaris()),
                            Text(
                              k.mc
                                  ? 'Hidup mulai Desember 2026'
                                  : 'Mati · Bendahara memeriksa dan membukukan '
                                        'sendiri',
                              style: TextStyle(fontSize: 13, color: c.tinta3),
                            ),
                          ],
                        ),
                      ),
                      Sakelar(
                        nilai: k.mc,
                        onUbah: (_) => k.toggleMc(),
                        label: 'Wajib pemeriksa kedua',
                      ),
                    ],
                  ),
                  if (k.mc)
                    Gerak(
                      Kerangka.muncul,
                      lama: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: c.garis)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: 6,
                          children: [
                            const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Berlaku mulai Desember 2026.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        ' Sejak itu, Bukukan memerlukan orang '
                                        'kedua yang menandai sudah diperiksa. '
                                        'Pemeriksa kedua tidak boleh orang yang '
                                        'mencatat.',
                                  ),
                                ],
                              ),
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              'Belum ada pemeriksa kedua yang ditunjuk. Tanpa '
                              'itu, Bukukan akan ditolak mulai Desember 2026.',
                              style: TextStyle(
                                fontSize: 14,
                                color: c.bata,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Transaksi November 2026 dan sebelumnya tidak '
                              'terpengaruh.',
                              style: TextStyle(fontSize: 13, color: c.tinta3),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Riwayat aktivitas ----------

class _Riwayat extends StatelessWidget {
  const _Riwayat();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return _Dalam(
      judul: 'Riwayat aktivitas',
      isi: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, r) in _riwayat.indexed)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: i == 0
                    ? null
                    : BoxDecoration(
                        border: Border(top: BorderSide(color: c.garis)),
                      ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.$1, style: _judulBaris()),
                    Text(r.$2, style: TextStyle(fontSize: 13, color: c.tinta3)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
