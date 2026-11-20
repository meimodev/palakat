import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../mock/orang.dart' show plk;
import '../../motion/kerangka.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/input_format.dart';
import '../../widgets/kecil.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tahapan.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// 30 · Rekonsiliasi: isi rekening koran dan cocok sebagian (spec 09).
class RekonIsiScreen extends StatefulWidget {
  const RekonIsiScreen({super.key});
  @override
  State<RekonIsiScreen> createState() => _RekonIsiState();
}

class _RekonIsiState extends State<RekonIsiScreen> with RekonIsiLogika {
  @override
  String get stem => 'RekonIsi';

  @override
  Widget build(BuildContext context) {
    final b = bagian(context);
    return LayarPonsel(
      layarKeuangan: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Rekonsiliasi',
            anakJudul: 'Bank BNI ··4821 · Oktober 2026',
            kembaliKe: Layar.tutupBuku,
            labelKembali: 'Kembali ke Bulan',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: kolomRekon([
                b.isian,
                b.daftar,
                b.tahap,
                b.sisa,
                ...b.akhir,
              ], 16),
            ),
          ),
        ],
      ),
    );
  }
}

/// Column with a CSS `gap`.
Widget kolomRekon(
  List<Widget> anak,
  double jarak, {
  CrossAxisAlignment rata = CrossAxisAlignment.stretch,
}) => Column(
  crossAxisAlignment: rata,
  mainAxisSize: MainAxisSize.min,
  children: [
    for (var i = 0; i < anak.length; i++) ...[
      if (i > 0) SizedBox(height: jarak),
      anak[i],
    ],
  ],
);

/// The board's transactions T: No. Bukti, text, amount.
const _t = {
  't1': ('BKU-2026-0118', 'Persembahan syukur', 500000),
  't2': ('BKU-2026-0121', 'Sumbangan donatur', 500000),
  't3': ('BKU-2026-0127', 'Pindah antar Kas/Bank: Bank BNI ke Kas', -2000000),
  't4': ('BKU-2026-0133', 'Biaya administrasi bank', -15000),
};

typedef _Mutasi = ({
  String id,
  String n,
  String tgl,
  int jm,
  List<String> k,
  List<String> awal,
});

const List<_Mutasi> _mutasiCsv = [
  (
    id: 'l1',
    n: 'TRF MASUK IBU RUNTU',
    tgl: '28/10/2026',
    jm: 1000000,
    k: ['t1', 't2'],
    awal: [],
  ),
  (
    id: 'l2',
    n: 'TARIK TUNAI',
    tgl: '30/10/2026',
    jm: -2000000,
    k: ['t3'],
    awal: [],
  ),
  (
    id: 'l3',
    n: 'BIAYA ADM',
    tgl: '31/10/2026',
    jm: -15000,
    k: ['t4'],
    awal: ['t4'],
  ),
];

/// The parts both boards place: RekonIsi stacks them, WebRekonIsi splits
/// them into two columns.
typedef BagianRekon = ({
  Widget isian,
  Widget daftar,
  Widget tahap,
  Widget sisa,
  List<Widget> akhir,
});

