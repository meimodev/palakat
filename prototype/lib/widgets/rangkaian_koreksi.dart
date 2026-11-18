import 'package:flutter/material.dart';

import '../motion/kerangka.dart';
import '../theme/palakat_tema.dart';
import 'garis.dart';
import 'lencana_status.dart';

/// One card of the chain: the reversed transaction ([dibalik]: 1.5 `tinta3`
/// line, `garis` badge) or the reversal / correction (1.5 `tinta`, `tinta`
/// badge).
class KartuRangkaian {
  const KartuRangkaian({
    required this.noBukti,
    required this.lencana,
    this.judul,
    this.jumlah,
    this.keterangan,
    this.dibalik = false,
    this.tundaMuncul,
  });

  /// 'BKU-2026-0144' or, in the preview form, 'BKU-2026-0144 · Pembalikan'.
  final String noBukti;

  /// 'Dibalik', 'Dibukukan'.
  final String lencana;

  /// WebKoreksi body: 'Pembalikan' (600) and the amount as shown
  /// ('−Rp750.000', mono 500), then [keterangan] 13 `tinta3`.
  final String? judul, jumlah, keterangan;
  final bool dibalik;

  /// WebKoreksi: the card enters with `muncul` 400 ms after this delay
  /// (pembalikan 200 ms, koreksi 600 ms); null = no entrance.
  final Duration? tundaMuncul;
}

/// Two or three linked cards: dibalik, pembalikan, koreksi. Cards
/// `permukaan`, radius 14, padding 10 14 (preview) or 12 16 ([web]); the
/// link between them is a 2 × 16 (web 18) `tinta` line, 28 from the left.
/// Nothing is deleted: the reversed one stays with its Dibalik badge.
class RangkaianKoreksi extends StatelessWidget {
  const RangkaianKoreksi({super.key, required this.kartu, this.web = false});

  final List<KartuRangkaian> kartu;
  final bool web;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (i, k) in kartu.indexed) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 2,
                  height: web ? 18 : 16,
                  child: ColoredBox(color: c.tinta),
                ),
              ),
            ),
          _muncul(k, _Kartu(k, web: web)),
        ],
      ],
    );
  }

  Widget _muncul(KartuRangkaian k, Widget w) => k.tundaMuncul == null
      ? w
      : Gerak(
          Kerangka.muncul,
          lama: const Duration(milliseconds: 400),
          tunda: k.tundaMuncul!,
          child: w,
        );
}

class _Kartu extends StatelessWidget {
  const _Kartu(this.k, {required this.web});
  final KartuRangkaian k;
  final bool web;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    const mono = TextStyle(
      fontFamily: PalakatText.mono,
      fontFeatures: [FontFeature.tabularFigures()],
    );
    return Container(
      padding: web
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
          : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: GarisBorder.penuh(k.dibalik ? c.tinta3 : c.tinta, radius: 14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  k.noBukti,
                  style: mono.copyWith(fontSize: 13, color: c.tinta2),
                ),
              ),
              const SizedBox(width: 16),
              if (k.dibalik)
                LencanaStatus(k.lencana, bentuk: BentukLencana.garis)
              else
                // The boards draw this one without a line (padding 3 9 only).
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: c.tinta,
                    borderRadius: BorderRadius.circular(PalakatRadius.lencana),
                  ),
                  child: Text(
                    k.lencana,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: c.permukaan,
                    ),
                  ),
                ),
            ],
          ),
          if (k.judul != null || k.jumlah != null) ...[
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    k.judul ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 16),
                if (k.jumlah != null)
                  Text(
                    k.jumlah!,
                    style: mono.copyWith(fontWeight: FontWeight.w500),
                  ),
              ],
            ),
          ],
          if (k.keterangan != null)
            Text(
              k.keterangan!,
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
        ],
      ),
    );
  }
}
