import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../mock/format.dart';
import '../../mock/mock.dart';
import '../../motion/hitung.dart';
import '../../motion/kerangka.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';

/// One selectable row: a bank mutation (m1…m3) or a posted transaction
/// (t1…t4, with its No. Bukti).
typedef _Baris = ({String id, String n, String? no, String tgl, int jm});

final List<_Baris> _mutasi = [
  for (final m in rekonBniOktober.mutasi)
    (id: m.id, n: m.nama, no: null, tgl: m.tanggal, jm: m.jumlah),
];
final List<_Baris> _transaksi = [
  for (var i = 0; i < rekonBniOktober.belumCocok.length; i++)
    (
      id: 't${i + 1}',
      n: rekonBniOktober.belumCocok[i].uraian,
      no: rekonBniOktober.belumCocok[i].noBukti,
      tgl: rekonBniOktober.belumCocok[i].tanggal ?? kosong,
      jm: rekonBniOktober.belumCocok[i].jumlah,
    ),
];

const _biaya = 15000;

/// A user match; [id] keys its cards so other groups do not replay.
typedef _Grup = ({int id, List<String> m, List<String> t});

class WebRekonsiliasiScreen extends StatefulWidget {
  const WebRekonsiliasiScreen({super.key});
  @override
  State<WebRekonsiliasiScreen> createState() => _WebRekonsiliasiState();
}

class _WebRekonsiliasiState extends State<WebRekonsiliasiScreen> {
  List<String> _selM = [], _selT = [];
  List<_Grup> _grup = [];
  bool _perjalanan = false, _biayaOn = false, _pasti = false;
  int _idBerikut = 0;

  int get _buku => rekonBniOktober.saldoBuku - (_biayaOn ? _biaya : 0);
  int get _pembanding =>
      rekonBniOktober.saldoRekeningKoran +
      (_perjalanan ? rekonBniOktober.dalamPerjalanan : 0);

  /// The board's `target(p)`; [Hitung] counts the shown figure to it.
  int get _target => _buku - _pembanding;

  /// `ubah(patch)`: pasti false plus the patch; the count follows the target.
  void _ubah(VoidCallback patch) => setState(() {
    _pasti = false;
    patch();
  });

  int _jumlah(List<_Baris> list, List<String> sel) =>
      list.where((r) => sel.contains(r.id)).fold(0, (a, r) => a + r.jm);

  String _nama(List<_Baris> list, List<String> ids) =>
      list.where((r) => ids.contains(r.id)).map((r) => r.n).join(' + ');

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final jk = PrototypeState.maybeOf(context)?.jabatanKosong ?? false;

    final dipakaiM = [for (final g in _grup) ...g.m, if (_biayaOn) 'm3'];
    final dipakaiT = [for (final g in _grup) ...g.t, if (_perjalanan) 't4'];
    final mutasi = [
      for (final r in _mutasi)
        if (!dipakaiM.contains(r.id)) r,
    ];
    final transaksi = [
      for (final r in _transaksi)
        if (!dipakaiT.contains(r.id)) r,
    ];

    final sm = _jumlah(_mutasi, _selM), st = _jumlah(_transaksi, _selT);
    final ada = _selM.isNotEmpty && _selT.isNotEmpty;
    final sama = ada && sm == st;
    final pilihTeks = _selM.isEmpty && _selT.isEmpty
        ? 'Pilih mutasi bank dan transaksi yang sama jumlahnya. Satu mutasi '
              'boleh dicocokkan dengan beberapa transaksi, dan sebaliknya.'
        : 'Mutasi bank dipilih ${rp(sm)} · transaksi dipilih ${rp(st)}'
              '${sama ? ' · jumlah sama' : (ada ? ' · sisa belum dicocokkan ${rp((sm - st).abs())}' : '')}';

    final nol = _target == 0, habis = mutasi.isEmpty;
    final bisaPasti = nol && habis && !_pasti;
    final pastiAlasan = tukarJkPapan(
      'WebRekonsiliasi',
      jk,
      _pasti
          ? 'Dipastikan oleh Meiske L. Perubahan pada buku membuatnya perlu '
                'dipastikan lagi.'
          : (!nol
                ? 'Selisih belum dijelaskan harus Rp0.'
                : (!habis
                      ? 'Masih ada mutasi bank yang belum cocok.'
                      : 'Selisih Rp0 dan semua mutasi bank sudah cocok.')),
    );

    void toggle(List<String> sel, String id) => setState(() {
      sel.contains(id) ? sel.remove(id) : sel.add(id);
    });

