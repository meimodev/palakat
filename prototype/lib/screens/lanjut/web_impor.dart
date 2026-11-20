import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import '../../app/layar.dart';
import '../../domain/core/core.dart';
import '../../providers/keuangan/impor.dart';
import '../../widgets/penolakan.dart';
import 'impor.dart' show tungguImpor;

const _kolom = [12, 13, 11, 12];

class WebImporScreen extends ConsumerStatefulWidget {
  const WebImporScreen({super.key});

  @override
  ConsumerState<WebImporScreen> createState() => _WebImporScreenState();
}

class _WebImporScreenState extends ConsumerState<WebImporScreen> {
  /// The choice on each possible duplicate: true "Tetap impor".
  final _tetap = <String, bool>{};
  Refusal? _pesan;
  late DataImpor? _d;

  int get _st => _d?.langkah ?? 0;
  bool get _tunggu => _d != null && tungguImpor(_d!, _tetap);

  String get _ket => switch (_d) {
    null => 'Belum ada file yang ditampung.',
    final d => switch (_st) {
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
        '${d.diimpor} baris sudah diimpor · '
            '${d.baris.length - d.diimpor} tidak diimpor. No. bukti asal dari '
            'file ditampilkan terpisah dari No. Bukti.',
    },
  };

  Future<void> _maju() async {
    final d = _d;
    if (d == null || _tunggu) return;
    final r = await majuImpor(ref, d, _tetap);
    if (mounted) setState(() => _pesan = r);
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
    _d = ref.watch(imporProvider);
    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        layarKeuangan: true,
        nav: const NavSamping(item: navKeuangan, aktif: 1),
        isi: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 44 px target over a 14 × 1.45 line: the extra height overlaps.
              MarginNegatif(
                atas: 11.85,
                bawah: 11.85,
                child: Tautan(
                  ke: Layar.transaksi,
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
                        text: _d == null
                            ? ''
                            : '· ${_d!.batch.fileName} · '
                                  '${_d!.baris.length} baris',
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
          if (_pesan case final r?)
            Penolakan(tindakan: r.action, sebab: r.because, jalan: const []),
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
    final label = [for (var i = 0; i < 4; i++) '${i + 1} · ${langkahImpor[i]}'];
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
        if (_d != null && _st < 3)
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
                for (final (i, b)
                    in (_d?.baris ?? const <BarisImpor>[]).indexed)
                  _barisTabel(context, i, b),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _barisTabel(BuildContext context, int i, BarisImpor d) {
    final c = context.warna;
    final st = _st;
    final kecil = TextStyle(fontSize: 13, color: c.tinta2);
    var (:hasil, :nada, :cat, :pilih) = hasilBaris(d, st, _tetap[d.id]);
    if (nada == NadaImpor.bata) {
      cat = '$cat Perbaiki di file lalu impor lagi, atau catat sendiri.';
    }
    final bentuk = BentukLencana.values.byName(nada.name);
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
    Widget keputusan(String label, bool nilai) => Tekan(
      onTap: () => setState(() => _tetap[d.id] = nilai),
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
          Text(
            d.baris.raw.replaceAll(' · ', '\n'),
            style: kecil.copyWith(fontFamily: PalakatText.mono),
          ),
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
                    keputusan('Tetap impor', true),
                    keputusan('Tidak diimpor', false),
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
