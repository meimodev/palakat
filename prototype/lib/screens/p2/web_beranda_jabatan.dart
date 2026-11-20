import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../providers/home_rows.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/bertindak_sebagai.dart';
import '../../widgets/garis.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'beranda_jabatan_isi.dart';

/// Web · Beranda: the combined Beranda on the laptop and the tablet, home of
/// every platform web screen (merged with AlurBeranda, README 7.1).
class WebBerandaJabatanScreen extends ConsumerStatefulWidget {
  const WebBerandaJabatanScreen({super.key});

  @override
  ConsumerState<WebBerandaJabatanScreen> createState() =>
      _WebBerandaJabatanScreenState();
}

class _WebBerandaJabatanScreenState
    extends ConsumerState<WebBerandaJabatanScreen> {
  final _scroll = ScrollController();

  /// The breadcrumb and the active nav item link to this same screen: they
  /// scroll the page to the top.
  void _keAtas() {
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final b = bacaBeranda(ref);
    // HalamanWeb's page scroll view inherits this controller (scroll to top).
    return KeluarSaatKembali(
      child: PrimaryScrollController(
        controller: _scroll,
        automaticallyInheritForPlatforms: TargetPlatform.values.toSet(),
        child: HalamanWeb(
          nav: NavSamping(item: navPlatform, aktif: 0, diSini: _keAtas),
          isi: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Inline link, 21.75 high on the board; the 44 target overhangs.
                MarginNegatif(
                  atas: 11.125,
                  bawah: 11.125,
                  child: Tautan(
                    ke: Layar.beranda,
                    cara: Cara.naik,
                    diSini: _keAtas,
                    child: const SizedBox(
                      height: 44,
                      child: Align(
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
                    'Beranda',
                    style: PalakatText.judulHalaman.copyWith(color: c.tinta),
                  ),
                ),
                Text(
                  'Satu Beranda untuk semua jabatan Anda',
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
                  children: bersela([
                    DaftarJabatan(nama: b.nama, jabatan: b.jabatan),
                    if (b.perluMemilih)
                      ...isiPilihJabatan(ref, b.pilihan)
                    else
                      ..._daftar(b),
                  ], 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The two columns, caption and "Akun saya". homeRowsProvider already
  /// leaves out rows to phone-only screens (README 7.1 rule 4).
  List<Widget> _daftar(IsiBeranda b) {
    Widget kolom(String judul, List<HomeRow> baris) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        JudulBagian(judul),
        const SizedBox(height: 12),
        _KotakDaftar(baris),
      ],
    );
    return [
      BarisLentur(
        jarak: 28,
        jarakBaris: 20,
        anak: [
          Lentur(
            dasar: 420,
            tumbuh: 1.3,
            child: b.tindak.isEmpty
                ? const KartuKosong()
                : kolom('Perlu tindakan', b.tindak),
          ),
          if (b.tahu.isNotEmpty)
            Lentur(dasar: 340, child: kolom('Untuk diketahui', b.tahu)),
        ],
      ),
      const Keterangan(kalimatBeranda),
      const TautanAkunSaya(),
    ];
  }
}

/// The list box (shared look with WebKotakMasuk): rows split by 1 px rules,
/// none above the first.
class _KotakDaftar extends StatelessWidget {
  const _KotakDaftar(this.baris);
  final List<HomeRow> baris;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, b) in baris.indexed) _Baris(b, pertama: i == 0),
        ],
      ),
    );
  }
}

class _Baris extends StatelessWidget {
  const _Baris(this.r, {required this.pertama});
  final HomeRow r;
  final bool pertama;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final judul = Text(
      r.judul,
      style: const TextStyle(fontWeight: FontWeight.w600),
    );
    final sub = Text(r.sub, style: TextStyle(fontSize: 13, color: c.tinta3));
    return Tautan(
      ke: r.ke,
      param: r.param,
      child: Container(
        // `<a>` is content-box: min-height 52 + padding 16 + the 1 px rule
        // (the first row's rule is hidden above the box).
        constraints: BoxConstraints(minHeight: pertama ? 68 : 69),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: pertama
            ? null
            : BoxDecoration(
                border: Border(top: BorderSide(color: c.garis)),
              ),
        child: Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, k) {
                  // flex-wrap: title (basis 260) and subtitle (basis 300,
                  // grow 1.4) share a baseline when both fit, gap 20.
                  if (k.maxWidth < 580) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [judul, const SizedBox(height: 2), sub],
                    );
                  }
                  final w = BarisLentur.lebar(
                    [
                      Lentur(dasar: 260, child: judul),
                      Lentur(dasar: 300, tumbuh: 1.4, child: sub),
                    ],
                    20,
                    k.maxWidth,
                  ).first;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      SizedBox(width: w[0], child: judul),
                      const SizedBox(width: 20),
                      SizedBox(width: w[1], child: sub),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            ?lencanaBaris(r),
            const SizedBox(width: 16),
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
    );
  }
}
