import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/tombol.dart';
import 'bantuan_ai_bagian.dart';

/// 14 · Bantuan AI saat mencatat (spec 05-kewajiban.md, BantuanAI).
class BantuanAIScreen extends StatefulWidget {
  const BantuanAIScreen({super.key});

  @override
  State<BantuanAIScreen> createState() => _BantuanAIScreenState();
}

class _BantuanAIScreenState extends State<BantuanAIScreen> {
  final _s = KeadaanBantuanAI();

  @override
  void dispose() {
    _s.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final keadaanAI = context.tweak<String>('BantuanAI', 'keadaanAI');
    return LayarPonsel(
      jabatanKosong: true,
      // No Material here: it would reset the inherited 16 px text style.
      child: ListenableBuilder(
        listenable: _s,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KepalaPonsel(
              judul: 'Belanja',
              kembaliKe: 'Main',
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
                    PanelBantuanAI(s: _s, keadaanAI: keadaanAI),
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Tombol(
                    'Periksa dan bukukan',
                    onPressed: null,
                    ke: 'Main',
                    cara: Cara.ganti,
                  ),
                  SizedBox(height: 6),
                  Tombol(
                    'Simpan sebagai draf',
                    onPressed: null,
                    jenis: JenisTombol.teks,
                    ke: 'Main',
                    cara: Cara.ganti,
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
