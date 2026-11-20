import 'package:flutter/widgets.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'dokumen_gereja_isi.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// 62 · Dokumen gereja (spec 17-keadaanumum.md): the church document archive
/// on the phone. Four in-place views from the `keadaan` tweak.
class DokumenGerejaScreen extends StatefulWidget {
  const DokumenGerejaScreen({super.key});

  @override
  State<DokumenGerejaScreen> createState() => _DokumenGerejaScreenState();
}

class _DokumenGerejaScreenState extends State<DokumenGerejaScreen>
    with KeadaanDokumenGereja {
  @override
  Widget build(BuildContext context) {
    final keadaan = belumDipindah<String>('Daftar dokumen');
    final ki = indeks(keadaan);
    final isi = isiDokumenGereja(
      web: false,
      ki: ki,
      ke: Layar.dokumenGereja,
      anak: 'terbit',
      keBaris: Layar.dokumenGereja,
      onBuka: () => pilih(1, keadaan),
    );
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Dokumen gereja',
            anakJudul: 'Arsip dokumen seluruh Jemaat yang dipelihara Sekretaris Jemaat',
            kembaliKe: Layar.beranda,
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            child: SingleChildScrollView(
              // A new view starts at the top.
              key: ValueKey(ki),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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
      ),
    );
  }
}
