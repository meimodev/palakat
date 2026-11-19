import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import 'warta_arsip_bagian.dart';

/// Web · Warta Jemaat (spec 18-wartaeditor.md, WebWartaArsip).
class WebWartaArsipScreen extends StatefulWidget {
  const WebWartaArsipScreen({super.key});
  @override
  State<WebWartaArsipScreen> createState() => _WebWartaArsipScreenState();
}

class _WebWartaArsipScreenState extends State<WebWartaArsipScreen>
    with KeadaanWartaArsip {
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final ki = keadaan('WebWartaArsip');
    final judul = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Inline 14/1.45 link (20.3 high) inside a 44 px target; the line
        // box keeps the 15/1.45 strut (21.75), so 1.45 more below the text.
        MarginNegatif(
          atas: 11.85,
          bawah: 10.4,
          child: Tautan(
            ke: 'WebBerandaJabatan',
            cara: Cara.naik,
            child: const SizedBox(
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
          child: Text(
            'Warta Jemaat',
            style: PalakatText.judulHalaman.copyWith(color: c.tinta),
          ),
        ),
        Text(
          'Edisi yang sudah diterbitkan, persis seperti saat diterbitkan',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
      ],
    );
    final daftar = Kartu(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, r) in edisiWarta.indexed)
              // Each row links to this same board: a self link, nothing happens.
              Tautan(
                ke: 'WebWartaArsip',
                child: Container(
                  // The first row's top rule hides under the card edge.
                  decoration: BoxDecoration(
                    border: i == 0
                        ? null
                        : Border(top: BorderSide(color: c.garis)),
                  ),
                  constraints: BoxConstraints(minHeight: i == 0 ? 68 : 69),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _Edisi(r)),
                      const SizedBox(width: 16),
                      LencanaStatus(r.l, bentuk: r.bentuk),
                      const SizedBox(width: 16),
                      const SizedBox(
                        width: 20,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ChevronWarta(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    return HalamanWeb(
      nav: const NavSamping(
        item: navPlatform,
        aktif: 4,
        pengguna: PenggunaNav(
          tebal: 'Olvie Pangemanan',
          biasa: ' · Sekretaris Jemaat',
        ),
      ),
      isi: [
        judul,
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: kolomWarta(
              isiWartaArsip(
                context,
                ki: ki,
                daftar: daftar,
                susun: tombolWarta(
                  const Tombol(
                    'Susun edisi 22/11/2026',
                    jenis: JenisTombol.tinta,
                    ke: 'WebWartaEditor',
                    onPressed: null,
                  ),
                ),
                susunPertama: tombolWarta(
                  const Tombol(
                    'Susun edisi pertama',
                    jenis: JenisTombol.tinta,
                    ke: 'WebWartaEditor',
                    onPressed: null,
                  ),
                ),
                onUnduh: go1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Column 1: edition (flex 1 1 260) and published line (flex 1.4 1 300),
/// wrap, baseline, gap 2 / 20.
class _Edisi extends StatelessWidget {
  const _Edisi(this.r);
  final EdisiWarta r;

  @override
  Widget build(BuildContext context) {
    final j = Text(r.j, style: const TextStyle(fontWeight: FontWeight.w600));
    final s = Text(
      r.s,
      style: TextStyle(fontSize: 13, color: context.warna.tinta3),
    );
    return LayoutBuilder(
      builder: (context, k) {
        final b = BarisLentur.lebar(
          [
            Lentur(dasar: 260, child: j),
            Lentur(dasar: 300, tumbuh: 1.4, child: s),
          ],
          20,
          k.maxWidth,
        );
        if (b.length > 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [j, const SizedBox(height: 2), s],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            SizedBox(width: b[0][0], child: j),
            const SizedBox(width: 20),
            SizedBox(width: b[0][1], child: s),
          ],
        );
      },
    );
  }
}
