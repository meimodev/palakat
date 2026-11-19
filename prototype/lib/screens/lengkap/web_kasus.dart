import 'package:flutter/material.dart';

import '../../mock/format.dart';
import '../../motion/hitung.dart';
import '../../motion/kerangka.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/batang_pembagian.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/input_format.dart';
import '../../widgets/kartu_kasus.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';

/// One entry on a case (board `entri`).
typedef _Entri = ({String n, String no, String t, String cat, int jm});

/// One running case (board `state.kasus`). [entri] grows when booking.
class _Kasus {
  _Kasus(
    this.id,
    this.j,
    this.judul,
    this.pihak,
    this.awal,
    this.awalCat,
    this.tempo,
    this.entri, {
    this.lewat = false,
  });

  final String id, j, judul, pihak, awalCat, tempo;
  final int awal;
  final bool lewat;
  final List<_Entri> entri;

  int get sisa => awal - entri.fold(0, (a, e) => a + e.jm);
}

List<_Kasus> _kasusAwal() => [
  _Kasus(
    'um1',
    'um',
    'Panitia Natal',
    'Sdr. Rivo Mandagi',
    1500000,
    'BKU-2026-0129 · 01/11/2026 · dari peruntukan Umum Jemaat',
    '30/11/2026',
    [
      (
        n: 'Pertanggungjawaban uang muka',
        no: 'BKU-2026-0138',
        t: '08/11/2026',
        cat: 'menjadi Belanja',
        jm: 850000,
      ),
    ],
  ),
  _Kasus(
    'um2',
    'um',
    'Retret Pemuda',
    'Sdri. Natalia Rumengan',
    800000,
    'BKU-2026-0112 · 20/10/2026 · dari peruntukan Umum Jemaat',
    '10/11/2026',
    [
      (
        n: 'Pertanggungjawaban uang muka',
        no: 'BKU-2026-0150',
        t: '05/11/2026',
        cat: 'menjadi Belanja',
        jm: 300000,
      ),
    ],
    lewat: true,
  ),
  _Kasus(
    'um3',
    'um',
    'Perjalanan dinas Wilayah',
    'Pnt. Jefry Wowor',
    400000,
    'BKU-2026-0103 · 07/10/2026',
    '',
    [
      (
        n: 'Pertanggungjawaban uang muka',
        no: 'BKU-2026-0149',
        t: '03/11/2026',
        cat: 'menjadi Belanja',
        jm: 400000,
      ),
    ],
  ),
  _Kasus(
    'tt1',
    'tt',
    'Sentralisasi November',
    'Sinode',
    2400000,
    'Dari 4 persembahan · disimpan di Bank BNI ··4821',
    '',
    [
      (
        n: 'Penyaluran',
        no: 'BKU-2026-0136',
        t: '07/11/2026',
        cat: 'bukan Belanja',
        jm: 1000000,
      ),
    ],
  ),
  _Kasus(
    'tt2',
    'tt',
    'Persembahan khusus',
    'Wilayah',
    450000,
    'Dari persembahan khusus 9 November · disimpan di Kas',
    '',
    [],
  ),
  _Kasus(
    'pb1',
    'pb',
    'Alat kebersihan gereja',
    'Ibu Selvie Kalalo',
    185000,
    'Nota 12/11/2026 terlampir · belum masuk saldo',
    '',
    [],
  ),
  _Kasus(
    'pb2',
    'pb',
    'Bensin antar jemput',
    'Sdr. Rivo Mandagi',
    120000,
    'Nota 02/11/2026 terlampir',
    '',
    [
      (
        n: 'Penggantian biaya dibayar',
        no: 'BKU-2026-0134',
        t: '05/11/2026',
        cat: 'Belanja, dicatat satu kali',
        jm: 120000,
      ),
    ],
  ),
];

/// Board `LBL` (its `cat` is never shown).
typedef _Label = ({
  String tab,
  String pihak,
  String awal,
  String sisa,
  List<String> st,
  String kaki,
});

