import 'package:flutter/material.dart';

import '../../mock/kolaborasi.dart';
import '../../mock/model.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/prototipe_state.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol.dart';

const _opsi = [
  'Draf',
  'Dijadwalkan',
  'Sedang berlangsung',
  'Selesai',
  'Ditutup',
  'Ibadah seluruh Jemaat',
];

/// 90 · Ibadah dan kegiatan: a Kolom service from Draf to Ditutup, plus a
/// whole-church service (spec 22, Ibadah).
class IbadahScreen extends StatefulWidget {
  const IbadahScreen({super.key});

  @override
  State<IbadahScreen> createState() => _IbadahScreenState();
}

class _IbadahScreenState extends State<IbadahScreen> {
  final _gulir = ScrollController();
  String? _k;
  String? _tweak;

  @override
  void dispose() {
    _gulir.dispose();
    super.dispose();
  }

  void _ke(String k) {
    setState(() => _k = k);
    if (_gulir.hasClients) _gulir.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tweak<String>('Ibadah', 'keadaan');
    if (t != _tweak) {
      // A panel change resets the in-board view (spec 22, shared rules).
      if (_tweak != null && _gulir.hasClients) _gulir.jumpTo(0);
      _tweak = t;
      _k = null;
    }
    final ki = _opsi.indexOf(_k ?? t).clamp(0, _opsi.length - 1);
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Ibadah dan kegiatan',
            anakJudul: 'Jadwal dan persetujuan; tanpa daftar petugas pelayanan',
            kembaliKe: 'BerandaJabatan',
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _gulir,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: _isi(ki),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _isi(int ki) => switch (ki) {
    0 => [
      const _KartuIbadah(
        lencana: LencanaStatus('Draf', bentuk: BentukLencana.draf),
        keterangan:
            'Disetujui oleh Penatua atau Syamas dari Kolom yang dituju: '
            'Pnt. Hendrik Rumagit atau Sym. Greis Mamahit.',
      ),
      BarisTombol(
        anak: [
          Tombol(
            'Setujui dan jadwalkan',
            jenis: JenisTombol.tinta,
            onPressed: () => _ke('Dijadwalkan'),
          ),
        ],
      ),
    ],
    1 => [
      const _KartuIbadah(
        lencana: LencanaStatus('Dijadwalkan', bentuk: BentukLencana.lautGaris),
        keterangan:
            'Disetujui oleh Pnt. Hendrik Rumagit, 16/11/2026. Yang menyetujui '
            'juga menugaskan petugas penghitung kehadiran.',
      ),
      const BarisTombol(
        anak: [
          Tombol(
            'Tugaskan penghitung kehadiran',
            onPressed: null,
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.sedang,
            ke: 'Kehadiran',
          ),
        ],
      ),
    ],
    2 => [
      const _KartuIbadah(
        lencana: LencanaStatus(
          'Sedang berlangsung',
          bentuk: BentukLencana.laut,
        ),
        keterangan: 'Jumlah kehadiran sedang dihitung.',
      ),
      const BarisTombol(
        anak: [
          Tombol(
            'Buka jumlah kehadiran',
            onPressed: null,
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.sedang,
            ke: 'Kehadiran',
          ),
        ],
      ),
    ],
    3 => const [
      _KartuIbadah(
        lencana: LencanaStatus('Selesai', bentuk: BentukLencana.garis),
        keterangan: 'Jumlah kehadiran: Sudah diperiksa, belum Ditetapkan.',
      ),
    ],
    4 => const [
      _KartuIbadah(
        lencana: LencanaStatus('Ditutup', bentuk: BentukLencana.tinta),
        keterangan:
            'Jumlah kehadiran Ditetapkan: $ibadahKolom7Ditutup. Persembahan '
            'dicatat di Keuangan sebagai Persembahan Ibadah Kolom.',
      ),
    ],
    _ => const [
      _KartuIbadah(
        ibadah: ibadahAdven,
        lencana: LencanaStatus('Dijadwalkan', bentuk: BentukLencana.lautGaris),
        keterangan:
            'Ibadah seluruh Jemaat dan kegiatan Panitia disetujui oleh Ketua '
            'Jemaat: Pdt. Lidya Rondonuwu, 15/11/2026. Bila tidak ada Ketua '
            'Jemaat: Sekretaris Jemaat atau yang ditunjuk.',
      ),
    ],
  };
}

/// The fact card: title and chip, the rows the service has, one caption.
class _KartuIbadah extends StatelessWidget {
  const _KartuIbadah({
    this.ibadah = ibadahKolom7,
    required this.lencana,
    required this.keterangan,
  });

  final Ibadah ibadah;
  final Widget lencana;
  final String keterangan;

  @override
  Widget build(BuildContext context) => Kartu(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        KepalaKartu(judul: ibadah.judul, ujung: lencana),
        if (ibadah.jenis.isNotEmpty) BarisInfo('Jenis', ibadah.jenis),
        BarisInfo('Waktu', ibadah.waktu),
        BarisInfo('Ditujukan untuk', ibadah.untuk),
        if (ibadah.tempat.isNotEmpty) BarisInfo('Tempat', ibadah.tempat),
        Text(
          keterangan,
          style: TextStyle(fontSize: 13, color: context.warna.tinta3),
        ),
      ],
    ),
  );
}
