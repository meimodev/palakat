import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/prototipe_state.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol.dart';

const _stem = 'Peristiwa';
const _jenis = [
  'Kelahiran',
  'Baptisan',
  'Sidi',
  'Pernikahan',
  'Kematian',
  'Pindah Kolom',
  'Atestasi masuk',
  'Atestasi keluar',
  'Tinggal sementara',
];

/// 77 · Peristiwa (spec 20). State `{ k: null }`; view = `k ?? keadaan`.
class PeristiwaScreen extends StatefulWidget {
  const PeristiwaScreen({super.key});

  @override
  State<PeristiwaScreen> createState() => _PeristiwaScreenState();
}

class _PeristiwaScreenState extends State<PeristiwaScreen> {
  String? _k;
  String? _tweak;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final t = context.tweak<String>(_stem, 'keadaan');
    if (_tweak != null && t != _tweak) _k = null; // panel change resets k
    _tweak = t;
  }

  void _ke(String k) => setState(() => _k = k);

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final v = _k ?? _tweak!;
    final k13 = TextStyle(fontSize: 13, color: c.tinta3);
    final k14 = TextStyle(fontSize: 14, color: c.tinta2);
    Widget kartu(
      String judul,
      String lencana,
      BentukLencana b,
      List<Widget> isi,
    ) => Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          KepalaKartu(
            judul: judul,
            ujung: LencanaStatus(lencana, bentuk: b),
          ),
          ...isi,
        ],
      ),
    );
    Widget isian(String label, String nilai) => IsianTeks(
      label: label,
      nilaiAwal: nilai,
      hanyaBaca: true,
      jarakLabel: 6,
      gaya: k14,
    );
    final List<Widget> isi = switch (v) {
      'Diajukan' => [
        kartu('Baptisan · Gabriel Wenas', 'Diajukan', BentukLencana.garis, [
          Text('Diajukan Novita Wenas, 15/11/2026', style: k14),
          Text(
            'Data anggota belum berubah sampai peristiwa ini Diverifikasi oleh Penatua Kolom 7.',
            style: k13,
          ),
        ]),
      ],
      'Diverifikasi' => [
        kartu('Baptisan · Gabriel Wenas', 'Diverifikasi', BentukLencana.laut, [
          Text('08/11/2026', style: k14),
          Text(
            'Diverifikasi oleh Pnt. Hendrik Rumagit, 17/11/2026. Tercatat di data Gabriel Wenas.',
            style: k13,
          ),
          Text(
            'Peristiwa Pernikahan yang Diverifikasi mengubah Kategori BIPRA kedua mempelai menjadi Bapa dan Ibu sejak tanggal pernikahan.',
            style: k13,
          ),
        ]),
      ],
      'Dikembalikan' => [
        kartu('Baptisan · Gabriel Wenas', 'Dikembalikan', BentukLencana.bata, [
          Text(
            'Alasan: nama di surat baptis “Gabriel J. Wenas”; mohon samakan.',
            style: k14,
          ),
          Text('Oleh Pnt. Hendrik Rumagit, 16/11/2026', style: k13),
        ]),
        BarisTombol(
          anak: [
            Tombol(
              'Ubah dan ajukan lagi',
              jenis: JenisTombol.tinta,
              onPressed: () => _ke('Mengajukan'),
            ),
          ],
        ),
      ],
      'Kematian' => [
        kartu('Kematian · Yohanis Rompas', 'Diverifikasi', BentukLencana.laut, [
          Text('14/11/2026 · diajukan keluarga', style: k14),
          Text(
            'Status menjadi Meninggal dunia; orangnya tidak dihapus. Sebab kematian tidak pernah tampil di publikasi. Jabatan Penatua Kolom 2 menjadi Jabatan kosong dan tidak diisi otomatis.',
            style: k13,
          ),
        ]),
        BarisTombol(
          tautan: const {0: 35},
          anak: [
            // An `<a>` is content-box: min-height 48 plus its 1.5 line.
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 51),
              child: Tombol(
                'Lihat penugasan jabatan',
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
                onPressed: null,
                ke: 'Penugasan',
              ),
            ),
          ],
        ),
      ],
      'Pindah Kolom' => [
        kartu(
          'Pindah Kolom · Keluarga Lasut',
          'Diajukan',
          BentukLencana.garis,
          [
            const BarisInfo('Dari', 'Kolom 4'),
            const BarisInfo('Ke', 'Kolom 7'),
            const BarisInfo('Berlaku', '01/12/2026'),
            const BarisInfo('Siapa', 'Seluruh keluarga (3 orang)'),
            Text(
              'Diverifikasi oleh Penatua Kolom asal dan tujuan. Jabatan tidak ikut pindah. Penugasan Kolom 4 disimpan dengan tanggal berakhirnya.',
              style: k13,
            ),
          ],
        ),
      ],
      _ => [
        Semantics(
          container: true,
          label: 'Jenis peristiwa: Baptisan dipilih',
          child: ExcludeSemantics(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final j in _jenis) _Chip(j, dipilih: j == 'Baptisan'),
              ],
            ),
          ),
        ),
        Kartu(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              isian('Untuk', 'Gabriel Wenas'),
              isian('Tanggal baptisan', '08/11/2026'),
              isian('Lampiran', 'surat-baptis.jpg'),
            ],
          ),
        ),
        Text(
          'Kelahiran tidak otomatis berarti baptisan. Peristiwa tidak otomatis tampil di Warta Jemaat.',
          style: k13,
        ),
        BarisTombol(
          anak: [
            Tombol(
              'Ajukan peristiwa',
              jenis: JenisTombol.tinta,
              onPressed: () => _ke('Diajukan'),
            ),
          ],
        ),
      ],
    };
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Peristiwa',
            anakJudul:
                'Diajukan anggota atau keluarga, diverifikasi Penatua Kolom',
            kembaliKe: 'DataAnggota',
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

/// A display-only chip (a `<span>` on the board): ChipSatu's look, but the
/// span's `min-height: 44` is content-box, so it stands 47 with its line.
class _Chip extends StatelessWidget {
  const _Chip(this.teks, {required this.dipilih});

  final String teks;
  final bool dipilih;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      constraints: const BoxConstraints(minHeight: 47),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: ShapeDecoration(
        color: dipilih ? c.tinta : c.permukaan,
        shape: GarisBorder.penuh(
          dipilih ? c.tinta : c.garisTegas,
          radius: PalakatRadius.chip,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            teks,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: dipilih ? c.permukaan : c.tinta,
            ),
          ),
        ],
      ),
    );
  }
}
