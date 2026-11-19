import 'package:flutter/material.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'lihat_dokumen_penampil.dart';

/// Web · Lihat file dokumen pendukung (spec 11-lihatdokumen.md).
class WebLihatDokumenScreen extends StatefulWidget {
  const WebLihatDokumenScreen({super.key});

  @override
  State<WebLihatDokumenScreen> createState() => _WebLihatDokumenScreenState();
}

class _WebLihatDokumenScreenState extends State<WebLihatDokumenScreen>
    with KeadaanLihatDokumen {
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final judul = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The 44-high target overlaps the lines around it, as the inline <a>.
        MarginNegatif(
          atas: 12,
          bawah: 12,
          child: Tautan(
            ke: 'WebDokumen',
            cara: Cara.naik,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              alignment: Alignment.centerLeft,
              child: const TautanTeks('Dokumen pendukung', ukuran: 14),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Semantics(
          header: true,
          child: Text(
            'Lihat file',
            style: PalakatText.judulHalaman.copyWith(color: c.tinta),
          ),
        ),
        Text(
          'File dibuka di dalam aplikasi. Tidak ada yang diunduh ke perangkat.',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
      ],
    );
    final penampilKartu = Container(
      height: 640,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.tinta,
        borderRadius: BorderRadius.circular(PalakatRadius.kartuBesar),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: c.permukaan),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                fileNama,
                style: const TextStyle(
                  fontFamily: PalakatText.mono,
                  fontSize: 14,
                ),
              ),
            ),
            ...penampil(),
          ],
        ),
      ),
    );
    final aside = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: panel(
          context,
          tautan: const Tautan(
            ke: 'WebDokumen',
            cara: Cara.naik,
            child: IsiTautanTolak(),
          ),
        ),
      ),
    );
    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        jabatanKosong: true,
        nav: const NavSamping(
          item: navKeuangan,
          aktif: 1,
          pengguna: PenggunaKeuangan(),
        ),
        isi: [
          judul,
          BarisLentur(
            anak: [
              Lentur(dasar: 480, tumbuh: 999, child: penampilKartu),
              // content-box: basis 340 plus padding 20 20 and border 1 1
              Lentur(dasar: 340 + 42, child: aside),
            ],
          ),
        ],
      ),
    );
  }
}
