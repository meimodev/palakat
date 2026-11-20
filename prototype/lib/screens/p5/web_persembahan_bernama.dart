import 'package:flutter/material.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'persembahan_bernama_blok.dart';

/// Web · Persembahan bernama (spec 22): PersembahanBernama on the laptop,
/// platform side nav with Keuangan active.
class WebPersembahanBernamaScreen extends StatefulWidget {
  const WebPersembahanBernamaScreen({super.key});

  @override
  State<WebPersembahanBernamaScreen> createState() =>
      _WebPersembahanBernamaScreenState();
}

class _WebPersembahanBernamaScreenState
    extends State<WebPersembahanBernamaScreen>
    with KeadaanPemberi {
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final i = ki(context, 'WebPersembahanBernama');
    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        nav: const NavSamping(
          item: navPlatform,
          aktif: 1,
          pengguna: PenggunaNav(
            tebal: 'Meiske Lumentut',
            biasa: ' · Bendahara Jemaat',
          ),
        ),
        isi: [
          Column(
            key: kunciIsi,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // A 44 px target drawn as the board's line box (15 × 1.45).
              const MarginNegatif(
                atas: 11.125,
                bawah: 11.125,
                child: Tautan(
                  ke: 'WebBeranda',
                  cara: Cara.naik,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: 1,
                    heightFactor: 1,
                    child: TautanTeks('Keuangan', ukuran: 14),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Semantics(
                header: true,
                child: const Text(
                  'Persembahan bernama',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                'Nama pemberi dicatat hanya bila sampulnya bernama',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: BarisLentur(
                jarak: 28,
                jarakBaris: 20,
                anak: [
                  const Lentur(dasar: 420, tumbuh: 1.3, child: KartuSampul()),
                  Lentur(
                    dasar: 340,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 12,
                      children: blokPemberi(
                        context,
                        ki: i,
                        pilih: pilih,
                        ke: 'PersembahanSaya',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
