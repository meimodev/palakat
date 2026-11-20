import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/finance/finance.dart';
import '../../providers/keuangan/laporan.dart';
import '../lanjut/laporan_tabel.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../app/layar.dart';

/// One sheet of the TERBATAS file (the board's `LAPT`). [lebar] are the grid
/// tracks after the board adds 28 px to each `px` column; null is the
/// `minmax(0, 1fr)` column. A row whose bool is true is a bold total row.
typedef _Lembar = ({
  String judul,
  List<String> kolom,
  List<double?> lebar,
  List<int> kanan,
  List<(List<String>, bool)> baris,
});

/// The TERBATAS sheets of [l] for the viewer's Fund, read from its
/// RestrictedReport.
Map<String, _Lembar> _lembarDari(LaporanBulan l, RestrictedReport r) => {
  for (final (kode, nama, t) in lembarTerbatas(l, r))
    kode: (
      judul: nama,
      kolom: t.cols,
      lebar: [for (final w in lebarKolom(t)) w == null ? null : w + 28],
      kanan: t.kanan,
      baris: [for (final x in t.rows) (selBaris(x), x.last is int)],
    ),
};

final _uang = RegExp(r'^.?Rp');
final _kode = RegExp(r'^(BKU|OPN|ADJ)-|^\d\.\d');

/// A spreadsheet cell shows a number: "−Rp300.000" → "-300.000", "Rp0" → "0".
String _xl(String v) =>
    v.replaceFirst('−Rp', '-').replaceFirst(RegExp('^Rp'), '');

/// Web · the TERBATAS workbook of the route's month (WebExcelTerbatas): one
/// sheet per TERBATAS form, only the viewer's Fund rows. Opened by "Unduh
/// Excel"; no file is written (D15).
class WebExcelTerbatasScreen extends ConsumerStatefulWidget {
  const WebExcelTerbatasScreen({super.key});

  @override
  ConsumerState<WebExcelTerbatasScreen> createState() =>
      _WebExcelTerbatasState();
}

class _WebExcelTerbatasState extends ConsumerState<WebExcelTerbatasScreen> {
  String _pilih = 'F05';

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final l = laporanRute(context, ref);
    final t = ref.watch(terbatasProvider);
    final r = l == null
        ? null
        : ref.watch(laporanTerbatasProvider(l.periode.id));
    if (l == null || t == null || r == null) {
      return const HalamanWeb(
        nav: NavSamping(item: navKeuangan, aktif: 5),
        isi: [Text('Tidak berwenang')],
      );
    }
    final dana = t.dana.name;
    final lembarAda = _lembarDari(l, r);
    final pilih = lembarAda.containsKey(_pilih) ? _pilih : lembarAda.keys.first;
    final kuat = TextStyle(fontWeight: FontWeight.w700, color: c.tinta);

