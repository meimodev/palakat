import 'package:flutter/material.dart';

import '../theme/palakat_tema.dart';
import 'garis.dart';
import 'garis_status.dart';
import 'kecil.dart';
import 'tombol.dart';

enum KeadaanPersetujuan { belumDicatat, sudahDicatat, tidakDiperlukan }

/// An approval given outside the app, as the Bendahara records it. No
/// "Approve" button, no imitation signature (components.md 3.5).
class KartuPersetujuan extends StatelessWidget {
  /// Dashed `putus` card, no fill, padding 14 16: title 700 and the button
  /// "Catat persetujuan" (8 below, 44 high, radius 12, 1.5 `tinta`).
  const KartuPersetujuan.belum({
    super.key,
    required VoidCallback this.onCatat,
    this.judul = 'Persetujuan belum dicatat',
    this.kepala,
  }) : keadaan = KeadaanPersetujuan.belumDicatat,
       pemberi = null,
       jabatan = null,
       tanggal = null,
       cara = null,
       dicatatOleh = null,
       dicatatPada = null,
       aturan = null;

  /// `Kartu`, padding 14 16, gap 4: optional [kepala], title, giver, date and
  /// way, and the Bendahara's statement under a 1 px dashed `garisTegas` rule.
  const KartuPersetujuan.sudah({
    super.key,
    required String this.pemberi,
    required String this.jabatan,
    required String this.tanggal,
    required String this.cara,
    required String this.dicatatOleh,
    required String this.dicatatPada,
    this.kepala,
  }) : keadaan = KeadaanPersetujuan.sudahDicatat,
       onCatat = null,
       judul = 'Persetujuan sudah dicatat',
       aturan = null;

  /// Plain 14 `tinta2`: "Tidak diperlukan" (700 `tinta`) + " (aturan: …)".
  const KartuPersetujuan.tidakDiperlukan({
    super.key,
    required String this.aturan,
  }) : keadaan = KeadaanPersetujuan.tidakDiperlukan,
       onCatat = null,
       judul = 'Tidak diperlukan',
       kepala = null,
       pemberi = null,
       jabatan = null,
       tanggal = null,
       cara = null,
       dicatatOleh = null,
       dicatatPada = null;

  final KeadaanPersetujuan keadaan;
  final VoidCallback? onCatat;
  final String judul;

  /// Kicker "Persetujuan di luar aplikasi" (14 `tinta2`, Persetujuan board).
  final String? kepala;

  /// 'Pnt. Jefry Wowor', 'Ketua BPMJ', 'dd/mm/yyyy', 'notulen rapat'.
  final String? pemberi, jabatan, tanggal, cara;

  /// 'Meiske L.', 'dd/mm/yyyy hh.mm'.
  final String? dicatatOleh, dicatatPada;

  /// 'transaksi rutin'.
  final String? aturan;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    const jarak = SizedBox(height: 4);
    final atas = [
      if (kepala != null) ...[
        Text(kepala!, style: TextStyle(fontSize: 14, color: c.tinta2)),
        jarak,
      ],
      Text(judul, style: const TextStyle(fontWeight: FontWeight.w700)),
    ];
    switch (keadaan) {
      case KeadaanPersetujuan.belumDicatat:
        return Kartu(
          status: GarisStatus.draf,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ...atas,
              const SizedBox(height: 8),
              Tombol(
                'Catat persetujuan',
                onPressed: onCatat,
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.kecil,
              ),
            ],
          ),
        );
      case KeadaanPersetujuan.sudahDicatat:
        return Kartu(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ...atas,
              jarak,
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Pemberi persetujuan:',
                      style: TextStyle(color: c.tinta2),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: pemberi,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: ', $jabatan'),
                  ],
                ),
                style: const TextStyle(fontSize: 14),
              ),
              jarak,
              Text(
                '$tanggal · cara: $cara',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
              const SizedBox(height: 12), // gap 4 + margin-top 8
              GarisLurus(warna: c.garisTegas, gaya: GayaGaris.putus),
              const SizedBox(height: 8),
              Text(
                'Dicatat oleh $dicatatOleh, $dicatatPada. Pernyataan '
                'Bendahara, bukan persetujuan di dalam aplikasi.',
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
            ],
          ),
        );
      case KeadaanPersetujuan.tidakDiperlukan:
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: judul,
                style: TextStyle(color: c.tinta, fontWeight: FontWeight.w700),
              ),
              TextSpan(text: ' (aturan: $aturan)'),
            ],
          ),
          style: TextStyle(fontSize: 14, color: c.tinta2),
        );
    }
  }
}
