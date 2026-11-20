import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show OverflowBoxFit;

import '../../mock/jabatan_kosong.dart';
import '../../motion/kerangka.dart';
import '../../motion/urutan.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';

/// One Mata Anggaran row of the board's `DATA` (spec 04, WebMataAnggaran).
typedef _Baris = ({String k, String n, bool grup, String tanda});

const Map<String, List<_Baris>> _data = {
  'Belanja': [
    (k: '5.00.00.00', n: 'BELANJA OPERASIONAL', grup: true, tanda: ''),
    (k: '5.01.02.00', n: 'Listrik, air dan telepon', grup: false, tanda: ''),
    (k: '5.03.03.00', n: 'Biaya administrasi bank', grup: false, tanda: ''),
    (
      k: '5.06.01.00',
      n: 'Internet dan langganan aplikasi',
      grup: false,
      tanda: 'Baru',
    ),
    (
      k: '4.03.03.00',
      n: 'Diakonia duka dan sakit',
      grup: false,
      tanda: 'Nama berubah',
    ),
    (
      k: '2.2.01.02.00',
      n: 'DANA TRANSIT Penyaluran Sentralisasi Sinode',
      grup: false,
      tanda: 'Baru',
    ),
  ],
  'Pendapatan': [
    (k: '1.3.53.00.00', n: 'PERSEMBAHAN', grup: true, tanda: ''),
    (k: '1.3.53.07.00', n: 'Persembahan Ibadah Minggu', grup: false, tanda: ''),
    (k: '1.3.53.09.00', n: 'Persembahan syukur', grup: false, tanda: ''),
    (
      k: '2.1.01.02.00',
      n: 'DANA TRANSIT Sentralisasi Sinode',
      grup: false,
      tanda: 'Baru',
    ),
    (k: '1.4.10.02.00', n: 'Sumbangan donatur', grup: false, tanda: ''),
    (k: '1.4.10.03.00', n: 'Sumbangan natura', grup: false, tanda: 'Baru'),
  ],
};

const Map<String, String> _bolehAwal = {
  '5.01.02.00': 'Milik sendiri',
  '5.03.03.00': 'Milik sendiri',
  '5.06.01.00': '',
  '4.03.03.00': 'Milik sendiri',
  '2.2.01.02.00': 'Titipan',
  '1.3.53.07.00': 'Milik sendiri',
  '1.3.53.09.00': 'Milik sendiri',
  '2.1.01.02.00': 'Titipan',
  '1.4.10.02.00': 'Keduanya',
  '1.4.10.03.00': '',
};

const _pilihan = ['Milik sendiri', 'Titipan', 'Keduanya'];
const _tahap = ['Draf', 'Sudah diperiksa', 'Diterbitkan'];
const _urut = ['draf', 'periksa', 'terbit'];

