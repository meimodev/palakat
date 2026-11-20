import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'ai_foto_bagian.dart';
import '../../app/layar.dart';

/// 35 · Bantuan AI dari foto nota (spec 10-aifoto.md, AIFoto).
class AIFotoScreen extends StatefulWidget {
  const AIFotoScreen({super.key});

  @override
  State<AIFotoScreen> createState() => _AIFotoScreenState();
}

class _AIFotoScreenState extends State<AIFotoScreen> {
  final _k = KeadaanAIFoto();

  @override
  void dispose() {
    _k.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: LayarPonsel(
      layarKeuangan: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Belanja',
            anakJudul: 'Dari foto nota',
            kembaliKe: Layar.keuangan,
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: ListenableBuilder(
                listenable: _k,
                builder: (context, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PanelAIFoto(_k),
                    const SizedBox(height: 16),
                    IsianAIFoto(_k),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
