import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../motion/kerangka.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/pita_peran.dart';
import '../../widgets/sakelar.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

const _kas = [
  (id: 'kas', n: 'Kas', mati: false),
  (id: 'bni', n: 'Bank BNI ··4821', mati: false),
  (id: 'bsg', n: 'Bank SulutGo ··1107', mati: false),
  (id: 'hut', n: 'Kas Panitia HUT', mati: true),
];

const _subSesi = {
  'Browser ini': 'Sesi ini · aktif sekarang',
  'Ponsel Android': 'Terakhir dipakai 16/11/2026 10.42',
};

const _riwayat = [
  ('16/11/2026 10.42', 'Meiske L.', 'Membukukan BKU-2026-0147'),
  (
    '12/11/2026 09.31',
    'Meiske L.',
    'Membuat pembalikan BKU-2026-0144 · alasan: Mata Anggaran keliru',
  ),
  (
    '28/10/2026 16.44',
    'Meiske L.',
    'Menonaktifkan Kas Panitia HUT · berlaku mulai November 2026',
  ),
  ('05/10/2026 19.02', 'Meiske L.', 'Menutup buku September 2026'),
  ('03/10/2026 10.15', 'Meiske L.', 'Mencatat persetujuan format laporan'),
  (
    '15/09/2026 10.15',
    'Petugas verifikasi',
    'Mengaktifkan wewenang Bendahara untuk Meiske Lumentut',
  ),
];

/// Web · Pengaturan (04-lainnya.md): the laptop settings hub on one page.
class WebPengaturanScreen extends StatefulWidget {
  const WebPengaturanScreen({super.key});
  @override
  State<WebPengaturanScreen> createState() => _WebPengaturanScreenState();
}

class _WebPengaturanScreenState extends State<WebPengaturanScreen> {
  final _non = <String>{};
  bool _mc = false;
  List<String> _sesi = ['Browser ini', 'Ponsel Android'];

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final kosong =
        belumDipindah<String>('Bendahara aktif') != 'Bendahara aktif';
    final riwayat = kosong
        ? [
            (
              '16/11/2026 08.10',
              'Petugas verifikasi',
              'Mencabut wewenang Bendahara Meiske Lumentut · semua sesi diakhiri',
            ),
            ..._riwayat.where((r) => !r.$1.contains('16/11/2026')),
          ]
        : _riwayat;
    final ket14 = TextStyle(fontSize: 14, color: c.tinta2);
    final ket13 = TextStyle(fontSize: 13, color: c.tinta3);
    final atas = BorderSide(color: c.garis);

    Widget kartu(Widget child, {EdgeInsets? padding, GarisStatus? status}) =>
        Kartu(
          status: status ?? GarisStatus.dibukukan,
          padding: padding ?? const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: child,
        );

