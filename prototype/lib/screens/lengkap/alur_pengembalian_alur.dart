import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../mock/format.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart' show BarisTombol, IsianAlur, KepalaKartu;
import '../../widgets/chip_pilihan.dart';
import '../../widgets/input_format.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

/// One original voucher of the board's `A` list.
typedef _Asal = ({
  String judul,
  String no,
  String tanggal,
  int jumlah,
  String ma,
  bool donatur,
});

const List<_Asal> _asal = [
  (
    judul: 'Pemeliharaan atap gedung',
    no: 'BKU-2026-0116',
    tanggal: '22/10/2026',
    jumlah: 5500000,
    ma: 'Belanja 5.08.02.00 Pemeliharaan gedung',
    donatur: false,
  ),
  (
    judul: 'Sewa sound system',
    no: 'BKU-2026-0143',
    tanggal: '11/11/2026',
    jumlah: 600000,
    ma: 'Belanja 5.05.02.00 Sewa peralatan',
    donatur: false,
  ),
  (
    judul: 'Sumbangan donatur',
    no: 'BKU-2026-0121',
    tanggal: '28/10/2026',
    jumlah: 500000,
    ma: 'Pendapatan 1.4.10.02.00 Sumbangan donatur',
    donatur: true,
  ),
];

const _hariT = '16/11/2026';
const _kasPilihan = ['Kas', 'Bank BNI ··4821'];
const _belanjaNov = 7940000, _pendapatanNov = 7540000, _saldoBuku = 38415000;

enum _Langkah { pilih, isi, hasil }

/// The refund flow of AlurPengembalian and WebAlurPengembalian: one state,
/// three views. [web] lays `isi` and `hasil` out in two columns.
class AlurPengembalianAlur extends StatefulWidget {
  const AlurPengembalianAlur({super.key, required this.web});

  final bool web;

  @override
  State<AlurPengembalianAlur> createState() => _AlurPengembalianAlurState();
}

class _AlurPengembalianAlurState extends State<AlurPengembalianAlur> {
  var _v = _Langkah.pilih;
  var _sel = 0;
  var _kas = '';
  var _st = '';
  final _jml = TextEditingController();
  final _alasan = TextEditingController();

  @override
  void dispose() {
    _jml.dispose();
    _alasan.dispose();
    super.dispose();
  }

  _Asal get _x => _asal[_sel];
  String get _digit => _jml.text.replaceAll('.', '');
  int get _n => int.tryParse(_digit) ?? 0;
  String get _jenis => _x.donatur ? 'Pendapatan' : 'Belanja';
  String get _kata => _x.donatur ? 'dibayarkan' : 'diterima';
  String get _kasLabel =>
      _x.donatur ? 'Keluar dari Kas/Bank' : 'Masuk ke Kas/Bank';

  /// The board's `a`: the first unmet condition, '' when all are met.
  String get _sebab => _n <= 0
      ? 'jumlah belum diisi.'
      : _n > _x.jumlah
      ? 'jumlah melebihi $_jenis asalnya (${rp(_x.jumlah)}).'
      : _kas.isEmpty
      ? 'Kas/Bank belum dipilih.'
      : _alasan.text.trim().isEmpty
      ? 'alasan belum diisi.'
      : '';

  String get _aBulan => _x.tanggal.substring(3, 5) == '10'
      ? 'Oktober 2026 Belum ditutup, tetapi pengembalian tetap dicatat di '
            'bulan uangnya $_kata: November 2026.'
      : 'Transaksi asal dan pengembalian sama-sama di November 2026.';

  void _ke(_Langkah v) {
    // Scroll on view change: jump to top (CONVENTIONS).
    Scrollable.maybeOf(context)?.position.jumpTo(0);
    setState(() => _v = v);
  }

  void _pilih(int i) {
    _sel = i;
    _kas = '';
    _st = '';
    _jml.clear();
    _alasan.clear();
    _ke(_Langkah.isi);
  }

  void _hasil(String st) {
    _st = st;
    _ke(_Langkah.hasil);
  }

  @override
  Widget build(BuildContext context) => switch (_v) {
    _Langkah.pilih => _kolom(_lihatPilih(context), 16),
    _Langkah.isi => _dua(_isiKiri(context), _isiKanan(context)),
    _Langkah.hasil => _dua(_hasilKiri(context), _hasilKanan(context)),
  };

  /// Phone: one gap-16 column. Web: `flex: 1.3 1 420px` | `flex: 1 1 340px`,
  /// gap 20 × 28, each a gap-12 column.
  Widget _dua(List<Widget> kiri, List<Widget> kanan) => widget.web
      ? BarisLentur(
          jarak: 28,
          jarakBaris: 20,
          anak: [
            Lentur(dasar: 420, tumbuh: 1.3, child: _kolom(kiri, 12)),
            Lentur(dasar: 340, child: _kolom(kanan, 12)),
          ],
        )
      : _kolom([...kiri, ...kanan], 16);

