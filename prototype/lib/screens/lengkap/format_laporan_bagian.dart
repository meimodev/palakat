import 'package:flutter/material.dart';

import '../../motion/kerangka.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

/// Parts shared by FormatLaporan and WebFormatLaporan (the boards draw the
/// same form, record and cards; only the shell and two link targets differ).

/// The board state `{ st, nama, jabatan, cara }`, owned by the screen.
class DataFormatLaporan {
  final nama = TextEditingController();
  final jabatan = TextEditingController(text: 'Ketua BPMJ');
  String cara = 'notulen rapat';
  bool ada = false;

  void dispose() {
    nama.dispose();
    jabatan.dispose();
  }
}

const _wajib = 'Pemberi persetujuan · wajib';

/// The Belum form or the Ada record, as the column children of the board's
/// `sc-if` blocks (gap is the parent column's).
List<Widget> bagianPersetujuan(
  BuildContext context,
  DataFormatLaporan d,
  void Function(VoidCallback) ubah,
) {
  final c = context.warna;
  final kecil = TextStyle(fontSize: 14, color: c.tinta2);
  if (d.ada) {
    return [
      Gerak(
        Kerangka.muncul,
        key: const ValueKey('ada'),
        lama: const Duration(milliseconds: 300),
        child: Kartu(
          status: GarisStatus.terpilih,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Persetujuan format: sudah dicatat',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Pemberi persetujuan:',
                      style: TextStyle(color: c.tinta2),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: d.nama.text,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: ', ${d.jabatan.text}'),
                  ],
                ),
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text('03/10/2026 · cara: ${d.cara}', style: kecil),
              const SizedBox(height: 4 + 8),
              GarisLurus(warna: c.garisTegas, gaya: GayaGaris.putus),
              const SizedBox(height: 8),
              Text(
                'Dicatat oleh Meiske L., 03/10/2026 11.40. Persetujuan '
                'diberikan di luar aplikasi. Catatan yang keliru digantikan '
                'catatan baru, tidak diubah.',
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
            ],
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.lautLembut,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          'Syarat tutup buku “persetujuan format laporan sudah dicatat” '
          'terpenuhi.',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    ];
  }

  String alasan() => d.nama.text.trim().isEmpty ? _wajib : '';
  return [
    Kartu(
      status: GarisStatus.hambatan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Persetujuan format: belum dicatat',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            'Hambatan tutup buku sampai dicatat. Pimpinan Jemaat yang '
            'berwenang menyetujui format di luar aplikasi; Anda mencatatnya '
            'di sini.',
            style: kecil,
          ),
        ],
      ),
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: Text.rich(
            TextSpan(
              text: 'Pemberi persetujuan ',
              children: [
                TextSpan(
                  text: '· wajib',
                  style: TextStyle(color: c.tinta, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            style: kecil,
          ),
        ),
        const SizedBox(height: 6),
        IsianTeks(
          controller: d.nama,
          labelSemantik: _wajib,
          petunjuk: 'Nama lengkap',
          onChanged: (_) => ubah(() {}),
        ),
      ],
    ),
    IsianTeks(
      controller: d.jabatan,
      label: 'Jabatan',
      jarakLabel: 6,
      onChanged: (_) => ubah(() {}),
    ),
    ChipPilihan<String>(
      label: 'Cara',
      pilihan: const [
        (nilai: 'surat', teks: 'surat'),
        (nilai: 'notulen rapat', teks: 'notulen rapat'),
        (nilai: 'pesan', teks: 'pesan'),
      ],
      terpilih: d.cara,
      onPilih: (v) => ubah(() => d.cara = v),
    ),
    Container(
      constraints: const BoxConstraints(minHeight: 44),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.garis)),
      ),
      child: Row(
        children: [
          Expanded(child: Text('Tanggal persetujuan', style: kecil)),
          const SizedBox(width: 16),
          const Text(
            '3 Oktober 2026',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
    TombolBersyarat(
      label: 'Catat persetujuan format',
      tindakan: 'Catat persetujuan format',
      alasan: alasan(),
      periksa: alasan,
      // The board shows no reason sentence; the reason is the semantics hint.
      sudahMulai: false,
      warnaSiap: JenisTombol.utama,
      teksBelumRedup: true,
      paddingH: 20,
      onPressed: () => ubah(() => d.ada = true),
    ),
  ];
}

/// Cards g, h, i. [tautan] are the two link-buttons of card g, built by the
/// screen (their targets differ per board).
List<Widget> kartuFormat(BuildContext context, List<Widget> tautan) {
  final c = context.warna;
  final kecil = TextStyle(fontSize: 14, color: c.tinta2);
  final catatan = TextStyle(fontSize: 13, color: c.tinta3);
  Widget kartu(double jarak, List<Widget> anak) => Kartu(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < anak.length; i++) ...[
          if (i > 0) SizedBox(height: jarak),
          anak[i],
        ],
      ],
    ),
  );
  const tebal = TextStyle(fontWeight: FontWeight.w700);
  return [
    kartu(6, [
      Text('Format laporan', style: kecil),
      const Text(
        'Bawaan Palakat · v1',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      Text(
        'Empat belas laporan, F01 sampai F14. Format ini buatan aplikasi dan '
        'tidak mengaku sama dengan formulir asli GMIM.',
        style: kecil,
      ),
      Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Wrap(spacing: 8, runSpacing: 8, children: tautan),
      ),
      Text(
        'Contoh memuat angka negatif, Rp0 dan isian kosong supaya cara '
        'cetaknya ikut dinilai.',
        style: catatan,
      ),
    ]),
    kartu(4, [
      const Text('Lampiran F14', style: tebal),
      for (final (i, n) in const [
        'Uang Muka',
        'Rincian Pertanggungjawaban Uang Muka',
        'Penghitungan Persembahan',
        'Penggantian Biaya',
        'Pengecualian Dokumen Pendukung',
        'Pembalikan dan Koreksi',
        'Saldo Awal Pencatatan',
        'Hasil Pengecekan Otomatis',
      ].indexed)
        Text('${i + 1}. $n', style: kecil),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'Lampiran tanpa isi dicetak sebagai “Nihil”.',
          style: catatan,
        ),
      ),
    ]),
    kartu(4, [
      const Text('Penanda tangan, dari pengaturan', style: tebal),
      Text('Bendahara · Meiske Lumentut', style: kecil),
      Text('Ketua BPMJ · [NAMA DARI PENGATURAN]', style: kecil),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'Laporan mencetak nama dan garis kosong. Tidak ada tanda tangan '
          'tiruan.',
          style: catatan,
        ),
      ),
    ]),
  ];
}

/// "Lihat contoh PDF" / "Lihat contoh Excel": min height 46, padding 0 20,
/// radius 12, 1.5 `tinta` line, `permukaan`, 700.
Widget tombolContoh(String label, {required String ke}) => Tombol(
  label,
  onPressed: null,
  jenis: JenisTombol.kedua,
  ukuran: UkuranTombol.ringkas,
  lebarPenuh: false,
  ke: ke,
);