/// The logic class shared by RekonIsi and WebRekonIsi: state, derived values,
/// handlers and the parts. Each screen owns its own instance.
mixin RekonIsiLogika<W extends StatefulWidget> on State<W> {
  /// Board stem the tweaks are read from.
  String get stem;

  bool _csv = false;
  final List<(String, int)> _tambah = [];
  final Map<String, List<String>> _m = {};
  String _st = 'kerja';
  bool _lagi = false;

  final _saldo = TextEditingController();
  final _fu = TextEditingController();
  final _fj = TextEditingController();

  @override
  void dispose() {
    _saldo.dispose();
    _fu.dispose();
    _fj.dispose();
    super.dispose();
  }

  List<_Mutasi> get _daftar => [
    if (_csv) ..._mutasiCsv,
    for (var i = 0; i < _tambah.length; i++)
      (
        id: 'x$i',
        n: _tambah[i].$1,
        tgl: '31/10/2026',
        jm: _tambah[i].$2,
        k: const <String>[],
        awal: const <String>[],
      ),
  ];

  List<String> _pakai(_Mutasi l) => _m[l.id] ?? l.awal;

  int _sisa(_Mutasi l) => l.jm - _pakai(l).fold(0, (a, k) => a + _t[k]!.$3);

  bool get _okF => _fu.text.trim().isNotEmpty && (angkaDari(_fj.text) ?? 0) > 0;

  /// Rule A02: the first unmet field, named by its label on the board.
  String get _alasanF => _fu.text.trim().isEmpty
      ? 'Uraian mutasi belum diisi.'
      : _okF
      ? ''
      : 'Jumlah mutasi belum diisi.';

  void _tambahMutasi() {
    if (!_okF) return;
    setState(() {
      _tambah.add((_fu.text.trim(), angkaDari(_fj.text)!));
      _fu.clear();
      _fj.clear();
    });
  }

  BagianRekon bagian(BuildContext context) {
    final c = context.warna;
    final wajib = belumDipindah<bool>(false);
    final berubah = belumDipindah<bool>(false);
    final jk = belumDipindah(false);
    final kerja = _st == 'kerja';

    final daftar = _daftar;
    final sisaTotal = daftar.fold(0, (a, l) => a + _sisa(l).abs());
    final semua = daftar.isNotEmpty && daftar.every((l) => _sisa(l) == 0);
    final okSaldo = _saldo.text.isNotEmpty;
    final siap = semua && okSaldo;
    final invalid = _st == 'pasti' && berubah && !_lagi;
    final urut = wajib
        ? ['Sedang dikerjakan', 'Sudah diperiksa', 'Sudah dipastikan']
        : ['Sedang dikerjakan', 'Sudah dipastikan'];
    final ke = kerja ? 0 : (_st == 'periksa' ? 1 : urut.length - 1);
    final aksiTeks = kerja
        ? (wajib ? 'Tandai sudah diperiksa' : 'Pastikan rekonsiliasi')
        : (_st == 'periksa' ? 'Pastikan rekonsiliasi' : '');
    final alasan = !okSaldo
        ? 'Saldo rekening koran belum diisi.'
        : daftar.isEmpty
        ? 'Belum ada mutasi bank.'
        : !semua
        ? 'Masih ada mutasi bank yang belum cocok seluruhnya.'
        : _st == 'periksa'
        ? 'Sudah diperiksa oleh Pnt. Jefry Wowor. Bendahara memastikan.'
        : 'Semua mutasi bank cocok dan selisih belum dijelaskan Rp0.';
    const t14 = TextStyle(fontSize: 14);

    final isian = Kartu(
      padding: const EdgeInsets.all(16),
      child: kolomRekon([
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _IsianSaldo(
              controller: _saldo,
              onChanged: (_) => setState(() {}),
              hanyaBaca: !kerja,
            ),
            const SizedBox(height: 4),
            Text(
              okSaldo
                  ? 'Saldo rekening koran per 31/10/2026'
                  : 'Rekening koran belum diisi. Kosong bukan Rp0.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: okSaldo ? c.tinta2 : c.bata,
              ),
            ),
          ],
        ),
        if (!_csv && kerja)
          Tombol(
            'Unggah mutasi dari file CSV',
            onPressed: () => setState(() => _csv = true),
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.sedang,
          ),
        if (_csv)
          Gerak(
            Kerangka.muncul,
            lama: const Duration(milliseconds: 300),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'mutasi-bni-okt.csv',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: c.tinta,
                    ),
                  ),
                  const TextSpan(
                    text: ' · 3 mutasi dibaca. Belum ada yang dicocokkan.',
                  ),
                ],
              ),
              style: t14.copyWith(color: c.tinta2),
            ),
          ),
        if (kerja)
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.garis)),
            ),
            child: kolomRekon([
              Text(
                'Atau ketik satu mutasi',
                style: t14.copyWith(color: c.tinta2),
              ),
              IsianTeks(
                controller: _fu,
                petunjuk: 'Uraian di rekening koran',
                labelSemantik: 'Uraian mutasi',
                onChanged: (_) => setState(() {}),
              ),
              // Rule A02: the TombolBersyarat sentence the board lacks, above
              // the row (the outlined button and its row are the board's).
              if (_alasanF.isNotEmpty &&
                  (_fu.text.isNotEmpty || _fj.text.isNotEmpty))
                Penolakan(
                  tindakan: 'Tambah',
                  sebab: _alasanF,
                  jalan: const [],
                  ukuranTeks: 14,
                ),
              Row(
                children: [
                  Expanded(
                    child: IsianTeks(
                      controller: _fj,
                      petunjuk: 'Jumlah masuk',
                      labelSemantik: 'Jumlah mutasi',
                      keyboardType: TextInputType.number,
                      formatters: const [RupiahInputFormatter()],
                      gaya: const TextStyle(fontFamily: PalakatText.mono),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TekanAria(
                    onTap: _tambahMutasi,
                    aktif: _okF,
                    petunjuk: _okF ? null : _alasanF,
                    radius: 12,
                    child: RupaTombol(
                      label: 'Tambah',
                      isi: c.permukaan,
                      garis: GarisBorder.penuh(c.tinta, radius: 12),
                      warnaTeks: c.tinta,
                      radius: 12,
                      tinggi: 48,
                      paddingH: 16,
                      lebarPenuh: false,
                    ),
                  ),
                ],
              ),
            ], 8),
          ),
      ], 12),
    );

    final Widget daftarW = daftar.isEmpty
        ? Container(
            padding: const EdgeInsets.all(16),
            decoration: ShapeDecoration(
              shape: GarisBorder.putus(c.putus, radius: 14),
            ),
            child: Text(
              'Belum ada mutasi bank. Unggah file CSV dari bank, atau ketik satu per satu.',
              style: t14.copyWith(color: c.tinta2),
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final l in daftar)
                Padding(
                  key: ValueKey(l.id),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _kartuMutasi(c, l, kerja),
                ),
            ],
          );

    final tahap = Tahapan(
      langkah: urut,
      selesai: invalid ? urut.length - 1 : ke + 1,
    );

    final sisa = Container(
      padding: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.tinta, width: 1.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          const Expanded(
            child: Text(
              'Sisa belum dicocokkan',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            rp(sisaTotal),
            style: TextStyle(
              fontFamily: PalakatText.mono,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: sisaTotal == 0 && daftar.isNotEmpty ? c.laut : c.bata,
            ),
          ),
        ],
      ),
    );

    const muncul = Duration(milliseconds: 300);
    final akhir = <Widget>[
      if (invalid)
        Gerak(
          Kerangka.muncul,
          key: const ValueKey('invalid'),
          lama: muncul,
          child: Kartu(
            status: GarisStatus.hambatan,
            child: kolomRekon(
              [
                Text(
                  'Perlu dipastikan lagi',
                  style: TextStyle(fontWeight: FontWeight.w700, color: c.bata),
                ),
                Text(
                  'BKU-2026-0127 dibalik setelah rekonsiliasi dipastikan. Pencocokan tetap tersimpan; hanya kepastiannya yang tidak berlaku lagi, dan ini menjadi hambatan tutup buku.',
                  style: t14.copyWith(color: c.tinta2),
                ),
                Tombol(
                  'Pastikan lagi',
                  onPressed: () => setState(() => _lagi = true),
                  ukuran: UkuranTombol.ringkas,
                  lebarPenuh: false,
                ),
              ],
              8,
              rata: CrossAxisAlignment.start,
            ),
          ),
        ),
      if (_st == 'pasti' && !invalid)
        Gerak(
          Kerangka.muncul,
          key: const ValueKey('pasti'),
          lama: muncul,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: c.lautLembut,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Sudah dipastikan oleh ${plk(jk)}, 16/11/2026. Perubahan pada buku Oktober membuatnya perlu dipastikan lagi.',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      if (aksiTeks.isNotEmpty) ...[
        Text(alasan, style: t14.copyWith(color: c.tinta2)),
        TekanAria(
          onTap: () {
            if (!siap) return;
            setState(() => _st = kerja && wajib ? 'periksa' : 'pasti');
          },
          aktif: siap,
          radius: 14,
          child: RupaTombol(
            label: aksiTeks,
            isi: siap ? c.laut : c.garis,
            warnaTeks: siap ? c.diLaut : c.tinta3,
            radius: 14,
            tinggi: 52,
            paddingH: 20,
          ),
        ),
      ],
    ];

    return (
      isian: isian,
      daftar: daftarW,
      tahap: tahap,
      sisa: sisa,
      akhir: akhir,
    );
  }

  Widget _kartuMutasi(PalakatWarna c, _Mutasi l, bool kerja) {
    final p = _pakai(l);
    final sisa = _sisa(l);
    final cocok = sisa == 0;
    final (lencana, isi, teks, garis) = cocok
        ? ('Cocok', c.laut, c.diLaut, c.laut)
        : p.isNotEmpty
        ? ('Sebagian cocok', c.permukaan, c.tinta, c.tinta)
        : ('Belum cocok', c.permukaan, c.tinta2, c.tinta3);
    final calon = kerja
        ? l.k.where((k) => !p.contains(k)).toList()
        : const <String>[];
    const t13 = TextStyle(fontSize: 13);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: cocok
            ? GarisBorder.penuh(c.laut, radius: 14)
            : GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
      ),
      child: kolomRekon([
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: ShapeDecoration(
                  color: isi,
                  shape: GarisBorder.penuh(garis, radius: 6),
                ),
                child: Text(
                  lencana,
                  style: t13.copyWith(fontWeight: FontWeight.w700, color: teks),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              rp(l.jm),
              style: const TextStyle(
                fontFamily: PalakatText.mono,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '${l.n} '),
              TextSpan(
                text: '· ${l.tgl}',
                style: t13.copyWith(
                  color: c.tinta3,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        if (sisa != 0 && p.isNotEmpty)
          Text(
            'sisa belum dicocokkan: ${rp(sisa.abs())}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        for (final k in p)
          Gerak(
            Kerangka.muncul,
            key: ValueKey(k),
            lama: const Duration(milliseconds: 300),
            child: Text(
              '↔ ${_t[k]!.$1} · ${_t[k]!.$2} · ${rp(_t[k]!.$3)}',
              style: t13.copyWith(
                fontFamily: PalakatText.mono,
                color: c.tinta2,
              ),
            ),
          ),
        // The action wrapper is always there, so it always adds one gap.
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final k in calon)
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 8),
                child: Tekan(
                  onTap: () => setState(() => _m[l.id] = [...p, k]),
                  radius: 10,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: ShapeDecoration(
                      color: c.permukaan,
                      shape: GarisBorder.penuh(c.tinta, radius: 10),
                    ),
                    child: Center(
                      widthFactor: 1,
                      heightFactor: 1,
                      child: _IsiCocokkan('${_t[k]!.$1} · ${rp(_t[k]!.$3)}'),
                    ),
                  ),
                ),
              ),
            if (p.isNotEmpty && kerja)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Tekan(
                  onTap: () => setState(() => _m[l.id] = []),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      widthFactor: 1,
                      heightFactor: 1,
                      child: Text(
                        'Lepaskan',
                        style: TextStyle(
                          fontSize: 14,
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
        if (l.k.isEmpty)
          Text(
            'Belum ada transaksinya. Buat transaksi dari mutasi ini, atau periksa lagi rekening korannya.',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
      ], 6),
    );
  }
}

/// The inside of a "Cocokkan · …" button. The board's button is inline-flex,
/// so "Cocokkan ·" and the mono span are two flex items that shrink in
/// proportion to their own widths and wrap separately.
class _IsiCocokkan extends StatelessWidget {
  const _IsiCocokkan(this.kode);
  final String kode;

  @override
  Widget build(BuildContext context) {
    final gaya = DefaultTextStyle.of(context).style
        .merge(const TextStyle(fontSize: 13, fontWeight: FontWeight.w700));
    final mono = gaya.copyWith(fontFamily: PalakatText.mono);
    final skala = MediaQuery.textScalerOf(context);
    int lebar(String t, TextStyle s) {
      final tp = TextPainter(
        text: TextSpan(text: t, style: s),
        textDirection: TextDirection.ltr,
        textScaler: skala,
      )..layout();
      final w = (tp.width * 100).ceil();
      tp.dispose();
      return w;
    }

    const awal = 'Cocokkan ·';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          flex: lebar(awal, gaya),
          child: Text(awal, style: gaya),
        ),
        const SizedBox(width: 4),
        Flexible(
          flex: lebar(kode, mono),
          child: Text(kode, style: mono),
        ),
      ],
    );
  }
}

