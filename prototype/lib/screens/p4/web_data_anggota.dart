import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'data_anggota.dart';
import '../../app/layar.dart';
import '../../providers/jemaat/jemaat.dart';

/// Web · Data anggota dan keluarga: the views of DataAnggota beside the
/// platform side nav ("Data jemaat" active).
class WebDataAnggotaScreen extends ConsumerStatefulWidget {
  const WebDataAnggotaScreen({super.key});

  @override
  ConsumerState<WebDataAnggotaScreen> createState() =>
      _WebDataAnggotaScreenState();
}

class _WebDataAnggotaScreenState extends ConsumerState<WebDataAnggotaScreen> {
  final _atas = GlobalKey();
  String? _keadaan;

  /// The page's own scroll view (inside HalamanWeb) back to the top.
  void _keAtas() {
    final konteks = _atas.currentContext;
    if (konteks == null) return;
    Scrollable.maybeOf(konteks)?.position.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final keadaan = ref.watch(anggotaDipilihProvider) ?? '';
    if (_keadaan != null && _keadaan != keadaan) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _keAtas());
    }
    _keadaan = keadaan;
    return HalamanWeb(
      nav: NavSamping(item: navPlatform, aktif: 5, diSini: _keAtas),
      isi: [
        Column(
          key: _atas,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MarginNegatif(
              // The 14 px <a> sits on the div's 15 × 1.45 strut: a 21.75 line
              // box with the text 1.1 down; the 44 target overhangs it.
              atas: 10.75,
              bawah: 11.5,
              child: Tautan(
                ke: Layar.beranda,
                cara: Cara.naik,
                child: Center(
                  widthFactor: 1,
                  child: TautanTeks('Beranda', ukuran: 14),
                ),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Data anggota dan keluarga',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            Text(
              'Satu data untuk setiap orang; keluarga menyimpan riwayatnya',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            // Peristiwa and KonfirmasiKeluarga are phone-only: their links
            // are left out on the web (README 7.1 rule 4).
            child: const IsiDataAnggota(),
          ),
        ),
      ],
    );
  }
}
