import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/panel_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import 'keluar_akun.dart';
import '../../app/layar.dart';

/// `st`: 'akun' (button shown), 'tanya' (confirmation panel), 'keluar'
/// (signed-out card in place of the main column; the side nav stays).
class WebKeluarScreen extends StatefulWidget {
  const WebKeluarScreen({super.key});
  @override
  State<WebKeluarScreen> createState() => _WebKeluarScreenState();
}

class _WebKeluarScreenState extends State<WebKeluarScreen> {
  String _st = 'akun';

  void _ke(String st) => setState(() => _st = st);

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return HalamanWeb(
      tengah: _st == 'keluar',
      nav: const NavSamping(item: navKeuangan, aktif: 6),
      isi: _st == 'keluar' ? [_sudahKeluar(context)] : _akun(c),
    );
  }

  List<Widget> _akun(PalakatWarna c) => [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The crumb keeps its 44 px target over the inline link's 15 × 1.45 line box.
        MarginNegatif(
          atas: 11.125,
          bawah: 11.125,
          child: Tautan(
            ke: Layar.pengaturan,
            cara: Cara.naik,
            child: const SizedBox(
              height: 44,
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: 1,
                child: TautanTeks('Pengaturan', ukuran: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Semantics(
          header: true,
          child: const Text(
            'Akun',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
    BarisLentur(
      jarak: 24,
      anak: [
        Lentur(
          dasar: 420,
          tumbuh: 999,
          maks: 560,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const KartuProfil(ke: Layar.akun),
              const SizedBox(height: 16),
              const KartuSesi(ke: Layar.bendahara, anak: 'serah'),
              const SizedBox(height: 16),
              const KalimatKeluar(),
              if (_st == 'akun') ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Tombol(
                    'Keluar dari perangkat ini',
                    onPressed: () => _ke('tanya'),
                    jenis: JenisTombol.kedua,
                    ukuran: UkuranTombol.ringkas,
                    lebarPenuh: false,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_st == 'tanya')
          PanelSamping(
            berbingkai: true,
            // The board's aside is content-box: 320 / 420 plus padding and line.
            dasar: 363,
            maks: 463,
            jarak: 12,
            muncul: true,
            anak: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: const Text(
                      judulTanya,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    kalimatTanya,
                    style: TextStyle(fontSize: 14, color: c.tinta2),
                  ),
                ],
              ),
              ...tombolTanya(
                context,
                onKeluar: () => _ke('keluar'),
                onKembali: () => _ke('akun'),
              ),
            ],
          ).lentur,
      ],
    ),
  ];

  // The board's `flex: 1` centring box; HalamanWeb.tengah centres it in
  // `main`.
  Widget _sudahKeluar(BuildContext context) {
    final c = context.warna;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 440),
          padding: EdgeInsets.all(context.jepit(24, 4, 40)),
          decoration: BoxDecoration(
            color: c.permukaan,
            border: Border.all(color: c.garis),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const IsiSudahKeluar(),
        ),
      ),
    );
  }
}
