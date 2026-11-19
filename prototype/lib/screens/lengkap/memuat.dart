import 'package:flutter/widgets.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/tombol.dart';
import 'memuat_isi.dart';

/// 44 · Memuat, gagal memuat, Bukukan tidak terjadi (spec 12, Memuat).
class MemuatScreen extends StatefulWidget {
  const MemuatScreen({super.key});
  @override
  State<MemuatScreen> createState() => _MemuatScreenState();
}

class _MemuatScreenState extends State<MemuatScreen>
    with PengendaliMemuat<MemuatScreen> {
  @override
  String get stem => 'Memuat';

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final st = this.st;
    final kepala = beranda
        ? Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Semantics(
                    header: true,
                    child: const Text(
                      'Beranda',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: c.garisTegas),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'November 2026',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.tinta2,
                    ),
                  ),
                ),
              ],
            ),
          )
        : const KepalaPonsel(
            judul: 'Periksa dan bukukan',
            kembaliKe: 'Main',
            labelKembali: 'Kembali ke Beranda',
          );
    final isi = beranda
        ? isiBeranda(
            context,
            st,
            onCoba: coba,
            buka: Tautan(
              ke: 'Main',
              cara: Cara.ganti,
              radius: 14,
              child: rupaTautanKedua(
                context,
                'Buka Beranda',
                tinggi: 48,
                radius: 14,
              ),
            ),
          )
        : isiPeriksa(context, st);
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          kepala,
          Expanded(
            child: SingleChildScrollView(
              key: ValueKey(beranda),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: kolom(16, isi),
            ),
          ),
          if (!beranda)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
              decoration: BoxDecoration(
                color: c.permukaan,
                border: Border(top: BorderSide(color: c.garis)),
              ),
              child: kolom(8, [
                if (st == KeadaanMemuat.aksi) ...[
                  Tombol(
                    'Coba lagi',
                    onPressed: cobaBuku,
                    jenis: JenisTombol.tinta,
                  ),
                  const Tombol(
                    'Biarkan sebagai draf',
                    onPressed: null,
                    jenis: JenisTombol.teks,
                    ke: 'Main',
                    cara: Cara.naik,
                  ),
                ] else
                  Tautan(
                    ke: 'Main',
                    cara: Cara.naik,
                    radius: 14,
                    child: rupaTautanKedua(
                      context,
                      'Kembali ke Beranda',
                      tinggi: 48,
                      radius: 14,
                      paddingH: 0,
                    ),
                  ),
              ]),
            ),
        ],
      ),
    );
  }
}
