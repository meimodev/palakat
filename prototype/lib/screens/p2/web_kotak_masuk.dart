import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/core/core.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tata_letak.dart';
import 'kotak_masuk.dart';
import '../../app/layar.dart';

/// Web · Pemberitahuan (spec 14-berandajabatan.md, WebKotakMasuk): the
/// notification box of the platform web nav, the same inbox as KotakMasuk.
class WebKotakMasukScreen extends ConsumerWidget {
  const WebKotakMasukScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final (tindak, tahu) = kotakMasukDari(ref);
    final ada = tindak.isNotEmpty || tahu.isNotEmpty;

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
                    // An empty list leaves its column out.
                    anak: [
                      if (tindak.isNotEmpty)
                        Lentur(
                          dasar: 420,
                          tumbuh: 1.3,
                          child: _Kolom('Perlu tindakan', tindak),
                        ),
                      if (tahu.isNotEmpty)
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
  final List<AppNotification> baris;

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
                  _Baris(baris[i])
                else
                  // Container, not DecoratedBox: the rule takes its own pixel.
                  Container(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: c.garis)),
                    ),
                    child: _Baris(baris[i]),
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
class _Baris extends ConsumerWidget {
  const _Baris(this.n);

  final AppNotification n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    return Tekan(
      onTap: () => bukaKabar(context, ref, n),
      peran: PeranTekan.tautan,
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
                        n.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Lentur(
                      dasar: 300,
                      tumbuh: 1.4,
                      child: Text(
                        subKabar(n),
                        style: TextStyle(fontSize: 13, color: c.tinta3),
                      ),
                    ),
                  ],
                ),
              ),
              lencanaKabar(n),
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
