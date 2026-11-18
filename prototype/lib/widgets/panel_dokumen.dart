import 'package:flutter/material.dart';

import '../motion/kerangka.dart';
import '../motion/urutan.dart';
import '../theme/palakat_tema.dart';
import 'garis.dart';
import 'ikon.dart';
import 'kecil.dart';
import 'tekan.dart';

enum StatusDokumen {
  wajibBelumAda,
  sedangDiunggah,
  gagalDiunggah,
  diunggah,
  terverifikasi,
  dikecualikan,
  ditolak,
  ditahan,
  tidakDiperlukan,
}

/// One supporting document row of [PanelDokumen].
class BarisDokumen {
  const BarisDokumen({
    required this.status,
    required this.judul,
    this.keterangan,
    this.aksi,
  });

  final StatusDokumen status;

  /// Status words verbatim: 'Wajib, belum ada', 'Gagal diunggah' …
  final String judul;

  /// 'nota-16-11.jpg · Terlampir', 'Alasan: nota hilang · oleh Ketua BPMJ'.
  final String? keterangan;

  /// 'Lampirkan', 'Coba lagi', 'Verifikasi': a `Tombol` (`mini`, 13 px,
  /// `kedua`, or `garisBata` on the failure rows).
  final Widget? aksi;
}

/// The documents of one transaction in a `Kartu(padding: 0 16)`: rows min
/// height 60, padding 8 0, gap 12, a 1 px `garis` rule between rows;
/// thumbnail 34 × 42 radius 6 in the status fill; title 600/14 (`bata` for
/// Gagal diunggah, Ditolak, Ditahan), keterangan 13 `tinta3`, then [aksi].
class PanelDokumen extends StatelessWidget {
  const PanelDokumen({super.key, required this.dokumen});

  final List<BarisDokumen> dokumen;

  static bool gagal(StatusDokumen s) =>
      s == StatusDokumen.gagalDiunggah ||
      s == StatusDokumen.ditolak ||
      s == StatusDokumen.ditahan;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Kartu(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, d) in dokumen.indexed) ...[
            if (i > 0) GarisLurus(warna: c.garis),
            // CSS content-box: min-height 60 is inside the 8 px padding.
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 60),
                child: Row(
                  children: [
                    ThumbDokumen(status: d.status),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            d.judul,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: gagal(d.status) ? c.bata : c.tinta,
                            ),
                          ),
                          if (d.keterangan != null)
                            Text(
                              d.keterangan!,
                              style: TextStyle(fontSize: 13, color: c.tinta3),
                            ),
                        ],
                      ),
                    ),
                    if (d.aksi != null) ...[const SizedBox(width: 12), d.aksi!],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The document thumbnail, radius 6: wajib-belum-ada / tidak diperlukan →
/// no fill, 1.5 dashed `putus`; sedang diunggah / diunggah → `kertas`;
/// gagal / ditolak / ditahan → `bataLembut`; terverifikasi / dikecualikan →
/// `lautLembut`; the filled ones with 1 px `garisTegas`. [lebar] × [tinggi]
/// is the inside; the line adds to it (36 × 44 outside for a solid 34 × 42).
class ThumbDokumen extends StatelessWidget {
  const ThumbDokumen({
    super.key,
    required this.status,
    this.lebar = 34,
    this.tinggi = 42,
  });

  final StatusDokumen status;
  final double lebar, tinggi;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final isi = switch (status) {
      StatusDokumen.wajibBelumAda || StatusDokumen.tidakDiperlukan => null,
      StatusDokumen.sedangDiunggah || StatusDokumen.diunggah => c.kertas,
      StatusDokumen.gagalDiunggah ||
      StatusDokumen.ditolak ||
      StatusDokumen.ditahan => c.bataLembut,
      StatusDokumen.terverifikasi || StatusDokumen.dikecualikan => c.lautLembut,
    };
    // A <div> is content-box: the line sits outside width × height.
    final tebal = isi == null ? 1.5 : 1.0;
    return SizedBox(
      width: lebar + 2 * tebal,
      height: tinggi + 2 * tebal,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: isi,
          shape: isi == null
              ? GarisBorder.putus(c.putus, radius: PalakatRadius.lencana)
              : GarisBorder.penuh(
                  c.garisTegas,
                  tebal: 1,
                  radius: PalakatRadius.lencana,
                ),
        ),
      ),
    );
  }
}

/// Main's "Dokumen pendukung" field, three board forms:
/// - [LampiranDokumen.belum]: dashed button "Lampirkan dokumen pendukung"
///   (min height 56, radius 12, 1.5 dashed `putus`, `laut` 600, `Ikon.kamera`
///   20, gap 8).
/// - [LampiranDokumen.mengunggah]: box (radius 12, 1 px `garisTegas`,
///   `permukaan`, padding 12 14): "Sedang diunggah…" 14/600 and a 4 px bar
///   (radius 2, `garis` track, `laut` fill `isi` 1.2 s linear), margin-top 8.
/// - [LampiranDokumen.terlampir]: the same box as a row, gap 12, entering
///   with `muncul` 280 ms: thumbnail 40 × 48 `lautLembut`; [nama] 14/600,
///   [keterangan] 13 `tinta2`.
class LampiranDokumen extends StatelessWidget {
  const LampiranDokumen.belum({
    super.key,
    required VoidCallback this.onLampirkan,
  }) : _bentuk = 0,
       nama = null,
       keterangan = null;

  const LampiranDokumen.mengunggah({super.key})
    : _bentuk = 1,
      onLampirkan = null,
      nama = null,
      keterangan = null;

  const LampiranDokumen.terlampir({
    super.key,
    this.nama = 'nota-16-11.jpg · Terlampir',
    this.keterangan = 'Diunggah, belum diverifikasi',
  }) : _bentuk = 2,
       onLampirkan = null;

  final int _bentuk;
  final VoidCallback? onLampirkan;
  final String? nama, keterangan;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    if (_bentuk == 0) {
      return Tekan(
        onTap: onLampirkan,
        radius: 12,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          decoration: ShapeDecoration(
            shape: GarisBorder.putus(c.putus, radius: 12),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PalakatIkon(Ikon.kamera, ukuran: 20, warna: c.laut),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Lampirkan dokumen pendukung',
                  style: TextStyle(fontWeight: FontWeight.w600, color: c.laut),
                ),
              ),
            ],
          ),
        ),
      );
    }
    Widget kotak(Widget child) => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: GarisBorder.penuh(c.garisTegas, tebal: 1, radius: 12),
      ),
      child: child,
    );
    if (_bentuk == 1) {
      return kotak(
        const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sedang diunggah…',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            BatangIsi(lama: Duration(milliseconds: 1200), tinggi: 4),
          ],
        ),
      );
    }
    return Gerak(
      Kerangka.muncul,
      lama: PalakatMotion.pindahLayar,
      child: kotak(
        Row(
          children: [
            ThumbDokumen(
              status: StatusDokumen.terverifikasi,
              lebar: 40,
              tinggi: 48,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    nama!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (keterangan != null)
                    Text(
                      keterangan!,
                      style: TextStyle(fontSize: 13, color: c.tinta2),
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