    _BarisPilih baris(_Baris r, List<String> sel) => _BarisPilih(
      baris: r,
      on: sel.contains(r.id),
      onTap: () => toggle(sel, r.id),
      aksi: switch (r.id) {
        'm3' => 'Buat transaksi dari mutasi ini',
        't4' => 'Tandai dalam perjalanan',
        _ => null,
      },
      onAksi: switch (r.id) {
        'm3' => () => _ubah(() {
          _biayaOn = true;
          _selM = _selM.where((x) => x != 'm3').toList();
        }),
        't4' => () => _ubah(() {
          _perjalanan = true;
          _selT = _selT.where((x) => x != 't4').toList();
        }),
        _ => null,
      },
    );

    final grup = [
      for (final g in _grup)
        _PasanganCocok(
          key: ValueKey(g.id),
          m: _nama(_mutasi, g.m),
          t: _nama(_transaksi, g.t),
          jenis: '${g.t.length} transaksi',
          rp: rp(_jumlah(_mutasi, g.m)),
          lepas: () => setState(() {
            _grup = [..._grup]..remove(g);
            _pasti = false;
          }),
        ),
      if (_biayaOn)
        _PasanganCocok(
          key: const ValueKey('biaya'),
          m: 'BIAYA ADM',
          t: 'Biaya administrasi bank · BKU-2026-0133',
          jenis: 'Belanja 5.03.03.00 · Dibukukan',
          rp: rp(-_biaya),
          lepas: () => _ubah(() => _biayaOn = false),
        ),
    ];

    final ket = TextStyle(fontSize: 13, color: c.tinta3);
    Widget judul2(String a, String b) => Text.rich(
      TextSpan(
        children: [
          TextSpan(text: a),
          TextSpan(
            text: b,
            style: ket.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
    Widget kosong(String t) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(t, style: TextStyle(fontSize: 14, color: c.tinta2)),
    );
    Widget kolom(List<Widget> anak) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < anak.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          anak[i],
        ],
      ],
    );

    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        jabatanKosong: true,
        nav: NavSamping(
          item: navKeuangan,
          aktif: 3,
          pengguna: const PenggunaKeuangan(),
        ),
        isi: [
          // Title row.
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Rekonsiliasi '),
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
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _Lencana(pasti: _pasti),
            ],
          ),
          DeretTautan(
            web: true,
            anak: [
              Tautan(
                ke: 'WebRekonIsi',
                child: const Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: TautanTeks('Isi rekening koran'),
                ),
              ),
              Tautan(
                ke: 'WebHitungKas',
                cara: Cara.ganti,
                child: const Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: TautanTeks('Hitung kas'),
                ),
              ),
            ],
          ),
          // Kas/Bank chips.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Tautan(
                ke: 'WebHitungKas',
                cara: Cara.ganti,
                radius: 999,
                child: _Chip(
                  'Kas · Sudah dipastikan',
                  isi: c.permukaan,
                  garis: c.garisTegas,
                  teks: c.tinta,
                ),
              ),
              Semantics(
                selected: true,
                child: _Chip(
                  'Bank BNI ··4821',
                  isi: c.tinta,
                  garis: c.tinta,
                  teks: c.permukaan,
                ),
              ),
              _Chip(
                'Bank SulutGo ··1107 · Sudah dipastikan',
                isi: c.permukaan,
                garis: c.garisTegas,
                teks: c.tinta2,
              ),
            ],
          ),
          _KartuSaldo(
            buku: _buku,
            pembanding: _pembanding,
            perjalanan: _perjalanan,
            target: _target,
            bisaPasti: bisaPasti,
            alasan: pastiAlasan,
            pastikan: () {
              if (bisaPasti) setState(() => _pasti = true);
            },
          ),
          _BilahPilih(
            teks: pilihTeks,
            sama: sama,
            cocokkan: () {
              if (!sama) return;
              setState(() {
                _grup = [
                  ..._grup,
                  (id: _idBerikut++, m: [..._selM], t: [..._selT]),
                ];
                _selM = [];
                _selT = [];
                _pasti = false;
              });
            },
          ),
          KisiOtomatis(
            minLebar: 440,
            jarak: 20,
            anak: [
              kolom([
                judul2('Mutasi bank ', '· belum cocok'),
                for (final r in mutasi) baris(r, _selM),
                if (habis) kosong('Semua mutasi bank sudah cocok.'),
              ]),
              kolom([
                judul2('Transaksi ', '· sudah dibukukan, belum cocok'),
                for (final r in transaksi) baris(r, _selT),
                if (transaksi.isEmpty)
                  kosong('Tidak ada transaksi yang belum cocok.'),
              ]),
            ],
          ),
          if (_perjalanan)
            Gerak(
              Kerangka.muncul,
              key: const ValueKey('perjalanan'),
              lama: const Duration(milliseconds: 300),
              child: kolom([
                judul2('Dalam perjalanan ', '· dibawa ke bulan berikutnya'),
                _BarisPerjalanan(lepas: () => _ubah(() => _perjalanan = false)),
              ]),
            ),
          kolom([
            judul2('Cocok ', '· ${12 + dipakaiM.length} mutasi bank'),
            ...grup,
            Text(
              rekonCocokLainTeks,
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ]),
        ],
      ),
    );
  }
}

