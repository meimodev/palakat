import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../mock/mock.dart';
import '../../motion/kerangka.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/input_format.dart';
import '../../widgets/isian_jumlah.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import '../../app/layar.dart';

/// Per-kind copy of the board's `CFG`.
typedef _Cfg = ({
  String tab,
  String pihak,
  String ph,
  String jm,
  String akun,
  String ur,
  String dok,
  String cat,
  String tombol,
  String sisa,
  String st,
  String no,
  String hasil,
  String hasilCat,
});

const Map<String, _Cfg> _cfg = {
  'um': (
    tab: 'Uang Muka',
    pihak: 'Diberikan kepada',
    ph: 'Nama penerima uang muka',
    jm: 'Jumlah uang muka (Rp)',
    akun: 'Diambil dari Kas/Bank',
    ur: 'Untuk keperluan',
    dok: 'Tanda terima uang muka',
    cat: 'Uang muka bukan Belanja saat diberikan. Mata Anggaran dipilih nanti, saat pertanggungjawabannya dicatat.',
    tombol: 'Periksa dan bukukan',
    sisa: 'Sisa belum dipertanggungjawabkan',
    st: 'Belum dipertanggungjawabkan',
    no: 'BKU-2026-0153',
    hasil: 'Uang muka dibukukan',
    hasilCat: 'Kasusnya terbuka sampai seluruh uang dipertanggungjawabkan atau dikembalikan.',
  ),
  'tt': (
    tab: 'Titipan',
    pihak: 'Titipan untuk',
    ph: 'Contoh: Sinode',
    jm: 'Jumlah diterima (Rp)',
    akun: 'Masuk ke Kas/Bank',
    ur: 'Uraian',
    dok: 'Bukti penerimaan titipan',
    cat: 'Uang titipan untuk pihak lain. Bukan Pendapatan saat diterima, dan bukan Belanja saat disalurkan.',
    tombol: 'Periksa dan bukukan',
    sisa: 'Sisa belum disalurkan',
    st: 'Belum disalurkan',
    no: 'BKU-2026-0154',
    hasil: 'Titipan dibukukan',
    hasilCat: 'Kasusnya terbuka sampai seluruh titipan disalurkan kepada yang berhak.',
  ),
  'pb': (
    tab: 'Penggantian biaya',
    pihak: 'Dibayar kepada',
    ph: 'Nama yang mengajukan klaim',
    jm: 'Jumlah klaim (Rp)',
    akun: '',
    ur: 'Yang dibeli',
    dok: 'Nota atau kuitansi',
    cat: 'Mencatat dan mengecek klaim tidak mengubah saldo. Pembayarannya mencatat Belanja satu kali.',
    tombol: 'Simpan klaim',
    sisa: 'Belum dibayar',
    st: 'Belum dibayar · klaim belum dicek',
    no: '',
    hasil: 'Klaim disimpan · belum masuk saldo',
    hasilCat: 'Cek klaim lebih dulu, lalu bayar. Mata Anggaran dipilih saat pembayaran.',
  ),
};

const _peruntukan = ['Umum Jemaat', 'Diakonia', 'Pembangunan'];
const _lingkup = ['Jemaat', 'Kolom 3', 'BIPRA Pemuda', 'Panitia Natal'];
const _tempo = ['30/11/2026', '15/12/2026', '31/12/2026'];
const _mataAnggaran = [
  ('2.1.01.02.00', 'Sentralisasi Sinode'),
  ('2.2.01.02.00', 'Persembahan khusus Wilayah'),
];

/// Web · Kasus baru: Uang Muka, Titipan, Penggantian biaya
/// (docs/build/screens/10-aifoto.md, WebKasusBaru).
class WebKasusBaruScreen extends StatefulWidget {
  const WebKasusBaruScreen({super.key});

  @override
  State<WebKasusBaruScreen> createState() => _WebKasusBaruScreenState();
}

class _WebKasusBaruScreenState extends State<WebKasusBaruScreen> {
  final _pihak = TextEditingController();
  final _jm = TextEditingController();
  final _ur = TextEditingController();
  String _tab = 'um';
  int? _akun;
  String? _per, _ling, _ma, _tempoPilih;
  bool _selesai = false;

  @override
  void dispose() {
    _pihak.dispose();
    _jm.dispose();
    _ur.dispose();
    super.dispose();
  }

  /// The board's reset (kind chip, "Catat kasus lain").
  void _kosongkan(String tab) => setState(() {
    _tab = tab;
    _pihak.clear();
    _jm.clear();
    _ur.clear();
    _akun = null;
    _per = _ling = _ma = _tempoPilih = null;
    _selesai = false;
  });

  /// Chips and rows: nothing once posted.
  void _pilih(void Function() f) {
    if (!_selesai) setState(f);
  }

