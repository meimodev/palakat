import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import 'lihat_dokumen_penampil.dart';
import '../../app/layar.dart';

/// 40 · Lihat file dokumen pendukung (spec 11-lihatdokumen.md).
class LihatDokumenScreen extends StatefulWidget {
  const LihatDokumenScreen({super.key});

  @override
  State<LihatDokumenScreen> createState() => _LihatDokumenScreenState();
}

class _LihatDokumenScreenState extends State<LihatDokumenScreen>
    with KeadaanLihatDokumen {
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Material(
      type: MaterialType.transparency,
      child: LayarPonsel(
        layarKeuangan: true,
        child: ColoredBox(
          color: c.tinta,
          child: DefaultTextStyle.merge(
            style: TextStyle(color: c.permukaan),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KepalaPonsel(
                  judul: fileNama,
                  kembaliKe: Layar.dokumen,
                  labelKembali: 'Kembali ke Dokumen pendukung',
                  judulMono: true,
                  ukuranJudul: 16,
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 4),
                ),
                ...penampil(),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  decoration: BoxDecoration(
                    color: c.permukaan,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(PalakatRadius.lembar),
                    ),
                  ),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: c.tinta),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 8,
                      children: panel(
                        context,
                        tautan: const Tautan(
                          ke: Layar.dokumen,
                          cara: Cara.naik,
                          child: IsiTautanTolak(),
                        ),
                      ),
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
