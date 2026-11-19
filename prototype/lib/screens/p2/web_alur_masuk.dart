import 'package:flutter/material.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'alur_masuk_isi.dart';

/// Web · Alur · Masuk dan menghubungkan akun (16-alurmasuk.md).
class WebAlurMasukScreen extends StatelessWidget {
  const WebAlurMasukScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return HalamanWeb(
      nav: const NavSamping(
        item: navPlatform,
        aktif: 0,
        pengguna: PenggunaNav(tebal: 'Belum masuk', biasa: ' · Jemaat Karunia'),
      ),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The inline breadcrumb's line is 15 × 1.45 high; the 44 target
            // overhangs it.
            const MarginNegatif(
              atas: 11.125,
              bawah: 11.125,
              child: Tautan(
                ke: 'WebBerandaJabatan',
                cara: Cara.naik,
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1,
                  heightFactor: 1,
                  child: TautanTeks('Beranda', ukuran: 14),
                ),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Alur · Masuk dan menghubungkan akun',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            Text(
              'Nomor ponsel, kode, lalu data jemaat yang diverifikasi Penatua',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: const AlurMasukIsi(
              stem: 'WebAlurMasuk',
              pemulihan: TautanPemulihan(ke: 'WebPemulihan'),
              anggota: TombolTautanAlur(
                'Ajukan permohonan menjadi anggota',
                ke: 'AlurAnggota',
              ),
              warta: TombolTautanAlur('Buka Warta Jemaat', ke: 'WebWartaArsip'),
              beranda: TombolTautanAlur(
                'Buka Beranda',
                ke: 'WebBerandaJabatan',
                tinta: true,
                cara: Cara.ganti,
              ),
              akun: TombolTautanAlur(
                'Tambah email cadangan',
                ke: 'WebAkunSaya',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
