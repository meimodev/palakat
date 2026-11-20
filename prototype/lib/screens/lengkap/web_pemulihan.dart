import 'package:flutter/material.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/perangkat_prototipe.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/tombol.dart';
import 'pemulihan.dart';
import 'web_masuk.dart';

class WebPemulihanScreen extends StatefulWidget {
  const WebPemulihanScreen({super.key});

  @override
  State<WebPemulihanScreen> createState() => _WebPemulihanScreenState();
}

class _WebPemulihanScreenState extends State<WebPemulihanScreen> {
  /// Bumped by the self nav item "Pemulihan akun": a fresh step block, as
  /// reopening the board on the canvas.
  int _generasi = 0;

  final _nav = GlobalKey();

  void _ulang() => setState(() => _generasi++);

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    // main: padding 28 … 40 around the centring wrapper (flex 1 of 100vh).
    final tinggi = MediaQuery.sizeOf(context).height - 68;
    return AlatPrototipe(
      stem: 'WebPemulihan',
      alat: alatPemulihan,
      child: HalamanWeb(
        nav: NavSamping(
          key: _nav,
          item: navPemulihan,
          aktif: 0,
          pengguna: const Text('Belum masuk'),
          diSini: _ulang,
        ),
        isi: [
          TengahBarisUtama(
            nav: _nav,
            tinggi: tinggi,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 460),
                  padding: EdgeInsets.all(context.jepit(24, 4, 40)),
                  decoration: ShapeDecoration(
                    color: c.permukaan,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: c.garis),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: LangkahPemulihan(
                    key: ValueKey(_generasi),
                    akunSaya: const Tautan(
                      ke: 'WebAkunSaya',
                      child: SizedBox(),
                    ),
                    beranda: const Tombol(
                      'Buka Beranda',
                      onPressed: null,
                      ke: 'WebBeranda',
                      cara: Cara.ganti,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
