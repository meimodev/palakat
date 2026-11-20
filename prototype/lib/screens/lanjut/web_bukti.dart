import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../core/format.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../app/layar.dart';

/// Web · Daftar Bukti Kas dan celah nomor (spec 06-bukti.md, WebBukti).
class WebBuktiScreen extends StatefulWidget {
  const WebBuktiScreen({super.key});

  @override
  State<WebBuktiScreen> createState() => _WebBuktiScreenState();
}

/// One row of the board's `R` table.
typedef _Baris = ({
  String no,
  String asal,
  String tgl,
  String ur,
  String tanda,
  int jumlah,
  String setuju,
  String dok,
  bool wajib,
});

const List<_Baris> _baris = [
  (
    no: 'BKU-2026-0147',
    asal: '—',
    tgl: '16/11/2026',
    ur: 'Fotokopi warta jemaat',
    tanda: '',
    jumlah: -150000,
    setuju: 'Tidak diperlukan (aturan: transaksi rutin)',
    dok: 'Diunggah, belum diverifikasi',
    wajib: false,
  ),
  (
    no: 'BKU-2026-0146',
    asal: '—',
    tgl: '15/11/2026',
    ur: 'Persembahan Ibadah Minggu',
    tanda: '',
    jumlah: 3450000,
    setuju: 'Tidak diperlukan (aturan: Pendapatan)',
    dok: 'Terverifikasi (oleh Meiske L.)',
    wajib: false,
  ),
  (
    no: 'BKU-2026-0144',
    asal: '—',
    tgl: '12/11/2026',
    ur: 'Pembalikan BKU-\u200B2026-\u200B0139', // Chrome breaks after its hyphens
    tanda: 'Pembalikan',
    jumlah: 750000,
    setuju: 'Tidak diperlukan (aturan: pembalikan)',
    dok: 'Tidak diperlukan (aturan: pembalikan)',
    wajib: false,
  ),
  (
    no: 'BKU-2026-0143',
    asal: '—',
    tgl: '11/11/2026',
    ur: 'Sewa sound system',
    tanda: '',
    jumlah: -600000,
    setuju: 'Tidak diperlukan (aturan: transaksi rutin)',
    dok: 'Wajib, belum ada',
    wajib: true,
  ),
  (
    no: 'BKU-2026-0139',
    asal: '—',
    tgl: '09/11/2026',
    ur: 'Konsumsi rapat majelis',
    tanda: 'Dibalik oleh BKU-2026-0144',
    jumlah: -750000,
    setuju: 'Tidak diperlukan (aturan: transaksi rutin)',
    dok: 'Terverifikasi (oleh Meiske L.)',
    wajib: false,
  ),
  (
    no: 'BKU-2026-0137',
    asal: 'KW-0412',
    tgl: '08/11/2026',
    ur: 'Renovasi pastori, termin 1',
    tanda: '',
    jumlah: -4500000,
    setuju: 'Sudah dicatat · Pdt. Lidya Rondonuwu, Ketua BPMJ',
    dok: 'Dikecualikan (alasan: kuitansi menyusul, oleh Ketua BPMJ)',
    wajib: false,
  ),
];

const _celah = [
  ('BKU-2026-0111', '14/10/2026 10.20'),
  ('BKU-2026-0124', '29/10/2026 16.05'),
  ('BKU-2026-0126', '30/10/2026 09.12'),
];

const _tindak = [
  (
    '1 dokumen pendukung wajib, belum ada',
    'BKU-2026-0143 · Sewa sound system · Rp600.000',
  ),
  ('2 draf belum dibukukan', 'Belum masuk saldo · Rp800.000'),
  ('1 Mata Anggaran belum dipilih', 'Draf · Honor pemusik'),
];

const _tabs = ['Daftar Bukti Kas', 'Celah nomor', 'Daftar perlu tindakan'];

const _mono = TextStyle(fontFamily: PalakatText.mono);

/// An inline link inside a text line of [tinggi]: keeps the 44 px target
/// without making the line taller (the boards' `<a>` in running text).
Widget _tautanSebaris({
  required Layar ke,
  required double tinggi,
  required Widget child,
  Cara cara = Cara.dorong,
}) {
  final lebih = (44 - tinggi) / 2;
  return MarginNegatif(
    atas: lebih,
    bawah: lebih,
    child: Tautan(
      ke: ke,
      cara: cara,
      child: SizedBox(
        height: 44,
        child: Align(alignment: Alignment.centerLeft, child: child),
      ),
    ),
  );
}

class _WebBuktiScreenState extends State<WebBuktiScreen> {
  String _tab = _tabs.first;

