import 'package:flutter/material.dart';

import '../../mock/format.dart';
import '../../mock/mock.dart';
import '../../motion/kerangka.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/input_format.dart';
import '../../widgets/isian_jumlah.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

/// 37 · Kasus baru: Uang Muka, Titipan, Penggantian biaya (spec
/// 10-aifoto.md, KasusBaru).
class KasusBaruScreen extends StatefulWidget {
  const KasusBaruScreen({super.key});

  @override
  State<KasusBaruScreen> createState() => _KasusBaruScreenState();
}

/// The board's `CFG`, one per kind.
typedef _Jenis = ({
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

const Map<String, _Jenis> _cfg = {
  'um': (
    tab: 'Uang Muka',
    pihak: 'Diberikan kepada',
    ph: 'Nama penerima uang muka',
    jm: 'Jumlah uang muka (Rp)',
    akun: 'Diambil dari Kas/Bank',
    ur: 'Untuk keperluan',
    dok: 'Tanda terima uang muka',
    cat:
        'Uang muka bukan Belanja saat diberikan. Mata Anggaran dipilih '
        'nanti, saat pertanggungjawabannya dicatat.',
    tombol: 'Periksa dan bukukan',
    sisa: 'Sisa belum dipertanggungjawabkan',
    st: 'Belum dipertanggungjawabkan',
    no: 'BKU-2026-0153',
    hasil: 'Uang muka dibukukan',
    hasilCat:
        'Kasusnya terbuka sampai seluruh uang dipertanggungjawabkan atau '
        'dikembalikan.',
  ),
  'tt': (
    tab: 'Titipan',
    pihak: 'Titipan untuk',
    ph: 'Contoh: Sinode',
    jm: 'Jumlah diterima (Rp)',
    akun: 'Masuk ke Kas/Bank',
    ur: 'Uraian',
    dok: 'Bukti penerimaan titipan',
    cat:
        'Uang titipan untuk pihak lain. Bukan Pendapatan saat diterima, dan '
        'bukan Belanja saat disalurkan.',
    tombol: 'Periksa dan bukukan',
    sisa: 'Sisa belum disalurkan',
    st: 'Belum disalurkan',
    no: 'BKU-2026-0154',
    hasil: 'Titipan dibukukan',
    hasilCat:
        'Kasusnya terbuka sampai seluruh titipan disalurkan kepada yang '
        'berhak.',
  ),
  'pb': (
    tab: 'Penggantian biaya',
    pihak: 'Dibayar kepada',
    ph: 'Nama yang mengajukan klaim',
    jm: 'Jumlah klaim (Rp)',
    akun: '',
    ur: 'Yang dibeli',
    dok: 'Nota atau kuitansi',
    cat:
        'Mencatat dan mengecek klaim tidak mengubah saldo. Pembayarannya '
        'mencatat Belanja satu kali.',
    tombol: 'Simpan klaim',
    sisa: 'Belum dibayar',
    st: 'Belum dibayar · klaim belum dicek',
    no: '',
    hasil: 'Klaim disimpan · belum masuk saldo',
    hasilCat:
        'Cek klaim lebih dulu, lalu bayar. Mata Anggaran dipilih saat '
        'pembayaran.',
  ),
};

const _tempoId = ['30/11/2026', '15/12/2026', '31/12/2026'];
const _peruntukan = ['Umum Jemaat', 'Diakonia', 'Pembangunan'];
const _lingkup = ['Jemaat', 'Kolom 3', 'BIPRA Pemuda', 'Panitia Natal'];
const _mataAnggaran = [
  ('2.1.01.02.00', 'Sentralisasi Sinode'),
  ('2.2.01.02.00', 'Persembahan khusus Wilayah'),
];

class _KasusBaruScreenState extends State<KasusBaruScreen> {
  String _tab = 'um';
  final _pihak = TextEditingController();
  final _jm = TextEditingController();
  final _ur = TextEditingController();
  int? _akun;
  String? _per, _ling, _ma, _tempo;
  bool _selesai = false;

  _Jenis get _k => _cfg[_tab]!;
  bool get _um => _tab == 'um';
  bool get _tt => _tab == 'tt';
  bool get _pb => _tab == 'pb';
  int get _j => angkaDari(_jm.text) ?? 0;
  (String, int)? get _ak => _akun == null ? null : kasusBaruKasBank[_akun!];

  /// The board's `alasan`: the first unmet reason, '' when met.
  String _alasan() {
    final ak = _ak;
    if (_pihak.text.trim().isEmpty) return '“${_k.pihak}” belum diisi.';
    if (_j <= 0) return 'jumlah belum diisi.';
    if (!_pb && ak == null) return 'Kas/Bank belum dipilih.';
    if (_um && _j > ak!.$2) {
      return 'melebihi saldo buku ${ak.$1} (${rp(ak.$2)}).';
    }
    if (_um && _per == null) return 'peruntukan belum dipilih.';
    if (_um && _ling == null) return 'Lingkup belum dipilih.';
    if (_tt && _ma == null) return 'Mata Anggaran belum dipilih.';
    if (_ur.text.trim().isEmpty) return 'uraian belum diisi.';
    if (_um && _tempo == null) return 'jatuh tempo belum dipilih.';
    return '';
  }

  void _kosongkan() {
    _pihak.clear();
    _jm.clear();
    _ur.clear();
    _akun = null;
    _per = _ling = _ma = _tempo = null;
    _selesai = false;
  }

  void _pilih(VoidCallback f) {
    if (_selesai) return;
    setState(f);
  }

  @override
  void dispose() {
    _pihak.dispose();
    _jm.dispose();
    _ur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final k = _k, j = _j, ak = _ak;
    final alasan = _alasan();
    final nama = _pihak.text.trim().isEmpty ? '…' : _pihak.text.trim();
    final padat = _selesai && !_pb;

    final saldo = 'Saldo buku ${ak?.$1 ?? 'Kas/Bank'}';
    final efek = _um
        ? [
            (
              n: saldo,
              s: ak == null
                  ? 'pilih Kas/Bank'
                  : 'dari ${rp(ak.$2)} menjadi ${rp(ak.$2 - j)}',
              rp: j != 0 ? rp(-j) : '—',
            ),
            (n: k.sisa, s: 'atas nama $nama', rp: j != 0 ? rp(j) : '—'),
            (
              n: 'Belanja bulan ini',
              s: 'belum ada Belanja sampai dipertanggungjawabkan',
              rp: 'tidak berubah',
            ),
          ]
        : _tt
        ? [
            (
              n: saldo,
              s: ak == null
                  ? 'pilih Kas/Bank'
                  : 'dari ${rp(ak.$2)} menjadi ${rp(ak.$2 + j)}',
              rp: j != 0 ? '+${rp(j)}' : '—',
            ),
            (n: k.sisa, s: 'Titipan untuk: $nama', rp: j != 0 ? rp(j) : '—'),
            (
              n: 'Pendapatan bulan ini',
              s: 'titipan dihitung terpisah',
              rp: 'tidak berubah',
            ),
          ]
        : [
            (
              n: 'Saldo buku semua Kas/Bank',
              s: 'klaim belum masuk saldo',
              rp: 'tidak berubah',
            ),
            (n: k.sisa, s: 'Dibayar kepada: $nama', rp: j != 0 ? rp(j) : '—'),
            (
              n: 'Belanja bulan ini',
              s: 'dicatat satu kali, saat klaim dibayar',
              rp: 'tidak berubah',
            ),
          ];

    Widget label(String teks, {bool wajib = false}) => Text.rich(
      TextSpan(
        text: teks,
        children: [
          if (wajib)
            TextSpan(
              text: ' · wajib',
              style: TextStyle(fontWeight: FontWeight.w700, color: c.tinta),
            ),
        ],
      ),
      style: TextStyle(fontSize: 14, color: c.tinta2),
    );

    Widget isian(String l, TextEditingController ctl, {String? petunjuk}) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExcludeSemantics(child: label(l, wajib: true)),
            const SizedBox(height: 6),
            IsianTeks(
              controller: ctl,
              labelSemantik: '$l · wajib',
              petunjuk: petunjuk,
              onChanged: (_) => _pilih(() {}),
            ),
          ],
        );

    Widget chips<T>(
      String l,
      List<({T nilai, String teks})> p,
      T? t,
      void Function(T) set,
    ) => ChipPilihan<T>(
      label: l,
      pilihan: p,
      terpilih: t,
      onPilih: (v) => _pilih(() => set(v)),
    );

    final form = <Widget>[
      Text(k.cat, style: TextStyle(fontSize: 14, color: c.tinta2)),
      isian(k.pihak, _pihak, petunjuk: k.ph),
      IsianJumlah(
        label: k.jm,
        controller: _jm,
        onChanged: (_) => _pilih(() {}),
      ),
      if (!_pb)
        chips<int>(
          k.akun,
          [
            for (final (i, a) in kasusBaruKasBank.indexed)
              (nilai: i, teks: a.$1),
          ],
          _akun,
          (v) => _akun = v,
        ),
      if (_um) ...[
        chips<String>(
          'Diambil dari peruntukan',
          [for (final p in _peruntukan) (nilai: p, teks: p)],
          _per,
          (v) => _per = v,
        ),
        chips<String>(
          'Lingkup',
          [for (final p in _lingkup) (nilai: p, teks: p)],
          _ling,
          (v) => _ling = v,
        ),
      ],
      if (_tt)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Mata Anggaran · hanya baris yang boleh untuk Titipan',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            for (final m in _mataAnggaran) ...[
              const SizedBox(height: 8),
              Tekan(
                onTap: () => _pilih(() => _ma = m.$1),
                dipilih: _ma == m.$1,
                radius: 12,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 52),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
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
            ],
          ],
        ),
      isian(k.ur, _ur),
      if (_um)
        chips<String>(
          'Jatuh tempo',
          [
            for (final (i, t) in kasusBaruJatuhTempo.indexed)
              (nilai: _tempoId[i], teks: t),
          ],
          _tempo,
          (v) => _tempo = v,
        ),
      Container(
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
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: c.bata,
                    ),
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
              ke: 'Kamera',
              radius: 12,
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  shape: GarisBorder.penuh(c.tinta, radius: 12),
                ),
                child: const Text(
                  'Lampirkan',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    ];

    final kartuEfek = TweenAnimationBuilder<Color?>(
      tween: ColorTween(
        end: padat ? c.permukaan : c.permukaan.withValues(alpha: 0),
      ),
      duration: context.gerak(const Duration(milliseconds: 300)),
      curve: Curves.ease,
      builder: (context, isi, child) => Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: isi,
          shape: padat
              ? GarisBorder.penuh(c.tinta, radius: 16)
              : GarisBorder.putus(c.putus, radius: 16),
        ),
        child: child,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // CSS never breaks "Dibukukan" mid-word (min-content); the
              // stamp gives way first.
              Flexible(
                fit: padat ? FlexFit.tight : FlexFit.loose,
                flex: padat ? 0 : 1,
                child: Text(
                  _selesai
                      ? (_pb ? 'Tersimpan · belum masuk saldo' : 'Dibukukan')
                      : 'Setelah ${_pb ? 'disimpan' : 'dibukukan'}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              if (padat) ...[
                const SizedBox(width: 16),
                Flexible(
                  child: Gerak(
                    Kerangka.muncul,
                    key: ValueKey('no-$_tab'),
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
              ],
            ],
          ),
          for (final (i, e) in efek.indexed) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: i > 0 ? Border(top: BorderSide(color: c.garis)) : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.n,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          e.s,
                          style: TextStyle(fontSize: 13, color: c.tinta3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    e.rp,
                    style: e.rp == 'tidak berubah'
                        ? TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: c.tinta3,
                          )
                        : TextStyle(
                            fontFamily: PalakatText.mono,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: c.tinta,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    final hasil = Gerak(
      Kerangka.muncul,
      key: ValueKey('hasil-$_tab'),
      lama: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            container: true,
            liveRegion: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  k.hasil,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                Text(
                  k.hasilCat,
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: ShapeDecoration(
              color: _pb ? null : c.permukaan,
              shape: _pb
                  ? GarisBorder.putus(c.putus, radius: 14)
                  : GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        _ur.text.trim(),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      rp(j),
                      style: const TextStyle(
                        fontFamily: PalakatText.mono,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${k.pihak}: $nama',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 8,
                  decoration: ShapeDecoration(
                    shape: GarisBorder.putus(c.putus, radius: 4),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${k.st}${_um && _tempo != null ? ' · jatuh tempo: $_tempo' : ''}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Tombol(
            'Buka di Uang yang masih berjalan',
            onPressed: null,
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.sedang,
            paddingH: 0,
            ke: 'Kewajiban',
            cara: Cara.naik,
          ),
          const SizedBox(height: 10),
          Tombol(
            'Catat kasus lain',
            onPressed: () => setState(_kosongkan),
            jenis: JenisTombol.teks,
          ),
        ],
      ),
    );

    final gulir = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, w) in [
            if (!_selesai) ...form,
            kartuEfek,
            if (_selesai) hasil,
          ].indexed) ...[if (i > 0) const SizedBox(height: 16), w],
        ],
      ),
    );

    return LayarPonsel(
      jabatanKosong: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Kasus baru',
            anakJudul: 'Uang yang masih berjalan',
            kembaliKe: 'Kewajiban',
            labelKembali: 'Kembali ke Uang yang masih berjalan',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: ChipPilihan<String>(
              pilihan: [
                for (final t in _cfg.keys) (nilai: t, teks: _cfg[t]!.tab),
              ],
              terpilih: _tab,
              onPilih: (t) => setState(() {
                _kosongkan();
                _tab = t;
              }),
            ),
          ),
          Expanded(child: gulir),
          if (!_selesai)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
              decoration: BoxDecoration(
                color: c.permukaan,
                border: Border(top: BorderSide(color: c.garis)),
              ),
              child: TombolBersyarat(
                label: k.tombol,
                tindakan: k.tombol,
                alasan: alasan,
                periksa: _alasan,
                onPressed: () => setState(() => _selesai = true),
                warnaSiap: JenisTombol.utama,
                teksBelumRedup: true,
                gayaAlasan: GayaAlasan.pendamping,
                paddingH: 20,
              ),
            ),
        ],
      ),
    );
  }
}