/// The saldo field: IsianJumlah at 26 px, but the board keeps 12 digits
/// (`slice(0, 12)`) and IsianJumlah's formatter stops at 11.
// ponytail: drop for IsianJumlah(ukuran: sedang, petunjuk: '—') once it takes `maks`.
class _IsianSaldo extends StatefulWidget {
  const _IsianSaldo({
    required this.controller,
    required this.onChanged,
    required this.hanyaBaca,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool hanyaBaca;

  @override
  State<_IsianSaldo> createState() => _IsianSaldoState();
}

class _IsianSaldoState extends State<_IsianSaldo> {
  final _fokus = FocusNode();

  @override
  void initState() {
    super.initState();
    _fokus.addListener(_ubah);
  }

  void _ubah() => setState(() {});

  @override
  void dispose() {
    _fokus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final dasar = DefaultTextStyle.of(context).style;
    final angka = dasar.copyWith(
      fontFamily: PalakatText.mono,
      fontFeatures: const [FontFeature.tabularFigures()],
      fontSize: 26,
      fontWeight: FontWeight.w500,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: GestureDetector(
            onTap: _fokus.requestFocus,
            child: Text(
              'Saldo rekening koran',
              strutStyle: StrutStyle.fromTextStyle(dasar),
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ),
        ),
        Container(
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
                  label: 'Saldo rekening koran',
                  child: CincinFokus(
                    tampil: _fokus.hasFocus,
                    // Rule X03: the field measured 43.6; the 0.4 goes below
                    // the top-aligned line, so the figure stays put.
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: Material(
                        type: MaterialType.transparency,
                        child: TextField(
                          controller: widget.controller,
                          focusNode: _fokus,
                          onChanged: widget.onChanged,
                          readOnly: widget.hanyaBaca,
                          keyboardType: TextInputType.number,
                          inputFormatters: const [
                            RupiahInputFormatter(maks: 12),
                          ],
                          textAlignVertical: TextAlignVertical.top,
                          style: angka,
                          cursorColor: c.laut,
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            // min-height 44 with the line centred, as in Chrome.
                            contentPadding: EdgeInsets.symmetric(
                              vertical: ((44 - 26 * (dasar.height ?? 1.4)) / 2)
                                  .clamp(0, 22),
                            ),
                            hintText: '—',
                            hintStyle: angka.copyWith(color: c.tinta3),
                          ),
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
    );
  }
}
