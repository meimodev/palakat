import 'package:flutter/material.dart';

import '../theme/palakat_tema.dart';
import 'tekan.dart';

/// On/off switch (Lainnya, Pemberitahuan, WebPengaturan, WebPemberitahuan):
/// target 56 × 44 (padding 6 0); track 56 × 32, radius 16, 1.5 `tinta`
/// line, `tinta` (on) / `permukaan` (off); thumb 23 circle at top 3, left 28
/// (on) / 3 (off) inside the line, `permukaan` (on) / `tinta` (off). Both
/// change over `sentuh` with CSS `ease`; instant under reduced motion.
/// [nonaktif] keeps the look and drops the tap (board `disabled`).
class Sakelar extends StatelessWidget {
  const Sakelar({
    super.key,
    required this.nilai,
    required this.onUbah,
    required this.label,
    this.nonaktif = false,
  });

  final bool nilai;
  final ValueChanged<bool> onUbah;

  /// aria-label: 'Wajib pemeriksa kedua'.
  final String label;
  final bool nonaktif;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final lama = context.gerak(PalakatMotion.sentuh);
    return Tekan(
      onTap: nonaktif ? null : () => onUbah(!nilai),
      peran: PeranTekan.sakelar,
      tercentang: nilai,
      label: label,
      minLebar: 56,
      child: SizedBox(
        width: 56,
        height: 44,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: AnimatedContainer(
            duration: lama,
            curve: Curves.ease,
            decoration: BoxDecoration(
              color: nilai ? c.tinta : c.permukaan,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.tinta, width: 1.5),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: lama,
                  curve: Curves.ease,
                  top: 3,
                  left: nilai ? 28 : 3,
                  width: 23,
                  height: 23,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: nilai ? c.permukaan : c.tinta,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
