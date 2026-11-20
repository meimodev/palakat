import 'package:flutter/widgets.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

const _o = ['Daftar pelimpahan', 'Buat pelimpahan', 'Berakhir sendiri'];

/// 50 · Pelimpahan tugas (spec 14). State `{k: null}`; the view is
/// `k ?? keadaan`. A panel change resets `k`; every view change scrolls up.
class PelimpahanScreen extends StatefulWidget {
  const PelimpahanScreen({super.key});
  @override
  State<PelimpahanScreen> createState() => _PelimpahanState();
}

class _PelimpahanState extends State<PelimpahanScreen> {
  String? _k, _keadaan, _tampil;
  final _gulir = ScrollController();

  @override
  void dispose() {
    _gulir.dispose();
    super.dispose();
  }

  void _ke(String v) => setState(() => _k = v);

  @override
  Widget build(BuildContext context) {
    final keadaan = belumDipindah<String>('Daftar pelimpahan');
    if (keadaan != _keadaan) {
      _keadaan = keadaan;
      _k = null;
    }
    final tampil = _k ?? keadaan;
    if (tampil != _tampil) {
      if (_tampil != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_gulir.hasClients) _gulir.jumpTo(0);
        });
      }
      _tampil = tampil;
    }
    final c = context.warna;

    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Pelimpahan tugas',
            anakJudul: 'Bertanggal, terbatas pada satu unit, berakhir sendiri',
            kembaliKe: Layar.beranda,
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _gulir,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: switch (_o.indexOf(tampil)) {
                  1 => _buat(c),
                  2 => _berakhir(c),
                  _ => _daftar(c),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _daftar(PalakatWarna c) => [
    _KartuPelimpahan(
      judul: 'Penatua Kolom 7 → Sym. Greis Mamahit',
      lencana: const LencanaStatus('Aktif', bentuk: BentukLencana.laut),
      rincian: 'Verifikasi data Kolom 7 · 16/11/2026 sampai 30/11/2026',
      catatan:
          'Dilimpahkan oleh Pnt. Hendrik Rumagit. Tidak memindahkan wewenang '
          'persetujuan ibadah.',
    ),
    _KartuPelimpahan(
      judul: 'Sekretaris Jemaat → Yanti Sumual',
      lencana: const LencanaStatus('Berakhir', bentuk: BentukLencana.abu),
      rincian: 'Menyusun draf pengumuman · 03/11/2026 sampai 10/11/2026',
      catatan: 'Berakhir sendiri pada tanggalnya.',
    ),
    BarisTombol(
      anak: [
        Tombol(
          'Buat pelimpahan',
          onPressed: () => _ke(_o[1]),
          jenis: JenisTombol.tinta,
        ),
      ],
    ),
  ];

  List<Widget> _buat(PalakatWarna c) {
    Widget isian(String label, String nilai) => IsianTeks(
      key: ValueKey(label),
      label: label,
      nilaiAwal: nilai,
      jarakLabel: 6,
      hanyaBaca: true,
      gaya: TextStyle(fontSize: 14, color: c.tinta2),
    );
    return [
      Kartu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            isian('Yang melimpahkan', 'Pnt. Hendrik Rumagit · Penatua Kolom 7'),
            isian('Kepada', 'Sym. Greis Mamahit'),
            isian('Tugas', 'Verifikasi data anggota'),
            isian('Unit', 'Kolom 7'),
            // grid minmax(300px, 1fr): one column in the 316 px card.
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                isian('Mulai', '16/11/2026'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 6,
                  children: [
                    isian('Sampai', '30/11/2026'),
                    Text(
                      'Wajib: pelimpahan selalu punya tanggal akhir',
                      style: TextStyle(fontSize: 13, color: c.tinta3),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      Text(
        'Pelimpahan tugas administrasi tidak memindahkan wewenang. Setiap '
        'tindakan mencatat pelaku, jabatan yang dijalankan, unit, atas nama '
        'siapa dan waktunya.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      ),
      BarisTombol(
        anak: [
          Tombol(
            'Simpan pelimpahan',
            onPressed: () => _ke(_o[0]),
            jenis: JenisTombol.tinta,
          ),
          Tombol(
            'Batalkan',
            onPressed: () => _ke(_o[0]),
            jenis: JenisTombol.teks,
          ),
        ],
      ),
    ];
  }

  List<Widget> _berakhir(PalakatWarna c) => [
    Kartu(
      status: GarisStatus.draf,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(
              text: 'Pelimpahan berakhir 30/11/2026.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text:
                  ' Verifikasi data Kolom 7 kembali hanya kepada Pnt. Hendrik '
                  'Rumagit.',
              style: TextStyle(color: c.tinta2),
            ),
          ],
        ),
        style: const TextStyle(fontSize: 14),
      ),
    ),
    const Penolakan(
      tindakan: 'Verifikasi data',
      sebab: 'Pelimpahan tugas Anda untuk Kolom 7 sudah berakhir.',
      jalan: [],
    ),
    // An `<a>` is content-box: max-width 340 + padding 32 + line 3 = 375
    // wide, 48 + 3 = 51 high.
    Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 375),
        child: const SizedBox(
          width: double.infinity,
          height: 51,
          child: Tombol(
            'Kembali ke Beranda',
            onPressed: null,
            ke: Layar.beranda,
            cara: Cara.naik,
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.sedang,
          ),
        ),
      ),
    ),
  ];
}

/// Delegation card: `permukaan`, 1 `garis`, radius 14, padding 14 16, gap 6.
class _KartuPelimpahan extends StatelessWidget {
  const _KartuPelimpahan({
    required this.judul,
    required this.lencana,
    required this.rincian,
    required this.catatan,
  });

  final String judul, rincian, catatan;
  final Widget lencana;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          KepalaKartu(judul: judul, ujung: lencana),
          Text(rincian, style: TextStyle(fontSize: 14, color: c.tinta2)),
          Text(catatan, style: TextStyle(fontSize: 13, color: c.tinta3)),
        ],
      ),
    );
  }
}