  _Cfg get _k => _cfg[_tab]!;
  int get _j => angkaDari(_jm.text) ?? 0;

  String get _alasan {
    final k = _k, j = _j;
    final um = _tab == 'um', tt = _tab == 'tt', pb = _tab == 'pb';
    final ak = _akun == null ? null : kasusBaruKasBank[_akun!];
    if (_pihak.text.trim().isEmpty) return '“${k.pihak}” belum diisi.';
    if (j <= 0) return 'jumlah belum diisi.';
    if (!pb && ak == null) return 'Kas/Bank belum dipilih.';
    if (um && j > ak!.$2) {
      return 'melebihi saldo buku ${ak.$1} (${rp(ak.$2)}).';
    }
    if (um && _per == null) return 'peruntukan belum dipilih.';
    if (um && _ling == null) return 'Lingkup belum dipilih.';
    if (tt && _ma == null) return 'Mata Anggaran belum dipilih.';
    if (_ur.text.trim().isEmpty) return 'uraian belum diisi.';
    if (um && _tempoPilih == null) return 'jatuh tempo belum dipilih.';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final k = _k;
    final um = _tab == 'um', tt = _tab == 'tt', pb = _tab == 'pb';

    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _sela(16, [
        Text(
          k.cat,
          style: TextStyle(fontSize: 14, color: context.warna.tinta2),
        ),
        _IsianWajib(
          label: k.pihak,
          controller: _pihak,
          petunjuk: k.ph,
          hanyaBaca: _selesai,
          onChanged: (_) => setState(() {}),
        ),
        IsianJumlah(
          label: k.jm,
          controller: _jm,
          hanyaBaca: _selesai,
          onChanged: (_) => setState(() {}),
        ),
        if (!pb)
          ChipPilihan<int>(
            label: k.akun,
            pilihan: [
              for (var i = 0; i < kasusBaruKasBank.length; i++)
                (nilai: i, teks: kasusBaruKasBank[i].$1),
            ],
            terpilih: _akun,
            onPilih: (v) => _pilih(() => _akun = v),
          ),
        if (um) ...[
          ChipPilihan<String>(
            label: 'Diambil dari peruntukan',
            pilihan: [for (final p in _peruntukan) (nilai: p, teks: p)],
            terpilih: _per,
            onPilih: (v) => _pilih(() => _per = v),
          ),
          ChipPilihan<String>(
            label: 'Lingkup',
            pilihan: [for (final p in _lingkup) (nilai: p, teks: p)],
            terpilih: _ling,
            onPilih: (v) => _pilih(() => _ling = v),
          ),
        ],
        if (tt) _daftarMa(context),
        _IsianWajib(
          label: k.ur,
          controller: _ur,
          hanyaBaca: _selesai,
          onChanged: (_) => setState(() {}),
        ),
        if (um)
          ChipPilihan<String>(
            label: 'Jatuh tempo',
            pilihan: [
              for (var i = 0; i < _tempo.length; i++)
                (nilai: _tempo[i], teks: kasusBaruJatuhTempo[i]),
            ],
            terpilih: _tempoPilih,
            onPilih: (v) => _pilih(() => _tempoPilih = v),
          ),
        _barisDokumen(context, k),
      ]),
    );

