import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import 'kesiapan_isi.dart';
import '../../app/layar.dart';

/// 101 · Pernyataan kesiapan per peruntukan (phone).
class KesiapanScreen extends ConsumerStatefulWidget {
  const KesiapanScreen({super.key});
  @override
  ConsumerState<KesiapanScreen> createState() => _KesiapanScreenState();
}

class _KesiapanScreenState extends ConsumerState<KesiapanScreen>
    with KesiapanLogika<KesiapanScreen> {
  @override
  Widget build(BuildContext context) {
    final bend = bendahara(context);
    final anak = [
      if (bend) kartuKeadaan(context) else introPenyiap(context),
      daftarBaris(context, bend),
      Text(
        'Perubahan pada transaksi bulan itu membuat pernyataan perlu dinyatakan lagi.',
        style: TextStyle(fontSize: 13, color: context.warna.tinta3),
      ),
    ];
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(
            judul: 'Pernyataan kesiapan',
            anakJudul: '$namaBulanIni · masuk sebagai ${siapaSaya(ref)}',
            kembaliKe: Layar.tutupBuku,
            labelKembali: 'Kembali ke Bulan',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < anak.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    anak[i],
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
