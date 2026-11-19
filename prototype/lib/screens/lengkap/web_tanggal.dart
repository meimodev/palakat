import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import 'tanggal_kalender.dart';

/// Web · Tanggal transaksi dan tanggal dokumen (spec 11, WebTanggal).
class WebTanggalScreen extends StatefulWidget {
  const WebTanggalScreen({super.key});

  @override
  State<WebTanggalScreen> createState() => _WebTanggalScreenState();
}

class _WebTanggalScreenState extends State<WebTanggalScreen>
    with TanggalLogika<WebTanggalScreen> {
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final pesanBulan = pesan(
      context,
      () => const Tautan(
        ke: 'WebKejadian',
        child: SizedBox(),
      ).buka(GoRouter.of(context)),
    );
    final kalender = [bilahBulan(context), kisiHari(context), ?pesanBulan];
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
          for (final w in <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The breadcrumb is an inline link in a 15 / 1.45 line: a 44
                // target, 21.75 px of layout.
                const MarginNegatif(
                  atas: 11.125,
                  bawah: 11.125,
                  child: Tautan(
                    ke: 'WebCatat',
                    cara: Cara.naik,
                    child: SizedBox(
                      height: 44,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: 1,
                        child: TautanTeks('Catat transaksi', ukuran: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Semantics(
                  header: true,
                  child: const Text(
                    'Tanggal transaksi',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  'Tanggal transaksi menentukan bulan laporan. Tanggal dokumen, '
                  'dicatat dan dibukukan disimpan terpisah.',
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
              ],
            ),
            BarisLentur(
              jarak: 28,
              anak: [
                Lentur(
                  dasar: 380,
                  maks: 460,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < kalender.length; i++) ...[
                        if (i > 0) const SizedBox(height: 14),
                        kalender[i],
                      ],
                    ],
                  ),
                ),
                Lentur(
                  dasar: 380,
                  tumbuh: 999,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      kartuRincian(context),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: sel != null
                            ? Tombol(
                                'Pakai $tglTeks',
                                onPressed: null,
                                ke: 'WebCatat',
                                cara: Cara.naik,
                                lebarPenuh: false,
                                paddingH: 20,
                              )
                            : const Tombol(
                                'Pilih tanggal dulu',
                                onPressed: null,
                                nonaktif: true,
                                lebarPenuh: false,
                                paddingH: 20,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ])
            // CSS half-leading (see tanggal.dart).
            DefaultTextStyle.merge(
              style: const TextStyle(
                leadingDistribution: TextLeadingDistribution.even,
              ),
              child: w,
            ),
        ],
      ),
    );
  }
}