    final aside = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _sela(14, [
        _kartuEfek(context),
        if (!_selesai)
          TombolBersyarat(
            label: k.tombol,
            tindakan: k.tombol,
            alasan: _alasan,
            periksa: () => _alasan,
            onPressed: () => setState(() => _selesai = true),
            warnaSiap: JenisTombol.utama,
            teksBelumRedup: true,
            gayaAlasan: GayaAlasan.pendamping,
            paddingH: 20,
            jarak: 14,
          ),
        if (_selesai)
          Gerak(
            Kerangka.muncul,
            key: ValueKey('hasil$_tab'),
            lama: const Duration(milliseconds: 300),
            child: _hasil(context),
          ),
      ]),
    );

    return HalamanWeb(
      nav: NavSamping(item: navKeuangan, aktif: 2),
      layarKeuangan: true,
      isi: [
        _judul(context),
        // The last chip's 8 px right margin counts toward the line (CSS
        // `margin: 0 8px 8px 0`): at 390 wide "Penggantian biaya" wraps.
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChipPilihan<String>(
            pilihan: [
              for (final t in const ['um', 'tt', 'pb'])
                (nilai: t, teks: _cfg[t]!.tab),
            ],
            terpilih: _tab,
            onPilih: _kosongkan,
          ),
        ),
        BarisLentur(
          jarak: 24,
          anak: [
            Lentur(dasar: 440, tumbuh: 999, child: form),
            Lentur(dasar: 380, child: aside),
          ],
        ),
      ],
    );
  }

  Widget _judul(BuildContext context) {
    final c = context.warna;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // An inline 14 px link on a 15 / 1.45 line: the 44 px target overhangs.
        MarginNegatif(
          atas: (44 - 15 * 1.45) / 2,
          bawah: (44 - 15 * 1.45) / 2,
          child: Tautan(
            ke: Layar.kewajiban,
            cara: Cara.naik,
            child: const Align(
              widthFactor: 1,
              heightFactor: 1,
              child: TautanTeks('Uang Muka dan Titipan', ukuran: 14),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Semantics(
          header: true,
          child: const Text(
            'Kasus baru',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          'Memberi uang muka, menerima titipan, atau mencatat klaim penggantian biaya.',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
      ],
    );
  }

  Widget _daftarMa(BuildContext context) {
    final c = context.warna;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _sela(8, [
        Text(
          'Mata Anggaran · hanya baris yang boleh untuk Titipan',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
        for (final m in _mataAnggaran)
          Tekan(
            onTap: () => _pilih(() => _ma = m.$1),
            dipilih: _ma == m.$1,
            radius: 12,
            child: Container(
              constraints: const BoxConstraints(minHeight: 52),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: ShapeDecoration(
                color: _ma == m.$1 ? c.lautLembut : c.permukaan,
                shape: _ma == m.$1
                    ? GarisBorder.penuh(c.laut, radius: 12)
                    : GarisBorder.penuh(c.garisTegas, tebal: 1, radius: 12),
              ),
              child: Row(
                children: [
                  Text(
                    m.$1,
                    style: TextStyle(
                      fontFamily: PalakatText.mono,
                      fontSize: 13,
                      color: c.tinta2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      m.$2,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ]),
    );
  }

  Widget _barisDokumen(BuildContext context, _Cfg k) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.garis)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dokumen pendukung · ${k.dok}',
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
                Text(
                  'Wajib, belum ada',
                  style: TextStyle(fontWeight: FontWeight.w700, color: c.bata),
                ),
                Text(
                  'Tidak menghalangi pembukuan. Menghalangi tutup buku.',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Tautan(
            ke: Layar.dokumen,
            radius: 12,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                shape: GarisBorder.penuh(c.tinta, radius: 12),
              ),
              child: Text(
                'Lampirkan',
                style: TextStyle(fontWeight: FontWeight.w700, color: c.tinta),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuEfek(BuildContext context) {
    final c = context.warna;
    final k = _k, j = _j;
    final um = _tab == 'um', tt = _tab == 'tt', pb = _tab == 'pb';
    final ak = _akun == null ? null : kasusBaruKasBank[_akun!];
    final nama = _pihak.text.trim().isEmpty ? '…' : _pihak.text.trim();
    final saldo = 'Saldo buku ${ak?.$1 ?? 'Kas/Bank'}';
    final efek = <(String, String, String)>[
      if (um) ...[
        (
          saldo,
          ak == null
              ? 'pilih Kas/Bank'
              : 'dari ${rp(ak.$2)} menjadi ${rp(ak.$2 - j)}',
          j != 0 ? rp(-j) : '—',
        ),
        (k.sisa, 'atas nama $nama', j != 0 ? rp(j) : '—'),
        (
          'Belanja bulan ini',
          'belum ada Belanja sampai dipertanggungjawabkan',
          'tidak berubah',
        ),
      ],
      if (tt) ...[
        (
          saldo,
          ak == null
              ? 'pilih Kas/Bank'
              : 'dari ${rp(ak.$2)} menjadi ${rp(ak.$2 + j)}',
          j != 0 ? '+${rp(j)}' : '—',
        ),
        (k.sisa, 'Titipan untuk: $nama', j != 0 ? rp(j) : '—'),
        ('Pendapatan bulan ini', 'titipan dihitung terpisah', 'tidak berubah'),
      ],
      if (pb) ...[
        (
          'Saldo buku semua Kas/Bank',
          'klaim belum masuk saldo',
          'tidak berubah',
        ),
        (k.sisa, 'Dibayar kepada: $nama', j != 0 ? rp(j) : '—'),
        (
          'Belanja bulan ini',
          'dicatat satu kali, saat klaim dibayar',
          'tidak berubah',
        ),
      ],
    ];
    final padat = _selesai && !pb;
    final judul = _selesai
        ? (pb ? 'Tersimpan · belum masuk saldo' : 'Dibukukan')
        : 'Setelah ${pb ? 'disimpan' : 'dibukukan'}';

    final isi = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _sela(8, [
        Row(
          children: [
            if (padat)
              Text(judul, style: const TextStyle(fontWeight: FontWeight.w700))
            else
              Flexible(
                child: Text(
                  judul,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            if (padat) ...[
              const SizedBox(width: 16),
              // The stamp shrinks (and wraps) before the title does.
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Gerak(
                    Kerangka.muncul,
                    key: ValueKey('no$_tab'),
                    lama: const Duration(milliseconds: 400),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: ShapeDecoration(
                        shape: GarisBorder.penuh(c.laut, tebal: 2, radius: 8),
                      ),
                      child: Text(
                        'No. Bukti ${k.no}',
                        style: TextStyle(
                          fontFamily: PalakatText.mono,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.laut,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        for (var i = 0; i < efek.length; i++)
          _BarisEfek(efek[i], garisAtas: i > 0),
      ]),
    );

    // `transition: background .3s` (ease); the line swaps at once.
    return TweenAnimationBuilder<double>(
      tween: Tween(end: padat ? 1 : 0),
      duration: context.gerak(const Duration(milliseconds: 300)),
      curve: Curves.ease,
      builder: (context, v, child) => Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: c.permukaan.withValues(alpha: v),
          shape: padat
              ? GarisBorder.penuh(c.tinta, radius: 16)
              : GarisBorder.putus(c.putus, radius: 16),
        ),
        child: child,
      ),
      child: isi,
    );
  }

  Widget _hasil(BuildContext context) {
    final c = context.warna;
    final k = _k;
    final pb = _tab == 'pb';
    final nama = _pihak.text.trim().isEmpty ? '…' : _pihak.text.trim();
    final st =
        k.st +
        (_tab == 'um' && _tempoPilih != null
            ? ' · jatuh tempo: $_tempoPilih'
            : '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _sela(10, [
        Semantics(
          container: true,
          liveRegion: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                k.hasil,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(k.hasilCat, style: TextStyle(fontSize: 14, color: c.tinta2)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: ShapeDecoration(
            color: pb ? null : c.permukaan,
            shape: pb
                ? GarisBorder.putus(c.putus, radius: 14)
                : GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _sela(6, [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _ur.text.trim(),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    rp(_j),
                    style: const TextStyle(
                      fontFamily: PalakatText.mono,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '${k.pihak}: $nama',
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
              Container(
                height: 8,
                decoration: ShapeDecoration(
                  shape: GarisBorder.putus(c.putus, radius: 4),
                ),
              ),
              Text(
                st,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ]),
          ),
        ),
        const Tombol(
          'Buka di Uang yang masih berjalan',
          onPressed: null,
          jenis: JenisTombol.kedua,
          ukuran: UkuranTombol.sedang,
          ke: Layar.kewajiban,
          cara: Cara.naik,
        ),
        Tombol(
          'Catat kasus lain',
          onPressed: () => _kosongkan(_tab),
          jenis: JenisTombol.teks,
        ),
      ]),
    );
  }
}

/// A board field with a "{label} **· wajib**" label 6 px above it; the
/// label is a `<label for>`, so pressing it focuses the field.
class _IsianWajib extends StatefulWidget {
  const _IsianWajib({
    required this.label,
    required this.controller,
    required this.onChanged,
    required this.hanyaBaca,
    this.petunjuk,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool hanyaBaca;
  final String? petunjuk;

  @override
  State<_IsianWajib> createState() => _IsianWajibState();
}

class _IsianWajibState extends State<_IsianWajib> {
  final _fokus = FocusNode();

  @override
  void dispose() {
    _fokus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final w = widget;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: GestureDetector(
            onTap: _fokus.requestFocus,
            child: Text.rich(
              TextSpan(
                text: '${w.label} ',
                children: [
                  TextSpan(
                    text: '· wajib',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: c.tinta,
                    ),
                  ),
                ],
              ),
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ),
        ),
        const SizedBox(height: 6),
        IsianTeks(
          controller: w.controller,
          focusNode: _fokus,
          labelSemantik: '${w.label} · wajib',
          petunjuk: w.petunjuk,
          onChanged: w.onChanged,
          hanyaBaca: w.hanyaBaca,
        ),
      ],
    );
  }
}

/// One effect row: name 600/15 over sub 13 `tinta3` | value 15/500.
class _BarisEfek extends StatelessWidget {
  const _BarisEfek(this.e, {required this.garisAtas});
  final (String, String, String) e;
  final bool garisAtas;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final tetap = e.$3 == 'tidak berubah';
    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: garisAtas
          ? BoxDecoration(
              border: Border(top: BorderSide(color: c.garis)),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.$1,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(e.$2, style: TextStyle(fontSize: 13, color: c.tinta3)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            e.$3,
            style: TextStyle(
              fontFamily: tetap ? null : PalakatText.mono,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: tetap ? c.tinta3 : c.tinta,
            ),
          ),
        ],
      ),
    );
  }
}

/// CSS `gap`: [jarak] between the children.
List<Widget> _sela(double jarak, List<Widget> anak) => [
  for (var i = 0; i < anak.length; i++) ...[
    if (i > 0) SizedBox(height: jarak),
    anak[i],
  ],
];
