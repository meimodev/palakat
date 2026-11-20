import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../motion/kerangka.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/batang_pembagian.dart';
import '../../widgets/garis.dart';
import '../../widgets/input_format.dart';
import '../../widgets/isian_jumlah.dart';
import '../../widgets/kartu_kasus.dart';
import '../../widgets/lembar_bawah.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import '../../app/layar.dart';

// Board data (Kewajiban.dc.html): its own figures, not the web board's.

class _Entri {
  const _Entri(this.n, this.no, this.t, this.cat, this.jm);
  final String n, no, t, cat;
  final int jm;
}

class _Kasus {
  _Kasus(
    this.id,
    this.j,
    this.judul,
    this.pihak,
    this.awal,
    this.awalCat,
    this.tempo,
    List<_Entri> entri, {
    this.lewat = false,
  }) : entri = [...entri];
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
    const [
      _Entri(
        'Pertanggungjawaban uang muka',
        'BKU-2026-0138',
        '08/11/2026',
        'menjadi Belanja',
        850000,
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
    lewat: true,
    const [
      _Entri(
        'Pertanggungjawaban uang muka',
        'BKU-2026-0150',
        '05/11/2026',
        'menjadi Belanja',
        300000,
      ),
    ],
  ),
  _Kasus(
    'um3',
    'um',
    'Perjalanan dinas Wilayah',
    'Pnt. Jefry Wowor',
    400000,
    'BKU-2026-0103 · 07/10/2026',
    '',
    const [
      _Entri(
        'Pertanggungjawaban uang muka',
        'BKU-2026-0149',
        '03/11/2026',
        'menjadi Belanja',
        400000,
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
    const [
      _Entri(
        'Penyaluran',
        'BKU-2026-0136',
        '07/11/2026',
        'bukan Belanja',
        1000000,
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
    const [],
  ),
  _Kasus(
    'pb1',
    'pb',
    'Alat kebersihan gereja',
    'Ibu Selvie Kalalo',
    185000,
    'Nota 12/11/2026 terlampir · belum masuk saldo',
    '',
    const [],
  ),
  _Kasus(
    'pb2',
    'pb',
    'Bensin antar jemput',
    'Sdr. Rivo Mandagi',
    120000,
    'Nota 02/11/2026 terlampir',
    '',
    const [
      _Entri(
        'Penggantian biaya dibayar',
        'BKU-2026-0134',
        '05/11/2026',
        'Belanja, dicatat satu kali',
        120000,
      ),
    ],
  ),
];

typedef _Label = ({
  String tab,
  String pihak,
  String awal,
  String sisa,
  String cat,
  List<String> st,
  String kaki,
});

const Map<String, _Label> _lbl = {
  'um': (
    tab: 'Uang Muka',
    pihak: 'Diberikan kepada',
    awal: 'Uang Muka diberikan',
    sisa: 'Sisa belum dipertanggungjawabkan',
    cat: 'Uang muka bukan Belanja saat diberikan.',
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
    cat: 'Uang titipan untuk pihak lain, bukan Pendapatan dan bukan Belanja.',
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
    cat: 'Klaim belum masuk saldo sampai dibayar.',
    st: ['Belum dibayar', 'Belum dibayar', 'Sudah dibayar'],
    kaki:
        'Mengecek klaim tidak mengubah saldo. Pembayarannya mencatat Belanja '
        'satu kali.',
  ),
};

typedef _Aksi = ({
  String id,
  String n,
  String cat,
  String entri,
  String ecat,
  String tombol,
  String lebih,
  bool utama,
  bool kunci,
  bool cek,
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
      kunci: false,
      cek: false,
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
      kunci: false,
      cek: false,
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
      kunci: false,
      cek: false,
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
      kunci: false,
      cek: true,
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
      kunci: true,
      cek: false,
    ),
  ],
};

/// The board's state (`state` of the logic class), shared by the list and
/// the case view for as long as the board is on the stack.
class _Papan extends ChangeNotifier {
  String tab = 'um';
  String? buka, sheet;
  int tampil = 0, nomor = 150;
  Set<String> cek = {};
  List<_Kasus> kasus = _kasusAwal();
  final isi = TextEditingController();
  Timer? _t;

  _Label get lbl => _lbl[tab]!;
  _Kasus? kasusDengan(String? id) => kasus.where((k) => k.id == id).firstOrNull;
  _Kasus? get cur => kasusDengan(buka);
  _Aksi? get akt => cur == null
      ? null
      : _aksi[cur!.j]!.where((a) => a.id == sheet).firstOrNull;

  String st(_Kasus k) {
    final l = _lbl[k.j]!.st;
    return k.sisa == 0 ? l[2] : (k.entri.isNotEmpty ? l[1] : l[0]);
  }

  int get angka => angkaDari(isi.text) ?? 0;

  /// First unmet reason of the book button, from the latest text.
  String alasan() {
    final c = cur, a = akt;
    if (c == null || a == null) return 'tidak ada kasus';
    final n = angka;
    if (n > c.sisa) return 'melebihi sisa ${rp(c.sisa)}. ${a.lebih}'.trim();
    if (n <= 0) return 'jumlah belum diisi';
    return '';
  }

  void ubah() => notifyListeners();

  void pilihTab(String t) {
    tab = t;
    notifyListeners();
  }

  /// Card press, or a deep link (also sets [tab] so Back lands right).
  void bukaKasus(String id, {bool beritahu = true}) {
    _t?.cancel();
    final k = kasusDengan(id)!;
    buka = id;
    tab = k.j;
    tampil = k.sisa;
    if (beritahu) notifyListeners();
  }

  void keDaftar() {
    _t?.cancel();
    buka = null;
    sheet = null;
    notifyListeners();
  }

  void tekanAksi(_Aksi a) {
    final c = cur!;
    if (a.cek) {
      cek = {...cek, c.id};
    } else {
      sheet = a.id;
      isi.text = titik('${c.sisa}');
    }
    notifyListeners();
  }

  void tutupSheet() {
    sheet = null;
    notifyListeners();
  }

  void simpan({required bool instan}) {
    final c = cur, a = akt;
    if (c == null || a == null || alasan().isNotEmpty) return;
    final n = angka, dari = c.sisa, ke = c.sisa - n;
    c.entri.add(_Entri(a.entri, 'BKU-2026-0$nomor', '16/11/2026', a.ecat, n));
    sheet = null;
    nomor++;
    _t?.cancel();
    if (instan) {
      tampil = ke;
    } else {
      var i = 0;
      _t = Timer.periodic(const Duration(milliseconds: 30), (t) {
        i++;
        tampil = hitungNaik(dari, ke, i, 22);
        notifyListeners();
        if (i >= 22) t.cancel();
      });
    }
    notifyListeners();
  }

  void ulang() {
    _t?.cancel();
    tab = 'um';
    buka = null;
    sheet = null;
    tampil = 0;
    nomor = 150;
    cek = {};
    kasus = _kasusAwal();
    isi.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _t?.cancel();
    isi.dispose();
    super.dispose();
  }
}

class _Lingkup extends InheritedNotifier<_Papan> {
  const _Lingkup({required _Papan papan, required super.child})
    : super(notifier: papan);

  static _Papan of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Lingkup>()!.notifier!;

  /// Without a dependency (initState).
  static _Papan baca(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_Lingkup>()!.notifier!;
}

class KewajibanKendali extends StatefulWidget {
  const KewajibanKendali({super.key, required this.child});
  final Widget child;
  @override
  State<KewajibanKendali> createState() => _KewajibanKendaliState();
}

class _KewajibanKendaliState extends State<KewajibanKendali> {
  final _papan = _Papan();

  @override
  void dispose() {
    _papan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Lingkup(
    papan: _papan,
    child: Material(
      type: MaterialType.transparency,
      // CSS splits line-height leading evenly above and below the glyphs.
      child: DefaultTextHeightBehavior(
        textHeightBehavior: _leadingRata,
        child: ListenableBuilder(
          listenable: _papan,
          builder: (context, navigator) => LayarPonsel(
            layarKeuangan: true,
            overlay: [if (_papan.akt != null) _Lembar(papan: _papan)],
            child: navigator!,
          ),
          child: widget.child,
        ),
      ),
    ),
  );
}

const _leadingRata = TextHeightBehavior(
  leadingDistribution: TextLeadingDistribution.even,
);

class KewajibanScreen extends StatelessWidget {
  const KewajibanScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) =>
      anak == null ? const _Daftar() : _Rinci(id: param['id'] ?? '');
}

// List view.

class _Daftar extends StatelessWidget {
  const _Daftar();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final p = _Lingkup.of(context);
    final lb = p.lbl;
    final list = p.kasus.where((k) => k.j == p.tab).toList();
    final buka = list.where((k) => k.sisa > 0).toList();
    final total = buka.fold(0, (a, k) => a + k.sisa);
    return Gerak(
      Kerangka.pudar,
      lama: const Duration(milliseconds: 200),
      child: ColoredBox(
        color: c.kertas,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KepalaPonsel(
              judul: 'Uang yang masih berjalan',
              kembaliKe: Layar.keuangan,
              labelKembali: 'Kembali ke Beranda',
              ujung: Tautan(
                ke: Layar.kasusBaru,
                radius: 12,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: c.laut,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '+ Kasus baru',
                    style: TextStyle(
                      color: c.diLaut,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Wrap(
                spacing: 6,
                children: [
                  for (final t in const ['um', 'tt', 'pb'])
                    _Chip(
                      teks: _lbl[t]!.tab,
                      dipilih: p.tab == t,
                      onTap: () => p.pilihTab(t),
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${lb.sisa} · ${buka.length} kasus',
                          style: TextStyle(fontSize: 14, color: c.tinta2),
                        ),
                        Text(
                          rp(total),
                          style: const TextStyle(
                            fontFamily: PalakatText.mono,
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          lb.cat,
                          style: TextStyle(fontSize: 13, color: c.tinta3),
                        ),
                      ],
                    ),
                    for (final k in list) ...[
                      const SizedBox(height: 12),
                      KartuKasus(
                        nama: k.judul,
                        labelPihak: lb.pihak,
                        pihak: k.pihak,
                        awal: k.awal,
                        dipertanggungjawabkan: k.awal - k.sisa,
                        status: _statusBaris(p, k),
                        lewatTempo: k.lewat,
                        onTap: () {
                          p.bukaKasus(k.id);
                          context.dorongKe(
                            Layar.kewajiban,
                            anak: 'kasus/${k.id}',
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _statusBaris(_Papan p, _Kasus k) {
    final beres = k.sisa == 0;
    final akhir = k.tempo.isNotEmpty && !beres
        ? (k.lewat
              ? ' · Lewat jatuh tempo (jatuh tempo: ${k.tempo})'
              : ' · jatuh tempo ${k.tempo}')
        : '';
    return p.st(k) + akhir;
  }
}

/// The board's 13 px kind chip (padding 0 13): ChipSatu is fixed at 14.
class _Chip extends StatelessWidget {
  const _Chip({required this.teks, required this.dipilih, required this.onTap});
  final String teks;
  final bool dipilih;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      dipilih: dipilih,
      radius: 22,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: ShapeDecoration(
          color: dipilih ? c.tinta : c.permukaan,
          shape: GarisBorder.penuh(
            dipilih ? c.tinta : c.garisTegas,
            radius: PalakatRadius.chip,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              teks,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: dipilih ? c.permukaan : c.tinta,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Case view (child route /Kewajiban/kasus/:id).

class _Rinci extends StatefulWidget {
  const _Rinci({required this.id});
  final String id;
  @override
  State<_Rinci> createState() => _RinciState();
}

class _RinciState extends State<_Rinci> {
  @override
  void initState() {
    super.initState();
    _pastikan();
  }

  @override
  void didUpdateWidget(_Rinci old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id) _pastikan();
  }

  void _pastikan() {
    final p = _Lingkup.baca(context);
    if (p.kasusDengan(widget.id) == null) {
      // Unknown id: back to the board's root route (navigation.md 5.4).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.gantiKe(Layar.kewajiban);
      });
    } else if (p.buka != widget.id) {
      // Deep link: open the case without a card press.
      p.bukaKasus(widget.id, beritahu: false);
      WidgetsBinding.instance.addPostFrameCallback((_) => p.ubah());
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final p = _Lingkup.of(context);
    final cur = p.kasusDengan(widget.id);
    if (cur == null) return const SizedBox.shrink();
    final lb = p.lbl;
    final csisa = cur.sisa;
    final beres = csisa == 0;
    final sudahCek = p.cek.contains(cur.id);
    final aksi = beres
        ? const <_Aksi>[]
        : _aksi[cur.j]!
              .where(
                (a) => !(a.cek && sudahCek) && !(a.id == 'by' && !sudahCek),
              )
              .toList();
    final tempo = cur.tempo.isNotEmpty && !beres
        ? (cur.lewat
              ? 'Lewat jatuh tempo (jatuh tempo: ${cur.tempo})'
              : 'Jatuh tempo ${cur.tempo}')
        : '';
    const mono = TextStyle(
      fontFamily: PalakatText.mono,
      fontWeight: FontWeight.w500,
    );

    Widget baris(String judul, InlineSpan ket, String jumlah, bool garis) =>
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: garis
              ? BoxDecoration(
                  border: Border(top: BorderSide(color: c.garis)),
                )
              : null,
          child: _BarisRiwayat(judul: judul, ket: ket, jumlah: jumlah),
        );

    final kecil = TextStyle(fontSize: 13, color: c.tinta3);

    return PopScope(
      canPop: p.sheet == null,
      onPopInvokedWithResult: (sudah, _) =>
          sudah ? p.keDaftar() : p.tutupSheet(),
      child: ColoredBox(
        color: c.kertas,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KepalaPonsel(
              judul: cur.judul,
              anakJudul: '${lb.pihak}: ${cur.pihak}',
              labelKembali: 'Kembali',
              onKembali: () {
                p.keDaftar();
                context.pop();
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lb.sisa,
                          style: TextStyle(fontSize: 14, color: c.tinta2),
                        ),
                        Text(
                          rp(p.tampil),
                          style: mono.copyWith(
                            fontSize: 36,
                            letterSpacing: -1,
                            height: 1.15,
                          ),
                        ),
                        Text(
                          'Dihitung dari catatan di bawah. Tidak ada isian '
                          'untuk mengubahnya.',
                          style: kecil,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    BatangPembagian(
                      // The board's width is a whole percentage.
                      total: 100,
                      tinggi: 14,
                      durasi: const Duration(milliseconds: 500),
                      bagian: [
                        BagianBatang(
                          ((cur.awal - csisa) / cur.awal * 100).round(),
                          c.tinta,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: ShapeDecoration(
                            color: beres ? c.laut : null,
                            shape: GarisBorder.penuh(
                              beres ? c.laut : c.tinta3,
                              radius: 6,
                            ),
                          ),
                          child: Text(
                            p.st(cur),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: beres ? c.diLaut : c.tinta2,
                            ),
                          ),
                        ),
                        if (tempo.isNotEmpty)
                          Text(
                            tempo,
                            style: TextStyle(
                              fontSize: 13,
                              color: c.tinta,
                              fontWeight: cur.lewat
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: c.permukaan,
                        border: Border.all(color: c.garis),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          baris(
                            lb.awal,
                            TextSpan(
                              text:
                                  cur.awalCat +
                                  (cur.j == 'pb' && sudahCek && !beres
                                      ? ' · klaim sudah dicek'
                                      : ''),
                            ),
                            rp(cur.awal),
                            false,
                          ),
                          for (final (i, e) in cur.entri.indexed)
                            Gerak(
                              Kerangka.muncul,
                              key: ValueKey(i),
                              lama: const Duration(milliseconds: 300),
                              child: baris(
                                e.n,
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
                                '− ${rp(e.jm)}',
                                true,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(lb.kaki, style: kecil),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
              decoration: BoxDecoration(
                color: c.permukaan,
                border: Border(top: BorderSide(color: c.garis)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, a) in aksi.indexed) ...[
                    if (i > 0) const SizedBox(height: 8),
                    _TombolAksi(
                      label: a.cek ? 'Cek klaim · tidak mengubah saldo' : a.n,
                      utama:
                          a.utama && !(cur.j == 'pb' && !sudahCek) ||
                          (a.cek && !sudahCek),
                      onTap: () => p.tekanAksi(a),
                    ),
                  ],
                  if (beres)
                    Gerak(
                      Kerangka.muncul,
                      lama: const Duration(milliseconds: 300),
                      child: Semantics(
                        container: true,
                        liveRegion: true,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 50),
                          child: Center(
                            child: Text(
                              '${p.st(cur)} · tidak ada sisa',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: c.laut,
                              ),
                            ),
                          ),
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

/// Action bar button: min height 50, radius 14, 700, centred.
class _TombolAksi extends StatelessWidget {
  const _TombolAksi({
    required this.label,
    required this.utama,
    required this.onTap,
  });
  final String label;
  final bool utama;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      radius: 14,
      child: RupaTombol(
        label: label,
        isi: utama ? c.laut : c.permukaan,
        garis: utama ? null : GarisBorder.penuh(c.tinta, radius: 14),
        warnaTeks: utama ? c.diLaut : c.tinta,
        radius: 14,
        tinggi: 50,
        paddingH: 6,
      ),
    );
  }
}

// Amount sheet (an overlay of the Kendali, over the case view).

class _Lembar extends StatelessWidget {
  const _Lembar({required this.papan});
  final _Papan papan;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final p = papan;
    final a = p.akt!;
    final alasan = p.alasan();
    return LembarBawah(
      judul: a.n,
      anakJudul: a.cat,
      onTutup: p.tutupSheet,
      labelTirai: 'Kembali ke kasus',
      isi: [
        IsianJumlah(
          label: 'Jumlah (Rp)',
          controller: p.isi,
          onChanged: (_) => p.ubah(),
          ukuran: UkuranJumlah.besar,
          ukuranRp: 20,
          ukuranAngka: 32,
          hanyaBaca: a.kunci,
        ),
        TombolBersyarat(
          label: a.tombol,
          tindakan: a.tombol,
          alasan: alasan,
          periksa: p.alasan,
          // Only the over-remainder case is worded on the board.
          sudahMulai: p.angka > p.cur!.sisa,
          gayaAlasan: GayaAlasan.kalimatBata,
          warnaSiap: JenisTombol.utama,
          teksBelumRedup: true,
          jarak: 14,
          paddingH: 6,
          onPressed: () => p.simpan(instan: gerakMati(context)),
        ),
        Tombol(
          'Kembali',
          jenis: JenisTombol.teks,
          warnaTeks: c.tinta,
          onPressed: p.tutupSheet,
        ),
      ],
    );
  }
}

/// A history row: label over caption, amount right. Lays out like the
/// board's `display: flex; justify-content: space-between; gap: 12px`: both
/// sides shrink in proportion to their natural width, the amount no
/// narrower than its longest word, so "− Rp850.000" can break after "−".
class _BarisRiwayat extends StatelessWidget {
  const _BarisRiwayat({
    required this.judul,
    required this.ket,
    required this.jumlah,
  });
  final String judul, jumlah;
  final InlineSpan ket;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final dasar = DefaultTextStyle.of(context).style;
    final gJudul = dasar.merge(
      const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    );
    final gKet = dasar.merge(TextStyle(fontSize: 13, color: c.tinta3));
    final gJumlah = dasar.merge(
      const TextStyle(
        fontFamily: PalakatText.mono,
        fontWeight: FontWeight.w500,
      ),
    );
    final scaler = MediaQuery.textScalerOf(context);
    double lebar(InlineSpan t, {bool min = false}) {
      final tp = TextPainter(
        text: t,
        textDirection: TextDirection.ltr,
        textScaler: scaler,
      )..layout();
      final w = min ? tp.minIntrinsicWidth : tp.maxIntrinsicWidth;
      tp.dispose();
      return w;
    }

    return LayoutBuilder(
      builder: (context, k) {
        final kiri = [
          lebar(TextSpan(text: judul, style: gJudul)),
          lebar(TextSpan(children: [ket], style: gKet)),
        ].reduce((a, b) => a > b ? a : b);
        final span = TextSpan(text: jumlah, style: gJumlah);
        final kanan = lebar(span);
        final ruang = k.maxWidth - 12;
        var wKanan = kanan;
        final lebih = kiri + kanan - ruang;
        if (lebih > 0) {
          final minKanan = lebar(span, min: true);
          wKanan = (kanan - lebih * kanan / (kiri + kanan)).clamp(
            minKanan,
            kanan,
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(judul, style: gJudul),
                  Text.rich(TextSpan(children: [ket]), style: gKet),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: wKanan.ceilToDouble(),
              child: Text(jumlah, style: gJumlah),
            ),
          ],
        );
      },
    );
  }
}
