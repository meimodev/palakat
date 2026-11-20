import 'package:flutter/material.dart';

import '../../mock/mock.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import 'kejadian_bagian.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// Web · Kejadian setelah tutup buku (07-kejadian.md): list and detail side
/// by side under the standard side nav.
class WebKejadianScreen extends StatefulWidget {
  const WebKejadianScreen({super.key});
  @override
  State<WebKejadianScreen> createState() => _WebKejadianScreenState();
}

class _WebKejadianScreenState extends State<WebKejadianScreen> {
  final _s = KeadaanKejadian();

  @override
  void dispose() {
    _s.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hambat = belumDipindah<bool>(true);
    return ListenableBuilder(
      listenable: _s,
      builder: (context, _) => HalamanWeb(
        layarKeuangan: true,
        nav: const NavSamping(item: navKeuangan, aktif: 4),
        isi: [
          _Judul(),
          if (hambat) const PernyataanHambatan(),
          BarisLentur(
            jarak: 24,
            anak: [
              Lentur(dasar: 360, child: _Daftar(s: _s)),
              Lentur(
                dasar: 520,
                tumbuh: 999,
                child: RinciKejadian(s: _s, hambat: hambat),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Judul extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // A 44 px target drawn in the board's 15 × 1.45 line.
      const MarginNegatif(
        atas: (44 - 15 * 1.45) / 2,
        bawah: (44 - 15 * 1.45) / 2,
        child: Tautan(
          ke: Layar.tutupBuku,
          cara: Cara.naik,
          child: SizedBox(
            height: 44,
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: 1,
              child: TautanTeks('Bulan dan tutup buku', ukuran: 14),
            ),
          ),
        ),
      ),
      const SizedBox(height: 2),
      Semantics(
        header: true,
        child: const Text(
          'Kejadian setelah tutup buku',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}

class _Daftar extends StatelessWidget {
  const _Daftar({required this.s});
  final KeadaanKejadian s;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final k in kejadian)
              Tekan(
                dipilih: k.no == s.pilih,
                onTap: () => s.pick(k.no),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: k.no == s.pilih ? c.lautLembut : c.permukaan,
                    border: Border(top: BorderSide(color: c.garis)),
                  ),
                  // `box-shadow: inset 3px 0 0 laut` on the chosen row.
                  foregroundDecoration: k.no == s.pilih
                      ? BoxDecoration(
                          border: Border(
                            left: BorderSide(color: c.laut, width: 3),
                          ),
                        )
                      : null,
                  child: IsiKartuKejadian(k: k, selesai: s.sel(k).isNotEmpty),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
