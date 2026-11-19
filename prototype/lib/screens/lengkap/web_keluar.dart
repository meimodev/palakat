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
      nav: const NavSamping(
        item: navKeuangan,
        aktif: 6,
        pengguna: PenggunaKeuangan(ikutJabatanKosong: false),
      ),
      isi: _st == 'keluar' ? [_sudahKeluar(context)] : _akun(c),
    );
  }

  List<Widget> _akun(PalakatWarna c) => [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The crumb keeps its 44 px target without growing the title block.
        MarginNegatif(
          atas: 12,
          bawah: 12,
          child: Tautan(
            ke: 'WebPengaturan',
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
              const KartuProfil(ke: 'WebAkunSaya'),
              const SizedBox(height: 16),
              const KartuSesi(ke: 'WebSerahTerima'),
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

  // `flex: 1` centring box in a main column at least the window high
  // (padding 28 + 40); below 860 the top nav bar (about 61 px) comes first.
  Widget _sudahKeluar(BuildContext context) {
    final c = context.warna;
    final tinggi =
        MediaQuery.sizeOf(context).height - 68 - (navSempit(context) ? 61 : 0);
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: tinggi < 0 ? 0 : tinggi),
      child: Padding(
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
            child: const IsiSudahKeluar(ke: 'WebMasuk'),
          ),
        ),
      ),
    );
  }
}
