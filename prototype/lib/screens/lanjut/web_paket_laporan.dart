import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../mock/format.dart';
import '../../mock/mock.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/pita_laporan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';

part 'web_paket_laporan_data.dart';

const _stem = 'WebPaketLaporan';
const _f02Kolom = <double?>[78, 104, 104, null, 100, 100, 104];

/// Web · Paket Laporan F01–F14 (spec 05-kewajiban.md). One view; state
/// `pilih` (the selected report), tweak `salinan` (full or TERBATAS copy).
class WebPaketLaporanScreen extends StatefulWidget {
  const WebPaketLaporanScreen({super.key});

  @override
  State<WebPaketLaporanScreen> createState() => _WebPaketLaporanScreenState();
}

class _WebPaketLaporanScreenState extends State<WebPaketLaporanScreen> {
  String _pilih = 'F02';

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final terbatas =
        context.tweak<String>(_stem, 'salinan') != 'Seluruh Jemaat';
    final cap = terbatas ? ' · TERBATAS · Peruntukan Diakonia' : '';
    final p = _daftarLaporan.firstWhere((f) => f.$1 == _pilih);
    final isi = p.$1 == 'F02' && terbatas ? _isiF02Terbatas : p.$3;

    return HalamanWeb(
      jabatanKosong: true,
      nav: const NavSamping(
        item: navKeuangan,
        aktif: 5,
        pengguna: PenggunaKeuangan(),
      ),
      isi: [
        _Judul(),
        DeretTautan(
          web: true,
          anak: const [
            _TautanDeret(
              teks: 'Persetujuan format laporan',
              ke: 'WebFormatLaporan',
            ),
            _TautanDeret(teks: 'Celah nomor', ke: 'WebBukti'),
            _TautanDeret(teks: 'Halaman A4', ke: 'A4F01'),
            _TautanDeret(
              teks: 'Lihat transaksi di balik sebuah angka',
              ke: 'WebLihatTransaksi',
            ),
          ],
        ),
        PitaLaporan.resmi(
          judul: 'Laporan resmi$cap',
          dibekukan: '16/11/2026 11.05',
          idSalinan: 'SNP-2026-10-01',
          versi: '2026.1',
          sebaris: true,
        ),
        BarisLentur(
          jarak: 24,
          anak: [
            // CSS flex-basis is the content box: + padding and border.
            Lentur(dasar: 216 + 14, child: _daftar(c)),
            Lentur(
              dasar: 620 + 2 * context.jepit(18, 2, 28) + 3,
              tumbuh: 999,
              child: _halaman(context, p.$1, p.$2, isi, cap, terbatas),
            ),
          ],
        ),
      ],
    );
  }

  Widget _daftar(PalakatWarna c) => Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: c.permukaan,
      border: Border.all(color: c.garis),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final f in _daftarLaporan)
          Tekan(
            onTap: () => setState(() => _pilih = f.$1),
            dipilih: _pilih == f.$1,
            radius: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: _pilih == f.$1 ? c.tinta : null,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  fontSize: 14,
                  color: _pilih == f.$1 ? c.permukaan : c.tinta,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      f.$1,
                      style: const TextStyle(
                        fontFamily: PalakatText.mono,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        f.$2,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );

  Widget _halaman(
    BuildContext context,
    String kode,
    String nama,
    String isi,
    String cap,
    bool terbatas,
  ) {
    final c = context.warna;
    final kecil = TextStyle(fontSize: 13, color: c.tinta3);
    final kepala = Container(
      padding: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.tinta, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '$kode · LAPORAN RESMI$cap',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.tinta2,
              letterSpacing: .4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            nama.toUpperCase(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: .2,
            ),
          ),
          const SizedBox(height: 2),
          const Text('Jemaat Karunia · Periode laporan 1–31 Oktober 2026'),
          const SizedBox(height: 2),
          Text('Format bawaan aplikasi. $isi', style: kecil),
        ],
      ),
    );

    final List<Widget> badan;
    if (kode == 'F01') {
      badan = [
        const Align(
          alignment: Alignment.centerLeft,
          // Board `<a>` is content-box: 44 + 1.5 px lines = 47.
          child: SizedBox(
            height: 47,
            child: Tombol(
              'Buka halaman F01',
              onPressed: null,
              ke: 'WebLaporan',
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.kecil,
              paddingH: 18,
              lebarPenuh: false,
            ),
          ),
        ),
      ];
    } else if (kode == 'F02') {
      badan = [
        _bku(context, terbatas),
        Text(
          'Pembayaran yang dibagi tampil satu kali dengan daftar No. MA-nya. Pembalikan tampil sebagai angka negatif dan tidak dipotong ke nol. Kolom saldo selalu menyebut Kas/Bank yang dijumlahkannya. Setiap No. Bukti membuka transaksinya.',
          style: kecil,
        ),
      ];
    } else {
      final lap = terbatas ? _lapTerbatas[kode] : _lap[kode];
      badan = lap == null
          ? [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: ShapeDecoration(
                  shape: GarisBorder.putus(c.putus, radius: 12),
                ),
                child: Text(
                  'Laporan ini tidak termasuk salinan TERBATAS. Akses terbatas tidak melihat posisi Kas/Bank, rekening koran, titipan pihak lain, atau daftar yang mencakup seluruh Jemaat. Salinan terbatas memuat F02, F03, F05, F07 dan F12, masing-masing hanya bagian peruntukan Diakonia.',
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
              ),
            ]
          : [
              Text(
                lap.sub,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              _tabel(context, lap),
              Text(lap.kaki, style: kecil),
            ];
    }

    final ruang = context.jepit(18, 2, 28);
    return Container(
      padding: EdgeInsets.all(ruang),
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.tinta, width: 1.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          kepala,
          for (final b in badan) ...[const SizedBox(height: 18), b],
        ],
      ),
    );
  }

  /// F02 Buku Kas Umum; the running balance is summed as the board does.
  Widget _bku(BuildContext context, bool terbatas) {
    final c = context.warna;
    final mono = const TextStyle(fontFamily: PalakatText.mono);
    final rows = terbatas
        ? [
            for (final r in _bkuTerbatas)
              (r.$1, r.$2, r.$3, r.$4, null, '', r.$5, r.$6),
          ]
        : [
            for (final t in f02Oktober)
              (
                t.tanggal ?? '',
                t.noBukti ?? '',
                t.kodeMA ?? '',
                t.uraian,
                t.tandaRantai,
                t.kasBank,
                t.masuk,
                t.keluar,
              ),
          ];
    var saldo = terbatas ? 3050000 : 36250000;
    Widget kanan(String s, {bool m = true}) =>
        Text(s, textAlign: TextAlign.right, style: m ? mono : null);

    return _Gulir(
      minLebar: 820,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Sel.baris(c, _f02Kolom, kepala: true, [
            const Text('Tanggal'),
            const Text('No. Bukti'),
            const Text('No. MA'),
            const Text('Uraian · Kas/Bank'),
            kanan('Penerimaan', m: false),
            kanan('Pengeluaran', m: false),
            kanan(
              terbatas ? 'Saldo Diakonia' : 'Saldo semua Kas/Bank',
              m: false,
            ),
          ]),
          DefaultTextStyle.merge(
            style: const TextStyle(fontWeight: FontWeight.w600),
            child: _Sel.baris(c, _f02Kolom, [
              const Text(''),
              const Text(''),
              const Text(''),
              Text(
                terbatas
                    ? 'Saldo awal peruntukan Diakonia'
                    : 'Saldo awal Kas/Bank',
              ),
              const Text(''),
              const Text(''),
              kanan(rp(saldo)),
            ]),
          ),
          for (final r in rows)
            _Sel.baris(c, _f02Kolom, [
              Text(r.$1),
              DefaultTextStyle.merge(style: mono, child: _NoBukti(r.$2)),
              Text(r.$3.isEmpty ? '—' : r.$3, style: mono),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        // Chrome breaks a code after a hyphen between
                        // digits (BKU-2026-|0105); Flutter does not.
                        TextSpan(
                          text: r.$4.replaceAllMapped(
                            RegExp(r'(\d)-(?=\d)'),
                            (m) => '${m[1]}-\u200B',
                          ),
                        ),
                        if (r.$5 != null) ...[
                          const TextSpan(text: ' '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            // white-space: nowrap: may overhang the column;
                            // an inline border does not grow the line box.
                            child: MarginNegatif(
                              atas: 1.5,
                              bawah: 1.5,
                              child: _Menggantung(child: _Tanda(r.$5!)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (r.$6.isNotEmpty)
                    Text(r.$6, style: TextStyle(color: c.tinta3)),
                ],
              ),
              kanan(r.$7 != 0 ? rp(r.$7) : ''),
              kanan(r.$8 != 0 ? rp(r.$8) : ''),
              kanan(rp(saldo += r.$7 - r.$8)),
            ]),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              terbatas
                  ? '2 baris. Jumlah seluruh transaksi, uraian, pelaku dan bagian peruntukan lain tidak ada di salinan ini.'
                  : '31 baris · Saldo akhir Kas/Bank Rp38.465.000',
              style: TextStyle(color: c.tinta3),
            ),
          ),
        ],
      ),
    );
  }

  /// A generic report table: header, rows (bold rows with a `tinta` line).
  Widget _tabel(BuildContext context, _Lap lap) {
    final c = context.warna;
    TextAlign rata(int i) =>
        lap.kanan.contains(i) ? TextAlign.right : TextAlign.left;
    return _Gulir(
      minLebar: lap.minLebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Sel.baris(c, lap.kolom, kepala: true, [
            for (var i = 0; i < lap.judul.length; i++)
              Text(lap.judul[i], textAlign: rata(i)),
          ]),
          for (final b in lap.baris)
            DefaultTextStyle.merge(
              style: TextStyle(
                fontWeight: b.tebal ? FontWeight.w700 : FontWeight.w400,
              ),
              child: _Sel.baris(c, lap.kolom, tebal: b.tebal, [
                for (var i = 0; i < b.sel.length; i++)
                  Text(
                    b.sel[i],
                    textAlign: rata(i),
                    style: lap.mono.contains(i)
                        ? const TextStyle(fontFamily: PalakatText.mono)
                        : null,
                  ),
              ]),
            ),
        ],
      ),
    );
  }
}

