import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/bilah_ponsel.dart';
import '../theme/palakat_tema.dart';
import '../widgets/ikon.dart';
import 'tautan.dart';
import '../app/layar.dart';

enum TabPonsel { beranda, transaksi, bulan, lainnya }

/// One column of a phone bottom bar: icon and label, drawn `laut` and
/// `Semantics(selected: true)` while [aktif]. [bungkus] makes it a link or
/// a button (null: a plain label). A [lingkaran] item is the raised circle:
/// its [teks] goes to the wrapper's Semantics label, and [label] is the
/// short word drawn under it (owner request; the boards draw the circle
/// bare).
class ItemBilah {
  const ItemBilah({
    required this.ikon,
    required this.teks,
    this.aktif = false,
    this.bungkus,
    this.lingkaran = false,
    this.label,
  });

  /// The visible word under the raised circle.
  final String? label;

  final IkonData ikon;
  final String teks;
  final bool aktif;
  final Widget Function(Widget isi)? bungkus;
  final bool lingkaran;
}

/// The phone bottom bar (components.md 4.2, navigation.md 1.1): the finance
/// tab bar's look and geometry for any list of items, equal columns. Put it
/// in a [LayarPonsel] Stack (`overlay`) or a screen Stack: it aligns itself
/// to the bottom. Its box is 13 px taller than the 84 px bar, so the lifted
/// circle stays tappable; the rest of that strip lets taps through.
class BilahPonsel extends StatelessWidget {
  const BilahPonsel({
    super.key,
    required this.item,
    this.diameterLingkaran = 58,
  });

  final List<ItemBilah> item;

  /// Outer size, ring included: Main 58 (border-box), Lainnya 66 (content-box).
  final double diameterLingkaran;

  /// Bar top below the box top: circle `margin-top: -22px` from the content
  /// edge (1 px line + 8 px padding).
  static const double _angkat = 22 - 9;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;

    Widget kolom(ItemBilah i) {
      if (i.lingkaran) {
        final lingkaran = Container(
          width: diameterLingkaran,
          height: diameterLingkaran,
          decoration: BoxDecoration(
            color: c.laut,
            shape: BoxShape.circle,
            border: Border.all(color: c.kertas, width: 4),
          ),
          alignment: Alignment.center,
          child: PalakatIkon(i.ikon, ukuran: 24, tebal: 2.4, warna: c.diLaut),
        );
        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              i.bungkus?.call(lingkaran) ?? lingkaran,
              if (i.label case final l?)
                // The circle already carries the Semantics label.
                ExcludeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      l,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.tinta3,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }
      final warna = i.aktif ? c.laut : c.tinta3;
      final isi = Semantics(
        selected: i.aktif ? true : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: double.infinity,
            minHeight: 52,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PalakatIkon(i.ikon, ukuran: 22, tebal: 2, warna: warna),
              const SizedBox(height: 3),
              Text(
                i.teks,
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
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: _angkat + 9),
          child: i.bungkus?.call(isi) ?? isi,
        ),
      );
    }

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
                children: [for (final i in item) kolom(i)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The phone finance tab bar (navigation.md 1.1), drawn on Main's Beranda
/// and Transaksi views and on the finance Lainnya hub: Beranda · Transaksi ·
/// Catat circle · Bulan · Lainnya.
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

  @override
  Widget build(BuildContext context) => BilahPonsel(
    diameterLingkaran: diameterCatat,
    item: [
      ItemBilah(
        ikon: Ikon.beranda,
        teks: 'Beranda',
        aktif: aktif == TabPonsel.beranda,
        bungkus: beranda,
      ),
      ItemBilah(
        ikon: Ikon.transaksi,
        teks: 'Transaksi',
        aktif: aktif == TabPonsel.transaksi,
        bungkus: transaksi,
      ),
      ItemBilah(
        ikon: Ikon.tambah,
        teks: 'Catat transaksi',
        label: 'Catat',
        lingkaran: true,
        bungkus: catat,
      ),
      ItemBilah(
        ikon: Ikon.bulan,
        teks: 'Bulan',
        aktif: aktif == TabPonsel.bulan,
        bungkus: (isi) =>
            Tautan(ke: Layar.tutupBuku, cara: Cara.ganti, child: isi),
      ),
      ItemBilah(
        ikon: Ikon.lainnya,
        teks: 'Lainnya',
        aktif: aktif == TabPonsel.lainnya,
        bungkus: aktif == TabPonsel.lainnya
            ? null
            : (isi) =>
                  Tautan(ke: Layar.pengaturan, cara: Cara.ganti, child: isi),
      ),
    ],
  );
}

/// Where the non-finance bar is drawn: the home or the Lainnya hub.
enum TabBeranda { beranda, lainnya }

/// The bottom bar of a phone home that is not the finance home (owner change
/// 21/11, README 7.3): Beranda · {module tab} · {raised action} · Kotak
/// masuk · Lainnya, the module tab and the action from [bilahPonselProvider];
/// a slot it leaves out is not drawn. Every item opens with `Cara.ganti`.
class BilahBeranda extends ConsumerWidget {
  const BilahBeranda({super.key, required this.aktif});

  final TabBeranda aktif;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = ref.watch(bilahPonselProvider);
    Widget Function(Widget) ke(Layar l, {String? anak, String? label}) =>
        (isi) => Tautan(
          ke: l,
          anak: anak,
          cara: Cara.ganti,
          label: label,
          radius: label == null ? 0 : 29,
          child: isi,
        );
    return BilahPonsel(
      item: [
        ItemBilah(
          ikon: Ikon.beranda,
          teks: 'Beranda',
          aktif: aktif == TabBeranda.beranda,
          bungkus: aktif == TabBeranda.beranda ? null : ke(Layar.beranda),
        ),
        if (b.tab case final t?)
          ItemBilah(
            ikon: t.ikon,
            teks: t.teks,
            bungkus: ke(t.ke, anak: t.anak),
          ),
        if (b.aksi case final a?)
          ItemBilah(
            ikon: a.ikon,
            teks: a.teks,
            label: a.teks,
            lingkaran: true,
            bungkus: ke(a.ke, anak: a.anak, label: a.teks),
          ),
        ItemBilah(
          ikon: Ikon.kotakMasuk,
          teks: 'Kotak masuk',
          bungkus: ke(Layar.kotakMasuk),
        ),
        ItemBilah(
          ikon: Ikon.lainnya,
          teks: 'Lainnya',
          aktif: aktif == TabBeranda.lainnya,
          bungkus: aktif == TabBeranda.lainnya ? null : ke(Layar.lainnya),
        ),
      ],
    );
  }
}
