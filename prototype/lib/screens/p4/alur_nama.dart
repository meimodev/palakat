import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/perangkat_prototipe.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

/// The seven display-name forms and their preview (board `P`), in board order.
const _pratinjau = {
  'Nama lengkap': 'Novita Wenas',
  'Nama keluarga': 'Kel. Wenas-Lasut',
  'Keluarga + Kolom': 'Kel. Wenas-Lasut — Kolom 7',
  'Kolom': 'Anggota Kolom 7',
  'BIPRA': 'Anggota Pemuda',
  'BIPRA + Kolom': 'Anggota Pemuda Kolom 7',
  'Tanpa nama': 'Tanpa nama',
};

const _hariT = '16/11/2026';

class AlurNamaScreen extends StatefulWidget {
  const AlurNamaScreen({super.key});

  @override
  State<AlurNamaScreen> createState() => _AlurNamaScreenState();
}

class _AlurNamaScreenState extends State<AlurNamaScreen> {
  String _pesan = '', _v = 'nama';
  String _bentuk = 'Keluarga + Kolom', _simpan = 'Keluarga + Kolom';
  bool _paham = false;
  final List<String> _riw = [];

  // keHapus / pulang: each visit to `hapus` starts unticked.
  void _ke(String v) => setState(() {
    _v = v;
    _pesan = '';
    if (v == 'hapus') _paham = false;
  });

  void _simpanNama() => setState(() {
    _simpan = _bentuk;
    _pesan = 'Tampilan nama disimpan: $_bentuk.';
    _riw.insert(
      0,
      '$_hariT · Tampilan nama diubah menjadi $_bentuk · Novita Wenas',
    );
  });

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final isi = switch (_v) {
      'hapus' => _hapus(c),
      'sudah' => _sudah(c),
      _ => _nama(c),
    };
    return AlatPrototipe(
      stem: 'AlurNama',
      alat: [
        if (_v == 'sudah')
          const Text(
            'Layar ini hanya contoh: setelah penghapusan, akun tidak dapat lagi masuk.',
          ),
      ],
      child: LayarPonsel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Alur · Data saya',
              anakJudul:
                  'Memilih tampilan nama; mencabut izin dan menghapus data',
              kembaliKe: 'DataAnggota',
              labelKembali: 'Kembali ke Data jemaat',
            ),
            Expanded(
              child: SingleChildScrollView(
                // A view change starts the body at the top.
                key: ValueKey(_v),
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
      ),
    );
  }

  List<Widget> _nama(PalakatWarna c) {
    final ok = _bentuk != _simpan;
    return [
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tampilan nama saya di publikasi',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
          const SizedBox(height: 6),
          // The board's chips sit in a plain `gap: 8px` wrap (no bottom margin).
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final n in _pratinjau.keys)
                ChipSatu(
                  teks: n,
                  dipilih: _bentuk == n,
                  onTap: () => setState(() {
                    _bentuk = n;
                    _pesan = '';
                  }),
                ),
            ],
          ),
        ],
      ),
      Pesan(
        siaran: false,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lihat tampilan nama saya',
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Syukur ulang tahun: '),
                  TextSpan(
                    text: _pratinjau[_bentuk],
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      if (_bentuk == 'BIPRA + Kolom')
        Kartu(
          status: GarisStatus.draf,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              const Text(
                'Masih mudah dikenali.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                'Kolom 7 hanya punya dua anggota Pemuda.',
                style: TextStyle(color: c.tinta2),
              ),
            ],
          ),
        ),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: 'Simpan pilihan',
            tindakan: 'Simpan pilihan',
            alasan: ok ? '' : 'pilihan ini sudah tersimpan.',
            sudahMulai: false,
            onPressed: _simpanNama,
          ),
        ],
      ),
      Text(
        'Berlaku untuk publikasi berikutnya; edisi yang sudah diterbitkan tidak berubah. Hanya Sekretaris Jemaat yang dapat menampilkan nama sebagai pengecualian, dengan alasan, dan Anda diberi tahu.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      ),
      BarisTombol(
        anak: [
          Tombol(
            'Cabut izin dan hapus data saya',
            jenis: JenisTombol.teks,
            ukuran: UkuranTombol.kecil,
            onPressed: () => _ke('hapus'),
          ),
        ],
      ),
      if (_riw.isNotEmpty) RiwayatAlur(baris: _riw),
    ];
  }

  List<Widget> _hapus(PalakatWarna c) => [
    Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          const Text(
            'Yang dihapus',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            'Data pribadi Anda, riwayat keluarga dan Kolom, peristiwa, jabatan yang sedang dipegang (menjadi Jabatan kosong), dan akun Anda.',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
        ],
      ),
    ),
    Kartu(
      status: GarisStatus.draf,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          const Text(
            'Yang tetap ada',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            'Catatan keuangan Jemaat tetap menyimpan nama seperti yang tercatat, sebagai bagian dari pembukuan gereja. Warta Jemaat dan dokumen yang sudah diterbitkan tetap persis seperti saat diterbitkan.',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
        ],
      ),
    ),
    KotakCentang(
      nilai: _paham,
      onUbah: (v) => setState(() => _paham = v),
      label: const Text(
        'Saya mengerti data saya akan dihapus dan tidak dapat dikembalikan. Untuk menjadi anggota lagi saya harus mengajukan permohonan baru.',
      ),
    ),
    BarisTombol(
      anak: [
        TombolBersyarat(
          label: 'Cabut izin dan hapus data saya',
          tindakan: 'Cabut izin dan hapus data saya',
          alasan: _paham ? '' : 'centang dulu pernyataan di atas.',
          sudahMulai: false,
          onPressed: () => setState(() => _v = 'sudah'),
        ),
        Tombol(
          'Kembali',
          jenis: JenisTombol.teks,
          ukuran: UkuranTombol.kecil,
          onPressed: () => _ke('nama'),
        ),
      ],
    ),
  ];

  List<Widget> _sudah(PalakatWarna c) => [
    Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          const KepalaKartu(
            judul: 'Catatan penghapusan',
            ujung: LencanaStatus('Selesai', bentuk: BentukLencana.abu),
          ),
          const BarisInfo('Dihapus pada', _hariT),
          const BarisInfo('Atas permintaan', 'anggota sendiri'),
          Text(
            'Catatan ini tidak memuat data pribadi. Orangnya tidak lagi punya status di Data jemaat.',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
        ],
      ),
    ),
  ];
}
