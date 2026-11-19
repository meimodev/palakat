import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../mock/format.dart';
import '../../motion/kerangka.dart';
import '../../motion/urutan.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/input_format.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';

/// (id, name, verified total, source) of the three Kas/Bank rows.
const _akun = [
  ('kas', 'Kas', 3200000, 'Berita acara hitung kas 14/09/2026'),
  ('bni', 'Bank BNI ··4821', 24000000, 'Rekening koran 14/09/2026'),
  ('bsg', 'Bank SulutGo ··1107', 5100000, 'Rekening koran 14/09/2026'),
];
const _per = ['Umum Jemaat', 'Diakonia', 'Pembangunan'];
const _awalSel = {
  'kas': ['2000000', '700000', ''],
  'bni': ['20000000', '1500000', '2500000'],
  'bsg': ['5100000', '0', '0'],
};

/// Grid `minmax(170px, 1.3fr) repeat(4, minmax(0, 1fr)) minmax(150px, 1.1fr)`
/// in [w] (gaps already taken out): the CSS fr resolution with minimums.
List<double> _kolom(double w) {
  const fr = [1.3, 1.0, 1.0, 1.0, 1.0, 1.1];
  const min = [170.0, 0.0, 0.0, 0.0, 0.0, 150.0];
  final tetap = List.filled(6, false);
  while (true) {
    var bebas = w, jumlahFr = 0.0;
    for (var i = 0; i < 6; i++) {
      if (tetap[i]) {
        bebas -= min[i];
      } else {
        jumlahFr += fr[i];
      }
    }
    final satuan = jumlahFr == 0 ? 0.0 : math.max(0.0, bebas) / jumlahFr;
    var ubah = false;
    for (var i = 0; i < 6; i++) {
      if (!tetap[i] && fr[i] * satuan < min[i]) tetap[i] = ubah = true;
    }
    if (!ubah) {
      return [for (var i = 0; i < 6; i++) tetap[i] ? min[i] : fr[i] * satuan];
    }
  }
}

class WebAwalScreen extends StatefulWidget {
  const WebAwalScreen({super.key});
  @override
  State<WebAwalScreen> createState() => _WebAwalScreenState();
}

class _WebAwalScreenState extends State<WebAwalScreen> {
  bool _opn = false;
  late final _sel = {
    for (final a in _akun)
      a.$1: [
        for (final d in _awalSel[a.$1]!)
          TextEditingController(text: titik(d))..addListener(_ubah),
      ],
  };

  void _ubah() => setState(() {});

  String _mentah(String id, int i) => _sel[id]![i].text.replaceAll('.', '');
  int _num(String id, int i) => int.tryParse(_mentah(id, i)) ?? 0;
  int _sisa((String, String, int, String) a) =>
      a.$3 - [0, 1, 2].fold(0, (x, i) => x + _num(a.$1, i));
  bool _kosong(String id) => [0, 1, 2].any((i) => _mentah(id, i).isEmpty);
  bool _pas((String, String, int, String) a) => _sisa(a) == 0 && !_kosong(a.$1);
  bool get _semuaPas => _akun.every(_pas);

  @override
  void dispose() {
    for (final l in _sel.values) {
      for (final c in l) {
        c.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final langkah = [
      ('Identitas Jemaat', 'WITA · tahun buku mulai 1 Januari', 'ok'),
      ('Kas/Bank, peruntukan, Lingkup', '3 · 3 · 4', 'ok'),
      ('Mata Anggaran', 'Versi 2026.1 diterbitkan', 'ok'),
      ('Penunjukan Bendahara', 'Wewenang Bendahara aktif', 'ok'),
      (
        'Saldo awal pencatatan',
        _opn ? 'Dibukukan · OPN-2026-0001' : 'Giliran Anda',
        _opn ? 'ok' : 'kini',
      ),
      (
        'Persetujuan format laporan',
        'Wajib sebelum tutup buku pertama',
        'nanti',
      ),
    ];
    return HalamanWeb(
      nav: const NavSamping(
        item: navKeuangan,
        aktif: 6,
        pengguna: PenggunaKeuangan(ikutJabatanKosong: false),
      ),
      jarak: 22,
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: const Text(
                'Pengaturan awal Jemaat',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              _opn
                  ? 'Jemaat siap mencatat. Persetujuan format laporan masih '
                        'perlu dicatat sebelum tutup buku pertama.'
                  : 'Belum ada tindakan keuangan yang tersedia: tinggal satu '
                        'langkah, bukukan saldo awal pencatatan.',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        const MarginNegatif(
          atas: 8,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Tautan(
              ke: 'WebAwalIsian',
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: 1,
                child: TautanTeks('Identitas Jemaat dan daftar', ukuran: 14),
              ),
            ),
          ),
        ),
        _Kisi(
          anak: [for (var i = 0; i < 6; i++) _KartuLangkah(i + 1, langkah[i])],
        ),
        if (!_opn) _bagian(c) else _kartuOpn(c),
      ],
    );
  }

