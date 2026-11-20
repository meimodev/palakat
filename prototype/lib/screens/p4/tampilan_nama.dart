import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

const _awal = 'Keluarga + Kolom';
const _bentuk = [
  ('Nama lengkap', 'Novita Wenas'),
  ('Nama keluarga', 'Kel. Wenas-Lasut'),
  ('Keluarga + Kolom', 'Kel. Wenas-Lasut — Kolom 7'),
  ('Kolom', 'Kolom 7'),
  ('BIPRA', 'Pemuda'),
  ('BIPRA + Kolom', 'Pemuda — Kolom 7'),
  ('Tanpa nama', 'Tanpa nama'),
];

/// 78 · Tampilan nama saya di publikasi (spec 20). State `{ k: null }` plus
/// the native radio selection `mode`, re-created whenever k0 shows anew.
class TampilanNamaScreen extends StatefulWidget {
  const TampilanNamaScreen({super.key});

  @override
  State<TampilanNamaScreen> createState() => _TampilanNamaScreenState();
}

class _TampilanNamaScreenState extends State<TampilanNamaScreen> {
  String? _k;
  String? _tweak;
  String _mode = _awal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final t = belumDipindah<String>('Pilihan pribadi');
    if (_tweak != null && t != _tweak) {
      _k = null;
      _mode = _awal;
    }
    _tweak = t;
  }

  void _keRadio() => setState(() {
    _k = 'Pilihan pribadi';
    _mode = _awal;
  });

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final v = _k ?? _tweak!;
    final k13 = TextStyle(fontSize: 13, color: c.tinta3);
    Widget kartu(String judul, String lencana, Widget baris) => Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          KepalaKartu(
            judul: judul,
            ujung: LencanaStatus(lencana, bentuk: BentukLencana.garis),
          ),
          baris,
        ],
      ),
    );
    Widget tebal(String awal, String nama) => Text.rich(
      TextSpan(
        text: awal,
        children: [
          TextSpan(
            text: nama,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      style: const TextStyle(fontSize: 15),
    );
    Widget pratinjau(String awal, String nama) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.lautLembut,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          Text('Lihat tampilan nama saya', style: k13),
          tebal(awal, nama),
        ],
      ),
    );
    Widget ubah(String label) => BarisTombol(
      anak: [
        Tombol(
          label,
          jenis: JenisTombol.kedua,
          ukuran: UkuranTombol.sedang,
          onPressed: _keRadio,
        ),
      ],
    );
    final List<Widget> isi = switch (v) {
      'Mengikuti bawaan keluarga' => [
        kartu(
          'Bawaan keluarga',
          'Nama keluarga',
          Text(
            'Diatur Wakil keluarga Agustina Lasut. Anda belum memilih sendiri.',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
        ),
        pratinjau('Sampul syukur: ', 'Kel. Wenas-Lasut'),
        ubah('Buat pilihan pribadi'),
      ],
      'Masih mudah dikenali' => [
        kartu(
          'Pilihan pribadi',
          'BIPRA + Kolom',
          tebal('Tampil sebagai: ', 'Remaja — Kolom 11'),
        ),
        Kartu(
          status: GarisStatus.draf,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Masih mudah dikenali.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text: 'Kolom 11 hanya punya satu anggota Remaja. Pilih “Kolom” atau “Tanpa nama” bila tidak ingin dikenali.',
                  style: TextStyle(color: c.tinta2),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        ubah('Ubah pilihan'),
      ],
      _ => [
        Text(
          'Pilihan pribadi',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
        for (final (nama, contoh) in _bentuk)
          _BarisRadio(
            nama: nama,
            contoh: contoh,
            dipilih: _mode == nama,
            onPilih: () => setState(() => _mode = nama),
          ),
        // The board's preview is static (review log: follow the selection).
        pratinjau('Syukur HUT pernikahan: ', 'Kel. Wenas-Lasut — Kolom 7'),
        Text(
          'Pilihan pribadi yang lebih tertutup mengalahkan bawaan keluarga untuk kegiatan Anda sendiri. Perubahan berlaku untuk publikasi berikutnya; edisi lama tidak berubah.',
          style: k13,
        ),
      ],
    };
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Tampilan nama saya di publikasi',
            anakJudul:
                'Pilihan Anda wajib diikuti di Warta Jemaat dan publikasi lain',
            kembaliKe: Layar.dataAnggota,
            labelKembali: 'Kembali ke Data jemaat',
          ),
          Expanded(
            child: SingleChildScrollView(
              key: ValueKey(v), // a view change starts at the top
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: isi,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A `<label>` radio row: the whole row is the target; the radio is the
/// TampilanNama component's drawn circle (PilihanBulat look).
class _BarisRadio extends StatelessWidget {
  const _BarisRadio({
    required this.nama,
    required this.contoh,
    required this.dipilih,
    required this.onPilih,
  });

  final String nama, contoh;
  final bool dipilih;
  final VoidCallback onPilih;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onPilih,
      tercentang: dipilih,
      label: '$nama, $contoh',
      radius: 14,
      child: Kartu(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: LayoutBuilder(
          builder: (context, ruang) => ConstrainedBox(
            // The label's min-height 44 is content-box: 66 with padding and line.
            constraints: const BoxConstraints(minHeight: 44),
            child: Row(
              spacing: 12,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.permukaan,
                    border: Border.all(
                      color: dipilih ? c.tinta : c.tinta3,
                      width: dipilih ? 6 : 1.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(nama, style: const TextStyle(fontSize: 15)),
                ),
                // CSS flex: the sample keeps its width, shrinking only past the row.
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: ruang.maxWidth - 46),
                  child: Text(
                    contoh,
                    style: TextStyle(fontSize: 13, color: c.tinta3),
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
