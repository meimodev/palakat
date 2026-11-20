import 'package:flutter/material.dart';

import '../shell/tautan.dart';
import '../theme/palakat_tema.dart';
import 'garis.dart';
import 'garis_status.dart';
import 'ikon.dart';
import 'kecil.dart';
import 'tekan.dart';
import '../app/layar.dart';

enum TingkatPerhatian { hambatan, perluTindakan, untukDiketahui }

/// One attention item at one of three levels (components.md 3.5):
/// - hambatan: `bata` 1.5 card (padding 14 16; [web] 16), gap 4: title 700
///   (15 phone), [keterangan] 14 `tinta2`, then [perbaikan] (the `tinta`
///   44-high button to the fix) 8 below; stretched on phone, start on web.
/// - perluTindakan: a list row for one card (`padding: 0 16`): min height 60,
///   gap 12, title 600/15, keterangan 13 `tinta3` (or [warnaKeterangan]
///   `bata`, 600 phone / 700 web), `Ikon.lanjut`; a 1 px `garis` rule above
///   unless [pertama].
/// - untukDiketahui: heading "Untuk diketahui" and the [judul] as a plain
///   14 `tinta2` link. No frame, no warning colour.
/// [ke] makes the row or link a `Tautan`; else [onTap] makes it a `Tekan`.
class ButirPerhatian extends StatelessWidget {
  const ButirPerhatian({
    super.key,
    required this.tingkat,
    required this.judul,
    this.keterangan,
    this.perbaikan,
    this.labelTingkat = false,
    this.ke,
    this.param = const {},
    this.anak,
    this.cara = Cara.dorong,
    this.onTap,
    this.warnaKeterangan,
    this.pertama = false,
    this.web = false,
  });

  final TingkatPerhatian tingkat;
  final String judul;
  final String? keterangan;

  /// Hambatan: required button or Tautan to the fix.
  final Widget? perbaikan;

  /// The preview's 'HAMBATAN' label (13/700 `bata`, letter spacing .3);
  /// boards omit it.
  final bool labelTingkat;

  /// Row or link target (literal: navigation.md 3.1).
  final Layar? ke;

  /// Path parameters and child route of [ke].
  final Map<String, String> param;
  final String? anak;
  final Cara cara;
  final VoidCallback? onTap;

  /// Main's and WebBeranda's first row: `bata` "1 hambatan · …".
  final Color? warnaKeterangan;

  /// Perlu tindakan: first row of its card (no rule above).
  final bool pertama;

  /// Laptop boards: hambatan padding 16, start-aligned fix, inherited title
  /// size; heading 17; `bata` keterangan 700.
  final bool web;

  Widget _tekan(Widget child) {
    if (ke != null) {
      return Tautan(
        ke: ke!,
        param: param,
        anak: anak,
        cara: cara,
        child: child,
      );
    }
    if (onTap != null) return Tekan(onTap: onTap, child: child);
    return child;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    switch (tingkat) {
      case TingkatPerhatian.hambatan:
        return Kartu(
          status: GarisStatus.hambatan,
          padding: web
              ? const EdgeInsets.all(16)
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: web
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (labelTingkat) ...[
                Text(
                  'HAMBATAN',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.bata,
                    letterSpacing: .3,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                judul,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: web ? null : 15,
                ),
              ),
              if (keterangan != null) ...[
                const SizedBox(height: 4),
                Text(
                  keterangan!,
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
              ],
              if (perbaikan != null) ...[
                const SizedBox(height: 12), // gap 4 + margin-top 8
                perbaikan!,
              ],
            ],
          ),
        );
      case TingkatPerhatian.perluTindakan:
        final merah = warnaKeterangan;
        final baris = ConstrainedBox(
          // Main's rows are border-box <button>s (60 includes the rule);
          // WebBeranda's are content-box <a>s (60 + rule).
          constraints: BoxConstraints(minHeight: pertama || web ? 60 : 59),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      judul,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (keterangan != null)
                      Text(
                        keterangan!,
                        style: TextStyle(
                          fontSize: 13,
                          color: merah ?? c.tinta3,
                          fontWeight: merah == null
                              ? null
                              : (web ? FontWeight.w700 : FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
            ],
          ),
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!pertama) GarisLurus(warna: c.garis),
            _tekan(baris),
          ],
        );
      case TingkatPerhatian.untukDiketahui:
        final tautan = _tekan(
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Align(
              alignment: Alignment.centerLeft,
              // Main's link is a full-width flex row; WebBeranda's is inline.
              widthFactor: web ? 1 : null,
              child: TautanTeks(
                judul,
                berat: FontWeight.w400,
                ukuran: 14,
                warna: c.tinta2,
              ),
            ),
          ),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (web) const SizedBox(height: 8),
            JudulBagian('Untuk diketahui', web: web),
            const SizedBox(height: 6),
            tautan,
          ],
        );
    }
  }
}