const Map<String, _Label> _lbl = {
  'um': (
    tab: 'Uang Muka',
    pihak: 'Diberikan kepada',
    awal: 'Uang Muka diberikan',
    sisa: 'Sisa belum dipertanggungjawabkan',
    st: [
      'Belum dipertanggungjawabkan',
      'Sebagian dipertanggungjawabkan',
      'Sudah dipertanggungjawabkan',
    ],
    kaki:
        'Pertanggungjawaban yang diterima menjadi Belanja. Pengembalian sisa '
        'kembali ke Kas dan bukan Pendapatan.',
  ),
  'tt': (
    tab: 'Titipan',
    pihak: 'Titipan untuk',
    awal: 'Terkumpul',
    sisa: 'Sisa belum disalurkan',
    st: ['Belum disalurkan', 'Sebagian disalurkan', 'Sudah disalurkan'],
    kaki:
        'Sentralisasi dari uang milik sendiri dicatat sebagai Belanja biasa, '
        'tidak di sini.',
  ),
  'pb': (
    tab: 'Penggantian biaya',
    pihak: 'Dibayar kepada',
    awal: 'Klaim',
    sisa: 'Belum dibayar',
    st: ['Belum dibayar', 'Belum dibayar', 'Sudah dibayar'],
    kaki:
        'Mengecek klaim tidak mengubah saldo. Pembayarannya mencatat Belanja '
        'satu kali.',
  ),
};

/// Board `AKSI`. `cek` is the claim check; `kunci` locks the amount.
typedef _Aksi = ({
  String id,
  String n,
  String cat,
  String entri,
  String ecat,
  String tombol,
  String lebih,
  bool utama,
  bool cek,
  bool kunci,
});

const Map<String, List<_Aksi>> _aksi = {
  'um': [
    (
      id: 'tj',
      n: 'Catat pertanggungjawaban',
      cat: 'Belanja dari uang muka, dengan nota.',
      entri: 'Pertanggungjawaban uang muka',
      ecat: 'menjadi Belanja',
      tombol: 'Bukukan pertanggungjawaban',
      lebih: 'Kelebihan belanja dicatat sebagai Penggantian biaya.',
      utama: true,
      cek: false,
      kunci: false,
    ),
    (
      id: 'kb',
      n: 'Catat pengembalian sisa',
      cat: 'Uang kembali ke Kas. Bukan Pendapatan.',
      entri: 'Pengembalian sisa uang muka',
      ecat: 'kembali ke Kas',
      tombol: 'Bukukan pengembalian',
      lebih: '',
      utama: false,
      cek: false,
      kunci: false,
    ),
  ],
  'tt': [
    (
      id: 'sl',
      n: 'Salurkan',
      cat: 'Menyerahkan titipan kepada yang berhak. Bukan Belanja.',
      entri: 'Penyaluran',
      ecat: 'bukan Belanja',
      tombol: 'Bukukan penyaluran',
      lebih: '',
      utama: true,
      cek: false,
      kunci: false,
    ),
  ],
  'pb': [
    (
      id: 'ck',
      n: 'Cek klaim',
      cat: '',
      entri: '',
      ecat: '',
      tombol: '',
      lebih: '',
      utama: false,
      cek: true,
      kunci: false,
    ),
    (
      id: 'by',
      n: 'Bayar penggantian biaya',
      cat: 'Membayar klaim penuh dan mencatat Belanja satu kali.',
      entri: 'Penggantian biaya dibayar',
      ecat: 'Belanja, dicatat satu kali',
      tombol: 'Bukukan pembayaran',
      lebih: '',
      utama: true,
      cek: false,
      kunci: true,
    ),
  ],
};

const _mono = TextStyle(
  fontFamily: PalakatText.mono,
  fontFeatures: [FontFeature.tabularFigures()],
  fontWeight: FontWeight.w500,
);

/// Web · Uang Muka dan Titipan: catat pada kasus (spec 10-aifoto.md, WebKasus).
class WebKasusScreen extends StatefulWidget {
  const WebKasusScreen({super.key});

  @override
  State<WebKasusScreen> createState() => _WebKasusScreenState();
}

class _WebKasusScreenState extends State<WebKasusScreen> {
  // Board state: { tab, buka, sheet, isi, nomor, cek, kasus }. `tampil` is
  // the [Hitung] below, keyed on the open case.
  String _tab = 'um';
  String? _buka, _sheet;
  String _isi = '';
  int _nomor = 150;
  final Set<String> _cek = {};
  final List<_Kasus> _kasus = _kasusAwal();
  final _isian = TextEditingController();
  final _fokus = FocusNode();

