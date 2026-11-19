import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/pita_laporan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';

/// F01 lines of WebLaporan.dc.html (`B`): label, value, note, total, link.
const _baris = [
  ('Saldo awal Kas/Bank', 'Rp36.250.000', '', true, false),
  ('Pendapatan ekonomi', 'Rp14.820.000', '', false, true),
  ('Belanja ekonomi', '−Rp11.455.000', '', false, true),
  ('Dana Transit masuk', 'Rp2.400.000', 'titipan masuk', false, true),
  ('Dana Transit keluar', '−Rp2.400.000', 'titipan disalurkan', false, true),
  ('Uang Muka diberikan', '−Rp1.500.000', '', false, true),
  ('Pengembalian sisa uang muka', 'Rp350.000', '', false, true),
  ('Saldo akhir Kas/Bank', 'Rp38.465.000', '', true, false),
];

const _posisi = [
  ['Kas', 'Rp8.750.000', 'Rp8.750.000', '', 'Rp0'],
  ['Bank BNI ··4821', 'Rp24.600.000', '', 'Rp24.100.000', 'Rp0'],
  ['Bank SulutGo ··1107', 'Rp5.115.000', '', 'Rp5.115.000', 'Rp0'],
];

class WebLaporanScreen extends StatelessWidget {
  const WebLaporanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final resmi = context.tweak<String>('WebLaporan', 'jenis') == 'resmi';
    return HalamanWeb(
      nav: const NavSamping(
        item: navKeuangan,
        aktif: 5,
        pengguna: PenggunaKeuangan(),
      ),
      jarak: 18,
      jabatanKosong: true,
      isi: [
        _BarisJudul(resmi: resmi),
        if (resmi)
          const PitaLaporan.resmi(
            dibekukan: '16/11/2026 11.05',
            idSalinan: 'SNP-2026-10-01',
            versi: '2026.1',
            sebaris: true,
          )
        else
          const PitaLaporan.sementara(
            kalimat: 'Bukan laporan resmi. Angka masih dapat berubah sampai Oktober 2026 ditutup; file resmi dibuat setelah tutup buku.',
            sebaris: true,
          ),
        BarisLentur(
          jarak: 24,
          anak: [
            Lentur(dasar: 560, tumbuh: 999, child: _Kertas(resmi: resmi)),
            Lentur(
              dasar: 280,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _KartuSisi(
                    jarak: 4,
                    anak: [
                      Text(
                        'Format laporan',
                        style: TextStyle(fontSize: 13, color: c.tinta2),
                      ),
                      const Text(
                        'Bawaan Palakat · v1',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Persetujuan format: sudah dicatat',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Pemberi persetujuan:',
                              style: TextStyle(color: c.tinta2),
                            ),
                            const TextSpan(
                              text: ' [NAMA], Pimpinan Jemaat yang berwenang · 01/11/2026',
                            ),
                          ],
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GarisLurus(
                              warna: c.garisTegas,
                              gaya: GayaGaris.putus,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Dicatat oleh Meiske L., 02/11/2026 09.10. Persetujuan diberikan di luar aplikasi.',
                              style: TextStyle(fontSize: 13, color: c.tinta3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _KartuSisi(
                    jarak: 6,
                    anak: [
                      const Text(
                        'Isi Paket Laporan Bulanan GMIM',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'F01 Laporan Perbendaharaan Bulanan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.tinta,
                        ),
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Tautan(
                          ke: 'WebPaketLaporan',
                          cara: Cara.naik,
                          child: SizedBox(
                            height: 44,
                            child: Center(
                              widthFactor: 1,
                              child: TautanTeks(
                                'Buka F02 sampai F14',
                                ukuran: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// h1 `flex: 1 1 260px` and, when resmi, the two download links, wrapping.
class _BarisJudul extends StatelessWidget {
  const _BarisJudul({required this.resmi});
  final bool resmi;

  static double _lebar(BuildContext context, String teks, double garis) {
    final tp = TextPainter(
      text: TextSpan(
        text: teks,
        style: PalakatText.isiWeb.copyWith(fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    return (tp.width + 36 + garis).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final judul = Semantics(
      header: true,
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'Laporan '),
            TextSpan(
              text: '· Oktober 2026',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: c.tinta3,
              ),
            ),
          ],
        ),
        style: PalakatText.judulHalaman.copyWith(color: c.tinta),
      ),
    );
    if (!resmi) return judul;
    return BarisLentur(
      jarak: 12,
      rata: CrossAxisAlignment.center,
      anak: [
        Lentur(dasar: 260, child: judul),
        Lentur(
          dasar: _lebar(context, 'Unduh PDF', 0),
          tumbuh: 0,
          child: const Tombol(
            'Unduh PDF',
            onPressed: null,
            ke: 'A4F01',
            ukuran: UkuranTombol.kecil,
            paddingH: 18,
          ),
        ),
        Lentur(
          dasar: _lebar(context, 'Unduh Excel', 3),
          tumbuh: 0,
          child: const Tombol(
            'Unduh Excel',
            onPressed: null,
            ke: 'WebExcel',
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.kecil,
            paddingH: 18,
          ),
        ),
      ],
    );
  }
}

class _Kertas extends StatelessWidget {
  const _Kertas({required this.resmi});
  final bool resmi;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final pad = context.jepit(20, 4, 48);
    final kecil3 = TextStyle(fontSize: 13, color: c.tinta3);
    return Container(
      padding: EdgeInsets.all(pad),
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: resmi
            ? GarisBorder.penuh(c.tinta, radius: 6)
            : GarisBorder.putus(c.putus, radius: 6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.tinta, width: 2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'F01 · ${resmi ? 'LAPORAN RESMI' : 'LAPORAN SEMENTARA · BUKAN LAPORAN RESMI'}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.tinta2,
                    letterSpacing: .4,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'LAPORAN PERBENDAHARAAN BULANAN',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .2,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Jemaat Karunia · Periode laporan 1–31 Oktober 2026',
                ),
                const SizedBox(height: 2),
                Text(
                  'Format bawaan aplikasi. Mencakup seluruh Jemaat: semua peruntukan dan semua kas/bank.',
                  style: kecil3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, b) in _baris.indexed)
                _BarisF01(b, pertama: i == 0),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Posisi Kas & Bank per 31 Oktober 2026',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const _TabelPosisi(),
          const SizedBox(height: 8),
          Text(
            'Bank BNI ··4821: setoran dalam perjalanan Rp500.000, dibawa ke November 2026. Hasil hitung kas dan saldo rekening koran tidak dijumlahkan.',
            style: kecil3,
          ),
          const SizedBox(height: 22 + 8),
          KisiOtomatis(
            minLebar: 200,
            jarak: 24,
            anak: [
              for (final (jabatan, nama) in const [
                ('Bendahara', 'Meiske Lumentut'),
                ('Ketua BPMJ', '[NAMA DARI PENGATURAN]'),
              ])
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      jabatan,
                      style: TextStyle(fontSize: 13, color: c.tinta2),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: c.tinta)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nama,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarisF01 extends StatelessWidget {
  const _BarisF01(this.b, {required this.pertama});
  final (String, String, String, bool, bool) b;
  final bool pertama;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final (label, nilai, catatan, total, lihat) = b;
    // ponytail: on windows under 600 px the link goes under the label; the
    // board's row overflows the page there (spec check 5 asks for no scroll).
    final sempit = MediaQuery.sizeOf(context).width < 600;
    final teks = Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$label '),
          if (catatan.isNotEmpty)
            TextSpan(
              text: '· $catatan',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: c.tinta3,
              ),
            ),
        ],
      ),
      style: TextStyle(fontWeight: total ? FontWeight.w700 : FontWeight.w500),
    );
    const tautan = Tautan(
      ke: 'WebTransaksi',
      child: SizedBox(
        height: 44,
        child: Center(
          widthFactor: 1,
          child: TautanTeks('Lihat transaksi', ukuran: 13),
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: pertama
            ? null
            : Border(
                top: total
                    ? BorderSide(color: c.tinta, width: 1.5)
                    : BorderSide(color: c.garis),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: sempit && lihat
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [teks, tautan],
                  )
                : teks,
          ),
          if (lihat && !sempit) ...[const SizedBox(width: 12), tautan],
          const SizedBox(width: 12),
          SizedBox(
            width: 150,
            child: Text(
              nilai,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: PalakatText.mono,
                fontWeight: total ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `table` min-width 600, width 100%, scrolling sideways inside the paper.
class _TabelPosisi extends StatelessWidget {
  const _TabelPosisi();

  static const _kepala = [
    'Kas/Bank',
    'Saldo buku',
    'Hasil hitung kas',
    'Saldo rekening koran',
    'Selisih belum dijelaskan',
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    TextStyle? gaya(int i, bool kepala) => kepala
        ? TextStyle(fontWeight: FontWeight.w600, color: c.tinta2)
        : i == 0
        ? null
        : const TextStyle(fontFamily: PalakatText.mono);
    Widget sel(String t, int i, {bool kepala = false}) => Padding(
      padding: EdgeInsets.fromLTRB(i == 0 ? 0 : 12, 8, 0, 8),
      child: Text(
        t,
        textAlign: i == 0 ? TextAlign.left : TextAlign.right,
        style: gaya(i, kepala),
      ),
    );
    // CSS auto table layout: spare width goes to each column in proportion
    // to its max-content width.
    final dasar = DefaultTextStyle.of(context).style.copyWith(fontSize: 14);
    final skala = MediaQuery.textScalerOf(context);
    double lebarTeks(String t, int i, bool kepala) {
      final tp = TextPainter(
        text: TextSpan(text: t, style: dasar.merge(gaya(i, kepala))),
        textDirection: TextDirection.ltr,
        textScaler: skala,
      )..layout();
      final w = tp.width + (i == 0 ? 0 : 12);
      tp.dispose();
      return w;
    }

    final kolom = {
      for (var i = 0; i < _kepala.length; i++)
        i: FlexColumnWidth(
          [
            lebarTeks(_kepala[i], i, true),
            for (final r in _posisi) lebarTeks(r[i], i, false),
          ].reduce(math.max),
        ),
    };
    return LayoutBuilder(
      builder: (context, k) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: math.max(600, k.maxWidth),
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 14),
            child: Table(
              columnWidths: kolom,
              defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: c.tinta)),
                  ),
                  children: [
                    for (final (i, t) in _kepala.indexed)
                      sel(t, i, kepala: true),
                  ],
                ),
                for (final r in _posisi)
                  TableRow(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: c.garis)),
                    ),
                    children: [for (final (i, t) in r.indexed) sel(t, i)],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KartuSisi extends StatelessWidget {
  const _KartuSisi({required this.anak, required this.jarak});
  final List<Widget> anak;
  final double jarak;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, w) in anak.indexed) ...[
            if (i > 0) SizedBox(height: jarak),
            w,
          ],
        ],
      ),
    );
  }
}
