import 'package:flutter/widgets.dart';

import '../../mock/mock.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import 'kotak_masuk.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// Web · Pemberitahuan (spec 14-berandajabatan.md, WebKotakMasuk): the
/// notification box of the platform web nav, same sets as KotakMasuk.
class WebKotakMasukScreen extends StatelessWidget {
  const WebKotakMasukScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final keadaan = belumDipindah<String>('Ada pemberitahuan');
    const a = kotakMasukAda, k1 = kotakMasukKeuangan;
    // Row targets are the logic class's hal(n) with web = true.
    final (tindak, tahu) = switch (keadaan) {
      'Semua sudah selesai' => (const <_Baris>[], const <_Baris>[]),
      'Hanya modul Keuangan' => (
        [_Baris(k1.tindak[0]), _Baris(k1.tindak[1])],
        [_Baris(k1.tahu[0])],
      ),
      _ => (
        [_Baris(a.tindak[0]), _Baris(a.tindak[1])],
        [_Baris(a.tahu[0]), _Baris(a.tahu[1])],
      ),
    };
    final ada = keadaan != 'Semua sudah selesai';

    return HalamanWeb(
      nav: const NavSamping(item: navPlatform, aktif: 6),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 44 px target on the div's 15 × 1.45 = 21.75 px line box (the
            // strut of the 15 px parent, not the 14 px link): the rest overlaps.
            MarginNegatif(
              atas: 11.125,
              bawah: 11.125,
              child: Tautan(
                ke: Layar.beranda,
                cara: Cara.naik,
                child: const Align(
                  widthFactor: 1,
                  alignment: Alignment.centerLeft,
                  child: TautanTeks('Beranda', ukuran: 14),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: Text(
                'Pemberitahuan',
                style: PalakatText.judulHalaman.copyWith(color: c.tinta),
              ),
            ),
            Text(
              'Satu kotak untuk semua modul yang aktif',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                if (ada)
                  BarisLentur(
                    jarak: 28,
                    jarakBaris: 20,
                    anak: [
                      Lentur(
                        dasar: 420,
                        tumbuh: 1.3,
                        child: _Kolom('Perlu tindakan', tindak),
                      ),
                      Lentur(
                        dasar: 340,
                        child: _Kolom('Untuk diketahui', tahu),
                      ),
                    ],
                  )
                else
                  const KotakKosong(),
                const CatatanKotakMasuk(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Heading and its list box: `permukaan`, 1 px `garis`, radius 14, a rule
/// between rows.
class _Kolom extends StatelessWidget {
  const _Kolom(this.judul, this.baris);

  final String judul;
  final List<_Baris> baris;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        JudulKotak(judul),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: c.permukaan,
            border: Border.all(color: c.garis),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < baris.length; i++)
                if (i == 0)
                  baris[i]
                else
                  // Container, not DecoratedBox: the rule takes its own pixel.
                  Container(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: c.garis)),
                    ),
                    child: baris[i],
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

/// List-box row: grid `1fr auto 20px`, gap 16, centred, min height 52
/// (content box), padding 8 18; title 600 and subtitle 13 `tinta3` wrap
/// (`flex 1 1 260` / `1.4 1 300`, gap 2 20).
class _Baris extends StatelessWidget {
  const _Baris(this.r);

  final ItemKotak r;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tautan(
      ke: r.ke,
      param: r.param,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Row(
            spacing: 16,
            children: [
              Expanded(
                child: BarisLentur(
                  jarak: 20,
                  jarakBaris: 2,
                  anak: [
                    Lentur(
                      dasar: 260,
                      child: Text(
                        r.judul,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Lentur(
                      dasar: 300,
                      tumbuh: 1.4,
                      child: Text(
                        r.sub,
                        style: TextStyle(fontSize: 13, color: c.tinta3),
                      ),
                    ),
                  ],
                ),
              ),
              if (r.label != null)
                LencanaStatus(
                  r.label!,
                  bentuk: (r.gaya ?? GayaLabel.garis).bentuk,
                )
              else
                const SizedBox.shrink(),
              SizedBox(
                width: 20,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