  Widget _bagian(PalakatWarna c) {
    final semuaPas = _semuaPas;
    final kolom = [
      for (var i = 0; i < 3; i++) _akun.fold(0, (x, a) => x + _num(a.$1, i)),
    ];
    const kanan = TextAlign.right;
    const mono = TextStyle(fontFamily: PalakatText.mono);

    Widget baris(
      List<double> w,
      List<Widget> sel, {
      required EdgeInsets padding,
      Border? garis,
      CrossAxisAlignment rata = CrossAxisAlignment.center,
    }) => Container(
      padding: padding,
      decoration: BoxDecoration(border: garis),
      child: Row(
        crossAxisAlignment: rata,
        children: [
          for (var i = 0; i < 6; i++) ...[
            if (i > 0) const SizedBox(width: 14),
            SizedBox(width: w[i], child: sel[i]),
          ],
        ],
      ),
    );

    final tabel = LayoutBuilder(
      builder: (context, k) {
        final lebar = math.max(860.0, k.maxWidth);
        final w = _kolom(lebar - 36 - 5 * 14);
        final isi = SizedBox(
          width: lebar,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DefaultTextStyle.merge(
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.tinta2,
                ),
                child: baris(
                  w,
                  rata: CrossAxisAlignment.start,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  const [
                    Text('Kas/Bank'),
                    Text('Jumlah terverifikasi', textAlign: kanan),
                    Text('Umum Jemaat', textAlign: kanan),
                    Text('Diakonia', textAlign: kanan),
                    Text('Pembangunan', textAlign: kanan),
                    Text('Sisa belum dibagi', textAlign: kanan),
                  ],
                ),
              ),
              for (final a in _akun)
                () {
                  final sisa = _sisa(a), pas = _pas(a);
                  final fg = pas ? c.laut : c.bata;
                  return baris(
                    w,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    garis: Border(top: BorderSide(color: c.garis)),
                    [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.$2,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            a.$4,
                            style: TextStyle(fontSize: 13, color: c.tinta3),
                          ),
                        ],
                      ),
                      Text(
                        rp(a.$3),
                        textAlign: kanan,
                        style: mono.copyWith(fontWeight: FontWeight.w500),
                      ),
                      for (var i = 0; i < 3; i++)
                        _Sel(
                          controller: _sel[a.$1]![i],
                          label: '${_per[i]} di ${a.$2}',
                        ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            rp(sisa.abs()),
                            textAlign: kanan,
                            style: mono.copyWith(
                              fontWeight: FontWeight.w600,
                              color: fg,
                            ),
                          ),
                          Text(
                            pas
                                ? 'Pas'
                                : sisa < 0
                                ? 'Lebih dari jumlah terverifikasi'
                                : sisa > 0
                                ? 'Belum habis dibagi'
                                : 'Ada sel belum diisi',
                            textAlign: kanan,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: fg,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }(),
              DefaultTextStyle.merge(
                style: const TextStyle(fontWeight: FontWeight.w700),
                child: baris(
                  w,
                  rata: CrossAxisAlignment.start,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  garis: Border(top: BorderSide(color: c.tinta, width: 1.5)),
                  [
                    const Text('Jumlah'),
                    Text(rp(32300000), textAlign: kanan, style: mono),
                    for (final s in kolom)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _Kata(rp(s), gaya: mono),
                      ),
                    const SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        );
        return lebar > k.maxWidth
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: isi,
              )
            : isi;
      },
    );

    final tombol = TekanAria(
      onTap: () {
        if (_semuaPas) setState(() => _opn = true);
      },
      aktif: semuaPas,
      radius: 12,
      minTinggi: 48,
      child: RupaTombol(
        label: 'Periksa dan bukukan saldo awal',
        isi: semuaPas ? c.laut : c.garis,
        warnaTeks: semuaPas ? c.diLaut : c.tinta3,
        radius: 12,
        tinggi: 48,
        paddingH: 22,
        lebarPenuh: false,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 16,
          runSpacing: 8,
          children: [
            const Text(
              'Saldo awal pencatatan',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            Text(
              'Per 15 September 2026, tanggal mulai pencatatan · bulan '
              'pertama pencatatan: September 2026',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: c.permukaan,
            border: Border.all(color: c.garis),
            borderRadius: BorderRadius.circular(14),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: tabel,
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, k) {
            final alasan = semuaPas
                ? 'Semua Kas/Bank pas. Dibukukan dengan seri OPN.'
                : 'Tidak dapat dibukukan: masih ada Kas/Bank yang belum pas.';
            final gayaAlasan = TextStyle(fontSize: 13, color: c.tinta2);
            final dasar = DefaultTextStyle.of(context).style;
            // The right column is `flex: 0 1 auto`: as wide as its widest line.
            double ukur(String t, TextStyle g) => (TextPainter(
              text: TextSpan(text: t, style: dasar.merge(g)),
              textDirection: TextDirection.ltr,
              textScaler: MediaQuery.textScalerOf(context),
            )..layout()).width;
            final kanan = math
                .max(
                  ukur(alasan, gayaAlasan),
                  ukur(
                        'Periksa dan bukukan saldo awal',
                        const TextStyle(fontWeight: FontWeight.w700),
                      ) +
                      44,
                )
                .ceilToDouble();
            final kiri = Text.rich(
              const TextSpan(
                children: [
                  TextSpan(
                    text:
                        'Saldo awal bukan Pendapatan. Jumlah per peruntukan '
                        'harus sama persis dengan tiap Kas/Bank; sel kosong '
                        'bukan Rp0, jadi isi ',
                  ),
                  TextSpan(text: '0', style: mono),
                  TextSpan(
                    text:
                        ' bila memang tidak ada. Uang muka dan titipan yang '
                        'masih berjalan: tidak ada.',
                  ),
                ],
              ),
              style: TextStyle(fontSize: 14, color: c.tinta2),
            );
            final kolomKanan = SizedBox(
              width: math.min(kanan, k.maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  tombol,
                  const SizedBox(height: 6),
                  Text(alasan, textAlign: TextAlign.right, style: gayaAlasan),
                ],
              ),
            );
            if (k.maxWidth >= 380 + 28 + kanan) {
              return Row(
                children: [
                  Expanded(child: kiri),
                  const SizedBox(width: 28),
                  kolomKanan,
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [kiri, const SizedBox(height: 14), kolomKanan],
            );
          },
        ),
      ],
    );
  }

  Widget _kartuOpn(PalakatWarna c) => LayoutBuilder(
    builder: (context, k) => Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: math.min(520, k.maxWidth)),
        child: IntrinsicWidth(
          child: Container(
            decoration: ShapeDecoration(
              color: c.permukaan,
              shape: GarisBorder.penuh(c.tinta, radius: 16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.5),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const LencanaStatus(
                              'Dibukukan',
                              bentuk: BentukLencana.tinta,
                              kepala: true,
                            ),
                            const SizedBox(width: 12),
                            Gerak(
                              Kerangka.cap,
                              lama: const Duration(milliseconds: 550),
                              tunda: const Duration(milliseconds: 350),
                              kurva: PalakatMotion.keluar,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: c.laut, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'No. Bukti OPN-2026-0001',
                                  style: TextStyle(
                                    fontFamily: PalakatText.mono,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: c.laut,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Saldo awal pencatatan · semua Kas/Bank',
                          style: TextStyle(fontSize: 14, color: c.tinta2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          rp(32300000),
                          style: const TextStyle(
                            fontFamily: PalakatText.mono,
                            fontSize: 36,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Seri OPN · bukan Pendapatan · menjadi final setelah '
                          'September 2026 ditutup',
                          style: TextStyle(fontSize: 13, color: c.tinta3),
                        ),
                        const SizedBox(height: 18),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Gerak(
                            Kerangka.muncul,
                            lama: Duration(milliseconds: 300),
                            tunda: Duration(milliseconds: 800),
                            child: Tombol(
                              'Mulai mencatat',
                              onPressed: null,
                              ke: 'WebBeranda',
                              cara: Cara.ganti,
                              ukuran: UkuranTombol.ringkas,
                              lebarPenuh: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SapuTinta(),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// The steps grid `repeat(auto-fit, minmax(min(150px, 100%), 1fr))`, gap 10;
/// a row's cards stretch to the tallest.
class _Kisi extends StatelessWidget {
  const _Kisi({required this.anak});
  final List<Widget> anak;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, k) {
      final n = KisiOtomatis.kolom(k.maxWidth, 150, 10, anak.length);
      final lebar = (k.maxWidth - 10 * (n - 1)) / n;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < anak.length; i += n) ...[
            if (i > 0) const SizedBox(height: 10),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var j = i; j < math.min(i + n, anak.length); j++) ...[
                    if (j > i) const SizedBox(width: 10),
                    SizedBox(width: lebar, child: anak[j]),
                  ],
                ],
              ),
            ),
          ],
        ],
      );
    },
  );
}

class _KartuLangkah extends StatelessWidget {
  const _KartuLangkah(this.nomor, this.l);
  final int nomor;
  final (String, String, String) l;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final (judul, sub, st) = l;
    final kini = st == 'kini';
    final (Color? isi, Color fg) = switch (st) {
      'ok' => (c.laut, c.diLaut),
      'kini' => (c.tinta, c.permukaan),
      _ => (null, c.tinta3),
    };
    // The dashed circle is content-box on the board: 30 + 2 × 1.5.
    final sisi = isi == null ? 33.0 : 30.0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: kini ? c.permukaan : null,
        shape: kini
            ? GarisBorder.penuh(c.tinta, radius: 12)
            : GarisBorder.penuh(c.garis, tebal: 1, radius: 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: sisi,
            height: sisi,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: isi,
              shape: isi == null
                  ? GarisBorder.putus(c.putus, radius: sisi / 2)
                  : const CircleBorder(),
            ),
            child: Text(
              st == 'ok' ? '✓' : '$nomor',
              style: TextStyle(
                fontFamily: PalakatText.mono,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: fg,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            judul,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(sub, style: TextStyle(fontSize: 13, color: c.tinta3)),
        ],
      ),
    );
  }
}

