import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'dokumen_gereja_isi.dart';

/// Web · Dokumen gereja (spec 17-keadaanumum.md): the document archive at
/// the Sekretaris Jemaat's desk. Same four views as DokumenGereja.
class WebDokumenGerejaScreen extends StatefulWidget {
  const WebDokumenGerejaScreen({super.key});

  @override
  State<WebDokumenGerejaScreen> createState() => _WebDokumenGerejaScreenState();
}

class _WebDokumenGerejaScreenState extends State<WebDokumenGerejaScreen>
    with KeadaanDokumenGereja {
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final keadaan = context.tweak<String>('WebDokumenGereja', 'keadaan');
    final ki = indeks(keadaan);
    final isi = isiDokumenGereja(
      web: true,
      ki: ki,
      ke: 'WebTerbitDokumen',
      keBaris: 'WebDokumenGereja',
      onBuka: () => pilih(1, keadaan),
    );
    return HalamanWeb(
      // A new view starts at the top of the page.
      key: ValueKey(ki),
      nav: const NavSamping(
        item: navPlatform,
        aktif: 2,
        pengguna: PenggunaNav(
          tebal: 'Olvie Pangemanan',
          biasa: ' · Sekretaris Jemaat',
        ),
      ),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Inline link: a 44 target that overhangs its 20 px line.
            const MarginNegatif(
              bawah: 44 - 14 * 1.45,
              child: Tautan(
                ke: 'WebBerandaJabatan',
                cara: Cara.naik,
                child: TautanTeks('Beranda', ukuran: 14),
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: Text(
                'Dokumen gereja',
                style: PalakatText.judulHalaman.copyWith(color: c.tinta),
              ),
            ),
            Text(
              'Arsip dokumen seluruh Jemaat yang dipelihara Sekretaris Jemaat',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < isi.length; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
                  isi[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