/// Max-content width of one line of [teks] in the page's 15 px sans merged
/// with [gaya]: the CSS `flex: 0 1 auto` basis of a block made of text.
double _lebarTeks(BuildContext context, String teks, TextStyle gaya) {
  final tp = TextPainter(
    text: TextSpan(
      text: teks,
      style: const TextStyle(
        fontFamily: PalakatText.sans,
        fontSize: 15,
      ).merge(gaya),
    ),
    textDirection: TextDirection.ltr,
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();
  final w = tp.width;
  tp.dispose();
  return w.ceilToDouble();
}

class WebMataAnggaranScreen extends StatefulWidget {
  const WebMataAnggaranScreen({super.key});

  @override
  State<WebMataAnggaranScreen> createState() => _WebMataAnggaranScreenState();
}

class _WebMataAnggaranScreenState extends State<WebMataAnggaranScreen> {
  String _st = 'draf', _tab = 'Belanja';
  bool _konfirmasi = false;
  final Map<String, String> _boleh = Map.of(_bolehAwal);

  bool get _terbit => _st == 'terbit';

  void _pick(String k, String o) {
    if (_terbit) return;
    setState(() {
      _boleh[k] = _boleh[k] == o ? '' : o;
      _st = 'draf';
      _konfirmasi = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final jk = context.prototipe.jabatanKosong;
    final kosongN = _boleh.values.where((v) => v.isEmpty).length;
    final vTeks = tukarJkPapan(
      'WebMataAnggaran',
      jk,
      _terbit
          ? 'Berlaku mulai Desember 2026 · diterbitkan oleh Meiske L., 16/11/2026 · tidak dapat diubah'
          : '2 baris baru · 1 nama berubah dibanding versi 2026.1 · usulan berlaku mulai Desember 2026',
    );

    // CSS splits a line's leading evenly above and below the glyphs.
    return DefaultTextHeightBehavior(
      textHeightBehavior: const TextHeightBehavior(
        leadingDistribution: TextLeadingDistribution.even,
      ),
      child: _halaman(context, vTeks, kosongN),
    );
  }

  Widget _halaman(BuildContext context, String vTeks, int kosongN) {
    final c = context.warna;
    return HalamanWeb(
      nav: NavSamping(
        item: navKeuangan,
        aktif: 6,
        pengguna: const PenggunaKeuangan(),
      ),
      jabatanKosong: true,
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 44 px target, drawn in the 21.75 px line the board gives it.
            MarginNegatif(
              bawah: 44 - 15 * 1.45,
              child: Tautan(
                ke: 'WebPengaturan',
                cara: Cara.naik,
                child: const TautanTeks('Pengaturan', ukuran: 14),
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: const Text(
                'Mata Anggaran',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        _kartuVersi(context, vTeks),
        if (_konfirmasi) _panelKonfirmasi(context),
        _barisTab(context, kosongN),
        _tabel(context),
        Text(
          'Contoh 6 dari ${_tab == 'Belanja' ? 158 : 131} baris $_tab. Nomor dan nama ditampilkan persis seperti tersimpan. Hanya baris bertanda “Dapat dibukukan” yang dapat dipilih pada transaksi, tidak ditebak dari akhiran nomornya. Baris tanpa “Boleh untuk” tidak dapat menerima titipan.',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ],
    );
  }

  Widget _kartuVersi(BuildContext context, String vTeks) {
    final c = context.warna;
    final draf = _st == 'draf';
    final ke = _urut.indexOf(_st);
    final lencana = switch (_st) {
      'draf' => LencanaStatus.uang(StatusUang.draf),
      'periksa' => LencanaStatus.uang(StatusUang.sudahDiperiksa),
      _ => const LencanaStatus('Diterbitkan', bentuk: BentukLencana.tinta),
    };

    const gayaTahap = TextStyle(fontSize: 13, fontWeight: FontWeight.w600);
    final lebarTahap =
        [
          for (var i = 0; i < _tahap.length; i++)
            _lebarTeks(context, '${i + 1} · ${_tahap[i]}', gayaTahap) + 27,
        ].fold(0.0, (a, b) => a + b) +
        8 * (_tahap.length - 1);
    Widget chip(int i, String t) => Container(
      // span content-box: min-height 32 plus the 1.5 line twice.
      constraints: const BoxConstraints(minHeight: 35),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: ShapeDecoration(
        color: i <= ke ? c.tinta : null,
        shape: i <= ke
            ? GarisBorder.penuh(c.tinta, radius: 999)
            : GarisBorder.putus(c.putus, radius: 999),
      ),
      // A min-size Row fills the min height and centres the text.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              t,
              style: gayaTahap.copyWith(
                color: i <= ke ? c.permukaan : c.tinta3,
              ),
            ),
          ),
        ],
      ),
    );
    final tahapan = Semantics(
      container: true,
      label:
          'Langkah ${ke + 1} dari 3: '
          '${[for (var i = 0; i < 3; i++) '${i + 1} ${_tahap[i]}'].join(', ')}',
      child: ExcludeSemantics(
        // One nowrap flex row on the board: when it does not fit, each chip
        // shrinks by its width down to its longest word and its text wraps
        // (390 wide). Wraps the chips only where even that would overflow.
        child: LayoutBuilder(
          builder: (context, k) {
            final teks = [
              for (var i = 0; i < _tahap.length; i++) '${i + 1} · ${_tahap[i]}',
            ];
            final maks = [
              for (final t in teks) _lebarTeks(context, t, gayaTahap) + 27,
            ];
            final min = [
              for (final t in teks)
                t
                        .split(' ')
                        .map((w) => _lebarTeks(context, w, gayaTahap))
                        .reduce(math.max) +
                    27,
            ];
            final ruang = k.maxWidth - 8 * (teks.length - 1);
            final jumlahMaks = maks.fold(0.0, (a, b) => a + b);
            final susut = jumlahMaks > ruang;
            if (susut && min.fold(0.0, (a, b) => a + b) > ruang) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < teks.length; i++) chip(i, teks[i]),
                ],
              );
            }
            // flex-shrink by base size, an item clamped at its min-content
            // is frozen and the rest shrinks again.
            final lebar = [...maks];
            final beku = List.filled(teks.length, false);
            while (susut) {
              var tetap = 0.0, dasar = 0.0;
              for (var i = 0; i < teks.length; i++) {
                beku[i] ? tetap += lebar[i] : dasar += maks[i];
              }
              final kurang = tetap + dasar - ruang;
              var langgar = false;
              for (var i = 0; i < teks.length; i++) {
                if (beku[i]) continue;
                lebar[i] = maks[i] - kurang * maks[i] / dasar;
                if (lebar[i] < min[i]) {
                  lebar[i] = min[i];
                  beku[i] = langgar = true;
                }
              }
              if (!langgar) break;
            }
            return Row(
              children: [
                for (var i = 0; i < teks.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  SizedBox(
                    width: lebar[i],
                    child: chip(i, teks[i]),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );

    const gayaTombol = TextStyle(fontWeight: FontWeight.w700);
    final (Widget? tombol, double lebarTombol) = switch (_st) {
      'draf' => (
        Tombol(
          'Tandai sudah diperiksa',
          onPressed: () => setState(() => _st = 'periksa'),
          jenis: JenisTombol.kedua,
          ukuran: UkuranTombol.ringkas,
          lebarPenuh: false,
        ),
        _lebarTeks(context, 'Tandai sudah diperiksa', gayaTombol) + 43,
      ),
      'periksa' when !_konfirmasi => (
        Tombol(
          'Terbitkan',
          onPressed: () => setState(() => _konfirmasi = true),
          ukuran: UkuranTombol.ringkas,
          lebarPenuh: false,
        ),
        _lebarTeks(context, 'Terbitkan', gayaTombol) + 40,
      ),
      _ => (null, 0.0),
    };

    return Container(
      decoration: ShapeDecoration(
        color: draf ? null : c.permukaan,
        shape: draf
            ? GarisBorder.putus(c.putus, radius: 16)
            : GarisBorder.penuh(c.tinta, radius: 16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.5),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: BarisLentur(
                jarak: 28,
                jarakBaris: 14,
                rata: CrossAxisAlignment.center,
                anak: [
                  Lentur(
                    dasar: 260,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Flexible(
                              child: Text(
                                'Versi 2026.2',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            lencana,
                          ],
                        ),
                        Text(
                          vTeks,
                          style: TextStyle(fontSize: 14, color: c.tinta2),
                        ),
                      ],
                    ),
                  ),
                  Lentur(dasar: lebarTahap, tumbuh: 0, child: tahapan),
                  Lentur(
                    dasar: lebarTombol,
                    tumbuh: 0,
                    child: tombol ?? const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            if (_terbit) const SapuTinta(),
          ],
        ),
      ),
    );
  }

  Widget _panelKonfirmasi(BuildContext context) {
    final c = context.warna;
    const gayaTombol = TextStyle(fontWeight: FontWeight.w700);
    const terbitkan = 'Terbitkan, berlaku mulai Desember 2026';
    return Gerak(
      Kerangka.muncul,
      key: const ValueKey('konfirmasi'),
      lama: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: c.tinta,
          borderRadius: BorderRadius.circular(16),
        ),
        child: BarisLentur(
          jarak: 28,
          jarakBaris: 14,
          rata: CrossAxisAlignment.center,
          anak: [
            Lentur(
              dasar: 380,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Versi yang diterbitkan tidak dapat diubah.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: c.permukaan,
                    ),
                  ),
                  Text(
                    'Perubahan berikutnya harus menjadi versi baru. Versi 2026.2 berlaku mulai Desember 2026; transaksi sampai November 2026 tetap memakai versi 2026.1.',
                    style: TextStyle(fontSize: 14, color: c.diTinta),
                  ),
                ],
              ),
            ),
            Lentur(
              dasar: _lebarTeks(context, terbitkan, gayaTombol) + 40,
              tumbuh: 0,
              child: Tekan(
                onTap: () => setState(() {
                  _st = 'terbit';
                  _konfirmasi = false;
                }),
                radius: 12,
                // RupaTombol, but the board's `button{text-align:left}`: the
                // label wraps left-aligned (390 wide).
                child: Container(
                  constraints: const BoxConstraints(minHeight: 46),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: c.permukaan,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1,
                    heightFactor: 1,
                    child: Text(
                      terbitkan,
                      style: gayaTombol.copyWith(color: c.tinta),
                    ),
                  ),
                ),
              ),
            ),
            Lentur(
              dasar: _lebarTeks(context, 'Kembali', gayaTombol) + 24,
              tumbuh: 0,
              child: Tekan(
                onTap: () => setState(() => _konfirmasi = false),
                radius: 12,
                child: RupaTombol(
                  label: 'Kembali',
                  isi: null,
                  warnaTeks: c.permukaan,
                  radius: 12,
                  tinggi: 46,
                  paddingH: 12,
                  lebarPenuh: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barisTab(BuildContext context, int kosongN) {
    final c = context.warna;
    const gayaChip = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
    return BarisLentur(
      jarak: 8,
      rata: CrossAxisAlignment.center,
      anak: [
        for (final t in const ['Belanja', 'Pendapatan'])
          () {
            final teks = '$t · ${t == 'Belanja' ? '158' : '131'} baris';
            return Lentur(
              dasar: _lebarTeks(context, teks, gayaChip) + 35,
              tumbuh: 0,
              child: ChipSatu(
                teks: teks,
                dipilih: _tab == t,
                padding: 16,
                onTap: () => setState(() => _tab = t),
              ),
            );
          }(),
        Lentur(
          dasar: 260,
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              kosongN > 0
                  ? '$kosongN baris belum punya “Boleh untuk” (ditandai garis bata). Diisi atas keputusan Pimpinan Jemaat yang berwenang.'
                  : 'Semua baris contoh sudah punya “Boleh untuk”.',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabel(BuildContext context) {
    final c = context.warna;
    Widget kisi(
      List<Widget> sel, {
      CrossAxisAlignment rata = CrossAxisAlignment.center,
    }) => Row(
      crossAxisAlignment: rata,
      children: [
        SizedBox(width: 170, child: sel[0]),
        const SizedBox(width: 16),
        Expanded(child: sel[1]),
        const SizedBox(width: 16),
        SizedBox(width: 190, child: sel[2]),
        const SizedBox(width: 16),
        SizedBox(width: 330, child: sel[3]),
      ],
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
          builder: (context, k) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: math.max(860, k.maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.tinta2,
                      ),
                      // The header grid stretches its cells: text sits on top.
                      child: kisi(const [
                        Text('No. MA'),
                        Text('Nama Mata Anggaran'),
                        Text('Jenis baris'),
                        Text('Boleh untuk'),
                      ], rata: CrossAxisAlignment.start),
                    ),
                  ),
                  for (final r in _data[_tab]!) _baris(context, r, kisi),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _baris(
    BuildContext context,
    _Baris r,
    Widget Function(List<Widget>, {CrossAxisAlignment rata}) kisi,
  ) {
    final c = context.warna;
    final cur = _boleh[r.k] ?? '';
    final gayaNama = TextStyle(
      fontWeight: r.grup ? FontWeight.w700 : FontWeight.w500,
    );
    final gayaTanda = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      height: 1.25,
      color: c.laut,
    );
    // CSS never breaks inside a word: one wider than the column spills over.
    final lebarKata = [
      for (final w in r.n.split(' ')) _lebarTeks(context, w, gayaNama),
    ].reduce(math.max);
    return Container(
      // content-box min-height 56, plus padding 6 + 6 and the 1 px line.
      constraints: const BoxConstraints(minHeight: 69),
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
      decoration: BoxDecoration(
        color: r.grup ? c.kertas : c.permukaan,
        border: Border(top: BorderSide(color: c.garis)),
      ),
      alignment: Alignment.centerLeft,
      child: kisi([
        Text(
          r.k,
          style: const TextStyle(fontFamily: PalakatText.mono, fontSize: 14),
        ),
        LayoutBuilder(
          builder: (context, k) {
            final nama = Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: r.n, style: gayaNama),
                  if (r.tanda.isNotEmpty) ...[
                    const TextSpan(text: ' '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      // white-space: nowrap; a tag wider than the column
                      // takes a line of its own and spills over it.
                      child: OverflowBox(
                        alignment: Alignment.centerLeft,
                        fit: OverflowBoxFit.deferToChild,
                        minWidth: 0,
                        maxWidth: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 1,
                          ),
                          decoration: ShapeDecoration(
                            shape: GarisBorder.penuh(c.laut, radius: 6),
                          ),
                          child: Text(
                            r.tanda,
                            softWrap: false,
                            style: gayaTanda,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
            if (lebarKata <= k.maxWidth) return nama;
            return OverflowBox(
              alignment: Alignment.topLeft,
              fit: OverflowBoxFit.deferToChild,
              minWidth: 0,
              maxWidth: lebarKata,
              child: nama,
            );
          },
        ),
        Text(
          r.grup ? 'Judul kelompok, tidak dapat dibukukan' : 'Dapat dibukukan',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
        if (r.grup)
          const SizedBox.shrink()
        else
          // A row on the board; the three chips always fit in 330 there.
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final o in _pilihan)
                _ChipBoleh(
                  teks: o,
                  dipilih: cur == o,
                  kosong: cur.isEmpty,
                  onTap: _terbit ? null : () => _pick(r.k, o),
                ),
            ],
          ),
      ]),
    );
  }
}

/// A "Boleh untuk" chip: min height 44, padding 0 12, radius 10, 13/600.
/// Unselected line `garisTegas`, or `bata` while the row has no value.
class _ChipBoleh extends StatelessWidget {
  const _ChipBoleh({
    required this.teks,
    required this.dipilih,
    required this.kosong,
    required this.onTap,
  });

  final String teks;
  final bool dipilih, kosong;

  /// null once published: the board's `disabled`, no visual change.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      dipilih: dipilih,
      radius: 10,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: ShapeDecoration(
          color: dipilih ? c.tinta : c.permukaan,
          shape: GarisBorder.penuh(
            dipilih
                ? c.tinta
                : kosong
                ? c.bata
                : c.garisTegas,
            radius: 10,
          ),
        ),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Text(
            teks,
            softWrap: false,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: dipilih ? c.permukaan : c.tinta,
            ),
          ),
        ),
      ),
    );
  }
}
