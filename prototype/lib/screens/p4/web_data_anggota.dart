import 'package:flutter/material.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'data_anggota.dart';

/// Web · Data anggota dan keluarga: the views of DataAnggota beside the
/// platform side nav ("Data jemaat" active).
class WebDataAnggotaScreen extends StatefulWidget {
  const WebDataAnggotaScreen({super.key});

  @override
  State<WebDataAnggotaScreen> createState() => _WebDataAnggotaScreenState();
}

class _WebDataAnggotaScreenState extends State<WebDataAnggotaScreen> {
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
    final keadaan = context.tweak<String>('WebDataAnggota', 'keadaan');
    if (_keadaan != null && _keadaan != keadaan) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _keAtas());
    }
    _keadaan = keadaan;
    return HalamanWeb(
      nav: NavSamping(
        item: navPlatform,
        aktif: 5,
        diSini: _keAtas,
        pengguna: const PenggunaNav(
          tebal: 'Pnt. Hendrik Rumagit',
          biasa: ' · Penatua Kolom 7',
        ),
      ),
      isi: [
        Column(
          key: _atas,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MarginNegatif(
              atas: 12,
              bawah: 12,
              child: Tautan(
                ke: 'WebBerandaJabatan',
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
            child: IsiDataAnggota(
              keadaan: keadaan,
              ajukan: (w) => Tautan(ke: 'Peristiwa', child: w),
              konfirmasi: (w) =>
                  Tautan(ke: 'KonfirmasiKeluarga', radius: 14, child: w),
            ),
          ),
        ),
      ],
    );
  }
}
