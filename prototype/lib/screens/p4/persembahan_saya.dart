import 'package:flutter/widgets.dart';

import '../../mock/format.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol.dart';

const _stem = 'PersembahanSaya';
const _ada = 'Ada persembahan bernama',
    _rincian = 'Rincian',
    _belum = 'Belum ada',
    _bukan = 'Bukan persembahan saya';

/// 81 · Persembahan saya: only the gifts recorded in the member's name.
/// Board state `{ k: null }`; the view is `k ?? keadaan`.
class PersembahanSayaScreen extends StatefulWidget {
  const PersembahanSayaScreen({super.key});

  @override
  State<PersembahanSayaScreen> createState() => _PersembahanSayaScreenState();
}

class _PersembahanSayaScreenState extends State<PersembahanSayaScreen> {
  String? _k;
  String? _keadaan;

  void _ke(String o) => setState(() => _k = o);

  @override
  Widget build(BuildContext context) {
    final keadaan = context.tweak<String>(_stem, 'keadaan');
    if (keadaan != _keadaan) {
      _keadaan = keadaan;
      _k = null; // a change in the Keadaan panel resets the board state
    }
    final v = _k ?? keadaan;
    final c = context.warna;
    final s13 = TextStyle(fontSize: 13, color: c.tinta3);
    const mono = TextStyle(
      fontFamily: PalakatText.mono,
      fontWeight: FontWeight.w500,
    );

    Widget kartu(String judul, int jumlah, String baris) => Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaKartu(
            judul: judul,
            ujung: Text(rp(jumlah), style: mono),
          ),
          const SizedBox(height: 6),
          Text(baris, style: s13),
        ],
      ),
    );

    final isi = switch (v) {
      _rincian => [
        Kartu(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KepalaKartu(
                judul: 'Sampul syukur',
                ujung: LencanaStatus.uang(StatusUang.dibukukan),
              ),
              for (final b in [
                BarisInfo(
                  'Jumlah (Rp)',
                  rp(100000),
                  mono: true,
                  berat: FontWeight.w500,
                ),
                const BarisInfo('Tanggal transaksi', '01/11/2026'),
                const BarisInfo('Diterima di', 'Ibadah Minggu Pagi'),
                const BarisInfo('Masuk ke peruntukan', 'Umum Jemaat'),
                // Codes are mono (CONVENTIONS, Theme); the board draws sans 600.
                const BarisInfo(
                  'No. Bukti',
                  'BKU-2026-0132',
                  mono: true,
                  berat: FontWeight.w500,
                ),
              ]) ...[const SizedBox(height: 6), b],
            ],
          ),
        ),
        Text(
          'Di Warta Jemaat nama Anda mengikuti Tampilan nama yang Anda pilih: Tanpa nama.',
          style: s13,
        ),
        BarisTombol(
          anak: [
            Tombol(
              'Ubah Tampilan nama',
              onPressed: null,
              ke: 'TampilanNama',
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.sedang,
            ),
            Tombol(
              'Bukan persembahan saya',
              onPressed: () => _ke(_bukan),
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.sedang,
            ),
            Tombol(
              'Kembali',
              onPressed: () => _ke(_ada),
              jenis: JenisTombol.teks,
            ),
          ],
        ),
      ],
      _belum => [
        Kartu(
          status: GarisStatus.draf,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Belum ada persembahan atas nama Anda',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Bila Anda memberi dengan sampul bernama, Bendahara Jemaat mencatatnya atas nama Anda. Persembahan itu tampil di sini setelah dibukukan.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
        ),
      ],
      _bukan => [
        kartu('Sampul syukur', 100000, '01/11/2026 · BKU-2026-0132'),
        IsianTeks(
          label: 'Keterangan · wajib',
          nilaiAwal: 'Saya tidak memberi sampul pada tanggal ini.',
          baris: 3,
          hanyaBaca: true,
          jarakLabel: 6,
          gaya: TextStyle(fontSize: 14, color: c.tinta2),
        ),
        Text(
          'Dikirim ke Bendahara Jemaat. Catatan keuangan tidak berubah; Bendahara yang melepas nama Anda bila memang keliru.',
          style: s13,
        ),
        BarisTombol(
          anak: [
            Tombol(
              'Kirim ke Bendahara Jemaat',
              onPressed: () => _ke(_ada),
              jenis: JenisTombol.tinta,
            ),
            Tombol(
              'Batalkan',
              onPressed: () => _ke(_rincian),
              jenis: JenisTombol.teks,
            ),
          ],
        ),
      ],
      _ => [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: c.lautLembut,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 14),
              children: [
                TextSpan(
                  text: 'Yang melihat halaman ini: Anda dan Bendahara Jemaat.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: ' Penatua, Syamas, Sekretaris Jemaat dan Operator tidak melihatnya.',
                ),
              ],
            ),
          ),
        ),
        // The board's `<a href="PersembahanSaya.dc.html" onClick={{go1}}>`:
        // a self link, so it switches to Rincian in place.
        Tautan(
          ke: _stem,
          radius: 14,
          diSini: () => _ke(_rincian),
          child: kartu(
            'Sampul syukur',
            100000,
            '01/11/2026 · Ibadah Minggu Pagi · Umum Jemaat',
          ),
        ),
        kartu(
          'Persembahan persepuluhan',
          300000,
          '04/10/2026 · Ibadah Minggu Pagi · Umum Jemaat',
        ),
        kartu(
          'Sampul syukur',
          150000,
          '20/09/2026 · Ibadah Minggu Pagi · Diakonia',
        ),
        Text(
          'Persembahan di kantong persembahan tidak dicatat per orang dan tidak tampil di sini. Yang tampil hanya yang sudah Dibukukan.',
          style: s13,
        ),
      ],
    };

    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Persembahan saya',
            anakJudul: 'Hanya persembahan yang dicatat atas nama Anda',
            kembaliKe: 'BerandaJabatan',
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            child: SingleChildScrollView(
              // A new view starts at the top.
              key: ValueKey(v),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, w) in isi.indexed) ...[
                    if (i > 0) const SizedBox(height: 16),
                    w,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