    return HalamanWeb(
      nav: NavSamping(item: navKeuangan, aktif: 5),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The phone shows this page without WebPaketLaporan behind it.
            if (adaLayar(context, Layar.paketLaporan))
              MarginNegatif(
                atas: 11.125,
                bawah: 11.125,
                child: Tautan(
                  ke: Layar.paketLaporan,
                  cara: Cara.naik,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1,
                    heightFactor: 1,
                    child: TautanTeks('Laporan', ukuran: 14),
                  ),
                ),
              ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: const Text(
                'Contoh file Excel TERBATAS',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              'File dibuat khusus untuk bagian peruntukan $dana. Bukan '
              'versi tersembunyi dari file seluruh Jemaat.',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: c.permukaan,
            border: Border.all(color: c.garisTegas),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: c.garis)),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    Text(
                      'Paket-Laporan-GMIM_Jemaat-Karunia_${l.periode.id}'
                              '_TERBATAS-$dana.xlsx'
                          .replaceAll('-', '-\u200B'),
                      style: const TextStyle(
                        fontFamily: PalakatText.mono,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'TERBATAS · Akses terbatas: Peruntukan $dana · hanya '
                      'lembar yang punya bagian $dana',
                      style: TextStyle(fontSize: 13, color: c.tinta3),
                    ),
                  ],
                ),
              ),
              _Kisi(
                lembar: lembarAda[pilih]!,
                periode: l.periode,
                kepala:
                    '${l.resmi ? 'Laporan resmi · ${l.snapshot!.id}' : 'Laporan sementara'}'
                    ' · TERBATAS · Akses terbatas: Peruntukan $dana',
              ),
              Container(
                decoration: BoxDecoration(
                  color: c.kertas,
                  border: Border(top: BorderSide(color: c.garisTegas)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final id in lembarAda.keys)
                        _Tab(
                          id: id,
                          dipilih: id == pilih,
                          onTap: () => setState(() => _pilih = id),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        DefaultTextStyle.merge(
          style: TextStyle(fontSize: 14, color: c.tinta2),
          child: KisiOtomatis(
            minLebar: 280,
            jarak: 28,
            jarakBaris: 12,
            anak: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Baris 1 sampai 4', style: kuat),
                    const TextSpan(
                      text:
                          ' selalu memuat judul, Jemaat, Periode laporan dan '
                          'ID laporan resmi, supaya lembar yang dicetak sendiri '
                          'tetap dapat dikenali.',
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Angka negatif', style: kuat),
                    const TextSpan(
                      text: ' memakai tanda minus dan tidak dipotong ke nol. ',
                    ),
                    TextSpan(text: 'Nol', style: kuat),
                    const TextSpan(text: ' ditulis 0. '),
                    TextSpan(text: 'Yang tidak ada', style: kuat),
                    const TextSpan(text: ' dibiarkan kosong, bukan 0.'),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Nomor Mata Anggaran dan No. Bukti',
                      style: kuat,
                    ),
                    const TextSpan(
                      text:
                          ' disimpan sebagai teks, persis seperti tersimpan, '
                          'supaya Excel tidak mengubahnya menjadi tanggal atau '
                          'angka.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.id, required this.dipilih, required this.onTap});
  final String id;
  final bool dipilih;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      dipilih: dipilih,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: dipilih ? c.permukaan : null,
          border: Border(right: BorderSide(color: c.garis)),
        ),
        // box-shadow: inset 0 -3px 0 laut (takes no space)
        foregroundDecoration: dipilih
            ? BoxDecoration(
                border: Border(bottom: BorderSide(color: c.laut, width: 3)),
              )
            : null,
        child: Text(
          id,
          style: TextStyle(
            fontFamily: PalakatText.mono,
            fontSize: 13,
            fontWeight: dipilih ? FontWeight.w700 : FontWeight.w500,
            color: c.tinta,
          ),
        ),
      ),
    );
  }
}

/// The grid: column letters, rows 1–4 identification, 5 blank, 6 headers,
/// data from 7. Scrolls sideways inside the window below its min-width.
class _Kisi extends StatelessWidget {
  const _Kisi({
    required this.lembar,
    required this.periode,
    required this.kepala,
  });
  final _Lembar lembar;
  final Period periode;

  /// Row 4: 'Laporan resmi · {ID} · TERBATAS · …'.
  final String kepala;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final l = lembar;
    final n = l.kolom.length;
    final tetap = l.lebar.fold<double>(0, (s, w) => s + (w ?? 0));
    final adaFr = l.lebar.contains(null);
    final minLebar = 44 + tetap + (adaFr ? 300 : 0);

    List<String> isi(String t) => [t, for (var i = 1; i < n; i++) ''];
    final baris =
        <({List<String> sel, bool tebal, bool lebar, bool data, bool kepala})>[
          (
            sel: isi(l.judul.toUpperCase()),
            tebal: true,
            lebar: true,
            data: false,
            kepala: false,
          ),
          (
            sel: isi('Jemaat Karunia'),
            tebal: false,
            lebar: true,
            data: false,
            kepala: false,
          ),
          (
            sel: isi('Periode laporan: ${periode.start} s.d. ${periode.end}'),
            tebal: false,
            lebar: true,
            data: false,
            kepala: false,
          ),
          (
            sel: isi(kepala),
            tebal: false,
            lebar: true,
            data: false,
            kepala: false,
          ),
          (
            sel: isi(''),
            tebal: false,
            lebar: false,
            data: false,
            kepala: false,
          ),
          (sel: l.kolom, tebal: true, lebar: false, data: false, kepala: true),
          for (final (sel, total) in l.baris)
            (sel: sel, tebal: total, lebar: false, data: true, kepala: false),
        ];

    final garis = BorderSide(color: c.garis);
    return LayoutBuilder(
      builder: (context, k) {
        final total = math.max(k.maxWidth, minLebar);
        final lebar = [
          44.0,
          for (final w in l.lebar) w ?? math.max(0.0, total - 44 - tetap),
        ];

        Widget sel(
          double w,
          String v, {
          required TextAlign rata,
          required bool mono,
          Color? warna,
          Color? latar,
          bool tumpah = false,
          EdgeInsets padding = const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
        }) {
          final teks = Text(
            v,
            textAlign: rata,
            softWrap: !tumpah,
            maxLines: tumpah ? 1 : null,
            overflow: TextOverflow.visible,
            style: TextStyle(
              fontFamily: mono ? PalakatText.mono : PalakatText.sans,
              color: warna,
            ),
          );
          return Container(
            width: w,
            padding: padding,
            decoration: BoxDecoration(
              color: latar,
              border: Border(right: garis),
            ),
            // white-space: nowrap; overflow: visible – runs over the blank
            // cells to its right, like Excel.
            child: tumpah
                ? OverflowBox(
                    alignment: Alignment.topLeft,
                    minWidth: 0,
                    maxWidth: double.infinity,
                    child: teks,
                  )
                : teks,
          );
        }

        final huruf = [
          '',
          for (var i = 0; i < n; i++) String.fromCharCode(65 + i),
        ];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: total,
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontFamily: PalakatText.mono,
                fontSize: 13,
                color: c.tinta,
                leadingDistribution: TextLeadingDistribution.even,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: c.kertas,
                      border: Border(bottom: BorderSide(color: c.garisTegas)),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < huruf.length; i++)
                            sel(
                              lebar[i],
                              huruf[i],
                              rata: TextAlign.center,
                              mono: true,
                              warna: c.tinta2,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  for (var r = 0; r < baris.length; r++)
                    Container(
                      decoration: BoxDecoration(
                        color: baris[r].kepala ? c.kertas : c.permukaan,
                        border: Border(bottom: garis),
                      ),
                      child: DefaultTextStyle.merge(
                        style: TextStyle(
                          fontWeight: baris[r].tebal
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              sel(
                                44,
                                '${r + 1}',
                                rata: TextAlign.center,
                                mono: true,
                                warna: c.tinta2,
                                latar: c.kertas,
                              ),
                              for (var i = 0; i < n; i++)
                                () {
                                  final v = baris[r].sel[i];
                                  final uang = _uang.hasMatch(v);
                                  return sel(
                                    lebar[i + 1],
                                    uang ? _xl(v) : v,
                                    rata:
                                        uang ||
                                            (baris[r].data &&
                                                l.kanan.contains(i))
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    mono: uang || _kode.hasMatch(v),
                                    tumpah: baris[r].lebar,
                                  );
                                }(),
                            ],
                          ),
                        ),
                      ),
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
