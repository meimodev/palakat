import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../widgets/tata_letak.dart';
import 'cari_bagian.dart';
import '../../app/layar.dart';

/// Web · Cari dan tanya (spec 08, WebCari).
class WebCariScreen extends ConsumerStatefulWidget {
  const WebCariScreen({super.key});

  @override
  ConsumerState<WebCariScreen> createState() => _WebCariScreenState();
}

class _WebCariScreenState extends ConsumerState<WebCariScreen> with LogikaCari {
  @override
  Widget build(BuildContext context) => HalamanWeb(
    layarKeuangan: true,
    nav: const NavSamping(item: navKeuangan, aktif: 1),
    isi: [
      Semantics(
        header: true,
        child: const Text(
          'Cari',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
      ),
      BarisLentur(
        jarak: 24,
        anak: [
          Lentur(
            dasar: 480,
            tumbuh: 999,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, w) in hasil(ke: Layar.transaksi).indexed) ...[
                  if (i > 0) const SizedBox(height: 16),
                  w,
                ],
              ],
            ),
          ),
          Lentur(dasar: 380, child: panelAi()),
        ],
      ),
    ],
  );
}
