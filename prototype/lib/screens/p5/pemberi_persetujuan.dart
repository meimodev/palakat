import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

/// Unit type → its two approver posts, in board order.
const _p = {
  'Kolom': ['Penatua Kolom', 'Ketua Jemaat'],
  'BIPRA': ['Ketua BIPRA', 'Ketua Jemaat'],
  'Komisi': ['Ketua Komisi', 'Ketua Jemaat'],
  'Panitia': ['Ketua Panitia', 'Ketua Jemaat'],
};

/// 98 · Alur · Pemberi persetujuan: the approver table (23-alurunit.md).
class PemberiPersetujuanScreen extends StatefulWidget {
  const PemberiPersetujuanScreen({super.key});

  @override
  State<PemberiPersetujuanScreen> createState() =>
      _PemberiPersetujuanScreenState();
}

class _PemberiPersetujuanScreenState extends State<PemberiPersetujuanScreen> {
  final _t = <String, String>{};
  var _simpan = false;
  var _pesan = '';
  final _riw = <String>[];

  List<String> get _kosong => [
    for (final k in _p.keys)
      if (_t[k] == null) k,
  ];

  void _simpanTabel() => setState(() {
    _simpan = true;
    _pesan = 'Tabel pemberi persetujuan disimpan.';
    final isi = [for (final k in _p.keys) '$k → ${_t[k]}'].join('; ');
    _riw.insert(
      0,
      '16/11/2026 · Tabel pemberi persetujuan disimpan: $isi · Pdt. Lidya Rondonuwu',
    );
  });

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final kosong = _kosong;
    final alasan = kosong.isEmpty
        ? ''
        : 'belum ada pemberi persetujuan untuk ${kosong.join(', ')}.';

    final isi = <Widget>[
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      Text(
        'Diisi sekali oleh Pimpinan Jemaat yang berwenang. Berlaku untuk Permintaan dana dan persetujuan lain di aplikasi.',
        style: TextStyle(fontSize: 14, color: c.tinta2),
      ),
      for (final MapEntry(key: k, value: pil) in _p.entries)
        Kartu(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Text(
                'Permintaan dari $k',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              // The board's pills sit in a flex row with `gap: 8px` both ways,
              // not ChipPilihan's `margin: 0 8px 8px 0`.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final n in pil)
                    ChipSatu(
                      teks: n,
                      dipilih: _t[k] == n,
                      onTap: () => setState(() {
                        _t[k] = n;
                        _simpan = false;
                        _pesan = '';
                      }),
                    ),
                ],
              ),
            ],
          ),
        ),
      Text(
        'Yang mengajukan tidak pernah menyetujui pengajuannya sendiri, walau jabatannya tercantum di sini. Bila jabatan pemberi persetujuan kosong, permintaan menunggu sampai ada pemegangnya.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      ),
      // The line shows only while one to three rows are unchosen.
      if (alasan.isNotEmpty && kosong.length < 4)
        Penolakan(
          tindakan: 'Simpan tabel',
          sebab: alasan,
          jalan: const [],
          ukuranTeks: 14,
        ),
      TombolBersyarat(
        label: 'Simpan tabel',
        tindakan: 'Simpan tabel',
        alasan: alasan,
        onPressed: _simpanTabel,
        sudahMulai: false,
        warnaSiap: JenisTombol.tinta,
        baris: const [],
      ),
      // The board's link is an `<a>`, so content-box: its max-width 340 and
      // min-height 48 exclude padding and the 1.5 line, which makes it span
      // the whole 350 column and stand 51 high.
      if (_simpan)
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 51),
          child: const Tombol(
            'Aktifkan modul Persetujuan di aplikasi',
            onPressed: null,
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.sedang,
            ke: 'AlurModul',
          ),
        ),
      if (_riw.isNotEmpty) RiwayatAlur(baris: _riw),
    ];

    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Alur · Pemberi persetujuan',
            anakJudul:
                'Jabatan mana yang menyetujui permintaan dari tiap jenis unit',
            kembaliKe: 'Modul',
            labelKembali: 'Kembali ke Modul',
          ),
          Expanded(
            child: SingleChildScrollView(
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
