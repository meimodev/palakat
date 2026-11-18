import 'package:flutter/widgets.dart';

import '../theme/palakat_tema.dart';
import '../widgets/ikon.dart';
import 'tautan.dart';

enum TabPonsel { beranda, transaksi, bulan, lainnya }

/// The phone finance tab bar (components.md 4.2, navigation.md 1.1), drawn
/// only on Main and Lainnya. Put it in the [LayarPonsel] Stack (`overlay`):
/// it aligns itself to the bottom. Its box is 13 px taller than the 84 px bar,
/// so the lifted Catat circle stays tappable; the rest of that strip lets
/// taps through.
class PonselTabBar extends StatelessWidget {
  const PonselTabBar({
    super.key,
    required this.aktif,
    this.beranda,
    this.transaksi,
    this.catat,
    this.diameterCatat = 58,
  });

  /// Drawn `laut` and `Semantics(selected: true)`.
  final TabPonsel aktif;

  /// Wrap the drawn item (icon + label); null draws it unwrapped.
  final Widget Function(Widget isi)? beranda;
  final Widget Function(Widget isi)? transaksi;

  /// Wraps the circle.
  final Widget Function(Widget isi)? catat;

  /// Outer size, ring included: Main 58 (border-box), Lainnya 66 (content-box).
  final double diameterCatat;

  /// Bar top below the box top: circle `margin-top: -22px` from the content
  /// edge (1 px line + 8 px padding).
  static const double _angkat = 22 - 9;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;

    Widget item(IkonData ikon, String teks, TabPonsel tab) {
      final warna = tab == aktif ? c.laut : c.tinta3;
      return Semantics(
        selected: tab == aktif ? true : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: double.infinity,
            minHeight: 52,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PalakatIkon(ikon, ukuran: 22, warna: warna),
              const SizedBox(height: 3),
              Text(
                teks,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: warna,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget bungkus(Widget Function(Widget)? b, Widget isi) =>
        b == null ? isi : b(isi);

    final lingkaran = Container(
      width: diameterCatat,
      height: diameterCatat,
      decoration: BoxDecoration(
        color: c.laut,
        shape: BoxShape.circle,
        border: Border.all(color: c.kertas, width: 4),
      ),
      alignment: Alignment.center,
      child: PalakatIkon(Ikon.tambah, ukuran: 24, tebal: 2.4, warna: c.diLaut),
    );

    final lainnya = item(Ikon.lainnya, 'Lainnya', TabPonsel.lainnya);
    Widget kolom(Widget w) => Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: _angkat + 9),
        child: w,
      ),
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 84 + _angkat,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 84,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: c.permukaan,
                  border: Border(top: BorderSide(color: c.garis)),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kolom(
                    bungkus(
                      beranda,
                      item(Ikon.beranda, 'Beranda', TabPonsel.beranda),
                    ),
                  ),
                  kolom(
                    bungkus(
                      transaksi,
                      item(Ikon.transaksi, 'Transaksi', TabPonsel.transaksi),
                    ),
                  ),
                  Expanded(child: Center(child: bungkus(catat, lingkaran))),
                  kolom(
                    Tautan(
                      ke: 'TutupBuku',
                      cara: Cara.ganti,
                      child: item(Ikon.bulan, 'Bulan', TabPonsel.bulan),
                    ),
                  ),
                  kolom(
                    aktif == TabPonsel.lainnya
                        ? lainnya
                        : Tautan(
                            ke: 'Lainnya',
                            cara: Cara.ganti,
                            child: lainnya,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