/// Width of one line of text in the inherited style merged with [s].
double _lebar(BuildContext context, String teks, TextStyle s) {
  final p = TextPainter(
    text: TextSpan(
      text: teks,
      style: DefaultTextStyle.of(context).style.merge(s),
    ),
    textDirection: TextDirection.ltr,
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();
  final w = p.width.ceilToDouble();
  p.dispose();
  return w;
}

/// Sedang dikerjakan / Sudah dipastikan, as this board draws it: padding
/// 4 10 inside a 1.5 line, transparent while not confirmed.
class _Lencana extends StatelessWidget {
  const _Lencana({required this.pasti});
  final bool pasti;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: pasti ? c.laut : null,
        border: Border.all(color: pasti ? c.laut : c.tinta3, width: 1.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        pasti ? 'Sudah dipastikan' : 'Sedang dikerjakan',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: pasti ? c.diLaut : c.tinta2,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(
    this.label, {
    required this.isi,
    required this.garis,
    required this.teks,
  });

  final String label;
  final Color isi, garis, teks;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 44),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: isi,
      border: Border.all(color: garis, width: 1.5),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Center(
      widthFactor: 1,
      heightFactor: 1,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: teks,
        ),
      ),
    ),
  );
}

/// A filled button that stays pressable; the handler re-checks its condition
/// (CONVENTIONS, TombolBersyarat deviation). Disabled look: `garis`/`tinta3`.
class _TombolIsi extends StatelessWidget {
  const _TombolIsi(
    this.teks, {
    required this.siap,
    required this.isi,
    required this.tinggi,
    required this.onTap,
  });
  final String teks;
  final bool siap;
  final Color isi;
  final double tinggi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      radius: 12,
      child: Container(
        constraints: BoxConstraints(minHeight: tinggi),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: siap ? isi : c.garis,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Text(
            teks,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: siap ? c.permukaan : c.tinta3,
            ),
          ),
        ),
      ),
    );
  }
}

/// "Lepaskan": a `laut` text button, min height 44.
class _Lepaskan extends StatelessWidget {
  const _Lepaskan({required this.onTap, this.ukuran, required this.padding});
  final VoidCallback onTap;
  final double? ukuran;
  final double padding;

  @override
  Widget build(BuildContext context) => Tekan(
    onTap: onTap,
    child: Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Text(
          'Lepaskan',
          style: TextStyle(
            fontSize: ukuran,
            fontWeight: FontWeight.w700,
            color: context.warna.laut,
          ),
        ),
      ),
    ),
  );
}

/// Saldo buku − Saldo pembanding = Selisih belum dijelaskan, and Pastikan.
class _KartuSaldo extends StatelessWidget {
  const _KartuSaldo({
    required this.buku,
    required this.pembanding,
    required this.perjalanan,
    required this.target,
    required this.bisaPasti,
    required this.alasan,
    required this.pastikan,
  });
  final int buku, pembanding, target;
  final bool perjalanan, bisaPasti;
  final String alasan;
  final VoidCallback pastikan;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final label = TextStyle(fontSize: 13, color: c.tinta2);
    const angka = TextStyle(
      fontFamily: PalakatText.mono,
      fontSize: 20,
      fontWeight: FontWeight.w500,
    );
    final tanda = angka.copyWith(fontWeight: FontWeight.w400, color: c.tinta3);
    final cat =
        '· rekening koran ${rp(rekonBniOktober.saldoRekeningKoran)}'
        '${perjalanan ? ' + dalam perjalanan ${rp(rekonBniOktober.dalamPerjalanan)}' : ''}';
    const tombol = 'Pastikan rekonsiliasi';
    double l(String t, TextStyle s) => _lebar(context, t, s);
    double maks(double a, double b) => a > b ? a : b;

