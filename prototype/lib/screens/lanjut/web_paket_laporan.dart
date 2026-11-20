import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/finance/finance.dart';
import '../../providers/keuangan/akhir_bulan.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/keuangan/laporan.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/pita_laporan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import 'laporan_tabel.dart';

part 'web_paket_laporan_data.dart';

/// Web · Paket Laporan F01–F14 (spec 05-kewajiban.md). One view; state
/// `pilih` (the selected report). The month is `laporanBulanProvider`'s;
/// the TERBATAS copy lives on WebTerbatas (D27).
class WebPaketLaporanScreen extends ConsumerStatefulWidget {
  const WebPaketLaporanScreen({super.key});

  @override
  ConsumerState<WebPaketLaporanScreen> createState() =>
      _WebPaketLaporanScreenState();
}

class _WebPaketLaporanScreenState extends ConsumerState<WebPaketLaporanScreen> {
  String _pilih = 'F02';

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final l = ref.watch(laporanBulanProvider);
    if (l == null) {
      return const HalamanWeb(
        layarKeuangan: true,
        nav: NavSamping(item: navKeuangan, aktif: 5),
        isi: [Text('Belum ada bulan untuk dilaporkan.')],
      );
    }
    final p = _daftarLaporan.firstWhere((f) => f.$1 == _pilih);
    final isi = p.$3;
    final bulan = namaBulan(l.periode);

    return HalamanWeb(
      layarKeuangan: true,
      nav: const NavSamping(item: navKeuangan, aktif: 5),
      isi: [
        _Judul(l: l),
        DeretTautan(
          web: true,
          anak: [
            const _TautanDeret(
              teks: 'Persetujuan format laporan',
              ke: Layar.formatLaporan,
            ),
            const _TautanDeret(teks: 'Celah nomor', ke: Layar.bukti),
            _TautanDeret(
              teks: 'Halaman A4',
              ke: Layar.laporanResmi,
              param: {
                'periode': l.periode.id,
                'bentuk': l.resmi ? 'f01' : 'sementara',
              },
            ),
            const _TautanDeret(
              teks: 'Lihat transaksi di balik sebuah angka',
              ke: Layar.lihatTransaksi,
            ),
          ],
        ),
        if (l.resmi)
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
            // CSS flex-basis is the content box: + padding and border.
            Lentur(dasar: 216 + 14, child: _daftar(c)),
            Lentur(
              dasar: 620 + 2 * context.jepit(18, 2, 28) + 3,
              tumbuh: 999,
              child: _halaman(context, l, p.$1, p.$2, isi),
            ),
          ],
        ),
      ],
    );
  }

  Widget _daftar(PalakatWarna c) => Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: c.permukaan,
      border: Border.all(color: c.garis),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final f in _daftarLaporan)
          Tekan(
            onTap: () => setState(() => _pilih = f.$1),
            dipilih: _pilih == f.$1,
            radius: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: _pilih == f.$1 ? c.tinta : null,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  fontSize: 14,
                  color: _pilih == f.$1 ? c.permukaan : c.tinta,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      f.$1,
                      style: const TextStyle(
                        fontFamily: PalakatText.mono,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        f.$2,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );

  Widget _halaman(
    BuildContext context,
    LaporanBulan l,
    String kode,
    String nama,
    String isi,
  ) {
    final c = context.warna;
    final kecil = TextStyle(fontSize: 13, color: c.tinta3);
    final kepala = Container(
      padding: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.tinta, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '$kode · ${l.resmi ? 'LAPORAN RESMI' : 'LAPORAN SEMENTARA · BUKAN LAPORAN RESMI'}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.tinta2,
              letterSpacing: .4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            nama.toUpperCase(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: .2,
            ),
          ),
          const SizedBox(height: 2),
          Text('Jemaat Karunia · Periode laporan ${rentangPeriode(l.periode)}'),
          const SizedBox(height: 2),
          Text('Format bawaan aplikasi. $isi', style: kecil),
        ],
      ),
    );

    final List<Widget> badan;
    if (kode == 'F01') {
      badan = [
        const Align(
          alignment: Alignment.centerLeft,
          // Board `<a>` is content-box: 44 + 1.5 px lines = 47.
          child: SizedBox(
            height: 47,
            child: Tombol(
              'Buka halaman F01',
              onPressed: null,
              ke: Layar.laporan,
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.kecil,
              paddingH: 18,
              lebarPenuh: false,
            ),
          ),
        ),
      ];
    } else {
      final lap = _lapDari(l, formLaporan(kode));
      badan = [
        Text(lap.sub, style: const TextStyle(fontWeight: FontWeight.w700)),
        _tabel(context, lap),
        Text(lap.kaki, style: kecil),
        if (kode == 'F02')
          Text(
            'Pembayaran yang dibagi tampil satu kali dengan daftar No. MA-nya. '
            'Pembalikan tampil sebagai angka negatif dan tidak dipotong ke '
            'nol. Kolom saldo selalu menyebut Kas/Bank yang dijumlahkannya.',
            style: kecil,
          ),
      ];
    }

    final ruang = context.jepit(18, 2, 28);
    return Container(
      padding: EdgeInsets.all(ruang),
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.tinta, width: 1.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          kepala,
          for (final b in badan) ...[const SizedBox(height: 18), b],
        ],
      ),
    );
  }

  /// A generic report table: header, rows (bold rows with a `tinta` line).
  Widget _tabel(BuildContext context, _Lap lap) {
    final c = context.warna;
    TextAlign rata(int i) =>
        lap.kanan.contains(i) ? TextAlign.right : TextAlign.left;
    return _Gulir(
      minLebar: lap.minLebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Sel.baris(c, lap.kolom, kepala: true, [
            for (var i = 0; i < lap.judul.length; i++)
              Text(lap.judul[i], textAlign: rata(i)),
          ]),
          for (final b in lap.baris)
            DefaultTextStyle.merge(
              style: TextStyle(
                fontWeight: b.tebal ? FontWeight.w700 : FontWeight.w400,
              ),
              child: _Sel.baris(c, lap.kolom, tebal: b.tebal, [
                for (var i = 0; i < b.sel.length; i++)
                  Text(
                    b.sel[i],
                    textAlign: rata(i),
                    style: lap.mono.contains(i)
                        ? const TextStyle(fontFamily: PalakatText.mono)
                        : null,
                  ),
              ]),
            ),
        ],
      ),
    );
  }
}