/// A table input: mono 15 right, min-height 44, padding 0 10, radius 10;
/// filled `permukaan` + 1 `garisTegas`, empty `bataLembut` + 1.5 dashed `bata`.
class _Sel extends StatefulWidget {
  const _Sel({required this.controller, required this.label});
  final TextEditingController controller;
  final String label;

  @override
  State<_Sel> createState() => _SelState();
}

class _SelState extends State<_Sel> {
  final _fokus = FocusNode();

  @override
  void initState() {
    super.initState();
    _fokus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fokus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final kosong = widget.controller.text.isEmpty;
    const gaya = TextStyle(fontFamily: PalakatText.mono, fontSize: 15);
    return CincinFokus(
      tampil: _fokus.hasFocus,
      radius: 10,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.centerRight,
        decoration: ShapeDecoration(
          color: kosong ? c.bataLembut : c.permukaan,
          shape: kosong
              ? GarisBorder.putus(c.bata, radius: 10)
              : GarisBorder.penuh(c.garisTegas, tebal: 1, radius: 10),
        ),
        child: Semantics(
          label: widget.label,
          child: Material(
            type: MaterialType.transparency,
            child: TextField(
              controller: widget.controller,
              focusNode: _fokus,
              keyboardType: TextInputType.number,
              inputFormatters: const [
                RupiahInputFormatter(sisakanNol: true, maks: 12),
              ],
              textAlign: TextAlign.right,
              textAlignVertical: TextAlignVertical.center,
              style: gaya.copyWith(color: c.tinta),
              cursorColor: c.laut,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: '—',
                hintStyle: gaya.copyWith(color: c.tinta3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One unbreakable word, right-aligned; wider than its cell it starts at the
/// cell's left edge and overflows to the right, as CSS does.
class _Kata extends StatelessWidget {
  const _Kata(this.teks, {required this.gaya});
  final String teks;
  final TextStyle gaya;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, k) {
      final g = DefaultTextStyle.of(context).style.merge(gaya);
      final tp = TextPainter(
        text: TextSpan(text: teks, style: g),
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      if (tp.width <= k.maxWidth) {
        return Text(teks, textAlign: TextAlign.right, style: gaya);
      }
      return Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(width: k.maxWidth, height: tp.height),
          Positioned(
            left: 0,
            top: 0,
            child: Text(teks, softWrap: false, style: gaya),
          ),
        ],
      );
    },
  );
}