    Widget pasangan(Widget atas, String nilai) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        atas,
        Text(nilai, style: angka),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarisLentur(
        jarak: 28,
        jarakBaris: 12,
        rata: CrossAxisAlignment.end,
        anak: [
          Lentur(
            dasar: maks(l('Saldo buku', label), l(rp(buku), angka)),
            tumbuh: 0,
            child: pasangan(Text('Saldo buku', style: label), rp(buku)),
          ),
          Lentur(
            dasar: l('−', tanda),
            tumbuh: 0,
            child: ExcludeSemantics(child: Text('−', style: tanda)),
          ),
          Lentur(
            dasar: maks(
              l('Saldo pembanding $cat', label),
              l(rp(pembanding), angka),
            ),
            tumbuh: 0,
            child: pasangan(
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Saldo pembanding '),
                    TextSpan(
                      text: cat,
                      style: TextStyle(color: c.tinta3),
                    ),
                  ],
                ),
                style: label,
              ),
              rp(pembanding),
            ),
          ),
          Lentur(
            dasar: l('=', tanda),
            tumbuh: 0,
            child: ExcludeSemantics(child: Text('=', style: tanda)),
          ),
          Lentur(
            dasar: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selisih belum dijelaskan',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                Hitung(
                  nilai: target,
                  builder: (ctx, tampil) => AnimatedDefaultTextStyle(
                    duration: ctx.gerak(const Duration(milliseconds: 300)),
                    curve: Curves.ease,
                    style: DefaultTextStyle.of(ctx).style.merge(
                      TextStyle(
                        fontFamily: PalakatText.mono,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                        color: tampil == 0 ? c.laut : c.bata,
                      ),
                    ),
                    child: Text(rp(tampil)),
                  ),
                ),
              ],
            ),
          ),
          Lentur(
            dasar: maks(
              l(tombol, const TextStyle(fontWeight: FontWeight.w700)) + 40,
              l(alasan, label) < 260 ? l(alasan, label) : 260,
            ),
            tumbuh: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TombolIsi(
                  tombol,
                  siap: bisaPasti,
                  isi: c.laut,
                  tinggi: 48,
                  onTap: pastikan,
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: Text(alasan, style: label),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The draf-line bar with the selection sentence and "Cocokkan".
class _BilahPilih extends StatelessWidget {
  const _BilahPilih({
    required this.teks,
    required this.sama,
    required this.cocokkan,
  });
  final String teks;
  final bool sama;
  final VoidCallback cocokkan;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: ShapeDecoration(
        shape: GarisBorder.putus(c.putus, radius: 14),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Align(
          alignment: Alignment.centerLeft,
          child: BarisLentur(
            jarak: 12,
            rata: CrossAxisAlignment.center,
            anak: [
              Lentur(
                dasar: 320,
                child: Text(
                  teks,
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
              ),
              Lentur(
                dasar:
                    _lebar(
                      context,
                      'Cocokkan',
                      const TextStyle(fontWeight: FontWeight.w700),
                    ) +
                    40,
                tumbuh: 0,
                child: _TombolIsi(
                  'Cocokkan',
                  siap: sama,
                  isi: c.tinta,
                  tinggi: 44,
                  onTap: cocokkan,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A mutation or transaction row with its checkbox; [aksi] is the side action.
class _BarisPilih extends StatelessWidget {
  const _BarisPilih({
    required this.baris,
    required this.on,
    required this.onTap,
    this.aksi,
    this.onAksi,
  });
  final _Baris baris;
  final bool on;
  final VoidCallback onTap;
  final String? aksi;
  final VoidCallback? onAksi;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final r = baris;
    final ket = TextStyle(fontSize: 13, color: c.tinta3);
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: ShapeDecoration(
        color: on ? c.lautLembut : c.permukaan,
        shape: GarisBorder.penuh(
          on ? c.laut : c.garis,
          tebal: on ? 1.5 : 1,
          radius: 12,
        ),
      ),
      // The board's side action is `flex: none`; it is capped so the row
      // keeps room for the checkbox, the amount and 80 px of name (390 wide).
      child: LayoutBuilder(
        builder: (context, k) => _isi(
          context,
          k.maxWidth - 8 - 78 - _lebar(context, rp(r.jm), _angka) - 80,
          ket,
        ),
      ),
    );
  }

  static const _angka = TextStyle(
    fontFamily: PalakatText.mono,
    fontWeight: FontWeight.w500,
  );
  static const _aksi = TextStyle(fontSize: 13, fontWeight: FontWeight.w700);

  Widget _isi(BuildContext context, double maksAksi, TextStyle ket) {
    final c = context.warna;
    final r = baris;
    // The board's row is `align-items: stretch`: the side action fills the
    // row height less its 8 px margins.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Tekan(
              onTap: onTap,
              radius: 12,
              peran: PeranTekan.sakelar,
              tercentang: on,
              child: Container(
                constraints: const BoxConstraints(minHeight: 60),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: on ? c.tinta : c.permukaan,
                        border: Border.all(color: c.tinta, width: 2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: PalakatIkon(
                        Ikon.centang,
                        ukuran: 14,
                        tebal: 3.4,
                        warna: c.permukaan,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.n,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          r.no == null
                              ? Text(r.tgl, style: ket)
                              : Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: r.no,
                                        style: const TextStyle(
                                          fontFamily: PalakatText.mono,
                                        ),
                                      ),
                                      TextSpan(text: ' · ${r.tgl}'),
                                    ],
                                  ),
                                  style: ket,
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(rp(r.jm), style: _angka),
                  ],
                ),
              ),
            ),
          ),
          if (aksi != null)
            Container(
              width:
                  8 +
                  math.min(
                    _lebar(context, aksi!, _aksi) + 27,
                    math.max(44, maksAksi),
                  ),
              padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
              child: Tekan(
                onTap: onAksi,
                radius: 10,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: c.permukaan,
                    border: Border.all(color: c.tinta, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    // CSS half-leading, so a wrapped label (390 wide) stays
                    // off the bottom border.
                    child: Text(
                      aksi!,
                      style: _aksi,
                      textHeightBehavior: const TextHeightBehavior(
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The deposit in transit: a draf-line row with "Lepaskan".
class _BarisPerjalanan extends StatelessWidget {
  const _BarisPerjalanan({required this.lepas});
  final VoidCallback lepas;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final t4 = rekonBniOktober.belumCocok.last;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: ShapeDecoration(
        shape: GarisBorder.putus(c.putus, radius: 12),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Setoran dalam perjalanan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      style: TextStyle(fontSize: 13, color: c.tinta3),
                      children: [
                        const TextSpan(text: '· '),
                        TextSpan(
                          text: t4.noBukti,
                          style: const TextStyle(fontFamily: PalakatText.mono),
                        ),
                        TextSpan(text: ' · ${t4.tanggal ?? kosong}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              rp(rekonBniOktober.dalamPerjalanan),
              style: const TextStyle(
                fontFamily: PalakatText.mono,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            _Lepaskan(onTap: lepas, padding: 12),
          ],
        ),
      ),
    );
  }
}

/// A matched group: the bank card slides in from the left, the transaction
/// card from the right, and the link badge pops (`kait`) between them.
class _PasanganCocok extends StatelessWidget {
  const _PasanganCocok({
    super.key,
    required this.m,
    required this.t,
    required this.jenis,
    required this.rp,
    required this.lepas,
  });
  final String m, t, jenis, rp;
  final VoidCallback lepas;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final ket = TextStyle(fontSize: 13, color: c.tinta3);
    const nama = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
    const angka = TextStyle(
      fontFamily: PalakatText.mono,
      fontWeight: FontWeight.w500,
    );
    Widget kartu(Widget child) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: GarisBorder.penuh(c.laut, radius: 12),
      ),
      child: child,
    );
    Widget masuk(Bingkai k, Widget child) => Gerak(
      k,
      lama: PalakatMotion.kait,
      kurva: PalakatMotion.keluar,
      child: child,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: masuk(
                  Kerangka.dariKiri(60),
                  kartu(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mutasi bank', style: ket),
                        Text(m, style: nama),
                        Text(rp, style: angka),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 28),
              Expanded(
                child: masuk(
                  Kerangka.dariKanan(60),
                  kartu(
                    // "Lepaskan" is capped as in [_BarisPilih]: 24 stay for
                    // the names.
                    LayoutBuilder(
                      builder: (context, k) => Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Transaksi · $jenis', style: ket),
                                Text(t, style: nama),
                                Text(rp, style: angka),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: k.maxWidth - 32 < 44
                                  ? 44
                                  : k.maxWidth - 32,
                            ),
                            child: _Lepaskan(
                              onTap: lepas,
                              ukuran: 14,
                              padding: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Gerak(
            Kerangka.kait,
            lama: const Duration(milliseconds: 400),
            tunda: const Duration(milliseconds: 400),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: c.laut, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: PalakatIkon(Ikon.kait, ukuran: 15, warna: c.diLaut),
            ),
          ),
        ],
      ),
    );
  }
}
