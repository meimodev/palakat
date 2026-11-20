import 'package:flutter/material.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../lanjut/bantuan_ai_bagian.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// Web · Bantuan AI dari kalimat (spec 05-kewajiban.md, WebBantuanAI).
class WebBantuanAIScreen extends StatefulWidget {
  const WebBantuanAIScreen({super.key});

  @override
  State<WebBantuanAIScreen> createState() => _WebBantuanAIScreenState();
}

class _WebBantuanAIScreenState extends State<WebBantuanAIScreen> {
  final _s = KeadaanBantuanAI();

  @override
  void dispose() {
    _s.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final keadaanAI = belumDipindah<String>('tersedia');
    final keterangan = TextStyle(fontSize: 13, color: c.tinta3);
    // No Material here: it would reset the inherited 15 px text style.
    return ListenableBuilder(
      listenable: _s,
      builder: (context, _) => HalamanWeb(
        layarKeuangan: true,
        nav: const NavSamping(item: navKeuangan, aktif: 1),
        isi: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 44 px target over a 20 px line.
              const MarginNegatif(
                atas: 12,
                bawah: 12,
                child: Tautan(
                  ke: Layar.catat,
                  cara: Cara.naik,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1,
                    heightFactor: 1,
                    child: TautanTeks('Catat transaksi', ukuran: 14),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Semantics(
                header: true,
                child: const Text(
                  'Catat dari kalimat',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                'Ketik seperti bercerita. Usulan AI belum mengisi apa pun sampai dipakai.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
          BarisLentur(
            jarak: 24,
            anak: [
              Lentur(
                dasar: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PanelBantuanAI(s: _s, keadaanAI: keadaanAI, web: true),
                    const SizedBox(height: 14),
                    Text(
                      'AI hanya mengusulkan. Membukukan, memverifikasi dokumen dan menutup buku selalu dilakukan orang.',
                      style: keterangan,
                    ),
                  ],
                ),
              ),
              Lentur(
                dasar: 420,
                tumbuh: 999,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          'Belanja',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          simpanTeks(_s),
                          style: keterangan.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // The board writes `turun` here but never declares it.
                    DrafBantuanAI(s: _s, turun: false),
                    const SizedBox(height: 16),
                    // Board `<a>` buttons are content-box: 46 + 1.5 px lines = 49,
                    // and the run stretches both to it.
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        SizedBox(
                          height: 49,
                          child: Tombol(
                            'Periksa dan bukukan',
                            onPressed: null,
                            ke: Layar.catat,
                            cara: Cara.ganti,
                            ukuran: UkuranTombol.ringkas,
                            lebarPenuh: false,
                          ),
                        ),
                        SizedBox(
                          height: 49,
                          child: Tombol(
                            'Simpan sebagai draf',
                            onPressed: null,
                            jenis: JenisTombol.kedua,
                            ke: Layar.transaksi,
                            cara: Cara.ganti,
                            ukuran: UkuranTombol.ringkas,
                            lebarPenuh: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
