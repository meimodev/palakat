import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'ai_mata_anggaran_isi.dart';
import '../../app/layar.dart';

/// Web · Bantuan AI: usulan Mata Anggaran dan pembagian (spec 12).
class WebAIMataAnggaranScreen extends ConsumerStatefulWidget {
  const WebAIMataAnggaranScreen({super.key});

  @override
  ConsumerState<WebAIMataAnggaranScreen> createState() =>
      _WebAIMataAnggaranScreenState();
}

class _WebAIMataAnggaranScreenState
    extends ConsumerState<WebAIMataAnggaranScreen> {
  final _k = KeadaanUsulanMA();

  @override
  void dispose() {
    _k.uraian.dispose();
    super.dispose();
  }

  static Widget _kolom(List<Widget> anak, double jarak) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (i, b) in anak.indexed) ...[
        if (i > 0) SizedBox(height: jarak),
        b,
      ],
    ],
  );

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final isi = IsiUsulanMA(
      context: context,
      ref: ref,
      k: _k,
      ubah: (f) {
        if (mounted) setState(f);
      },
      keBagi: Layar.bagi,
    );
    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        layarKeuangan: true,
        nav: const NavSamping(item: navKeuangan, aktif: 1),
        isi: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The 44 target holds the text at its top: trim it to the
              // board's line box (15 px strut, 21.75 tall; the 14 px text
              // sits 1.1 px down on the strut's baseline).
              const MarginNegatif(
                bawah: 22.25,
                child: Tautan(
                  ke: Layar.catat,
                  cara: Cara.naik,
                  child: Padding(
                    padding: EdgeInsets.only(top: 1.1),
                    child: TautanTeks('Catat transaksi', ukuran: 14),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Semantics(
                header: true,
                child: const Text(
                  'Pilih Mata Anggaran',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                'Usulan AI berdiri di samping isian dan belum mengisi apa pun sampai dipakai.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
          BarisLentur(
            anak: [
              Lentur(
                dasar: 440,
                tumbuh: 999,
                child: _kolom([
                  ?isi.kosong,
                  if (isi.kosong == null) ...[
                    isi.draf,
                    isi.uraian,
                    isi.mataAnggaran,
                  ],
                ], 16),
              ),
              Lentur(dasar: 380, child: _kolom([?isi.panel, ?isi.abai], 14)),
            ],
          ),
        ],
      ),
    );
  }
}
