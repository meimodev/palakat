import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/tombol.dart';
import 'bantuan_ai_bagian.dart';
import '../../app/layar.dart';

/// 14 · Bantuan AI saat mencatat (spec 05-kewajiban.md, BantuanAI).
class BantuanAIScreen extends ConsumerStatefulWidget {
  const BantuanAIScreen({super.key});

  @override
  ConsumerState<BantuanAIScreen> createState() => _BantuanAIScreenState();
}

class _BantuanAIScreenState extends ConsumerState<BantuanAIScreen> {
  late final _s = KeadaanBantuanAI(kalimatContoh(ref));

  @override
  void dispose() {
    _s.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return LayarPonsel(
      layarKeuangan: true,
      // No Material here: it would reset the inherited 16 px text style.
      child: ListenableBuilder(
        listenable: _s,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KepalaPonsel(
              judul: 'Belanja',
              kembaliKe: Layar.keuangan,
              labelKembali: 'Kembali ke Beranda',
              ujung: Text(
                simpanTeks(_s),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.tinta3,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PanelBantuanAI(s: _s),
                    const SizedBox(height: 16),
                    DrafBantuanAI(s: _s, turun: true),
                    const SizedBox(height: 16),
                    Text(
                      'AI hanya mengusulkan. Membukukan, memverifikasi dokumen dan menutup buku selalu dilakukan orang.',
                      style: TextStyle(fontSize: 13, color: c.tinta3),
                    ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // With a saved draft, Main's Catat opens on it (WebBantuanAI
                  // does the same with WebCatat).
                  Tombol(
                    'Periksa dan bukukan',
                    onPressed: _s.dipakai
                        ? () => bukaDrafAiDiCatat(context, ref, _s.drafId!)
                        : null,
                    ke: _s.dipakai ? null : Layar.keuangan,
                    cara: Cara.ganti,
                  ),
                  const SizedBox(height: 6),
                  Tombol(
                    'Simpan sebagai draf',
                    onPressed: () =>
                        simpanDrafAi(context, ref, _s, Layar.keuangan),
                    jenis: JenisTombol.teks,
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
