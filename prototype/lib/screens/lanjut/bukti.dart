import 'package:flutter/material.dart';

import '../../mock/format.dart';
import '../../motion/kerangka.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';

/// 16 · Daftar Bukti Kas dan celah nomor (spec 06-bukti.md, Bukti).
class BuktiScreen extends StatefulWidget {
  const BuktiScreen({super.key});

  @override
  State<BuktiScreen> createState() => _BuktiScreenState();
}

/// One Bukti Kas row of the board's `R` table.
typedef _Baris = ({
  String no,
  String tgl,
  String ur,
  String tanda,
  String asal,
  int jumlah,
  String setuju,
  String dok,
  bool wajib,
});

const List<_Baris> _baris = [
  (
    no: 'BKU-2026-0147',
    tgl: '16/11/2026',
    ur: 'Fotokopi warta jemaat',
    tanda: '',
    asal: '',
    jumlah: -150000,
    setuju: 'tidak diperlukan (aturan: transaksi rutin)',
    dok: 'diunggah, belum diverifikasi',
    wajib: false,
  ),
  (
    no: 'BKU-2026-0146',
    tgl: '15/11/2026',
    ur: 'Persembahan Ibadah Minggu',
    tanda: '',
    asal: '',
    jumlah: 3450000,
    setuju: 'tidak diperlukan (aturan: Pendapatan)',
    dok: 'terverifikasi (oleh Meiske L.)',
    wajib: false,
  ),
  (
    no: 'BKU-2026-0143',
    tgl: '11/11/2026',
    ur: 'Sewa sound system',
    tanda: '',
    asal: '',
    jumlah: -600000,
    setuju: 'tidak diperlukan (aturan: transaksi rutin)',
    dok: 'wajib, belum ada',
    wajib: true,
  ),
  (
    no: 'BKU-2026-0139',
    tgl: '09/11/2026',
    ur: 'Konsumsi rapat majelis',
    tanda: 'Dibalik oleh No. Bukti BKU-2026-0144',
    asal: '',
    jumlah: -750000,
    setuju: 'tidak diperlukan (aturan: transaksi rutin)',
    dok: 'terverifikasi (oleh Meiske L.)',
    wajib: false,
  ),
  (
    no: 'BKU-2026-0137',
    tgl: '08/11/2026',
    ur: 'Renovasi pastori, termin 1',
    tanda: '',
    asal: 'KW-0412',
    jumlah: -4500000,
    setuju: 'sudah dicatat · Pdt. Lidya Rondonuwu, Ketua BPMJ',
    dok: 'dikecualikan (alasan: kuitansi menyusul, oleh Ketua BPMJ)',
    wajib: false,
  ),
];

/// The three unused numbers of the Biasa series (code, when it was given).
const _celah = [
  ('BKU-2026-0111', '14/10/2026 10.20'),
  ('BKU-2026-0124', '29/10/2026 16.05'),
  ('BKU-2026-0126', '30/10/2026 09.12'),
];

const _mono = TextStyle(
  fontFamily: PalakatText.mono,
  fontFeatures: [FontFeature.tabularFigures()],
);

class _BuktiScreenState extends State<BuktiScreen> {
  String _tab = 'Daftar';

  /// Bumped on every chip press: the board re-renders the view, so the
  /// Celah nomor fade replays and the scroll goes back to the top.
  int _versi = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return LayarPonsel(
      jabatanKosong: true,
      // CSS splits line-height leading evenly above and below each font;
      // without this the mono spans make mixed lines taller than the board.
      child: DefaultTextStyle.merge(
        style: const TextStyle(
          leadingDistribution: TextLeadingDistribution.even,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Daftar Bukti Kas',
              anakJudul: 'November 2026 · Belum ditutup',
              kembaliKe: 'Lainnya',
              labelKembali: 'Kembali ke Lainnya',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: ChipPilihan<String>(
                pilihan: const [
                  (nilai: 'Daftar', teks: 'Daftar'),
                  (nilai: 'Celah nomor', teks: 'Celah nomor'),
                ],
                terpilih: _tab,
                onPilih: (t) => setState(() {
                  _tab = t;
                  _versi++;
                }),
                jarakBaris: 0,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                key: ValueKey(_versi),
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: _tab == 'Daftar'
                    ? _daftar(c)
                    : Gerak(
                        Kerangka.pudar,
                        lama: const Duration(milliseconds: 200),
                        child: _celahNomor(c),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _daftar(PalakatWarna c) {
    final kecil = TextStyle(fontSize: 13, color: c.tinta2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final r in _baris)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Kartu(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          '${r.no} · ${r.tgl}',
                          style: _mono.copyWith(fontSize: 13, color: c.tinta2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        rp(r.jumlah),
                        style: _mono.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r.ur,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (r.tanda.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(r.tanda, style: kecil),
                  ],
                  if (r.asal.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        text: 'No. bukti asal ',
                        children: [TextSpan(text: r.asal, style: _mono)],
                      ),
                      style: kecil,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: c.garis)),
                    ),
                    child: Text('Persetujuan: ${r.setuju}', style: kecil),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dokumen pendukung: ${r.dok}',
                    style: TextStyle(
                      fontSize: 13,
                      color: r.wajib ? c.bata : c.tinta2,
                      fontWeight: r.wajib ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Text(
          'Contoh 5 dari 51. Transaksi yang dibalik tetap ada di daftar.',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ],
    );
  }

  Widget _celahNomor(PalakatWarna c) {
    const judul = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);
    final sub = TextStyle(fontSize: 14, color: c.tinta2);
    Widget seri(String j, String s) => Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(j, style: judul),
          Text(s, style: sub),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Kartu(
          status: GarisStatus.terpilih,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text.rich(
                const TextSpan(
                  text: 'Seri Biasa · ',
                  children: [
                    TextSpan(text: 'BKU-2026-0001', style: _mono),
                    TextSpan(text: ' sampai '),
                    TextSpan(text: '0151', style: _mono),
                  ],
                ),
                style: judul,
              ),
              const SizedBox(height: 4),
              const Text(
                '3 nomor tanpa transaksi',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              for (final (kode, waktu) in _celah) ...[
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: kode,
                        style: _mono.copyWith(color: c.tinta),
                      ),
                      TextSpan(
                        text:
                            ' · diberikan $waktu, pembukuannya tidak selesai. '
                            'Nomor ini tidak dipakai ulang.',
                      ),
                    ],
                  ),
                  style: sub,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        seri('Seri OPN Saldo awal pencatatan', 'Tidak ada celah'),
        const SizedBox(height: 10),
        seri('Seri ADJ Penyesuaian', 'Belum pernah dipakai'),
        const SizedBox(height: 10),
        Text(
          'Hanya terlihat oleh yang melihat seluruh Jemaat.',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ],
    );
  }
}
