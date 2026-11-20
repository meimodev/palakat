import 'package:flutter/material.dart';

import '../theme/palakat_tema.dart';
import '../widgets/tombol.dart';
import '../app/layar.dart';
import 'tautan.dart';

/// Unknown route (navigation.md 5.5): prototype chrome, fluid, tokens.
/// Case matters: `/main`, `/Main.dc.html` and `/Main/xyz` all land here.
class TidakDitemukanScreen extends StatelessWidget {
  const TidakDitemukanScreen({super.key, required this.lokasi});
  final String lokasi;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Material(
      color: c.kertas,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Layar tidak ditemukan',
                  textAlign: TextAlign.center,
                  style: PalakatText.judulBesar.copyWith(color: c.tinta),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lokasi,
                textAlign: TextAlign.center,
                style: PalakatText.kode.copyWith(color: c.tinta3),
              ),
              const SizedBox(height: 20),
              Tombol(
                'Ke beranda',
                onPressed: () => context.gantiKe(Layar.beranda),
                lebarPenuh: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
