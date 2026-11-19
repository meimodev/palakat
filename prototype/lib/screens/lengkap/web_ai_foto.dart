import 'package:flutter/material.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'ai_foto_bagian.dart';

/// Web · Bantuan AI dari foto nota (spec 10-aifoto.md, WebAIFoto).
class WebAIFotoScreen extends StatefulWidget {
  const WebAIFotoScreen({super.key});

  @override
  State<WebAIFotoScreen> createState() => _WebAIFotoScreenState();
}

class _WebAIFotoScreenState extends State<WebAIFotoScreen> {
  final _k = KeadaanAIFoto();

  @override
  void dispose() {
    _k.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: HalamanWeb(
      jabatanKosong: true,
      nav: const NavSamping(
        item: navKeuangan,
        aktif: 1,
        pengguna: PenggunaKeuangan(),
      ),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The 44 px target overhangs the 21.75 px text line (15 × 1.45).
            MarginNegatif(
              atas: 11.125,
              bawah: 11.125,
              child: Tautan(
                ke: 'WebCatat',
                cara: Cara.naik,
                child: const SizedBox(
                  height: 44,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1,
                    child: TautanTeks('Transaksi', ukuran: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: const Text(
                'Belanja dari foto nota',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        ListenableBuilder(
          listenable: _k,
          builder: (context, _) => BarisLentur(
            anak: [
              Lentur(dasar: 420, tumbuh: 999, child: IsianAIFoto(_k)),
              Lentur(dasar: 400, child: PanelAIFoto(_k)),
            ],
          ),
        ),
      ],
    ),
  );
}
