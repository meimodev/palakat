import 'package:flutter/material.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import 'terbit_dokumen.dart';

class WebTerbitDokumenScreen extends StatefulWidget {
  const WebTerbitDokumenScreen({super.key});

  @override
  State<WebTerbitDokumenScreen> createState() => _WebTerbitDokumenScreenState();
}

class _WebTerbitDokumenScreenState extends State<WebTerbitDokumenScreen>
    with KeadaanTerbitDokumen {
  @override
  String get stemTerbit => 'WebTerbitDokumen';

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final ki = tampilan(context);
    return Material(
      type: MaterialType.transparency,
      // HalamanWeb's page scroll takes this controller, so a view change can
      // jump to the top.
      child: PrimaryScrollController(
        controller: gulir,
        automaticallyInheritForPlatforms: TargetPlatform.values.toSet(),
        child: HalamanWeb(
          nav: NavSamping(
            item: navPlatform,
            aktif: 2,
            pengguna: const PenggunaNav(
              tebal: 'Olvie Pangemanan',
              biasa: ' · Sekretaris Jemaat',
            ),
          ),
          isi: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Inline breadcrumb: a 44 px target without growing the block.
                MarginNegatif(
                  atas: (44 - 14 * 1.45) / 2,
                  bawah: (44 - 14 * 1.45) / 2,
                  child: const Tautan(
                    ke: 'WebDokumenGereja',
                    cara: Cara.naik,
                    child: SizedBox(
                      height: 44,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: 1,
                        child: TautanTeks('Dokumen gereja', ukuran: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Semantics(
                  header: true,
                  child: const Text(
                    'Terbitkan dokumen',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  'Unggah salinan bertanda tangan, pilih untuk siapa',
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
              ],
            ),
            BarisLentur(
              jarak: 24,
              anak: [
                Lentur(
                  dasar: 520,
                  maks: 880,
                  child: IsiTerbitDokumen(
                    ki: ki,
                    ke: ke,
                    induk: 'WebDokumenGereja',
                  ),
                ),
                Lentur(dasar: 300, maks: 480, child: _Penerima(ki == 3)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Aside "Yang dilihat penerima", column gap 10, in every view.
class _Penerima extends StatelessWidget {
  const _Penerima(this.terbit);

  final bool terbit;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    Widget pasangan(String kiri, String kanan) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(kiri, style: TextStyle(color: c.tinta2)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            kanan,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: const Text(
            'Yang dilihat penerima',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 10),
        Kartu(
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Surat edaran jadwal ibadah Natal 2026',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    terbit
                        ? const LencanaStatus(
                            'Diterbitkan',
                            bentuk: BentukLencana.tinta,
                          )
                        : const LencanaStatus(
                            'Belum diterbitkan',
                            bentuk: BentukLencana.draf,
                          ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Keputusan dan surat edaran · 12/11/2026',
                  style: TextStyle(color: c.tinta2),
                ),
                const SizedBox(height: 6),
                pasangan('Ditujukan untuk', 'Semua anggota'),
                const SizedBox(height: 6),
                pasangan('Lampiran', 'Salinan bertanda tangan (PDF)'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Penerima melihat judul, tanggal dan salinan bertanda tangan. Mereka tidak melihat draf, unggahan yang gagal, atau dokumen yang ditujukan untuk orang lain.',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ],
    );
  }
}
