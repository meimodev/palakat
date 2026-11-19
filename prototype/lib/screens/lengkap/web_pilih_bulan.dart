import 'package:flutter/material.dart';

import '../../motion/kerangka.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/tata_letak.dart';
import 'pilih_bulan.dart';

class WebPilihBulanScreen extends StatefulWidget {
  const WebPilihBulanScreen({super.key});

  @override
  State<WebPilihBulanScreen> createState() => _WebPilihBulanScreenState();
}

class _WebPilihBulanScreenState extends State<WebPilihBulanScreen> {
  final k = KeadaanPilihBulan();

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
          _BarisJudul(
            tombol: TombolBulan(k: k, onTap: () => setState(k.toggle)),
            teksTombol: TombolBulan.teks(k),
          ),
          BarisLentur(
            jarak: 24,
            anak: [
              Lentur(
                dasar: 460,
                tumbuh: 999,
                child: DaftarBulan(k: k, jarak: 14),
              ),
              if (k.buka)
                Lentur(
                  dasar: 340,
                  child: Gerak(
                    Kerangka.muncul,
                    lama: const Duration(milliseconds: 300),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Semantics(
                          header: true,
                          child: const Text(
                            'Pilih bulan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Semua bulan sejak tanggal mulai pencatatan.',
                          style: TextStyle(fontSize: 14, color: c.tinta2),
                        ),
                        const SizedBox(height: 12),
                        PilihanBulan(
                          k: k,
                          onPilih: (n) => setState(() => k.pilih(n)),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Title row: `flex-wrap`, centred, gap 12; h1 `flex: 1 1 200px`, the month
/// button at its content width, wrapping under the h1 when they do not fit.
class _BarisJudul extends StatelessWidget {
  const _BarisJudul({required this.tombol, required this.teksTombol});
  final Widget tombol;
  final String teksTombol;

  @override
  Widget build(BuildContext context) {
    final gaya = DefaultTextStyle.of(context).style
        .copyWith(fontWeight: FontWeight.w700);
    final tp = TextPainter(
      text: TextSpan(text: teksTombol, style: gaya),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final lebarTombol = tp.width + 32 + 3; // padding 0 16, 1.5 line
    tp.dispose();
    const judul = Text(
      'Transaksi',
      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
    );
    return LayoutBuilder(
      builder: (context, k) => 200 + 12 + lebarTombol <= k.maxWidth
          ? Row(
              children: [
                Expanded(child: Semantics(header: true, child: judul)),
                const SizedBox(width: 12),
                tombol,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(header: true, child: judul),
                const SizedBox(height: 12),
                tombol,
              ],
            ),
    );
  }
}
