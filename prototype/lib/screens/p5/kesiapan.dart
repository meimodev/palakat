import 'package:flutter/widgets.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import 'kesiapan_isi.dart';

/// 101 · Pernyataan kesiapan per peruntukan (phone).
class KesiapanScreen extends StatefulWidget {
  const KesiapanScreen({super.key});
  @override
  State<KesiapanScreen> createState() => _KesiapanScreenState();
}

class _KesiapanScreenState extends State<KesiapanScreen>
    with KesiapanLogika<KesiapanScreen> {
  @override
  String get stem => 'Kesiapan';

  @override
  Widget build(BuildContext context) {
    final bend = bendahara(context);
    final anak = [
      if (bend) kartuKeadaan(context) else introPenyiap(context),
      daftarBaris(context, bend),
      Text(
        'Berlaku setelah Jemaat punya bendahara unit (Putaran 5). Perubahan pada transaksi bulan itu membuat pernyataan perlu dinyatakan lagi.',
        style: TextStyle(fontSize: 13, color: context.warna.tinta3),
      ),
    ];
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(
            judul: 'Pernyataan kesiapan',
            anakJudul: 'Oktober 2026 · masuk sebagai ${siapaKesiapan(bend)}',
            kembaliKe: 'TutupBuku',
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