    Widget kolom(List<Widget> anak, double jarak) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < anak.length; i++) ...[
          if (i > 0) SizedBox(height: jarak),
          anak[i],
        ],
      ],
    );

    Widget kepala(String judul, String tautan, {required Layar ke}) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(child: _H2(judul)),
        const SizedBox(width: 12),
        _Tautan(tautan, ke: ke),
      ],
    );

    Widget baris(String n, String s, {Color? warna, Widget? aksi}) => Container(
      // min-height 56 plus the 1 px top line (content-box).
      constraints: const BoxConstraints(minHeight: 57),
      decoration: BoxDecoration(border: Border(top: atas)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  n,
                  style: TextStyle(fontWeight: FontWeight.w600, color: warna),
                ),
                Text(s, style: ket13),
              ],
            ),
          ),
          if (aksi != null) ...[const SizedBox(width: 12), aksi],
        ],
      ),
    );

    final jemaat = kartu(
      kolom([
        kepala('Jemaat Karunia', 'Pengaturan awal Jemaat', ke: Layar.awal),
        Text(
          'WITA · tahun buku mulai 1 Januari (tidak dapat diubah)',
          style: ket14,
        ),
        Text(
          'Tanggal mulai pencatatan 15 September 2026 · bulan pertama pencatatan September 2026',
          style: ket14,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _Tautan('Ekspor data Jemaat', ke: Layar.ekspor),
          ),
        ),
      ], 4),
    );

    final kasBank = kartu(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: _H2('Kas/Bank'),
          ),
          for (final k in _kas)
            baris(
              k.n,
              k.mati
                  ? 'Nonaktif sejak November 2026 · tetap tampil di laporan lama'
                  : _non.contains(k.id)
                  ? 'Aktif sampai akhir November 2026 · nonaktif mulai Desember 2026'
                  : 'Aktif · dipakai sejak September 2026',
              warna: k.mati ? c.tinta2 : c.tinta,
              aksi: k.mati || _non.contains(k.id)
                  ? null
                  : _TombolBaris(
                      'Nonaktifkan',
                      onTap: kosong
                          ? null
                          : () => setState(() => _non.add(k.id)),
                    ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Yang sudah dipakai hanya dapat dinonaktifkan, berlaku mulai bulan berikutnya yang belum berjalan.',
              style: ket13,
            ),
          ),
        ],
      ),
    );

    final mono = TextStyle(fontFamily: PalakatText.mono, color: c.tinta);
    Widget blok(String judul, Widget isi, {bool garis = true}) => Container(
      padding: EdgeInsets.only(top: garis ? 10 : 0),
      decoration: garis ? BoxDecoration(border: Border(top: atas)) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_H2(judul), isi],
      ),
    );
    final daftar = kartu(
      kolom([
        blok(
          'Peruntukan',
          Text('Umum Jemaat · Diakonia · Pembangunan', style: ket14),
          garis: false,
        ),
        blok(
          'Lingkup',
          Text(
            'Jemaat · Kolom 3 · BIPRA Pemuda · Komisi Diakonia · Panitia Natal',
            style: ket14,
          ),
        ),
        blok(
          'Seri No. Bukti',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  // U+200B: Chrome breaks after these hyphens; Flutter does not.
                  children: [
                    TextSpan(text: 'BKU-\u200B2026-\u200B0001', style: mono),
                    const TextSpan(text: ' Biasa · '),
                    TextSpan(text: 'OPN-\u200B2026-\u200B0001', style: mono),
                    const TextSpan(text: ' Saldo awal pencatatan · '),
                    TextSpan(text: 'ADJ-\u200B2026-\u200B0001', style: mono),
                    const TextSpan(text: ' Penyesuaian'),
                  ],
                ),
                style: ket14,
              ),
              Text(
                'Nomor dibuat aplikasi saat Bukukan, tidak pernah diketik.',
                style: ket13,
              ),
            ],
          ),
        ),
      ], 10),
    );

    final mataAnggaran = kartu(
      kolom([
        kepala('Mata Anggaran', 'Buka versi 2026.2', ke: Layar.mataAnggaran),
        Text(
          'Versi 2026.1 · Diterbitkan · berlaku mulai September 2026',
          style: ket14,
        ),
        Text(
          'Versi 2026.2 · Draf · usulan berlaku mulai Desember 2026',
          style: ket14,
        ),
      ], 4),
    );

    final aturan = kartu(
      kolom([
        const _H2('Aturan persetujuan dan dokumen pendukung'),
        Text(
          'Persetujuan di luar aplikasi wajib untuk Belanja Rp2.000.000 ke atas. Dokumen pendukung wajib untuk semua Belanja; Bendahara boleh memverifikasi unggahannya sendiri. Pemberi pengecualian: Ketua BPMJ.',
          style: ket14,
        ),
        Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(border: Border(top: atas)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wajib pemeriksa kedua',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _mc
                          ? 'Hidup mulai Desember 2026'
                          : 'Mati · Bendahara memeriksa dan membukukan sendiri',
                      style: ket13,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Sakelar(
                nilai: _mc,
                label: 'Wajib pemeriksa kedua',
                nonaktif: kosong,
                onUbah: (_) => setState(() => _mc = !_mc),
              ),
            ],
          ),
        ),
        if (_mc)
          Gerak(
            Kerangka.muncul,
            key: const ValueKey('mc'),
            lama: const Duration(milliseconds: 300),
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Berlaku mulai Desember 2026.',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: 'Belum ada pemeriksa kedua yang ditunjuk; tanpa itu Bukukan akan ditolak mulai Desember 2026.',
                    style: TextStyle(
                      color: c.bata,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(
                    text: ' Transaksi sebelumnya tidak terpengaruh.',
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
      ], 10),
    );

    final format = kartu(
      kolom([
        kepala('Format laporan', 'Lihat laporan', ke: Layar.laporan),
        Text(
          'Bawaan Palakat v1 · Persetujuan format: sudah dicatat · 01/11/2026',
          style: ket14,
        ),
      ], 4),
    );

    final bendahara = kartu(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
      status: kosong ? GarisStatus.terpilih : GarisStatus.dibukukan,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                const _H2('Bendahara dan sesi'),
                _Lencana(
                  kosong
                      ? 'Belum ada Bendahara aktif'
                      : 'Wewenang Bendahara aktif',
                  warna: kosong ? c.tinta : c.laut,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              kosong
                  ? 'Meiske Lumentut · Wewenang dicabut 16/11/2026 · Riwayat tetap mencatatnya sebagai pelaku tindakannya.'
                  : 'Meiske Lumentut · aktif sejak 15/09/2026 · SK-BPMJ-04-2026',
              style: ket14,
            ),
          ),
          if (!kosong)
            for (final n in _sesi)
              baris(
                n,
                _subSesi[n]!,
                aksi: n == 'Browser ini'
                    ? null
                    : _TombolBaris(
                        'Akhiri sesi',
                        onTap: () => setState(
                          () => _sesi = _sesi.where((x) => x != n).toList(),
                        ),
                      ),
              ),
          if (!kosong)
            Container(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 10),
              decoration: BoxDecoration(border: Border(top: atas)),
              child: _BarisSerah(ket13: ket13),
            ),
        ],
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        nav: NavSamping(item: navKeuangan, aktif: 6),
        isi: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: const Text(
                  'Pengaturan',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                'Pengaturan tidak diubah di tempat. Setiap perubahan berlaku mulai bulan tertentu dan tidak mengubah transaksi yang sudah dibukukan.',
                style: ket14,
              ),
            ],
          ),
          const DeretTautan(
            web: true,
            anak: [
              _Tautan(
                'Tambah dan ubah',
                ke: Layar.ubahPengaturan,
                ukuran: null,
              ),
              _Tautan(
                'Persetujuan format laporan',
                ke: Layar.formatLaporan,
                ukuran: null,
              ),
              _Tautan(
                'Wajib pemeriksa kedua',
                ke: Layar.pemeriksa,
                ukuran: null,
              ),
              _Tautan(
                'Serah terima Bendahara',
                ke: Layar.bendahara,
                anak: 'serah',
                ukuran: null,
              ),
              _Tautan('Akun dan keluar', ke: Layar.keluar, ukuran: null),
            ],
          ),
          if (kosong)
            PitaPeran(
              jenis: JenisPita.kunci,
              judul: 'Belum ada Bendahara aktif',
              radius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ukuranJudul: 19,
              anak: [
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Wewenang Meiske Lumentut dicabut pada 16/11/2026 08.10 oleh Petugas verifikasi. Semua data hanya dapat dilihat. ',
                      ),
                      TextSpan(
                        text: 'Yang perlu bertindak: BPMJ Jemaat Karunia',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: c.permukaan,
                        ),
                      ),
                      const TextSpan(
                        text: ', dengan menunjuk Bendahara baru dan mengirim surat penunjukannya untuk diverifikasi.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          KisiOtomatis(
            minLebar: 420,
            jarak: 20,
            anak: [
              kolom([jemaat, kasBank, daftar], 20),
              kolom([mataAnggaran, aturan, format, bendahara], 20),
            ],
          ),
          kolom([
            const _H2('Riwayat aktivitas'),
            Kartu(
              padding: EdgeInsets.zero,
              child: LayoutBuilder(
                builder: (context, k) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: math.max(640, k.maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _BarisRiwayat(
                          'Waktu',
                          'Pelaku',
                          'Tindakan',
                          kepala: true,
                        ),
                        for (final r in riwayat)
                          _BarisRiwayat(r.$1, r.$2, r.$3),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ], 10),
        ],
      ),
    );
  }
}

