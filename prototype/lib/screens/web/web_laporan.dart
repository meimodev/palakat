import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/finance/finance.dart';
import '../../providers/keuangan/akhir_bulan.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/keuangan/laporan.dart';
import '../lanjut/laporan_tabel.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/pita_laporan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';

/// F01 lines (`B`): label, value, note, total, link to the transactions.
List<(String, String, String, bool, bool)> _baris(LaporanBulan l) => [
  for (final r in tabelLaporan(l, ReportForm.f01).rows)
    (
      r[0] as String,
      r[1] as String,
      switch (r[0]) {
        'Dana Transit masuk' => 'titipan masuk',
        'Dana Transit keluar' => 'titipan disalurkan',
        _ => '',
      },
      r.last is int,
      r.last is! int,
    ),
];

/// WebLaporan: F01 of `laporanBulanProvider` on paper, provisional before
/// the close and official after it.
class WebLaporanScreen extends ConsumerWidget {
  const WebLaporanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final l = ref.watch(laporanBulanProvider);
    if (l == null) {
      return const HalamanWeb(
        nav: NavSamping(item: navKeuangan, aktif: 5),
        layarKeuangan: true,
        isi: [Text('Belum ada bulan untuk dilaporkan.')],
      );
    }
    final resmi = l.resmi;
    final bulan = namaBulan(l.periode);
    final f = l.format;
    return HalamanWeb(
      nav: const NavSamping(item: navKeuangan, aktif: 5),
      jarak: 18,
      layarKeuangan: true,
      isi: [
        _BarisJudul(l: l),
        if (resmi)
          PitaLaporan.resmi(
            dibekukan: dibekukan(l.snapshot!),
            idSalinan: l.snapshot!.id,
            versi: l.data(ReportForm.f05).totals['versionCode'] as String?,
            sebaris: true,
          )
        else
          PitaLaporan.sementara(
            kalimat:
                'Bukan laporan resmi. Angka masih dapat berubah sampai '
                '$bulan ditutup; file resmi dibuat setelah tutup buku.',
            sebaris: true,
          ),
        BarisLentur(
          jarak: 24,
          anak: [
            Lentur(dasar: 560, tumbuh: 999, child: _Kertas(l: l)),
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
                      Text(
                        f?.name ?? 'Bawaan Palakat',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          f == null
                              ? 'Persetujuan format: belum dicatat'
                              : 'Persetujuan format: sudah dicatat',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (f != null)
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Pemberi persetujuan:',
                                style: TextStyle(color: c.tinta2),
                              ),
                              const TextSpan(
                                text: ' [NAMA], Pimpinan Jemaat yang berwenang',
                              ),
                            ],
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      if (f != null)
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
                                'Dicatat oleh ${l.pencatatFormat}, '
                                '${tglJam(f.acceptedAt!)}. Persetujuan diberikan '
                                'di luar aplikasi.',
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
                          ke: Layar.paketLaporan,
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
  const _BarisJudul({required this.l});
  final LaporanBulan l;

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
    final resmi = l.resmi;
    final judul = Semantics(
      header: true,
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'Laporan '),
            TextSpan(
              text: '· ${namaBulan(l.periode)}',
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
          child: Tombol(
            'Unduh PDF',
            onPressed: null,
            ke: Layar.laporanResmi,
            param: {'periode': l.periode.id, 'bentuk': 'f01'},
            ukuran: UkuranTombol.kecil,
            paddingH: 18,
          ),
        ),
        Lentur(
          dasar: _lebar(context, 'Unduh Excel', 3),
          tumbuh: 0,
          child: Tombol(
            'Unduh Excel',
            onPressed: null,
            ke: Layar.laporanResmi,
            param: {'periode': l.periode.id, 'bentuk': 'excel'},
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
  const _Kertas({required this.l});
  final LaporanBulan l;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final resmi = l.resmi;
    final posisi = tabelLaporan(l, ReportForm.f10);
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
                Text(
                  'Jemaat Karunia · Periode laporan '
                  '${rentangPeriode(l.periode)}',
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
              for (final (i, b) in _baris(l).indexed)
                _BarisF01(b, pertama: i == 0),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Posisi Kas & Bank per ${tglPanjang(l.periode.end.awal)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _TabelPosisi(posisi.rows.map((r) => r.cast<String>()).toList()),
          const SizedBox(height: 8),
          Text(posisi.kaki, style: kecil3),
          const SizedBox(height: 22 + 8),
          KisiOtomatis(
            minLebar: 200,
            jarak: 24,
            anak: [
              for (final (jabatan, nama) in [
                ('Bendahara', l.penutup ?? '[NAMA]'),
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
    final gayaTeks = TextStyle(
      fontWeight: total ? FontWeight.w700 : FontWeight.w500,
    );
    final rentangTeks = TextSpan(
      children: [
        TextSpan(text: '$label '),
        if (catatan.isNotEmpty)
          TextSpan(
            text: '· $catatan',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
      ],
    );
    const gayaTautan = TextStyle(fontSize: 13, fontWeight: FontWeight.w600);
    final gayaNilai = TextStyle(
      fontFamily: PalakatText.mono,
      fontWeight: total ? FontWeight.w600 : FontWeight.w400,
    );
    final dasar = DefaultTextStyle.of(context).style;
    TextPainter ukur(InlineSpan t) => TextPainter(
      text: TextSpan(style: dasar, children: [t]),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final pTeks = ukur(TextSpan(style: gayaTeks, children: [rentangTeks]));
    final pTautan = ukur(
      const TextSpan(text: 'Lihat transaksi', style: gayaTautan),
    );
    final pNilai = ukur(TextSpan(text: nilai, style: gayaNilai));

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
      child: LayoutBuilder(
        builder: (context, k) {
          // CSS flex: label `flex: 1` (basis 0), link and figure `0 1 auto`
          // (link max-content, figure 150), none below its min-content; on a
          // narrow page the label stops at its longest word and the link
          // and figure shrink by their basis (390 wide).
          final jarak = lihat ? 24.0 : 12.0;
          final dTautan = lihat ? pTautan.maxIntrinsicWidth : 0.0;
          var wTautan = dTautan, wNilai = 150.0;
          var wTeks = k.maxWidth - jarak - wTautan - wNilai;
          if (wTeks < pTeks.minIntrinsicWidth) {
            wTeks = pTeks.minIntrinsicWidth;
            final kurang = wTeks + jarak + dTautan + 150 - k.maxWidth;
            final minT = lihat ? pTautan.minIntrinsicWidth : 0.0;
            final minN = pNilai.maxIntrinsicWidth;
            wTautan = dTautan - kurang * dTautan / (dTautan + 150);
            wNilai = 150 - kurang * 150 / (dTautan + 150);
            if (wTautan < minT) {
              wTautan = minT;
              wNilai = k.maxWidth - jarak - wTeks - minT;
            } else if (wNilai < minN) {
              wNilai = minN;
              wTautan = k.maxWidth - jarak - wTeks - minN;
            }
            // Even the minimums overflow (very narrow box or wide font):
            // scale all three to fit and let them wrap, never overflow.
            wTautan = math.max(wTautan, minT);
            wNilai = math.max(wNilai, minN);
            final isi = wTeks + wTautan + wNilai;
            if (isi > k.maxWidth - jarak) {
              final f = math.max(0.0, k.maxWidth - jarak) / isi;
              wTeks *= f;
              wTautan *= f;
              wNilai *= f;
            }
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              SizedBox(
                width: wTeks,
                child: Text.rich(rentangTeks, style: gayaTeks),
              ),
              if (lihat) ...[
                const SizedBox(width: 12),
                SizedBox(
                  width: wTautan,
                  child: const Tautan(
                    ke: Layar.transaksi,
                    child: SizedBox(
                      height: 44,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: 1,
                        child: TautanTeks('Lihat transaksi', ukuran: 13),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 12),
              SizedBox(
                width: wNilai,
                child: Text(
                  nilai,
                  textAlign: TextAlign.right,
                  style: gayaNilai,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// `table` min-width 600, width 100%, scrolling sideways inside the paper.
class _TabelPosisi extends StatelessWidget {
  const _TabelPosisi(this._posisi);
  final List<List<String>> _posisi;

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
    // CSS auto table layout: each column's min-content (longest word) and
    // max-content width, both plus its 12 px left padding.
    final dasar = DefaultTextStyle.of(context).style.copyWith(fontSize: 14);
    final skala = MediaQuery.textScalerOf(context);
    final minK = List.filled(_kepala.length, 0.0);
    final maksK = List.filled(_kepala.length, 0.0);
    for (var i = 0; i < _kepala.length; i++) {
      for (final (t, kepala) in [
        (_kepala[i], true),
        for (final r in _posisi) (r[i], false),
      ]) {
        final tp = TextPainter(
          text: TextSpan(text: t, style: dasar.merge(gaya(i, kepala))),
          textDirection: TextDirection.ltr,
          textScaler: skala,
        )..layout();
        final pad = i == 0 ? 0.0 : 12.0;
        minK[i] = math.max(minK[i], tp.minIntrinsicWidth.ceilToDouble() + pad);
        maksK[i] = math.max(
          maksK[i],
          tp.maxIntrinsicWidth.ceilToDouble() + pad,
        );
        tp.dispose();
      }
    }
    final jumlahMin = minK.reduce((a, b) => a + b);
    final jumlahMaks = maksK.reduce((a, b) => a + b);
    // Table width W: at least max-content → spare width in proportion to
    // max-content; else min-content plus a share of (max − min).
    Map<int, TableColumnWidth> kolom(double w) => {
      for (var i = 0; i < _kepala.length; i++)
        i: FixedColumnWidth(
          w >= jumlahMaks
              ? maksK[i] * w / jumlahMaks
              : minK[i] +
                    (w - jumlahMin) *
                        (maksK[i] - minK[i]) /
                        (jumlahMaks - jumlahMin),
        ),
    };
    return LayoutBuilder(
      builder: (context, k) {
        final w = math.max(math.max(600.0, k.maxWidth), jumlahMin);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: w,
            child: DefaultTextStyle.merge(
              style: const TextStyle(fontSize: 14),
              child: Table(
                columnWidths: kolom(w),
                // td/th default to vertical-align: middle.
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
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
        );
      },
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
