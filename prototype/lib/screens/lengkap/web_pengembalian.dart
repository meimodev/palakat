import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/keuangan/pengembalian.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'pengembalian_isi.dart';
import '../../app/layar.dart';

/// Web · Pengembalian (spec 07-kejadian.md, with WebAlurPengembalian merged
/// in): the pick list, then the original card left and the form (or the
/// saved refund) beside it.
class WebPengembalianScreen extends ConsumerStatefulWidget {
  const WebPengembalianScreen({super.key});

  @override
  ConsumerState<WebPengembalianScreen> createState() =>
      _WebPengembalianScreenState();
}

class _WebPengembalianScreenState extends ConsumerState<WebPengembalianScreen> {
  final _k = KeadaanPengembalian();

  @override
  void dispose() {
    _k.dispose();
    super.dispose();
  }

  Widget _kolom(List<Widget> anak, double jarak) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (i, w) in anak.indexed) ...[
        if (i > 0 && w is! SizedBox) SizedBox(height: jarak),
        w,
      ],
    ],
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _k,
    builder: (context, _) {
      final a = _k.asalId == null
          ? null
          : ref.watch(asalPengembalianProvider(_k.asalId!));
      return HalamanWeb(
        layarKeuangan: true,
        nav: const NavSamping(item: navKeuangan, aktif: 1),
        isi: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The 15 / 1.45 line box of the breadcrumb's div.
              TautanSebaris(
                tinggi: 15 * 1.45,
                child: Tautan(
                  ke: Layar.transaksi,
                  cara: Cara.naik,
                  child: Center(
                    widthFactor: 1,
                    child: TautanTeks('Transaksi', ukuran: 14),
                  ),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Pengembalian',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          chipJenis(_k, ponsel: false),
          if (a == null)
            _kolom(
              daftarAsal(
                context,
                _k,
                ref.watch(daftarAsalPengembalianProvider),
              ),
              12,
            )
          else ...[
            CatatanAturan(c: JenisPengembalian.dari(a)),
            BarisLentur(
              anak: [
                Lentur(
                  dasar: 420,
                  tumbuh: 999,
                  child: _kolom([
                    KartuAsal(a: a),
                    if (_k.hasilId != null) ...blokDraf(context, ref, _k, a),
                  ], 0),
                ),
                Lentur(
                  dasar: 380,
                  child: _kolom([
                    if (_k.hasilId == null) ...isianPengembalian(ref, _k, a),
                  ], 14),
                ),
              ],
            ),
          ],
        ],
      );
    },
  );
}