  @override
  void initState() {
    super.initState();
    _fokus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _isian.dispose();
    _fokus.dispose();
    super.dispose();
  }

  String _st(_Kasus k) {
    final l = _lbl[k.j]!.st;
    return k.sisa == 0 ? l[2] : (k.entri.isNotEmpty ? l[1] : l[0]);
  }

  _Kasus? get _cur {
    for (final k in _kasus) {
      if (k.id == _buka) return k;
    }
    return null;
  }

  _Aksi? get _akt {
    final cur = _cur;
    if (cur == null) return null;
    for (final a in _aksi[cur.j]!) {
      if (a.id == _sheet) return a;
    }
    return null;
  }

  int get _jumlah => int.tryParse(_isi) ?? 0;

  bool get _salah {
    final csisa = _cur?.sisa ?? 0;
    return _jumlah <= 0 || _jumlah > csisa;
  }

  void _isiKe(String digit) {
    _isi = digit;
    _isian.text = titik(digit);
  }

  void _simpan() {
    final cur = _cur, akt = _akt;
    if (_salah || cur == null || akt == null) return;
    setState(() {
      cur.entri.add((
        n: akt.entri,
        no: 'BKU-2026-0$_nomor',
        t: '16/11/2026',
        cat: akt.ecat,
        jm: _jumlah,
      ));
      _sheet = null;
      _nomor++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final L = _lbl[_tab]!;
    final list = [
      for (final k in _kasus)
        if (k.j == _tab) k,
    ];
    final terbuka = [
      for (final k in list)
        if (k.sisa > 0) k,
    ];

    final kiri = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _jarak(10, [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${L.sisa} · ${terbuka.length} kasus',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            Text(
              rp(terbuka.fold(0, (a, k) => a + k.sisa)),
              style: _mono.copyWith(fontSize: 30),
            ),
          ],
        ),
        for (final k in list)
          KartuKasus(
            web: true,
            nama: k.judul,
            labelPihak: L.pihak,
            pihak: k.pihak,
            awal: k.awal,
            dipertanggungjawabkan: k.awal - k.sisa,
            lewatTempo: k.lewat,
            status:
                _st(k) +
                (k.tempo.isNotEmpty && k.sisa > 0
                    ? (k.lewat
                          ? ' · Lewat jatuh tempo (jatuh tempo: ${k.tempo})'
                          : ' · jatuh tempo ${k.tempo}')
                    : ''),
            onTap: () => setState(() => _buka = k.id),
          ),
      ]),
    );

    final cur = _cur;
    final kanan = cur == null
        ? Kartu(
            status: GarisStatus.draf,
            padding: const EdgeInsets.all(18),
            child: Text(
              'Pilih satu kasus di kiri untuk melihat catatannya.',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          )
        : _rinci(cur, L);

    return HalamanWeb(
      jabatanKosong: true,
      nav: const NavSamping(
        item: navKeuangan,
        aktif: 2,
        pengguna: PenggunaKeuangan(),
      ),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The breadcrumb's 44 px target overhangs its 14 px line.
            MarginNegatif(
              atas: 12,
              bawah: 12,
              child: Tautan(
                ke: 'WebKewajiban',
                cara: Cara.naik,
                child: const SizedBox(
                  height: 44,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1,
                    child: TautanTeks('Uang Muka dan Titipan', ukuran: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: const Text(
                'Catat pada kasus',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in const ['um', 'tt', 'pb'])
              ChipSatu(
                teks: _lbl[t]!.tab,
                dipilih: _tab == t,
                onTap: () => setState(() => _tab = t),
              ),
          ],
        ),
        BarisLentur(
          jarak: 24,
          anak: [
            Lentur(dasar: 340, child: kiri),
            Lentur(dasar: 480, tumbuh: 999, child: kanan),
          ],
        ),
      ],
    );
  }

  Widget _rinci(_Kasus cur, _Label L) {
    final c = context.warna;
    final csisa = cur.sisa;
    final akt = _akt;
    final sudahCek = _cek.contains(cur.id);
    final status = _st(cur);
    final aksi = csisa > 0
        ? [
            for (final a in _aksi[cur.j]!)
              if (!(a.cek && sudahCek) && !(a.id == 'by' && !sudahCek)) a,
          ]
        : const <_Aksi>[];
    final tempo = cur.tempo.isNotEmpty && csisa > 0
        ? (cur.lewat
              ? 'Lewat jatuh tempo (jatuh tempo: ${cur.tempo})'
              : 'Jatuh tempo ${cur.tempo}')
        : '';

    final selesai = csisa == 0;

    final barisTabel = [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    L.awal,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    cur.awalCat +
                        (cur.j == 'pb' && sudahCek && csisa > 0
                            ? ' · klaim sudah dicek'
                            : ''),
                    style: TextStyle(fontSize: 13, color: c.tinta3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(rp(cur.awal), style: _mono),
          ],
        ),
      ),
      for (final (i, e) in cur.entri.indexed)
        Gerak(
          Kerangka.muncul,
          key: ValueKey('${cur.id}-$i'),
          lama: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.garis)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.n,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: e.no,
                              style: const TextStyle(
                                fontFamily: PalakatText.mono,
                              ),
                            ),
                            TextSpan(text: ' · ${e.t} · ${e.cat}'),
                          ],
                        ),
                        style: TextStyle(fontSize: 13, color: c.tinta3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text('− ${rp(e.jm)}', style: _mono),
              ],
            ),
          ),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _jarak(14, [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                cur.judul,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${L.pihak}: ${cur.pihak}',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        LayoutBuilder(
          builder: (context, k) {
            // `align-items: baseline` in a wrapping row: the items sharing
            // a line with the badge (the lowest first baseline) sit on its
            // baseline; an item alone on its line keeps its top.
            final dasar = DefaultTextStyle.of(context).style;
            final skala = MediaQuery.textScalerOf(context);
            final gLabel = TextStyle(fontSize: 14, color: c.tinta2);
            final gAngka = _mono.copyWith(fontSize: 34, letterSpacing: -1);
            final gLencana = TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selesai ? c.diLaut : c.tinta2,
            );
            final gTempo = TextStyle(
              fontSize: 13,
              fontWeight: cur.lewat ? FontWeight.w700 : FontWeight.w400,
            );
            final ukur = [
              for (final (t, g) in [
                (L.sisa, gLabel),
                (rp(csisa), gAngka),
                (status, gLencana),
                (tempo, gTempo),
              ])
                TextPainter(
                  text: TextSpan(text: t, style: dasar.merge(g)),
                  textDirection: TextDirection.ltr,
                  textScaler: skala,
                )..layout(),
            ];
            final blok = ukur[0].width > ukur[1].width
                ? ukur[0].width
                : ukur[1].width;
            final lencana = ukur[2].width + 21;
            final lebarTempo = ukur[3].width;
            final garisDasar =
                4.5 +
                ukur[2].computeDistanceToActualBaseline(
                  TextBaseline.alphabetic,
                );
            for (final t in ukur) {
              t.dispose();
            }
            final w = k.maxWidth;
            final lencanaSebaris = blok + 20 + lencana <= w;
            final tempoBersama = lencanaSebaris
                ? blok + 40 + lencana + lebarTempo <= w
                : lencana + 20 + lebarTempo <= w;
            Widget sejajar(bool ya, Widget anak) => ya
                ? Baseline(
                    baseline: garisDasar,
                    baselineType: TextBaseline.alphabetic,
                    child: anak,
                  )
                : anak;
            return Wrap(
              spacing: 20,
              runSpacing: 8,
              children: [
                sejajar(
                  lencanaSebaris,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(L.sisa, style: gLabel),
                      Hitung(
                        key: ValueKey(cur.id),
                        nilai: csisa,
                        builder: (context, v) => Text(rp(v), style: gAngka),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: ShapeDecoration(
                    color: selesai ? c.laut : null,
                    shape: GarisBorder.penuh(
                      selesai ? c.laut : c.tinta3,
                      radius: 6,
                    ),
                  ),
                  child: Text(status, style: gLencana),
                ),
                sejajar(tempoBersama, Text(tempo, style: gTempo)),
              ],
            );
          },
        ),
        // Not keyed: like the board's CSS transition, the width also
        // animates when another case opens.
        BatangPembagian(
          total: cur.awal,
          tinggi: 14,
          durasi: const Duration(milliseconds: 500),
          bagian: [BagianBatang(cur.awal - csisa, c.tinta)],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: c.permukaan,
            border: Border.all(color: c.garis),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: barisTabel,
          ),
        ),
        if (akt != null) _panel(akt, csisa),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in aksi)
              Tombol(
                a.cek ? 'Cek klaim · tidak mengubah saldo' : a.n,
                jenis:
                    (a.utama && !(cur.j == 'pb' && !sudahCek)) ||
                        (a.cek && !sudahCek)
                    ? JenisTombol.utama
                    : JenisTombol.kedua,
                ukuran: UkuranTombol.ringkas,
                paddingH: 18,
                lebarPenuh: false,
                onPressed: () => setState(() {
                  if (a.cek) {
                    _cek.add(cur.id);
                    return;
                  }
                  _sheet = a.id;
                  _isiKe('$csisa');
                }),
              ),
          ],
        ),
        if (selesai)
          Semantics(
            container: true,
            liveRegion: true,
            child: Text(
              '$status · tidak ada sisa',
              style: TextStyle(fontWeight: FontWeight.w700, color: c.laut),
            ),
          ),
        Text(
          '${L.kaki} Sisa dihitung dari catatan di atas; tidak ada isian '
          'untuk mengubahnya.',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ]),
    );
  }

  Widget _panel(_Aksi akt, int csisa) {
    final c = context.warna;
    final salah = _salah;
    final angka = _mono.copyWith(fontSize: 26);
    final isian = Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.tinta, width: 2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          ExcludeSemantics(
            child: Text(
              'Rp',
              style: TextStyle(
                fontFamily: PalakatText.mono,
                fontSize: 18,
                color: c.tinta3,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Semantics(
              label: 'Jumlah (Rp)',
              child: CincinFokus(
                tampil: _fokus.hasFocus,
                child: Material(
                  type: MaterialType.transparency,
                  child: TextField(
                    controller: _isian,
                    focusNode: _fokus,
                    // Board `onIsi`: typing is ignored on a locked amount.
                    readOnly: akt.kunci,
                    keyboardType: TextInputType.number,
                    inputFormatters: const [RupiahInputFormatter()],
                    onChanged: (v) =>
                        setState(() => _isi = v.replaceAll(RegExp(r'\D'), '')),
                    textAlignVertical: TextAlignVertical.center,
                    style: angka,
                    cursorColor: c.laut,
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      constraints: BoxConstraints(minHeight: 44),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    // Not keyed: switching the action keeps the open panel (no replay).
    return Gerak(
      Kerangka.muncul,
      lama: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: c.permukaan,
          shape: GarisBorder.penuh(c.tinta, radius: 14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _jarak(10, [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  akt.n,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(akt.cat, style: TextStyle(fontSize: 14, color: c.tinta2)),
              ],
            ),
            Align(alignment: Alignment.centerLeft, child: isian),
            if (_jumlah > csisa)
              Semantics(
                container: true,
                liveRegion: true,
                child: Text(
                  'Tidak dapat dilakukan: melebihi sisa ${rp(csisa)}. '
                  '${akt.lebih}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: c.bata,
                  ),
                ),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Board `disabled="{{isiSalah}}"`: stays pressable and
                // re-checks the latest amount (CONVENTIONS deviation).
                TekanAria(
                  onTap: _simpan,
                  aktif: !salah,
                  petunjuk: salah
                      ? 'Jumlah harus lebih dari nol dan tidak melebihi sisa '
                            '${rp(csisa)}.'
                      : null,
                  radius: 12,
                  child: RupaTombol(
                    label: akt.tombol,
                    isi: salah ? c.garis : c.laut,
                    warnaTeks: salah ? c.tinta3 : c.diLaut,
                    radius: 12,
                    tinggi: 46,
                    paddingH: 20,
                    lebarPenuh: false,
                  ),
                ),
                Tombol(
                  'Kembali',
                  onPressed: () => setState(() => _sheet = null),
                  jenis: JenisTombol.kedua,
                  ukuran: UkuranTombol.ringkas,
                  lebarPenuh: false,
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

/// CSS column `gap`.
List<Widget> _jarak(double g, List<Widget> anak) => [
  for (var i = 0; i < anak.length; i++) ...[
    if (i > 0) SizedBox(height: g),
    anak[i],
  ],
];
