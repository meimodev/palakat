import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import 'cari_orang.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// The rows' web targets (`hal()` with `web = true`), by index. A row to a
/// phone-only screen is left out on the web (README 7.1 rule 4).
const _tujuanWeb = [
  (ke: Layar.dataAnggota),
  (ke: Layar.dataAnggota),
  (ke: Layar.konfirmasiKeluarga),
  (ke: Layar.surat),
  (ke: Layar.keuangan),
];

class WebCariOrangScreen extends StatelessWidget {
  const WebCariOrangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final ki = indeksCariOrang(belumDipindah<String>('Dilihat Operator'));
    final n = jumlahCariOrang(ki);

    final isi = <Widget>[
      IsianCariOrang(ki == 2 ? 'Rumengan' : 'Wenas'),
      if (ki != 2) ...[
        Text(
          '$n hasil untuk “Wenas”',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
        _Tabel(n),
      ],
      if (ki == 0)
        TautanPulihkan(
          tautan: (isi) => Tautan(ke: Layar.cariOrang, child: isi),
        ),
      if (ki == 2) const KosongCariOrang(),
      const CatatanCariOrang(),
    ];

    return HalamanWeb(
      nav: const NavSamping(item: navPlatform, aktif: 0),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 44 px target, drawn as the board's line: the inline 14 px link
            // sits on the div's 15/1.45 strut.
            const MarginNegatif(
              atas: (44 - 15 * 1.45) / 2,
              bawah: (44 - 15 * 1.45) / 2,
              child: Tautan(
                ke: Layar.beranda,
                cara: Cara.naik,
                child: SizedBox(
                  height: 44,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1,
                    child: TautanTeks('Beranda', ukuran: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: const Text(
                'Cari orang',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              'Hasil hanya dari modul aktif dan dari yang boleh Anda lihat',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < isi.length; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
                  isi[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The results card: rows under a 1 px `garis` rule each, the first rule
/// hidden under the card's top line. Each row is its own grid
/// `[1fr | auto | 20]`, gap 16, so the badge column is that row's badge.
class _Tabel extends StatelessWidget {
  const _Tabel(this.n);
  final int n;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final hasil = hasilCariOrang.take(n).toList();
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < hasil.length; i++)
            if (_tujuanWeb[i].ke.web)
              Tautan(
                ke: _tujuanWeb[i].ke,
                child: Container(
                  // content min 52 + padding 16 (+ the rule)
                  constraints: BoxConstraints(minHeight: i == 0 ? 68 : 69),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: i == 0
                      ? null
                      : BoxDecoration(
                          border: Border(top: BorderSide(color: c.garis)),
                        ),
                  child: Row(
                    children: [
                      Expanded(child: _NamaKonteks(hasil[i])),
                      const SizedBox(width: 16),
                      if (hasil[i].l.isNotEmpty)
                        LencanaStatus(hasil[i].l, bentuk: hasil[i].b),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 20,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: PalakatIkon(
                            Ikon.lanjut,
                            ukuran: 18,
                            warna: c.tinta3,
                          ),
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
}

/// Name 15/600 (`flex: 1 1 260px`) and context 13 `tinta3`
/// (`flex: 1.4 1 300px`) in a wrapping row, gap 2 20, baseline-aligned.
class _NamaKonteks extends StatelessWidget {
  const _NamaKonteks(this.r);
  final HasilCari r;

  @override
  Widget build(BuildContext context) {
    final nama = Text(r.j, style: const TextStyle(fontWeight: FontWeight.w600));
    final konteks = Text(
      r.s,
      style: TextStyle(fontSize: 13, color: context.warna.tinta3),
    );
    return LayoutBuilder(
      builder: (context, k) {
        final baris = BarisLentur.lebar(
          [
            Lentur(dasar: 260, child: nama),
            Lentur(dasar: 300, tumbuh: 1.4, child: konteks),
          ],
          20,
          k.maxWidth,
        );
        if (baris.length > 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [nama, const SizedBox(height: 2), konteks],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            SizedBox(width: baris[0][0], child: nama),
            const SizedBox(width: 20),
            SizedBox(width: baris[0][1], child: konteks),
          ],
        );
      },
    );
  }
}