/// h2 17/700 (off-token).
class _H2 extends StatelessWidget {
  const _H2(this.teks);
  final String teks;
  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      teks,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    ),
  );
}

/// A board `<a>`: 14/600 (or inherited), `laut`, min 44 × 44, text centred
/// vertically. Drill-ins push.
class _Tautan extends StatelessWidget {
  const _Tautan(this.teks, {required this.ke, this.anak, this.ukuran = 14});
  final String teks;
  final Layar ke;
  final String? anak;
  final double? ukuran;
  @override
  Widget build(BuildContext context) => Tautan(
    ke: ke,
    anak: anak,
    child: Center(
      widthFactor: 1,
      heightFactor: 1,
      child: TautanTeks(teks, ukuran: ukuran),
    ),
  );
}

/// "Nonaktifkan" / "Akhiri sesi": min 44, padding 0 12, radius 10, 1.5
/// `garisTegas`, `permukaan`, 14/700. [onTap] null keeps the look (board
/// `disabled`).
class _TombolBaris extends StatelessWidget {
  const _TombolBaris(this.label, {required this.onTap});
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      radius: 10,
      child: RupaTombol(
        label: label,
        isi: c.permukaan,
        garis: GarisBorder.penuh(c.garisTegas, radius: 10),
        warnaTeks: c.tinta,
        radius: 10,
        tinggi: 44,
        paddingH: 12,
        lebarPenuh: false,
        ukuranTeks: 14,
      ),
    );
  }
}

