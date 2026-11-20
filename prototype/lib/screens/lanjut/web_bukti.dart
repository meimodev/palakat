import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/finance/finance.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/keuangan/laporan.dart';
import '../../providers/repositories_keuangan.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../app/layar.dart';
import 'bukti.dart';

/// Web · Daftar Bukti Kas dan celah nomor (spec 06-bukti.md, WebBukti):
/// the chosen month's posted Bukti Kas (F12), the gap cards (DP7) and the
/// unofficial to-do list, all computed.
class WebBuktiScreen extends ConsumerStatefulWidget {
  const WebBuktiScreen({super.key});

  @override
  ConsumerState<WebBuktiScreen> createState() => _WebBuktiScreenState();
}

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

class _WebBuktiScreenState extends ConsumerState<WebBuktiScreen> {
  String _tab = _tabs.first;
  String? _bulan;

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
    final bulan = bulanBukti(ref, _bulan);
    final baris = bulan == null
        ? const <BarisBukti>[]
        : ref.watch(buktiBulanProvider(bulan.id));
    final tindak = _tindak(baris);
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
                        text: bulan == null
                            ? ''
                            : '· ${namaBulan(bulan)} · '
                                  '${bulan.isClosed ? 'Sudah ditutup' : 'Belum ditutup'}',
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
            PilihBulanBukti(
              terpilih: bulan,
              onPilih: (id) => setState(() => _bulan = id),
            ),
            _tabel(c, baris),
            Text(
              '${baris.length} baris. No. Bukti dibuat aplikasi; nomor dari '
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
                  if (tindak.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Tidak ada yang perlu ditindaklanjuti.',
                        style: keterangan,
                      ),
                    ),
                  for (var i = 0; i < tindak.length; i++)
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
                                  tindak[i].$1,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(tindak[i].$2, style: keterangan),
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

  /// The unofficial to-do lines: required documents missing, drafts not
  /// booked, drafts without a Mata Anggaran.
  List<(String, String)> _tindak(List<BarisBukti> baris) {
    final wajib = [
      for (final r in baris)
        if (r.wajib) r,
    ];
    final draf = ref.watch(transactionRepositoryProvider).drafts();
    final tanpaMa = [
      for (final t in draf)
        if (t.allocations.any(
          (a) =>
              a.masterCode == null &&
              (t.type == TransactionType.income ||
                  t.type == TransactionType.expense),
        ))
          t,
    ];
    return [
      if (wajib.isNotEmpty)
        (
          '${wajib.length} dokumen pendukung wajib, belum ada',
          wajib
              .map((r) => '${r.no} · ${r.ur} · ${rp(r.jumlah.abs())}')
              .join('; '),
        ),
      if (draf.isNotEmpty)
        (
          '${draf.length} draf belum dibukukan',
          'Belum masuk saldo · ${rp(draf.fold(0, (n, t) => n + t.total))}',
        ),
      if (tanpaMa.isNotEmpty)
        (
          '${tanpaMa.length} Mata Anggaran belum dipilih',
          tanpaMa.map((t) => 'Draf · ${t.description}').join('; '),
        ),
    ];
  }

  Widget _tabel(PalakatWarna c, List<BarisBukti> rows) {
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
        for (final r in rows)
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

  Widget _celahNomor(PalakatWarna c) => _Kisi(anak: kartuCelah(ref, c));
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