/// Title row: h1 (flex 1 1 320) and the two download buttons; wraps.
class _Judul extends StatelessWidget {
  const _Judul({required this.l});
  final LaporanBulan l;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final judul = Semantics(
      header: true,
      child: Text.rich(
        TextSpan(
          text: 'Paket Laporan Bulanan GMIM ',
          children: [
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
        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        // CSS line box: a wrapped line holding only the 15 px span keeps
        // the h1's 26 × 1.45 height.
        strutStyle: const StrutStyle(
          fontFamily: PalakatText.sans,
          fontSize: 26,
          height: 1.45,
          leadingDistribution: TextLeadingDistribution.even,
        ),
      ),
    );
    final pdf = Tombol(
      'Unduh PDF',
      onPressed: null,
      ke: Layar.laporanResmi,
      param: {'periode': l.periode.id, 'bentuk': l.resmi ? 'f01' : 'sementara'},
      ukuran: UkuranTombol.kecil,
      paddingH: 18,
      lebarPenuh: false,
    );
    final excel = Tombol(
      'Unduh Excel',
      onPressed: null,
      ke: Layar.laporanResmi,
      param: {'periode': l.periode.id, 'bentuk': 'excel'},
      jenis: JenisTombol.kedua,
      ukuran: UkuranTombol.kecil,
      paddingH: 18,
      lebarPenuh: false,
    );
    // flex-wrap with the h1 at basis 320: the buttons join its line while
    // they fit, in order (the button width is its 700 label + 2 × 18).
    final gaya = DefaultTextStyle.of(context).style
        .copyWith(fontWeight: FontWeight.w700);
    double lebar(String s) =>
        (TextPainter(
          text: TextSpan(text: s, style: gaya),
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
        )..layout()).width +
        36;
    final wPdf = lebar('Unduh PDF');
    return LayoutBuilder(
      builder: (context, k) {
        final w = k.maxWidth;
        if (w >= 320 + 12 + wPdf + 12 + lebar('Unduh Excel')) {
          return Row(
            children: [
              Expanded(child: judul),
              const SizedBox(width: 12),
              pdf,
              const SizedBox(width: 12),
              excel,
            ],
          );
        }
        if (w >= 320 + 12 + wPdf) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: judul),
                  const SizedBox(width: 12),
                  pdf,
                ],
              ),
              const SizedBox(height: 12),
              excel,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            judul,
            const SizedBox(height: 12),
            Wrap(spacing: 12, runSpacing: 12, children: [pdf, excel]),
          ],
        );
      },
    );
  }
}

/// A 14/600 `laut` link of the link row: min 44×44, text centred vertically.
class _TautanDeret extends StatelessWidget {
  const _TautanDeret({
    required this.teks,
    required this.ke,
    this.param = const {},
  });
  final String teks;
  final Layar ke;
  final Map<String, String> param;

  @override
  Widget build(BuildContext context) => Tautan(
    ke: ke,
    param: param,
    child: Align(widthFactor: 1, heightFactor: 1, child: TautanTeks(teks)),
  );
}

/// `overflow-x: auto` around a table with `min-width`; table text 13.
class _Gulir extends StatelessWidget {
  const _Gulir({required this.minLebar, required this.child});
  final double minLebar;
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, k) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: math.max(minLebar, k.maxWidth),
        child: DefaultTextStyle.merge(
          // CSS splits line-height evenly; mixed fonts on a baseline row
          // would otherwise grow each row.
          style: const TextStyle(
            fontSize: 13,
            leadingDistribution: TextLeadingDistribution.even,
          ),
          child: child,
        ),
      ),
    ),
  );
}

/// One grid row (`grid-template-columns`, gap 10, padding 8 0).
abstract final class _Sel {
  static Widget baris(
    PalakatWarna c,
    List<double?> kolom,
    List<Widget> sel, {
    bool kepala = false,
    bool tebal = false,
  }) {
    final isi = Row(
      crossAxisAlignment: kepala
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        for (var i = 0; i < kolom.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          kolom[i] == null
              ? Expanded(child: sel[i])
              : SizedBox(width: kolom[i], child: sel[i]),
        ],
      ],
    );
    final row = Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: kepala || tebal ? c.tinta : c.garis),
        ),
      ),
      child: isi,
    );
    return kepala
        ? DefaultTextStyle.merge(
            style: const TextStyle(fontWeight: FontWeight.w700),
            child: row,
          )
        : row;
  }
}
