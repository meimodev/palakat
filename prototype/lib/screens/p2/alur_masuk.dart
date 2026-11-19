import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import 'alur_masuk_isi.dart';

/// 58 · Alur · Masuk dan menghubungkan akun (16-alurmasuk.md).
class AlurMasukScreen extends StatelessWidget {
  const AlurMasukScreen({super.key});

  @override
  Widget build(BuildContext context) => const LayarPonsel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KepalaPonsel(
          judul: 'Alur · Masuk dan menghubungkan akun',
          anakJudul:
              'Nomor ponsel, kode, lalu data jemaat yang diverifikasi Penatua',
          kembaliKe: 'BerandaJabatan',
          labelKembali: 'Kembali ke Beranda',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: AlurMasukIsi(
              stem: 'AlurMasuk',
              pemulihan: TautanPemulihan(ke: 'Pemulihan'),
              anggota: TombolTautanAlur(
                'Ajukan permohonan menjadi anggota',
                ke: 'AlurAnggota',
              ),
              warta: TombolTautanAlur('Buka Warta Jemaat', ke: 'WartaArsip'),
              beranda: TombolTautanAlur(
                'Buka Beranda',
                ke: 'BerandaJabatan',
                tinta: true,
                cara: Cara.ganti,
              ),
              akun: TombolTautanAlur('Tambah email cadangan', ke: 'AkunSaya'),
            ),
          ),
        ),
      ],
    ),
  );
}
