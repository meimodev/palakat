import 'package:flutter/widgets.dart';

import '../../mock/format.dart';
import '../../mock/mock.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/tautan.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tombol.dart';
import 'permintaan_dana_keadaan.dart';

const _opsi = [
  'Menunggu persetujuan',
  'Disetujui',
  'Tidak disetujui',
  'Kembali menunggu',
  'Menyetujui permintaan sendiri',
  'Di bawah batas',
  'Persetujuan di luar aplikasi',
];

/// 88 · Permintaan dana (spec 22): the approver's view of a unit's request.
class PermintaanDanaScreen extends StatelessWidget {
  const PermintaanDanaScreen({super.key});

  @override
  Widget build(BuildContext context) => PapanKeadaan(
    stem: 'PermintaanDana',
    opsi: _opsi,
    kepala: const KepalaPonsel(
      judul: 'Permintaan dana',
      anakJudul: 'Minta, periksa, setujui, bayar, verifikasi: lima tindakan yang terpisah',
      kembaliKe: 'KeuanganUnit',
      labelKembali: 'Kembali ke Keuangan',
    ),
    isi: _isi,
  );
}

const _p = permintaanDanaNatalPemuda;

/// The request card: title, badge, the three fact rows, then [ekor].
Widget _kartu(String label, BentukLencana bentuk, List<Widget> ekor) =>
    KartuFakta(
      anak: [
        KepalaLencana('Permintaan dana · ${_p.perlu}', label, bentuk: bentuk),
        BarisFakta(
          'Jumlah (Rp)',
          rp(_p.jumlah),
          mono: true,
          berat: FontWeight.w500,
        ),
        BarisFakta('Diambil dari peruntukan', _p.peruntukan),
        BarisFakta('Diajukan oleh', _p.diajukanOleh),
        ...ekor,
      ],
    );

List<Widget> _isi(String k, ValueChanged<String> pilih) => switch (k) {
  'Disetujui' => [
    _kartu('Disetujui oleh Pdt. Lidya Rondonuwu', BentukLencana.laut, [
      Keterangan(
        'Disetujui di aplikasi oleh orang yang masuk sendiri, '
        '${permintaanDana.disetujui}.',
      ),
    ]),
    const Catatan(
      status: GarisStatus.draf,
      tebal: 'Disetujui bukan berarti sudah dibayar.',
      sisa: 'Pembayarannya adalah Belanja tersendiri yang dibukukan Bendahara Jemaat.',
      redup: true,
    ),
    const BarisTombol(
      tautan: {0: 35},
      anak: [
        // An `<a>` on the board: content-box, min-height 48 plus the 1.5 lines.
        SizedBox(
          height: 51,
          child: Tombol(
            'Catat pembayaran',
            onPressed: null,
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.sedang,
            ke: 'Main',
            cara: Cara.ganti,
          ),
        ),
      ],
    ),
  ],
  'Tidak disetujui' => [
    _kartu('Tidak disetujui', BentukLencana.bata, [
      BarisPolos('Alasan: ${permintaanDana.alasanTolak}'),
      Keterangan('Oleh Pdt. Lidya Rondonuwu, ${permintaanDana.ditolak}'),
    ]),
  ],
  'Kembali menunggu' => [
    _kartu('Menunggu persetujuan', BentukLencana.draf, [
      Keterangan(
        'Jumlah diubah dari ${rp(_p.jumlah)} menjadi '
        '${rp(permintaanDana.jumlahBaru)} setelah disetujui. Persetujuan lama '
        'tidak berlaku lagi dan tetap ada di Riwayat.',
      ),
    ]),
  ],
  'Menyetujui permintaan sendiri' => [
    _kartu('Menunggu persetujuan', BentukLencana.draf, const []),
    const Penolakan(
      tindakan: 'Setujui',
      sebab: 'permintaan ini Anda ajukan sendiri sebagai Ketua Pemuda.',
      jalan: [],
      ukuranTeks: 15,
    ),
    const Keterangan(
      'Jabatan Anda yang lain tidak membuka jalan menyetujui permintaan sendiri.',
    ),
  ],
  'Di bawah batas' => [
    KartuFakta(
      anak: [
        KepalaLencana(
          'Permintaan dana · ${permintaanDana.kecilPerlu}',
          'Tidak diperlukan',
          bentuk: BentukLencana.garis,
        ),
        BarisFakta(
          'Jumlah (Rp)',
          rp(permintaanDana.kecilJumlah),
          mono: true,
          berat: FontWeight.w500,
        ),
        const Keterangan(
          'Tidak diperlukan (aturan: $teksBatasPermintaanDana).',
        ),
      ],
    ),
  ],
  'Persetujuan di luar aplikasi' => [
    KartuFakta(
      anak: [
        const KepalaLencana(
          'Persetujuan di luar aplikasi',
          'Persetujuan sudah dicatat',
          bentuk: BentukLencana.garis,
        ),
        BarisPolos('Pemberi persetujuan: ${permintaanDana.persetujuanLuar}'),
        const Keterangan(
          'Dicatat oleh Meiske L. Catatan lama ini tetap pernyataan Bendahara '
          'dan tidak pernah diubah menjadi “Disetujui oleh” di aplikasi.',
        ),
      ],
    ),
  ],
  _ => [
    _kartu('Menunggu persetujuan', BentukLencana.draf, [
      const Keterangan(
        'Pemberi persetujuan menurut tabel Jemaat: Ketua Jemaat untuk '
        'peruntukan Umum Jemaat.',
      ),
    ]),
    BarisTombol(
      anak: [
        Tombol(
          'Setujui',
          onPressed: () => pilih('Disetujui'),
          jenis: JenisTombol.tinta,
        ),
        Tombol(
          'Tidak disetujui',
          onPressed: () => pilih('Tidak disetujui'),
          jenis: JenisTombol.kedua,
          ukuran: UkuranTombol.sedang,
        ),
      ],
    ),
  ],
};
