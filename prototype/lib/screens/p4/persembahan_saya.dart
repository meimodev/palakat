import 'package:flutter/widgets.dart';

import '../../core/format.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

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
    final keadaan = belumDipindah<String>('Ada persembahan bernama');
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
        _BarisTombolTautan(
          anak: [
            Tombol(
              'Ubah Tampilan nama',
              onPressed: null,
              ke: Layar.tampilanNama,
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
          ke: Layar.persembahanSaya,
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
            kembaliKe: Layar.beranda,
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

/// BarisTombol whose first child is an `<a>` link-button. The board's `<a>`
/// is content-box (Chrome's `<button>` is border-box), so its flex-basis 150
/// and max-width 340 grow by padding 32 and border 3: 185 and 375. On the
/// phone the two first-line buttons are then 188.5 and 153.5 wide, as drawn.
class _BarisTombolTautan extends StatelessWidget {
  const _BarisTombolTautan({required this.anak});

  final List<Widget> anak;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, ruang) {
      final lentur = [
        for (final (i, a) in anak.indexed)
          i == 0
              ? Lentur(dasar: 185, maks: 375, child: a)
              : Lentur(dasar: 150, maks: 340, child: a),
      ];
      final semua = BarisLentur.lebar(lentur, 8, ruang.maxWidth);
      var i = 0;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (n, b) in semua.indexed) ...[
            if (n > 0) const SizedBox(height: 8),
            IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (k, w) in b.indexed) ...[
                    if (k > 0) const SizedBox(width: 8),
                    SizedBox(width: w, child: anak[i++]),
                  ],
                ],
              ),
            ),
          ],
        ],
      );
    },
  );
}