  Widget _kolom(List<Widget> anak, double jarak) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < anak.length; i++) ...[
        if (i > 0) SizedBox(height: jarak),
        anak[i],
      ],
    ],
  );

  Widget _kartu(List<Widget> anak, {EdgeInsets? padding}) => Kartu(
    padding:
        padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: _kolom(anak, 6),
  );

  Widget _catatan(String teks) =>
      Text(teks, style: TextStyle(fontSize: 13, color: context.warna.tinta3));

  List<Widget> _lihatPilih(BuildContext context) => [
    Text(
      'Pilih transaksi asalnya. Transaksi asal tidak diubah.',
      style: TextStyle(fontSize: 14, color: context.warna.tinta2),
    ),
    for (final (i, r) in _asal.indexed)
      _kartu(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        [
          KepalaKartu(
            judul: r.judul,
            ujung: LencanaStatus.uang(StatusUang.dibukukan),
          ),
          _catatan('${r.no} · ${r.tanggal} · ${rp(r.jumlah)} · ${r.ma}'),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Tombol(
              r.donatur
                  ? 'Kembalikan kepada donatur'
                  : 'Catat uang kembali dari pemasok',
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.sedang,
              lebarPenuh: false,
              onPressed: () => _pilih(i),
            ),
          ),
        ],
      ),
  ];

  List<Widget> _isiKiri(BuildContext context) => [
    _kartu([
      KepalaKartu(
        judul: _x.judul,
        ujung: LencanaStatus.uang(StatusUang.dibukukan),
      ),
      _BarisKv('No. Bukti', _x.no, mono: true),
      _BarisKv('Jumlah (Rp)', rp(_x.jumlah), mono: true),
      _BarisKv('Mata Anggaran', _x.ma),
      _catatan(_aBulan),
    ]),
    Pesan(
      siaran: false,
      Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: _x.donatur
                  ? 'Pengembalian kepada donatur mengurangi Pendapatan di '
                        'bulan uangnya dibayarkan.'
                  : 'Uang kembali dari pemasok mengurangi Belanja di bulan '
                        'uangnya diterima.',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text:
                  ' Dicatat sebagai $_jenis negatif pada Mata Anggaran yang '
                  'sama dan tertaut ke transaksi asal. Bulan yang sudah '
                  'ditutup tidak dibuka lagi.',
            ),
          ],
        ),
        style: TextStyle(color: context.warna.tinta),
        // Bold and regular runs keep the paragraph's 1.4 / 1.45 lines.
        strutStyle: StrutStyle.fromTextStyle(
          DefaultTextStyle.of(context).style
              .merge(const TextStyle(fontSize: 14)),
          forceStrutHeight: true,
        ),
      ),
    ),
  ];

  List<Widget> _isiKanan(BuildContext context) {
    final sebab = _sebab;
    final mulai =
        _jml.text.isNotEmpty || _kas.isNotEmpty || _alasan.text.isNotEmpty;
    return [
      IsianAlur(
        label: 'Jumlah dikembalikan (Rp)',
        controller: _jml,
        petunjuk: '0',
        keterangan: rpDigit(_digit),
        formatter: const [RupiahInputFormatter(sisakanNol: true)],
        onChanged: (_) => setState(() {}),
      ),
      ChipPilihan<String>(
        label: _kasLabel,
        jarakLabel: 6,
        // The board's chip row has gap 8 and no margin under it.
        jarakBawah: 0,
        pilihan: [for (final k in _kasPilihan) (nilai: k, teks: k)],
        terpilih: _kas.isEmpty ? null : _kas,
        onPilih: (k) => setState(() => _kas = k),
      ),
      const _BarisKv('Tanggal transaksi', _hariT),
      _catatan(
        'Tanggal transaksi adalah hari uangnya $_kata, bukan tanggal '
        'transaksi asal.',
      ),
      IsianAlur(
        label: 'Alasan · wajib',
        controller: _alasan,
        baris: 3,
        onChanged: (_) => setState(() {}),
      ),
      if (mulai && sebab.isNotEmpty)
        Penolakan(
          tindakan: 'Periksa dan bukukan',
          sebab: sebab,
          jalan: const [],
          ukuranTeks: 14,
        ),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: 'Periksa dan bukukan',
            tindakan: 'Periksa dan bukukan',
            alasan: sebab,
            sudahMulai: false,
            periksa: () => _sebab,
            onPressed: () => _hasil('Dibukukan'),
          ),
          Semantics(
            hint: sebab.isEmpty ? null : sebab,
            child: Tombol(
              'Simpan sebagai draf',
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.sedang,
              onPressed: () {
                if (_sebab.isEmpty) _hasil('Draf');
              },
            ),
          ),
        ],
      ),
      BarisTombol(
        anak: [
          Tombol(
            'Kembali',
            jenis: JenisTombol.teks,
            ukuran: UkuranTombol.kecil,
            onPressed: () => _ke(_Langkah.pilih),
          ),
        ],
      ),
    ];
  }

  List<Widget> _hasilKiri(BuildContext context) {
    final dibukukan = _st == 'Dibukukan';
    final alasan = _alasan.text.trim();
    return [
      _kartu([
        KepalaKartu(
          judul:
              '${_x.donatur ? 'Pengembalian kepada donatur' : 'Uang kembali dari pemasok'} · ${_x.judul}',
          ujung: LencanaStatus.uang(
            dibukukan ? StatusUang.dibukukan : StatusUang.draf,
          ),
        ),
        _BarisKv('Jumlah (Rp)', '−${rpDigit(_digit)}', mono: true),
        _BarisKv('Mata Anggaran', _x.ma),
        _BarisKv(_kasLabel, _kas),
        const _BarisKv('Tanggal transaksi', _hariT),
        _BarisKv('Terkait dengan', _x.no, mono: true),
        _catatan(
          dibukukan
              ? 'Dibukukan $_hariT oleh Meiske L. · No. Bukti diberikan saat '
                    'dibukukan · alasan: $alasan'
              : 'Draf dicatat $_hariT · alasan: $alasan',
        ),
      ]),
    ];
  }

  List<Widget> _hasilKanan(BuildContext context) {
    final n = _n;
    final don = _x.donatur;
    return [
      if (_st == 'Dibukukan')
        _kartu([
          const Text(
            'Pengaruhnya',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          _BarisKv(
            '$_jenis November 2026',
            rp((don ? _pendapatanNov : _belanjaNov) - n),
            mono: true,
          ),
          _BarisKv(
            'Saldo buku semua Kas/Bank',
            rp(_saldoBuku + (don ? -n : n)),
            mono: true,
          ),
          _catatan(_aBulan),
        ]),
      if (_st == 'Draf') ...[
        _catatan(
          'Draf belum masuk saldo. Draf di bulan yang akan ditutup '
          'menghalangi tutup buku.',
        ),
        BarisTombol(
          anak: [
            Tombol(
              'Periksa dan bukukan',
              jenis: JenisTombol.tinta,
              onPressed: () => setState(() => _st = 'Dibukukan'),
            ),
          ],
        ),
      ],
      BarisTombol(
        anak: [
          Tombol(
            'Selesai',
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.sedang,
            onPressed: () => _ke(_Langkah.pilih),
          ),
        ],
      ),
    ];
  }
}

