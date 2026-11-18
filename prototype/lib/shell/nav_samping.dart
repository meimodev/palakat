import 'package:flutter/widgets.dart';

import '../theme/palakat_tema.dart';
import '../widgets/logo.dart';
import '../widgets/tekan.dart';
import 'nav_item.dart';
import 'prototipe_state.dart';
import 'tautan.dart';

export 'nav_item.dart';

/// The boards' `@media (max-width:860px)`: the side nav becomes a top bar.
bool navSempit(BuildContext context) => MediaQuery.sizeOf(context).width <= 860;

/// Wide side-nav width: `flex: 1 1 220px` beside `main` `flex: 999 1 560px`
/// in a row [lebarHalaman] wide.
double lebarNav(double lebarHalaman) => 220 + (lebarHalaman - 780) / 1000;

/// Web side nav (components.md 4.3, navigation.md 1.3), identical on all 86
/// laptop and tablet boards. Wide: a full-height column (placed by
/// [HalamanWeb]). At 860 px and below: the top bar with the "Menu" toggle,
/// closed on every new page; while open, Back closes it first.
class NavSamping extends StatefulWidget {
  const NavSamping({
    super.key,
    required this.item,
    required this.aktif,
    required this.pengguna,
    this.diSini,
  });

  /// One of the `nav…` consts of nav_item.dart.
  final List<ItemNav> item;

  /// Index drawn active; null when the board highlights no item.
  final int? aktif;

  /// Footer block, for example [PenggunaKeuangan] or [PenggunaNav].
  final Widget pengguna;

  /// Passed to every item's [Tautan]: runs, instead of navigating, on an item
  /// whose `ke` is the page open now.
  final VoidCallback? diSini;

  @override
  State<NavSamping> createState() => _NavSampingState();
}

class _NavSampingState extends State<NavSamping> {
  bool _buka = false;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final sempit = navSempit(context);

    final merek = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const TandaPalakat(),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const KataPalakat(),
                Text(
                  'Jemaat Karunia',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final daftar = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.item.length; i++)
          Tautan(
            ke: widget.item[i].ke,
            cara: Cara.ganti,
            radius: 10,
            diSini: widget.diSini,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: i == widget.aktif ? c.tinta : null,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.item[i].teks,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: i == widget.aktif ? c.permukaan : c.tinta,
                ),
              ),
            ),
          ),
      ],
    );

    Widget kaki(EdgeInsets padding) => Container(
      padding: padding,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.garis)),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: 13, color: c.tinta2),
        child: widget.pengguna,
      ),
    );

    if (!sempit) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: c.permukaan,
          border: Border(right: BorderSide(color: c.garis)),
        ),
        // ponytail: scrolls inside its own column if the window is shorter
        // than the nav; the boards never are.
        child: LayoutBuilder(
          builder: (context, k) => SingleChildScrollView(
            primary: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: k.maxHeight.isFinite ? k.maxHeight : 0,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  // right 17: padding 16 inside the 1 px line (border-box)
                  padding: const EdgeInsets.fromLTRB(16, 24, 17, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(alignment: Alignment.centerLeft, child: merek),
                      const SizedBox(height: 20),
                      daftar,
                      const SizedBox(height: 20),
                      const Spacer(),
                      kaki(const EdgeInsets.fromLTRB(8, 12, 8, 0)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final tombol = Tekan(
      onTap: () => setState(() => _buka = !_buka),
      label: 'Menu',
      radius: 14,
      peran: PeranTekan.sakelar,
      tercentang: _buka,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _buka ? c.tinta : c.permukaan,
          border: Border.all(color: c.tinta, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          _buka ? 'Tutup menu' : 'Menu',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _buka ? c.permukaan : c.tinta,
          ),
        ),
      ),
    );

    return PopScope(
      canPop: !_buka,
      onPopInvokedWithResult: (sudah, _) {
        if (!sudah) setState(() => _buka = false);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: c.permukaan,
          border: Border(bottom: BorderSide(color: c.garis)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Align(alignment: Alignment.centerLeft, child: merek),
                ),
                const SizedBox(width: 12),
                tombol,
              ],
            ),
            if (_buka) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: daftar,
              ),
              kaki(const EdgeInsets.fromLTRB(8, 12, 8, 8)),
            ],
          ],
        ),
      ),
    );
  }
}

/// A footer line as the boards write it: **[tebal]**[biasa], then [baris2] on
/// its own line. Inherits 13 `tinta2` from the nav; [tebal] is 700 `tinta`.
class PenggunaNav extends StatelessWidget {
  const PenggunaNav({super.key, this.tebal, this.biasa = '', this.baris2});

  /// Name in `<strong>`: 'Meiske L.'.
  final String? tebal;

  /// Plain text after it: ' · Bendahara'.
  final String biasa;

  /// After the `<br>`: 'Wewenang Bendahara aktif'.
  final String? baris2;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        if (tebal != null)
          TextSpan(
            text: tebal,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: context.warna.tinta,
            ),
          ),
        TextSpan(text: biasa),
        if (baris2 != null) TextSpan(text: '\n$baris2'),
      ],
    ),
  );
}

/// The finance footer of 38 web boards (navigation.md 1.3, "Footer text"):
/// "**Meiske L.** · Bendahara / Wewenang Bendahara aktif", or with the global
/// `jabatanKosong` switch on "**Yanti Sumual** · Operator / Menjalankan
/// jabatan kosong Bendahara Jemaat". Boards without the tweak pass
/// `ikutJabatanKosong: false`.
class PenggunaKeuangan extends StatelessWidget {
  const PenggunaKeuangan({super.key, this.ikutJabatanKosong = true});
  final bool ikutJabatanKosong;

  @override
  Widget build(BuildContext context) =>
      ikutJabatanKosong &&
          (PrototypeState.maybeOf(context)?.jabatanKosong ?? false)
      ? const PenggunaNav(
          tebal: 'Yanti Sumual',
          biasa: ' · Operator',
          baris2: 'Menjalankan jabatan kosong Bendahara Jemaat',
        )
      : const PenggunaNav(
          tebal: 'Meiske L.',
          biasa: ' · Bendahara',
          baris2: 'Wewenang Bendahara aktif',
        );
}
