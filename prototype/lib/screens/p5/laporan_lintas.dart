import 'package:flutter/widgets.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// 92 · Laporan (spec 22): reports across modules, filtered by the reach of
/// each post. The view is the `keadaan` tweak; the board binds no handlers.
class LaporanLintasScreen extends StatelessWidget {
  const LaporanLintasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final keadaan = belumDipindah<String>('Seluruh Jemaat');
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Laporan',
            anakJudul:
                'Dari data yang sah, disaring menurut jangkauan tiap jabatan',
            kembaliKe: Layar.beranda,
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: IsiLaporanLintas(keadaan: keadaan),
            ),
          ),
        ],
      ),
    );
  }
}

const _opsi = [
  'Seluruh Jemaat',
  'Kolom 7',
  'Panitia Natal 2026',
  'Modul tidak aktif',
];

/// Stats per reach: s0, s1, s2, s3, k0t. Only the first two are ever shown.
const _stat = [
  ['1.284', '412', '7', '412', 'di 12 Kolom'],
  ['96', '31', '2', '38', 'Kolom 7 saja'],
];

/// Money card per reach: uj, uv, uk. U+2060 keeps "Kas/Bank" whole: Chrome
/// does not break after the slash there, Flutter would.
const _uang = [
  [
    'Saldo buku semua Kas/\u2060Bank',
    'Rp38.415.000',
    'Keuangan · hanya yang sudah dibukukan',
  ],
  [
    'Saldo buku peruntukan Kolom 7',
    'Rp1.240.000',
    'Keuangan unit · Kas Kolom 7',
  ],
  [
    'Saldo buku peruntukan Panitia Natal',
    'Rp4.350.000',
    'Panitia · tahap Aktif',
  ],
  [
    'Saldo buku semua Kas/\u2060Bank',
    'Rp38.415.000',
    'Keuangan · hanya yang sudah dibukukan',
  ],
];

const _dimensi = [
  'Jemaat',
  'Kolom',
  'BIPRA',
  'Komisi',
  'Panitia',
  'Peruntukan',
  'Kas/Bank',
];

/// The content column shared with WebLaporanLintas: chips, stats, money card,
/// module-off note and footer caption, gap 16. Body size is inherited (16 on
/// the phone, 15 on the web).
class IsiLaporanLintas extends StatelessWidget {
  const IsiLaporanLintas({super.key, required this.keadaan});

  final String keadaan;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final ki = _opsi.indexOf(keadaan).clamp(0, 3);
    final ket = TextStyle(fontSize: 13, color: c.tinta3);
    final u = _uang[ki];

    Widget stat(String label, String nilai, String sub) => Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ket),
          const SizedBox(height: 6),
          Text(
            nilai,
            style: const TextStyle(
              fontFamily: PalakatText.mono,
              fontSize: 26,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(sub, style: ket),
        ],
      ),
    );

    final anak = <Widget>[
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [for (final d in _dimensi) _Chip(d)],
      ),
      if (ki < 2)
        KisiOtomatis(
          minLebar: 300,
          jarak: 16,
          anak: [
            stat('Anggota aktif', _stat[ki][0], _stat[ki][4]),
            stat('Keluarga', _stat[ki][1], 'dengan riwayat Kolom'),
            stat(
              'Peristiwa diverifikasi · November 2026',
              _stat[ki][2],
              '2 kelahiran · 3 baptisan · 1 pernikahan · 1 kematian',
            ),
            stat(
              'Jumlah kehadiran Minggu 15/11/2026',
              _stat[ki][3],
              'hanya yang Ditetapkan',
            ),
          ],
        ),
      Kartu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    u[0],
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  u[1],
                  style: const TextStyle(
                    fontFamily: PalakatText.mono,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(u[2], style: ket),
          ],
        ),
      ),
      if (ki == 3)
        Kartu(
          status: GarisStatus.draf,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 14),
              children: [
                const TextSpan(
                  text: 'Data jemaat dan Jumlah kehadiran belum aktif.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text: 'Laporannya tidak tampil. Laporan keuangan tetap tersedia.',
                  style: TextStyle(color: c.tinta2),
                ),
              ],
            ),
          ),
        ),
      Text(
        'Tidak ada penyusun laporan bebas. Laporan tidak pernah memuat '
        'kehadiran per orang atau gabungan kehadiran dengan persembahan.',
        style: ket,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < anak.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          anak[i],
        ],
      ],
    );
  }
}

/// A static dimension chip (a `<span>`, not pressable): unselected
/// ChipPilihan look, min height 44 plus the 1.5 border (content-box).
class _Chip extends StatelessWidget {
  const _Chip(this.teks);
  final String teks;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      constraints: const BoxConstraints(minHeight: 47),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: GarisBorder.penuh(c.garisTegas, radius: 999),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            teks,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