/// Title row: h1 (flex 1 1 320) and the two download buttons; wraps.
class _Judul extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final judul = Semantics(
      header: true,
      child: Text.rich(
        TextSpan(
          text: 'Paket Laporan Bulanan GMIM ',
          children: [
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
        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        // CSS line box: a wrapped line holding only the 15 px span keeps
        // the h1's 26 × 1.45 height.
        strutStyle: const StrutStyle(
          fontFamily: PalakatText.sans,
          fontSize: 26,
          height: 1.45,
          leadingDistribution: TextLeadingDistribution.even,
        ),
      ),
    );
    const pdf = Tombol(
      'Unduh PDF',
      onPressed: null,
      ke: 'A4F01',
      ukuran: UkuranTombol.kecil,
      paddingH: 18,
      lebarPenuh: false,
    );
    const excel = Tombol(
      'Unduh Excel',
      onPressed: null,
      ke: 'WebExcel',
      jenis: JenisTombol.kedua,
      ukuran: UkuranTombol.kecil,
      paddingH: 18,
      lebarPenuh: false,
    );
    // flex-wrap with the h1 at basis 320: the buttons join its line while
    // they fit, in order (the button width is its 700 label + 2 × 18).
    final gaya = DefaultTextStyle.of(context).style
        .copyWith(fontWeight: FontWeight.w700);
    double lebar(String s) =>
        (TextPainter(
          text: TextSpan(text: s, style: gaya),
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
        )..layout()).width +
        36;
    final wPdf = lebar('Unduh PDF');
    return LayoutBuilder(
      builder: (context, k) {
        final w = k.maxWidth;
        if (w >= 320 + 12 + wPdf + 12 + lebar('Unduh Excel')) {
          return Row(
            children: [
              Expanded(child: judul),
              const SizedBox(width: 12),
              pdf,
              const SizedBox(width: 12),
              excel,
            ],
          );
        }
        if (w >= 320 + 12 + wPdf) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: judul),
                  const SizedBox(width: 12),
                  pdf,
                ],
              ),
              const SizedBox(height: 12),
              excel,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            judul,
            const SizedBox(height: 12),
            const Wrap(spacing: 12, runSpacing: 12, children: [pdf, excel]),
          ],
        );
      },
    );
  }
}