  /// Width of "Lihat transaksi" at 14/700: the link's flex basis.
  double _lebarLihat(BuildContext context) {
    final tp = TextPainter(
      text: const TextSpan(
        text: 'Lihat transaksi',
        style: TextStyle(
          fontFamily: PalakatText.sans,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final w = tp.width.ceilToDouble();
    tp.dispose();
    return w;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final keterangan = TextStyle(fontSize: 13, color: c.tinta3);
    return HalamanWeb(
      layarKeuangan: true,
      nav: const NavSamping(item: navKeuangan, aktif: 5),
      isi: [
        for (final w in <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumb in a 15 / 1.45 line.
              _tautanSebaris(
                ke: Layar.paketLaporan,
                cara: Cara.naik,
                tinggi: 15 * 1.45,
                child: const TautanTeks('Laporan', ukuran: 14),
              ),
              const SizedBox(height: 2),
              Semantics(
                header: true,
                child: Text.rich(
                  TextSpan(
                    text: 'Daftar Bukti Kas ',
                    children: [
                      TextSpan(
                        text: '· November 2026 · Belum ditutup',
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
                  // The h1's 26 px line box also holds a wrapped line of
                  // only the 15 px span (390 wide).
                  strutStyle: const StrutStyle(
                    fontFamily: PalakatText.sans,
                    fontSize: 26,
                    height: 1.45,
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                ),
              ),
            ],
          ),
          // `flex-wrap: wrap; gap: 8px`: wrapped chips keep 8 between rows.
          Builder(
            builder: (context) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in _tabs)
                  ChipSatu(
                    teks: t,
                    dipilih: t == _tab,
                    padding: 16,
                    onTap: () {
                      // A view change jumps to the top (CONVENTIONS).
                      final s = Scrollable.maybeOf(context);
                      if (s != null && s.position.pixels > 0) {
                        s.position.jumpTo(0);
                      }
                      setState(() => _tab = t);
                    },
                  ),
              ],
            ),
          ),
          if (_tab == _tabs[0]) ...[
            _tabel(c),
            Text(
              'Contoh 6 dari 51 baris. No. Bukti dibuat aplikasi; nomor dari '
              'catatan lama tampil terpisah sebagai No. bukti asal. Transaksi '
              'yang dibalik tetap ada di daftar.',
              style: keterangan,
            ),
          ],
          if (_tab == _tabs[1]) ...[
            _celahNomor(c),
            Text(
              'Daftar celah nomor hanya terlihat oleh yang melihat seluruh '
              'Jemaat. Akses terbatas per peruntukan tidak melihat halaman ini.',
              style: keterangan,
            ),
          ],
          if (_tab == _tabs[2]) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: ShapeDecoration(
                shape: GarisBorder.putus(c.putus, radius: 14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Daftar perlu tindakan (tidak resmi)',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Bukan bagian laporan resmi dan tidak mengubah jumlah apa '
                    'pun.',
                    style: TextStyle(fontSize: 14, color: c.tinta2),
                  ),
                ],
              ),
            ),
            Kartu(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < _tindak.length; i++)
                    Container(
                      // CSS content-box: min-height 56 plus padding 8 8.
                      constraints: const BoxConstraints(minHeight: 72),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        border: i == 0
                            ? null
                            : Border(top: BorderSide(color: c.garis)),
                      ),
                      child: BarisLentur(
                        jarak: 16,
                        jarakBaris: 8,
                        rata: CrossAxisAlignment.center,
                        anak: [
                          Lentur(
                            dasar: 320,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _tindak[i].$1,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(_tindak[i].$2, style: keterangan),
                              ],
                            ),
                          ),
                          // CSS sizes the inline-flex link to its text: flush
                          // right beside the text, flush left once it wraps.
                          Lentur(
                            dasar: _lebarLihat(context),
                            tumbuh: 0,
                            child: Tautan(
                              ke: Layar.transaksi,
                              child: const SizedBox(
                                height: 44,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: TautanTeks(
                                    'Lihat transaksi',
                                    ukuran: 14,
                                    berat: FontWeight.w700,
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
          ],
        ])
          // CSS splits line-height leading evenly above and below each
          // font; Flutter's default puts mixed-size and mono lines lower.
          DefaultTextStyle.merge(
            style: const TextStyle(
              leadingDistribution: TextLeadingDistribution.even,
            ),
            child: w,
          ),
      ],
    );
  }

  Widget _tabel(PalakatWarna c) {
    final kecil = TextStyle(fontSize: 13, color: c.tinta2);
    Widget baris(List<Widget> sel, {bool garis = false, bool kepala = false}) {
      final lebar = <double?>[130, 110, 92, null, 130, null, null];
      final flex = <int>[0, 0, 0, 10, 0, 9, 9];
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          border: garis ? Border(top: BorderSide(color: c.garis)) : null,
        ),
        child: Row(
          crossAxisAlignment: kepala
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            for (var i = 0; i < sel.length; i++) ...[
              if (i > 0) const SizedBox(width: 14),
              if (lebar[i] != null)
                SizedBox(width: lebar[i], child: sel[i])
              else
                Expanded(flex: flex[i], child: sel[i]),
            ],
          ],
        ),
      );
    }

