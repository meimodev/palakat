import 'package:flutter/material.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'kas_unit_isi.dart';

/// Web · Alur · Kas/Bank unit (spec 23-alurunit.md, WebKasUnit).
class WebKasUnitScreen extends StatelessWidget {
  const WebKasUnitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        nav: const NavSamping(
          item: navPlatform,
          aktif: 1,
          pengguna: PenggunaNav(
            tebal: 'Meiske Lumentut',
            biasa: ' · Bendahara Jemaat',
          ),
        ),
        isi: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // A 44 px target drawn as the board's line box (15 × 1.45).
              const MarginNegatif(
                atas: 11.125,
                bawah: 11.125,
                child: Tautan(
                  ke: 'WebPengaturan',
                  cara: Cara.naik,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: 1,
                    heightFactor: 1,
                    child: TautanTeks('Pengaturan', ukuran: 14),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Alur · Kas/Bank unit',
                style: PalakatText.judulHalaman.copyWith(color: c.tinta),
              ),
              Text(
                'Menetapkan Kas/Bank yang dikelola sebuah unit',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.topStart,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: const KasUnitIsi(web: true),
            ),
          ),
        ],
      ),
    );
  }
}
