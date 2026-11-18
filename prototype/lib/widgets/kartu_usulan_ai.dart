import 'package:flutter/material.dart';

import '../motion/kerangka.dart';
import '../theme/palakat_tema.dart';
import 'garis_status.dart';
import 'kecil.dart';
import 'lencana_status.dart';
import 'tombol.dart';

/// An AI suggestion: no value until Pakai. Card `permukaan`, 1.5 dotted
/// `laut`, radius 12, padding [padding], column gap [jarak], entering with
/// `muncul` 300 ms: the `usulanAI` badge, the suggestion in 14 italic
/// `lautTua`, "AI kurang yakin, mohon dicek" 13/600 when [kurangYakin], and
/// the actions Pakai (`utama`), Ubah, Abaikan (`kedua`), gap 8:
/// - default: `mini` 44, radius 10, padding 0 16, 14 px, inside the card
///   (4 below the text);
/// - [tombolBesar] (BantuanAI, AIFoto): 46 high, radius 12, `flex: 1`, in a
///   row under the card (gap 10).
/// [bingkai] adds the `lautLembut` panel (radius 16; padding 14, or 14 16
/// with [tombolBesar]). [onUbah] null drops Ubah (WebAI rows).
class KartuUsulanAI extends StatelessWidget {
  const KartuUsulanAI({
    super.key,
    required this.label,
    required this.isi,
    this.kurangYakin = false,
    required this.onPakai,
    required this.onUbah,
    required this.onAbaikan,
    this.bingkai = true,
    this.tombolBesar = false,
    this.padding = const EdgeInsets.all(14),
    this.jarak = 6,
  });

  /// 'Usulan AI' or 'Usulan AI · dari foto' …
  final String label;

  /// The suggestion; plain text inherits 14 italic `lautTua` (wrap a Mata
  /// Anggaran line in `FontWeight.w600`).
  final Widget isi;
  final bool kurangYakin;
  final VoidCallback? onPakai, onUbah, onAbaikan;
  final bool bingkai, tombolBesar;
  final EdgeInsetsGeometry padding;
  final double jarak;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final ukuran = tombolBesar ? UkuranTombol.ringkas : UkuranTombol.mini;
    Widget tombol(String t, VoidCallback? f, JenisTombol j) {
      final b = Tombol(
        t,
        onPressed: f,
        jenis: j,
        ukuran: ukuran,
        lebarPenuh: tombolBesar,
        ukuranTeks: tombolBesar ? null : 14,
        paddingH: tombolBesar ? 0 : 16,
      );
      return tombolBesar ? Expanded(child: b) : b;
    }

    final aksi = [
      tombol('Pakai', onPakai, JenisTombol.utama),
      if (onUbah != null) tombol('Ubah', onUbah, JenisTombol.kedua),
      tombol('Abaikan', onAbaikan, JenisTombol.kedua),
    ];
    final jeda = SizedBox(height: jarak);
    final kartu = Gerak(
      Kerangka.muncul,
      lama: const Duration(milliseconds: 300),
      child: Kartu(
        status: GarisStatus.usulanAI,
        radius: 12,
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            LencanaStatus(label, bentuk: BentukLencana.usulanAI),
            jeda,
            DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: c.lautTua,
              ),
              child: isi,
            ),
            if (kurangYakin) ...[
              jeda,
              const Text(
                'AI kurang yakin, mohon dicek',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
            if (!tombolBesar) ...[
              jeda,
              const SizedBox(height: 4),
              Wrap(spacing: 8, runSpacing: 8, children: aksi),
            ],
          ],
        ),
      ),
    );
    final isiPanel = tombolBesar
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              kartu,
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final (i, a) in aksi.indexed) ...[
                    if (i > 0) const SizedBox(width: 8),
                    a,
                  ],
                ],
              ),
            ],
          )
        : kartu;
    final grup = Semantics(
      container: true,
      label: 'Usulan AI',
      child: isiPanel,
    );
    if (!bingkai) return grup;
    return Container(
      padding: tombolBesar
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
          : const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.lautLembut,
        borderRadius: BorderRadius.circular(PalakatRadius.kartuBesar),
      ),
      child: grup,
    );
  }
}
