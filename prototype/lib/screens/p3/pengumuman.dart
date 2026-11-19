import 'package:flutter/widgets.dart';

import '../../mock/mock.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'pengumuman_bagian.dart';

/// 65 · Pengumuman (17-keadaanumum.md): list, draft, published, archived,
/// correction as revision; the view swaps in place.
class PengumumanScreen extends StatefulWidget {
  const PengumumanScreen({super.key});

  @override
  State<PengumumanScreen> createState() => _PengumumanScreenState();
}

class _PengumumanScreenState extends State<PengumumanScreen>
    with KeadaanPengumuman {
  @override
  String get stem => 'Pengumuman';

  @override
  Widget build(BuildContext context) {
    final k = keadaan(context);
    final isi = switch (k) {
      'Daftar' => [
        for (final p in semuaPengumuman) BarisPengumuman(p),
        tulisPengumuman(pilih),
      ],
      'Draf' => drafPengumuman(context, pilih),
      _ => viewPengumuman(context, k, pilih),
    };
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Pengumuman',
            anakJudul: 'Berdiri sendiri; Warta Jemaat mengambil dari sini',
            kembaliKe: 'BerandaJabatan',
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: KolomJarak(key: kunciAtas, jarak: 16, anak: isi),
            ),
          ),
        ],
      ),
    );
  }
}