/// The boards' key–value row (`display: flex; justify-content:
/// space-between; gap: 16px`, 14 px): like [BarisInfo], but when the two
/// texts do not fit both sides shrink in proportion to their width, down to
/// their longest word, as CSS flex-shrink does ("Mata / Anggaran" wraps).
class _BarisKv extends StatelessWidget {
  const _BarisKv(this.label, this.nilai, {this.mono = false});

  final String label;
  final String nilai;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final dasar = DefaultTextStyle.of(context).style
        .merge(const TextStyle(fontSize: 14));
    final gL = dasar.copyWith(color: c.tinta2);
    final gN = dasar.copyWith(
      color: c.tinta,
      fontWeight: FontWeight.w600,
      fontFamily: mono ? PalakatText.mono : null,
    );
    final skala = MediaQuery.textScalerOf(context);
    (double, double) ukur(String t, TextStyle g) {
      final tp = TextPainter(
        text: TextSpan(text: t, style: g),
        textDirection: TextDirection.ltr,
        textScaler: skala,
      )..layout();
      final r = (tp.minIntrinsicWidth, tp.maxIntrinsicWidth);
      tp.dispose();
      return r;
    }

    return LayoutBuilder(
      builder: (context, k) {
        final w = k.maxWidth - 16;
        final (minA, a) = ukur(label, gL);
        final (minB, b) = ukur(nilai, gN);
        var wa = a;
        if (a + b > w) {
          wa = a - (a + b - w) * a / (a + b);
          final wb = w - wa;
          if (wa < minA) wa = minA;
          if (wb < minB) wa = math.max(minA, w - minB);
        }
        final baris = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: wa.ceilToDouble(),
              child: Text(label, style: gL),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(nilai, textAlign: TextAlign.right, style: gN),
            ),
          ],
        );
        // A mono span in a sans line box: Chrome rounds each font's ascent
        // and descent, so the board's mono rows are 1 px taller (21.3 vs 20.3).
        return mono
            ? Padding(padding: const EdgeInsets.only(bottom: 1), child: baris)
            : baris;
      },
    );
  }
}