    final kepala = DefaultTextStyle.merge(
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: c.tinta2,
      ),
      child: baris(kepala: true, const [
        Text('No. Bukti'),
        Text('No. bukti asal'),
        Text('Tanggal'),
        Text('Uraian'),
        Text('Jumlah (Rp)', textAlign: TextAlign.right),
        Text('Persetujuan'),
        Text('Dokumen pendukung'),
      ]),
    );

    final isi = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        kepala,
        for (final r in _baris)
          DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 14),
            child: baris(garis: true, [
              DefaultTextStyle.merge(
                style: _mono.copyWith(fontSize: 13),
                child: _tautanSebaris(
                  ke: Layar.transaksi,
                  tinggi: 13 * 1.45,
                  child: TautanTeks(r.no, berat: FontWeight.w400),
                ),
              ),
              Text(
                r.asal,
                style: _mono.copyWith(fontSize: 13, color: c.tinta2),
              ),
              Text(r.tgl, style: TextStyle(color: c.tinta2)),
              Text.rich(
                TextSpan(
                  text: r.ur,
                  children: [
                    if (r.tanda.isNotEmpty) ...[
                      const TextSpan(text: ' '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        // `white-space: nowrap`: overflows a narrow cell.
                        child: _TanpaBatas(child: _Lencana(r.tanda)),
                      ),
                    ],
                  ],
                ),
              ),
              Text(rp(r.jumlah), textAlign: TextAlign.right, style: _mono),
              Text(r.setuju, style: kecil),
              Text(
                r.dok,
                style: kecil.copyWith(color: r.wajib ? c.bata : c.tinta2),
              ),
            ]),
          ),
      ],
    );

    return Kartu(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, k) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: k.maxWidth < 960 ? 960 : k.maxWidth,
            child: isi,
          ),
        ),
      ),
    );
  }

  Widget _celahNomor(PalakatWarna c) {
    const judul = TextStyle(fontWeight: FontWeight.w700);
    final sub = TextStyle(fontSize: 14, color: c.tinta2);
    Widget kartu(List<Widget> anak, {bool terpilih = false}) => Kartu(
      status: terpilih ? GarisStatus.terpilih : GarisStatus.dibukukan,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < anak.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            anak[i],
          ],
        ],
      ),
    );
    return _Kisi(
      anak: [
        kartu(terpilih: true, [
          const Text.rich(
            TextSpan(
              text: 'Seri Biasa · ',
              children: [
                TextSpan(text: 'BKU-2026-0001', style: _mono),
                TextSpan(text: ' sampai '),
                TextSpan(text: '0151', style: _mono),
              ],
            ),
            style: judul,
          ),
          const Text(
            '3 nomor tanpa transaksi',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          for (final (kode, waktu) in _celah)
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: kode,
                    style: _mono.copyWith(color: c.tinta),
                  ),
                  TextSpan(
                    text:
                        ' · diberikan $waktu, pembukuannya tidak selesai. '
                        'Nomor ini tidak dipakai ulang.',
                  ),
                ],
              ),
              style: sub,
            ),
        ]),
        kartu([
          const Text.rich(
            TextSpan(
              text: 'Seri OPN Saldo awal pencatatan · ',
              children: [TextSpan(text: 'OPN-2026-0001', style: _mono)],
            ),
            style: judul,
          ),
          Text('Tidak ada celah', style: sub),
        ]),
        kartu([
          const Text('Seri ADJ Penyesuaian', style: judul),
          Text('Belum pernah dipakai', style: sub),
        ]),
      ],
    );
  }
}

/// `grid-template-columns: repeat(auto-fit, minmax(min(320px, 100%), 1fr));
/// gap: 16px` with the grid's default stretch: cards in a row share a height.
class _Kisi extends StatelessWidget {
  const _Kisi({required this.anak});
  final List<Widget> anak;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, k) {
      final n = KisiOtomatis.kolom(k.maxWidth, 320, 16, anak.length);
      final baris = <Widget>[];
      for (var i = 0; i < anak.length; i += n) {
        if (baris.isNotEmpty) baris.add(const SizedBox(height: 16));
        baris.add(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var j = i; j < i + n; j++) ...[
                  if (j > i) const SizedBox(width: 16),
                  Expanded(child: j < anak.length ? anak[j] : const SizedBox()),
                ],
              ],
            ),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: baris,
      );
    },
  );
}

/// The table's inline badge: 13/700, 1.5 `tinta3` line, `tinta2` text,
/// radius 6, padding 0 6, no wrap.
class _Lencana extends StatelessWidget {
  const _Lencana(this.teks);
  final String teks;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: ShapeDecoration(
        shape: GarisBorder.penuh(c.tinta3, radius: 6),
      ),
      child: Text(
        teks,
        softWrap: false,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: c.tinta2,
          height: 1.26,
        ),
      ),
    );
  }
}

/// Lays its child out at its own width and lets it paint past a narrower
/// box, as CSS `white-space: nowrap` overflows a grid cell.
class _TanpaBatas extends SingleChildRenderObjectWidget {
  const _TanpaBatas({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderTanpaBatas();
}

class _RenderTanpaBatas extends RenderProxyBox {
  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.constrain(
    child!.getDryLayout(
      constraints.copyWith(minWidth: 0, maxWidth: double.infinity),
    ),
  );

  @override
  void performLayout() {
    final c = child!;
    c.layout(
      constraints.copyWith(minWidth: 0, maxWidth: double.infinity),
      parentUsesSize: true,
    );
    size = constraints.constrain(c.size);
  }
}
