import 'package:flutter/material.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/tata_letak.dart';
import 'awal_isian_isi.dart';

/// Web · Pengaturan awal: identitas dan daftar.
class WebAwalIsianScreen extends StatefulWidget {
  const WebAwalIsianScreen({super.key});

  @override
  State<WebAwalIsianScreen> createState() => _WebAwalIsianScreenState();
}

class _WebAwalIsianScreenState extends State<WebAwalIsianScreen> {
  final _k = KeadaanAwalIsian();

  @override
  void dispose() {
    _k.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        nav: const NavSamping(
          item: navKeuangan,
          aktif: 6,
          // No jabatanKosong on this board: the footer stays Meiske L.
          pengguna: PenggunaKeuangan(ikutJabatanKosong: false),
        ),
        isi: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Tautan(
                ke: 'WebAwal',
                cara: Cara.naik,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Pengaturan awal Jemaat',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.laut,
                          decoration: TextDecoration.underline,
                          decorationColor: c.laut,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Semantics(
                  header: true,
                  child: const Text(
                    'Identitas dan daftar',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          ListenableBuilder(
            listenable: _k,
            builder: (context, _) => BarisLentur(
              jarak: 24,
              anak: [
                Lentur(
                  dasar: 360,
                  child: kolomAwal([
                    KartuIdentitas(_k),
                    ...akhirAwal(context, _k),
                  ], 16),
                ),
                Lentur(dasar: 460, tumbuh: 999, child: DaftarAwal(_k)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