/// The Bendahara badge: 13/700, radius 6, padding 4 10 inside a 1.5 line of
/// its own fill, `permukaan` text.
class _Lencana extends StatelessWidget {
  const _Lencana(this.teks, {required this.warna});
  final String teks;
  final Color warna;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11.5, vertical: 5.5),
    decoration: BoxDecoration(
      color: warna,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      teks,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: context.warna.permukaan,
      ),
    ),
  );
}

/// "Serah terima Bendahara" link-button and its note: wrap, gap 10 16,
/// centred; the note `flex: 1 1 200px`.
class _BarisSerah extends StatelessWidget {
  const _BarisSerah({required this.ket13});
  final TextStyle ket13;
  @override
  Widget build(BuildContext context) {
    const label = 'Serah terima Bendahara';
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: DefaultTextStyle.of(context).style
            .merge(const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final lebar = tp.width + 32 + 3;
    tp.dispose();
    return BarisLentur(
      jarak: 16,
      jarakBaris: 10,
      rata: CrossAxisAlignment.center,
      anak: [
        Lentur(
          dasar: lebar,
          tumbuh: 0,
          child: const Tombol(
            label,
            onPressed: null,
            ke: Layar.bendahara,
            anak: 'serah',
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.kecil,
            ukuranTeks: 14,
          ),
        ),
        Lentur(
          dasar: 200,
          child: Text(
            'Bendahara baru memerlukan surat penunjukan baru dan tidak mewarisi persetujuan yang pernah dicatat.',
            style: ket13,
          ),
        ),
      ],
    );
  }
}

/// One history row: grid 160 | 190 | 1fr, gap 16, padding 12 18.
class _BarisRiwayat extends StatelessWidget {
  const _BarisRiwayat(this.w, this.p, this.t, {this.kepala = false});
  final String w, p, t;
  final bool kepala;
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: kepala
          ? null
          : BoxDecoration(
              border: Border(top: BorderSide(color: c.garis)),
            ),
      child: DefaultTextStyle.merge(
        style: kepala
            ? TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: c.tinta2,
              )
            : const TextStyle(fontSize: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 160,
              child: Text(
                w,
                style: kepala
                    ? null
                    : TextStyle(
                        fontFamily: PalakatText.mono,
                        fontSize: 13,
                        color: c.tinta2,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 190,
              child: Text(
                p,
                style: kepala
                    ? null
                    : const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(t)),
          ],
        ),
      ),
    );
  }
}
