import 'package:flutter/material.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'ai_mata_anggaran_isi.dart';

/// Web · Bantuan AI: usulan Mata Anggaran dan pembagian (spec 12).
class WebAIMataAnggaranScreen extends StatefulWidget {
  const WebAIMataAnggaranScreen({super.key});

  @override
  State<WebAIMataAnggaranScreen> createState() =>
      _WebAIMataAnggaranScreenState();
}

class _WebAIMataAnggaranScreenState extends State<WebAIMataAnggaranScreen> {
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
      k: _k,
      mode: context.tweak<String>('WebAIMataAnggaran', 'usulan'),
      ubah: setState,
      keBagi: 'WebBagi',
    );
    final jk = context.prototipe.jabatanKosong;
    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        jabatanKosong: true,
        nav: const NavSamping(
          item: navKeuangan,
          aktif: 1,
          pengguna: PenggunaKeuangan(),
        ),
        isi: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The 44 target holds the text at its top: trim the rest.
              const MarginNegatif(
                bawah: 24,
                child: Tautan(
                  ke: 'WebCatat',
                  cara: Cara.naik,
                  child: TautanTeks('Catat transaksi', ukuran: 14),
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
                child: _kolom([isi.draf, isi.uraian, isi.mataAnggaran(jk)], 16),
              ),
              Lentur(dasar: 380, child: _kolom([?isi.panel, ?isi.abai], 14)),
            ],
          ),
        ],
      ),
    );
  }
}
