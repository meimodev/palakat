import 'package:flutter/material.dart';

import '../core/format.dart';
import '../shell/tautan.dart';
import '../theme/palakat_tema.dart';
import 'batang_pembagian.dart';
import 'garis.dart';
import 'tekan.dart';
import '../app/layar.dart';

/// One Uang Muka, Titipan or Penggantian case in the Kewajiban list, as the
/// board draws it: radius 14, padding 14 16, gap 6; open → `permukaan` with
/// 1 px `garisTegas`, settled (sisa 0) → no fill, 1 px `garis`. Name 700 and
/// the remainder `rp(sisa)` mono 500 on one line; "{labelPihak}: {pihak}" 13;
/// an 8-high bar with the accounted part in `tinta` on the dashed rest;
/// [status] 13 `tinta2`, 700 when [lewatTempo] (never `bata`).
/// [web] is WebKasus: name size inherited, line gap 16, pihak `tinta3`.
class KartuKasus extends StatelessWidget {
  const KartuKasus({
    super.key,
    required this.nama,
    required this.labelPihak,
    required this.pihak,
    required this.awal,
    required this.dipertanggungjawabkan,
    required this.status,
    this.lewatTempo = false,
    this.ke,
    this.param = const {},
    this.anak,
    this.cara = Cara.dorong,
    this.onTap,
    this.web = false,
  });

  final String nama;

  /// 'Diberikan kepada' (Uang Muka), per kind from the board's LBL.
  final String labelPihak;
  final String pihak;

  /// sisa = awal − dipertanggungjawabkan, never typed.
  final int awal, dipertanggungjawabkan;

  /// 'Sebagian dipertanggungjawabkan · jatuh tempo dd/mm/yyyy'.
  final String status;
  final bool lewatTempo;

  /// Card target (literal: navigation.md 3.1).
  final Layar? ke;

  /// Path parameters and child route of [ke].
  final Map<String, String> param;
  final String? anak;
  final Cara cara;

  /// In-board open (Kewajiban `k.buka`).
  final VoidCallback? onTap;
  final bool web;

  int get sisa => awal - dipertanggungjawabkan;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final beres = sisa == 0;
    final kartu = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: ShapeDecoration(
        color: beres ? null : c.permukaan,
        shape: GarisBorder.penuh(
          beres ? c.garis : c.garisTegas,
          tebal: 1,
          radius: 14,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nama,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: web ? null : 15,
                  ),
                ),
              ),
              SizedBox(width: web ? 16 : 8),
              Text(
                rp(sisa),
                style: const TextStyle(
                  fontFamily: PalakatText.mono,
                  fontFeatures: [FontFeature.tabularFigures()],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$labelPihak: $pihak',
            style: TextStyle(fontSize: 13, color: web ? c.tinta3 : c.tinta2),
          ),
          const SizedBox(height: 6),
          BatangPembagian(
            // The boards draw Math.round(pct)%, not the exact fraction.
            total: 100,
            tinggi: 8,
            // No animation in the list (the 14-high detail bar animates).
            durasi: Duration.zero,
            bagian: [
              BagianBatang(
                awal == 0 ? 0 : (dipertanggungjawabkan * 100 / awal).round(),
                c.tinta,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 13,
              color: c.tinta2,
              fontWeight: lewatTempo && !beres
                  ? FontWeight.w700
                  : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
    if (ke != null) {
      return Tautan(
        ke: ke!,
        param: param,
        anak: anak,
        cara: cara,
        radius: 14,
        child: kartu,
      );
    }
    if (onTap != null) return Tekan(onTap: onTap, radius: 14, child: kartu);
    return kartu;
  }
}
