import 'package:flutter/material.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'pengembalian_isi.dart';

/// Web · Pengembalian (spec 07-kejadian.md): Pengembalian on the laptop,
/// original card left, form in the aside.
class WebPengembalianScreen extends StatefulWidget {
  const WebPengembalianScreen({super.key});

  @override
  State<WebPengembalianScreen> createState() => _WebPengembalianScreenState();
}

class _WebPengembalianScreenState extends State<WebPengembalianScreen> {
  final _k = KeadaanPengembalian();

  @override
  void dispose() {
    _k.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _k,
    builder: (context, _) {
      final c = _k.tab;
      final d = _k.jadi[c];
      final form = isianPengembalian(_k);
      return HalamanWeb(
        jabatanKosong: true,
        nav: const NavSamping(
          item: navKeuangan,
          aktif: 1,
          pengguna: PenggunaKeuangan(),
        ),
        isi: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The 15 / 1.45 line box of the breadcrumb's div.
              TautanSebaris(
                tinggi: 15 * 1.45,
                child: Tautan(
                  ke: 'WebTransaksi',
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
          CatatanAturan(
            c: c,
            tautan: const Tautan(ke: 'WebAlurPengembalian', child: SizedBox()),
          ),
          chipJenis(_k, ponsel: false),
          BarisLentur(
            anak: [
              Lentur(
                dasar: 420,
                tumbuh: 999,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    KartuAsal(c: c),
                    if (d != null) ...blokDraf(context, c, d),
                  ],
                ),
              ),
              Lentur(
                dasar: 380,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (d == null)
                      for (final (i, w) in form.indexed) ...[
                        if (i > 0) const SizedBox(height: 14),
                        w,
                      ],
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