/// A 14/600 `laut` link of the link row: min 44×44, text centred vertically.
class _TautanDeret extends StatelessWidget {
  const _TautanDeret({required this.teks, required this.ke});
  final String teks, ke;

  @override
  Widget build(BuildContext context) => Tautan(
    ke: ke,
    child: Align(widthFactor: 1, heightFactor: 1, child: TautanTeks(teks)),
  );
}

/// A No. Bukti link in F02 (an inline `<a>` on the board): the 44 px target
/// overhangs the line so the row keeps the board's height.
class _NoBukti extends StatelessWidget {
  const _NoBukti(this.no);
  final String no;

  @override
  Widget build(BuildContext context) {
    final tinggi = 13 * 1.45;
    final lebih = (44 - tinggi) / 2;
    return MarginNegatif(
      atas: lebih,
      bawah: lebih,
      child: Tautan(
        ke: 'WebTransaksi',
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: 1,
          heightFactor: 1,
          child: TautanTeks(no, berat: FontWeight.w400),
        ),
      ),
    );
  }
}

/// F02 chain tag: 13/700, 1.5 `tinta3` edge, `tinta2` text, radius 6.
class _Tanda extends StatelessWidget {
  const _Tanda(this.teks);
  final String teks;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border.all(color: c.tinta3, width: 1.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        teks,
        softWrap: false,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: c.tinta2,
        ),
      ),
    );
  }
}

