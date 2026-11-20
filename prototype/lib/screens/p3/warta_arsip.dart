import 'package:flutter/widgets.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol.dart';
import 'warta_arsip_bagian.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// 68 · Warta Jemaat (spec 18-wartaeditor.md, WartaArsip).
class WartaArsipScreen extends StatefulWidget {
  const WartaArsipScreen({super.key});
  @override
  State<WartaArsipScreen> createState() => _WartaArsipScreenState();
}

class _WartaArsipScreenState extends State<WartaArsipScreen>
    with KeadaanWartaArsip {
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final ki = keadaan('WartaArsip');
    final daftar = kolomWarta([
      for (final r in edisiWarta)
        // Each row links to this same board: a self link, nothing happens.
        Tautan(
          ke: Layar.warta,
          radius: 14,
          child: ConstrainedBox(
            // content-box min-height 44 + padding 12 12 + 1 px line.
            constraints: const BoxConstraints(minHeight: 70),
            child: Kartu(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.j,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          r.s,
                          style: TextStyle(fontSize: 13, color: c.tinta3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  LencanaStatus(r.l, bentuk: r.bentuk),
                  const SizedBox(width: 12),
                  const ChevronWarta(),
                ],
              ),
            ),
          ),
        ),
    ]);
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Warta Jemaat',
            anakJudul:
                'Edisi yang sudah diterbitkan, persis seperti saat diterbitkan',
            kembaliKe: Layar.beranda,
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: kolomWarta(
                isiWartaArsip(
                  context,
                  ki: ki,
                  daftar: daftar,
                  susun: tombolWarta(
                    const Tombol(
                      'Susun edisi 22/11/2026',
                      jenis: JenisTombol.tinta,
                      ke: Layar.wartaEdisi,
                      param: {'edisi': belumDipindahId},
                      onPressed: null,
                    ),
                  ),
                  susunPertama: tombolWarta(
                    const Tombol(
                      'Susun edisi pertama',
                      jenis: JenisTombol.tinta,
                      ke: Layar.wartaEdisi,
                      param: {'edisi': belumDipindahId},
                      onPressed: null,
                    ),
                  ),
                  onUnduh: go1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
