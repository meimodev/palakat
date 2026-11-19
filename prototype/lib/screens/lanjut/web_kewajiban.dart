import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show OverflowBoxFit;

import '../../mock/format.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/tata_letak.dart';

typedef _Label = ({
  String tab,
  String pihak,
  String awal,
  String sudah,
  String sisaPendek,
  String sisa,
  String cat,
  List<String> st,
  String kaki,
});

const Map<String, _Label> _lbl = {
  'um': (
    tab: 'Uang Muka',
    pihak: 'Diberikan kepada',
    awal: 'Diberikan',
    sudah: 'Sudah dicatat',
    sisaPendek: 'Sisa',
    sisa: 'Sisa belum dipertanggungjawabkan',
    cat:
        'Uang muka bukan Belanja saat diberikan. Pertanggungjawaban yang '
        'diterima menjadi Belanja; pengembalian sisa bukan Pendapatan.',
    st: [
      'Belum dipertanggungjawabkan',
      'Sebagian dipertanggungjawabkan',
      'Sudah dipertanggungjawabkan',
    ],
    kaki:
        'Kasus yang belanjanya melebihi uang muka ditampilkan terpisah dan '
        'tidak pernah mengurangi sisa kasus lain. Kelebihannya dibayar lewat '
        'Penggantian biaya.',
  ),
  'tt': (
    tab: 'Titipan',
    pihak: 'Titipan untuk',
    awal: 'Terkumpul',
    sudah: 'Disalurkan',
    sisaPendek: 'Sisa',
    sisa: 'Sisa belum disalurkan',
    cat:
        'Uang titipan untuk pihak lain: bukan Pendapatan saat masuk, bukan '
        'Belanja saat disalurkan.',
    st: ['Belum disalurkan', 'Sebagian disalurkan', 'Sudah disalurkan'],
    kaki:
        'Sentralisasi dari uang milik sendiri dicatat sebagai Belanja biasa, '
        'tidak di sini. Aturan Jemaat yang menentukan, bukan nomor Mata '
        'Anggarannya.',
  ),
  'pb': (
    tab: 'Penggantian biaya',
    pihak: 'Dibayar kepada',
    awal: 'Klaim',
    sudah: 'Dibayar',
    sisaPendek: 'Belum dibayar',
    sisa: 'Belum dibayar',
    cat: 'Klaim belum masuk saldo. Pembayarannya mencatat Belanja satu kali.',
    st: ['Belum dibayar', 'Belum dibayar', 'Sudah dibayar'],
    kaki: 'Mengecek klaim tidak mengubah saldo.',
  ),
};

// Board data (WebKewajiban.dc.html `D`): kind, case, note, party, opening,
// recorded, due text, past due. Its own figures, not the phone board's.
const _d = <(String, String, String, String, int, int, String, bool)>[
  (
    'um',
    'Panitia Natal',
    'BKU-2026-0129 · 01/11/2026',
    'Sdr. Rivo Mandagi',
    1500000,
    850000,
    'Jatuh tempo 30/11/2026',
    false,
  ),
  (
    'um',
    'Retret Pemuda',
    'BKU-2026-0112 · 20/10/2026',
    'Sdri. Natalia Rumengan',
    800000,
    300000,
    'Lewat jatuh tempo (jatuh tempo: 10/11/2026)',
    true,
  ),
  (
    'um',
    'Konsumsi syukur HUT',
    'BKU-2026-0119 · 25/10/2026',
    'Ibu Selvie Kalalo',
    300000,
    375000,
    '',
    false,
  ),
  (
    'um',
    'Perjalanan dinas Wilayah',
    'BKU-2026-0103 · 07/10/2026',
    'Pnt. Jefry Wowor',
    400000,
    400000,
    '',
    false,
  ),
  (
    'tt',
    'Sentralisasi November',
    'Disimpan di Bank BNI ··4821',
    'Sinode',
    2400000,
    1000000,
    '',
    false,
  ),
  (
    'tt',
    'Persembahan khusus',
    'Disimpan di Kas',
    'Wilayah',
    450000,
    0,
    '',
    false,
  ),
  (
    'pb',
    'Alat kebersihan gereja',
    'Nota 12/11/2026 · klaim sudah dicek',
    'Ibu Selvie Kalalo',
    185000,
    0,
    '',
    false,
  ),
  (
    'pb',
    'Kelebihan konsumsi syukur HUT',
    'Dari uang muka BKU-2026-0119',
    'Ibu Selvie Kalalo',
    75000,
    0,
    '',
    false,
  ),
  (
    'pb',
    'Bensin antar jemput',
    'BKU-2026-0134 · 05/11/2026',
    'Sdr. Rivo Mandagi',
    120000,
    120000,
    '',
    false,
  ),
];

