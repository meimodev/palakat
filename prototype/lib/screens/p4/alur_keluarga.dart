import 'package:flutter/widgets.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'alur_keluarga_bersama.dart';

/// 84 · Alur · Buku anggota (phone): the Operator imports three book rows,
/// enters the family's signed form; the Penatua Kolom 7 verifies it.
class AlurKeluargaScreen extends StatefulWidget {
  const AlurKeluargaScreen({super.key});

  @override
  State<AlurKeluargaScreen> createState() => _AlurKeluargaScreenState();
}

class _AlurKeluargaScreenState extends State<AlurKeluargaScreen>
    with AlurKeluargaLogika {
  @override
  Widget build(BuildContext context) {
    final blok = [
      ?banner,
      if (op && st.isEmpty) ...[...bukuKiri, ...bukuKanan],
      if (op && st.isNotEmpty) ...[...konfKiri, ...konfKanan],
      if (!op) ...penatua,
      ?riwayat,
    ];
    return denganAlat(
      'AlurKeluarga',
      LayarPonsel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Alur · Buku anggota',
              anakJudul: 'Operator mengimpor; keluarga mengonfirmasi; Penatua memverifikasi',
              kembaliKe: 'DataAnggota',
              labelKembali: 'Kembali ke Data jemaat',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: kolomAlur(blok, 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
