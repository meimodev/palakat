import 'package:flutter/material.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

const _nama = [
  'Ditampung',
  'Lolos pengecekan',
  'Sudah diperiksa',
  'Sudah diimpor',
];

enum _Jenis { ok, ganda, tolak }

/// kas-november.xlsx as the web board reads it (06-bukti.md, WebImpor).
const _baris = <({String asli, String ur, String baca, String ma, _Jenis j})>[
  (
    asli: '02/11/26\nPersembahan Mgg\n3.100.000',
    ur: 'Persembahan Ibadah Minggu',
    baca: '02/11/2026 · Kas · Rp3.100.000 masuk',
    ma: 'Pendapatan 1.3.53.07.00 Persembahan Ibadah Minggu',
    j: _Jenis.ok,
  ),
  (
    asli: '04/11/26\nBayar PLN\n-1250000',
    ur: 'Bayar PLN',
    baca: '04/11/2026 · Bank BNI ··4821 · Rp1.250.000 keluar',
    ma: 'Belanja 5.01.02.00 Listrik, air dan telepon',
    j: _Jenis.ok,
  ),
  (
    asli: '4 Nop\nPLN nov\n1.250.000,-',
    ur: 'PLN nov',
    baca: '04/11/2026 · Bank BNI ··4821 · Rp1.250.000 keluar',
    ma: 'Belanja 5.01.02.00 Listrik, air dan telepon',
    j: _Jenis.ganda,
  ),
  (
    asli: '08/11/26\nHonor pemusik\n650rb',
    ur: 'Honor pemusik',
    baca: '08/11/2026 · Kas · Rp650.000 keluar',
    ma: '',
    j: _Jenis.ok,
  ),
  (
    asli: '31/11/26\nATK\n85.000',
    ur: 'ATK',
    baca: 'Tanggal tidak terbaca · Kas · Rp85.000 keluar',
    ma: 'Belanja 5.02.01.00 Alat tulis dan fotokopi',
    j: _Jenis.tolak,
  ),
];

const _kolom = [12, 13, 11, 12];

class WebImporScreen extends StatefulWidget {
  const WebImporScreen({super.key});

  @override
  State<WebImporScreen> createState() => _WebImporScreenState();
}

class _WebImporScreenState extends State<WebImporScreen> {
  int _st = 0;

  /// '' | 'tetap' | 'tidak'.
  String _ganda = '';

  bool get _tunggu => _st == 1 && _ganda.isEmpty;

  String get _ket => switch (_st) {
    0 =>
      'Nilai asli dan hasil bacaannya ditampilkan berdampingan. '
          'Belum ada yang masuk saldo.',
    1 =>
      _tunggu
          ? 'Putuskan dulu baris yang mungkin ganda.'
          : 'Pengecekan selesai. Baca sekali lagi sebelum menandai sudah '
                'diperiksa.',
    2 =>
      'Sudah diperiksa. Impor mencatat baris yang lolos; baris tanpa Mata '
          'Anggaran masuk sebagai transaksi dengan Mata Anggaran belum '
          'dipilih.',
    _ =>
      '${_ganda == 'tetap' ? 4 : 3} baris sudah diimpor · '
          '${_ganda == 'tetap' ? 1 : 2} tidak diimpor. No. bukti asal dari '
          'file ditampilkan terpisah dari No. Bukti.',
  };

  void _maju() {
    if (!_tunggu) setState(() => _st = (_st + 1).clamp(0, 3));
  }

