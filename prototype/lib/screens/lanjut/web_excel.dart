import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import 'web_excel_data.dart';
import '../../app/layar.dart';

/// Web · Contoh file Excel (spec 08-cari.md, WebExcel): the October 2026
/// report pack as a workbook, one sheet per form F01–F14.
class WebExcelScreen extends StatefulWidget {
  const WebExcelScreen({super.key});

  @override
  State<WebExcelScreen> createState() => _WebExcelScreenState();
}

class _WebExcelScreenState extends State<WebExcelScreen> {
  String _pilih = 'F02';

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final l = lembarExcel.firstWhere((f) => f.kode == _pilih);
    TextSpan tebal(String t) => TextSpan(
      text: t,
      style: TextStyle(color: c.tinta, fontWeight: FontWeight.w700),
    );

    return HalamanWeb(
      layarKeuangan: true,
      nav: NavSamping(item: navKeuangan, aktif: 5),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The phone shows this page without WebPaketLaporan behind it.
            if (adaLayar(context, Layar.paketLaporan))
              // The link is a 44 px target; the line keeps its text height.
              MarginNegatif(
                atas: 12,
                bawah: 12,
                child: Tautan(
                  ke: Layar.paketLaporan,
                  cara: Cara.naik,
                  child: const Center(
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
                'Contoh file Excel',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              'Isi tiap lembar sama dengan halaman PDF-nya. Angka disimpan '
              'sebagai angka, bukan teks.',
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
                    // Zero-width space: Chrome may break after the hyphen
                    // before "10", the Flutter breaker does not.
                    const Text(
                      'Paket-Laporan-GMIM_Jemaat-Karunia_2026-​10.xlsx',
                      style: TextStyle(
                        fontFamily: PalakatText.mono,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Laporan resmi · ID SNP-2026-10-01 · satu lembar per '
                      'laporan',
                      style: TextStyle(fontSize: 13, color: c.tinta3),
                    ),
                  ],
                ),
              ),
              _Lembar(l, key: ValueKey(l.kode)),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: c.kertas,
                  border: Border(top: BorderSide(color: c.garisTegas)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final f in lembarExcel)
                        _Tab(
                          f.kode,
                          dipilih: f.kode == _pilih,
                          onTap: () => setState(() => _pilih = f.kode),
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
                    tebal('Baris 1 sampai 4'),
                    const TextSpan(
                      text:
                          ' selalu memuat judul, Jemaat, Periode laporan dan '
                          'ID laporan resmi, supaya lembar yang dicetak '
                          'sendiri tetap dapat dikenali.',
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    tebal('Angka negatif'),
                    const TextSpan(
                      text: ' memakai tanda minus dan tidak dipotong ke nol. ',
                    ),
                    tebal('Nol'),
                    const TextSpan(text: ' ditulis 0. '),
                    tebal('Yang tidak ada'),
                    const TextSpan(text: ' dibiarkan kosong, bukan 0.'),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    tebal('Nomor Mata Anggaran dan No. Bukti'),
                    const TextSpan(
                      text:
                          ' disimpan sebagai teks, persis seperti tersimpan, '
                          'supaya Excel tidak mengubahnya menjadi tanggal '
                          'atau angka.',
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

/// A sheet tab: mono 13, min height 44, padding 0 16, 1 px `garis` right
/// rule; selected `permukaan`, 700, 3 px inner `laut` line at the bottom.
class _Tab extends StatelessWidget {
  const _Tab(this.kode, {required this.dipilih, required this.onTap});

  final String kode;
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
        // box-shadow: inset 0 -3px 0 laut (no layout change)
        foregroundDecoration: dipilih
            ? BoxDecoration(
                border: Border(bottom: BorderSide(color: c.laut, width: 3)),
              )
            : null,
        child: Text(
          kode,
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

final _kode = RegExp(r'^(BKU|OPN|ADJ)-|^\d\.\d');
final _uang = RegExp(r'^.?Rp');

/// The grid of one sheet: column letters, rows 1–6, then the data rows.
/// Scrolls sideways on its own; the `fr` column takes what is left.
class _Lembar extends StatelessWidget {
  const _Lembar(this.l, {super.key});

  final LembarExcel l;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    // 44 px row numbers, then every px column + 28; null = minmax(0, 1fr).
    final lebar = <double?>[
      44,
      for (final w in l.lebar) w == null ? null : w + 28,
    ];
    final minW =
        lebar.fold<double>(0, (t, w) => t + (w ?? 0)) +
        (lebar.contains(null) ? 300 : 0);
    final n = l.kolom.length;
    List<String> isi(String t) => [t, for (var i = 1; i < n; i++) ''];
    final baris =
        <({int no, List<String> sel, bool tebal, bool lebar, bool data})>[
          (
            no: 1,
            sel: isi(l.nama.toUpperCase()),
            tebal: true,
            lebar: true,
            data: false,
          ),
          (
            no: 2,
            sel: isi('Jemaat Karunia'),
            tebal: false,
            lebar: true,
            data: false,
          ),
          (
            no: 3,
            sel: isi('Periode laporan: 01/10/2026 s.d. 31/10/2026'),
            tebal: false,
            lebar: true,
            data: false,
          ),
          (
            no: 4,
            sel: isi(
              'Laporan resmi · SNP-2026-10-01 · Versi Mata Anggaran 2026.1',
            ),
            tebal: false,
            lebar: true,
            data: false,
          ),
          (no: 5, sel: isi(''), tebal: false, lebar: false, data: false),
          (no: 6, sel: l.kolom, tebal: true, lebar: false, data: false),
          for (var i = 0; i < l.baris.length; i++)
            (
              no: 7 + i,
              sel: l.baris[i].sel,
              tebal: l.baris[i].tebal,
              lebar: false,
              data: true,
            ),
        ];
    final garisKanan = Border(right: BorderSide(color: c.garis));

    Widget kolom(int i, Widget sel) => lebar[i] == null
        ? Expanded(child: sel)
        : SizedBox(width: lebar[i], child: sel);

    Widget baris1(
      List<Widget> sel, {
      required Color latar,
      required Color garisBawah,
      FontWeight berat = FontWeight.w400,
    }) => Container(
      decoration: BoxDecoration(
        color: latar,
        border: Border(bottom: BorderSide(color: garisBawah)),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontWeight: berat),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [for (var i = 0; i < sel.length; i++) kolom(i, sel[i])],
          ),
        ),
      ),
    );

    Widget sel(
      String v,
      int i,
      ({int no, List<String> sel, bool tebal, bool lebar, bool data}) r,
    ) {
      final uang = _uang.hasMatch(v);
      final mono = uang || _kode.hasMatch(v);
      final teks = uang
          ? v.replaceFirst('−Rp', '-').replaceFirst(RegExp('^Rp'), '')
          // Chrome breaks a sentence after "BKU-" before the digits; ICU
          // keeps "-2026" together, so a zero-width space allows the break.
          : mono
          ? v
          : v.replaceAll('-', '-\u200B');
      final kanan = uang || (l.kanan.contains(i) && r.data);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(border: garisKanan),
        child: Text(
          teks,
          textAlign: kanan ? TextAlign.right : TextAlign.left,
          softWrap: !r.lebar,
          overflow: r.lebar ? TextOverflow.visible : TextOverflow.clip,
          style: TextStyle(
            color: c.tinta,
            fontFamily: mono ? PalakatText.mono : PalakatText.sans,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, k) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: math.max(k.maxWidth, minW),
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontFamily: PalakatText.mono, fontSize: 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                baris1(latar: c.kertas, garisBawah: c.garisTegas, [
                  for (final h in [
                    '',
                    for (var i = 0; i < n; i++) String.fromCharCode(65 + i),
                  ])
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(border: garisKanan),
                      child: Text(
                        h,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: c.tinta2),
                      ),
                    ),
                ]),
                for (final r in baris)
                  baris1(
                    latar: r.no == 6 ? c.kertas : c.permukaan,
                    garisBawah: c.garis,
                    berat: r.tebal ? FontWeight.w700 : FontWeight.w400,
                    [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: c.kertas,
                          border: garisKanan,
                        ),
                        child: Text(
                          '${r.no}',
                          textAlign: TextAlign.center,
                          softWrap: false,
                          overflow: TextOverflow.clip,
                          style: TextStyle(color: c.tinta2),
                        ),
                      ),
                      for (var i = 0; i < r.sel.length; i++)
                        sel(r.sel[i], i, r),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
