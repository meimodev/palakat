import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/tombol.dart';
import 'tanggal_kalender.dart';

/// 41 · Tanggal transaksi dan tanggal dokumen (spec 11, Tanggal).
class TanggalScreen extends StatefulWidget {
  const TanggalScreen({super.key});

  @override
  State<TanggalScreen> createState() => _TanggalScreenState();
}

class _TanggalScreenState extends State<TanggalScreen>
    with TanggalLogika<TanggalScreen> {
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final pesanBulan = pesan(
      context,
      () => const Tautan(
        ke: 'Kejadian',
        child: SizedBox(),
      ).buka(GoRouter.of(context)),
    );
    final isi = [
      bilahBulan(context),
      kisiHari(context),
      ?pesanBulan,
      kartuRincian(context),
    ];
    return Material(
      type: MaterialType.transparency,
      child: LayarPonsel(
        jabatanKosong: true,
        // CSS half-leading: the board's text sits centred in its line box.
        child: DefaultTextStyle.merge(
          style: const TextStyle(
            leadingDistribution: TextLeadingDistribution.even,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const KepalaPonsel(
                judul: 'Tanggal transaksi',
                anakJudul: 'Belanja · draf',
                kembaliKe: 'Main',
                labelKembali: 'Kembali ke isian',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < isi.length; i++) ...[
                        if (i > 0) const SizedBox(height: 16),
                        isi[i],
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
                decoration: BoxDecoration(
                  color: c.permukaan,
                  border: Border(top: BorderSide(color: c.garis)),
                ),
                child: sel != null
                    ? Tombol(
                        'Pakai $tglTeks',
                        onPressed: null,
                        ke: 'Main',
                        cara: Cara.naik,
                        paddingH: 20,
                      )
                    : const Tombol(
                        'Pilih tanggal dulu',
                        onPressed: null,
                        nonaktif: true,
                        paddingH: 20,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
