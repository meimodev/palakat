import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/palakat_tema.dart';
import '../widgets/logo.dart';
import '../widgets/tekan.dart';
import 'nav_item.dart';
import '../providers/actor.dart';
import '../providers/session.dart';
import 'tautan.dart';
import '../providers/layout.dart';

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
class NavSamping extends ConsumerStatefulWidget {
  const NavSamping({
    super.key,
    required this.item,
    required this.aktif,
    this.diSini,
  });

  /// One of the `nav…` consts of nav_item.dart.
  final List<ItemNav> item;

  /// Index drawn active; null when the board highlights no item.
  final int? aktif;

  /// Passed to every item's [Tautan]: runs, instead of navigating, on an item
  /// whose `ke` is the page open now.
  final VoidCallback? diSini;

  @override
  ConsumerState<NavSamping> createState() => _NavSampingState();
}

class _NavSampingState extends ConsumerState<NavSamping> {
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
            // CSS half-leading: 'palakat' (line-height 1.1) and the 13 px line.
            child: DefaultTextStyle.merge(
              style: const TextStyle(
                leadingDistribution: TextLeadingDistribution.even,
              ),
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
          ),
        ],
      ),
    );

    final daftar = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.item.length; i++)
          // An item to a screen this layout lacks is left out (D13): the
          // web Excel pages on a phone have no "Laporan" (WebPaketLaporan).
          if (widget.item[i].ke.adaUntuk(ref.watch(layoutProvider)))
            Tautan(
              ke: widget.item[i].ke,
              anak: widget.item[i].anak,
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
        child: const PenggunaSesi(),
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
          // HalamanWeb may give the bar extra height (the boards' flex-line
          // stretch); each wrapped line takes an equal share, centred.
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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

/// The footer from the session (navigation.md 1.3, README 5.2): the
/// persona's line, or the vacancy footer while the actor covers the vacant
/// Bendahara post (D18).
class PenggunaSesi extends ConsumerWidget {
  const PenggunaSesi({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final j = ref.watch(jabatanDijalankanProvider);
    if (j != null) {
      return PenggunaNav(
        tebal: j.operator,
        biasa: ' · Operator',
        baris2: 'Menjalankan jabatan kosong ${j.jabatan}',
      );
    }
    final p = ref.watch(sessionProvider)?.persona;
    if (p == null) return const PenggunaNav(biasa: 'Belum masuk');
    final k = p.kaki;
    if (k == null) return PenggunaNav(tebal: p.nama, biasa: ' · ${p.jabatan}');
    // The persona's post line while they act in that post; otherwise what
    // they act as now (another post, or a member after the term ended).
    final a = ref.watch(actorProvider);
    final sebagai = a == null
        ? null
        : ref
              .watch(canProvider)
              .grantsOf(a.personId, at: ref.watch(hariIniProvider))
              .where((g) => g.toActor() == a)
              .firstOrNull
              ?.title;
    if (k.$2.startsWith(' · ') &&
        sebagai != null &&
        !p.jabatan.startsWith(sebagai)) {
      return PenggunaNav(tebal: k.$1 ?? p.nama, biasa: ' · $sebagai');
    }
    return PenggunaNav(tebal: k.$1, biasa: k.$2, baris2: k.$3);
  }
}
