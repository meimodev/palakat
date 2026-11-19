import 'package:flutter/material.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'ubah_pengaturan.dart';

class WebUbahPengaturanScreen extends StatelessWidget {
  const WebUbahPengaturanScreen({super.key});

  @override
  Widget build(BuildContext context) => HalamanWeb(
    nav: const NavSamping(
      item: navKeuangan,
      aktif: 6,
      // The board has no jabatanKosong tweak: the footer never changes.
      pengguna: PenggunaKeuangan(ikutJabatanKosong: false),
    ),
    isi: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inline 14/600 link on a 15 × 1.45 line; the 44 target overhangs it.
          MarginNegatif(
            atas: 11,
            bawah: 11,
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
            // judulHalaman's size and weight; colour inherited (dark theme).
            child: const Text(
              'Tambah dan ubah',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      IsiUbahPengaturan(
        web: true,
        tata: (b) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            b.tab,
            const SizedBox(height: 20),
            BarisLentur(
              jarak: 28,
              anak: [
                Lentur(
                  dasar: 420,
                  tumbuh: 999,
                  maks: 620,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [b.isi, const SizedBox(height: 16), b.tombol],
                  ),
                ),
                Lentur(
                  dasar: 360,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final w in [b.judul, ...b.jadi, b.catatan]) ...[
                        if (w != b.judul) const SizedBox(height: 12),
                        w,
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}