class WebKewajibanScreen extends StatefulWidget {
  const WebKewajibanScreen({super.key});
  @override
  State<WebKewajibanScreen> createState() => _WebKewajibanScreenState();
}

class _WebKewajibanScreenState extends State<WebKewajibanScreen> {
  String _tab = 'um';

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final lb = _lbl[_tab]!;
    final d = _d.where((x) => x.$1 == _tab).toList();
    final buka = d.where((x) => x.$5 - x.$6 > 0).toList();
    final lebih = d.where((x) => x.$5 - x.$6 < 0).toList();
    final tinta2 = TextStyle(fontSize: 14, color: c.tinta2);
    const mono = TextStyle(
      fontFamily: PalakatText.mono,
      fontWeight: FontWeight.w500,
      letterSpacing: -1,
    );

    Widget tautan(String teks) => ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
      child: Align(
        widthFactor: 1,
        heightFactor: 1,
        child: Text(
          teks,
          style: TextStyle(
            color: c.laut,
            decoration: TextDecoration.underline,
            decorationColor: c.laut,
          ),
        ),
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: DefaultTextHeightBehavior(
        textHeightBehavior: const TextHeightBehavior(
          leadingDistribution: TextLeadingDistribution.even,
        ),
        child: HalamanWeb(
          jabatanKosong: true,
          nav: NavSamping(
            item: navKeuangan,
            aktif: 2,
            pengguna: const PenggunaKeuangan(),
          ),
          isi: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: const Text(
                    'Uang Muka dan Titipan',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  'Uang yang masih berjalan, satu baris per kasus. Sisa '
                  'dihitung dari catatannya dan tidak dapat diketik.',
                  style: tinta2,
                ),
              ],
            ),
            MarginNegatif(
              atas: 8,
              child: DefaultTextStyle.merge(
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                child: Wrap(
                  spacing: 22,
                  children: [
                    Tautan(ke: 'WebKasusBaru', child: tautan('+ Kasus baru')),
                    Tautan(ke: 'WebKasus', child: tautan('Catat pada kasus')),
                  ],
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in const ['um', 'tt', 'pb'])
                  ChipSatu(
                    teks: _lbl[t]!.tab,
                    dipilih: _tab == t,
                    padding: 16,
                    onTap: () => setState(() => _tab = t),
                  ),
              ],
            ),
            Builder(
              builder: (context) {
                final gTotal = mono.copyWith(fontSize: 40, height: 1.1);
                final gLebih = mono.copyWith(
                  fontSize: 24,
                  letterSpacing: 0,
                  color: c.bata,
                );
                final kalimatA = '${lb.sisa} · ${buka.length} kasus';
                final totalA = rp(buka.fold(0, (a, x) => a + x.$5 - x.$6));
                final kalimatB =
                    'Lebih dari uang muka · ${lebih.length} kasus · tidak '
                    'dikurangkan dari sisa di kiri';
                final totalB = rp(lebih.fold(0, (a, x) => a + x.$6 - x.$5));
                Widget blok(String atas, String bawah, TextStyle g) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(atas, style: tinta2),
                    Text(bawah, style: g),
                  ],
                );
                return BarisLentur(
                  jarak: 40,
                  jarakBaris: 12,
                  rata: CrossAxisAlignment.end,
                  anak: [
                    Lentur(
                      dasar: _lebar(context, [
                        (kalimatA, tinta2),
                        (totalA, gTotal),
                      ]),
                      tumbuh: 0,
                      child: blok(kalimatA, totalA, gTotal),
                    ),
                    if (lebih.isNotEmpty)
                      Lentur(
                        dasar: _lebar(context, [
                          (kalimatB, tinta2),
                          (totalB, gLebih),
                        ]),
                        tumbuh: 0,
                        child: blok(kalimatB, totalB, gLebih),
                      ),
                    Lentur(dasar: 260, child: Text(lb.cat, style: tinta2)),
                  ],
                );
              },
            ),
            _Tabel(lb: lb, baris: d),
            Text(lb.kaki, style: TextStyle(fontSize: 13, color: c.tinta3)),
          ],
        ),
      ),
    );
  }
}