  /// Max-content width of [teks] in body 15 + [gaya] (the flex basis of an
  /// auto item); the State context sits above the page DefaultTextStyle.
  double _lebarTeks(BuildContext context, String teks, TextStyle gaya) {
    final p = TextPainter(
      text: TextSpan(text: teks, style: PalakatText.isiWeb.merge(gaya)),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final w = p.width;
    p.dispose();
    return w;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        jabatanKosong: true,
        nav: const NavSamping(
          item: navKeuangan,
          aktif: 1,
          pengguna: PenggunaKeuangan(),
        ),
        isi: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 44 px target over a 14 × 1.45 line: the extra height overlaps.
              MarginNegatif(
                atas: 11.85,
                bawah: 11.85,
                child: Tautan(
                  ke: 'WebTransaksi',
                  cara: Cara.naik,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1,
                    child: TautanTeks('Transaksi', ukuran: 14),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Semantics(
                header: true,
                child: Text.rich(
                  TextSpan(
                    text: 'Impor ',
                    children: [
                      TextSpan(
                        text: '· kas-november.xlsx · 5 baris',
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
            ],
          ),
          _panel(context),
          _tabel(context),
          Text(
            'Baris yang masih ditampung belum masuk saldo dan menjadi hambatan '
            'tutup buku bulannya. Baris yang tidak diimpor tetap disimpan '
            'bersama alasannya.',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
        ],
      ),
    );
  }

  Widget _panel(BuildContext context) {
    final c = context.warna;
    const gayaChip = TextStyle(fontSize: 13, fontWeight: FontWeight.w700);
    final label = [for (var i = 0; i < 4; i++) '${i + 1} · ${_nama[i]}'];
    // Chips: padding 0 12 inside a 1.5 line; group gap 6.
    final lebarChip = label.fold<double>(
      18,
      (s, t) => s + _lebarTeks(context, t, gayaChip) + 27,
    );
    final teksTombol = const [
      'Jalankan pengecekan',
      'Tandai sudah diperiksa',
      'Impor',
    ][_st.clamp(0, 2)];
    final lebarTombol =
        _lebarTeks(
          context,
          teksTombol,
          const TextStyle(fontWeight: FontWeight.w700),
        ) +
        40;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: ShapeDecoration(
        color: _st == 3 ? c.permukaan : null,
        shape: _st == 3
            ? GarisBorder.penuh(c.tinta, radius: 16)
            : GarisBorder.putus(c.putus, radius: 16),
      ),
      child: _barisPanel([
        Lentur(
          dasar: lebarChip + 1,
          tumbuh: 0,
          child: Semantics(
            container: true,
            label: 'Langkah ${_st + 1} dari 4: ${label.join(', ')}',
            child: ExcludeSemantics(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (var i = 0; i < 4; i++)
                    Container(
                      // span content-box: min-height 32 plus the line.
                      constraints: const BoxConstraints(minHeight: 35),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: ShapeDecoration(
                        color: i <= _st ? c.tinta : null,
                        shape: i <= _st
                            ? GarisBorder.penuh(c.tinta, radius: 999)
                            : GarisBorder.putus(c.putus, radius: 999),
                      ),
                      child: Center(
                        widthFactor: 1,
                        heightFactor: 1,
                        child: Text(
                          label[i],
                          style: gayaChip.copyWith(
                            color: i <= _st ? c.permukaan : c.tinta3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Lentur(
          dasar: 280,
          child: Text(_ket, style: TextStyle(fontSize: 14, color: c.tinta2)),
        ),
        if (_st < 3)
          Lentur(
            dasar: lebarTombol + 1,
            tumbuh: 0,
            child: TombolBersyarat(
              label: teksTombol,
              tindakan: 'Tandai sudah diperiksa',
              alasan: _tunggu ? 'Putuskan dulu baris yang mungkin ganda.' : '',
              onPressed: _maju,
              // The board's reason is `ket` beside the button.
              sudahMulai: false,
              warnaSiap: _st == 2 ? JenisTombol.utama : JenisTombol.tinta,
              teksBelumRedup: true,
              tinggi: 46,
              radius: 12,
              paddingH: 20,
            ),
          ),
      ]),
    );
  }

  /// `flex-wrap` of the step panel. Chrome draws the chips' 1.5 lines 1 px
  /// wide at device scale 1, so on the board the three items just fit one
  /// line at 1440 (with `ket` shrinking a little); decide the line with those
  /// widths, then let `ket` take what is left.
  Widget _barisPanel(List<Lentur> anak) => LayoutBuilder(
    builder: (context, k) {
      final satuBaris =
          anak.fold<double>(-24, (s, a) => s + a.dasar + 24) -
              4 -
              anak.length <=
          k.maxWidth;
      if (!satuBaris) {
        return BarisLentur(
          jarak: 24,
          jarakBaris: 12,
          rata: CrossAxisAlignment.center,
          anak: anak,
        );
      }
      return Row(
        children: [
          for (var i = 0; i < anak.length; i++) ...[
            if (i > 0) const SizedBox(width: 24),
            if (anak[i].tumbuh > 0)
              Expanded(child: anak[i].child)
            else
              SizedBox(width: anak[i].dasar, child: anak[i].child),
          ],
        ],
      );
    },
  );

  Widget _baris5(List<Widget> sel) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(width: 50, child: sel[0]),
      for (var i = 1; i < 5; i++) ...[
        const SizedBox(width: 16),
        Expanded(flex: _kolom[i - 1], child: sel[i]),
      ],
    ],
  );

  Widget _tabel(BuildContext context) {
    final c = context.warna;
    final kecil = TextStyle(fontSize: 13, color: c.tinta2);
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: c.permukaan,
        borderRadius: BorderRadius.circular(14),
      ),
      // On top, so the scrolled rows never cover the 1 px line.
      foregroundDecoration: ShapeDecoration(
        shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
      ),
      child: LayoutBuilder(
        builder: (context, k) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: k.maxWidth < 980 ? 980 : k.maxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  child: DefaultTextStyle.merge(
                    style: kecil.copyWith(fontWeight: FontWeight.w600),
                    child: _baris5(const [
                      Text('Baris'),
                      Text('Nilai asli di file'),
                      Text('Dibaca sebagai'),
                      Text('Mata Anggaran'),
                      Text('Hasil'),
                    ]),
                  ),
                ),
                for (var i = 0; i < _baris.length; i++) _barisTabel(context, i),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _barisTabel(BuildContext context, int i) {
    final c = context.warna;
    final d = _baris[i];
    final st = _st;
    final kecil = TextStyle(fontSize: 13, color: c.tinta2);
    var hasil = _nama[st];
    var bentuk = st == 3
        ? BentukLencana.tinta
        : st == 0
        ? BentukLencana.draf
        : BentukLencana.garis;
    var cat = '';
    var pilih = false;
    if (st >= 1 && d.j == _Jenis.tolak) {
      (hasil, bentuk, cat) = (
        'Tidak diimpor',
        BentukLencana.bata,
        'Alasan: tanggal 31/11 tidak ada. Perbaiki di file lalu impor lagi, '
            'atau catat sendiri.',
      );
    }
    if (st >= 1 && d.j == _Jenis.ganda) {
      if (_ganda == 'tidak') {
        (hasil, bentuk, cat) = (
          'Tidak diimpor',
          BentukLencana.garis,
          'Alasan: sama dengan baris 2.',
        );
      } else if (_ganda.isEmpty) {
        (hasil, bentuk, cat, pilih) = (
          'Mungkin ganda',
          BentukLencana.peran,
          'Tanggal, Kas/Bank dan jumlah sama dengan baris 2.',
          st < 3,
        );
      }
    }
    Widget lencana = LencanaStatus(hasil, bentuk: bentuk);
    if (bentuk == BentukLencana.draf) {
      // Web keeps the white field under the dashed line.
      lencana = DecoratedBox(
        decoration: BoxDecoration(
          color: c.permukaan,
          borderRadius: BorderRadius.circular(6),
        ),
        child: lencana,
      );
    }
    Widget keputusan(String label, String nilai) => Tekan(
      onTap: () => setState(() => _ganda = nilai),
      radius: 10,
      child: RupaTombol(
        label: label,
        isi: c.permukaan,
        garis: GarisBorder.penuh(c.tinta, radius: 10),
        warnaTeks: c.tinta,
        radius: 10,
        tinggi: 44,
        paddingH: 12,
        ukuranTeks: 13,
        lebarPenuh: false,
      ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: st == 0 ? c.kertas : c.permukaan,
        border: Border(top: BorderSide(color: c.garis)),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 14),
        child: _baris5([
          Text(
            '${i + 1}',
            style: TextStyle(fontFamily: PalakatText.mono, color: c.tinta2),
          ),
          Text(d.asli, style: kecil.copyWith(fontFamily: PalakatText.mono)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(d.ur, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(d.baca, style: kecil),
            ],
          ),
          Text(
            d.ma.isEmpty ? 'Mata Anggaran belum dipilih' : d.ma,
            style: TextStyle(
              fontSize: 13,
              color: d.ma.isEmpty ? c.bata : c.tinta,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              lencana,
              if (cat.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(cat, style: kecil),
              ],
              if (pilih) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    keputusan('Tetap impor', 'tetap'),
                    keputusan('Tidak diimpor', 'tidak'),
                  ],
                ),
              ],
            ],
          ),
        ]),
      ),
    );
  }
}
