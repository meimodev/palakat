import 'package:flutter/material.dart';

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

/// The `keadaan` options, in board order (`O`).
const _o = [
  'Beranda unit',
  'Dibukukan',
  'Kas/Bank dikelola Bendahara Jemaat',
  'Peruntukan lain',
  'Pernyataan kesiapan',
  'Tutup buku bukan wewenang unit',
];

class KeuanganUnitScreen extends StatefulWidget {
  const KeuanganUnitScreen({super.key});

  @override
  State<KeuanganUnitScreen> createState() => _KeuanganUnitScreenState();
}

class _KeuanganUnitScreenState extends State<KeuanganUnitScreen> {
  /// Set by the board's buttons; null shows the tweak.
  String? _k;
  String? _tweakTadi;

  void _go(int i) => setState(() => _k = _o[i]);

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final tweak = belumDipindah<String>('Beranda unit');
    // A tweak change in the Keadaan panel resets the button-set view.
    if (tweak != _tweakTadi) {
      _tweakTadi = tweak;
      _k = null;
    }
    final ki = _o.indexOf(_k ?? tweak).clamp(0, _o.length - 1);
    final isi = switch (ki) {
      1 => _dibukukan(c),
      2 => _kasJemaat(c),
      3 => _peruntukanLain(c),
      4 => _kesiapan(c),
      5 => _tutupBuku(c),
      _ => _beranda(c),
    };
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(
            judul: 'Keuangan Kolom 7',
            anakJudul: 'Layar keuangan yang sama, terbatas pada peruntukan dan Kas/Bank unit',
            // The board links its back arrow to itself: a reload, so k resets.
            kembaliKe: Layar.keuanganUnit,
            labelKembali: 'Kembali ke Keuangan',
            diSini: () => setState(() => _k = null),
          ),
          Expanded(
            child: SingleChildScrollView(
              // A view change starts the body at the top.
              key: ValueKey(ki),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [_pita(c), ...isi],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pita(PalakatWarna c) => Kartu(
    status: GarisStatus.terpilih,
    radius: 12,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: const Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Keuangan unit: Kolom 7.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: ' Anda membukukan hanya di peruntukan Kolom 7, pada Kas/Bank yang dikelola Kolom 7.',
          ),
        ],
      ),
      style: TextStyle(fontSize: 14),
    ),
  );

  static const _mono = TextStyle(
    fontFamily: PalakatText.mono,
    fontWeight: FontWeight.w500,
  );

  Widget _catatan(PalakatWarna c, String t) =>
      Text(t, style: TextStyle(fontSize: 13, color: c.tinta3));

  Widget _kartu(List<Widget> anak) => Kartu(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: anak,
    ),
  );

  Widget _tinta(String label, int ke) =>
      Tombol(label, jenis: JenisTombol.tinta, onPressed: () => _go(ke));

  Widget _kedua(String label, int ke) => Tombol(
    label,
    jenis: JenisTombol.kedua,
    ukuran: UkuranTombol.sedang,
    onPressed: () => _go(ke),
  );

  List<Widget> _beranda(PalakatWarna c) => [
    _kartu([
      const KepalaKartu(
        judul: 'Kas Kolom 7',
        ujung: Text('Rp1.240.000', style: _mono),
      ),
      _catatan(
        c,
        'Dikelola oleh Kolom 7 · saldo buku, hanya yang sudah dibukukan',
      ),
    ]),
    _kartu([
      const KepalaKartu(
        judul: 'Perlu tindakan',
        ujung: LencanaStatus('2', bentuk: BentukLencana.bata),
      ),
      Text(
        '1 draf belum dibukukan · hitung kas November belum diisi',
        style: TextStyle(fontSize: 14, color: c.tinta2),
      ),
    ]),
    BarisTombol(
      anak: [
        _tinta('Catat transaksi', 1),
        _kedua('Rekonsiliasi Kas Kolom 7', 4),
      ],
    ),
  ];

  List<Widget> _dibukukan(PalakatWarna c) => [
    _kartu([
      // Codes are mono (CONVENTIONS); the board's 700 has no mono cut, so 600.
      const Row(
        children: [
          Expanded(
            child: Text(
              'BKU-2026-0151',
              style: TextStyle(
                fontFamily: PalakatText.mono,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 16),
          LencanaStatus('Dibukukan', bentuk: BentukLencana.tinta),
        ],
      ),
      const _Info('Persembahan Ibadah Kolom', 'Rp320.000', mono: true),
      const _Info('Masuk ke peruntukan', 'Kolom 7'),
      const _Info('Kas/Bank', 'Kas Kolom 7 · dikelola oleh Kolom 7'),
      _catatan(
        c,
        'Dibukukan oleh Deasy Tumbelaka, Bendahara Kolom 7 · 17/11/2026 20.10. No. Bukti dari seri Jemaat yang sama.',
      ),
    ]),
  ];

  List<Widget> _kasJemaat(PalakatWarna c) => [
    _kartu(const [
      KepalaKartu(
        judul: 'Draf · Konsumsi ibadah Kolom',
        ujung: Text('−Rp150.000', style: _mono),
      ),
      _Info('Diambil dari peruntukan', 'Kolom 7'),
      _Info('Kas/Bank', 'Bank BNI ··4821 · dikelola oleh Bendahara Jemaat'),
    ]),
    const Penolakan(
      tindakan: 'Bukukan',
      sebab:
          'Bank BNI ··4821 dikelola oleh Bendahara Jemaat, bukan oleh Kolom 7.',
      jalan: [],
    ),
    _catatan(
      c,
      'Uang Kolom 7 yang ada di Kas/Bank Jemaat dibukukan oleh Bendahara Jemaat.',
    ),
    Tautan(
      ke: Layar.kasUnit,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: const Align(
          alignment: Alignment.centerLeft,
          child: TautanTeks(
            'Kas/Bank mana yang dikelola unit',
            berat: FontWeight.w700,
            ukuran: 14,
          ),
        ),
      ),
    ),
    BarisTombol(
      anak: [
        _tinta('Kirim ke Bendahara Jemaat untuk dibukukan', 0),
        _kedua('Ubah Kas/Bank', 0),
      ],
    ),
  ];

  List<Widget> _peruntukanLain(PalakatWarna c) => [
    _kartu(const [
      KepalaKartu(
        judul: 'Draf · Bantuan duka',
        ujung: Text('−Rp200.000', style: _mono),
      ),
      _Info('Diambil dari peruntukan', 'Diakonia'),
      _Info('Kas/Bank', 'Kas Kolom 7'),
    ]),
    const Penolakan(
      tindakan: 'Bukukan',
      sebab: 'peruntukan Diakonia bukan peruntukan Kolom 7.',
      jalan: [],
    ),
    _catatan(
      c,
      'Bendahara unit tidak membukukan di luar peruntukannya dan tidak membuat Alih peruntukan.',
    ),
    BarisTombol(
      anak: [
        _tinta('Kirim ke Bendahara Jemaat untuk dibukukan', 0),
        _kedua('Ubah peruntukan', 0),
      ],
    ),
  ];

  List<Widget> _kesiapan(PalakatWarna c) => [
    _kartu(const [
      KepalaKartu(
        judul: 'Rekonsiliasi Kas Kolom 7 · Oktober 2026',
        ujung: LencanaStatus('Sudah dipastikan', bentuk: BentukLencana.laut),
      ),
      _Info('Saldo buku', 'Rp920.000', mono: true),
      _Info('Hasil hitung kas', 'Rp920.000', mono: true),
      _Info('Selisih belum dijelaskan', 'Rp0', mono: true),
    ]),
    _kartu([
      const KepalaKartu(
        judul: 'Pernyataan kesiapan · Kolom 7',
        ujung: LencanaStatus('Belum ada', bentuk: BentukLencana.bata),
      ),
      _catatan(
        c,
        'Perubahan pada transaksi Oktober di peruntukan ini membuat pernyataan perlu dinyatakan lagi.',
      ),
      BarisTombol(anak: [_tinta('Nyatakan siap', 0)]),
    ]),
  ];

  List<Widget> _tutupBuku(PalakatWarna c) => [
    const Penolakan(
      tindakan: 'Tutup buku',
      sebab: 'tutup buku dilakukan Bendahara Jemaat untuk seluruh Jemaat.',
      jalan: [],
    ),
    _catatan(
      c,
      'Bendahara unit menyiapkan: membukukan, merekonsiliasi Kas/Bank unit, dan menyatakan siap.',
    ),
  ];
}

/// KitAlur's info row with the label allowed to shrink, as the board's flex
/// spans do (`BarisInfo` keeps its label rigid and overflows on narrow fonts).
/// Money values are mono 14/500.
class _Info extends StatelessWidget {
  const _Info(this.label, this.nilai, {this.mono = false});

  final String label, nilai;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return LayoutBuilder(
      builder: (context, ruang) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ruang.maxWidth * .6),
            child: Text(label, style: TextStyle(fontSize: 14, color: c.tinta2)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              nilai,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                color: c.tinta,
                fontWeight: mono ? FontWeight.w500 : FontWeight.w600,
                fontFamily: mono ? PalakatText.mono : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