/// Content width of a block of lines (CSS `flex: 0 1 auto` basis).
double _lebar(BuildContext context, List<(String, TextStyle)> baris) {
  final dasar = DefaultTextStyle.of(context).style;
  var w = 0.0;
  for (final (t, g) in baris) {
    final tp = TextPainter(
      text: TextSpan(text: t, style: dasar.merge(g)),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    if (tp.width > w) w = tp.width;
    tp.dispose();
  }
  return w.ceilToDouble();
}

class _Tabel extends StatelessWidget {
  const _Tabel({required this.lb, required this.baris});
  final _Label lb;
  final List<(String, String, String, String, int, int, String, bool)> baris;

  static const _minLebar = 900.0;

  Widget _grid(List<Widget> sel, {bool tengah = false}) => Row(
    crossAxisAlignment: tengah
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start,
    children: [
      Expanded(flex: 13, child: sel[0]),
      const SizedBox(width: 16),
      Expanded(flex: 11, child: sel[1]),
      const SizedBox(width: 16),
      SizedBox(width: 130, child: sel[2]),
      const SizedBox(width: 16),
      SizedBox(width: 130, child: sel[3]),
      const SizedBox(width: 16),
      SizedBox(width: 140, child: sel[4]),
      const SizedBox(width: 16),
      Expanded(flex: 15, child: sel[5]),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    const kanan = TextAlign.right;
    final kepala = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: c.tinta2,
        ),
        child: _grid([
          const Text('Kasus'),
          Text(lb.pihak),
          Text(lb.awal, textAlign: kanan),
          Text(lb.sudah, textAlign: kanan),
          Text(lb.sisaPendek, textAlign: kanan),
          const Text('Status'),
        ]),
      ),
    );
    final isi = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [kepala, for (final d in baris) _baris(context, d)],
    );
    return Container(
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: LayoutBuilder(
          builder: (context, k) => k.maxWidth >= _minLebar
              ? isi
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(width: _minLebar, child: isi),
                ),
        ),
      ),
    );
  }

  Widget _baris(
    BuildContext context,
    (String, String, String, String, int, int, String, bool) d,
  ) {
    final c = context.warna;
    final x = d.$5 - d.$6, beres = x == 0, lebihBelanja = x < 0;
    final status = lebihBelanja
        ? 'Lebih dipertanggungjawabkan'
        : (beres ? lb.st[2] : (d.$6 != 0 ? lb.st[1] : lb.st[0]));
    final tempo = beres ? '' : d.$7;
    const mono = TextStyle(fontFamily: PalakatText.mono);
    return Container(
      // Board min-height 60 is content-box: plus padding 8 + 8 and the 1 px line.
      constraints: const BoxConstraints(minHeight: 77),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.garis)),
      ),
      alignment: Alignment.centerLeft,
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 14),
        child: _grid(tengah: true, [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(d.$2, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(d.$3, style: TextStyle(fontSize: 13, color: c.tinta3)),
            ],
          ),
          Text(d.$4),
          Text(rp(d.$5), style: mono, textAlign: TextAlign.right),
          Text(
            d.$6 != 0 ? rp(d.$6) : '—',
            style: mono,
            textAlign: TextAlign.right,
          ),
          Text(
            lebihBelanja ? 'lebih ${rp(-x)}' : rp(x),
            style: mono.copyWith(
              fontWeight: FontWeight.w600,
              color: lebihBelanja ? c.bata : c.tinta,
            ),
            textAlign: TextAlign.right,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Lencana(
                teks: status,
                isi: beres ? c.laut : c.permukaan,
                garis: beres ? c.laut : (lebihBelanja ? c.bata : c.tinta3),
                gaya: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: beres ? c.diLaut : (lebihBelanja ? c.bata : c.tinta2),
                ),
              ),
              if (tempo.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    tempo,
                    style: TextStyle(
                      fontSize: 13,
                      color: c.tinta,
                      fontWeight: d.$8 ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
            ],
          ),
        ]),
      ),
    );
  }
}

/// The board's inline-block status badge (padding 3 9, 1.5 line, radius 6).
/// Shrink-to-fit like CSS: it wraps only at spaces, and a word longer than
/// the column pushes the badge past it (Chrome) instead of breaking
/// mid-word. Keeps one line when Flutter's glyphs come out up to 2 px wider
/// than Chrome's ("Sebagian dipertanggungjawabkan" just fits at 1440).
class _Lencana extends StatelessWidget {
  const _Lencana({
    required this.teks,
    required this.isi,
    required this.garis,
    required this.gaya,
  });
  final String teks;
  final Color isi, garis;
  final TextStyle gaya;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, k) {
      const tepi = 2 * (9 + 1.5);
      final ruang = k.maxWidth - tepi;
      final penuh = _lebar(context, [(teks, gaya)]);
      final kata = _lebar(context, [
        for (final w in teks.split(' ')) (w, gaya),
      ]);
      final satuBaris = penuh <= ruang + 2;
      final lebar = (satuBaris ? penuh : (kata > ruang ? kata : ruang)) + tepi;
      return SizedBox(
        width: lebar.clamp(0.0, k.maxWidth),
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: lebar,
          maxWidth: lebar,
          fit: OverflowBoxFit.deferToChild,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: ShapeDecoration(
              color: isi,
              shape: GarisBorder.penuh(garis, radius: 6),
            ),
            child: Text(teks, style: gaya, softWrap: !satuBaris),
          ),
        ),
      );
    },
  );
}
