import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import 'lihat_transaksi_rinci.dart';
import '../../app/layar.dart';

/// Web · Lihat transaksi di balik angka laporan.
class WebLihatTransaksiScreen extends StatefulWidget {
  const WebLihatTransaksiScreen({super.key});

  @override
  State<WebLihatTransaksiScreen> createState() =>
      _WebLihatTransaksiScreenState();
}

class _WebLihatTransaksiScreenState extends State<WebLihatTransaksiScreen> {
  String _pilih = 'atk';

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        layarKeuangan: true,
        nav: const NavSamping(item: navKeuangan, aktif: 5),
        isi: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // An inline 14 px link on a 15 / 1.45 line: the 44 px target
              // overhangs.
              const MarginNegatif(
                atas: (44 - 15 * 1.45) / 2,
                bawah: (44 - 15 * 1.45) / 2,
                child: Tautan(
                  ke: Layar.paketLaporan,
                  cara: Cara.naik,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1,
                    heightFactor: 1,
                    child: TautanTeks('Laporan', ukuran: 14),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Semantics(
                header: true,
                child: const Text(
                  'Lihat transaksi',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                'Setiap angka di laporan membuka transaksi yang membentuknya.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
          BarisLentur(
            anak: [
              Lentur(dasar: 380, child: _daftar(c)),
              Lentur(
                dasar: 440,
                tumbuh: 999,
                child: RinciAngkaLaporan(pilih: _pilih, ke: Layar.pilihBulan),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _daftar(PalakatWarna c) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: ShapeDecoration(
      color: c.permukaan,
      shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Text(
            'Angka di laporan Oktober 2026',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.tinta2,
            ),
          ),
        ),
        for (final x in angkaLaporanOktober)
          Tekan(
            onTap: () => setState(() => _pilih = x.id),
            dipilih: x.id == _pilih,
            child: Container(
              constraints: const BoxConstraints(minHeight: 60),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: x.id == _pilih ? c.lautLembut : c.permukaan,
                border: Border(top: BorderSide(color: c.garis)),
              ),
              // box-shadow: inset 3px 0 0 laut (drawn over, no layout shift).
              foregroundDecoration: x.id == _pilih
                  ? BoxDecoration(
                      border: Border(left: BorderSide(color: c.laut, width: 3)),
                    )
                  : null,
              child: Row(
                children: [
                  Text(
                    x.lap.substring(0, 3),
                    style: TextStyle(
                      fontFamily: PalakatText.mono,
                      fontSize: 13,
                      color: c.tinta2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      x.pendek,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    rp(x.total),
                    style: const TextStyle(
                      fontFamily: PalakatText.mono,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