/// Lays its child out at its natural width and paints it in full, but takes
/// at most the width it is given (CSS `white-space: nowrap` overhang).
class _Menggantung extends SingleChildRenderObjectWidget {
  const _Menggantung({super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderMenggantung();
}

class _RenderMenggantung extends RenderProxyBox {
  @override
  void performLayout() {
    child!.layout(
      BoxConstraints(maxHeight: constraints.maxHeight),
      parentUsesSize: true,
    );
    size = constraints.constrain(child!.size);
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      child!.getDistanceToActualBaseline(baseline);
}

/// `overflow-x: auto` around a table with `min-width`; table text 13.
class _Gulir extends StatelessWidget {
  const _Gulir({required this.minLebar, required this.child});
  final double minLebar;
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, k) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: math.max(minLebar, k.maxWidth),
        child: DefaultTextStyle.merge(
          // CSS splits line-height evenly; mixed fonts on a baseline row
          // would otherwise grow each row.
          style: const TextStyle(
            fontSize: 13,
            leadingDistribution: TextLeadingDistribution.even,
          ),
          child: child,
        ),
      ),
    ),
  );
}

/// One grid row (`grid-template-columns`, gap 10, padding 8 0).
abstract final class _Sel {
  static Widget baris(
    PalakatWarna c,
    List<double?> kolom,
    List<Widget> sel, {
    bool kepala = false,
    bool tebal = false,
  }) {
    final isi = Row(
      crossAxisAlignment: kepala
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        for (var i = 0; i < kolom.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          kolom[i] == null
              ? Expanded(child: sel[i])
              : SizedBox(width: kolom[i], child: sel[i]),
        ],
      ],
    );
    final row = Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: kepala || tebal ? c.tinta : c.garis),
        ),
      ),
      child: isi,
    );
    return kepala
        ? DefaultTextStyle.merge(
            style: const TextStyle(fontWeight: FontWeight.w700),
            child: row,
          )
        : row;
  }
}
